use strict;
use warnings;
use Test::More;
use Data::Dumper;
use JSON::XS;

if ($ENV{SKIP_REAL}) {
  plan skip_all => 'Skip real tests';
};

use utf8;
use lib 'lib', '../lib';

use File::Basename 'dirname';
use File::Spec::Functions 'catdir';

use_ok('KorAP::XML::Krill');

my $path = catdir(dirname(__FILE__), 'corpus','NKJP','NKJP','KOT');

ok(my $doc = KorAP::XML::Krill->new( path => $path . '/' ), 'Load Korap::Document');
ok($doc->parse, 'Parse document');

is($doc->text_sigle, 'NKJP/NKJP/KOT', 'Correct text sigle');
is($doc->doc_sigle, 'NKJP/NKJP', 'Correct document sigle');
is($doc->corpus_sigle, 'NKJP', 'Correct corpus sigle');

my $meta = $doc->meta;

is($meta->{T_title}, 'TEI P5 encoded version of sample(s) of "Kot"', 'Title');
ok(!$meta->{T_sub_title}, 'SubTitle');
ok(!$meta->{T_author}, 'Author');
ok(!$meta->{A_editor}, 'Editor');
ok(!$meta->{S_pub_place}, 'PubPlace');
ok(!$meta->{A_publisher},  'Publisher');

ok(!$meta->{S_text_type}, 'No Text Type');
ok(!$meta->{S_text_type_art}, 'No Text Type Art');
ok(!$meta->{S_text_type_ref}, 'No Text Type Ref');
ok(!$meta->{S_text_domain}, 'No Text Domain');
ok(!$meta->{S_text_column}, 'No Text Column');


# Tokenization
use_ok('KorAP::XML::Tokenizer');

my ($token_base_foundry, $token_base_layer) = (qw/nkjp Morpho/);

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

is($output->{data}->{stream}->[0]->[0], '-:tokens$<i>43', 't');
is($output->{data}->{stream}->[0]->[3], 'i:nie', 't');
is($output->{data}->{stream}->[1]->[2], 's:zdążyła', 't');

## Base
ok($tokens->add('DeReKo', 'Structure', 'base_sentences_paragraphs'));
ok($tokens->add('NKJP', 'Morpho'), 'Add Gingko');

$output = $tokens->to_data;

is($output->{data}->{foundries}, 'dereko dereko/structure dereko/structure/base_sentences_paragraphs nkjp nkjp/morpho', 'Foundries');

is($output->{data}->{layerInfos}, 'dereko/s=spans nkjp/l=tokens nkjp/m=tokens nkjp/p=tokens', 'layerInfos');

my $token = join('||', @{$output->{data}->{stream}->[7]});

like($token, qr!<>:dereko\/s:seg\$<b>64!);
like($token, qr!<>:dereko\/s:seg\$<b>64!);
like($token, qr!i:ładu!);
like($token, qr!nkjp\/l:ład!);
like($token, qr!nkjp\/m:sg:gen:m3!);
like($token, qr!nkjp\/p:subst!);
like($token, qr!s:ładu!);

done_testing;
__END__

