#!/usr/bin/perl

use strict;
use warnings;

use Test::More 'no_plan';

BEGIN { 
    use_ok('Class::Comparable');
}


{
    package Number;
    our @ISA = ('Class::Comparable');
    sub new { bless { num => $_[1] } => $_[0] }
    
    sub compare {
        my ($left, $right, $is_reversed) = @_;
        ($left, $right) = ($right, $left) if $is_reversed;
        return $left->{num} <=> $right->{num};
    }
}
can_ok("Number", 'new');

{
    my $three = Number->new(3);
    isa_ok($three, 'Number');
    isa_ok($three, 'Class::Comparable');

    my $four = Number->new(4);
    isa_ok($four, 'Number');
    isa_ok($four, 'Class::Comparable');

    my $five = Number->new(5);    
    isa_ok($five, 'Number');
    isa_ok($five, 'Class::Comparable');    
    
    cmp_ok($three, '<',  $four,  '... three is less than four');
    cmp_ok($three, '<=', $three, '... three is less than or equal to three');
    cmp_ok($three, '<=', $four,  '... three is less than or equal to four');
    cmp_ok($three, '==', $three, '... three equals three');
    cmp_ok($three, '!=', $four,  '... three does not equal four');
    cmp_ok($three, '>=', $three, '... three is greater than or equal to three');
    cmp_ok($four,  '>=', $three, '... four is greater than or equal to three');    
    cmp_ok($four,  '>', $three,  '... four is greater than three'); 
    
    cmp_ok(($three <=> $three), '==',  0, '... three equals three');
    cmp_ok(($three <=> $four),  '==', -1, '... three less than four');
    cmp_ok(($four  <=> $three), '==',  1, '... four is greater than three');

    ok($three->equals($three), '... three equals three');    
    ok($three->notEquals($four), '... three not equal to four');  
    
    cmp_ok($three->compare($three), '==',  0, '... three equals three');
    cmp_ok($three->compare($four),  '==', -1, '... three less than four');
    cmp_ok($four->compare($three),  '==',  1, '... four is greater than three'); 
    
    ok($three->isBetween($three, $four), '... three is between three and four');    
    ok($four->isBetween($three, $five), '... four is between three and five');  
    ok($four->isBetween($three, $four), '... four is between three and four');  
    ok(!$three->isBetween($four, $five), '... three is not between four and five');  
    ok(!$five->isBetween($three, $four), '... five is not between three and four');  
           
    ok($three->isExactly($three), '... three is exactly three');
    ok(!$three->isExactly($four), '... three is not exactly four');                     
    
    ok(!$three->isExactly(), '... three is not exactly undef');                         
    ok(!$three->isExactly("Three"), '... three is not exactly "Three"');                         
    ok(!$three->isExactly([]), '... three is not exactly an array ref');                             
    ok(!$three->isExactly(bless({ num => 3}, 'NotNumber')), '... three is not exactly another object');                             

}

eval {
    Class::Comparable->compare();
};
like($@, qr/Method Not Implemented/, '... this is an abstract method');

{
    package String;
    our @ISA = ('Class::Comparable');
    use overload q|""| => sub { $_[0]->{num} };
    sub new { bless { num => $_[1] } => $_[0] }
}
can_ok("String", 'new');

{
    my $is = String->new("is");
    isa_ok($is, 'String');
    isa_ok($is, 'Class::Comparable');

    my $isnt = String->new("isnt");
    isa_ok($isnt, 'String');
    isa_ok($isnt, 'Class::Comparable');
        
    ok($is->isExactly($is), '... is is exactly is');
    ok(!$is->isExactly($isnt), '... is is not exactly isnt');                     
}
