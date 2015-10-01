#!/usr/bin/env perl
# source ~/perl5/perlbrew/etc/bashrc
# perlbrew switch perl-blead@korap
use strict;
use warnings;
use utf8;
use Test::More;
use Benchmark ':hireswallclock';
use lib 'lib', '../lib';

use File::Basename 'dirname';
use File::Spec::Functions 'catdir';


diag 'Support "availability"';
diag 'Support "pubPlace-key"';

# TODO: Make 'text' -> 'primaryText'

use_ok('KorAP::Document');

# WPD/00001
my $path = catdir(dirname(__FILE__), 'WPD/00001');
ok(my $doc = KorAP::Document->new( path => $path . '/' ), 'Load Korap::Document');
like($doc->path, qr!$path/!, 'Path');

ok($doc = KorAP::Document->new( path => $path ), 'Load Korap::Document');
like($doc->path, qr!$path/$!, 'Path');

ok($doc->parse, 'Parse document');

# Metdata
is($doc->text_sigle, 'WPD_AAA.00001', 'ID');

is($doc->title, 'A', 'title');
ok(!$doc->sub_title, 'subTitle');
is($doc->corpus_sigle, 'WPD', 'corpusID');
is($doc->pub_date, '20050328', 'pubDate');
is($doc->pub_place, 'URL:http://de.wikipedia.org', 'pubPlace');
is($doc->text_class->[0], 'freizeit-unterhaltung', 'TextClass');
is($doc->text_class->[1], 'reisen', 'TextClass');
is($doc->text_class->[2], 'wissenschaft', 'TextClass');
is($doc->text_class->[3], 'populaerwissenschaft', 'TextClass');
ok(!$doc->text_class->[4], 'TextClass');
is($doc->author, 'Ruru; Jens.Ol; Aglarech; u.a.', 'author');

#is($doc->author->[0], 'Ruru', 'author');
#is($doc->author->[1], 'Jens.Ol', 'author');
#is($doc->author->[2], 'Aglarech', 'author');
#ok(!$doc->author->[3], 'author');

# Additional information
ok(!$doc->editor, 'Editor');
is($doc->publisher, 'Wikipedia', 'Publisher');
is($doc->creation_date, '20050000', 'Creation date');
ok(!$doc->text_type, 'No text_type');
ok(!$doc->text_type_art, 'no text_type art');
ok(!$doc->text_type_ref, 'no text_type ref');
ok(!$doc->text_domain, 'no text_domain');
ok(!$doc->text_column, 'no text_column');
ok(!$doc->keywords_string, 'no keywords');
is($doc->text_class_string, 'freizeit-unterhaltung reisen wissenschaft populaerwissenschaft', 'no text classes');
ok(!$doc->language, 'no text_column');

#is($doc->coll_title, 'Wikipedia', 'Collection title');
#is($doc->coll_sub_title, 'Die freie Enzyklopädie', 'Collection subtitle');
#is($doc->coll_editor, 'wikipedia.org', 'Collection editor');
#ok(!$doc->coll_author, 'Collection author');

# BRZ13/00001
$path = catdir(dirname(__FILE__), 'BRZ13/00001');
ok($doc = KorAP::Document->new( path => $path . '/' ), 'Load Korap::Document');

ok($doc->parse, 'Parse document');
is($doc->title, 'Sexueller Missbrauch –„Das schreiende Kind steckt noch tief in mir“', 'title');
ok(!$doc->sub_title, 'subTitle');
is($doc->text_sigle, 'BRZ13_APR.00001', 'ID');
is($doc->corpus_sigle, 'BRZ13', 'corpusID');


is($doc->pub_date, '20130402', 'pubDate');
is($doc->pub_place, 'Braunschweig', 'pubPlace');

is($doc->text_class->[0], 'staat-gesellschaft', 'TextClass');
is($doc->text_class->[1], 'familie-geschlecht', 'TextClass');
ok(!$doc->text_class->[2], 'TextClass');
ok(!$doc->author, 'author');

# Additional information
ok(!$doc->editor, 'Editor');
is($doc->publisher, 'Braunschweiger Zeitungsverlag, Druckhaus Albert Limbach GmbH & Co. KG', 'Publisher');
is($doc->creation_date, '20130402', 'Creation date');
#is($doc->coll_title, 'Braunschweiger Zeitung', 'Collection title');
#ok(!$doc->coll_sub_title, 'Collection subtitle');
#ok(!$doc->coll_editor, 'Collection editor');
#ok(!$doc->coll_author, 'Collection author');
is($doc->text_type, 'Zeitung: Tageszeitung', 'text_type');
ok(!$doc->text_type_art, 'text_type art');

# A01/13047
$path = catdir(dirname(__FILE__), 'A01/13047');
ok($doc = KorAP::Document->new( path => $path . '/' ), 'Load Korap::Document');

ok($doc->parse, 'Parse document');
is($doc->title, 'Fischer und Kolp im Sonnenhügel', 'title');
ok(!$doc->sub_title, 'subTitle');
is($doc->text_sigle, 'A01_APR.13047', 'ID');
is($doc->corpus_sigle, 'A01', 'corpusID');
is($doc->pub_date, '20010402', 'pubDate');
ok(!$doc->pub_place, 'pubPlace');
is($doc->text_class->[0], 'freizeit-unterhaltung', 'TextClass');
is($doc->text_class->[1], 'vereine-veranstaltungen', 'TextClass');
ok(!$doc->text_class->[2], 'TextClass');
ok(!$doc->author, 'author');

# Additional information
ok(!$doc->editor, 'Editor');
ok(!$doc->publisher, 'Publisher');
is($doc->creation_date, '20010402', 'Creation date');
#ok(!$doc->coll_title, 'Collection title');
#ok(!$doc->coll_sub_title, 'Collection subtitle');
#ok(!$doc->coll_editor, 'Collection editor');
#ok(!$doc->coll_author, 'Collection author');
ok(!$doc->text_type, 'text_type');
is($doc->text_type_art, 'Bericht', 'text_type art');


# ERL/0001
$path = catdir(dirname(__FILE__), 'ERL/00001');
ok($doc = KorAP::Document->new( path => $path . '/' ), 'Load Korap::Document');

ok($doc->parse, 'Parse document');
is($doc->title, 'MK2/ERL.00001 Amtsblatt des Landesbezirks Baden [diverse Erlasse], Hrsg. und Schriftleitung: Präsidialstelle der Landesverwaltung Baden in Karlsruhe. - Karlsruhe, o.J.', 'title'); # Amtsblatt des Landesbezirks Baden [diverse Erlasse]

ok(!$doc->sub_title, 'subTitle');
is($doc->text_sigle, 'MK2_ERL.00001', 'ID');
is($doc->corpus_sigle, 'MK2', 'corpusID');
is($doc->pub_date, '00000000', 'pubDate');
is($doc->pub_place, 'Karlsruhe', 'pubPlace');
is($doc->text_class->[0], 'politik', 'TextClass');
is($doc->text_class->[1], 'kommunalpolitik', 'TextClass');
ok(!$doc->text_class->[2], 'TextClass');
ok(!$doc->author, 'author');

# Additional information
ok(!$doc->editor, 'Editor');
is($doc->publisher, 'Badenia Verlag und Druckerei', 'Publisher');
is($doc->creation_date, '19600000', 'Creation date');
diag 'Non-acceptance of creation date ranges may be temporary';
#ok(!$doc->coll_title, 'Collection title');
#ok(!$doc->coll_sub_title, 'Collection subtitle');
#ok(!$doc->coll_editor, 'Collection editor');
#ok(!$doc->coll_author, 'Collection author');
is($doc->text_type, 'Erlass', 'text_type');
ok(!$doc->text_type_art, 'text_type art');

# A01/02035-substring
$path = catdir(dirname(__FILE__), 'A01/02035-substring');
ok($doc = KorAP::Document->new( path => $path . '/' ), 'Load Korap::Document');

ok($doc->parse, 'Parse document');
is($doc->title, 'A00/JAN.02035 St. Galler Tagblatt, 11.01.2000, Ressort: TB-RSP (Abk.)', 'title');
ok(!$doc->sub_title, 'subTitle');
is($doc->text_sigle, 'A00_JAN.02035', 'ID');
is($doc->corpus_sigle, 'A00', 'corpusID');
is($doc->pub_date, '20000111', 'pubDate');
ok(!$doc->pub_place, 'pubPlace');
is($doc->text_class->[0], 'sport', 'TextClass');
is($doc->text_class->[1], 'ballsport', 'TextClass');
ok(!$doc->text_class->[2], 'TextClass');
ok(!$doc->author, 'author');

# Additional information
ok(!$doc->editor, 'Editor');
ok(!$doc->publisher, 'Publisher');
is($doc->creation_date, "20000111", 'Creation date');
#ok(!$doc->coll_title, 'Collection title');
#ok(!$doc->coll_sub_title, 'Collection subtitle');
#ok(!$doc->coll_editor, 'Collection editor');
#ok(!$doc->coll_author, 'Collection author');
ok(!$doc->text_type, 'text_type');
is($doc->text_type_art, 'Bericht', 'text_type art');

# A01/02873-meta
$path = catdir(dirname(__FILE__), 'A01/02873-meta');
ok($doc = KorAP::Document->new( path => $path . '/' ), 'Load Korap::Document');

ok($doc->parse, 'Parse document');
is($doc->title, 'Tradition und Moderne', 'title');
ok(!$doc->sub_title, 'subTitle');
is($doc->text_sigle, 'A00_JAN.02873', 'ID');
is($doc->corpus_sigle, 'A00', 'corpusID');
is($doc->pub_date, '20000113', 'pubDate');
ok(!$doc->pub_place, 'pubPlace');
is($doc->text_class->[0], 'kultur', 'TextClass');
is($doc->text_class->[1], 'film', 'TextClass');
ok(!$doc->text_class->[2], 'TextClass');
ok(!$doc->author, 'author');

# Additional information
ok(!$doc->editor, 'Editor');
ok(!$doc->publisher, 'Publisher');
is($doc->creation_date, "20000113", 'Creation date');
#ok(!$doc->coll_title, 'Collection title');
#ok(!$doc->coll_sub_title, 'Collection subtitle');
#ok(!$doc->coll_editor, 'Collection editor');
#ok(!$doc->coll_author, 'Collection author');
ok(!$doc->text_type, 'text_type');
is($doc->text_type_art, 'Bericht', 'text_type art');


# A01/05663-unbalanced
$path = catdir(dirname(__FILE__), 'A01/05663-unbalanced');
ok($doc = KorAP::Document->new( path => $path . '/' ), 'Load Korap::Document');

ok($doc->parse, 'Parse document');
is($doc->title, 'Mehr Arbeitslose im Dezember', 'title');
ok(!$doc->sub_title, 'subTitle');
is($doc->text_sigle, 'A00_JAN.05663', 'ID');
is($doc->corpus_sigle, 'A00', 'corpusID');
is($doc->pub_date, '20000124', 'pubDate');
ok(!$doc->pub_place, 'pubPlace');
is($doc->text_class->[0], 'gesundheit-ernaehrung', 'TextClass');
is($doc->text_class->[1], 'gesundheit', 'TextClass');
ok(!$doc->text_class->[2], 'TextClass');
ok(!$doc->author, 'author');

# Additional information
ok(!$doc->editor, 'Editor');
ok(!$doc->publisher, 'Publisher');
is($doc->creation_date, "20000124", 'Creation date');
#ok(!$doc->coll_title, 'Collection title');
#ok(!$doc->coll_sub_title, 'Collection subtitle');
#ok(!$doc->coll_editor, 'Collection editor');
#ok(!$doc->coll_author, 'Collection author');
ok(!$doc->text_type, 'text_type');
is($doc->text_type_art, 'Bericht', 'text_type art');


# A01/07452-deep
$path = catdir(dirname(__FILE__), 'A01/07452-deep');
ok($doc = KorAP::Document->new( path => $path . '/' ), 'Load Korap::Document');

ok($doc->parse, 'Parse document');
is($doc->title, 'Wil im Dezember 1999', 'title');
ok(!$doc->sub_title, 'subTitle');
is($doc->text_sigle, 'A00_JAN.07452', 'ID');
is($doc->corpus_sigle, 'A00', 'corpusID');
is($doc->pub_date, '20000129', 'pubDate');
ok(!$doc->pub_place, 'pubPlace');
is($doc->text_class->[0], 'politik', 'TextClass');
is($doc->text_class->[1], 'kommunalpolitik', 'TextClass');
ok(!$doc->text_class->[2], 'TextClass');
ok(!$doc->author, 'author');

# Additional information
ok(!$doc->editor, 'Editor');
ok(!$doc->publisher, 'Publisher');
is($doc->creation_date, "20000129", 'Creation date');
#ok(!$doc->coll_title, 'Collection title');
#ok(!$doc->coll_sub_title, 'Collection subtitle');
#ok(!$doc->coll_editor, 'Collection editor');
#ok(!$doc->coll_author, 'Collection author');
ok(!$doc->text_type, 'text_type');
is($doc->text_type_art, 'Bericht', 'text_type art');


# ART
$path = catdir(dirname(__FILE__), 'artificial');
ok($doc = KorAP::Document->new( path => $path . '/' ), 'Load Korap::Document');
#is($doc->path, $path . '/', 'Path');

ok($doc = KorAP::Document->new( path => $path ), 'Load Korap::Document');
#is($doc->path, $path . '/', 'Path');

ok($doc->parse, 'Parse document');

# Metdata
is($doc->title, 'Artificial Title', 'title');
is($doc->sub_title, 'Artificial Subtitle', 'subTitle');
is($doc->text_sigle, 'ART_ABC.00001', 'ID');
is($doc->corpus_sigle, 'ART', 'corpusID');
is($doc->pub_date, '20010402', 'pubDate');
is($doc->pub_place, 'Mannheim', 'pubPlace');
is($doc->text_class->[0], 'freizeit-unterhaltung', 'TextClass');
is($doc->text_class->[1], 'vereine-veranstaltungen', 'TextClass');
ok(!$doc->text_class->[2], 'TextClass');
#is($doc->author->[0], 'Ruru', 'author');
#is($doc->author->[1], 'Jens.Ol', 'author');
#is($doc->author->[2], 'Aglarech', 'author');
is($doc->author, 'Ruru; Jens.Ol; Aglarech; u.a.', 'author');

# Additional information
is($doc->editor, 'Nils Diewald', 'Editor');
is($doc->publisher, 'Artificial articles Inc.', 'Publisher');
is($doc->creation_date, '19990601', 'Creation date');
#is($doc->coll_title, 'Artificial articles', 'Collection title');
#is($doc->coll_sub_title, 'Best of!', 'Collection subtitle');
#is($doc->coll_editor, 'Nils Diewald', 'Collection editor');
#is($doc->coll_author, 'Nils Diewald', 'Collection author');
is($doc->text_type, 'Zeitung: Tageszeitung', 'No text_type');
is($doc->text_type_art, 'Bericht', 'text_type art');

# Multipath headers
$path = catdir(dirname(__FILE__), 'VDI/JAN/00001');
ok($doc = KorAP::Document->new( path => $path . '/' ), 'Load Korap::Document');
like($doc->path, qr!$path/!, 'Path');

ok($doc = KorAP::Document->new( path => $path ), 'Load Korap::Document');
like($doc->path, qr!$path/$!, 'Path');

ok($doc->parse, 'Parse document');
is($doc->text_sigle, 'VDI_JAN.00001', 'text sigle');
is($doc->doc_sigle, 'VDI_JAN', 'doc sigle');
is($doc->corpus_sigle, 'VDI', 'corpus sigle');
is($doc->title, '10- Zz mit Zahl', 'title');
ok(!$doc->sub_title, 'subtitle');
is($doc->pub_date, '20140117', 'pubdate');
is($doc->pub_place, 'Düsseldorf', 'pubplace');
is($doc->author, 'Windhövel, Kerstin', 'author');
is($doc->publisher, 'VDI Verlag GmbH', 'publisher');
ok(!$doc->editor, 'editor');

ok(!$doc->text_type, 'text type');
ok(!$doc->text_type_art, 'text type art');
ok(!$doc->text_type_ref, 'text type ref');
ok(!$doc->text_column, 'text column');
ok(!$doc->text_domain, 'text domain');
ok(!$doc->creation_date, 'creation date');
ok(!$doc->license, 'License');
ok(!$doc->pages, 'Pages');
ok(!$doc->file_edition_statement, 'file edition statement');
ok(!$doc->bibl_edition_statement, 'bibl edition statement');
is($doc->reference, 'VDI nachrichten, 17.01.2014, S. 10; 10- Zz mit Zahl [Ausführliche Zitierung nicht verfügbar]', 'Reference');

ok(!$doc->language, 'Language');
diag 'This may be "de" in the future';

is($doc->doc_title, 'VDI nachrichten, Januar 2014', 'Doc title');
ok(!$doc->doc_sub_title, 'Doc Sub title');
ok(!$doc->doc_editor, 'Doc editor');
ok(!$doc->doc_author, 'Doc author');

is($doc->corpus_title, 'VDI nachrichten 2014', 'Corpus title');
ok(!$doc->corpus_sub_title, 'Corpus Sub title');
ok(!$doc->corpus_editor, 'Corpus editor');
ok(!$doc->corpus_author, 'Corpus author');

is($doc->keywords_string, '', 'Keywords');
is($doc->text_class_string, 'Freizeit-Unterhaltung Reisen Politik Ausland', 'Text class');


# WDD
$path = catdir(dirname(__FILE__), 'WDD/G27/38989');
ok($doc = KorAP::Document->new( path => $path . '/' ), 'Load Korap::Document');
like($doc->path, qr!$path/!, 'Path');
ok($doc->parse, 'Parse document');

is($doc->text_sigle, 'WDD11_G27.38989', 'text sigle');
is($doc->doc_sigle, 'WDD11_G27', 'doc sigle');
is($doc->corpus_sigle, 'WDD11', 'corpus sigle');

is($doc->title, 'Diskussion:Gunter A. Pilz', 'title');
ok(!$doc->sub_title, 'subtitle');
is($doc->pub_date, '20111029', 'pubdate');
is($doc->pub_place, 'URL:http://de.wikipedia.org', 'pubplace');

is($doc->author, '€pa, u.a.', 'author');
is($doc->publisher, 'Wikipedia', 'publisher');
ok(!$doc->editor, 'editor');

is($doc->text_type, 'Diskussionen zu Enzyklopädie-Artikeln', 'text type');
ok(!$doc->text_type_art, 'text type art');
ok(!$doc->text_type_ref, 'text type ref');
ok(!$doc->text_column, 'text column');
ok(!$doc->text_domain, 'text domain');

is($doc->creation_date, '20070707', 'creation date');
is($doc->license, 'CC-BY-SA', 'License');
ok(!$doc->pages, 'Pages');
ok(!$doc->file_edition_statement, 'file edition statement');
ok(!$doc->bibl_edition_statement, 'bibl edition statement');
is($doc->reference, 'Diskussion:Gunter A. Pilz, In: Wikipedia - URL:http://de.wikipedia.org/wiki/Diskussion:Gunter_A._Pilz: Wikipedia, 2007', 'Reference');

is($doc->language, 'de', 'Language');

is($doc->doc_title, 'Wikipedia, Diskussionen zu Artikeln mit Anfangsbuchstabe G, Teil 27', 'Doc title');
ok(!$doc->doc_sub_title, 'Doc Sub title');
ok(!$doc->doc_editor, 'Doc editor');
ok(!$doc->doc_author, 'Doc author');

is($doc->corpus_title, 'Wikipedia.de 2011 Diskussionen', 'Corpus title');
ok(!$doc->corpus_sub_title, 'Corpus Sub title');
ok(!$doc->corpus_editor, 'Corpus editor');
ok(!$doc->corpus_author, 'Corpus author');

is($doc->keywords_string, '', 'Keywords');
is($doc->text_class_string, '', 'Text class');

done_testing;
__END__


