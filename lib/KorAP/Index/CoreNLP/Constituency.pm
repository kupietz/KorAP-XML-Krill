package KorAP::Index::CoreNLP::Constituency;
use KorAP::Index::Base;
use Set::Scalar;
use v5.16;

sub parse {
  my $self = shift;

  # Collect all spans and check for roots
  my %corenlp_const;
  my $corenlp_const_root = Set::Scalar->new;
  my $corenlp_const_noroot = Set::Scalar->new;

  # First run:
  $$self->add_spandata(
    foundry => 'corenlp',
    layer => 'constituency',
    cb => sub {
      my ($stream, $span) = @_;

      $corenlp_const{$span->id} = $span;
      $corenlp_const_root->insert($span->id);

      my $rel = $span->hash->{rel} or return;
      $rel = [$rel] unless ref $rel eq 'ARRAY';

      foreach (@$rel) {
	if ($_->{-label} eq 'dominates' && $_->{-target}) {
	  $corenlp_const_noroot->insert($_->{-target});
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
      term => '<>:corenlp/c:' . $type,
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
      my $subspan = delete $corenlp_const{$_->{-target}} or return;
      $this->($subspan, $level + 1);
    };
  };

  my $diff = $corenlp_const_root->difference($corenlp_const_noroot);
  foreach ($diff->members) {
    my $obj = delete $corenlp_const{$_} or next;
    $add_const->($obj, 0);
  };

  return 1;
};

sub layer_info {
    ['corenlp/c=const']
}

1;
