package KorAP::XML::Krill;
use Mojo::Base -base;
use Mojo::ByteStream 'b';
use Mojo::Util qw/encode/;
use Scalar::Util qw/weaken/;
use XML::Fast;
use Try::Tiny;
use Carp qw/croak/;
use KorAP::XML::Document::Primary;
use Log::Log4perl;
use KorAP::XML::Log;
use Mojo::DOM;
use Data::Dumper;
use File::Spec::Functions qw/catdir catfile catpath splitdir splitpath rel2abs/;

# TODO: Currently metadata is processed multiple times - that's horrible!
#       Due to the kind of processing, processed metadata may be stored in
#       a multiprocess cache instead.

our $VERSION = '0.05';

our @ATTR = qw/text_sigle
	       doc_sigle
	       corpus_sigle
	       title
	       pub_date
	       sub_title
	       pub_place
	       author/;

our @ADVANCED_ATTR = qw/publisher
			editor
			text_type
			text_type_art
			text_type_ref
			text_column
			text_domain
			creation_date
			license
			pages
			file_edition_statement
			bibl_edition_statement
			reference
			language

			doc_title
			doc_sub_title
			doc_editor
			doc_author

			corpus_author
			corpus_title
			corpus_sub_title
			corpus_editor

			availability
			pub_place_key
			/;
# Separate: text_class, keywords

# Removed:    coll_title, coll_sub_title, coll_author, coll_editor
# Introduced: doc_title, doc_sub_title, corpus_editor, doc_editor, corpus_author, doc_author


has 'path';
has [@ATTR, @ADVANCED_ATTR];

has log => sub {
  if(Log::Log4perl->initialized()) {
    state $log = Log::Log4perl->get_logger(__PACKAGE__);
  };
  state $log = KorAP::XML::Log->new;
  return $log;
};


sub new {
  my $class = shift;
  my $self = bless { @_ }, $class;
  if (exists $self->{path}) {
    $self->{path} = rel2abs($self->{path});
    if ($self->{path} !~ m!\/$!) {
      $self->{path} .= '/';
    };
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
    } catch  {
      $self->log->warn($unable);
      $error = 1;
    };
  };

  return if $error;

  $self->log->debug('Parse document ' . $self->path);

  # Get document id and corpus id
  if ($rt && $rt->{'-docid'}) {
    $self->text_sigle($rt->{'-docid'});
    if ($self->text_sigle =~ /^(([^_]+)_[^\._]+?)\..+?$/) {
      $self->corpus_sigle($2);
      $self->doc_sigle($1);
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
    $self->{pd} = KorAP::XML::Document::Primary->new($pd);
  }
  else {
    croak $unable;
  };

  my @path = grep { $_ } splitdir($self->path);
  my @header;

  # Parse the corpus file, the doc file, and the text file for meta information
  foreach (0..2) {
    unshift @header, '/' . catfile(@path, 'header.xml');
    pop @path;
  };

  my @type = qw/corpus doc text/;
  foreach (@header) {
    # Get corpus, doc and text meta data
    my $type = shift(@type);

    next unless -e $_;

    my $slurp = b($_)->slurp;
    $slurp =~ /^[^>]+encoding\s*=\s*(["'])([^\1]+?)\1/;
    my $file = $slurp->decode($2 // 'UTF-8');

    # Get DOM
    my $dom = Mojo::DOM->new($file);

    if ($dom->at('idsHeader') || $dom->at('idsheader')) {
      $self->_parse_meta_i5($dom, $type);
    }
    else {
      $self->_parse_meta_tei($dom, $type);
    };
  };

  return $self;
};


sub tokenize {
  my $self = shift;
  my ($token_foundry, $token_layer) = @_;

  $token_foundry //= 'OpenNLP';
  $token_layer   //= 'Tokens';

  my $tokens = KorAP::Tokenizer->new(
    path => $self->path,
    doc => $self,
    foundry => $token_foundry,
    layer => $token_layer,
    name => 'tokens'
  );

  unless ($tokens->parse) {
    $self->log->warn(
      'Unable to tokenize ' . $self->path .
	' with ' . $token_foundry . '#'
	  . $token_layer
    );
  }
  else {
    weaken $self;
    $self->{tokenizer} = $tokens;
  };

  return $self;
};


# Add annotation
sub annotate {
  my $self = shift;
  unless ($self->{tokenizer}) {
    $self->log->warn('No tokenizer defined')
  }
  else {
    $self->{tokenizer}->add(@_);
  };

  $self;
};


# Store arbitrary data
sub store {
  my $self = shift;
  return $self->{store} unless @_;
  return $self->{store}->{$_[0]} if @_ == 1;
  $self->{store}->{$_[0]} = $_[1];
};


# Primary data
sub primary {
  $_[0]->{pd};
};

#sub author {
#  my $self = shift;
#
#  # Set authors
#  if ($_[0]) {
#    return $self->{authors} = [
#      grep { $_ !~ m{^\s*u\.a\.\s*$} } split(/;\s+/, shift())
#    ];
#  }
#  return ($self->{authors} // []);
#};

sub text_class {
  my $self = shift;
  if ($_[0]) {
    return $self->{topics} = [ @_ ];
  };
  return ($self->{topics} //= []);
};

sub text_class_string {
  return join ' ', @{shift->text_class};
}

sub keywords {
  my $self = shift;
  if ($_[0]) {
    return $self->{keywords} = [ @_ ];
  };
  return ($self->{keywords} //= []);
};

sub keywords_string {
  return join ' ', @{shift->keywords};
}

sub _remove_prefix {
#   return $_[0];

  # This may render some titles wrong, e.g. 'VDI nachrichten 2014' ...
  my $title = shift;
  my $prefix = shift;
  $prefix =~ tr!_!/!;
  if (index($title, $prefix) == 0) {
    $title = substr($title, length($prefix));
    $title =~ s/^\s+//;
    $title =~ s/\s+$//;
  };
  return $title;
};


sub _parse_meta_tei {
  my $self = shift;
  my $dom = shift;
  my $type = shift;

  my $stmt;
  if ($type eq 'text' && ($stmt = $dom->at('titleStmt'))) {

    # Title
    try {
      $stmt->find('title')->each(
	sub {
	  my $type = $_->attr('type') || 'main';
	  $self->title($_->all_text) if $type eq 'main';
	  $self->sub_title($_->all_text) if $type eq 'sub';
	}
      );
    };

    # Author
    try {
      my $author = $stmt->at('author')->attr('ref');

      $author = $self->{ref_author}->{$author};

      if ($author) {

	my $array = $self->keywords;
	$self->author($author->{id});

	if ($author->{age}) {
	  $self->store('sgbrAuthorAgeClass' => $author->{age});
	  push @$array, 'sgbrAuthorAgeClass:' . $author->{age};
	};
	if ($author->{sex}) {
	  $self->store('sgbrAuthorSex' => $author->{sex});
	  push @$array, 'sgbrAuthorSex:' . $author->{sex};
	};
      };
    };

    try {
      my $kodex = $dom->at('item[rend]')->attr('rend');
      if ($kodex) {
	my $array = $self->keywords;
	$self->store('sgbrKodex' => $kodex);
	push @$array, 'sgbrKodex:' . $kodex;
      };
    };
  }

  elsif ($type eq 'doc') {
    try {
      $dom->find('particDesc person')->each(
	sub {

	  $self->{ref_author}->{'#' . $_->attr('xml:id')} = {
	    age => $_->attr('age'),
	    sex => $_->attr('sex'),
	    id => $_->attr('xml:id')
	  }
	});
    };

    try {
      my $lang = $dom->at('language[ident]')->attr('ident');
      $self->language($lang);
    };

    try {
      $stmt = $dom->find('titleStmt > title')->each(
	sub {
	  my $type = $_->attr('type') || 'main';
	  $self->doc_title($_->all_text) if $type eq 'main';
	  $self->doc_sub_title($_->all_text) if $type eq 'sub';
	}
      );
    };
  };
  return;
};



sub _parse_meta_i5 {
  my $self = shift;
  my $dom = shift;
  my $type = shift;

  my $analytic = $dom->at('analytic') || $dom->at('monogr');

  # There is an analytic element
  if ($analytic) {

    # Get title, subtitle, author, editor
    my $title     = $analytic->at('h\.title[type=main]');
    my $sub_title = $analytic->at('h\.title[type=sub]');
    my $author    = $analytic->at('h\.author');
    my $editor    = $analytic->at('editor');

    $title     = $title     ? $title->all_text     : undef;
    $sub_title = $sub_title ? $sub_title->all_text : undef;
    $author    = $author    ? $author->all_text    : undef;
    $editor    = $editor    ? $editor->all_text    : undef;

    if ($type eq 'text') {
      $self->title(_remove_prefix($title, $self->text_sigle)) if $title;
      $self->sub_title($sub_title) if $sub_title;
      $self->editor($editor)       if $editor;
      $self->author($author)       if $author;
    }
    elsif ($type eq 'doc') {
      $self->doc_title(_remove_prefix($title, $self->doc_sigle)) if $title;
      $self->doc_sub_title($sub_title) if $sub_title;
      $self->doc_author($author)       if $author;
      $self->doc_editor($editor)       if $editor;
    }
    elsif ($type eq 'corpus') {
      $self->corpus_title(_remove_prefix($title, $self->corpus_sigle)) if $title;
      $self->corpus_sub_title($sub_title) if $sub_title;
      $self->corpus_author($author)       if $author;
      $self->corpus_editor($editor)       if $editor;
    };
  };

  # Not in analytic
  if ($type eq 'corpus') {
    unless ($self->corpus_title) {
      if (my $title = $dom->at('fileDesc > titleStmt > c\.title')) {
	$self->corpus_title(_remove_prefix($title->all_text, $self->corpus_sigle))
	  if $title->all_text;
      };
    };
  }

  # doc title
  elsif ($type eq 'doc') {
    unless ($self->doc_title) {
      if (my $title = $dom->at('fileDesc > titleStmt > d\.title')) {
	$self->doc_title(_remove_prefix($title->all_text, $self->doc_sigle))
	  if $title->all_text;
      };
    };
  }

  # text title
  elsif ($type eq 'text') {
    unless ($self->title) {
      if (my $title = $dom->at('fileDesc > titleStmt > t\.title')) {
	$self->title(_remove_prefix($title->all_text, $self->text_sigle))
	  if $title->all_text;
      }
    };
  };

  # Get PubPlace
  if (my $place = $dom->at('pubPlace')) {
    $self->pub_place($place->all_text) if $place->all_text;
    $self->pub_place_key($place->attr('key')) if $place->attr('key');
  };

  # Get Publisher
  if (my $publisher = $dom->at('imprint publisher')) {
    $self->publisher($publisher->all_text) if $publisher->all_text;
  };

#  my $mono = $dom->at('monogr');
#  if ($mono) {
#
#    # Get title, subtitle, author, editor
#    my $title     = $mono->at('h\.title[type=main]');
#    my $sub_title = $mono->at('h\.title[type=sub]');
#    my $author    = $mono->at('h\.author');
#    my $editor    = $mono->at('editor');
#
#    $title     = $title     ? $title->all_text     : undef;
#    $sub_title = $sub_title ? $sub_title->all_text : undef;
#    $author    = $author    ? $author->all_text    : undef;
#    $editor    = $editor    ? $editor->all_text    : undef;
#
#    if ($type eq 'text') {
#      $self->title($title)         if $title && !$self->title;
#      $self->sub_title($sub_title) if $sub_title && !$self->sub_title;
#      $self->editor($editor)       if $editor && !$self->editor;
#      $self->author($author)       if $author && !$self->author;
#    }
#    elsif ($type eq 'doc') {
#      $self->doc_title($title)         if $title && !$self->doc_title;
#      $self->doc_sub_title($sub_title) if $sub_title && !$self->doc_sub_title;
#      $self->doc_author($author)       if $author && !$self->doc_author;
#      $self->doc_editor($editor)       if $editor && !$self->doc_editor;
#    }
#    elsif ($type eq 'corpus') {
#      $self->corpus_title($title)         if $title && !$self->corpus_title;
#      $self->corpus_sub_title($sub_title) if $sub_title && !$self->corpus_sub_title;
#      $self->corpus_author($author)       if $author && !$self->corpus_author;
#      $self->corpus_editor($editor)       if $editor && !$self->corpus_editor;
#    };
#  };

  # Get text type
  my $text_desc = $dom->at('textDesc');

  if ($text_desc) {
    if (my $text_type = $text_desc->at('textType')) {
      $self->text_type($text_type->all_text) if $text_type->all_text;
    };

    # Get text domain
    if (my $text_domain = $text_desc->at('textDomain')) {
      $self->text_domain($text_domain->all_text) if $text_domain->all_text;
    };

    # Get text type art
    if (my $text_type_art = $text_desc->at('textTypeArt')) {
      $self->text_type_art($text_type_art->all_text) if $text_type_art->all_text;
    };

    # Get text type art
    if (my $text_type_ref = $text_desc->at('textTypeRef')) {
      $self->text_type_ref($text_type_ref->all_text) if $text_type_ref->all_text;
    };
  };

  # Availability
  try {
    $self->availability(
      $dom->at('availability')->all_text
    );
  };

  # Get pubDate
  my $pub_date = $dom->find('pubDate[type=year]');
  $pub_date->each(
    sub {
      my $x = shift->parent;
      my $year = $x->at("pubDate[type=year]");
      return unless $year;

      $year = $year ? $year->text : 0;
      my $month = $x->at("pubDate[type=month]");
      $month = $month ? $month->text : 0;
      my $day = $x->at("pubDate[type=day]");
      $day = $day ? $day->text : 0;

      $year  = 0 if $year  !~ /^\d+$/;
      $month = 0 if $month !~ /^\d+$/;
      $day   = 0 if $day   !~ /^\d+$/;

      my $date = $year ? ($year < 100 ? '20' . $year : $year) : '0000';
      $date .= length($month) == 1 ? '0' . $month : $month;
      $date .= length($day) == 1 ? '0' . $day : $day;
      $self->pub_date($date);
    });

  # creatDate
  my $create_date = $dom->at('creatDate');
  if ($create_date && $create_date->text) {
    $create_date = $create_date->all_text;
    if (index($create_date, '-') > -1) {
      $self->log->warn("Creation date ranges are not supported");
      ($create_date) = split /\s*-\s*/, $create_date;
    }

    $create_date =~ s{^(\d{4})$}{$1\.00};
    $create_date =~ s{^(\d{4})\.(\d{2})$}{$1\.$2\.00};
    if ($create_date =~ /^\d{4}\.\d{2}\.\d{2}$/) {
      $create_date =~ tr/\.//d;
      $self->creation_date($create_date);
    };
  };

  my $text_class = $dom->at('textClass');
  if ($text_class) {
    # Get textClasses
    my @topic;

    $text_class->find("catRef")->each(
      sub {
	my ($ign, @ttopic) = split('\.', $_->attr('target'));
	push(@topic, @ttopic);
      }
    );
    $self->text_class(@topic) if @topic > 0;

    my $kws = $self->keywords;
    my @keywords = $text_class->find("h\.keywords > keyTerm")->each;
    push(@$kws, @keywords) if @keywords > 0;
  };

  if (my $edition_statement = $dom->at('biblFull editionStmt')) {
    $self->bibl_edition_statement($edition_statement->all_text)
      if $edition_statement->text;
  };

  if (my $edition_statement = $dom->at('fileDescl editionStmt')) {
    $self->file_edition_statement($edition_statement->all_text)
      if $edition_statement->text;
  };

  if (my $file_desc = $dom->at('fileDesc')) {
    if (my $availability = $file_desc->at('publicationStmt > availability')) {
      $self->license($availability->all_text);
    };
  };

  # Some meta data only available in the corpus
  if ($type eq 'corpus') {
    if (my $language = $dom->at('profileDesc > langUsage > language[id]')) {
      $self->language($language->attr('id'));
    };
  }

  # Some meta data only reevant from the text
  elsif ($type eq 'text') {

    if (my $reference = $dom->at('sourceDesc reference[type=complete]')) {
      if (my $ref_text = $reference->all_text) {
	$ref_text =~ s!^[a-zA-Z0-9]+\/[a-zA-Z0-9]+\.\d+[\s:]\s*!!;
	$self->reference($ref_text);
      };
    };

    my $column = $dom->at('textDesc > column');
    $self->text_column($column->all_text) if $column;

    if (my $pages = $dom->at('biblStruct biblScope[type="pp"]')) {
      $pages = $pages->all_text;
      if ($pages && $pages =~ m/(\d+)\s*-\s*(\d+)/) {
	$self->pages($1 . '-' . $2);
      };
    };
  };
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

#  if ($self->author) {
#    foreach (@{$self->author}) {
#      $_ =~ s/\n/ /g;
#      $_ =~ s/\s\s+/ /g;
#      $string .= 'author = ' . $_ . "\n";
#    };
#  };

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

  $self->parse unless $self->text_sigle;

  my %hash;

  foreach (@ATTR, @ADVANCED_ATTR, 'store') {
    if (my $att = $self->$_) {
      $att =~ s/\n/ /g;
      $att =~ s/\s\s+/ /g;
      $hash{_k($_)} = $att;
    };
  };

  for (qw/text_class keywords/) {
    my @array = @{ $self->$_ };
    next unless @array;
    $hash{_k($_)} = join(' ', @array);
  };

  return \%hash;
};

# Todo: Make this a KoralQuery serializer
sub to_koral_query {
  my $self = shift;
  my $hash = $self->to_hash;
  $hash->{text} = $self->primary->data;
  $hash->{version} = '0.04';
};

1;


__END__

=pod

=head1 NAME

KorAP::XML::Krill


=head1 SYNOPSIS

  my $doc = KorAP::XML::Krill->new(
    path => 'mydoc-1/'
  );

  $doc->parse;

  print $doc->title;


=head1 DESCRIPTION

Parse the primary and meta data of a document.


=head2 ATTRIBUTES

=head2 text_sigle

  $doc->text_sigle(75476);
  print $doc->text_sigle;

The unique identifier of the text.


=head2 doc_sigle

  $doc->doc_sigle(75476);
  print $doc->doc_sigle;

The unique identifier of the document.


=head2 corpus_sigle

  $doc->corpus_sigle(4);
  print $doc->corpus_sigle;

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

The L<KorAP::XML::Document::Primary> object containing the primary data.


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
