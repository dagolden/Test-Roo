use 5.008001;
use strict;
use warnings;
use Test::Roo;

use lib 't/lib';

with 'LastTest';

test in_main => sub {
    pass( "main" );
};

run_tests;

# COPYRIGHT
# vim: ts=4 sts=4 sw=4 et:
