package KorAP::XML::Annotation::XIP::Dependency;
use KorAP::XML::Annotation::Base;

# > source to target
# < target to source

sub parse {
  my $self = shift;

  # Phrase depencies are currently ignored.

  my $rel_id = 1;

  # XIP dependencies are currently skipped
  return;

  $$self->add_tokendata(
    foundry => 'xip',
    layer => 'dependency',
    encoding => 'xip',
    cb => sub {
      my ($stream, $token, $tokens) = @_;
      my $mtt = $stream->pos($token->pos);

      my $content = $token->hash;

      my $rel = $content->{rel};
      $rel = [$rel] unless ref $rel eq 'ARRAY';

      foreach (@$rel) {
	my $label = $_->{-label};

	# Relation is "unary" - meaning relation to itself
	if ($_->{-type} && $_->{-type} eq 'unary') {
	  $mtt->add(
	    term => '>:xip/d:' . $label,
	    payload => '<i>' . $token->pos
	  );
	  $mtt->add(
	    term => '<:xip/d:' . $label,
	    payload => '<i>' . $token->pos
	  );
	}
	else {

	  my $from = $_->{span}->{-from};
	  my $to   = $_->{span}->{-to};

	  my $rel_token = $tokens->token($from, $to) or next;

	  # die $token->pos . ' -' . $label . '-> ' . $rel_token->pos;
	  $mtt->add(
	    term => '>:xip/d:' . $label,
	    payload => '<i>' . $rel_token->pos
	  );

	  $stream->pos($rel_token->pos)->add(
	    term => '<:xip/d:' . $label,
	    payload => '<i>' . $token->pos
	  );
	};

#	print $label,"\n";
      };
    }) or return;

  return 1;
};

sub layer_info {
  ['xip/d=rels']
}


1;
