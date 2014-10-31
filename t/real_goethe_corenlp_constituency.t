#!/usr/bin/env perl
# source ~/perl5/perlbrew/etc/bashrc
# perlbrew switch perl-blead@korap
use strict;
use warnings;
use Test::More;
use Data::Dumper;
use JSON::XS;

use utf8;
use lib 'lib', '../lib';

use File::Basename 'dirname';
use File::Spec::Functions 'catdir';

use_ok('KorAP::Document');

# GOE/AGA/03828
my $path = catdir(dirname(__FILE__), 'GOE/AGA/03828');

ok(my $doc = KorAP::Document->new( path => $path . '/' ), 'Load Korap::Document');
ok($doc->parse, 'Parse document');

# Tokenization
use_ok('KorAP::Tokenizer');

my ($token_base_foundry, $token_base_layer) = (qw/OpenNLP Tokens/);

# Get tokenization
my $tokens = KorAP::Tokenizer->new(
  path => $doc->path,
  doc => $doc,
  foundry => $token_base_foundry,
  layer => $token_base_layer,
  name => 'tokens'
);
ok($tokens, 'Token Object is fine');
ok($tokens->parse, 'Token parsing is fine');

$tokens->add('CoreNLP', 'Constituency');
my $output = decode_json( $tokens->to_json );
is($output->{foundries}, 'corenlp corenlp/constituency', 'Foundries');
is($output->{layerInfos}, 'corenlp/c=spans', 'layerInfos');
my $first_token = join('||', @{$output->{data}->[0]});
#like($first_token, qr!<>:xip/s:s#0-179\$<i>21!, 'data');

diag Dumper $output->{data}->[0];
