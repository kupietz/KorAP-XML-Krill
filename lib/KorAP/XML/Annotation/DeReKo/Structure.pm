package KorAP::XML::Annotation::DeReKo::Structure;
use KorAP::XML::Annotation::Base;
use List::Util qw/first/;
use Scalar::Util qw/looks_like_number/;

sub parse {
  my $self = shift;
  my $as_base = shift // 0;
  my ($sentences, $paragraphs) = (0,0);

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

      unless ($mtt) {

        # This is a special case were a milestone is at the
        # end of a text and can't be indexed at the moment!
        $$self->log->warn(
          'Span ' . $span->to_string . ' can\'t be indexed'
        );
        return;
      };

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

      # Use sentence and paragraph elements for base
      if ($as_base && ($name eq 's' || $name eq 'p' || $name eq 'pb')) {

        if ($name eq 's' && index($as_base, 'sentences') >= 0) {
          # Clone Multiterm
          my $mt2 = $mt->clone;
          $mt2->term('<>:base/s:' . $name);
          $mt2->payload('<b>2');
          $sentences++;

          # Add to stream
          $mtt->add($mt2);
        }
        elsif ($name eq 'p' && index($as_base, 'paragraphs') >= 0) {
          # Clone Multiterm
          my $mt2 = $mt->clone;
          $mt2->term('<>:base/s:' . $name);
          $mt2->payload('<b>1');
          $paragraphs++;

          # Add to stream
          $mtt->add($mt2);
        }

        # Add pagebreaks
        elsif ($name eq 'pb' && index($as_base, 'pagebreaks') >= 0) {
          if (my $nr = first { $_->{-name} eq 'n' } @$attrs) {
            if (($nr = $nr->{'#text'}) && looks_like_number($nr)) {
              my $mt2 = $mtt->add('~:base/s:pb');
              $mt2->payload('<i>' . $nr . '<i>' . $span->o_start);
              $mt2->store_offsets(0);
            };
          };
        };
      };

      # Add attributes
      if ($attrs) {

        # Set a tui if attributes are set
        foreach (@$attrs) {

          # Add attributes
          $mtt->add(
            term =>
              '@:dereko/s:' . $_->{'-name'} . ($_->{'#text'} ? ':' . $_->{'#text'} : ''),
            p_start => $p_start,
            pti     => 17,
            payload => '<s>' . $tui .
              ($span->milestone ? '' : '<i>' . $p_end)
            );
        };
      };
    }
  ) or return;

  if ($as_base) {
    if (index($as_base, 'sentences') >= 0) {
      $$self->stream->add_meta('base/sentences', '<i>' . $sentences);
    };
    if (index($as_base, 'paragraphs') >= 0) {
      $$self->stream->add_meta('base/paragraphs', '<i>' . $paragraphs);
    };
  };

  return 1;
};

sub layer_info {
  ['dereko/s=spans'];
};

1;
