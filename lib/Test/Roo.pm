use 5.008001;
use strict;
use warnings;

package Test::Roo;
# ABSTRACT: Composable tests with roles and Moo
# VERSION

use Test::More 0.96 import => [qw/subtest done_testing/];

our @EXPORT = qw/setup do_it teardown test run_tests/;

sub import {
    my ($class, @args) = @_;
    my $caller = caller;
    for my $x (@EXPORT) {
        no strict 'refs';
        *{$caller . "::$x"} = *{$x};
    }
    eval qq{ package $caller; use Test::More; use Moo };
    die $@ if $@;
}

#--------------------------------------------------------------------------#
# functions
#--------------------------------------------------------------------------#

sub test {
    my ($name, $code) = @_;
    my $caller = caller;
    my $subtest = sub {
        my $self = shift;
        subtest $name => sub { $code->($self) };
    };
    eval qq{ package $caller; after do_it => \$subtest };
    die $@ if $@;
}

# XXX take args for new?
sub run_tests {
    my @roles = @_;
    my $caller = caller;
    for my $role ( @roles ) {
        eval qq{ package $caller; with '$role' };
        die $@ if $@;
    }
    my $obj = $caller->new;
    $obj->setup;
    $obj->do_it;
    $obj->teardown;
    done_testing;
}

#--------------------------------------------------------------------------#
# stub methods that get modified
#--------------------------------------------------------------------------#

sub setup {}

sub teardown {}

sub do_it {}

1;

=for Pod::Coverage method_names_here

=head1 SYNOPSIS

  use Test::Roo;

=head1 DESCRIPTION

This module might be cool, but you'd never know it from the lack
of documentation.

=head1 USAGE

Good luck!

=head1 SEE ALSO

Maybe other modules do related things.

=cut

# vim: ts=4 sts=4 sw=4 et:
