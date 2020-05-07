package KorAP::XML::Annotation::DGD::Structure;
use KorAP::XML::Annotation::Base;
use List::Util qw/uniq/;

# This handler introduces pseudo sentences
# based on anchor texts in AGD. A sentence is defined as
# being the span between
#   a) two empty anchor elements, or
#   b) an anchor element and the start of the doc, or
#   c) an anchor element and the end of the doc.

sub parse {
  my $self = shift;

  my @milestones = ();
  my ($p_start, $o_start) = (0,0);
  my ($last_p, $last_o) = (0,0);

  $$self->add_spandata(
    foundry => 'struct',
    layer => 'structure',
    cb => sub {
      my ($stream, $span) = @_;

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

      # Check only for anchors
      if ($name eq 'anchor') {
        push @milestones, [ $span->p_start, $span->o_start ];
      } else {
        $last_p = $span->p_start;
        $last_o = $span->o_end;
      }
    }
  ) or return;

  my $sentences = 0;

  # Add final position
  push @milestones, [$last_p, $last_o];

  # Sort and unique milestones
  @milestones = sort {
    $a->[0] <=> $b->[0]
  } @milestones;

  my $stream = $$self->stream;

  # Iterate overs milestones
  foreach (@milestones) {

    if (($_->[0] == $p_start) || ($_->[1] == $o_start)) {
      next;
    };

    my $mtt = $stream->pos($p_start);

    # Add the base sentence
    my $mt = $mtt->add(
      term    => '<>:base/s:s',
      o_start => $o_start,
      o_end   => $_->[1],
      p_start => $p_start,
      p_end   => $_->[0],
      pti     => 64
    );
    $mt->payload('<b>1');
    $sentences++;

    $p_start = $_->[0];
    $o_start = $_->[1];
  }

  # Set meta information about sentence count
  $stream->add_meta('base/sentences', '<i>' . $sentences);

  return 1;
};

sub layer_info {
  [];
};


1;

__END__
