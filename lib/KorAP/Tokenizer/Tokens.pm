package KorAP::Tokenizer::Tokens;
use Mojo::Base 'KorAP::Tokenizer::Units';
use Mojo::DOM;
use Mojo::ByteStream 'b';
use KorAP::Tokenizer::Token;
use Carp qw/croak carp/;
use XML::Fast;


sub parse {
  my $self = shift;
  my $file = b($self->path . $self->foundry . '/' . $self->layer . '.xml')->slurp;

#  my $spans = Mojo::DOM->new($file);
#  $spans->xml(1);
  my $spans = xml2hash($file, text => '#text', attr => '-')->{layer}->{spanList}->{span};
  $spans = [$spans] if ref $spans ne 'ARRAY';


  my ($should, $have) = (0,0);

  my @tokens;

  foreach my $s (@$spans) {

    $should++;

    my $token = $self->token(
      $s->{-from},
      $s->{-to},
      $s
    ) or next;

    $have++;

    push(@tokens, $token);
  };

  $self->should($should);
  $self->have($have);

  return \@tokens;
};


1;
