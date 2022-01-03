package KorAP::XML::Meta::Gingko;
use KorAP::XML::Meta::Base;
use KorAP::XML::Meta::I5;

my $squish = \&KorAP::XML::Meta::I5::_squish;

sub parse {
  my ($self, $dom, $type) = @_;

  unless (KorAP::XML::Meta::I5::parse($self, $dom, $type)) {
    return 0;
  };

  my $temp;

  if ($type eq 'text') {
    if ($temp = $dom->at('textClass > classCode[scheme=gingkoGenre.top]')) {
      $temp = $squish->($temp->all_text);
      $self->{S_gingko_genre_main} = $temp if $temp;
    };

    if ($temp = $dom->at('textClass > classCode[scheme=gingkoGenre.sub]')) {
      $temp = $squish->($temp->all_text);
      $self->{S_gingko_genre_sub} = $temp if $temp;
    };

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

    if (my $analytic = $dom->at('sourceDesc > biblStruct > analytic')) {
      if ($temp = $analytic->at('biblNote[n=DOI]')) {
        $temp = $squish->($temp->all_text);
        if ($temp) {
          $self->{A_gingko_article_DOI} = $self->korap_data_uri('https://doi.org/' . $temp, title => 'doi:' . $temp);
        };
      };
    };

    if ($temp = $dom->at('correction')) {
      $temp = $squish->($temp->all_text);
      $self->{S_gingko_lemma_corr} = $temp if $temp;
    };

    if ($temp = $dom->at('encodingDesc > tagsDecl > tagUsage[gi=w]')) {
      if ($temp->attr('occurs')) {
        $self->{I_gingko_text_tokens} = $temp->attr('occurs');
      };
    };
  }

  elsif ($type eq 'corpus') {
    if (my $mono = $dom->at('sourceDesc > biblStruct > monogr')) {
      if ($temp = $mono->at('biblNote[n=collection]')) {
        $temp = $squish->($temp->all_text);
        $self->{T_gingko_collection} = $temp if $temp;
      };

      if ($temp = $mono->at('biblNote[n=collectionShort]')) {
        $temp = $squish->($temp->all_text);
        $self->{S_gingko_collection_short} = $temp if $temp;
      };

      if ($temp = $mono->at('biblNote[n="url"]')) {
        $temp = $squish->($temp->all_text);
        $self->{A_external_link} = $self->korap_data_uri($temp, title => 'Gingko-Webseite an der Universität Leipzig');
      };

      if ($temp = $mono->at('biblNote[n="url.ids"]')) {
        $temp = $squish->($temp->all_text);
        $self->{A_internal_link} = $self->korap_data_uri($temp, title => 'IDS webpage on Gingko in the DeReKo archive');
      };

    };
  };
};

1;
