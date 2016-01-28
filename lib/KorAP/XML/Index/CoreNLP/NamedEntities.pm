package KorAP::XML::Index::CoreNLP::NamedEntities;
use KorAP::XML::Index::Base;

# Import named entities, potentially with a specified
# Model. However - now all models are mapped to the 'ne'-Prefix
# and are indistinguishable in annotations. However - if only one
# model is used, the model is listed in the foundries.
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
