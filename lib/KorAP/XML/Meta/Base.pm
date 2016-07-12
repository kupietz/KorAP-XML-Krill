package KorAP::XML::Meta::Base;
use Mojo::Log;
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
  return $_[0]->{_log} if $_[0]->{_log};
  $_[0]->{_log} = Mojo::Log->new;
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

sub cache {
  $_[0]->{_cache};
}

sub new {
  my $class = shift;
  my %hash = @_;
  my $copy = {};
  foreach (qw/log cache corpus_sigle doc_sigle text_sigle/) {
    $copy->{'_' . $_} = $hash{$_};
  };

  bless $copy, $class;
};

sub keywords {
  my $self = shift;
  return join(' ', @{$self->{$_[0]} // []});
};

# Check if cached
# Cache differently!
sub is_cached {
  my ($self, $type) = @_;

  return if $type eq 'text';
  return unless $self->cache;

  my $value;
  my $cache = $self->cache;
  if ($type eq 'corpus') {
    $value = $cache->get($self->corpus_sigle);
  }
  elsif ($type eq 'doc') {
    $value = $cache->get($self->doc_sigle);
  };

  if ($value) {
    foreach (grep {index($_, '_') != 0 } keys %$value) {
      $self->{$_} = $value->{$_};
    };
    return 1;
  };

  return;
};

sub to_hash {
  my $self = shift;
  my %new;
  foreach ($self->keys) {
    $new{$_} = $self->{$_};
  };
  if ($self->corpus_sigle) {
    $new{corpus_sigle} = $self->corpus_sigle;
    if ($self->doc_sigle) {
      $new{doc_sigle} = $self->doc_sigle;
      if ($self->text_sigle) {
	$new{text_sigle} = $self->text_sigle;
      }
    }
  };
  return \%new;
};

sub keys {
  my $self = shift;
  return grep {index($_, '_') != 0 } keys %$self;
};

sub do_cache {
  my ($self, $type) = @_;

  return if $type eq 'text';
  return unless $self->cache;

  my %value;
  foreach ($self->keys) {
    $value{$_} = $self->{$_};
  };

  my $cache = $self->cache;

  if ($type eq 'corpus') {
    $cache->set($self->corpus_sigle, \%value);
    return 1;
  }
  elsif ($type eq 'doc') {
    $cache->set($self->doc_sigle, \%value);
    return 1;
  };

  return 0;
};

1;
