package KorAP::XML::Annotation::LWC::Dependency;
use KorAP::XML::Annotation::Base;
use strict;
use warnings;

sub parse {
  my $self = shift;

  # Relation data
  $$self->add_tokendata(
    foundry => 'lwc',
    layer => 'dependency',
    cb => sub {
      my ($stream, $source, $tokens) = @_;

      # Get MultiTermToken from stream for source
      my $mtt = $stream->pos($source->get_pos);

      # Serialized information from token
      my $content = $source->get_hash;

      # Get relation information
      my $rel = $content->{rel};
      $rel = [$rel] unless ref $rel eq 'ARRAY';

      my $mt;

      # Iterate over relations
      foreach (@$rel) {
        my $label = $_->{-label};

        #my $target = $stream->tui($source->pos);
        my $from = $_->{span}->{-from};
        my $to   = $_->{span}->{-to};

        # Target
        my $target = $tokens->token($from, $to);

        # Relation is term-to-term with a found target!
        if ($target) {

          # Unary means, it refers to itself!
          $mt = $mtt->add_by_term('>:lwc/d:' . $label);
          $mt->set_pti(32); # term-to-term relation
          $mt->set_payload(
            '<i>' . $target->get_pos # . # right part token position
              # '<s>0' . # $source_term->tui . # left part tui
              # '<s>0' # . $target_term->tui # right part tui
          );

          $mt = $stream->pos($target->get_pos)
            ->add_by_term('<:lwc/d:' . $label);
          $mt->set_pti(32); # term-to-term relation
          $mt->set_payload(
            '<i>' . $source->get_pos # . # left part token position
              # '<s>0' . # $source_term->tui . # left part tui
              # '<s>0' # . $target_term->tui # right part tui
          );
        }

        # Relation is possibly term-to-element
        # with a found target!
        elsif ($target = $tokens->span($from, $to)) {
          $mt = $mtt->add_by_term('>:lwc/d:' . $label);
          $mt->set_pti(33); # term-to-element relation
          $mt->set_payload(
            '<i>' . $target->get_o_start . # end position
              '<i>' . $target->get_o_end . # end position
              '<i>' . $target->get_p_start . # right part start position
              '<i>' . $target->get_p_end # . # right part end position
              # '<s>0' . # $source_term->tui . # left part tui
              # '<s>0' # . $target_span->tui # right part tui
            );

          $mt = $stream->pos($target->get_p_start)
            ->add_by_term('<:lwc/d:' . $label);
          $mt->set_pti(34); # element-to-term relation
          $mt->set_payload(
            '<i>' . $target->get_o_start . # end position
              '<i>' . $target->get_o_end . # end position
              '<i>' . $target->get_p_end . # right part end position
              '<i>' . $source->get_pos # . # left part token position
              #	'<s>0' . # $source_term->tui . # left part tui
              # '<s>0' # . $target_span->tui # right part tui
            );
        }
        else {
          use Data::Dumper;
          $$self->log->warn('Relation currently not supported: ' . Dumper($content));
        };
      };
    }) or return;

  return 1;
};

sub layer_info {
  ['lwc/d=rels']
};


1;
