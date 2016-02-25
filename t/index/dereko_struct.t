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

ok($tokens->add('DeReKo', 'Structure'), 'Add Structure');

my $data = $tokens->to_data->{data};

like($data->{foundries}, qr!dereko/structure!, 'data');
like($data->{layerInfos}, qr!dereko/s=spans!, 'data');

# Empty element (from 0 to 0) on level 1, with TUI 2
is($data->{stream}->[0]->[1],
   '<>:dereko/s:idsHeader$<b>65<i>0<i>0<i>0<b>1<s>2',
   'Empty element');


is($data->{stream}->[0]->[5], '<>:base/s:t$<b>64<i>0<i>129<i>17<b>0', 'Text boundary');

# Attributes:
is($data->{stream}->[0]->[11],
   '@:dereko/s:type:text$<b>17<s>2',
   'Attribute of idsHeader');

is($data->{stream}->[0]->[12],
   '@:dereko/s:status:new$<b>17<s>2',
   'Attribute of idsHeader');

is($data->{stream}->[0]->[13],
   '@:dereko/s:version:1.1$<b>17<s>2',
   'Attribute of idsHeader');



is($data->{stream}->[0]->[14],
   '@:dereko/s:pattern:text$<b>17<s>2',
   'Attribute of idsHeader');

is($data->{stream}->[4]->[1],
   '<>:dereko/s:s$<b>64<i>32<i>42<i>6<b>6<s>1',
   'Sentence span');

is($data->{stream}->[4]->[2],
   '@:dereko/s:broken:no$<b>17<s>1<i>6',
   'Attribute of sentence span');

is($data->{stream}->[6]->[0],
   '<>:dereko/s:pb$<b>65<i>42<i>42<i>6<b>6<s>1',
   'Pagebreak element');

done_testing;

__END__
