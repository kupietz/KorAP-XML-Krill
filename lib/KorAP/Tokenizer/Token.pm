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
  if (defined $_[1]) {
    $_[0]->[1] = $_[1];
  }
  else {
    return $_[0]->[1];
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

sub dom {
  if ($_[0]->[3]) {
    return $_[0]->[3];
  }
  else {
    my $c = Mojo::DOM->new($_[0]->[1]);
    $c->xml(1);
    return $_[0]->[3] = $c;
  };
};

sub hash {
  if (defined $_[1]) {
    $_[0]->[4] = $_[1];
  }
  else {
    return $_[0]->[4];
  };
};


1;