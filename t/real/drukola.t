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

# This will Check DRuKoLa-Files

# New
# BBU/BLOG/83709_a_82384
my $path = catdir(dirname(__FILE__), '../corpus/BBU/BLOG/83709_a_82384');

ok(my $doc = KorAP::XML::Krill->new( path => $path . '/' ), 'Load Korap::Document');
ok($doc->parse, 'Parse document');

is($doc->text_sigle, 'BBU/BLOG/83709_a_82384', 'Correct text sigle');
is($doc->doc_sigle, 'BBU/BLOG', 'Correct document sigle');
is($doc->corpus_sigle, 'BBU', 'Correct corpus sigle');

my $meta = $doc->meta;
is($meta->{title}, 'Schimbă vorba', 'Title');
is($meta->{pub_place}, 'URL:http://www.bucurenci.ro', 'PubPlace');
is($meta->{pub_date}, '20131005', 'Creation Date');
ok(!$meta->{sub_title}, 'SubTitle');
is($meta->{author}, 'Dragoș Bucurenci', 'Author');

ok(!$meta->{publisher}, 'Publisher');
ok(!$meta->{editor}, 'Editor');
is($meta->{translator}, '[TRANSLATOR]', 'Translator');
#is($meta->{text_type}, 'Autobiographie', 'Correct Text Type');
ok(!$meta->{text_type_art}, 'Correct Text Type Art');
# is($meta->{text_type_ref}, '', 'Correct Text Type Ref');
ok(!$meta->{text_column}, 'Correct Text Column');
ok(!$meta->{text_domain}, 'Correct Text Domain');
ok(!$meta->{creation_date}, 'Creation Date');

ok(!$meta->{pages}, 'Pages');
ok(!$meta->{file_edition_statement}, 'File Ed Statement');
ok(!$meta->{bibl_edition_statement}, 'Bibl Ed Statement');
ok(!$meta->{reference}, 'Reference');
is($meta->{language}, 'ro', 'Language');

#is($meta->{corpus_title}, 'Goethes Werke', 'Correct Corpus title');
ok(!$meta->{corpus_sub_title}, 'Correct Corpus Sub title');
#is($meta->{corpus_author}, 'Goethe, Johann Wolfgang von', 'Correct Corpus author');
#is($meta->{corpus_editor}, 'Trunz, Erich', 'Correct Corpus editor');

#is($meta->{doc_title}, 'Goethe: Autobiographische Schriften II, (1817-1825, 1832)',
#   'Correct Doc title');
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

## Base
$tokens->add('DeReKo', 'Structure', 'base_sentences_paragraphs');
ok($tokens->add('DRuKoLa', 'Morpho'), 'Add Drukola');

$output = $tokens->to_data;

is($output->{data}->{foundries}, 'dereko dereko/structure dereko/structure/base_sentences_paragraphs drukola drukola/morpho', 'Foundries');

is($output->{data}->{layerInfos}, 'dereko/s=spans drukola/l=tokens drukola/m=tokens drukola/p=tokens', 'layerInfos');

my $token = join('||', @{$output->{data}->{stream}->[7]});

like($token, qr!drukola/l:la!, 'data');
like($token, qr!drukola/m:msd:Sp!, 'data');
like($token, qr!drukola/p:ADPOSITION!, 'data');

$token = join('||', @{$output->{data}->{stream}->[9]});

like($token, qr!i:vorba!, 'data');
like($token, qr!drukola/l:vorbă!, 'data');
like($token, qr!drukola/m:case:Ncfsry!, 'data');
like($token, qr!drukola/m:definiteness:yes!, 'data');
like($token, qr!drukola/m:gender:feminine!, 'data');
like($token, qr!drukola/p:NOUN!, 'data');


# New
# BBU2/BLOG/83709_a_82384
$path = catdir(dirname(__FILE__), '../corpus/BBU2/Blog/83701_a_82376');



ok($doc = KorAP::XML::Krill->new( path => $path . '/' ), 'Load Korap::Document');
ok($doc->parse, 'Parse document');

$meta = $doc->meta;

ok(!exists $meta->{doc_title}, 'No doc title');
ok(!exists $meta->{translator}, 'No translator');

ok(!exists $meta->{text_class}, 'No translator');


done_testing;
__END__
