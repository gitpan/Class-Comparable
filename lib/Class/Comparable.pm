
package Class::Comparable;

use strict;
use warnings;

our $VERSION = '0.01';

# NOTE:
# magnitude (<, <=, >=, >) is not the same as equality (==, !=)
# there may come a time when it makes sense to implement 
# object equality seperately from object magnitude, so we 
# define equals and notEquals methods and operators seperately,
# which will by default "do the right thing", but allow the 
# flexibility which may be needed down the road

use overload (
    '=='     => "equals",
    '!='     => "notEquals",
    '<=>'    => "compare",
    fallback => 1
    );

# we do not supply a default here since very rarely 
# would a default would not be appropriate. So unless
# this is overridden, an exception is thrown.
sub compare { die "Method Not Implemented : no comparison method specified" }

# equals is implemented in terms of compare
sub equals {
	my ($left, $right) = @_;
	return ($left->compare($right) == 0);
}

# notEquals is implemented in terms of equals
sub notEquals {
	my ($left, $right) = @_;
	return !$left->equals($right);
}

# isBetween is implemented in terms of compare
sub isBetween {
	my ($self, $left, $right) = @_;
    # greater than or equal to the left value
    # and less than or equal to the right value
    return (($self->compare($left) >= 0) && ($self->compare($right) <= 0));    
}

# this method attempts to decide if an object
# is exactly the same as one another. It does
# this by comparing the Perl built-in string 
# representations of a reference and displays
# the object's memory address. 
sub isExactly {
	my ($left, $right) = @_;
    # if nothing is passed, then it cannot be 
    # the same thing, we choose to return false
    # here rather than die so it works when a
    # null pointer is passed.
	return 0 unless defined($right);
	# we check to see if we are dealing with the same 
	# types objects by calling ref, which will return
	# the top level class of the object. If they do 
	# not share that in common, they are certainly not
	# the same object.
	return 0 unless ref($left) eq ref($right);
	# from now on this gets a little trickier...
	# First we need to test if the objects overloads
	# the stringification operator, in which case
	# we need to extract the string value. We can get
	# away with just checking the overloading on the
	# left argument, since our test above has already
	# told us they are the same class.
	return (overload::StrVal($left) eq overload::StrVal($right)) if overload::Method($left, '""');
	# if the object does not overload the stringification 
	# operator, then that means that we can use the built 
	# in Perl stringification routine then. If these strings 
	# match then the memory address will match as well, and 
	# we will know we have the exact same object.
	return ("$left" eq "$right");
}

1;

__END__

=head1 NAME

Class::Comparable - A base class for Comparable objects

=head1 SYNOPSIS

  package MyObject;
  our @ISA = ('Class::Comparable');

  # define your object as normal

  # make sure to add a compare routine
  # to be able to use all the features
  # of Class::Comparable (see below)
  sub compare {
    my ($left, $right, $is_reversed) = @_;
    # check for any reversals
    ($left, $right) = ($right, $left) if $is_reversed;
    # and then compare them
    return $left->{some_value} <=> $right->{some_value};
  }

=head1 DESCRIPTION

=head1 METHODS

=over 4

=item B<compare ($compareTo, $is_reversed)>

This method is abstract, and will throw an exception unless it is properly overridden by the class which implements Class::Comparable. 

At it's simplest, this method is expected to return 1 if the invocant is greater than C<$compareTo>, 0 if they are equal to one another and -1 if the invocant is less than C<$compareTo>. However, if the C<$is_reversed> argument is set to true (C<1>) then the order of the invocant and C<$compareTo> are reversed and should be compared appropriately (see the L<overload> docs for an explanation).

=item B<equals ($compareTo)>

Returns true (C<1>) if the invocant is equal to the C<$compareTo> argument (as determined by C<compare>) and return false (C<0>) otherwise.

=item B<notEquals ($compareTo)>

Returns true (C<1>) if the invocant is not equal to the C<$compareTo> argument (as determined by C<equals>) and return false (C<0>) otherwise.

=item B<isBetween ($left, $right)>

Returns true (C<1>) if the invocant is greater than or equal to C<$left> and less than or equal to C<$right> (as determined by C<compare>) and return false (C<0>) otherwise. This method does not enforce the fact that C<$left> should be less than C<$right> so that it can allow for C<compare> to accept non-standard values. 

=item B<isExactly ($compareTo)>

Returns true (C<1>) if the invocant is exactly the same instance as C<$compareTo> and return false (C<0>) otherwise. This method will correctly handle objects who overload the C<""> (stringification) operator.

=back

=head1 OPERATORS

=over 4

=item B<==>

This operator is implemented by the C<equals> method.

=item B<!=>

This operator is implemented by the C<notEquals> method.

=item B<E<lt>=E<gt>>

This operator is implemented by the C<compare> method. It should be noted that perl will auto-generate the means to handle the E<lt>, E<lt>=, E<gt>= and E<gt> operators as well (see the L<overload> docs for more information about auto-generation).

=back

=head1 BUGS

None that I am aware of. Of course, if you find a bug, let me know, and I will be sure to fix it. 

=head1 CODE COVERAGE

I use B<Devel::Cover> to test the code coverage of my tests, below is the B<Devel::Cover> report on this module test suite.

 ------------------------ ------ ------ ------ ------ ------ ------ ------
 File                       stmt branch   cond    sub    pod   time  total
 ------------------------ ------ ------ ------ ------ ------ ------ ------
 Class/Comparable.pm       100.0  100.0  100.0  100.0  100.0  100.0  100.0
 ------------------------ ------ ------ ------ ------ ------ ------ ------
 Total                     100.0  100.0  100.0  100.0  100.0  100.0  100.0
 ------------------------ ------ ------ ------ ------ ------ ------ ------

=head1 SEE ALSO

There are a number of comparison modules out there (search for 'Compare' at http://search.cpan.org), which can be used in conjunction with this module to help implement the C<compare> method for your class. 

=head1 AUTHOR

stevan little, E<lt>stevan@iinteractive.comE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright 2004 by Infinity Interactive, Inc.

L<http://www.iinteractive.com>

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself. 

=cut

