package KorAP::Index::Base::Paragraphs;
use KorAP::Index::Base;

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
	term => '<>:base/para',
	o_start => $span->o_start,
	o_end => $span->o_end,
	p_end => $span->p_end
      );
      $i++;
    }
  ) or return;

  $$self->stream->add_meta('paragraphs', '<i>' . $i);

  return 1;
};



1;
