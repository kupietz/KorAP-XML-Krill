package KorAP::XML::Index::MultiTerm;
use strict;
use warnings;
use MIME::Base64;

# Todo: This should store only the pti and the payload - with clever access using the pti!
# Everything should be stored as bytes already (if this is feasible)

use constant {
  PAYLOAD => 0,
  P_START => 1,
  P_END => 2,
  O_START => 3,
  O_END => 4,
  TERM => 5,
  STORED_OFFSETS => 6,
  PTI => 7, # former 10
  TUI => 8,
};

sub new {
  my $self = bless [], shift;
  for (my $i = 0; $i < scalar @_; $i+=2) {
    if ($_[$i] eq 'term') {
      $self->[TERM] = $_[$i+1];
    }
    elsif ($_[$i] eq 'p_start') {
      $self->[P_START] = $_[$i+1];
    }
    elsif ($_[$i] eq 'p_end') {
      $self->[P_END] = $_[$i+1];
    }
    elsif ($_[$i] eq 'payload') {
      $self->[PAYLOAD] = $_[$i+1];
    }
    elsif ($_[$i] eq 'store_offsets') {
      $self->store_offsets($_[$i+1]);
    }
    elsif ($_[$i] eq 'o_start') {
      $self->[O_START] = $_[$i+1];
    }
    elsif ($_[$i] eq 'o_end') {
      $self->[O_END] = $_[$i+1];
    }
    elsif ($_[$i] eq 'pti') {
      $self->[PTI] = $_[$i+1];
    }
    elsif ($_[$i] eq 'tui') {
      $self->[TUI] = $_[$i+1];
    };
  };
  $self;
};

sub new_from_array {
  bless [@_], shift;
};

sub new_blank {
  bless [], shift;
}

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
  my $str = shift;
  $str =~ s/([\#\$\\])/\\$1/g;
  return $str;
};


1;
