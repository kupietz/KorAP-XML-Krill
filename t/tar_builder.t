#!/usr/bin/env perl
use strict;
use warnings;
use Test::More;

use File::Basename 'dirname';
use File::Spec::Functions qw/catfile catdir/;
use File::Temp qw/tempdir tempfile/;

use_ok('Archive::Tar');

my ($out_tar, $out_tar_fn) = tempfile();

use_ok('KorAP::XML::TarBuilder');

ok(my $tar = KorAP::XML::TarBuilder->new($out_tar), 'Create new tar');

is(ref $tar, 'KorAP::XML::TarBuilder');

my $file = catfile(dirname(__FILE__), 'corpus','artificial', 'data.xml');
ok($tar->archive_as($file, 'example1.xml'));

$file = catfile(dirname(__FILE__), 'corpus','artificial', 'header.xml');
ok($tar->archive_as($file, 'example2.xml'));

ok($tar->finish, 'Finish tar');

use_ok('Archive::Tar');

my $tar_read = Archive::Tar->new($out_tar_fn);

ok($tar_read->contains_file('example1.xml'), 'File exists');
ok($tar_read->contains_file('example2.xml'), 'File exists');

my $content = $tar_read->get_content('example1.xml');
like($content, qr!A_RT_ABC\.00001!, 'Content is correct');

$content = $tar_read->get_content('example2.xml');
like($content, qr!A_RT\/ABC\.00001!, 'Content is correct');




# Now test for equivalence to Archive::Tar::Builder
if (eval("use Archive::Tar::Builder; 1;")) {

  use_ok('Archive::Tar::Builder');

  # Reset
  ($out_tar, $out_tar_fn) = tempfile();

  $tar = Archive::Tar::Builder->new(
    ignore_errors => 1
  );

  # Set handle
  $tar->set_handle($out_tar);

  is(ref $tar, 'Archive::Tar::Builder');

  $file = catfile(dirname(__FILE__), 'corpus','artificial', 'data.xml');
  ok($tar->archive_as($file, 'example1.xml'));

  $file = catfile(dirname(__FILE__), 'corpus','artificial', 'header.xml');
  ok($tar->archive_as($file, 'example2.xml'));

  ok($tar->finish, 'Finish tar');

  use_ok('Archive::Tar');

  $tar_read = Archive::Tar->new($out_tar_fn);

  ok($tar_read->contains_file('example1.xml'), 'File exists');
  ok($tar_read->contains_file('example2.xml'), 'File exists');

  $content = $tar_read->get_content('example1.xml');
  like($content, qr!A_RT_ABC\.00001!, 'Content is correct');

  $content = $tar_read->get_content('example2.xml');
  like($content, qr!A_RT\/ABC\.00001!, 'Content is correct');
}
else {
  diag 'Archive::Tar::Builder not installed.';
};

done_testing;

