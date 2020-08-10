package KorAP::XML::Annotation::XIP::Constituency;
use KorAP::XML::Annotation::Base;
use Set::Scalar;
use feature 'current_sub';

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
      };
    }
  ) or return;

  # Get the stream
  my $stream = $$self->stream;

  # Recursive tree traversal method
  my $add_const = sub {
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
    $mtt->add_span('<>:xip/c:' . $type, $span)
      # Only add level payload if node != root
      ->set_payload('<b>' . ($level // 0));

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

      next unless $target;

      my $subspan = delete $xip_const{$target};

      next unless $subspan;

      # Recursive call
      __SUB__->($subspan, $level + 1);
    };
  };

  # Calculate all roots
  my $roots = $xip_const_root->difference($xip_const_noroot);

  # Start tree traversal from the root
  foreach ($roots->members) {
    my $obj = delete $xip_const{$_};

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
