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

ok($tokens->add('Connexor', 'Syntax'), 'Add Structure');

my $data = $tokens->to_data->{data};
like($data->{foundries}, qr!connexor/syntax!, 'data');
like($data->{layerInfos}, qr!cnx/syn=tokens!, 'data');
is($data->{stream}->[1]->[1], 'cnx/syn:@PREMOD', 'Syntax');
is($data->{stream}->[2]->[1], 'cnx/syn:@PREMOD', 'Syntax');

done_testing;

__END__
