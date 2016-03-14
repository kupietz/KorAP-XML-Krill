package KorAP::XML::Annotation::CoreNLP::Morpho;
use KorAP::XML::Annotation::Base;

sub parse {
  my $self = shift;

  $$self->add_tokendata(
    foundry => 'corenlp',
    layer => 'morpho',
    cb => sub {
      my ($stream, $token) = @_;
      my $mtt = $stream->pos($token->pos);

      my $content = $token->hash->{fs}->{f} or return;
      $content = $content->{fs}->{f};

      # syntax
      if (($content->{-name} eq 'pos') && ($content->{'#text'})) {
	$mtt->add(
	  term => 'corenlp/p:' . $content->{'#text'}
	);
      };
    }) or return;

  return 1;
};

sub layer_info {
  ['corenlp/p=tokens'];
};

1;
