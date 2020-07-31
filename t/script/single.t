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

if ($ENV{SKIP_SCRIPT}) {
  plan skip_all => 'Skip script tests';
};

my $f = dirname(__FILE__);
my $script = catfile($f, '..', '..', 'script', 'korapxml2krill');

my $input = catdir($f, '..', 'annotation', 'corpus', 'doc', '0001');
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
  '-k' => 0.03,
  '-t' => 'OpenNLP#Tokens',
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
is($json->{textType}, 'Zeitung: Tageszeitung', 'text type');
is($json->{title}, 'Beispiel Text', 'Title');
is($json->{data}->{tokenSource}, 'opennlp#tokens', 'Title');
is($json->{data}->{foundries}, 'base base/paragraphs base/sentences connexor connexor/morpho connexor/phrase connexor/sentences connexor/syntax corenlp corenlp/constituency corenlp/morpho corenlp/sentences dereko dereko/structure glemm glemm/morpho mate mate/dependency mate/morpho opennlp opennlp/morpho opennlp/sentences treetagger treetagger/morpho treetagger/sentences xip xip/constituency xip/morpho xip/sentences', 'Foundries');
like($json->{data}->{text}, qr/^Zum letzten kulturellen/, 'Foundries');
is($json->{data}->{stream}->[0]->[0], '-:base/paragraphs$<i>1', 'Paragraphs');
is($json->{data}->{tokenSource}, 'opennlp#tokens', 'TokenSource');

# Delete output
unlink $output;
ok(!-f $output, 'Output does not exist');

$call .= ' -z';

# Test with compression
stderr_like(
  sub { system($call); },
  qr!The code took!,
  $call
);

ok(-f $output, 'Output does exist');

# Uncompress the data using a buffer
my $gz = IO::Uncompress::Gunzip->new($output, Transparent => 0);
($file, my $buffer) = '';
while ($gz->read($buffer)) {
  $file .= $buffer;
};
$gz->close;

ok($json = decode_json($file), 'decode json');

is($json->{textType}, 'Zeitung: Tageszeitung', 'text type');
is($json->{title}, 'Beispiel Text', 'Title');
is($json->{data}->{tokenSource}, 'opennlp#tokens', 'TokenSource');
is($json->{data}->{foundries}, 'base base/paragraphs base/sentences connexor connexor/morpho connexor/phrase connexor/sentences connexor/syntax corenlp corenlp/constituency corenlp/morpho corenlp/sentences dereko dereko/structure glemm glemm/morpho mate mate/dependency mate/morpho opennlp opennlp/morpho opennlp/sentences treetagger treetagger/morpho treetagger/sentences xip xip/constituency xip/morpho xip/sentences', 'Foundries');
like($json->{data}->{text}, qr/^Zum letzten kulturellen/, 'Foundries');
is($json->{data}->{stream}->[0]->[0], '-:base/paragraphs$<i>1', 'Paragraphs');

# Delete output
is(unlink($output), 1, 'Unlink successful');
ok(!-e $output, 'Output does not exist');

# Use a different token source and skip all annotations,
# except for DeReKo#Structure and Mate#Dependency
$call = join(
  ' ',
  'perl', $script,
  '--input' => $input,
  '--output' => $output,
  '--cache' => $cache,
  '-t' => 'CoreNLP#Tokens',
  '-s' => '#all',
  '-a' => 'DeReKo#Structure',
  '-a' => 'Mate#Dependency',
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
ok(($file = Mojo::File->new($output)->slurp), 'Slurp data');
ok(($json = decode_json $file), 'decode json');

is($json->{textType}, 'Zeitung: Tageszeitung', 'text type');

is($json->{title}, 'Beispiel Text', 'Title');
is($json->{data}->{tokenSource}, 'corenlp#tokens', 'TokenSource');
is($json->{data}->{foundries}, 'dereko dereko/structure mate mate/dependency', 'Foundries');

like($json->{data}->{text}, qr/^Zum letzten kulturellen/, 'Foundries');
is($json->{data}->{stream}->[0]->[0], '-:tokens$<i>20', 'Tokens');


# Check overwrite
$call = join(
  ' ',
  'perl', $script,
  '--input' => $input,
  '--output' => $output,
  '--cache' => $cache,
  '-t' => 'CoreNLP#Tokens',
  '-s' => '#all',
  '-a' => 'DeReKo#Structure',
  '-a' => 'Mate#Dependency',
  '-l' => 'DEBUG'
);

ok(-f $output, 'Output does exist');
stderr_like(
  sub {
    system($call);
  },
  qr!already exists!,
  $call
);

$call .= ' -w ';

stderr_unlike(
  sub {
    system($call);
  },
  qr!already exists!,
  $call
);

# Check meta data switch

# Delete output
unlink $output;
ok(!-f $output, 'Output does not exist');

$input = catdir($f, '..', 'sgbr', 'PRO-DUD', 'BSP-2013-01', '32');

# Use a different token source and skip all annotations,
# except for DeReKo#Structure and Mate#Dependency
$call = join(
  ' ',
  'perl', $script,
  '--input' => $input,
  '--output' => $output,
  '--cache' => $cache,
  '-m' => 'Sgbr',
  '-t' => 'Base#Tokens_aggr',
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
ok(($file = Mojo::File->new($output)->slurp), 'Slurp data');
ok(($json = decode_json $file), 'decode json');

is($json->{data}->{text}, 'Selbst ist der Jeck', 'Text');
is($json->{data}->{tokenSource}, 'base#tokens_aggr', 'TokenSource');
is($json->{pubPlace}, 'Stadtingen', 'pubPlace');
is($json->{textSigle}, 'PRO-DUD/BSP-2013-01/32', 'textSigle');
is($json->{docSigle}, 'PRO-DUD/BSP-2013-01', 'docSigle');
is($json->{corpusSigle}, 'PRO-DUD', 'corpusSigle');
is($json->{sgbrKodex}, 'T', 'sgbrKodex');
is($json->{author}, 'unbekannt', 'Author');
is($json->{language}, 'de', 'Language');
is($json->{docTitle}, 'Korpus zur Beobachtung des Schreibgebrauchs im Deutschen', 'docTitle');
is($json->{funder}, 'Bundesministerium für Bildung und Forschung', 'docTitle');
is($json->{title}, 'Nur Platt, kein Deutsch', 'title');
is($json->{pubDate}, '20130126', 'pubDate');
is($json->{docSubTitle}, 'Subkorpus Ortsblatt, Jahrgang 2013, Monat Januar', 'docSubTitle');
is($json->{keywords}, 'sgbrKodex:T', 'keywords');
is($json->{publisher}, 'Dorfblatt GmbH', 'publisher');



# AGA with base info
unlink $output;
ok(!-f $output, 'Output does not exist');
$input = catdir($f, '..', 'corpus', 'GOE2', 'AGA', '03828');
ok(-d $input, 'Input directory found');

ok(!-f $output, 'Output does not exist');

$call = join(
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
ok(($file = Mojo::File->new($output)->slurp), 'Slurp data');
ok(($json = decode_json $file), 'decode json');

is($json->{title}, 'Autobiographische Einzelheiten', 'title');
is($json->{data}->{stream}->[0]->[-1], '~:base/s:pb$<i>529<i>0', 'Pagebreak annotation');



# Koral version
$input = catdir($f, '..', 'annotation', 'corpus', 'doc', '0001');
$call = join(
  ' ',
  'perl', $script,
  '--input' => $input,
  '--output' => $output,
  '--cache' => $cache,
  '-t' => 'OpenNLP#Tokens',
  '-k' => 0.4,
  '-l' => 'INFO'
);

$call .= ' -w ';

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
ok(!$json->{textType}, 'text type');
ok(!$json->{title}, 'Title');

is($json->{fields}->[0]->{key}, 'corpusSigle');
is($json->{fields}->[0]->{type}, 'type:string');
is($json->{fields}->[0]->{value}, 'Corpus');
is($json->{fields}->[0]->{'@type'}, 'koral:field');

is($json->{fields}->[4]->{key}, 'distributor');
is($json->{fields}->[4]->{value}, 'data:,Institut für Deutsche Sprache');
is($json->{fields}->[4]->{type}, 'type:attachement');
is($json->{fields}->[4]->{'@type'}, 'koral:field');

is($json->{fields}->[9]->{key}, 'textClass');
is($json->{fields}->[9]->{value}->[0], 'freizeit-unterhaltung');
is($json->{fields}->[9]->{value}->[1], 'vereine-veranstaltungen');
is($json->{fields}->[9]->{type}, 'type:keywords');
is($json->{fields}->[9]->{'@type'}, 'koral:field');

is($json->{fields}->[14]->{key}, 'textType');
is($json->{fields}->[14]->{value}, 'Zeitung: Tageszeitung');
is($json->{fields}->[14]->{type}, 'type:string');
is($json->{fields}->[14]->{'@type'}, 'koral:field');

is($json->{fields}->[22]->{key}, 'title');
is($json->{fields}->[22]->{value}, 'Beispiel Text');
is($json->{fields}->[22]->{type}, 'type:text');
is($json->{fields}->[22]->{'@type'}, 'koral:field');

is($json->{data}->{tokenSource}, 'opennlp#tokens', 'Title');
is($json->{data}->{foundries}, 'base base/paragraphs base/sentences connexor connexor/morpho connexor/phrase connexor/sentences connexor/syntax corenlp corenlp/constituency corenlp/morpho corenlp/sentences dereko dereko/structure glemm glemm/morpho mate mate/dependency mate/morpho opennlp opennlp/morpho opennlp/sentences treetagger treetagger/morpho treetagger/sentences xip xip/constituency xip/morpho xip/sentences', 'Foundries');
like($json->{data}->{text}, qr/^Zum letzten kulturellen/, 'Foundries');
is($json->{data}->{stream}->[0]->[0], '-:base/paragraphs$<i>1', 'Paragraphs');
is($json->{data}->{tokenSource}, 'opennlp#tokens', 'TokenSource');

# Delete output
unlink $output;
ok(!-f $output, 'Output does not exist');


done_testing;
__END__

