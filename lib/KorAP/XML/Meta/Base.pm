package KorAP::XML::Meta::Base;
# use Mojo::Log;
use Log::Any qw($log);
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
  $_[0]->{_log} = $log;
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


# Generate koral_fields
sub to_koral_fields {
  my $self = shift;
  my @fields = ();

  if ($self->corpus_sigle) {
    push @fields, _string_field('corpusSigle', $self->corpus_sigle);
    if ($self->doc_sigle) {
      push @fields, _string_field('docSigle', $self->doc_sigle);
      if ($self->text_sigle) {
        push @fields, _string_field('textSigle', $self->text_sigle);
      }
    }
  };

  # Iterate over all keys
  foreach (sort {$a cmp $b } $self->keys) {
    if (index($_, 'D_') == 0) {
      push @fields, _date_field(_k($_), $self->{$_});
    }
    elsif (index($_, 'S_') == 0) {
      push @fields, _string_field(_k($_), $self->{$_});
    }
    elsif (index($_, 'T_') == 0) {
      push @fields, _text_field(_k($_), $self->{$_});
    }
    # elsif (index($_, 'I_') == 0) {
    #  _int_field(_k($_), $self->{$_});
    # }
    elsif (index($_, 'A_') == 0) {
      push @fields, _attachement_field(_k($_), $self->{$_});
    }
    elsif (index($_, 'K_') == 0) {
      push @fields, _keywords_field(_k($_), $self->{$_});
    }
    else {
      warn 'Unknown field type: ' . $_;
    }
  };

  return \@fields;
};

sub _k {
  my $x = substr($_[0], 2);
  $x =~ s/_(\w)/\U$1\E/g;
  $x =~ s/id$/ID/gi;
  return $x;
};


sub _string_field {
  return {
    '@type' => 'koral:field',
    type    => 'type:string',
    key     => $_[0],
    value   => $_[1]
  };
};

sub _text_field {
  return {
    '@type' => 'koral:field',
    type    => 'type:text',
    key     => $_[0],
    value   => $_[1]
  };
};

sub _date_field {
  my ($key, $value) = @_;
  my $new_value;
  if ($value =~ /^(\d\d\d\d)(\d\d)(\d\d)$/) {
    $new_value = "$1";
    if ($2 ne '00') {
      $new_value .= "-$2";
      if ($3 ne '00') {
        $new_value .= "-$3";
      };
    };
  };
  return {
    '@type' => 'koral:field',
    type    => 'type:date',
    key     => $key,
    value   => $new_value
  };
};

sub _keywords_field {
  return {
    '@type' => 'koral:field',
    type    => 'type:keywords',
    key     => $_[0],
    value   => $_[1]
  };
};

sub _attachement_field {
  my $value = $_[1];
  if (index($value, 'data:') != 0) {
    $value = 'data:,' . $value;
  };
  return {
    '@type' => 'koral:field',
    type    => 'type:attachement',
    key     => $_[0],
    value   => $value
  };
};

1;
