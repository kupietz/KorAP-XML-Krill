#!/usr/bin/env perl
use strict;
use warnings;
use FindBin;
use v5.16;
use Getopt::Long;
use Directory::Iterator;

my $local = $FindBin::Bin;

sub printhelp {
  print <<'EOHELP';

Merge foundry data based on a tokenization and create indexer friendly documents
for whole directories.

Call:
wrap_folders.pl -z --input <directory> --output <directory>

--input|-i <directory>          Directory of documents to index
--output|-o <directory>         Name of output folder
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

diewald@ids-mannheim.de, 2013/11/25

EOHELP

  exit(defined $_[0] ? $_[0] : 0);
};

my ($input, $output, $text, $gzip, $log_level, @skip, $token_base, $primary, @allow, $pretty);
GetOptions(
  'input|i=s'   => \$input,
  'output|o=s'  => \$output,
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

printhelp(1) if !$input || !$output;


sub write_file {
  my $anno = shift;
  my $file = $anno;
  $file =~ s/^?\/?$input//;
  $file =~ tr/\//-/;
  $file =~ s{^-+}{};

  my $call = 'perl ' . $local . '/prepare_index.pl -i ' . $anno . ' -o ' . $output . '/' . $file . '.json';
  $call .= '.gz -z' if $gzip;
  $call .= ' -m' if $text;
  $call .= ' -l ' . $log_level if $log_level;
  $call .= ' --no-primary ' if $primary;
  $call .= ' -y ' . $pretty if $pretty;
  $call .= ' -a ' . $_ foreach @allow;
  $call .= ' -s ' . $_ foreach @skip;
  system($call);
};


my $it = Directory::Iterator->new($input);
my $dir;
while (1) {

    if (!$it->is_directory && ($dir = $it->get) && $dir =~ s{/data\.xml$}{}) {
	write_file($dir);
	$it->prune;
    };
  last unless $it->next;
};


__END__