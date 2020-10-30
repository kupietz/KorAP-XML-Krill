#!/usr/bin/env perl
use strict;
use warnings;
use KorAP::XML::Annotation::Malt::Dependency;
use utf8;
use Log::Log4perl;

Log::Log4perl->init({
  'log4perl.rootLogger' => 'ERROR, STDERR',
  'log4perl.appender.STDERR' => 'Log::Log4perl::Appender::ScreenColoredLevels',
  'log4perl.appender.STDERR.layout' => 'PatternLayout',
  'log4perl.appender.STDERR.layout.ConversionPattern' => '[%r] %F %L %c - %m%n'
});

use Test::More;
use Scalar::Util qw/weaken/;
use Data::Dumper;
use lib 't/annotation';
use TestInit;



use_ok('KorAP::XML::Annotation::Malt::Dependency');

ok(my $tokens = TestInit::tokens('0002', 'Tree_Tagger'), 'Parse tokens');

ok($tokens->add('Malt', 'Dependency'), 'Add Dependency');

my $data = $tokens->to_data->{data};

is($data->{tokenSource}, 'tree_tagger#tokens', 'TokenSource');
like($data->{foundries}, qr!malt/dependency!, 'foundries');
like($data->{layerInfos}, qr!malt/d=rels!, 'foundries');

my $stream = $data->{stream};

is($stream->[0]->[0], '-:tokens$<i>31', 'Number of paragraphs');

# Term2Term relation
is($stream->[0]->[1], '<:malt/d:KON$<b>32<i>1', 'Term2Term relation');
is($stream->[0]->[-1], 's:Maximen', 'Surface');

is($stream->[1]->[0], '>:malt/d:KON$<b>32<i>0', 'Term2Term relation');
is($stream->[1]->[-1], 's:und', 'Surface');

is($stream->[0]->[2], '<:malt/d:KON$<b>32<i>3', 'Term2Term relation');
is($stream->[3]->[0], '>:malt/d:KON$<b>32<i>0', 'Term2Term relation');
is($stream->[3]->[-1], 's:Religion', 'Term2Term relation');

# Term2Element and Element2Term relation
is($stream->[0]->[3], '<:malt/d:ROOT$<b>34<i>0<i>49<i>6<i>0', 'Term2Term relation');
is($stream->[0]->[5], '>:malt/d:ROOT$<b>33<i>0<i>49<i>0<i>6', 'Term2Term relation');

# Text element
is($stream->[0]->[4], '<>:base/s:t$<b>64<i>0<i>238<i>31<b>0', 'Text element');

done_testing;
__END__
