package KorAP::XML::Annotation::TreeTagger::Morpho;
use KorAP::XML::Annotation::Base;
use POSIX 'floor';

sub parse {
  my $self = shift;

  $$self->add_tokendata(
    foundry => 'tree_tagger',
    layer => 'morpho',
    cb => sub {
      my ($stream, $token) = @_;
      my $mtt = $stream->pos($token->get_pos);

      my $content = $token->get_hash->{fs}->{f};

      my $found;

      $content = ref $content ne 'ARRAY' ? [$content] : $content;

      my (%lemma, %pos) = ();

      # Iterate over feature structures
      foreach my $fs (@$content) {
        $content = $fs->{fs}->{f};

        my @val;
        my $certainty = 0;
        foreach (@$content) {
          if ($_->{-name} eq 'certainty') {
            $certainty = $_->{'#text'};
          }
          else {
            push @val, $_
          };
        };

        # Iterate over values
        foreach (@val) {
          # lemma
          if (($_->{-name} eq 'lemma') &&
                ($found = $_->{'#text'}) &&
                ($found ne 'UNKNOWN') &&
                ($found ne '?')) {
            $lemma{$found} += $certainty // 1;
          };

          # pos
          if (($_->{-name} eq 'ctag') && ($found = $_->{'#text'})) {

            $pos{$found} += $certainty // 1;
          };
        };
      };

      my %term;
      foreach (keys %lemma) {
        if ($lemma{$_} < 1) {
          $mtt->add(
            term => 'tt/l:' . $_,
            pti => 129,
            payload => '<b>' . floor(($lemma{$_} * 255))
          );
        } else {
          $mtt->add(term => 'tt/l:' . $_);
        };
      };

      foreach (keys %pos) {
        if ($pos{$_} < 1) {
          $mtt->add(
            term => 'tt/p:' . $_,
            pti => 129,
            payload => '<b>' . floor(($pos{$_} * 255))
          );
        } else {
          $mtt->add(term => 'tt/p:' . $_);
        };
      };

    }) or return;

  return 1;
};

sub layer_info {
  ['tt/p=tokens', 'tt/l=tokens']
};

1;
