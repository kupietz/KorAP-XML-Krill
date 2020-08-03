use strict;
use warnings;
use Test::More;
use File::Basename 'dirname';
use File::Spec::Functions 'catdir';
use Data::Dumper;
use KorAP::XML::Tokenizer;
use KorAP::XML::Krill;
use utf8;

if ($ENV{SKIP_REAL}) {
  plan skip_all => 'Skip real tests';
};

my $path = catdir(dirname(__FILE__), 'TEST', 'BSP', 1);

ok(my $doc = KorAP::XML::Krill->new(
  path => $path . '/',
  meta_type => 'Sgbr'
), 'Create Document');

ok($doc->parse, 'Parse document');

like($doc->path, qr!\Q$path\E/!, 'Path');

# Metdata
is($doc->text_sigle, 'TEST/BSP/1', 'ID-text');
is($doc->doc_sigle, 'TEST/BSP', 'ID-doc');
is($doc->corpus_sigle, 'TEST', 'ID-corpus');

my $meta = $doc->meta;

is($meta->{T_title}, 'Sommerüberraschung', 'title');
is($meta->{T_author}, 'TEST.BSP.Autoren.1', 'Author');
is($meta->{'S_sgbr_author_age_class'}, 'X', 'AgeClass');

is($meta->{'S_sgbr_author_sex'}, 'M', 'Sex');
is($meta->{'S_sgbr_kodex'}, 'M', 'Kodex');

is($meta->{T_doc_title}, 'Beispielkorpus', 'Doc: title');
is($meta->{T_doc_sub_title}, 'Subkorpus Beispieltext', 'Doc: subtitle');

is($meta->{S_language}, 'de', 'Language');

ok(!$meta->{A_publisher}, 'Publisher');
ok(!$meta->{A_editor}, 'Editor');
ok(!$meta->{S_text_type}, 'Text Type');
ok(!$meta->{S_text_type_art}, 'Text Type Art');
ok(!$meta->{S_text_type_ref}, 'Text Type Ref');
ok(!$meta->{S_text_column}, 'Text Column');
ok(!$meta->{S_text_domain}, 'Text Domain');
ok(!$meta->{D_creation_date}, 'Creation Date');
ok(!$meta->{license}, 'License');
ok(!$meta->{pages}, 'Pages');
ok(!$meta->{A_file_edition_statement}, 'File Edition Statement');
ok(!$meta->{A_bibl_edition_statement}, 'Bibl Edition Statement');
ok(!$meta->{A_reference}, 'Reference');

ok(!$meta->{A_doc_editor}, 'Doc: editor');
ok(!$meta->{T_doc_author}, 'Doc: author');

ok(!$meta->{T_corpus_title}, 'Corpus: title');
ok(!$meta->{T_corpus_sub_title}, 'Corpus: subtitle');
ok(!$meta->{A_corpus_editor}, 'Corpus: editor');
ok(!$meta->{T_corpus_author}, 'Corpus: author');

my $hash = $doc->to_hash;
is($hash->{title}, 'Sommerüberraschung', 'Corpus title');
is($hash->{sgbrAuthorSex}, 'M', 'additional');

# Sgbr specific keywords
is($meta->keywords('K_keywords'), 'sgbrAuthorAgeClass:X sgbrAuthorSex:M sgbrKodex:M');


done_testing;


__END__
