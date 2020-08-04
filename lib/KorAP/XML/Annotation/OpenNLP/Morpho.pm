package KorAP::XML::Annotation::OpenNLP::Morpho;
use KorAP::XML::Annotation::Base;
use Scalar::Util 'weaken';

sub parse {
  ${shift()}->add_tokendata(
    foundry => 'opennlp',
    layer => 'morpho',
    cb => sub {
      my ($stream, $token) = @_;
      my $mtt = $stream->pos($token->get_pos);

      my $content = $token->get_hash->{fs}->{f} or return;

      $content = $content->{fs}->{f};
      my $found;

      # syntax
      if (($content->{-name} eq 'pos') && ($content->{'#text'})) {
        $mtt->add(
          term => 'opennlp/p:' . $content->{'#text'}
        ) if $content->{'#text'};
      };
    }) or return;

  return 1;
};

sub layer_info {
  ['opennlp/p=tokens'];
};

1;
