package KorAP::XML::Annotation::RWK::Structure;
use KorAP::XML::Annotation::Base;

sub parse {
  my $self = shift;

  my %milestones = (
    s => [],
    p => [],
  );

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
      if ($name eq 's-milestone') {
        push @{$milestones{s}}, [ $span->p_start, $span->o_start ];
      }
      elsif ($name eq 'p-milestone') {
        push @{$milestones{p}}, [ $span->p_start, $span->o_start ];
      }
      else {
        $last_p = $span->p_start;
        $last_o = $span->o_end;
      }
    }
  ) or return;

  my ($sentences, $paragraphs) = (0, 0);

  # Add final position
  push @{$milestones{s}}, [$last_p, $last_o];
  push @{$milestones{p}}, [$last_p, $last_o];

  my $stream = $$self->stream;
  foreach my $type ('s', 'p') {

    # Sort and unique milestones
    @{$milestones{$type}} = sort {
      $a->[0] <=> $b->[0]
    } @{$milestones{$type}};

    # Iterate overs milestones
    foreach (@{$milestones{$type}}) {

      if (($_->[0] == $p_start) || ($_->[1] == $o_start)) {
        next;
      };

      my $mtt = $stream->pos($p_start);

      if (!$mtt) {
        $p_start--;

        if (($_->[0] == $p_start) || ($_->[1] == $o_start)) {
          next;
        };

        $mtt = $stream->pos($p_start);
      }

      # Add the base sentence
      my $mt = $mtt->add(
        term    => '<>:base/s:' . $type,
        o_start => $o_start,
        o_end   => $_->[1],
        p_start => $p_start,
        p_end   => $_->[0],
        pti     => 64
      );
      $mt->payload('<b>1');

      if ($type eq 's') {
        $sentences++;
      } else {
        $paragraphs++;
      };

      $p_start = $_->[0];
      $o_start = $_->[1];
    };

    # Set meta information about sentence count
    if ($type eq 's') {
      $stream->add_meta('base/sentences', '<i>' . $sentences);
    }
    else {
      $stream->add_meta('base/paragraphs', '<i>' . $paragraphs);
    };
  };

  return 1;
};

sub layer_info {
  [];
};


1;
__END__
