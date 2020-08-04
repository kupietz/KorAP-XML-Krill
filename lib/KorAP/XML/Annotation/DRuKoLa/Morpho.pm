package KorAP::XML::Annotation::DRuKoLa::Morpho;
use KorAP::XML::Annotation::Base;

sub parse {
  my $self = shift;

  $$self->add_tokendata(
    foundry => 'drukola',
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
          $mtt->add_by_term('drukola/p:' . $found);
        }

        # ana tag
        elsif ($name eq 'msd' &&
                 ($found = $f->{'#text'})) {
          my ($pos, $msd) = split(/ /, $found);
          if ($msd) {
            $mtt->add_by_term('drukola/p:' . $pos);
          }
          else {
            $msd = $pos;
          };

          # Split all values
          foreach (split '\|', $msd) {
            my ($x, $y) = split "=", $_;
            # case, tense, number, mood, person, degree, gender
            $mtt->add_by_term('drukola/m:' . $x . ($y ? ':' . $y : ''));
          };
        }

        # lemma tag
        elsif (($name eq 'lemma')
                 && ($found = $f->{'#text'})
                 && $found ne '--') {
          # b($found)->decode('latin-1')->encode->to_string
          $mtt->add_by_term('drukola/l:' . $found);
        };
      };
    }) or return;
  return 1;
};

sub layer_info {
  ['drukola/l=tokens', 'drukola/p=tokens', 'drukola/m=tokens']
}

1;
