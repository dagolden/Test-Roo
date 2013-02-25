use 5.008001;
use strict;
use warnings;

package Test::Roo::Role;
# ABSTRACT: No abstract given for Test::Roo::Role
# VERSION

use Test::Roo (); # no imports!

sub import {
    my ($class, @args) = @_;
    my $caller = caller;
    {
        no strict 'refs';
        *{$caller . "::test"} = *Test::Roo::test;
    }
    eval qq{ package $caller; use Test::More; use Moo::Role };
    die $@ if $@;
}

1;

=for Pod::Coverage method_names_here

=head1 SYNOPSIS

  use Test::Roo::Role;

=head1 DESCRIPTION

This module might be cool, but you'd never know it from the lack
of documentation.

=head1 USAGE

Good luck!

=head1 SEE ALSO

Maybe other modules do related things.

=cut

# vim: ts=4 sts=4 sw=4 et:
