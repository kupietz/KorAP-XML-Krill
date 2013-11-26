package KorAP::Tokenizer::Spans;
use Mojo::Base 'KorAP::Tokenizer::Units';
use KorAP::Tokenizer::Span;
use Mojo::DOM;
use Mojo::ByteStream 'b';
use XML::Fast;
use Try::Tiny;

has 'range';

has 'log' => sub {
  Log::Log4perl->get_logger(__PACKAGE__)
};

sub parse {
  my $self = shift;
  my $path = $self->path . $self->foundry . '/' . $self->layer . '.xml';
  my $file = b($path)->slurp;

  # my $spans = Mojo::DOM->new($file);
  # $spans->xml(1);

  # my $spans = XML::LibXML->load_xml(string => $file);

  my $spans;

  try {
      local $SIG{__WARN__} = sub {
	  my $msg = shift;
	  $self->log->error('Error in ' . $path . ($msg ? ': ' . $msg : ''));
      };

      $spans = xml2hash($file, text => '#text', attr => '-')->{layer}->{spanList};

  }
  catch  {
      $self->log->error('Span error in ' . $path . ($_ ? ': ' . $_ : ''));
      return [];
  };

  if (ref $spans && $spans->{span}) {
      $spans = $spans->{span};
  }
  else {
      return [];
  };

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
