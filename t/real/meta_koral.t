use strict;
use warnings;
use utf8;
use Test::More;
use Benchmark ':hireswallclock';
use Mojo::DOM;
use Mojo::File;
use Mojo::ByteStream 'b';
use Data::Dumper;

use File::Basename 'dirname';
use File::Spec::Functions 'catdir';

if ($ENV{SKIP_REAL}) {
  plan skip_all => 'Skip real tests';
};

use_ok('KorAP::XML::Krill');

# WPD/00001
my $path = catdir(dirname(__FILE__), qw!corpus WPD 00001!);
ok(my $doc = KorAP::XML::Krill->new( path => $path . '/' ), 'Load Korap::Document');
like($doc->path, qr!\Q$path\E/!, 'Path');

ok($doc = KorAP::XML::Krill->new( path => $path ), 'Load Korap::Document');
like($doc->path, qr!\Q$path\E/$!, 'Path');

ok($doc->parse, 'Parse document');

my $meta = $doc->meta;

my $fields = $meta->to_koral_fields;

# TODO: Check for foundries, tokenSource, layerInfos!

_contains($fields, 'title', 'A', 'text');
_contains($fields, 'textSigle', 'WPD/AAA/00001', 'string');
_contains($fields, 'docSigle', 'WPD/AAA', 'string');
_contains($fields, 'corpusSigle', 'WPD', 'string');
_contains($fields, 'pubDate', '2005-03-28', 'date');
_contains($fields, 'pubPlace', 'URL:http://de.wikipedia.org', 'string');
_contains($fields, 'textClass', 'freizeit-unterhaltung reisen wissenschaft populaerwissenschaft', 'keywords');
_contains($fields, 'author', 'Ruru; Jens.Ol; Aglarech; u.a.', 'text');

_contains($fields, 'editor', 'data:,wikipedia.org', 'attachement');
_contains($fields, 'publisher', 'data:,Wikipedia', 'attachement');
_contains($fields, 'creationDate', '2005', 'date');
_contains_not($fields, 'textType');
_contains_not($fields, 'textTypeArt');
_contains_not($fields, 'textTypeRef');
_contains_not($fields, 'textDomain');
_contains_not($fields, 'keywords');

_contains_not($fields, 'subTitle');


sub _contains {
  my ($fields, $key, $value, $type) = @_;

  local $Test::Builder::Level = $Test::Builder::Level + 1;

  my $tb = Test::More->builder;

  foreach (@$fields) {
    if ($_->{key} eq $key) {

      my $cmp_value = $_->{value};
      if ($_->{type} eq 'type:keywords' && ref($cmp_value) eq 'ARRAY') {
        $cmp_value = join(' ', @{$cmp_value});
      };

      if ($cmp_value eq $value) {
        if ($_->{type} eq 'type:' . $type) {
          $tb->ok(1, 'Contains ' . $key);
        }
        else {
          $tb->ok(0, 'Contains ' . $key . ' but type ' . $_->{type} . ' != ' . $type);
        };
      }
      else {
        $tb->ok(0, 'Contains ' . $key . ' but value ' . $cmp_value . ' != ' . $value);
      };
      return;
    }
  };

  $tb->ok(0, 'Contains ' . $key);
};

sub _contains_not {
  my ($fields, $key) = @_;

  local $Test::Builder::Level = $Test::Builder::Level + 1;

  my $tb = Test::More->builder;

  foreach (@$fields) {
    if ($_->{key} eq $key) {
      $tb->ok(0, 'Contains not ' . $key);
      return;
    }
  };

  $tb->ok(1, 'Contains not ' . $key);
};

done_testing;
__END__
