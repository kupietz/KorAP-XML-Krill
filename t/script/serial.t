use strict;
use warnings;
use Test::More;
use Test::Output;
use File::Basename 'dirname';
use File::Spec::Functions qw/catdir catfile/;
use File::Temp qw/tempdir/;

my $f = dirname(__FILE__);
my $script = catfile($f, '..', '..', 'script', 'korapxml2krill');

my $input_base = catdir($f, '..', 'corpus', 'archives');

# Temporary output
my $output = File::Temp->newdir(CLEANUP => 0);

my $call = join(
  ' ',
  'perl', $script,
  'serial',
  '-i' => '"ngafy*.zip"',
  '-i' => '"tree*.zip"',
  '-ib' => $input_base,
  '-o' => $output,
  '-l' => 'WARN'
);

# Test without parameters
combined_like(
  sub {
    system($call);
  },
  qr!Start serial processing of ngafy\*\.zip!s,
  $call
);


done_testing;
__END__
