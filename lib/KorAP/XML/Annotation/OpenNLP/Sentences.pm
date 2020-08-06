package KorAP::XML::Annotation::OpenNLP::Sentences;
use KorAP::XML::Annotation::Base;

sub parse {
  my $self = shift;
  my $i = 0;

  $$self->add_spandata(
    foundry => 'opennlp',
    layer => 'sentences',
    cb => sub {
      my ($stream, $span) = @_;
      $stream->pos($span->get_p_start)
        ->add_span('<>:opennlp/s:s', $span)
        ->set_payload('<b>0');
      $i++;
    }
  ) or return;

  $$self->stream->add_meta('opennlp/sentences', '<i>' . $i);

  return 1;
};

sub layer_info {
    ['opennlp/s=spans'];
};

1;
