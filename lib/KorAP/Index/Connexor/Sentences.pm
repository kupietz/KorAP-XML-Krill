package KorAP::Index::Connexor::Sentences;
use KorAP::Index::Base;

sub parse {
  my $self = shift;
  my $i = 0;

  $$self->add_spandata(
    foundry => 'connexor',
    layer => 'sentences',
    cb => sub {
      my ($stream, $span) = @_;
      my $mtt = $stream->pos($span->p_start);
      $mtt->add(
	term => '<>:cnx/s:s',
	o_start => $span->o_start,
	o_end => $span->o_end,
	p_end => $span->p_end,
	payload => '<b>2'
      );
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
