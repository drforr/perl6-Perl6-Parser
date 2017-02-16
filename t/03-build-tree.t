use v6;

use Test;
use Perl6::Parser;

plan 9;

my $pt = Perl6::Parser.new;
my $*CONSISTENCY-CHECK = True;
my $*GRAMMAR-CHECK = True;

# $pt.build-tree verifies that the tokens are contiguous, along with a bunch
# of other things.
#
# So, all I really want to verify here is that the data types are correct.
#
subtest {
	plan 1;
	
	my $p = $pt.parse( Q{} );
	my $t = $pt.build-tree( $p );
	isa-ok $t, Perl6::Document;
}, Q{no ws};

subtest {
	plan 3;
	
	my $p = $pt.parse( Q{ } );
	my $t = $pt.build-tree( $p );
	isa-ok $t, Perl6::Document;
	isa-ok $t.child.[0], Perl6::Statement;
	isa-ok $t.child.[0].child.[0], Perl6::WS;
}, Q{ws};

subtest {
	plan 4;

	my $p = $pt.parse( Q{my$a} );
	my $t = $pt.build-tree( $p );

	isa-ok $t, Perl6::Document;
	isa-ok $t.child.[0], Perl6::Statement;
	isa-ok $t.child.[0].child.[0], Perl6::Bareword;
	isa-ok $t.child.[0].child.[1], Perl6::Variable::Scalar;
}, Q{without semi, without ws};

subtest {
	plan 5;

	my $p = $pt.parse( Q{ my$a} );
	my $t = $pt.build-tree( $p );

	isa-ok $t, Perl6::Document;
	isa-ok $t.child.[0], Perl6::WS;
	isa-ok $t.child.[1], Perl6::Statement;
	isa-ok $t.child.[1].child.[0], Perl6::Bareword;
	isa-ok $t.child.[1].child.[1], Perl6::Variable::Scalar;
}, Q{without semi, with};

subtest {
	plan 5;

	my $p = $pt.parse( Q{my $a} );
	my $t = $pt.build-tree( $p );

	isa-ok $t, Perl6::Document;
	isa-ok $t.child.[0], Perl6::Statement;
	isa-ok $t.child.[0].child.[0], Perl6::Bareword;
	isa-ok $t.child.[0].child.[1], Perl6::WS;
	isa-ok $t.child.[0].child.[2], Perl6::Variable::Scalar;
}, Q{without semi, without ws};

subtest {
	plan 5;

	my $p = $pt.parse( Q{my$a;} );
	my $t = $pt.build-tree( $p );

	isa-ok $t, Perl6::Document;
	isa-ok $t.child.[0], Perl6::Statement;
	isa-ok $t.child.[0].child.[0], Perl6::Bareword;
	isa-ok $t.child.[0].child.[1], Perl6::Variable::Scalar;
	isa-ok $t.child.[0].child.[2], Perl6::Semicolon;
}, Q{with semi, without ws};

subtest {
	plan 6;

	my $p = $pt.parse( Q{my $a;} );
	my $t = $pt.build-tree( $p );

	isa-ok $t, Perl6::Document;
	isa-ok $t.child.[0], Perl6::Statement;
	isa-ok $t.child.[0].child.[0], Perl6::Bareword;
	isa-ok $t.child.[0].child.[1], Perl6::WS;
	isa-ok $t.child.[0].child.[2], Perl6::Variable::Scalar;
	isa-ok $t.child.[0].child.[3], Perl6::Semicolon;
}, Q{with semi, with ws};

subtest {
	plan 9;

	my $p = $pt.parse( Q{my $a = 1} );
	my $t = $pt.build-tree( $p );

	isa-ok $t, Perl6::Document;
	isa-ok $t.child.[0], Perl6::Statement;
	isa-ok $t.child.[0].child.[0], Perl6::Bareword;
	isa-ok $t.child.[0].child.[1], Perl6::WS;
	isa-ok $t.child.[0].child.[2], Perl6::Variable::Scalar;
	isa-ok $t.child.[0].child.[3], Perl6::WS;
	isa-ok $t.child.[0].child.[4], Perl6::Operator::Infix;
	isa-ok $t.child.[0].child.[5], Perl6::WS;
	isa-ok $t.child.[0].child.[6], Perl6::Number::Decimal;
}, Q{assignment without semi, with ws};

subtest {
	plan 13;

	my $p = $pt.parse( Q{my $a = 1 + 2} );
	my $t = $pt.build-tree( $p );

	isa-ok $t, Perl6::Document;
	isa-ok $t.child.[0], Perl6::Statement;
	isa-ok $t.child.[0].child.[0], Perl6::Bareword;
	isa-ok $t.child.[0].child.[1], Perl6::WS;
	isa-ok $t.child.[0].child.[2], Perl6::Variable::Scalar;
	isa-ok $t.child.[0].child.[3], Perl6::WS;
	isa-ok $t.child.[0].child.[4], Perl6::Operator::Infix;
	isa-ok $t.child.[0].child.[5], Perl6::WS;
	isa-ok $t.child.[0].child.[6], Perl6::Number::Decimal;
	isa-ok $t.child.[0].child.[7], Perl6::WS;
	isa-ok $t.child.[0].child.[8], Perl6::Operator::Infix;
	isa-ok $t.child.[0].child.[9], Perl6::WS;
	isa-ok $t.child.[0].child.[10], Perl6::Number::Decimal;
}, Q{assignment without semi, with ws, complex expression};

# vim: ft=perl6
