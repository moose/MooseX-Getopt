use strict;
use warnings;

use Test::More tests => 6;
use Test::Trap;
use Test::NoWarnings 1.04 ':early';

{
    package MyScript;
    use Moose;

    with 'MooseX::Getopt';

    has foo => ( isa => 'Int', is => 'ro', documentation => 'A foo' );
}

# FIXME - it looks like we have a spacing issue in Getopt::Long?
my $usage = <<USAGE;
usage: 104_override_usage.t [-?h] [long options...]
\t-h -? --usage --help  Prints this usage information.
\t--foo                A foo
USAGE

{
    local @ARGV = ('--foo', '1');
    my $i = trap { MyScript->new_with_options };
    is($i->foo, 1, 'attr is set');
    is($trap->stdout, '', 'nothing printed when option is accepted');
}

{
    local @ARGV = ('--help');
    trap { MyScript->new_with_options };
    is($trap->stdout, $usage, 'usage is printed on --help');
}

{
    local @ARGV = ('-q'); # Does not exist
    trap { MyScript->new_with_options };
    is($trap->die, join("\n", 'Unknown option: q', $usage), 'usage is printed on unknown option');
}

{
    Class::MOP::class_of('MyScript')->add_before_method_modifier(
        print_usage_text => sub {
            print "--- DOCUMENTATION ---\n";
        },
    );

    local @ARGV = ('--help');
    trap { MyScript->new_with_options };
    is(
        $trap->stdout,
        join("\n", '--- DOCUMENTATION ---', $usage),
        'additional text included before normal usage string',
    );
}

