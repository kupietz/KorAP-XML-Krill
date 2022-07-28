package KorAP::XML::Meta::NKJP;
use KorAP::XML::Meta::Base;
use KorAP::XML::Meta::I5;

my $squish = \&KorAP::XML::Meta::I5::_squish;

our %taxonomy = ();

sub parse {
  my ($self, $dom, $type) = @_;

  # Parse using the parent I% class
  unless (KorAP::XML::Meta::I5::parse($self, $dom, $type)) {
    return 0;
  };

  my $lang = $self->lang // 'pl';

  if ($type eq 'corpus') {

    %taxonomy = ();

    my $taxes = $dom->find('encodingDesc > classDecl > taxonomy');

    $taxes->each(
      sub{
        my $tax_id = $_->attr('xml:id') or return;

        $_->find('category')->each(
          sub {
            my $cat_id = $_->attr('xml:id') or return;

            my $desc = $_->find('> desc')->first(
              sub{ $_->attr('xml:lang') && lc($_->attr('xml:lang')) eq lc($lang) }
            )->all_text;

            my $tax_sub = $taxonomy{$tax_id} //= {};
            $tax_sub->{'#' . $cat_id} = $desc;
          }
        );
      }
    );
  }

  elsif ($type eq 'text') {

    # Delete old interpretation
    delete $self->{K_text_class};

    my $temp = $dom->at('textClass');
    if ($temp) {
      # Dereference categories
      $temp->find("catRef")->each(
        sub {
          return unless $_->attr('target');
          return unless $_->attr('scheme');

          my $target = $_->attr('target');
          my $scheme = $_->attr('scheme');


          # Set NKJP type
          if ($scheme eq '#taxonomy-NKJP-type') {
            $self->{K_nkjp_type} //= [];
            my $resolved = $taxonomy{'taxonomy-NKJP-type'}->{$target};
            push(@{$self->{K_nkjp_type}}, split(',\s+', $resolved)) if $resolved;
          }

          # Set NKJP type
          elsif ($scheme eq '#taxonomy-NKJP-channel') {
            $self->{K_nkjp_channel} //= [];
            my $resolved = $taxonomy{'taxonomy-NKJP-channel'}->{$target};
            push(@{$self->{K_nkjp_channel}}, split(',\s+', $resolved)) if $resolved;
          };
        }
      );
    };
  };
};

1;
