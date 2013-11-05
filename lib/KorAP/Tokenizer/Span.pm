package KorAP::Tokenizer::Span;
use strict;
use warnings;
use Mojo::DOM;

sub new {
  bless [], shift;
};

sub o_start {
  if (defined $_[1]) {
    $_[0]->[0] = $_[1];
  };
  $_[0]->[0];
};

sub o_end {
  if (defined $_[1]) {
    $_[0]->[1] = $_[1];
  };
  $_[0]->[1];
};

sub p_start {
  if (defined $_[1]) {
    $_[0]->[2] = $_[1];
  };
  $_[0]->[2];
};

sub p_end {
  if (defined $_[1]) {
    $_[0]->[3] = $_[1];
  };
  $_[0]->[3];
};

sub id {
  if (defined $_[1]) {
    $_[0]->[4] = $_[1];
  };
  $_[0]->[4];
};

sub content {
  if (defined $_[1]) {
    $_[0]->[5] = $_[1];
  }
  else {
    return $_[0]->[5];
  };
};

sub dom {
  if ($_[0]->[6]) {
    return $_[0]->[6];
  }
  else {
    my $c = Mojo::DOM->new($_[0]->[5]);
    $c->xml(1);
    return $_[0]->[6] = $c;
  };
};

sub hash {
  if (defined $_[1]) {
    $_[0]->[7] = $_[1];
  }
  else {
    return $_[0]->[7];
  };
};

1;
