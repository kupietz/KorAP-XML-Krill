package KorAP::XML::TarBuilder;
use Archive::Tar::Stream;
use strict;
use warnings;

# This is a fallback module for Archive::Tar::Builder
# that may not be available on certain systems.

# Create a new TarBuilder object
sub new {
  my $class = shift;
  my $fh = shift;
  my $tar = Archive::Tar::Stream->new(outfh => $fh);
  bless \$tar, $class;
};


# Archive a file
sub archive_as {
  my $self = shift;
  my ($datafile, $tarfilename) = @_;
  if (open(my $fh, $datafile)) {
    $$self->AddFile($tarfilename, -s $datafile, $fh);
    close $fh;
    return 1;
  };
  return;
};


# Finish the Tar stream
sub finish {
  my $self = shift;
  return $$self->FinishTar;
};

1;
