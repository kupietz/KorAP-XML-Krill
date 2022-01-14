#/usr/bin/env perl
use strict;
use warnings;
use File::Basename 'dirname';
use File::Spec::Functions qw/catdir catfile/;
use File::Temp qw/:POSIX/;
use Mojo::File;
use Mojo::JSON qw/decode_json/;
use IO::Uncompress::Gunzip;
use Test::More;
use Test::Output;
use Data::Dumper;
use utf8;

if ($ENV{SKIP_SCRIPT}) {
  plan skip_all => 'Skip script tests';
};

my $f = dirname(__FILE__);
my $script = catfile($f, '..', '..', 'script', 'korapxml2krill');
my $log = catfile($f, '..', 'logs', 'dereko-example-log.txt');

my $call = join(' ', 'perl', $script, 'slimlog', $log);

# Test with compression
stdout_like(
  sub { system($call); },
  qr!## Done\. \[\!Process: 2\]!,
  $call
);

done_testing;
__END__

