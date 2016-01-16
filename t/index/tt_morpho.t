#!/usr/bin/env perl
use strict;
use warnings;
use utf8;
use Test::More;
use Scalar::Util qw/weaken/;
use Data::Dumper;

use_ok('KorAP::Document');

use File::Basename 'dirname';
use File::Spec::Functions 'catdir';

my $path = catdir(dirname(__FILE__), 'corpus', 'doc', '0001');

ok(my $doc = KorAP::Document->new(
  path => $path . '/'
), 'Load Korap::Document');

like($doc->path, qr!$path/$!, 'Path');
ok($doc->parse, 'Parse document');

ok($doc->primary->data, 'Primary data in existence');
is($doc->primary->data_length, 129, 'Data length');

use_ok('KorAP::Tokenizer');

ok(my $tokens = KorAP::Tokenizer->new(
  path => $doc->path,
  doc => $doc,
  foundry => 'OpenNLP',
  layer => 'Tokens',
  name => 'tokens'
), 'New Tokenizer');

ok($tokens->parse, 'Parse');

ok($tokens->add('TreeTagger', 'Morpho'), 'Add Structure');

my $data = $tokens->to_data->{data};

like($data->{foundries}, qr!treetagger/morpho!, 'data');
like($data->{layerInfos}, qr!tt/p=tokens!, 'data');
like($data->{layerInfos}, qr!tt/l=tokens!, 'data');

is($data->{stream}->[0]->[4], 'tt/l:zum$<b>129<b>255', 'POS');
is($data->{stream}->[0]->[5], 'tt/p:APPRART$<b>129<b>255', 'POS');

is($data->{stream}->[3]->[3], 'tt/l:Anlaß$<b>129<b>255', 'POS');
is($data->{stream}->[3]->[4], 'tt/p:NN$<b>129<b>255', 'POS');

is($data->{stream}->[10]->[3], 'tt/l:ein$<b>129<b>253', 'POS');
is($data->{stream}->[10]->[4], 'tt/p:PTKVZ$<b>129<b>253', 'POS');

is($data->{stream}->[-1]->[3], 'tt/l:werden$<b>129<b>255', 'POS');
is($data->{stream}->[-1]->[4], 'tt/p:VAFIN$<b>129<b>255', 'POS');

done_testing;

__END__

