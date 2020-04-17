package KorAP::XML::Annotation::RWK::Morpho;
use KorAP::XML::Annotation::Base;

sub parse {
  my $self = shift;

  $$self->add_tokendata(
    foundry => 'rwk',
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
          $mtt->add(term => 'rwk/p:' . $found);
        }

        # normtok tag
        elsif (($f->{-name} eq 'normtok') &&
              ($found = $f->{'#text'})) {
          $mtt->add(term => 'rwk/norm:' . $found);
        }

        # ana tag
        elsif ($f->{-name} eq 'rfpos' &&
                 ($found = $f->{'#text'})) {
          $mtt->add(term => 'rwk/m:' . $found);
        }

        # lemma tag
        elsif (($f->{-name} eq 'lemma')
                 && ($found = $f->{'#text'})
                 && $found ne '--') {
          $mtt->add(term => 'rwk/l:' . $found);
        };
      };
    }) or return;
  return 1;
};

sub layer_info {
  ['rwk/l=tokens', 'rwk/p=tokens', 'rwk/m=tokens', 'rwk/normtok=tokens']
}

1;
