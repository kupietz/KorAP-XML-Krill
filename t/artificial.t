#!/usr/bin/env perl
# source ~/perl5/perlbrew/etc/bashrc
# perlbrew switch perl-blead@korap
use strict;
use warnings;
use utf8;
use Test::More;
use Benchmark ':hireswallclock';
use lib 'lib', '../lib';
use Scalar::Util qw/weaken/;

use File::Basename 'dirname';
use File::Spec::Functions 'catdir';

use_ok('KorAP::Document');

my $path = catdir(dirname(__FILE__), 'artificial');
ok(my $doc = KorAP::Document->new( path => $path . '/' ), 'Load Korap::Document');
is($doc->path, $path . '/', 'Path');
ok($doc->parse, 'Parse document');

sub new_tokenizer {
  my $x = $doc;
  weaken $x;
  return KorAP::Tokenizer->new(
    path => $x->path,
    doc => $x,
    foundry => 'OpenNLP',
    layer => 'Tokens',
    name => 'tokens'
  )
};

is($doc->primary->data,
   'Zum letzten kulturellen Anlass lädt die Leitung des Schulheimes Hofbergli ein, '.
     'bevor der Betrieb Ende Schuljahr eingestellt wird.', 'Primary data');

is($doc->primary->data_length, 129, 'Primary data length');

is($doc->primary->data(0,3), 'Zum', 'Get primary data');

# Get tokens
use_ok('KorAP::Tokenizer');
# Get tokenization
ok(my $tokens = KorAP::Tokenizer->new(
  path => $doc->path,
  doc => $doc,
  foundry => 'OpenNLP',
  layer => 'Tokens',
  name => 'tokens'
), 'New Tokenizer');
ok($tokens->parse, 'Parse');

is($tokens->foundry, 'OpenNLP', 'Foundry');

is($tokens->doc->id, 'ART_00001', 'Doc id');
is($tokens->should, 20, 'Should');
is($tokens->have, 18, 'Have');
is($tokens->name, 'tokens', 'Name');
is($tokens->layer, 'Tokens', 'Layer');

is($tokens->stream->pos(0)->to_string, '[(0-3)s:Zum|i:zum|_0#0-3|-:tokens$<i>18]', 'Token is correct');
is($tokens->stream->pos(1)->to_string, '[(4-11)s:letzten|i:letzten|_1#4-11]', 'Token is correct');

my $i = 2;
foreach ([12,23, 'kulturellen'],
	 [24,30, 'Anlass'],
	 [31,35, 'lädt'],
	 [36,39, 'die'],
	 [40,47, 'Leitung'],
	 [48,51, 'des'],
	 [52,63, 'Schulheimes'],
	 [64,73, 'Hofbergli'],
	 [74,77, 'ein'],
	 [79,84, 'bevor'],
	 [85,88, 'der'],
	 [89,96, 'Betrieb'],
	 [97,101, 'Ende'],
	 [102,111, 'Schuljahr'],
	 [112,123, 'eingestellt'],
	 [124,128, 'wird']
       ) {
  is($tokens->stream->pos($i++)->to_string,
     '[('.$_->[0].'-'.$_->[1].')'.
       's:'.$_->[2].'|i:'.lc($_->[2]).'|'.
       '_'.($i-1).'#'.$_->[0].'-'.$_->[1].']',
     'Token is correct');
};

ok(!$tokens->stream->pos($i++), 'No more tokens');

# Add OpenNLP/morpho
ok($tokens->add('OpenNLP', 'Morpho'), 'Add OpenNLP/Morpho');

$i = 0;
foreach (qw/APPRART ADJA ADJA NN VVFIN ART NN ART NN NE PTKVZ KOUS ART NN NN NN VVPP VAFIN/) {
  like($tokens->stream->pos($i++)->to_string,
       qr!\|opennlp/p:$_!,
       'Annotation (OpenNLP) is correct');
};

# Add OpenNLP/sentences
ok($tokens->add('OpenNLP', 'Sentences'), 'Add OpenNLP/Sentences');

is($tokens->stream->pos(0)->to_string, '[(0-3)s:Zum|i:zum|_0#0-3|-:tokens$<i>18|opennlp/p:APPRART|<>:opennlp/s#0-129$<i>17|-:opennlp/sentences$<i>1]', 'Correct sentence');


# New instantiation
ok($tokens = KorAP::Tokenizer->new(
  path => $doc->path,
  doc => $doc,
  foundry => 'OpenNLP',
  layer => 'Tokens',
  name => 'tokens'
), 'New Tokenizer');

ok($tokens->parse, 'Parse');

# Add OpenNLP/sentences
ok($tokens->add('Base', 'Sentences'), 'Add Base/Sentences');

# Add OpenNLP/sentences
ok($tokens->add('Base', 'Paragraphs'), 'Add Base/Paragraphs');

is($tokens->stream->pos(0)->to_string,
   '[(0-3)s:Zum|i:zum|_0#0-3|-:tokens$<i>18|<>:base/s#0-129$<i>17|<>:base/text#0-129$<i>17|-:base/sentences$<i>1|-:base/paragraphs$<i>0]',
   'Correct base annotation');


# New instantiation
ok($tokens = new_tokenizer, 'New Tokenizer');

ok($tokens->parse, 'Parse');

# Add CoreNLP/NamedEntities
ok($tokens->add('CoreNLP', 'NamedEntities', 'ne_dewac_175m_600'), 'Add CoreNLP/NamedEntities');
ok($tokens->add('CoreNLP', 'NamedEntities', 'ne_hgc_175m_600'), 'Add CoreNLP/NamedEntities');

is($tokens->stream->pos(9)->to_string,
   '[(64-73)s:Hofbergli|i:hofbergli|_9#64-73|corenlp/ne_dewac_175m_600:I-LOC|corenlp/ne_hgc_175m_600:I-LOC]',
   'Correct NamedEntities annotation');


# New instantiation
ok($tokens = new_tokenizer, 'New Tokenizer');
ok($tokens->parse, 'Parse');

# Add CoreNLP/Morpho
ok($tokens->add('CoreNLP', 'Morpho'), 'Add CoreNLP/Morpho');

is($tokens->stream->pos(0)->to_string,
   '[(0-3)s:Zum|i:zum|_0#0-3|-:tokens$<i>18|corenlp/p:APPRART]',
   'Correct corenlp annotation');

$i = 0;
foreach (qw/APPRART ADJ ADJA NN VVFIN ART NN ART NN NE PTKVZ KOUS ART NN NN NN VVPP VAFIN/) {
  like($tokens->stream->pos($i++)->to_string,
       qr!\|corenlp/p:$_!,
       'Annotation (CoreNLP) is correct');
};

# Add CoreNLP/Sentences
ok($tokens->add('CoreNLP', 'Sentences'), 'Add CoreNLP/Sentences');

is($tokens->stream->pos(0)->to_string,
   '[(0-3)s:Zum|i:zum|_0#0-3|-:tokens$<i>18|corenlp/p:APPRART|<>:corenlp/s#0-129$<i>17|-:corenlp/sentences$<i>1]',
   'Correct corenlp annotation');


# New instantiation
ok($tokens = new_tokenizer, 'New Tokenizer');
ok($tokens->parse, 'Parse');

# Add CoreNLP/Sentences
ok($tokens->add('Connexor', 'Sentences'), 'Add Connexor/Sentences');

is($tokens->stream->pos(0)->to_string,
   '[(0-3)s:Zum|i:zum|_0#0-3|-:tokens$<i>18|<>:cnx/s#0-129$<i>17|-:cnx/sentences$<i>1]',
   'Correct cnx annotation');



# Todo: CoreNLP/Constituency!
# Todo: Connexor/Morpho
# Todo: Connexor/Phrase
# Todo: Connexor/Syntax


done_testing;
__END__



# Connexor
push(@layers, ['Connexor', 'Morpho']);
push(@layers, ['Connexor', 'Syntax']);
push(@layers, ['Connexor', 'Phrase']);
push(@layers, ['Connexor', 'Sentences']);

# TreeTagger
push(@layers, ['TreeTagger', 'Morpho']);
push(@layers, ['TreeTagger', 'Sentences']);

# Mate
# push(@layers, ['Mate', 'Morpho']);
push(@layers, ['Mate', 'Dependency']);

# XIP
push(@layers, ['XIP', 'Morpho']);
push(@layers, ['XIP', 'Constituency']);
push(@layers, ['XIP', 'Dependency']);
push(@layers, ['XIP', 'Sentences']);



# Metdata
is($doc->title, 'A', 'title');
ok(!$doc->sub_title, 'subTitle');

is($doc->id, 'WPD_AAA.00001', 'ID');
is($doc->corpus_id, 'WPD', 'corpusID');
is($doc->pub_date, '20050328', 'pubDate');
is($doc->pub_place, 'URL:http://de.wikipedia.org', 'pubPlace');
is($doc->text_class->[0], 'freizeit-unterhaltung', 'TextClass');
is($doc->text_class->[1], 'reisen', 'TextClass');
is($doc->text_class->[2], 'wissenschaft', 'TextClass');
is($doc->text_class->[3], 'populaerwissenschaft', 'TextClass');
ok(!$doc->text_class->[4], 'TextClass');
is($doc->author->[0], 'Ruru', 'author');
is($doc->author->[1], 'Jens.Ol', 'author');
is($doc->author->[2], 'Aglarech', 'author');
ok(!$doc->author->[3], 'author');

# Get tokens
use_ok('KorAP::Tokenizer');
# Get tokenization
ok(my $tokens = KorAP::Tokenizer->new(
  path => $doc->path,
  doc => $doc,
  foundry => 'OpenNLP',
  layer => 'Tokens',
  name => 'tokens'
), 'New Tokenizer');
ok($tokens->parse, 'Parse');

is($tokens->path, $path . '/', 'Path');
is($tokens->foundry, 'OpenNLP', 'Foundry');
is($tokens->doc->id, 'WPD_AAA.00001', 'Doc id');
is($tokens->should, 1068, 'Should');
is($tokens->have, 923, 'Have');
is($tokens->name, 'tokens', 'Name');
is($tokens->layer, 'Tokens', 'Layer');

is($tokens->stream->pos(118)->to_string, '[(763-768)s:Linie|i:linie|_118#763-768]', 'Token is correct');

# Add Mate
ok($tokens->add('Mate', 'Morpho'), 'Add Mate');

is($tokens->stream->pos(118)->to_string, '[(763-768)s:Linie|i:linie|_118#763-768|mate/l:linie|mate/p:NN|mate/m:case:acc|mate/m:number:sg|mate/m:gender:fem]', 'with Mate');

# Add sentences
ok($tokens->add('Base', 'Sentences'), 'Add Sentences');

is($tokens->stream->pos(0)->to_string, '[(0-1)s:A|i:a|_0#0-1|-:tokens$<i>923|mate/p:XY|<>:base/s#0-74$<i>13|<>:base/text#0-6083$<i>923|-:sentences$<i>96]', 'Startinfo');

foreach (@layers) {
  ok($tokens->add(@$_), 'Add '. join(', ', @$_));
};

is($tokens->stream->pos(0)->to_string, '[(0-1)s:A|i:a|_0#0-1|-:tokens$<i>923|mate/p:XY|<>:base/s#0-74$<i>13|<>:base/text#0-6083$<i>923|-:sentences$<i>96|<>:base/para#0-224$<i>34|-:paragraphs$<i>76|opennlp/p:NE|<>:opennlp/s#0-74$<i>13|<>:corenlp/s#0-6$<i>2|cnx/l:A|cnx/p:N|cnx/syn:@NH|<>:cnx/s#0-74$<i>13|tt/l:A|tt/p:NN|tt/l:A|tt/p:FM|<>:tt/s#0-6083$<i>923|>:mate/d:PNC$<i>2|xip/p:SYMBOL|xip/l:A|<>:xip/c:TOP#0-74$<i>13|<>:xip/c:MC#0-73$<i>13<b>1|>:xip/d:SUBJ$<i>3|<:xip/d:COORD$<i>1|<>:xip/s#0-74$<i>13]', 'Startinfo');


is($tokens->stream->pos(118)->to_string,
   '[(763-768)s:Linie|i:linie|_118#763-768|'.
     'mate/l:linie|mate/p:NN|mate/m:case:acc|mate/m:number:sg|mate/m:gender:fem|' .
     'opennlp/p:NN|'.
     'cnx/l:linie|cnx/p:N|cnx/syn:@NH|'.
     'tt/l:Linie|tt/p:NN|'.
     '<:mate/d:NK$<i>116|<:mate/d:NK$<i>117|>:mate/d:NK$<i>115|'.
     'xip/p:NOUN|xip/l:Linie|<>:xip/c:NOUN#763-768$<i>119|<:xip/d:DETERM$<i>116|<:xip/d:NMOD$<i>117]', 'with All');

is($tokens->layer_info, 'cnx/c=const cnx/l=lemma cnx/m=msd cnx/p=pos mate/d=dep mate/l=lemma mate/m=msd mate/p=pos opennlp/p=pos tt/l=lemma tt/p=pos xip/c=const xip/d=dep xip/l=lemma xip/p=pos', 'Layer info');

is($tokens->support, 'base base/paragraphs base/sentences connexor connexor/morpho connexor/phrase connexor/sentences connexor/syntax corenlp corenlp/namedentities corenlp/namedentities corenlp/namedentities/ne_dewac_175m_600 corenlp/namedentities/ne_hgc_175m_600 corenlp/sentences mate mate/dependency mate/morpho opennlp opennlp/morpho opennlp/sentences treetagger treetagger/morpho treetagger/sentences xip xip/constituency xip/dependency xip/morpho xip/sentences', 'Support');

done_testing;

__END__
