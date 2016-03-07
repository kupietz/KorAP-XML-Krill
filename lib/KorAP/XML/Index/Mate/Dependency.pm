package KorAP::XML::Index::Mate::Dependency;
use KorAP::XML::Index::Base;
use strict;
use warnings;
our $NODE_LABEL = '&&&';

sub parse {
  my $self = shift;

  # TODO: Create XIP tree here - for indirect dependency
  # >>:xip/d:SUBJ<i>566<i>789

  # Relation data
  # Supports term-to-term and term-to-element only
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

	  # Get target node - not very elegant
	  # This is only necessary for nodes with attributes
	  #	  my $target = $stream->get_node(
	  #	    $source, 'mate/d:' . $NODE_LABEL
	  #	  );

	  # Target is at the same position!
	  my $pos = $source->pos;

	  my %rel = (
	    pti => 32, # term-to-term relation
	    payload =>
	      '<i>' . $pos # . # right part token position
#		'<s>0' . # $target->tui . # left part tui
#		  '<s>0'  # . $target->tui # right part tui
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

	  # Get source node
	  # This is only necessary for nodes with attributes
	  #	  my $source_term = $stream->get_node(
	  #	    $source, 'mate/d:' . $NODE_LABEL
	  #	  );

	  # Target
	  my $target = $tokens->token($from, $to);

	  # Relation is term-to-term with a found target!
	  if ($target) {

	    # Get target node
	    #	    my $target_term = $stream->get_node(
	    #	      $target, 'mate/d:' . $NODE_LABEL
	    #	    );

	    $mtt->add(
	      term => '>:mate/d:' . $label,
	      pti => 32, # term-to-term relation
	      payload =>
		'<i>' . $target->pos # . # right part token position
#		  '<s>0' . # $source_term->tui . # left part tui
#		    '<s>0' # . $target_term->tui # right part tui
	    );

	    my $target_mtt = $stream->pos($target->pos);
	    $target_mtt->add(
	      term => '<:mate/d:' . $label,
	      pti => 32, # term-to-term relation
	      payload =>
		'<i>' . $source->pos # . # left part token position
#		  '<s>0' . # $source_term->tui . # left part tui
#		    '<s>0' # . $target_term->tui # right part tui
	    );
	  }

	  # Relation is possibly term-to-element with a found target!
	  elsif ($target = $tokens->span($from, $to)) {

	    # Get target node
	    #	    my $target_span = $stream->get_node(
	    #	      $target, 'mate/d:' . $NODE_LABEL
	    #	    );

	    $mtt->add(
	      term => '>:mate/d:' . $label,
	      pti => 33, # term-to-element relation
	      payload =>
		'<i>' . $target->o_start . # end position
		  '<i>' . $target->o_end . # end position
		    '<i>' . $target->p_start . # right part start position
		      '<i>' . $target->p_end # . # right part end position
#			'<s>0' . # $source_term->tui . # left part tui
#			  '<s>0' # . $target_span->tui # right part tui
	    );

	    my $target_mtt = $stream->pos($target->p_start);
	    $target_mtt->add(
	      term => '<:mate/d:' . $label,
	      pti => 34, # element-to-term relation
	      payload =>
		'<i>' . $target->o_start . # end position
		  '<i>' . $target->o_end . # end position
		    '<i>' . $target->p_end . # right part end position
		      '<i>' . $source->pos # . # left part token position
#			'<s>0' . # $source_term->tui . # left part tui
#			  '<s>0' # . $target_span->tui # right part tui

	    );
	  }
	  else {
	    #	    use Data::Dumper;
	    #	    warn '2###### ' . Dumper($content);
	  };
	};
      };
    }) or return;

  return 1;
};

sub layer_info {
  ['mate/d=rels']
};

1;

__END__
