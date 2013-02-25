use 5.008001;
use strictures;

package Test::Roo;
# ABSTRACT: Composable tests with roles and Moo
# VERSION

use Test::More 0.96 import => [qw/subtest done_testing/];

our @EXPORT = qw/setup do_it teardown run_me test run_tests/;

sub import {
    my ( $class, @args ) = @_;
    my $caller = caller;
    for my $x (@EXPORT) {
        no strict 'refs';
        *{ $caller . "::$x" } = *{$x};
    }
    strictures->import; # do this for Moo, since we load Moo in eval
    eval qq{ package $caller; use Test::More; use Moo };
    die $@ if $@;
}

#--------------------------------------------------------------------------#
# functions
#--------------------------------------------------------------------------#

sub test {
    my ( $name, $code ) = @_;
    my $caller  = caller;
    my $subtest = sub {
        my $self = shift;
        subtest $name => sub { $code->($self) };
    };
    eval qq{ package $caller; after do_it => \$subtest };
    die $@ if $@;
}

# XXX take args for new?
sub run_tests {
    my @roles  = @_;
    my $caller = caller;
    for my $role (@roles) {
        eval qq{ package $caller; with '$role' };
        die $@ if $@;
    }
    my $obj = $caller->new;
    $obj->run_me;
    done_testing;
}

#--------------------------------------------------------------------------#
# methods
#--------------------------------------------------------------------------#

sub run_me {
    my ($self) = @_;
    $self->setup;
    $self->do_it;
    $self->teardown;
}

#--------------------------------------------------------------------------#
# stub methods that get modified
#--------------------------------------------------------------------------#

sub setup { }

sub teardown { }

sub do_it { }

1;

=for Pod::Coverage
setup teardown do_it

=head1 SYNOPSIS

A test file:

    # t/test.t
    use Test::Roo; # loads Moo and Test::More

    use lib 't/lib';

    has class => (
        is      => 'ro',
        default => sub { "Digest::MD5" },
    );

    run_tests(qw/MyTestRole/);

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
fatal warnings and other goodies) and L<Test::More>.  No test plan is
used.  The C<done_testing> function will be called for you automatically.

See also L<Test::Roo::Role> for test role usage.

If you have to call C<plan skip_all>, do it in the main body of your code, not
in a test or modifier.

=head2 Creating fixtures

You can create fixtures with normal Moo syntax.  You can even make them lazy
if you want:

    has fixture => (
        is => 'lazy'
    );

    sub _build_fixture { ... }

This becomes really useful with L<Test::Roo::Role>.  A role could define
the attribute and require the builder method to be provided by the
main test class.

=head2 Setup and teardown

You can add method modifiers around the C<setup> and C<teardown> methods
and these will be run before and after all tests (respectively).

    before  setup     => sub { ... };

    after   teardown  => sub { ... };

Roles may also modify these, so the order that modifiers will be called
will depend on when roles are composed.

You can even call test functions in these, for example, to confirm
that something has been set up or cleaned up.

=head2 Running tests

The simplest way to use L<Test::Roo> is to make the C<main> package in your
test file the test class and call C<run_tests> in it:

    # t/test.t
    use Test::Roo; # loads Moo and Test::More

    use lib 't/lib';

    has class => (
        is      => 'ro',
        default => sub { "Digest::MD5" },
    );

    run_tests(qw/MyTestRole/);

If you do this, however, you can't specify arguments to the test class
constructor and can only run the test class once.

Alternatively, you can create a separate package (in the test file or
in a separate C<.pm> file) and create and run the test objects yourself:

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
        my $obj = new_ok( 'MyTest', [class => $c] );
        $obj->run_me;
    }

    done_testing;

Note that, in this case, you will need to compose your own roles with C<with>
and call C<done_testing> yourself.

=head1 FUNCTIONS

=head2 test

    test $label => sub { ... };

The C<test> function adds a subtest.  The code reference will be called with
the test object as its only argument.

Tests are run in the order declared, so the order of tests from roles will
depend on when they are composed relative to other test declarations.

=head2 run_tests

    run_tests( @optional_roles  );

The C<run_tests> function composes an optional list of roles into the calling
package, creates an object without arguments, calls the C<run_me> method, and
calls C<done_testing>.

Because this is usually at the end of the test file, all attributes,
tests and method modifiers in the main test file will be set up before
roles are composed.  If this isn't what you want, use C<with> earlier
in the file and omit the role from the arguments to C<run_tests>.

Because it calls C<done_testing>, it may only be called once for a given test class.

=head1 IMPORTED METHODS

Loading L<Test::Roo> imports several subroutines into the calling
package to create required default methods.

=head2 run_me

    $obj->run_me;

This method runs the setup method (triggering modifiers), runs the tests, and
calls the teardown method (triggering modifiers).  It is called by the
C<run_tests> function, or you can call it yourself after composing
roles with C<with>.

=head2 setup, teardown, do_it

These are used to anchor method modifiers in the testing class and
should not be otherwise modified or called directly.

=cut

# vim: ts=4 sts=4 sw=4 et:
