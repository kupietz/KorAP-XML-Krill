package KorAP::Log;
use Mojo::Base -base;
use Carp;

has 'warn'  => sub {};
has 'debug' => sub {};
has 'trace' => sub {};

has is_debug => 0;

sub error {
  shift;
  carp(join ' ', @_);
};

1;
