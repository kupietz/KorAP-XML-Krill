#!/usr/bin/env perl
use strict;
use warnings;
use utf8;
use Test::More;
use Scalar::Util qw/weaken/;
use Data::Dumper;

use_ok('KorAP::Document');

use File::Basename 'dirname';
use File::Spec::Functions 'catdir';

my $path = catdir(dirname(__FILE__), 'corpus', 'doc', 'text');

ok(my $doc = KorAP::Document->new(
  path => $path . '/'
), 'Load Korap::Document');

like($doc->path, qr!$path/$!, 'Path');
ok($doc->parse, 'Parse document');

ok($doc->primary->data, 'Primary data in existence');
is($doc->primary->data_length, 129, 'Data length');

use_ok('KorAP::Tokenizer');

ok(my $tokens = KorAP::Tokenizer->new(
  path => $doc->path,
  doc => $doc,
  foundry => 'OpenNLP',
  layer => 'Tokens',
  name => 'tokens'
), 'New Tokenizer');

ok($tokens->parse, 'Parse');

ok($tokens->add('TreeTagger', 'Sentences'), 'Add Structure');

my $data = $tokens->to_data->{data};

#diag Dumper $data;

like($data->{foundries}, qr!treetagger/sentences!, 'data');
is($data->{stream}->[0]->[0], '-:tokens$<i>18', 'Number of tokens');
is($data->{stream}->[0]->[1], '-:tt/sentences$<i>1', 'Number of paragraphs');
is($data->{stream}->[0]->[2], '<>:tt/s:s$<b>64<i>0<i>130<i>17<b>0', 'Text');
is($data->{stream}->[0]->[3], '_0$<i>0<i>3', 'Position');
is($data->{stream}->[-1]->[0], '_17$<i>124<i>128', 'Position');

done_testing;

__END__
