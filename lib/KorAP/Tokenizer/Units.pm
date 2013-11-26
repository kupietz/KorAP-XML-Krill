package KorAP::Tokenizer::Units;
use KorAP::Tokenizer::Span;
use KorAP::Tokenizer::Token;
use Mojo::Base -base;

has [qw/path foundry layer match range primary/];
has 'should' => 0;
has 'have' => 0;
has 'encoding' => 'utf-8';

sub span {
  my $self = shift;
  my ($from, $to, $s) = @_;

  ($from, $to) = $self->_offset($from, $to);

  return unless $to > $from;

  my $span = KorAP::Tokenizer::Span->new;

  $span->id($s->{-id}) if $s && $s->{-id};

  $span->o_start($from);
  $span->o_end($to);

  my $start = $self->match->startswith($span->o_start);

  unless (defined $start) {
    $start = $self->range->after($span->o_start) or return;
  };

  $span->p_start($start);

  my $end = $self->match->endswith($span->o_end);
  unless ($end) {
    $end = $self->range->before($span->o_end) or return;
  };
  # $span->p_end($end);
  # return unless $span->p_end >= $span->p_start;

  # EXPERIMENTAL:
  return unless $end >= $span->p_start;
  $span->p_end($end + 1);

  $span->hash($s) if $s;

  return $span;
};

sub token {
  my $self = shift;
  my ($from, $to, $s) = @_;

  ($from, $to) = $self->_offset($from, $to);

  my $pos = $self->match->lookup($from, $to);

  return unless defined $pos;

#      if ($from == $to) {
#	print "Unable to find match for $from - $to (resp ".$s->{-from} . '-' . $s->{-to}.") " . $s->{-id};
#	print "\n";
#      };

  my $token = KorAP::Tokenizer::Token->new;
  $token->id($s->{-id}) if $s && $s->{-id};
  $token->pos($pos);

  $token->hash($s) if $s;

  return $token;
};


sub _offset {
  my $self = shift;
  my ($from, $to) = @_;

  if ($self->encoding) {
    my $p = $self->primary;
    if ($self->encoding eq 'bytes') {
      $from = $p->bytes2chars($from);
      $to = $p->bytes2chars($to);
    }
    elsif ($self->encoding eq 'xip') {
      $from = $p->xip2chars($from);
      $to = $p->xip2chars($to);
    };
  };

  return ($from, $to);
};

1;
