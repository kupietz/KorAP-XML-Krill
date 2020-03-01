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

my $input = catdir($f, '..', 'corpus', 'WPD', '00001');
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
  '-t' => 'OpenNLP#tokens',
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
is($json->{textSigle}, 'WPD/AAA/00001', 'text sigle');
is($json->{title}, 'A', 'Title');
is($json->{data}->{tokenSource}, 'opennlp#tokens', 'Title');
is($json->{data}->{foundries}, 'base base/paragraphs base/sentences connexor connexor/morpho connexor/phrase connexor/sentences connexor/syntax corenlp corenlp/sentences dereko dereko/structure mate mate/dependency mate/morpho opennlp opennlp/morpho opennlp/sentences treetagger treetagger/morpho treetagger/sentences xip xip/constituency xip/morpho xip/sentences', 'Foundries');
my $stream = $json->{data}->{stream};
my $token = $stream->[12];
is($token->[16], 's:Vokal', 'Token');
$token = $stream->[13];
is($token->[23], 's:Der', 'Token');


$call = join(
  ' ',
  'perl', $script,
  '--input' => $input,
  '--output' => $output,
  '--cache' => $cache,
  '-t' => 'OpenNLP#tokens',
  '-l' => 'INFO',
  '-w' => '',
  '-nwt' => ''
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
$token = $stream->[12];
is($token->[17], 's:Vokal', 'Token');
$token = $stream->[13];
is($token->[7], 's:.', 'Token');
is($token->[11], 'xip/p:PUNCT', 'Token');
$token = $stream->[14];
is($token->[23], 's:Der', 'Token');


done_testing;

__END__
