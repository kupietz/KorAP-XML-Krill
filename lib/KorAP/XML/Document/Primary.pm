package KorAP::XML::Document::Primary;
use strict;
use warnings;
use Mojo::ByteStream 'b';
use feature 'state';
use Packed::Array;
use utf8;

use constant {
  DATA => 0,
  BYTES => 1,
  XIP => 2
};

# our $QUOT = b("„“”")->decode;
our $QUOT_RE = qr/[„“”]/;

# Constructor
sub new {
  my $class = shift;
  bless [$_[0]], $class;
};


# Get the data as a substring
sub data {
  my ($self, $from, $to) = @_;

  # Get range data from primary
  return substr($self->[DATA], $from) if $from && !$to;

  # Get full data
  return $self->[DATA] unless $to;

  return if $to > $self->data_length;

  # Return substring
  return (substr($self->[DATA], $from, $to - $from) // undef);
};


# Get the data using byte ofsets
sub data_bytes {
  my ($self, $from, $to) = @_;

  use bytes;

  # Only start offset defined
  if ($from && !$to) {
    return b(substr($self->[DATA], $from))->decode;
  };

  # No offset defined
  return b($self->[DATA])->decode unless $to;

  # Get the substring based on offsets
  my $substr = substr($self->[DATA], $from, $to - $from);

  # Decode
  return b($substr)->decode if defined $substr;

  # No data
  return;
};


# The length of the primary text in characters
sub data_length {
  length($_[0]->[DATA]);
};


# Get correct offset
sub bytes2chars {
  my $self = shift;
  unless ($self->[BYTES]) {
    $self->[BYTES] = _calc_chars($self->[DATA]);
  };
  return $self->[BYTES]->[shift];
};


# Get correct offset
sub xip2chars {
  my $self = shift;
  unless ($self->[XIP]) {
    # Hacky work around: replace fancy quotation marks for XIP
    $self->[XIP] = _calc_chars($self->[DATA] =~ s{$QUOT_RE}{"}gr);
  };
  return $self->[XIP]->[shift];
};


# Calculate character offsets
sub _calc_chars {
  use bytes;

  tie my @array, 'Packed::Array';

  state $leading = pack( 'B8', '10000000' );
  state $start   = pack( 'B8', '01000000' );

  my ($i, $j) = (0,0);
  my $c;

  # Init array
  my $l = length($_[0]);
  $array[$l-1] = 0;

  # Iterate over every character
  while ($i <= $l) {

    # Get actual character
    $c = substr($_[0], $i, 1);

    # store character position
    $array[$i++] = $j;

    # This is the start of a multibyte sequence
    if (ord($c & $leading) && ord($c & $start)) {

      # Get the next byte - expecting a following character
      $c = substr($_[0], $i, 1);

      # Character is part of a multibyte
      while (ord($c & $leading)) {

        # Set count
        $array[$i] = (ord($c & $start)) ? ++$j : $j;

        # Get next character
        $c = substr($_[0], ++$i, 1);
      };
    };

    $j++;
  };
  return \@array;
};


1;


__END__

=pod

=head1 NAME

KorAP::XML::Document::Primary

=head1 SYNOPSIS

  my $text = KorAP::XML::Document::Primary('Das ist mein Text');
  print $text->data(2,5);
  print $text->data_length;


=head1 DESCRIPTION

Represent textual data with annotated character and byte offsets.


=head1 ATTRIBUTES

=head2 data_length

  print $text->data_length;

The textual length in number of characters.


=head1 METHODS

=head2 data

  print $text->data;
  print $text->data(4);
  print $text->data(5,17);

Return the textual data as a substring. Accepts a starting offset and the length of
the requested data. The data will be wrapped in an utf-8 encoded L<Mojo::ByteStream>.

=head2 bytes2chars

  print $text->bytes2chars(40);

Calculates the character offset based on a given byte offset.

=cut
