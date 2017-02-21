package KorAP::XML::ForkPool;
use strict;
use warnings;
use Parallel::ForkManager;
use v5.10;
use Sys::Info;
use Sys::Info::Constants qw( :device_cpu );

# Construct a new fork pool
sub new {
  my $class = shift;
  my %param = @_;

  bless {
    jobs      => $param{jobs} // 0,
    iter      => 1,      # Current text in process
    overwrite => $param{overwrite},
    output    => $param{output},
    cache     => $param{cache}
  }, $class;
};

sub new_pool {
  my $self = shift;

  # Zero means: everything runs in the parent process
  my $pool = Parallel::ForkManager->new($self->{jobs});

  # Report per processed text
  $pool->run_on_finish(
    sub {
      my ($pid, $code) = @_;
      my $data = pop;

      print 'Convert [' . ($self->{jobs} > 0 ? "\$$pid:" : '') .
        ($self->{iter}++) . '/' . $self->{count} . ']';
      print ($code ? " $code" : '') . " $$data\n";
    }
  );

  return $pool;
};

sub process_directory {
  my $self = shift;
  my $input = shift;

  my $pool = $self->new_pool;

  print "Reading data ...\n";

  my $it = Directory::Iterator->new($input);
  my @dirs;
  my $dir;

  while (1) {
    if (!$it->is_directory && ($dir = $it->get) && $dir =~ s{/data\.xml$}{}) {
      push @dirs, $dir;
      $it->prune;
    };
    last unless $it->next;
  };

  $self->{count} = scalar @dirs;

 DIRECTORY_LOOP:
  for (my $i = 0; $i < $count; $i++) {

    unless ($self->{overwrite}) {
      my $filename = catfile(
        $output,
        get_file_name($dirs[$i]) . '.json' . ($gzip ? '.gz' : '')
      );

      if (-e $filename) {
        $iter++;
        print "Skip $filename\n";
        next;
      };
    };

    # Get the next fork
    my $pid = $pool->start and next DIRECTORY_LOOP;
    my $msg;
    $msg = write_file($dirs[$i]);
    $pool->finish(0, \$msg);
  };

  $pool->wait_all_children;

  # Delete cache file
  unlink($cache_file) if $cache_delete;
};


sub process_archive {
  my $self = shift;
  my $archive = shift;
  my @input = @_;

  unless ($archive->test_unzip) {
    print "Unzip is not installed or incompatible.\n\n";
    exit(1);
  };

  # Add further annotation archived
  $archive->attach($_) foreach @input;

  print "Start processing ...\n";

  my @dirs = $archive->list_texts;
  $self->{count} = scalar @dirs;

  # Creae new pool
  my $pool = $self->new_pool;

 ARCHIVE_LOOP:
  for (my $i = 0; $i < $count; $i++) {

    # Split path information
    my ($prefix, $corpus, $doc, $text) = $archive->split_path($dirs[$i]);

    unless ($self->{overwrite}) {

      my $filename = catfile(
        $output,
        get_file_name(
          catfile($corpus, $doc, $text)
            . '.json' . ($gzip ? '.gz' : '')
          )
      );

      if (-e $filename) {
        $iter++;
        print "Skip $filename\n";
        next;
      };
    };

    # Get the next fork
    my $pid = $pool->start and next ARCHIVE_LOOP;

    # Create temporary file
    my $temp = File::Temp->newdir;

    my $msg;

    # Extract from archive
    if ($archive->extract($dirs[$i], $temp)) {

      # Create corpus directory
      my $input = catdir("$temp", $corpus);

      # Temporary directory
      my $dir = catdir($input, $doc, $text);

      # Write file
      $msg = write_file($dir);
      $temp = undef;
      $pool->finish(0, \$msg);
    }
    else {
      $temp = undef;
      $msg = "Unable to extract " . $dirs[$i] . "\n";
      $pool->finish(1, \$msg);
    };
  };

  $pool->wait_all_children;

  # Delete cache file
  unlink($cache_file) if $cache_delete;
};


1;
