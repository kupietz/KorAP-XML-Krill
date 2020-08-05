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

      my $mt = $stream->pos($span->get_p_start)
        ->add_by_term('<>:xip/s:s');
      $mt->set_o_start($span->get_o_start);
      $mt->set_o_end($span->get_o_end);
      $mt->set_p_end($span->get_p_end);
      $mt->set_pti(64);
      $mt->set_payload('<b>0'); # Could be 2 as well for t/p/s
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
