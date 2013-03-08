use 5.008001;
use Test::Roo;

use lib 't/lib';

has fixture => (
    is => 'ro',
    default => sub { "hello world" },
);

with qw/RequiresFixture/;
run_me;
done_testing;
# COPYRIGHT
# vim: ts=4 sts=4 sw=4 et:
