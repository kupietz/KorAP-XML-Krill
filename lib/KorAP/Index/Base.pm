package KorAP::Index::Base;

use strict;
use warnings;

# Importing method
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


# Constructor
sub new {
  my $class = shift;
  my $tokens = shift;
  bless \$tokens, $class;
};

# Basic layer info
sub layer_info {
  []
};

1;

__END__

=pod

=head1 KorAP::Index::Base
