package KorAP::Field::MultiTerm;
use Mojo::Base -base;
use MIME::Base64;

has [qw/p_start p_end o_start o_end term payload/];
has store_offsets => 1;

sub to_string {
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
