package KorAP::Index::TreeTagger::Morpho;
use KorAP::Index::Base;

sub parse {
  my $self = shift;

  $$self->add_tokendata(
    foundry => 'tree_tagger',
    layer => 'morpho',
    cb => sub {
      my ($stream, $token) = @_;
      my $mtt = $stream->pos($token->pos);

      my $content = $token->hash->{fs}->{f};

      my $found;

      $content = ref $content ne 'ARRAY' ? [$content] : $content;

      foreach my $fs (@$content) {
	$content = $fs->{fs}->{f};
	foreach (@$content) {

	  # lemma
	  if (($_->{-name} eq 'lemma') &&
		($found = $_->{'#text'}) &&
		  ($found ne 'UNKNOWN') &&
		    ($found ne '?')) {
	    $mtt->add(
	      term => 'tt_l:' . $found
	    );
	  };

	  # pos
	  if (($_->{-name} eq 'ctag') && ($found = $_->{'#text'})) {
	    $mtt->add(
	      term => 'tt_p:' . $found
	    );
	  };
	};
      };
    }) or return;

  return 1;
};


1;
