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
       'Annotation (OpenNLP/p) is correct: ' . $_
     );
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
ok($tokens = new_tokenizer->parse, 'Parse');

# Add CoreNLP/NamedEntities
ok($tokens->add('CoreNLP', 'NamedEntities', 'ne_dewac_175m_600'), 'Add CoreNLP/NamedEntities');
ok($tokens->add('CoreNLP', 'NamedEntities', 'ne_hgc_175m_600'), 'Add CoreNLP/NamedEntities');

is($tokens->stream->pos(9)->to_string,
   '[(64-73)s:Hofbergli|i:hofbergli|_9#64-73|corenlp/ne_dewac_175m_600:I-LOC|corenlp/ne_hgc_175m_600:I-LOC]',
   'Correct NamedEntities annotation');


# New instantiation
ok($tokens = new_tokenizer->parse, 'Parse');

# Add CoreNLP/Morpho
ok($tokens->add('CoreNLP', 'Morpho'), 'Add CoreNLP/Morpho');

is($tokens->stream->pos(0)->to_string,
   '[(0-3)s:Zum|i:zum|_0#0-3|-:tokens$<i>18|corenlp/p:APPRART]',
   'Correct corenlp annotation');

$i = 0;
foreach (qw/APPRART ADJ ADJA NN VVFIN ART NN ART NN NE PTKVZ KOUS ART NN NN NN VVPP VAFIN/) {
  like($tokens->stream->pos($i++)->to_string,
       qr!\|corenlp/p:$_!,
       'Annotation (CoreNLP/p) is correct: '. $_);
};

# Add CoreNLP/Sentences
ok($tokens->add('CoreNLP', 'Sentences'), 'Add CoreNLP/Sentences');

is($tokens->stream->pos(0)->to_string,
   '[(0-3)s:Zum|i:zum|_0#0-3|-:tokens$<i>18|corenlp/p:APPRART|<>:corenlp/s#0-129$<i>17|-:corenlp/sentences$<i>1]',
   'Correct corenlp annotation');


# New instantiation
ok($tokens = new_tokenizer->parse, 'New Tokenizer');

# Add CoreNLP/Sentences
ok($tokens->add('Connexor', 'Sentences'), 'Add Connexor/Sentences');

is($tokens->stream->pos(0)->to_string,
   '[(0-3)s:Zum|i:zum|_0#0-3|-:tokens$<i>18|<>:cnx/s#0-129$<i>17|-:cnx/sentences$<i>1]',
   'Correct cnx annotation');

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
like($stream->pos(1)->to_string, qr!\|<>:cnx/c:np#4-30\$<i>4!, 'Annotation (Connexor/c) is correct');
like($stream->pos(6)->to_string, qr!\|<>:cnx/c:np#40-47\$<i>7!, 'Annotation (Connexor/c) is correct');
like($stream->pos(8)->to_string, qr!\|<>:cnx/c:np#52-73\$<i>10!, 'Annotation (Connexor/c) is correct');
like($stream->pos(13)->to_string, qr!\|<>:cnx/c:np#89-111\$<i>16!, 'Annotation (Connexor/c) is correct');

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

is($tokens->stream->pos(0)->to_string, '[(0-3)s:Zum|i:zum|_0#0-3|-:tokens$<i>18|<>:xip/s#0-129$<i>17|-:xip/sentences$<i>1]', 'First sentence');

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
foreach ('zu', 'letzt', 'kulturell', 'Anlass', '=laden:laden', 'die', 'Leitung', 'der', '#schulen:#Heim:schulen#Heim', 'Hofbergli', 'ein', 'bevor', 'der', 'Betrieb', 'Ende', '#schulen:#Jahr:schulen#Jahr') {
  if ($_ eq '!') {
    $i++;
    next;
  };
  foreach my $f (split(':', $_)) {
    like($tokens->stream->pos($i)->to_string,
	 qr!\|xip/l:$f!,
	 'Annotation (xip/l) is correct: ' . $f);
  };
  $i++;
};

# New instantiation
ok($tokens = new_tokenizer->parse, 'New Tokenizer');

# Add XIP/Sentences
ok($tokens->add('XIP', 'Dependency'), 'Add XIP/Sentences');

$stream = $tokens->stream;
like($stream->pos(1)->to_string, qr!\|>:xip/d:NMOD\$<i>3!, 'Dependency fine');
like($stream->pos(3)->to_string, qr!\|<:xip/d:NMOD\$<i>1!, 'Dependency fine');
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
