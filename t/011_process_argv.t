use strict;
use warnings;

use Test::More;
use Test::Fatal 0.003;

if ( !eval { require Test::Deep } )
{
    plan skip_all => 'Test requires Test::Deep';
    exit;
}
else
{
    plan tests => 6;
}

{
    package Testing::Foo;
    use Moose;

    with 'MooseX::Getopt';

    has 'bar' => (
        is       => 'ro',
        isa      => 'Int',
        required => 1,
    );

    has 'baz' => (
        is       => 'ro',
        isa      => 'Int',
        required => 1,
    );
}

@ARGV = qw(--bar 10 file.dat);

my $pa;
is(
    exception {
        $pa = Testing::Foo->process_argv(baz => 100);
    },
    undef,
    '... this should work'
);
isa_ok($pa, 'MooseX::Getopt::ProcessedArgv');

Test::Deep::cmp_deeply($pa->argv_copy, [
    '--bar',
    '10',
    'file.dat'
], 'argv_copy');
Test::Deep::cmp_deeply($pa->cli_params, {
    'bar' => 10
}, 'cli_params');
Test::Deep::cmp_deeply($pa->constructor_params, {
    'baz' => 100
}, 'constructor_params');
Test::Deep::cmp_deeply($pa->extra_argv, [
    'file.dat'
], 'extra_argv');
