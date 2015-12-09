package KorAP::Index::Struct::Structure;
use KorAP::Index::Base;
use Scalar::Util 'weaken';
use Data::Dumper;

# Support attributes using token-unique identifiers!

sub parse {
  my $self = shift;
  my $i = 0;

  my $depth = 0;
  my $tui = 0;

  # Build tree structure!
  my @mtt = ();

  # Range for tree depth
  # my $range = Array::IntSpan->new;

  $$self->add_spandata(
    foundry => 'struct',
    layer => 'structure',
    cb => sub {
      my ($stream, $span) = @_;

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
      };

      # Get term label
      my $name = $feature->{'#text'};

      # Add the element to the stream
      push(@mtt, {
	term    => '<>:dereko/s:' . $name,
	o_start => $span->o_start,
	o_end   => $span->o_end,
	p_start => $p_start,
	p_end   => $span->p_end,
	pti     => $span->milestone ? 65 : 64
      });

      # Get the mtt
      # my $mtt = $stream->pos($p_start);
      # my $unit = $mtt->add(...)
      # payload => '<b>' . $depth . ($tui ? '<s>' . $tui : ''),
      # $tui = $stream->tui($p_start);

      # Add attributes
      if ($attrs) {

	# Set a tui if attributes are set
	foreach (@$attrs) {

	  # Add attributes
	  push(@mtt, {
	    term =>
	      '@:dereko/s:' . $_->{'-name'} . ':' . $_->{'#text'},
	    p_start => $p_start,
	    p_end   => $span->p_end,
	    pti     => 17
	  });

	  # '<s>' . $tui
	  # $unit = $mtt->add(
	  # warn $unit->to_string;
	};
      };

      $i++;
    }
  ) or return;






  $$self->stream->add_meta('dereko/sentences', '<i>' . $i);

  return 1;
};

sub layer_info {
    ['dereko/s=spans'];
};

1;
