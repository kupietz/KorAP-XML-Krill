package KorAP::XML::Archive;
use Carp qw/carp/;
use File::Spec::Functions qw(rel2abs);
use strict;
use warnings;

# Construct new archive helper
sub new {
  my $class = shift;
  my @file;

  foreach (@_) {
    my $file = _file_to_array($_) or return;
    push(@file, $file);
  };

  return unless @file;

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
    my $x = $_->[0];
    my $out = `unzip -t $x`;
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
  my $file = $self->[0]->[0];
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
  carp $text_path . ' is not a well-formed text path in ' . $self->[0]->[0];
  return;
};


# Get the archives path
# Deprecated
sub path {
  my $self = shift;
  my $archive = shift // 0;
  return rel2abs($self->[$archive]->[0]);
};


# Attach another archive
sub attach {
  my $self = shift;
  my $file = _file_to_array(shift()) or return;
  push @$self, $file;
  return 1;
};


# Check attached file for prefix negation
sub _file_to_array {
  my $file = shift;
  my $prefix = 1;

  # Should the archive support prefixes
  if (index($file, '#') == 0) {
    $file = substr($file, 1);
    $prefix = 0;
  };

  # The archive is a valid file
  if (-e $file) {
    return [$file, $prefix]
  };
};



# Extract files to a directory
sub extract {
  my $self = shift;
  my $text_path = shift;
  my $target_dir = shift;

  my $first = 1;

  my @init_cmd = (
    'unzip',          # Use unzip program
    '-qo',            # quietly overwrite all existing files
    '-d', $target_dir # Extract into target directory
  );

  my ($prefix, $corpus, $doc, $text) = $self->split_path($text_path) or return;

  # Iterate over all attached archives
  foreach my $archive (@$self) {

    # $_ is the zip
    my @cmd = @init_cmd;
    push(@cmd, $archive->[0]); # Extract from zip

    # Add some interesting files for extraction
    # Can't use catfile(), as this removes the '.' prefix
    my @breadcrumbs = ($corpus);

    # If the prefix is not forbidden - prefix!
    unshift @breadcrumbs, $prefix if ($prefix && $archive->[1]);

    if ($first) {
      # Only extract from first file
      push(@cmd, join('/', @breadcrumbs, 'header.xml'));
      push(@cmd, join('/', @breadcrumbs, $doc, 'header.xml'));
      $first = 0;
    };

    # With prefix
    push @breadcrumbs, $doc, $text, '*';

    push(@cmd, join('/', @breadcrumbs));

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

=head1 attach

=head1 list_texts

Returns all texts found in the zip file

=head1 extract

  $archive->extract('./GOE/AGU/0004', '~/temp');

Extract all files for the named text to a certain directory.
