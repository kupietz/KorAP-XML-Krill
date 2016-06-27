package TestInit;
use strict;
use warnings;
use File::Basename 'dirname';
use File::Spec::Functions 'catdir';
use KorAP::XML::Tokenizer;
use KorAP::XML::Krill;

sub tokens {
  my $file = shift;
  my $token_foundry = shift;
  my $path = catdir(dirname(__FILE__), 'corpus', 'doc', $file);

  my $doc = KorAP::XML::Krill->new(
    path => $path . '/'
  ) or return;

  $doc->parse;

  my $tokens = KorAP::XML::Tokenizer->new(
    path => $doc->path,
    doc => $doc,
    foundry => ($token_foundry // 'OpenNLP'),
    layer => 'Tokens',
    name => 'tokens'
  ) or return;

  $tokens->parse or return;

  return $tokens;
};

1;
