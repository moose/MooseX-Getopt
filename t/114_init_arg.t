use strict;
use warnings;

use Test::More 0.88;
use if $ENV{AUTHOR_TESTING}, 'Test::Warnings';

{
    package Test1;
    use Moose;
    with 'MooseX::Getopt';

    has foo => ( is => 'ro', isa => 'Str', init_arg => 'big' );
};

{
    my $obj = Test1->new_with_options( argv => [ '--big', 'lebowski' ] );
    is( $obj->foo, 'lebowski', 'init_arg is respected' );
}

done_testing;
