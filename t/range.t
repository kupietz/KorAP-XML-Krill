#!/usr/bin/env perl
use strict;
use warnings;
use Test::More;

use_ok('KorAP::XML::Tokenizer::Range');

my $range = KorAP::XML::Tokenizer::Range->new;

# Set a gap from 0 to 2, refering to position 0
$range->gap(0, 2, 0);

# Set a range from 3 to 14, refering to position 0
$range->set(3, 14, 0);

is($range->lookup(3), 0, 'Lookup is fine');

# Set a gap from 15 to 16, refering to position 1
$range->gap(15, 16, 1);
$range->set(17, 20, 1);
$range->set(21, 28, 2);

is($range->lookup(3), 0, 'Lookup is fine');

is($range->lookup(6), 0, 'Lookup is fine');
is($range->lookup(14), 0, 'Lookup is fine');

ok(!$range->lookup(1), 'Lookup is fine');
ok(!$range->lookup(16), 'Lookup is fine');

is($range->before(0), 0, 'Before is fine');
is($range->before(1), 0, 'Before is fine');
is($range->before(2), 0, 'Before is fine');
is($range->before(3), 0, 'Before is fine');
is($range->before(4), 0, 'Before is fine');
is($range->before(15), 0, 'Before is fine');
is($range->before(23), 1, 'Before is fine');

{
  local $SIG{__WARN__} = sub {};
  ok(!$range->before(590), 'No range here');
};

is($range->after(0), 0, 'After is fine');
is($range->after(1), 0, 'After is fine');
is($range->after(2), 0, 'After is fine');
is($range->after(3), 1, 'After is fine');
is($range->after(14), 1, 'After is fine');
is($range->after(15), 1, 'After is fine');

is($range->to_string,
   '[0,2,!-1:0][3,14,0][15,16,!0:1][17,20,1][21,28,2][29,100,...]...',
   'ToString is fine');

done_testing;

__END__
