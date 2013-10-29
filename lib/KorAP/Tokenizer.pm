package KorAP::Tokenizer;

use Mojo::Base -base;
use Mojo::ByteStream 'b';
use Carp qw/carp croak/;
use KorAP::Tokenizer::Range;
use KorAP::Tokenizer::Match;
use KorAP::Tokenizer::Spans;
use KorAP::Tokenizer::Tokens;
use KorAP::MultiTermTokenStream;
use Log::Log4perl;

has [qw/path foundry layer doc stream should have/];

has 'log' => sub {
  Log::Log4perl->get_logger(__PACKAGE__)
};

# Parse tokens of the document
sub parse {
  my $self = shift;

  # Create new token stream
  my $mtts = KorAP::MultiTermTokenStream->new;
  my $file = b($self->path . $self->foundry . '/' . ($self->layer // 'tokens') . '.xml')->slurp;
  my $tokens = Mojo::DOM->new($file);
  $tokens->xml(1);

  my $doc = $self->doc;

  my ($should, $have) = (0, 0);

  # Create range and match objects
  my $range = KorAP::Tokenizer::Range->new;
  my $match = KorAP::Tokenizer::Match->new;

  my $old = 0;

  $self->log->trace('Tokenize data ' . $self->foundry . ':' . $self->layer);

  # Iterate over all tokens
  $tokens->find('span')->each(
    sub {
      my $span = $_;
      my $from = $span->attr('from');
      my $to = $span->attr('to');
      my $token = $doc->primary->data($from, $to);

      $should++;

      # Ignore non-word tokens
      return if $token !~ /[\w\d]/;

      my $mtt = $mtts->add;

      # Add gap for later finding matching positions before or after
      $range->gap($old, $from, $have) unless $old >= $from;

      # Add surface term
      $mtt->add('s:' . $token);

      # Add case insensitive term
      $mtt->add('i:' . lc $token);

      # Add offset information
      $mtt->o_start($from);
      $mtt->o_end($to);

      # Store offset information for position matching
      $range->set($from, $to, $have);
      $match->set($from, $to, $have);

      $old = $to + 1;

      # Add position term
      $mtt->add('_' . $have . '#' . $mtt->o_start . '-' . $mtt->o_end);

      $have++;
    });

  # Add token count
  $mtts->add_meta('t', '<i>' . $have);

  $range->gap($old, $doc->primary->data_length, $have-1) if $doc->primary->data_length >= $old;

  # Add info
  $self->stream($mtts);
  $self->{range} = $range;
  $self->{match} = $match;
  $self->should($should);
  $self->have($have);

    $self->log->debug('With a non-word quota of ' . _perc($self->should, $self->should - $self->have) . ' %');
};


# Get span positions through character offsets
sub range {
  return shift->{range} // KorAP::Tokenizer::Range->new;
};


# Get token positions through character offsets
sub match {
  return shift->{match} // KorAP::Tokenizer::Match->new;
};


# Add information of spans to the tokens
sub add_spandata {
  my $self = shift;
  my %param = @_;

  croak 'No token data available' unless $self->stream;

  $self->log->trace(
    ($param{skip} ? 'Skip' : 'Add').' span data '.$param{foundry}.':'.$param{layer}
  );

  return if $param{skip};

  my $cb = delete $param{cb};

  if ($param{encoding} && $param{encoding} eq 'bytes') {
    $param{primary} = $self->doc->primary;
  };

  my $spans = KorAP::Tokenizer::Spans->new(
    path => $self->path,
    range => $self->range,
    %param
  );

  my $spanarray = $spans->parse;

  if ($spans->should == $spans->have) {
    $self->log->trace('With perfect alignment!');
  }
  else {
    $self->log->debug('With an alignment quota of ' . _perc($spans->should, $spans->have) . ' %');
  };


  if ($cb) {
    foreach (@$spanarray) {
      $cb->($self->stream, $_);
    };
    return;
  };
  return $spans;
};


# Add information to the tokens
sub add_tokendata {
  my $self = shift;
  my %param = @_;

  croak 'No token data available' unless $self->stream;

  $self->log->trace(
    ($param{skip} ? 'Skip' : 'Add').' token data '.$param{foundry}.':'.$param{layer}
  );
  return if $param{skip};

  my $cb = delete $param{cb};

  if ($param{encoding} && $param{encoding} eq 'bytes') {
    $param{primary} = $self->doc->primary;
  };

  my $tokens = KorAP::Tokenizer::Tokens->new(
    path => $self->path,
    match => $self->match,
    %param
  );

  my $tokenarray = $tokens->parse;

  if ($tokens->should == $tokens->have) {
    $self->log->trace('With perfect alignment!');
  }
  else {
    my $perc = _perc(
      $tokens->should, $tokens->have, $self->should, $self->should - $self->have
    );
    $self->log->debug('With an alignment quota of ' . $perc);
  };

  if ($cb) {
    foreach (@$tokenarray) {
      $cb->($self->stream, $_);
    };
    return;
  };
  return $tokens;
};


sub _perc {
  if (@_ == 2) {
    # '[' . $_[0] . '/' . $_[1] . ']' .
    return sprintf("%.2f", ($_[1] * 100) / $_[0]);
  }

  my $a_should = shift;
  my $a_have   = shift;
  my $b_should = shift;
  my $b_have   = shift;
  my $a_quota = ($a_have * 100) / $a_should;
  my $b_quota = ($b_have * 100) / $b_should;
  return sprintf("%.2f", $a_quota) . '%' .
    ((($a_quota + $b_quota) <= 100) ?
       ' [' . sprintf("%.2f", $a_quota + $b_quota) . '%]' : '');
};


1;


__END__

=pod

=head1 NAME

KorAP::Tokenizer

=head1 SYNOPSIS

  my $tokens = KorAP::Tokenizer->new(
    path    => '../examples/00003',
    doc     => KorAP::Document->new( ... ),
    foundry => 'opennlp',
    layer   => 'tokens'
  );

  $tokens->parse;

=head1 DESCRIPTION

Convert token information from the KorAP XML
format into Lucene Index compatible token streams.

=head1 ATTRIBUTES

=head2 path

  print $tokens->path;

The path of the document.


=head2 foundry

  print $tokens->foundry;

The name of the foundry.


=head2 layer

  print $tokens->layer;

The name of the tokens layer.


=head2 doc

  print $tokens->doc->corpus_id;

The L<KorAP::Document> object.


=head2 stream

  $tokens->stream->add_meta('adjCount', '<i>45');

The L<KorAP::MultiTermTokenStream> object


=head2 range

  $tokens->range->lookup(45);

The L<KorAP::Tokenizer::Range> object for converting span offsets to positions.

=head2 match

  $tokens->match->lookup(45);

The L<KorAP::Tokenizer::Match> object for converting token offsets to positions.


=head1 METHODS

=head2 parse

  $tokens->parse;

Start the tokenization process.


=head2 add_spandata

  $tokens->add_spandata(
    foundry => 'base',
    layer => 'sentences',
    cb => sub {
      my ($stream, $span) = @_;
      my $mtt = $stream->pos($span->p_start);
      $mtt->add(
	term    => '<>:s',
	o_start => $span->o_start,
	o_end   => $span->o_end,
	p_end   => $span->p_end
      );
    }
  );

Add span information to the parsed token stream.
Expects a C<foundry> name, a C<layer> name and a
callback parameter, that will be called after each parsed
span. The L<KorAP::MultiTermTokenStream> object will be passed,
as well as the current L<KorAP::Tokenizer::Span>.

An optional parameter C<encoding> may indicate that the span offsets
are either refering to C<bytes> or C<utf-8> offsets.

An optional parameter C<skip> allows for skipping the process.


=head2 add_tokendata

  $tokens->add_tokendata(
    foundry => 'connexor',
    layer => 'syntax',
    cb => sub {
      my ($stream, $token) = @_;
      my $mtt = $stream->pos($token->pos);
      my $content = $token->content;

      # syntax
      if ((my $found = $content->at('f[name="pos"]')) && ($found = $found->text)) {
	$mtt->add(
	  term => 'cnx_syn:' . $found
	);
      };
    });

Add token information to the parsed token stream.
Expects a C<foundry> name, a C<layer> name and a
callback parameter, that will be called after each parsed
token. The L<KorAP::MultiTermTokenStream> object will be passed,
as well as the current L<KorAP::Tokenizer::Span>.

An optional parameter C<encoding> may indicate that the token offsets
are either refering to C<bytes> or C<utf-8> offsets.

An optional parameter C<skip> allows for skipping the process.

=cut
