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
use_ok('KorAP::XML::Meta::I5');
use_ok('KorAP::XML::Meta::NKJP');
use_ok('KorAP::XML::Annotation::NKJP::NamedEntities');

my $path = catdir(dirname(__FILE__), 'corpus','NKJP','NKJP','KOT');

ok(my $doc = KorAP::XML::Krill->new( path => $path . '/', meta_type => 'NKJP' ), 'Load Korap::Document');
ok($doc->parse, 'Parse document');

is($doc->text_sigle, 'NKJP/NKJP/KOT', 'Correct text sigle');
is($doc->doc_sigle, 'NKJP/NKJP', 'Correct document sigle');
is($doc->corpus_sigle, 'NKJP', 'Correct corpus sigle');

my $meta = $doc->meta;

is($meta->{T_title}, 'TEI P5 encoded version of sample(s) of "Kot"', 'Title');
is($meta->{T_corpus_title}, 'Narodowy Korpus Języka Polskiego -- podkorpus zawierający 1 milion słów', 'Title');

is($meta->{K_nkjp_channel}->[0], 'miesiecznik', 'NKJP-Channel');
ok(!$meta->{K_nkjp_channel}->[1], 'NKJP-Channel');
is($meta->{K_nkjp_type}->[0], 'publicystyka i wiadomości prasowe', 'NKJP-Type');
ok(!$meta->{K_nkjp_type}->[1], 'NKJP-Type');

ok($doc = KorAP::XML::Krill->new( path => $path . '/', meta_type => 'NKJP', lang => 'en' ), 'Load Korap::Document');
ok($doc->parse, 'Parse document');
$meta = $doc->meta;

is($meta->{T_title}, 'TEI P5 encoded version of sample(s) of "Kot"', 'Title');
is($meta->{T_corpus_title}, 'National Corpus of Polish -- the 1 million word subcorpus', 'Language sensitive Title');

ok(!$meta->{T_sub_title}, 'SubTitle');
ok(!$meta->{T_author}, 'Author');
ok(!$meta->{A_editor}, 'Editor');
ok(!$meta->{S_pub_place}, 'PubPlace');
ok(!$meta->{A_publisher},  'Publisher');

ok(!$meta->{S_text_type}, 'No Text Type');
ok(!$meta->{S_text_type_art}, 'No Text Type Art');
ok(!$meta->{S_text_type_ref}, 'No Text Type Ref');
ok(!$meta->{S_text_domain}, 'No Text Domain');
ok(!$meta->{S_text_column}, 'No Text Column');

is($meta->{K_nkjp_channel}->[0], 'monthly', 'NKJP-Channel');
ok(!$meta->{K_nkjp_channel}->[1], 'NKJP-Channel');
is($meta->{K_nkjp_type}->[0], 'journalism', 'NKJP-Type');
ok(!$meta->{K_nkjp_type}->[1], 'NKJP-Type');

# Tokenization
use_ok('KorAP::XML::Tokenizer');

my ($token_base_foundry, $token_base_layer) = (qw/nkjp Morpho/);

# Get tokenization
my $tokens = KorAP::XML::Tokenizer->new(
  path => $doc->path,
  doc => $doc,
  foundry => $token_base_foundry,
  layer => $token_base_layer,
  name => 'tokens',
);
ok($tokens, 'Token Object is fine');
ok($tokens->parse, 'Token parsing is fine');

my $output = decode_json( $tokens->to_json );

is($output->{data}->{stream}->[0]->[0], '-:tokens$<i>43', 't');
is($output->{data}->{stream}->[0]->[3], 'i:nie', 't');
is($output->{data}->{stream}->[1]->[2], 's:zdążyła', 't');

## Base
ok($tokens->add('DeReKo', 'Structure', 'base_sentences_paragraphs'));
ok($tokens->add('NKJP', 'Morpho'), 'Add Morpho');

$output = $tokens->to_data;

is($output->{data}->{foundries}, 'dereko dereko/structure dereko/structure/base_sentences_paragraphs nkjp nkjp/morpho', 'Foundries');

is($output->{data}->{layerInfos}, 'dereko/s=spans nkjp/l=tokens nkjp/m=tokens nkjp/ov=tokens nkjp/p=tokens', 'layerInfos');

my $token = join('||', @{$output->{data}->{stream}->[7]});

like($token, qr!<>:dereko\/s:seg\$<b>64!);
like($token, qr!<>:dereko\/s:seg\$<b>64!);
like($token, qr!i:ładu!);
like($token, qr!nkjp\/l:ład!);
like($token, qr!nkjp\/m:number:sg!);
like($token, qr!nkjp\/m:case:gen!);
like($token, qr!nkjp\/m:gender:m3!);
like($token, qr!nkjp\/p:subst!);
like($token, qr!s:ładu!);


# KolakowskiOco
$path = catdir(dirname(__FILE__), 'corpus','NKJP','NKJP','KolakowskiOco');

ok($doc = KorAP::XML::Krill->new( path => $path . '/', meta_type => 'NKJP', lang => 'pl'), 'Load Korap::Document');
ok($doc->parse, 'Parse document');

is($doc->text_sigle, 'NKJP/NKJP/KolakowskiOco', 'Correct text sigle');
is($doc->doc_sigle, 'NKJP/NKJP', 'Correct document sigle');
is($doc->corpus_sigle, 'NKJP', 'Correct corpus sigle');

$meta = $doc->meta;

is($meta->{T_title}, 'TEI P5 encoded version of sample(s) of "O co nas pytają wielcy filozofowie. Seria 3 "', 'Title');
ok(!$meta->{T_sub_title}, 'SubTitle');
ok(!$meta->{T_author}, 'Author');
ok(!$meta->{A_editor}, 'Editor');
ok(!$meta->{S_pub_place}, 'PubPlace');
ok(!$meta->{A_publisher},  'Publisher');

ok(!$meta->{S_text_type}, 'No Text Type');
ok(!$meta->{S_text_type_art}, 'No Text Type Art');
ok(!$meta->{S_text_type_ref}, 'No Text Type Ref');
ok(!$meta->{S_text_domain}, 'No Text Domain');
ok(!$meta->{S_text_column}, 'No Text Column');

is($meta->{K_nkjp_channel}->[0], 'książka', 'NKJP-Channel');
ok(!$meta->{K_nkjp_channel}->[1], 'NKJP-Channel');
is($meta->{K_nkjp_type}->[0], 'literatura piękna', 'NKJP-Type');
ok(!$meta->{K_nkjp_type}->[1], 'NKJP-Type');


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

is($output->{data}->{stream}->[0]->[0], '-:tokens$<i>117', 't');
is($output->{data}->{stream}->[0]->[3], 'i:czy', 't');
is($output->{data}->{stream}->[1]->[2], 's:zdarza', 't');

## Base
ok($tokens->add('DeReKo', 'Structure', 'base_sentences_paragraphs'));
ok($tokens->add('NKJP', 'Morpho'), 'Add Morpho');
ok($tokens->add('NKJP', 'NamedEntities'), 'Add NamedEntities');

$output = $tokens->to_data;

is($output->{data}->{foundries}, 'dereko dereko/structure dereko/structure/base_sentences_paragraphs nkjp nkjp/morpho nkjp/namedentities', 'Foundries');

is($output->{data}->{layerInfos}, 'dereko/s=spans nkjp/l=tokens nkjp/m=tokens nkjp/ne=tokens nkjp/ov=tokens nkjp/p=tokens', 'layerInfos');

$token = join('||', @{$output->{data}->{stream}->[5]});

like($token, qr!<>:dereko/s:seg\$<b>64<i>23<i>28<i>6<b>4<s>1!);
like($token, qr!_5\$<i>23<i>28!);
like($token, qr!i:takie!);
like($token, qr!nkjp/l:taki!);
like($token, qr!nkjp/m:number:sg!);
like($token, qr!nkjp/m:case:nom!);
like($token, qr!nkjp/m:gender:n!);
like($token, qr!nkjp/m:degree:pos!);
like($token, qr!nkjp/p:adj!);
like($token, qr!s:takie!);
like($token, qr!nkjp/ov:takie!);



$token = join('||', @{$output->{data}->{stream}->[67]});

like($token, qr!<>:dereko/s:seg\$<b>64<i>464<i>475<i>68<b>4<s>1!);
like($token, qr!\@:dereko\/s:corresp:ann_segmentation\.xml\\#segm_2\.2-seg\$<b>17<s>1<i>68!);
like($token, qr!\@:dereko\/s:id:morph_2\.2-seg\$<b>17<s>1<i>68!);
like($token, qr!_67\$<i>464<i>475!);
like($token, qr!i:kierkegaard!);
like($token, qr!nkjp/l:Kierkegaard!);
like($token, qr!nkjp/m:number:sg!);
like($token, qr!nkjp/m:case:nom!);
like($token, qr!nkjp/m:gender:m1!);
like($token, qr!nkjp/ne:persName:surname!);
like($token, qr!nkjp/p:subst!);
like($token, qr!s:Kierkegaard!);
like($token, qr!nkjp/ov:Kierkegaard!);

done_testing;
__END__

