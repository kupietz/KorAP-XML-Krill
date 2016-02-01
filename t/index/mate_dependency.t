#!/usr/bin/env perl
use strict;
use warnings;
use utf8;
use Test::More; # skip_all => 'Not yet implemented';
use Scalar::Util qw/weaken/;
use Data::Dumper;
use lib 't/index';
use TestInit;

ok(my $tokens = TestInit::tokens('0001'), 'Parse tokens');

ok($tokens->add('Mate', 'Dependency'), 'Add Dependency');

my $data = $tokens->to_data->{data}->{stream};

# Unary relation
is($data->[4]->[3], '<:mate/d:--$<b>32<i>4<s>1<s>1', '< rel 1 (unary)');
is($data->[4]->[4], '>:mate/d:--$<b>32<i>4<s>1<s>1', '> rel 1 (unary)');
is($data->[4]->[7], 'mate/d:NODE$<b>128<s>1', 'token for rel 1 (unary)');

is($data->[1]->[0], '>:mate/d:NK$<b>32<i>3<s>1<s>1', '> rel 2 (term-to-term)');
is($data->[1]->[3], 'mate/d:NODE$<b>128<s>1', '< rel 2 (term-to-term)');
is($data->[3]->[1], '<:mate/d:NK$<b>32<i>3<s>1<s>1', '< rel 2 (term-to-term)');
is($data->[3]->[4], 'mate/d:NODE$<b>128<s>1', '< rel 2 (term-to-term)');

done_testing;

__END__

