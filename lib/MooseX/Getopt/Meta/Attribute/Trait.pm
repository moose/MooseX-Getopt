package MooseX::Getopt::Meta::Attribute::Trait;
# ABSTRACT: Optional meta attribute trait for custom option names

our $VERSION = '0.77';

use Moose::Role;
use Moose::Util::TypeConstraints qw(subtype coerce from via as);
use namespace::autoclean;

has 'cmd_flag' => (
    is        => 'rw',
    isa       => 'Str',
    predicate => 'has_cmd_flag',
);

# This subtype is to support scalar -> arrayref coercion
#  without polluting the built-in types
my $cmd_aliases = subtype as 'ArrayRef';

coerce $cmd_aliases
    => from 'Str'
        => via { [$_] };

has 'cmd_aliases' => (
    is        => 'rw',
    isa       => $cmd_aliases,
    predicate => 'has_cmd_aliases',
    coerce    => 1,
);

# register this as a metaclass alias ...
package # stop confusing PAUSE
    Moose::Meta::Attribute::Custom::Trait::Getopt;
sub register_implementation { 'MooseX::Getopt::Meta::Attribute::Trait' }

1;

=head1 SYNOPSIS

  package App;
  use Moose;

  with 'MooseX::Getopt';

  has 'data' => (
      traits    => [ 'Getopt' ],
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

This is a custom attribute metaclass trait which can be used to
specify a the specific command line flag to use instead of the
default one which L<MooseX::Getopt> will create for you.

=method B<cmd_flag>

Changes the command-line flag to be this value, instead of the default,
which is the same as the attribute name.

=method B<cmd_aliases>

Adds more aliases for this command-line flag, useful for short options
and such.

=method B<has_cmd_flag>

=method B<has_cmd_aliases>

=cut
