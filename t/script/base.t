#/usr/bin/env perl
use strict;
use warnings;
use File::Basename 'dirname';
use File::Spec::Functions qw/catdir catfile/;
use File::Temp qw/ :POSIX /;
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

my $input = catdir($f, '..', 'corpus', 'GOE2', 'AGA', '03828');
ok(-d $input, 'Input directory found');

my $output = tmpnam();
my $cache = tmpnam();

ok(!-f $output, 'Output does not exist');

my $call = join(
  ' ',
  'perl', $script,
  '--input' => $input,
  '--output' => $output,
  '--cache' => $cache,
  '-t' => 'Base#tokens_aggr.xml',
  '-bs' => 'DeReKo#Structure',
  '-bp' => 'DeReKo#Structure',
  '-l' => 'INFO'
);

# Test without compression
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
is($json->{textType}, 'Autobiographie', 'text type');
is($json->{title}, 'Autobiographische Einzelheiten', 'Title');
is($json->{data}->{tokenSource}, 'base#tokens_aggr', 'Title');
is($json->{data}->{foundries}, 'dereko dereko/structure dereko/structure/base-sentences-paragraphs marmot marmot/morpho', 'Foundries');
my $stream = $json->{data}->{stream};
my $token = $stream->[0];
is($token->[0], '-:base/paragraphs$<i>14', 'Paragraphs');
is($token->[1], '-:base/sentences$<i>215', 'Sentences');

is($token->[5], '<>:base/s:s$<b>64<i>0<i>30<i>2<b>2', 'struct');
is($token->[7], '<>:dereko/s:s$<b>64<i>0<i>30<i>2<b>4', 'struct');
is($token->[8], '<>:base/s:t$<b>64<i>0<i>35242<i>5239<b>0', 'struct');

$token = $stream->[4];
is($token->[0], '<>:base/s:s$<b>64<i>53<i>254<i>32<b>2', 'struct');
is($token->[1], '<>:dereko/s:s$<b>64<i>53<i>254<i>32<b>5<s>1', 'struct');
is($token->[2], '<>:base/s:p$<b>64<i>53<i>3299<i>504<b>1', 'struct');
is($token->[3], '<>:dereko/s:p$<b>64<i>53<i>3299<i>504<b>4', 'struct');

done_testing;

__END__
