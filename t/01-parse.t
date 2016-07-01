use v6;

use nqp;
use Test;
use Perl6::Tidy;

plan 2;

my $pt = Perl6::Tidy.new( :debugging(True) );

subtest sub {
	plan 2;

	my $parsed = $pt.tidy( q{} );
	isa-ok $parsed, 'Perl6::Tidy::StatementList';
	is $parsed.statement.elems, 0;
}, 'Empty file';

subtest sub {
	subtest sub {
		my $parsed = $pt.tidy( q{1} );
		isa-ok $parsed, 'Perl6::Tidy::StatementList';
		is $parsed.statement.elems, 1;
	}, 'single decimal integer';

	subtest sub {
		my $parsed = $pt.tidy( q{0b1} );
		isa-ok $parsed, 'Perl6::Tidy::StatementList';
		is $parsed.statement.elems, 1;
	}, 'single binary integer';

	subtest sub {
		my $parsed = $pt.tidy( q{0o1} );
		isa-ok $parsed, 'Perl6::Tidy::StatementList';
		is $parsed.statement.elems, 1;
	}, 'single octal integer';

	subtest sub {
		my $parsed = $pt.tidy( q{0x1} );
		isa-ok $parsed, 'Perl6::Tidy::StatementList';
		is $parsed.statement.elems, 1;
	}, 'single hex integer';

	subtest sub {
		my $parsed = $pt.tidy( q{:13(1)} );
		isa-ok $parsed, 'Perl6::Tidy::StatementList';
		is $parsed.statement.elems, 1;
	}, 'single hex integer';

	subtest sub {
		my $parsed = $pt.tidy( q{'Hello, world!'} );
		isa-ok $parsed, 'Perl6::Tidy::StatementList';
		is $parsed.statement.elems, 1;
	}, 'single string';
}, 'single term';

#`(

Perl6::Tidy::Statement.new(
  items => [
    Perl6::Tidy::LongnameArgs.new(
      longname => "Pkg::say",
       args => [
        Perl6::Tidy::EXPR.new(
          items => [
            Perl6::Tidy::Nibble.new( value => "Hello, world!" ),
            Perl6::Tidy::HexInt.new( value => 1e0 ) ] ) ] ),
    Perl6::Tidy::IdentifierArgs.new(
      identifier => "print",
      semiarglist => [
        Perl6::Tidy::EXPR.new(
          items => [
            Perl6::Tidy::Nibble.new( value => "Goodbye, cruel world!" ) ] ) ] ) ] )

)

#`(

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

)

# vim: ft=perl6
