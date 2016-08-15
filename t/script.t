use strict;
use warnings;
use Test::More;
use File::Basename 'dirname';
use File::Spec::Functions qw/catfile/;
use Test::Output;
use FindBin;

my $script = catfile(dirname(__FILE__), '..', 'script', 'korapxml2krill');

stdout_like(
  sub { system('perl', $script) },
  qr!Usage.+?korapxml2krill!s,
  'Usage output'
);

done_testing;
__END__
