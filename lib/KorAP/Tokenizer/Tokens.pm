package KorAP::Tokenizer::Tokens;
use Mojo::Base -base;
use Mojo::DOM;
use Mojo::ByteStream 'b';
use KorAP::Tokenizer::Token;

has [qw/path foundry layer match primary should have/];
has 'encoding' => 'utf-8';

sub parse {
  my $self = shift;
  my $file = b($self->path . $self->foundry . '/' . $self->layer . '.xml')->slurp;

  my $spans = Mojo::DOM->new($file);
  $spans->xml(1);

  my ($should, $have) = (0,0);
  my ($from, $to);

  my $match = $self->match;

  my @tokens;
  $spans->find('span')->each(
    sub {
      my $s = shift;

      $should++;

      if ($self->encoding eq 'bytes') {
	$from = $self->primary->bytes2chars($s->attr('from'));
	$to = $self->primary->bytes2chars($s->attr('to'));
      }
      else {
	$from = $s->attr('from');
	$to = $s->attr('to');
      };

      my $pos = $match->lookup($from, $to);

      return unless defined $pos;

      my $token = KorAP::Tokenizer::Token->new;
      $token->id($s->attr('id'));
      $token->pos($pos);

      if (@{$s->children}) {
	$token->content($s->content_xml);
      };

      $have++;

      push(@tokens, $token);
    });

  $self->should($should);
  $self->have($have);

  return \@tokens;
};


1;
