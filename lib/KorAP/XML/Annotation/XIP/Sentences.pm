package KorAP::XML::Annotation::XIP::Sentences;
use KorAP::XML::Annotation::Base;

sub parse {
  my $self = shift;

  my $i = 0;

  $$self->add_spandata(
    foundry => 'xip',
    layer => 'sentences',
    encoding => 'xip',
    cb => sub {
      my ($stream, $span) = @_;

      my $mtt = $stream->pos($span->get_p_start);
      $mtt->add(
        term => '<>:xip/s:s',
        o_start => $span->get_o_start,
        o_end => $span->get_o_end,
        p_end => $span->get_p_end,
        pti => 64,
        payload => '<b>0' # Could be 2 as well for t/p/s
      );
      $i++;
    }
  ) or return;

  $$self->stream->add_meta('xip/sentences', '<i>' . $i);

  return 1;
};

sub layer_info {
  ['xip/s=spans'];
};


1;
