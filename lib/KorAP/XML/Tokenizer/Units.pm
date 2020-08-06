package KorAP::XML::Tokenizer::Units;
use strict;
use warnings;
use KorAP::XML::Tokenizer::Span;
use KorAP::XML::Tokenizer::Token;

use constant DEBUG => 0;


# Construct a new units object
sub new {
  my $class = shift;
  my $self = bless {@_}, $class;

  $self->{should} //= 0;
  $self->{have} //= 0;

  # Set _offset
  $self->encoding(
    $self->{encoding} // 'utf-8'
  );
  return $self;
};


# Get or set "should"
sub should {
  if (defined $_[1]) {
    $_[0]->{should} = $_[1];
    return $_[0];
  };
  $_[0]->{should};
};


# Get or set "have"
sub have {
  if (defined $_[1]) {
    $_[0]->{have} = $_[1];
    return $_[0];
  };
  $_[0]->{have};
};


# Get or set encoding
sub encoding {

  # Set encoding
  if (defined $_[1]) {
    my $self = shift;
    $self->{encoding} = $_[0];

    # Set offset handling for bytes
    if ($_[0] eq 'bytes') {
      $self->{_offset} = sub {
        my ($self, $from, $to) = @_;
        my $p = $self->primary;
        $from = $p->bytes2chars($from);
        $to = $p->bytes2chars($to);
        return ($from, $to);
      }
    }

    # Set offset method for xip
    elsif ($_[0] eq 'xip') {
      $self->{_offset} = sub {
        my ($self, $from, $to) = @_;
        my $p = $self->primary;
        $from = $p->xip2chars($from);
        $to = $p->xip2chars($to);
        return ($from, $to);
      }
    }

    # Set to default
    else {
      $self->{_offset} = undef;
    }
    return $self;
  };

  # Get encoding
  $_[0]->{encoding};
};


# Get or set path
sub path {
  if (@_ == 1) {
    return $_[0]->{path};
  };
  $_[0]->{path} = $_[1];
  return $_[0];
};

# Get or set foundry
sub foundry {
  if (@_ == 1) {
    return $_[0]->{foundry};
  };
  $_[0]->{foundry} = $_[1];
  return $_[0];
};


# Get or set layer
sub layer {
  if (@_ == 1) {
    return $_[0]->{layer};
  };
  $_[0]->{layer} = $_[1];
  return $_[0];
};


# Get or set match
sub match {
  if (defined $_[1]) {
    $_[0]->{match} = $_[1];
    return $_[0];
  };
  $_[0]->{match};
};


# Get or set range
sub range {
  if (defined $_[1]) {
    $_[0]->{range} = $_[1];
    return $_[0];
  };
  $_[0]->{range};
};


# Get or set primary
sub primary {
  if (defined $_[1]) {
    $_[0]->{primary} = $_[1];
    return $_[0];
  };
  $_[0]->{primary};
};


# Get or set stream
sub stream {
  if (defined $_[1]) {
    $_[0]->{stream} = $_[1];
    return $_[0];
  };
  $_[0]->{stream};
};


# Create new span
sub span {
  my $self = shift;
  my ($from, $to, $s) = @_;

  ($from, $to) = $self->{_offset}->($self, $from, $to) if $self->{_offset};

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


# Create new token
sub token {
  my ($self, $from, $to, $s) = @_;

  ($from, $to) = $self->{_offset}->($self, $from, $to) if $self->{_offset};

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


1;
