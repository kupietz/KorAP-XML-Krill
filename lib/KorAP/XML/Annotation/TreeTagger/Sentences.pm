package KorAP::XML::Annotation::TreeTagger::Sentences;
use KorAP::XML::Annotation::Base;

sub parse {
  my $self = shift;
  my $i = 0;

  $$self->add_spandata(
    foundry => 'tree_tagger',
    layer => 'sentences',
    cb => sub {
      my ($stream, $span) = @_;
      $stream->pos($span->get_p_start)
        ->add_span('<>:tt/s:s',$span)
        ->set_payload('<b>0'); # Could be 2 as well t/p/s
      $i++;
    }
  ) or return;

  $$self->stream->add_meta('tt/sentences', '<i>' . $i);

  return 1;
};

sub layer_info {
  ['tt/s=spans'];
};


1;
