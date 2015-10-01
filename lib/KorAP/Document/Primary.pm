package KorAP::Document::Primary;
use strict;
use warnings;
use Carp qw/croak carp/;
use Mojo::ByteStream 'b';
use feature 'state';
use Packed::Array;
use utf8;

# our $QUOT = b("„“”")->decode;
our $QUOT_RE = qr/[„“”]/;

# Constructor
sub new {
  my $class = shift;
  bless [shift()], $class;
};


# Get the data as a substring
sub data {
  my ($self, $from, $to) = @_;

  return substr($self->[0], $from) if $from && !$to;

  return $self->[0] unless $to;

  my $substr = substr($self->[0], $from, $to - $from);

  return $substr if defined $substr;

  return;
};


# Get the data using byte ofsets
sub data_bytes {
  my ($self, $from, $to) = @_;

  use bytes;

  # Only start offset defined
  if ($from && !$to) {
    return b(substr($self->[0], $from))->decode;
  };

  # No offset defined
  return b($self->[0])->decode unless $to;

  # Get the substring based on offsets
  my $substr = substr($self->[0], $from, $to - $from);

  # Decode
  return b($substr)->decode if defined $substr;

  # No data
  return;
};


# The length of the primary text in characters
sub data_length {
  my $self = shift;
  return $self->[1] if $self->[1];
  $self->[1] = length($self->[0]);
  return $self->[1];
};


# Get correct offset
sub bytes2chars {
  my $self = shift;
  unless ($self->[2]) {
    $self->[2] = $self->_calc_chars($self->[0]);
  };
  return $self->[2]->[shift];
};


# Get correct offset
sub xip2chars {
  my $self = shift;
  unless ($self->[3]) {
    my $buffer = $self->[0];

    # Hacky work around: replace fancy quotation marks for XIP
    $buffer =~ s{$QUOT_RE}{"}g;

    $self->[3] = $self->_calc_chars($buffer);
  };
  return $self->[3]->[shift];
};


# Calculate character offsets
sub _calc_chars {
  use bytes;
  my $self = shift;
  my $text = shift;

  tie my @array, 'Packed::Array';

  state $leading = pack( 'B8', '10000000' );
  state $start   = pack( 'B8', '01000000' );

  my ($i, $j) = (0,0);
  my $c;

  # Init array
  my $l = length($text);
  $array[$l-1] = 0;

  # Iterate over every character
  while ($i <= $l) {

    # Get actual character
    $c = substr($text, $i, 1);

    # store character position
    $array[$i++] = $j;

    # This is the start of a multibyte sequence
    if (ord($c & $leading) && ord($c & $start)) {

      # Get the next byte - expecting a following character
      $c = substr($text, $i, 1);

      # Character is part of a multibyte
      while (ord($c & $leading)) {

	# Set count
	$array[$i] = (ord($c & $start)) ? ++$j : $j;

	# Get next character
	$c = substr($text, ++$i, 1);
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

KorAP::Document::Primary

=head1 SYNOPSIS

  my $text = KorAP::Document::Primary('Das ist mein Text');
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
