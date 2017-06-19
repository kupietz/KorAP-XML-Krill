#/usr/bin/env perl
use strict;
use warnings;
use File::Basename 'dirname';
use File::Spec::Functions qw/catdir catfile/;
use File::Temp qw/:POSIX tempdir/;
use Mojo::File;
use Mojo::Util qw/quote/;
use Mojo::JSON qw/decode_json/;
use IO::Uncompress::Gunzip;
use Test::More;
use Test::Output qw/:stdout :stderr :functions/;
use Data::Dumper;
use KorAP::XML::Archive;
use utf8;

my $f = dirname(__FILE__);
my $script = catfile($f, '..', '..', 'script', 'korapxml2krill');

my $call = join(
  ' ',
  'perl', $script,
  'archive'
);

unless (KorAP::XML::Archive::test_unzip) {
  plan skip_all => 'unzip not found';
};

# Test without parameters
stdout_like(
  sub {
    system($call);
  },
  qr!archive.+?\$ korapxml2krill!s,
  $call
);

my $input = catfile($f, '..', 'corpus', 'archive.zip');
ok(-f $input, 'Input archive found');

my $output = File::Temp->new;

ok(-f $output, 'Output directory exists');

my $input_quotes = "'".catfile($f, '..', 'corpus', 'archives', 'wpd15*.zip') . "'";

my $cache = tmpnam();

$call = join(
  ' ',
  'perl', $script,
  'archive',
  '--input' => $input_quotes,
  '--output' => $output . '.tar',
  '--cache' => $cache,
  '-t' => 'Base#tokens_aggr',
  '--to-tar'
);

# Test without parameters
my $combined = combined_from( sub { system($call) });

like($combined, qr!Input is .+?wpd15-single\.zip,.+?wpd15-single\.malt\.zip,.+?wpd15-single\.corenlp\.zip,.+?wpd15-single\.opennlp\.zip,.+?wpd15-single\.mdparser\.zip,.+?wpd15-single\.tree_tagger\.zip!is, 'Input is fine');

like($combined, qr!Writing to file .+?\.tar!, 'Write out');
like($combined, qr!Wrote to tar archive!, 'Write out');



done_testing;
__END__
