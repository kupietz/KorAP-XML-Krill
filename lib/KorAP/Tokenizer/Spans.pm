package KorAP::Tokenizer::Spans;
use Mojo::Base 'KorAP::Tokenizer::Units';
use KorAP::Tokenizer::Span;
use Mojo::DOM;
use Mojo::ByteStream 'b';
use XML::Fast;

has 'range';

sub parse {
  my $self = shift;
  my $file = b($self->path . $self->foundry . '/' . $self->layer . '.xml')->slurp;

  # my $spans = Mojo::DOM->new($file);
  # $spans->xml(1);

  # my $spans = XML::LibXML->load_xml(string => $file);

  my $spans = xml2hash($file, text => '#text', attr => '-')->{layer}->{spanList}->{span};
  $spans = [$spans] if ref $spans ne 'ARRAY';

  my ($should, $have) = (0,0);
  my ($from, $to, $h);

  my @spans;
  my $p = $self->primary;

  foreach my $s (@$spans) {

    $should++;

    my $span = $self->span(
      $s->{-from},
      $s->{-to},
      $s
    ) or next;

    $have++;

    push(@spans, $span);
  };

  $self->should($should);
  $self->have($have);

  return \@spans;
};

1;
