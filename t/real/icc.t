use strict;
use warnings;
use Test::More;
use Data::Dumper;
use JSON::XS;

if ($ENV{SKIP_REAL}) {
  plan skip_all => 'Skip real tests';
};

use Benchmark qw/:hireswallclock/;

my $t = Benchmark->new;

use utf8;
use lib 'lib', '../lib';

use File::Basename 'dirname';
use File::Spec::Functions 'catdir';

use_ok('KorAP::XML::Krill');

# This will check preliminary HNC-Files

# HNC/DOC00001/00001
my $path = catdir(dirname(__FILE__), 'corpus','ICCGER','CCBY-LTE','WMA-00005');

ok(my $doc = KorAP::XML::Krill->new(
  path => $path . '/',
  meta_type => 'ICC'
), 'Load Korap::Document');
ok($doc->parse, 'Parse document');

is($doc->text_sigle, 'ICCGER/CCBY-LTE/WMA-00005', 'Correct text sigle');
is($doc->doc_sigle, 'ICCGER/CCBY-LTE', 'Correct document sigle');
is($doc->corpus_sigle, 'ICCGER', 'Correct corpus sigle');

my $meta = $doc->meta;
like($meta->{T_title}, qr!Affinit.tschromatografie!, 'Title');
is($meta->{S_pub_place}, 'Zug', 'PubPlace');

is($meta->{T_author}, 'Wilke, Marco; Weller, Michael G.', 'Author');

is($meta->{D_pub_date}, '20190000', 'Publication date');

ok(!$meta->{T_sub_title}, 'SubTitle');

is($meta->{A_publisher}, 'Sigwerb Sigwerb', 'Publisher');

is($meta->{S_license}, 'Lizenz (Deutsch): License LogoCreative Commons - CC BY - Namensnennung 4.0 International', 'Licence');

is($meta->{S_iccGenre}, 'Learned_Technology', 'Editor');

is($meta->{A_source}, 'German Reference Corpus DeReKo', 'Editor');


# Norwegian
$path = catdir(dirname(__FILE__), 'corpus','ICCNOR','199', '00002');

ok($doc = KorAP::XML::Krill->new(
  path => $path . '/',
  meta_type => 'ICC'
), 'Load Korap::Document');
ok($doc->parse, 'Parse document');

is($doc->text_sigle, 'NO/199/00002', 'Correct text sigle');
is($doc->doc_sigle, 'NO/199', 'Correct document sigle');
is($doc->corpus_sigle, 'NO', 'Correct corpus sigle');

$meta = $doc->meta;
like($meta->{T_title}, qr!Pengesnakk!, 'Title');
is($meta->{S_pub_place}, 'https://www.pengesnakk.no/', 'PubPlace');

is($meta->{T_author}, 'Kristoffersen, Lise Vermelid', 'Author');

is($meta->{D_pub_date}, '20190000', 'Publication date');

ok(!$meta->{T_sub_title}, 'SubTitle');

ok(!$meta->{A_publisher}, 'Publisher');

ok(!$meta->{S_license}, 'Licence');

is($meta->{S_iccGenre}, 'blog', 'Editor');

ok(!$meta->{A_source}, 'Editor');

# English
$path = catdir(dirname(__FILE__), 'corpus','ICCENG','144', '00005');

ok($doc = KorAP::XML::Krill->new(
  path => $path . '/',
  meta_type => 'ICC'
), 'Load Korap::Document');
ok($doc->parse, 'Parse document');

is($doc->text_sigle, 'EN/144/00005', 'Correct text sigle');
is($doc->doc_sigle, 'EN/144', 'Correct document sigle');
is($doc->corpus_sigle, 'EN', 'Correct corpus sigle');

$meta = $doc->meta;
like($meta->{T_title}, qr!Irish News!, 'Title');
ok(!$meta->{S_pub_place}, 'PubPlace');

ok(!$meta->{T_author}, 'Author');

is($meta->{D_pub_date}, '19940000', 'Publication date');

ok(!$meta->{T_sub_title}, 'SubTitle');

ok(!$meta->{A_publisher}, 'Publisher');

ok(!$meta->{S_license}, 'Licence');

is($meta->{S_iccGenre}, 'PreEdi', 'Editor');

ok(!$meta->{A_source}, 'Editor');




done_testing;
__END__
