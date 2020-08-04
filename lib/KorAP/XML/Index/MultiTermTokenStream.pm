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
    my $mtt = $self->pos($unit->get_pos);
    my $node = $mtt->grep_mt($term);

    # TODO: Check if term has PTI 128 - or what is wanted!

    # TODO: if the node has no TUI - add!
    return $node if $node;

    my $tui = $self->tui($unit->get_pos);
    #    return $mtt->add(
    #      term => $term,
    #      pti => 128,
    #      payload => '<s>' . $tui,
    #      tui => $tui
    #    );
    return $mtt->add_as_array(
      '<s>' . $tui, # PAYLOAD=0
      undef,
      undef,
      undef,
      undef,
      $term,        # TERM=5
      undef,
      128,         # PTI=7
      $tui          # TUI=8
    )
  }

  # Is span
  else {
    my $mtt = $self->pos($unit->get_p_start);
    my $node = $mtt->grep_mt('<>:' . $term);

    # TODO: if the node has no TUI - add!
    return $node if $node;

    my $tui = $self->tui($unit->get_p_start);

    return $mtt->add(
      term => '<>:' . $term,
      o_start => $unit->get_o_start,
      o_end   => $unit->get_o_end,
      p_start => $unit->get_p_start,
      p_end   => $unit->get_p_end,
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
  return unless defined $_[1];
  return $_[0]->[MTT]->[$_[1]];
};

sub to_string {
  my $self = shift;
  return join("\n" , map { $_->to_string } @{$self->[MTT]}) . "\n";
};

sub multi_term_tokens {
  $_[0]->[MTT];
};

sub tui {
  return unless defined $_[1];
  return ++$_[0]->[TUI]->[$_[1]];
};

sub to_array {
  my $self = shift;
  [ map { $_->to_array } @{$self->[MTT]} ];
};

1;
