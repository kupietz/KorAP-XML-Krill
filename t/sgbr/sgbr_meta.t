use strict;
use warnings;
use Test::More;
use File::Basename 'dirname';
use File::Spec::Functions 'catdir';
use Data::Dumper;
use KorAP::Tokenizer;
use KorAP::Document;
use utf8;

my $path = catdir(dirname(__FILE__), 'TEST', 'BSP', 1);

ok(my $doc = KorAP::Document->new(
  path => $path . '/'
), 'Create Document');

ok($doc->parse, 'Parse document');

like($doc->path, qr!$path/!, 'Path');

# Metdata
is($doc->text_sigle, 'TEST_BSP.1', 'ID-text');
is($doc->doc_sigle, 'TEST_BSP', 'ID-doc');
is($doc->corpus_sigle, 'TEST', 'ID-corpus');

diag 'TODO: Parse meta';

done_testing;
