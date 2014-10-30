package KorAP::Index::TreeTagger::Morpho;
use KorAP::Index::Base;
use POSIX 'floor';

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

	my @val;
	my $certainty = 0;
	foreach (@$content) {
	  if ($_->{-name} eq 'certainty') {
	    $certainty = floor(($_->{'#text'} * 255));
	    $certainty = $certainty if $certainty;
	  }
	  else {
	    push @val, $_
	  };
	};

	foreach (@val) {
	  # lemma
	  if (($_->{-name} eq 'lemma') &&
		($found = $_->{'#text'}) &&
		  ($found ne 'UNKNOWN') &&
		    ($found ne '?')) {
	    my %term = (
	      term => 'tt/l:' . $found
	    );
	    $term{payload} = '<b>' . $certainty if $certainty;
	    $mtt->add(%term);
	  };

	  # pos
	  if (($_->{-name} eq 'ctag') && ($found = $_->{'#text'})) {
	    my %term = (
	      term => 'tt/p:' . $found
	    );
	    $term{payload} = '<b>' . $certainty if $certainty;
	    $mtt->add(%term);
	  };
	};
      };
    }) or return;

  return 1;
};

sub layer_info {
    ['tt/p=tokens', 'tt/l=tokens']
};

1;
