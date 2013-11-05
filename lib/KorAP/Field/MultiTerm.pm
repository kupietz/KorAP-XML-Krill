package KorAP::Field::MultiTerm;
use Mojo::Base -base;

has [qw/p_start p_end o_start o_end term payload/];
has store_offsets => 1;

sub to_string {
  my $self = shift;
  my $string = $self->term;
  if (defined $self->o_start) {
    $string .= '#' .$self->o_start .'-' . $self->o_end;
#  }
#  elsif (!$self->storeOffsets) {
#    $string .= '#-';
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

1;
