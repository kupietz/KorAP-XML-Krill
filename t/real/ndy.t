use strict;
use warnings;
use Test::More;
use Data::Dumper;
use JSON::XS;

if ($ENV{SKIP_REAL}) {
  plan skip_all => 'Skip real tests';
};

use utf8;
use lib 'lib', '../lib';

use File::Basename 'dirname';
use File::Spec::Functions 'catdir';

use_ok('KorAP::XML::Krill');

my $path = catdir(dirname(__FILE__), 'corpus','NDY','296','008718');

ok(my $doc = KorAP::XML::Krill->new( path => $path . '/' ), 'Load Korap::Document');
ok($doc->parse, 'Parse document');

is($doc->text_sigle, 'NDY/296/008718', 'Correct text sigle');
is($doc->doc_sigle, 'NDY/296', 'Correct document sigle');
is($doc->corpus_sigle, 'NDY', 'Correct corpus sigle');

my $meta = $doc->meta;

like($meta->{T_title}, qr!^Kommentar zu: LOCKE hat mein MERCEDES AMG ZERSTÖRT!, 'Title');
ok(!$meta->{T_sub_title}, 'SubTitle');
is($meta->{T_author}, 'Livia Banse', 'Author');
ok(!$meta->{A_editor}, 'Editor');
is($meta->{S_pub_place}, 'San Bruno, California');
is($meta->{A_publisher}, 'YouTube', 'Publisher');

is($meta->{S_text_type},'Kurzmeldungen: YouTube-Kommentare', 'No Text Type');
ok(!$meta->{S_text_type_art}, 'No Text Type Art');
ok(!$meta->{S_text_type_ref}, 'No Text Type Ref');
ok(!$meta->{S_text_domain}, 'No Text Domain');
ok(!$meta->{S_text_column}, 'No Text Column');

is($meta->{K_text_class}->[0], 'entertainment', 'Correct Text Class');
ok(!$meta->{K_text_class}->[1], 'Correct Text Class');

is($meta->{D_pub_date}, '20171204', 'Creation date');
is($meta->{D_creation_date}, '20171204', 'Creation date');
is($meta->{S_availability}, 'QAO-NC-LOC:ids', 'License');
ok(!$meta->{A_pages}, 'Pages');

ok(!$meta->{A_file_edition_statement}, 'File Statement');
ok(!$meta->{A_bibl_edition_statement}, 'Bibl Statement');

like($meta->{A_reference}, qr!NDY\/296\.008718, YouTube, 04\.12\.2017\. Livia Banse: Kommentar zu: LOCKE hat mein MERCEDES AMG ZERSTÖRT.* \(AutoUnfall\), - YouTube!, 'Reference');

is($meta->{S_language}, 'de', 'Language');

is($meta->{T_corpus_title}, 'YouTube', 'Correct Corpus title');
ok(!$meta->{T_corpus_sub_title}, 'Correct Corpus sub title');
ok(!$meta->{T_corpus_author}, 'Correct Corpus author');
ok(!$meta->{A_corpus_editor}, 'Correct Corpus editor');

like($meta->{T_doc_title}, qr!LOCKE hat mein MERCEDES AMG ZERSTÖRT\!.* \(AutoUnfall\)!, 'Correct Doc title');
ok(!$meta->{T_doc_sub_title}, 'Correct Doc sub title');
is($meta->{T_doc_author},'Leon Machère', 'Correct Doc author');
ok(!$meta->{A_doc_editor}, 'Correct doc editor');


done_testing;
__END__
