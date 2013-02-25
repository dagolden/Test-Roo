use 5.008001;
use Test::Roo;

use lib 't/lib';

has fixture => (
    is => 'ro',
    default => sub { "hello world" },
);

run_tests( qw/RequiresFixture/ );
# COPYRIGHT
# vim: ts=4 sts=4 sw=4 et:
