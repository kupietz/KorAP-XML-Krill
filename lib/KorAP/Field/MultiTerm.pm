package KorAP::Field::MultiTerm;
use strict;
use warnings;
use MIME::Base64;

sub new {
  my $self = bless [], shift;
  my $i = 0;
  for (; $i < scalar @_; $i+=2) {
    if ($_[$i] eq 'term') {
      $self->term($_[$i+1]);
    }
    elsif ($_[$i] eq 'p_start') {
      $self->p_start($_[$i+1]);
    }
    elsif ($_[$i] eq 'p_end') {
      $self->p_end($_[$i+1]);
    }
    elsif ($_[$i] eq 'payload') {
      $self->payload($_[$i+1]);
    }
    elsif ($_[$i] eq 'store_offsets') {
      $self->store_offsets($_[$i+1]);
    }
    elsif ($_[$i] eq 'o_start') {
      $self->o_start($_[$i+1]);
    }
    elsif ($_[$i] eq 'o_end') {
      $self->o_end($_[$i+1]);
    };
  };
  $self;
};

# 0
sub payload {
  if (defined $_[1]) {
    return $_[0]->[0] = $_[1];
  };
  $_[0]->[0];
};

# 1
sub p_start {
  if (defined $_[1]) {
    return $_[0]->[1] = $_[1];
  };
  $_[0]->[1];
};

# 2
sub p_end {
  if (defined $_[1]) {
    return $_[0]->[2] = $_[1];
  };
  $_[0]->[2];
};

# 3
sub o_start {
  if (defined $_[1]) {
    return $_[0]->[3] = $_[1];
  };
  $_[0]->[3];
};

# 4
sub o_end {
  if (defined $_[1]) {
    return $_[0]->[4] = $_[1];
  };
  $_[0]->[4];
};

# 5
sub term {
  if (defined $_[1]) {
    return $_[0]->[5] = $_[1];
  };
  $_[0]->[5];
};

# 6
sub store_offsets {
  if (defined $_[1]) {
    return $_[0]->[6] = $_[1];
  };
  $_[0]->[6];
};


# to string based on array
sub to_string {
  my $string = $_[0]->[5];
  if (defined $_[0]->[3]) {
    $string .= '#' .$_[0]->[3] .'-' . $_[0]->[4];
  };

  my $pl = $_[0]->[1] ? $_[0]->[1] - 1 : $_[0]->[0];
  if ($_[0]->[2] || $_[0]->[0]) {
    $string .= '$';
    if ($_[0]->[2]) {
      $string .= '<i>' . $_[0]->[2];
    };
    if ($_[0]->[0]) {
      if (index($_[0]->[0], '<') == 0) {
	$string .= $_[0]->[0];
      }
      else {
	$string .= '<?>' . $_[0]->[0];
      };
    };
  };

  $string;
};


sub to_string_2 {
  my $self = shift;
  my $string = $self->term;
  if (defined $self->o_start) {
    $string .= '#' .$self->o_start .'-' . $self->o_end;
  };

  my $pl = $self->p_end ? $self->p_end - 1 : $self->payload;
  if ($self->p_end || $self->payload) {
    $string .= '$';
    if ($self->p_end) {
      $string .= '<i>' . $self->p_end;
    };
    if ($self->payload) {
      if (index($self->payload, '<') == 0) {
	$string .= $self->payload;
      }
      else {
	$string .= '<?>' . $self->payload;
      };
    };
  };

  return $string;
};




sub to_solr {
  my $self = shift;
  my $increment = shift;

  my (@payload_types, @payload) = ();

  my $term = $self->term;
  if ($term =~ s/\#(\d+)-(\d+)//) {
    push(@payload, $1, $2);
    push(@payload_types, 'l', 'l');
  };

  my %term = ( t => $term );
  if (defined $increment && $increment == 0) {
    $term{i} = 0;
  };

  if (defined $self->o_start && !@payload) {
    push(@payload, $self->o_start, $self->o_end);
    push(@payload_types, 'l', 'l');
  };

  if ($self->p_end || $self->payload) {
    if ($self->p_end) {
      push(@payload, $self->p_end);
      push(@payload_types, 'l');
    };
    if ($self->payload) {
      if (index($self->payload, '<') == 0) {
	my @pls = split /(?=<)|(?<=>)/, $self->payload;
	for (my $i = 0; $i < @pls; $i+=2) {
	  if ($pls[$i] eq 'b') {
	    push(@payload, $pls[$i+1]);
	    push(@payload_types, 'c');
	  }
	  elsif ($pls[$i] eq 's') {
	    push(@payload, $pls[$i+1]);
	    push(@payload_types, 's');
	  }
	  elsif ($pls[$i] eq 'i') {
	    push(@payload, $pls[$i+1]);
	    push(@payload_types, 'l');
	  }
	  elsif ($pls[$i] eq 'l') {
	    push(@payload, $pls[$i+1]);
	    push(@payload_types, 'q');
	  }
	  else {
	    push(@payload, $pls[$i+1]);
	    push(@payload_types, 'w*');
	  };
	};
      }
      else {
	push(@payload, $self->payload);
	push(@payload_types, 'w*');
      };
    };
  };
  if (@payload) {
    $term{p} = encode_base64(pack(join('', @payload_types), @payload), '');
  };

  return \%term;
};

1;
