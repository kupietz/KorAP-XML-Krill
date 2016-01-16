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

ok($tokens->add('CoreNLP', 'Constituency'), 'Add Structure');

my $data = $tokens->to_data->{data};

like($data->{foundries}, qr!corenlp/constituency!, 'data');
like($data->{layerInfos}, qr!corenlp/c=spans!, 'data');

is($data->{stream}->[0]->[1], '<>:corenlp/c:CNP$<b>64<i>0<i>16<i>2<b>2', 'Noun phrase');
is($data->{stream}->[0]->[2], '<>:corenlp/c:ROOT$<b>64<i>0<i>42<i>6<b>0', 'Noun phrase');
is($data->{stream}->[0]->[3], '<>:corenlp/c:NP$<b>64<i>0<i>42<i>6<b>1', 'Noun phrase');

done_testing;

__END__

