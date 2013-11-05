package KorAP::Index::XIP::Dependency;
use KorAP::Index::Base;

sub parse {
  my $self = shift;

  # TODO: Create XIP tree here - for indirect dependency
  # >>:xip_d:SUBJ<i>566<i>789

  $$self->add_tokendata(
    foundry => 'xip',
    layer => 'dependency',
    encoding => 'xip',
    cb => sub {
      my ($stream, $token, $tokens) = @_;
      my $mtt = $stream->pos($token->pos);

      my $content = $token->hash;

      my $rel = $content->{rel};
      $rel = [$rel] unless ref $rel eq 'ARRAY';

      foreach (@$rel) {
	my $label = $_->{-label};

	if ($_->{-type} && $_->{-type} eq 'unary') {
	  $mtt->add(
	    term => 'xip_d:' . $label
	  );
	}
	else {

	  my $from = $_->{span}->{-from};
	  my $to   = $_->{span}->{-to};

	  my $rel_token = $tokens->token($from, $to) or next;

	  # die $token->pos . ' -' . $label . '-> ' . $rel_token->pos;
	  $mtt->add(
	    term => '>:xip_d:' . $label,
	    payload => '<i>' . $rel_token->pos
	  );

	  $stream->pos($rel_token->pos)->add(
	    term => '<:xip_d:' . $label,
	    payload => '<i>' . $token->pos
	  );
	};

#	print $label,"\n";
      };
    }) or return;

  return 1;
};


1;
