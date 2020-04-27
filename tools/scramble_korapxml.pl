#!/usr/bin/env perl
use Mojo::Base -strict;
use Mojo::DOM;
use Mojo::File qw'path';
use Mojo::ByteStream 'b';
use String::Random;
use Pod::Usage;
use Getopt::Long qw/GetOptions :config no_auto_abbrev/;

#############################################################
# This helper tool iterates over a single KorAP-XML files   #
# and randomizes all word strings occurring following       #
# several rules. This is useful to create example files     #
# based on corpora that can't be published.                 #
# (c) IDS Mannheim                                          #
#############################################################

my %ERROR_HASH = (
  -sections => 'NAME|SYNOPSIS',
  -verbose  => 99,
  -output   => '-',
  -exit     => 1
);

my ($orig_folder, $scr_folder);
GetOptions(
  'input|i=s' => \$orig_folder,
  'output|o=s' => \$scr_folder,
  'help|h'      => sub {
    pod2usage(
      -sections => 'NAME|SYNOPSIS|DESCRIPTION|ARGUMENTS|OPTIONS',
      -verbose  => 99,
      -output   => '-'
    );
  }
);

unless ($orig_folder || $scr_folder) {
  pod2usage(%ERROR_HASH);
};

my $string_gen = String::Random->new;

# Remember all generated pairs orig -> random
my %replacements = ();
my $offset = 0;
my @offsets = ();

# Turn a word into a random word with similar characteristics
sub get_rnd_word {
  my $o_word = shift;
  return $o_word unless $o_word =~ /[a-z]/i;

  # Return the old replacement
  if ($replacements{$o_word}) {
    return $replacements{$o_word};
  };

  my $word = $o_word;

  # Turn the word into a pattern for String::Random
  # c: Any Latin lowercase character [a-z]
  # C: Any Latin uppercase character [A-Z]
  # n: Any digit [0-9]
  # !: A punctuation character
  $word =~ tr/ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyzöäü1234567890~`!@$%^&*()-_+={}[]|\\:;"'.<>?\/#,/CCCCCCCCCCCCCCCCCCCCCCCCCCccccccccccccccccccccccccccccccnnnnnnnnnn!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!/;
  $word =~ s/[^Ccn!]/n/g;
  $replacements{$o_word} = $string_gen->randpattern($word);
}

# 1. Load data.xml
# replace all surface forms of /[a-z]/
# with character strings of the same length, randomly created.
# Create an array, accessible by offsets.
my $data_file = $orig_folder . '/data.xml';
# Process the data file and replace all surface words with random words
my $data = Mojo::File->new($data_file)->slurp;
my $dom = Mojo::DOM->new->xml(1)->parse(b($data)->decode);
my $new_text = b($dom->at('text')->text)->split(
  " "
)->map(
  sub {
    my $token = get_rnd_word($_);
    $offsets[$offset] = $token;
    # print $offset, ':', $_, ':', $token,"\n";
    $offset += length($token);
    $offset++; # space

    # exit if $offset > 300;
    return $token;
  }
)->join(
  " "
);
$dom->at('text')->content($new_text);

# Create folder
path($scr_folder)->make_path->child('data.xml')->spurt(b($dom->to_string)->encode);


# 2. Take some css selectors and rename attributes,
# either according to the surface form ("=") or
# somehow derived ("^"), or random as well ("~"),
# based on the given content, that can be randomized and
# stuffed in a hash as well.
# If no CSS rules are parsed, the file will just be copied.

scramble('dgd/annot.xml' => [
  ["f[name=trans]", "="],
  ["f[name=lemma]", "^"],
  ["f[name=pos]", "~"]
] => 'dgd/annot.xml');

scramble('struct/structure.xml');
scramble('header.xml');

# Scramble an annotation file
sub scramble {
  my ($input, $rules, $output) = @_;
  my $data_file = path($orig_folder)->child($input);

  unless (-f $data_file) {
    warn "$data_file does not exist";
    return;
  };

  my $data = $data_file->slurp;

  # Only transfer if rules exist
  if ($rules) {
    my $dom = Mojo::DOM->new->xml(1)->parse(b($data)->decode);

    foreach (@$rules) {
      transform($dom, $_->[0], $_->[1]);
    };

    $data = b($dom->to_string)->encode;
  }

  else {

    # Just copy the data
    $output = $input;
  };

  my $file = Mojo::File->new($scr_folder)->child($output);
  path($file->dirname)->make_path;
  $file->spurt($data);
};


# Iterate over an annotation document and scramble
# all textual content based on CSS rules
sub transform {
  my ($dom, $selector, $rule) = @_;

  $dom->find("spanList > span")->each(
    sub {
      my $from = $_->attr("from");
      my $to = $_->attr("to");
      $_->find($selector)->each(
        sub {
          my $word = $_->text;

          unless ($offsets[$from]) {
            # warn '!!! Unknown word at ' . $from . '!';
            $_->content('UNKN');
            return;
          };

          # The derive rule means that the original
          # word is taken and appended the string 'ui'
          if ($rule eq '^') {
            my $deriv = $offsets[$from];
            chop($deriv);
            chop($deriv);
            $_->content($deriv . 'ui');

          }

          # The random rule means the word is replaced by
          # with a random word with the same characterisms.
          elsif ($rule eq '~') {
            $_->content(get_rnd_word($word));
          }

          # Any other rule means, that the original word
          # from the character data is taken.
          else {
            $_->content($offsets[$from])
          }
        }
      )
    }
  )
};

__END__

# Config data:
{
  '/dgd/annot.xml' => [
    ["f[name=norm]", "="],
    ["f[name=lemma]", "^"],
    ["f[name=pos]", "~"]
  ],
  '/dgd/morpho.xml' => [
    ["f[name=norm]", "="],
    ["f[name=lemma]", "^"],
    ["f[name=pos]", "~"]
  ],
  '/dgd/nospeech.xml' => []
}


__END__

=pod

=encoding utf8

=head1 NAME

scramble_korapxml.pl - Merge KorAP-XML data and create Krill documents


=head1 SYNOPSIS

  scramble_korapxml.pl -i <input-directory> -o <output-directory>


=head1 DESCRIPTION

This helper tool iterates over a single KorAP-XML folder
and randomizes all word strings occurring following
several rules. This is useful to create example files
based on corpora that can't be published.

Two identical words in a single run will always be transfered
to the same target word.

The C<data.xml> file will be scrambled automatically.
