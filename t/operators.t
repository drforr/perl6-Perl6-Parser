use v6;

use nqp;
use Test;
use Perl6::Tidy;

plan 13;

my $pt = Perl6::Tidy.new;

subtest {
	plan 13;

	subtest {
		plan 2;

		my $parsed = $pt.tidy( Q{my $x; $x.say} );
		isa-ok $parsed, 'Perl6::Tidy::Root';
		is $parsed.child.elems, 1;
	}, Q[.say];

	subtest {
		plan 2;

		my $parsed = $pt.tidy( Q{my $x; $x.+say} );
		isa-ok $parsed, 'Perl6::Tidy::Root';
		is $parsed.child.elems, 1;
	}, Q[.+say];

	subtest {
		plan 2;

		my $parsed = $pt.tidy( Q{my $x; $x.?say} );
		isa-ok $parsed, 'Perl6::Tidy::Root';
		is $parsed.child.elems, 1;
	}, Q[.?say];

	subtest {
		plan 2;

		my $parsed = $pt.tidy( Q{my $x; $x.*say} );
		isa-ok $parsed, 'Perl6::Tidy::Root';
		is $parsed.child.elems, 1;
	}, Q[.*say];

#	subtest {
#		plan 2;
#
#		my $parsed = $pt.tidy( Q{my $x; $x.()} );
#		isa-ok $parsed, 'Perl6::Tidy::Root';
#		is $parsed.child.elems, 1;
#	}, Q[.()];
#
#	subtest {
#		plan 2;
#
#		my $parsed = $pt.tidy( Q{my $x; $x.[]} );
#		isa-ok $parsed, 'Perl6::Tidy::Root';
#		is $parsed.child.elems, 1;
#	}, Q[.[]];
#
#	subtest {
#		plan 2;
#
#		my $parsed = $pt.tidy( Q{my $x; $x.{}} );
#		isa-ok $parsed, 'Perl6::Tidy::Root';
#		is $parsed.child.elems, 1;
#	}, Q[.{}];
#
#	subtest {
#		plan 2;
#
#		my $parsed = $pt.tidy( Q{my $x; $x.<>} );
#		isa-ok $parsed, 'Perl6::Tidy::Root';
#		is $parsed.child.elems, 1;
#	}, Q[.<>];
#
#	subtest {
#		plan 2;
#
#		my $parsed = $pt.tidy( Q{my $x; $x.«»} );
#		isa-ok $parsed, 'Perl6::Tidy::Root';
#		is $parsed.child.elems, 1;
#	}, Q[.«»];
#
#	subtest {
#		plan 2;
#
#		my $parsed = $pt.tidy( Q{my $x; $x.::} );
#		isa-ok $parsed, 'Perl6::Tidy::Root';
#		is $parsed.child.elems, 1;
#	}, Q[.::];
#
	subtest {
		plan 2;

		my $parsed = $pt.tidy( Q{my $x; $x.=say} );
		isa-ok $parsed, 'Perl6::Tidy::Root';
		is $parsed.child.elems, 1;
	}, Q[.=];

	subtest {
		plan 2;

		my $parsed = $pt.tidy( Q{my $x; $x.^say} );
		isa-ok $parsed, 'Perl6::Tidy::Root';
		is $parsed.child.elems, 1;
	}, Q[.^];

#	subtest {
#		plan 2;
#
#		my $parsed = $pt.tidy( Q{my $x; $x.:say} );
#		isa-ok $parsed, 'Perl6::Tidy::Root';
#		is $parsed.child.elems, 1;
#	}, Q[.:];
}, 'postfix';

subtest {
	plan 2;

	subtest {
		plan 2;

		my $parsed = $pt.tidy( Q{my $x; $x++} );
		isa-ok $parsed, 'Perl6::Tidy::Root';
		is $parsed.child.elems, 1;
	}, Q[++];

	subtest {
		plan 2;

		my $parsed = $pt.tidy( Q{my $x; $x--} );
		isa-ok $parsed, 'Perl6::Tidy::Root';
		is $parsed.child.elems, 1;
	}, Q[--];
}, 'autoincrement';

subtest {
	plan 1;

	subtest {
		plan 2;

		my $parsed = $pt.tidy( Q{3 ** 2} );
		isa-ok $parsed, 'Perl6::Tidy::Root';
		is $parsed.child.elems, 1;
	}, Q[**];
}, 'exponentiation';

subtest {
	plan 12;

	subtest {
		plan 2;

		my $parsed = $pt.tidy( Q{my $x; !$x} );
		isa-ok $parsed, 'Perl6::Tidy::Root';
		is $parsed.child.elems, 1;
	}, Q[!];

	subtest {
		plan 2;

		my $parsed = $pt.tidy( Q{my $x; +$x} );
		isa-ok $parsed, 'Perl6::Tidy::Root';
		is $parsed.child.elems, 1;
	}, Q[+];

	subtest {
		plan 2;

		my $parsed = $pt.tidy( Q{my $x; -$x} );
		isa-ok $parsed, 'Perl6::Tidy::Root';
		is $parsed.child.elems, 1;
	}, Q[-];

	subtest {
		plan 2;

		my $parsed = $pt.tidy( Q{my $x; ~$x} );
		isa-ok $parsed, 'Perl6::Tidy::Root';
		is $parsed.child.elems, 1;
	}, Q[~];

	subtest {
		plan 2;

		my $parsed = $pt.tidy( Q{my $x; ?$x} );
		isa-ok $parsed, 'Perl6::Tidy::Root';
		is $parsed.child.elems, 1;
	}, Q[?];

	subtest {
		plan 2;

		my $parsed = $pt.tidy( Q{my $x; ?$x} );
		isa-ok $parsed, 'Perl6::Tidy::Root';
		is $parsed.child.elems, 1;
	}, Q[?];

	subtest {
		plan 2;

		my $parsed = $pt.tidy( Q{my $x; |$x} );
		isa-ok $parsed, 'Perl6::Tidy::Root';
		is $parsed.child.elems, 1;
	}, Q[|];

#	subtest {
#		plan 2;
#
#		my $parsed = $pt.tidy( Q{my $x; ||$x} );
#		isa-ok $parsed, 'Perl6::Tidy::Root';
#		is $parsed.child.elems, 1;
#	}, Q[||];
#
	subtest {
		plan 2;

		my $parsed = $pt.tidy( Q{my $x; +^$x} );
		isa-ok $parsed, 'Perl6::Tidy::Root';
		is $parsed.child.elems, 1;
	}, Q[+^];

	subtest {
		plan 2;

		my $parsed = $pt.tidy( Q{my $x; ~^$x} );
		isa-ok $parsed, 'Perl6::Tidy::Root';
		is $parsed.child.elems, 1;
	}, Q[~^];

	subtest {
		plan 2;

		my $parsed = $pt.tidy( Q{my $x; ?^$x} );
		isa-ok $parsed, 'Perl6::Tidy::Root';
		is $parsed.child.elems, 1;
	}, Q[?^];

	subtest {
		plan 2;

		my $parsed = $pt.tidy( Q{my $x; ?$x} );
		isa-ok $parsed, 'Perl6::Tidy::Root';
		is $parsed.child.elems, 1;
	}, Q[?];
}, 'symbolic unary';

subtest {
	plan 15;

	subtest {
		plan 2;

		my $parsed = $pt.tidy( Q{3 * 2} );
		isa-ok $parsed, 'Perl6::Tidy::Root';
		is $parsed.child.elems, 1;
	}, Q[*];

	subtest {
		plan 2;

		my $parsed = $pt.tidy( Q{3 / 2} );
		isa-ok $parsed, 'Perl6::Tidy::Root';
		is $parsed.child.elems, 1;
	}, Q[/];

	subtest {
		plan 2;

		my $parsed = $pt.tidy( Q{3 % 2} );
		isa-ok $parsed, 'Perl6::Tidy::Root';
		is $parsed.child.elems, 1;
	}, Q[%];

	subtest {
		plan 2;

		my $parsed = $pt.tidy( Q{3 %% 2} );
		isa-ok $parsed, 'Perl6::Tidy::Root';
		is $parsed.child.elems, 1;
	}, Q[%%];

	subtest {
		plan 2;

		my $parsed = $pt.tidy( Q{3 +& 2} );
		isa-ok $parsed, 'Perl6::Tidy::Root';
		is $parsed.child.elems, 1;
	}, Q[+&];

	subtest {
		plan 2;

		my $parsed = $pt.tidy( Q{3 +< 2} );
		isa-ok $parsed, 'Perl6::Tidy::Root';
		is $parsed.child.elems, 1;
	}, Q[+<];

	subtest {
		plan 2;

		my $parsed = $pt.tidy( Q{3 +> 2} );
		isa-ok $parsed, 'Perl6::Tidy::Root';
		is $parsed.child.elems, 1;
	}, Q[+>];

	subtest {
		plan 2;

		my $parsed = $pt.tidy( Q{3 ~& 2} );
		isa-ok $parsed, 'Perl6::Tidy::Root';
		is $parsed.child.elems, 1;
	}, Q[~&];

	subtest {
		plan 2;

		my $parsed = $pt.tidy( Q{3 ~< 2} );
		isa-ok $parsed, 'Perl6::Tidy::Root';
		is $parsed.child.elems, 1;
	}, Q[~<];

	subtest {
		plan 2;

		my $parsed = $pt.tidy( Q{3 ~> 2} );
		isa-ok $parsed, 'Perl6::Tidy::Root';
		is $parsed.child.elems, 1;
	}, Q[~>];

	subtest {
		plan 2;

		my $parsed = $pt.tidy( Q{3 ?& 2} );
		isa-ok $parsed, 'Perl6::Tidy::Root';
		is $parsed.child.elems, 1;
	}, Q[?&];

	subtest {
		plan 2;

		my $parsed = $pt.tidy( Q{3 div 2} );
		isa-ok $parsed, 'Perl6::Tidy::Root';
		is $parsed.child.elems, 1;
	}, Q[div];

	subtest {
		plan 2;

		my $parsed = $pt.tidy( Q{3 mod 2} );
		isa-ok $parsed, 'Perl6::Tidy::Root';
		is $parsed.child.elems, 1;
	}, Q[mod];

	subtest {
		plan 2;

		my $parsed = $pt.tidy( Q{3 gcd 2} );
		isa-ok $parsed, 'Perl6::Tidy::Root';
		is $parsed.child.elems, 1;
	}, Q[gcd];

	subtest {
		plan 2;

		my $parsed = $pt.tidy( Q{3 lcm 2} );
		isa-ok $parsed, 'Perl6::Tidy::Root';
		is $parsed.child.elems, 1;
	}, Q[lcm];
}, 'multiplicative';

subtest {
	plan 8;

	subtest {
		plan 2;

		my $parsed = $pt.tidy( Q{3 + 2} );
		isa-ok $parsed, 'Perl6::Tidy::Root';
		is $parsed.child.elems, 1;
	}, Q[+];

	subtest {
		plan 2;

		my $parsed = $pt.tidy( Q{3 - 2} );
		isa-ok $parsed, 'Perl6::Tidy::Root';
		is $parsed.child.elems, 1;
	}, Q[-];

	subtest {
		plan 2;

		my $parsed = $pt.tidy( Q{3 +| 2} );
		isa-ok $parsed, 'Perl6::Tidy::Root';
		is $parsed.child.elems, 1;
	}, Q[+|];

	subtest {
		plan 2;

		my $parsed = $pt.tidy( Q{3 +^ 2} );
		isa-ok $parsed, 'Perl6::Tidy::Root';
		is $parsed.child.elems, 1;
	}, Q[+^];

	subtest {
		plan 2;

		my $parsed = $pt.tidy( Q{3 ~| 2} );
		isa-ok $parsed, 'Perl6::Tidy::Root';
		is $parsed.child.elems, 1;
	}, Q[~|];

	subtest {
		plan 2;

		my $parsed = $pt.tidy( Q{3 ~^ 2} );
		isa-ok $parsed, 'Perl6::Tidy::Root';
		is $parsed.child.elems, 1;
	}, Q[~^];

	subtest {
		plan 2;

		my $parsed = $pt.tidy( Q{3 ?| 2} );
		isa-ok $parsed, 'Perl6::Tidy::Root';
		is $parsed.child.elems, 1;
	}, Q[?|];

	subtest {
		plan 2;

		my $parsed = $pt.tidy( Q{3 ?^ 2} );
		isa-ok $parsed, 'Perl6::Tidy::Root';
		is $parsed.child.elems, 1;
	}, Q[?^];
}, 'additive';

subtest {
	plan 2;

	subtest {
		plan 2;

		my $parsed = $pt.tidy( Q{'a' x 2} );
		isa-ok $parsed, 'Perl6::Tidy::Root';
		is $parsed.child.elems, 1;
	}, Q[x];

	subtest {
		plan 2;

		my $parsed = $pt.tidy( Q{'a' xx 2} );
		isa-ok $parsed, 'Perl6::Tidy::Root';
		is $parsed.child.elems, 1;
	}, Q[xx];
}, 'replication';

subtest {
	plan 1;

	subtest {
		plan 2;

		my $parsed = $pt.tidy( Q{'a' ~ 2} );
		isa-ok $parsed, 'Perl6::Tidy::Root';
		is $parsed.child.elems, 1;
	}, Q[~];
}, 'concatenation';

subtest {
	plan 1;

	subtest {
		plan 2;

		my $parsed = $pt.tidy( Q{'a' & 2} );
		isa-ok $parsed, 'Perl6::Tidy::Root';
		is $parsed.child.elems, 1;
	}, Q[&];
}, 'junctive and';

subtest {
	plan 2;

	subtest {
		plan 2;

		my $parsed = $pt.tidy( Q{'a' | 2} );
		isa-ok $parsed, 'Perl6::Tidy::Root';
		is $parsed.child.elems, 1;
	}, Q[|];

	subtest {
		plan 2;

		my $parsed = $pt.tidy( Q{'a' ^ 2} );
		isa-ok $parsed, 'Perl6::Tidy::Root';
		is $parsed.child.elems, 1;
	}, Q[^];
}, 'junctive or';

subtest {
	plan 2;

	subtest {
		plan 2;

		my $parsed = $pt.tidy( Q{my $x; temp $x} );
		isa-ok $parsed, 'Perl6::Tidy::Root';
		is $parsed.child.elems, 1;
	}, Q[temp];

	subtest {
		plan 2;

		my $parsed = $pt.tidy( Q{my $x; let $x} );
		isa-ok $parsed, 'Perl6::Tidy::Root';
		is $parsed.child.elems, 1;
	}, Q[let];
}, 'named unary';

subtest {
	plan 9;

	subtest {
		plan 2;

		my $parsed = $pt.tidy( Q{1 but 2} );
		isa-ok $parsed, 'Perl6::Tidy::Root';
		is $parsed.child.elems, 1;
	}, Q[but];

	subtest {
		plan 2;

		my $parsed = $pt.tidy( Q{1 does 2} );
		isa-ok $parsed, 'Perl6::Tidy::Root';
		is $parsed.child.elems, 1;
	}, Q[does];

	subtest {
		plan 2;

		my $parsed = $pt.tidy( Q{1 <=> 2} );
		isa-ok $parsed, 'Perl6::Tidy::Root';
		is $parsed.child.elems, 1;
	}, Q[<=>];

	subtest {
		plan 2;

		my $parsed = $pt.tidy( Q{1 leg 2} );
		isa-ok $parsed, 'Perl6::Tidy::Root';
		is $parsed.child.elems, 1;
	}, Q[leg];

	subtest {
		plan 2;

		my $parsed = $pt.tidy( Q{'a' cmp 'b'} );
		isa-ok $parsed, 'Perl6::Tidy::Root';
		is $parsed.child.elems, 1;
	}, Q[cmp];

	subtest {
		plan 2;

		my $parsed = $pt.tidy( Q{1 .. 2} );
		isa-ok $parsed, 'Perl6::Tidy::Root';
		is $parsed.child.elems, 1;
	}, Q[..];

	subtest {
		plan 2;

		my $parsed = $pt.tidy( Q{1 ..^ 2} );
		isa-ok $parsed, 'Perl6::Tidy::Root';
		is $parsed.child.elems, 1;
	}, Q[..^];

	subtest {
		plan 2;

		my $parsed = $pt.tidy( Q{1 ^.. 2} );
		isa-ok $parsed, 'Perl6::Tidy::Root';
		is $parsed.child.elems, 1;
	}, Q[^..];

	subtest {
		plan 2;

		my $parsed = $pt.tidy( Q{1 ^..^ 2} );
		isa-ok $parsed, 'Perl6::Tidy::Root';
		is $parsed.child.elems, 1;
	}, Q[^..^];
}, 'structural infix';

subtest {
	plan 17;

	subtest {
		plan 2;

		my $parsed = $pt.tidy( Q{3 != 2} );
		isa-ok $parsed, 'Perl6::Tidy::Root';
		is $parsed.child.elems, 1;
	}, Q[!=];

	subtest {
		plan 2;

		my $parsed = $pt.tidy( Q{3 == 2} );
		isa-ok $parsed, 'Perl6::Tidy::Root';
		is $parsed.child.elems, 1;
	}, Q[==];

	subtest {
		plan 2;

		my $parsed = $pt.tidy( Q{3 < 2} );
		isa-ok $parsed, 'Perl6::Tidy::Root';
		is $parsed.child.elems, 1;
	}, Q[<];

	subtest {
		plan 2;

		my $parsed = $pt.tidy( Q{3 <= 2} );
		isa-ok $parsed, 'Perl6::Tidy::Root';
		is $parsed.child.elems, 1;
	}, Q[<=];

	subtest {
		plan 2;

		my $parsed = $pt.tidy( Q{3 > 2} );
		isa-ok $parsed, 'Perl6::Tidy::Root';
		is $parsed.child.elems, 1;
	}, Q[>];

	subtest {
		plan 2;

		my $parsed = $pt.tidy( Q{3 >= 2} );
		isa-ok $parsed, 'Perl6::Tidy::Root';
		is $parsed.child.elems, 1;
	}, Q[>=];

	subtest {
		plan 2;

		my $parsed = $pt.tidy( Q{'a' eq 'b'} );
		isa-ok $parsed, 'Perl6::Tidy::Root';
		is $parsed.child.elems, 1;
	}, Q[eq];

	subtest {
		plan 2;

		my $parsed = $pt.tidy( Q{'a' ne 'b'} );
		isa-ok $parsed, 'Perl6::Tidy::Root';
		is $parsed.child.elems, 1;
	}, Q[ne];

	subtest {
		plan 2;

		my $parsed = $pt.tidy( Q{'a' lt 'b'} );
		isa-ok $parsed, 'Perl6::Tidy::Root';
		is $parsed.child.elems, 1;
	}, Q[lt];

	subtest {
		plan 2;

		my $parsed = $pt.tidy( Q{'a' le 'b'} );
		isa-ok $parsed, 'Perl6::Tidy::Root';
		is $parsed.child.elems, 1;
	}, Q[le];

	subtest {
		plan 2;

		my $parsed = $pt.tidy( Q{'a' gt 'b'} );
		isa-ok $parsed, 'Perl6::Tidy::Root';
		is $parsed.child.elems, 1;
	}, Q[gt];

	subtest {
		plan 2;

		my $parsed = $pt.tidy( Q{'a' ge 'b'} );
		isa-ok $parsed, 'Perl6::Tidy::Root';
		is $parsed.child.elems, 1;
	}, Q[ge];

	subtest {
		plan 2;

		my $parsed = $pt.tidy( Q{3 ~~ 2} );
		isa-ok $parsed, 'Perl6::Tidy::Root';
		is $parsed.child.elems, 1;
	}, Q[~~];

	subtest {
		plan 2;

		my $parsed = $pt.tidy( Q{3 === 2} );
		isa-ok $parsed, 'Perl6::Tidy::Root';
		is $parsed.child.elems, 1;
	}, Q[===];

	subtest {
		plan 2;

		my $parsed = $pt.tidy( Q{3 eqv 2} );
		isa-ok $parsed, 'Perl6::Tidy::Root';
		is $parsed.child.elems, 1;
	}, Q[eqv];

#	subtest {
#		plan 2;
#
#		my $parsed = $pt.tidy( Q{3 !eqv 2} );
#		isa-ok $parsed, 'Perl6::Tidy::Root';
#		is $parsed.child.elems, 1;
#	}, Q[!eqv];
#
#	subtest {
#		plan 2;
#
#		my $parsed = $pt.tidy( Q{3 =~= 2} );
#		isa-ok $parsed, 'Perl6::Tidy::Root';
#		is $parsed.child.elems, 1;
#	}, Q[=~=];
}, 'chaining infix';

subtest {
	plan 1;

	subtest {
		plan 2;

		my $parsed = $pt.tidy( Q{3 && 2} );
		isa-ok $parsed, 'Perl6::Tidy::Root';
		is $parsed.child.elems, 1;
	}, Q[&&];
}, 'tight and';

subtest {
	plan 5;

	subtest {
		plan 2;

		my $parsed = $pt.tidy( Q{3 || 2} );
		isa-ok $parsed, 'Perl6::Tidy::Root';
		is $parsed.child.elems, 1;
	}, Q[||];

	subtest {
		plan 2;

		my $parsed = $pt.tidy( Q{3 ^^ 2} );
		isa-ok $parsed, 'Perl6::Tidy::Root';
		is $parsed.child.elems, 1;
	}, Q[^^];

	subtest {
		plan 2;

		my $parsed = $pt.tidy( Q{3 // 2} );
		isa-ok $parsed, 'Perl6::Tidy::Root';
		is $parsed.child.elems, 1;
	}, Q[//];

	subtest {
		plan 2;

		my $parsed = $pt.tidy( Q{3 min 2} );
		isa-ok $parsed, 'Perl6::Tidy::Root';
		is $parsed.child.elems, 1;
	}, Q[min];

	subtest {
		plan 2;

		my $parsed = $pt.tidy( Q{3 max 2} );
		isa-ok $parsed, 'Perl6::Tidy::Root';
		is $parsed.child.elems, 1;
	}, Q[max];
}, 'tight or';

subtest {
	plan 3;

#	subtest {
#		plan 2;
#
#		my $parsed = $pt.tidy( Q{3 ?? 2 !! 1} );
#		isa-ok $parsed, 'Perl6::Tidy::Root';
#		is $parsed.child.elems, 1;
#	}, Q[??];

	subtest {
		plan 2;

		my $parsed = $pt.tidy( Q{3 ff 2} );
		isa-ok $parsed, 'Perl6::Tidy::Root';
		is $parsed.child.elems, 1;
	}, Q[ff];

	subtest {
		plan 2;

		my $parsed = $pt.tidy( Q{3 fff 2} );
		isa-ok $parsed, 'Perl6::Tidy::Root';
		is $parsed.child.elems, 1;
	}, Q[fff];
}, 'conditional';

#`(

Item assignment 	= => += -= **= xx= .=

)

subtest {
	plan 2;

	subtest {
		plan 2;

		my $parsed = $pt.tidy( Q{so 2} );
		isa-ok $parsed, 'Perl6::Tidy::Root';
		is $parsed.child.elems, 1;
	}, Q[so];

	subtest {
		plan 2;

		my $parsed = $pt.tidy( Q{not 2} );
		isa-ok $parsed, 'Perl6::Tidy::Root';
		is $parsed.child.elems, 1;
	}, Q[not];
}, 'loose unary';

subtest {
	plan 2;

	subtest {
		plan 2;

		my $parsed = $pt.tidy( Q{3 , 2} );
		isa-ok $parsed, 'Perl6::Tidy::Root';
		is $parsed.child.elems, 1;
	}, Q[,];

#	subtest {
#		plan 2;
#
#		my $parsed = $pt.tidy( Q{'a': 2} );
#		isa-ok $parsed, 'Perl6::Tidy::Root';
#		is $parsed.child.elems, 1;
#	}, Q[:];
}, 'comma operator';

subtest {
	plan 6;

	subtest {
		plan 2;

		my $parsed = $pt.tidy( Q{my @a; my @b; @a Z @b} );
		isa-ok $parsed, 'Perl6::Tidy::Root';
		is $parsed.child.elems, 1;
	}, Q[Z];

	subtest {
		plan 2;

		my $parsed = $pt.tidy( Q{my @a; my @b; @a minmax @b} );
		isa-ok $parsed, 'Perl6::Tidy::Root';
		is $parsed.child.elems, 1;
	}, Q[minmax];

	subtest {
		plan 2;

		my $parsed = $pt.tidy( Q{my @a; my @b; @a X @b} );
		isa-ok $parsed, 'Perl6::Tidy::Root';
		is $parsed.child.elems, 1;
	}, Q[X];

#	subtest {
#		plan 2;
#
#		my $parsed = $pt.tidy( Q{my @a; my @b; @a X~ @b} );
#		isa-ok $parsed, 'Perl6::Tidy::Root';
#		is $parsed.child.elems, 1;
#	}, Q[X~];

#	subtest {
#		plan 2;
#
#		my $parsed = $pt.tidy( Q{my @a; my @b; @a X* @b} );
#		isa-ok $parsed, 'Perl6::Tidy::Root';
#		is $parsed.child.elems, 1;
#	}, Q[X*];

#	subtest {
#		plan 2;
#
#		my $parsed = $pt.tidy( Q{my @a; my @b; @a Xeqv @b} );
#		isa-ok $parsed, 'Perl6::Tidy::Root';
#		is $parsed.child.elems, 1;
#	}, Q[Xeqv];
}, 'list infix';

#`(

List prefix 	print push say die map substr ... [+] [*] any Z=

)

subtest {
	plan 2;

	subtest {
		plan 2;

		my $parsed = $pt.tidy( Q{3 and 2} );
		isa-ok $parsed, 'Perl6::Tidy::Root';
		is $parsed.child.elems, 1;
	}, Q[and];

#	subtest {
#		plan 2;
#
#		my $parsed = $pt.tidy( Q{3 andthen 2} );
#		isa-ok $parsed, 'Perl6::Tidy::Root';
#		is $parsed.child.elems, 1;
#	}, Q[andthen];
}, 'loose and';

subtest {
	plan 3;

	subtest {
		plan 2;

		my $parsed = $pt.tidy( Q{3 or 2} );
		isa-ok $parsed, 'Perl6::Tidy::Root';
		is $parsed.child.elems, 1;
	}, Q[or];

	subtest {
		plan 2;

		my $parsed = $pt.tidy( Q{3 xor 2} );
		isa-ok $parsed, 'Perl6::Tidy::Root';
		is $parsed.child.elems, 1;
	}, Q[xor];

	subtest {
		plan 2;

		my $parsed = $pt.tidy( Q{3 orelse 2} );
		isa-ok $parsed, 'Perl6::Tidy::Root';
		is $parsed.child.elems, 1;
	}, Q[orelse];
}, 'loose or';

subtest {
	plan 4;

#	subtest {
#		plan 2;
#
#		my $parsed = $pt.tidy( Q{my @a; sort() <== @a} );
#		isa-ok $parsed, 'Perl6::Tidy::Root';
#		is $parsed.child.elems, 1;
#	}, Q[<==];

#	subtest {
#		plan 2;
#
#		my $parsed = $pt.tidy( Q{my @a; @a ==> sort} );
#		isa-ok $parsed, 'Perl6::Tidy::Root';
#		is $parsed.child.elems, 1;
#	}, Q[==>];

#	subtest {
#		plan 2;
#
#		my $parsed = $pt.tidy( Q{3 <<== 2} );
#		isa-ok $parsed, 'Perl6::Tidy::Root';
#		is $parsed.child.elems, 1;
#	}, Q[<<==];

#	subtest {
#		plan 2;
#
#		my $parsed = $pt.tidy( Q{3 ==>> 2} );
#		isa-ok $parsed, 'Perl6::Tidy::Root';
#		is $parsed.child.elems, 1;
#	}, Q[==>>];
}, 'sequencer';

# vim: ft=perl6
