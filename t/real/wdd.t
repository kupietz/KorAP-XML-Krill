#!/usr/bin/env perl
# source ~/perl5/perlbrew/etc/bashrc
# perlbrew switch perl-blead@korap
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

use_ok('KorAP::Document');

# GOE/AGA/03828
my $path = catdir(dirname(__FILE__), '../corpus/WDD/G27/38989');

ok(my $doc = KorAP::Document->new( path => $path . '/' ), 'Load Korap::Document');
ok($doc->parse, 'Parse document');

is($doc->text_sigle, 'WDD11_G27.38989', 'Correct text sigle');
is($doc->doc_sigle, 'WDD11_G27', 'Correct document sigle');
is($doc->corpus_sigle, 'WDD11', 'Correct corpus sigle');

is($doc->title, 'Diskussion:Gunter A. Pilz', 'Title');
ok(!$doc->sub_title, 'No SubTitle');
is($doc->author, '€pa, u.a.', 'Author');
ok(!$doc->editor, 'Publisher');

is($doc->pub_place, 'URL:http://de.wikipedia.org', 'PubPlace');
is($doc->publisher, 'Wikipedia', 'Publisher');
is($doc->text_type, 'Diskussionen zu Enzyklopädie-Artikeln', 'Correct Text Type');
ok(!$doc->text_type_art, 'Correct Text Type Art');
ok(!$doc->text_type_ref, 'Correct Text Type Ref');
ok(!$doc->text_domain, 'Correct Text Domain');
is($doc->creation_date, '20070707', 'Creation date');
is($doc->license, 'CC-BY-SA', 'License');
ok(!$doc->pages, 'Pages');
ok(!$doc->file_edition_statement, 'File Statement');
ok(!$doc->bibl_edition_statement, 'Bibl Statement');
is($doc->reference . "\n", <<'REF', 'Reference');
Diskussion:Gunter A. Pilz, In: Wikipedia - URL:http://de.wikipedia.org/wiki/Diskussion:Gunter_A._Pilz: Wikipedia, 2007
REF
is($doc->language, 'de', 'Language');

is($doc->corpus_title, 'Wikipedia', 'Correct Corpus title');
ok(!$doc->corpus_sub_title, 'Correct Corpus sub title');
ok(!$doc->corpus_author, 'Correct Corpus author');
is($doc->corpus_editor, 'wikipedia.org', 'Correct Corpus editor');

is($doc->doc_title, 'Wikipedia, Diskussionen zu Artikeln mit Anfangsbuchstabe G, Teil 27', 'Correct Doc title');
ok(!$doc->doc_sub_title, 'Correct Doc sub title');
ok(!$doc->doc_author, 'Correct Doc author');
ok(!$doc->doc_editor, 'Correct doc editor');

# Tokenization
use_ok('KorAP::Tokenizer');

my ($token_base_foundry, $token_base_layer) = (qw/OpenNLP Tokens/);

# Get tokenization
my $tokens = KorAP::Tokenizer->new(
  path => $doc->path,
  doc => $doc,
  foundry => $token_base_foundry,
  layer => $token_base_layer,
  name => 'tokens'
);
ok($tokens, 'Token Object is fine');
ok($tokens->parse, 'Token parsing is fine');

my $output = decode_json( $tokens->to_json );

is(substr($output->{data}->{text}, 0, 100), '{{War Löschkandidat|6. Juli 2007|(erl., bleibt)}}', 'Primary Data');
is($output->{data}->{name}, 'tokens', 'tokenName');
is($output->{data}->{tokenSource}, 'opennlp#tokens', 'tokenSource');
is($output->{version}, '0.03', 'version');
is($output->{data}->{foundries}, '', 'Foundries');
is($output->{data}->{layerInfos}, '', 'layerInfos');
is($output->{data}->{stream}->[0]->[3], 's:{War', 'data');

is($output->{textSigle}, 'WDD11_G27.38989', 'Correct text sigle');
is($output->{docSigle}, 'WDD11_G27', 'Correct document sigle');
is($output->{corpusSigle}, 'WDD11', 'Correct corpus sigle');

is($output->{title}, 'Diskussion:Gunter A. Pilz', 'Title');
ok(!$output->{subTitle}, 'No SubTitle');
is($output->{author}, '€pa, u.a.', 'Author');
ok(!$output->{editor}, 'Editor');

is($output->{pubPlace}, 'URL:http://de.wikipedia.org', 'PubPlace');
is($output->{publisher}, 'Wikipedia', 'Publisher');
is($output->{textType}, 'Diskussionen zu Enzyklopädie-Artikeln', 'Correct Text Type');
ok(!$output->{textTypeArt}, 'Correct Text Type Art');
ok(!$output->{textTypeRef}, 'Correct Text Type Ref');
ok(!$output->{textDomain}, 'Correct Text Domain');
is($output->{creationDate}, '20070707', 'Creation date');
is($output->{license}, 'CC-BY-SA', 'License');
ok(!$output->{pages}, 'Pages');
ok(!$output->{fileEditionStatement}, 'File Statement');
ok(!$output->{biblEditionStatement}, 'Bibl Statement');
is($output->{reference} . "\n", <<'REF', 'Reference');
Diskussion:Gunter A. Pilz, In: Wikipedia - URL:http://de.wikipedia.org/wiki/Diskussion:Gunter_A._Pilz: Wikipedia, 2007
REF
is($output->{language}, 'de', 'Language');

is($output->{corpusTitle}, 'Wikipedia', 'Correct Corpus title');
ok(!$output->{corpusSubTitle}, 'Correct Corpus sub title');
ok(!$output->{corpusAuthor}, 'Correct Corpus author');
is($output->{corpusEditor}, 'wikipedia.org', 'Correct Corpus editor');

is($output->{docTitle}, 'Wikipedia, Diskussionen zu Artikeln mit Anfangsbuchstabe G, Teil 27', 'Correct Doc title');
ok(!$output->{docSubTitle}, 'Correct Doc sub title');
ok(!$output->{docAuthor}, 'Correct Doc author');
ok(!$output->{docEditor}, 'Correct doc editor');

## Base
$tokens->add('Base', 'Sentences');

$tokens->add('Base', 'Paragraphs');

$output = decode_json( $tokens->to_json );

is($output->{data}->{foundries}, 'base base/paragraphs base/sentences', 'Foundries');
is($output->{data}->{layerInfos}, 'base/s=spans', 'layerInfos');
my $first_token = join('||', @{$output->{data}->{stream}->[0]});
like($first_token, qr/s:{War/, 'data');
like($first_token, qr/_0\$<i>1<i>5/, 'data');


## OpenNLP
$tokens->add('OpenNLP', 'Sentences');

$output = decode_json( $tokens->to_json );
is($output->{data}->{foundries},
   'base base/paragraphs base/sentences opennlp opennlp/sentences',
   'Foundries');
is($output->{data}->{layerInfos}, 'base/s=spans opennlp/s=spans', 'layerInfos');


$tokens->add('OpenNLP', 'Morpho');
$output = decode_json( $tokens->to_json );
is($output->{data}->{foundries},
   'base base/paragraphs base/sentences opennlp opennlp/morpho opennlp/sentences',
   'Foundries');
is($output->{data}->{layerInfos}, 'base/s=spans opennlp/p=tokens opennlp/s=spans', 'layerInfos');


## Treetagger
$tokens->add('TreeTagger', 'Sentences');
$output = decode_json( $tokens->to_json );
is($output->{data}->{foundries},
   'base base/paragraphs base/sentences opennlp opennlp/morpho opennlp/sentences treetagger treetagger/sentences',
   'Foundries');
is($output->{data}->{layerInfos}, 'base/s=spans opennlp/p=tokens opennlp/s=spans tt/s=spans', 'layerInfos');

$tokens->add('TreeTagger', 'Morpho');
$output = decode_json( $tokens->to_json );
is($output->{data}->{foundries},
   'base base/paragraphs base/sentences opennlp opennlp/morpho opennlp/sentences treetagger treetagger/morpho treetagger/sentences',
   'Foundries');
is($output->{data}->{layerInfos}, 'base/s=spans opennlp/p=tokens opennlp/s=spans tt/l=tokens tt/p=tokens tt/s=spans', 'layerInfos');

## CoreNLP
{
  local $SIG{__WARN__} = sub {};
  $tokens->add('CoreNLP', 'NamedEntities');
};
$output = decode_json( $tokens->to_json );
is($output->{data}->{foundries},
   'base base/paragraphs base/sentences opennlp opennlp/morpho opennlp/sentences treetagger treetagger/morpho treetagger/sentences',
   'Foundries');
is($output->{data}->{layerInfos}, 'base/s=spans opennlp/p=tokens opennlp/s=spans tt/l=tokens tt/p=tokens tt/s=spans', 'layerInfos');


{
  local $SIG{__WARN__} = sub {};
  $tokens->add('CoreNLP', 'Sentences');
};
$output = decode_json( $tokens->to_json );
is($output->{data}->{foundries},
   'base base/paragraphs base/sentences opennlp opennlp/morpho opennlp/sentences treetagger treetagger/morpho treetagger/sentences',
   'Foundries');
is($output->{data}->{layerInfos}, 'base/s=spans opennlp/p=tokens opennlp/s=spans tt/l=tokens tt/p=tokens tt/s=spans', 'layerInfos');

{
  local $SIG{__WARN__} = sub {};
  $tokens->add('CoreNLP', 'Morpho');
};
$output = decode_json( $tokens->to_json );
unlike($output->{data}->{foundries}, qr!corenlp/morpho!, 'Foundries');
unlike($output->{data}->{layerInfos}, qr!corenlp/p=tokens!, 'layerInfos');

{
  local $SIG{__WARN__} = sub {};
  $tokens->add('CoreNLP', 'Constituency');
};
$output = decode_json( $tokens->to_json );
unlike($output->{data}->{foundries}, qr!corenlp/constituency!, 'Foundries');
unlike($output->{data}->{layerInfos}, qr!corenlp/c=spans!, 'layerInfos');

## Glemm
{
  local $SIG{__WARN__} = sub {};
  $tokens->add('Glemm', 'Morpho');
};
$output = decode_json( $tokens->to_json );
unlike($output->{data}->{foundries}, qr!glemm/morpho!, 'Foundries');
unlike($output->{data}->{layerInfos}, qr!glemm/l=tokens!, 'layerInfos');

## Connexor
$tokens->add('Connexor', 'Sentences');
$output = decode_json( $tokens->to_json );
like($output->{data}->{foundries}, qr!connexor/sentences!, 'Foundries');
like($output->{data}->{layerInfos}, qr!cnx/s=spans!, 'layerInfos');

$tokens->add('Connexor', 'Morpho');
$output = decode_json( $tokens->to_json );
like($output->{data}->{foundries}, qr!connexor/morpho!, 'Foundries');
like($output->{data}->{layerInfos}, qr!cnx/p=tokens!, 'layerInfos');
like($output->{data}->{layerInfos}, qr!cnx/l=tokens!, 'layerInfos');
like($output->{data}->{layerInfos}, qr!cnx/m=tokens!, 'layerInfos');

$tokens->add('Connexor', 'Phrase');
$output = decode_json( $tokens->to_json );
like($output->{data}->{foundries}, qr!connexor/phrase!, 'Foundries');
like($output->{data}->{layerInfos}, qr!cnx/c=spans!, 'layerInfos');

$tokens->add('Connexor', 'Syntax');
$output = decode_json( $tokens->to_json );
like($output->{data}->{foundries}, qr!connexor/syntax!, 'Foundries');
like($output->{data}->{layerInfos}, qr!cnx/syn=tokens!, 'layerInfos');

## Mate
$tokens->add('Mate', 'Morpho');
$output = decode_json( $tokens->to_json );
like($output->{data}->{foundries}, qr!mate/morpho!, 'Foundries');
like($output->{data}->{layerInfos}, qr!mate/p=tokens!, 'layerInfos');
like($output->{data}->{layerInfos}, qr!mate/l=tokens!, 'layerInfos');
like($output->{data}->{layerInfos}, qr!mate/m=tokens!, 'layerInfos');

# diag "No test for mate dependency";

## XIP
$tokens->add('XIP', 'Sentences');
$output = decode_json( $tokens->to_json );
like($output->{data}->{foundries}, qr!xip/sentences!, 'Foundries');
like($output->{data}->{layerInfos}, qr!xip/s=spans!, 'layerInfos');

$tokens->add('XIP', 'Morpho');
$output = decode_json( $tokens->to_json );
like($output->{data}->{foundries}, qr!xip/morpho!, 'Foundries');
like($output->{data}->{layerInfos}, qr!xip/l=tokens!, 'layerInfos');
like($output->{data}->{layerInfos}, qr!xip/p=tokens!, 'layerInfos');

$tokens->add('XIP', 'Constituency');
$output = decode_json( $tokens->to_json );
like($output->{data}->{foundries}, qr!xip/constituency!, 'Foundries');
like($output->{data}->{layerInfos}, qr!xip/c=spans!, 'layerInfos');

# diag "No test for xip dependency";

done_testing;
__END__
