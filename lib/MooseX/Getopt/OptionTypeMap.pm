package MooseX::Getopt::OptionTypeMap;
# ABSTRACT: Storage for the option to type mappings

our $VERSION = '0.69';

use Moose;
use Carp 'confess';
use Scalar::Util 'blessed';
use Moose::Util::TypeConstraints 'find_type_constraint';
use namespace::autoclean;

my %option_type_map = (
    'Bool'     => '!',
    'Str'      => '=s',
    'Int'      => '=i',
    'Num'      => '=f',
    'ArrayRef' => '=s@',
    'HashRef'  => '=s%',
);

sub has_option_type {
    my (undef, $type_or_name) = @_;

    if (blessed($type_or_name)
        && $type_or_name->isa('Moose::Meta::TypeConstraint::Union')) {
        foreach my $union_type (@{$type_or_name->type_constraints}) {
            return 1
                if __PACKAGE__->has_option_type($union_type);
        }
        return 0;
    }

    return 1 if exists $option_type_map{blessed($type_or_name) ? $type_or_name->name : $type_or_name};

    my $current = blessed($type_or_name) ? $type_or_name : find_type_constraint($type_or_name);

    (defined $current)
        || confess "Could not find the type constraint for '$type_or_name'";

    while (my $parent = $current->parent) {
        return 1 if exists $option_type_map{$parent->name};
        $current = $parent;
    }

    return 0;
}

sub get_option_type {
    my (undef, $type_or_name) = @_;

    if (blessed($type_or_name)
        && $type_or_name->isa('Moose::Meta::TypeConstraint::Union')) {
        foreach my $union_type (@{$type_or_name->type_constraints}) {
            my $option_type = __PACKAGE__->get_option_type($union_type);
            return $option_type
                if defined $option_type;
        }
        return;
    }

    my $name = blessed($type_or_name) ? $type_or_name->name : $type_or_name;

    return $option_type_map{$name} if exists $option_type_map{$name};

    my $current = ref $type_or_name ? $type_or_name : find_type_constraint($type_or_name);

    (defined $current)
        || confess "Could not find the type constraint for '$type_or_name'";

    while ( $current = $current->parent ) {
        return $option_type_map{$current->name}
            if exists $option_type_map{$current->name};
    }

    return;
}

sub add_option_type_to_map {
    my (undef, $type_name, $option_string) = @_;
    (defined $type_name && defined $option_string)
        || confess "You must supply both a type name and an option string";

    if ( blessed($type_name) ) {
        $type_name = $type_name->name;
    } else {
        (find_type_constraint($type_name))
            || confess "The type constraint '$type_name' does not exist";
    }

    $option_type_map{$type_name} = $option_string;
}

1;

=head1 DESCRIPTION

See the I<Custom Type Constraints> section in the L<MooseX::Getopt> docs
for more info about how to use this module.

=method B<has_option_type ($type_or_name)>

=method B<get_option_type ($type_or_name)>

=method B<add_option_type_to_map ($type_name, $option_spec)>

=cut
