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

my $path = catdir(dirname(__FILE__), 'corpus','ICCGER','DeReKo-WPD17','A00-82293');

ok(my $doc = KorAP::XML::Krill->new( path => $path . '/' ), 'Load Korap::Document');
ok($doc->parse, 'Parse document');

is($doc->text_sigle, 'ICCGER/DeReKo-WPD17/A00-82293', 'Correct text sigle');
is($doc->doc_sigle, 'ICCGER/DeReKo-WPD17', 'Correct document sigle');
is($doc->corpus_sigle, 'ICCGER', 'Correct corpus sigle');

my $meta = $doc->meta;

is($meta->{T_title}, 'WPD17/A00.82293 Abbildungsfehler, In: Wikipedia - URL:http://de.wikipedia.org/wiki/Abbildungsfehler: Wikipedia, 2017 [Extract]', 'Title');
is($meta->{S_pub_place}, undef, 'PubPlace');
is($meta->{D_pub_date}, undef, 'Creation Date');
is($meta->{S_text_type}, undef, 'Text type');
is($meta->{T_author}, undef, 'Author');
is($meta->{S_language}, undef, 'Language');
is($meta->{T_doc_title}, undef, 'Correct Doc title');
ok(!$meta->{T_doc_sub_title}, 'Correct Doc Sub title');
ok(!$meta->{T_doc_author}, 'Correct Doc author');
ok(!$meta->{A_doc_editor}, 'Correct Doc editor');

# Tokenization
use_ok('KorAP::XML::Tokenizer');

my ($token_base_foundry, $token_base_layer) = (qw/Base tokens/);

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

is(substr($output->{data}->{text}, 0, 100), 'Es ist aber möglich, die Abbildungsfehler gegenüber einem einfachen System aus einer einzelnen Linse', 'Primary Data');

is($output->{data}->{name}, 'tokens', 'tokenName');
is($output->{data}->{tokenSource}, 'base#tokens', 'tokenSource');
is($output->{version}, '0.03', 'version');

is($output->{data}->{foundries}, '', 'Foundries');
is($output->{data}->{layerInfos}, '', 'layerInfos');
is($output->{data}->{stream}->[0]->[4], 's:Es', 'data');

is($output->{textSigle}, 'ICCGER/DeReKo-WPD17/A00-82293', 'Correct text sigle');
is($output->{docSigle}, 'ICCGER/DeReKo-WPD17', 'Correct document sigle');
is($output->{corpusSigle}, 'ICCGER', 'Correct corpus sigle');

is($output->{title}, 'WPD17/A00.82293 Abbildungsfehler, In: Wikipedia - URL:http://de.wikipedia.org/wiki/Abbildungsfehler: Wikipedia, 2017 [Extract]', 'Title');
ok(!exists $output->{subTitle}, 'Correct SubTitle');
ok(!exists $output->{author}, 'Author');
ok(!exists $output->{editor}, 'Publisher');

ok(!exists $output->{pubPlace}, 'PubPlace');
ok(!exists $output->{publisher}, 'Publisher');

ok(!exists $output->{textType}, 'Correct Text Type');
ok(!exists $output->{textTypeArt}, 'Correct Text Type Art');
ok(!exists $output->{textTypeRef}, 'Correct Text Type Ref');
ok(!exists $output->{textDomain}, 'Correct Text Domain');

ok(!exists $output->{creationDate}, 'Creation date');
ok(!exists $output->{availability}, 'License');

ok(!exists $output->{pages}, 'Pages');
ok(!exists $output->{fileEditionStatement}, 'File Statement');
ok(!exists $output->{biblEditionStatement}, 'Bibl Statement');

ok(!exists $output->{reference}, 'Reference');
ok(!exists $output->{language}, 'Language');

ok(!exists $output->{corpusTitle}, 'Correct Corpus title');
ok(!exists $output->{corpusSubTitle}, 'Correct Corpus sub title');
ok(!exists $output->{corpusAuthor}, 'Correct Corpus author');
ok(!exists $output->{corpusEditor}, 'Correct Corpus editor');

ok(!exists $output->{docTitle}, 'Correct Doc title');
ok(!exists $output->{docSubTitle}, 'Correct Doc sub title');
ok(!exists $output->{docAuthor}, 'Correct Doc author');
ok(!exists $output->{docEditor}, 'Correct doc editor');

## Base
$tokens->add('DeReKo', 'Structure');

$output = decode_json( $tokens->to_json );

is($output->{data}->{foundries}, 'dereko dereko/structure', 'Foundries');
is($output->{data}->{layerInfos}, 'dereko/s=spans', 'layerInfos');
my $first_token = join('||', @{$output->{data}->{stream}->[0]});
like($first_token, qr/<>:dereko\/s:s\$<b>64<i>0<i>145<i>21<b>4/, 'data');
like($first_token, qr/s:Es/, 'data');

# Add annotations
$tokens->add('UDPipe', 'Dependency');
$tokens->add('UDPipe', 'Morpho');

$output = decode_json( $tokens->to_json );

my $first = $output->{data}->{stream}->[0];

is('-:tokens$<i>1878', $first->[0]);
is('<:ud/d:root$<b>34<i>0<i>145<i>21<i>3', $first->[1]);
is('<>:dereko/s:s$<b>64<i>0<i>145<i>21<b>4', $first->[2]);
is('<>:dereko/s:p$<b>64<i>0<i>484<i>61<b>3', $first->[3]);
is('<>:dereko/s:div$<b>64<i>0<i>782<i>96<b>2<s>1', $first->[4]);
is('<>:base/s:t$<b>64<i>0<i>15402<i>1878<b>0', $first->[5]);
is('<>:dereko/s:text$<b>64<i>0<i>15402<i>1878<b>0', $first->[6]);
is('<>:dereko/s:body$<b>64<i>0<i>15402<i>1878<b>1', $first->[7]);
is('>:ud/d:expl$<b>32<i>3', $first->[8]);
is('@:dereko/s:type:fix2$<b>17<s>1<i>96', $first->[9]);
is('_0$<i>0<i>2', $first->[10]);
is('i:es', $first->[11]);
is('s:Es', $first->[12]);
is('ud/l:Es', $first->[13]);
is('ud/m:case:nom', $first->[14]);
is('ud/m:gender:neut', $first->[15]);
is('ud/m:number:sing', $first->[16]);
is('ud/m:person:3', $first->[17]);
is('ud/m:prontype:prs', $first->[18]);
is('ud/p:PRON', $first->[19]);
ok(!$first->[20]);

my $last = $output->{data}->{stream}->[-1];

is('>:ud/d:advmod$<b>32<i>1876', $last->[0]);
is('_1877$<i>15397<i>15401', $last->[1]);
is('i:auch', $last->[2]);
is('s:auch', $last->[3]);
is('ud/l:auch', $last->[4]);
is('ud/p:ADV', $last->[5]);
ok(!$last->[6]);

done_testing;
__END__
