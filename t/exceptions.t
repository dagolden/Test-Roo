use 5.008001;
use Test::More 0.96;
use Capture::Tiny qw/capture/;

use lib 't/lib';

my @cases = (
    {
        label => "missing role",
        file => "t/bin/role-not-found.pl",
        expect => qr/Can't \S+ RoleNotFoundAnywhere\.pm in \@INC/,
    },
    {
        label => "requires not satisfied",
        file => "t/bin/unsatisfied.pl",
        expect => qr/Can't apply RequiresFixture to main/,
    },
    {
        label => "Test::Roo loads strictures",
        file => "t/bin/not-strict.pl",
        expect => qr/requires explicit package name/,
    },
);

for my $c (@cases) {
    my ($output, $error, $rc) = capture {  system($^X, $c->{file}) };
    subtest $c->{label} => sub {
        ok( $rc, "non-zero exit" );
        like( $error, $c->{expect}, "exception text" );
    };
}

done_testing;
# COPYRIGHT
# vim: ts=4 sts=4 sw=4 et:
