use 5.008001;

package MyTest;
use Test::Roo;

has phrase => (
    is       => 'ro',
    required => 1,
);

has regex => (
    is      => 'ro',
    default => sub { qr/world/i },
);

test try_me => sub {
    my $self = shift;
    like( $self->phrase, $self->regex, "phrase matched regex" );
};

package main;
use strictures;
use Test::More;

my @phrases = ( 'hello world', 'goodbye world', );

for my $p (@phrases) {
    subtest $p => sub {
        my $obj = new_ok( 'MyTest', [ phrase => $p ] );
        $obj->run_me;
    };
}

done_testing;

# COPYRIGHT
# vim: ts=4 sts=4 sw=4 et:
