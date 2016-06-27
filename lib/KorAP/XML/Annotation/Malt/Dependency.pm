package KorAP::XML::Annotation::Malt::Dependency;
use KorAP::XML::Annotation::Base;
use strict;
use warnings;

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
	my $from = $_->{span}->{-from};
	my $to   = $_->{span}->{-to};

	# Target
	my $target = $tokens->token($from, $to);

	# Relation is term-to-term with a found target!
	if ($target) {

	  # Unary means, it refers to itself!
	  $mtt->add(
	    term => '>:malt/d:' . $label,
	    pti => 32, # term-to-term relation
	    payload =>
	      '<i>' . $target->pos # . # right part token position
		# '<s>0' . # $source_term->tui . # left part tui
		# '<s>0' # . $target_term->tui # right part tui
	    );

	  my $target_mtt = $stream->pos($target->pos);

	  $target_mtt->add(
	    term => '<:malt/d:' . $label,
	    pti => 32, # term-to-term relation
	    payload =>
	      '<i>' . $source->pos # . # left part token position
		# '<s>0' . # $source_term->tui . # left part tui
		# '<s>0' # . $target_term->tui # right part tui
	    );
	}

	# Relation is possibly term-to-element with a found target!
	elsif ($target = $tokens->span($from, $to)) {
	  $mtt->add(
	    term => '>:malt/d:' . $label,
	    pti => 33, # term-to-element relation
	    payload =>
	      '<i>' . $target->o_start . # end position
		'<i>' . $target->o_end . # end position
		  '<i>' . $target->p_start . # right part start position
		    '<i>' . $target->p_end # . # right part end position
		      # '<s>0' . # $source_term->tui . # left part tui
		      # '<s>0' # . $target_span->tui # right part tui
	    );

	  my $target_mtt = $stream->pos($target->p_start);
	  $target_mtt->add(
	    term => '<:malt/d:' . $label,
	    pti => 34, # element-to-term relation
	    payload =>
	      '<i>' . $target->o_start . # end position
		'<i>' . $target->o_end . # end position
		  '<i>' . $target->p_end . # right part end position
		    '<i>' . $source->pos # . # left part token position
		      #	'<s>0' . # $source_term->tui . # left part tui
		      # '<s>0' # . $target_span->tui # right part tui

	    );
	}
	else {
	  use Data::Dumper;
	  $tokens->log->warn('Relation currently not supported: ' . Dumper($content));
	};
      };
    }) or return;

  return 1;
};

sub layer_info {
  ['malt/d=rels']
};


1;
