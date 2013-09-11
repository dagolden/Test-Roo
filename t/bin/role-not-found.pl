use 5.008001;
use Test::Roo; # should import Moo as well

use lib 't/lib';

has fixture => (
    is      => 'ro',
    default => sub { "hello world" },
);

with qw/RoleNotFoundAnywhere/;

run_me;
done_testing;
# COPYRIGHT
# vim: ts=4 sts=4 sw=4 et:
