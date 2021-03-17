#/usr/bin/env perl
use strict;
use warnings;
use File::Basename 'dirname';
use File::Spec::Functions qw/catdir catfile/;
use File::Temp qw/:POSIX tempdir/;
use Mojo::File;
use Mojo::Util qw/quote/;
use Mojo::JSON qw/decode_json/;
use Archive::Tar;
use IO::Uncompress::Gunzip;
use Test::More;
use Test::Output qw/:stdout :stderr :functions/;
use Data::Dumper;
use KorAP::XML::Archive;
use utf8;

if ($ENV{SKIP_SCRIPT}) {
  plan skip_all => 'Skip script tests';
};

unless (KorAP::XML::Archive::test_unzip) {
  plan skip_all => 'unzip not found';
};

my $f = dirname(__FILE__);
my $script = catfile($f, '..', '..', 'script', 'korapxml2krill');

my $input_base = catdir($f, '..', 'corpus');

# Temporary output
my $output = File::Temp->newdir(CLEANUP => 0);
my $temp_ex = File::Temp->newdir(CLEANUP => 0);

my $cache = tmpnam();

my $call = join(
  ' ',
  'perl', $script,
  'serial',
  '-t' => 'Base#tokens_aggr',
  '-i' => '"archive.zip"',
  '-i' => '"archives/wpd15*.zip"',
  '--cache' => $cache,
  '-ib' => $input_base,
  '-o' => $output,
  '--to-tar' => 1,
  '-temporary-extract' => $temp_ex,
  '-sequential-extraction' => 1,
  '--gzip' => 1
);

# Test without parameters
my $stdout = stdout_from(sub { system($call) });

my $wpd_archive = catfile($output, 'archives-wpd15.tar');
my $bsp_archive = catfile($output, 'archive.tar');

ok(-e $wpd_archive, 'Archive exists');
ok(-e $bsp_archive, 'Archive exists');

my $tar = Archive::Tar->new;
$tar->read($bsp_archive);
ok($tar->contains_file('TEST-BSP-1.json.gz'), 'File found');

$tar->read($wpd_archive);
ok($tar->contains_file('WPD15-A00-00081.json.gz'), 'File found');

done_testing;
