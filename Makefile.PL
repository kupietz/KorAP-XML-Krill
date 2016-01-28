#!/usr/bin/env perl
use v5.14;
use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
  NAME         => 'KorAP::Indexer',
  AUTHOR       => 'Nils Diewald',
  ABSTRACT     => 'Preprocessor for Krill Index preparation',
  VERSION_FROM => 'lib/KorAP/Indexer.pm',
  PREREQ_PM => {
    'Mojolicious'    => 6.11,
    'Packed::Array'  => 0.01,
    'Log::Log4perl'  => 1.42,
    'JSON::XS'       => 3.01,
    'Set::Scalar'    => 1.26,
    'XML::Fast'      => 0.11,
    'Try::Tiny'      => 0.21,
    'Array::IntSpan' => 2.003,
    'List::MoreUtils' => 0.33,
    'IO::Dir::Recursive' => 0.03,
    'Directory::Iterator' => 0,
    'Benchmark'      => 0,
    'Carp'           => 0,
    'strict'         => 0,
    'warnings'       => 0,
    'utf8'           => 0,
    'bytes'          => 0
  },
  MIN_PERL_VERSION => '5.014',
  test => {
    TESTS =>
      't/*.t '.
	't/index/*.t ' .
	  't/sgbr/*.t ' .
	    't/real/*.t'
	  }
);
