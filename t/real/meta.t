use strict;
use warnings;
use utf8;
use Test::More;
use Benchmark ':hireswallclock';
use Mojo::DOM;
use Mojo::File;
use Mojo::ByteStream 'b';
use Data::Dumper;
use lib 'lib', '../lib';

if ($ENV{SKIP_REAL}) {
  plan skip_all => 'Skip real tests';
};

use File::Basename 'dirname';
use File::Spec::Functions 'catdir';

use_ok('KorAP::XML::Krill');

# WPD/00001
my $path = catdir(dirname(__FILE__), 'corpus','WPD','00001');
ok(my $doc = KorAP::XML::Krill->new( path => $path . '/' ), 'Load Korap::Document');
like($doc->path, qr!\Q$path\E/!, 'Path');

ok($doc = KorAP::XML::Krill->new( path => $path ), 'Load Korap::Document');
like($doc->path, qr!\Q$path\E/$!, 'Path');

ok($doc->parse, 'Parse document');

# Metdata
is($doc->text_sigle, 'WPD/AAA/00001', 'ID');

my $meta = $doc->meta;
is($meta->{T_title}, 'A', 'title');

ok(!$meta->{T_sub_title}, 'subTitle');
is($doc->corpus_sigle, 'WPD', 'corpusID');
is($meta->{D_pub_date}, '20050328', 'pubDate');
is($meta->{S_pub_place}, 'URL:http://de.wikipedia.org', 'pubPlace');
is($meta->{K_text_class}->[0], 'freizeit-unterhaltung', 'TextClass');
is($meta->{K_text_class}->[1], 'reisen', 'TextClass');
is($meta->{K_text_class}->[2], 'wissenschaft', 'TextClass');
is($meta->{K_text_class}->[3], 'populaerwissenschaft', 'TextClass');
ok(!$meta->{K_text_class}->[4], 'TextClass');
is($meta->{T_author}, 'Ruru; Jens.Ol; Aglarech; u.a.', 'author');


#is($doc->author->[0], 'Ruru', 'author');
#is($doc->author->[1], 'Jens.Ol', 'author');
#is($doc->author->[2], 'Aglarech', 'author');
#ok(!$doc->author->[3], 'author');

# Additional information
is($meta->{A_editor}, 'wikipedia.org', 'Editor');
is($meta->{A_publisher}, 'Wikipedia', 'Publisher');
is($meta->{D_creation_date}, '20050000', 'Creation date');
ok(!$meta->{S_text_type}, 'No text_type');
ok(!$meta->{S_text_type_art}, 'no text_type art');
ok(!$meta->{S_text_type_ref}, 'no text_type ref');
ok(!$meta->{S_text_domain}, 'no text_domain');
ok(!$meta->{S_text_column}, 'no text_column');
ok(!$meta->keywords('K_keywords'), 'no keywords');
is($meta->keywords('K_text_class'), 'freizeit-unterhaltung reisen wissenschaft populaerwissenschaft', 'no text classes');

#is($doc->coll_title, 'Wikipedia', 'Collection title');
#is($doc->coll_sub_title, 'Die freie Enzyklopädie', 'Collection subtitle');
#is($doc->coll_editor, 'wikipedia.org', 'Collection editor');
#ok(!$doc->coll_author, 'Collection author');

# A01/13047
$path = catdir(dirname(__FILE__), 'corpus','A01','13047');
ok($doc = KorAP::XML::Krill->new( path => $path . '/' ), 'Load Korap::Document');

ok($doc->parse, 'Parse document');
$meta = $doc->meta;
is($meta->{T_title}, 'Fischer und Kolp im Sonnenhügel', 'title');

ok(!$meta->{T_sub_title}, 'subTitle');
is($doc->text_sigle, 'A01/APR/13047', 'ID');
is($doc->corpus_sigle, 'A01', 'corpusID');
is($meta->{D_pub_date}, '20010402', 'pubDate');
ok(!$meta->{S_pub_place}, 'pubPlace');
is($meta->{K_text_class}->[0], 'freizeit-unterhaltung', 'TextClass');
is($meta->{K_text_class}->[1], 'vereine-veranstaltungen', 'TextClass');
ok(!$meta->{K_text_class}->[2], 'TextClass');
ok(!$meta->{T_author}, 'author');

# Additional information
ok(!$meta->{A_editor}, 'Editor');
ok(!$meta->{A_publisher}, 'Publisher');
is($meta->{D_creation_date}, '20010402', 'Creation date');
#ok(!$doc->coll_title, 'Collection title');
#ok(!$doc->coll_sub_title, 'Collection subtitle');
#ok(!$doc->coll_editor, 'Collection editor');
#ok(!$doc->coll_author, 'Collection author');
ok(!$meta->{S_text_type}, 'text_type');
is($meta->{S_text_type_art}, 'Bericht', 'text_type art');

# ERL/0001
$path = catdir(dirname(__FILE__), 'corpus','ERL','00001');
ok($doc = KorAP::XML::Krill->new( path => $path . '/' ), 'Load Korap::Document');

ok($doc->parse, 'Parse document');

$meta = $doc->meta;
is($meta->{T_title}, 'Amtsblatt des Landesbezirks Baden [diverse Erlasse]', 'title'); # Amtsblatt des Landesbezirks Baden [diverse Erlasse]
# MK2/ERL.00001

ok(!$meta->{T_sub_title}, 'subTitle');
is($doc->text_sigle, 'MK2/ERL/00001', 'ID');
is($doc->corpus_sigle, 'MK2', 'corpusID');
is($meta->{D_pub_date}, '00000000', 'pubDate');
is($meta->{S_pub_place}, 'Karlsruhe', 'pubPlace');
is($meta->{K_text_class}->[0], 'politik', 'TextClass');
is($meta->{K_text_class}->[1], 'kommunalpolitik', 'TextClass');
ok(!$meta->{K_text_class}->[2], 'TextClass');
ok(!$meta->{T_author}, 'author');

# Additional information
ok(!$meta->{A_editor}, 'Editor');
is($meta->{A_publisher}, 'Badenia Verlag und Druckerei', 'Publisher');
is($meta->{D_creation_date}, '19600000', 'Creation date');

# !!!
# diag 'Non-acceptance of creation date ranges may be temporary';


#ok(!$doc->coll_title, 'Collection title');
#ok(!$doc->coll_sub_title, 'Collection subtitle');
#ok(!$doc->coll_editor, 'Collection editor');
#ok(!$doc->coll_author, 'Collection author');
is($meta->{S_text_type}, 'Erlass', 'text_type');
ok(!$meta->{S_text_type_art}, 'text_type art');


# A01/02035-substring
$path = catdir(dirname(__FILE__), 'corpus','A00','02035-substring');
ok($doc = KorAP::XML::Krill->new( path => $path . '/' ), 'Load Korap::Document');
ok($doc->parse, 'Parse document');

$meta = $doc->meta;

is($meta->{T_title}, 'St. Galler Tagblatt, 11.01.2000, Ressort: TB-RSP (Abk.)', 'title'); # A00/JAN.02035
ok(!$meta->{T_sub_title}, 'subTitle');
is($doc->text_sigle, 'A00/JAN/02035', 'ID');
is($doc->corpus_sigle, 'A00', 'corpusID');
is($meta->{D_pub_date}, '20000111', 'pubDate');
ok(!$meta->{S_pub_place}, 'pubPlace');
is($meta->{K_text_class}->[0], 'sport', 'TextClass');
is($meta->{K_text_class}->[1], 'ballsport', 'TextClass');
ok(!$meta->{K_text_class}->[2], 'TextClass');
ok(!$meta->{T_author}, 'author');

# Additional information
ok(!$meta->{A_editor}, 'Editor');
ok(!$meta->{A_publisher}, 'Publisher');
is($meta->{D_creation_date}, "20000111", 'Creation date');
#ok(!$doc->coll_title, 'Collection title');
#ok(!$doc->coll_sub_title, 'Collection subtitle');
#ok(!$doc->coll_editor, 'Collection editor');
#ok(!$doc->coll_author, 'Collection author');
ok(!$meta->{S_text_type}, 'text_type');
is($meta->{S_text_type_art}, 'Bericht', 'text_type art');

# A01/02873-meta
$path = catdir(dirname(__FILE__), 'corpus','A00','02873-meta');
ok($doc = KorAP::XML::Krill->new( path => $path . '/' ), 'Load Korap::Document');
ok($doc->parse, 'Parse document');
$meta = $doc->meta;

is($meta->{T_title}, 'Tradition und Moderne', 'title');
ok(!$meta->{T_sub_title}, 'subTitle');
is($doc->text_sigle, 'A00/JAN/02873', 'ID');
is($doc->corpus_sigle, 'A00', 'corpusID');
is($meta->{D_pub_date}, '20000113', 'pubDate');
ok(!$meta->{S_pub_place}, 'pubPlace');
is($meta->{K_text_class}->[0], 'kultur', 'TextClass');
is($meta->{K_text_class}->[1], 'film', 'TextClass');
ok(!$meta->{K_text_class}->[2], 'TextClass');
ok(!$meta->{T_author}, 'author');


# Additional information
ok(!$meta->{A_editor}, 'Editor');
ok(!$meta->{A_publisher}, 'Publisher');
is($meta->{D_creation_date}, "20000113", 'Creation date');
#ok(!$doc->coll_title, 'Collection title');
#ok(!$doc->coll_sub_title, 'Collection subtitle');
#ok(!$doc->coll_editor, 'Collection editor');
#ok(!$doc->coll_author, 'Collection author');
ok(!$meta->{S_text_type}, 'text_type');
is($meta->{S_text_type_art}, 'Bericht', 'text_type art');


# A01/05663-unbalanced
$path = catdir(dirname(__FILE__), 'corpus','A00','05663-unbalanced');
ok($doc = KorAP::XML::Krill->new( path => $path . '/' ), 'Load Korap::Document');
ok($doc->parse, 'Parse document');
$meta = $doc->meta;

is($meta->{T_title}, 'Mehr Arbeitslose im Dezember', 'title');
ok(!$meta->{T_sub_title}, 'subTitle');
is($doc->text_sigle, 'A00/JAN/05663', 'ID');
is($doc->corpus_sigle, 'A00', 'corpusID');
is($meta->{D_pub_date}, '20000124', 'pubDate');
ok(!$meta->{S_pub_place}, 'pubPlace');
is($meta->{K_text_class}->[0], 'gesundheit-ernaehrung', 'TextClass');
is($meta->{K_text_class}->[1], 'gesundheit', 'TextClass');
ok(!$meta->{K_text_class}->[2], 'TextClass');
ok(!$meta->{T_author}, 'author');


# Additional information
ok(!$meta->{A_editor}, 'Editor');
ok(!$meta->{A_publisher}, 'Publisher');
is($meta->{D_creation_date}, "20000124", 'Creation date');
#ok(!$doc->coll_title, 'Collection title');
#ok(!$doc->coll_sub_title, 'Collection subtitle');
#ok(!$doc->coll_editor, 'Collection editor');
#ok(!$doc->coll_author, 'Collection author');
ok(!$meta->{S_text_type}, 'text_type');
is($meta->{S_text_type_art}, 'Bericht', 'text_type art');

# A01/07452-deep
$path = catdir(dirname(__FILE__), 'corpus','A00','07452-deep');
ok($doc = KorAP::XML::Krill->new( path => $path . '/' ), 'Load Korap::Document');
ok($doc->parse, 'Parse document');
$meta = $doc->meta;

is($meta->{T_title}, 'Wil im Dezember 1999', 'title');
ok(!$meta->{T_sub_title}, 'subTitle');
is($doc->text_sigle, 'A00/JAN/07452', 'ID');
is($doc->corpus_sigle, 'A00', 'corpusID');
is($meta->{D_pub_date}, '20000129', 'pubDate');
ok(!$meta->{S_pub_place}, 'pubPlace');
is($meta->{K_text_class}->[0], 'politik', 'TextClass');
is($meta->{K_text_class}->[1], 'kommunalpolitik', 'TextClass');
ok(!$meta->{K_text_class}->[2], 'TextClass');
ok(!$meta->{T_author}, 'author');


# Additional information
ok(!$meta->{A_editor}, 'Editor');
ok(!$meta->{A_publisher}, 'Publisher');
is($meta->{D_creation_date}, "20000129", 'Creation date');
#ok(!$doc->coll_title, 'Collection title');
#ok(!$doc->coll_sub_title, 'Collection subtitle');
#ok(!$doc->coll_editor, 'Collection editor');
#ok(!$doc->coll_author, 'Collection author');
ok(!$meta->{S_text_type}, 'text_type');
is($meta->{S_text_type_art}, 'Bericht', 'text_type art');

# Multipath headers
$path = catdir(dirname(__FILE__), 'corpus','VDI','JAN','00001');
ok($doc = KorAP::XML::Krill->new( path => $path . '/' ), 'Load Korap::Document');
like($doc->path, qr!\Q$path\E/!, 'Path');

ok($doc = KorAP::XML::Krill->new( path => $path ), 'Load Korap::Document');
like($doc->path, qr!\Q$path\E/$!, 'Path');

ok($doc->parse, 'Parse document');
$meta = $doc->meta;

is($doc->text_sigle, 'VDI14/JAN/00001', 'text sigle');
is($doc->doc_sigle, 'VDI14/JAN', 'doc sigle');
is($meta->corpus_sigle, 'VDI14', 'corpus sigle');

is($meta->{T_title}, '10- Zz mit Zahl', 'title');

ok(!$meta->{T_sub_title}, 'subtitle');
is($meta->{D_pub_date}, '20140117', 'pubdate');
is($meta->{S_pub_place}, 'Düsseldorf', 'pubplace');
is($meta->{T_author}, 'Windhövel, Kerstin', 'author');
is($meta->{A_publisher}, 'VDI Verlag GmbH', 'publisher');
ok(!$meta->{A_editor}, 'editor');

ok(!$meta->{S_text_type}, 'text type');
ok(!$meta->{S_text_type_art}, 'text type art');
ok(!$meta->{S_text_type_ref}, 'text type ref');
ok(!$meta->{S_text_column}, 'text column');
ok(!$meta->{S_text_domain}, 'text domain');
ok(!$meta->{D_creation_date}, 'creation date');
ok(!$meta->{S_availability}, 'License');
ok(!$meta->{pages}, 'Pages');
ok(!$meta->{A_file_edition_statement}, 'file edition statement');
ok(!$meta->{A_bibl_edition_statement}, 'bibl edition statement');
is($meta->{A_reference}, 'VDI nachrichten, 17.01.2014, S. 10; 10- Zz mit Zahl [Ausführliche Zitierung nicht verfügbar]', 'Reference');

ok(!$doc->{S_language}, 'Language');
# !!!
# diag 'This may be "de" in the future';

is($meta->{T_doc_title}, 'VDI nachrichten, Januar 2014', 'Doc title');
ok(!$meta->{T_doc_sub_title}, 'Doc Sub title');
ok(!$meta->{A_doc_editor}, 'Doc editor');
ok(!$meta->{T_doc_author}, 'Doc author');

is($meta->{T_corpus_title}, 'VDI nachrichten', 'Corpus title');
ok(!$meta->{T_corpus_sub_title}, 'Corpus Sub title');
is($meta->{A_corpus_editor}, 'Verein Deutscher Ingenieure', 'Corpus editor');
ok(!$meta->{T_corpus_author}, 'Corpus author');

is($meta->keywords('K_keywords'), '', 'Keywords');
is($meta->keywords('K_text_class'), 'Freizeit-Unterhaltung Reisen Politik Ausland', 'Text class');

# WDD
$path = catdir(dirname(__FILE__), 'corpus','WDD','G27','38989');
ok($doc = KorAP::XML::Krill->new( path => $path . '/' ), 'Load Korap::Document');
like($doc->path, qr!\Q$path\E/!, 'Path');
ok($doc->parse, 'Parse document');
$meta = $doc->meta;

is($doc->text_sigle, 'WDD11/G27/38989', 'text sigle');
is($doc->doc_sigle, 'WDD11/G27', 'doc sigle');
is($doc->corpus_sigle, 'WDD11', 'corpus sigle');

is($meta->{T_title}, 'Diskussion:Gunter A. Pilz', 'title');
ok(!$meta->{T_sub_title}, 'subtitle');
is($meta->{D_pub_date}, '20111029', 'pubdate');
is($meta->{S_pub_place}, 'URL:http://de.wikipedia.org', 'pubplace');

is($meta->{T_author}, '€pa, u.a.', 'author');
is($meta->{A_publisher}, 'Wikipedia', 'publisher');
is($meta->{A_editor}, 'wikipedia.org', 'Editor');

is($meta->{S_text_type}, 'Diskussionen zu Enzyklopädie-Artikeln', 'text type');
ok(!$meta->{S_text_type_art}, 'text type art');
ok(!$meta->{S_text_type_ref}, 'text type ref');
ok(!$meta->{S_text_column}, 'text column');
ok(!$meta->{S_text_domain}, 'text domain');

is($meta->{D_creation_date}, '20070707', 'creation date');
is($meta->{S_availability}, 'CC-BY-SA', 'License');
ok(!$meta->{pages}, 'Pages');
ok(!$meta->{A_file_edition_statement}, 'file edition statement');
ok(!$meta->{A_bibl_edition_statement}, 'bibl edition statement');
is($meta->{A_reference}, 'Diskussion:Gunter A. Pilz, In: Wikipedia - URL:http://de.wikipedia.org/wiki/Diskussion:Gunter_A._Pilz: Wikipedia, 2007', 'Reference');

is($meta->{S_language}, 'de', 'Language');

is($meta->{T_doc_title}, 'Wikipedia, Diskussionen zu Artikeln mit Anfangsbuchstabe G, Teil 27', 'Doc title');
ok(!$meta->{T_doc_sub_title}, 'Doc Sub title');
ok(!$meta->{A_doc_editor}, 'Doc editor');
ok(!$meta->{T_doc_author}, 'Doc author');

is($meta->{T_corpus_title}, 'Wikipedia', 'Corpus title');
ok(!$meta->{T_corpus_sub_title}, 'Corpus Sub title');
is($meta->{A_corpus_editor}, 'wikipedia.org', 'Corpus editor');
ok(!$meta->{T_corpus_author}, 'Corpus author');

is($meta->keywords('keywords'), '', 'Keywords');
is($meta->keywords('text_class'), '', 'Text class');

is($meta->{S_availability}, 'CC-BY-SA', 'Availability');

use_ok('KorAP::XML::Meta::I5');

$path = catdir(dirname(__FILE__), 'corpus', 'I5', 'rei-example.i5');
ok($meta = KorAP::XML::Meta::I5->new, 'Construct meta object');
my $dom = Mojo::DOM->new->parse(Mojo::File->new($path)->slurp);
ok($meta->parse($dom->at('idsHeader'), 'corpus'), 'Parse corpus header');

my $hash = $meta->to_hash;
is($hash->{S_availability}, 'CC-BY-SA', 'Availability');
is($hash->{S_language}, 'de', 'Language');
is($hash->{T_corpus_title}, 'Reden und Interviews', 'Corpus title');
is($hash->{corpus_sigle}, 'REI', 'Corpus Sigle');

ok($meta->parse($dom->find('idsHeader')->[1], 'doc'), 'Parse corpus header');

$hash = $meta->to_hash;
is($hash->{S_availability}, 'CC-BY-SA', 'Availability');
is($hash->{S_language}, 'de', 'Language');
is($hash->{T_corpus_title}, 'Reden und Interviews', 'Corpus title');
is($hash->{corpus_sigle}, 'REI', 'Corpus Sigle');
is($hash->{doc_sigle}, 'REI/BNG', 'Document Sigle');
is($hash->{T_doc_title}, 'Reden der Bundestagsfraktion Bündnis 90/DIE GRÜNEN, (2002-2006)', 'Document Sigle');

ok($meta->parse($dom->find('idsHeader')->[2], 'text'), 'Parse corpus header');

$hash = $meta->to_hash;
is($hash->{S_availability}, 'CC-BY-SA', 'Availability');
is($hash->{S_language}, 'de', 'Language');
is($hash->{T_corpus_title}, 'Reden und Interviews', 'Corpus title');
is($hash->{corpus_sigle}, 'REI', 'Corpus Sigle');
is($hash->{doc_sigle}, 'REI/BNG', 'Document Sigle');
is($hash->{T_doc_title}, 'Reden der Bundestagsfraktion Bündnis 90/DIE GRÜNEN, (2002-2006)', 'Document Sigle');

is($hash->{text_sigle}, 'REI/BNG/00001');
is($hash->{T_title}, 'Energiewirtschaft');
is($hash->{T_sub_title}, 'Rede im Deutschen Bundestag am 19.01.2002');
is($hash->{D_creation_date}, '20020119');
is($hash->{D_pub_date}, '20020119');
is($hash->{S_pub_place_key}, 'DE');
is($hash->{A_reference}, 'Hustedt, Michaele: Energiewirtschaft. Rede im Deutschen Bundestag am 19.01.2002, Hrsg: Bundestagsfraktion Bündnis 90/DIE GRÜNEN [Ausführliche Zitierung nicht verfügbar]');
is($hash->{K_text_class}->[0], 'politik');
is($hash->{K_text_class}->[1], 'inland');
is($hash->{T_author}, 'Hustedt, Michaele');
is($hash->{S_pub_place}, 'Berlin');


# UMB45/D38/00001
$path = catdir(dirname(__FILE__), 'corpus','UMB45','D38','00001');
ok($doc = KorAP::XML::Krill->new( path => $path), 'Load Korap::Document');
like($doc->path, qr!\Q$path\E/!, 'Path');

ok($doc->parse, 'Parse document');
$meta = $doc->meta;

is($doc->text_sigle, 'UMB45/D38/00001', 'text sigle');
is($doc->doc_sigle, 'UMB45/D38', 'doc sigle');
is($doc->corpus_sigle, 'UMB45', 'corpus sigle');

is($meta->{T_title}, 'In: Über Schuld und Aufgabe der geistigen Führungsschicht im deutschen politischen Leben der Gegenwart. - Göttingen, 1955', 'title');


done_testing;
__END__



