use 5.008001;
use Test::Roo;

has fixture => (
    is      => 'ro',
    default => sub { "hello world" },
);

test try_me => sub {
    my $self = shift;
    like( $self->fixture, qr/hello world/, "saw fixture" );
};

run_me;
done_testing;
# COPYRIGHT
# vim: ts=4 sts=4 sw=4 et:
