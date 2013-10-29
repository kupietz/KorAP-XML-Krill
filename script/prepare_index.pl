#!/usr/bin/env perl
use strict;
use warnings;
use v5.16;
use lib 'lib', '../lib';
use Set::Scalar;
use Mojo::DOM;
use Mojo::Util qw/encode decode/;
use Mojo::ByteStream 'b';

use Log::Log4perl;
Log::Log4perl->init("script/log4perl.conf");

use KorAP::Document;
use KorAP::Tokenizer;


# Call perl script/prepare_index.pl WPD/AAA/00001

sub parse_doc {
  my $doc = KorAP::Document->new(
    path => shift . '/'
  );

  $doc->parse;

  my $tokens = KorAP::Tokenizer->new(
    path => $doc->path,
    doc => $doc,
    foundry => 'connexor',
    layer => 'tokens'
  );

  $tokens->parse;

  my $i = 0;
  $tokens->add_spandata(
    foundry => 'connexor',
    layer => 'sentences',
    #skip => 1,
    cb => sub {
      my ($stream, $span) = @_;
      my $mtt = $stream->pos($span->p_start);
      $mtt->add(
	term => '<>:s',
	o_start => $span->o_start,
	o_end => $span->o_end,
	p_end => $span->p_end
      );
      $i++;
    }
  );

  $tokens->stream->add_meta('s', '<i>' . $i);

  $i = 0;
  $tokens->add_spandata(
    foundry => 'base',
    layer => 'paragraph',
    #skip => 1,
    cb => sub {
      my ($stream, $span) = @_;
      my $mtt = $stream->pos($span->p_start);
      $mtt->add(
	term => '<>:p',
	o_start => $span->o_start,
	o_end => $span->o_end,
	p_end => $span->p_end
      );
      $i++;
    }
  );
  $tokens->stream->add_meta('p', '<i>' . $i);

  $tokens->add_tokendata(
    foundry => 'opennlp',
    layer => 'morpho',
    #skip => 1,
    cb => sub {
      my ($stream, $token) = @_;
      my $mtt = $stream->pos($token->pos);
      my $content = $token->content;

      my $found;

      # syntax
      if (($found = $content->at('f[name="pos"]')) && ($found = $found->text)) {
	$mtt->add(
	  term => 'opennlp_p:' . $found
	);
      };
    });


  my $model = 'ne_dewac_175m_600';
  $tokens->add_tokendata(
    foundry => 'corenlp',
    #skip => 1,
    layer => $model,
    cb => sub {
      my ($stream, $token) = @_;
      my $mtt = $stream->pos($token->pos);
      my $content = $token->content;

      my $found;

      if (($found = $content->at('f[name=ne] f[name=ent]')) && ($found = $found->text)) {
	$mtt->add(
	  term => 'corenlp_' . $model . ':' . $found
	);
      };
    });

  $model = 'ne_hgc_175m_600';
  $tokens->add_tokendata(
    foundry => 'corenlp',
    #skip => 1,
    layer => $model,
    cb => sub {
      my ($stream, $token) = @_;
      my $mtt = $stream->pos($token->pos);
      my $content = $token->content;

      my $found;

      if (($found = $content->at('f[name=ne] f[name=ent]')) && ($found = $found->text)) {
	$mtt->add(
	  term => 'corenlp_' . $model . ':' . $found
	);
      };
    });

  $tokens->add_tokendata(
    foundry => 'connexor',
    layer => 'morpho',
    #skip => 1,
    cb => sub {
      my ($stream, $token) = @_;
      my $mtt = $stream->pos($token->pos);
      my $content = $token->content;

      my $found;

      # Lemma
      if (($found = $content->at('f[name="lemma"]')) && ($found = $found->text)) {
	if (index($found, "\N{U+00a0}") >= 0) {
	  $found = b($found)->decode;
	  foreach (split(/\x{00A0}/, $found)) {
	    $mtt->add(
	      term => 'cnx_l:' . b($_)->encode
	    );
	  }
	}
	else {
	  $mtt->add(
	    term => 'cnx_l:' . $found # b($found)->encode
	  );
	};
      };

      # POS
      if (($found = $content->at('f[name="pos"]')) && ($found = $found->text)) {
	$mtt->add(
	  term => 'cnx_p:' . $found
	);
      };

      # MSD
      # Todo: Look in the description!
      if (($found = $content->at('f[name="msd"]')) && ($found = $found->text)) {
	foreach (split(':', $found)) {
	  $mtt->add(
	    term => 'cnx_m:' . $_
	  );
	};
      };
    }
  );

  $tokens->add_tokendata(
    foundry => 'connexor',
    layer => 'syntax',
    #skip => 1,
    cb => sub {
      my ($stream, $token) = @_;
      my $mtt = $stream->pos($token->pos);
      my $content = $token->content;

      my $found;

      # syntax
      if (($found = $content->at('f[name="pos"]')) && ($found = $found->text)) {
	$mtt->add(
	  term => 'cnx_syn:' . $found
	);
      };
    });

  $tokens->add_spandata(
    foundry => 'connexor',
    layer => 'phrase',
    #skip => 1,
    cb => sub {
      my ($stream, $span) = @_;

      my $type = $span->content->at('f[name=pos]');
      if ($type && ($type = $type->text)) {
	my $mtt = $stream->pos($span->p_start);
	$mtt->add(
	  term => '<>:cnx_const:' . $type,
	  o_start => $span->o_start,
	  o_end => $span->o_end,
	  p_end => $span->p_end
	);
      };
    }
  );

  $tokens->add_tokendata(
    foundry => 'tree_tagger',
    #skip => 1,
    layer => 'morpho',
    cb => sub {
      my ($stream, $token) = @_;
      my $mtt = $stream->pos($token->pos);
      my $content = $token->content;

      my $found;

      # lemma
      if (($found = $content->at('f[name="lemma"]')) &&
	    ($found = $found->text) && $found ne 'UNKNOWN') {
	$mtt->add(
	  term => 'tt_l:' . $found
	);
      };

      # pos
      if (($found = $content->at('f[name="ctag"]')) && ($found = $found->text)) {
	$mtt->add(
	  term => 'tt_p:' . $found
	);
      };
    });

  $tokens->add_tokendata(
    foundry => 'mate',
    layer => 'morpho',
    cb => sub {
      my ($stream, $token) = @_;
      my $mtt = $stream->pos($token->pos);
      my $content = $token->content;

      my $found;

      my $capital = 0;

      # pos
      if (($found = $content->at('f[name="pos"]')) &&
	    ($found = $found->text)) {
	$mtt->add(term => 'mate_p:' . $found
	);
      };

      # lemma
      if (($found = $content->at('f[name="lemma"]'))
	    && ($found = $found->text)
	      && $found ne '--') {
	$mtt->add(term => 'mate_l:' . b($found)->decode('latin-1')->encode->to_string);
      };

      # MSD
      if (($found = $content->at('f[name="msd"]')) &&
	    ($found = $found->text) &&
	      ($found ne '_')) {
	foreach (split '\|', $found) {
	  my ($x, $y) = split "=", $_;
	  # case, tense, number, mood, person, degree, gender
	  $mtt->add(term => 'mate_m:' . $x . ':' . $y);
	};
      };
    });


  $tokens->add_tokendata(
    foundry => 'xip',
    #skip => 1,
    layer => 'morpho',
    encoding => 'bytes',
    cb => sub {
      my ($stream, $token) = @_;
      my $mtt = $stream->pos($token->pos);
      my $content = $token->content;

      my $found;

      my $capital = 0;
      # pos
      if (($found = $content->at('f[name="pos"]')) && ($found = $found->text)) {
	$mtt->add(
	  term => 'xip_p:' . $found
	);

	$capital = 1 if $found eq 'NOUN';
      };

      # lemma
      if (($found = $content->at('f[name="lemma"]')) && ($found = $found->text)) {
	my (@token) = split('#', $found);

	my $full = '';
	foreach (@token) {
	  $full .= $_;
	  $_ =~ s{/\w+$}{};
	  $mtt->add(term => 'xip_l:' . $_);
	};
	if (@token > 1) {
	  $full =~ s{/}{}g;
	  $full = lc $full;
	  $full = $capital ? ucfirst($full) : $full;
	  $mtt->add(term => 'xip_l:' . $full);
	};
      };
    });


  # Collect all spans and check for roots
  my %xip_const;
  my $xip_const_root = Set::Scalar->new;
  my $xip_const_noroot = Set::Scalar->new;

  # First run:
  $tokens->add_spandata(
    foundry => 'xip',
    layer => 'constituency',
    encoding => 'bytes',
    #skip => 1,
    cb => sub {
      my ($stream, $span) = @_;

      $xip_const{$span->id} = $span;
      $xip_const_root->insert($span->id);

      $span->content->find('rel[label=dominates][target]')->each(
	sub {
	  my $rel = shift;
	  $xip_const_noroot->insert($rel->attr('target'));
	}
      );
    }
  );

  my $stream = $tokens->stream;

  my $add_const = sub {
    my $span = shift;
    my $level = shift;
    my $mtt = $stream->pos($span->p_start);

    my $content = $span->content;
    my $type = $content->at('f[name=const]');
    if ($type && ($type = $type->text)) {
      # $type is now NPA, NP, NUM
      my %term = (
	term => '<>:xip_const:' . $type,
	o_start => $span->o_start,
	o_end => $span->o_end,
	p_end => $span->p_end
      );

      $term{payload} = '<s>' . $level if $level;

      $mtt->add(%term);

      my $this = __SUB__;

      $content->find('rel[label=dominates][target]')->each(
	sub {
	  my $subspan = delete $xip_const{$_[0]->attr('target')} or return;
	  $this->($subspan, $level + 1);
	}
      );
    };
  };

  my $diff = $xip_const_root->difference($xip_const_noroot);
  foreach ($diff->members) {
    my $obj = delete $xip_const{$_} or next;
    $add_const->($obj, 0);
  };

  # Todo: Add mate-morpho
  # Todo: Add mate-dependency
  # Todo: Add xip-dependency

  print $tokens->stream->to_string;
};

if ($ARGV[0]) {
  parse_doc($ARGV[0]);
};



__END__
