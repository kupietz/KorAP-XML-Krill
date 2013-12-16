package KorAP::Index::OpenNLP::Morpho;
use KorAP::Index::Base;

sub parse {
  my $self = shift;

  $$self->add_tokendata(
    foundry => 'opennlp',
    layer => 'morpho',
    cb => sub {
      my ($stream, $token) = @_;
      my $mtt = $stream->pos($token->pos);

      my $content = $token->hash->{fs}->{f} or return;

      $content = $content->{fs}->{f};
      my $found;

      # syntax
      if (($content->{-name} eq 'pos') && ($content->{'#text'})) {
	$mtt->add(
	  term => 'opennlp/p:' . $content->{'#text'}
	);
      };
    }) or return;

  return 1;
};

sub layer_info {
    ['opennlp/p=pos'];
};

1;
