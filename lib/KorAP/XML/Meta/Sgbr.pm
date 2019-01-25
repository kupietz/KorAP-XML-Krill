package KorAP::XML::Meta::Sgbr;
use KorAP::XML::Meta::Base;
use Try::Tiny;

# Parse meta data
sub parse {
  my $self = shift;
  my $dom = shift;
  my $type = shift;

  my $stmt;
  if ($type eq 'text') {

    # Publisher
    try {
      $self->{A_publisher} = $dom->at('publisher')->all_text;
    };

    # Date of publication
    try {
      my $date = $dom->at('date')->all_text;
      $self->{D_sgbr_date} = $date;
      if ($date =~ s!^\s*(\d{4})-(\d{2})-(\d{2}).*$!$1$2$3!) {
        $self->{D_pub_date} = $date;
      }
      else {
        $self->log->warn('"' . $date . '" is not a compatible pubDate');
      };
    };

    # Publication place
    try {
      my $pp = $dom->at('pubPlace');
      if ($pp) {
        $self->{S_pub_place} = $pp->all_text if $pp->all_text;
      };
      if ($pp->attr('ref')) {
        $self->{A_reference} = $pp->attr('ref');
      };
    };

    if ($stmt = $dom->at('titleStmt')) {
      # Title
      try {
        $stmt->find('title')->each(
          sub {
            my $type = $_->attr('type') || 'main';
            $self->{T_title} = $_->all_text if $type eq 'main';

            # Only support the first subtitle
            $self->{T_sub_title} = $_->all_text
              if $type eq 'sub' && !$self->sub_title;
          }
        );
      };

      # Author
      try {
        my $author = $stmt->at('author')->attr('ref');

        $author = $self->{_ref_author}->{$author};

        if ($author) {
          my $array = ($self->{K_keywords} //= []);
          $self->{T_author} = $author->{name} // $author->{id};

          if ($author->{age}) {
            $self->{'S_sgbr_author_age_class'} = $author->{age};
            push @$array, 'sgbrAuthorAgeClass:' . $author->{age};
          };
          if ($author->{sex}) {
            $self->{'S_sgbr_author_sex'} = $author->{sex};
            push @$array, 'sgbrAuthorSex:' . $author->{sex};
          };
        };
      };
    };

    try {
      my $kodex = $dom->at('item[rend]')->attr('rend');
      if ($kodex) {
        my $array = ($self->{K_keywords} //= []);
        $self->{'S_sgbr_kodex'} = $kodex;
        push @$array, 'sgbrKodex:' . $kodex;
      };
    };
  }

  elsif ($type eq 'doc') {
    try {
      $dom->find('particDesc person')->each(
        sub {

          my $hash = $self->{_ref_author}->{'#' . $_->attr('xml:id')} = {
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
      $self->{S_language} = $lang;
    };

    try {
      $self->{'A_funder'} = $dom->at('funder > orgName')->all_text;
    };

    try {
      $stmt = $dom->find('fileDesc > titleStmt > title')->each(
        sub {
          my $type = $_->attr('type') || 'main';
          $self->{T_doc_title} = $_->all_text if $type eq 'main';
          if ($type eq 'sub') {
            my $sub_title = $self->{T_doc_sub_title};
            $self->{T_doc_sub_title} =
              ($sub_title ? $sub_title . ', ' : '') . $_->all_text;
          };
        }
      );
    };
  };
  return;
};

1;
