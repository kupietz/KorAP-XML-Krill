#!/usr/bin/env perl
use strict;
use warnings;
use utf8;
use JSON::XS;
use Test::More;
use Scalar::Util qw/weaken/;
use Data::Dumper;
use lib 't/annotation';
use TestInit;
use File::Basename 'dirname';
use File::Spec::Functions 'catdir';


my $path = catdir(dirname(__FILE__), 'corpus', 'doc', '0001');

ok(my $doc = KorAP::XML::Krill->new( path => $path . '/' ), 'Load Korap::Document');
ok($doc->parse, 'Parse document');
like($doc->path, qr!\Q$path\E/!, 'Path');

# Metdata
is($doc->text_sigle, 'Corpus/Doc/0001', 'ID-text');
is($doc->doc_sigle, 'Corpus/Doc', 'ID-doc');
is($doc->corpus_sigle, 'Corpus', 'ID-corpus');

my $meta = $doc->meta;

is($meta->{T_title}, 'Beispiel Text', 'title');
is($meta->{T_sub_title}, 'Beispiel Text Untertitel', 'title');
is($meta->{D_pub_date}, '20010402', 'Publication date');
is($meta->{S_pub_place}, 'Mannheim', 'Publication place');
is($meta->{T_author}, 'Mustermann, Max', 'Author');

is($meta->{A_publisher}, 'Artificial articles Inc.', 'Publisher');
is($meta->{A_editor}, 'Monika Mustermann', 'Editor');
is($meta->{S_text_type}, 'Zeitung: Tageszeitung', 'Text Type');
is($meta->{S_text_type_art}, 'Bericht', 'Text Type Art');
is($meta->{S_text_type_ref}, 'Aphorismen', 'Text Type Ref');
ok(!$meta->{S_text_column}, 'Text Column');
ok(!$meta->{S_text_domain}, 'Text Domain');
is($meta->{D_creation_date}, '19990601', 'Creation Date');
ok(!$meta->{license}, 'License');
ok(!$meta->{pages}, 'Pages');
ok(!$meta->{A_file_edition_statement}, 'File Edition Statement');
ok(!$meta->{A_bibl_edition_statement}, 'Bibl Edition Statement');
ok(!$meta->{A_reference}, 'Reference');
is($meta->{S_language}, 'de', 'Language');

is($meta->{T_doc_title}, 'Beispiel Dokument', 'Doc: title');
ok(!$meta->{T_doc_sub_title}, 'Doc: subtitle');
ok(!$meta->{A_doc_editor}, 'Doc: editor');
ok(!$meta->{T_doc_author}, 'Doc: author');

is($meta->{T_corpus_title}, 'Werke von Beispiel', 'Corpus: title');
ok(!$meta->{T_corpus_sub_title}, 'Corpus: subtitle');
is($meta->{A_corpus_editor}, 'Mustermann, Monika', 'Corpus: editor');
is($meta->{T_corpus_author}, 'Mustermann, Max', 'Corpus: author');


done_testing;

__END__
