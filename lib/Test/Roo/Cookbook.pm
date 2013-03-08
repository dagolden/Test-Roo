use 5.008001;
use strictures;

package Test::Roo::Cookbook;
# ABSTRACT: Test::Roo examples
# VERSION

1;

=for Pod::Coverage method_names_here

=head1 DESCRIPTION

This file offers usage ideas and examples for L<Test::Roo>.

=head1 SELF-CONTAINED TEST FILE

A single test file could be used for simple tests where you want to
use Moo attributes for fixtures that get used by test blocks.

Here is an example that requires a C<corpus> attribute, stores
lines from that file in the C<lines> attribute and makes it
available to all test blocks:

    # examples/cookbook/single_file.t

    use Test::Roo;

    use MooX::Types::MooseLike::Base qw/ArrayRef/;
    use Path::Tiny;

    has corpus => (
        is       => 'ro',
        isa      => sub { -f shift },
        required => 1,
    );

    has lines => (
        is  => 'lazy',
        isa => ArrayRef,
    );

    sub _build_lines {
        my ($self) = @_;
        return [ map { lc } path( $self->corpus )->lines ];
    }

    test 'sorted' => sub {
        my $self = shift;
        is_deeply( $self->lines, [ sort @{$self->lines} ], "alphabetized");
    };

    test 'a to z' => sub {
        my $self = shift;
        my %letters = map { substr($_,0,1) => 1 } @{ $self->lines };
        is_deeply( [sort keys %letters], ["a" .. "z"], "all letters found" );
    };


    run_me( { corpus => "/usr/share/dict/words" } );
    # ... test other corpuses ...

    done_testing;

=head1 STANDALONE TEST CLASS

...

=head1 STANDALONE TEST ROLES

...

=head1 PARAMETERIZED TESTS

...

=head1 MANAGING FIXTURES

...

=head1 MODIFIERS FOR SETUP AND TEARDOWN

...

=head1 MODIFIERS ON TESTS

=head2 Global modifiers with C<each_test>

Modifying C<each_test> triggers methods before or after B<every> test block
defined with the C<test> function.  Because this affects all tests, whether
from the test class or composed from roles, it needs to be used thoughtfully.

Here is an example that ensures that all tests are run in their own separate
temporary directory.

    # examples/cookbook/with_tempd.t
    use Test::Roo;
    use File::pushd qw/tempd/;
    use Cwd qw/getcwd/;

    has tempdir => (
        is => 'lazy',
        isa => sub { shift->isa('File::pushd') },
        clearer => 1,
    );

    # tempd changes directory until the object is destroyed
    # and the fixture caches the object until cleared
    sub _build_tempdir { return tempd() }

    # building attribute will change to temp directory
    before each_test => sub { shift->tempdir };

    # clearing attribute will change to original directory
    after each_test => sub { shift->clear_tempdir };

    # do stuff in a temp directory
    test 'first test' => sub {
        my $self = shift;
        is( $self->tempdir, getcwd(), "cwd is " . $self->tempdir );
        # ... more tests ...
    };

    # do stuff in a separate, fresh temp directory
    test 'second test' => sub {
        my $self = shift;
        is( $self->tempdir, getcwd(), "cwd is " . $self->tempdir );
        # ... more tests ...
    };

    run_me;
    done_testing;

=head2 Individual teat modifiers

If you want to have method modifiers on an individual test, put your
L<Test::More> tests in a method, add modifiers to that method, and use C<test>
to invoke it.

    # examples/cookbook/hookable_test.t
    use Test::Roo;

    has counter => ( is => 'rw', default => sub { 0 } );

    sub is_positive {
        my $self = shift;
        ok( $self->counter > 0, "counter is positive" );
    }

    before is_positive => sub { shift->counter( 1 ) };

    test 'hookable' => sub { shift->is_positive };

    run_me;
    done_testing;

=cut

# vim: ts=4 sts=4 sw=4 et:
