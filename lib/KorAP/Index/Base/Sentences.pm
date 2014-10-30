package KorAP::Index::Base::Sentences;
use KorAP::Index::Base;

sub parse {
  my $self = shift;
  my $i = 0;

  my ($first, $last_p, $last_o);

  $$self->add_spandata(
    foundry => 'base',
    layer => 'sentences',
    cb => sub {
      my ($stream, $span) = @_;
      my $mtt = $stream->pos($span->p_start);
      $first = [$span->p_start, $span->o_start] unless defined $first;
      $mtt->add(
	term => '<>:base/s:s',
	o_start => $span->o_start,
	o_end => $span->o_end,
	p_end => $span->p_end,
	payload => '<b>2'
      );
      $last_p = $span->p_end;
      $last_o = $span->o_end;
      $i++;
    }
  ) or return;

  my $mt = $$self->stream->pos($first->[0]);
  $mt->add(
    term => '<>:base/s:t',
    o_start => $first->[1],
    p_end => $last_p,
    o_end => $last_o,
    payload => '<b>0'
  );

  $$self->stream->add_meta('base/sentences', '<i>' . $i);

  return 1;
};

sub layer_info {
    ['base/s=spans'];
};

1;
