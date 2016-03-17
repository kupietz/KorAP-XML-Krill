package KorAP::XML::Meta::I5;
use KorAP::XML::Meta::Base;
use Try::Tiny;

# Parse meta data
sub parse {
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
      $self->{title} =_remove_prefix($title, $self->text_sigle) if $title;
      $self->{sub_title} = $sub_title if $sub_title;
      $self->{editor} = $editor       if $editor;
      $self->{author} = $author       if $author;
    }
    elsif ($type eq 'doc') {
      $self->{doc_title} = _remove_prefix($title, $self->doc_sigle) if $title;
      $self->{doc_sub_title} = $sub_title if $sub_title;
      $self->{doc_author} = $author       if $author;
      $self->{doc_editor} = $editor       if $editor;
    }
    elsif ($type eq 'corpus') {
      $self->{corpus_title} = _remove_prefix($title, $self->corpus_sigle) if $title;
      $self->{corpus_sub_title} = $sub_title if $sub_title;
      $self->{corpus_author} = $author       if $author;
      $self->{corpus_editor} = $editor       if $editor;
    };
  };

  # Not in analytic
  if ($type eq 'corpus') {
    unless ($self->{corpus_title}) {
      if (my $title = $dom->at('fileDesc > titleStmt > c\.title')) {
	$self->{corpus_title} = _remove_prefix($title->all_text, $self->corpus_sigle)
	  if $title->all_text;
      };
    };
  }

  # doc title
  elsif ($type eq 'doc') {
    unless ($self->{doc_title}) {
      if (my $title = $dom->at('fileDesc > titleStmt > d\.title')) {
	$self->{doc_title} = _remove_prefix($title->all_text, $self->doc_sigle)
	  if $title->all_text;
      };
    };
  }

  # text title
  elsif ($type eq 'text') {
    unless ($self->{title}) {
      if (my $title = $dom->at('fileDesc > titleStmt > t\.title')) {
	$self->{title} = _remove_prefix($title->all_text, $self->text_sigle)
	  if $title->all_text;
      }
    };
  };

  # Get PubPlace
  if (my $place = $dom->at('pubPlace')) {
    $self->{pub_place} = $place->all_text if $place->all_text;
    $self->{pub_place_key} = $place->attr('key') if $place->attr('key');
  };

  # Get Publisher
  if (my $publisher = $dom->at('imprint publisher')) {
    $self->{publisher} = $publisher->all_text if $publisher->all_text;
  };

  # Get text type
  my $text_desc = $dom->at('textDesc');

  if ($text_desc) {
    if (my $text_type = $text_desc->at('textType')) {
      $self->{text_type} = $text_type->all_text if $text_type->all_text;
    };

    # Get text domain
    if (my $text_domain = $text_desc->at('textDomain')) {
      $self->{text_domain} = $text_domain->all_text if $text_domain->all_text;
    };

    # Get text type art
    if (my $text_type_art = $text_desc->at('textTypeArt')) {
      $self->{text_type_art} = $text_type_art->all_text if $text_type_art->all_text;
    };

    # Get text type art
    if (my $text_type_ref = $text_desc->at('textTypeRef')) {
      $self->{text_type_ref} = $text_type_ref->all_text if $text_type_ref->all_text;
    };
  };

  # Availability
  try {
    $self->{availability} = $dom->at('availability')->all_text;
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
      $self->{pub_date} = $date;
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
      $self->{creation_date} = $create_date;
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
    $self->{text_class} = [@topic] if @topic > 0;

    my $kws = $self->{keywords};
    my @keywords = $text_class->find("h\.keywords > keyTerm")->each;
    push(@$kws, @keywords) if @keywords > 0;
  };

  if (my $edition_statement = $dom->at('biblFull editionStmt')) {
    $self->{bibl_edition_statement} = $edition_statement->all_text
      if $edition_statement->text;
  };

  if (my $edition_statement = $dom->at('fileDescl editionStmt')) {
    $self->{file_edition_statement} = $edition_statement->all_text
      if $edition_statement->text;
  };

  if (my $file_desc = $dom->at('fileDesc')) {
    if (my $availability = $file_desc->at('publicationStmt > availability')) {
      $self->{license} = $availability->all_text;
    };
  };

  # Some meta data only available in the corpus
  if ($type eq 'corpus') {
    if (my $language = $dom->at('profileDesc > langUsage > language[id]')) {
      $self->{language} = $language->attr('id');
    };
  }

  # Some meta data only reevant from the text
  elsif ($type eq 'text') {

    if (my $reference = $dom->at('sourceDesc reference[type=complete]')) {
      if (my $ref_text = $reference->all_text) {
	$ref_text =~ s!^[a-zA-Z0-9]+\/[a-zA-Z0-9]+\.\d+[\s:]\s*!!;
	$self->{reference} = $ref_text;
      };
    };

    my $column = $dom->at('textDesc > column');
    $self->{text_column} = $column->all_text if $column;

    if (my $pages = $dom->at('biblStruct biblScope[type="pp"]')) {
      $pages = $pages->all_text;
      if ($pages && $pages =~ m/(\d+)\s*-\s*(\d+)/) {
	$self->{pages} = $1 . '-' . $2;
      };
    };
  };
};


sub _remove_prefix {
#   return $_[0];

  # This may render some titles wrong, e.g. 'VDI nachrichten 2014' ...
  my $title = shift;
  my $prefix = shift or return $title;
  $prefix =~ tr!_!/!;
  if (index($title, $prefix) == 0) {
    $title = substr($title, length($prefix));
    $title =~ s/^\s+//;
    $title =~ s/\s+$//;
  };
  return $title;
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
#sub text_class {
#  my $self = shift;
#  if ($_[0]) {
#    return $self->{topics} = [ @_ ];
#  };
#  return ($self->{topics} //= []);
#};

#sub text_class_string {
#  return join ' ', @{shift->text_class};
#}

#sub keywords {
#  my $self = shift;
#  if ($_[0]) {
#    return $self->{keywords} = [ @_ ];
#  };
#  return ($self->{keywords} //= []);
#};

#sub keywords_string {
#  return join ' ', @{shift->keywords};
#}


1;
