package KorAP::XML::Archive;
use Carp qw/carp/;
use File::Spec::Functions qw(rel2abs);
use strict;
use warnings;

# Convert new archive helper
sub new {
  my $class = shift;
  my @file = @_ or return;
  bless \@file, $class;
};


# Check if unzip is installed
sub test_unzip {
  return 1 if grep { -x "$_/unzip"} split /:/, $ENV{PATH};
  return;
};

# Check the compressed archive
sub test {
  my $self = shift;
  foreach (@$self) {
    my $out = `unzip -t $_`;
    if ($out !~ /no errors/i) {
      return 0;
    };
  };
  return 1;
};


# List all text paths contained in the file
sub list_texts {
  my $self = shift;
  my @texts;
  my $file = $self->[0];
  foreach (`unzip -l -UU -qq $file "*/data.xml"`) {
    if (m![\t\s]
      ((?:\./)?
	[^\t\s/\.]+?/ # Corpus
	[^\t\s/]+?/   # Document
	[^\t\s/]+?    # Text
      )/data\.xml$!x) {
      push @texts, $1;
    };
  };
  return @texts;
};


# Split a text path to prefix, corpus, document, text
sub split_path {
  my $self = shift;
  my $text_path = shift;

  unless ($text_path) {
    carp('No text path given');
    return 0;
  };

  # Check for '.' prefix in text
  my $prefix = '';
  if ($text_path =~ s!^\./!!) {
    $prefix = '.';
  };

  # Unix form
  if ($text_path =~ m!^([^/]+?)/([^/]+?)/([^/]+?)$!) {
    return ($prefix, $1, $2, $3);
  }

  # Windows form
  elsif ($text_path =~ m!^([^\\]+?)\\([^\\]+?)\\([^\\]+?)$!) {
    return ($prefix, $1, $2, $3);
  };

  # Text has not the expected pattern
  carp $text_path . ' is not a well-formed text path in ' . $self->[0];
  return;
};


# Get the archives path
# Deprecated
sub path {
  my $self = shift;
  my $archive = shift // 0;
  return rel2abs($self->[$archive]);
};


sub attach {
  my $self = shift;
  if (-e $_[0]) {
    push @$self, $_[0];
    return 1;
  };
  return 0;
};


# Extract files to a directory
sub extract {
  my $self = shift;
  my $text_path = shift;
  my $target_dir = shift;

  my $first = 1;

  my @init_cmd = (
    'unzip',           # Use unzip program
    '-qo',             # quietly overwrite all existing files
    '-d', $target_dir # Extract into target directory
  );

  foreach (@$self) {
    my @cmd = @init_cmd;
    push(@cmd, $_); # Extract from zip

    my ($prefix, $corpus, $doc, $text) = $self->split_path($text_path) or return;

    # Add some interesting files for extraction
    # Can't use catfile(), as this removes the '.' prefix
    if ($first) {
      # Only extract from first file
      push(@cmd, join('/', $prefix, $corpus, 'header.xml'));
      push(@cmd, join('/', $prefix, $corpus, $doc, 'header.xml'));
      $first = 0;
    };

    # With prefix
    push(@cmd, join('/', $prefix, $corpus, $doc, $text, '*'));

    # Run system call
    system(@cmd);

    # Check for return code
    if ($? != 0) {
      carp("System call '" . join(' ', @cmd) . "' errors " . $?);
      return;
    };
  };

  # Fine
  return 1;
};


1;


__END__

=POD

C<KorAP::XML::Archive> expects the unzip tool to be installed.


=head1 new

=head1 test

=head1 list_texts

Returns all texts found in the zip file

=head1 extract

  $archive->extract('./GOE/AGU/0004', '~/temp');

Extract all files for the named text to a certain directory.
