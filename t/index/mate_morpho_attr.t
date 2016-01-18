#!/usr/bin/env perl
use strict;
use warnings;
use utf8;
use Test::More;
use Scalar::Util qw/weaken/;
use Data::Dumper;
use lib 't/index';
use TestInit;

ok(my $tokens = TestInit::tokens('0001'), 'Parse tokens');

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
