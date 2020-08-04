package KorAP::XML::Annotation::CoreNLP::Constituency;
use KorAP::XML::Annotation::Base;
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

      $corenlp_const{$span->get_id} = $span;

      # Maybe root
      $corenlp_const_root->insert($span->get_id);

      my $rel = $span->get_hash->{rel} or return;

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

  no warnings 'recursion';

  $add_const = sub {
    my $span = shift;
    my $level = shift;
    my $mtt = $stream->pos($span->get_p_start);

    my $content = $span->get_hash;
    my $f = $content->{fs}->{f};
    return unless $f->{-name} eq 'const';

    my $type = $f->{'#text'} or return;

    # $type is now NPA, NP, NUM ...
    my $term = $mtt->add('<>:corenlp/c:' . $type);
    $term->set_o_start($span->get_o_start);
    $term->set_o_end($span->get_o_end);
    $term->set_p_end($span->get_p_end);
    $term->set_pti(64);
    $term->set_payload('<b>' . ($level // 0));

    my $this = $add_const;

    my $rel = $content->{rel} or return;
    $rel = [$rel] unless ref $rel eq 'ARRAY';

    foreach (@$rel) {
      next if $_->{-label} ne 'dominates' || !$_->{-target};
      my $subspan = delete $corenlp_const{$_->{-target}} or return;

      # This will be called recursively
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
