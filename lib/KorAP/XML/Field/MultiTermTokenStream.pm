package KorAP::XML::Field::MultiTermTokenStream;
use Mojo::Base -base;
use KorAP::XML::Field::MultiTermToken;

has [qw/oStart oEnd/];

sub add {
  my $self = shift;
  my $mtt = shift // KorAP::XML::Field::MultiTermToken->new;
  $self->{mtt} //= [];
  $self->{tui} //= [];
  push(@{$self->{mtt}}, $mtt);
  return $mtt;
};

sub get_node {
  my ($self, $pos, $term) = @_;
  my $mtt = $self->pos($pos);
  my $node = $mtt->grep_mt($term);

  # TODO: Check if term has PTI 128 - or what is wanted!

  # TODO: if the node has no TUI - add!
  return $node if $node;

  my $tui = $self->tui($pos);
  return $mtt->add(
    term => $term,
    pti => 128,
    payload => '<s>' . $tui,
    tui => $tui
  );
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
