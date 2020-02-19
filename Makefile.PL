#!/usr/bin/env perl
use v5.16;
use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
  NAME         => 'KorAP::XML::Krill',
  AUTHOR       => 'Nils Diewald',
  ABSTRACT     => 'Merge KorAP-XML data and create Krill documents',
  VERSION_FROM => 'lib/KorAP/XML/Krill.pm',
  LICENSE      => 'freebsd',
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
    'Dumbbench'       => '0.111',
    'Benchmark'       => 0,
    'Unicode::Normalize' => 0,
    'Carp'            => 0,
    'strict'          => 0,
    'warnings'        => 0,
    'utf8'            => 0,
    'bytes'           => 0,
    'Pod::Usage'      => 0,
    'Cache::FastMmap' => 1.45,
    'Sys::Info'       => 0.78,
    'Config::Simple'  => 4.58,
    'String::Random'  => 0.29,
    'File::Path'      => 2.12,
    'Archive::Tar::Builder' => 2.5002,
    'Archive::Tar'    => 2.24
  },
  MIN_PERL_VERSION => '5.016',
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
