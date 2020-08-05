package KorAP::XML::Annotation::Connexor::Sentences;
use KorAP::XML::Annotation::Base;

sub parse {
  my $self = shift;
  my $i = 0;

  $$self->add_spandata(
    foundry => 'connexor',
    layer => 'sentences',
    cb => sub {
      my ($stream, $span) = @_;
      my $mt = $stream->pos($span->get_p_start)
        ->add_by_term('<>:cnx/s:s');
      $mt->set_o_start($span->get_o_start);
      $mt->set_o_end($span->get_o_end);
      $mt->set_p_end($span->get_p_end);
      $mt->set_pti(64);
      $mt->set_payload('<b>0');
      $i++;
    }
  ) or return;

  $$self->stream->add_meta('cnx/sentences', '<i>' . $i);

  return 1;
};


sub layer_info {
  ['cnx/s=spans'];
};

1;
