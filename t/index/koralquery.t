#!/usr/bin/env perl
use strict;
use warnings;
use utf8;
use Test::More skip_all => 'Not yet implemented';
use lib 't/index';
use File::Basename 'dirname';
use File::Spec::Functions 'catdir';

my $path = catdir(dirname(__FILE__), 'corpus', 'doc', '0001');

use_ok('KorAP::XML::Krill');

ok(my $doc = KorAP::XML::Krill->new( path => $path . '/' ), 'Load Korap::Document');

ok($doc->parse
     ->tokenize
       ->annotate('Base', 'Paragraphs')
	 ->annotate('DeReKo', 'Struct');

# Metdata
is($doc->text_sigle, 'Corpus_Doc.0001', 'ID-text');
is($doc->doc_sigle, 'Corpus_Doc', 'ID-doc');
is($doc->corpus_sigle, 'Corpus', 'ID-corpus');
is($doc->title, 'Beispiel Text', 'title');
is($doc->sub_title, 'Beispiel Text Untertitel', 'title');

done_testing;
__END__
