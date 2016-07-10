use v6;

use nqp;
use Test;
use Perl6::Tidy;

plan 2;

my $pt = Perl6::Tidy.new;

subtest {
	plan 6;

	subtest {
		plan 2;

		my $parsed = $pt.tidy( Q{1 + 1} );
		isa-ok $parsed, 'Perl6::Tidy::Root';
		is $parsed.child.elems, 1;
	}, Q{add};

	subtest {
		plan 2;

		my $parsed = $pt.tidy( Q{1 - 1} );
		isa-ok $parsed, 'Perl6::Tidy::Root';
		is $parsed.child.elems, 1;
	}, Q{subtract};

	subtest {
		plan 2;

		my $parsed = $pt.tidy( Q{1 * 1} );
		isa-ok $parsed, 'Perl6::Tidy::Root';
		is $parsed.child.elems, 1;
	}, Q{multiply};

	subtest {
		plan 2;

		my $parsed = $pt.tidy( Q{1 / 1} );
		isa-ok $parsed, 'Perl6::Tidy::Root';
		is $parsed.child.elems, 1;
	}, Q{divide};

	subtest {
		plan 2;

		my $parsed = $pt.tidy( Q{1 % 1} );
		isa-ok $parsed, 'Perl6::Tidy::Root';
		is $parsed.child.elems, 1;
	}, Q{modulo};

	subtest {
		plan 2;

		my $parsed = $pt.tidy( Q{1 ** 1} );
		isa-ok $parsed, 'Perl6::Tidy::Root';
		is $parsed.child.elems, 1;
	}, Q{exp};
}, Q{asmd mod exp};

subtest {
	plan 4;

	subtest {
		plan 2;

		my $parsed = $pt.tidy( Q{my $x; $x.say} );
		isa-ok $parsed, 'Perl6::Tidy::Root';
		is $parsed.child.elems, 1;
	}, Q{.meth};

	subtest {
		plan 2;

		my $parsed = $pt.tidy( Q{my $x; $x.+say} );
		isa-ok $parsed, 'Perl6::Tidy::Root';
		is $parsed.child.elems, 1;
	}, Q{.+};

	subtest {
		plan 2;

		my $parsed = $pt.tidy( Q{my $x; $x.?say} );
		isa-ok $parsed, 'Perl6::Tidy::Root';
		is $parsed.child.elems, 1;
	}, Q{.?};

	subtest {
		plan 2;

		my $parsed = $pt.tidy( Q{my $x; $x.*say} );
		isa-ok $parsed, 'Perl6::Tidy::Root';
		is $parsed.child.elems, 1;
	}, Q{.*};

#	subtest {
#		plan 2;
#
#		my $parsed = $pt.tidy( Q{my $x; $x.()} );
#		isa-ok $parsed, 'Perl6::Tidy::Root';
#		is $parsed.child.elems, 1;
#	}, Q{.()};
}, 'postfix';

#`(

L 	Method postfix 	.() .[] .{} .<> .«» .:: .= .^ .:
N 	Autoincrement 	++ --
R 	Exponentiation 	**
L 	Symbolic unary 	! + - ~ ? | || +^ ~^ ?^ ^
L 	Multiplicative 	* / % %% +& +< +> ~& ~< ~> ?& div mod gcd lcm
L 	Additive 	+ - +| +^ ~| ~^ ?| ?^
L 	Replication 	x xx
X 	Concatenation 	~
X 	Junctive and 	&
X 	Junctive or 	| ^
L 	Named unary 	temp let
N 	Structural infix 	but does <=> leg cmp .. ..^ ^.. ^..^
C 	Chaining infix 	!= == < <= > >= eq ne lt le gt ge ~~ === eqv !eqv =~=
X 	Tight and 	&&
X 	Tight or 	|| ^^ // min max
R 	Conditional 	?? !! ff fff
R 	Item assignment 	= => += -= **= xx= .=
L 	Loose unary 	so not
X 	Comma operator 	, :
X 	List infix 	Z minmax X X~ X* Xeqv ...
R 	List prefix 	print push say die map substr ... [+] [*] any Z=
X 	Loose and 	and andthen
X 	Loose or 	or xor orelse
X 	Sequencer 	<==, ==>, <<==, ==>>
N 	Terminator 	; {...}, unless, extra close-paren, ], }

)

# vim: ft=perl6
