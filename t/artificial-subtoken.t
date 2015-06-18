#!/usr/bin/env perl
# source ~/perl5/perlbrew/etc/bashrc
# perlbrew switch perl-blead@korap
use strict;
use warnings;
use utf8;
use Test::More;
use Benchmark ':hireswallclock';
use lib 'lib', '../lib';
use Scalar::Util qw/weaken/;

use File::Basename 'dirname';
use File::Spec::Functions 'catdir';

use_ok('KorAP::Document');

my $path = catdir(dirname(__FILE__), 'artificial');
ok(my $doc = KorAP::Document->new( path => $path . '/' ), 'Load Korap::Document');
like($doc->path, qr!$path/$!, 'Path');
ok($doc->parse, 'Parse document');

sub new_tokenizer {
  my $x = $doc;
  weaken $x;
  return KorAP::Tokenizer->new(
    path => $x->path,
    doc => $x,
    foundry => 'OpenNLP',
    layer => 'Tokens',
    name => 'tokens'
  )
};

is($doc->primary->data,
   'Zum letzten kulturellen Anlass lädt die Leitung des Schulheimes Hofbergli ein, '.
     'bevor der Betrieb Ende Schuljahr eingestellt wird.', 'Primary data');

is($doc->primary->data_length, 129, 'Primary data length');

is($doc->primary->data(0,3), 'Zum', 'Get primary data');

# Get tokens
use_ok('KorAP::Tokenizer');
# Get tokenization
ok(my $tokens = KorAP::Tokenizer->new(
  path => $doc->path,
  doc => $doc,
  foundry => 'OpenNLP',
  layer => 'Tokens',
  name => 'tokens'
), 'New Tokenizer');
ok($tokens->parse, 'Parse');

ok($tokens->add_subtokens, 'Add subtokens');

# diag $tokens->to_string;

#foreach (@{$tokens->stream->multi_term_tokens}) {
#  print $_;
#};

done_testing;


__END__
