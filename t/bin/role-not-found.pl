use 5.008001;
use strict;
use warnings;
use Test::Roo; # should import Moo as well

use lib 't/lib';

has fixture => (
    is => 'ro',
    default => sub { "hello world" },
);

run_tests( qw/RoleNotFoundAnywhere/ );
# COPYRIGHT
# vim: ts=4 sts=4 sw=4 et:
