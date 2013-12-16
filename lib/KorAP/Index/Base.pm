package KorAP::Index::Base;

use strict;
use warnings;

sub import {
  my $class = shift;
  my $caller = caller;

  no strict 'refs';

  push @{"${caller}::ISA"}, $class;

  strict->import;
  warnings->import;
  utf8->import;
  feature->import(':5.10');
};


sub new {
  my $class = shift;
  my $tokens = shift;
  bless \$tokens, $class;
};

sub layer_info {
    return []
};

1;
