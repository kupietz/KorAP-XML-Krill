package KorAP::Index::XIP::Constituency;
use KorAP::Index::Base;
use Set::Scalar;
use Scalar::Util qw/weaken/;
use v5.16;

our $URI_RE = qr/^[^\#]+\#(.+?)$/;

sub parse {
  my $self = shift;

  # Collect all spans
  my %xip_const;

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
      $xip_const{$span->id} = $span;

      # It's probably a root
      $xip_const_root->insert($span->id);

      my $rel = $span->hash->{rel} or return;
      $rel = [$rel] unless ref $rel eq 'ARRAY';

      foreach (@$rel) {
	if ($_->{-label} eq 'dominates') {

	  my $target = $_->{-target};
	  if (!$target && $_->{-uri} &&
		$_->{-uri} =~ $URI_RE)  {
	    $target = $1;
	  };

	  next unless $target;

	  # It's definately not a root
	  $xip_const_noroot->insert($target);
	};
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
    my $mtt = $stream->pos($span->p_start);

    my $content = $span->hash;
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
    my %term = (
      term => '<>:xip/c:' . $type,
      o_start => $span->o_start,
      o_end => $span->o_end,
      p_end => $span->p_end
    );

    # Only add level payload if node != root
    $term{payload} = '<b>' . $level if $level;

    $mtt->add(%term);

    my $this = __SUB__;

    my $rel = $content->{rel};

    unless ($rel) {
      warn $f->{-id} . ' has no relation';
      return;
    };

    $rel = [$rel] unless ref $rel eq 'ARRAY';

    foreach (@$rel) {
      next if $_->{-label} ne 'dominates';
      my $target;

      $target = $_->{-target};
      if (!$target && $_->{-uri} && $_->{-uri} =~ $URI_RE)  {
	$target = $1;
      };

      next unless $target;

      my $subspan = delete $xip_const{$target};
      unless ($subspan) {
#	warn "Span " . $target . " not found";
	return;
      };
      $this->($subspan, $level + 1);
    };
  };

  # Calculate all roots
  my $roots = $xip_const_root->difference($xip_const_noroot);

  # Start tree traversal from the root
  foreach ($roots->members) {

    my $obj = delete $xip_const{$_} or next;

    $add_const->($obj, 0);
  };

  return 1;
};


# Layer info
sub layer_info {
    ['xip/c=const']
}

1;
