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

ok($tokens->add('OpenNLP', 'Sentences'), 'Add Structure');

my $data = $tokens->to_data->{data};

like($data->{foundries}, qr!opennlp/sentences!, 'data');
is($data->{stream}->[0]->[0], '-:opennlp/sentences$<i>1', 'Number of Sentences');
is($data->{stream}->[0]->[1], '-:tokens$<i>18', 'Number of tokens');
is($data->{stream}->[0]->[3], '<>:opennlp/s:s$<b>64<i>0<i>129<i>18<b>0', 'Sentence');
is($data->{stream}->[0]->[4], '_0$<i>0<i>3', 'Position');

done_testing;

__END__
