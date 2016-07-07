package KorAP::XML::Batch::File;
use KorAP::XML::Krill;
use Mojo::Log;
use IO::Compress::Gzip;
use IO::File;
use strict;
use warnings;

sub new {
  my $class = shift;
  my %param = @_;

  bless {
    cache     => $param{cache}     // undef,
    meta_type => $param{meta_type} // 'I5',
    overwrite => $param{overwrite},
    foundry   => $param{foundry}   // 'Base',
    layer     => $param{layer}     // 'Tokens',
    anno      => $param{anno}      // [[]],
    log       => $param{log}       // Mojo::Log->new,
    primary   => $param{primary},
    pretty    => $param{pretty},
    gzip      => $param{gzip} // 0
  }, $class;
};


sub process {
  my $self = shift;
  my $input = shift;
  my $output = shift;

  # Create and parse new document
  $input =~ s{([^/])$}{$1/};
  my $doc = KorAP::XML::Krill->new(
    path      => $input,
    meta_type => $self->{meta_type},
    cache     => $self->{cache}
  );

  # Parse document
  unless ($doc->parse) {
    $self->{log}->warn(($output // $input) . " can't be processed - no document data");
    return;
  };

  # Get tokenization
  my $tokens = KorAP::XML::Tokenizer->new(
    path => $doc->path,
    doc => $doc,
    foundry => $self->{foundry},
    layer => $self->{layer},
    name => 'tokens'
  );

  # Unable to process base tokenization
  unless ($tokens->parse) {
    $self->{log}->error(($output // $input) . " can't be processed - no base tokenization");
    return;
  };

  foreach (@{$self->{anno}}) {
    $tokens->add(@$_);
  };

  my $file;
  my $print_text = ($self->{pretty} ? $tokens->to_pretty_json($self->{primary}) : $tokens->to_json($self->{primary}));
  if ($output) {
    if ($self->{gzip}) {
      $file = IO::Compress::Gzip->new($output, Minimal => 1);
    }
    else {
      $file = IO::File->new($output, "w");
    };

    $file->print($print_text);
    $file->close;
  }

  else {
    print $print_text . "\n";
  };

  return 1;
};

1;
