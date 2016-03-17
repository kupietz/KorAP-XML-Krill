package KorAP::XML::Meta::Base;
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

sub log {
  return $_[0]->{_log};
};

sub corpus_sigle {
  $_[0]->{_corpus_sigle};
};

sub doc_sigle {
  $_[0]->{_doc_sigle};
};

sub text_sigle {
  $_[0]->{_text_sigle};
};

sub new {
  my $class = shift;
  my %hash = @_;
  my $copy = {};
  foreach (qw/log corpus_sigle doc_sigle text_sigle/) {
    $copy->{'_' . $_} = $hash{$_};
  };

  bless $copy, $class;
};

sub keywords {
  my $self = shift;
  return join(' ', @{$self->{$_[0]} // []});
};


1;
