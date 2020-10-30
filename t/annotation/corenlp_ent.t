#!/usr/bin/env perl
use strict;
use warnings;
use utf8;
use Test::More;
use KorAP::XML::Annotation::CoreNLP::NamedEntities;
use Scalar::Util qw/weaken/;
use Data::Dumper;
use lib 't/annotation';
use TestInit;

ok(my $tokens = TestInit::tokens('0001'), 'Parse tokens');

ok($tokens->add('CoreNLP', 'NamedEntities', 'ne_dewac_175m_600'), 'Add Structure');

my $data = $tokens->to_data->{data};

like($data->{foundries}, qr!corenlp/namedentities!, 'data');
like($data->{foundries}, qr!corenlp/namedentities/ne_dewac_175m_600!, 'data');
like($data->{layerInfos}, qr!corenlp/ne=tokens!, 'layerInfos');
is($data->{stream}->[0]->[0], '-:tokens$<i>18', 'Number of tokens');
is($data->{stream}->[9]->[0], '_9$<i>64<i>73', 'Position of NE');
is($data->{stream}->[9]->[1], 'corenlp/ne:I-LOC', 'Position of NE');
is($data->{stream}->[9]->[2], 'i:hofbergli', 'Position of NE');

done_testing;

__END__
