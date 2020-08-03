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

if ($ENV{SKIP_SCRIPT} || $ENV{SKIP_REAL}) {
  plan skip_all => 'Skip script/real tests';
};


my $output = tmpnam();
my $cache = tmpnam();

my $f = dirname(__FILE__);
my $script = catfile($f, '..', '..', '..', 'script', 'korapxml2krill');

# AGA with base info
my $input = catdir($f, '..', 'corpus', 'GOE2', 'AGA', '03828');
ok(-d $input, 'Input directory found');

ok(!-f $output, 'Output does not exist');

my $call = join(
  ' ',
  'perl', $script,
  '--input' => $input,
  '--output' => $output,
  '--cache' => $cache,
  '-t' => 'base#tokens_aggr',
  '-bs' => 'DeReKo#Structure',
  '-bp' => 'DeReKo#Structure',
  '-bpb' => 'DeReKo#Structure',
  '-l' => 'INFO'
);

stderr_like(
  sub {
    system($call);
  },
  qr!The code took!,
  $call
);
ok(-f $output, 'Output does exist');
ok((my $file = Mojo::File->new($output)->slurp), 'Slurp data');
ok((my $json = decode_json $file), 'decode json');

is($json->{title}, 'Autobiographische Einzelheiten', 'title');
is($json->{data}->{stream}->[0]->[-1], '~:base/s:pb$<i>529<i>0', 'Pagebreak annotation');

done_testing;
