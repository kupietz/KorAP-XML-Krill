#!/usr/bin/env perl
use strict;
use warnings;
use utf8;
use Test::More;
use Scalar::Util qw/weaken/;

use_ok('KorAP::Document');

use File::Basename 'dirname';
use File::Spec::Functions 'catdir';

my $path = catdir(dirname(__FILE__), 'GOE-2', 'AGX', '00002' );
ok(my $doc = KorAP::Document->new( path => $path . '/' ), 'Load Korap::Document');
like($doc->path, qr!$path/$!, 'Path');
ok($doc->parse, 'Parse document');

ok($doc->primary->data, 'Primary data in existence');
is($doc->primary->data_length, 8888, 'Data length');

use_ok('KorAP::Tokenizer');

ok(my $tokens = KorAP::Tokenizer->new(
  path => $doc->path,
  doc => $doc,
  foundry => 'Tree_Tagger',
  layer => 'Tokens',
  name => 'tokens'
), 'New Tokenizer');

ok($tokens->parse, 'Parse');

ok($tokens->add('Struct', 'Structure'), 'Add Structure');


done_testing;
__END__


sub new_tokenizer {
  my $x = $doc;
  weaken $x;
  return KorAP::Tokenizer->new(
    path => $x->path,
    doc => $x,
    foundry => 'DeReKo',
    layer => 'Structure',
    name => 'spans'
  )
};

__END__
