#!/usr/bin/env perl
use strict;
use warnings;
use Test::More;
use Mojo::ByteStream 'b';
use utf8;
use lib 'lib', '../lib';

use_ok('KorAP::Document::Primary');

my $t = "Der März ging vorüber und demnächst würde es Herbstblätter regnen.";

ok(my $p = KorAP::Document::Primary->new($t), 'Constructor');

is($p->data_length, 66, 'Text has correct length');

is($p->data, $t, 'Text is identical');
is($p->data(0,3), 'Der', 'Text is identical');
is($p->data(4,8), 'März', 'Text is identical');
is($p->data(26,35), 'demnächst', 'Text is identical');

is($p->data_bytes(0,3), 'Der', 'Text is identical');
is($p->data_bytes(4,9), 'März', 'Text is identical');
is($p->data_bytes(28,38), 'demnächst', 'Text is identical');

is($p->bytes2chars(4), 4, 'Byte offset matches');
is($p->bytes2chars(9), 8, 'Byte offset matches');
is($p->bytes2chars(28), 26, 'Byte offset matches');
is($p->bytes2chars(38), 35, 'Byte offset matches');

is(
  $p->data(
    $p->bytes2chars(17),
    $p->bytes2chars(45)
  ),
  $p->data_bytes(17,45),
  'Text is identical'
);

$t = 'Er dächte, daß dies „für alle Elemente gilt“.';

ok($p = KorAP::Document::Primary->new($t), 'Constructor');

is($p->data_length, 45, 'Text has correct length');

is($p->data, $t, 'Text is identical');
is($p->data(0,2), 'Er', 'Text is identical');
is($p->data(3,9), 'dächte', 'Text is identical');
is($p->data(21,24), 'für', 'Text is identical');
is($p->data(20,21), '„', 'Text is identical');
is($p->data(43,44), '“', 'Text is identical');
is($p->data(44,45), '.', 'Text is identical');

is($p->data_bytes(0,2), 'Er', 'Text is identical');
is($p->bytes2chars(0),0, 'b2c correct');
is($p->bytes2chars(2),2, 'b2c correct');
is($p->data_bytes(3,10), 'dächte', 'Text is identical');
is($p->bytes2chars(3),3, 'b2c correct');
is($p->bytes2chars(10),9, 'b2c correct');
is($p->data_bytes(25,29), 'für', 'Text is identical');
is($p->bytes2chars(25),21, 'b2c correct');
is($p->bytes2chars(29),24, 'b2c correct');
is($p->data_bytes(22,25), '„', 'Text is identical');
is($p->bytes2chars(22),20, 'b2c correct');
is($p->bytes2chars(25),21, 'b2c correct');
is($p->data_bytes(48,51), '“', 'Text is identical');
is($p->bytes2chars(48),43, 'b2c correct');
is($p->bytes2chars(51),44, 'b2c correct');
is($p->data_bytes(51,52), '.', 'Text is identical');
is($p->bytes2chars(52),45, 'b2c correct');

is(
  $p->data(
    $p->bytes2chars(17),
    $p->bytes2chars(45)
  ),
  $p->data_bytes(17,45),
  'Text is identical'
);


#ok($p = KorAP::Document::Primary->new($t), 'Constructor');
is($p->xip2chars(0), 0, 'Fine');
is($p->xip2chars(7), 6, 'Fine');
#diag $p->data($p->latinbytes2chars(3),$p->latinbytes2chars(9));


done_testing;
