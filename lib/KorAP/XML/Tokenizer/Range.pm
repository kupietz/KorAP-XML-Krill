package KorAP::XML::Tokenizer::Range;
use strict;
use warnings;
use Array::IntSpan;
use Carp 'carp';

our $SPAN_RE = qr/!([-+]?\d+):([-+]?\d+)$/;

our $debug = 0;

sub new {
  my $range = Array::IntSpan->new;
  bless \$range, shift;
};


# Set integer range from x to y with z
sub set {
  ${shift()}->set_range(@_);
};


# Set gap in range from x to y with !z-1:z
sub gap {
  ${shift()}->set_range(
    $_[0], $_[1],
    '!' . ($_[2] - 1) . ':' . $_[2]
  );
};


# Lookup range - ignore gaps!
sub lookup {
  my $x = ${$_[0]}->lookup( $_[1] );
  return if (!defined $x || index($x, '!') == 0);
  return $x;
};


# Lookup the position before the character offset
sub before {
  my $self = shift;
  my $offset = shift;

  # Be aware - this uses the array-lookup, not the object method!
  my $found = $$self->lookup( $offset );

  # Nothing set here
  unless (defined $found) {
    carp "There is no value for $offset" if $debug;
    return;
  };

  # Hit a gap,
  # return preceding match
  if ($found =~ $SPAN_RE) {
    return $1 >= 0 ? $1 : 0;
  }
  else {
    # Didn't hit a gap
    # this however may be inaccurate
    # but lifts recall
    return $found > 1 ? $found - 1 : 0;
  };
};


# Lookup the position after the character offset
sub after {
  my $self = shift;
  my $offset = shift;
  my $found = $$self->lookup( $offset );

  unless (defined $found) {
    carp "There is no value for $offset" if $debug;
    return;
  };

  if ($found =~ $SPAN_RE) {
    return $2;
  }
  else {
    # The current position is likely wrong. The most common non-gap
    # and non-exact-match is in the situation of
    # "y<e> z</e>", where e is in the range of the y token.
    $found + 1;
  };
};


sub to_string {
  my $self = shift;
  return join(
    '',
    map {'['.join(',',@$_).']'}
      @{$$self->get_range(0,100,'...')}
    ) . '...';
};

1;


__END__

=pod

This module is used for mapping character offsets to positions in
the stream of tokens.

=head1 set

  $range->set(34, 46, 2);

Start-offset, end-offset, position in token stream.

=head1 gap

  $range->gap(47, 49, 5);

Start-offset, end-offset, preceding position in token stream.

=head1 before

  my $pos = $range->before(15);

Return the token position in the token stream
before the character offset.
Be aware: The smallest before-position is 0.

=head1 after

  my $pos = $range->after(34);

Return the token position in the token stream
following the character offset.
In case, the character offset is part of a token,
the current token position is returned.

=head1 to_string

  print $range->to_string;

Serialize the first 100 character positions
in a string representation.
