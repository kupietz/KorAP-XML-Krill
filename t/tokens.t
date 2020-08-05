use strict;
use warnings;
use utf8;
use Test::More;
use Benchmark ':hireswallclock';
use lib 'lib', '../lib';

use_ok('KorAP::XML::Index::MultiTerm');

ok(my $term = KorAP::XML::Index::MultiTerm->new('Baum'), 'Create new object');
$term->set_p_start(0);
$term->set_p_end(56);
$term->set_payload('<i>56');
$term->set_o_start(34);
$term->set_o_end(120);

is($term->get_term, 'Baum');
is($term->get_p_start, 0);
is($term->get_p_end, 56);
is($term->get_o_start, 34);
is($term->get_o_end, 120);
is($term->get_payload, '<i>56');
is($term->to_string, 'Baum$<i>34<i>120<i>56<i>56');

ok($term = KorAP::XML::Index::MultiTerm->new('Baum'), 'Create new object');

is($term->get_term, 'Baum');
is($term->get_p_start, 0);
is($term->get_p_end, 0);
is($term->get_o_start, 0);
is($term->get_o_end, 0);
is($term->get_payload, undef);
is($term->to_string, 'Baum');

ok($term = KorAP::XML::Index::MultiTerm->new('Ba#um'), 'Create new object');

is($term->get_term, 'Ba#um');
is($term->get_p_start, 0);
is($term->get_p_end, 0);
is($term->get_o_start, 0);
is($term->get_o_end, 0);
is($term->get_payload, undef);
is($term->to_string, 'Ba\#um');

ok($term = KorAP::XML::Index::MultiTerm->new('Ba#u$m'), 'Create new object');
$term->set_payload('<i>45');

is($term->get_term, 'Ba#u$m');
is($term->get_p_start, 0);
is($term->get_p_end, 0);
is($term->get_o_start, 0);
is($term->get_o_end, 0);
is($term->get_payload, '<i>45');
is($term->to_string, 'Ba\#u\$m$<i>45');

use_ok('KorAP::XML::Tokenizer');

use utf8;
sub remove_diacritics { KorAP::XML::Tokenizer::remove_diacritics(@_) };

is(remove_diacritics('äöü'), 'aou', 'Remove diacritics');

is(remove_diacritics('Česká'), 'Ceska', 'Removed diacritics');
is(remove_diacritics('Äößa'), 'Aoßa', 'Removed diacritics');

# From comment in http://archives.miloush.net/michkap/archive/2007/05/14/2629747.html
is(remove_diacritics('ÅåÄäÖö'), 'AaAaOo', 'Check swedish');
# Krawfish::Util::String::_list_props('Łł');
is(remove_diacritics('ĄąĆćĘęŁłŃńÓóŚśŹźŻż'), 'AaCcEeLlNnOoSsZzZz', 'Check polish');
is(remove_diacritics('ľščťžýáíéúäôňďĽŠČŤŽÝÁÍÉÚÄÔŇĎ'), 'lsctzyaieuaondLSCTZYAIEUAOND', 'Check slowakish');
is(remove_diacritics('ëőüűŐÜŰ'), 'eouuOUU', 'Check hungarian');
is(remove_diacritics('Ññ¿'), 'Nn¿', 'Check spanish');
is(remove_diacritics('àèòçï'), 'aeoci', 'Check CA?');
is(remove_diacritics('ı'), 'i', 'Check turkish');

# From http://stackoverflow.com/questions/249087/how-do-i-remove-diacritics-accents-from-a-string-in-net#249126
is(remove_diacritics('äáčďěéíľľňôóřŕšťúůýž'), 'aacdeeillnoorrstuuyz');
is(remove_diacritics('ÄÁČĎĚÉÍĽĽŇÔÓŘŔŠŤÚŮÝŽ'), 'AACDEEILLNOORRSTUUYZ');
is(remove_diacritics('ÖÜË'), 'OUE');
is(remove_diacritics('łŁđĐ'), 'lLdD');
is(remove_diacritics('ţŢşŞçÇ'), 'tTsScC');
is(remove_diacritics('øı'), 'oi');

is(remove_diacritics(
  q{Bonjour ça va? C'est l'été! Ich möchte ä Ä á à â ê é è ë Ë É ï Ï î í ì ó ò ô ö Ö Ü ü ù ú û Û ý Ý ç Ç ñ Ñ}),
  q{Bonjour ca va? C'est l'ete! Ich mochte a A a a a e e e e E E i I i i i o o o o O U u u u u U y Y c C n N});

# https://docs.seneca.nl/Smartsite-Docs/Features-Modules/Add-On_Modules/Faceted_Search/FS_Reference/FTS_and_iFTS_technical_background_information/Diacritics_and_Unicode.html
is(remove_diacritics(
  q/!"#$'()*+,-.0123456789:;=?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\]^_` abcdefghijklmnoprstuvwxyz{|}~¡¢£¤¥¦§¨©ª«¬®¯°±²³´µ¶·¸¹º»¼½¾¿−ÀÁÂ ÃÄÅÆÇÈÉÊËÌÍÎÏÐÑÒÓÔÕÖ×ØÙÚÛÜÝÞßàáâãäåæçèéêëìíîïðñòóôõö÷øùúûüýþÿ/),
  q/!"#$'()*+,-.0123456789:;=?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\]^_` abcdefghijklmnoprstuvwxyz{|}~¡¢£¤¥¦§¨©ª«¬®¯°±²³´µ¶·¸¹º»¼½¾¿−AAA AAAÆCEEEEIIIIDNOOOOO×OUUUUYÞßaaaaaaæceeeeiiiiðnooooo÷ouuuuyþy/);

no utf8;

done_testing;
__END__
