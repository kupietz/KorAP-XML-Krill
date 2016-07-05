#!/usr/bin/env perl
use strict;
use warnings;
use utf8;
use Log::Log4perl;
use Data::Dumper;

Log::Log4perl->init({
  'log4perl.rootLogger' => 'ERROR, STDERR',
  'log4perl.appender.STDERR' => 'Log::Log4perl::Appender::ScreenColoredLevels',
  'log4perl.appender.STDERR.layout' => 'PatternLayout',
  'log4perl.appender.STDERR.layout.ConversionPattern' => '[%r] %F %L %c - %m%n'
});

use File::Basename 'dirname';
use File::Spec::Functions qw/catdir catfile/;
use Test::More;
use Scalar::Util qw/weaken/;
use Data::Dumper;
use lib 't/annotation';
use File::Temp qw/tempdir/;

use_ok('KorAP::XML::Annotation::MDParser::Dependency');
use_ok('KorAP::XML::Archive');
use_ok('KorAP::XML::Krill');
use_ok('KorAP::XML::Tokenizer');

my $name = 'wpd15-single';
my @path = (dirname(__FILE__), '..', 'corpus','archives');

my $file = catfile(@path, $name . '.zip');
ok(my $archive = KorAP::XML::Archive->new($file), 'Create archive');

ok($archive->attach('#' . catfile(@path, $name . '.mdparser.zip')), 'Attach mdparser archive');

my $dir = tempdir();

my $f_path = 'WPD15/A00/00081';
$archive->extract($f_path, $dir);

ok(my $doc = KorAP::XML::Krill->new( path => $dir . '/' . $f_path));

ok($doc->parse, 'Krill parser works');

my $tokens = KorAP::XML::Tokenizer->new(
  path => $doc->path,
  doc => $doc,
  foundry => 'Base',
  layer => 'Tokens',
  name => 'tokens'
) or return;

$tokens->parse or return;

ok($tokens->add('MDParser', 'Dependency'), 'Add Dependency');

my $data = $tokens->to_data->{data};


is($data->{tokenSource}, 'base#tokens', 'TokenSource');
like($data->{foundries}, qr!mdparser/dependency!, 'foundries');
like($data->{layerInfos}, qr!mdp/d=rels!, 'foundries');

my $stream = $data->{stream};

# diag Dumper $stream->[0];

done_testing;
__END__
