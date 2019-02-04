use strict;
use warnings;
use Test::More;
use Data::Dumper;
use JSON::XS;

use Benchmark qw/:hireswallclock/;

my $t = Benchmark->new;

use utf8;

use File::Basename 'dirname';
use File::Spec::Functions 'catdir';

use_ok('KorAP::XML::Krill');

my $path = catdir(dirname(__FILE__), '../corpus/WPE15/G00/11973');

ok(my $doc = KorAP::XML::Krill->new( path => $path . '/' ), 'Load Korap::Document');
ok($doc->parse, 'Parse document');

is($doc->text_sigle, 'WPE15/G00/11973', 'Correct text sigle');
is($doc->doc_sigle, 'WPE15/G00', 'Correct document sigle');
is($doc->corpus_sigle, 'WPE15', 'Correct corpus sigle');

my $meta = $doc->meta;
is($meta->{T_title}, 'Generation X', 'Title');
is($meta->{S_pub_place}, 'URL:http://en.wikipedia.org', 'PubPlace');
is($meta->{D_pub_date}, '20150808', 'Creation Date');
ok(!$meta->{T_sub_title}, 'Title');
is($meta->{T_author}, 'Bnosnhoj, u.a.', 'Author');
is($meta->{T_doc_title}, 'Wikipedia, Artikel mit Anfangsbuchstabe G, Teil 00', 'Correct Doc title');

is($meta->{A_reference}, 'Generation X, In: Wikipedia - URL:http://en.wikipedia.org/wiki/Generation_X: Wikipedia, 2015', 'Reference');

is($meta->{'S_availability'}, 'CC-BY-SA', 'Availability');
is($meta->{'S_language'}, 'en', 'Language');

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

is(substr($output->{data}->{text}, 0, 100), '         Generation X, commonly abbreviated to Gen X, is the generation born after the Western Post–', 'Primary Data');
is($output->{data}->{name}, 'tokens', 'tokenName');
is($output->{data}->{tokenSource}, 'base#tokens', 'tokenSource');

is($output->{version}, '0.03', 'version');
is($output->{data}->{foundries}, '', 'Foundries');
is($output->{data}->{layerInfos}, '', 'layerInfos');
is($output->{data}->{stream}->[0]->[4], 's:Generation', 'data');
is($output->{data}->{stream}->[3]->[2], 's:abbreviated', 'data');

$tokens->add('Malt', 'Dependency');

my $stream = $tokens->to_data->{data}->{stream};

# This is not a goot relation example
is($stream->[77]->[0],
   '>:malt/d:pobj$<b>32<i>75',
   'Relation');
is($stream->[100]->[0], '>:malt/d:dep$<b>32<i>101', 'relation');

$tokens->add('DeReKo', 'Structure', 'base-sentences-paragraphs-pagebreaks');

$stream = $tokens->to_data->{data}->{stream};

is($stream->[0]->[8], '<>:base/s:s$<b>64<i>8<i>123<i>19<b>2', 'Text starts with sentence');

$tokens->add('TreeTagger', 'Morpho');

$stream = $tokens->to_data->{data}->{stream};

is($stream->[20]->[4], 'tt/l:historian', 'Treetagger');
is($stream->[20]->[5], 'tt/p:NNS', 'Treetagger');

done_testing;
__END__
