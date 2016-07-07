#!/usr/bin/env perl
use strict;
use warnings;
use Test::More;
use File::Basename 'dirname';
use File::Spec::Functions 'catdir';
use File::Temp qw/ :POSIX /;
use Mojo::Util qw/slurp/;
use Mojo::JSON qw/decode_json/;

use_ok('KorAP::XML::Batch::File');

ok(my $bf = KorAP::XML::Batch::File->new(
  overwrite => 1,
  foundry => 'OpenNLP',
  layer => 'Tokens'
), 'Construct new batch file object');

# gzip => 1,

my $path = catdir(dirname(__FILE__), 'annotation', 'corpus', 'doc', '0001');

my $output = tmpnam();
ok($bf->process($path => $output), 'Process file');

ok(-f $output, 'File exists');

ok(my $file = slurp $output, 'Slurp data');

ok(my $json = decode_json $file, 'decode json');

is($json->{textType}, 'Zeitung: Tageszeitung', 'text type');
is($json->{title}, 'Beispiel Text', 'Title');
is($json->{data}->{tokenSource}, 'opennlp#tokens', 'Title');
is($json->{data}->{foundries}, '', 'Foundries');
like($json->{data}->{text}, qr/^Zum letzten kulturellen/, 'Foundries');
is($json->{data}->{stream}->[0]->[0], '-:tokens$<i>18', 'Tokens');
is($json->{data}->{stream}->[0]->[1], '<>:base/s:t$<b>64<i>0<i>129<i>17<b>0', 'Data');

done_testing;
__END__
