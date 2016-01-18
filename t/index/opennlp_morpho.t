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

ok($tokens->add('OpenNLP', 'Morpho'), 'Add Structure');

my $data = $tokens->to_data->{data};

like($data->{foundries}, qr!opennlp/morpho!, 'data');
is($data->{stream}->[0]->[1], '_0$<i>0<i>3', 'Position');
is($data->{stream}->[0]->[3], 'opennlp/p:APPRART', 'POS');
is($data->{stream}->[1]->[2], 'opennlp/p:ADJA', 'POS');
is($data->{stream}->[2]->[2], 'opennlp/p:ADJA', 'POS');
is($data->{stream}->[-1]->[2], 'opennlp/p:VAFIN', 'POS');

done_testing;

__END__

