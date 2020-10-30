#!/usr/bin/env perl
use strict;
use warnings;
use utf8;
use Test::More;
use KorAP::XML::Annotation::Mate::Dependency;
use Scalar::Util qw/weaken/;
use Data::Dumper;
use lib 't/annotation';
use TestInit;

ok(my $tokens = TestInit::tokens('0001'), 'Parse tokens');

ok($tokens->add('Mate', 'Dependency'), 'Add Dependency');

my $data = $tokens->to_data->{data}->{stream};

is($data->[4]->[-1], 's:lädt', 'Surface form');
is($data->[4]->[1], '<:mate/d:--$<b>32<i>4', '< rel 1 (unary)');
is($data->[4]->[2], '>:mate/d:--$<b>32<i>4', '> rel 1 (unary)');
#is($data->[4]->[8], 'mate/d:&&&$<b>128<s>1', 'token for rel 1 (unary)');

is($data->[1]->[-1], 's:letzten', 'Surface');
is($data->[1]->[0], '>:mate/d:NK$<b>32<i>3', '> rel 2 (term-to-term)');
#is($data->[1]->[3], 'mate/d:&&&$<b>128<s>1', '< rel 2 (term-to-term)');

is($data->[3]->[-1], 's:Anlass', 'Surface');
is($data->[3]->[1], '<:mate/d:NK$<b>32<i>1', '< rel 2 (term-to-term)');
#is($data->[3]->[5], 'mate/d:&&&$<b>128<s>1', '< rel 2 (term-to-term)');


done_testing;
__END__

