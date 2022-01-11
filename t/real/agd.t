use strict;
use warnings;
use Test::More;
use Data::Dumper;
use JSON::XS;
use utf8;

if ($ENV{SKIP_REAL}) {
  plan skip_all => 'Skip real tests';
};

use Benchmark qw/:hireswallclock/;

my $t = Benchmark->new;

use File::Basename 'dirname';
use File::Spec::Functions 'catdir';

use_ok('KorAP::XML::Krill');

my $path = catdir(dirname(__FILE__), 'corpus', 'AGD-scrambled', 'DOC', '00001');

ok(my $doc = KorAP::XML::Krill->new( path => $path . '/' ), 'Load Korap::Document');
ok($doc->parse, 'Parse document');

is($doc->text_sigle, 'AGD/DOC/00001', 'Correct text sigle');
is($doc->doc_sigle, 'AGD/DOC', 'Correct document sigle');
is($doc->corpus_sigle, 'AGD', 'Correct corpus sigle');

my $meta = $doc->meta;
is($meta->{T_title}, 'FOLK_E_00321_SE_01_T_01_DF_01', 'Title');
is($meta->{D_creation_date}, '20181112', 'Title');

is($meta->{A_externalLink}, 'data:application/x.korap-link;title=DGD,'.
     'https%3A%2F%2Fdgd.ids-mannheim.de%2FDGD2Web%2FExternalAccessServlet%3F'.
     'command%3DdisplayData%26id%3DFOLK_E_00321_SE_01_T_01', 'External link');

# Tokenization
use_ok('KorAP::XML::Tokenizer');

my ($token_base_foundry, $token_base_layer) = (qw/DGD Annot/);

# Get tokenization
my $tokens = KorAP::XML::Tokenizer->new(
  path => $doc->path,
  doc => $doc,
  foundry => $token_base_foundry,
  layer => $token_base_layer,
  name => 'tokens',
  non_verbal_tokens => 1
);

ok($tokens, 'Token Object is fine');
ok($tokens->parse, 'Token parsing is fine');

my $output = decode_json( $tokens->to_json );

is(substr($output->{data}->{text}, 0, 100),
   '+++++++++ ku sqn alxv a pwm ▮ xnj nq qtl ohmdgjqp ▮ ▮ ▮ ▮ ▮ fi ▮ sna ▮ alxv hn ▮ zjc ahyx ftwbramn l',
   'Primary Data');

is($output->{data}->{name}, 'tokens', 'tokenName');
is($output->{data}->{tokenSource}, 'dgd#annot', 'tokenSource');

is($output->{version}, '0.03', 'version');
is($output->{data}->{foundries}, '', 'Foundries');
is($output->{data}->{layerInfos}, '', 'layerInfos');
is($output->{data}->{stream}->[0]->[4], 's:ku', 'data');
is($output->{data}->{stream}->[1]->[2], 's:sqn', 'data');
is($output->{data}->{stream}->[2]->[2], 's:alxv', 'data');
is($output->{textSigle}, 'AGD/DOC/00001', 'Correct text sigle');
is($output->{docSigle}, 'AGD/DOC', 'Correct document sigle');
is($output->{corpusSigle}, 'AGD', 'Correct corpus sigle');

is($output->{title}, 'FOLK_E_00321_SE_01_T_01_DF_01', 'Title');

## DeReKo
$tokens->add('DeReKo', 'Structure');

$output = decode_json( $tokens->to_json );

is($output->{data}->{foundries},
   'dereko dereko/structure',
   'Foundries');
is($output->{data}->{layerInfos}, 'dereko/s=spans', 'layerInfos');

my $first_token = join('||', @{$output->{data}->{stream}->[0]});
like($first_token, qr!<>:dereko/s:text!);

## DGD
ok($tokens->add('DGD', 'Morpho'), 'Add Morpho');

$output = decode_json( $tokens->to_json );
is($output->{data}->{foundries},
   'dereko dereko/structure dgd dgd/morpho',
   'Foundries');
is($output->{data}->{layerInfos}, 'dereko/s=spans dgd/l=tokens dgd/p=tokens dgd/para=tokens',
   'layerInfos');

my $third_token = join('||', @{$output->{data}->{stream}->[2]});
like($third_token, qr!dgd/l:alui!);
like($third_token, qr!dgd/p:VMGWY!);
like($third_token, qr!i:alxv!);
like($third_token, qr!s:alxv!);

## DGD base sentences
ok($tokens->add('DGD', 'Structure'), 'Add sentences');
$output = decode_json( $tokens->to_json );

# Offsets are suboptimal set, but good enough

$first_token = join('||', @{$output->{data}->{stream}->[0]});
like($first_token, qr!<>:base/s:s\$<b>64<i>0<i>16<i>2<b>1!);

my $token = join('||', @{$output->{data}->{stream}->[2]});
like($token, qr!<>:base/s:s\$<b>64<i>16<i>23<i>4<b>1!);
$token = join('||', @{$output->{data}->{stream}->[3]});
unlike($token, qr!<>:base/s:s!);

$token = join('||', @{$output->{data}->{stream}->[4]});
like($token, qr!<>:base/s:s\$<b>64<i>23<i>27<i>5<b>1!);

$token = join('||', @{$output->{data}->{stream}->[5]});
like($token, qr!dgd/para:pause!);


# New revision
$path = catdir(dirname(__FILE__), 'corpus', 'FOLK-scrambled', '00068-SE-01', 'T-05');
ok($doc = KorAP::XML::Krill->new( path => $path . '/' ), 'Load Korap::Document');
ok($doc->parse, 'Parse document');

is($doc->text_sigle, 'FOLK/00068-SE-01/T-05', 'Correct text sigle');
is($doc->doc_sigle, 'FOLK/00068-SE-01', 'Correct document sigle');
is($doc->corpus_sigle, 'FOLK', 'Correct corpus sigle');

$meta = $doc->meta;
is($meta->{T_title}, 'FOLK_E_00068_SE_01_T_05_DF_01', 'Title');

is($meta->{A_externalLink}, 'data:application/x.korap-link;title=DGD,'.
     'https%3A%2F%2Fdgd.ids-mannheim.de%2FDGD2Web%2FExternalAccessServlet'.
     '%3Fcommand%3DdisplayData%26id%3DFOLK_E_00068_SE_01_T_05');

# Tokenization
use_ok('KorAP::XML::Tokenizer');

($token_base_foundry, $token_base_layer) = (qw/DGD Annot/);

# Get tokenization
$tokens = KorAP::XML::Tokenizer->new(
  path => $doc->path,
  doc => $doc,
  foundry => $token_base_foundry,
  layer => $token_base_layer,
  name => 'tokens',
  non_verbal_tokens => 1
);

ok($tokens, 'Token Object is fine');
ok($tokens->parse, 'Token parsing is fine');

## DeReKo
# $tokens->add('DeReKo', 'Structure');

## DGD
ok($tokens->add('DGD', 'Morpho'), 'Add Morpho');

$output = decode_json( $tokens->to_json );

is(substr($output->{data}->{text}, 11, 30),
   'ogeuy Nva wvho zhl usblyuug Kt',
   'Primary Data');
is($output->{data}->{name}, 'tokens', 'tokenName');
is($output->{data}->{tokenSource}, 'dgd#annot', 'tokenSource');

is($output->{data}->{stream}->[0]->[1],
   '<>:base/s:t$<b>64<i>0<i>39384<i>7190<b>0',
   'data'
 );

is($output->{data}->{stream}->[0]->[2],
   '@:dgd/para:type:micro$<b>16<s>1',
   'data'
 );

is($output->{data}->{stream}->[0]->[3],
   '@:dgd/para:rend:(.)$<b>16<s>1',
   'data'
 );

is($output->{data}->{stream}->[0]->[5],
   'dgd/para:pause$<b>128<s>1',
   'data'
 );

is($output->{data}->{stream}->[1]->[0],
   '@:dgd/para:desc:short breathe in$<b>16<s>1',
   'data'
 );

is($output->{data}->{stream}->[1]->[1],
   "\@:dgd/para:rend:\x{b0}h\$<b>16<s>1",
   'data'
 );

is($output->{data}->{stream}->[1]->[3],
   'dgd/para:vocal$<b>128<s>1',
   'data'
 );

is($output->{data}->{stream}->[97]->[1],
   'dgd/l:ui',
   'data'
 );

is($output->{data}->{stream}->[97]->[2],
   'dgd/p:AUUK',
   'data'
 );

is($output->{data}->{stream}->[97]->[3],
   'dgd/trans:rh',
   'data'
 );

is($output->{data}->{stream}->[97]->[4],
   'dgd/type:assimilated',
   'data'
 );


done_testing;
__END__
