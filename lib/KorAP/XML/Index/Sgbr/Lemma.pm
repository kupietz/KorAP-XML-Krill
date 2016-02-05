package KorAP::XML::Index::Sgbr::Lemma;
use KorAP::XML::Index::Base;
use Mojo::ByteStream 'b';

sub parse {
  my $self = shift;

  $$self->add_tokendata(
    foundry => 'sgbr',
    layer => 'lemma',
    cb => sub {
      my ($stream, $token) = @_;
      my $mtt = $stream->pos($token->pos);

      my $content = $token->hash->{fs}->{f};

      my $found;

      my $capital = 0;

      my $lemmata = (ref $content->{fs}->{f} eq 'ARRAY') ?
	$content->{fs}->{f} : [$content->{fs}->{f}];

      my $first = 0;

      # Iterate over all lemmata
      foreach my $f (@$lemmata) {

	# lemma
	if (($f->{-name} eq 'lemma')
	      && ($found = $f->{'#text'})) {

	  # $found = b($found)->decode('latin-1')->encode->to_string;
	  # warn $found;

	  unless ($first++) {
	    $mtt->add(
	      term => 'sgbr/l:' . $found
	    );
	  }
	  else {
	    $mtt->add(
	      term => 'sgbr/lv:' . $found
	    );
	  };
	};
      };
    }) or return;

  return 1;
};

sub layer_info {
  ['sgbr/l=tokens', 'sgbr/lv=tokens']
}

1;
