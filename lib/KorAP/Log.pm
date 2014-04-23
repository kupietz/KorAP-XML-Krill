package KorAP::Log;
use Mojo::Base -base;

has 'warn'  => sub {};
has 'debug' => sub {};
has 'trace' => sub {};
has 'error' => sub {
  warn(join ' ', @_);
};

1;
