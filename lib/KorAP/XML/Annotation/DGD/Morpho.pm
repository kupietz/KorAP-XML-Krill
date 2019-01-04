package KorAP::XML::Annotation::DGD::Morpho;
use KorAP::XML::Annotation::Base;
use Data::Dumper;

sub parse {
  my $self = shift;

  $$self->add_tokendata(
    foundry => 'dgd',
    layer => 'annot',
    cb => sub {
      my ($stream, $token) = @_;
      my $mtt = $stream->pos($token->pos);
      my $tui = $stream->tui($token->pos);

      my $content = $token->hash->{fs}->{f} or return;

      $content = $content->{fs}->{f};
      $content = [$content] unless ref $content eq 'ARRAY';

      foreach my $feat (@$content) {

        # syntax
        if (($feat->{-name} eq 'pos') && ($feat->{'#text'})) {
          $mtt->add(
            term => 'dgd/p:' . $feat->{'#text'}
          );
        }

        elsif (($feat->{-name} eq 'lemma') && ($feat->{'#text'})) {
          $mtt->add(
            term => 'dgd/l:' . $feat->{'#text'}
          );
          # }
          #
          # elsif (($feat->{-name} eq 'type') && ($feat->{'#text'})) {
          #   $mtt->add(
          #     term => 'dgd/h:' . $feat->{'#text'}
          #   );
        }

        # Pause
        elsif ($feat->{-name} eq 'pause') {
          $mtt->add(
            term => 'dgd/para:pause',
            pti => 128,
            payload => '<s>' . $tui
          );

          # Duration
          if ($feat->{'#text'} =~ /dur="PT([^"]+?)"/) {
            $mtt->add(
              term => '@:dgd/para:dur:' . $1,
              pti => 16,
              payload => '<s>' . $tui
            );
          };

          last;
        }

        # Incident
        elsif (($feat->{-name} eq 'incident') || ($feat->{-name} eq 'vocal')) {
          $mtt->add(
            term => 'dgd/para:' . $feat->{-name},
            pti => 128,
            payload => '<s>' . $tui
          );

          # Rendering
          if ($feat->{'#text'} =~ /rend="([^"]+?)"/) {
            $mtt->add(
              term => '@:dgd/para:rend:' . $1,
              pti => 16,
              payload => '<s>' . $tui
            );
          };

          # Rendering
          if ($feat->{'#text'} =~ /rend="([^"]+?)"/) {
            $mtt->add(
              term => '@:dgd/para:rend:' . $1,
              pti => 16,
              payload => '<s>' . $tui
            );
          };

          # Description
          if ($feat->{'#text'} =~ />([^<]+?)</) {
            $mtt->add(
              term => '@:dgd/para:desc:' . $1,
              pti => 16,
              payload => '<s>' . $tui
            );
          };
          last;
        };
      };
    }) or return;

  return 1;
};

sub layer_info {
  ['dgd/p=tokens','dgd/l=tokens','dgd/para=tokens'];
};

1;
