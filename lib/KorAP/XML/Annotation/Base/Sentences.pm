package KorAP::XML::Annotation::Base::Sentences;
use KorAP::XML::Annotation::Base;

sub parse {
  my $self = shift;
  my $i = 0;

  my ($first, $last_p, $last_o);

  $$self->add_spandata(
    foundry => 'base',
    layer => 'sentences',
    cb => sub {
      my ($stream, $span) = @_;
      my $mtt = $stream->pos($span->get_p_start);

      $first = [$span->get_p_start, $span->get_o_start] unless defined $first;
      $mtt->add(
        term => '<>:base/s:s',
        o_start => $span->get_o_start,
        o_end => $span->get_o_end,
        p_end => $span->get_p_end,
        payload => '<b>2',
        pti => 64
      );
      $last_p = $span->get_p_end;
      $last_o = $span->get_o_end;
      $i++;
    }
  ) or return;

  $$self->stream->add_meta('base/sentences', '<i>' . $i);

  return 1;
};

sub layer_info {
  ['base/s=spans'];
};

1;
