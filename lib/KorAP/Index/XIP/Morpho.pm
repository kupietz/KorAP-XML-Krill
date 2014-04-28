package KorAP::Index::XIP::Morpho;
use KorAP::Index::Base;

sub parse {
  my $self = shift;

  $$self->add_tokendata(
    foundry => 'xip',
    layer => 'morpho',
    encoding => 'xip',
    cb => sub {
      my ($stream, $token) = @_;
      my $mtt = $stream->pos($token->pos);

      my $content = $token->hash->{fs}->{f}->{fs}->{f};

      my $found;

      my $capital = 0;
      foreach (@$content) {
	# pos
	if (($_->{-name} eq 'pos') && ($found = $_->{'#text'})) {
	  $mtt->add(
	    term => 'xip/p:' . $found
	  );

	  $capital = 1 if $found eq 'NOUN';
	}
      };

      foreach (@$content) {
	# lemma
	if (($_->{-name} eq 'lemma') && ($found = $_->{'#text'})) {

	  # Verb delimiter (aus=druecken)
	  $mtt->add(term => 'xip/l:' . $found);
	  if ($found =~ tr/=//d) {
	    $mtt->add(term => 'xip/l:' . $found);
	  };

	  # Composites
	  my (@token) = split('#', $found);

	  if (@token == 1) {
#	    my $x = $token[0];
#	    $x =~ s{/\w+$}{};
#	    $mtt->add(term => 'xip/l:' . $x);
	    next;
	  };
	  my $full = '';
	  foreach (@token) {
	    $full .= $_;
	    $_ =~ s{/\w+$}{};
	    $mtt->add(term => 'xip/l:#' . $_);
	  };
#	  if (@token > 1) {
#	    $full =~ s{/}{}g;
#	    $full = lc $full;
#	    $full = $capital ? ucfirst($full) : $full;
#	    $mtt->add(term => 'xip/l:' . $full);
#	  };
	};
      };
    }) or return;

  return 1;
};

sub layer_info {
    ['xip/l=lemma', 'xip/p=pos']
};


1;
