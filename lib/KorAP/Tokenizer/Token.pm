package KorAP::Tokenizer::Token;
use strict;
use warnings;
use Mojo::DOM;

sub new {
  bless [], shift;
};

sub pos {
  if (defined $_[1]) {
    $_[0]->[0] = $_[1];
  };
  $_[0]->[0];
};

sub content {
  if ($_[1]) {
    $_[0]->[1] = $_[1];
  }
  else {
    my $c = Mojo::DOM->new($_[0]->[1]);
    $c->xml(1);
    return $c;
  };
};

sub id {
  if ($_[1]) {
    $_[0]->[2] = $_[1];
  }
  else {
    $_[0]->[2];
  };
};

1;
