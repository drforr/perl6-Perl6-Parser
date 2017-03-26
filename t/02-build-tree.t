use v6;

use Test;
use Perl6::Parser;

plan 9;

my $pt = Perl6::Parser.new;
my $*CONSISTENCY-CHECK = True;
my $*FALL-THROUGH = True;

# $pt.to-tree verifies that the tokens are contiguous, along with a bunch
# of other things.
#
# So, all I really want to verify here is that the data types are correct.
#
subtest {
	my $source = Q{};
	my $t = $pt.to-tree( $source );
	isa-ok $t, Perl6::Document;

	done-testing;
}, Q{no ws};

subtest {
	my $source = Q{ };
	my $t = $pt.to-tree( $source );
	isa-ok $t, Perl6::Document;
	isa-ok $t.child.[0], Perl6::WS;

	done-testing;
}, Q{ws};

subtest {
	my $source = Q{my$a};
	my $t = $pt.to-tree( $source );

	isa-ok $t, Perl6::Document;
	isa-ok $t.child.[0], Perl6::Statement;
	isa-ok $t.child.[0].child.[0], Perl6::Bareword;
	isa-ok $t.child.[0].child.[1], Perl6::Variable::Scalar;

	done-testing;
}, Q{without semi, without ws};

subtest {
	my $source = Q{ my$a};
	my $t = $pt.to-tree( $source );

	isa-ok $t, Perl6::Document;
	isa-ok $t.child.[0], Perl6::WS;
	isa-ok $t.child.[1], Perl6::Statement;
	isa-ok $t.child.[1].child.[0], Perl6::Bareword;
	isa-ok $t.child.[1].child.[1], Perl6::Variable::Scalar;

	done-testing;
}, Q{without semi, with};

subtest {
	my $source = Q{my $a};
	my $t = $pt.to-tree( $source );

	isa-ok $t, Perl6::Document;
	isa-ok $t.child.[0], Perl6::Statement;
	isa-ok $t.child.[0].child.[0], Perl6::Bareword;
	isa-ok $t.child.[0].child.[1], Perl6::WS;
	isa-ok $t.child.[0].child.[2], Perl6::Variable::Scalar;

	done-testing;
}, Q{without semi, without ws};

subtest {
	my $source = Q{my$a;};
	my $t = $pt.to-tree( $source );

	isa-ok $t, Perl6::Document;
	isa-ok $t.child.[0], Perl6::Statement;
	isa-ok $t.child.[0].child.[0], Perl6::Bareword;
	isa-ok $t.child.[0].child.[1], Perl6::Variable::Scalar;
	isa-ok $t.child.[0].child.[2], Perl6::Semicolon;

	done-testing;
}, Q{with semi, without ws};

subtest {
	my $source = Q{my $a;};
	my $t = $pt.to-tree( $source );

	isa-ok $t, Perl6::Document;
	isa-ok $t.child.[0], Perl6::Statement;
	isa-ok $t.child.[0].child.[0], Perl6::Bareword;
	isa-ok $t.child.[0].child.[1], Perl6::WS;
	isa-ok $t.child.[0].child.[2], Perl6::Variable::Scalar;
	isa-ok $t.child.[0].child.[3], Perl6::Semicolon;

	done-testing;
}, Q{with semi, with ws};

subtest {
	my $source = Q{my $a = 1};
	my $t = $pt.to-tree( $source );

	isa-ok $t, Perl6::Document;
	isa-ok $t.child.[0], Perl6::Statement;
	isa-ok $t.child.[0].child.[0], Perl6::Bareword;
	isa-ok $t.child.[0].child.[1], Perl6::WS;
	isa-ok $t.child.[0].child.[2], Perl6::Variable::Scalar;
	isa-ok $t.child.[0].child.[3], Perl6::WS;
	isa-ok $t.child.[0].child.[4], Perl6::Operator::Infix;
	isa-ok $t.child.[0].child.[5], Perl6::WS;
	isa-ok $t.child.[0].child.[6], Perl6::Number::Decimal;

	done-testing;
}, Q{assignment without semi, with ws};

subtest {
	my $source = Q{my $a = 1 + 2};
	my $t = $pt.to-tree( $source );

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

	done-testing;
}, Q{assignment without semi, with ws, complex expression};

# vim: ft=perl6
