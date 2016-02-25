#!/usr/bin/env perl
use strict;
use warnings;
use utf8;
use Test::More;
use Scalar::Util qw/weaken/;
use Data::Dumper;
use lib 't/index';
use TestInit;

ok(my $tokens = TestInit::tokens('0001'), 'Parse tokens');

is($tokens->stream->pos(0)->to_string, '[(0-3)-:tokens$<i>18|<>:base/s:t$<b>64<i>0<i>129<i>17<b>0|_0$<i>0<i>3|i:zum|s:Zum]', 'Token is correct');

is($tokens->stream->pos(1)->to_string, '[(4-11)_1$<i>4<i>11|i:letzten|s:letzten]', 'Token is correct');

my $i = 2;
foreach ([12,23, 'kulturellen'],
	 [24,30, 'Anlass'],
	 [31,35, 'lädt'],
	 [36,39, 'die'],
	 [40,47, 'Leitung'],
	 [48,51, 'des'],
	 [52,63, 'Schulheimes'],
	 [64,73, 'Hofbergli'],
	 [74,77, 'ein'],
	 [79,84, 'bevor'],
	 [85,88, 'der'],
	 [89,96, 'Betrieb'],
	 [97,101, 'Ende'],
	 [102,111, 'Schuljahr'],
	 [112,123, 'eingestellt'],
	 [124,128, 'wird']
       ) {
  is($tokens->stream->pos($i++)->to_string,
     '[('.$_->[0].'-'.$_->[1].')'.
       '_'.($i-1).
	 '$<i>'.$_->[0].'<i>' . $_->[1] . '|' .
	 'i:'.lc($_->[2]).'|s:'.$_->[2].']',
     'Token is correct');
};

ok(!$tokens->stream->pos($i++), 'No more tokens');

ok($tokens->add('OpenNLP', 'Morpho'), 'Add Structure');

my $data = $tokens->to_data->{data};

like($data->{foundries}, qr!opennlp/morpho!, 'data');
is($data->{stream}->[0]->[2], '_0$<i>0<i>3', 'Position');
is($data->{stream}->[0]->[4], 'opennlp/p:APPRART', 'POS');
is($data->{stream}->[1]->[2], 'opennlp/p:ADJA', 'POS');
is($data->{stream}->[2]->[2], 'opennlp/p:ADJA', 'POS');
is($data->{stream}->[-1]->[2], 'opennlp/p:VAFIN', 'POS');

done_testing;

__END__

