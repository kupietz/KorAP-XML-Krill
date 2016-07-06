package KorAP::XML::ProcessFile;
use KorAP::XML::Krill;
use Log::Log4perl;
use strict;
use warnings;

sub new {
  my $class = shift;
  my %param = @_;

  my @layers;
  push(@layers, ['Base', 'Sentences']);
  push(@layers, ['Base', 'Paragraphs']);

  # Connexor
  push(@layers, ['Connexor', 'Morpho']);
  push(@layers, ['Connexor', 'Syntax']);
  push(@layers, ['Connexor', 'Phrase']);
  push(@layers, ['Connexor', 'Sentences']);

  # CoreNLP
  push(@layers, ['CoreNLP', 'NamedEntities']);
  push(@layers, ['CoreNLP', 'Sentences']);
  push(@layers, ['CoreNLP', 'Morpho']);
  push(@layers, ['CoreNLP', 'Constituency']);

  # DeReKo
  push(@layers, ['DeReKo', 'Structure']);

  # Glemm
  push(@layers, ['Glemm', 'Morpho']);

  # Malt
  push(@layers, ['Malt', 'Dependency']);

  # MDParser
  push(@layers, ['MDParser', 'Dependency']);

  # Mate
  push(@layers, ['Mate', 'Morpho']);
  push(@layers, ['Mate', 'Dependency']);

  # OpenNLP
  push(@layers, ['OpenNLP', 'Morpho']);
  push(@layers, ['OpenNLP', 'Sentences']);

  # Schreibgebrauch
  push(@layers, ['Sgbr', 'Lemma']);
  push(@layers, ['Sgbr', 'Morpho']);

  # TreeTagger
  push(@layers, ['TreeTagger', 'Morpho']);
  push(@layers, ['TreeTagger', 'Sentences']);

  # XIP
  push(@layers, ['XIP', 'Morpho']);
  push(@layers, ['XIP', 'Constituency']);
  push(@layers, ['XIP', 'Sentences']);
  push(@layers, ['XIP', 'Dependency']);

  my @anno;
  my $skip = $param{skip};

  # Check for complete skipping
  if ($skip->{'#all'}) {
    foreach (@$param{anno}) {
      push @anno, [split('#', $_)];
    }
  }

  # Iterate over all layers
  else {
    # Add to index file - respect skipping
    foreach my $info (@layers) {

      # Skip if Foundry or Foundry#Layer should be skipped
      unless ($skip->{lc($info->[0])} || $skip->{lc($info->[0]) . '#' . lc($info->[1])}) {
	push @anno, $info;
      };
    };
  };

  bless {
    cache     => $param{cache} // undef,
    meta      => $param{meta}  // 'I5',
    outpu     => $param{output},
    overwrite => $param{overwrite},
    foundry   => $param{foundry} // 'Base',
    layer     => $param{layer}   // 'Tokens',
    anno      => \@anno,
    log       => $param{log} // Log::Log4perl->get_logger('main')
  }, $class;
};


sub process {
  my $self = shift;
  my $input = shift;
  my $output = shift;

  # Create and parse new document
  $input =~ s{([^/])$}{$1/};
  my $doc = KorAP::XML::Krill->new(
    path => $input,
    meta_type => $self->{meta},
    cache => $self->{cache}
  );

  # Parse document
  unless ($doc->parse) {
    $log->warn($output . " can't be processed - no document data");
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
    $log->error($output . " can't be processed - no base tokenization");
    return;
  };

  foreach (@{$self->{anno}}) {
    $tokens->add(@$_);
  };

# Go on here with my $file; my $print_text
};

1;
