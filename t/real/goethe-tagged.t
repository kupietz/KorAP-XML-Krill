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

# This will Check Goethe-Files without base annotations!

# GOE/AGA/03828
my $path = catdir(dirname(__FILE__), '../corpus/GOE-TAGGED/AGA/03828');

ok(my $doc = KorAP::XML::Krill->new( path => $path . '/' ), 'Load Korap::Document');
ok($doc->parse, 'Parse document');

is($doc->text_sigle, 'GOE/AGA/03828', 'Correct text sigle');
is($doc->doc_sigle, 'GOE/AGA', 'Correct document sigle');
is($doc->corpus_sigle, 'GOE', 'Correct corpus sigle');

my $meta = $doc->meta;
is($meta->{T_title}, 'Autobiographische Einzelheiten', 'Title');

is($meta->{S_pub_place}, 'München', 'PubPlace');
is($meta->{D_pub_date}, '19820000', 'Creation Date');
ok(!$meta->{T_sub_title}, 'SubTitle');
is($meta->{T_author}, 'Goethe, Johann Wolfgang von', 'Author');

is($meta->{A_publisher}, 'Verlag C. H. Beck', 'Publisher');
ok(!$meta->{A_editor}, 'Publisher');
is($meta->{S_text_type}, 'Autobiographie', 'Correct Text Type');
ok(!$meta->{S_text_type_art}, 'Correct Text Type Art');
ok(!$meta->{S_text_type_ref}, 'Correct Text Type Ref');
ok(!$meta->{S_text_column}, 'Correct Text Column');
ok(!$meta->{S_text_domain}, 'Correct Text Domain');
is($meta->{D_creation_date}, '18200000', 'Creation Date');

is($meta->{A_src_pages}, '529-547', 'Pages');
ok(!$meta->{A_file_edition_statement}, 'File Ed Statement');
ok(!$meta->{A_bibl_edition_statement}, 'Bibl Ed Statement');
is($meta->{A_reference} . "\n", <<'REF', 'Author');
Goethe, Johann Wolfgang von: Autobiographische Einzelheiten, (Geschrieben bis 1832), In: Goethe, Johann Wolfgang von: Goethes Werke, Bd. 10, Autobiographische Schriften II, Hrsg.: Trunz, Erich. München: Verlag C. H. Beck, 1982, S. 529-547
REF
is($meta->{S_language}, 'de', 'Language');


is($meta->{T_corpus_title}, 'Goethes Werke', 'Correct Corpus title');
ok(!$meta->{T_corpus_sub_title}, 'Correct Corpus Sub title');
is($meta->{T_corpus_author}, 'Goethe, Johann Wolfgang von', 'Correct Corpus author');
is($meta->{A_corpus_editor}, 'Trunz, Erich', 'Correct Corpus editor');

is($meta->{T_doc_title}, 'Goethe: Autobiographische Schriften II, (1817-1825, 1832)',
   'Correct Doc title');
ok(!$meta->{T_doc_sub_title}, 'Correct Doc Sub title');
ok(!$meta->{T_doc_author}, 'Correct Doc author');
ok(!$meta->{A_doc_editor}, 'Correct Doc editor');

# Tokenization
use_ok('KorAP::XML::Tokenizer');

my ($token_base_foundry, $token_base_layer) = (qw/Base Tokens_conservative/);

# Get tokenization
my $tokens = KorAP::XML::Tokenizer->new(
  path => $doc->path,
  doc => $doc,
  foundry => $token_base_foundry,
  layer => $token_base_layer,
  name => 'tokens'
);
ok($tokens, 'Token Object is fine');
ok($tokens->parse, 'Token parsing is fine');

my $output = decode_json( $tokens->to_json );

is(substr($output->{data}->{text}, 0, 100), 'Autobiographische einzelheiten Selbstschilderung (1) immer tätiger, nach innen und außen fortwirkend', 'Primary Data');
is($output->{data}->{name}, 'tokens', 'tokenName');
is($output->{data}->{tokenSource}, 'base#tokens_conservative', 'tokenSource');
is($output->{version}, '0.03', 'version');
is($output->{data}->{foundries}, '', 'Foundries');
is($output->{data}->{layerInfos}, '', 'layerInfos');
is($output->{data}->{stream}->[0]->[4], 's:Autobiographische', 'data');

is($output->{textSigle}, 'GOE/AGA/03828', 'Correct text sigle');
is($output->{docSigle}, 'GOE/AGA', 'Correct document sigle');
is($output->{corpusSigle}, 'GOE', 'Correct corpus sigle');

is($output->{author}, 'Goethe, Johann Wolfgang von', 'Author');
is($output->{pubPlace}, 'München', 'PubPlace');
is($output->{pubDate}, '19820000', 'Creation Date');
is($output->{title}, 'Autobiographische Einzelheiten', 'Title');
ok(!exists $output->{subTitle}, 'subTitle');

is($output->{publisher}, 'Verlag C. H. Beck', 'Publisher');
ok(!exists $output->{editor}, 'Editor');
is($output->{textType}, 'Autobiographie', 'Correct Text Type');
ok(!exists $output->{textTypeArt}, 'Correct Text Type');
ok(!exists $output->{textTypeRef}, 'Correct Text Type');
ok(!exists $output->{textColumn}, 'Correct Text Type');
ok(!exists $output->{textDomain}, 'Correct Text Type');
is($output->{creationDate}, '18200000', 'Creation Date');
is($output->{srcPages}, '529-547', 'Pages');
ok(!exists $output->{fileEditionStatement}, 'Correct Text Type');
ok(!exists $output->{biblEditionStatement}, 'Correct Text Type');
is($output->{reference} . "\n", <<'REF', 'Author');
Goethe, Johann Wolfgang von: Autobiographische Einzelheiten, (Geschrieben bis 1832), In: Goethe, Johann Wolfgang von: Goethes Werke, Bd. 10, Autobiographische Schriften II, Hrsg.: Trunz, Erich. München: Verlag C. H. Beck, 1982, S. 529-547
REF
is($output->{language}, 'de', 'Language');

is($output->{corpusTitle}, 'Goethes Werke', 'Correct Corpus title');
ok(!exists $output->{corpusSubTitle}, 'Correct Text Type');
is($output->{corpusAuthor}, 'Goethe, Johann Wolfgang von', 'Correct Corpus title');
is($output->{corpusEditor}, 'Trunz, Erich', 'Editor');

is($output->{docTitle}, 'Goethe: Autobiographische Schriften II, (1817-1825, 1832)', 'Correct Corpus title');
ok(!exists $output->{docSubTitle}, 'Correct Text Type');
ok(!exists $output->{docAuthor}, 'Correct Text Type');
ok(!exists $output->{docEditor}, 'Correct Text Type');

## Base
$tokens->add('DeReKo', 'Structure', 'base_sentences_paragraphs');
ok($tokens->add('DRuKoLa', 'Morpho'), 'Add Drukola');

$output = $tokens->to_data;

is($output->{data}->{foundries}, 'dereko dereko/structure dereko/structure/base_sentences_paragraphs drukola drukola/morpho', 'Foundries');

is($output->{data}->{layerInfos}, 'dereko/s=spans drukola/l=tokens drukola/m=tokens drukola/p=tokens', 'layerInfos');

my $token = join('||', @{$output->{data}->{stream}->[7]});

like($token, qr!drukola/p:ADV!, 'data');
like($token, qr!drukola/m:\@ADVL!, 'data');

done_testing;
__END__
