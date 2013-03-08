use Test::Roo;

use lib 't/lib';

has class => (
    is      => 'ro',
    default => sub { "Digest::MD5" },
);

with qw/MyTestRole/;
run_me;
done_testing;
