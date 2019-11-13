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

# This will check preliminary HNC-Files

# HNC/DOC00001/00001
my $path = catdir(dirname(__FILE__), '../corpus/HNC/DOC00001/00001');

ok(my $doc = KorAP::XML::Krill->new( path => $path . '/' ), 'Load Korap::Document');
ok($doc->parse, 'Parse document');

is($doc->text_sigle, 'HNC/DOC00001/00001', 'Correct text sigle');
is($doc->doc_sigle, 'HNC/DOC00001', 'Correct document sigle');
is($doc->corpus_sigle, 'HNC', 'Correct corpus sigle');

my $meta = $doc->meta;
is($meta->{T_title}, 'GNU Free Documentation License', 'Title');
is($meta->{S_pub_place}, 'H_PUBPLACE', 'PubPlace');

# Defined on document level as
# idsHeader > fileDesc > publicationStmt > pubDate == 2005/08/16
# idsHeader > fileDesc > biblFull > publicationStmt > pubDate == 2003/07/08-2014/05/03
# idsHeader > fileDesc > biblFull > publicationStmt > sourceDesc > biblStruct > monogr > imprint > pubDate == 2003/07/08-2014/05/03
# is($meta->{D_pub_date}, '20030708', 'Publication date');
ok(!$meta->{T_sub_title}, 'SubTitle');
is($meta->{T_author}, 'Addbot', 'Author');

is($meta->{A_publisher}, 'H_PUBLISHER', 'Publisher');
ok(!$meta->{A_editor}, 'Editor');
ok(!$meta->{translator}, 'Translator');

ok(!$meta->{S_text_type}, 'Correct Text Type');
ok(!$meta->{S_text_type_art}, 'Correct Text Type Art');
ok(!$meta->{S_text_type_ref}, 'Correct Text Type Ref');
ok(!$meta->{S_text_column}, 'Correct Text Column');
ok(!$meta->{S_text_domain}, 'Correct Text Domain');
is($meta->{D_creation_date}, '20130302', 'Creation Date');

ok(!$meta->{pages}, 'Pages');
ok(!$meta->{A_file_edition_statement}, 'File Ed Statement');
ok(!$meta->{A_bibl_edition_statement}, 'Bibl Ed Statement');
ok(!$meta->{A_reference}, 'Reference');
is($meta->{S_language}, 'hu', 'Language');

is($meta->{S_availability}, 'Kutatási célokra, megállapodás alapján, hozzáférhető', 'Availability');
is($meta->{A_distributor}, 'MTA Nyelvtudományi Intézet', 'Distributor');

ok(!$meta->{T_corpus_title}, 'Correct Corpus title');
ok(!$meta->{T_corpus_sub_title}, 'Correct Corpus Sub title');
ok(!$meta->{T_corpus_author}, 'Correct Corpus author');
ok(!$meta->{A_corpus_editor}, 'Correct Corpus editor');

is($meta->{T_doc_title}, 'MNSZ hivatalos korpusz: Wikipédia cikkek', 'Correct Doc title');
ok(!$meta->{T_doc_sub_title}, 'Correct Doc Sub title');
ok(!$meta->{T_doc_author}, 'Correct Doc author');
ok(!$meta->{A_doc_editor}, 'Correct Doc editor');

# Tokenization
use_ok('KorAP::XML::Tokenizer');

my ($token_base_foundry, $token_base_layer) = (qw/HNC Morpho/);

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

is($output->{data}->{stream}->[0]->[1], '<>:base/s:t$<b>64<i>0<i>4368<i>577<b>0', 't');
is($output->{data}->{stream}->[0]->[3], 'i:addbot', 't');


## Base
ok($tokens->add('DeReKo', 'Structure', 'base_sentences_paragraphs'), 'DeReKo');
ok($tokens->add('HNC', 'Morpho'), 'Add HNC Morphology');

$output = $tokens->to_data;

is($output->{data}->{foundries}, 'dereko dereko/structure dereko/structure/base_sentences_paragraphs hnc hnc/morpho', 'Foundries');

is($output->{data}->{layerInfos}, 'dereko/s=spans hnc/l=tokens hnc/m=tokens hnc/p=tokens', 'layerInfos');

my $token = join('||', @{$output->{data}->{stream}->[7]});

like($token, qr!hnc/l:free!, 'data');
like($token, qr!hnc/m:compound:n!, 'data');
like($token, qr!hnc/m:hyphenated:n!, 'data');
like($token, qr!hnc/m:mboundary:free!, 'data');
like($token, qr!hnc/m:morphemes:ZERO::NOM!, 'data');
like($token, qr!hnc/m:stem:free::FN!, 'data');
like($token, qr!hnc/p:FN\.NOM!, 'data');
like($token, qr!i:free!, 'data');
like($token, qr!s:Free!, 'data');

$token = join('||', @{$output->{data}->{stream}->[30]});

like($token, qr!hnc/l:tervez!, 'data');
like($token, qr!hnc/m:compound:n!, 'data');
like($token, qr!hnc/m:hyphenated:n!, 'data');
like($token, qr!hnc/m:mboundary:tervez\+ett!, 'data');
like($token, qr!hnc/m:morphemes:ett::_MIB ZERO::NOM!, 'data');
like($token, qr!hnc/m:stem:tervez::IGE!, 'data');
like($token, qr!hnc/p:IGE\._MIB\.NOM!, 'data');
like($token, qr!i:tervezett!, 'data');
like($token, qr!s:tervezett!, 'data');

done_testing;
__END__
