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
      my $mtt = $stream->pos($span->get_p_start);
      my $mt = $mtt->add_by_term('<>:tt/s:s');
      $mt->set_o_start($span->get_o_start);
      $mt->set_o_end($span->get_o_end);
      $mt->set_p_end($span->get_p_end);
      $mt->set_pti(64);
      $mt->set_payload('<b>0'); # Could be 2 as well t/p/s
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
