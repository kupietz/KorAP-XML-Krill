package KorAP::XML::Index::Mate::Dependency;
use KorAP::XML::Index::Base;

our $NODE_LABEL = 'NODE';

sub parse {
  my $self = shift;

  # TODO: Create XIP tree here - for indirect dependency
  # >>:xip/d:SUBJ<i>566<i>789

  # Relation data
  $$self->add_tokendata(
    foundry => 'mate',
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

	# Relation type is unary
	# Unary means, it refers to itself!
	if ($_->{-type} && $_->{-type} eq 'unary') {

	  # I have no clue, what -- should mean
	  # next if $_->{-label} eq '--';

	  # Target is at the same position!
	  my $pos = $source->pos;


	  # Get target node - not very elegant
	  my $target = $stream->get_node(
	    $pos, 'mate/d:' . $NODE_LABEL
	  );

	  my %rel = (
	    pti => 32, # term-to-term relation
	    payload =>
	      '<i>' . $pos . # right part token position
		'<s>' . $target->tui . # left part tui
		  '<s>' . $target->tui # right part tui
		);

	  # Add relations
	  $mtt->add(
	    term => '>:mate/d:' . $label,
	    %rel
	  );
	  $mtt->add(
	    term => '<:mate/d:' . $label,
	    %rel
	  );
	}

	# Not unary
	elsif (!$_->{type}) {

	  # Get information about the target token
	  my $from = $_->{span}->{-from};
	  my $to   = $_->{span}->{-to};

	  # Target
	  my $target = $tokens->token($from, $to);

	  if ($target) {
	    # Relation is term-to-term with a found target!

	    # Get source node
	    my $source_term = $stream->get_node(
	      $source->pos, 'mate/d:' . $NODE_LABEL
	    );

	    # Get target node
	    my $target_term = $stream->get_node(
	      $target->pos, 'mate/d:' . $NODE_LABEL
	    );

	    $mtt->add(
	      term => '>:mate/d:' . $label,
	      pti => 32, # term-to-term relation
	      payload =>
		'<i>' . $target->pos . # right part token position
		  '<s>' . $source_term->tui . # left part tui
		    '<s>' . $target_term->tui # right part tui
		  );

	    my $target_mtt = $stream->pos($target->pos);
	    $target_mtt->add(
	      term => '<:mate/d:' . $label,
	      pti => 32, # term-to-term relation
	      payload =>
		'<i>' . $target->pos . # right part token position (TODO: THIS IS PROBABLY WRONG!)
		  '<s>' . $source_term->tui . # left part tui
		    '<s>' . $target_term->tui # right part tui

	    );
	  }
	  else {

	    # TODO: SPANS not yet supported
	    next;
	  };


	  # Temporary
	  next;

	  $mtt->add(
	    term => '>:mate/d:' . $label,
	    payload => '<i>' . $target->pos
	  );

	  $stream->pos($target->pos)->add(
	    term => '<:mate/d:' . $label,
	    payload => '<i>' . $source->pos
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
