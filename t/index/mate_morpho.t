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

ok($tokens->add('Mate', 'Morpho'), 'Add Structure');

my $data = $tokens->to_data->{data};

like($data->{foundries}, qr!mate/morpho!, 'data');
like($data->{layerInfos}, qr!mate/p=tokens!, 'data');
like($data->{layerInfos}, qr!mate/l=tokens!, 'data');
like($data->{layerInfos}, qr!mate/m=tokens!, 'data');

is($data->{stream}->[0]->[3], 'mate/l:zu', 'POS');
is($data->{stream}->[0]->[4], 'mate/m:case:dat', 'POS');
is($data->{stream}->[0]->[5], 'mate/m:gender:neut', 'POS');
is($data->{stream}->[0]->[6], 'mate/m:number:sg', 'POS');
is($data->{stream}->[0]->[7], 'mate/p:APPRART', 'POS');

is($data->{stream}->[-1]->[2], 'mate/l:werden', 'POS');
is($data->{stream}->[-1]->[3], 'mate/m:mood:ind', 'POS');
is($data->{stream}->[-1]->[4], 'mate/m:number:sg', 'POS');
is($data->{stream}->[-1]->[5], 'mate/m:person:3', 'POS');
is($data->{stream}->[-1]->[6], 'mate/m:tense:pres', 'POS');
is($data->{stream}->[-1]->[7], 'mate/p:VAFIN', 'POS');

done_testing;

__END__
