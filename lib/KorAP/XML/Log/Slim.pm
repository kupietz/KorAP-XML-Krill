package KorAP::XML::Log::Slim;
use strict;
use warnings;

# Parse log files and filter out only unusual and unexpected errors.

sub new {
  my ($class, $file) = @_;

  if ($file && open(my $fh, $file)) {
    return bless { input => $fh}, $class;
  };

  return;
};


sub slim_to {
  my $self = shift;
  my $fh = $self->{input};
  my $out_fh = shift // *STDOUT;

  my ($unable, $unable_substring, $unable_offsets) = (0,0,0);

  # Iterate over file
  while (!eof($fh)){
    local $_ = <$fh>;

    # Ignore success lines
    if ($_ =~ qr!(?: Processed)! && $_ !~ qr!:1\/!) {
      next;
    }

    # Ignore extraction lines
    elsif ($_ =~ qr!^Extract unzip -qo!) {
      next;
    }

    # Ignore but remember lines unable to process
    elsif ($_ =~ qr! Unable to process !) {
      $unable++;
      next;
    }

    # Ignore but remember offset errors in the tokenization
    elsif ($_ =~ qr! Tokenization with failing offsets !) {
      $unable_offsets++;
      next;
    }

    # Ignore but remember substring errors
    elsif ($_ =~ qr! Unable to find substring !) {
      $unable_substring++;
      next;
    }

    # Print out summary of the log
    elsif ($_ =~ qr!^Done\.$!) {
      my $str = 'Done.';
      $str .= ' [!Process: ' . $unable . ']' if $unable;
      $str .= ' [!Offsets: ' . $unable_offsets . ']' if $unable_offsets;
      $str .= ' [!Substring: ' . $unable_substring . ']' if $unable_substring;
      $unable = 0;
      $unable_substring = 0;
      $unable_offsets = 0;
      print $out_fh "## $str\n";
      next;
    }

    # Ignore Unable to process lines
    elsif ($_ =~ qr! Unable to (?:process|find substring) !) {
      next;
    }

    # Ignore substr errors
    elsif ($_ =~ qr!substr outside of string!) {
      next;
    }

    # Ignore lines with failing offsets
    elsif ($_ =~ qr!with failing offsets!) {
      next;
    }

    # WARNING: This is very environment specific for
    # the IDS korap instance
    elsif ($_ =~ qr! in \/opt\/korap!) {
      next;
    };

    # Print out everything else ...
    print $out_fh $. . ' ' . $_;
  };
};

sub DESTROY {
  my $self = shift;
  $self->{input}->close;
};

1;
