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

...

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

...

=head2 Individual teat modifiers

If you want to have method modifiers on an individual test, put your
L<Test::More> tests in a method, add modifiers to that method, and use C<test>
to invoke it.

    use Test::Roo;

    has counter => ( is => 'rw', default => sub { 0 } );

    sub is_positive {
        my $self = shift;
        ok( $self->counter > 0, "counter is positive" );
    }

    before is_positive => sub { shift->counter( 1 ) };

    test 'hookable' => sub { shift->is_positive };

    run_tests;

=cut

# vim: ts=4 sts=4 sw=4 et:
