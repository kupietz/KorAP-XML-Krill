package KorAP::XML::Annotation::HNC::Morpho;
use KorAP::XML::Annotation::Base;

sub parse {
  my $self = shift;

  $$self->add_tokendata(
    foundry => 'hnc',
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
          $mtt->add(term => 'hnc/p:' . $found);
        }

        # ana tag
        elsif ($f->{-name} eq 'msd' &&
                 ($found = $f->{'#text'})) {

          # Unknown annotation
          next if $found eq '__NA__';

          # Split at semicolons
          foreach (split ';;', $found) {
            my ($x, $y) = split "=", $_;
            # compound,hyphenated,stem,morphemes,mboundary
            $mtt->add(term => 'hnc/m:' . $x . ($y ? ':' . $y : ''));
          };
        }

        # lemma tag
        elsif (($f->{-name} eq 'lemma')
                 && ($found = $f->{'#text'})
                 && $found ne '--') {
          # b($found)->decode('latin-1')->encode->to_string
          $mtt->add(term => 'hnc/l:' . $found);
        };
      };
    }) or return;
  return 1;
};

sub layer_info {
  ['hnc/l=tokens', 'hnc/p=tokens', 'hnc/m=tokens']
}

1;
