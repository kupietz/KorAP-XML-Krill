#!/usr/bin/env perl
use strict;
use warnings;
use Test::More;
use Mojo::ByteStream 'b';
use utf8;
use lib 'lib', '../lib';

use_ok('KorAP::XML::Index::MultiTermTokenStream');

ok(my $mtt = KorAP::XML::Index::MultiTermToken->new, 'New token');
ok(defined $mtt->set_o_start(0), 'Set start character offset');
ok($mtt->set_o_end(5), 'Set end character offset');
ok(my $mt = $mtt->add_by_term('@:k=N'), 'Add token');
$mt->set_pti(128);
$mt->set_payload('<s>9');
ok($mt = $mtt->add_by_term('a=N'), 'Add token');
$mt->set_pti(129);
$mt->set_payload('<b>144');
ok($mt = $mtt->add_by_term('<>:b=N'), 'Add token');
$mt->set_pti(64);
$mt->set_o_start(0);
$mt->set_o_end(5);
$mt->set_p_end(5);
ok($mt = $mtt->add_by_term('c=N'), 'Add token');
$mt->set_pti(129);
$mt->set_payload('<b>144');
ok($mt = $mtt->add_by_term('<>:d=N'), 'Add token');
$mt->set_pti(64);
$mt->set_o_start(0);
$mt->set_o_end(5);
$mt->set_p_end(6);
$mt->set_payload('<b>7');
ok($mt = $mtt->add_by_term('@:j=N'), 'Add token');
$mt->set_pti(16);
$mt->set_payload('<s>8');
ok($mt = $mtt->add_by_term('<>:e=ADJ'), 'Add token');
$mt->set_pti(64);
$mt->set_o_start(0);
$mt->set_o_end(5);
$mt->set_p_end(6);
$mt->set_payload('<b>6');
ok($mt = $mtt->add_by_term('<>:f=N'), 'Add token');
$mt->set_pti(64);
$mt->set_o_start(0);
$mt->set_o_end(5);
$mt->set_p_end(6);
$mt->set_payload('<b>5<b>122');
ok($mt = $mtt->add_by_term('g=N'), 'Add token');
$mt->set_pti(129);
$mt->set_payload('<b>144');
ok($mt = $mtt->add_by_term('@:h=N'), 'Add token');
$mt->set_pti(16);
$mt->set_payload('<s>5');
ok($mt = $mtt->add_by_term('@:i=N'), 'Add token');
$mt->set_pti(16);
$mt->set_payload('<s>3');

is($mtt->to_string,
   '[(0-5)<>:b=N$<b>64<i>0<i>5<i>5|' .
     '<>:e=ADJ$<b>64<i>0<i>5<i>6<b>6|' .
       '<>:d=N$<b>64<i>0<i>5<i>6<b>7|' .
	 '<>:f=N$<b>64<i>0<i>5<i>6<b>5<b>122|' .
	   '@:i=N$<b>16<s>3|' .
	     '@:h=N$<b>16<s>5|' .
	       '@:j=N$<b>16<s>8|' .
		 '@:k=N$<b>128<s>9|' .
		   'a=N$<b>129<b>144|' .
		     'c=N$<b>129<b>144|' .
		       'g=N$<b>129<b>144]',
   'Check string');

ok($mtt = KorAP::XML::Index::MultiTermToken->new, 'New token');
ok(defined $mtt->set_o_start(0), 'Set start character offset');
ok($mtt->set_o_end(5), 'Set end character offset');

# 2-7 to 2-4
ok($mt = $mtt->add_by_term('<:child-of'), 'New rel');
$mt->set_pti(35);
$mt->set_payload('<i>0<i>0<i>0<i>0'. # character os
                   '<i>7<i>2<i>4<s>5<s>4<s>3'
                 );

# 2-4 to 3
ok($mt = $mtt->add_by_term('<:child-of'), 'New rel');
$mt->set_pti(34);
$mt->set_payload(
  '<i>0<i>0' . # character os
    '<i>4<i>3<s>3<s>3<s>1'
  );

# 2 to 2-4
# <i>startright<i>endright<s>relation-id<s>left-id<s>right-id
ok($mt = $mtt->add_by_term('>:child-of'), 'New rel');
$mt->set_pti(33);
$mt->set_payload(
  '<i>0<i>0'. # character os
    '<i>2<i>4<s>2<s>1<s>3'
  );

# 2-4 to 2-7
ok($mt = $mtt->add_by_term('>:child-of'), 'New rel');
$mt->set_pti(35);
$mt->set_payload(
  '<i>0<i>0<i>0<i>0' . # character os
    '<i>4<i>2<i>7<s>1<s>3<s>4'
  );

# 2-4 to 4
ok($mt = $mtt->add_by_term('<:child-of'), 'New rel');
$mt->set_pti(34);
$mt->set_payload(
  '<i>0<i>0' . # character os
    '<i>4<i>4<s>4<s>3<s>1'
  );

# 2-7 to 1-7
ok($mt = $mtt->add_by_term('>:child-of'), 'New rel');
$mt->set_pti(35);
$mt->set_payload(
  '<i>0<i>0<i>0<i>0' . # character os
    '<i>7<i>1<i>7<s>2<s>4<s>2'
  );

# 2-7 to 4-7
ok($mt = $mtt->add_by_term('<:child-of'), 'New rel');
$mt->set_pti(35);
$mt->set_payload(
  '<i>0<i>0<i>0<i>0' . # character os
    '<i>7<i>4<i>7<s>6<s>4<s>2'
  );



# 2 to 3
ok($mt = $mtt->add_by_term('>:child-of'), 'New rel');
$mt->set_pti(32);
$mt->set_payload('<i>3<s>2<s>4<s>2');


#NOTE: Sorting of the candidate spans can alternatively be done in
# * indexing, instead of here. (first by left positions and then by
# * right positions)

is($mtt->to_string,
   '[(0-5)'.
   # 2 -> 2-4
   '>:child-of$<b>33<i>0<i>0'                  . '<i>2<i>4<s>2<s>1<s>3|'.
   # 2 -> 3
   '>:child-of$<b>32'                          . '<i>3<s>2<s>4<s>2|'.
     # 2-4 -> 2-7
   '>:child-of$<b>35<i>0<i>0<i>0<i>0' . '<i>4' . '<i>2<i>7<s>1<s>3<s>4|'.
     # 2-4 -> 3
   '<:child-of$<b>34<i>0<i>0' . '<i>4'         . '<i>3<s>3<s>3<s>1|' .
     # 2-4 -> 4
   '<:child-of$<b>34<i>0<i>0' . '<i>4'         . '<i>4<s>4<s>3<s>1|'.
     # 2-7 -> 1-7
   '>:child-of$<b>35<i>0<i>0<i>0<i>0' . '<i>7' . '<i>1<i>7<s>2<s>4<s>2|'.
     # 2-7 -> 2-4
   '<:child-of$<b>35<i>0<i>0<i>0<i>0' . '<i>7' . '<i>2<i>4<s>5<s>4<s>3|'.
     # 2-7 -> 4-7
   '<:child-of$<b>35<i>0<i>0<i>0<i>0' . '<i>7' . '<i>4<i>7<s>6<s>4<s>2' .
     ']' ,
   'Check sorted relations'
 );

done_testing;
__END__
