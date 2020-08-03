package MyLog;
use Mojo::Base -base;

has is_debug => 0;
has warn  => sub {};
has debug => sub {};
has trace => sub {};
has error => sub {};

package main;
use strict;
use warnings;
use Test::More;
use Data::Dumper;
use JSON::XS;
use Log::Log4perl;

if ($ENV{SKIP_REAL}) {
  plan skip_all => 'Skip real tests';
};

use Benchmark qw/:hireswallclock/;

my $t = Benchmark->new;

use utf8;
use lib 'lib', '../lib';

use File::Basename 'dirname';
use File::Spec::Functions 'catdir';

use_ok('KorAP::XML::Krill');

# This will check files from the dortmund chat corpus

# New
my $path = catdir(dirname(__FILE__), 'corpus','NGAFC','B14','00010');

ok(my $doc = KorAP::XML::Krill->new( path => $path . '/' ), 'Load Korap::Document');
ok($doc->parse, 'Parse document');

is($doc->text_sigle, 'NGAFC/B14/00010', 'Correct text sigle');
is($doc->doc_sigle, 'NGAFC/B14', 'Correct document sigle');
is($doc->corpus_sigle, 'NGAFC', 'Correct corpus sigle');

my $meta = $doc->meta;
is($meta->{T_title}, 'Re: Ranking der Zuverlässigkeit von Filesystemen, In: de.sci.informatik.misc',
   'Title');
is($meta->{A_publisher}, 'Usenet', 'Publisher');

# Tokenization
use_ok('KorAP::XML::Tokenizer');

my ($token_base_foundry, $token_base_layer) = (qw/Base Tokens/);

# Get tokenization
my $tokens = KorAP::XML::Tokenizer->new(
  path => $doc->path,
  doc => $doc,
  foundry => $token_base_foundry,
  layer => $token_base_layer,
  name => 'tokens',
  log => MyLog->new
);

ok($tokens, 'Token Object is fine');
ok(!$tokens->parse, 'Token parsing is not fine');

done_testing;


__END__
