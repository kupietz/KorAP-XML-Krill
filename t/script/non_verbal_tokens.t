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

my $f = dirname(__FILE__);
my $script = catfile($f, '..', '..', 'script', 'korapxml2krill');

my $input = catdir($f, '..', 'corpus', 'AGD-scrambled', 'DOC', '00001');
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
  '-t' => 'DGD#Annot',
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

is($json->{textSigle}, 'AGD/DOC/00001', 'text sigle');
is($json->{title}, 'FOLK_E_00321_SE_01_T_01_DF_01', 'Title');
is($json->{data}->{tokenSource}, 'dgd#annot', 'Title');
is($json->{data}->{foundries}, 'dereko dereko/structure dgd dgd/morpho', 'Foundries');
my $stream = $json->{data}->{stream};
my $token = $stream->[4];
is($token->[3], 'dgd/l:pui', 'Token');
$token = $stream->[5];
is($token->[13], 'dgd/l:xui', 'Token');

$call = join(
  ' ',
  'perl', $script,
  '--input' => $input,
  '--output' => $output,
  '--cache' => $cache,
  '-t' => 'DGD#annot',
  '-l' => 'INFO',
  '-w' => '',
  '-nvt' => ''
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
ok(($file = Mojo::File->new($output)->slurp), 'Slurp data');
ok(($json = decode_json $file), 'decode json');
$stream = $json->{data}->{stream};

$stream = $json->{data}->{stream};

$token = $stream->[4];
is($token->[3], 'dgd/l:pui', 'Token');

$token = $stream->[5];
is($token->[14], 'dgd/para:pause$<b>128<s>5', 'Token');

$token = $stream->[6];
is($token->[1], 'dgd/l:xui', 'Token');



done_testing;
__END__
