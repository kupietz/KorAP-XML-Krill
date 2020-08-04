package KorAP::XML::Annotation::Mate::MorphoAttr;
use KorAP::XML::Annotation::Base;

# This attaches morphological information as attributes to the pos

sub parse {
  my $self = shift;

  $$self->add_tokendata(
    foundry => 'mate',
    layer => 'morpho',
    cb => sub {
      my ($stream, $token) = @_;
      my $mtt = $stream->pos($token->get_pos);

      my $content = $token->get_hash->{fs}->{f};

      my ($found, $pos, $msd, $tui);

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
          $tui = $mtt->id_counter;
        };
      };

      my %term = (
        term => 'mate/p:' . $pos
      );

      # There are attributes needed
      if ($tui) {
        $term{pti} = 128;
        $term{payload} = '<s>' . $tui
      };

      $mtt->add(%term);

      # MSD
      if ($msd) {
        foreach (split '\|', $msd) {
          my ($x, $y) = split "=", $_;
          # case, tense, number, mood, person, degree, gender
          $mtt->add(
            term => '@:' . $x . ($y ? '=' . $y : ''),
            pti => 16,
            payload => '<s>' . $tui
          );
        };
      };
    }) or return;

  return 1;
};

sub layer_info {
  ['mate/l=tokens', 'mate/p=tokens']
};

1;
