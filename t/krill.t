use strict;
use warnings;
use utf8;
use Test::More;
use lib 'lib', '../lib';

use_ok('KorAP::XML::Krill', 'get_file_name_from_glob');

is(
  get_file_name_from_glob('versuch'),
  'versuch'
);

is(
  get_file_name_from_glob('versuch/alt\seltsam'),
  'versuch-alt-seltsam'
);

is(
  get_file_name_from_glob('versuch/*.xml'),
  'versuch-.xml'
);

is(
  get_file_name_from_glob('versuch//[a-z]{2,4}.xml'),
  'versuch-a-z-2-4-.xml'
);

is(
  get_file_name_from_glob('versuch//[a-z]{2,4}.zip'),
  'versuch-a-z-2-4'
);

done_testing;
