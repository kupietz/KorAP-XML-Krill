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

ok($tokens->add('Glemm', 'Morpho'), 'Add Structure');

my $data = $tokens->to_data->{data};

like($data->{foundries}, qr!glemm/morpho!, 'data');
like($data->{layerInfos}, qr!glemm/l=tokens!, 'data');

is($data->{stream}->[0]->[2], 'glemm/l:__zu', 'Lemma');
is($data->{stream}->[1]->[1], 'glemm/l:__letzt-', 'Lemma');
is($data->{stream}->[3]->[1], 'glemm/l:_+an-', 'Lemma');
is($data->{stream}->[3]->[2], 'glemm/l:_+lass', 'Lemma');
is($data->{stream}->[3]->[3], 'glemm/l:__Anlass', 'Lemma');

is($data->{stream}->[6]->[1], 'glemm/l:_+-ung', 'Lemma');
is($data->{stream}->[6]->[2], 'glemm/l:_+leiten', 'Lemma');
is($data->{stream}->[6]->[3], 'glemm/l:__Leitung', 'Lemma');

is($data->{stream}->[-1]->[1], 'glemm/l:__werden', 'Lemma');

done_testing;

__END__
