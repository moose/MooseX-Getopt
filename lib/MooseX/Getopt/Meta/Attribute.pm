package MooseX::Getopt::Meta::Attribute;
# ABSTRACT: Optional meta attribute for custom option names

our $VERSION = '0.76';

use Moose;
use namespace::autoclean;

extends 'Moose::Meta::Attribute'; # << Moose extending Moose :)
   with 'MooseX::Getopt::Meta::Attribute::Trait';

# register this as a metaclass alias ...
package # stop confusing PAUSE
    Moose::Meta::Attribute::Custom::Getopt;
sub register_implementation { 'MooseX::Getopt::Meta::Attribute' }

1;

=head1 SYNOPSIS

  package App;
  use Moose;

  with 'MooseX::Getopt';

  has 'data' => (
      metaclass => 'Getopt',
      is        => 'ro',
      isa       => 'Str',
      default   => 'file.dat',

      # tells MooseX::Getopt to use --somedata as the
      # command line flag instead of the normal
      # autogenerated one (--data)
      cmd_flag  => 'somedata',

      # tells MooseX::Getopt to also allow --moosedata,
      # -m, and -d as aliases for this same option on
      # the commandline.
      cmd_aliases => [qw/ moosedata m d /],

      # Or, you can use a plain scalar for a single alias:
      cmd_aliases => 'm',
  );

=head1 DESCRIPTION

This is a custom attribute metaclass which can be used to specify a
the specific command line flag to use instead of the default one
which L<MooseX::Getopt> will create for you.

This is certainly not the prettiest way to go about this, but for
now it works for those who might need such a feature.

=head2 Use 'traits' instead of 'metaclass'

You should rarely need to explicitly set the attribute metaclass. It is much
preferred to simply provide a trait (a role applied to the attribute
metaclass), which allows other code to further modify the attribute by applying
additional roles.

Therefore, you should first try to do this:

  has 'foo' => (traits => ['Getopt'], cmd_flag => 'f');

=head2 Custom Metaclass alias

This now takes advantage of the Moose 0.19 feature to support
custom attribute metaclass aliases. This means you can also
use this as the B<Getopt> alias, like so:

  has 'foo' => (metaclass => 'Getopt', cmd_flag => 'f');

=method B<cmd_flag>

Changes the command-line flag to be this value, instead of the default,
which is the same as the attribute name.

=method B<cmd_aliases>

Adds more aliases for this command-line flag, useful for short options
and such.

=method B<has_cmd_flag>

=method B<has_cmd_aliases>

=cut
