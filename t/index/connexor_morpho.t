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

ok($tokens->add('Connexor', 'Morpho'), 'Add Structure');

my $data = $tokens->to_data->{data};
like($data->{foundries}, qr!connexor/morpho!, 'data');
is($data->{stream}->[0]->[1], '_0$<i>0<i>3', 'Position');
is($data->{stream}->[1]->[1], 'cnx/l:letzt', 'Lemma');
is($data->{stream}->[1]->[2], 'cnx/p:A', 'POS');
is($data->{stream}->[2]->[1], 'cnx/l:kulturell', 'Lemma');
is($data->{stream}->[2]->[2], 'cnx/p:A', 'POS');
is($data->{stream}->[4]->[2], 'cnx/m:IND', 'Morpho');
is($data->{stream}->[4]->[3], 'cnx/m:PRES', 'Morpho');

is($data->{stream}->[-1]->[2], 'cnx/m:IND', 'Morpho');
is($data->{stream}->[-1]->[3], 'cnx/m:PRES', 'Morpho');

done_testing;

__END__
