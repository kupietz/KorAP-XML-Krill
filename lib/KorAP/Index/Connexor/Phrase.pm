package KorAP::Index::Connexor::Phrase;
use KorAP::Index::Base;

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
	  term => '<>:cnx/const:' . $type,
	  o_start => $span->o_start,
	  o_end => $span->o_end,
	  p_end => $span->p_end
	);
      };
    }
  ) or return;

  return 1;
};


1;
