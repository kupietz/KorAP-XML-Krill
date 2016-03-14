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

ok($tokens->add('TreeTagger', 'Sentences'), 'Add Structure');

my $data = $tokens->to_data->{data};

#diag Dumper $data;

like($data->{foundries}, qr!treetagger/sentences!, 'data');
is($data->{stream}->[0]->[0], '-:tokens$<i>18', 'Number of tokens');
is($data->{stream}->[0]->[1], '-:tt/sentences$<i>1', 'Number of paragraphs');
is($data->{stream}->[0]->[3], '<>:tt/s:s$<b>64<i>0<i>130<i>17<b>0', 'Text');
is($data->{stream}->[0]->[4], '_0$<i>0<i>3', 'Position');
is($data->{stream}->[-1]->[0], '_17$<i>124<i>128', 'Position');

done_testing;

__END__
