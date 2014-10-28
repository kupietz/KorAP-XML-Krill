#!/usr/bin/env perl
# source ~/perl5/perlbrew/etc/bashrc
# perlbrew switch perl-blead@korap
use strict;
use warnings;
use utf8;
use Test::More;
use JSON::XS;
use Benchmark ':hireswallclock';
use lib 'lib', '../lib';

use File::Basename 'dirname';
use File::Spec::Functions 'catdir';

use_ok('KorAP::Document');

my @layers;
# push(@layers, ['Base', 'Sentences']);
push(@layers, ['Base', 'Paragraphs']);

# OpenNLP
push(@layers, ['OpenNLP', 'Morpho']);
push(@layers, ['OpenNLP', 'Sentences']);

# CoreNLP
push(@layers, ['CoreNLP', 'NamedEntities', 'ne_dewac_175m_600']);
push(@layers, ['CoreNLP', 'NamedEntities', 'ne_hgc_175m_600']);
push(@layers, ['CoreNLP', 'Sentences']);

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


my $path = catdir(dirname(__FILE__), 'WPD/00001');
ok(my $doc = KorAP::Document->new( path => $path . '/' ), 'Load Korap::Document');
is($doc->path, $path . '/', 'Path');

ok($doc = KorAP::Document->new( path => $path ), 'Load Korap::Document');
is($doc->path, $path . '/', 'Path');

ok($doc->parse, 'Parse document');

# Metdata
is($doc->title, 'A', 'title');
ok(!$doc->sub_title, 'subTitle');

is($doc->text_sigle, 'WPD_AAA.00001', 'ID');
is($doc->corpus_sigle, 'WPD', 'corpusID');
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
is($tokens->doc->text_sigle, 'WPD_AAA.00001', 'Doc id');
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

is($tokens->stream->pos(0)->to_string, '[(0-1)s:A|i:a|_0#0-1|-:tokens$<i>923|mate/p:XY|<>:base/s:s#0-74$<i>13|<>:base/s:t#0-6083$<i>923|-:base/sentences$<i>96]', 'Startinfo');

foreach (@layers) {
  ok($tokens->add(@$_), 'Add '. join(', ', @$_));
};

is($tokens->stream->pos(0)->to_string, '[(0-1)s:A|i:a|_0#0-1|-:tokens$<i>923|mate/p:XY|<>:base/s:s#0-74$<i>13|<>:base/s:t#0-6083$<i>923|-:base/sentences$<i>96|<>:base/s:p#0-224$<i>34|-:base/paragraphs$<i>76|opennlp/p:NE|<>:opennlp/s:s#0-74$<i>13|-:opennlp/sentences$<i>50|<>:corenlp/s:s#0-6$<i>2|-:corenlp/sentences$<i>65|cnx/l:A|cnx/p:N|cnx/syn:@NH|<>:cnx/c:np#0-1$<i>1|<>:cnx/s:s#0-74$<i>13|-:cnx/sentences$<i>62|tt/l:A|tt/p:NN|tt/l:A|tt/p:FM|<>:tt/s:s#0-6083$<i>923|-:tt/sentences$<i>1|>:mate/d:PNC$<i>2|xip/p:SYMBOL|xip/l:A|<>:xip/c:TOP#0-74$<i>13|<>:xip/c:MC#0-73$<i>13<b>1|<>:xip/c:NP#0-1$<i>1<b>2|<>:xip/c:NPA#0-1$<i>1<b>3|<>:xip/c:NOUN#0-1$<i>1<b>4|<>:xip/c:SYMBOL#0-1$<i>1<b>5|>:xip/d:SUBJ$<i>3|<:xip/d:COORD$<i>1|<>:xip/s:s#0-74$<i>13|-:xip/sentences$<i>64]', 'Startinfo');


#is($tokens->stream->pos(118)->to_string,
#   '[(763-768)s:Linie|i:linie|_118#763-768|'.
#     'mate/l:linie|mate/p:NN|mate/m:case:acc|mate/m:number:sg|mate/m:gender:fem|' .
#     'opennlp/p:NN|'.
#     'cnx/l:linie|cnx/p:N|cnx/syn:@NH|'.
#     'tt/l:Linie|tt/p:NN|'.
#     '<:mate/d:NK$<i>116|<:mate/d:NK$<i>117|>:mate/d:NK$<i>115|'.
#     'xip/p:NOUN|xip/l:Linie|<>:xip/c:NOUN#763-768$<i>119|<:xip/d:DETERM$<i>116|<:xip/d:NMOD$<i>117]', 'with All');

#[(763-768)s:Linie|i:linie|_118#763-768|mate/l:linie|mate/p:NN|mate/m:case:acc|mate/m:number:sg|mate/m:gender:fem|opennlp/p:NN|cnx/l:linie|cnx/p:N|cnx/syn:@NH|tt/l:Linie|tt/p:NN|<:mate/d:NK$<i>116|<:mate/d:NK$<i>117|>:mate/d:NK$<i>115|
#      xip/p:NOUN|xip/l:Linie|<:xip/d:DETERM$<i>116|<:xip/d:NMOD$<i>117]

is($tokens->layer_info, 'cnx/c=const cnx/l=lemma cnx/m=msd cnx/p=pos mate/d=dep mate/l=lemma mate/m=msd mate/p=pos opennlp/p=pos tt/l=lemma tt/p=pos xip/c=const xip/d=dep xip/l=lemma xip/p=pos', 'Layer info');

is($tokens->support, 'base base/paragraphs base/sentences connexor connexor/morpho connexor/phrase connexor/sentences connexor/syntax corenlp corenlp/namedentities corenlp/namedentities corenlp/namedentities/ne_dewac_175m_600 corenlp/namedentities/ne_hgc_175m_600 corenlp/sentences mate mate/dependency mate/morpho opennlp opennlp/morpho opennlp/sentences treetagger treetagger/morpho treetagger/sentences xip xip/constituency xip/dependency xip/morpho xip/sentences', 'Support');




# encode_json $tokens->stream->to_solr;

done_testing;





__END__
