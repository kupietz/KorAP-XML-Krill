package KorAP::XML::Index::MultiTerm;
use strict;
use warnings;
use MIME::Base64;

# Todo: This should store only the pti and the payload - with clever access using the pti!
# Everything should be stored as bytes already (if this is feasible)

use constant {
  TERM           => 0,
  O_START        => 1,
  O_END          => 2,
  P_START        => 3,
  P_END          => 4,
  STORED_OFFSETS => 5,
  PTI            => 6,
  TUI            => 7,
  PAYLOAD        => 8,
};


# Construct a multiterm object by passing a term
sub new {
  bless [$_[1]], $_[0];
};

sub set_payload {
  return $_[0]->[PAYLOAD] = $_[1];
};

sub get_payload {
  $_[0]->[PAYLOAD];
};

sub set_p_start {
  return $_[0]->[P_START] = $_[1];
};

sub get_p_start {
  $_[0]->[P_START] // 0;
};

sub set_p_end {
  $_[0]->[P_END] = $_[1];
};

sub get_p_end {
  $_[0]->[P_END] // 0
};

sub set_o_start {
  return $_[0]->[O_START] = $_[1];
};

sub get_o_start {
  $_[0]->[O_START] // 0;
};

sub set_o_end {
  $_[0]->[O_END] = $_[1];
};

sub get_o_end {
  $_[0]->[O_END] // 0;
};

sub set_term {
  return $_[0]->[TERM] = $_[1];
};

sub get_term {
  $_[0]->[TERM] // '';
};

sub set_stored_offsets {
  return $_[0]->[STORED_OFFSETS] = $_[1];
};

sub get_stored_offsets {
  $_[0]->[STORED_OFFSETS];
};

sub set_pti {
  return $_[0]->[PTI] = $_[1];
};

sub get_pti {
  $_[0]->[PTI];
};

sub set_tui {
  return $_[0]->[TUI] = $_[1];
};

sub get_tui {
  $_[0]->[TUI];
};


# To string based on array
sub to_string {
  my $string = _escape_term($_[0]->[TERM]);

  my $pre;

  # PTI
  $pre .= '<b>' . $_[0]->[PTI] if  $_[0]->[PTI];

  # Offsets
  if (defined $_[0]->[O_START]) {
    $pre .= '<i>' .$_[0]->[O_START] .
      '<i>' . $_[0]->[O_END];
  };

  #  my $pl = $_[0]->[1] ?
  #    $_[0]->[1] - 1 : $_[0]->[0];

  if ($_[0]->[P_END] || $_[0]->[PAYLOAD]) {

    # p_end
    if (defined $_[0]->[P_END]) {
      $pre .= '<i>' . $_[0]->[P_END];
    };
    if ($_[0]->[PAYLOAD]) {
      if (index($_[0]->[PAYLOAD], '<') == 0) {
        $pre .= $_[0]->[PAYLOAD];
      }
      else {
        $pre .= '<?>' . $_[0]->[PAYLOAD];
      };
    };
  };

  $string . ($pre ? '$' . $pre : '');
};


sub clone {
  my $self = shift;
  bless [@$self], __PACKAGE__;
};


sub _escape_term ($) {
  $_[0] =~ s/([\#\$\\])/\\$1/gr;
};


1;
