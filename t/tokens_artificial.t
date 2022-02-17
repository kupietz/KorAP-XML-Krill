use strict;
use warnings;
use utf8;
use Test::More;
use Benchmark ':hireswallclock';
use Mojo::DOM;
use Mojo::File;
use Mojo::ByteStream 'b';
use Data::Dumper;
use File::Basename 'dirname';
use File::Spec::Functions 'catdir';
use lib 'lib', '../lib';

use_ok('KorAP::XML::Krill');

# ART
my $path = catdir(dirname(__FILE__), 'corpus','artificial');
ok(my $doc = KorAP::XML::Krill->new( path => $path . '/' ), 'Load Korap::Document');

ok($doc->parse, 'Parse document');

$doc->parse;

my $tokens = KorAP::XML::Tokenizer->new(
  path => $doc->path,
  doc => $doc,
  foundry => 'OpenNLP',
  layer => 'tokens_wrong',
  name => 'Tokens'
);

# Order is wrong!
ok(!$tokens->parse, 'Parse tokens');

done_testing;
__END__

