package KorAP::XML::Meta::ICC;
use KorAP::XML::Meta::Base;
use KorAP::XML::Meta::I5;

my $squish = \&KorAP::XML::Meta::I5::_squish;

sub parse_date {
  my $temp = shift;
  if ($temp =~ m/^(\d\d\d\d)(?:-(\d\d)(?:-(\d\d))?)?$/) {
    my $year = $1;
    my $month = $2 // 0;
    my $day = $3 // 0;

    my $date = $year ? ($year < 100 ? '20' . $year : $year) : '0000';
    $date .= length($month) == 1 ? '0' . $month : $month;
    $date .= length($day) == 1 ? '0' . $day : $day;
    return $date;
  };
};

sub parse {
  my ($self, $dom, $type) = @_;

  # Parse using the parent I% class
  unless (KorAP::XML::Meta::I5::parse($self, $dom, $type)) {
    return 0;
  };

  my $temp;

  # Add metadata on the text level
  return if $type ne 'text';

  if (my $bibl = $dom->at('fileDesc > sourceDesc > bibl')) {
    if ($temp = $bibl->at('> author')) {
      $temp = $squish->($temp->all_text);
      $self->{T_author} = $temp if $temp;
    };

    if ($temp = $bibl->at('> title')) {
      $temp = $squish->($temp->all_text);
      $self->{T_title} = $temp if $temp;
    };

    if ($temp = $bibl->at('> pubPlace')) {
      $temp = $squish->($temp->all_text);
      $self->{S_pub_place} = $temp if $temp;
    };

    if ($temp = $bibl->at('> date')) {
      $temp = $squish->($temp->all_text);

      my $date = parse_date($temp);

      $self->{D_pub_date} = $date if $date;
    };

    if ($temp = $bibl->at('> publisher')) {
      $temp = $squish->($temp->all_text);
      $self->{A_publisher} = $temp if $temp;
    };

    if ($temp = $bibl->at('> availability > licence')) {
      $temp = $squish->($temp->all_text);
      $self->{S_license} = $temp if $temp;
    };
  };

  if ($temp = $dom->at('fileDesc > publicationStmt > distributor > note:nth-child(2)')) {
    $temp = $squish->($temp->all_text);
    $self->{A_source} = $temp if $temp;
  };

  if ($temp = $dom->at('profileDesc > textClass > classCode[scheme=ICC], fileDesc > titleStmt > domain')) {
    $temp = $squish->($temp->all_text);
    $self->{S_iccGenre} = $temp if $temp;
  };

  if (my $person = $dom->at('profileDesc > particDesc > person')) {
    if ($temp = $person->at('> birth > date')) {
      $temp = $squish->($temp->all_text);

      my $date = parse_date($temp);

      $self->{D_author_birth_date} = $date if $date;
    };

    if ($temp = $person->at('> occupation')) {
      $temp = $squish->($temp->all_text);
      $self->{S_author_occupation} = $temp if $temp;
    };

    if ($temp = $person->at('> sex')) {
      $temp = $squish->($temp->all_text);
      $self->{S_author_sex} = $temp if $temp;
    };
  };
};

1;
