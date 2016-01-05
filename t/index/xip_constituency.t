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

ok($tokens->add('XIP', 'Constituency'), 'Add Structure');

my $data = $tokens->to_data->{data};
like($data->{foundries}, qr!xip/constituency!, 'data');
like($data->{layerInfos}, qr!xip/c=spans!, 'data');

# The length includes the punct - but that doesn't matter
is($data->{stream}->[0]->[1], '<>:xip/c:PREP$<b>64<i>0<i>3<i>1<b>3', 'Prep phrase');
is($data->{stream}->[0]->[2], '<>:xip/c:PP$<b>64<i>0<i>30<i>4<b>2', 'pp phrase');
is($data->{stream}->[0]->[3], '<>:xip/c:TOP$<b>64<i>0<i>129<i>17<b>0', 'top phrase');
is($data->{stream}->[0]->[4], '<>:xip/c:MC$<b>64<i>0<i>129<i>17<b>1', 'mc phrase');

is($data->{stream}->[-1]->[0], '<>:xip/c:VERB$<b>64<i>124<i>128<i>18<b>4', 'Noun phrase');

done_testing;

__END__




