use strict;
use warnings;
use Test::More 0.88;
use Test::Trap;

{
    package MyScript;
    use Moose;

    with 'MooseX::Getopt';

    has foo => ( isa => 'Int', is => 'ro', documentation => 'A foo' );

    our $usage = 0;
    before _getopt_full_usage => sub { $usage++; };
    our @warnings;
    before _getopt_spec_warnings => sub { shift; push(@warnings, @_) };
    our @exception;
    before _getopt_spec_exception => sub { shift; push(@exception, @{ shift() }, shift()) };
}
{
    local $MyScript::usage; local @MyScript::warnings; local @MyScript::exception;
    local @ARGV = ('--foo', '1');
    my $i = MyScript->new_with_options;
    ok $i;
    is $i->foo, 1;
    is $MyScript::usage, undef;
}
{
    local $MyScript::usage; local @MyScript::warnings; local @MyScript::exception;
    local @ARGV = ('--help');
    trap { MyScript->new_with_options };
    like($trap->stdout, qr/A foo/);
    is $MyScript::usage, 1;
}
{
    local $MyScript::usage; local @MyScript::warnings; local @MyScript::exception;
    local @ARGV = ('-q'); # Does not exist
    trap { MyScript->new_with_options };
    like($trap->die, qr/A foo/);
    is_deeply \@MyScript::warnings, [
          'Unknown option: q
'
    ];
    # FIXME - it looks like we have a spacing issue in Getopt::Long?
    my $exp = [
         'Unknown option: q
',
         qq{usage: 104_override_usage.t [-?h] [long options...]
\t-h -? --usage --help  Prints this usage information.
\t--foo                A foo
}
     ];

     is_deeply \@MyScript::exception, $exp;
}

done_testing;

