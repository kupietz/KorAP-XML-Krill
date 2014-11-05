#!/usr/bin/env perl
use strict;
use warnings;
use lib 'lib', '../lib';
use Getopt::Long;
use Benchmark qw/:hireswallclock/;
use IO::Compress::Gzip qw/$GzipError/;
use Log::Log4perl;
use KorAP::Document;
use KorAP::Tokenizer;

our $VERSION = 0.03;

# Merges foundry data to create indexer friendly documents
# ndiewald, 2014/10/29

sub printhelp {
  print <<'EOHELP';

Merge foundry data based on a tokenization and create indexer friendly documents.

Call:
prepare_index.pl -z --input <directory> --output <filename>

--input|-i <directory>          Directory of the document to index
--output|-o <filename>          Document name for output (optional),
                                Writes to <STDOUT> by default
--overwrite|-w                  Overwrite files that already exist
--token|-t <foundry>[#<layer>]  Define the default tokenization by specifying
                                the name of the foundry and optionally the name
                                of the layer. Defaults to OpenNLP#tokens.
--skip|-s <foundry>[#<layer>]   Skip specific foundries by specifying the name
                                or specific layers by defining the name
                                with a # in front of the foundry,
                                e.g. Mate#Morpho. Alternatively you can skip #ALL.
                                Can be set multiple times.
--allow|-a <foundry>#<layer>    Allow specific foundries and layers by defining them
                                combining the foundry name with a # and the layer name.
--primary|-p                    Output primary data or not. Defaults to true.
                                Can be flagged using --no-primary as well.
--human|-m                      Represent the data human friendly,
                                while the output defaults to JSON
--pretty|-y                     Pretty print json output
--gzip|-z                       Compress the output
                                (expects a defined output file)
--log|-l                        The Log4perl log level, defaults to ERROR.
--help|-h                       Print this document (optional)

diewald@ids-mannheim.de, 2014/11/05

EOHELP
  exit(defined $_[0] ? $_[0] : 0);
};

# Options from the command line
my ($input, $output, $text, $gzip, $log_level, @skip, $token_base,
    $primary, @allow, $pretty, $overwrite);
GetOptions(
  'input|i=s'   => \$input,
  'output|o=s'  => \$output,
  'overwrite|w' => \$overwrite,
  'human|m'     => \$text,
  'token|t=s'   => \$token_base,
  'gzip|z'      => \$gzip,
  'skip|s=s'    => \@skip,
  'log|l=s'     => \$log_level,
  'allow|a=s'   => \@allow,
  'primary|p!'  => \$primary,
  'pretty|y'    => \$pretty,
  'help|h'      => sub { printhelp }
);

printhelp(1) if !$input || ($gzip && !$output);

$log_level //= 'ERROR';

my %skip;
$skip{lc($_)} = 1 foreach @skip;

Log::Log4perl->init({
  'log4perl.rootLogger' => uc($log_level) . ', STDERR',
  'log4perl.appender.STDERR' => 'Log::Log4perl::Appender::ScreenColoredLevels',
  'log4perl.appender.STDERR.layout' => 'PatternLayout',
  'log4perl.appender.STDERR.layout.ConversionPattern' => '[%r] %F %L %c - %m%n'
});

my $log = Log::Log4perl->get_logger('main');

# Ignore processing
if (!$overwrite && $output && -e $output) {
  $log->trace($output . ' already exists');
  exit(0);
};

BEGIN {
  $main::TIME = Benchmark->new;
  $main::LAST_STOP = Benchmark->new;
};

sub stop_time {
  my $new = Benchmark->new;
  $log->trace(
    'The code took: '.
      timestr(timediff($new, $main::LAST_STOP)) .
	' (overall: ' . timestr(timediff($new, $main::TIME)) . ')'
      );
  $main::LAST_STOP = $new;
};

# Call perl script/prepare_index.pl WPD/AAA/00001

# Create and parse new document
$input =~ s{([^/])$}{$1/};
my $doc = KorAP::Document->new( path => $input );

unless ($doc->parse) {
  $log->trace($output . " can't be processed");
  exit(0);
};

my ($token_base_foundry, $token_base_layer) = (qw/OpenNLP Tokens/);
if ($token_base) {
  ($token_base_foundry, $token_base_layer) = split /#/, $token_base;
};

# Get tokenization
my $tokens = KorAP::Tokenizer->new(
  path => $doc->path,
  doc => $doc,
  foundry => $token_base_foundry,
  layer => $token_base_layer,
  name => 'tokens'
);

# Unable to process base tokenization
unless ($tokens->parse) {
  $log->trace($output . " can't be processed");
  exit(0);
};

my @layers;
push(@layers, ['Base', 'Sentences']);
push(@layers, ['Base', 'Paragraphs']);

# OpenNLP
push(@layers, ['OpenNLP', 'Morpho']);
push(@layers, ['OpenNLP', 'Sentences']);

# CoreNLP
push(@layers, ['CoreNLP', 'NamedEntities']);
push(@layers, ['CoreNLP', 'Sentences']);
push(@layers, ['CoreNLP', 'Morpho']);
push(@layers, ['CoreNLP', 'Constituency']);

# Glemm
push(@layers, ['Glemm', 'Morpho']);

# Connexor
push(@layers, ['Connexor', 'Morpho']);
push(@layers, ['Connexor', 'Syntax']);
push(@layers, ['Connexor', 'Phrase']);
push(@layers, ['Connexor', 'Sentences']);

# TreeTagger
push(@layers, ['TreeTagger', 'Morpho']);
push(@layers, ['TreeTagger', 'Sentences']);

# Mate
push(@layers, ['Mate', 'Morpho']);
# push(@layers, ['Mate', 'Dependency']);

# XIP
push(@layers, ['XIP', 'Morpho']);
push(@layers, ['XIP', 'Constituency']);
push(@layers, ['XIP', 'Sentences']);
# push(@layers, ['XIP', 'Dependency']);


if ($skip{'#all'}) {
  foreach (@allow) {
    $tokens->add(split('#', $_));
    stop_time;
  };
}
else {
  # Add to index file - respect skipping
  foreach my $info (@layers) {
    unless ($skip{lc($info->[0]) . '#' . lc($info->[1])}) {
      $tokens->add(@$info);
      stop_time;
    };
  };
};

my $file;

my $print_text = $text ? $tokens->to_string($primary) :
  ($pretty ? $tokens->to_pretty_json($primary) : $tokens->to_json($primary));

if ($output) {

  if ($gzip) {
    $file = IO::Compress::Gzip->new($output, Minimal => 1);
  }
  else {
    $file = IO::File->new($output, "w");
  };

  $file->print($print_text);
  $file->close;
}

else {
  print $print_text . "\n";
};

stop_time;

__END__
