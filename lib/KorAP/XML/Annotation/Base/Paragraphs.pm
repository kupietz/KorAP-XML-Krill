package KorAP::XML::Annotation::Base::Paragraphs;
use KorAP::XML::Annotation::Base;

sub parse {
  my $self = shift;
  my $i = 0;

  $$self->add_spandata(
    foundry => 'base',
    layer => 'paragraph',
    cb => sub {
      my ($stream, $span) = @_;
      my $mtt = $stream->pos($span->get_p_start);
      my $mt = $mtt->add('<>:base/s:p');
      $mt->set_o_start($span->get_o_start);
      $mt->set_o_end($span->get_o_end);
      $mt->set_p_end($span->get_p_end);
      $mt->set_payload('<b>1');
      $mt->set_pti(64);
      $i++;
    }
  ) or return;

  # Add information about paragraph number
  $$self->stream->add_meta('base/paragraphs', '<i>' . $i);

  return 1;
};


sub layer_info {
  ['base/s=spans'];
};



1;
