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

my $path = catdir(dirname(__FILE__), '../corpus/REI/BNG/00128');

ok(my $doc = KorAP::XML::Krill->new( path => $path . '/' ), 'Load Korap::Document');
ok($doc->parse, 'Parse document');

is($doc->text_sigle, 'REI/BNG/00128', 'Correct text sigle');
is($doc->doc_sigle, 'REI/BNG', 'Correct document sigle');
is($doc->corpus_sigle, 'REI', 'Correct corpus sigle');

my $meta = $doc->meta;
is($meta->{title}, 'Friedensgutachten der führenden Friedensforschungsinstitute', 'Title');
is($meta->{sub_title}, 'Rede im Deutschen Bundestag am 14.06.2002', 'SubTitle');
is($meta->{author}, 'Nachtwei, Winfried', 'Author');
ok(!$meta->{editor}, 'Editor');
is($meta->{pub_place}, 'Berlin', 'PubPlace');
ok(!$meta->{publisher}, 'Publisher');

ok(!$meta->{text_type}, 'No Text Type');
ok(!$meta->{text_type_art}, 'No Text Type Art');
ok(!$meta->{text_type_ref}, 'No Text Type Ref');
ok(!$meta->{text_domain}, 'No Text Domain');
ok(!$meta->{text_column}, 'No Text Column');

is($meta->{text_class}->[0], 'politik', 'Correct Text Class');
is($meta->{text_class}->[1], 'inland', 'Correct Text Class');
ok(!$meta->{text_class}->[2], 'Correct Text Class');

is($meta->{pub_date}, '20020614', 'Creation date');
is($meta->{creation_date}, '20020614', 'Creation date');
is($meta->{availability}, 'CC-BY-SA', 'License');
ok(!$meta->{pages}, 'Pages');

ok(!$meta->{file_edition_statement}, 'File Statement');
ok(!$meta->{bibl_edition_statement}, 'Bibl Statement');

is($meta->{reference} . "\n", <<'REF', 'Reference');
Nachtwei, Winfried: Friedensgutachten der führenden Friedensforschungsinstitute. Rede im Deutschen Bundestag am 14.06.2002, Hrsg: Bundestagsfraktion Bündnis 90/DIE GRÜNEN [Ausführliche Zitierung nicht verfügbar]
REF
is($meta->{language}, 'de', 'Language');

is($meta->{corpus_title}, 'Reden und Interviews', 'Correct Corpus title');
ok(!$meta->{corpus_sub_title}, 'Correct Corpus sub title');
ok(!$meta->{corpus_author}, 'Correct Corpus author');
ok(!$meta->{corpus_editor}, 'Correct Corpus editor');

is($meta->{doc_title}, 'Reden der Bundestagsfraktion Bündnis 90/DIE GRÜNEN, (2002-2006)', 'Correct Doc title');
ok(!$meta->{doc_sub_title}, 'Correct Doc sub title');
ok(!$meta->{doc_author}, 'Correct Doc author');
ok(!$meta->{doc_editor}, 'Correct doc editor');

# Tokenization
use_ok('KorAP::XML::Tokenizer');

my ($token_base_foundry, $token_base_layer) = (qw/Base tokens_conservative/);

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

is(substr($output->{data}->{text}, 0, 100), 'Winfried Nachtwei, Friedensgutachten der führenden Friedensforschungsinstitute 14. Juni 2002 Vizeprä', 'Primary Data');

is($output->{data}->{name}, 'tokens', 'tokenName');
is($output->{data}->{tokenSource}, 'base#tokens_conservative', 'tokenSource');
is($output->{version}, '0.03', 'version');

is($output->{data}->{foundries}, '', 'Foundries');
is($output->{data}->{layerInfos}, '', 'layerInfos');
is($output->{data}->{stream}->[0]->[4], 's:Winfried', 'data');

is($output->{textSigle}, 'REI/BNG/00128', 'Correct text sigle');
is($output->{docSigle}, 'REI/BNG', 'Correct document sigle');
is($output->{corpusSigle}, 'REI', 'Correct corpus sigle');

is($output->{title}, 'Friedensgutachten der führenden Friedensforschungsinstitute', 'Title');
is($output->{subTitle}, 'Rede im Deutschen Bundestag am 14.06.2002', 'Correct SubTitle');
is($output->{author}, 'Nachtwei, Winfried', 'Author');
ok(!exists $output->{editor}, 'Publisher');

is($output->{pubPlace}, 'Berlin', 'PubPlace');
ok(!exists $output->{publisher}, 'Publisher');

ok(!exists $output->{textType}, 'Correct Text Type');
ok(!exists $output->{textTypeArt}, 'Correct Text Type Art');
ok(!exists $output->{textTypeRef}, 'Correct Text Type Ref');
ok(!exists $output->{textDomain}, 'Correct Text Domain');

is($output->{creationDate}, '20020614', 'Creation date');
is($output->{availability}, 'CC-BY-SA', 'License');

ok(!exists $output->{pages}, 'Pages');
ok(!exists $output->{fileEditionStatement}, 'File Statement');
ok(!exists $output->{biblEditionStatement}, 'Bibl Statement');

is($output->{reference} . "\n", <<'REF', 'Reference');
Nachtwei, Winfried: Friedensgutachten der führenden Friedensforschungsinstitute. Rede im Deutschen Bundestag am 14.06.2002, Hrsg: Bundestagsfraktion Bündnis 90/DIE GRÜNEN [Ausführliche Zitierung nicht verfügbar]
REF
is($output->{language}, 'de', 'Language');

is($output->{corpusTitle}, 'Reden und Interviews', 'Correct Corpus title');
ok(!exists $output->{corpusSubTitle}, 'Correct Corpus sub title');
ok(!exists $output->{corpusAuthor}, 'Correct Corpus author');
ok(!exists $output->{corpusEditor}, 'Correct Corpus editor');

is($output->{docTitle}, 'Reden der Bundestagsfraktion Bündnis 90/DIE GRÜNEN, (2002-2006)', 'Correct Doc title');
ok(!exists $output->{docSubTitle}, 'Correct Doc sub title');
ok(!exists $output->{docAuthor}, 'Correct Doc author');
ok(!exists $output->{docEditor}, 'Correct doc editor');

## Base
$tokens->add('Base', 'Sentences');
$tokens->add('Base', 'Paragraphs');

$output = decode_json( $tokens->to_json );

is($output->{data}->{foundries}, 'base base/paragraphs base/sentences', 'Foundries');
is($output->{data}->{layerInfos}, 'base/s=spans', 'layerInfos');
my $first_token = join('||', @{$output->{data}->{stream}->[0]});
like($first_token, qr/s:Winfried/, 'data');
like($first_token, qr/_0\$<i>0<i>8/, 'data');


done_testing;
__END__
