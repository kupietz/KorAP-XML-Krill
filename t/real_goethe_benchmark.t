#!/usr/bin/env perl
# source ~/perl5/perlbrew/etc/bashrc
# perlbrew switch perl-blead@korap
use strict;
use warnings;
use Mojo::ByteStream 'b';
use Devel::Cycle;
use Memory::Stats;

use Benchmark qw/:hireswallclock/;

my $t = Benchmark->new;

use utf8;
use lib 'lib', '../lib';

use File::Basename 'dirname';
use File::Spec::Functions 'catdir';

# Tokenization
use KorAP::Tokenizer;
use KorAP::Document;

# my $stats = Memory::Stats->new;

#$stats->start;

# GOE/AGA/03828
#my $path = catdir(dirname(__FILE__), 'GOE/AGA/03828');
my $path = catdir(dirname(__FILE__), 'BZK/D59/00089');
# Todo: Test with absolute path!

# do something
#$stats->checkpoint(sprintf("%20s", "Init"));

my $doc = KorAP::Document->new( path => $path . '/' );
$doc->parse;
# $stats->checkpoint(sprintf("%20s", "After Parsing"));

my ($token_base_foundry, $token_base_layer) = (qw/OpenNLP Tokens/);

# Get tokenization
my $tokens = KorAP::Tokenizer->new(
  path => $doc->path,
  doc => $doc,
  foundry => $token_base_foundry,
  layer => $token_base_layer,
  name => 'tokens'
);
$tokens->parse;
#$stats->checkpoint(sprintf("%20s", "After Tokenization"));

$tokens->add('Base', 'Sentences');
#$stats->checkpoint(sprintf("%20s", "After Base/Sentences"));

$tokens->add('Base', 'Paragraphs');
#$stats->checkpoint(sprintf("%20s", "After Base/Paragraphs"));

$tokens->add('OpenNLP', 'Sentences');
#$stats->checkpoint(sprintf("%20s", "After OpenNLP/Sentences"));

$tokens->add('OpenNLP', 'Morpho');
#$stats->checkpoint(sprintf("%20s", "After OpenNLP/Morpho"));

$tokens->add('TreeTagger', 'Sentences');
#$stats->checkpoint(sprintf("%20s", "After TT/Sentences"));

$tokens->add('TreeTagger', 'Morpho');
#$stats->checkpoint(sprintf("%20s", "After TT/Morpho"));

$tokens->add('CoreNLP', 'Sentences');
#$stats->checkpoint(sprintf("%20s", "After CoreNLP/Sentences"));

$tokens->add('CoreNLP', 'Constituency');
#$stats->checkpoint(sprintf("%20s", "After CoreNLP/Constituency"));

#$stats->stop;
#$stats->report;

$tokens->add('CoreNLP', 'NamedEntities');
$tokens->add('CoreNLP', 'Morpho');
$tokens->add('Glemm', 'Morpho');
# t ok($tokens->add('Connexor', 'Sentences'),    'Add cnx sentences');
# t ok($tokens->add('Connexor', 'Morpho'),       'Add cnx morpho');
# t ok($tokens->add('Connexor', 'Phrase'),       'Add cnx phrase');
# t ok($tokens->add('Connexor', 'Syntax'),       'Add cnx syntax');
$tokens->add('Mate', 'Morpho');
# $tokens->add('Mate', 'Dependency');
# t ok($tokens->add('XIP', 'Sentences'),         'Add xip sentences');
# t ok($tokens->add('XIP', 'Morpho'),            'Add xip morpho');
# t ok($tokens->add('XIP', 'Constituency'),      'Add xip constituency');
# $tokens->add('XIP', 'Dependency');
# ok($tokens->to_json, 'To json');

#b($tokens->to_json)->spurt('AGA-03828.json');
b($tokens->to_json)->spurt('D59-00089.json');

# timestr(timediff(Benchmark->new, $t));
