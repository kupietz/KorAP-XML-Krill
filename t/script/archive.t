#/usr/bin/env perl
use strict;
use warnings;
use File::Basename 'dirname';
use File::Spec::Functions qw/catdir catfile/;
use File::Temp qw/tempdir/;
use Mojo::Util qw/slurp/;
use Mojo::JSON qw/decode_json/;
use IO::Uncompress::Gunzip;
use Test::More;
use Test::Output qw/:stdout :stderr :functions/;
use Data::Dumper;
use utf8;

my $f = dirname(__FILE__);
my $script = catfile($f, '..', '..', 'script', 'korapxml2krill');

my $call = join(
  ' ',
  'perl', $script,
  'archive'
);

# Test without parameters
stdout_like(
  sub {
    system($call);
  },
  qr!archive.+?Process an!s,
  $call
);

my $input = catfile($f, '..', 'corpus', 'archive.zip');
ok(-f $input, 'Input archive found');

my $output = tempdir(CLEANUP => 1);
ok(-d $output, 'Output directory exists');

$call = join(
  ' ',
  'perl', $script,
  'archive',
  '--input' => $input,
  '--output' => $output,
  '-t' => 'Base#tokens_aggr',
  '-m' => 'Sgbr'
);

# Test without compression
my $json;
{
  local $SIG{__WARN__} = sub {};
  my $out = stdout_from(sub { system($call); });

  like($out, qr!TEST-BSP-1\.json!s, $call);

  $out =~ m!Processed (.+?\.json)!;
  $json = $1;
};

ok(-f $json, 'Json file exists');
ok((my $file = slurp $json), 'Slurp data');
ok(($json = decode_json $file), 'decode json');

is($json->{data}->{tokenSource}, 'base#tokens_aggr', 'Title');
is($json->{data}->{foundries}, 'base base/paragraphs base/sentences dereko dereko/structure sgbr sgbr/lemma sgbr/morpho', 'Foundries');
is($json->{sgbrKodex}, 'M', 'Kodex meta data');

done_testing;
__END__
