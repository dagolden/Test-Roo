use 5.008001;
use strictures;

package Test::Roo::Class;
# ABSTRACT: Base class for Test::Roo test classes
# VERSION

use Moo;
use Test::More 0.96 import => [qw/subtest/];

#--------------------------------------------------------------------------#
# class methods
#--------------------------------------------------------------------------#

sub run_once {
    my ($class, @args) = @_;
    my $obj = $class->new( @args );
    $obj->_start;
}

#--------------------------------------------------------------------------#
# object methods
#--------------------------------------------------------------------------#

sub each_test {
    my ($self, $name, $code) = @_;
    subtest $name => sub { $code->($self) };
}

sub _start {
    my ($self) = @_;
    $self->setup;
    $self->_do_tests;
    $self->teardown;
}

#--------------------------------------------------------------------------#
# stub methods that get modified
#--------------------------------------------------------------------------#

sub setup { }

sub _do_tests { }

sub teardown { }

1;

=for Pod::Coverage method_names_here

=head1 SYNOPSIS

  use Test::Roo::Class;

=head1 DESCRIPTION

This module might be cool, but you'd never know it from the lack
of documentation.

=head1 USAGE

Good luck!

=head1 SEE ALSO

Maybe other modules do related things.

=cut

# vim: ts=4 sts=4 sw=4 et:
