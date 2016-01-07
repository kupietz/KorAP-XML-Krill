#!/usr/bin/env perl
use strict;
use warnings;
use utf8;
use Test::More skip_all => 'Not yet implemented';
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

ok($tokens->add('CoreNLP', 'Dependency'), 'Add Structure');

my $data = $tokens->to_data->{data};


# diag Dumper $data;

done_testing;

__END__



like($data->{foundries}, qr!xip/morpho!, 'data');
like($data->{layerInfos}, qr!xip/l=tokens!, 'data');
like($data->{layerInfos}, qr!xip/p=tokens!, 'data');
is($data->{stream}->[0]->[4], 'xip/l:zu', 'Lemma');
is($data->{stream}->[0]->[5], 'xip/p:PREP', 'POS');

is($data->{stream}->[1]->[3], 'xip/l:letzt', 'Lemma');
is($data->{stream}->[1]->[4], 'xip/p:ADJ', 'POS');

is($data->{stream}->[8]->[3], 'xip/l:\#Heim', 'Lemma (part)');
is($data->{stream}->[8]->[4], 'xip/l:\#schulen', 'Lemma (part)');
is($data->{stream}->[8]->[5], 'xip/l:schulen\#Heim', 'Lemma (part)');

is($data->{stream}->[-1]->[3], 'xip/l:werden', 'Lemma');
is($data->{stream}->[-1]->[4], 'xip/p:VERB', 'POS');

