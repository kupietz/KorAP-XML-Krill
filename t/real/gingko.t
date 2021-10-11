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

# This will Check Gingko-Files

# New
# ATZ07/JAN/00001
my $path = catdir(dirname(__FILE__), 'corpus','Gingko', 'ATZ07','JAN','00001');

ok(my $doc = KorAP::XML::Krill->new( path => $path . '/' ), 'Load Korap::Document');
ok($doc->parse, 'Parse document');

is($doc->text_sigle, 'ATZ07/JAN/00001', 'Correct text sigle');
is($doc->doc_sigle, 'ATZ07/JAN', 'Correct document sigle');
is($doc->corpus_sigle, 'ATZ07', 'Correct corpus sigle');

my $meta = $doc->meta;
is($meta->{T_title}, 'Ein neues Energiemanagement-Konzept für das elektrische Bordnetz', 'Title');
is($meta->{S_pub_place}, 'Wiesbaden', 'PubPlace');
is($meta->{D_pub_date}, '20070000', 'Creation Date');
ok(!$meta->{T_sub_title}, 'SubTitle');
is($meta->{T_author}, 'Theuerkauf, Heinz; Schmidt, Matthias', 'Author');

is($meta->{A_publisher}, 'Springer Fachmedien GmbH', 'Publisher');
ok(!$meta->{A_editor}, 'Editor');
ok(!$meta->{A_translator}, 'Translator');
is($meta->{S_text_type}, 'Zeitschrift: Fachzeitschrift', 'Correct Text Type');
is($meta->{S_text_type_art}, 'Fachartikel', 'Correct Text Type Art');
is($meta->{S_text_type_ref}, 'Fachzeitschrift', 'Correct Text Type Ref');
ok(!$meta->{S_text_column}, 'Correct Text Column');
ok(!$meta->{S_text_domain}, 'Correct Text Domain');
ok(!$meta->{D_creation_date}, 'Creation Date');

ok(!$meta->{pages}, 'Pages');
ok(!$meta->{A_file_edition_statement}, 'File Ed Statement');
ok(!$meta->{A_bibl_edition_statement}, 'Bibl Ed Statement');
is($meta->{A_reference}, 'ATZ - Automobiltechnische Zeitschrift, Januar 2007, Nr.109, S. 10-15 - Theuerkauf, H.; Schmidt, M.: Ein neues Energiemanagement-Konzept für das elektrische Bordnetz', 'Reference');
is($meta->{S_language}, 'de', 'Language');

is($meta->{T_corpus_title}, 'Gingko - Geschriebenes Ingenieurwissenschaftliches Korpus', 'Correct Corpus title');
ok(!$meta->{T_corpus_sub_title}, 'Correct Corpus Sub title');
ok(!$meta->{T_corpus_author}, 'Correct Corpus author');
is($meta->{A_corpus_editor}, 'Christian Fandrych', 'Correct Corpus editor');

is($meta->{T_doc_title}, 'Gingko - Geschriebenes Ingenieurwissenschaftliches Korpus',   'Correct Doc title');
ok(!$meta->{T_doc_sub_title}, 'Correct Doc Sub title');
ok(!$meta->{T_doc_author}, 'Correct Doc author');
is($meta->{A_doc_editor}, 'Prof. Dr. Christian Fandrych, Leipzig University', 'Correct Doc editor');

# Tokenization
use_ok('KorAP::XML::Tokenizer');

my ($token_base_foundry, $token_base_layer) = (qw/Gingko Morpho/);

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

## Base
ok($tokens->add('DeReKo', 'Structure', 'base_sentences_paragraphs'));
ok($tokens->add('Gingko', 'Morpho'), 'Add Gingko');

$output = $tokens->to_data;

is($output->{data}->{foundries}, 'dereko dereko/structure dereko/structure/base_sentences_paragraphs gingko gingko/morpho', 'Foundries');

is($output->{data}->{layerInfos}, 'dereko/s=spans gingko/l=tokens gingko/p=tokens', 'layerInfos');

my $token = join('||', @{$output->{data}->{stream}->[7]});

# Unknown
unlike($token, qr!gingko/l!, 'data');
like($token, qr!ginkgo/p:NN!, 'data');

$token = join('||', @{$output->{data}->{stream}->[9]});

like($token, qr!i:heutige!, 'data');
like($token, qr!ginkgo/p:ADJA!, 'data');
like($token, qr!gingko/l:heutig!, 'data');

done_testing;
__END__

