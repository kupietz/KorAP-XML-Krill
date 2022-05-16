package KorAP::XML::Meta::Gingko;
use KorAP::XML::Meta::Base;
use KorAP::XML::Meta::I5;

my $squish = \&KorAP::XML::Meta::I5::_squish;

sub parse {
  my ($self, $dom, $type) = @_;

  # Parse using the parent I% class
  unless (KorAP::XML::Meta::I5::parse($self, $dom, $type)) {
    return 0;
  };

  my $temp;

  # Add metadata on the text level
  if ($type eq 'text') {

    # Add main genre information
    if ($temp = $dom->at('textClass > classCode[scheme=gingkoGenre.top]')) {
      $temp = $squish->($temp->all_text);
      $self->{S_gingko_genre_main} = $temp if $temp;
    };

    # Add subordinate genre information
    if ($temp = $dom->at('textClass > classCode[scheme=gingkoGenre.sub]')) {
      $temp = $squish->($temp->all_text);
      $self->{S_gingko_genre_sub} = $temp if $temp;
    };

    # Add source information
    if (my $mono = $dom->at('sourceDesc > biblStruct > monogr')) {
      if ($temp = $mono->at('h\.title[type=main]')) {
        $temp = $squish->($temp->all_text);
        $self->{T_gingko_source} = $temp if $temp;
      };

      if ($temp = $mono->at('h\.title[type=short]')) {
        $temp = $squish->($temp->all_text);
        $self->{S_gingko_source_short} = $temp if $temp;
      };
    };

    # Add article DOI
    if (my $analytic = $dom->at('sourceDesc > biblStruct > analytic')) {
      if ($temp = $analytic->at('biblNote[n=DOI]')) {
        $temp = $squish->($temp->all_text);
        if ($temp) {
          $self->{A_gingko_article_DOI} = $self->korap_data_uri('https://doi.org/' . $temp, title => 'doi:' . $temp);
        };
      };
    };

    # Add lemma correction information
    if ($temp = $dom->at('correction')) {
      $temp = $squish->($temp->all_text);
      $self->{S_gingko_lemma_corr} = $temp if $temp;
    };

    # Add text tokens count
    if ($temp = $dom->at('encodingDesc > tagsDecl > tagUsage[gi=w]')) {
      if ($temp->attr('occurs')) {
        $self->{I_gingko_text_tokens} = $temp->attr('occurs');
      };
    };
  }

  # Add metadata on the corpus level
  elsif ($type eq 'corpus') {

    # Add collection information
    if (my $mono = $dom->at('sourceDesc > biblStruct > monogr')) {
      if ($temp = $mono->at('biblNote[n=collection]')) {
        $temp = $squish->($temp->all_text);
        $self->{T_gingko_collection} = $temp if $temp;
      };

      if ($temp = $mono->at('biblNote[n=collectionShort]')) {
        $temp = $squish->($temp->all_text);
        $self->{S_gingko_collection_short} = $temp if $temp;
      };
    };
  };
};

1;
