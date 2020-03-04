#!/usr/bin/env perl
use Mojo::Base -strict;
use Mojo::File;
use Mojo::Util qw'gzip gunzip';
use Mojo::JSON qw'decode_json encode_json';

#############################################################
# This helper tool iterates over a list of Krill-Json files #
# that are used as a sample corpus for Kustvakt (the works  #
# of Goethe) and adopts license strings from a list of      #
# strings to have variouses licenses to check for.          #
# (c) IDS Mannheim                                          #
#############################################################

# Create a license hash with all licenses
my %license = ();
foreach (<DATA>) {
  my ($file, $license) = split /\s+/, $_;
  chomp $license;
  $license{$file} = $license;
};


# Compare the license
sub _cmp_license {
  my ($fn, $expected, $is) = @_;

  # Compare the availability fields
  if ($expected ne $is) {
    print 'Mismatch: ', $fn, ': ', $expected, ' vs ', $is, "\n";
    return $expected;
  } else {
    print 'Match:    ', $fn, ': ', $expected, "\n";
    return;
  };
};


# Iterate over all krill json files in the directory
Mojo::File->new('.')->list->grep(qr!\.json(?:\.gz)?!)->each(
  sub {

    my $file = $_;

    # Get the base name of the file
    my $fn = $file->basename;
    my $gzipped = 0;
    my $content = $file->slurp;
    if ($fn =~ s/\.gz$//) {
      $gzipped = 1;
      $content = gunzip $content;
    };

    # Get the json content
    my $json = decode_json $content;

    my $modified = 0;

    # KoralQuery >= 0.3
    if ($json->{fields}) {

      # Iterate over all fields
      foreach ($json->{fields}->@*) {

        # Check for license fields
        if ($_->{key} eq 'availability') {
          my $cmp = _cmp_license($fn, $license{$fn}, $_->{value});

          # The licenses match - do nothing
          last unless $cmp;

          # Rewrite license
          $_->{value} = $license{$fn};
          $modified = 1;
          last;
        }
      };
    }

    # KoralQuery < 0.3
    else {
      my $cmp = _cmp_license($fn, $license{$fn}, $json->{availability});

      # The licenses match - do nothing
      last unless $cmp;

      # Rewrite license
      $json->{availability} = $license{$fn};
      $modified = 1;
    };

    # Store the modified file
    if ($modified) {
      print 'Rewrite:  ', $_->basename, "\n";
      if ($gzipped) {
        $_->spurt(gzip encode_json $json);
      }

      else {
        $_->spurt(encode_json $json);
      };
    };

    delete $license{$fn};
  }
);


# Warn on missing files
foreach (keys %license) {
  print 'Missing:  ', $_, ': ', $license{$_}, "\n";
};


__DATA__
GOE-AGA-00000.json QAO-NC
GOE-AGA-01784.json CC-BY-SA
GOE-AGA-02232.json ACA-NC
GOE-AGA-02616.json ACA-NC-LC
GOE-AGA-03828.json QAO-NC-LOC:ids
GOE-AGD-00000.json QAO-NC-LOC:ids-NU:1
GOE-AGD-06345.json QAO-NC
GOE-AGF-00000.json CC-BY-SA
GOE-AGF-02286.json QAO-NC
GOE-AGI-00000.json ACA-NC
GOE-AGI-04846.json QAO-NC-LOC:ids
