package KorAP::XML::Annotation::Sgbr::Morpho;
use KorAP::XML::Annotation::Base;

sub parse {
  my $self = shift;

  $$self->add_tokendata(
    foundry => 'sgbr',
    layer => 'ana',
    cb => sub {
      my ($stream, $token) = @_;
      my $mtt = $stream->pos($token->get_pos);

      my $found;
      my $content = $token->get_hash->{fs}->{f};
      my $pos = (ref $content->{fs}->{f} eq 'ARRAY') ?
        $content->{fs}->{f} : [$content->{fs}->{f}];

      # Iterate over all lemmata
      foreach my $f (@$pos) {

        # lemma
        if (($f->{-name} eq 'ctag')
              && ($found = $f->{'#text'})) {
          # b($found)->decode('latin-1')->encode->to_string
          $mtt->add(term => 'sgbr/p:' . $found);
        };
      };
    }) or return;

  return 1;
};

sub layer_info {
  ['sgbr/p=tokens']
};

1;
