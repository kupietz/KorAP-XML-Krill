package KorAP::Tokenizer::Match;
use strict;
use warnings;

sub new {
  bless {}, shift;
};

sub set {
  $_[0]->{$_[1] . ':' . $_[2]} = $_[3];
  $_[0]->{'[' . $_[1]} = $_[3];
  $_[0]->{$_[2] . ']'} = $_[3];
};

sub lookup {
  $_[0]->{$_[1] . ':' . $_[2]} // undef;
};

sub startswith {
  $_[0]->{'[' . $_[1]} // undef;
};

sub endswith {
  $_[0]->{$_[1] . ']'} // undef;
};


1;
