#!/usr/bin/env perl
use v5.16;
use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
  NAME         => 'KorAP::Bundle',
  AUTHOR       => 'Nils Diewald',
  ABSTRACT     => 'Perl Implementation for Generating Multifoundry Lucene Indices',
  VERSION_FROM => 'lib/KorAP/Bundle.pm',
  PREREQ_PM => {
    'Mojolicious'    => 4.51,
    'Packed::Array'  => 0.01,
    'Log::Log4perl'  => 1.42,
    'JSON::XS'       => 3.01,
    'Set::Scalar'    => 1.26,
    'XML::Fast'      => 0.11,
    'Try::Tiny'      => 0.21,
    'Array::IntSpan' => 2,
    'List::MoreUtils' => 0.33,
    'IO::Dir::Recursive' => 0.03,
    'Benchmark'      => 0,
    'Carp'           => 0,
    'strict'         => 0,
    'warnings'       => 0,
    'utf8'           => 0,
    'bytes'          => 0
  },
  MIN_PERL_VERSION => '5.016',
  test => {
    TESTS => 't/*.t'
  }
);
