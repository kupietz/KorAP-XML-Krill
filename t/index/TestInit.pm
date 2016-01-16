package TestInit;
use strict;
use warnings;
use File::Basename 'dirname';
use File::Spec::Functions 'catdir';
use KorAP::Tokenizer;
use KorAP::Document;

sub tokens {
  my $file = shift;
  my $path = catdir(dirname(__FILE__), 'corpus', 'doc', $file);

  my $doc = KorAP::Document->new(
    path => $path . '/'
  ) or return;

  $doc->parse;

  my $tokens = KorAP::Tokenizer->new(
    path => $doc->path,
    doc => $doc,
    foundry => 'OpenNLP',
    layer => 'Tokens',
    name => 'tokens'
  ) or return;

  $tokens->parse or return;

  return $tokens;
};

1;
