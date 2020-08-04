package KorAP::XML::Tokenizer::Span;
use strict;
use warnings;
use Mojo::DOM;
use Clone;

sub new {
  bless [], shift;
};

sub type {
  'span';
};

sub o_start {
  if (defined $_[1]) {
    $_[0]->[0] = $_[1];
  };
  $_[0]->[0];
};

sub set_o_start {
  $_[0]->[0] = $_[1];
};

sub o_end {
  if (defined $_[1]) {
    $_[0]->[1] = $_[1];
  };
  $_[0]->[1];
};

sub set_o_end {
  $_[0]->[1] = $_[1];
};

sub p_start {
  if (defined $_[1]) {
    $_[0]->[2] = $_[1];
  };
  $_[0]->[2];
};

sub set_p_start {
  $_[0]->[2] = $_[1];
};

sub p_end {
  if (defined $_[1]) {
    $_[0]->[3] = $_[1];
  };
  $_[0]->[3];
};

sub set_p_end {
  $_[0]->[3] = $_[1];
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


sub milestone {
  if (defined $_[1]) {
    $_[0]->[8] = 1;
  };
  $_[0]->[8] ? 1 : 0;
};


#sub tui {
#  if (defined $_[1]) {
#    $_[0]->[9] = $_[1];
#  };
#  $_[0]->[9];
#};

sub pti {
  if (defined $_[1]) {
    $_[0]->[10] = $_[1];
  };
  $_[0]->[10];
};


sub to_string {
  my $v = shift;
  {
    no warnings;
    return '[(' . $v->[0] . ':' . $v->[1] . '|' .
      $v->[2] . ':' . $v->[3] . ')' .
      $v->[4] . '-' .$v->[5] . ']';
  };
};


# Clone the span
sub clone {
  return Clone::clone(shift);
};


1;
