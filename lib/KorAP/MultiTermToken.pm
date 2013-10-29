package KorAP::MultiTermToken;
use KorAP::MultiTerm;
use Mojo::Base -base;

has [qw/o_start o_end/];

sub add {
  my $self = shift;
  my $mt;
  unless (ref $_[0] eq 'MultiTerm') {
    if (@_ == 1) {
      $mt = KorAP::MultiTerm->new(term => shift());
    }
    else {
      $mt = KorAP::MultiTerm->new(@_);
    };
  }
  else {
    $mt = shift;
  };
  $self->{mt} //= [];
  push(@{$self->{mt}}, $mt);
  return $mt;
};

sub to_string {
  my $self = shift;
  my $string = '[(' . $self->o_start . '-'. $self->o_end . ')';
  $string .= join ('|', map($_->to_string, @{$self->{mt}}));
  $string .= ']';
  return $string;
};

1;
