package KorAP::Index::Schreibgebrauch::Morpho;
use KorAP::Index::Base;

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

      foreach my $f (@$lemmata) {

	# lemma
	if (($f->{-name} eq 'lemma')
	      && ($found = $f->{'#text'})) {
	  # b($found)->decode('latin-1')->encode->to_string
	  $mtt->add(term => 'sgbr/l:' . $found) unless $first++;
	  $mtt->add(term => 'sgbr/lv:' . $found);
	};
      };
    }) or return;

  return 1;
};

sub layer_info {
    ['sgbr/l=tokens', 'sgbr/lv=tokens']
}

1;
