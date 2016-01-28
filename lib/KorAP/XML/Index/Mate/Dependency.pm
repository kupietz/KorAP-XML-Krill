package KorAP::XML::Index::Mate::Dependency;
use KorAP::XML::Index::Base;

sub parse {
  my $self = shift;

  # TODO: Create XIP tree here - for indirect dependency
  # >>:xip/d:SUBJ<i>566<i>789

  # Relation data
  $$self->add_tokendata(
    foundry => 'mate',
    layer => 'dependency',
    cb => sub {
      my ($stream, $token, $tokens) = @_;

      # Get MultiTermToken from stream
      my $mtt = $stream->pos($token->pos);

      # Serialized information from token
      my $content = $token->hash;

      # Get relation information
      my $rel = $content->{rel};
      $rel = [$rel] unless ref $rel eq 'ARRAY';

      # Iterate over relations
      foreach (@$rel) {
	my $label = $_->{-label};

	# Relation type
	if ($_->{-type} && $_->{-type} eq 'unary') {
	  next if $_->{-label} eq '--';
	  $mtt->add(
	    term => 'mate/d:' . $label
	  );
	}
	else {

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
