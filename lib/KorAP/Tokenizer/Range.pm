package KorAP::Tokenizer::Range;
use strict;
use warnings;
use Array::IntSpan;

sub new {
  my $class = shift;
  my $range = Array::IntSpan->new;
  bless \$range, $class;
};

sub set {
  my $self = shift;
  $$self->set_range(@_);
};

sub gap {
  my $self = shift;
  $$self->set_range($_[0], $_[1], '!' . ($_[2] - 1) . ':' . $_[2]);
};

sub lookup {
  my $x = ${$_[0]}->lookup( $_[1] ) or return;
  return if index($x, '!') == 0;
  return $x;
};

sub before {
  my $self = shift;
  my $offset = shift;
  my $found = $$self->lookup( $offset );
  unless (defined $found) {
    warn 'There is no value for ', $offset;
  };

  if ($found =~ /!(\d+):(\d+)$/) {
    return $1 >= 0 ? $1 : 0;
  }
  else {
    return $found;
  };
};

sub after {
  my $self = shift;
  my $found = $$self->lookup( shift() );
  if ($found =~ /!(\d+):(\d+)$/) {
    return $2;
  }
  else {
    return $found;
  };
};

1;
