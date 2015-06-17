#!/usr/bin/env perl
use strict;
use warnings;
use FindBin;
use v5.16;

my $dir = $FindBin::Bin;

foreach my $file (qw/00001
		     00002
		     00003
		     00004
		     00005
		     00006
		     02035-substring
		     02439
		     05663-unbalanced
		     07452-deep/) {
  my $out = $dir . '/../' . $file . '.json';

  my $call = 'perl ' . $dir . '/prepare_index.pl -i ' . $dir . '/../examples/WPD/AAA/' . $file . ' -o ' . $out;
  print 'Create ' . $out . "\n";
  system($call);

  print 'Create ' . $out . ".gz\n";
  $call .= '.gz -z';
  system($call);
};
