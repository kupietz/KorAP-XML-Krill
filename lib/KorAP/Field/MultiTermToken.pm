package KorAP::Field::MultiTermToken;
use KorAP::Field::MultiTerm;
use Mojo::Base -base;

has [qw/o_start o_end/];

sub add {
  my $self = shift;
  my $mt;
  unless (ref $_[0] eq 'MultiTerm') {
    if (@_ == 1) {
      $mt = KorAP::Field::MultiTerm->new(term => shift());
    }
    else {
      $mt = KorAP::Field::MultiTerm->new(@_);
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

sub to_array {
  my $self = shift;
  [map($_->to_string, @{$self->{mt}})];
};

1;
