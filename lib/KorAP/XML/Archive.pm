package KorAP::XML::Archive;
use Carp qw/carp/;
use File::Spec::Functions qw(rel2abs);
use strict;
use warnings;

# Convert new archive helper
sub new {
  my $class = shift;
  my $file = shift or return;
  bless \$file, $class;
};


# Check if unzip is installed
sub test_unzip {
  return 1 if grep { -x "$_/unzip"} split /:/, $ENV{PATH};
  return;
};

# Check the compressed archive
sub test {
  my $self = shift;
  my $file = $$self;
  my $out = `unzip -t $file`;
  if ($out =~ /no errors/i) {
    return 1;
  };
  return 0;
};


# List all text paths contained in the file
sub list_texts {
  my $self = shift;
  my $file = $$self;
  my %texts;
  foreach (`unzip -l $file *.xml`) {
    if ($_ =~ m![\t\s]
		((?:\./)?
		  [^\t\s/\.]+?/ # Corpus
		  [^\t\s/]+?/   # Document
		  [^\t\s/]+?    # Text
		)/(?:[^/]+?)\.xml$!x) {
      $texts{$1} = 1;
    };
  };

  return sort {$a cmp $b} keys %texts;
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
  carp $text_path . ' is not a well-formed text path in ' . $$self;
  return;
};


# Get the archives path
sub path {
  return rel2abs(${$_[0]});
};


# Extract files to a directory
sub extract {
  my $self = shift;
  my $text_path = shift;
  my $target_dir = shift;

  my @cmd = (
    'unzip',           # Use unzip program
    '-qo',             # quietly overwrite all existing files
    '-d', $target_dir # Extract into target directory
  );

  push(@cmd, $$self); # Extract from zip

  my ($prefix, $corpus, $doc, $text) = $self->split_path($text_path) or return;

  # Add some interesting files for extraction
  # Can't use catfile(), as this removes the '.' prefix
  push(@cmd, join('/', $prefix, $corpus, 'header.xml'));
  push(@cmd, join('/', $prefix, $corpus, $doc, 'header.xml'));
  push(@cmd, join('/', $prefix, $corpus, $doc, $text, '*'));

  # Run system call
  system(@cmd);

  # Check for return code
  if ($? != 0) {
    carp("System call '" . join(' ', @cmd) . "' errors " . $?);
    return;
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
