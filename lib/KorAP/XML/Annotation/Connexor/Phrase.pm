package KorAP::XML::Annotation::Connexor::Phrase;
use KorAP::XML::Annotation::Base;

sub parse {
  my $self = shift;

  $$self->add_spandata(
    foundry => 'connexor',
    layer => 'phrase',
    cb => sub {
      my ($stream, $span) = @_;

      my $content = $span->get_hash->{fs}->{f};

      return if $content->{-name} ne 'pos';

      my $type = $content->{'#text'};

      if ($type) {
        $stream->pos($span->get_p_start)
          ->add_span('<>:cnx/c:' . $type, $span)
          ->set_payload('<b>0'); # Pseudo-depth
      };
    }
  ) or return;

  return 1;
};

sub layer_info {
  ['cnx/c=spans'];
};


1;
