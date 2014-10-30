package KorAP::Index::CoreNLP::NamedEntities;
use KorAP::Index::Base;

sub parse {
  my $self   = shift;
  my $model  = shift;

  $$self->add_tokendata(
    foundry => 'corenlp',
    layer => $model // lc('NamedEntities'),
    cb => sub {
      my ($stream, $token) = @_;
      my $mtt = $stream->pos($token->pos);

      my $content = $token->hash->{fs}->{f} or return;
      my $found;

      if (($content->{-name} eq 'ne') &&
	    ($found = $content->{fs}) &&
	      ($found = $found->{f}) &&
		($found->{-name} eq 'ent') &&
		  ($found = $found->{'#text'})) {
	$mtt->add(
	  term => 'corenlp/ne:' . $found
	);
      };
    }) or return;

  return 1;
};

sub layer_info {
    ['corenlp/ne=tokens'];
};

1;
