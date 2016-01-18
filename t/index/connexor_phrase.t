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

ok($tokens->add('Connexor', 'Phrase'), 'Add Structure');

my $data = $tokens->to_data->{data};

like($data->{foundries}, qr!connexor/phrase!, 'data');
is($data->{stream}->[1]->[0], '<>:cnx/c:np$<b>64<i>4<i>30<i>4<b>0', 'Noun phrase');

done_testing;

__END__
