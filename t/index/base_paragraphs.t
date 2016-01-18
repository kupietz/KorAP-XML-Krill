#!/usr/bin/env perl
use strict;
use warnings;
use utf8;
use Test::More;
use lib 't/index';
use TestInit;
use Scalar::Util qw/weaken/;
use Data::Dumper;

ok(my $tokens = TestInit::tokens('0001'), 'Parse tokens');

ok($tokens->add('Base', 'Paragraphs'), 'Add Structure');

my $data = $tokens->to_data->{data};

like($data->{foundries}, qr!base/paragraphs!, 'data');
is($data->{stream}->[0]->[0], '-:base/paragraphs$<i>1', 'Number of paragraphs');
is($data->{stream}->[0]->[1], '-:tokens$<i>18', 'Number of tokens');
is($data->{stream}->[0]->[2], '<>:base/s:p$<b>64<i>0<i>129<i>17<b>1', 'Paragraph');
is($data->{stream}->[0]->[3], '_0$<i>0<i>3', 'Position');

done_testing;

__END__
