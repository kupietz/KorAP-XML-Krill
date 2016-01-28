package KorAP::XML::Index::Connexor::Phrase;
use KorAP::XML::Index::Base;

sub parse {
  my $self = shift;

  $$self->add_spandata(
    foundry => 'connexor',
    layer => 'phrase',
    cb => sub {
      my ($stream, $span) = @_;

      my $content = $span->hash->{fs}->{f};

      return if $content->{-name} ne 'pos';

      my $type = $content->{'#text'};

      if ($type) {
	my $mtt = $stream->pos($span->p_start);
	$mtt->add(
	  term => '<>:cnx/c:' . $type,
	  o_start => $span->o_start,
	  o_end => $span->o_end,
	  p_end => $span->p_end,
	  pti => 64,
	  payload => '<b>0' # Pseudo-depth
	);
      };
    }
  ) or return;

  return 1;
};

sub layer_info {
  ['cnx/c=spans'];
};


1;
