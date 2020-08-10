package KorAP::XML::Annotation::Sgbr::Lemma;
use KorAP::XML::Annotation::Base;
use Mojo::ByteStream 'b';

sub parse {
  my $self = shift;

  $$self->add_tokendata(
    foundry => 'sgbr',
    layer => 'lemma',
    cb => sub {
      my ($stream, $token) = @_;
      my $mtt = $stream->pos($token->get_pos);

      my $content = $token->get_hash->{fs}->{f};

      my $found;

      my $lemmata = (ref $content->{fs}->{f} eq 'ARRAY') ?
        $content->{fs}->{f} : [$content->{fs}->{f}];

      my $first = 0;

      # Iterate over all lemmata
      foreach my $f (@$lemmata) {

        # lemma
        if (($f->{-name} eq 'lemma')
              && ($found = $f->{'#text'})) {

          unless ($first++) {
            $mtt->add_by_term('sgbr/l:' . $found);
          }
          else {
            $mtt->add_by_term('sgbr/lv:' . $found);
          };
        };
      };
    }) or return;

  return 1;
};

sub layer_info {
  ['sgbr/l=tokens', 'sgbr/lv=tokens']
}

1;
