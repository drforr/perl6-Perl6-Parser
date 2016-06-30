use v6;

use nqp;
use Test;
use Perl6::Tidy;

plan 1;

my $pt = Perl6::Tidy.new( :debugging(True) );

#`(

subtest sub {
  my $parsed = $pt.tidy( q{} );
  isa-ok $parsed, 'Perl6::Tidy::StatementList';
  nok $parsed.statement, 'Contains no statements';
}, 'Empty file';

subtest sub {
  my $parsed = $pt.tidy( q{1} );
}, 'single integer';

)

subtest sub {
  # Use 'Pkg::' to check that <longname>.Str is qualified.
  # Use 'print' to make sure that it's there regardless.
  #
  my $parsed = $pt.tidy(
    q{Pkg::say 'Hello, world!', 0x1; print( 'Goodbye, cruel world!' )}
  );

#  isa-ok $parsed, 'Perl6::Tidy::StatementList';
#  is $parsed.statement.elems, 2, 'StatementList has 2 statements';
#
#  my $statement = $parsed.statement.[0];
#  subtest sub {
#    isa-ok $statement, 'Perl6::Tidy::Statement';
#    isa-ok $statement.EXPR, 'Perl6::Tidy::EXPR';
#
#    my $EXPR = $statement.EXPR;
#    subtest sub {
#      isa-ok $EXPR, 'Perl6::Tidy::EXPR';
#      is $EXPR.longname, 'Pkg::say';
#    }, 'EXPR';
#  }, 'statement 0';
}, 'basic test';

# vim: ft=perl6
