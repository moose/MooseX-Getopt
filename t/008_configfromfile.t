use strict;
use warnings;

use Test::Requires { 'MooseX::ConfigFromFile' => '0.06' };    # skip all if not installed
use Test::More tests => 38;
use Test::Fatal;
use Path::Tiny;
use Test::NoWarnings 1.04 ':early';

{
    package App;

    use Moose;
    with 'MooseX::Getopt';
    with 'MooseX::ConfigFromFile';

    has 'config_from_override' => (
        is       => 'ro',
        isa      => 'Bool',
        default  => 0,
    );

    has 'optional_from_config' => (
        is        => 'ro',
        isa       => 'Str',
        required  => 0,
    );

    has 'required_from_config' => (
        is        => 'ro',
        isa       => 'Str',
        required  => 1,
    );

    has 'required_from_argv' => (
        is        => 'ro',
        isa       => 'Str',
        required  => 1,
    );

    sub get_config_from_file
    {
        my ( $class, $file ) = @_;

        my %config = (
            required_from_config => 'from_config_1',
            optional_from_config => 'from_config_2',
        );

        my $cpath = Path::Tiny::path('/notused/default');
        if ( $file ne $cpath ) {
            $config{config_from_override} = 1;
        }

        return \%config;
    }
}

{
    package App::DefaultConfigFile;

    use Moose;
    extends 'App';

    has '+configfile' => (
        default => Path::Tiny::path('/notused/default')->stringify,
    );
}

{
    package App::DefaultConfigFileCodeRef;

    use Moose;
    extends 'App';

    has '+configfile' => (
        default => sub { return Path::Tiny::path('/notused/default') },
    );
}

# No config specified
{
    local @ARGV = qw( --required_from_argv 1 );

    like exception { App->new_with_options },
        ($Getopt::Long::Descriptive::VERSION >= 0.091
            ? qr/Mandatory parameter 'required_from_config' missing/
            : qr/Required option missing: required_from_config/);

    {
        my $app = App::DefaultConfigFile->new_with_options;
        isa_ok( $app, 'App::DefaultConfigFile' );
        app_ok( $app );

        ok(  !$app->config_from_override,
            '... config_from_override false as expected' );

        is( $app->configfile, path('/notused/default'),
            '... configfile is /notused/default as expected' );
    }

    {
        my $app = App::DefaultConfigFileCodeRef->new_with_options;
        isa_ok( $app, 'App::DefaultConfigFileCodeRef' );
        app_ok( $app );

        ok(  !$app->config_from_override,
            '... config_from_override false as expected' );

        is( $app->configfile, path('/notused/default'),
            '... configfile is /notused/default as expected' );
    }
}

# Config specified
{
    local @ARGV = qw( --configfile /notused --required_from_argv 1 );

    {
        my $app = App->new_with_options;
        isa_ok( $app, 'App' );
        app_ok( $app );
    }

    {
        my $app = App::DefaultConfigFile->new_with_options;
        isa_ok( $app, 'App::DefaultConfigFile' );
        app_ok( $app );

        ok( $app->config_from_override,
             '... config_from_override true as expected' );

        is( $app->configfile, path('/notused'),
            '... configfile is /notused as expected' );
    }
    {
        my $app = App::DefaultConfigFileCodeRef->new_with_options;
        isa_ok( $app, 'App::DefaultConfigFileCodeRef' );
        app_ok( $app );

        ok( $app->config_from_override,
             '... config_from_override true as expected' );

        is( $app->configfile, path('/notused'),
            '... configfile is /notused as expected' );
    }
}

# Required arg not supplied from cmdline
{
    local @ARGV = qw( --configfile /notused );
    like exception { App->new_with_options },
        ($Getopt::Long::Descriptive::VERSION >= 0.091
            ? qr/Mandatory parameter 'required_from_argv' missing/
            : qr/Required option missing: required_from_argv/);
}

# Config file value overriden from cmdline
{
    local @ARGV = qw( --configfile /notused --required_from_argv 1 --required_from_config override );

    my $app = App->new_with_options;
    isa_ok( $app, 'App' );

    is( $app->required_from_config, 'override',
        '... required_from_config is override as expected' );

    is( $app->optional_from_config, 'from_config_2',
        '... optional_from_config is from_config_2 as expected' );
}

# No config file
{
    local @ARGV = qw( --required_from_argv 1 --required_from_config noconfig );

    my $app = App->new_with_options;
    isa_ok( $app, 'App' );

    is( $app->required_from_config, 'noconfig',
        '... required_from_config is noconfig as expected' );

    ok( !defined $app->optional_from_config,
        '... optional_from_config is undef as expected' );
}

{
    package BaseApp::WithConfig;
    use Moose;
    with 'MooseX::ConfigFromFile';

    sub get_config_from_file { return {}; }
}

{
    package DerivedApp::Getopt;
    use Moose;
    extends 'BaseApp::WithConfig';
    with 'MooseX::Getopt';
}

# With DerivedApp, the Getopt role was applied at a different level
# than the ConfigFromFile role
{
    ok ! exception { DerivedApp::Getopt->new_with_options }, 'Can create DerivedApp';
}

sub app_ok {
    my $app = shift;

    is( $app->required_from_config, 'from_config_1',
        '... required_from_config is from_config_1 as expected' );

    is( $app->optional_from_config, 'from_config_2',
        '... optional_from_config is from_config_2 as expected' );

    is( $app->required_from_argv, '1',
        '... required_from_argv is 1 as expected' );
}
