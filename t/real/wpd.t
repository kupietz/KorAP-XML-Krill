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
my $path = catdir(dirname(__FILE__), '../corpus/WPD/00001');
# my $path = '/home/ndiewald/Repositories/korap/KorAP-sandbox/KorAP-lucene-indexer/t/GOE/AGA/03828';

ok(my $doc = KorAP::XML::Krill->new( path => $path . '/' ), 'Load Korap::Document');
ok($doc->parse, 'Parse document');

is($doc->text_sigle, 'WPD_AAA.00001', 'Correct text sigle');
is($doc->doc_sigle, 'WPD_AAA', 'Correct document sigle');
is($doc->corpus_sigle, 'WPD', 'Correct corpus sigle');

is($doc->title, 'A', 'Title');
is($doc->pub_place, 'URL:http://de.wikipedia.org', 'PubPlace');
is($doc->pub_date, '20050328', 'Creation Date');
ok(!$doc->sub_title, 'SubTitle');
is($doc->author, 'Ruru; Jens.Ol; Aglarech; u.a.', 'Author');

ok(!$doc->doc_title, 'Correct Doc title');
ok(!$doc->doc_sub_title, 'Correct Doc Sub title');
ok(!$doc->doc_author, 'Correct Doc author');
ok(!$doc->doc_editor, 'Correct Doc editor');

ok(!$doc->corpus_title, 'Correct Corpus title');
ok(!$doc->corpus_sub_title, 'Correct Corpus Sub title');

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

my $output = $tokens->to_data;

is(substr($output->{data}->{text}, 0, 100), 'A bzw. a ist der erste Buchstabe des lateinischen Alphabets und ein Vokal. Der Buchstabe A hat in de', 'Primary Data');
is($output->{data}->{name}, 'tokens', 'tokenName');
is($output->{data}->{tokenSource}, 'opennlp#tokens', 'tokenSource');

is($output->{version}, '0.03', 'version');
is($output->{data}->{foundries}, '', 'Foundries');
is($output->{data}->{layerInfos}, '', 'layerInfos');
is($output->{data}->{stream}->[0]->[4], 's:A', 'data');

$tokens->add('Mate', 'Dependency');

my $stream = $tokens->to_data->{data}->{stream};

is($stream->[77]->[0], '<:mate/d:--$<b>34<i>78<i>78<s>1<s>1', 'element to term');
is($stream->[77]->[1], '<>:mate/d:&&&$<b>64<i>498<i>499<i>78<b>0<s>1', 'element to term');
is($stream->[78]->[0], '>:mate/d:--$<b>33<i>77<i>78<s>1<s>1', 'term to element');
is($stream->[78]->[3], 'mate/d:&&&$<b>128<s>1', 'Node');


done_testing;
__END__




