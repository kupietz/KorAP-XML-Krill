package KorAP::XML::Annotation::UDPipe::Morpho;
use KorAP::XML::Annotation::Base;

sub parse {
  my $self = shift;

  $$self->add_tokendata(
    foundry => 'ud',
    layer => 'morpho',
    cb => sub {
      my ($stream, $token) = @_;
      my $mtt = $stream->pos($token->get_pos);

      my $content = $token->get_hash->{fs}->{f};

      my $found;

      # If no array - make array
      my $fs_array = ref($content->{fs}->{f}) eq 'ARRAY' ?
        $content->{fs}->{f} : [$content->{fs}->{f}];

      foreach my $f (@$fs_array) {

        # pos tag
        if (($f->{-name} eq 'pos') &&
              ($found = $f->{'#text'})) {
          $mtt->add_by_term('ud/p:' . $found);
        }

        # lemma tag
        elsif (($f->{-name} eq 'lemma') &&
            ($found = $f->{'#text'})) {
            $mtt->add_by_term('ud/l:' . $found);
        }

        # msd tag
        elsif ($f->{-name} eq 'msd' &&
                 ($found = $f->{'#text'})) {

          # Split all values
          foreach (split '\|', $found) {
            my ($x, $y) = split "=", lc($_);
            # case, tense, number, mood, person, degree, gender
            $mtt->add_by_term('ud/m:' . $x . ($y ? ':' . $y : ''));
          };
        };
      };
    }) or return;
  return 1;
};

sub layer_info {
  ['ud/p=tokens', 'ud/l=tokens', 'ud/m=tokens']
}

1;
