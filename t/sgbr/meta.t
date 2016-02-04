use strict;
use warnings;
use Test::More;
use File::Basename 'dirname';
use File::Spec::Functions 'catdir';
use Data::Dumper;
use KorAP::XML::Tokenizer;
use KorAP::XML::Krill;
use utf8;

my $path = catdir(dirname(__FILE__), 'TEST', 'BSP', 1);

ok(my $doc = KorAP::XML::Krill->new(
  path => $path . '/'
), 'Create Document');

ok($doc->parse, 'Parse document');

like($doc->path, qr!$path/!, 'Path');

# Metdata
is($doc->text_sigle, 'TEST_BSP.1', 'ID-text');
is($doc->doc_sigle, 'TEST_BSP', 'ID-doc');
is($doc->corpus_sigle, 'TEST', 'ID-corpus');

is($doc->title, 'Sommerüberraschung', 'title');
#is($doc->sub_title, 'Beispiel Text Untertitel', 'title');
#is($doc->pub_date, '20010402', 'Publication date');
#is($doc->pub_place, 'Mannheim', 'Publication place');

is($doc->author, 'TEST.BSP.Autoren.1', 'Author');

is($doc->store('sgbrAuthorAgeClass'), 'X', 'AgeClass');

is($doc->store('sgbrAuthorSex'), 'M', 'Sex');
is($doc->store('sgbrKodex'), 'M', 'Kodex');

is($doc->doc_title, 'Beispielkorpus', 'Doc: title');
is($doc->doc_sub_title, 'Subkorpus Beispieltext', 'Doc: subtitle');

is($doc->language, 'de', 'Language');

ok(!$doc->publisher, 'Publisher');
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
is($hash->{title}, 'Sommerüberraschung', 'Corpus title');
is($hash->{store}->{sgbrAuthorSex}, 'M', 'store');

# Sgbr specific keywords
is($doc->keywords_string, 'sgbrAuthorAgeClass:X sgbrAuthorSex:M sgbrKodex:M');

done_testing;


__END__
