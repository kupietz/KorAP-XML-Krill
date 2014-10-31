package KorAP::Tokenizer::Range;
use strict;
use warnings;
use Array::IntSpan;

sub new {
  my $class = shift;
  my $range = Array::IntSpan->new;
  bless \$range, $class;
};


# Set integer range from x to y with z
sub set {
  ${shift()}->set_range(@_);
};

# Set gap in range from x to y with !z-1:z
sub gap {
  ${shift()}->set_range($_[0], $_[1],
  '!' . ($_[2] - 1) . ':' . $_[2]);
};

# Lookup range - ignore gaps!
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
    return;
  };

  # Hit a gap,
  # return preceding match
  if ($found =~ /!(\d+):(\d+)$/) {
    return $1 >= 0 ? $1 : 0;
  }
  else {
    # Didn't hit a gap
    # this however may be inaccurate
    # but lifts recall
    return $found - 1;
  };
};

sub after {
  my $self = shift;
  my $offset = shift;
  my $found = $$self->lookup( $offset );

  unless (defined $found) {
    warn 'There is no value for ', $offset;
    return;
  };

  if ($found =~ /^!(\d+):(\d+)$/) {
    return $2;
  }
  else {
    # I am not sure about that ...
    $found;
  };
};


sub to_string {
  my $self = shift;
  return join('', map {'['.join(',',@$_).']'}
		@{$$self->get_range(0,100,'...')})
    . '...';
};

1;
