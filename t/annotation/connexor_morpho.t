#!/usr/bin/env perl
use strict;
use warnings;
use utf8;
use Test::More;
use lib 't/annotation';
use TestInit;
use Scalar::Util qw/weaken/;
use Data::Dumper;

ok(my $tokens = TestInit::tokens('0001'), 'Parse tokens');

ok($tokens->add('Connexor', 'Morpho'), 'Add Structure');

my $data = $tokens->to_data->{data};
like($data->{foundries}, qr!connexor/morpho!, 'data');
is($data->{stream}->[0]->[1], '<>:base/s:t$<b>64<i>0<i>129<i>18<b>0', 'Text boundary');
is($data->{stream}->[0]->[2], '_0$<i>0<i>3', 'Position');
is($data->{stream}->[1]->[1], 'cnx/l:letzt', 'Lemma');
is($data->{stream}->[1]->[2], 'cnx/p:A', 'POS');
is($data->{stream}->[2]->[1], 'cnx/l:kulturell', 'Lemma');
is($data->{stream}->[2]->[2], 'cnx/p:A', 'POS');
is($data->{stream}->[4]->[2], 'cnx/m:IND', 'Morpho');
is($data->{stream}->[4]->[3], 'cnx/m:PRES', 'Morpho');

is($data->{stream}->[-1]->[2], 'cnx/m:IND', 'Morpho');
is($data->{stream}->[-1]->[3], 'cnx/m:PRES', 'Morpho');

done_testing;

__END__
