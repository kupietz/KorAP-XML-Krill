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

my $path = catdir(dirname(__FILE__), '../corpus/WPF19/P00/0042242');

ok(my $doc = KorAP::XML::Krill->new( path => $path . '/' ), 'Load Korap::Document');
ok($doc->parse, 'Parse document');

is($doc->text_sigle, 'WPF19/P00/0042242', 'Correct text sigle');
is($doc->doc_sigle, 'WPF19/P00', 'Correct document sigle');
is($doc->corpus_sigle, 'WPF19', 'Correct corpus sigle');

my $meta = $doc->meta;

is($meta->{T_title}, 'Psychanalyse', 'Title');
is($meta->{S_pub_place}, 'URL:http://fr.wikipedia.org', 'PubPlace');
is($meta->{D_pub_date}, '20190220', 'Creation Date');
is($meta->{S_text_type}, 'Enzyklopädie', 'Text type');
is($meta->{T_author}, 'Pierrette13, u.a.', 'Author');
is($meta->{S_language}, 'fr', 'Author');

is($meta->{T_doc_title}, 'Wikipedia, Artikel mit Anfangsbuchstabe P, Teil 00', 'Correct Doc title');
ok(!$meta->{T_doc_sub_title}, 'Correct Doc Sub title');
ok(!$meta->{T_doc_author}, 'Correct Doc author');
ok(!$meta->{A_doc_editor}, 'Correct Doc editor');

is($meta->{T_corpus_title}, 'Wikipedia', 'Correct Corpus title');
ok(!$meta->{T_corpus_sub_title}, 'Correct Corpus Sub title');

# This link is broken, but that's due to the data
is($meta->{A_externalLink}, 'data:application/x.korap-link;title=Wikipedia,http://fr.wikipedia.org/wiki/Psychanalyse', 'No link');

# Tokenization
use_ok('KorAP::XML::Tokenizer');

my ($token_base_foundry, $token_base_layer) = (qw/Base Tokens/);

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

my $output = $tokens->to_data;

is(substr($output->{data}->{text}, 0, 100), 'Fichier:Sigmund Freud LIFE.jpg La psychanalyse est, selon la définition classique qu\'en a donnée Sig', 'Primary Data');
is($output->{data}->{name}, 'tokens', 'tokenName');
is($output->{data}->{tokenSource}, 'base#tokens', 'tokenSource');

is($output->{version}, '0.03', 'version');
is($output->{data}->{foundries}, '', 'Foundries');
is($output->{data}->{layerInfos}, '', 'layerInfos');
is($output->{data}->{stream}->[0]->[4], 's:Fichier', 'data');

$tokens->add('Malt', 'Dependency');

my $stream = $tokens->to_data->{data}->{stream};

# This is not a goot relation example
is($stream->[77]->[0],
   '>:malt/d:nsubj$<b>32<i>78',
   'element to term');
is($stream->[78]->[0], '>:malt/d:null$<b>32<i>76', 'term to element');

# Add structure
$tokens->add('DeReKo', 'Structure');

$stream = $tokens->to_data->{data}->{stream};

is($stream->[71]->[1], '<>:dereko/s:s$<b>64<i>530<i>856<i>124<b>4', 'Text starts with sentence');

# Add Talismane Dependency
$tokens->add('Talismane', 'Dependency');

$stream = $tokens->to_data->{data}->{stream};
is($stream->[1]->[0], '>:talismane/d:mod$<b>32<i>0', 'Talismane dependency annotation');
is($stream->[300]->[0], '>:talismane/d:det$<b>32<i>301', 'Talismane dep annotation');


# Add Talismane Morpho
$tokens->add('Talismane', 'Morpho');

$stream = $tokens->to_data->{data}->{stream};

is($stream->[1]->[9], 'talismane/l:Sigmund', 'Talismane morpho annotation');
is($stream->[1]->[10], 'talismane/m:g:m', 'Talismane morpho annotation');
is($stream->[1]->[11], 'talismane/m:n:s', 'Talismane morpho annotation');
is($stream->[1]->[12], 'talismane/p:NPP', 'Talismane morpho annotation');

is($stream->[300]->[5], 'talismane/l:son', 'Talismane lemma annotation');
is($stream->[300]->[6], 'talismane/m:g:m', 'Talismane morph annotation');
is($stream->[300]->[7], 'talismane/m:n:s', 'Talismane morph annotation');
is($stream->[300]->[8], 'talismane/m:p:3', 'Talismane morph annotation');
is($stream->[300]->[9], 'talismane/m:poss:s', 'Talismane morph annotation');
is($stream->[300]->[10], 'talismane/p:DET', 'Talismane pos annotation');

# Add Malt dependency
$tokens->add('Malt', 'Dependency');
$stream = $tokens->to_data->{data}->{stream};

# This is no longer indexed
# is($stream->[1]->[1], '>:malt/d:dep$<b>33<i>7<i>8<i>0<i>1', 'Malt dep annotation');

is($stream->[1]->[2], '<:malt/d:dep$<b>32<i>2', 'Malt dep annotation');
is($stream->[300]->[1], '>:malt/d:punct$<b>32<i>302', 'Malt dep annotation');


# Add TreeTagger morpho
$tokens->add('TreeTagger', 'Morpho');
$stream = $tokens->to_data->{data}->{stream};

is($stream->[1]->[13], 'tt/p:ADJ$<b>129<b>26', 'TreeTagger morph annotation');
is($stream->[1]->[14], 'tt/p:NAM$<b>129<b>200', 'TreeTagger morph annotation');
is($stream->[1]->[15], 'tt/p:NOM$<b>129<b>27', 'TreeTagger morph annotation');


done_testing;
__END__




