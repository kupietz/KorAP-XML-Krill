package KorAP::Index::Mate::Dependency;
use KorAP::Index::Base;
use Data::Dumper;

sub parse {
  my $self = shift;

  # TODO: Create XIP tree here - for indirect dependency
  # >>:xip_d:SUBJ<i>566<i>789

  $$self->add_tokendata(
    foundry => 'mate',
    layer => 'dependency',
    cb => sub {
      my ($stream, $token, $tokens) = @_;
      my $mtt = $stream->pos($token->pos);

      my $content = $token->hash;

      my $rel = $content->{rel};
      $rel = [$rel] unless ref $rel eq 'ARRAY';

      foreach (@$rel) {
	my $label = $_->{-label};

	if ($_->{-type} && $_->{-type} eq 'unary') {
	  next if $_->{-label} eq '--';
	  $mtt->add(
	    term => 'mate_d:' . $label
	  );
	}
	else {

	  my $from = $_->{span}->{-from};
	  my $to   = $_->{span}->{-to};

	  my $rel_token = $tokens->token($from, $to) or next;

	  $mtt->add(
	    term => '>:mate_d:' . $label,
	    payload => '<i>' . $rel_token->pos
	  );

	  $stream->pos($rel_token->pos)->add(
	    term => '<:mate_d:' . $label,
	    payload => '<i>' . $token->pos
	  );
	};
      };
    }) or return;

  return 1;
};


1;
