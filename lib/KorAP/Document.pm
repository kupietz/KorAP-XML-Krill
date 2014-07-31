package KorAP::Document;
use Mojo::Base -base;
use v5.16;
use Mojo::ByteStream 'b';
use Mojo::Util qw/encode/;
use XML::Fast;
use Try::Tiny;
use Carp qw/croak/;
use KorAP::Document::Primary;
use Log::Log4perl;
use KorAP::Log;
use Mojo::DOM;
use Data::Dumper;

our @ATTR = qw/id
	       corpus_id
	       pub_date
	       title
	       sub_title
	       pub_place/;

our @ADVANCED_ATTR = qw/publisher
			editor
			text_type
			text_type_art
			creation_date
			coll_title
			coll_sub_title
			coll_author
			coll_editor
			/;

has 'path';
has [@ATTR, @ADVANCED_ATTR];

has log => sub {
  if(Log::Log4perl->initialized()) {
    state $log = Log::Log4perl->get_logger(__PACKAGE__);
  };
  state $log = KorAP::Log->new;
  return $log;
};

sub new {
  my $class = shift;
  my $self = bless { @_ }, $class;
  if (exists $self->{path} && $self->{path} !~ m!\/$!) {
    $self->{path} .= '/';
  };
  return $self;
};

# parse document
sub parse {
  my $self = shift;

  my $data_xml = $self->path . 'data.xml';

  my ($rt, $error, $file);

  my $unable = 'Unable to parse document ' . $self->path;

  unless (-e $data_xml) {
    $self->log->warn($unable . ' - no data.xml found');
    $error = 1;
  }

  else {
    $file = b($data_xml)->slurp;

    try {
      local $SIG{__WARN__} = sub {
	$error = 1;
      };
      $rt = xml2hash($file, text => '#text', attr => '-')->{raw_text};
    }
      catch  {
	$self->log->warn($unable);
	$error = 1;
      };
  };

  return if $error;

  $self->log->debug('Parse document ' . $self->path);

  # Get document id and corpus id
  if ($rt && $rt->{'-docid'}) {
    $self->id($rt->{'-docid'});
    if ($self->id =~ /^([^_]+)_/) {
      $self->corpus_id($1);
    }
    else {
      croak $unable . ': ID not parseable';
    };
  }
  else {
    croak $unable . ': No raw_text found or no ID';
  };

  # Get primary data
  my $pd = $rt->{text};
  if ($pd) {
    $self->{pd} = KorAP::Document::Primary->new($pd);
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
  my $analytic = $dom->at('analytic');

  if ($analytic) {
    # Get title
    my $title = $analytic->at('h\.title[type=main]');
    $self->title($title->text) if $title;

    # Get Subtitle
    my $sub_title = $analytic->at('h\.title[type=sub]');
    $self->sub_title($sub_title->text) if $sub_title;

    # Get Author
    my $author = $analytic->at('h\.author');
    $self->author($author->all_text) if $author;

    # Get Editor
    my $editor = $analytic->at('editor');
    $self->editor($editor->all_text) if $editor;
  };

  # Get PubPlace
  my $place = $dom->at('pubPlace');
  $self->pub_place($place->all_text) if $place;

  # Get Publisher
  my $publisher = $dom->at('publisher');
  $self->publisher($publisher->all_text) if $publisher;

  my $mono = $dom->at('monogr');
  if ($mono) {
    # Get title
    my $title = $mono->at('h\.title[type=main]');

    # It's a monograph
    if (!$self->title) {
      $self->title($title->text) if $title;

      # Get Subtitle
      my $sub_title = $mono->at('h\.title[type=sub]');
      $self->sub_title($sub_title->text) if $sub_title;

    }
    else {
      $self->coll_title($title->text) if $title;

      # Get Subtitle
      my $sub_title = $mono->at('h\.title[type=sub]');
      $self->coll_sub_title($sub_title->text) if $sub_title;
    };

    # Get Author
    my $author = $mono->at('h\.author');
    $self->coll_author($author->all_text) if $author;

    # Get editor
    my $editor = $mono->at('editor');
    $self->coll_editor($editor->all_text) if $editor;
  };

  # Get text type
  my $text_type = $dom->at('textDesc textType');
  $self->text_type($text_type->all_text) if $text_type;

  # Get text type
  my $text_type_art = $dom->at('textDesc textTypeArt');
  $self->text_type_art($text_type_art->all_text) if $text_type_art;


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

  # creatDate
  my $createdate = $dom->at('creatDate');
  if ($createdate) {
    $createdate = $createdate->all_text;
    if (index($createdate, '-') > -1) {
      $self->log->warn("Creation date ranges are not supported yet");
    }
    else {
      $createdate =~ s{^(\d{4})$}{$1\.00};
      $createdate =~ s{^(\d{4})\.(\d{2})$}{$1\.$2\.00};
      if ($createdate =~ /^\d{4}\.\d{2}\.\d{2}$/) {
	$createdate =~ tr/\.//d;
	$self->creation_date($createdate);
      };
    };
  };

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

  $self->parse unless $self->id;

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



sub _parse_meta_fast {
  my $self = shift;

  #  my $file = b($self->path . 'header.xml')->slurp->decode('iso-8859-1');
    my $file = b($self->path . 'header.xml')->slurp;

  my ($meta, $error);
  my $unable = 'Unable to parse document ' . $self->path;

  try {
      local $SIG{__WARN__} = sub {
	  $error = 1;
      };
      $meta = xml2hash($file, text => '#text', attr => '-', array => ['h.title', 'imprint', 'catRef', 'h.author'])->{idsHeader};
  }
  catch  {
      $self->log->warn($unable);
      $error = 1;
  };

  return if $error;

  my $bibl_struct = $meta->{fileDesc}->{sourceDesc}->{biblStruct};
  my $analytic = $bibl_struct->{analytic};

  my $titles = $analytic->{'h.title'};
  foreach (@$titles) {
    if ($_->{'-type'} eq 'main') {
      $self->title($_->{'#text'});
    }
    elsif ($_->{'-type'} eq 'sub') {
      $self->sub_title($_->{'#text'});
    };
  };

  # Get Author
  if (my $author = $analytic->{'h.author'}) {
    $self->author($author->[0]);
  };

  # Get pubDate
  my $date = $bibl_struct->{monogr}->{imprint};
  my ($year, $month, $day) = (0,0,0);
  foreach (@$date) {
    warn $date;
    if ($date->{-type} eq 'year') {
      $year = $date->{'#text'};
    }
    elsif ($date->{-type} eq 'month') {
      $month = $date->{'#text'};
    }
    elsif ($date->{-type} eq 'day') {
      $day = $date->{'#text'};
    };
  };

  $year  = 0 if $year  !~ /^\d+$/;
  $month = 0 if $month !~ /^\d+$/;
  $day   = 0 if $day   !~ /^\d+$/;

  $date = $year ? ($year < 100 ? '20' . $year : $year) : '0000';
  $date .= length($month) == 1 ? '0' . $month : $month;
  $date .= length($day) == 1 ? '0' . $day : $day;

  $self->pub_date($date);

  # Get textClasses
  my @topic;
  my $textClass = $meta->{profileDesc}->{textClass}->{catRef};
  foreach (@$textClass) {
    my ($ign, @ttopic) = split('\.', $_->{'-target'});
    push(@topic, @ttopic);
  };
  $self->text_class(@topic);
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


Deal with:
        <attribute name="info">
          <documentation xmlns="http://relaxng.org/ns/compatibility/annotations/1.0">kind of
            information expressed by the given layer of annotation (there may, and often will, be
            more than one)</documentation>
          <list>
            <oneOrMore>
              <choice>
                <value type="NCName">pos</value>
                <value type="NCName">lemma</value>
                <value type="NCName">msd</value>
                <documentation xmlns="http://relaxng.org/ns/compatibility/annotations/1.0">'msd' is
                  the traditional abbreviation for "morphosyntactic description", listing info on
                  e.g. tense, person, case, etc.</documentation>
                <value type="NCName">dep</value>
                <documentation xmlns="http://relaxng.org/ns/compatibility/annotations/1.0">'dep' is
                  information about types of relations, used in dependency-style annotations; it is
                  an indication for the visualiser that word-to-word relationships should be
                  displayed</documentation>
                <value type="NCName">lbl</value>
                <documentation xmlns="http://relaxng.org/ns/compatibility/annotations/1.0">'lbl'
                  indicates the presence of labels over dependency relations</documentation>
                <value type="NCName">const</value>
                <documentation xmlns="http://relaxng.org/ns/compatibility/annotations/1.0">'const'
                  stands for 'constituency' or hierarchical, tree-based annotations; it is an
                  indication for the visualiser that it should display syntactic
                  trees</documentation>
                <value type="NCName">cat</value>
                <documentation xmlns="http://relaxng.org/ns/compatibility/annotations/1.0">'cat' is
                  used for syntactic categories, as separate from pos; note that these sets need not
                  be disjoint (at the lexical level, they usually overlap), but the frontend prefers
                  to keep them separate. 'cat' will be found in the context of chunking or
                  hierarchical parsing and will characterise nodes; it may also be found in
                  dependency annotations, to indicate labels on nodes, as opposed to labels on arcs
                  (the latter are signalled by 'lbl')</documentation>
                <value type="NCName">struct</value>
                <documentation xmlns="http://relaxng.org/ns/compatibility/annotations/1.0">all
                  non-linguistic information (headers, highlights, etc.)</documentation>
                <value type="NCName">frag</value>
                <documentation xmlns="http://relaxng.org/ns/compatibility/annotations/1.0"
                  >non-exhaustive coverage (when spanList/@fragmented="true")</documentation>
                <value type="NCName">ne</value>
                <documentation xmlns="http://relaxng.org/ns/compatibility/annotations/1.0">named
                  entities</documentation>
              </choice>
            </oneOrMore>
          </list>
        </attribute>
