use strict;
use warnings;
use Test::More;
use File::Basename 'dirname';
use File::Spec::Functions 'catdir';
use Data::Dumper;
use KorAP::XML::Tokenizer;
use KorAP::XML::Krill;
use utf8;

my $path = catdir(dirname(__FILE__), 'PRO-DUD', 'BSP-2013-01', 32);

ok(my $doc = KorAP::XML::Krill->new(
  path => $path . '/'
), 'Create Document');

ok($doc->parse, 'Parse document');

like($doc->path, qr!$path/!, 'Path');

# Metdata
is($doc->text_sigle, 'PRO-DUD_BSP-2013-01.32', 'ID-text');

is($doc->doc_sigle, 'PRO-DUD_BSP-2013-01', 'ID-doc');
is($doc->corpus_sigle, 'PRO-DUD', 'ID-corpus');

is($doc->title, 'Nur Platt, kein Deutsch', 'title');
ok(!$doc->sub_title, 'no subtitle');

is($doc->publisher, 'Dorfblatt GmbH', 'Publisher');
is($doc->pub_date, '20130126');
is($doc->store('sgbrDate'), '2013-01-26');
is($doc->pub_place, 'Stadtingen');

is($doc->doc_title, 'Korpus zur Beobachtung des Schreibgebrauchs im Deutschen', 'Doc title');
is($doc->doc_sub_title, 'Subkorpus Ortsblatt, Jahrgang 2013, Monat Januar', 'Doc Sub title');

is($doc->store('funder'), 'Bundesministerium für Bildung und Forschung', 'Funder');

is($doc->author, 'unbekannt', 'Author');
ok(!$doc->store('sgbrAuthorSex'), 'No Sex');
is($doc->store('sgbrKodex'), 'T', '');

is($doc->keywords_string, 'sgbrKodex:T');

is($doc->language, 'de', 'Language');

ok(!$doc->editor, 'Editor');

ok(!$doc->text_type, 'Text Type');
ok(!$doc->text_type_art, 'Text Type Art');
ok(!$doc->text_type_ref, 'Text Type Ref');
ok(!$doc->text_column, 'Text Column');
ok(!$doc->text_domain, 'Text Domain');
ok(!$doc->creation_date, 'Creation Date');
ok(!$doc->license, 'License');
ok(!$doc->pages, 'Pages');
ok(!$doc->file_edition_statement, 'File Edition Statement');
ok(!$doc->bibl_edition_statement, 'Bibl Edition Statement');
ok(!$doc->reference, 'Reference');


ok(!$doc->doc_editor, 'Doc: editor');
ok(!$doc->doc_author, 'Doc: author');

ok(!$doc->corpus_title, 'Corpus: title');
ok(!$doc->corpus_sub_title, 'Corpus: subtitle');
ok(!$doc->corpus_editor, 'Corpus: editor');
ok(!$doc->corpus_author, 'Corpus: author');

my $hash = $doc->to_hash;
is($hash->{title}, 'Nur Platt, kein Deutsch', 'Corpus title');
is($hash->{store}->{sgbrKodex}, 'T', 'store');


done_testing;


__END__
