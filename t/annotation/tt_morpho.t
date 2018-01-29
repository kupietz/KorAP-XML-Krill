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

ok($tokens->add('TreeTagger', 'Morpho'), 'Add Structure');

my $data = $tokens->to_data->{data};

like($data->{foundries}, qr!treetagger/morpho!, 'data');
like($data->{layerInfos}, qr!tt/p=tokens!, 'data');
like($data->{layerInfos}, qr!tt/l=tokens!, 'data');

is($data->{stream}->[0]->[5], 'tt/l:zum', 'POS');
is($data->{stream}->[0]->[6], 'tt/p:APPRART$<b>129<b>255', 'POS');

is($data->{stream}->[3]->[3], 'tt/l:Anlaß', 'POS');
is($data->{stream}->[3]->[4], 'tt/p:NN$<b>129<b>255', 'POS');

is($data->{stream}->[10]->[3], 'tt/l:ein', 'POS');
is($data->{stream}->[10]->[4], 'tt/p:PTKVZ$<b>129<b>253', 'POS');

is($data->{stream}->[-1]->[3], 'tt/l:werden', 'POS');
is($data->{stream}->[-1]->[4], 'tt/p:VAFIN$<b>129<b>255', 'POS');

is($data->{stream}->[11]->[3], 'tt/l:bevor', 'Lemma');
is($data->{stream}->[11]->[4], 'tt/p:KOUS$<b>129<b>254', 'Lemma');


done_testing;

__END__

