package KorAP::Tokenizer;
use Mojo::Base -base;
use Mojo::ByteStream 'b';
use Mojo::Loader;
use XML::Fast;
use Try::Tiny;
use Carp qw/croak/;
use KorAP::Tokenizer::Range;
use KorAP::Tokenizer::Match;
use KorAP::Tokenizer::Spans;
use KorAP::Tokenizer::Tokens;
use KorAP::Field::MultiTermTokenStream;
use List::MoreUtils 'uniq';
use JSON::XS;
use Log::Log4perl;

has [qw/path foundry doc stream should have name/];
has layer => 'Tokens';

has log => sub {
  if(Log::Log4perl->initialized()) {
    state $log = Log::Log4perl->get_logger(__PACKAGE__);
  };
  state $log = KorAP::Log->new;
  return $log;
};

warn('IMPLEMENT AGGRESSIVE TOKENIZATION (trennen mit [-\'\s])');
warn('In the payload the position of the partial token has to be marked, '.
       'so the voodoo operator can do its thing');

# Parse tokens of the document
sub parse {
  my $self = shift;

  # Create new token stream
  my $mtts = KorAP::Field::MultiTermTokenStream->new;
  my $path = $self->path . lc($self->foundry) . '/' . lc($self->layer) . '.xml';
  my $file = b($path)->slurp;
#  my $tokens = Mojo::DOM->new($file);
#  $tokens->xml(1);

  my $doc = $self->doc;

  my ($should, $have) = (0, 0);

  # Create range and match objects
  my $range = KorAP::Tokenizer::Range->new;
  my $match = KorAP::Tokenizer::Match->new;

  my $old = 0;

  $self->log->trace('Tokenize data ' . $self->foundry . ':' . $self->layer);

  # TODO: Reuse the following code from Spans.pm and tokens.pm
  my ($tokens, $error);
  try {
      local $SIG{__WARN__} = sub {
	  $error = 1;
      };
      $tokens = xml2hash($file, text => '#text', array => ['span'], attr => '-')->{layer}->{spanList};
  }
  catch  {
      $self->log->warn('Token error in ' . $path . ($_ ? ': ' . $_ : ''));
      $error = 1;
  };

  return if $error;

  if (ref $tokens && $tokens->{span}) {
    $tokens = $tokens->{span};
  }
  else {
      return $self;
  };

  $tokens = [$tokens] if ref $tokens ne 'ARRAY';

  # Iterate over all tokens
  # $tokens->find('span')->each(
  #    sub {
  # my $span = $_;
  foreach my $span (@$tokens) {
      my $from = $span->{'-from'};
      my $to = $span->{'-to'};
      my $token = $doc->primary->data($from, $to);

      # warn 'Has ' . $from . '->' . $to . "($old)";

      unless (defined $token) {
	  $self->log->error("Unable to find substring [$from-$to] in $path");
	  next;
      };

      $should++;

      # Ignore non-word tokens
      next if $token !~ /[\w\d]/;

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
  };

  # Add token count
  $mtts->add_meta('tokens', '<i>' . $have);

  $range->gap($old, $doc->primary->data_length + 1, $have-1) if $doc->primary->data_length >= ($old - 1);

  # Add info
  $self->stream($mtts);
  $self->{range} = $range;
  $self->{match} = $match;
  $self->should($should);
  $self->have($have);

  $self->log->debug('With a non-word quota of ' . _perc($self->should, $self->should - $self->have) . ' %');

  return $self;
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

  $param{primary} = $self->doc->primary;

  my $spans = KorAP::Tokenizer::Spans->new(
    path => $self->path,
    range => $self->range,
    match => $self->match,
    %param
  );

  my $spanarray = $spans->parse or return;

  if ($spans->should == $spans->have) {
    $self->log->trace('With perfect alignment!');
  }
  else {
    $self->log->debug('With an alignment quota of ' . _perc($spans->should, $spans->have) . ' %');
  };

  if ($cb) {
    foreach (@$spanarray) {
      $cb->($self->stream, $_, $spans);
    };
    return 1;
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

  $param{primary} = $self->doc->primary;

  my $tokens = KorAP::Tokenizer::Tokens->new(
    path => $self->path,
    range => $self->range,
    match => $self->match,
    %param
  );

  my $tokenarray = $tokens->parse or return;

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
      $cb->($self->stream, $_, $tokens);
    };
    return 1;
  };
  return $tokens;
};


sub add {
  my $self = shift;
  my $loader = Mojo::Loader->new;
  my $foundry = shift;
  my $layer = shift;

  unless ($foundry && $layer) {
    warn 'Unable to add specific module - not enough information given!';
    return;
  };

  my $mod = 'KorAP::Index::' . $foundry . '::' . $layer;

  if ($mod->can('new') || eval("require $mod; 1;")) {
    if (my $retval = $mod->new($self)->parse(@_)) {

      # This layer is supported
      $self->support($foundry => $layer, @_);

      # Get layerinfo
      $self->layer_info($mod->layer_info);
      return $retval;
    };
  }
  else {
    $self->log->error('Unable to load '.$mod . '(' . $@ . ')');
  };

  return;
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


sub support {
  my $self = shift;

  # No setting - just getting
  unless ($_[0]) {
    my @supports;

    # Get all foundries
    foreach my $foundry (keys %{$self->{support}}) {
      push(@supports, $foundry);

      # Get all layers
      foreach my $layer (@{$self->{support}->{$foundry}}) {
	  my @layers = @$layer;
	  push(@supports, $foundry . '/' . $layers[0]);

	  # More information
	  if ($layers[1]) {
	      push(@supports, $foundry . '/' . join('/', @layers));
	  };
      };
    };
    return lc ( join ' ', sort {$a cmp $b } @supports );
  }
  elsif (!$_[1]) {
    return $self->{support}->{$_[0]} // []
  };
  my $f = lc shift;
  my $l = lc shift;
  my @info = @_;
  $self->{support} //= {};
  $self->{support}->{$f} //= [];
  push(@{$self->{support}->{$f}}, [$l, @info]);
};


sub layer_info {
    my $self = shift;
    $self->{layer_info} //= [];
    if ($_[0]) {
	push(@{$self->{layer_info}}, @{$_[0]});
    }
    else {
	return join ' ', sort {$a cmp $b } uniq @{$self->{layer_info}};
    };
};


sub to_string {
  my $self = shift;
  my $primary = defined $_[0] ? $_[0] : 1;
  my $string = "<meta>\n";
  $string .= $self->doc->to_string;
  $string .= "</meta>\n";
  if ($primary) {
    $string .= "<text>\n";
    $string .= $self->doc->primary->data . "\n";
    $string .= "</text>\n";
  };
  $string .= '<field name="' . $self->name . "\">\n";
  $string .= "<info>\n";
  $string .= 'tokenization = ' . $self->foundry . '#' . $self->layer . "\n";

  # There is support info
  if (my $support = $self->support) {
    $string .= 'support = ' . $support . "\n";
  };
  if (my $layer_info = $self->layer_info) {
    $string .= 'layer_info = ' . $layer_info . "\n";
  };

  $string .= "</info>\n";
  $string .= $self->stream->to_string;
  $string .= "</field>";
  return $string;
};

sub to_data {
  my $self = shift;
  my $primary = defined $_[0] ? $_[0] : 1;
  my %data = %{$self->doc->to_hash};

  my @fields;
  push(@fields, { primaryData => $self->doc->primary->data }) if $primary;

  push(@fields, {
    name => $self->name,
    data => $self->stream->to_array,
    tokenization => lc($self->foundry) . '#' . lc($self->layer),
    foundries => $self->support,
    layerInfo => $self->layer_info
  });

  $data{fields} = \@fields;
  \%data;
};


sub to_json {
  encode_json($_[0]->to_data($_[1]));
};


sub to_pretty_json {
  JSON::XS->new->pretty->encode($_[0]->to_data($_[1]));
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

=head2 should

Number of tokens that exist at all.

=head2 have

Number of tokens effectively stored in the token stream (e.g., no punctuations).

=head2 layer

  print $tokens->layer;

The name of the tokens layer.


=head2 doc

  print $tokens->doc->corpus_id;

The L<KorAP::Document> object.


=head2 stream

  $tokens->stream->add_meta('adjCount', '<i>45');

The L<KorAP::Field::MultiTermTokenStream> object


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
span. The L<KorAP::Field::MultiTermTokenStream> object will be passed,
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
token. The L<KorAP::Field::MultiTermTokenStream> object will be passed,
as well as the current L<KorAP::Tokenizer::Span>.

An optional parameter C<encoding> may indicate that the token offsets
are either refering to C<bytes> or C<utf-8> offsets.

An optional parameter C<skip> allows for skipping the process.

=cut
