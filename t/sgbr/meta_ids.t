use strict;
use warnings;
use Test::More;
use File::Basename 'dirname';
use File::Spec::Functions 'catdir';
use Data::Dumper;
use KorAP::XML::Tokenizer;
use KorAP::XML::Krill;
use utf8;

my $path = catdir(dirname(__FILE__), 'CMC-TSK', '2014-09', '2843');

ok(my $doc = KorAP::XML::Krill->new(
  path => $path . '/'
), 'Create Document');

ok($doc->parse, 'Parse document');

like($doc->path, qr!$path/!, 'Path');

# Metdata
is($doc->text_sigle, 'CMC-TSK_2014-09.2843', 'ID-text');

is($doc->doc_sigle, 'CMC-TSK_2014-09', 'ID-doc');
is($doc->corpus_sigle, 'CMC-TSK', 'ID-corpus');

is($doc->title, '@ Koelle_am_Rhing 10:18', 'title');

ok(!$doc->sub_title, 'no subtitle');

is($doc->publisher, 'tagesschau.de', 'Publisher');

is($doc->pub_date, '20140930');

ok(!$doc->pub_place, 'No pub place');

is($doc->doc_title, 'Korpus zur Beobachtung des Schreibgebrauchs im Deutschen', 'Doc title');
is($doc->doc_sub_title, 'Subkorpus Internettexte, Subkorpus Leserkommentare Tagesschau, Subkorpus September 2014, Subkorpus Beispielauszug', 'Doc Sub title');

is($doc->store('funder'), 'Bundesministerium für Bildung und Forschung', 'Funder');

is($doc->author, 'privat23', 'Author');
ok(!$doc->store('sgbrAuthorSex'), 'No Sex');
ok(!$doc->store('sgbrKodex'), 'No kodex');
is($doc->reference, 'http://meta.tagesschau.de/node/090285#comment-1732187', 'Publace ref');

is($doc->keywords_string, '');

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

ok(!$doc->doc_editor, 'Doc: editor');
ok(!$doc->doc_author, 'Doc: author');

ok(!$doc->corpus_title, 'Corpus: title');
ok(!$doc->corpus_sub_title, 'Corpus: subtitle');
ok(!$doc->corpus_editor, 'Corpus: editor');
ok(!$doc->corpus_author, 'Corpus: author');

my $hash = $doc->to_hash;
is($hash->{title}, '@ Koelle_am_Rhing 10:18', 'Corpus title');


# Second document

$path = catdir(dirname(__FILE__), 'CMC-TSK', '2014-09', '3401');

ok($doc = KorAP::XML::Krill->new(
  path => $path . '/'
), 'Create Document');

ok($doc->parse, 'Parse document');

like($doc->path, qr!$path/!, 'Path');

# Metdata
is($doc->text_sigle, 'CMC-TSK_2014-09.3401', 'ID-text');

is($doc->doc_sigle, 'CMC-TSK_2014-09', 'ID-doc');
is($doc->corpus_sigle, 'CMC-TSK', 'ID-corpus');

is($doc->title, '@fitnessfrosch', 'title');

ok(!$doc->sub_title, 'no subtitle');

is($doc->publisher, 'tagesschau.de', 'Publisher');

is($doc->pub_date, '20141001');
is($doc->store('sgbrDate'), '2014-10-01 00:50:00');

ok(!$doc->pub_place, 'No pub place');

is($doc->doc_title, 'Korpus zur Beobachtung des Schreibgebrauchs im Deutschen', 'Doc title');
is($doc->doc_sub_title, 'Subkorpus Internettexte, Subkorpus Leserkommentare Tagesschau, Subkorpus September 2014, Subkorpus Beispielauszug', 'Doc Sub title');

is($doc->store('funder'), 'Bundesministerium für Bildung und Forschung', 'Funder');

is($doc->author, 'weltoffen', 'Author');
ok(!$doc->store('sgbrAuthorSex'), 'No Sex');
ok(!$doc->store('sgbrKodex'), 'No kodex');
is($doc->reference, 'http://meta.tagesschau.de/node/090308#comment-1732754', 'Publace ref');

is($doc->keywords_string, '');

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

ok(!$doc->doc_editor, 'Doc: editor');
ok(!$doc->doc_author, 'Doc: author');

ok(!$doc->corpus_title, 'Corpus: title');
ok(!$doc->corpus_sub_title, 'Corpus: subtitle');
ok(!$doc->corpus_editor, 'Corpus: editor');
ok(!$doc->corpus_author, 'Corpus: author');

$hash = $doc->to_hash;
is($hash->{title}, '@fitnessfrosch', 'Corpus title');

done_testing;
__END__

