package KorAP::XML::Annotation::DGD::Morpho;
use KorAP::XML::Annotation::Base;
use Data::Dumper;

our %conv = (
  pos   => 'p',
  trans => 'trans',
  phon  => 'phon',
  type  => 'type',
  lemma => 'l'
);

sub parse {
  my $self = shift;

  $$self->add_tokendata(
    foundry => 'dgd',
    layer => 'annot',
    cb => sub {
      my ($stream, $token) = @_;
      my $mtt = $stream->pos($token->get_pos);
      my $tui = $stream->tui($token->get_pos);

      my $content = $token->get_hash->{fs}->{f} or return;

      $content = $content->{fs}->{f};
      $content = [$content] unless ref $content eq 'ARRAY';

      foreach my $feat (@$content) {

        my $text = $feat->{'#text'} or next;
        my $name = $feat->{-name};

        if (my $t = $conv{$name}) {
          $mtt->add_by_term('dgd/' . $t . ':' . $text);
        }

        # Pause
        elsif ($name eq 'pause') {
          my $p = $mtt->add_by_term('dgd/para:pause');
          $p->set_pti(128);
          $p->set_payload('<s>' . $tui);

          # Duration
          if ($text =~ /dur="PT([^"]+?)"/) {
            $p = $mtt->add_by_term('@:dgd/para:dur:' . $1);
            $p->set_pti(16);
            $p->set_payload('<s>' . $tui);
          };

          # Rendering
          if ($text =~ /rend="([^"]+?)"/) {
            $p = $mtt->add_by_term('@:dgd/para:rend:' . $1);
            $p->set_pti(16);
            $p->set_payload('<s>' . $tui);
          };

          # Type
          if ($text =~ /type="([^"]+?)"/) {
            $p = $mtt->add_by_term('@:dgd/para:type:' . $1);
            $p->set_pti(16);
            $p->set_payload('<s>' . $tui);
          };

          last;
        }

        # Incident
        elsif (($name eq 'incident') || ($name eq 'vocal')) {
          my $i = $mtt->add_by_term('dgd/para:' . $name);
          $i->set_pti(128);
          $i->set_payload('<s>' . $tui);

          # Rendering
          if ($text =~ /rend="([^"]+?)"/) {
            $i = $mtt->add_by_term('@:dgd/para:rend:' . $1);
            $i->set_pti(16);
            $i->set_payload('<s>' . $tui);
          };

          # desc
          if ($text =~ m!<desc[^>]*>([^<]+?)<\/desc>!) {
            $i = $mtt->add_by_term('@:dgd/para:desc:' . $1);
            $i->set_pti(16);
            $i->set_payload('<s>' . $tui);
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
