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

my $path = catdir(dirname(__FILE__), 'corpus','REDEW','DOC1','00000');

ok(my $doc = KorAP::XML::Krill->new( path => $path . '/' ), 'Load Korap::Document');
ok($doc->parse, 'Parse document');

is($doc->text_sigle, 'REDEW/DOC1/00000', 'Correct text sigle');
is($doc->doc_sigle, 'REDEW/DOC1', 'Correct document sigle');
is($doc->corpus_sigle, 'REDEW', 'Correct corpus sigle');

my $meta = $doc->meta;
is($meta->{T_title}, 'Gram', 'Title');               # ???
ok(!$meta->{T_sub_title}, 'SubTitle');
ok(!$meta->{T_author}, 'Author');
ok(!$meta->{A_editor}, 'Editor');
ok(!$meta->{S_pub_place}, 'PubPlace');
ok(!$meta->{A_publisher}, 'Publisher');

is($meta->{S_text_type}, '?', 'Text Type');   # ???
ok(!$meta->{S_text_type_art}, 'No Text Type Art');
ok(!$meta->{S_text_type_ref}, 'No Text Type Ref');
ok(!$meta->{S_text_domain}, 'No Text Domain');
ok(!$meta->{S_text_column}, 'No Text Column');

ok(!$meta->{K_text_class}->[0], 'Correct Text Class');

is($meta->{D_pub_date}, '00000000', 'Creation date'); # ???
is($meta->{D_creation_date}, '20200000', 'Creation date');
is($meta->{S_availability}, 'QAO-NC', 'License');           # ???
ok(!$meta->{A_pages}, 'Pages');

ok(!$meta->{A_file_edition_statement}, 'File Statement');
ok(!$meta->{A_bibl_edition_statement}, 'Bibl Statement');

ok(!$meta->{A_reference}, 'Reference');
ok(!$meta->{S_language}, 'Language'); # ???

is($meta->{T_corpus_title}, 'Redewiedergabe', 'Correct Corpus title');
ok(!$meta->{T_corpus_sub_title}, 'Correct Corpus sub title');
ok(!$meta->{T_corpus_author}, 'Correct Corpus author');
ok(!$meta->{A_corpus_editor}, 'Correct Corpus editor');

is($meta->{T_doc_title}, 'Redewiedergabe Dokument 1', 'Correct Doc title');
ok(!$meta->{T_doc_sub_title}, 'Correct Doc sub title');
ok(!$meta->{T_doc_author}, 'Correct Doc author');
ok(!$meta->{A_doc_editor}, 'Correct doc editor');

# Tokenization
use_ok('KorAP::XML::Tokenizer');

my ($token_base_foundry, $token_base_layer) = (qw/drukola Morpho/);

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

is(substr($output->{data}->{text}, 0, 100), 'Cechov,_Anton_Pavlovic_Gram.tg4_1.xml 1886 1880 Gram Čechov, Anton Pavlovič yes yes Erzähltext digbi', 'Primary Data');

is($output->{data}->{name}, 'tokens', 'tokenName');
is($output->{data}->{tokenSource}, 'drukola#morpho', 'tokenSource');
is($output->{version}, '0.03', 'version');

is($output->{data}->{foundries}, '', 'Foundries');
is($output->{data}->{layerInfos}, '', 'layerInfos');
is($output->{data}->{stream}->[0]->[4], 's:Hörst', 'data');

is($output->{textSigle}, 'REDEW/DOC1/00000', 'Correct text sigle');
is($output->{docSigle}, 'REDEW/DOC1', 'Correct document sigle');
is($output->{corpusSigle}, 'REDEW', 'Correct corpus sigle');

is($output->{title}, 'Gram', 'Title');
ok(!$output->{subTitle}, 'Correct SubTitle');
ok(!$output->{author}, 'Author');
ok(!exists $output->{editor}, 'Publisher');

# Add annotations
$tokens->add('DRuKoLa', 'Morpho');
$tokens->add('DeReKo', 'Structure');

$output = decode_json( $tokens->to_json );

my $first = $output->{data}->{stream}->[0];

is('-:tokens$<i>13',$first->[0]);
is('<>:base/s:t$<b>64<i>0<i>197<i>13<b>0',$first->[1]);
is('<>:dereko/s:text$<b>64<i>0<i>197<i>13<b>0',$first->[2]);
is('<>:dereko/s:body$<b>64<i>118<i>197<i>13<b>1',$first->[3]);
is('<>:dereko/s:p$<b>64<i>118<i>197<i>13<b>2',$first->[4]);
is('<>:dereko/s:said$<b>64<i>118<i>197<i>13<b>3<s>1',$first->[5]);
is('@:dereko/s:level:1$<b>17<s>1<i>13',$first->[6]);
is('@:dereko/s:content:speech$<b>17<s>1<i>13',$first->[7]);
is('@:dereko/s:mode:direct$<b>17<s>1<i>13',$first->[8]);
is('@:dereko/s:id:1$<b>17<s>1<i>13',$first->[9]);
is('_0$<i>123<i>128',$first->[10]);
is("drukola/l:H\x{f6}rst",$first->[11]);
is('drukola/m:msd:rfpos',$first->[12]);
is('drukola/m:sentstart:no',$first->[13]);
is('drukola/m:stwr:direct.speech.1',$first->[14]);
is('drukola/p:VVFIN',$first->[15]);
is("i:h\x{f6}rst",$first->[16]);
is("s:H\x{f6}rst",$first->[17]);

my $nine = join(',', @{$output->{data}->{stream}->[9]});
like($nine, qr{drukola\/l:nichts}, 'Nichts');
like($nine, qr{_9\$<i>170<i>176}, 'Term boundaries');
unlike($nine, qr{<>:dereko/s:said\$<b>64<i>176<i>196<i>13<b>4<s>1}, 'Term boundaries');

my $ten = join(',', @{$output->{data}->{stream}->[10]});
like($ten, qr{_10\$<i>177<i>180}, 'Term boundaries');
like($ten, qr{<>:dereko/s:said\$<b>64<i>176<i>196<i>13<b>4<s>1}, 'Term boundaries');

my $eleven = join(',', @{$output->{data}->{stream}->[11]});
like($eleven, qr{_11\$<i>181<i>188}, 'Term boundaries');
like($eleven, qr{<>:dereko/s:seg\$<b>64<i>180<i>188<i>12<b>5<s>1}, 'Segment');


my $twelve = join(',', @{$output->{data}->{stream}->[12]});
like($twelve, qr{_12\$<i>189<i>195}, 'Term boundaries');
like($twelve, qr{drukola/l:Wort}, 'Lemma');
like($twelve, qr{<>:dereko/s:seg\$<b>64<i>188<i>195<i>13<b>5<s>1}, 'Segment');


# Updated format:
$path = catdir(dirname(__FILE__), 'corpus','REDEW','DOC1b','00011');

ok($doc = KorAP::XML::Krill->new( path => $path . '/' ), 'Load Korap::Document');
ok($doc->parse, 'Parse document');

is($doc->text_sigle, 'REDEW/DOC1/00011', 'Correct text sigle');
is($doc->doc_sigle, 'REDEW/DOC1', 'Correct document sigle');
is($doc->corpus_sigle, 'REDEW', 'Correct corpus sigle');

$meta = $doc->meta;

is($meta->{A_distributor}, 'Institut für Deutsche Sprache', 'Distributor');
is($meta->{D_pub_date}, '18730000', 'Publication date');
is($meta->{D_creation_date}, '18730000', 'Publication date');
is($meta->{S_pub_place_key}, 'DE', 'Publication place key');
is($meta->{T_corpus_title}, 'Redewiedergabe', 'Title');
is($meta->{T_doc_title}, 'Redewiedergabe Dokument 1', 'Title');
is($meta->{T_author}, 'Christen, Ada', 'Author');
is($meta->{T_title}, 'Rahel', 'Author');
is($meta->{S_availability}, 'QAO-NC-LOC:ids', 'Availability');
is($meta->{S_text_type_art}, 'Erzähltext', 'Availability');

# Tokenization
use_ok('KorAP::XML::Tokenizer');

($token_base_foundry, $token_base_layer) = (qw/rwk Morpho/);

# Get tokenization
$tokens = KorAP::XML::Tokenizer->new(
  path => $doc->path,
  doc => $doc,
  foundry => $token_base_foundry,
  layer => $token_base_layer,
  name => 'tokens'
);

ok($tokens, 'Token Object is fine');
ok($tokens->parse, 'Token parsing is fine');

$output = decode_json( $tokens->to_json );

is(substr($output->{data}->{text}, 0, 100), 'Er hatte den Kopf weit nach rückwärts gebeugt, seine langen schwarzen Haare lockten sich über den li', 'Primary Data');

# Add annotations
ok($tokens->add('RWK', 'Morpho'));
ok($tokens->add('RWK', 'Structure'));

$output = decode_json( $tokens->to_json );

$first = $output->{data}->{stream}->[0];

is('-:base/paragraphs$<i>1',$first->[0]);
is('-:base/sentences$<i>21',$first->[1]);
is('-:tokens$<i>522',$first->[2]);

is('<>:base/s:s$<b>64<i>0<i>139<i>23<b>1',$first->[3]);
is('<>:base/s:p$<b>64<i>0<i>2631<i>449<b>1',$first->[4]);
is('<>:base/s:t$<b>64<i>0<i>3062<i>522<b>0',$first->[5]);
is('_0$<i>0<i>2',$first->[6]);
is('i:er',$first->[7]);
is('rwk/l:er',$first->[8]);
is('rwk/m:bc:PRO',$first->[9]);
is('rwk/m:case:Nom',$first->[10]);
is('rwk/m:gender:Masc',$first->[11]);
is('rwk/m:number:Sg',$first->[12]);
is('rwk/m:person:3',$first->[13]);
is('rwk/m:type:Pers',$first->[14]);
is('rwk/m:usage:Subst',$first->[15]);
is('rwk/norm:Er',$first->[16]);
is('rwk/p:PPER',$first->[17]);
is('s:Er',$first->[18]);




# Updated format:
$path = catdir(dirname(__FILE__), 'corpus','REDEW','DOC1b','00011');

ok($doc = KorAP::XML::Krill->new( path => $path . '/' ), 'Load Korap::Document');
ok($doc->parse, 'Parse document');

is($doc->text_sigle, 'REDEW/DOC1/00011', 'Correct text sigle');
is($doc->doc_sigle, 'REDEW/DOC1', 'Correct document sigle');
is($doc->corpus_sigle, 'REDEW', 'Correct corpus sigle');

$meta = $doc->meta;

is($meta->{A_distributor}, 'Institut für Deutsche Sprache', 'Distributor');
is($meta->{D_pub_date}, '18730000', 'Publication date');
is($meta->{D_creation_date}, '18730000', 'Publication date');
is($meta->{S_pub_place_key}, 'DE', 'Publication place key');
is($meta->{T_corpus_title}, 'Redewiedergabe', 'Title');
is($meta->{T_doc_title}, 'Redewiedergabe Dokument 1', 'Title');
is($meta->{T_author}, 'Christen, Ada', 'Author');
is($meta->{T_title}, 'Rahel', 'Author');
is($meta->{S_availability}, 'QAO-NC-LOC:ids', 'Availability');
is($meta->{S_text_type_art}, 'Erzähltext', 'Availability');

# Tokenization
use_ok('KorAP::XML::Tokenizer');

($token_base_foundry, $token_base_layer) = (qw/rwk Morpho/);

# Get tokenization
$tokens = KorAP::XML::Tokenizer->new(
  path => $doc->path,
  doc => $doc,
  foundry => $token_base_foundry,
  layer => $token_base_layer,
  name => 'tokens'
);

ok($tokens, 'Token Object is fine');
ok($tokens->parse, 'Token parsing is fine');

$output = decode_json( $tokens->to_json );

is(substr($output->{data}->{text}, 0, 100), 'Er hatte den Kopf weit nach rückwärts gebeugt, seine langen schwarzen Haare lockten sich über den li', 'Primary Data');

# Add annotations
ok($tokens->add('RWK', 'Morpho'));
ok($tokens->add('RWK', 'Structure'));

$output = decode_json( $tokens->to_json );

$first = $output->{data}->{stream}->[0];

is('-:base/paragraphs$<i>1',$first->[0]);
is('-:base/sentences$<i>21',$first->[1]);
is('-:tokens$<i>522',$first->[2]);
is('<>:base/s:s$<b>64<i>0<i>139<i>23<b>1',$first->[3]);
is('<>:base/s:p$<b>64<i>0<i>2631<i>449<b>1',$first->[4]);
is('<>:base/s:t$<b>64<i>0<i>3062<i>522<b>0',$first->[5]);
is('_0$<i>0<i>2',$first->[6]);
is('i:er',$first->[7]);
is('rwk/l:er',$first->[8]);
is('rwk/m:bc:PRO',$first->[9]);
is('rwk/m:case:Nom',$first->[10]);
is('rwk/m:gender:Masc',$first->[11]);
is('rwk/m:number:Sg',$first->[12]);
is('rwk/m:person:3',$first->[13]);
is('rwk/m:type:Pers',$first->[14]);
is('rwk/m:usage:Subst',$first->[15]);
is('rwk/norm:Er',$first->[16]);
is('rwk/p:PPER',$first->[17]);
is('s:Er',$first->[18]);


$path = catdir(dirname(__FILE__), 'corpus','REDEW','DOC1b','00001');

ok($doc = KorAP::XML::Krill->new( path => $path . '/' ), 'Load Korap::Document');
ok($doc->parse, 'Parse document');

is($doc->text_sigle, 'REDEW/DOC1/00001', 'Correct text sigle');
is($doc->doc_sigle, 'REDEW/DOC1', 'Correct document sigle');
is($doc->corpus_sigle, 'REDEW', 'Correct corpus sigle');

$meta = $doc->meta;

is($meta->{A_distributor}, 'Institut für Deutsche Sprache', 'Distributor');
is($meta->{D_pub_date}, '18950000', 'Publication date');
is($meta->{D_creation_date}, '18950000', 'Publication date');
is($meta->{S_pub_place_key}, 'DE', 'Publication place key');
is($meta->{T_corpus_title}, 'Redewiedergabe', 'Title');
is($meta->{T_doc_title}, 'Redewiedergabe Dokument 1', 'Title');
is($meta->{T_author}, 'Busch, Wilhelm', 'Author');
is($meta->{T_title}, 'Der Schmetterling', 'Titel');
is($meta->{S_availability}, 'QAO-NC-LOC:ids', 'Availability');
is($meta->{S_text_type_art}, 'Erzähltext', 'Availability');

# Tokenization
use_ok('KorAP::XML::Tokenizer');

($token_base_foundry, $token_base_layer) = (qw/rwk Morpho/);

# Get tokenization
$tokens = KorAP::XML::Tokenizer->new(
  path => $doc->path,
  doc => $doc,
  foundry => $token_base_foundry,
  layer => $token_base_layer,
  name => 'tokens'
);

ok($tokens, 'Token Object is fine');
ok($tokens->parse, 'Token parsing is fine');

$output = decode_json( $tokens->to_json );

is(substr($output->{data}->{text}, 0, 100), 'Eier! Schinken! Franzwein! Flink, marsch!« schrie ihn gebieterisch der Nazi an und kniff dabei einen', 'Primary Data');

# Add annotations
ok($tokens->add('RWK', 'Morpho'));
ok($tokens->add('RWK', 'Structure'));

$output = decode_json( $tokens->to_json );

$first = $output->{data}->{stream}->[0];

is('-:base/paragraphs$<i>1',$first->[0]);
is('-:base/sentences$<i>33',$first->[1]);
is('-:tokens$<i>511',$first->[2]);
is('<>:base/s:s$<b>64<i>0<i>6<i>2<b>1',$first->[3]);
is('<>:base/s:p$<b>64<i>0<i>2010<i>307<b>1',$first->[4]);
is('<>:base/s:t$<b>64<i>0<i>3246<i>511<b>0',$first->[5]);


$path = catdir(dirname(__FILE__), 'corpus','REDEW','DOC1b','00558');

ok($doc = KorAP::XML::Krill->new( path => $path . '/' ), 'Load Korap::Document');
ok($doc->parse, 'Parse document');

is($doc->text_sigle, 'REDEW/DOC1/00558', 'Correct text sigle');
is($doc->doc_sigle, 'REDEW/DOC1', 'Correct document sigle');
is($doc->corpus_sigle, 'REDEW', 'Correct corpus sigle');

$meta = $doc->meta;

# Tokenization
use_ok('KorAP::XML::Tokenizer');

($token_base_foundry, $token_base_layer) = (qw/rwk Morpho/);

# Get tokenization
$tokens = KorAP::XML::Tokenizer->new(
  path => $doc->path,
  doc => $doc,
  foundry => $token_base_foundry,
  layer => $token_base_layer,
  name => 'tokens'
);

ok($tokens, 'Token Object is fine');
ok($tokens->parse, 'Token parsing is fine');

$output = decode_json( $tokens->to_json );

is(substr($output->{data}->{text}, 0, 100), 'Außer den sechs größten Vereinigungen haben sich 59 keiner Körperschaft angehörige Künstler angemeld', 'Primary Data');

# Add annotations
ok($tokens->add('RWK', 'Morpho'));
ok($tokens->add('RWK', 'Structure'));

$output = decode_json( $tokens->to_json );

$first = $output->{data}->{stream}->[0];

is('-:base/paragraphs$<i>1',$first->[0]);
is('-:base/sentences$<i>68',$first->[1]);

done_testing;
