package KorAP::XML::Index::MultiTermTokenStream;
use strict;
use warnings;
use KorAP::XML::Index::MultiTermToken;

use constant {
  MTT => 0,
  TUI => 1
};

sub new {
  bless [[],[]], shift;
};

sub add {
  my $self = shift;
  my $mtt = shift // KorAP::XML::Index::MultiTermToken->new;
  push(@{$self->[MTT]}, $mtt);
  return $mtt;
};

sub get_node {
  my ($self, $unit, $term) = @_;

  if ($unit->type eq 'token') {
    my $mtt = $self->pos($unit->pos);
    my $node = $mtt->grep_mt($term);

    # TODO: Check if term has PTI 128 - or what is wanted!

    # TODO: if the node has no TUI - add!
    return $node if $node;

    my $tui = $self->tui($unit->pos);
    return $mtt->add(
      term => $term,
      pti => 128,
      payload => '<s>' . $tui,
      tui => $tui
    );
  }

  # Is span
  else {
    my $mtt = $self->pos($unit->p_start);
    my $node = $mtt->grep_mt('<>:' . $term);

    # TODO: if the node has no TUI - add!
    return $node if $node;

    my $tui = $self->tui($unit->p_start);

    return $mtt->add(
      term => '<>:' . $term,
      o_start => $unit->o_start,
      o_end   => $unit->o_end,
      p_start => $unit->p_start,
      p_end   => $unit->p_end,
      pti => 64,
      payload => '<b>0<s>' . $tui,
      tui => $tui
    );

  };
};

sub add_meta {
  my $self = shift;
  my $pos_0 = $self->pos(0) or return;
  my $mt = $pos_0->add('-:' . shift);
  $mt->set_payload(shift);
  $mt->set_stored_offsets(0);
};

sub pos {
  my $self = shift;
  my $pos = shift;
  return unless defined $pos;
  return $self->[MTT]->[$pos];
};

sub to_string {
  my $self = shift;
  return join("\n" , map { $_->to_string } @{$self->[MTT]}) . "\n";
};

sub multi_term_tokens {
  $_[0]->[MTT];
};

sub tui {
  my $self = shift;
  my $pos = shift;
  return unless defined $pos;
  return ++$self->[TUI]->[$pos];
};

sub to_array {
  my $self = shift;
  [ map { $_->to_array } @{$self->[MTT]} ];
};

1;
