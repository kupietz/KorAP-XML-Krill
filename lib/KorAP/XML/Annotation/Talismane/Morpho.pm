package KorAP::XML::Annotation::Talismane::Morpho;
use KorAP::XML::Annotation::Base;

sub parse {
  my $self = shift;

  $$self->add_tokendata(
    foundry => 'talismane',
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
          $mtt->add(term => 'talismane/p:' . $found);
        }

        # ana tag
        elsif ($f->{-name} eq 'msd' &&
                 ($found = $f->{'#text'})) {
          my ($pos, $msd) = split(/ /, $found);
          if ($msd) {
            $mtt->add(term => 'talismane/p:' . $pos);
          }
          else {
            $msd = $pos;
          };

          # Split all values
          foreach (split '\|', $msd) {
            my ($x, $y) = split "=", $_;
            # case, tense, number, mood, person, degree, gender
            $mtt->add(term => 'talismane/m:' . $x . ($y ? ':' . $y : ''));
          };
        }

        # lemma tag
        elsif (($f->{-name} eq 'lemma')
                 && ($found = $f->{'#text'})
                 && $found ne '--' && $found ne '_') {
          # b($found)->decode('latin-1')->encode->to_string
          $mtt->add(term => 'talismane/l:' . $found);
        };
      };
    }) or return;
  return 1;
};

sub layer_info {
  ['talismane/l=tokens', 'talismane/p=tokens', 'talismane/m=tokens']
}

1;
