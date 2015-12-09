package KorAP::Field::MultiTermTokenStream;
use Mojo::Base -base;
use KorAP::Field::MultiTermToken;

has [qw/oStart oEnd/];

sub add {
  my $self = shift;
  my $mtt = shift // KorAP::Field::MultiTermToken->new;
  $self->{mtt} //= [];
  $self->{tui} //= [];
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
  return unless defined $pos;
  return $self->{mtt}->[$pos];
};

sub to_string {
  my $self = shift;
  return join("\n" , map { $_->to_string } @{$self->{mtt}}) . "\n";
};

sub multi_term_tokens {
  $_[0]->{mtt};
};

sub tui {
  my $self = shift;
  my $pos = shift;
  return unless defined $pos;
  return ++$self->{tui}->[$pos];
};

sub to_array {
  my $self = shift;
  [ map { $_->to_array } @{$self->{mtt}} ];
};

sub to_solr {
  my $self = shift;
  [ map { $_->to_solr } @{$self->{mtt}} ];
};

1;
