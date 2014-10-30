package KorAP::Field::MultiTermToken;
use KorAP::Field::MultiTerm;
use Mojo::Base -base;
use List::MoreUtils 'uniq';

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

# Return a new term id
sub id_counter {
  $_[0]->{id_counter} //= 1;
  return $_[0]->{id_counter}++;
};


sub surface {
  substr($_[0]->{mt}->[0]->term,2);
};

sub lc_surface {
  substr($_[0]->{mt}->[1]->term,2);
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
  [uniq(map($_->to_string, @{$self->{mt}}))];
};


sub to_solr {
  my $self = shift;
  my @array = map { $_->to_solr(0) } @{$self->{mt}};
  $array[0]->{i} = 1;
  return \@array;
};


1;


__END__

[
  {
   "e":128,
   "i":22,
   "p":"DQ4KDQsODg8=",
   "s":123,
   "t":"one",
   "y":"word"
  },
  {
   "e":8,
   "i":1,
   "s":5,
   "t":"two",
   "y":"word"
  },
  {
   "e":22,
   "i":1,
   "s":20,
   "t":"three",
   "y":"foobar"
  }
 ]

