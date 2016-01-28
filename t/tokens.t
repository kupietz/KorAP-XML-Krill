use strict;
use warnings;
use utf8;
use Test::More;
use Benchmark ':hireswallclock';
use lib 'lib', '../lib';

use_ok('KorAP::XML::Field::MultiTerm');

ok(my $term = KorAP::XML::Field::MultiTerm->new(
  term => 'Baum',
  p_start => 0,
  p_end => 56,
  payload => '<i>56',
  o_start => 34,
  o_end => 120
), 'Create new object');

is($term->term, 'Baum');
is($term->p_start, 0);
is($term->p_end, 56);
is($term->o_start, 34);
is($term->o_end, 120);
is($term->payload, '<i>56');
is($term->to_string, 'Baum$<i>34<i>120<i>56<i>56');

ok($term = KorAP::XML::Field::MultiTerm->new(
  term => 'Baum'
), 'Create new object');

is($term->term, 'Baum');
is($term->p_start, 0);
is($term->p_end, 0);
is($term->o_start, 0);
is($term->o_end, 0);
is($term->payload, undef);
is($term->to_string, 'Baum');

ok($term = KorAP::XML::Field::MultiTerm->new(
  term => 'Ba#um'
), 'Create new object');

is($term->term, 'Ba#um');
is($term->p_start, 0);
is($term->p_end, 0);
is($term->o_start, 0);
is($term->o_end, 0);
is($term->payload, undef);
is($term->to_string, 'Ba\#um');

ok($term = KorAP::XML::Field::MultiTerm->new(
  term => 'Ba#u$m',
  payload => '<i>45'
), 'Create new object');

is($term->term, 'Ba#u$m');
is($term->p_start, 0);
is($term->p_end, 0);
is($term->o_start, 0);
is($term->o_end, 0);
is($term->payload, '<i>45');
is($term->to_string, 'Ba\#u\$m$<i>45');

done_testing;
__END__
