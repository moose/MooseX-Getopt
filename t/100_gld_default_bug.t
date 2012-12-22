use strict;
use warnings;

use Test::More tests => 6;
use Test::NoWarnings 1.04 ':early';

use Test::Requires {
    'Getopt::Long::Descriptive' => 0.01, # skip all if not installed
};

use_ok('MooseX::Getopt');

{
    package Engine::Foo;
    use Moose;

    with 'MooseX::Getopt';

    has 'nproc' => (
        traits      => ['Getopt'],
        is          => 'ro',
        isa         => 'Int',
        default     => sub { 1 },
        cmd_aliases => 'n',
    );
}

@ARGV = ();

{
    my $foo = Engine::Foo->new_with_options(nproc => 10);
    isa_ok($foo, 'Engine::Foo');

    is($foo->nproc, 10, '... got the right value (10), not the default (1)');
}

{
    my $foo = Engine::Foo->new_with_options();
    isa_ok($foo, 'Engine::Foo');

    is($foo->nproc, 1, '... got the right value (1), without GLD needing to handle defaults');
}



