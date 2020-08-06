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
      $stream->pos($span->get_p_start)
        ->add_span('<>:base/s:p', $span)
        ->set_payload('<b>1');
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
