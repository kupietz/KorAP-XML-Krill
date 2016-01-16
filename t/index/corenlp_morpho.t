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

my $path = catdir(dirname(__FILE__), 'corpus', 'doc', '0001');

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

ok($tokens->add('CoreNLP', 'Morpho'), 'Add Structure');

my $data = $tokens->to_data->{data};
like($data->{foundries}, qr!corenlp/morpho!, 'data');
like($data->{layerInfos}, qr!corenlp/p=tokens!, 'data');
is($data->{stream}->[0]->[2], 'corenlp/p:APPRART', 'POS');
is($data->{stream}->[1]->[1], 'corenlp/p:ADJ', 'POS');
is($data->{stream}->[2]->[1], 'corenlp/p:ADJA', 'POS');

done_testing;

__END__
