use 5.008001;
use strictures;

package Test::Roo::Cookbook;
# ABSTRACT: Test::Roo examples
# VERSION

1;

=for Pod::Coverage method_names_here

=head1 DESCRIPTION

This file offers usage ideas and examples for L<Test::Roo>.

=head1 ORGANIZING TEST CLASSES AND ROLES

=head2 Self-contained test file

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

=head2 Standalone test class

You don't have to put the test class into the F<.t> file.  It's just a class.

Here is the same corpus checking example as before, but now as a class:

    # examples/cookbook/lib/CorpusCheck.pm
    package CorpusCheck;
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

    1;

Running it from a F<.t> file doesn't even need L<Test::Roo>:

    # examples/cookbook/standalone.t

    use strictures;
    use Test::More;

    use lib 'lib';
    use CorpusCheck;

    CorpusCheck->run_tests({ corpus => "/usr/share/dict/words" });

    done_testing;

=head2 Standalone Test Roles

The real power of L<Test::Roo> is decomposing test behaviors into
roles that can be reused.

Imagine we want to test a file-finder module like L<Path::Iterator::Rule>.
We could put tests for it into a role, then run the tests from a file that composes
that role.  For example, here would be the test file:

    # examples/cookbook/test-pir.pl

    use Test::Roo;

    use lib 'lib';

    with 'IteratorTest';

    run_me(
        {
            iterator_class => 'Path::Iterator::Rule',
            result_type    => '',
        }
    );

    done_testing;

Then in the distribution for L<Path::Class::Rule>, the same role
could be tested with a test file like this:

    # examples/cookbook/test-pcr.pl
    
    use Test::Roo;

    use lib 'lib';

    with 'IteratorTest';

    run_me(
        {
            iterator_class => 'Path::Class::Rule',
            result_type    => 'Path::Class::Entity',
        },
    );

    done_testing;

What is the common role that they are consuming?  It sets up a test
directory, creates files and runs tests:

    # examples/cookbook/lib/IteratorTest.pm

    package IteratorTest;
    use Test::Roo::Role;

    use MooX::Types::MooseLike::Base qw/:all/;
    use Class::Load qw/load_class/;
    use Path::Tiny;

    has [qw/iterator_class result_type/] => (
        is       => 'ro',
        isa      => Str,
        required => 1,
    );

    has test_files => (
        is      => 'ro',
        isa     => ArrayRef,
        default => sub {
            return [
                qw(
                aaaa
                bbbb
                cccc/dddd
                eeee/ffff/gggg
                )
            ];
        },
    );

    has tempdir => (
        is  => 'lazy',
        isa => InstanceOf ['Path::Tiny']
    );

    has rule_object => (
        is      => 'lazy',
        isa     => Object,
        clearer => 1,
    );

    sub _build_description { return shift->iterator_class }

    sub _build_tempdir {
        my ($self) = @_;
        my $dir = Path::Tiny->tempdir;
        $dir->child($_)->touchpath for @{ $self->test_files };
        return $dir;
    }

    sub _build_rule_object {
        my ($self) = @_;
        load_class( $self->iterator_class );
        return $self->iterator_class->new;
    }

    sub test_result_type {
        my ( $self, $file ) = @_;
        if ( my $type = $self->result_type ) {
            isa_ok( $file, $type, $file );
        }
        else {
            is( ref($file), '', "$file is string" );
        }
    }

    test 'find files' => sub {
        my $self = shift;
        $self->clear_rule_object; # make sure have a new one each time

        $self->tempdir;
        my $rule = $self->rule_object;
        my @files = $rule->file->all( $self->tempdir, { relative => 1 } );

        is_deeply( \@files, $self->test_files, "correct list of files" )
        or diag explain \@files;

        $self->test_result_type($_) for @files;
    };

    # ... more tests ...

    1;

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
