#/usr/bin/env perl
use strict;
use warnings;
use File::Basename 'dirname';
use File::Spec::Functions qw/catdir catfile/;
use File::Temp qw/:POSIX tempdir/;
use Mojo::JSON qw/decode_json/;
use IO::Uncompress::Gunzip;
use Test::More;
use Test::Output;
use Data::Dumper;
use KorAP::XML::Archive;
use utf8;

my $f = dirname(__FILE__);
my $script = catfile($f, '..', '..', 'script', 'korapxml2krill');

my $call = join(
  ' ',
  'perl', $script,
  'extract'
);

unless (KorAP::XML::Archive::test_unzip) {
  plan skip_all => 'unzip not found';
};

# Test without parameters
stdout_like(
  sub {
    system($call);
  },
  qr!extract.+?\$ korapxml2krill!s,
  $call
);

my $input = catfile($f, '..', 'corpus', 'archive.zip');
ok(-f $input, 'Input archive found');

my $output = tempdir(CLEANUP => 1);
ok(-d $output, 'Output directory exists');

my $cache = tmpnam();

$call = join(
  ' ',
  'perl', $script,
  'extract',
  '--input' => $input,
  '--output' => $output,
  '--cache' => $cache
);

my $sep = qr!\.\.\.[\n\r]+?\.\.\.!;

# Test without compression
stdout_like(
  sub {
    system($call);
  },
  qr!TEST/BSP/1 $sep extracted!s,
#  qr!TEST/BSP/1 $sep extracted.!s,
  $call
);

ok(-d catdir($output, 'TEST', 'BSP', '1'), 'Directory created');
ok(-d catdir($output, 'TEST', 'BSP', '1', 'base'), 'Directory created');
ok(-d catdir($output, 'TEST', 'BSP', '1', 'sgbr'), 'Directory created');
ok(-d catdir($output, 'TEST', 'BSP', '1', 'struct'), 'Directory created');
ok(-f catfile($output, 'TEST', 'BSP', '1', 'data.xml'), 'File created');
ok(-f catfile($output, 'TEST', 'BSP', '1', 'header.xml'), 'File created');
ok(-d catdir($output, 'TEST', 'BSP', '2'), 'Directory created');
ok(-d catdir($output, 'TEST', 'BSP', '3'), 'Directory created');

# Check sigles
my $output2 = tempdir(CLEANUP => 1);
ok(-d $output2, 'Output directory exists');

$call = join(
  ' ',
  'perl', $script,
  'extract',
  '--input' => $input,
  '--output' => $output2,
  '--cache' => $cache,
  '-sg' => 'TEST/BSP/4'
);

# Test with sigle
stdout_like(
  sub {
    system($call);
  },
  qr!TEST/BSP/4 $sep extracted.!s,
  $call
);

# Test with sigle
stdout_unlike(
  sub {
    system($call);
  },
  qr!TEST/BSP/5 $sep extracted.!s,
  $call
);

ok(!-d catdir($output2, 'TEST', 'BSP', '1'), 'Directory created');
ok(!-d catdir($output2, 'TEST', 'BSP', '2'), 'Directory created');
ok(!-d catdir($output2, 'TEST', 'BSP', '3'), 'Directory created');
ok(-d catdir($output2, 'TEST', 'BSP', '4'), 'Directory created');
ok(!-d catdir($output2, 'TEST', 'BSP', '5'), 'Directory created');


# Test with document sigle
my $input_rei = catdir($f, '..', 'corpus', 'archive_rei.zip');
ok(-f $input_rei, 'Input archive found');

$call = join(
  ' ',
  'perl', $script,
  'extract',
  '--input' => $input_rei,
  '--output' => $output2,
  '--cache' => $cache,
  '-sg' => 'REI/BNG'
);

# Test with sigle
stdout_like(
  sub {
    system($call);
  },
  qr!Extract .+? REI/BNG!s,
  $call
);

# Test with sigle
stdout_unlike(
  sub {
    system($call);
  },
  qr!Extract .+? REI/RBR!s,
  $call
);

ok(-d catdir($output2, 'REI', 'BNG', '00071'), 'Directory created');
ok(-d catdir($output2, 'REI', 'BNG', '00128'), 'Directory created');
ok(!-d catdir($output2, 'REI', 'RBR', '00610'), 'Directory not created');


# Test with document sigle
$output2 = undef;
$output2 = tempdir(CLEANUP => 1);

$call = join(
  ' ',
  'perl', $script,
  'extract',
  '--input' => $input_rei,
  '--output' => $output2,
  '--cache' => $cache,
  '-sg' => 'REI/BN*'
);

# Test with sigle
stdout_like(
  sub {
    system($call);
  },
  qr!Extract .+? REI/BN\*!s,
  $call
);

# Test with sigle
stdout_unlike(
  sub {
    system($call);
  },
  qr!REI/RBR $sep extracted!s,
  $call
);

ok(-d catdir($output2, 'REI', 'BNG', '00071'), 'Directory created');
ok(-d catdir($output2, 'REI', 'BNG', '00128'), 'Directory created');
ok(!-d catdir($output2, 'REI', 'RBR', '00610'), 'Directory not created');


# Check multiple archives
$output = tempdir(CLEANUP => 1);
ok(-d $output, 'Output directory exists');

$call = join(
  ' ',
  'perl', $script,
  'extract',
  '-i' => catfile($f, '..', 'corpus', 'archives', 'wpd15-single.zip'),
  '-i' => catfile($f, '..', 'corpus', 'archives', 'wpd15-single.tree_tagger.zip'),
  '-i' => catfile($f, '..', 'corpus', 'archives', 'wpd15-single.opennlp.zip'),
  '--output' => $output,
  '--cache' => $cache
);

# Test with sigle
stdout_like(
  sub {
    system($call);
  },
  qr!WPD15/A00/00081 $sep extracted!s,
  $call
);

ok(-d catdir($output, 'WPD15', 'A00', '00081'), 'Directory created');
ok(-f catfile($output, 'WPD15', 'A00', 'header.xml'), 'Header file created');
ok(-d catdir($output, 'WPD15', 'A00', '00081', 'base'), 'Directory created');

ok(-f catfile($output, 'WPD15', 'A00', '00081', 'tree_tagger', 'morpho.xml'), 'New archive');
ok(-f catfile($output, 'WPD15', 'A00', '00081', 'opennlp', 'morpho.xml'), 'New archive');


# With quotes:
# Test with document sigle
my $input_quotes = catfile($f, '..', 'corpus', 'archive_quotes.zip');
ok(-f $input, 'Input archive found');
$output2 = undef;
$output2 = tempdir(CLEANUP => 1);

$call = join(
  ' ',
  'perl', $script,
  'extract',
  '--input' => $input_quotes,
  '--output' => $output2,
  '--cache' => $cache,
  '-sg' => '"TEST/BSP \"Example\"/1"'
);

# Test with sigle
stdout_like(
  sub {
    system($call);
  },
  qr!TEST/BSP "Example"\/1 $sep extracted!s,
  # qr!Extract .+? TEST/BSP "Example"\/1!s,
  $call
);

done_testing;
__END__
