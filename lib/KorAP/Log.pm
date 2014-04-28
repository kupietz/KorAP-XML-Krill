package KorAP::Log;
use Mojo::Base -base;
use Carp;

has 'warn'  => sub {};
has 'debug' => sub {};
has 'trace' => sub {};

sub error {
  shift;
  carp(join ' ', @_);
};

1;
