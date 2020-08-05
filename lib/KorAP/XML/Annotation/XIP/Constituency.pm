package KorAP::XML::Annotation::XIP::Constituency;
use KorAP::XML::Annotation::Base;
use Set::Scalar;
use Scalar::Util qw/weaken/;

our $URI_RE = qr/^[^\#]+\#(.+?)$/;

sub parse {
  my $self = shift;

  # Collect all spans
  my %xip_const = ();

  # Collect all roots
  my $xip_const_root = Set::Scalar->new;

  # Collect all non-roots
  my $xip_const_noroot = Set::Scalar->new;

  # First run:
  $$self->add_spandata(
    foundry => 'xip',
    layer => 'constituency',
    encoding => 'xip',
    cb => sub {
      my ($stream, $span) = @_;

      # Collect the span
      $xip_const{$span->get_id} = $span;
      # warn 'Remember ' . $span->get_id;

      # It's probably a root
      $xip_const_root->insert($span->get_id);

      my $rel = $span->get_hash->{rel} or return;

      $rel = [$rel] unless ref $rel eq 'ARRAY';

      my $target;

      # Iterate over all relations
      foreach (@$rel) {

        next if $_->{-label} ne 'dominates';

        $target = $_->{-target};
        if (!$target && $_->{-uri} &&
              $_->{-uri} =~ $URI_RE)  {
          $target = $1;
        };

        # The target may not be addressable
        next unless $target;

        # It's definately not a root
        $xip_const_noroot->insert($target);

        # if ($target =~ /^s2_n(?:36|58|59|60|40)$/) {
        #   warn 'Probably not a root ' . $target . ' but ' . $span->id;
        # };
      };
    }
  ) or return;

  # Get the stream
  my $stream = $$self->stream;

  # Recursive tree traversal method
  my $add_const;
  $add_const = sub {
    my ($span, $level) = @_;

    weaken $xip_const_root;
    weaken $xip_const_noroot;

    # Get the correct position for the span
    my $mtt = $stream->pos($span->get_p_start);

    my $content = $span->get_hash;
    my $f = $content->{fs}->{f};

    unless ($f->{-name} eq 'const') {
      warn $f->{-id} . ' is no constant';
      return;
    };

    my $type = $f->{'#text'};

    unless ($type) {
      warn $f->{-id} . ' has no content';
      return;
    };

    # $type is now NPA, NP, NUM ...
    my $mt = $mtt->add_by_term('<>:xip/c:' . $type);
    $mt->set_o_start($span->get_o_start);
    $mt->set_o_end($span->get_o_end);
    $mt->set_p_end($span->get_p_end);
    $mt->set_pti(64);

    # Only add level payload if node != root
    $mt->set_payload('<b>' . ($level // 0));

    # my $this = __SUB__
    my $this = $add_const;

    my $rel = $content->{rel};

    unless ($rel) {
      warn $f->{-id} . ' has no relation' if $f->{-id};
      return;
    };

    $rel = [$rel] unless ref $rel eq 'ARRAY';

    # Iterate over all relations (again ...)
    foreach (@$rel) {
      next if $_->{-label} ne 'dominates';

      my $target = $_->{-target};
      if (!$target && $_->{-uri} &&
            $_->{-uri} =~ $URI_RE)  {
        $target = $1;
      };

      # if ($span->id =~ /^s2_n(?:36|58|59|60|40)$/ && $target =~ /^s2_n(?:36|58|59|60|40)$/) {
      # warn 'B: ' . $span->id . ' points to ' . $target;
      # };

      next unless $target;

      my $subspan = delete $xip_const{$target};
      # warn "A-Forgot about $target: " . ($subspan ? 'yes' : 'no');

      next unless $subspan;
      #  warn "Span " . $target . " not found";

      $this->($subspan, $level + 1);
    };
  };

  # Calculate all roots
  my $roots = $xip_const_root->difference($xip_const_noroot);

  # Start tree traversal from the root
  foreach ($roots->members) {
    my $obj = delete $xip_const{$_};

    # warn "B-Forgot about $_: " . ($obj ? 'yes' : 'no');

    next unless $obj;

    $add_const->($obj, 0);
  };

  return 1;
};


# Layer info
sub layer_info {
  ['xip/c=spans']
};


1;
