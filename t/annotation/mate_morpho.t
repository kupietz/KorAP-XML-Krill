#!/usr/bin/env perl
use strict;
use warnings;
use utf8;
use Test::More;
use Scalar::Util qw/weaken/;
use Data::Dumper;
use lib 't/annotation';
use TestInit;

ok(my $tokens = TestInit::tokens('0001'), 'Parse tokens');

ok($tokens->add('Mate', 'Morpho'), 'Add Structure');

my $data = $tokens->to_data->{data};

like($data->{foundries}, qr!mate/morpho!, 'data');
like($data->{layerInfos}, qr!mate/p=tokens!, 'data');
like($data->{layerInfos}, qr!mate/l=tokens!, 'data');
like($data->{layerInfos}, qr!mate/m=tokens!, 'data');

is($data->{stream}->[0]->[1], '<>:base/s:t$<b>64<i>0<i>129<i>17<b>0', 'Text boundary');
is($data->{stream}->[0]->[4], 'mate/l:zu', 'POS');
is($data->{stream}->[0]->[5], 'mate/m:case:dat', 'POS');
is($data->{stream}->[0]->[6], 'mate/m:gender:neut', 'POS');
is($data->{stream}->[0]->[7], 'mate/m:number:sg', 'POS');
is($data->{stream}->[0]->[8], 'mate/p:APPRART', 'POS');

is($data->{stream}->[-1]->[2], 'mate/l:werden', 'POS');
is($data->{stream}->[-1]->[3], 'mate/m:mood:ind', 'POS');
is($data->{stream}->[-1]->[4], 'mate/m:number:sg', 'POS');
is($data->{stream}->[-1]->[5], 'mate/m:person:3', 'POS');
is($data->{stream}->[-1]->[6], 'mate/m:tense:pres', 'POS');
is($data->{stream}->[-1]->[7], 'mate/p:VAFIN', 'POS');

done_testing;

__END__
