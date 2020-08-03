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

my $path = catdir(dirname(__FILE__), 'PRO-DUD', 'BSP-2013-01', 32);

ok(my $doc = KorAP::XML::Krill->new(
  path => $path . '/',
  meta_type => 'Sgbr'
), 'Create Document');

ok($doc->parse, 'Parse document');

like($doc->path, qr!\Q$path\E/!, 'Path');

# Metdata
is($doc->text_sigle, 'PRO-DUD/BSP-2013-01/32', 'ID-text');
is($doc->doc_sigle, 'PRO-DUD/BSP-2013-01', 'ID-doc');
is($doc->corpus_sigle, 'PRO-DUD', 'ID-corpus');

my $meta = $doc->meta;
is($meta->{T_title}, 'Nur Platt, kein Deutsch', 'title');
ok(!$meta->{T_sub_title}, 'no subtitle');

is($meta->{A_publisher}, 'Dorfblatt GmbH', 'Publisher');
is($meta->{D_pub_date}, '20130126');
is($meta->{D_sgbr_date}, '2013-01-26');
is($meta->{S_pub_place}, 'Stadtingen');

is($meta->{T_doc_title}, 'Korpus zur Beobachtung des Schreibgebrauchs im Deutschen', 'Doc title');
is($meta->{T_doc_sub_title}, 'Subkorpus Ortsblatt, Jahrgang 2013, Monat Januar', 'Doc Sub title');

is($meta->{'A_funder'}, 'Bundesministerium für Bildung und Forschung', 'Funder');

is($meta->{T_author}, 'unbekannt', 'Author');
ok(!$meta->{'S_sgbr_author_sex'}, 'No Sex');
is($meta->{'S_sgbr_kodex'}, 'T', '');

is($meta->keywords('K_keywords'), 'sgbrKodex:T');

is($meta->{S_language}, 'de', 'Language');

ok(!$meta->{A_editor}, 'Editor');

ok(!$meta->{S_text_type}, 'Text Type');
ok(!$meta->{S_text_type_art}, 'Text Type Art');
ok(!$meta->{S_text_type_ref}, 'Text Type Ref');
ok(!$meta->{S_text_column}, 'Text Column');
ok(!$meta->{S_text_domain}, 'Text Domain');
ok(!$meta->{D_creation_date}, 'Creation Date');
ok(!$meta->{A_license}, 'License');
ok(!$meta->{A_pages}, 'Pages');
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
is($hash->{title}, 'Nur Platt, kein Deutsch', 'Corpus title');
is($hash->{sgbrKodex}, 'T', 'store');


done_testing;


__END__
