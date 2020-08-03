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

my $f = dirname(__FILE__);
my $script = catfile($f, '..', '..', 'script', 'korapxml2krill');

my $input = catdir($f, '..', 'sgbr', 'PRO-DUD', 'BSP-2013-01', '32');

my $output = tmpnam();
my $cache = tmpnam();

# Use a different token source and skip all annotations,
# except for DeReKo#Structure and Mate#Dependency
my $call = join(
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
ok((my $file = Mojo::File->new($output)->slurp), 'Slurp data');
ok((my $json = decode_json $file), 'decode json');

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

done_testing;
