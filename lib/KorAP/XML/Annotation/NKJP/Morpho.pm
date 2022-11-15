package KorAP::XML::Annotation::NKJP::Morpho;
use KorAP::XML::Annotation::Base;
use Data::Dumper;

our %morpho = (
  sg => 'number',
  pl => 'number',
  nom => 'case',
  gen => 'case',
  dat => 'case',
  acc => 'case',
  inst => 'case',
  loc => 'case',
  voc => 'case',
  m1 => 'gender',
  m2 => 'gender',
  m3 => 'gender',
  f => 'gender',
  n => 'gender',
  pri => 'person',
  sec => 'person',
  ter => 'person',
  pos => 'degree',
  com => 'degree',
  sup => 'degree',
  imperf => 'aspect',
  perf => 'aspect',
  aff => 'negation',
  neg => 'negation',
  akc => 'accent',
  nakc => 'accent',
  praep => 'postprep',
  npraep => 'postprep',
  congr => 'accomm',
  rec => 'accomm',
  nagl => 'agglut',
  agl => 'agglut',
  wok => 'vocal',
  nwok => 'vocal',
  pun => 'fullstopp',
  npun => 'fullstopp',
);

sub parse {
  my $self = shift;

  $$self->add_tokendata(
    foundry => 'nkjp',
    layer => 'morpho',
    cb => sub {
      my ($stream, $token) = @_;
      my $mtt = $stream->pos($token->get_pos);

      my $content = $token->get_hash->{fs}->{f};

      my $found;

      if (ref $content eq 'HASH') {
        $content = [$content];
      };

      my $name;
      foreach my $c (@$content) {

        # For the moment, ignore all interps
        next if $c->{-name} ne 'lex';

        if (ref $c->{fs} eq 'HASH') {
          $c = [$c->{fs}];
        } else {
          $c = $c->{fs};
        };

        foreach my $ci (@$c) {
          foreach my $f (@{$ci->{f}}) {

            $name = $f->{-name};

            # pos tag
            if (($name eq 'pos') &&
                  ($found = $f->{'#text'})) {
              $mtt->add_by_term('nkjp/p:' . $found);
            }

            # lemma tag
            elsif (($name eq 'lemma')
                     && ($found = $f->{'#text'})
                     && $found ne '<unknown>') {
              $mtt->add_by_term('nkjp/l:' . $found);
            }

            # orig tag
            elsif (($name eq 'orig')
                     && ($found = $f->{'#text'})) {
              $mtt->add_by_term('nkjp/ov:' . $found);
            }

            # msd tag
            elsif (($name eq 'msd')
                     && ($found = $f->{'#text'})) {
              foreach (split(':',$found)) {
                if (exists $morpho{$_}) {
                  $mtt->add_by_term('nkjp/m:' . $morpho{$_} . ':' . $_);
                }

                else {
                  $$self->log->warn('Unknown morphological feature: ' . $_);
                };
              };
            };
          };
        };
      };
    }) or return;
  return 1;
};

sub layer_info {
  ['nkjp/l=tokens', 'nkjp/p=tokens', 'nkjp/m=tokens', 'nkjp/ov=tokens']
}

1;
