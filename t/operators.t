use v6;

use nqp;
use Test;
use Perl6::Tidy;

plan 13;

my $pt = Perl6::Tidy.new;

subtest {
	plan 1;

	subtest {
		plan 2;

		my $parsed = $pt.tidy( Q{my $x; $x.say} );
		isa-ok $parsed, 'Perl6::Tidy::Root';
		is $parsed.child.elems, 1;
	}, Q[.say];

#	subtest {
#		plan 2;
#
#		my $parsed = $pt.tidy( Q{my $x; $x.+say} );
#		isa-ok $parsed, 'Perl6::Tidy::Root';
#		is $parsed.child.elems, 1;
#	}, Q[.+say];
#
#	subtest {
#		plan 2;
#
#		my $parsed = $pt.tidy( Q{my $x; $x.?say} );
#		isa-ok $parsed, 'Perl6::Tidy::Root';
#		is $parsed.child.elems, 1;
#	}, Q[.?say];
#
#	subtest {
#		plan 2;
#
#		my $parsed = $pt.tidy( Q{my $x; $x.*say} );
#		isa-ok $parsed, 'Perl6::Tidy::Root';
#		is $parsed.child.elems, 1;
#	}, Q[.*say];
#
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
#	subtest {
#		plan 2;
#
#		my $parsed = $pt.tidy( Q{my $x; $x.=} );
#		isa-ok $parsed, 'Perl6::Tidy::Root';
#		is $parsed.child.elems, 1;
#	}, Q[.=];
#
#	subtest {
#		plan 2;
#
#		my $parsed = $pt.tidy( Q{my $x; $x.^} );
#		isa-ok $parsed, 'Perl6::Tidy::Root';
#		is $parsed.child.elems, 1;
#	}, Q[.^];
#
#	subtest {
#		plan 2;
#
#		my $parsed = $pt.tidy( Q{my $x; $x.:} );
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
#	subtest {
#		plan 2;
#
#		my $parsed = $pt.tidy( Q{my $x; +^$x} );
#		isa-ok $parsed, 'Perl6::Tidy::Root';
#		is $parsed.child.elems, 1;
#	}, Q[+^];
#
#	subtest {
#		plan 2;
#
#		my $parsed = $pt.tidy( Q{my $x; ~^$x} );
#		isa-ok $parsed, 'Perl6::Tidy::Root';
#		is $parsed.child.elems, 1;
#	}, Q[~^];
#
#	subtest {
#		plan 2;
#
#		my $parsed = $pt.tidy( Q{my $x; ?^$x} );
#		isa-ok $parsed, 'Perl6::Tidy::Root';
#		is $parsed.child.elems, 1;
#	}, Q[?^];
#
#	subtest {
#		plan 2;
#
#		my $parsed = $pt.tidy( Q{my $x; ?$x} );
#		isa-ok $parsed, 'Perl6::Tidy::Root';
#		is $parsed.child.elems, 1;
#	}, Q[?];
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
}, 'structural infix';

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

#`(

Chaining infix 	!= == < <= > >= eq ne lt le gt ge ~~ === eqv !eqv =~=
Tight and 	&&
Tight or 	|| ^^ // min max
Conditional 	?? !! ff fff
Item assignment 	= => += -= **= xx= .=
Loose unary 	so not
Comma operator 	, :
List infix 	Z minmax X X~ X* Xeqv ...
List prefix 	print push say die map substr ... [+] [*] any Z=
Loose and 	and andthen
Loose or 	or xor orelse
Sequencer 	<==, ==>, <<==, ==>>

)

# vim: ft=perl6
