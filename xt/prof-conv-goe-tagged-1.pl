#!/usr/bin/env perl
use strict;
use warnings;
use FindBin;
use File::Basename 'dirname';
use File::Spec::Functions qw/catfile catdir rel2abs/;

# Run
# $ perl -d:NYTProf xt/prof-conv-goe-tagged-1.pl
# $ nytprofhtml --open

BEGIN {
  unshift @INC, "$FindBin::Bin/../lib";
};

use KorAP::XML::Krill;
use KorAP::XML::Tokenizer;
my $path = catdir(dirname(__FILE__), '..','t','real', 'corpus','GOE-TAGGED','AGA','03828');

my $doc = KorAP::XML::Krill->new(path => $path . '/');
$doc->parse;
my $meta = $doc->meta;
my $tokens = KorAP::XML::Tokenizer->new(
  path => $doc->path,
  doc => $doc,
  foundry => 'Base',
  layer => 'Tokens_conservative',
  name => 'tokens'
);
$tokens->parse;
$tokens->add('DeReKo', 'Structure', 'base_sentences_paragraphs');
$tokens->add('DRuKoLa', 'Morpho');
$tokens->to_data;
