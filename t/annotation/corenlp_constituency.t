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

ok($tokens->add('CoreNLP', 'Constituency'), 'Add Structure');

my $data = $tokens->to_data->{data};

like($data->{foundries}, qr!corenlp/constituency!, 'data');
like($data->{layerInfos}, qr!corenlp/c=spans!, 'data');

is($data->{stream}->[0]->[1], '<>:corenlp/c:CNP$<b>64<i>0<i>16<i>2<b>2', 'Noun phrase');
is($data->{stream}->[0]->[2], '<>:corenlp/c:ROOT$<b>64<i>0<i>42<i>6<b>0', 'Noun phrase');
is($data->{stream}->[0]->[3], '<>:corenlp/c:NP$<b>64<i>0<i>42<i>6<b>1', 'Noun phrase');

done_testing;

__END__

