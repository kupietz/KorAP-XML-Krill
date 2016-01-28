package KorAP::XML::Index::Base::Paragraphs;
use KorAP::XML::Index::Base;

sub parse {
  my $self = shift;
  my $i = 0;

  $$self->add_spandata(
    foundry => 'base',
    layer => 'paragraph',
    cb => sub {
      my ($stream, $span) = @_;
      my $mtt = $stream->pos($span->p_start);

      $mtt->add(
	term => '<>:base/s:p',
	o_start => $span->o_start,
	o_end => $span->o_end,
	p_end => $span->p_end,
	payload => '<b>1',
	pti => 64
      );
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
