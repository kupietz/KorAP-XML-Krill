package KorAP::MultiTermTokenStream;
use Mojo::Base -base;
use KorAP::MultiTermToken;

has [qw/oStart oEnd/];

sub add {
  my $self = shift;
  my $mtt = shift // KorAP::MultiTermToken->new;
  $self->{mtt} //= [];
  push(@{$self->{mtt}}, $mtt);
  return $mtt;
};

sub add_meta {
  my $self = shift;
  my $mt = $self->pos(0)->add('-:' . shift);
  $mt->payload(shift);
  $mt->store_offsets(0);
};

sub pos {
  my $self = shift;
  my $pos = shift;
  return $self->{mtt}->[$pos];
};

sub to_string {
  my $self = shift;
  return join("\n" , map { $_->to_string } @{$self->{mtt}}) . "\n";
};

1;
