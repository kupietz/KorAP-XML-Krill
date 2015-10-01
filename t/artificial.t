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

# Tests for material identicality of a token
sub _t2h {
  my $string = shift;
  $string =~ s/^\[\(\d+?-\d+?\)(.+?)\]$/$1/;
  my %hash = ();
  foreach (split(qr!\|!, $string)) {
    $hash{$_} = 1;
  };
  return \%hash;
};


my $path = catdir(dirname(__FILE__), 'artificial');
ok(my $doc = KorAP::Document->new( path => $path . '/' ), 'Load Korap::Document');
like($doc->path, qr!$path/$!, 'Path');
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

is($tokens->doc->text_sigle, 'ART_ABC.00001', 'Doc id');
is($tokens->should, 20, 'Should');
is($tokens->have, 18, 'Have');
is($tokens->name, 'tokens', 'Name');
is($tokens->layer, 'Tokens', 'Layer');

is($tokens->stream->pos(0)->to_string, '[(0-3)-:tokens$<i>18|_0#0-3|i:zum|s:Zum]', 'Token is correct');

is($tokens->stream->pos(1)->to_string, '[(4-11)_1#4-11|i:letzten|s:letzten]', 'Token is correct');

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
       '_'.($i-1).'#'.$_->[0].'-'.$_->[1] . '|' .
	 'i:'.lc($_->[2]).'|s:'.$_->[2].']',
     'Token is correct');
};

ok(!$tokens->stream->pos($i++), 'No more tokens');

# Add OpenNLP/morpho
ok($tokens->add('OpenNLP', 'Morpho'), 'Add OpenNLP/Morpho');

$i = 0;
foreach (qw/APPRART ADJA ADJA NN VVFIN ART NN ART NN NE PTKVZ KOUS ART NN NN NN VVPP VAFIN/) {
  like($tokens->stream->pos($i++)->to_string,
       qr!\|opennlp/p:$_!,
       'Annotation (OpenNLP/p) is correct: ' . $_
     );
};

# Add OpenNLP/sentences
ok($tokens->add('OpenNLP', 'Sentences'), 'Add OpenNLP/Sentences');

is($tokens->stream->pos(0)->to_string,
   '[(0-3)-:opennlp/sentences$<i>1|-:tokens$<i>18|<>:opennlp/s:s#0-129$<i>17<b>0|_0#0-3|i:zum|opennlp/p:APPRART|s:Zum]',
   #   '[(0-3)-:opennlp/sentences$<i>1|-:tokens$<i>18|_0#0-3|i:zum|s:Zum|opennlp/p:APPRART|<>:opennlp/s:s#0-129$<i>17]',
   'Correct sentence'
 );

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

is_deeply(
  _t2h($tokens->stream->pos(0)->to_string),
  _t2h('[(0-3)-:base/paragraphs$<i>1|-:base/sentences$<i>1|-:tokens$<i>18|<>:base/s:t#0-129$<i>17<b>0|<>:base/s:p#0-129$<i>17<b>1|<>:base/s:s#0-129$<i>17<b>2|_0#0-3|i:zum|s:Zum]'),
   'Correct base annotation');

# New instantiation
ok($tokens = new_tokenizer->parse, 'Parse');

# Add CoreNLP/NamedEntities
ok($tokens->add('CoreNLP', 'NamedEntities', 'ne_dewac_175m_600'), 'Add CoreNLP/NamedEntities');
ok($tokens->add('CoreNLP', 'NamedEntities', 'ne_hgc_175m_600'), 'Add CoreNLP/NamedEntities');

# [(64-73)s:Hofbergli|i:hofbergli|_9#64-73|corenlp/ne_dewac_175m_600:I-LOC|corenlp/ne_hgc_175m_600:I-LOC]
is_deeply(
  _t2h($tokens->stream->pos(9)->to_string),
  _t2h('[(64-73)_9#64-73|corenlp/ne:I-LOC|i:hofbergli|s:Hofbergli]'),
  'Correct NamedEntities annotation'
);

# New instantiation
ok($tokens = new_tokenizer->parse, 'Parse');

# Add CoreNLP/Morpho
ok($tokens->add('CoreNLP', 'Morpho'), 'Add CoreNLP/Morpho');

is_deeply(
  _t2h($tokens->stream->pos(0)->to_string),
  _t2h('[(0-3)-:tokens$<i>18|_0#0-3|corenlp/p:APPRART|i:zum|s:Zum]'),
  'Correct corenlp annotation'
);

$i = 0;
foreach (qw/APPRART ADJ ADJA NN VVFIN ART NN ART NN NE PTKVZ KOUS ART NN NN NN VVPP VAFIN/) {
  like($tokens->stream->pos($i++)->to_string,
       qr!\|corenlp/p:$_!,
       'Annotation (CoreNLP/p) is correct: '. $_);
};


# Add CoreNLP/Sentences
ok($tokens->add('CoreNLP', 'Sentences'), 'Add CoreNLP/Sentences');

is_deeply(
  _t2h($tokens->stream->pos(0)->to_string),
  _t2h('[(0-3)-:corenlp/sentences$<i>1|-:tokens$<i>18|<>:corenlp/s:s#0-129$<i>17<b>0|_0#0-3|corenlp/p:APPRART|i:zum|s:Zum]'),
  #   '[(0-3)-:corenlp/sentences$<i>1|-:tokens$<i>18|_0#0-3|i:zum|s:Zum|corenlp/p:APPRART|<>:corenlp/s:s#0-129$<i>17]',
  'Correct corenlp annotation'
);

# New instantiation
ok($tokens = new_tokenizer->parse, 'New Tokenizer');

# Add CoreNLP/Sentences
ok($tokens->add('Connexor', 'Sentences'), 'Add Connexor/Sentences');

is_deeply(
  _t2h($tokens->stream->pos(0)->to_string),
  _t2h('[(0-3)-:cnx/sentences$<i>1|-:tokens$<i>18|<>:cnx/s:s#0-129$<i>17<b>0|_0#0-3|i:zum|s:Zum]'),
  #   '[(0-3)-:cnx/sentences$<i>1|-:tokens$<i>18|_0#0-3|i:zum|s:Zum|<>:cnx/s:s#0-129$<i>17<b>0]',
  'Correct cnx annotation'
);

# New instantiation
ok($tokens = new_tokenizer->parse, 'New Tokenizer');

# Add Connexor/Morpho
ok($tokens->add('Connexor', 'Morpho'), 'Add Connexor/Morpho');

$i = 0;
foreach (qw/! A A N V DET N DET N N NUM CS DET N N N V V/) {
  if ($_ eq '!') {
    $i++;
    next;
  };
  like($tokens->stream->pos($i++)->to_string,
       qr!\|cnx/p:$_!,
       'Annotation (Connexor/p) is correct: ' . $_);
};


$i = 0;
foreach (qw/! ! ! ! IND:PRES ! ! ! ! Prop ! ! ! ! ! ! PCP:PERF IND:PRES/) {
  if ($_ eq '!') {
    $i++;
    next;
  };
  foreach my $f (split(':', $_)) {
    like($tokens->stream->pos($i)->to_string,
	 qr!\|cnx/m:$f!,
	 'Annotation (Connexor/m) is correct: '. $f);
  };
  $i++;
};

# New instantiation
ok($tokens = new_tokenizer->parse, 'New Tokenizer');

# Add Connexor/Phrase
ok($tokens->add('Connexor', 'Phrase'), 'Add Connexor/Phrase');
my $stream = $tokens->stream;
like($stream->pos(1)->to_string, qr!<>:cnx/c:np#4-30\$<i>4<b>0!, 'Annotation (Connexor/c) is correct');
like($stream->pos(6)->to_string, qr!<>:cnx/c:np#40-47\$<i>7<b>0!, 'Annotation (Connexor/c) is correct');
like($stream->pos(8)->to_string, qr!<>:cnx/c:np#52-73\$<i>10<b>0!, 'Annotation (Connexor/c) is correct');
like($stream->pos(13)->to_string, qr!<>:cnx/c:np#89-111\$<i>16<b>0!, 'Annotation (Connexor/c) is correct');

# New instantiation
ok($tokens = new_tokenizer->parse, 'New Tokenizer');

# Add Connexor/Syntax
ok($tokens->add('Connexor', 'Syntax'), 'Add Connexor/Syntax');
$stream = $tokens->stream;

$i = 0;
foreach (qw/! @PREMOD @PREMOD @NH @MAIN @PREMOD @NH @PREMOD
	    @PREMOD @NH @NH @PREMARK @PREMOD @PREMOD @NH @NH @MAIN @AUX/) {
  if ($_ eq '!') {
    $i++;
    next;
  };
  like($tokens->stream->pos($i++)->to_string,
       qr!\|cnx/syn:$_!,
       'Annotation (Connexor/syn) is correct: ' . $_);
};

# New instantiation
ok($tokens = new_tokenizer->parse, 'New Tokenizer');

# Add XIP/Sentences
ok($tokens->add('XIP', 'Sentences'), 'Add XIP/Sentences');

is_deeply(
  _t2h($tokens->stream->pos(0)->to_string),
  _t2h('[(0-3)-:tokens$<i>18|-:xip/sentences$<i>1|<>:xip/s:s#0-129$<i>17<b>0|_0#0-3|i:zum|s:Zum]'),
  #   '[(0-3)-:tokens$<i>18|_0#0-3|i:zum|s:Zum|-:xip/sentences$<i>1|<>:xip/s:s#0-129$<i>17<b>0]',
  'First sentence'
);

# Add XIP/Morpho
ok($tokens->add('XIP', 'Morpho'), 'Add XIP/Morpho');
$stream = $tokens->stream;

$i = 0;
foreach (qw/PREP ADJ ADJ NOUN VERB DET NOUN DET NOUN NOUN PTCL CONJ DET NOUN NOUN NOUN VERB VERB/) {
  if ($_ eq '!') {
    $i++;
    next;
  };
  like($tokens->stream->pos($i++)->to_string,
       qr!\|xip/p:$_!,
       'Annotation (xip/p) is correct: ' . $_);
};

$i = 0;
foreach ('zu', 'letzt', 'kulturell', 'Anlass', '=laden:laden', 'die', 'Leitung', 'der', '\#schulen:\#Heim:schulen\#Heim', 'Hofbergli', 'ein', 'bevor', 'der', 'Betrieb', 'Ende', '\#schulen:\#Jahr:schulen\#Jahr') {
  if ($_ eq '!') {
    $i++;
    next;
  };
  foreach my $f (split(':', $_)) {
    like($tokens->stream->pos($i)->to_string,
	 qr!\|xip\/l:\Q$f\E!,
	 'Annotation (xip/l) is correct: ' . $f);
  };
  $i++;
};

# New instantiation
ok($tokens = new_tokenizer->parse, 'New Tokenizer');

# Add XIP/Sentences
ok($tokens->add('XIP', 'Dependency'), 'Add XIP/Dependency');

$stream = $tokens->stream;
diag $stream->pos(1)->to_string;

like($stream->pos(1)->to_string, qr![^<]>:xip/d:NMOD\$<i>3!, 'Dependency fine');
like($stream->pos(3)->to_string, qr![^<]<:xip/d:NMOD\$<i>1!, 'Dependency fine');

done_testing;
__END__


like($stream->pos(3)->to_string, qr!\|<:xip/d:NMOD\$<i>2!, 'Dependency fine');
like($stream->pos(4)->to_string, qr!\|>xip/d:VMAIN\$<i>4!, 'Dependency fine');
like($stream->pos(4)->to_string, qr!\|<:xip/d:SUBJ\$<i>6!, 'Dependency fine');
like($stream->pos(4)->to_string, qr!\|<:xip/d:VPREF\$<i>10!, 'Dependency fine');
like($stream->pos(5)->to_string, qr!\|>:xip/d:DETERM\$<i>6!, 'Dependency fine');
like($stream->pos(6)->to_string, qr!\|<:xip/d:DETERM\$<i>5!, 'Dependency fine');
like($stream->pos(6)->to_string, qr!\|>:xip/d:SUBJ\$<i>4!, 'Dependency fine');
like($stream->pos(6)->to_string, qr!\|<:xip/d:NMOD\$<i>8!, 'Dependency fine');
like($stream->pos(7)->to_string, qr!\|>:xip/d:DETERM\$<i>8!, 'Dependency fine');
like($stream->pos(8)->to_string, qr!\|<:xip/d:DETERM\$<i>7!, 'Dependency fine');
like($stream->pos(8)->to_string, qr!\|>:xip/d:NMOD\$<i>6!, 'Dependency fine');
like($stream->pos(8)->to_string, qr!\|<:xip/d:NMOD\$<i>9!, 'Dependency fine');
like($stream->pos(9)->to_string, qr!\|>:xip/d:NMOD\$<i>8!, 'Dependency fine');
like($stream->pos(10)->to_string, qr!\|>:xip/d:VPREF\$<i>4!, 'Dependency fine');
like($stream->pos(11)->to_string, qr!\|>:xip/d:CONNECT\$<i>16!, 'Dependency fine');
like($stream->pos(12)->to_string, qr!\|>:xip/d:DETERM\$<i>13!, 'Dependency fine');
like($stream->pos(13)->to_string, qr!\|<:xip/d:DETERM\$<i>12!, 'Dependency fine');
like($stream->pos(13)->to_string, qr!\|>:xip/d:SUBJ\$<i>16!, 'Dependency fine');
like($stream->pos(14)->to_string, qr!\|>:xip/d:OBJ\$<i>16!, 'Dependency fine');
like($stream->pos(15)->to_string, qr!\|>:xip/d:OBJ\$<i>16!, 'Dependency fine');
like($stream->pos(16)->to_string, qr!\|<:xip/d:CONNECT\$<i>11!, 'Dependency fine');
like($stream->pos(16)->to_string, qr!\|<:xip/d:SUBJ\$<i>13!, 'Dependency fine');
like($stream->pos(16)->to_string, qr!\|<:xip/d:OBJ\$<i>14!, 'Dependency fine');
like($stream->pos(16)->to_string, qr!\|<:xip/d:OBJ\$<i>15!, 'Dependency fine');
like($stream->pos(16)->to_string, qr!\|>:xip/d:AUXIL\$<i>17!, 'Dependency fine');
like($stream->pos(16)->to_string, qr!\|>xip/d:VMAIN\$<i>16!, 'Dependency fine');
like($stream->pos(16)->to_string, qr!\|<xip/d:VMAIN\$<i>16!, 'Dependency fine');
like($stream->pos(17)->to_string, qr!\|<:xip/d:AUXIL\$<i>16!, 'Dependency fine');

# New instantiation
ok($tokens = new_tokenizer->parse, 'New Tokenizer');

# Add XIP/Sentences
ok($tokens->add('XIP', 'Constituency'), 'Add XIP/Constituency');

$stream = $tokens->stream;
like($stream->pos(0)->to_string, qr!\|<>:xip/c:TOP#0-129\$<i>17!, 'Constituency fine');
like($stream->pos(0)->to_string, qr!\|<>:xip/c:MC#0-129\$<i>17<b>1!, 'Constituency fine');
like($stream->pos(0)->to_string, qr!\|<>:xip/c:PP#0-30\$<i>4<b>2!, 'Constituency fine');
like($stream->pos(0)->to_string, qr!\|<>:xip/c:PREP#0-3\$<i>1!, 'Constituency fine');

like($stream->pos(1)->to_string, qr!\|<>:xip/c:NP#4-30\$<i>4<b>3!, 'Constituency fine');
like($stream->pos(1)->to_string, qr!\|<>:xip/c:NPA#4-30\$<i>4<b>4!, 'Constituency fine');
like($stream->pos(1)->to_string, qr!\|<>:xip/c:AP#4-11\$<i>2<b>5!, 'Constituency fine');
like($stream->pos(1)->to_string, qr!\|<>:xip/c:ADJ#4-11\$<i>2<b>6!, 'Constituency fine');

like($stream->pos(2)->to_string, qr!\|<>:xip/c:AP#12-23\$<i>3<b>5!, 'Constituency fine');
like($stream->pos(2)->to_string, qr!\|<>:xip/c:ADJ#12-23\$<i>3<b>6!, 'Constituency fine');

like($stream->pos(3)->to_string, qr!\|<>:xip/c:NOUN#24-30\$<i>4<b>5!, 'Constituency fine');

like($stream->pos(4)->to_string, qr!\|<>:xip/c:VERB#31-35\$<i>5<b>2!, 'Constituency fine');

like($stream->pos(5)->to_string, qr!\|<>:xip/c:NP#36-47\$<i>7<b>2!, 'Constituency fine');
like($stream->pos(5)->to_string, qr!\|<>:xip/c:DET#36-39\$<i>6<b>3!, 'Constituency fine');

like($stream->pos(6)->to_string, qr!\|<>:xip/c:NPA#40-47\$<i>7<b>3!, 'Constituency fine');
like($stream->pos(6)->to_string, qr!\|<>:xip/c:NOUN#40-47\$<i>7<b>4!, 'Constituency fine');

like($stream->pos(7)->to_string, qr!\|<>:xip/c:NP#48-63\$<i>9<b>2!, 'Constituency fine');
like($stream->pos(7)->to_string, qr!\|<>:xip/c:DET#48-51\$<i>8<b>3!, 'Constituency fine');

like($stream->pos(8)->to_string, qr!\|<>:xip/c:NPA#52-63\$<i>9<b>3!, 'Constituency fine');
like($stream->pos(8)->to_string, qr!\|<>:xip/c:NOUN#52-63\$<i>9<b>4!, 'Constituency fine');

like($stream->pos(9)->to_string, qr!\|<>:xip/c:NP#64-73\$<i>10<b>2!, 'Constituency fine');
like($stream->pos(9)->to_string, qr!\|<>:xip/c:NPA#64-73\$<i>10<b>3!, 'Constituency fine');
like($stream->pos(9)->to_string, qr!\|<>:xip/c:NOUN#64-73\$<i>10<b>4!, 'Constituency fine');

like($stream->pos(10)->to_string, qr!\|<>:xip/c:PTCL#74-77\$<i>11<b>2!, 'Constituency fine');

like($stream->pos(11)->to_string, qr!\|<>:xip/c:SC#79-128\$<i>18!, 'Constituency fine');
like($stream->pos(11)->to_string, qr!\|<>:xip/c:CONJ#79-84\$<i>12<b>1!, 'Constituency fine');

like($stream->pos(12)->to_string, qr!\|<>:xip/c:NP#85-96\$<i>14<b>1!, 'Constituency fine');
like($stream->pos(12)->to_string, qr!\|<>:xip/c:DET#85-88\$<i>13<b>2!, 'Constituency fine');


like($stream->pos(13)->to_string, qr!\|<>:xip/c:NPA#89-96\$<i>14<b>2!, 'Constituency fine');
like($stream->pos(13)->to_string, qr!\|<>:xip/c:NOUN#89-96\$<i>14<b>3!, 'Constituency fine');

like($stream->pos(14)->to_string, qr!\|<>:xip/c:NP#97-101\$<i>15<b>1!, 'Constituency fine');
like($stream->pos(14)->to_string, qr!\|<>:xip/c:NPA#97-101\$<i>15<b>2!, 'Constituency fine');
like($stream->pos(14)->to_string, qr!\|<>:xip/c:NOUN#97-101\$<i>15<b>3!, 'Constituency fine');

like($stream->pos(15)->to_string, qr!\|<>:xip/c:NP#102-111\$<i>16<b>1!, 'Constituency fine');
like($stream->pos(15)->to_string, qr!\|<>:xip/c:NPA#102-111\$<i>16<b>2!, 'Constituency fine');
like($stream->pos(15)->to_string, qr!\|<>:xip/c:NOUN#102-111\$<i>16<b>3!, 'Constituency fine');

like($stream->pos(16)->to_string, qr!\|<>:xip/c:VERB#112-123\$<i>17<b>1!, 'Constituency fine');

like($stream->pos(17)->to_string, qr!\|<>:xip/c:VERB#124-128\$<i>18<b>1!, 'Constituency fine');

# diag $stream->to_string;


# ADJA ADJA NN VVFIN ART NN ART NN NE PTKVZ KOUS ART NN NN NN VVPP VAFIN
done_testing;
__END__


# Todo: CoreNLP/Constituency!





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


__END__
