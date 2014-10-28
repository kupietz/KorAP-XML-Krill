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

use_ok('KorAP::Document');

# WPD/00001
my $path = catdir(dirname(__FILE__), 'WPD/00001');
ok(my $doc = KorAP::Document->new( path => $path . '/' ), 'Load Korap::Document');
is($doc->path, $path . '/', 'Path');

ok($doc = KorAP::Document->new( path => $path ), 'Load Korap::Document');
is($doc->path, $path . '/', 'Path');

ok($doc->parse, 'Parse document');

# Metdata
is($doc->title, 'A', 'title');
ok(!$doc->sub_title, 'subTitle');
is($doc->text_sigle, 'WPD_AAA.00001', 'ID');
is($doc->corpus_sigle, 'WPD', 'corpusID');
is($doc->pub_date, '20050328', 'pubDate');
is($doc->pub_place, 'URL:http://de.wikipedia.org', 'pubPlace');
is($doc->text_class->[0], 'freizeit-unterhaltung', 'TextClass');
is($doc->text_class->[1], 'reisen', 'TextClass');
is($doc->text_class->[2], 'wissenschaft', 'TextClass');
is($doc->text_class->[3], 'populaerwissenschaft', 'TextClass');
ok(!$doc->text_class->[4], 'TextClass');
is($doc->author->[0], 'Ruru', 'author');
is($doc->author->[1], 'Jens.Ol', 'author');
is($doc->author->[2], 'Aglarech', 'author');
ok(!$doc->author->[3], 'author');

# Additional information
is($doc->editor,'wikipedia.org', 'Editor');
is($doc->publisher, 'Wikipedia', 'Publisher');
is($doc->creation_date, '20050000', 'Creation date');
is($doc->coll_title, 'Wikipedia', 'Collection title');
is($doc->coll_sub_title, 'Die freie Enzyklopädie', 'Collection subtitle');
is($doc->coll_editor, 'wikipedia.org', 'Collection editor');
ok(!$doc->coll_author, 'Collection author');
ok(!$doc->text_type, 'No text_type');
ok(!$doc->text_type_art, 'text_type art');

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
ok(!$doc->author->[0], 'author');

# Additional information
ok(!$doc->editor, 'Editor');
is($doc->publisher, 'Braunschweiger Zeitungsverlag, Druckhaus Albert Limbach GmbH & Co. KG', 'Publisher');
is($doc->creation_date, '20130402', 'Creation date');
is($doc->coll_title, 'Braunschweiger Zeitung', 'Collection title');
ok(!$doc->coll_sub_title, 'Collection subtitle');
ok(!$doc->coll_editor, 'Collection editor');
ok(!$doc->coll_author, 'Collection author');
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
ok(!$doc->author->[0], 'author');


# Additional information
ok(!$doc->editor, 'Editor');
ok(!$doc->publisher, 'Publisher');
is($doc->creation_date, '20010402', 'Creation date');
ok(!$doc->coll_title, 'Collection title');
ok(!$doc->coll_sub_title, 'Collection subtitle');
ok(!$doc->coll_editor, 'Collection editor');
ok(!$doc->coll_author, 'Collection author');
ok(!$doc->text_type, 'text_type');
is($doc->text_type_art, 'Bericht', 'text_type art');


# ERL/0001
$path = catdir(dirname(__FILE__), 'ERL/00001');
ok($doc = KorAP::Document->new( path => $path . '/' ), 'Load Korap::Document');

ok($doc->parse, 'Parse document');
is($doc->title, 'Amtsblatt des Landesbezirks Baden [diverse Erlasse]', 'title');
ok(!$doc->sub_title, 'subTitle');
is($doc->text_sigle, 'MK2_ERL.00001', 'ID');
is($doc->corpus_sigle, 'MK2', 'corpusID');
is($doc->pub_date, '00000000', 'pubDate');
is($doc->pub_place, 'Karlsruhe', 'pubPlace');
is($doc->text_class->[0], 'politik', 'TextClass');
is($doc->text_class->[1], 'kommunalpolitik', 'TextClass');
ok(!$doc->text_class->[2], 'TextClass');
ok(!$doc->author->[0], 'author');

# Additional information
ok(!$doc->editor, 'Editor');
is($doc->publisher, 'Badenia Verlag und Druckerei', 'Publisher');
is($doc->creation_date, '19600000', 'Creation date');
diag 'Non-acceptance of creation date ranges is temporary';
ok(!$doc->coll_title, 'Collection title');
ok(!$doc->coll_sub_title, 'Collection subtitle');
ok(!$doc->coll_editor, 'Collection editor');
ok(!$doc->coll_author, 'Collection author');
is($doc->text_type, 'Erlass', 'text_type');
ok(!$doc->text_type_art, 'text_type art');


# A01/02035-substring
$path = catdir(dirname(__FILE__), 'A01/02035-substring');
ok($doc = KorAP::Document->new( path => $path . '/' ), 'Load Korap::Document');

ok($doc->parse, 'Parse document');
ok(!$doc->title, 'title');
ok(!$doc->sub_title, 'subTitle');
is($doc->text_sigle, 'A00_JAN.02035', 'ID');
is($doc->corpus_sigle, 'A00', 'corpusID');
is($doc->pub_date, '20000111', 'pubDate');
ok(!$doc->pub_place, 'pubPlace');
is($doc->text_class->[0], 'sport', 'TextClass');
is($doc->text_class->[1], 'ballsport', 'TextClass');
ok(!$doc->text_class->[2], 'TextClass');
ok(!$doc->author->[0], 'author');

# Additional information
ok(!$doc->editor, 'Editor');
ok(!$doc->publisher, 'Publisher');
is($doc->creation_date, "20000111", 'Creation date');
ok(!$doc->coll_title, 'Collection title');
ok(!$doc->coll_sub_title, 'Collection subtitle');
ok(!$doc->coll_editor, 'Collection editor');
ok(!$doc->coll_author, 'Collection author');
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
ok(!$doc->author->[0], 'author');

# Additional information
ok(!$doc->editor, 'Editor');
ok(!$doc->publisher, 'Publisher');
is($doc->creation_date, "20000113", 'Creation date');
ok(!$doc->coll_title, 'Collection title');
ok(!$doc->coll_sub_title, 'Collection subtitle');
ok(!$doc->coll_editor, 'Collection editor');
ok(!$doc->coll_author, 'Collection author');
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
ok(!$doc->author->[0], 'author');

# Additional information
ok(!$doc->editor, 'Editor');
ok(!$doc->publisher, 'Publisher');
is($doc->creation_date, "20000124", 'Creation date');
ok(!$doc->coll_title, 'Collection title');
ok(!$doc->coll_sub_title, 'Collection subtitle');
ok(!$doc->coll_editor, 'Collection editor');
ok(!$doc->coll_author, 'Collection author');
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
ok(!$doc->author->[0], 'author');

# Additional information
ok(!$doc->editor, 'Editor');
ok(!$doc->publisher, 'Publisher');
is($doc->creation_date, "20000129", 'Creation date');
ok(!$doc->coll_title, 'Collection title');
ok(!$doc->coll_sub_title, 'Collection subtitle');
ok(!$doc->coll_editor, 'Collection editor');
ok(!$doc->coll_author, 'Collection author');
ok(!$doc->text_type, 'text_type');
is($doc->text_type_art, 'Bericht', 'text_type art');

# ART
$path = catdir(dirname(__FILE__), 'artificial');
ok($doc = KorAP::Document->new( path => $path . '/' ), 'Load Korap::Document');
is($doc->path, $path . '/', 'Path');

ok($doc = KorAP::Document->new( path => $path ), 'Load Korap::Document');
is($doc->path, $path . '/', 'Path');

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
is($doc->author->[0], 'Ruru', 'author');
is($doc->author->[1], 'Jens.Ol', 'author');
is($doc->author->[2], 'Aglarech', 'author');
ok(!$doc->author->[3], 'author');

# Additional information
is($doc->editor, 'Nils Diewald', 'Editor');
is($doc->publisher, 'Artificial articles Inc.', 'Publisher');
is($doc->creation_date, '19990601', 'Creation date');
is($doc->coll_title, 'Artificial articles', 'Collection title');
is($doc->coll_sub_title, 'Best of!', 'Collection subtitle');
is($doc->coll_editor, 'Nils Diewald', 'Collection editor');
is($doc->coll_author, 'Nils Diewald', 'Collection author');
is($doc->text_type, 'Zeitung: Tageszeitung', 'No text_type');
is($doc->text_type_art, 'Bericht', 'text_type art');

done_testing;
__END__
