use 5.008001;
use Test::More 0.96;
use Capture::Tiny qw/capture/;

use lib 't/lib';

my @cases = (
    {
        label  => "main tests",
        file   => "t/bin/main-order.pl",
        expect => qr/first_test.*?second_test/ms,
    },
    {
        label  => "role vs main",
        file   => "t/bin/role-last.pl",
        expect => qr/in_main.*?in_role/ms,
    },
    {
        label  => "force role first",
        file   => "t/bin/custom-order.pl",
        expect => qr/in_role.*?in_main/ms,
    },
);

for my $c (@cases) {
    my ( $output, $error, $rc ) = capture { system( $^X, $c->{file} ) };
    subtest $c->{label} => sub {
        ok( !$rc, "zero exit" );
        like( $output, $c->{expect}, "expected text" );
    };
}

done_testing;
# COPYRIGHT
# vim: ts=4 sts=4 sw=4 et:
