#!/usr/bin/env perl
# source ~/perl5/perlbrew/etc/bashrc
# perlbrew switch perl-blead@korap
use strict;
use warnings;
use Test::More;
use Mojo::ByteStream 'b';

use Benchmark qw/:hireswallclock/;

my $t = Benchmark->new;

use utf8;
use lib 'lib', '../lib';

use File::Basename 'dirname';
use File::Spec::Functions 'catdir';

use_ok('KorAP::Document');

# GOE/AGA/03828
my $path = catdir(dirname(__FILE__), 'GOE/AGA/03828');
# Todo: Test with absolute path!

ok(my $doc = KorAP::Document->new( path => $path . '/' ), 'Load Korap::Document');
ok($doc->parse, 'Parse document');

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

ok($tokens->add('Base', 'Sentences'),        'Add base sentences');
ok($tokens->add('Base', 'Paragraphs'),       'Add base paragraphs');
ok($tokens->add('OpenNLP', 'Sentences'),     'Add opennlp sentences');
ok($tokens->add('OpenNLP', 'Morpho'),        'Add opennlp morpho');
ok($tokens->add('TreeTagger', 'Sentences'),  'Add tt sentences');
ok($tokens->add('TreeTagger', 'Morpho'),     'Add tt morpho');
ok($tokens->add('CoreNLP', 'NamedEntities'), 'Add corenlp ne');
ok($tokens->add('CoreNLP', 'Sentences'),     'Add corenlp sentences');
ok($tokens->add('CoreNLP', 'Morpho'),        'Add corenlp morpho');
ok($tokens->add('CoreNLP', 'Constituency'),  'Add corenlp constituency');
ok($tokens->add('Glemm', 'Morpho'),          'Add glemm morpho');
# t ok($tokens->add('Connexor', 'Sentences'),    'Add cnx sentences');
# t ok($tokens->add('Connexor', 'Morpho'),       'Add cnx morpho');
# t ok($tokens->add('Connexor', 'Phrase'),       'Add cnx phrase');
# t ok($tokens->add('Connexor', 'Syntax'),       'Add cnx syntax');
ok($tokens->add('Mate', 'Morpho'),           'Add mate morpho');
# $tokens->add('Mate', 'Dependency');
# t ok($tokens->add('XIP', 'Sentences'),         'Add xip sentences');
# t ok($tokens->add('XIP', 'Morpho'),            'Add xip morpho');
# t ok($tokens->add('XIP', 'Constituency'),      'Add xip constituency');
# $tokens->add('XIP', 'Dependency');
ok($tokens->to_json, 'To json');

is($tokens->doc->to_hash->{title}, 'Autobiographische Einzelheiten');

b($tokens->to_json)->spurt('AGA.03828.json');

diag timestr(timediff(Benchmark->new, $t));
