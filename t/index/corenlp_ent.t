#!/usr/bin/env perl
use strict;
use warnings;
use utf8;
use Test::More;
use Scalar::Util qw/weaken/;
use Data::Dumper;

use_ok('KorAP::Document');

use File::Basename 'dirname';
use File::Spec::Functions 'catdir';

my $path = catdir(dirname(__FILE__), 'corpus', 'doc', 'text');

ok(my $doc = KorAP::Document->new(
  path => $path . '/'
), 'Load Korap::Document');

like($doc->path, qr!$path/$!, 'Path');
ok($doc->parse, 'Parse document');

ok($doc->primary->data, 'Primary data in existence');
is($doc->primary->data_length, 129, 'Data length');

use_ok('KorAP::Tokenizer');

ok(my $tokens = KorAP::Tokenizer->new(
  path => $doc->path,
  doc => $doc,
  foundry => 'OpenNLP',
  layer => 'Tokens',
  name => 'tokens'
), 'New Tokenizer');

ok($tokens->parse, 'Parse');

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
