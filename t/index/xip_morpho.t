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

ok($tokens->add('XIP', 'Morpho'), 'Add Structure');

my $data = $tokens->to_data->{data};

like($data->{foundries}, qr!xip/morpho!, 'data');
like($data->{layerInfos}, qr!xip/l=tokens!, 'data');
like($data->{layerInfos}, qr!xip/p=tokens!, 'data');
is($data->{stream}->[0]->[5], 'xip/l:zu', 'Lemma');
is($data->{stream}->[0]->[6], 'xip/p:PREP', 'POS');

is($data->{stream}->[1]->[3], 'xip/l:letzt', 'Lemma');
is($data->{stream}->[1]->[4], 'xip/p:ADJ', 'POS');

is($data->{stream}->[8]->[3], 'xip/l:\#Heim', 'Lemma (part)');
is($data->{stream}->[8]->[4], 'xip/l:\#schulen', 'Lemma (part)');
is($data->{stream}->[8]->[5], 'xip/l:schulen\#Heim', 'Lemma (part)');

is($data->{stream}->[-1]->[3], 'xip/l:werden', 'Lemma');
is($data->{stream}->[-1]->[4], 'xip/p:VERB', 'POS');

done_testing;

__END__

