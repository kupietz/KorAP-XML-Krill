package KorAP::XML::Annotation::Gingko::Morpho;
use KorAP::XML::Annotation::Base;

sub parse {
  my $self = shift;

  $$self->add_tokendata(
    foundry => 'gingko',
    layer => 'morpho',
    cb => sub {
      my ($stream, $token) = @_;
      my $mtt = $stream->pos($token->get_pos);

      my $content = $token->get_hash->{fs}->{f};

      my $found;

      my $name;
      foreach my $f (@{$content->{fs}->{f}}) {

        $name = $f->{-name};

        # pos tag
        if (($name eq 'pos') &&
              ($found = $f->{'#text'})) {
          $mtt->add_by_term('ginkgo/p:' . $found);
        }

        # lemma tag
        elsif (($name eq 'lemma')
                 && ($found = $f->{'#text'})
                 && $found ne '<unknown>') {
          $mtt->add_by_term('gingko/l:' . $found);
        };
      };
    }) or return;
  return 1;
};

sub layer_info {
  ['gingko/l=tokens', 'gingko/p=tokens']
}

1;
