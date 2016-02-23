package KorAP::XML::Krill;
use Mojo::Base -base;
use Mojo::ByteStream 'b';
use Mojo::Util qw/encode/;
use Scalar::Util qw/weaken/;
use XML::Fast;
use Try::Tiny;
use Carp qw/croak/;
use KorAP::XML::Document::Primary;
use KorAP::XML::Tokenizer;
use Log::Log4perl;
use KorAP::XML::Log;
use Mojo::DOM;
use Data::Dumper;
use File::Spec::Functions qw/catdir catfile catpath splitdir splitpath rel2abs/;

# TODO: Currently metadata is processed multiple times - that's horrible!
#       Due to the kind of processing, processed metadata may be stored in
#       a multiprocess cache instead.

our $VERSION = '0.11';

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

  # Create tokenizer
  my $tokens = KorAP::XML::Tokenizer->new(
    path => $self->path,
    doc => $self,
    foundry => $token_foundry,
    layer => $token_layer,
    name => 'tokens'
  );

  # Parse tokens
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
  if ($type eq 'text') {

    # Publisher
    try {
      $self->publisher($dom->at('publisher')->all_text);
    };

    # Date of publication
    try {
      my $date = $dom->at('date')->all_text;
      $self->store(sgbrDate => $date);
      if ($date =~ s!^\s*(\d{4})-(\d{2})-(\d{2}).*$!$1$2$3!) {
	$self->pub_date($date);
      }
      else {
	$self->log->warn('"' . $date . '" is not a compatible pubDate');
      };
    };

    # Publication place
    try {
      my $pp = $dom->at('pubPlace');
      if ($pp) {
	$self->pub_place($pp->all_text) if $pp->all_text;
      };
      if ($pp->attr('ref')) {
	$self->reference($pp->attr('ref'));
      };
    };

    if ($stmt = $dom->at('titleStmt')) {
      # Title
      try {
	$stmt->find('title')->each(
	  sub {
	    my $type = $_->attr('type') || 'main';
	    $self->title($_->all_text) if $type eq 'main';

	    # Only support the first subtitle
	    $self->sub_title($_->all_text) if $type eq 'sub' && !$self->sub_title;
	  }
	);
      };

      # Author
      try {
	my $author = $stmt->at('author')->attr('ref');

	$author = $self->{ref_author}->{$author};

	if ($author) {
	  my $array = $self->keywords;
	  $self->author($author->{name} // $author->{id});

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

	  my $hash = $self->{ref_author}->{'#' . $_->attr('xml:id')} = {
	    age => $_->attr('age'),
	    sex => $_->attr('sex'),
	    id => $_->attr('xml:id')
	  };

	  # Get name
	  if ($_->at('persName')) {
	    $hash->{name} = $_->at('persName')->all_text;
	  };
	});
    };

    try {
      my $lang = $dom->at('language[ident]')->attr('ident');
      $self->language($lang);
    };

    try {
      $self->store('funder', $dom->at('funder > orgName')->all_text);
    };

    try {
      $stmt = $dom->find('fileDesc > titleStmt > title')->each(
	sub {
	  my $type = $_->attr('type') || 'main';
	  $self->doc_title($_->all_text) if $type eq 'main';
	  if ($type eq 'sub') {
	    my $sub_title = $self->doc_sub_title;
	    $self->doc_sub_title(
	      ($sub_title ? $sub_title . ', ' : '') . $_->all_text
	    );
	  };
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

  $string .= 'text_class = ' . $self->text_class_string . "\n";
  $string .= 'keywords = ' . $self->keywords_string . "\n";

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
  my $hash = {};
  $hash->{'@context'} = 'http://korap.ids-mannheim.de/ns/koral/0.4/context.jsonld';
  $hash->{'@type'} = 'koral:corpus';
#  $hash->{'text'} = $self->primary->data;
#  my $hash = $self->to_hash;
};


sub to_json {
  my $self = shift;
  unless ($self->{tokenizer}) {
    $self->log->warn('No tokenizer defined');
    return;
  };

  return $self->{tokenizer}->to_json;
};


1;


__END__

=pod

=encoding utf8

=head1 NAME

KorAP::XML::Krill - Preprocess KorAP XML documents for Krill


=head1 SYNOPSIS

  # Create Converter Object
  my $doc = KorAP::XML::Krill->new(
    path => 'mydoc-1/'
  );

  # Convert to krill json
  print $doc->parse->tokenize->annotate('Mate', 'Morpho')->to_json;


=head1 DESCRIPTION

Parse the primary and meta data of a KorAP-XML document.


=head1 ATTRIBUTES

=head2 log

L<Log::Log4perl> object for logging.

=head2 path

  $doc->path("example-004/");
  print $doc->path;

The path of the document.


=head2 primary

  print $doc->primary->data(0,20);

The L<KorAP::XML::Document::Primary> object containing the primary data.


=head1 METHODS

=head2 annotate

  $doc->add('Mate', 'Morpho');

Add annotation layer to conversion process.


=head2 parse

  $doc = $doc->parse;

Run the meta parsing process of the document.


=head2 tokenize

  $doc = $doc->tokenize('OpenNLP', 'Tokens');

Accept the tokenization based on a given foundry and a given layer.


=head1 AVAILABILITY

  https://github.com/KorAP/KorAP-XML-Krill


=head1 COPYRIGHT AND LICENSE

Copyright (C) 2015-2016, L<IDS Mannheim|http://www.ids-mannheim.de/>
Author: L<Nils Diewald|http://nils-diewald.de/>

KorAP::XML::Krill is developed as part of the
L<KorAP|http://korap.ids-mannheim.de/>
Corpus Analysis Platform at the
L<Institute for the German Language (IDS)|http://ids-mannheim.de/>,
member of the
L<Leibniz-Gemeinschaft|http://www.leibniz-gemeinschaft.de/en/about-us/leibniz-competition/projekte-2011/2011-funding-line-2/>
and supported by the L<KobRA|http://www.kobra.tu-dortmund.de> project,
funded by the
L<Federal Ministry of Education and Research (BMBF)|http://www.bmbf.de/en/>.

KorAP::XML::Krill is free software published under the
L<BSD-2 License|https://raw.githubusercontent.com/KorAP/KorAP-XML-Krill/master/LICENSE>.

=cut
