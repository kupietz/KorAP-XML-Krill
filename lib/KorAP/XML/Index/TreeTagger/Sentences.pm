package KorAP::XML::Index::TreeTagger::Sentences;
use KorAP::XML::Index::Base;

sub parse {
  my $self = shift;
  my $i = 0;

  $$self->add_spandata(
    foundry => 'tree_tagger',
    layer => 'sentences',
    cb => sub {
      my ($stream, $span) = @_;
      my $mtt = $stream->pos($span->p_start);
      $mtt->add(
	term => '<>:tt/s:s',
	o_start => $span->o_start,
	o_end => $span->o_end,
	p_end => $span->p_end,
	pti => 64,
	payload => '<b>0' # Could be 2 as well t/p/s
      );
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
