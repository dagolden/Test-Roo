use 5.008001;
use strictures;

package Test::Roo;
# ABSTRACT: Composable tests with roles and Moo
# VERSION

our @EXPORT = qw/test run_me/;

sub import {
    my ( $class, @args ) = @_;
    my $caller = caller;
    for my $x (@EXPORT) {
        no strict 'refs';
        *{ $caller . "::$x" } = *{$x};
    }
    strictures->import; # do this for Moo, since we load Moo in eval
    eval qq{
        package $caller;
        use Moo;
        extends 'Test::Roo::Class'
    };
    if ( @args ) {
        eval qq{ package $caller; use Test::More \@args };
    }
    else {
        eval qq{ package $caller; use Test::More };
    };
    die $@ if $@;
}

sub test {
    my ( $name, $code ) = @_;
    my $caller = caller;
    my $subtest = sub { shift->each_test( $name, $code ) };
    eval qq{ package $caller; after _do_tests => \$subtest };
    die $@ if $@;
}

sub run_me {
    my $class = caller;
    $class->run_tests(@_);
}

1;

=for Pod::Coverage add_methods_here

=head1 SYNOPSIS

A test file:

    # t/test.t
    use Test::Roo; # loads Moo and Test::More

    use lib 't/lib';

    has class => (
        is      => 'ro',
        default => sub { "Digest::MD5" },
    );

    with 'MyTestRole';

    run_me;
    done_testing;

A testing role:

    # t/lib/MyTestRole.pm
    package MyTestRole;
    use Test::Roo::Role; # loads Moo::Role and Test::More

    requires 'class';

    test 'object creation' => sub {
        my $self = shift;
        require_ok( $self->class );
        my $obj  = new_ok( $self->class );
    };

    1;

=head1 DESCRIPTION

This module allows you to compose L<Test::More> tests from roles.  It is
inspired by the excellent L<Test::Routine> module, but uses L<Moo> instead of
L<Moose>.  This gives most of the benefits without the need for L<Moose> as a
test dependency.

Test files are Moo classes.  You can define any needed test fixtures as Moo
attributes.  You define tests as method modifiers -- similar in concept to
C<subtest> in L<Test::More>, but your test method will be passed the test
object for access to fixture attributes.  You may compose any L<Moo::Role> into
your test to define attributes, require particular methods, or define tests.

This means that you can isolate test I<behaviors> into roles which require
certain test I<fixtures> in order to run.  Your main test file will provide the
fixtures and compose the roles to run.  This makes it easy to reuse test
behaviors.

For example, if you are creating tests for Awesome::Module, you could create
the test behaviors as Awesome::Module::Test::Role and distribute it with
your module.  If another distribution subclasses Awesome::Module, it can
compose the Awesome::Module::Test::Role behavior for its own tests.

No more copying and pasting tests from a super class!  Superclasses define and
share their tests.  Subclasses provide their own fixtures and run the tests.

=head1 USAGE

Importing L<Test::Roo> also loads L<Moo> (which gives you L<strictures> with
fatal warnings and other goodies) and makes the current package a subclass
of L<Test::Roo::Class>.

Importing also loads L<Test::More>.  No test plan is used.  The C<done_testing>
function must be used at the end of every test file.  Any import arguments are
passed through to Test::More's C<import> method.

See also L<Test::Roo::Role> for test role usage.

=head2 Creating fixtures

You can create fixtures with normal Moo syntax.  You can even make them lazy if
you want:

    has fixture => (
        is => 'lazy'
    );

    sub _build_fixture { ... }

This becomes really useful with L<Test::Roo::Role>.  A role could define the
attribute and require the builder method to be provided by the main test class.

=head2 Composing test roles

You can use roles to define units of test behavior and then compose them into
your test class using the C<with> function.  Test roles may define attributes,
declare tests, require certain methods and anything else you can regularly do
with roles.

    use Test::Roo;

    with 'MyTestRole1', 'MyTestRole2';

See L<Test::Roo::Role> and the L<Test::Roo::Cookbook> for details and
examples.

=head2 Setup and teardown

You can add method modifiers around the C<setup> and C<teardown> methods and
these will be run before tests begin and after tests finish (respectively).

    before  setup     => sub { ... };

    after   teardown  => sub { ... };

You can also add method modifiers around C<each_test>, which will be
run before and after B<every> individual test.  You could use these to
prepare or reset a fixture.

    has fixture => ( is => 'lazy, clearer => 1, predicate => 1 );

    after  each_test => sub { shift->clear_fixture };

Roles may also modify C<setup>, C<teardown>, and C<each_test>, so the order
that modifiers will be called will depend on when roles are composed.  Be
careful with C<each_test>, though, because the global effect may make
composition more fragile.

You can call test functions in modifiers. For example, you could
confirm that something has been set up or cleaned up.

    before each_test => sub { ok( ! shift->has_fixture ) };

=head2 Running tests

The simplest way to use L<Test::Roo> with a single F<.t> file is to let the
C<main> package be the test class and call C<run_me> in it:

    # t/test.t
    use Test::Roo; # loads Moo and Test::More

    has class => (
        is      => 'ro',
        default => sub { "Digest::MD5" },
    );

    test 'load class' => sub {
        my $self = shift;
        require_ok( $self->class );
    }

    run_me;
    done_testing;

Calling C<< run_me(@args) >> is equivalent to calling
C<< __PACKAGE__->run_tests(@args) >> and runs tests for the current package.

You may specify an optional description or hash reference of constructor
arguments to customize the test object:

    run_me( "load MD5" );
    run_me( { class => "Digest::MD5" } );
    run_me( "load MD5", { class => "Digest::MD5" } );

See L<Test::Roo::Class> for more about the C<run_tests> method.

Alternatively, you can create a separate package (in the test file or in a
separate F<.pm> file) and run tests explicitly on that class.

    # t/test.t
    package MyTest;
    use Test::Roo;

    use lib 't/lib';

    has class => (
        is       => 'ro',
        required => 1,
    );

    with 'MyTestRole';

    package main;
    use strictures;
    use Test::More;

    for my $c ( qw/Digest::MD5 Digest::SHA/ ) {
        MyTest->run_tests("Testing $c", { class => $c } );
    }

    done_testing;

=head1 EXPORTED FUNCTIONS

Loading L<Test::Roo> exports subroutines into the calling package to declare
and run tests.

=head2 test

    test $label => sub { ... };

The C<test> function adds a subtest.  The code reference will be called with
the test object as its only argument.

Tests are run in the order declared, so the order of tests from roles will
depend on when they are composed relative to other test declarations.

=head2 run_me

    run_me;
    run_me( $description );
    run_me( $init_args   );
    run_me( $description, $init_args );

The C<run_me> function calls the C<run_tests> method on the current package
and passes all arguments to that method.  It takes a description and/or
a hash reference of constructor arguments.

=cut

# vim: ts=4 sts=4 sw=4 et:
