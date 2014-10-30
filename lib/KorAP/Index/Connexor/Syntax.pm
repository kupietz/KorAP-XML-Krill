package KorAP::Index::Connexor::Syntax;
use KorAP::Index::Base;

sub parse {
  my $self = shift;

  $$self->add_tokendata(
    foundry => 'connexor',
    layer => 'syntax',
    cb => sub {
      my ($stream, $token) = @_;
      my $mtt = $stream->pos($token->pos);
      my $found;
      my $spans = $token->hash->{fs}->{f}->{fs}->{f};


      # syntax
      foreach (@$spans) {
	if (($_->{-name} eq 'pos') && ($found = $_->{'#text'})) {
	  $mtt->add(
	    term => 'cnx/syn:' . $found
	  );
	};
      };
    }) or return;

  return 1;
};

sub layer_info {
    ['cnx/syn=tokens'];
};

1;
