#!/usr/bin/env perl
use strict;
use warnings;
use Data::Dumper;
use Test::More;
use File::Basename 'dirname';
use File::Spec::Functions qw/catfile catdir/;
use File::Temp qw/tempdir/;

use KorAP::XML::Archive;

my $file = catfile(dirname(__FILE__), 'corpus','archive.zip');
my $archive = KorAP::XML::Archive->new($file);

unless ($archive->test_unzip) {
  plan skip_all => 'unzip not found';
};

ok($archive->test, 'Test archive');
like($archive->path(0), qr/archive\.zip$/, 'Archive path');

ok($archive->check_prefix, 'Archive has dot prefix');

my @list = $archive->list_texts;
is(scalar @list, 10, 'Found all tests');
is($list[0], './TEST/BSP/1', 'First document');
is($list[-1], './TEST/BSP/10', 'First document');

my @path = $archive->split_path('./TEST/BSP/9');
is($path[0],'.', 'Prefix');
is($path[1],'TEST', 'Prefix');
is($path[2],'BSP', 'Prefix');
is($path[3],'9', 'Prefix');

my $dir = tempdir(CLEANUP => 1);

{
  local $SIG{__WARN__} = sub {};
  ok($archive->extract_sigle(['TEST/BSP/8'], $dir), 'Wrong path');
};

ok(-d catdir($dir, 'TEST'), 'Test corpus directory exists');
ok(-f catdir($dir, 'TEST', 'header.xml'), 'Test corpus header exists');
ok(-d catdir($dir, 'TEST', 'BSP'), 'Test doc directory exists');
ok(-f catdir($dir, 'TEST', 'BSP', 'header.xml'), 'Test doc header exists');

$file = catfile(dirname(__FILE__), 'corpus','archive_rei.zip');
$archive = KorAP::XML::Archive->new($file);
ok(!$archive->check_prefix, 'Archive has no prefix');

# No leading '.'
$file = catfile(dirname(__FILE__), 'corpus','archive_rei.zip');
$archive = KorAP::XML::Archive->new($file);
ok(!$archive->check_prefix, 'Archive has no dot prefix');

my @cmd = map { join ' ', @{$_} } $archive->cmds_from_sigle(['REI/RB*', 'REI/BNG/00071']);

like($cmd[0], qr!unzip -qo -uo t/corpus/archive_rei\.zip!);
like($cmd[0], qr!\QREI/header.xml REI/RB*/header.xml REI/RB* REI/BNG/header.xml REI/BNG/00071/*\E!);
ok(!$cmd[1]);

# New temporary directory
$dir = tempdir(CLEANUP => 1);

{
  local $SIG{__WARN__} = sub {};
  ok($archive->extract_sigle(['REI/RB*', 'REI/BNG/00071'], $dir), 'Fine');
};

ok(-d catdir($dir, 'REI'), 'Test corpus directory exists');
ok(-d catdir($dir, 'REI','BNG'), 'Test corpus directory exists');
ok(-d catdir($dir, 'REI','BNG','00071'), 'Test corpus directory exists');

ok(-f catdir($dir, 'REI', 'header.xml'), 'Test corpus directory exists');
ok(-f catdir($dir, 'REI','BNG', 'header.xml'), 'Test corpus directory exists');
ok(-f catdir($dir, 'REI','BNG','00071', 'header.xml'), 'Test corpus directory exists');

ok(-f catdir($dir, 'REI','RBR', 'header.xml'), 'Test corpus directory exists');
ok(-f catdir($dir, 'REI','RBR','00610', 'header.xml'), 'Test corpus directory exists');
ok(-f catdir($dir, 'REI','RBR','00610', 'header.xml'), 'Test corpus directory exists');

ok(!-e catdir($dir, 'REI','BNG','00128'), 'Test corpus directory does not exist');


done_testing;

__END__
