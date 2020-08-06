package KorAP::XML::Annotation::CoreNLP::Sentences;
use KorAP::XML::Annotation::Base;

sub parse {
  my $self = shift;
  my $i = 0;

  $$self->add_spandata(
    foundry => 'corenlp',
    layer => 'sentences',
    cb => sub {
      my ($stream, $span) = @_;
      $stream->pos($span->get_p_start)
        ->add_span('<>:corenlp/s:s', $span)
        ->set_payload('<b>0'); # Could also be 2 for t/p/s
      $i++;
    }
  ) or return;

  $$self->stream->add_meta('corenlp/sentences', '<i>' . $i);

  return 1;
};


sub layer_info {
    ['corenlp/s=spans'];
};

1;
