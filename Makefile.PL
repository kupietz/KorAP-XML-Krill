#!/usr/bin/env perl
use v5.14;
use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
  NAME         => 'KorAP::XML::Krill',
  AUTHOR       => 'Nils Diewald',
  ABSTRACT     => 'Preprocess KorAP XML Documents for Krill',
  VERSION_FROM => 'lib/KorAP/XML/Krill.pm',
  LICENSE      => 'bsd_2',
  PREREQ_PM => {
    'Mojolicious'     => 7.23,
    'Packed::Array'   => 0.01,
    'Test::Output'    => 0,
    'Log::Log4perl'   => 1.42,
    'JSON::XS'        => 3.01,
    'Set::Scalar'     => 1.26,
    'XML::Fast'       => 0.11,
    'Try::Tiny'       => 0.21,
    'Array::IntSpan'  => 2.003,
    'List::MoreUtils' => 0.33,
    'Parallel::ForkManager' => 1.17,
    'IO::Compress::Gzip' => 2.069,
    'IO::Uncompress::Gunzip' => 2.069,
    'IO::Dir::Recursive' => 0.03,
    'File::Temp'      => 0,
    'Directory::Iterator' => 0,
    'Benchmark'       => 0,
    'Carp'            => 0,
    'strict'          => 0,
    'warnings'        => 0,
    'utf8'            => 0,
    'bytes'           => 0,
    'Pod::Usage'      => 0,
    'Cache::FastMmap' => 1.40
  },
  MIN_PERL_VERSION => '5.014',
  test => {
    TESTS =>
      't/*.t '.
      't/annotation/*.t ' .
      't/sgbr/*.t ' .
      't/real/*.t ' .
      't/script/*.t '
	  },
  EXE_FILES => ['script/korapxml2krill']
);
