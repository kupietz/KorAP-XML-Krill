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
my $path = catdir(dirname(__FILE__), 'GOE/AGA/03828');

ok(my $doc = KorAP::Document->new( path => $path . '/' ), 'Load Korap::Document');
ok($doc->parse, 'Parse document');

is($doc->text_sigle, 'GOE_AGA.03828', 'Correct text sigle');
is($doc->doc_sigle, 'GOE_AGA', 'Correct document sigle');
is($doc->corpus_sigle, 'GOE', 'Correct corpus sigle');

is($doc->corpus_title, 'Goethes Werke', 'Correct Corpus title');
is($doc->text_type, 'Autobiographie', 'Correct Text Type');
is($doc->author->[0], 'Goethe, Johann Wolfgang von', 'Author');
is($doc->reference . "\n", <<'REF', 'Author');
Goethe, Johann Wolfgang von: Autobiographische Einzelheiten, (Geschrieben bis 1832), In: Goethe, Johann Wolfgang von: Goethes Werke, Bd. 10, Autobiographische Schriften II, Hrsg.: Trunz, Erich. München: Verlag C. H. Beck, 1982, S. 529-547
REF
is($doc->pub_place, 'München', 'PubPlace');
is($doc->publisher, 'Verlag C. H. Beck', 'Publisher');
is($doc->coll_editor, 'Trunz, Erich', 'Editor');
is($doc->language, 'de', 'Language');
is($doc->license, 'QAO-NC', 'License');
is($doc->creation_date, '18200000', 'Creation Date');
is($doc->pub_date, '19820000', 'Creation Date');
is($doc->title, 'Autobiographische Einzelheiten', 'Title');
is($doc->pages, '529-547', 'Pages');

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


is(substr($output->{primaryData}, 0, 100), 'Autobiographische einzelheiten Selbstschilderung (1) immer tätiger, nach innen und außen fortwirkend', 'Primary Data');
is($output->{tokenName}, 'tokens', 'tokenName');
is($output->{tokenSource}, 'opennlp#tokens', 'tokenSource');
is($output->{version}, '0.02', 'version');

is($output->{foundries}, '', 'Foundries');
is($output->{layerInfos}, '', 'layerInfos');
is($output->{data}->[0]->[3], 's:Autobiographische', 'data');

is($output->{textSigle}, 'GOE_AGA.03828', 'Correct text sigle');
is($output->{docSigle}, 'GOE_AGA', 'Correct document sigle');
is($output->{corpusSigle}, 'GOE', 'Correct corpus sigle');

is($output->{corpusTitle}, 'Goethes Werke', 'Correct Corpus title');
is($output->{textType}, 'Autobiographie', 'Correct Text Type');
is($output->{author}, 'Goethe, Johann Wolfgang von', 'Author');
is($output->{reference} . "\n", <<'REF', 'Author');
Goethe, Johann Wolfgang von: Autobiographische Einzelheiten, (Geschrieben bis 1832), In: Goethe, Johann Wolfgang von: Goethes Werke, Bd. 10, Autobiographische Schriften II, Hrsg.: Trunz, Erich. München: Verlag C. H. Beck, 1982, S. 529-547
REF
is($output->{pubPlace}, 'München', 'PubPlace');
is($output->{publisher}, 'Verlag C. H. Beck', 'Publisher');
is($output->{collEditor}, 'Trunz, Erich', 'Editor');
is($output->{language}, 'de', 'Language');
is($output->{license}, 'QAO-NC', 'License');
is($output->{creationDate}, '18200000', 'Creation Date');
is($output->{pubDate}, '19820000', 'Creation Date');
is($output->{title}, 'Autobiographische Einzelheiten', 'Title');
is($output->{pages}, '529-547', 'Pages');


## Base
$tokens->add('Base', 'Sentences');
$tokens->add('Base', 'Paragraphs');

$output = decode_json( $tokens->to_json );

is($output->{foundries}, 'base base/paragraphs base/sentences', 'Foundries');
is($output->{layerInfos}, 'base/s=spans', 'layerInfos');
my $first_token = join('||', @{$output->{data}->[0]});
like($first_token, qr/s:Autobiographische/, 'data');
like($first_token, qr/_0#0-17/, 'data');
like($first_token, qr!<>:base/s:s#0-30\$<i>2<b>2!, 'data');
like($first_token, qr!<>:base\/s:t#0-35199\$<i>5226<b>0!, 'data');

## OpenNLP
$tokens->add('OpenNLP', 'Sentences');

$output = decode_json( $tokens->to_json );
is($output->{foundries},
   'base base/paragraphs base/sentences opennlp opennlp/sentences',
   'Foundries');
is($output->{layerInfos}, 'base/s=spans opennlp/s=spans', 'layerInfos');
$first_token = join('||', @{$output->{data}->[0]});
like($first_token, qr!<>:opennlp/s:s#0-254\$<i>32!, 'data');

$tokens->add('OpenNLP', 'Morpho');
$output = decode_json( $tokens->to_json );
is($output->{foundries},
   'base base/paragraphs base/sentences opennlp opennlp/morpho opennlp/sentences',
   'Foundries');
is($output->{layerInfos}, 'base/s=spans opennlp/p=tokens opennlp/s=spans', 'layerInfos');
$first_token = join('||', @{$output->{data}->[0]});
like($first_token, qr!opennlp/p:ADJA!, 'data');

## Treetagger
$tokens->add('TreeTagger', 'Sentences');
$output = decode_json( $tokens->to_json );
is($output->{foundries},
   'base base/paragraphs base/sentences opennlp opennlp/morpho opennlp/sentences treetagger treetagger/sentences',
   'Foundries');
is($output->{layerInfos}, 'base/s=spans opennlp/p=tokens opennlp/s=spans tt/s=spans', 'layerInfos');
$first_token = join('||', @{$output->{data}->[0]});
like($first_token, qr!<>:tt/s:s#0-179\$<i>21<b>2!, 'data');

$tokens->add('TreeTagger', 'Morpho');
$output = decode_json( $tokens->to_json );
is($output->{foundries},
   'base base/paragraphs base/sentences opennlp opennlp/morpho opennlp/sentences treetagger treetagger/morpho treetagger/sentences',
   'Foundries');
is($output->{layerInfos}, 'base/s=spans opennlp/p=tokens opennlp/s=spans tt/l=tokens tt/p=tokens tt/s=spans', 'layerInfos');
$first_token = join('||', @{$output->{data}->[0]});
like($first_token, qr!tt/l:autobiographisch\$<b>165!, 'data');
like($first_token, qr!tt/p:ADJA\$<b>165!, 'data');
like($first_token, qr!tt/l:Autobiographische\$<b>89!, 'data');
like($first_token, qr!tt/p:NN\$<b>89!, 'data');

## CoreNLP
$tokens->add('CoreNLP', 'NamedEntities');
$output = decode_json( $tokens->to_json );
is($output->{foundries},
   'base base/paragraphs base/sentences corenlp corenlp/namedentities opennlp opennlp/morpho opennlp/sentences treetagger treetagger/morpho treetagger/sentences',
   'Foundries');
is($output->{layerInfos}, 'base/s=spans corenlp/ne=tokens opennlp/p=tokens opennlp/s=spans tt/l=tokens tt/p=tokens tt/s=spans', 'layerInfos');

diag "Missing test for NamedEntities";

# Problematic:
# diag Dumper $output->{data}->[180];
# diag Dumper $output->{data}->[341];

$tokens->add('CoreNLP', 'Sentences');
$output = decode_json( $tokens->to_json );
is($output->{foundries},
   'base base/paragraphs base/sentences corenlp corenlp/namedentities corenlp/sentences opennlp opennlp/morpho opennlp/sentences treetagger treetagger/morpho treetagger/sentences',
   'Foundries');
is($output->{layerInfos}, 'base/s=spans corenlp/ne=tokens corenlp/s=spans opennlp/p=tokens opennlp/s=spans tt/l=tokens tt/p=tokens tt/s=spans', 'layerInfos');
$first_token = join('||', @{$output->{data}->[0]});
like($first_token, qr!<>:corenlp/s:s#0-254\$<i>32!, 'data');

$tokens->add('CoreNLP', 'Morpho');
$output = decode_json( $tokens->to_json );
like($output->{foundries}, qr!corenlp/morpho!, 'Foundries');
like($output->{layerInfos}, qr!corenlp/p=tokens!, 'layerInfos');
$first_token = join('||', @{$output->{data}->[0]});
like($first_token, qr!corenlp/p:ADJA!, 'data');

$tokens->add('CoreNLP', 'Constituency');
$output = decode_json( $tokens->to_json );
like($output->{foundries}, qr!corenlp/constituency!, 'Foundries');
like($output->{layerInfos}, qr!corenlp/c=spans!, 'layerInfos');
$first_token = join('||', @{$output->{data}->[0]});

#           '<>:corenlp/c:ADJA#0-17$<i>1<b>0',
#           '<>:corenlp/c:NP#0-17$<i>1<b>0',
#           '<>:corenlp/c:CNP#0-17$<i>1<b>1',
#           '<>:corenlp/c:NP#0-17$<i>1<b>2',
#           '<>:corenlp/c:AP#0-17$<i>1<b>3',
#           '<>:corenlp/c:PP#0-58$<i>5<b>2',
#           '<>:corenlp/c:S#0-58$<i>5<b>3',
#           '<>:corenlp/c:ROOT#0-254$<i>32<b>0',
#           '<>:corenlp/c:S#0-254$<i>32<b>1',

#like($first_token, qr!<>:corenlp/c:ADJA#0-17$<i>1<b>0!, 'data');
#like($first_token, qr!<>:corenlp/c:NP#0-17$<i>1<b>0!, 'data');



diag Dumper $output->{data}->[0];


done_testing;
__END__


## Glemm
$tokens->add('Glemm', 'Morpho');
$output = decode_json( $tokens->to_json );
like($output->{foundries}, qr!glemm/morpho!, 'Foundries');
like($output->{layerInfos}, qr!glemm/l=tokens!, 'layerInfos');
$first_token = join('||', @{$output->{data}->[0]});
like($first_token, qr!glemm/l:__autobiographisch!, 'data');
like($first_token, qr!glemm/l:\+_Auto!, 'data');
like($first_token, qr!glemm/l:\+_biographisch!, 'data');
like($first_token, qr!glemm/l:\+\+Biograph!, 'data');
like($first_token, qr!glemm/l:\+\+-isch!, 'data');

## Connexor
$tokens->add('Connexor', 'Sentences');
$output = decode_json( $tokens->to_json );
like($output->{foundries}, qr!connexor/sentences!, 'Foundries');
like($output->{layerInfos}, qr!cnx/s=spans!, 'layerInfos');
$first_token = join('||', @{$output->{data}->[0]});
like($first_token, qr!<>:cnx/s:s#0-179\$<i>21<b>2!, 'data');

$tokens->add('Connexor', 'Morpho');
$output = decode_json( $tokens->to_json );
like($output->{foundries}, qr!connexor/morpho!, 'Foundries');
like($output->{layerInfos}, qr!cnx/p=tokens!, 'layerInfos');
like($output->{layerInfos}, qr!cnx/l=tokens!, 'layerInfos');
like($output->{layerInfos}, qr!cnx/m=tokens!, 'layerInfos');
$first_token = join('||', @{$output->{data}->[0]});
like($first_token, qr!cnx/l:autobiografisch!, 'data');
like($first_token, qr!cnx/p:A!, 'data');

$tokens->add('Connexor', 'Phrase');
$output = decode_json( $tokens->to_json );
like($output->{foundries}, qr!connexor/phrase!, 'Foundries');
like($output->{layerInfos}, qr!cnx/c=spans!, 'layerInfos');
$first_token = join('||', @{$output->{data}->[0]});
like($first_token, qr!<>:cnx/c:np#0-30\$<i>2!, 'data');

$tokens->add('Connexor', 'Syntax');
$output = decode_json( $tokens->to_json );
like($output->{foundries}, qr!connexor/syntax!, 'Foundries');
like($output->{layerInfos}, qr!cnx/syn=tokens!, 'layerInfos');
$first_token = join('||', @{$output->{data}->[0]});
like($first_token, qr!cnx/syn:\@PREMOD!, 'data');

## Mate
$tokens->add('Mate', 'Morpho');
$output = decode_json( $tokens->to_json );
like($output->{foundries}, qr!mate/morpho!, 'Foundries');
like($output->{layerInfos}, qr!mate/p=tokens!, 'layerInfos');
like($output->{layerInfos}, qr!mate/l=tokens!, 'layerInfos');
like($output->{layerInfos}, qr!mate/m=tokens!, 'layerInfos');
$first_token = join('||', @{$output->{data}->[0]});
like($first_token, qr!mate/l:autobiographisch!, 'data');
like($first_token, qr!mate/p:NN!, 'data');
like($first_token, qr!mate/m:case:nom!, 'data');
like($first_token, qr!mate/m:number:pl!, 'data');
like($first_token, qr!mate/m:gender:\*!, 'data');


fail("No test for mate dependency");

## XIP
$tokens->add('XIP', 'Sentences');
$output = decode_json( $tokens->to_json );
like($output->{foundries}, qr!xip/sentences!, 'Foundries');
like($output->{layerInfos}, qr!xip/s=spans!, 'layerInfos');
$first_token = join('||', @{$output->{data}->[0]});
like($first_token, qr!<>:xip/s:s#0-179\$<i>21!, 'data');

$tokens->add('XIP', 'Morpho');
$output = decode_json( $tokens->to_json );
like($output->{foundries}, qr!xip/morpho!, 'Foundries');
like($output->{layerInfos}, qr!xip/l=tokens!, 'layerInfos');
like($output->{layerInfos}, qr!xip/p=tokens!, 'layerInfos');
$first_token = join('||', @{$output->{data}->[0]});
like($first_token, qr!<>:xip/s:s#0-179\$<i>21!, 'data');


# print timestr(timediff(Benchmark->new, $t));
# 57.6802 wallclock secs (57.15 usr +  0.12 sys = 57.27 CPU)# $VAR1 = [
# 55.026 wallclock secs (54.44 usr +  0.10 sys = 54.54 CPU)# $VAR1 = [
# 55.3887 wallclock secs (54.62 usr +  0.17 sys = 54.79 CPU)# $VAR1 = [
# 54.9578 wallclock secs (54.51 usr +  0.13 sys = 54.64 CPU)# $VAR1 = [
# 53.7051 wallclock secs (53.42 usr +  0.11 sys = 53.53 CPU)# $VAR1 = [
# 47.6566 wallclock secs (46.88 usr +  0.15 sys = 47.03 CPU)# $VAR1 = [
# 47.2379 wallclock secs (46.60 usr +  0.11 sys = 46.71 CPU)# $VAR1 = [
# 29.563 wallclock secs (29.37 usr +  0.10 sys = 29.47 CPU)# $VAR1 = [
# 30.9321 wallclock secs (30.69 usr +  0.14 sys = 30.83 CPU)# $VAR1 = [

$tokens->add('XIP', 'Constituency');
$output = decode_json( $tokens->to_json );
like($output->{foundries}, qr!xip/constituency!, 'Foundries');
like($output->{layerInfos}, qr!xip/c=spans!, 'layerInfos');
$first_token = join('||', @{$output->{data}->[0]});
like($first_token, qr!<>:xip/c:NP#0-17\$<i>1<b>1!, 'data');
like($first_token, qr!<>:xip/c:AP#0-17\$<i>1<b>2!, 'data');
like($first_token, qr!<>:xip/c:ADJ#0-17\$<i>1<b>3!, 'data');
like($first_token, qr!<>:xip/c:TOP#0-179\$<i>21<b>0!, 'data');

diag Dumper $output->{data}->[0];


done_testing;
__END__
