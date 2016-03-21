package KorAP::XML::Meta::I5;
use KorAP::XML::Meta::Base;
use Try::Tiny;

# Parse meta data
sub parse {
  my ($self, $dom, $type) = @_;

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

    # Text meta data
    if ($type eq 'text') {
      $self->{title} =_remove_prefix($title, $self->text_sigle) if $title;
      $self->{sub_title} = $sub_title if $sub_title;
      $self->{editor} = $editor       if $editor;
      $self->{author} = $author       if $author;
    }

    # Doc meta data
    elsif ($type eq 'doc') {
      $self->{doc_title} = _remove_prefix($title, $self->doc_sigle) if $title;
      $self->{doc_sub_title} = $sub_title if $sub_title;
      $self->{doc_author} = $author       if $author;
      $self->{doc_editor} = $editor       if $editor;
    }

    # Corpus meta data
    elsif ($type eq 'corpus') {
      $self->{corpus_title} = _remove_prefix($title, $self->corpus_sigle) if $title;
      $self->{corpus_sub_title} = $sub_title if $sub_title;
      $self->{corpus_author} = $author       if $author;
      $self->{corpus_editor} = $editor       if $editor;
    };
  };

  # Not in analytic
  my $title;
  if ($type eq 'corpus') {

    # Corpus title not yet given
    unless ($self->{corpus_title}) {
      if ($title = $dom->at('fileDesc > titleStmt > c\.title')) {
	$title = $title->all_text;

	if ($title) {
	  $self->{corpus_title} = _remove_prefix($title, $self->corpus_sigle);
	};
      };
    };
  }

  # doc title
  elsif ($type eq 'doc') {
    unless ($self->{doc_title}) {
      if ($title = $dom->at('fileDesc > titleStmt > d\.title')) {
	$title = $title->all_text;

	if ($title) {
	  $self->{doc_title} = _remove_prefix($title, $self->doc_sigle);
	};
      };
    };
  }

  # text title
  elsif ($type eq 'text') {
    unless ($self->{title}) {
      if ($title = $dom->at('fileDesc > titleStmt > t\.title')) {
	$title = $title->all_text;
	if ($title) {
	  $self->{title} = _remove_prefix($title, $self->text_sigle);
	};
      }
    };
  };

  my $temp;

  # Get PubPlace
  if ($temp = $dom->at('pubPlace')) {
    my $place_attr = $temp->attr('key');
    $self->{pub_place_key} = $place_attr if $place_attr;
    $temp = $temp->all_text;
    $self->{pub_place} = $temp if $temp;
  };

  # Get Publisher
  if ($temp = $dom->at('imprint publisher')) {
    $temp = $temp->all_text;
    $self->{publisher} = $temp if $temp;
  };

  # Get text type
  $temp = $dom->at('textDesc');
  my $temp_2;

  if ($temp) {
    if ($temp_2 = $temp->at('textType')) {
      $temp_2 = $temp_2->all_text;
      $self->{text_type} = $temp_2 if $temp_2;
    };

    # Get text domain
    if ($temp_2 = $temp->at('textDomain')) {
      $temp_2 = $temp_2->all_text;
      $self->{text_domain} = $temp_2 if $temp_2;
    };

    # Get text type art
    if ($temp_2 = $temp->at('textTypeArt')) {
      $temp_2 = $temp_2->all_text;
      $self->{text_type_art} = $temp_2 if $temp_2;
    };

    # Get text type ref
    if ($temp_2 = $temp->at('textTypeRef')) {
      $temp_2 = $temp_2->all_text;
      $self->{text_type_ref} = $temp_2 if $temp_2;
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
      $self->{pub_date} = $date;
    });

  # creatDate
  my $create_date = $dom->at('creatDate');
  if ($create_date && $create_date->text) {
    $create_date = $create_date->all_text;
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
      $self->{creation_date} = $create_date;
    };
  };

  $temp = $dom->at('textClass');
  if ($temp) {
    # Get textClasses
    my @topic;

    $temp->find("catRef")->each(
      sub {
	my ($ign, @ttopic) = split('\.', $_->attr('target'));
	push(@topic, @ttopic);
      }
    );
    $self->{text_class} = [@topic] if @topic > 0;

    my $kws = $self->{keywords};
    my @keywords = $temp->find("h\.keywords > keyTerm")->each;
    push(@$kws, @keywords) if @keywords > 0;
  };

  if ($temp = $dom->at('biblFull editionStmt')) {
    $temp = $temp->all_text;
    $self->{bibl_edition_statement} = $temp if $temp;
  };

  if ($temp = $dom->at('fileDescl editionStmt')) {
    $temp = $temp->all_text;
    $self->{file_edition_statement} = $temp if $temp;
  };

  if ($temp = $dom->at('fileDesc')) {
    if (my $availability = $temp->at('publicationStmt > availability')) {
      $temp = $availability->all_text;
      $self->{availability} = $temp if $temp;
    };
  };

  # Some meta data only available in the corpus
  if ($type eq 'corpus') {
    if ($temp = $dom->at('profileDesc > langUsage > language[id]')) {
      $self->{language} = $temp->attr('id') if $temp->attr('id');
    };
  }

  # Some meta data only reevant from the text
  elsif ($type eq 'text') {

    if ($temp = $dom->at('sourceDesc reference[type=complete]')) {
      if (my $ref_text = $temp->all_text) {
	$ref_text =~ s!$REF_RE!!;
	$self->{reference} = $ref_text;
      };
    };

    $temp = $dom->at('textDesc > column');
    if ($temp && ($temp = $temp->all_text)) {
      $self->{text_column} = $temp;
    };

    if ($temp = $dom->at('biblStruct biblScope[type=pp]')) {
      $temp = $temp->all_text;
      if ($temp && $temp =~ m/(\d+)\s*-\s*(\d+)/) {
	$self->{pages} = $1 . '-' . $2;
      };
    };
  };
};


sub _remove_prefix {
  # This may render some titles wrong, e.g. 'VDI nachrichten 2014' ...
  return $_[0] unless $_[1];

  my ($title, $prefix) = @_;
  # $prefix =~ tr!_!/!;
  $prefix =~ s!^([^/]+?/[^/]+?)/!$1\.!;
  if (index($title, $prefix) == 0) {
    $title = substr($title, length($prefix));
    $title =~ s/^\s+//;
    $title =~ s/\s+$//;
  };

  return $title;
};


1;
