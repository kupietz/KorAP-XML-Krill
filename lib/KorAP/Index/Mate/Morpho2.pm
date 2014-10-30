package KorAP::Index::Mate::Morpho;
use KorAP::Index::Base;

# This attaches morphological information as attributes to the pos

sub parse {
  my $self = shift;

  $$self->add_tokendata(
    foundry => 'mate',
    layer => 'morpho',
    cb => sub {
      my ($stream, $token) = @_;
      my $mtt = $stream->pos($token->pos);

      my $content = $token->hash->{fs}->{f};

      my ($found, $pos, $msd, $id);

      my $capital = 0;

      foreach my $f (@{$content->{fs}->{f}}) {
	#pos
	if (($f->{-name} eq 'pos') && ($found = $f->{'#text'})) {
	  $pos = $found;
	}

	# lemma
	elsif (($f->{-name} eq 'lemma')
		 && ($found = $f->{'#text'})
		   && $found ne '--') {
	  $mtt->add(term => 'mate/l:' . $found);
	}

	# MSD
	elsif (($f->{-name} eq 'msd') &&
		 ($found = $f->{'#text'}) &&
		   ($found ne '_')) {
	  $msd = $found;
	  $id = $mtt->id_counter;
	};
      };

      $mtt->add(term => 'mate/m:' . $pos . ($id ? ('$<s>' . $id) : ''));

      # MSD
      if ($msd) {
	foreach (split '\|', $msd) {
	  my ($x, $y) = split "=", $_;
	  # case, tense, number, mood, person, degree, gender
	  $mtt->add(term => '@:' . $x . ($y ? '=' . $y : '') . '$<s>' . $id);
	};
      };
    }) or return;

  return 1;
};

sub layer_info {
    ['mate/l=tokens', 'mate/m=tokens']
};

1;
