#!/usr/bin/env perl
use strict;
use warnings;
use Test::More;
use Mojo::ByteStream 'b';
use utf8;
use lib 'lib', '../lib';

use_ok('KorAP::XML::Field::MultiTermTokenStream');

ok(my $mtt = KorAP::XML::Field::MultiTermToken->new, 'New token');
ok(defined $mtt->o_start(0), 'Set start character offset');
ok($mtt->o_end(5), 'Set end character offset');
ok($mtt->add(term => '@:k=N',
	     payload =>'<s>9'), 'Add token');
ok($mtt->add(term => 'a=N',
	     payload =>'<b>144'), 'Add token');
ok($mtt->add(term => '<>:b=N',
	     o_start => 0,
	     o_end => 5,
	     p_end => 5), 'Add token');
ok($mtt->add(term => 'c=N', payload => '<b>144'), 'Add token');
ok($mtt->add(term => '<>:d=N',
	     o_start => 0,
	     o_end => 5,
	     p_end => 6,
	     payload => '<b>7'), 'Add token');
ok($mtt->add(term => '@:j=N',
	     payload =>'<s>8'), 'Add token');
ok($mtt->add(term => '<>:e=ADJ',
	     o_start => 0,
	     o_end => 5,
	     p_end => 6,
	     payload => '<b>6'), 'Add token');
ok($mtt->add(term => '<>:f=N',
	     o_start => 0,
	     o_end => 5,
	     p_end => 6,
	     payload => '<b>5<b>122'), 'Add token');
ok($mtt->add(term => 'g=N',
	     payload =>'<b>144'), 'Add token');
ok($mtt->add(term => '@:h=N',
	     payload =>'<s>5'), 'Add token');
ok($mtt->add(term => '@:i=N',
	     payload =>'<s>3'), 'Add token');

is($mtt->to_string,
   '[(0-5)<>:b=N$<i>0<i>5<i>5|'.
     '<>:e=ADJ$<i>0<i>5<i>6<b>6|'.
       '<>:d=N$<i>0<i>5<i>6<b>7|'.
	 '<>:f=N$<i>0<i>5<i>6<b>5<b>122|'.
	   '@:i=N$<s>3|'.
	     '@:h=N$<s>5|'.
	       '@:j=N$<s>8|'.
		 '@:k=N$<s>9|'.
		   'a=N$<b>144|'.
		     'c=N$<b>144|'.
		       'g=N$<b>144]', 'Check string');

ok($mtt = KorAP::XML::Field::MultiTermToken->new, 'New token');
ok(defined $mtt->o_start(0), 'Set start character offset');
ok($mtt->o_end(5), 'Set end character offset');

# 2-7 to 2-4
ok($mtt->add(term => '<:child-of', p_end => 7, payload => '<i>2<i>4<s>5<s>4<s>3'), 'New rel');

# 2-4 to 3
ok($mtt->add(term => '<:child-of', p_end => 4, payload => '<b>0<i>3<s>3<s>3<s>1'), 'New rel');

# 2 to 2-4
# <i>startright<i>endright<s>relation-id<s>left-id<s>right-id
ok($mtt->add(term => '>:child-of', payload => '<i>2<i>4<s>2<s>1<s>3'), 'New rel');

# 2-4 to 2-7
ok($mtt->add(term => '>:child-of', p_end => 4, payload => '<i>2<i>7<s>1<s>3<s>4'), 'New rel');

# 2-4 t0 4
ok($mtt->add(term => '<:child-of', p_end => 4, payload => '<b>0<i>4<s>4<s>3<s>1'), 'New rel');

# 2-7 to 1-7
ok($mtt->add(term => '>:child-of', p_end => 7, payload => '<i>1<i>7<s>2<s>4<s>2'), 'New rel');

# 2-7 to 4-7
ok($mtt->add(term => '<:child-of', p_end => 7, payload => '<i>4<i>7<s>6<s>4<s>2'), 'New rel');

# 2 to 3
ok($mtt->add(term => '>:child-of', payload => '<i>3<s>2<s>4<s>2'), 'New rel');

is($mtt->to_string, '[(0-5)>:child-of$<i>2<i>4<s>2<s>1<s>3|>:child-of$<i>3<s>2<s>4<s>2|>:child-of$<i>4<i>2<i>7<s>1<s>3<s>4|<:child-of$<i>4<b>0<i>3<s>3<s>3<s>1|<:child-of$<i>4<b>0<i>4<s>4<s>3<s>1|>:child-of$<i>7<i>1<i>7<s>2<s>4<s>2|<:child-of$<i>7<i>2<i>4<s>5<s>4<s>3|<:child-of$<i>7<i>4<i>7<s>6<s>4<s>2]', 'Check sorted relations');
# 2 -> 2-4
# >:child-of$<i>2<i>4<s>2<s>1<s>3
# 2 -> 3
# >:child-of$<i>3<s>2<s>4<s>2
# 2-4 -> 2-7
# >:child-of$<i>4<i>2<i>7<s>1<s>3<s>4
# 2-4 -> 3
# <:child-of$<i>4<b>0<i>3<s>3<s>3<s>1
# 2-4 -> 4
# <:child-of$<i>4<b>0<i>4<s>4<s>3<s>1
# 2-7 -> 1-7
# >:child-of$<i>7<i>1<i>7<s>2<s>4<s>2
# 2-7 -> 2-4
# <:child-of$<i>7<i>2<i>4<s>5<s>4<s>3
# 2-7 -> 4-7
# <:child-of$<i>7<i>4<i>7<s>6<s>4<s>2

done_testing;


__END__

