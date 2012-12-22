use strict;
use warnings;

use Test::More tests => 6;
use Test::NoWarnings 1.04 ':early';

use Test::Requires {
    'Getopt::Long::Descriptive' => 0.01, # skip all if not installed
};

use_ok('MooseX::Getopt::GLD');

{
    package Engine::Foo;
    use Moose;

    with 'MooseX::Getopt::GLD' => { getopt_conf => [ 'pass_through' ] };

    has 'foo' => (
        metaclass   => 'Getopt',
        is          => 'ro',
        isa         => 'Int',
    );
}

{
    package Engine::Bar;
    use Moose;

    with 'MooseX::Getopt::GLD' => { getopt_conf => [ 'pass_through' ] };;

    has 'bar' => (
        metaclass   => 'Getopt',
        is          => 'ro',
        isa         => 'Int',
    );
}

local @ARGV = ('--foo=10', '--bar=42');

{
    my $foo = Engine::Foo->new_with_options();
    isa_ok($foo, 'Engine::Foo');
    is($foo->foo, 10, '... got the right value (10)');
}

{
    my $bar = Engine::Bar->new_with_options();
    isa_ok($bar, 'Engine::Bar');
    is($bar->bar, 42, '... got the right value (42)');
}



