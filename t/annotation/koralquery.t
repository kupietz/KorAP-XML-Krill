#!/usr/bin/env perl
use strict;
use warnings;
use utf8;
use Test::More skip_all => 'Not yet implemented';
use lib 't/annotation';
use File::Basename 'dirname';
use File::Spec::Functions 'catdir';

my $path = catdir(dirname(__FILE__), 'corpus', 'doc', '0001');

use_ok('KorAP::XML::Krill');

ok(my $doc = KorAP::XML::Krill->new( path => $path . '/' ), 'Load Korap::Document');

ok($doc->parse
     ->tokenize
       ->annotate('Base', 'Sentences')
	 ->annotate('Base', 'Paragraphs')
	   ->annotate('DeReKo', 'Struct'), 'Annotate');

# Metdata
is($doc->text_sigle, 'Corpus_Doc.0001', 'ID-text');
is($doc->doc_sigle, 'Corpus_Doc', 'ID-doc');
is($doc->corpus_sigle, 'Corpus', 'ID-corpus');
is($doc->title, 'Beispiel Text', 'title');
is($doc->sub_title, 'Beispiel Text Untertitel', 'title');

# diag $doc->to_json;

done_testing;
__END__

{
  "@context" : "http://korap.ids-mannheim.de/ns/koral/0.4/context.jsonld",
# Add krill context!
  "text" : {
    "@type" : "koral:corpus",
    "meta" : {
      "@type" : "koral:meta",
      "s_sigle" : "BSP",
      "s_id" : "BSP",
      "t_title" : "Der Name als Text",
      "k_keywords" : ["Some", "Keywords"],
      "d_date" : "2015-12-03"
    },
    "@value" : {
      "@type" : "koral:doc",
      "meta" : {
	"@type" : "koral:meta",
	"s_sigle" : "BSP/AAA",
	"s_id" : "AAA"
      },
      "@value" : {
	"@type" : "koral:text",
	"meta" : {
	  "@type" : "koral:meta",
	  "s_sigle" : "BSP/AAA/0001",
	  "s_id" : "0001",
	  "s_language" : "de"
        },
	"store" : {
	  ...
	},
	"@value" : {
	  "@type" : "krill:stream",
	  "source" : "opennlp#tokens",
	  "layer" : ["base/s=spans"],
	  "primary" : "...",
	  "name" : "tokens",
	  "foundries": ["base","base/paragraphs","base/sentences"],
	  "stream" : [[ ... ], [ ... ]]
	}
      }
    }
  }
}
