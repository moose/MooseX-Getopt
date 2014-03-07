# NAME

MooseX::Getopt - A Moose role for processing command line options

# VERSION

version 0.62

# SYNOPSIS

    ## In your class
    package My::App;
    use Moose;

    with 'MooseX::Getopt';

    has 'out' => (is => 'rw', isa => 'Str', required => 1);
    has 'in'  => (is => 'rw', isa => 'Str', required => 1);

    # ... rest of the class here

    ## in your script
    #!/usr/bin/perl

    use My::App;

    my $app = My::App->new_with_options();
    # ... rest of the script here

    ## on the command line
    % perl my_app_script.pl -in file.input -out file.dump

# DESCRIPTION

This is a role which provides an alternate constructor for creating
objects using parameters passed in from the command line.

# METHODS

## `new_with_options (%params)`

This method will take a set of default `%params` and then collect
parameters from the command line (possibly overriding those in `%params`)
and then return a newly constructed object.

The special parameter `argv`, if specified should point to an array
reference with an array to use instead of `@ARGV`.

If ["GetOptions" in Getopt::Long](https://metacpan.org/pod/Getopt::Long#GetOptions) fails (due to invalid arguments),
`new_with_options` will throw an exception.

If [Getopt::Long::Descriptive](https://metacpan.org/pod/Getopt::Long::Descriptive) is installed and any of the following
command line parameters are passed, the program will exit with usage
information (and the option's state will be stored in the help\_flag
attribute). You can add descriptions for each option by including a
__documentation__ option for each attribute to document.

    -?
    --?
    -h
    --help
    --usage

If you have [Getopt::Long::Descriptive](https://metacpan.org/pod/Getopt::Long::Descriptive) the `usage` parameter is also passed to
`new` as the usage option.

## `ARGV`

This accessor contains a reference to a copy of the `@ARGV` array
as it originally existed at the time of `new_with_options`.

## `extra_argv`

This accessor contains an arrayref of leftover `@ARGV` elements that
[Getopt::Long](https://metacpan.org/pod/Getopt::Long) did not parse.  Note that the real `@ARGV` is left
untouched.

__Important__: By default, [Getopt::Long](https://metacpan.org/pod/Getopt::Long) will reject unrecognized _options_
(that is, options that do not correspond with attributes using the Getopt
trait). To disable this, and allow options to also be saved in `extra_argv` (for example to pass along to another class's `new_with_options`), you can either enable the
`pass_through` option of [Getopt::Long](https://metacpan.org/pod/Getopt::Long) for your class:  `use Getopt::Long
qw(:config pass_through);` or specify a value for [MooseX::Getopt::GLD](https://metacpan.org/pod/MooseX::Getopt::GLD)'s `getopt_conf` parameter.

## `usage`

This accessor contains the [Getopt::Long::Descriptive::Usage](https://metacpan.org/pod/Getopt::Long::Descriptive::Usage) object (if
[Getopt::Long::Descriptive](https://metacpan.org/pod/Getopt::Long::Descriptive) is used).

## `help_flag`

This accessor contains the boolean state of the --help, --usage and --?
options (true if any of these options were passed on the command line).

## `print_usage_text`

This method is called internally when the `help_flag` state is true.
It prints the text from the `usage` object (see above) to `stdout` and then the
program terminates normally.  You can apply a method modification (see
[Moose::Manual::MethodModifiers](https://metacpan.org/pod/Moose::Manual::MethodModifiers)) if different behaviour is desired, for
example to include additional text.

## `meta`

This returns the role meta object.

## `process_argv (%params)`

This does most of the work of `new_with_options`, analyzing the parameters
and `argv`, except for actually calling the constructor. It returns a
[MooseX::Getopt::ProcessedArgv](https://metacpan.org/pod/MooseX::Getopt::ProcessedArgv) object. `new_with_options` uses this
method internally, so modifying this method via subclasses/roles will affect
`new_with_options`.

This module attempts to DWIM as much as possible with the command line
parameters by introspecting your class's attributes. It will use the name
of your attribute as the command line option, and if there is a type
constraint defined, it will configure Getopt::Long to handle the option
accordingly.

You can use the trait [MooseX::Getopt::Meta::Attribute::Trait](https://metacpan.org/pod/MooseX::Getopt::Meta::Attribute::Trait) or the
attribute metaclass [MooseX::Getopt::Meta::Attribute](https://metacpan.org/pod/MooseX::Getopt::Meta::Attribute) to get non-default
command-line option names and aliases.

You can use the trait [MooseX::Getopt::Meta::Attribute::Trait::NoGetopt](https://metacpan.org/pod/MooseX::Getopt::Meta::Attribute::Trait::NoGetopt)
or the attribute metaclass [MooseX::Getopt::Meta::Attribute::NoGetopt](https://metacpan.org/pod/MooseX::Getopt::Meta::Attribute::NoGetopt)
to have `MooseX::Getopt` ignore your attribute in the command-line options.

By default, attributes which start with an underscore are not given
command-line argument support, unless the attribute's metaclass is set
to [MooseX::Getopt::Meta::Attribute](https://metacpan.org/pod/MooseX::Getopt::Meta::Attribute). If you don't want your accessors
to have the leading underscore in their name, you can do this:

    # for read/write attributes
    has '_foo' => (accessor => 'foo', ...);

    # or for read-only attributes
    has '_bar' => (reader => 'bar', ...);

This will mean that Getopt will not handle a --foo parameter, but your
code can still call the `foo` method.

If your class also uses a configfile-loading role based on
[MooseX::ConfigFromFile](https://metacpan.org/pod/MooseX::ConfigFromFile), such as [MooseX::SimpleConfig](https://metacpan.org/pod/MooseX::SimpleConfig),
[MooseX::Getopt](https://metacpan.org/pod/MooseX::Getopt)'s `new_with_options` will load the configfile
specified by the `--configfile` option (or the default you've
given for the configfile attribute) for you.

Options specified in multiple places follow the following
precedence order: command-line overrides configfile, which
overrides explicit new\_with\_options parameters.

## Supported Type Constraints

- _Bool_

    A _Bool_ type constraint is set up as a boolean option with
    Getopt::Long. So that this attribute description:

        has 'verbose' => (is => 'rw', isa => 'Bool');

    would translate into `verbose!` as a Getopt::Long option descriptor,
    which would enable the following command line options:

        % my_script.pl --verbose
        % my_script.pl --noverbose

- _Int_, _Float_, _Str_

    These type constraints are set up as properly typed options with
    Getopt::Long, using the `=i`, `=f` and `=s` modifiers as appropriate.

- _ArrayRef_

    An _ArrayRef_ type constraint is set up as a multiple value option
    in Getopt::Long. So that this attribute description:

        has 'include' => (
            is      => 'rw',
            isa     => 'ArrayRef',
            default => sub { [] }
        );

    would translate into `includes=s@` as a Getopt::Long option descriptor,
    which would enable the following command line options:

        % my_script.pl --include /usr/lib --include /usr/local/lib

- _HashRef_

    A _HashRef_ type constraint is set up as a hash value option
    in Getopt::Long. So that this attribute description:

        has 'define' => (
            is      => 'rw',
            isa     => 'HashRef',
            default => sub { {} }
        );

    would translate into `define=s%` as a Getopt::Long option descriptor,
    which would enable the following command line options:

        % my_script.pl --define os=linux --define vendor=debian

## Custom Type Constraints

It is possible to create custom type constraint to option spec
mappings if you need them. The process is fairly simple (but a
little verbose maybe). First you create a custom subtype, like
so:

    subtype 'ArrayOfInts'
        => as 'ArrayRef'
        => where { scalar (grep { looks_like_number($_) } @$_)  };

Then you register the mapping, like so:

    MooseX::Getopt::OptionTypeMap->add_option_type_to_map(
        'ArrayOfInts' => '=i@'
    );

Now any attribute declarations using this type constraint will
get the custom option spec. So that, this:

    has 'nums' => (
        is      => 'ro',
        isa     => 'ArrayOfInts',
        default => sub { [0] }
    );

Will translate to the following on the command line:

    % my_script.pl --nums 5 --nums 88 --nums 199

This example is fairly trivial, but more complex validations are
easily possible with a little creativity. The trick is balancing
the type constraint validations with the Getopt::Long validations.

Better examples are certainly welcome :)

## Inferred Type Constraints

If you define a custom subtype which is a subtype of one of the
standard ["Supported Type Constraints"](#supported-type-constraints) above, and do not explicitly
provide custom support as in ["Custom Type Constraints"](#custom-type-constraints) above,
MooseX::Getopt will treat it like the parent type for Getopt
purposes.

For example, if you had the same custom `ArrayOfInts` subtype
from the examples above, but did not add a new custom option
type for it to the `OptionTypeMap`, it would be treated just
like a normal `ArrayRef` type for Getopt purposes (that is,
`=s@`).

## More Customization Options

See ["Configuring Getopt::Long" in Getopt::Long](https://metacpan.org/pod/Getopt::Long#Configuring-Getopt::Long) for many other customizations you
can make to how options are parsed. Simply `use Getopt::Long qw(:config
other_options...)` in your class to set these.

# SEE ALSO

[MooseX::Getopt::Usage](https://metacpan.org/pod/MooseX::Getopt::Usage), an extension to generate man pages, with colour

# AUTHOR

Stevan Little <stevan@iinteractive.com>

# COPYRIGHT AND LICENSE

This software is copyright (c) 2007 by Infinity Interactive, Inc.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

# CONTRIBUTORS

- Brandon L Black <blblack@gmail.com>
- Chris Prather <chris@prather.org>
- Dagfinn Ilmari Mannsåker <ilmari@ilmari.org>
- Damien Krotkine <dkrotkine@weborama.com>
- Devin Austin <devin@devin-laptop.(none)>
- Drew Taylor <drew@drewtaylor.com>
- Florian Ragwitz <rafl@debian.org>
- Gordon Irving <goraxe@goraxe.me.uk>
- Hans Dieter Pearcey <hdp@weftsoar.net>
- Hinrik Örn Sigurðsson <hinrik.sig@gmail.com>
- Jesse Luehrs <doy@tozt.net>
- John Goulah <jgoulah@cpan.org>
- Jonathan Swartz <swartz@pobox.com>
- Justin Hunter <justin.d.hunter@gmail.com>
- Karen Etheridge <ether@cpan.org>
- Nelo Onyiah <nelo.onyiah@gmail.com>
- Ricardo SIGNES <rjbs@cpan.org>
- Ryan D Johnson <ryan@innerfence.com>
- Shlomi Fish <shlomif@iglu.org.il>
- Stevan Little <stevan.little@iinteractive.com>
- Todd Hepler <thepler@employees.org>
- Tomas Doran <bobtfish@bobtfish.net>
- Yuval Kogman <nothingmuch@woobling.org>
- Ævar Arnfjörð Bjarmason <avarab@gmail.com>
