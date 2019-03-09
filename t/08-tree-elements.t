use v6;

use Test;
use Perl6::Parser;

use lib 't/lib';
use Utils;

plan 2;

my $pp = Perl6::Parser.new;
my $*CONSISTENCY-CHECK = True;
my $*FALL-THROUGH      = True;

# Verify that all of the token types can be found in parsed output.
# I don't particularly care *where* they are, just *that* they are.
#

ok has-a( Perl6::Parser.new.to-tree( Q{} ), Perl6::Document ),
	Q{Document};

subtest {
	my $tree = Perl6::Parser.new.to-tree( Q{my $a; my %a; my @a; my &a;} );

	ok has-a( $tree, Perl6::Statement ), Q{Statement};
	ok has-a( $tree, Perl6::Bareword ), Q{Bareword};
	ok has-a( $tree, Perl6::Variable::Scalar ), Q{Variable::Scalar};
}, Q{my $a;};

#`{

subtest {
	my $t = $pp.to-tree( Q{ my$a} );

	isa-ok $t.child.[0], Perl6::WS;
	isa-ok $t.child.[1], Perl6::Statement;
	isa-ok $t.child.[1].child.[0], Perl6::Bareword;
	isa-ok $t.child.[1].child.[1], Perl6::Variable::Scalar;

	done-testing;
}, Q{without semi, with};

subtest {
	my $t = $pp.to-tree( Q{my $a} );

	isa-ok $t.child.[0], Perl6::Statement;
	isa-ok $t.child.[0].child.[0], Perl6::Bareword;
	isa-ok $t.child.[0].child.[1], Perl6::WS;
	isa-ok $t.child.[0].child.[2], Perl6::Variable::Scalar;

	done-testing;
}, Q{without semi, without ws};

subtest {
	my $t = $pp.to-tree( Q{my$a;} );

	isa-ok $t.child.[0], Perl6::Statement;
	isa-ok $t.child.[0].child.[0], Perl6::Bareword;
	isa-ok $t.child.[0].child.[1], Perl6::Variable::Scalar;
	isa-ok $t.child.[0].child.[2], Perl6::Semicolon;

	done-testing;
}, Q{with semi, without ws};

subtest {
	my $t = $pp.to-tree( Q{my $a;} );

	isa-ok $t.child.[0], Perl6::Statement;
	isa-ok $t.child.[0].child.[0], Perl6::Bareword;
	isa-ok $t.child.[0].child.[1], Perl6::WS;
	isa-ok $t.child.[0].child.[2], Perl6::Variable::Scalar;
	isa-ok $t.child.[0].child.[3], Perl6::Semicolon;

	done-testing;
}, Q{with semi, with ws};

subtest {
	my $t = $pp.to-tree( Q{my $a = 1} );

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
	my $t = $pp.to-tree( Q{my $a = 1 + 2} );

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
}

# vim: ft=perl6
