#!/usr/bin/env perl
use strict;
use warnings;
use Data::Dumper;
use Test::More;
use File::Temp 'tempfile';
use File::Basename 'dirname';
use File::Spec::Functions qw!catdir catfile!;

use_ok('KorAP::XML::Log::Slim');

my $temp = tempfile();

my $file = catfile(dirname(__FILE__), 'logs','dereko-example-log.txt');

ok(!KorAP::XML::Log::Slim->new);

my $slim = KorAP::XML::Log::Slim->new($file);

$slim->slim_to($temp);

seek($temp, 0,0);

my $content;
{
  local $/;
  $content = <$temp>;
}

like($content, qr!2 Start serial processing of e03\.\*zip!);
unlike($content, qr!Convert \[[^:]+?\:2\/\d+?\] Processed!);
unlike($content, qr!Unable to process!);
like($content, qr!Use of uninitialized value!);
like($content, qr!End-of-central-directory!);
like($content, qr!## Done\. \[\!Process\: 1\]!);
like($content, qr!file #1:  bad zipfile offset!);
like($content, qr!cannot find zipfile directory!);

done_testing;
