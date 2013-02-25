use 5.008001;
use strict;
use warnings;
use Test::Roo;

test first_test => sub {
    pass( "first" );
};

test second_test => sub {
    pass( "second" );
};

run_tests;

# COPYRIGHT
# vim: ts=4 sts=4 sw=4 et:
