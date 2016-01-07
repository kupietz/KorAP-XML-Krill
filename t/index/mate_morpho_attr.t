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

my $path = catdir(dirname(__FILE__), 'corpus', 'doc', 'text');

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

ok($tokens->add('Mate', 'MorphoAttr'), 'Add Structure');

my $data = $tokens->to_data->{data};

like($data->{foundries}, qr!mate/morphoattr!, 'data');
like($data->{layerInfos}, qr!mate/p=tokens!, 'data');
like($data->{layerInfos}, qr!mate/l=tokens!, 'data');

is($data->{stream}->[0]->[1], '@:gender=neut$<b>16<s>1', 'POS');
is($data->{stream}->[0]->[2], '@:number=sg$<b>16<s>1', 'POS');
is($data->{stream}->[0]->[3], '@:case=dat$<b>16<s>1', 'POS');
is($data->{stream}->[0]->[6], 'mate/l:zu', 'Lemmata');
is($data->{stream}->[0]->[7], 'mate/p:APPRART$<b>128<s>1', 'POS');

is($data->{stream}->[-1]->[0], '@:mood=ind$<b>16<s>1', 'POS');
is($data->{stream}->[-1]->[1], '@:tense=pres$<b>16<s>1', 'POS');
is($data->{stream}->[-1]->[2], '@:person=3$<b>16<s>1', 'POS');
is($data->{stream}->[-1]->[3], '@:number=sg$<b>16<s>1', 'POS');
is($data->{stream}->[-1]->[6], 'mate/l:werden', 'Lemmata');
is($data->{stream}->[-1]->[7], 'mate/p:VAFIN$<b>128<s>1', 'POS');

done_testing;

__END__
