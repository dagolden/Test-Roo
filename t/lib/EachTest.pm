package EachTest;
use Test::Roo::Role;

has counter => (
    is      => 'rw',
    lazy    => 1,
    builder => 1,
);

requires '_build_counter';

before each_test => sub {
    my $self = shift;
    $self->counter( $self->counter + 1 );
};

after each_test => sub {
    my $self = shift;
    $self->counter( $self->counter - 1 );
};

test 'positive' => sub { ok( shift->counter, "counter positive" ) };

1;
