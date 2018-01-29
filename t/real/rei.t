use strict;
use warnings;
use Test::More;
use Data::Dumper;
use JSON::XS;
use Log::Log4perl;

use utf8;
use lib 'lib', '../lib';

use File::Basename 'dirname';
use File::Spec::Functions 'catdir';

# Initialize log4perl object
Log::Log4perl->init({
  'log4perl.rootLogger' => 'ERROR, STDERR',
  'log4perl.appender.STDERR' => 'Log::Log4perl::Appender::ScreenColoredLevels',
  'log4perl.appender.STDERR.layout' => 'PatternLayout',
  'log4perl.appender.STDERR.layout.ConversionPattern' => '[%r] %F %L %c - %m%n'
});

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


# REI/RBR/00610
$path = catdir(dirname(__FILE__), '../corpus/REI/RBR/00610');

ok($doc = KorAP::XML::Krill->new( path => $path . '/' ), 'Load Korap::Document');
ok($doc->parse, 'Parse document');

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

# Add annotations
$tokens->add('Base', 'Sentences');
$tokens->add('Base', 'Paragraphs');

$tokens->add('CoreNLP', 'Constituency');
$tokens->add('CoreNLP', 'Morpho');
$tokens->add('CoreNLP', 'Sentences');

$tokens->add('Malt', 'Dependency');

$tokens->add('OpenNLP', 'Morpho');
$tokens->add('OpenNLP', 'Sentences');

$tokens->add('DeReKo', 'Structure');

$tokens->add('TreeTagger', 'Morpho');
$tokens->add('TreeTagger', 'Sentences');

$output = decode_json( $tokens->to_json );

my $first = $output->{data}->{stream}->[0];
is('-:base/paragraphs$<i>31', $first->[0]);
is('-:base/sentences$<i>168', $first->[1]);
is('-:corenlp/sentences$<i>175', $first->[2]);
is('-:opennlp/sentences$<i>169', $first->[3]);
is('-:tokens$<i>2641', $first->[4]);
is('-:tt/sentences$<i>196', $first->[5]);
is('<:malt/d:PP$<b>32<i>4', $first->[6]);
is('<>:corenlp/c:ROOT$<b>64<i>0<i>48<i>7<b>0', $first->[7]);
is('<>:corenlp/s:s$<b>64<i>0<i>48<i>7<b>0', $first->[8]);
is('<>:opennlp/s:s$<b>64<i>0<i>48<i>7<b>0', $first->[9]);
is('<>:tt/s:s$<b>64<i>0<i>48<i>7<b>0', $first->[10]);
is('<>:corenlp/c:S$<b>64<i>0<i>48<i>7<b>1', $first->[11]);
is('<>:dereko/s:front$<b>64<i>0<i>91<i>11<b>1', $first->[12]);
is('<>:base/s:s$<b>64<i>0<i>91<i>11<b>2', $first->[13]);
is('<>:dereko/s:titlePage$<b>64<i>0<i>91<i>11<b>2<s>1', $first->[14]);
is('<>:dereko/s:docTitle$<b>64<i>0<i>91<i>11<b>3', $first->[15]);
is('<>:dereko/s:titlePart$<b>64<i>0<i>91<i>11<b>4<s>2', $first->[16]);
is('<>:dereko/s:s$<b>64<i>0<i>91<i>11<b>5', $first->[17]);
is('<>:base/s:t$<b>64<i>0<i>17859<i>2640<b>0', $first->[18]);
is('>:malt/d:ROOT$<b>33<i>0<i>48<i>0<i>7', $first->[19]);
is('<:malt/d:PP$<b>32<i>1', $first->[20]);
is('<:malt/d:ROOT$<b>34<i>0<i>48<i>7<i>0', $first->[21]);
is('@:dereko/s:id:rbr.00610-0-titlepage$<b>17<s>1<i>11', $first->[22]);
is('@:dereko/s:type:unspecified$<b>17<s>2<i>11', $first->[23]);
is('_0$<i>0<i>4', $first->[24]);
is('corenlp/p:NN', $first->[25]);
is('i:rede', $first->[26]);
is('opennlp/p:NN', $first->[27]);
is('s:Rede', $first->[28]);
is('tt/l:Rede', $first->[29]);
is('tt/p:NN$<b>129<b>253', $first->[30]);

my $last = $output->{data}->{stream}->[-1];

is('<>:dereko/s:text$<b>65<i>17859<i>17859<i>2640<b>0', $last->[0]);
is('<>:dereko/s:back$<b>65<i>17859<i>17859<i>2640<b>1', $last->[1]);
is('>:malt/d:APP$<b>32<i>2639', $last->[2]);
is('_2640$<i>17851<i>17859', $last->[3]);
is('corenlp/p:NE', $last->[4]);
is("i:schr\x{f6}der", $last->[5]);
is('opennlp/p:NE', $last->[6]);
is("s:Schr\x{f6}der", $last->[7]);
is("tt/l:Schr\x{f6}der", $last->[8]);
is('tt/p:NE$<b>129<b>255', $last->[9]);


# REI/BNG/00071
$path = catdir(dirname(__FILE__), '../corpus/REI/BNG/00071');

ok($doc = KorAP::XML::Krill->new( path => $path . '/' ), 'Load Korap::Document');
ok($doc->parse, 'Parse document');

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

# Add annotations
$tokens->add('Base', 'Sentences');
$tokens->add('Base', 'Paragraphs');

$tokens->add('CoreNLP', 'Constituency');
$tokens->add('CoreNLP', 'Morpho');
$tokens->add('CoreNLP', 'Sentences');

$tokens->add('Malt', 'Dependency');

$tokens->add('OpenNLP', 'Morpho');
$tokens->add('OpenNLP', 'Sentences');

$tokens->add('DeReKo', 'Structure');

$tokens->add('TreeTagger', 'Morpho');
$tokens->add('TreeTagger', 'Sentences');

$output = decode_json( $tokens->to_json );

$first = $output->{data}->{stream}->[0];

is('-:base/paragraphs$<i>41', $first->[0]);
is('-:base/sentences$<i>73', $first->[1]);
is('-:corenlp/sentences$<i>69', $first->[2]);
is('-:opennlp/sentences$<i>65', $first->[3]);
is('-:tokens$<i>1009', $first->[4]);
is('-:tt/sentences$<i>95', $first->[5]);
is('<:malt/d:APP$<b>32<i>1', $first->[6]);
is('<>:corenlp/c:MPN$<b>64<i>0<i>16<i>2<b>3', $first->[7]);
is('<>:base/s:s$<b>64<i>0<i>48<i>5<b>2', $first->[8]);
is('<>:dereko/s:titlePart$<b>64<i>0<i>48<i>5<b>4<s>2', $first->[9]);
is('<>:dereko/s:s$<b>64<i>0<i>48<i>5<b>5', $first->[10]);
is('<>:corenlp/c:ROOT$<b>64<i>0<i>51<i>6<b>0', $first->[11]);
is('<>:corenlp/s:s$<b>64<i>0<i>51<i>6<b>0', $first->[12]);
is('<>:tt/s:s$<b>64<i>0<i>51<i>6<b>0', $first->[13]);
is('<>:corenlp/c:NUR$<b>64<i>0<i>51<i>6<b>1', $first->[14]);
is('<>:corenlp/c:NP$<b>64<i>0<i>50<i>6<b>2', $first->[15]);
is('<>:dereko/s:front$<b>64<i>0<i>61<i>8<b>1', $first->[16]);
is('<>:dereko/s:titlePage$<b>64<i>0<i>61<i>8<b>2<s>1', $first->[17]);
is('<>:dereko/s:docTitle$<b>64<i>0<i>61<i>8<b>3', $first->[18]);
is('<>:opennlp/s:s$<b>64<i>0<i>173<i>24<b>0', $first->[19]);
is('<>:base/s:t$<b>64<i>0<i>7008<i>1008<b>0', $first->[20]);
is('<>:dereko/s:text$<b>64<i>0<i>7008<i>1008<b>0', $first->[21]);
is('>:malt/d:GMOD$<b>32<i>3', $first->[22]);
is('<:malt/d:ROOT$<b>34<i>0<i>51<i>6<i>3', $first->[23]);
is('@:dereko/s:id:bng.00071-0-titlepage$<b>17<s>1<i>8', $first->[24]);
is('@:dereko/s:type:unspecified$<b>17<s>2<i>5', $first->[25]);
is('_0$<i>0<i>9', $first->[26]);
is('corenlp/p:NE', $first->[27]);
is('i:christine', $first->[28]);
is('opennlp/p:NE', $first->[29]);
is('s:Christine', $first->[30]);
is('tt/l:Christine', $first->[31]);
is('tt/p:NE$<b>129<b>255', $first->[32]);

$last = $output->{data}->{stream}->[-1];
is('<>:dereko/s:back$<b>65<i>7008<i>7008<i>1008<b>1', $last->[0]);
is('<>:dereko/s:div$<b>65<i>7008<i>7008<i>1008<b>2<s>1', $last->[1]);
is('@:dereko/s:n:1$<b>17<s>1', $last->[2]);
is('@:dereko/s:type:footnotes$<b>17<s>1', $last->[3]);
is('@:dereko/s:complete:y$<b>17<s>1', $last->[4]);
is('_1008$<i>6990<i>7006', $last->[5]);
is('corenlp/p:NN', $last->[6]);
is('i:befreiungsschlag', $last->[7]);
is('opennlp/p:NN', $last->[8]);
is('s:Befreiungsschlag', $last->[9]);

done_testing;
__END__
