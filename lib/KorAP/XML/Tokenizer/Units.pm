package KorAP::XML::Tokenizer::Units;
use KorAP::XML::Tokenizer::Span;
use KorAP::XML::Tokenizer::Token;
use Mojo::Base -base;

has [qw/path foundry layer match range primary stream/];
has 'should' => 0;
has 'have' => 0;
has 'encoding' => 'utf-8';

sub span {
  my $self = shift;
  my ($from, $to, $s) = @_;

  ($from, $to) = $self->_offset($from, $to);

  # return if !$to;
  $to   //= 0;
  $from //= 0;

  # The span is invalid
  return unless $from <= $to;

  my $span = KorAP::XML::Tokenizer::Span->new;


  # The span is a milestone
  if ($from == $to) {
    $span->milestone(1);
  };

  # The span has an id (probably useful)
  $span->id($s->{-id}) if $s && $s->{-id};

  # Set character offsets
  $span->o_start($from);
  $span->o_end($to);

  # Get start position (exactly)
  my $start = $self->match->startswith($span->o_start);

  unless (defined $start) {
    $start = $self->range->after($span->o_start);
    return unless defined $start;
  };

  # Set start token position to span
  $span->p_start($start);

  if ($span->milestone) {
    $span->p_end($start);
  }
  else {

    # Get end position (exactly)
    my $end = $self->match->endswith($span->o_end);

    unless (defined $end) {
      $end = $self->range->before($span->o_end);
      return unless defined $end;

      # The next token of end has a character
      # offset AFTER th given end character offset
      my $real_start = $self->stream->pos($end)->o_start;

      # Ignore non-milestone elements outside the token stream!
      return if $to <= $real_start;
    };

    # $span->p_end($end);
    # return unless $span->p_end >= $span->p_start;

    # EXPERIMENTAL:
    return unless $end >= $span->p_start;

    $span->p_end($end + 1);
  }

  $span->hash($s) if $s;

  $span;
};

sub token {
  my $self = shift;
  my ($from, $to, $s) = @_;

  ($from, $to) = $self->_offset($from, $to);

  return if !$to;
  $from ||= 0;
  return unless $to > $from;

  my $pos = $self->match->lookup($from, $to);

  return unless defined $pos;

  my $token = KorAP::XML::Tokenizer::Token->new;
  $token->id($s->{-id}) if $s && $s->{-id};
  $token->pos($pos);

  $token->hash($s) if $s;

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
  elsif ($self->encoding eq 'xip') {
    $from = $p->xip2chars($from);
    $to = $p->xip2chars($to);
  };

  ($from, $to);
};

1;
