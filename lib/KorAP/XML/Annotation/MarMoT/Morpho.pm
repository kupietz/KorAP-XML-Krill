package KorAP::XML::Annotation::MarMoT::Morpho;
use KorAP::XML::Annotation::Base;

sub parse {
  my $self = shift;

  $$self->add_tokendata(
    foundry => 'marmot',
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
          $mtt->add_by_term('marmot/p:' . $found);
        }

        # msd tag
        elsif ($f->{-name} eq 'msd' &&
                 ($found = $f->{'#text'})) {

          # Split all values
          foreach (split '\|', $found) {
            my ($x, $y) = split "=", $_;
            # case, tense, number, mood, person, degree, gender
            $mtt->add_by_term('marmot/m:' . $x . ($y ? ':' . $y : ''));
          };
        };
      };
    }) or return;
  return 1;
};

sub layer_info {
  ['marmot/p=tokens', 'marmot/m=tokens']
}

1;
