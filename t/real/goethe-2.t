use strict;
use warnings;
use Test::More;
use Data::Dumper;
use JSON::XS;

use Benchmark qw/:hireswallclock/;

my $t = Benchmark->new;

use utf8;
use lib 'lib', '../lib';

use File::Basename 'dirname';
use File::Spec::Functions 'catdir';

use_ok('KorAP::XML::Krill');

# This will Check Goethe-Files without base annotations!

# GOE/AGA/03828
my $path = catdir(dirname(__FILE__), '../corpus/GOE2/AGA/03828');

ok(my $doc = KorAP::XML::Krill->new( path => $path . '/' ), 'Load Korap::Document');
ok($doc->parse, 'Parse document');

is($doc->text_sigle, 'GOE/AGA/03828', 'Correct text sigle');
is($doc->doc_sigle, 'GOE/AGA', 'Correct document sigle');
is($doc->corpus_sigle, 'GOE', 'Correct corpus sigle');

my $meta = $doc->meta;
is($meta->{title}, 'Autobiographische Einzelheiten', 'Title');
is($meta->{pub_place}, 'München', 'PubPlace');
is($meta->{pub_date}, '19820000', 'Creation Date');
ok(!$meta->{sub_title}, 'SubTitle');
is($meta->{author}, 'Goethe, Johann Wolfgang von', 'Author');

is($meta->{publisher}, 'Verlag C. H. Beck', 'Publisher');
ok(!$meta->{editor}, 'Publisher');
is($meta->{text_type}, 'Autobiographie', 'Correct Text Type');
ok(!$meta->{text_type_art}, 'Correct Text Type Art');
ok(!$meta->{text_type_ref}, 'Correct Text Type Ref');
ok(!$meta->{text_column}, 'Correct Text Column');
ok(!$meta->{text_domain}, 'Correct Text Domain');
is($meta->{creation_date}, '18200000', 'Creation Date');
is($meta->{availability}, 'QAO-NC', 'License');
is($meta->{src_pages}, '529-547', 'Pages');
ok(!$meta->{file_edition_statement}, 'File Ed Statement');
ok(!$meta->{bibl_edition_statement}, 'Bibl Ed Statement');
is($meta->{reference} . "\n", <<'REF', 'Author');
Goethe, Johann Wolfgang von: Autobiographische Einzelheiten, (Geschrieben bis 1832), In: Goethe, Johann Wolfgang von: Goethes Werke, Bd. 10, Autobiographische Schriften II, Hrsg.: Trunz, Erich. München: Verlag C. H. Beck, 1982, S. 529-547
REF
is($meta->{language}, 'de', 'Language');


is($meta->{corpus_title}, 'Goethes Werke', 'Correct Corpus title');
ok(!$meta->{corpus_sub_title}, 'Correct Corpus Sub title');
is($meta->{corpus_author}, 'Goethe, Johann Wolfgang von', 'Correct Corpus author');
is($meta->{corpus_editor}, 'Trunz, Erich', 'Correct Corpus editor');

is($meta->{doc_title}, 'Goethe: Autobiographische Schriften II, (1817-1825, 1832)',
   'Correct Doc title');
ok(!$meta->{doc_sub_title}, 'Correct Doc Sub title');
ok(!$meta->{doc_author}, 'Correct Doc author');
ok(!$meta->{doc_editor}, 'Correct Doc editor');

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
is($output->{availability}, 'QAO-NC', 'License');
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
$tokens->add('DeReKo', 'Structure', 'base_sentences_paragraphs_pagebreaks');

$output = $tokens->to_data;

is($output->{data}->{foundries}, 'dereko dereko/structure dereko/structure/base_sentences_paragraphs_pagebreaks', 'Foundries');
is($output->{data}->{layerInfos}, 'dereko/s=spans', 'layerInfos');
my $first_token = join('||', @{$output->{data}->{stream}->[0]});
like($first_token, qr/s:Autobiographische/, 'data');
like($first_token, qr/_0\$<i>0<i>17/, 'data');
like($first_token, qr!<>:dereko/s:s\$<b>64<i>0<i>30<i>2<b>4!, 'data');
like($first_token, qr!<>:base\/s:t\$<b>64<i>0<i>35242<i>5233<b>0!, 'data');
# like($first_token, qr!<>:base\/s:t\$<b>64<i>0<i>35250<i>5233<b>0!, 'data');
like($first_token, qr!<>:base/s:s\$<b>64<i>0<i>30<i>2<b>2!, 'data');
like($first_token, qr!-:base\/paragraphs\$\<i\>14!, 'data');
like($first_token, qr!-:base\/sentences\$\<i\>215!, 'data');

is($output->{data}->{stream}->[378]->[-1], '~:base/s:pb$<i>530<i>2469', 'Pagebreaks');

# Check paragraph
$first_token = join('||', @{$output->{data}->{stream}->[4]});
like($first_token, qr/s:immer/, 'data');
like($first_token, qr!<>:base\/s:s\$<b>64<i>53<i>254<i>32<b>2!, 'data');
like($first_token, qr!<>:dereko\/s:s\$<b>64<i>53<i>254<i>32<b>5<s>1!, 'data');
like($first_token, qr!<>:base/s:p\$\<b>64<i>53<i>3299<i>504<b>1!, 'data');
like($first_token, qr!<>:dereko/s:p\$\<b>64<i>53<i>3299<i>504<b>4!, 'data');

$first_token = join('||', @{$output->{data}->{stream}->[180]});
like($first_token, qr/i:geschäften/, 'data');

## MarMoT
ok($tokens->add('MarMoT', 'Morpho'), 'Add marmot');

$output = $tokens->to_data;

is($output->{data}->{foundries}, 'dereko dereko/structure dereko/structure/base_sentences_paragraphs_pagebreaks marmot marmot/morpho', 'Foundries');

is($output->{data}->{layerInfos}, 'dereko/s=spans marmot/m=tokens marmot/p=tokens', 'layerInfos');
$first_token = join('||', @{$output->{data}->{stream}->[0]});
like($first_token, qr!marmot/m:case:nom!, 'Marmot case');
like($first_token, qr!marmot/m:degree:pos!, 'Marmot degree');
like($first_token, qr!marmot/m:gender:fem!, 'Marmot gender');
like($first_token, qr!marmot/m:number:pl!, 'Marmot number');
like($first_token, qr!marmot/p:ADJA!, 'Marmot part of speech');

done_testing;
__END__
