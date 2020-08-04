package KorAP::XML::Tokenizer::Span;
use strict;
use warnings;
use Mojo::DOM;
use Clone;

use constant {
  O_START   => 0,
  O_END     => 1,
  P_START   => 2,
  P_END     => 3,
  ID        => 4,
  CONTENT   => 5,
  DOM       => 6,
  HASH      => 7,
  MILESTONE => 8,
  PTI       => 9
};

sub new {
  bless [], shift;
};

sub type {
  'span';
};

sub set_o_start {
  $_[0]->[O_START] = $_[1];
};

sub get_o_start {
  $_[0]->[O_START]
};

sub set_o_end {
  $_[0]->[O_END] = $_[1];
};

sub get_o_end {
  $_[0]->[O_END]
};

sub set_p_start {
  $_[0]->[P_START] = $_[1];
};

sub get_p_start {
  $_[0]->[P_START]
};

sub set_p_end {
  $_[0]->[P_END] = $_[1];
};

sub get_p_end {
  $_[0]->[P_END];
};

sub set_id {
  $_[0]->[ID] = $_[1];
};

sub get_id {
  $_[0]->[ID];
};

sub set_content {
  $_[0]->[CONTENT] = $_[1];
};

sub get_content {
  $_[0]->[CONTENT];
};

sub dom {
  if ($_[0]->[DOM]) {
    return $_[0]->[DOM];
  }
  else {
    my $c = Mojo::DOM->new($_[0]->[CONTENT]);
    $c->xml(1);
    return $_[0]->[DOM] = $c;
  };
};

sub set_hash {
  $_[0]->[HASH] = $_[1];
};

sub get_hash {
  return $_[0]->[HASH];
};

sub set_milestone {
  $_[0]->[MILESTONE] = 1;
};

sub get_milestone {
  $_[0]->[MILESTONE] ? 1 : 0;
};

sub set_pti {
  $_[0]->[PTI] = $_[1];
};

sub get_pti {
  $_[0]->[PTI];
};

sub to_string {
  my $v = shift;
  {
    no warnings;
    return '[(' . $v->[O_START] . ':' . $v->[O_END] . '|' .
      $v->[P_START] . ':' . $v->[P_END] . ')' .
      $v->[ID] . '-' .$v->[CONTENT] . ']';
  };
};

# Clone the span
sub clone {
  # TODO:
  #   Optionally clone without DOM and treat hash specially
  return Clone::clone(shift);
};


1;
