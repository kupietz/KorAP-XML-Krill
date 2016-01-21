package KorAP::Index::Malt::Dependency;
use KorAP::Index::Base;
use Data::Dumper;

sub parse {
  my $self = shift;

  # Relation data
  $$self->add_tokendata(
    foundry => 'malt',
    layer => 'dependency',
    cb => sub {
      my ($stream, $token, $tokens) = @_;

      # Get MultiTermToken from stream
      my $mtt = $stream->pos($token->pos);

      # Serialized information from token
      my $content = $token->hash;
    }) or return;

  return 1;
};

sub layer_info {
  ['malt/d=rels']
};


1;
