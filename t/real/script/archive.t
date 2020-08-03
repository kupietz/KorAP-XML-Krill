#/usr/bin/env perl
use strict;
use warnings;
use File::Basename 'dirname';
use File::Spec::Functions qw/catdir catfile/;
use File::Temp qw/:POSIX/;
use Mojo::File;
use Mojo::Util qw/quote/;
use Mojo::JSON qw/decode_json/;
use IO::Uncompress::Gunzip;
use Test::More;
use Test::Output qw/:stdout :stderr :combined :functions/;
use Data::Dumper;
use KorAP::XML::Archive;
use utf8;

if ($ENV{SKIP_SCRIPT} || $ENV{SKIP_REAL}) {
  plan skip_all => 'Skip script/real tests';
};

my $f = dirname(__FILE__);
my $script = catfile($f, '..', '..', '..', 'script', 'korapxml2krill');

my $cache = tmpnam();

my $output = File::Temp->newdir(CLEANUP => 0);
$output->unlink_on_destroy(0);

my $input = catfile($f, '..', 'corpus', 'WDD15', 'A79', '83946');
my $call = join(
  ' ',
  'perl', $script,
  '--input' => $input,
  '--cache' => $cache
);

# Test without compression
{
  local $SIG{__WARN__} = sub {};
  my $out = combined_from(sub { system($call); });

  like($out, qr!No tokens found!s, $call);
};


done_testing;
__END__
