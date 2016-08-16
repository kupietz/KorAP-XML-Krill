#/usr/bin/env perl
use strict;
use warnings;
use File::Basename 'dirname';
use File::Spec::Functions qw/catdir catfile/;
use File::Temp qw/ :POSIX /;
use Mojo::Util qw/slurp/;
use Mojo::JSON qw/decode_json/;
use IO::Uncompress::Gunzip;
use Test::More;
use Test::Output;
use Data::Dumper;

my $f = dirname(__FILE__);
my $script = catfile($f, '..', '..', 'script', 'korapxml2krill');
ok(-f $script, 'Script found');

stdout_like(
  sub { system('perl', $script) },
  qr!Usage.+?korapxml2krill!s,
  'Usage output'
);

stdout_like(
  sub { system('perl', $script, '--help') },
  qr!Usage.+?korapxml2krill!s,
  'Usage output'
);

stdout_like(
  sub { system('perl', $script, '--version') },
  qr!Version \d+\.\d+!s,
  'Version output'
);

done_testing;
__END__
