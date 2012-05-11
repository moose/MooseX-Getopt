use strict;
use warnings;

use Test::Requires
    'MooseX::SimpleConfig'; # skip all if not installed

# respect the configfile value passed into the constructor.

use Test::More tests => 2;

{
    package Foo;
    use Moose;
    with 'MooseX::Getopt', 'MooseX::SimpleConfig';

    has foo => (
        is => 'ro', isa => 'Str',
        default => 'foo default',
    );
}

TODO:
{
    local $TODO = "doh, this doesn't work!";

    my $configfile = 't/112_configfile_constructor_arg.yml';

    my $obj = Foo->new_with_options(configfile => $configfile);

    is(
        $obj->configfile,
        $configfile,
        'configfile value is used from the constructor',
    );
    is(
        $obj->foo,
        'foo value',
        'value is read in from the config file',
    );
}

