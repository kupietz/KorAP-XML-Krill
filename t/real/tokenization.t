#!/usr/bin/env perl
use strict;
use warnings;
use utf8;
use Test::More;
use JSON::XS;
use Data::Dumper;

use File::Basename 'dirname';
use File::Spec::Functions 'catdir';

if ($ENV{SKIP_REAL}) {
  plan skip_all => 'Skip real tests';
};

sub _t2h {
  my $string = shift;
  $string =~ s/^\[\(\d+?-\d+?\)(.+?)\]$/$1/;
  my %hash = ();
  foreach (split(qr!\|!, $string)) {
    $hash{$_} = 1;
  };
  return \%hash;
};

use_ok('KorAP::XML::Krill');

my $path = catdir(dirname(__FILE__), qw/corpus WPD 00001/);
ok(my $doc = KorAP::XML::Krill->new( path => $path ), 'Load Korap::Document');
like($doc->path, qr!\Q$path\E/$!, 'Path');
ok($doc->parse, 'Parse document');
is($doc->text_sigle, 'WPD/AAA/00001', 'ID');


# Get tokens
use_ok('KorAP::XML::Tokenizer');

# Get tokenization
ok(my $tokens = KorAP::XML::Tokenizer->new(
  path => $doc->path,
  doc => $doc,
  foundry => 'OpenNLP',
  layer => 'Tokens',
  name => 'tokens'
), 'New Tokenizer');
ok($tokens->parse, 'Parse');

like($tokens->stream->pos(12)->to_string, qr/s:Vokal/);
like($tokens->stream->pos(13)->to_string, qr/s:Der/);


# Get tokenization with non word tokens
ok($tokens = KorAP::XML::Tokenizer->new(
  path => $doc->path,
  doc => $doc,
  foundry => 'OpenNLP',
  layer => 'Tokens',
  name => 'tokens',
  non_word_tokens => 1
), 'New Tokenizer');
ok($tokens->parse, 'Parse');

like($tokens->stream->pos(12)->to_string, qr/s:Vokal/);
like($tokens->stream->pos(13)->to_string, qr/s:\./);
like($tokens->stream->pos(14)->to_string, qr/s:Der/);


my $json = decode_json $tokens->to_json;
is($json->{docSigle}, 'WPD/AAA', 'DocSigle old');
is($json->{author}, 'Ruru; Jens.Ol; Aglarech; u.a.', 'author old');

$json = decode_json $tokens->to_json(0.4);
is($json->{fields}->[0]->{key}, 'corpusSigle');
is($json->{fields}->[0]->{value}, 'WPD');
is($json->{fields}->[7]->{key}, 'creationDate');
is($json->{fields}->[7]->{value}, '2005');

is($json->{data}->{name}, 'tokens');
is($json->{data}->{tokenSource}, 'opennlp#tokens');
is($json->{data}->{stream}->[0]->[0], '-:tokens$<i>1068');
is($json->{data}->{stream}->[0]->[1], '<>:base/s:t$<b>64<i>0<i>6083<i>1068<b>0');

done_testing;

__END__
