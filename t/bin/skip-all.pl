use Test::Roo;

plan skip_all => "We just want to skip";

test 'just fail' => sub { ok(0) };

run_tests;
