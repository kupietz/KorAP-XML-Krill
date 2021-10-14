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

    if ($temp = $dom->at('correction')) {
      $temp = $squish->($temp->all_text);
      $self->{S_gingko_lemma_corr} = $temp if $temp;
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
    };
  };
};

1;
