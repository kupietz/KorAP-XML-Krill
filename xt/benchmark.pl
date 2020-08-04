#!/usr/bin/env perl
use strict;
use warnings;
use Dumbbench;
use File::Basename 'dirname';
use File::Spec::Functions qw/catfile catdir rel2abs/;
use File::Temp ':POSIX';
use FindBin;
use Getopt::Long;

BEGIN {
  unshift @INC, "$FindBin::Bin/../lib";
};

my $columns = 0;
my $no_header = 0;
GetOptions(
  'columns|c' => \$columns,
  'no-header|n' => \$no_header,
  'help|h' => sub {
    print "--columns|-c     Print instances in columns\n";
    print "--no-header|-n   Dismiss benchmark names\n";
    print "--help|-h        Print this page\n\n";
    exit(0);
  }
);

our $SCRIPT_NAME = 'korapxml2krill';

my $f = dirname(__FILE__);
my $script = rel2abs(catfile($f, '..', 'script', $SCRIPT_NAME));


# begin instance 1 setup
# Load example file
my $input = rel2abs(catdir($f, '..', 't', 'annotation', 'corpus', 'doc', '0001'));
my $output = tmpnam();
my $cache = tmpnam();
# end instance 1


# begin instance 2 setup
# Load example file
use KorAP::XML::Krill;
use KorAP::XML::Tokenizer;
my $path = catdir(dirname(__FILE__), '..','t','real', 'corpus','GOE-TAGGED','AGA','03828');
my ($tokens, $result);
# end instance 2


# Create a new benchmark object
my $bench = Dumbbench->new(
  verbosity => 0
);

# Add benchmark instances
$bench->add_instances(
  Dumbbench::Instance::PerlSub->new(
    name => 'Script-ExampleRun-1',
    code => sub {
      my $cmd = join(
        ' ',
        'perl', $script,
        '--input' => $input,
        '--output' => $output,
        '--cache' => $cache,
        '-k' => '0.03',
        '-t' => 'OpenNLP#Tokens',
        '-l' => 'ERROR',
        '>' => '/dev/null'
      );
      `$cmd`;
    }
  ),
  Dumbbench::Instance::PerlSub->new(
    name => 'Script-Conversion-GOE-Tagged-1',
    code => sub {
      my $doc = KorAP::XML::Krill->new(path => $path . '/');
      $doc->parse;
      my $meta = $doc->meta;
      $tokens = KorAP::XML::Tokenizer->new(
        path => $doc->path,
        doc => $doc,
        foundry => 'Base',
        layer => 'Tokens_conservative',
        name => 'tokens'
      );
      $tokens->parse;
      $tokens->add('DeReKo', 'Structure', 'base_sentences_paragraphs');
      $tokens->add('DRuKoLa', 'Morpho');
      $result = $tokens->to_data;
      $tokens = undef;
    }
  ),
  Dumbbench::Instance::PerlSub->new(
    name => 'Conversion-GOE-Tagged-1',
    code => sub {
      my $doc = KorAP::XML::Krill->new(path => $path . '/');
      $doc->parse;
      my $meta = $doc->meta;
      $tokens = KorAP::XML::Tokenizer->new(
        path => $doc->path,
        doc => $doc,
        foundry => 'Base',
        layer => 'Tokens_conservative',
        name => 'tokens'
      );
      $tokens->parse;
      $tokens->add('DeReKo', 'Structure', 'base_sentences_paragraphs');
      $tokens->add('DRuKoLa', 'Morpho');
      $result = $tokens->to_data;
      $tokens = undef;
    }
  )
);

# Run benchmarks
$bench->run;

# Output in a single row
if ($columns) {
  unless ($no_header) {
    print join("\t", map { $_->name } $bench->instances), "\n";
  };
  print join("\t", map { $_->result->raw_number } $bench->instances), "\n";
  exit(0);
};

print "----------------------------------\n";

# Output simple timings for comparation
foreach my $inst ($bench->instances) {
  unless ($no_header) {
    print $inst->name, ': ';
  };
  print $inst->result->raw_number, "\n";
};

exit(0);
