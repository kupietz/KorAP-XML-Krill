package KorAP::Tokenizer::Spans;
use Mojo::Base -base;
use KorAP::Tokenizer::Span;
use Mojo::DOM;
use Mojo::ByteStream 'b';

has [qw/path foundry layer range primary should have/];
has 'encoding' => 'utf-8';

sub parse {
  my $self = shift;
  my $file = b($self->path . $self->foundry . '/' . $self->layer . '.xml')->slurp;

  my $spans = Mojo::DOM->new($file);
  $spans->xml(1);

  my ($should, $have) = (0,0);
  my ($from, $to);

  my @spans;
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

      return unless $to > $from;

      my $span = KorAP::Tokenizer::Span->new;

      $span->id($s->attr('id'));
      $span->o_start($from);
      $span->o_end($to);
      $span->p_start($self->range->after($span->o_start));
      $span->p_end($self->range->before($span->o_end));

      return unless $span->p_end >= $span->p_start;

      if (@{$s->children}) {
	$span->content($s->content_xml);
      };

      $have++;

      push(@spans, $span);
    });

  $self->should($should);
  $self->have($have);

  return \@spans;
};

1;
