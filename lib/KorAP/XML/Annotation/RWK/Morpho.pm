package KorAP::XML::Annotation::RWK::Morpho;
use KorAP::XML::Annotation::Base;

sub parse {
  my $self = shift;

  $$self->add_tokendata(
    foundry => 'rwk',
    layer => 'morpho',
    cb => sub {
      my ($stream, $token) = @_;
      my $mtt = $stream->pos($token->get_pos);

      my $content = $token->get_hash->{fs}->{f};

      my $found;

      foreach my $f (@{$content->{fs}->{f}}) {

        my $name = lc($f->{-name});

        # pos tag
        if (($name eq 'pos') &&
              ($found = $f->{'#text'})) {
          $mtt->add_by_term('rwk/p:' . $found);
        }

        # normtok tag
        elsif (($name eq 'normtok') &&
              ($found = $f->{'#text'})) {
          $mtt->add_by_term('rwk/norm:' . $found);
        }

        # lemma tag
        elsif (($name eq 'lemma')
                 && ($found = $f->{'#text'})
                 && $found ne '--') {
          $mtt->add_by_term('rwk/l:' . $found);
        }

        # ana tag
        elsif ($name =~ m/^(?:bc|(?:sub)?type|usage|person|pos|case|number|gender|tense|mood|degree)$/ &&
                 ($found = $f->{'#text'})) {
          $mtt->add_by_term('rwk/m:' . $name . ':' . $found);
        };
      };
    }) or return;
  return 1;
};

sub layer_info {
  ['rwk/l=tokens', 'rwk/p=tokens', 'rwk/m=tokens', 'rwk/normtok=tokens']
}

1;
