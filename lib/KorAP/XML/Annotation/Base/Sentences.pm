package KorAP::XML::Annotation::Base::Sentences;
use KorAP::XML::Annotation::Base;

sub parse {
  my $self = shift;
  my $i = 0;

  my ($first, $last_p, $last_o);

  $$self->add_spandata(
    foundry => 'base',
    layer => 'sentences',
    cb => sub {
      my ($stream, $span) = @_;
      my $mtt = $stream->pos($span->get_p_start);

      $first = [$span->get_p_start, $span->get_o_start] unless defined $first;

      my $mt = $mtt->add('<>:base/s:s');
      $mt->set_o_start($span->get_o_start);
      $mt->set_o_end($span->get_o_end);
      $mt->set_p_end($span->get_p_end);
      $mt->set_payload('<b>2');
      $mt->set_pti(64);

      $last_p = $span->get_p_end;
      $last_o = $span->get_o_end;
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
