package KorAP::Document;
use Mojo::Base -base;
use v5.16;

use Mojo::ByteStream 'b';
use Mojo::DOM;
use Carp qw/croak/;
use KorAP::Document::Primary;

our @ATTR = qw/id corpus_id pub_date
	       title sub_title pub_place/;
has 'path';
has [@ATTR];

has log => sub { Log::Log4perl->get_logger(__PACKAGE__) };

# parse document
sub parse {
  my $self = shift;
  my $file = b($self->path . 'data.xml')->slurp;

  state $unable = 'Unable to parse document';

  $self->log->trace('Parse document ' . $self->path);

  my $dom = Mojo::DOM->new($file);

  my $rt = $dom->at('raw_text');

  # Get document id and corpus id
  if ($rt && $rt->attr('docid')) {
    $self->id($rt->attr('docid'));
    if ($self->id =~ /^([^_]+)_/) {
      $self->corpus_id($1);
    }
    else {
      croak $unable;
    };
  }
  else {
    croak $unable;
  };

  # Get primary data
  my $pd = $rt->at('text');
  if ($pd) {

    $pd = b($pd->text)->decode;
    $self->{pd} = KorAP::Document::Primary->new($pd->to_string);
  }
  else {
    croak $unable;
  };

  # Get meta data
  $self->_parse_meta;
  return 1;
};


# Primary data
sub primary {
  $_[0]->{pd};
};

sub author {
  my $self = shift;

  # Set authors
  if ($_[0]) {
    return $self->{authors} = [
      grep { $_ !~ m{^\s*u\.a\.\s*$} } split(/;\s+/, shift())
    ];
  }
  return ($self->{authors} // []);
};

sub text_class {
  my $self = shift;
  if ($_[0]) {
    return $self->{topics} = [ @_ ];
  };
  return ($self->{topics} // []);
};



sub _parse_meta {
  my $self = shift;

  my $file = b($self->path . 'header.xml')->slurp->decode('iso-8859-1');

  my $dom = Mojo::DOM->new($file);
  my $monogr = $dom->at('monogr');

  # Get title
  my $title = $monogr->at('h\.title[type=main]');
  $self->title($title->text) if $title;

  # Get Subtitle
  my $sub_title = $monogr->at('h\.title[type=sub]');
  $self->sub_title($sub_title->text) if $sub_title;

  # Get Author
  my $author = $monogr->at('h\.author');
  $self->author($author->all_text) if $author;

  # Get pubDate
  my $year = $dom->at("pubDate[type=year]");
  $year = $year ? $year->text : 0;
  my $month = $dom->at("pubDate[type=month]");
  $month = $month ? $month->text : 0;
  my $day = $dom->at("pubDate[type=day]");
  $day = $day ? $day->text : 0;

  $year = 0  if $year  !~ /^\d+$/;
  $month = 0 if $month !~ /^\d+$/;
  $day = 0   if $day   !~ /^\d+$/;

  my $date = $year ? ($year < 100 ? '20' . $year : $year) : '0000';
  $date .= length($month) == 1 ? '0' . $month : $month;
  $date .= length($day) == 1 ? '0' . $day : $day;

  $self->pub_date($date);

  # Get textClasses
  my @topic;
  $dom->find("textClass catRef")->each(
    sub {
      my ($ign, @ttopic) = split('\.', $_->attr('target'));
      push(@topic, @ttopic);
    }
  );
  $self->text_class(@topic);
};

sub to_string {
  my $self = shift;

  my $string;

  foreach (@ATTR) {
    if (my $att = $self->$_) {
      $att =~ s/\n/ /g;
      $att =~ s/\s\s+/ /g;
      $string .= $_ . ' = ' . $att . "\n";
    };
  };

  if ($self->author) {
    foreach (@{$self->author}) {
      $_ =~ s/\n/ /g;
      $_ =~ s/\s\s+/ /g;
      $string .= 'author = ' . $_ . "\n";
    };
  };

  if ($self->text_class) {
    foreach (@{$self->text_class}) {
      $string .= 'text_class = ' . $_ . "\n";
    };
  };

  return $string;
};

sub _k {
  my $x = $_[0];
  $x =~ s/_(\w)/\U$1\E/g;
  $x =~ s/id$/ID/gi;
  return $x;
};


sub to_hash {
  my $self = shift;

  my %hash;

  foreach (@ATTR) {
    if (my $att = $self->$_) {
      $att =~ s/\n/ /g;
      $att =~ s/\s\s+/ /g;
      $hash{_k($_)} = $att;
    };
  };

  for ('author') {
      $hash{_k($_)} = join(',', @{ $self->$_ });
  };

  for ('text_class') {
      $hash{_k($_)} = join(' ', @{ $self->$_ });
  };

  return \%hash;
};


1;


__END__

=pod

=head1 NAME

KorAP::Document


=head1 SYNOPSIS

  my $doc = KorAP::Document->new(
    path => 'mydoc-1/'
  );

  $doc->parse;

  print $doc->title;


=head1 DESCRIPTION

Parse the primary and meta data of a document.


=head2 ATTRIBUTES

=head2 id

  $doc->id(75476);
  print $doc->id;

The unique identifier of the document.


=head2 corpus_id

  $doc->corpus_id(4);
  print $doc->corpus_id;

The unique identifier of the corpus.


=head2 path

  $doc->path("example-004/");
  print $doc->path;

The path of the document.


=head2 title

  $doc->title("Der Name der Rose");
  print $doc->title;

The title of the document.


=head2 sub_title

  $doc->sub_title("Natürlich eine Handschrift");
  print $doc->sub_title;

The title of the document.


=head2 pub_place

  $doc->pub_place("Rom");
  print $doc->pub_place;

The publication place of the document.


=head2 pub_date

  $doc->pub_place("19800404");
  print $doc->pub_place;

The publication date of the document,
in the format "YYYYMMDD".


=head2 primary

  print $doc->primary->data(0,20);

The L<KorAP::Document::Primary> object containing the primary data.


=head2 author

  $doc->author('Binks, Jar Jar; Luke Skywalker');
  print $doc->author->[0];

Set the author value as semikolon separated list of names or
get an array reference of author names.

=head2 text_class

  $doc->text_class(qw/news sports/);
  print $doc->text_class->[0];

Set the text class as an array or get an array
reference of text classes.


=head1 METHODS

=head2 parse

  $doc->parse;

Run the parsing process of the document


=cut
