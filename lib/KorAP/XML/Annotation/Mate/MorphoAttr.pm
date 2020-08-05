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

      my $mt;

      foreach my $f (@{$content->{fs}->{f}}) {

        #pos
        if (($f->{-name} eq 'pos') && ($found = $f->{'#text'})) {
          $pos = $found;
        }

        # lemma
        elsif (($f->{-name} eq 'lemma')
                 && ($found = $f->{'#text'})
                 && $found ne '--') {
          $mtt->add_by_term('mate/l:' . $found);
        }

        # MSD
        elsif (($f->{-name} eq 'msd') &&
                 ($found = $f->{'#text'}) &&
                 ($found ne '_')) {
          $msd = $found;
          $tui = $mtt->id_counter;
        };
      };

      $mt = $mtt->add_by_term('mate/p:' . $pos);

      # There are attributes needed
      if ($tui) {
        $mt->set_pti(128);
        $mt->set_payload('<s>' . $tui);
      };

      # MSD
      if ($msd) {
        foreach (split '\|', $msd) {
          my ($x, $y) = split "=", $_;
          # case, tense, number, mood, person, degree, gender
          $mt = $mtt->add_by_term('@:' . $x . ($y ? '=' . $y : ''));
          $mt->set_pti(16);
          $mt->set_payload('<s>' . $tui);
        };
      };
    }) or return;

  return 1;
};

sub layer_info {
  ['mate/l=tokens', 'mate/p=tokens']
};

1;
