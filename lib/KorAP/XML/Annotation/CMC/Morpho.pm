package KorAP::XML::Annotation::CMC::Morpho;
use KorAP::XML::Annotation::Base;

sub parse {
  my $self = shift;

  $$self->add_tokendata(
    foundry => 'cmc',
    layer => 'morpho',
    cb => sub {
      my ($stream, $token) = @_;
      my $mtt = $stream->pos($token->pos);

      my $content = $token->hash->{fs}->{f};

      my $found;

      foreach my $f (@{$content->{fs}->{f}}) {

        # pos tag
        if (($f->{-name} eq 'pos') &&
              ($found = $f->{'#text'})) {
          $mtt->add(term => 'cmc/p:' . $found);
        }

        # lemma tag
        elsif (($f->{-name} eq 'lemma')
                 && ($found = $f->{'#text'})) {
          $mtt->add(term => 'cmc/l:' . $found);
        };
      };
    }) or return;
  return 1;
};

sub layer_info {
  ['cmc/l=tokens', 'cmc/p=tokens']
}

1;
