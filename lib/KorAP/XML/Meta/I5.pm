package KorAP::XML::Meta::I5;
use KorAP::XML::Meta::Base;

our $SIGLE_RE = qr/^([^_\/]+)(?:[_\/]([^\._\/]+?)(?:\.(.+?))?)?$/;

# STRING:
#   "pubPlace",
#   "textSigle",
#   "docSigle",
#   "corpusSigle",
#   "textType",
#   "textTypeArt",
#   "textTypeRef",
#   "textColumn",
#   "textDomain",
#   "availability",
#   "language",
#   "corpusID", // Deprecated!
#   "ID"        // Deprecated!
#
# TEXT:
#   "author",
#   "title",
#   "subTitle",
#   "corpusTitle",
#   "corpusSubTitle",
#   "corpusAuthor",
#   "docTitle",
#   "docSubTitle",
#   "docAuthor"
#
# KEYWORDS:
#   "textClass",
#   "foundries",
#   "keywords"
#
# STORE:
#   "docEditor",
#   "tokenSource",
#   "layerInfos",
#   "publisher",
#   "editor",
#   "fileEditionStatement",
#   "biblEditionStatement",
#   "reference",
#   "corpusEditor"
#   "distributor"
#
# DATE:
#   "pubDate",
#   "creationDate"


sub _squish ($) {
  for ($_[0]) {
    s!\s\s+! !g;
    s!^\s*!!;
    s!\s*$!!;
    s!^\-+$!!g;
  };
  $_[0];
};

# Parse meta data
# This will normally be parsed in the order corpus, doc, text
sub parse {
  my ($self, $dom, $type) = @_;

  # Parse text sigle
  if ($type eq 'text' && !$self->text_sigle) {
    my $v = $dom->at('textSigle');
    if ($v) {
      $self->{_text_sigle} = _squish $v->text;
      if ($self->{_text_sigle} =~ $SIGLE_RE) {
        $self->{_text_sigle} = join('/', $1, $2, $3);
        $self->{_doc_sigle} = join('/', $1, $2);
        $self->{_corpus_sigle} = $1;
      };
    }
  }

  # Parse document sigle
  elsif ($type eq 'doc' && !$self->doc_sigle) {
    my $v = $dom->at('dokumentSigle');
    if ($v) {
      $self->{_doc_sigle} = $v->text;
      if ($self->{_doc_sigle} =~ $SIGLE_RE) {
        $self->{_doc_sigle} = join('/', $1, $2);
        $self->{_corpus_sigle} = $1;
      };
    }
  }

  # Parse corpus sigle
  elsif ($type eq 'corpus' && !$self->corpus_sigle) {
    my $v = $dom->at('korpusSigle');
    $self->{_corpus_sigle} = $v->text if $v;
  };

  # TODO: May have analytic AND monogr
  foreach my $analytic ($dom->at('analytic'), $dom->at('monogr')) {
    next unless $analytic;
    # There is an analytic element

    # Get title, subtitle, author, editor
    my $title     = $analytic->at('h\.title[type=main]');
    my $sub_title = $analytic->at('h\.title[type=sub]');
    my $author    = $analytic->at('h\.author');
    my $editor    = $analytic->at('editor');

    #if ($analytic->find('editor')->size > 1) {
    #  warn 'Mehr als ein Editor!';
    #  warn $analytic->find('editor')->join("\n");
    #};

    #if ($analytic->find('author')->size > 1) {
    #  warn 'Mehr als ein Autor!';
    #  warn $analytic->find('author')->join("\n");
    #};

    # Editor contains translator
    my $translator;
    if ($editor && $editor->attr('role') && $editor->attr('role') eq 'translator') {
      # Translator is only supported on the text level currently
      $translator = _squish $editor->all_text;
      $self->{A_translator} = $translator if $translator;
      $editor = undef;
    }
    else {
      $editor = $editor ? _squish $editor->all_text : undef;
    };

    $title     = $title     ? _squish $title->all_text     : undef;
    $sub_title = $sub_title ? _squish $sub_title->all_text : undef;
    $author    = $author    ? _squish $author->all_text    : undef;

    # Text meta data
    if ($type eq 'text') {
      unless ($self->{T_title} || $self->{T_sub_title}) {
        $self->{T_title} = _remove_prefix($title, $self->text_sigle) if $title;
        $self->{T_sub_title} = $sub_title if $sub_title;
      };
      $self->{A_editor} //= $editor       if $editor;
      $self->{T_author} //= $author       if $author;
    }

    # Doc meta data
    elsif ($type eq 'doc') {
      unless ($self->{T_doc_title} || $self->{T_doc_sub_title}) {
        $self->{T_doc_title} //= _remove_prefix($title, $self->doc_sigle) if $title;
        $self->{T_doc_sub_title} //= $sub_title if $sub_title;
      };
      $self->{T_doc_author} //= $author       if $author;
      $self->{A_doc_editor} //= $editor       if $editor;
    }

    # Corpus meta data
    elsif ($type eq 'corpus') {
      unless ($self->{T_corpus_title} || $self->{T_corpus_sub_title}) {
        $self->{T_corpus_title} //= _remove_prefix($title, $self->corpus_sigle) if $title;
        $self->{T_corpus_sub_title} //= $sub_title if $sub_title;
      };
      $self->{T_corpus_author} //= $author       if $author;
      $self->{A_corpus_editor} //= $editor       if $editor;
    };
  };

  # Not in analytic
  my $title;
  if ($type eq 'corpus') {

    # Corpus title not yet given
    unless ($self->{T_corpus_title}) {
      if ($title = $dom->at('fileDesc > titleStmt > c\.title')) {
        $title = _squish($title->all_text);

        if ($title) {
          $self->{T_corpus_title} = _remove_prefix($title, $self->corpus_sigle);
        };
      };
    };
  }

  # doc title
  elsif ($type eq 'doc') {
    unless ($self->{T_doc_title}) {
      if ($title = $dom->at('fileDesc > titleStmt > d\.title')) {
        $title = _squish($title->all_text);

        if ($title) {
          $self->{T_doc_title} = _remove_prefix($title, $self->doc_sigle);
        };
      };
    };
  }

  # text title
  elsif ($type eq 'text') {
    unless ($self->{T_title}) {
      if ($title = $dom->at('fileDesc > titleStmt > t\.title')) {
        $title = _squish($title->all_text);
        if ($title) {
          $self->{T_title} = _remove_prefix($title, $self->text_sigle);
        };
      }
    };
  };

  my $temp;

  # Get PubPlace
  if ($temp = $dom->at('pubPlace')) {
    my $place_attr = $temp->attr('key');
    $self->{S_pub_place_key} = $place_attr if $place_attr;
    $temp = _squish $temp->all_text;
    $self->{S_pub_place} = $temp if $temp;
  };

  # Get Publisher
  if ($temp = $dom->at('imprint publisher')) {
    $temp = _squish $temp->all_text;
    $self->{A_publisher} = $temp if $temp;
  };

  # Get text type
  $temp = $dom->at('textDesc');
  my $temp_2;

  if ($temp) {
    if ($temp_2 = $temp->at('textType')) {
      $temp_2 = _squish $temp_2->all_text;
      $self->{S_text_type} = $temp_2 if $temp_2;
    };

    # Get text domain
    if ($temp_2 = $temp->at('textDomain')) {
      $temp_2 = _squish $temp_2->all_text;
      $self->{S_text_domain} = $temp_2 if $temp_2;
    };

    # Get text type art
    if ($temp_2 = $temp->at('textTypeArt')) {
      $temp_2 = _squish $temp_2->all_text;
      $self->{S_text_type_art} = $temp_2 if $temp_2;
    };

    # Get text type ref
    if ($temp_2 = $temp->at('textTypeRef')) {
      $temp_2 = _squish $temp_2->all_text;
      $self->{S_text_type_ref} = $temp_2 if $temp_2;
    };
  };

  state $NR_RE = qr/^\d+$/;
  state $REF_RE = qr!^[a-zA-Z0-9]+\/[a-zA-Z0-9]+\.\d+[\s:]\s*!;

  # Get pubDate
  my $pub_date = $dom->find('pubDate[type=year]');
  $pub_date->each(
    sub {
      my $x = shift->parent;
      my $year = $x->at('pubDate[type=year]') or return;
      $year = $year ? $year->text : 0;
      my $month = $x->at('pubDate[type=month]');
      $month = $month ? $month->text : 0;
      my $day = $x->at('pubDate[type=day]');
      $day = $day ? $day->text : 0;

      $year  = 0 if $year  !~ $NR_RE;
      $month = 0 if $month !~ $NR_RE;
      $day   = 0 if $day   !~ $NR_RE;

      my $date = $year ? ($year < 100 ? '20' . $year : $year) : '0000';
      $date .= length($month) == 1 ? '0' . $month : $month;
      $date .= length($day) == 1 ? '0' . $day : $day;
      $self->{D_pub_date} = $date;
    });

  # creatDate
  my $create_date = $dom->at('creatDate');
  if ($create_date && $create_date->text) {
    $create_date = _squish $create_date->all_text;
    if (index($create_date, '-') > -1) {
      $self->log->warn("Creation date ranges are not supported");
      ($create_date) = split /\s*-\s*/, $create_date;
    };
    unless ($create_date =~ s{^(\d{4})$}{$1\.00\.00}) {
      unless ($create_date =~ s{^(\d{4})\.(\d{2})$}{$1\.$2\.00}) {
        $create_date =~ /^\d{4}\.\d{2}\.\d{2}$/;
      };
    };
    if ($create_date =~ /^\d{4}(?:\.\d{2}(?:\.\d{2})?)?$/) {
      $create_date =~ tr/\.//d;
      $self->{D_creation_date} = $create_date;
    };
  };


  $temp = $dom->at('textClass');
  if ($temp) {
    # Get textClasses
    my @topic;

    $temp->find("catRef")->each(
      sub {
        my ($ign, @ttopic) = grep { $_ } map { _squish($_) } split('\.', $_->attr('target'));
        push(@topic, @ttopic);
      }
    );
    $self->{K_text_class} = [@topic] if @topic > 0;

    my $kws = $self->{K_keywords};
    my @keywords = $temp->find("h\.keywords > keyTerm")->map(sub {_squish($_) })->grep(sub { $_ })->each;
    push(@$kws, @keywords) if @keywords > 0;
  };

  if ($temp = $dom->at('biblFull editionStmt')) {
    $temp = _squish $temp->all_text;
    $self->{A_bibl_edition_statement} = $temp if $temp;
  };

  if ($temp = $dom->at('fileDescl editionStmt')) {
    $temp = _squish $temp->all_text;
    $self->{A_file_edition_statement} = $temp if $temp;
  };

  if ($temp = $dom->at('fileDesc')) {
    my $temp2;

    if (my $availability = $temp->at('publicationStmt > availability')) {
      $temp2 = _squish $availability->all_text;
      $self->{S_availability} = $temp2 if $temp2;
    };

    if (my $distributor = $temp->at('publicationStmt > distributor')) {
      $temp2 = _squish $distributor->all_text;
      $self->{A_distributor} = $temp2 if $temp2;
    }
  };

  if ($temp = $dom->at('profileDesc > langUsage > language[id]')) {
    $self->{S_language} = $temp->attr('id') if $temp->attr('id');
  };


  # Some meta data only available in the corpus
  #if ($type eq 'corpus') {
  #}

  # Some meta data only reevant from the text
  if ($type eq 'text') {

    if ($temp = $dom->at('sourceDesc reference[type=complete]')) {
      if (my $ref_text = _squish $temp->all_text) {
        $ref_text =~ s!$REF_RE!!;
        $self->{A_reference} = $ref_text;

      # In case of Wikipedia texts, take the URL
        if ($ref_text =~ /URL:(http:.+?):\s+Wikipedia,\s+\d+\s*$/) {
          $self->{A_externalLink} = 'data:application/x.korap-link;title=Wikipedia,' . $1;
        };
      };
    };

    $temp = $dom->at('textDesc > column');
    if ($temp && ($temp = _squish $temp->all_text)) {
      $self->{S_text_column} = $temp;
    };

    if ($temp = $dom->at('biblStruct biblScope[type=pp]')) {
      $temp = _squish $temp->all_text;
      if ($temp && $temp =~ m/(\d+)\s*-\s*(\d+)/) {
        $self->{A_src_pages} = $1 . '-' . $2;
      };
    };
  };

  return 1;
};


sub _remove_prefix {
  # This may render some titles wrong, e.g. 'VDI nachrichten 2014' ...
  return $_[0] unless $_[1];

  my ($title, $prefix) = @_;
  # $prefix =~ tr!_!/!;
  $prefix =~ s!^([^/]+?/[^/]+?)/!$1\.!;
  if (index($title, $prefix) == 0) {
    $title = substr($title, length($prefix));
    $title =~ s!^\s*[-;:,]\s*!!;
  };

  return _squish $title;
};


1;
