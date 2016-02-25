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

ok($tokens->add('CoreNLP', 'Morpho'), 'Add Structure');

my $data = $tokens->to_data->{data};
like($data->{foundries}, qr!corenlp/morpho!, 'data');
like($data->{layerInfos}, qr!corenlp/p=tokens!, 'data');
is($data->{stream}->[0]->[1], '<>:base/s:t$<b>64<i>0<i>129<i>17<b>0', 'Text boundary');
is($data->{stream}->[0]->[3], 'corenlp/p:APPRART', 'POS');
is($data->{stream}->[1]->[1], 'corenlp/p:ADJ', 'POS');
is($data->{stream}->[2]->[1], 'corenlp/p:ADJA', 'POS');

done_testing;

__END__
