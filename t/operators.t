use v6;

use Test;
use Perl6::Tidy;

plan 24;

my $pt = Perl6::Tidy.new;
#my $*TRACE = 1;
#my $*DEBUG = 1;

subtest {
	plan 13;

	subtest {
		plan 1;

		my $parsed = $pt.tidy( Q{my $x; $x.say} );
		isa-ok $parsed, Q{Perl6::Document};
	}, Q{.say};

	subtest {
		plan 1;

		my $parsed = $pt.tidy( Q{my $x; $x.+say} );
		isa-ok $parsed, Q{Perl6::Document};
	}, Q{.+say};

	subtest {
		plan 1;

		my $parsed = $pt.tidy( Q{my $x; $x.?say} );
		isa-ok $parsed, Q{Perl6::Document};
	}, Q{.?say};

	subtest {
		plan 1;

		my $parsed = $pt.tidy( Q{my $x; $x.*say} );
		isa-ok $parsed, Q{Perl6::Document};
	}, Q{.*say};

	subtest {
		plan 1;

		my $parsed = $pt.tidy( Q{my $x; $x.()} );
		isa-ok $parsed, Q{Perl6::Document};
	}, Q{.()};

	subtest {
		plan 1;

		my $parsed = $pt.tidy( Q{my $x; $x.[]} );
		isa-ok $parsed, Q{Perl6::Document};
	}, Q{.[]};

	subtest {
		plan 1;

		my $parsed = $pt.tidy( Q{my $x; $x.{}} );
		isa-ok $parsed, Q{Perl6::Document};
	}, Q{.{}};

	subtest {
		plan 1;

		my $parsed = $pt.tidy( Q{my $x; $x.<>} );
		isa-ok $parsed, Q{Perl6::Document};
	}, Q{.<>};

	subtest {
		plan 1;

		my $parsed = $pt.tidy( Q{my $x; $x.«»} );
		isa-ok $parsed, Q{Perl6::Document};
	}, Q{.«»};

	subtest {
		plan 1;

		my $parsed = $pt.tidy( Q{my $x; $x.Foo::Bar} );
		isa-ok $parsed, Q{Perl6::Document};
	}, Q{.::};

	subtest {
		plan 1;

		my $parsed = $pt.tidy( Q{my $x; $x.=say} );
		isa-ok $parsed, Q{Perl6::Document};
	}, Q{.=};

	subtest {
		plan 1;

		my $parsed = $pt.tidy( Q{my $x; $x.^say} );
		isa-ok $parsed, Q{Perl6::Document};
	}, Q{.^};

	subtest {
		plan 1;

		my $parsed = $pt.tidy( Q{my $x; $x.:say} );
		isa-ok $parsed, Q{Perl6::Document};
	}, Q{.:};
}, Q{postfix};

subtest {
	plan 2;

	subtest {
		plan 1;

		my $parsed = $pt.tidy( Q{my $x; $x++} );
		isa-ok $parsed, Q{Perl6::Document};
	}, Q{++};

	subtest {
		plan 1;

		my $parsed = $pt.tidy( Q{my $x; $x--} );
		isa-ok $parsed, Q{Perl6::Document};
	}, Q{--};
}, Q{autoincrement};

subtest {
	plan 1;

	subtest {
		plan 1;

		my $parsed = $pt.tidy( Q{3 ** 2} );
		isa-ok $parsed, Q{Perl6::Document};
	}, Q{**};
}, Q{exponentiation};

subtest {
	plan 12;

	subtest {
		plan 1;

		my $parsed = $pt.tidy( Q{my $x; !$x} );
		isa-ok $parsed, Q{Perl6::Document};
	}, Q{!};

	subtest {
		plan 1;

		my $parsed = $pt.tidy( Q{my $x; +$x} );
		isa-ok $parsed, Q{Perl6::Document};
	}, Q{+};

	subtest {
		plan 1;

		my $parsed = $pt.tidy( Q{my $x; -$x} );
		isa-ok $parsed, Q{Perl6::Document};
	}, Q{-};

	subtest {
		plan 1;

		my $parsed = $pt.tidy( Q{my $x; ~$x} );
		isa-ok $parsed, Q{Perl6::Document};
	}, Q{~};

	subtest {
		plan 1;

		my $parsed = $pt.tidy( Q{my $x; ?$x} );
		isa-ok $parsed, Q{Perl6::Document};
	}, Q{?};

	subtest {
		plan 1;

		my $parsed = $pt.tidy( Q{my $x; ?$x} );
		isa-ok $parsed, Q{Perl6::Document};
	}, Q{?};

	subtest {
		plan 1;

		my $parsed = $pt.tidy( Q{my $x; |$x} );
		isa-ok $parsed, Q{Perl6::Document};
	}, Q{|};

	subtest {
		plan 1;

		my $parsed = $pt.tidy( Q{my $x; ||$x} );
		isa-ok $parsed, Q{Perl6::Document};
	}, Q{||};

	subtest {
		plan 1;

		my $parsed = $pt.tidy( Q{my $x; +^$x} );
		isa-ok $parsed, Q{Perl6::Document};
	}, Q{+^};

	subtest {
		plan 1;

		my $parsed = $pt.tidy( Q{my $x; ~^$x} );
		isa-ok $parsed, Q{Perl6::Document};
	}, Q{~^};

	subtest {
		plan 1;

		my $parsed = $pt.tidy( Q{my $x; ?^$x} );
		isa-ok $parsed, Q{Perl6::Document};
	}, Q{?^};

	subtest {
		plan 1;

		my $parsed = $pt.tidy( Q{my $x; ?$x} );
		isa-ok $parsed, Q{Perl6::Document};
	}, Q{?};
}, Q{symbolic unary};

subtest {
	plan 15;

	subtest {
		plan 1;

		my $parsed = $pt.tidy( Q{3 * 2} );
		isa-ok $parsed, Q{Perl6::Document};
	}, Q{*};

	subtest {
		plan 1;

		my $parsed = $pt.tidy( Q{3 / 2} );
		isa-ok $parsed, Q{Perl6::Document};
	}, Q{/};

	subtest {
		plan 1;

		my $parsed = $pt.tidy( Q{3 % 2} );
		isa-ok $parsed, Q{Perl6::Document};
	}, Q{%};

	subtest {
		plan 1;

		my $parsed = $pt.tidy( Q{3 %% 2} );
		isa-ok $parsed, Q{Perl6::Document};
	}, Q{%%};

	subtest {
		plan 1;

		my $parsed = $pt.tidy( Q{3 +& 2} );
		isa-ok $parsed, Q{Perl6::Document};
	}, Q{+&};

	subtest {
		plan 1;

		my $parsed = $pt.tidy( Q{3 +< 2} );
		isa-ok $parsed, Q{Perl6::Document};
	}, Q{+<};

	subtest {
		plan 1;

		my $parsed = $pt.tidy( Q{3 +> 2} );
		isa-ok $parsed, Q{Perl6::Document};
	}, Q{+>};

	subtest {
		plan 1;

		my $parsed = $pt.tidy( Q{3 ~& 2} );
		isa-ok $parsed, Q{Perl6::Document};
	}, Q{~&};

	subtest {
		plan 1;

		my $parsed = $pt.tidy( Q{3 ~< 2} );
		isa-ok $parsed, Q{Perl6::Document};
	}, Q{~<};

	subtest {
		plan 1;

		my $parsed = $pt.tidy( Q{3 ~> 2} );
		isa-ok $parsed, Q{Perl6::Document};
	}, Q{~>};

	subtest {
		plan 1;

		my $parsed = $pt.tidy( Q{3 ?& 2} );
		isa-ok $parsed, Q{Perl6::Document};
	}, Q{?&};

	subtest {
		plan 1;

		my $parsed = $pt.tidy( Q{3 div 2} );
		isa-ok $parsed, Q{Perl6::Document};
	}, Q{div};

	subtest {
		plan 1;

		my $parsed = $pt.tidy( Q{3 mod 2} );
		isa-ok $parsed, Q{Perl6::Document};
	}, Q{mod};

	subtest {
		plan 1;

		my $parsed = $pt.tidy( Q{3 gcd 2} );
		isa-ok $parsed, Q{Perl6::Document};
	}, Q{gcd};

	subtest {
		plan 1;

		my $parsed = $pt.tidy( Q{3 lcm 2} );
		isa-ok $parsed, Q{Perl6::Document};
	}, Q{lcm};
}, Q{multiplicative};

subtest {
	plan 8;

	subtest {
		plan 1;

		my $parsed = $pt.tidy( Q{3 + 2} );
		isa-ok $parsed, Q{Perl6::Document};
	}, Q{+};

	subtest {
		plan 1;

		my $parsed = $pt.tidy( Q{3 - 2} );
		isa-ok $parsed, Q{Perl6::Document};
	}, Q{-};

	subtest {
		plan 1;

		my $parsed = $pt.tidy( Q{3 +| 2} );
		isa-ok $parsed, Q{Perl6::Document};
	}, Q{+|};

	subtest {
		plan 1;

		my $parsed = $pt.tidy( Q{3 +^ 2} );
		isa-ok $parsed, Q{Perl6::Document};
	}, Q{+^};

	subtest {
		plan 1;

		my $parsed = $pt.tidy( Q{3 ~| 2} );
		isa-ok $parsed, Q{Perl6::Document};
	}, Q{~|};

	subtest {
		plan 1;

		my $parsed = $pt.tidy( Q{3 ~^ 2} );
		isa-ok $parsed, Q{Perl6::Document};
	}, Q{~^};

	subtest {
		plan 1;

		my $parsed = $pt.tidy( Q{3 ?| 2} );
		isa-ok $parsed, Q{Perl6::Document};
	}, Q{?|};

	subtest {
		plan 1;

		my $parsed = $pt.tidy( Q{3 ?^ 2} );
		isa-ok $parsed, Q{Perl6::Document};
	}, Q{?^};
}, Q{additive};

subtest {
	plan 2;

	subtest {
		plan 1;

		my $parsed = $pt.tidy( Q{'a' x 2} );
		isa-ok $parsed, Q{Perl6::Document};
	}, Q{x};

	subtest {
		plan 1;

		my $parsed = $pt.tidy( Q{'a' xx 2} );
		isa-ok $parsed, Q{Perl6::Document};
	}, Q{xx};
}, Q{replication};

subtest {
	plan 1;

	subtest {
		plan 1;

		my $parsed = $pt.tidy( Q{'a' ~ 2} );
		isa-ok $parsed, Q{Perl6::Document};
	}, Q{~};
}, Q{concatenation};

subtest {
	plan 1;

	subtest {
		plan 1;

		my $parsed = $pt.tidy( Q{'a' & 2} );
		isa-ok $parsed, Q{Perl6::Document};
	}, Q{&};
}, Q{junctive and};

subtest {
	plan 2;

	subtest {
		plan 1;

		my $parsed = $pt.tidy( Q{'a' | 2} );
		isa-ok $parsed, Q{Perl6::Document};
	}, Q{|};

	subtest {
		plan 1;

		my $parsed = $pt.tidy( Q{'a' ^ 2} );
		isa-ok $parsed, Q{Perl6::Document};
	}, Q{^};
}, Q{junctive or};

subtest {
	plan 2;

	subtest {
		plan 1;

		my $parsed = $pt.tidy( Q{my $x; temp $x} );
		isa-ok $parsed, Q{Perl6::Document};
	}, Q{temp};

	subtest {
		plan 1;

		my $parsed = $pt.tidy( Q{my $x; let $x} );
		isa-ok $parsed, Q{Perl6::Document};
	}, Q{let};
}, Q{named unary};

subtest {
	plan 9;

	subtest {
		plan 1;

		my $parsed = $pt.tidy( Q{1 but 2} );
		isa-ok $parsed, Q{Perl6::Document};
	}, Q{but};

	subtest {
		plan 1;

		my $parsed = $pt.tidy( Q{1 does 2} );
		isa-ok $parsed, Q{Perl6::Document};
	}, Q{does};

	subtest {
		plan 1;

		my $parsed = $pt.tidy( Q{1 <=> 2} );
		isa-ok $parsed, Q{Perl6::Document};
	}, Q{<=>};

	subtest {
		plan 1;

		my $parsed = $pt.tidy( Q{1 leg 2} );
		isa-ok $parsed, Q{Perl6::Document};
	}, Q{leg};

	subtest {
		plan 1;

		my $parsed = $pt.tidy( Q{'a' cmp 'b'} );
		isa-ok $parsed, Q{Perl6::Document};
	}, Q{cmp};

	subtest {
		plan 1;

		my $parsed = $pt.tidy( Q{1 .. 2} );
		isa-ok $parsed, Q{Perl6::Document};
	}, Q{..};

	subtest {
		plan 1;

		my $parsed = $pt.tidy( Q{1 ..^ 2} );
		isa-ok $parsed, Q{Perl6::Document};
	}, Q{..^};

	subtest {
		plan 1;

		my $parsed = $pt.tidy( Q{1 ^.. 2} );
		isa-ok $parsed, Q{Perl6::Document};
	}, Q{^..};

	subtest {
		plan 1;

		my $parsed = $pt.tidy( Q{1 ^..^ 2} );
		isa-ok $parsed, Q{Perl6::Document};
	}, Q{^..^};
}, Q{structural infix};

subtest {
	plan 17;

	subtest {
		plan 1;

		my $parsed = $pt.tidy( Q{3 != 2} );
		isa-ok $parsed, Q{Perl6::Document};
	}, Q{!=};

	subtest {
		plan 1;

		my $parsed = $pt.tidy( Q{3 == 2} );
		isa-ok $parsed, Q{Perl6::Document};
	}, Q{==};

	subtest {
		plan 1;

		my $parsed = $pt.tidy( Q{3 < 2} );
		isa-ok $parsed, Q{Perl6::Document};
	}, Q{<};

	subtest {
		plan 1;

		my $parsed = $pt.tidy( Q{3 <= 2} );
		isa-ok $parsed, Q{Perl6::Document};
	}, Q{<=};

	subtest {
		plan 1;

		my $parsed = $pt.tidy( Q{3 > 2} );
		isa-ok $parsed, Q{Perl6::Document};
	}, Q{>};

	subtest {
		plan 1;

		my $parsed = $pt.tidy( Q{3 >= 2} );
		isa-ok $parsed, Q{Perl6::Document};
	}, Q{>=};

	subtest {
		plan 1;

		my $parsed = $pt.tidy( Q{'a' eq 'b'} );
		isa-ok $parsed, Q{Perl6::Document};
	}, Q{eq};

	subtest {
		plan 1;

		my $parsed = $pt.tidy( Q{'a' ne 'b'} );
		isa-ok $parsed, Q{Perl6::Document};
	}, Q{ne};

	subtest {
		plan 1;

		my $parsed = $pt.tidy( Q{'a' lt 'b'} );
		isa-ok $parsed, Q{Perl6::Document};
	}, Q{lt};

	subtest {
		plan 1;

		my $parsed = $pt.tidy( Q{'a' le 'b'} );
		isa-ok $parsed, Q{Perl6::Document};
	}, Q{le};

	subtest {
		plan 1;

		my $parsed = $pt.tidy( Q{'a' gt 'b'} );
		isa-ok $parsed, Q{Perl6::Document};
	}, Q{gt};

	subtest {
		plan 1;

		my $parsed = $pt.tidy( Q{'a' ge 'b'} );
		isa-ok $parsed, Q{Perl6::Document};
	}, Q{ge};

	subtest {
		plan 1;

		my $parsed = $pt.tidy( Q{3 ~~ 2} );
		isa-ok $parsed, Q{Perl6::Document};
	}, Q{~~};

	subtest {
		plan 1;

		my $parsed = $pt.tidy( Q{3 === 2} );
		isa-ok $parsed, Q{Perl6::Document};
	}, Q{===};

	subtest {
		plan 1;

		my $parsed = $pt.tidy( Q{3 eqv 2} );
		isa-ok $parsed, Q{Perl6::Document};
	}, Q{eqv};

	subtest {
		plan 1;

		my $parsed = $pt.tidy( Q{3 !eqv 2} );
		isa-ok $parsed, Q{Perl6::Document};
	}, Q{!eqv};

	subtest {
		plan 1;

		my $parsed = $pt.tidy( Q{3 =~= 2} );
		isa-ok $parsed, Q{Perl6::Document};
	}, Q{=~=};
}, Q{chaining infix};

subtest {
	plan 1;

	subtest {
		plan 1;

		my $parsed = $pt.tidy( Q{3 && 2} );
		isa-ok $parsed, Q{Perl6::Document};
	}, Q{&&};
}, Q{tight and};

subtest {
	plan 5;

	subtest {
		plan 1;

		my $parsed = $pt.tidy( Q{3 || 2} );
		isa-ok $parsed, Q{Perl6::Document};
	}, Q{||};

	subtest {
		plan 1;

		my $parsed = $pt.tidy( Q{3 ^^ 2} );
		isa-ok $parsed, Q{Perl6::Document};
	}, Q{^^};

	subtest {
		plan 1;

		my $parsed = $pt.tidy( Q{3 // 2} );
		isa-ok $parsed, Q{Perl6::Document};
	}, Q{//};

	subtest {
		plan 1;

		my $parsed = $pt.tidy( Q{3 min 2} );
		isa-ok $parsed, Q{Perl6::Document};
	}, Q{min};

	subtest {
		plan 1;

		my $parsed = $pt.tidy( Q{3 max 2} );
		isa-ok $parsed, Q{Perl6::Document};
	}, Q{max};
}, Q{tight or};

subtest {
	plan 3;

	subtest {
		plan 1;

		my $parsed = $pt.tidy( Q{3 ?? 2 !! 1} );
		isa-ok $parsed, Q{Perl6::Document};
	}, Q{??};

	subtest {
		plan 1;

		my $parsed = $pt.tidy( Q{3 ff 2} );
		isa-ok $parsed, Q{Perl6::Document};
	}, Q{ff};

	subtest {
		plan 1;

		my $parsed = $pt.tidy( Q{3 fff 2} );
		isa-ok $parsed, Q{Perl6::Document};
	}, Q{fff};
}, Q{conditional};

subtest {
	plan 7;

	subtest {
		plan 1;

		my $parsed = $pt.tidy( Q{my $a; $a = 2} );
		isa-ok $parsed, Q{Perl6::Document};
	}, Q{=};

	subtest {
		plan 1;

		my $parsed = $pt.tidy( Q{3 => 2} );
		isa-ok $parsed, Q{Perl6::Document};
	}, Q{=>};

	subtest {
		plan 1;

		my $parsed = $pt.tidy( Q{my $a; $a += 2} );
		isa-ok $parsed, Q{Perl6::Document};
	}, Q{+=};

	subtest {
		plan 1;

		my $parsed = $pt.tidy( Q{my $a; $a -= 2} );
		isa-ok $parsed, Q{Perl6::Document};
	}, Q{-=};

	subtest {
		plan 1;

		my $parsed = $pt.tidy( Q{my $a; $a **= 2} );
		isa-ok $parsed, Q{Perl6::Document};
	}, Q{**=};

	subtest {
		plan 1;

		my $parsed = $pt.tidy( Q{my $a; $a xx= 2} );
		isa-ok $parsed, Q{Perl6::Document};
	}, Q{xx=};

	subtest {
		plan 1;

		my $parsed = $pt.tidy( Q{my $a; $a .= say} );
		isa-ok $parsed, Q{Perl6::Document};
	}, Q{.=};
}, Q{item assignment};

subtest {
	plan 2;

	subtest {
		plan 1;

		my $parsed = $pt.tidy( Q{so 2} );
		isa-ok $parsed, Q{Perl6::Document};
	}, Q{so};

	subtest {
		plan 1;

		my $parsed = $pt.tidy( Q{not 2} );
		isa-ok $parsed, Q{Perl6::Document};
	}, Q{not};
}, Q{loose unary};

subtest {
	plan 2;

	subtest {
		plan 1;

		my $parsed = $pt.tidy( Q{3 , 2} );
		isa-ok $parsed, Q{Perl6::Document};
	}, Q{,};

	subtest {
		plan 1;

		my $parsed = $pt.tidy( Q{substr('a': 2)} );
		isa-ok $parsed, Q{Perl6::Document};
	}, Q{:};
}, Q{comma operator};

subtest {
	plan 6;

	subtest {
		plan 1;

		my $parsed = $pt.tidy( Q{my @a; my @b; @a Z @b} );
		isa-ok $parsed, Q{Perl6::Document};
	}, Q{Z};

	subtest {
		plan 1;

		my $parsed = $pt.tidy( Q{my @a; my @b; @a minmax @b} );
		isa-ok $parsed, Q{Perl6::Document};
	}, Q{minmax};

	subtest {
		plan 1;

		my $parsed = $pt.tidy( Q{my @a; my @b; @a X @b} );
		isa-ok $parsed, Q{Perl6::Document};
	}, Q{X};

	subtest {
		plan 1;

		my $parsed = $pt.tidy( Q{my @a; my @b; @a X~ @b} );
		isa-ok $parsed, Q{Perl6::Document};
	}, Q{X~};

	subtest {
		plan 1;

		my $parsed = $pt.tidy( Q{my @a; my @b; @a X* @b} );
		isa-ok $parsed, Q{Perl6::Document};
	}, Q{X*};

	subtest {
		plan 1;

		my $parsed = $pt.tidy( Q{my @a; my @b; @a Xeqv @b} );
		isa-ok $parsed, Q{Perl6::Document};
	}, Q{Xeqv};
}, Q{list infix};

subtest {
	plan 11;

	subtest {
		plan 1;

		my $parsed = $pt.tidy( Q{my @a; print @a} );
		isa-ok $parsed, Q{Perl6::Document};
	}, Q{print};

	subtest {
		plan 1;

		my $parsed = $pt.tidy( Q{my @a; push @a, 1} );
		isa-ok $parsed, Q{Perl6::Document};
	}, Q{push};

	subtest {
		plan 1;

		my $parsed = $pt.tidy( Q{my @a; say @a} );
		isa-ok $parsed, Q{Perl6::Document};
	}, Q{say};

	subtest {
		plan 1;

		my $parsed = $pt.tidy( Q{my @a; die @a} );
		isa-ok $parsed, Q{Perl6::Document};
	}, Q{die};

	subtest {
		plan 1;

		my $parsed = $pt.tidy( Q{my @a; map @a, {}} );
		isa-ok $parsed, Q{Perl6::Document};
	}, Q{map};

	subtest {
		plan 1;

		my $parsed = $pt.tidy( Q{my @a; substr @a} );
		isa-ok $parsed, Q{Perl6::Document};
	}, Q{substr};

	subtest {
		plan 1;

		my $parsed = $pt.tidy( Q{my @a; ... @a} );
		isa-ok $parsed, Q{Perl6::Document};
	}, Q{...};

	subtest {
		plan 1;

		my $parsed = $pt.tidy( Q{my @a; [+] @a} );
		isa-ok $parsed, Q{Perl6::Document};
	}, Q{[+]};

	subtest {
		plan 1;

		my $parsed = $pt.tidy( Q{my @a; [*] @a} );
		isa-ok $parsed, Q{Perl6::Document};
	}, Q{[*]};

	subtest {
		plan 1;

		my $parsed = $pt.tidy( Q{my @a; any @a} );
		isa-ok $parsed, Q{Perl6::Document};
	}, Q{any};

	# XXX Is Z= really list *prefix*?
	subtest {
		plan 1;

		my $parsed = $pt.tidy( Q{my @a; my @b; @a Z= @b} );
		isa-ok $parsed, Q{Perl6::Document};
	}, Q{Z=};
}, Q{list prefix};

subtest {
	plan 2;

	subtest {
		plan 1;

		my $parsed = $pt.tidy( Q{3 and 2} );
		isa-ok $parsed, Q{Perl6::Document};
	}, Q{and};

	subtest {
		plan 1;

		my $parsed = $pt.tidy( Q{3 andthen 2} );
		isa-ok $parsed, Q{Perl6::Document};
	}, Q{andthen};
}, Q{loose and};

subtest {
	plan 3;

	subtest {
		plan 1;

		my $parsed = $pt.tidy( Q{3 or 2} );
		isa-ok $parsed, Q{Perl6::Document};
	}, Q{or};

	subtest {
		plan 1;

		my $parsed = $pt.tidy( Q{3 xor 2} );
		isa-ok $parsed, Q{Perl6::Document};
	}, Q{xor};

	subtest {
		plan 1;

		my $parsed = $pt.tidy( Q{3 orelse 2} );
		isa-ok $parsed, Q{Perl6::Document};
	}, Q{orelse};
}, Q{loose or};

subtest {
	plan 2;

	subtest {
		plan 1;

		my $parsed = $pt.tidy( Q{my @a; sort() <== @a} );
		isa-ok $parsed, Q{Perl6::Document};
	}, Q{<==};

	subtest {
		plan 1;

		my $parsed = $pt.tidy( Q{my @a; @a ==> sort} );
		isa-ok $parsed, Q{Perl6::Document};
	}, Q{==>};

	todo Q[<<== not implemented yet];
#	subtest {
#		plan 1;
#
#		my $parsed = $pt.tidy( Q{3 <<== 2} );
#		isa-ok $parsed, Q{Perl6::Document};
#	}, Q{<<==};

	todo Q[==>> not implemented yet];
#	subtest {
#		plan 1;
#
#		my $parsed = $pt.tidy( Q{3 ==>> 2} );
#		isa-ok $parsed, Q{Perl6::Document};
#	}, Q{==>>};
}, Q{sequencer};

# vim: ft=perl6
