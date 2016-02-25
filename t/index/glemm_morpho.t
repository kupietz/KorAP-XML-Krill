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

ok($tokens->add('Glemm', 'Morpho'), 'Add Structure');

my $data = $tokens->to_data->{data};

like($data->{foundries}, qr!glemm/morpho!, 'data');
like($data->{layerInfos}, qr!glemm/l=tokens!, 'data');

is($data->{stream}->[0]->[1], '<>:base/s:t$<b>64<i>0<i>129<i>17<b>0', 'Text boundary');
is($data->{stream}->[0]->[3], 'glemm/l:__zu', 'Lemma');
is($data->{stream}->[1]->[1], 'glemm/l:__letzt-', 'Lemma');

is($data->{stream}->[3]->[1], 'glemm/l:_+an-', 'Lemma');
is($data->{stream}->[3]->[2], 'glemm/l:_+lass', 'Lemma');
is($data->{stream}->[3]->[3], 'glemm/l:__Anlass', 'Lemma');

is($data->{stream}->[6]->[1], 'glemm/l:_+-ung', 'Lemma');
is($data->{stream}->[6]->[2], 'glemm/l:_+leiten', 'Lemma');
is($data->{stream}->[6]->[3], 'glemm/l:__Leitung', 'Lemma');

is($data->{stream}->[-1]->[1], 'glemm/l:__werden', 'Lemma');

done_testing;

__END__
