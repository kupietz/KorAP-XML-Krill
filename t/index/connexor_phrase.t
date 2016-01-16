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

ok($tokens->add('Connexor', 'Phrase'), 'Add Structure');

my $data = $tokens->to_data->{data};

like($data->{foundries}, qr!connexor/phrase!, 'data');
is($data->{stream}->[1]->[0], '<>:cnx/c:np$<b>64<i>4<i>30<i>4<b>0', 'Noun phrase');

done_testing;

__END__
