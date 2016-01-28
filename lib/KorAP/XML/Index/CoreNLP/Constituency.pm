package KorAP::XML::Index::CoreNLP::Constituency;
use KorAP::XML::Index::Base;
use Set::Scalar;

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

      # Maybe root
      $corenlp_const_root->insert($span->id);

      my $rel = $span->hash->{rel} or return;

      # Make rel an array in case it's not
      $rel = [$rel] unless ref $rel eq 'ARRAY';

      foreach (@$rel) {
	if ($_->{-label} eq 'dominates') {
	  if ($_->{-target}) {
	    $corenlp_const_noroot->insert($_->{-target});
	  }
	  elsif (my $uri = $_->{-uri}) {
	    $uri =~ s/^morpho\.xml#//;
	    $corenlp_const_noroot->insert($uri);
	  };
	};
      };
    }
  ) or return;

  my $stream = $$self->stream;

  my $add_const;

  $add_const = sub {
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
      p_end => $span->p_end,
      pti => 64
    );

    $term{payload} = '<b>' . ($level // 0);

    $mtt->add(%term);

    my $this = $add_const;

    my $rel = $content->{rel} or return;
    $rel = [$rel] unless ref $rel eq 'ARRAY';

    foreach (@$rel) {
      next if $_->{-label} ne 'dominates' || !$_->{-target};
      my $subspan = delete $corenlp_const{$_->{-target}} or return;
      $this->($subspan, $level + 1);
    };
  };

  # Next run
  my $diff = $corenlp_const_root->difference($corenlp_const_noroot);

  # Iterate over all roots
  foreach ($diff->members) {

    # Get root span based on root id
    my $obj = delete $corenlp_const{$_} or next;

    # Start on level 0
    $add_const->($obj, 0);
  };

  return 1;
};


sub layer_info {
  ['corenlp/c=spans']
};


1;
