package KorAP::XML::Annotation::Malt::Dependency;
use KorAP::XML::Annotation::Base;

sub parse {
  my $self = shift;

  # TODO: Create XIP tree here - for indirect dependency
  # >>:xip/d:SUBJ<i>566<i>789

  # Relation data
  $$self->add_tokendata(
    foundry => 'malt',
    layer => 'dependency',
    cb => sub {
      my ($stream, $source, $tokens) = @_;

      # Get MultiTermToken from stream for source
      my $mtt = $stream->pos($source->pos);

      # Serialized information from token
      my $content = $source->hash;

      # Get relation information
      my $rel = $content->{rel};
      $rel = [$rel] unless ref $rel eq 'ARRAY';

      # Iterate over relations
      foreach (@$rel) {
	my $label = $_->{-label};


	  #my $target = $stream->tui($source->pos);

	  # Unary means, it refers to itself!
	  $mtt->add(
	    term => 'mate/d:' . $label
	  );

#	  $mtt->add(
#	    term => '>:mate/d:' . $label,
#	  );


	  my $from = $_->{span}->{-from};
	  my $to   = $_->{span}->{-to};

	  my $rel_token = $tokens->token($from, $to) or next;

	  $mtt->add(
	    term => '>:mate/d:' . $label,
	    payload => '<i>' . $rel_token->pos
	  );

	  $stream->pos($rel_token->pos)->add(
	    term => '<:mate/d:' . $label,
	    payload => '<i>' . $token->pos
	  );
	};
      };
    }) or return;

  return 1;
};

sub layer_info {
  ['mate/d=rels']
};


1;
