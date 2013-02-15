use strict;
use warnings FATAL => 'all';

# respect the configfile value passed into the constructor.

use Test::Requires 'MooseX::SimpleConfig';  # skip all if not installed
use Test::More tests => 3;
use Test::NoWarnings 1.04 ':early';
use Path::Tiny 0.009;

# avoid warning if all we have installed is YAML or YAML::Syck - the user will
# see this eventually when he actually uses MooseX::SimpleConfig in his own
# code
use Config::Any::YAML;
$Config::Any::YAML::NO_YAML_XS_WARNING = 1;

{
    package Foo;
    use Moose;
    with 'MooseX::Getopt', 'MooseX::SimpleConfig';

    has foo => (
        is => 'ro', isa => 'Str',
        default => 'foo default',
    );
}

{
    my $configfile = path(qw(t 112_configfile_constructor_arg.yml))->stringify;

    my $obj = Foo->new_with_options(configfile => $configfile);

    is(
        path($obj->configfile),
        $configfile,
        'configfile value is used from the constructor',
    );
    is(
        $obj->foo,
        'foo value',
        'value is read in from the config file',
    );
}

