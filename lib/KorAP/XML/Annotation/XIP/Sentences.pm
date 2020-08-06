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

      $stream->pos($span->get_p_start)
        ->add_span('<>:xip/s:s', $span)
        ->set_payload('<b>0'); # Could be 2 as well for t/p/s
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
