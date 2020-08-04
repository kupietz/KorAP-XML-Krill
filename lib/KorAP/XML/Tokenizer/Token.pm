package KorAP::XML::Tokenizer::Token;
use strict;
use warnings;
use Mojo::DOM;

use constant {
  POS     => 0,
  CONTENT => 1,
  ID      => 2,
  DOM     => 3,
  HASH    => 4,
};

sub new {
  bless [], shift;
};

sub type {
  'token';
};

sub set_pos {
  $_[0]->[POS] = $_[1];
};

sub get_pos {
  $_[0]->[POS];
};

sub set_content {
  $_[0]->[CONTENT] = $_[1];
};

sub get_content {
  $_[0]->[CONTENT];
};

sub set_id {
  $_[0]->[ID] = $_[1];
};

sub get_id {
  $_[0]->[ID];
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
  return $_[0]->[HASH] = $_[1];
};

sub get_hash {
  return $_[0]->[HASH];
};


sub to_string {
  my $v = shift;
  {
    no warnings;
    return '[(' . $v->[POS] . ')' .
      $v->[CONTENT] . '-' . $v->[ID] . ']';
  };
};


1;
