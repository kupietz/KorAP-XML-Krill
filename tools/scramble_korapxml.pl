#!/usr/bin/env perl
use Mojo::Base -strict;
use Mojo::DOM;
use Mojo::File qw'path';
use Mojo::JSON qw'decode_json';
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
  'rules|r=s' => \(my $rule_file),
  'help|h'      => sub {
    pod2usage(
      -sections => 'NAME|SYNOPSIS|DESCRIPTION|ARGUMENTS|OPTIONS',
      -verbose  => 99,
      -output   => '-'
    );
  }
);

unless ($orig_folder || $scr_folder || $rule_file) {
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

if ($rule_file) {
  $rule_file = Mojo::File->new($rule_file);
  if (-e $rule_file) {
    my $rules = decode_json $rule_file->slurp;

    foreach my $rule (@$rules) {
      scramble(@$rule);
    };
  };
};

# Scramble an annotation file
sub scramble {
  my ($input, $rules) = @_;
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
      if ($input =~ /header\.xml$/) {
        transform_header($dom, $_->[0]);
      } else {
        transform($dom, $_->[0], $_->[1]);
      };
    };

    $data = b($dom->to_string)->encode;
  };

  my $file = Mojo::File->new($scr_folder)->child($input);
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


# Transform header file
sub transform_header {
  my ($dom, $selector) = @_;

  $dom->find($selector)->each(
    sub {
      my $word = $_->text;

      # The random rule means the word is replaced by
      # with a random word with the same characterisms.
      $_->content(get_rnd_word($word));
    }
  )
};



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


=head1 OPTIONS

=over 2

=item B<--input|-i> <directory>

The unscrambled KorAP-XML directory.


=item B<--output|-o> <directory>

The output directory


=item B<--rules|-r> <file>

The rule file for transformation as a json file.
Example:

  [
    [
      "dgd/annot.xml",
      [
        ["f[name=trans]", "="],
        ["f[name=lemma]", "^"],
        ["f[name=pos]", "~"]
      ]
    ],
    ["struct/structure.xml"]
  ]

All elements of the json list are copied from the input directory to
the output directory.
The C<data.xml> file will be automatically coppied and scrambled.
If the file name is followed by a rule set, these
CSS selector rules followed by a transformation type marker
are used to transform elements of the file.

All CSS selectors for annotation files
are nested in C<spanList > span>.

The following markers are supported:

=over 4

=item B<=>

Take the scrambled surface form from the C<data.xml>.

=item B<^>

Take the scrambled surface form from the C<data.xml> and
modify the term by appending the string C<ui>.

=item B<~>

Create a randomized string, keeping the characteristicts of
the original element content.
Two identical words in a single run will always be transfered
to the same target word.

=back

For header files, the rules are not nested and only the
randomized marker C<~> is supported.

=back
