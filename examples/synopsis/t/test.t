use Test::Roo;

use lib 't/lib';

has class => (
    is      => 'ro',
    default => sub { "Digest::MD5" },
);

run_tests(qw/MyTestRole/);
