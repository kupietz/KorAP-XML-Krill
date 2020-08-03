use strict;
use warnings;
use Test::More;
use File::Basename 'dirname';
use File::Spec::Functions 'catdir';
use Data::Dumper;
use KorAP::XML::Tokenizer;
use KorAP::XML::Krill;
use utf8;

if ($ENV{SKIP_REAL}) {
  plan skip_all => 'Skip real tests';
};

my $path = catdir(dirname(__FILE__), 'TEST', 'BSP', 1);

ok(my $doc = KorAP::XML::Krill->new(
  path => $path . '/'
), 'Create Document');

ok($doc->parse, 'Parse document');

ok(my $tokens = KorAP::XML::Tokenizer->new(
  path => $doc->path,
  doc => $doc,
  foundry => 'Sgbr',
  layer => 'Lemma',
  name => 'tokens'
), 'Create tokens based on lemmata');

ok($tokens->parse, 'Parse tokenization based on lemmata');

my $data = $tokens->to_data->{data};

my $stream = $data->{stream};

is($stream->[0]->[0], '-:tokens$<i>51', 'Token number');
is($stream->[0]->[2], '_0$<i>0<i>18', 'Position');
is($stream->[0]->[3], 'i:sommerüberraschung', 'First term');
is($stream->[0]->[4], 's:Sommerüberraschung', 'First term');
is($stream->[-1]->[0], '_50$<i>359<i>364', 'Last position');
is($stream->[-1]->[1], 'i:kevin', 'Last term');
is($stream->[-1]->[2], 's:Kevin', 'Last term');

done_testing;
