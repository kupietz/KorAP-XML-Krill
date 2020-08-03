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

my $path = catdir(dirname(__FILE__), 'CMC-TSK', '2014-09', '2843');

ok(my $doc = KorAP::XML::Krill->new(
  path => $path . '/',
  meta_type => 'Sgbr'
), 'Create Document');

ok($doc->parse, 'Parse document');

like($doc->path, qr!\Q$path\E/!, 'Path');

# Metdata
is($doc->text_sigle, 'CMC-TSK/2014-09/2843', 'ID-text');

is($doc->doc_sigle, 'CMC-TSK/2014-09', 'ID-doc');
is($doc->corpus_sigle, 'CMC-TSK', 'ID-corpus');

my $meta = $doc->meta;

is($meta->{T_title}, '@ Koelle_am_Rhing 10:18', 'title');

ok(!$meta->{T_sub_title}, 'no subtitle');

is($meta->{A_publisher}, 'tagesschau.de', 'Publisher');

is($meta->{D_pub_date}, '20140930');

ok(!$meta->{S_pub_place}, 'No pub place');

is($meta->{T_doc_title}, 'Korpus zur Beobachtung des Schreibgebrauchs im Deutschen', 'Doc title');
is($meta->{T_doc_sub_title}, 'Subkorpus Internettexte, Subkorpus Leserkommentare Tagesschau, Subkorpus September 2014, Subkorpus Beispielauszug', 'Doc Sub title');

is($meta->{'A_funder'}, 'Bundesministerium für Bildung und Forschung', 'Funder');

is($meta->{T_author}, 'privat23', 'Author');
ok(!$meta->{'S_sgbr_author_sex'}, 'No Sex');
ok(!$meta->{'S_sgbr_kodex'}, 'No kodex');
is($meta->{A_reference}, 'http://meta.tagesschau.de/node/090285#comment-1732187', 'Publace ref');

is($meta->keywords('K_keywords'), '');

is($meta->{S_language}, 'de', 'Language');

ok(!$meta->{A_editor}, 'Editor');

ok(!$meta->{S_text_type}, 'Text Type');
ok(!$meta->{S_text_type_art}, 'Text Type Art');
ok(!$meta->{S_text_type_ref}, 'Text Type Ref');
ok(!$meta->{S_text_column}, 'Text Column');
ok(!$meta->{S_text_domain}, 'Text Domain');
ok(!$meta->{D_creation_date}, 'Creation Date');
ok(!$meta->{S_license}, 'License');
ok(!$meta->{A_pages}, 'Pages');
ok(!$meta->{A_file_edition_statement}, 'File Edition Statement');
ok(!$meta->{A_bibl_edition_statement}, 'Bibl Edition Statement');

ok(!$meta->{A_doc_editor}, 'Doc: editor');
ok(!$meta->{T_doc_author}, 'Doc: author');

ok(!$meta->{T_corpus_title}, 'Corpus: title');
ok(!$meta->{T_corpus_sub_title}, 'Corpus: subtitle');
ok(!$meta->{A_corpus_editor}, 'Corpus: editor');
ok(!$meta->{T_corpus_author}, 'Corpus: author');

my $hash = $doc->to_hash;
is($hash->{title}, '@ Koelle_am_Rhing 10:18', 'Corpus title');

# Second document
$path = catdir(dirname(__FILE__), 'CMC-TSK', '2014-09', '3401');

ok($doc = KorAP::XML::Krill->new(
  path => $path . '/',
  meta_type => 'Sgbr'
), 'Create Document');

ok($doc->parse, 'Parse document');

like($doc->path, qr!\Q$path\E/!, 'Path');

# Metdata
is($doc->text_sigle, 'CMC-TSK/2014-09/3401', 'ID-text');

is($doc->doc_sigle, 'CMC-TSK/2014-09', 'ID-doc');
is($doc->corpus_sigle, 'CMC-TSK', 'ID-corpus');


$meta = $doc->meta;
is($meta->{T_title}, '@fitnessfrosch', 'title');

ok(!$meta->{T_sub_title}, 'no subtitle');

is($meta->{A_publisher}, 'tagesschau.de', 'Publisher');

is($meta->{D_pub_date}, '20141001');
is($meta->{'D_sgbr_date'}, '2014-10-01 00:50:00');

ok(!$meta->{S_pub_place}, 'No pub place');

is($meta->{T_doc_title}, 'Korpus zur Beobachtung des Schreibgebrauchs im Deutschen', 'Doc title');
is($meta->{T_doc_sub_title}, 'Subkorpus Internettexte, Subkorpus Leserkommentare Tagesschau, Subkorpus September 2014, Subkorpus Beispielauszug', 'Doc Sub title');

is($meta->{'A_funder'}, 'Bundesministerium für Bildung und Forschung', 'Funder');

is($meta->{T_author}, 'weltoffen', 'Author');
ok(!$meta->{'S_sgbr_author_sex'}, 'No Sex');
ok(!$meta->{'S_sgbr_kodex'}, 'No kodex');
is($meta->{A_reference}, 'http://meta.tagesschau.de/node/090308#comment-1732754', 'Publace ref');

is($meta->keywords('K_keywords'), '');

is($meta->{S_language}, 'de', 'Language');

ok(!$meta->{A_editor}, 'Editor');

ok(!$meta->{S_text_type}, 'Text Type');
ok(!$meta->{S_text_type_art}, 'Text Type Art');
ok(!$meta->{S_text_type_ref}, 'Text Type Ref');
ok(!$meta->{S_text_column}, 'Text Column');
ok(!$meta->{S_text_domain}, 'Text Domain');
ok(!$meta->{D_creation_date}, 'Creation Date');
ok(!$meta->{S_license}, 'License');
ok(!$meta->{A_pages}, 'Pages');
ok(!$meta->{A_file_edition_statement}, 'File Edition Statement');
ok(!$meta->{A_bibl_edition_statement}, 'Bibl Edition Statement');

ok(!$meta->{A_doc_editor}, 'Doc: editor');
ok(!$meta->{T_doc_author}, 'Doc: author');

ok(!$meta->{T_corpus_title}, 'Corpus: title');
ok(!$meta->{T_corpus_sub_title}, 'Corpus: subtitle');
ok(!$meta->{A_corpus_editor}, 'Corpus: editor');
ok(!$meta->{T_corpus_author}, 'Corpus: author');

$hash = $doc->to_hash;
is($hash->{title}, '@fitnessfrosch', 'Corpus title');

done_testing;
__END__

