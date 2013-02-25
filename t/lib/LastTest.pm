use 5.008001;
use strict;
use warnings;
package LastTest;
use Test::Roo::Role;

test in_role => sub {
    pass( "role" );
};

1;
