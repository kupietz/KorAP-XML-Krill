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

# GOE/AGA/03828
my $path = catdir(dirname(__FILE__), '../corpus/GOE/AGA/03828');
# my $path = '/home/ndiewald/Repositories/korap/KorAP-sandbox/KorAP-lucene-indexer/t/GOE/AGA/03828';

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

my ($token_base_foundry, $token_base_layer) = (qw/OpenNLP Tokens/);

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
is($output->{data}->{tokenSource}, 'opennlp#tokens', 'tokenSource');
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
$tokens->add('Base', 'Sentences');
$tokens->add('Base', 'Paragraphs');

$output = $tokens->to_data;

is($output->{data}->{foundries}, 'base base/paragraphs base/sentences', 'Foundries');
is($output->{data}->{layerInfos}, 'base/s=spans', 'layerInfos');
my $first_token = join('||', @{$output->{data}->{stream}->[0]});
like($first_token, qr/s:Autobiographische/, 'data');
like($first_token, qr/_0\$<i>0<i>17/, 'data');
like($first_token, qr!<>:base/s:s\$<b>64<i>0<i>30<i>2<b>2!, 'data');
like($first_token, qr!<>:base\/s:t\$<b>64<i>0<i>35199<i>5226<b>0!, 'data');

## OpenNLP
$tokens->add('OpenNLP', 'Sentences');

$output = decode_json( $tokens->to_json );
is($output->{data}->{foundries},
   'base base/paragraphs base/sentences opennlp opennlp/sentences',
   'Foundries');
is($output->{data}->{layerInfos}, 'base/s=spans opennlp/s=spans', 'layerInfos');
$first_token = join('||', @{$output->{data}->{stream}->[0]});
like($first_token, qr!<>:opennlp/s:s\$<b>64<i>0<i>254<i>32!, 'data');

$tokens->add('OpenNLP', 'Morpho');
$output = $tokens->to_data;
is($output->{data}->{foundries},
   'base base/paragraphs base/sentences opennlp opennlp/morpho opennlp/sentences',
   'Foundries');
is($output->{data}->{layerInfos}, 'base/s=spans opennlp/p=tokens opennlp/s=spans', 'layerInfos');
$first_token = join('||', @{$output->{data}->{stream}->[0]});
like($first_token, qr!opennlp/p:ADJA!, 'data');

## Treetagger
$tokens->add('TreeTagger', 'Sentences');
$output = $tokens->to_data;
is($output->{data}->{foundries},
   'base base/paragraphs base/sentences opennlp opennlp/morpho opennlp/sentences treetagger treetagger/sentences',
   'Foundries');
is($output->{data}->{layerInfos}, 'base/s=spans opennlp/p=tokens opennlp/s=spans tt/s=spans', 'layerInfos');
$first_token = join('||', @{$output->{data}->{stream}->[0]});
like($first_token, qr!<>:tt/s:s\$<b>64<i>0<i>179<i>21<b>0!, 'data');

$tokens->add('TreeTagger', 'Morpho');
$output = $tokens->to_data;
is($output->{data}->{foundries},
   'base base/paragraphs base/sentences opennlp opennlp/morpho opennlp/sentences treetagger treetagger/morpho treetagger/sentences',
   'Foundries');

is($output->{data}->{layerInfos}, 'base/s=spans opennlp/p=tokens opennlp/s=spans tt/l=tokens tt/p=tokens tt/s=spans', 'layerInfos');
$first_token = join('||', @{$output->{data}->{stream}->[0]});
like($first_token, qr!tt/l:autobiographisch\$<b>129<b>165!, 'data');
like($first_token, qr!tt/p:ADJA\$<b>129<b>165!, 'data');
like($first_token, qr!tt/l:Autobiographische\$<b>129<b>89!, 'data');
like($first_token, qr!tt/p:NN\$<b>129<b>89!, 'data');

## CoreNLP
$tokens->add('CoreNLP', 'NamedEntities');
$output = $tokens->to_data;
is($output->{data}->{foundries},
   'base base/paragraphs base/sentences corenlp corenlp/namedentities opennlp opennlp/morpho opennlp/sentences treetagger treetagger/morpho treetagger/sentences',
   'Foundries');
is($output->{data}->{layerInfos}, 'base/s=spans corenlp/ne=tokens opennlp/p=tokens opennlp/s=spans tt/l=tokens tt/p=tokens tt/s=spans', 'layerInfos');

# diag "Missing test for NamedEntities";

# Problematic:
# diag Dumper $output->{data}->{stream}->[180];
# diag Dumper $output->{data}->{stream}->[341];

$tokens->add('CoreNLP', 'Sentences');
$output = decode_json( $tokens->to_json );
is($output->{data}->{foundries},
   'base base/paragraphs base/sentences corenlp corenlp/namedentities corenlp/sentences opennlp opennlp/morpho opennlp/sentences treetagger treetagger/morpho treetagger/sentences',
   'Foundries');
is($output->{data}->{layerInfos}, 'base/s=spans corenlp/ne=tokens corenlp/s=spans opennlp/p=tokens opennlp/s=spans tt/l=tokens tt/p=tokens tt/s=spans', 'layerInfos');
$first_token = join('||', @{$output->{data}->{stream}->[0]});
like($first_token, qr!<>:corenlp/s:s\$<b>64<i>0<i>254<i>32<b>0!, 'data');

$tokens->add('CoreNLP', 'Morpho');
$output = $tokens->to_data;
like($output->{data}->{foundries}, qr!corenlp/morpho!, 'Foundries');
like($output->{data}->{layerInfos}, qr!corenlp/p=tokens!, 'layerInfos');
$first_token = join('||', @{$output->{data}->{stream}->[0]});
like($first_token, qr!corenlp/p:ADJA!, 'data');

$tokens->add('CoreNLP', 'Constituency');
$output = $tokens->to_data;
like($output->{data}->{foundries}, qr!corenlp/constituency!, 'Foundries');
like($output->{data}->{layerInfos}, qr!corenlp/c=spans!, 'layerInfos');
$first_token = join('||', @{$output->{data}->{stream}->[0]});
like($first_token, qr!<>:corenlp/c:NP\$<b>64<i>0<i>17<i>1<b>6!, 'data');
like($first_token, qr!<>:corenlp/c:CNP\$<b>64<i>0<i>17<i>1<b>7!, 'data');
like($first_token, qr!<>:corenlp/c:NP\$<b>64<i>0<i>17<i>1<b>8!, 'data');
like($first_token, qr!<>:corenlp/c:AP\$<b>64<i>0<i>17<i>1<b>9!, 'data');
like($first_token, qr!<>:corenlp/c:PP\$<b>64<i>0<i>50<i>3<b>4!, 'data');
like($first_token, qr!<>:corenlp/c:S\$<b>64<i>0<i>50<i>3<b>5!, 'data');
like($first_token, qr!<>:corenlp/c:PP\$<b>64<i>0<i>58<i>5<b>2!, 'data');
like($first_token, qr!<>:corenlp/c:S\$<b>64<i>0<i>58<i>5<b>3!, 'data');
like($first_token, qr!<>:corenlp/c:ROOT\$<b>64<i>0<i>254<i>32<b>0!, 'data');
like($first_token, qr!<>:corenlp/c:S\$<b>64<i>0<i>254<i>32<b>1!, 'data');

## Glemm
$tokens->add('Glemm', 'Morpho');
$output = $tokens->to_data;
like($output->{data}->{foundries}, qr!glemm/morpho!, 'Foundries');
like($output->{data}->{layerInfos}, qr!glemm/l=tokens!, 'layerInfos');
$first_token = join('||', @{$output->{data}->{stream}->[0]});
like($first_token, qr!glemm/l:__autobiographisch!, 'data');
like($first_token, qr!glemm/l:\+_Auto!, 'data');
like($first_token, qr!glemm/l:\+_biographisch!, 'data');
like($first_token, qr!glemm/l:\+\+Biograph!, 'data');
like($first_token, qr!glemm/l:\+\+-isch!, 'data');

## Connexor
$tokens->add('Connexor', 'Sentences');
$output = $tokens->to_data;
like($output->{data}->{foundries}, qr!connexor/sentences!, 'Foundries');
like($output->{data}->{layerInfos}, qr!cnx/s=spans!, 'layerInfos');
$first_token = join('||', @{$output->{data}->{stream}->[0]});
like($first_token, qr!<>:cnx/s:s\$<b>64<i>0<i>179<i>21<b>0!, 'data');

$tokens->add('Connexor', 'Morpho');
$output = $tokens->to_data;
like($output->{data}->{foundries}, qr!connexor/morpho!, 'Foundries');
like($output->{data}->{layerInfos}, qr!cnx/p=tokens!, 'layerInfos');
like($output->{data}->{layerInfos}, qr!cnx/l=tokens!, 'layerInfos');
like($output->{data}->{layerInfos}, qr!cnx/m=tokens!, 'layerInfos');
$first_token = join('||', @{$output->{data}->{stream}->[0]});
like($first_token, qr!cnx/l:autobiografisch!, 'data');
like($first_token, qr!cnx/p:A!, 'data');

$tokens->add('Connexor', 'Phrase');
$output = $tokens->to_data;
like($output->{data}->{foundries}, qr!connexor/phrase!, 'Foundries');
like($output->{data}->{layerInfos}, qr!cnx/c=spans!, 'layerInfos');
$first_token = join('||', @{$output->{data}->{stream}->[0]});
like($first_token, qr!<>:cnx/c:np\$<b>64<i>0<i>30<i>2!, 'data');

$tokens->add('Connexor', 'Syntax');
$output = $tokens->to_data;
like($output->{data}->{foundries}, qr!connexor/syntax!, 'Foundries');
like($output->{data}->{layerInfos}, qr!cnx/syn=tokens!, 'layerInfos');
$first_token = join('||', @{$output->{data}->{stream}->[0]});
like($first_token, qr!cnx/syn:\@PREMOD!, 'data');

## Mate
$tokens->add('Mate', 'Morpho');
$output = $tokens->to_data;
like($output->{data}->{foundries}, qr!mate/morpho!, 'Foundries');
like($output->{data}->{layerInfos}, qr!mate/p=tokens!, 'layerInfos');
like($output->{data}->{layerInfos}, qr!mate/l=tokens!, 'layerInfos');
like($output->{data}->{layerInfos}, qr!mate/m=tokens!, 'layerInfos');
$first_token = join('||', @{$output->{data}->{stream}->[0]});
like($first_token, qr!mate/l:autobiographisch!, 'data');
like($first_token, qr!mate/p:NN!, 'data');
like($first_token, qr!mate/m:case:nom!, 'data');
like($first_token, qr!mate/m:number:pl!, 'data');
like($first_token, qr!mate/m:gender:\*!, 'data');

## XIP
$tokens->add('XIP', 'Sentences');
$output = $tokens->to_data;
like($output->{data}->{foundries}, qr!xip/sentences!, 'Foundries');
like($output->{data}->{layerInfos}, qr!xip/s=spans!, 'layerInfos');
$first_token = join('||', @{$output->{data}->{stream}->[0]});
like($first_token, qr!<>:xip/s:s\$<b>64<i>0<i>179<i>21!, 'data');

$tokens->add('XIP', 'Morpho');
$output = $tokens->to_data;
like($output->{data}->{foundries}, qr!xip/morpho!, 'Foundries');
like($output->{data}->{layerInfos}, qr!xip/l=tokens!, 'layerInfos');
like($output->{data}->{layerInfos}, qr!xip/p=tokens!, 'layerInfos');
$first_token = join('||', @{$output->{data}->{stream}->[0]});
like($first_token, qr!<>:xip/s:s\$<b>64<i>0<i>179<i>21!, 'data');

$tokens->add('XIP', 'Constituency');
$output = $tokens->to_data;
like($output->{data}->{foundries}, qr!xip/constituency!, 'Foundries');
like($output->{data}->{layerInfos}, qr!xip/c=spans!, 'layerInfos');
$first_token = join('||', @{$output->{data}->{stream}->[0]});
like($first_token, qr!<>:xip/c:NP\$<b>64<i>0<i>17<i>1<b>1!, 'data');
like($first_token, qr!<>:xip/c:AP\$<b>64<i>0<i>17<i>1<b>2!, 'data');
like($first_token, qr!<>:xip/c:ADJ\$<b>64<i>0<i>17<i>1<b>3!, 'data');
like($first_token, qr!<>:xip/c:TOP\$<b>64<i>0<i>179<i>21<b>0!, 'data');

# diag "No test for mate dependency";
# diag "No test for xip dependency";

# diag timestr(timediff(Benchmark->new, $t));

done_testing;
__END__
