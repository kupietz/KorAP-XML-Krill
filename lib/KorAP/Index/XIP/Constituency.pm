package KorAP::Index::XIP::Constituency;
use KorAP::Index::Base;
use Set::Scalar;
use v5.16;

sub parse {
  my $self = shift;

  # Collect all spans and check for roots
  my %xip_const;
  my $xip_const_root = Set::Scalar->new;
  my $xip_const_noroot = Set::Scalar->new;

  # First run:
  $$self->add_spandata(
    foundry => 'xip',
    layer => 'constituency',
    encoding => 'xip',
    cb => sub {
      my ($stream, $span) = @_;

      $xip_const{$span->id} = $span;
      $xip_const_root->insert($span->id);

      my $rel = $span->hash->{rel} or return;
      $rel = [$rel] unless ref $rel eq 'ARRAY';

      foreach (@$rel) {
	if ($_->{-label} eq 'dominates' && $_->{-target}) {
	  $xip_const_noroot->insert($_->{-target});
	};
      };
    }
  ) or return;

  my $stream = $$self->stream;

  my $add_const = sub {
    my $span = shift;
    my $level = shift;
    my $mtt = $stream->pos($span->p_start);

    my $content = $span->hash;
    my $f = $content->{fs}->{f};
    return unless $f->{-name} eq 'const';

    my $type = $f->{'#text'} or return;

    # $type is now NPA, NP, NUM ...
    my %term = (
      term => '<>:xip/const:' . $type,
      o_start => $span->o_start,
      o_end => $span->o_end,
      p_end => $span->p_end
    );

    $term{payload} = '<b>' . $level if $level;

    $mtt->add(%term);

    my $this = __SUB__;

    my $rel = $content->{rel} or return;
    $rel = [$rel] unless ref $rel eq 'ARRAY';

    foreach (@$rel) {
      next if $_->{-label} ne 'dominates' || !$_->{-target};
      my $subspan = delete $xip_const{$_->{-target}} or return;
      $this->($subspan, $level + 1);
    };
  };

  my $diff = $xip_const_root->difference($xip_const_noroot);
  foreach ($diff->members) {
    my $obj = delete $xip_const{$_} or next;
    $add_const->($obj, 0);
  };

  return 1;
};


1;
