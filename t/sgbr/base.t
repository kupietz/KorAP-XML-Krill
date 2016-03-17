use strict;
use warnings;
use Test::More;
use File::Basename 'dirname';
use File::Spec::Functions 'catdir';
use Data::Dumper;
use KorAP::XML::Tokenizer;
use KorAP::XML::Krill;
use utf8;

my $path = catdir(dirname(__FILE__), 'CMC-TSK', '2014-09', 3401);

ok(my $doc = KorAP::XML::Krill->new(
  path => $path . '/'
), 'Create Document');

ok($doc->parse('Sgbr'), 'Parse document');

ok(my $tokens = KorAP::XML::Tokenizer->new(
  path => $doc->path,
  doc => $doc,
  foundry => 'Sgbr',
  layer => 'Lemma',
  name => 'tokens'
), 'Create tokens based on lemmata');

ok($tokens->parse, 'Parse tokenization based on lemmata');

ok($tokens->add('Base', 'Sentences'), 'Add Sentences');

my $stream = $tokens->to_data->{data}->{stream};

is($stream->[0]->[0], '-:base/sentences$<i>1');
is($stream->[0]->[1], '-:tokens$<i>15');
is($stream->[0]->[2], '<>:base/s:t$<b>64<i>0<i>115<i>14<b>0');
is($stream->[0]->[3], '<>:base/s:s$<b>64<i>16<i>114<i>14<b>2');
is($stream->[0]->[4], '_0$<i>17<i>18');

done_testing;
