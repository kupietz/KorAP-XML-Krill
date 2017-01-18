package KorAP::XML::Tokenizer::Spans;
use strict;
use warnings;
use KorAP::XML::Log;
use Data::Dumper;
use Mojo::Base 'KorAP::XML::Tokenizer::Units';
use Mojo::File;
use KorAP::XML::Tokenizer::Span;
use Mojo::ByteStream 'b';
use XML::Fast;
use Try::Tiny;

has 'range';

has 'log' => sub {
  if(Log::Log4perl->initialized()) {
    state $log = Log::Log4perl->get_logger(__PACKAGE__);
  };
  state $log = KorAP::XML::Log->new;
  return $log;
};


# Parse span file
sub parse {
  my $self = shift;
  my $path = $self->path . $self->foundry . '/' . $self->layer . '.xml';

  unless (-e $path) {
    $self->log->warn('Unable to load file ' . $path);
    return;
  };

  my $file = b(Mojo::File->new($path)->slurp);

  my ($spans, $error);
  try {
    local $SIG{__WARN__} = sub {
      $error = 1;
    };
    $spans = xml2hash($file, text => '#text', attr => '-', array => ['span'])->{layer}->{spanList};
  }
  catch  {
    $self->log->warn('Span error in ' . $path . ($_ ? ': ' . $_ : ''));
    $error = 1;
  };

  return if $error;

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
