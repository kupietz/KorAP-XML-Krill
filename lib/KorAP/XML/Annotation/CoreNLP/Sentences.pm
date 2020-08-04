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
      my $mtt = $stream->pos($span->get_p_start);
      my $mt = $mtt->add_by_term('<>:corenlp/s:s');
      $mt->set_o_start($span->get_o_start);
      $mt->set_o_end($span->get_o_end);
      $mt->set_p_end($span->get_p_end);
      $mt->set_pti(64);
      $mt->set_payload('<b>0'); # Could also be 2 for t/p/s
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
