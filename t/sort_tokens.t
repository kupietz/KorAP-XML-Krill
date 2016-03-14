#!/usr/bin/env perl
use strict;
use warnings;
use Test::More;
use Mojo::ByteStream 'b';
use utf8;
use lib 'lib', '../lib';

use_ok('KorAP::XML::Index::MultiTermTokenStream');

ok(my $mtt = KorAP::XML::Index::MultiTermToken->new, 'New token');
ok(defined $mtt->o_start(0), 'Set start character offset');
ok($mtt->o_end(5), 'Set end character offset');
ok($mtt->add(term => '@:k=N',
	     pti => 128,
	     payload =>'<s>9'), 'Add token');
ok($mtt->add(term => 'a=N',
	     pti => 129,
	     payload =>'<b>144'), 'Add token');
ok($mtt->add(term => '<>:b=N',
	     pti => 64,
	     o_start => 0,
	     o_end => 5,
	     p_end => 5), 'Add token');
ok($mtt->add(term => 'c=N',
	     pti => 129,
	     payload => '<b>144'), 'Add token');
ok($mtt->add(term => '<>:d=N',
	     pti => 64,
	     o_start => 0,
	     o_end => 5,
	     p_end => 6,
	     payload => '<b>7'), 'Add token');
ok($mtt->add(term => '@:j=N',
	     pti => 16,
	     payload =>'<s>8'), 'Add token');
ok($mtt->add(term => '<>:e=ADJ',
	     pti => 64,
	     o_start => 0,
	     o_end => 5,
	     p_end => 6,
	     payload => '<b>6'), 'Add token');
ok($mtt->add(term => '<>:f=N',
	     pti => 64,
	     o_start => 0,
	     o_end => 5,
	     p_end => 6,
	     payload => '<b>5<b>122'), 'Add token');
ok($mtt->add(term => 'g=N',
	     pti => 129,
	     payload =>'<b>144'), 'Add token');
ok($mtt->add(term => '@:h=N',
	     pti => 16,
	     payload =>'<s>5'), 'Add token');
ok($mtt->add(term => '@:i=N',
	     pti => 16,
	     payload =>'<s>3'), 'Add token');

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
ok(defined $mtt->o_start(0), 'Set start character offset');
ok($mtt->o_end(5), 'Set end character offset');

# 2-7 to 2-4
ok($mtt->add(term => '<:child-of',
	     pti => 35,
	     payload => '<i>0<i>0<i>0<i>0'. # character os
	       '<i>7<i>2<i>4<s>5<s>4<s>3'
	   ), 'New rel');

# 2-4 to 3
ok($mtt->add(term => '<:child-of',
	     pti => 34,
	     payload => '<i>0<i>0' . # character os
	       '<i>4<i>3<s>3<s>3<s>1'
	   ), 'New rel');

# 2 to 2-4
# <i>startright<i>endright<s>relation-id<s>left-id<s>right-id
ok($mtt->add(term => '>:child-of',
	     pti => 33,
	     payload => '<i>0<i>0'. # character os
	       '<i>2<i>4<s>2<s>1<s>3'
	   ), 'New rel');

# 2-4 to 2-7
ok($mtt->add(term => '>:child-of',
	     pti => 35,
	     payload => '<i>0<i>0<i>0<i>0' . # character os
	       '<i>4<i>2<i>7<s>1<s>3<s>4'
	   ), 'New rel');

# 2-4 to 4
ok($mtt->add(term => '<:child-of',
	     pti => 34,
	     payload => '<i>0<i>0' . # character os
	       '<i>4<i>4<s>4<s>3<s>1'), 'New rel');


# 2-7 to 1-7
ok($mtt->add(term => '>:child-of',
	     pti => 35,
	     payload => '<i>0<i>0<i>0<i>0' . # character os
	       '<i>7<i>1<i>7<s>2<s>4<s>2'), 'New rel');

# 2-7 to 4-7
ok($mtt->add(term => '<:child-of',
	     pti => 35,
	     payload => '<i>0<i>0<i>0<i>0' . # character os
	       '<i>7<i>4<i>7<s>6<s>4<s>2'), 'New rel');



# 2 to 3
ok($mtt->add(term => '>:child-of',
	     pti => 32,
	     payload => '<i>3<s>2<s>4<s>2'
	   ), 'New rel');

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
