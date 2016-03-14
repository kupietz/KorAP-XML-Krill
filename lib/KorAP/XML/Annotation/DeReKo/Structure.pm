package KorAP::XML::Annotation::DeReKo::Structure;
use KorAP::XML::Annotation::Base;
use Data::Dumper;

sub parse {
  my $self = shift;

  $$self->add_spandata(
    foundry => 'struct',
    layer => 'structure',
    cb => sub {
      my ($stream, $span) = @_;
      my $tui = 0;

      # Get starting position
      my $p_start = $span->p_start;

      # Read feature
      my $feature = $span->hash->{fs}->{f};
      my $attrs;

      # Get attributes
      if (ref $feature eq 'ARRAY') {
	$attrs = $feature->[1]->{fs}->{f};
	$attrs = ref $attrs eq 'ARRAY' ? $attrs : [$attrs];
	$feature = $feature->[0];
	$tui = $stream->tui($p_start);
      };

      # Get term label
      my $name = $feature->{'#text'};

      # Get the mtt
      my $mtt = $stream->pos($p_start);

      my $p_end = $span->p_end;

      # Add structure
      my $mt = $mtt->add(
	term    => '<>:dereko/s:' . $name,
	o_start => $span->o_start,
	o_end   => $span->o_end,
	p_start => $p_start,
	p_end   => $p_end,
	pti     => $span->milestone ? 65 : 64,
      );

      my $level = $span->hash->{'-l'};
      if ($level || $tui) {
	my $pl;
	$pl .= '<b>' . ($level ? $level - 1 : 0);
	$pl .= '<s>' . $tui if $tui;
	$mt->payload($pl);
      };

      # Add attributes
      if ($attrs) {

	# Set a tui if attributes are set
	foreach (@$attrs) {

	  # Add attributes
	  $mtt->add(
	    term =>
	      '@:dereko/s:' . $_->{'-name'} . ':' . $_->{'#text'},
	    p_start => $p_start,
	    pti     => 17,
	    payload => '<s>' . $tui .
	      ($span->milestone ? '' : '<i>' . $p_end)
	  );
	};
      };
    }
  ) or return;

  return 1;
};

sub layer_info {
  ['dereko/s=spans'];
};

1;
