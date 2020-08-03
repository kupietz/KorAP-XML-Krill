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

ok($tokens->add('Sgbr', 'Lemma'), 'Add Structure');

my $data = $tokens->to_data->{data};

my $stream = $data->{stream};
is($stream->[0]->[0], '-:tokens$<i>51', 'Token number');
is($stream->[0]->[1], '<>:base/s:t$<b>64<i>0<i>365<i>51<b>0', 'Text Boundary');
is($stream->[0]->[2], '_0$<i>0<i>18', 'Position');
is($stream->[0]->[3], 'i:sommerüberraschung', 'First term');
is($stream->[0]->[4], 's:Sommerüberraschung', 'First term');
is($stream->[0]->[5], 'sgbr/l:Sommerüberraschung', 'First term');
ok(!defined $stream->[0]->[6], 'First term');

is($stream->[1]->[0], '_1$<i>19<i>21', 'Position');
is($stream->[1]->[1], 'i:es', 'Second term');
is($stream->[1]->[2], 's:Es', 'Second term');
is($stream->[1]->[3], 'sgbr/l:es', 'Second term');
is($stream->[1]->[4], 'sgbr/lv:er', 'Second term');
is($stream->[1]->[5], 'sgbr/lv:sie', 'Second term');

is($stream->[16]->[0], '_16$<i>107<i>115', 'Position');
is($stream->[16]->[1], 'i:guenther', '16th term');
is($stream->[16]->[2], 's:Guenther', '16th term');
is($stream->[16]->[3], 'sgbr/l:Günther', '16th term');
is($stream->[16]->[4], 'sgbr/lv:Günter', '16th term');

is($stream->[-1]->[0], '_50$<i>359<i>364', 'Position');
is($stream->[-1]->[1], 'i:kevin', 'Last term');
is($stream->[-1]->[2], 's:Kevin', 'Last term');
is($stream->[-1]->[3], 'sgbr/l:Kevin', 'Last term');


# Real data 1
$path = catdir(dirname(__FILE__), 'CMC-TSK', '2014-09', '2843');

ok($doc = KorAP::XML::Krill->new(
  path => $path . '/'
), 'Create Document');

ok($doc->parse, 'Parse document');

ok($tokens = KorAP::XML::Tokenizer->new(
  path => $doc->path,
  doc => $doc,
  foundry => 'Sgbr',
  layer => 'Lemma',
  name => 'tokens'
), 'Create tokens based on lemmata');

ok($tokens->parse, 'Parse tokenization based on lemmata');

ok(!$tokens->add('Sgbr', 'Lemma'), 'Add Structure impossible - no token data');


# Real data 2
$path = catdir(dirname(__FILE__), 'CMC-TSK', '2014-09', '3401');

ok($doc = KorAP::XML::Krill->new(
  path => $path . '/'
), 'Create Document');

ok($doc->parse, 'Parse document');

ok($tokens = KorAP::XML::Tokenizer->new(
  path => $doc->path,
  doc => $doc,
  foundry => 'Sgbr',
  layer => 'Lemma',
  name => 'tokens'
), 'Create tokens based on lemmata');

ok($tokens->parse, 'Parse tokenization based on lemmata');

ok($tokens->add('Sgbr', 'Lemma'), 'Add Structure');

done_testing;

__END__
