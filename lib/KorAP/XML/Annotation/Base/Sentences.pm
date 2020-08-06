package KorAP::XML::Annotation::Base::Sentences;
use KorAP::XML::Annotation::Base;

sub parse {
  my $self = shift;
  my $i = 0;

  $$self->add_spandata(
    foundry => 'base',
    layer => 'sentences',
    cb => sub {
      my ($stream, $span) = @_;
      $stream->pos($span->get_p_start)
        ->add_span('<>:base/s:s', $span)
        ->set_payload('<b>2');
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
