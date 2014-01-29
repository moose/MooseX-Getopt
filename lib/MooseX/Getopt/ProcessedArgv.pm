package MooseX::Getopt::ProcessedArgv;
# ABSTRACT: MooseX::Getopt::ProcessedArgv - Class containing the results of process_argv

use Moose;
use namespace::autoclean;

has 'argv_copy'          => (is => 'ro', isa => 'ArrayRef');
has 'extra_argv'         => (is => 'ro', isa => 'ArrayRef');
has 'usage'              => (is => 'ro', isa => 'Maybe[Object]');
has 'constructor_params' => (is => 'ro', isa => 'HashRef');
has 'cli_params'         => (is => 'ro', isa => 'HashRef');

__PACKAGE__->meta->make_immutable();

1;

=head1 SYNOPSIS

  use My::App;

  my $pa = My::App->process_argv(@params);
  my $argv_copy          = $pa->argv_copy();
  my $extra_argv         = $pa->extra_argv();
  my $usage              = $pa->usage();
  my $constructor_params = $pa->constructor_params();
  my $cli_params         = $pa->cli_params();

=head1 DESCRIPTION

This object contains the result of a L<MooseX::Getopt/process_argv> call. It
contains all the information that L<MooseX::Getopt/new_with_options> uses
when calling new.

=method argv_copy

Reference to a copy of the original C<@ARGV> array as it originally existed
at the time of C<new_with_options>.

=method extra_arg

Arrayref of leftover C<@ARGV> elements that L<Getopt::Long> did not parse.

=method usage

Contains the L<Getopt::Long::Descriptive::Usage> object (if
L<Getopt::Long::Descriptive> is used).

=method constructor_params

Parameters passed to process_argv.

=method cli_param

Command-line parameters parsed out of C<@ARGV>.

=cut
