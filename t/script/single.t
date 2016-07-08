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

my $f = dirname(__FILE__);
my $script = catfile($f, '..', '..', 'script', 'korapxml2krill');
my $input = catdir($f, '..', 'annotation', 'corpus', 'doc', '0001');
my $output = tmpnam();

ok(-f $script, 'Script found');
ok(-d $input, 'Input directory found');

my $call = 'perl ';
$call .= $script . ' ';
$call .= "--input $input ";
$call .= "--output $output ";
$call .= '-t OpenNLP#Tokens ';

system($call);

ok(my $file = slurp $output, 'Slurp data');
ok(my $json = decode_json $file, 'decode json');
is($json->{textType}, 'Zeitung: Tageszeitung', 'text type');
is($json->{title}, 'Beispiel Text', 'Title');
is($json->{data}->{tokenSource}, 'opennlp#tokens', 'Title');
is($json->{data}->{foundries}, 'base base/paragraphs base/sentences connexor connexor/morpho connexor/phrase connexor/sentences connexor/syntax corenlp corenlp/constituency corenlp/morpho corenlp/sentences dereko dereko/structure glemm glemm/morpho mate mate/dependency mate/morpho opennlp opennlp/morpho opennlp/sentences treetagger treetagger/morpho treetagger/sentences xip xip/constituency xip/morpho xip/sentences', 'Foundries');
like($json->{data}->{text}, qr/^Zum letzten kulturellen/, 'Foundries');
is($json->{data}->{stream}->[0]->[0], '-:base/paragraphs$<i>1', 'Paragraphs');

system($call . ' -z');

my $gz = IO::Uncompress::Gunzip->new($output);
ok($gz->read($file), 'Uncompress');

ok($json = decode_json $file, 'decode json');
is($json->{textType}, 'Zeitung: Tageszeitung', 'text type');
is($json->{title}, 'Beispiel Text', 'Title');
is($json->{data}->{tokenSource}, 'opennlp#tokens', 'Title');
is($json->{data}->{foundries}, 'base base/paragraphs base/sentences connexor connexor/morpho connexor/phrase connexor/sentences connexor/syntax corenlp corenlp/constituency corenlp/morpho corenlp/sentences dereko dereko/structure glemm glemm/morpho mate mate/dependency mate/morpho opennlp opennlp/morpho opennlp/sentences treetagger treetagger/morpho treetagger/sentences xip xip/constituency xip/morpho xip/sentences', 'Foundries');
like($json->{data}->{text}, qr/^Zum letzten kulturellen/, 'Foundries');
is($json->{data}->{stream}->[0]->[0], '-:base/paragraphs$<i>1', 'Paragraphs');


done_testing;
__END__
