package KorAP::XML::Tokenizer::Units;
use KorAP::XML::Tokenizer::Span;
use KorAP::XML::Tokenizer::Token;

# TODO:
#   Don't use Mojo::Base! - "encodings" is called too often
use Mojo::Base -base;

has [qw/path foundry layer match range primary stream/];
has 'should' => 0;
has 'have' => 0;
has 'encoding' => 'utf-8';

use constant DEBUG => 0;

sub span {
  my $self = shift;
  my ($from, $to, $s) = @_;

  ($from, $to) = $self->_offset($from, $to);

  # return if !$to;
  $to   //= 0;
  $from //= 0;

  # The span is invalid
  unless ($from <= $to) {
    if (DEBUG) {
      warn $s->{-id} . ' is invalid';
    };
    return;
  };

  my $span = KorAP::XML::Tokenizer::Span->new;

  # The span is a milestone
  if ($from == $to) {
    $span->set_milestone(1);
  };

  # The span has an id (probably useful)
  $span->set_id($s->{-id}) if $s && $s->{-id};

  # Set character offsets
  $span->set_o_start($from);
  $span->set_o_end($to);

  # Get start position (exactly)
  my $start = $self->match->startswith($from);

  unless (defined $start) {
    $start = $self->range->after($from);

    unless (defined $start) {
      if (DEBUG) {
        warn $span->id . ' has no valid start';
      };
      return;
    };
  };

  # Set start token position to span
  $span->set_p_start($start);

  if ($span->get_milestone) {
    $span->set_p_end($start);
  }
  else {

    # Get end position (exactly)
    my $end = $self->match->endswith($span->get_o_end);

    unless (defined $end) {
      $end = $self->range->before($span->get_o_end);

      if (DEBUG && $span->o_end == 196) {
        warn 'SPAN ends at ' . $span->get_o_end . ' and has ' . $end;
      };

      unless (defined $end) {
        if (DEBUG) {
          warn $span->id . ' has no valid end';
        };
        return;
      };

      # The next token of end has a character
      # offset AFTER the given end character offset
      my $real_start = $self->stream->pos($end)->get_o_start;

      # Ignore non-milestone elements outside the token stream!
      if ($to <= $real_start) {
        if (DEBUG) {
          warn 'Ignore ' . $span->id . ' is a non-milestone element outside the token stream';
        };
        return;
      };
    };

    # $span->p_end($end);
    # return unless $span->p_end >= $span->p_start;

    # EXPERIMENTAL:
    unless ($end >= $span->get_p_start) {
      if (DEBUG) {
        warn 'Ignore ' . $span->id . ' with ' . $span->get_p_start . '-' . $end;
      };
      return;
    };

    $span->set_p_end($end + 1);
  }

  if (DEBUG && $from == 124) {
    warn 'exact: ' . $span->get_p_start . '-' . $span->get_p_end;
  };

  $span->set_hash($s) if $s;

  $span;
};

sub token {
  my ($self, $from, $to, $s) = @_;

  ($from, $to) = $self->_offset($from, $to);

  return if !$to;
  return unless $to > $from;
  $from ||= 0;

  my $pos = $self->match->lookup($from, $to);

  return unless defined $pos;

  my $token = KorAP::XML::Tokenizer::Token->new;
  $token->set_pos($pos);

  if ($s) {
    $token->set_id($s->{-id}) if $s->{-id};
    $token->set_hash($s);
  };

  $token;
};


sub _offset {
  my $self = shift;
  return @_ if ($self->encoding eq 'utf-8' || !$self->encoding);

  my ($from, $to) = @_;

  my $p = $self->primary;
  if ($self->encoding eq 'bytes') {
    $from = $p->bytes2chars($from);
    $to = $p->bytes2chars($to);
  }

  # This is legacy treating of bytes2chars
  elsif ($self->encoding eq 'xip') {
    $from = $p->xip2chars($from);
    $to = $p->xip2chars($to);
  };

  ($from, $to);
};

1;
