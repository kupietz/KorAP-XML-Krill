package KorAP::XML::Annotation::NKJP::NamedEntities;
use KorAP::XML::Annotation::Base;

# Import named entities, potentially with a specified
# Model. However - now all models are mapped to the 'ne'-Prefix
# and are indistinguishable in annotations. However - if only one
# model is used, the model is listed in the foundries.
sub parse {
  my $self   = shift;
  my $model  = shift;

  $$self->add_tokendata(
    foundry => 'nkjp',
    layer => 'named',
    cb => sub {
      my ($stream, $token) = @_;
      my $mtt = $stream->pos($token->get_pos);

      my $content = $token->get_hash->{fs}->{f} or return;
      my $found;

      if (ref $content eq 'HASH') {
        $content = [$content];
      };

      foreach my $c (@$content) {
        if ($c->{-name} ne 'ne') {
          next;
        };

        if ($found = $c->{fs}) {
          my $ents;
          if (ref $found->{f} eq 'HASH') {
            $ents = [$found->{f}];
          } else {
            $ents = $found->{f};
          };

          my ($type, $subtype);
          foreach (@$ents) {
            if ($_->{'-name'}) {
              if ($_->{'-name'} eq 'type') {
                $type = $_->{symbol}->{'-value'};
              }
              elsif ($_->{'-name'} eq 'subtype') {
                $subtype = $_->{symbol}->{'-value'};
              };
            };
          };

          if ($type && $subtype) {
            $mtt->add_by_term('nkjp/ne:' . $type . ':' . $subtype);
          } elsif ($type) {
            $mtt->add_by_term('nkjp/ne:' . $type);
          };
        };
      };
    }) or return;

  return 1;
};

sub layer_info {
  ['nkjp/ne=tokens'];
};

1;
