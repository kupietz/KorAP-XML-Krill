#!/usr/bin/env perl
use strict;
use warnings;
use utf8;
use Test::More;
use Scalar::Util qw/weaken/;
use Data::Dumper;
use lib 't/index';
use TestInit;
use File::Basename 'dirname';
use File::Spec::Functions 'catdir';


my $path = catdir(dirname(__FILE__), 'corpus', 'doc', '0001');

ok(my $doc = KorAP::XML::Krill->new( path => $path . '/' ), 'Load Korap::Document');
ok($doc->parse, 'Parse document');
like($doc->path, qr!$path/!, 'Path');

# Metdata
is($doc->text_sigle, 'Corpus_Doc.0001', 'ID-text');
is($doc->doc_sigle, 'Corpus_Doc', 'ID-doc');
is($doc->corpus_sigle, 'Corpus', 'ID-corpus');

is($doc->title, 'Beispiel Text', 'title');
is($doc->sub_title, 'Beispiel Text Untertitel', 'title');
is($doc->pub_date, '20010402', 'Publication date');
is($doc->pub_place, 'Mannheim', 'Publication place');
is($doc->author, 'Mustermann, Max', 'Author');

is($doc->publisher, 'Artificial articles Inc.', 'Publisher');
is($doc->editor, 'Monika Mustermann', 'Editor');
is($doc->text_type, 'Zeitung: Tageszeitung', 'Text Type');
is($doc->text_type_art, 'Bericht', 'Text Type Art');
is($doc->text_type_ref, 'Aphorismen', 'Text Type Ref');
ok(!$doc->text_column, 'Text Column');
ok(!$doc->text_domain, 'Text Domain');
is($doc->creation_date, '19990601', 'Creation Date');
ok(!$doc->license, 'License');
ok(!$doc->pages, 'Pages');
ok(!$doc->file_edition_statement, 'File Edition Statement');
ok(!$doc->bibl_edition_statement, 'Bibl Edition Statement');
ok(!$doc->reference, 'Reference');
is($doc->language, 'de', 'Language');

is($doc->doc_title, 'Beispiel Dokument', 'Doc: title');
ok(!$doc->doc_sub_title, 'Doc: subtitle');
ok(!$doc->doc_editor, 'Doc: editor');
ok(!$doc->doc_author, 'Doc: author');

is($doc->corpus_title, 'Werke von Beispiel', 'Corpus: title');
ok(!$doc->corpus_sub_title, 'Corpus: subtitle');
is($doc->corpus_editor, 'Mustermann, Monika', 'Corpus: editor');
is($doc->corpus_author, 'Mustermann, Max', 'Corpus: author');

done_testing;

__END__
