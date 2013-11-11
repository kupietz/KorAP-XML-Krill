package KorAP::Index::Mate::Morpho;
use KorAP::Index::Base;

sub parse {
  my $self = shift;

  $$self->add_tokendata(
    foundry => 'mate',
    layer => 'morpho',
    cb => sub {
      my ($stream, $token) = @_;
      my $mtt = $stream->pos($token->pos);

      my $content = $token->hash->{fs}->{f};

      my $found;

      my $capital = 0;

      foreach my $f (@{$content->{fs}->{f}}) {

	# pos
	if (($f->{-name} eq 'pos') &&
	      ($found = $f->{'#text'})) {
	  $mtt->add(term => 'mate/p:' . $found);
	}

	# lemma
	elsif (($f->{-name} eq 'lemma')
		 && ($found = $f->{'#text'})
		   && $found ne '--') {
	  # b($found)->decode('latin-1')->encode->to_string
	  $mtt->add(term => 'mate/l:' . $found);
	}

	# MSD
	elsif (($f->{-name} eq 'msd') &&
		 ($found = $f->{'#text'}) &&
		   ($found ne '_')) {
	  foreach (split '\|', $found) {
	    my ($x, $y) = split "=", $_;
	    # case, tense, number, mood, person, degree, gender
	    $mtt->add(term => 'mate/m:' . $x . ':' . $y);
	  };
	};
      };
    }) or return;

  return 1;
};


1;
