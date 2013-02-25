use Test::Roo;

use lib 't/lib/';

test 'just fail' => sub { ok(0) };

run_tests(qw/Skipper/);
