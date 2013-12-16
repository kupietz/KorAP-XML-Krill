package KorAP::Index::Connexor::Morpho;
use KorAP::Index::Base;

sub parse {
  my $self = shift;

  $$self->add_tokendata(
    foundry => 'connexor',
    layer => 'morpho',
    cb => sub {
      my ($stream, $token) = @_;
      my $mtt = $stream->pos($token->pos);

      my $content = $token->hash->{fs}->{f};

      my $found;

      my $features = $content->{fs}->{f};

      for my $f (@$features) {

      # Lemma
	if (($f->{-name} eq 'lemma') && ($found = $f->{'#text'})) {
	  if (index($found, "\N{U+00a0}") >= 0) {
	    foreach (split(/\x{00A0}/, $found)) {
	      $mtt->add(
		term => 'cnx/l:' . $_
	      );
	    }
	  }
	  else {
	    $mtt->add(
	      term => 'cnx/l:' . $found
	    );
	  };
	}

	# POS
	elsif (($f->{-name} eq 'pos') && ($found = $f->{'#text'})) {
	  $mtt->add(
	    term => 'cnx/p:' . $found
	  );

	}
	# MSD
	# Todo: Look in the description!
	elsif (($f->{-name} eq 'msd') && ($found = $f->{'#text'})) {
	  foreach (split(':', $found)) {
	    $mtt->add(
	      term => 'cnx/m:' . $_
	    );
	  };
	};
      };
    }
  ) or return;

  return 1;
};

sub layer_info {
    ['cnx/l=lemma', 'cnx/p=pos', 'cnx/m=msd'];
};



1;
