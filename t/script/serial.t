use strict;
use warnings;
use Test::More;
use Test::Output qw/stdout_from/;
use File::Basename 'dirname';
use File::Spec::Functions qw/catdir catfile/;
use File::Temp qw/:POSIX/;

if ($ENV{SKIP_SCRIPT}) {
  plan skip_all => 'Skip script tests';
};

my $f = dirname(__FILE__);
my $script = catfile($f, '..', '..', 'script', 'korapxml2krill');

my $input_base = catdir($f, '..', 'corpus');

# Temporary output
my $output = File::Temp->newdir(CLEANUP => 0);

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
  '-o' => $output
);

# Test without parameters
my $stdout = stdout_from(sub { system($call) });

like($stdout, qr!Start serial processing of .+?wpd15\*\.zip!, 'Processing');
like($stdout, qr!Start serial processing .+?archive.zip!, 'Processing');

like($stdout, qr!Processed .+?/archive/TEST-BSP-1\.json!, 'Archive file');
like($stdout, qr!Processed .+?/archives-wpd15/WPD15-A00-00081\.json!, 'Archive file');

done_testing;
__END__
