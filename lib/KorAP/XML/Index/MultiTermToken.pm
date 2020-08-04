package KorAP::XML::Index::MultiTermToken;
use KorAP::XML::Index::MultiTerm;
use Scalar::Util qw/blessed/;
use List::MoreUtils 'uniq';
use Carp qw/carp croak/;
use strict;
use warnings;

# This tries to be highly optimized (it's not supposed to be readable)
# but is rather slow on sorting relations.
# Should be replaced by an efficient implementation!

use constant {
  MT      => 0,
  O_START => 1,
  O_END   => 2,
  ID_COUNTER => 3,
};

sub new {
  bless [[]], shift;
};


sub add {
  my $self = shift;

  my $mt;
  unless (blessed $_[0]) {
    if (@_ == 1) {
      $mt = KorAP::XML::Index::MultiTerm->new_blank;
      $mt->set_term($_[0]);
    }
    else {
      $mt = KorAP::XML::Index::MultiTerm->new(@_);
    };
  }
  else {
    $mt = $_[0];
  };
  push(@{$self->[MT]}, $mt);
  $mt;
};

sub add_by_term {
  my $mt = KorAP::XML::Index::MultiTerm->new_from_term($_[1]);
  push(@{$_[0]->[MT]}, $mt);
  $mt;
};

sub add_blessed {
  push(@{$_[0]->[MT]}, $_[1]);
  $_[1];
};

sub set_o_start {
  return $_[0]->[O_START] = $_[1];
};

sub get_o_start {
  $_[0]->[O_START]
};

sub set_o_end {
  return $_[0]->[O_END] = $_[1];
};

sub get_o_end {
  $_[0]->[O_END]
};

sub id_counter {
  $_[0]->[ID_COUNTER] //= 1;
  return $_[0]->[ID_COUNTER]++;
};

sub surface {
  substr($_[0]->[MT]->[0]->term,2);
};

sub lc_surface {
  substr($_[0]->[MT]->[1]->term,2);
};

sub to_array {
  my $self = shift;
  [uniq(map($_->to_string, sort _sort @{$self->[0]}))];
};

# Get multiterm based on term content (treat as prefix)
# TODO: This currently only works for simple terms!
sub grep_mt {
  my $self = shift;
  my $term = shift;
  foreach (@{$self->[0]}) {
    return $_ if index($_->term, $term) == 0;
  };
  return;
};

sub to_string {
  my $self = shift;
  my $string = '[(' . $self->get_o_start . '-'. $self->get_o_end . ')';
  $string .= join ('|', @{$self->to_array});
  $string .= ']';
  return $string;
};

# Get relation based positions
sub _rel_right_pos {
  # Both are either < or >

  # term to term - right token
  if ($_[1] =~ m/^<i>(\d+)(?:<s>|$)/o) {
    return ($1, $1);
  }

  # term to span - right token
  # (including character offsets)
  elsif ($_[0] == 33 && $_[1] =~ m/^(?:<i>\d+){2}<i>(\d+)<i>(\d+)(?:<s>|$)/o) {
    return ($1, $2);
  }

  # span to term
  elsif ($_[0] == 34 && $_[1] =~ m/^(?:<i>\d+){3}<i>(\d+)(?:<s>|$)/o) {
    return ($1, $1);
  }

  # span-to-span
  elsif ($_[0] == 35 && $_[1] =~ m/^(?:<i>\d+){5}<i>(\d+)<i>(\d+)(?:<s>|$)/o) {
    return ($1, $2);
  };

  # span to term - right token
  carp 'Unknown relation format! ' .$_[0] . ':' . $_[1];
  return (0,0);
};


# Sort spans, attributes and relations
sub _sort {

  # Both are no spans
  if (index($a->get_term, '<>:') != 0 && index($b->get_term, '<>:') != 0) {

    # Both are attributes
    # Order attributes by reference id
    if (index($a->get_term, '@:') == 0 && index($b->get_term, '@:') == 0) {

      # Check TUI
      my ($a_id) = ($a->get_payload =~ m/^<s>(\d+)/);
      my ($b_id) = ($b->get_payload =~ m/^<s>(\d+)/);
      if ($a_id > $b_id) {
        return 1;
      }
      elsif ($a_id < $b_id) {
        return -1;
      }
      else {
        return 1;
      };
    }

    # Both are relations
    elsif (
      (index($a->get_term,'<:') == 0 || index($a->get_term,'>:') == 0)  &&
        (index($b->get_term, '<:') == 0 || index($b->get_term,'>:') == 0)) {

      my $a_end = ($a->get_pti < 34 ? $a->get_p_start : (
        ($a->get_pti == 35 ? ($a->get_payload =~ /^(?:<i>\d+){4}<i>(\d+)</ && $1) :
           ($a->get_payload =~ /^(?:<i>\d+){2}<i>(\d+)</ && $1)
         )
      ));

      my $b_end = ($b->get_pti < 34 ? $b->get_p_start : (
        ($b->get_pti == 35 ? ($b->get_payload =~ /^(?:<i>\d+){4}<i>(\d+)</ && $1) :
           ($b->get_payload =~ /^(?:<i>\d+){2}<i>(\d+)</ && $1)
         )
      ));

      # left is p_end
      if ($a_end < $b_end) {
        return -1;
      }
      elsif ($a_end > $b_end) {
        return 1;
      }
      else {
        # Both are either > or <

        # Check for right positions
        (my $a_start, $a_end) = _rel_right_pos($a->get_pti, $a->get_payload);
        (my $b_start, $b_end) = _rel_right_pos($b->get_pti, $b->get_payload);
        if ($a_start < $b_start) {
          return -1;
        }
        elsif ($a_start > $b_start) {
          return 1;
        }
        elsif ($a_end < $b_end) {
          return -1;
        }
        elsif ($a_end > $b_end) {
          return 1;
        }
        else {
          return 1;
        };
      };
    };

    # This has to be sorted alphabetically!
    return $a->get_term cmp $b->get_term;
  }

  # Not identical
  elsif (index($a->get_term, '<>:') != 0) {
    return $a->get_term cmp $b->get_term;
  }
  # Not identical
  elsif (index($b->get_term, '<>:') != 0) {
    return $a->get_term cmp $b->get_term;
  }

  # Sort both spans
  else {
    if ($a->get_p_end < $b->get_p_end) {
      return -1;
    }
    elsif ($a->get_p_end > $b->get_p_end) {
      return 1;
    }

    # Check depth
    else {
      my ($a_depth) = ($a->get_payload ? $a->get_payload =~ m/<b>(\d+)(?:<s>\d+)?$/ : 0);
      my ($b_depth) = ($b->get_payload ? $b->get_payload =~ m/<b>(\d+)(?:<s>\d+)?$/ : 0);

      $a_depth //= 0;
      $b_depth //= 0;
      if ($a_depth < $b_depth) {
        return -1;
      }
      elsif ($a_depth > $b_depth) {
        return 1;
      }
      else {
        return $a->get_term cmp $b->get_term;
      };
    };
  };
};


1;


__END__
