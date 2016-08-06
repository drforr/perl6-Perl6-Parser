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

		my $parsed = $pt.parse-source( Q:to[_END_] );
my $x; $x.say
_END_
		ok $pt.validate( $parsed );
	}, Q{.say};

	subtest {
		plan 1;

		my $parsed = $pt.parse-source( Q:to[_END_] );
my $x; $x.+say
_END_
		ok $pt.validate( $parsed );
	}, Q{.+say};

	subtest {
		plan 1;

		my $parsed = $pt.parse-source( Q:to[_END_] );
my $x; $x.?say
_END_
		ok $pt.validate( $parsed );
	}, Q{.?say};

	subtest {
		plan 1;

		my $parsed = $pt.parse-source( Q:to[_END_] );
my $x; $x.*say
_END_
		ok $pt.validate( $parsed );
	}, Q{.*say};

	subtest {
		plan 1;

		my $parsed = $pt.parse-source( Q:to[_END_] );
my $x; $x.()
_END_
		ok $pt.validate( $parsed );
	}, Q{.()};

	subtest {
		plan 1;

		my $parsed = $pt.parse-source( Q:to[_END_] );
my $x; $x.[]
_END_
		ok $pt.validate( $parsed );
	}, Q{.[]};

	subtest {
		plan 1;

		my $parsed = $pt.parse-source( Q:to[_END_] );
my $x; $x.{}
_END_
		ok $pt.validate( $parsed );
	}, Q{.{}};

	subtest {
		plan 1;

		my $parsed = $pt.parse-source( Q:to[_END_] );
my $x; $x.<>
_END_
		ok $pt.validate( $parsed );
	}, Q{.<>};

	subtest {
		plan 1;

		my $parsed = $pt.parse-source( Q:to[_END_] );
my $x; $x.«»
_END_
		ok $pt.validate( $parsed );
	}, Q{.«»};

	subtest {
		plan 1;

		my $parsed = $pt.parse-source( Q:to[_END_] );
my $x; $x.Foo::Bar
_END_
		ok $pt.validate( $parsed );
	}, Q{.::};

	subtest {
		plan 1;

		my $parsed = $pt.parse-source( Q:to[_END_] );
my $x; $x.=say
_END_
		ok $pt.validate( $parsed );
	}, Q{.=};

	subtest {
		plan 1;

		my $parsed = $pt.parse-source( Q:to[_END_] );
my $x; $x.^say
_END_
		ok $pt.validate( $parsed );
	}, Q{.^};

	subtest {
		plan 1;

		my $parsed = $pt.parse-source( Q:to[_END_] );
my $x; $x.:say
_END_
		ok $pt.validate( $parsed );
	}, Q{.:};
}, Q{postfix};

subtest {
	plan 2;

	subtest {
		plan 1;

		my $parsed = $pt.parse-source( Q:to[_END_] );
my $x; $x++
_END_
		ok $pt.validate( $parsed );
	}, Q{++};

	subtest {
		plan 1;

		my $parsed = $pt.parse-source( Q:to[_END_] );
my $x; $x--
_END_
		ok $pt.validate( $parsed );
	}, Q{--};
}, Q{autoincrement};

subtest {
	plan 1;

	subtest {
		plan 1;

		my $parsed = $pt.parse-source( Q:to[_END_] );
3 ** 2
_END_
		ok $pt.validate( $parsed );
	}, Q{**};
}, Q{exponentiation};

subtest {
	plan 12;

	subtest {
		plan 1;

		my $parsed = $pt.parse-source( Q:to[_END_] );
my $x; !$x
_END_
		ok $pt.validate( $parsed );
	}, Q{!};

	subtest {
		plan 1;

		my $parsed = $pt.parse-source( Q:to[_END_] );
my $x; +$x
_END_
		ok $pt.validate( $parsed );
	}, Q{+};

	subtest {
		plan 1;

		my $parsed = $pt.parse-source( Q:to[_END_] );
my $x; -$x
_END_
		ok $pt.validate( $parsed );
	}, Q{-};

	subtest {
		plan 1;

		my $parsed = $pt.parse-source( Q:to[_END_] );
my $x; ~$x
_END_
		ok $pt.validate( $parsed );
	}, Q{~};

	subtest {
		plan 1;

		my $parsed = $pt.parse-source( Q:to[_END_] );
my $x; ?$x
_END_
		ok $pt.validate( $parsed );
	}, Q{?};

	subtest {
		plan 1;

		my $parsed = $pt.parse-source( Q:to[_END_] );
my $x; ?$x
_END_
		ok $pt.validate( $parsed );
	}, Q{?};

	subtest {
		plan 1;

		my $parsed = $pt.parse-source( Q:to[_END_] );
my $x; |$x
_END_
		ok $pt.validate( $parsed );
	}, Q{|};

	subtest {
		plan 1;

		my $parsed = $pt.parse-source( Q:to[_END_] );
my $x; ||$x
_END_
		ok $pt.validate( $parsed );
	}, Q{||};

	subtest {
		plan 1;

		my $parsed = $pt.parse-source( Q:to[_END_] );
my $x; +^$x
_END_
		ok $pt.validate( $parsed );
	}, Q{+^};

	subtest {
		plan 1;

		my $parsed = $pt.parse-source( Q:to[_END_] );
my $x; ~^$x
_END_
		ok $pt.validate( $parsed );
	}, Q{~^};

	subtest {
		plan 1;

		my $parsed = $pt.parse-source( Q:to[_END_] );
my $x; ?^$x
_END_
		ok $pt.validate( $parsed );
	}, Q{?^};

	subtest {
		plan 1;

		my $parsed = $pt.parse-source( Q:to[_END_] );
my $x; ?$x
_END_
		ok $pt.validate( $parsed );
	}, Q{?};
}, Q{symbolic unary};

subtest {
	plan 15;

	subtest {
		plan 1;

		my $parsed = $pt.parse-source( Q:to[_END_] );
3 * 2
_END_
		ok $pt.validate( $parsed );
	}, Q{*};

	subtest {
		plan 1;

		my $parsed = $pt.parse-source( Q:to[_END_] );
3 / 2
_END_
		ok $pt.validate( $parsed );
	}, Q{/};

	subtest {
		plan 1;

		my $parsed = $pt.parse-source( Q:to[_END_] );
3 % 2
_END_
		ok $pt.validate( $parsed );
	}, Q{%};

	subtest {
		plan 1;

		my $parsed = $pt.parse-source( Q:to[_END_] );
3 %% 2
_END_
		ok $pt.validate( $parsed );
	}, Q{%%};

	subtest {
		plan 1;

		my $parsed = $pt.parse-source( Q:to[_END_] );
3 +& 2
_END_
		ok $pt.validate( $parsed );
	}, Q{+&};

	subtest {
		plan 1;

		my $parsed = $pt.parse-source( Q:to[_END_] );
3 +< 2
_END_
		ok $pt.validate( $parsed );
	}, Q{+<};

	subtest {
		plan 1;

		my $parsed = $pt.parse-source( Q:to[_END_] );
3 +> 2
_END_
		ok $pt.validate( $parsed );
	}, Q{+>};

	subtest {
		plan 1;

		my $parsed = $pt.parse-source( Q:to[_END_] );
3 ~& 2
_END_
		ok $pt.validate( $parsed );
	}, Q{~&};

	subtest {
		plan 1;

		my $parsed = $pt.parse-source( Q:to[_END_] );
3 ~< 2
_END_
		ok $pt.validate( $parsed );
	}, Q{~<};

	subtest {
		plan 1;

		my $parsed = $pt.parse-source( Q:to[_END_] );
3 ~> 2
_END_
		ok $pt.validate( $parsed );
	}, Q{~>};

	subtest {
		plan 1;

		my $parsed = $pt.parse-source( Q:to[_END_] );
3 ?& 2
_END_
		ok $pt.validate( $parsed );
	}, Q{?&};

	subtest {
		plan 1;

		my $parsed = $pt.parse-source( Q:to[_END_] );
3 div 2
_END_
		ok $pt.validate( $parsed );
	}, Q{div};

	subtest {
		plan 1;

		my $parsed = $pt.parse-source( Q:to[_END_] );
3 mod 2
_END_
		ok $pt.validate( $parsed );
	}, Q{mod};

	subtest {
		plan 1;

		my $parsed = $pt.parse-source( Q:to[_END_] );
3 gcd 2
_END_
		ok $pt.validate( $parsed );
	}, Q{gcd};

	subtest {
		plan 1;

		my $parsed = $pt.parse-source( Q:to[_END_] );
3 lcm 2
_END_
		ok $pt.validate( $parsed );
	}, Q{lcm};
}, Q{multiplicative};

subtest {
	plan 8;

	subtest {
		plan 1;

		my $parsed = $pt.parse-source( Q:to[_END_] );
3 + 2
_END_
		ok $pt.validate( $parsed );
	}, Q{+};

	subtest {
		plan 1;

		my $parsed = $pt.parse-source( Q:to[_END_] );
3 - 2
_END_
		ok $pt.validate( $parsed );
	}, Q{-};

	subtest {
		plan 1;

		my $parsed = $pt.parse-source( Q:to[_END_] );
3 +| 2
_END_
		ok $pt.validate( $parsed );
	}, Q{+|};

	subtest {
		plan 1;

		my $parsed = $pt.parse-source( Q:to[_END_] );
3 +^ 2
_END_
		ok $pt.validate( $parsed );
	}, Q{+^};

	subtest {
		plan 1;

		my $parsed = $pt.parse-source( Q:to[_END_] );
3 ~| 2
_END_
		ok $pt.validate( $parsed );
	}, Q{~|};

	subtest {
		plan 1;

		my $parsed = $pt.parse-source( Q:to[_END_] );
3 ~^ 2
_END_
		ok $pt.validate( $parsed );
	}, Q{~^};

	subtest {
		plan 1;

		my $parsed = $pt.parse-source( Q:to[_END_] );
3 ?| 2
_END_
		ok $pt.validate( $parsed );
	}, Q{?|};

	subtest {
		plan 1;

		my $parsed = $pt.parse-source( Q:to[_END_] );
3 ?^ 2
_END_
		ok $pt.validate( $parsed );
	}, Q{?^};
}, Q{additive};

subtest {
	plan 2;

	subtest {
		plan 1;

		my $parsed = $pt.parse-source( Q:to[_END_] );
'a' x 2
_END_
		ok $pt.validate( $parsed );
	}, Q{x};

	subtest {
		plan 1;

		my $parsed = $pt.parse-source( Q:to[_END_] );
'a' xx 2
_END_
		ok $pt.validate( $parsed );
	}, Q{xx};
}, Q{replication};

subtest {
	plan 1;

	subtest {
		plan 1;

		my $parsed = $pt.parse-source( Q:to[_END_] );
'a' ~ 2
_END_
		ok $pt.validate( $parsed );
	}, Q{~};
}, Q{concatenation};

subtest {
	plan 1;

	subtest {
		plan 1;

		my $parsed = $pt.parse-source( Q:to[_END_] );
'a' & 2
_END_
		ok $pt.validate( $parsed );
	}, Q{&};
}, Q{junctive and};

subtest {
	plan 2;

	subtest {
		plan 1;

		my $parsed = $pt.parse-source( Q:to[_END_] );
'a' | 2
_END_
		ok $pt.validate( $parsed );
	}, Q{|};

	subtest {
		plan 1;

		my $parsed = $pt.parse-source( Q:to[_END_] );
'a' ^ 2
_END_
		ok $pt.validate( $parsed );
	}, Q{^};
}, Q{junctive or};

subtest {
	plan 2;

	subtest {
		plan 1;

		my $parsed = $pt.parse-source( Q:to[_END_] );
my $x; temp $x
_END_
		ok $pt.validate( $parsed );
	}, Q{temp};

	subtest {
		plan 1;

		my $parsed = $pt.parse-source( Q:to[_END_] );
my $x; let $x
_END_
		ok $pt.validate( $parsed );
	}, Q{let};
}, Q{named unary};

subtest {
	plan 9;

	subtest {
		plan 1;

		my $parsed = $pt.parse-source( Q:to[_END_] );
1 but 2
_END_
		ok $pt.validate( $parsed );
	}, Q{but};

	subtest {
		plan 1;

		my $parsed = $pt.parse-source( Q:to[_END_] );
1 does 2
_END_
		ok $pt.validate( $parsed );
	}, Q{does};

	subtest {
		plan 1;

		my $parsed = $pt.parse-source( Q:to[_END_] );
1 <=> 2
_END_
		ok $pt.validate( $parsed );
	}, Q{<=>};

	subtest {
		plan 1;

		my $parsed = $pt.parse-source( Q:to[_END_] );
1 leg 2
_END_
		ok $pt.validate( $parsed );
	}, Q{leg};

	subtest {
		plan 1;

		my $parsed = $pt.parse-source( Q:to[_END_] );
'a' cmp 'b'
_END_
		ok $pt.validate( $parsed );
	}, Q{cmp};

	subtest {
		plan 1;

		my $parsed = $pt.parse-source( Q:to[_END_] );
1 .. 2
_END_
		ok $pt.validate( $parsed );
	}, Q{..};

	subtest {
		plan 1;

		my $parsed = $pt.parse-source( Q:to[_END_] );
1 ..^ 2
_END_
		ok $pt.validate( $parsed );
	}, Q{..^};

	subtest {
		plan 1;

		my $parsed = $pt.parse-source( Q:to[_END_] );
1 ^.. 2
_END_
		ok $pt.validate( $parsed );
	}, Q{^..};

	subtest {
		plan 1;

		my $parsed = $pt.parse-source( Q:to[_END_] );
1 ^..^ 2
_END_
		ok $pt.validate( $parsed );
	}, Q{^..^};
}, Q{structural infix};

subtest {
	plan 17;

	subtest {
		plan 1;

		my $parsed = $pt.parse-source( Q:to[_END_] );
3 != 2
_END_
		ok $pt.validate( $parsed );
	}, Q{!=};

	subtest {
		plan 1;

		my $parsed = $pt.parse-source( Q:to[_END_] );
3 == 2
_END_
		ok $pt.validate( $parsed );
	}, Q{==};

	subtest {
		plan 1;

		my $parsed = $pt.parse-source( Q:to[_END_] );
3 < 2
_END_
		ok $pt.validate( $parsed );
	}, Q{<};

	subtest {
		plan 1;

		my $parsed = $pt.parse-source( Q:to[_END_] );
3 <= 2
_END_
		ok $pt.validate( $parsed );
	}, Q{<=};

	subtest {
		plan 1;

		my $parsed = $pt.parse-source( Q:to[_END_] );
3 > 2
_END_
		ok $pt.validate( $parsed );
	}, Q{>};

	subtest {
		plan 1;

		my $parsed = $pt.parse-source( Q:to[_END_] );
3 >= 2
_END_
		ok $pt.validate( $parsed );
	}, Q{>=};

	subtest {
		plan 1;

		my $parsed = $pt.parse-source( Q:to[_END_] );
'a' eq 'b'
_END_
		ok $pt.validate( $parsed );
	}, Q{eq};

	subtest {
		plan 1;

		my $parsed = $pt.parse-source( Q:to[_END_] );
'a' ne 'b'
_END_
		ok $pt.validate( $parsed );
	}, Q{ne};

	subtest {
		plan 1;

		my $parsed = $pt.parse-source( Q:to[_END_] );
'a' lt 'b'
_END_
		ok $pt.validate( $parsed );
	}, Q{lt};

	subtest {
		plan 1;

		my $parsed = $pt.parse-source( Q:to[_END_] );
'a' le 'b'
_END_
		ok $pt.validate( $parsed );
	}, Q{le};

	subtest {
		plan 1;

		my $parsed = $pt.parse-source( Q:to[_END_] );
'a' gt 'b'
_END_
		ok $pt.validate( $parsed );
	}, Q{gt};

	subtest {
		plan 1;

		my $parsed = $pt.parse-source( Q:to[_END_] );
'a' ge 'b'
_END_
		ok $pt.validate( $parsed );
	}, Q{ge};

	subtest {
		plan 1;

		my $parsed = $pt.parse-source( Q:to[_END_] );
3 ~~ 2
_END_
		ok $pt.validate( $parsed );
	}, Q{~~};

	subtest {
		plan 1;

		my $parsed = $pt.parse-source( Q:to[_END_] );
3 === 2
_END_
		ok $pt.validate( $parsed );
	}, Q{===};

	subtest {
		plan 1;

		my $parsed = $pt.parse-source( Q:to[_END_] );
3 eqv 2
_END_
		ok $pt.validate( $parsed );
	}, Q{eqv};

	subtest {
		plan 1;

		my $parsed = $pt.parse-source( Q:to[_END_] );
3 !eqv 2
_END_
		ok $pt.validate( $parsed );
	}, Q{!eqv};

	subtest {
		plan 1;

		my $parsed = $pt.parse-source( Q:to[_END_] );
3 =~= 2
_END_
		ok $pt.validate( $parsed );
	}, Q{=~=};
}, Q{chaining infix};

subtest {
	plan 1;

	subtest {
		plan 1;

		my $parsed = $pt.parse-source( Q:to[_END_] );
3 && 2
_END_
		ok $pt.validate( $parsed );
	}, Q{&&};
}, Q{tight and};

subtest {
	plan 5;

	subtest {
		plan 1;

		my $parsed = $pt.parse-source( Q:to[_END_] );
3 || 2
_END_
		ok $pt.validate( $parsed );
	}, Q{||};

	subtest {
		plan 1;

		my $parsed = $pt.parse-source( Q:to[_END_] );
3 ^^ 2
_END_
		ok $pt.validate( $parsed );
	}, Q{^^};

	subtest {
		plan 1;

		my $parsed = $pt.parse-source( Q:to[_END_] );
3 // 2
_END_
		ok $pt.validate( $parsed );
	}, Q{//};

	subtest {
		plan 1;

		my $parsed = $pt.parse-source( Q:to[_END_] );
3 min 2
_END_
		ok $pt.validate( $parsed );
	}, Q{min};

	subtest {
		plan 1;

		my $parsed = $pt.parse-source( Q:to[_END_] );
3 max 2
_END_
		ok $pt.validate( $parsed );
	}, Q{max};
}, Q{tight or};

subtest {
	plan 3;

	subtest {
		plan 1;

		my $parsed = $pt.parse-source( Q:to[_END_] );
3 ?? 2 !! 1
_END_
		ok $pt.validate( $parsed );
	}, Q{??};

	subtest {
		plan 1;

		my $parsed = $pt.parse-source( Q:to[_END_] );
3 ff 2
_END_
		ok $pt.validate( $parsed );
	}, Q{ff};

	subtest {
		plan 1;

		my $parsed = $pt.parse-source( Q:to[_END_] );
3 fff 2
_END_
		ok $pt.validate( $parsed );
	}, Q{fff};
}, Q{conditional};

subtest {
	plan 7;

	subtest {
		plan 1;

		my $parsed = $pt.parse-source( Q:to[_END_] );
my $a; $a = 2
_END_
		ok $pt.validate( $parsed );
	}, Q{=};

	subtest {
		plan 1;

		my $parsed = $pt.parse-source( Q:to[_END_] );
3 => 2
_END_
		ok $pt.validate( $parsed );
	}, Q{=>};

	subtest {
		plan 1;

		my $parsed = $pt.parse-source( Q:to[_END_] );
my $a; $a += 2
_END_
		ok $pt.validate( $parsed );
	}, Q{+=};

	subtest {
		plan 1;

		my $parsed = $pt.parse-source( Q:to[_END_] );
my $a; $a -= 2
_END_
		ok $pt.validate( $parsed );
	}, Q{-=};

	subtest {
		plan 1;

		my $parsed = $pt.parse-source( Q:to[_END_] );
my $a; $a **= 2
_END_
		ok $pt.validate( $parsed );
	}, Q{**=};

	subtest {
		plan 1;

		my $parsed = $pt.parse-source( Q:to[_END_] );
my $a; $a xx= 2
_END_
		ok $pt.validate( $parsed );
	}, Q{xx=};

	subtest {
		plan 1;

		my $parsed = $pt.parse-source( Q:to[_END_] );
my $a; $a .= say
_END_
		ok $pt.validate( $parsed );
	}, Q{.=};
}, Q{item assignment};

subtest {
	plan 2;

	subtest {
		plan 1;

		my $parsed = $pt.parse-source( Q:to[_END_] );
so 2
_END_
		ok $pt.validate( $parsed );
	}, Q{so};

	subtest {
		plan 1;

		my $parsed = $pt.parse-source( Q:to[_END_] );
not 2
_END_
		ok $pt.validate( $parsed );
	}, Q{not};
}, Q{loose unary};

subtest {
	plan 2;

	subtest {
		plan 1;

		my $parsed = $pt.parse-source( Q:to[_END_] );
3 , 2
_END_
		ok $pt.validate( $parsed );
	}, Q{,};

	subtest {
		plan 1;

		my $parsed = $pt.parse-source( Q:to[_END_] );
substr('a': 2)
_END_
		ok $pt.validate( $parsed );
	}, Q{:};
}, Q{comma operator};

subtest {
	plan 6;

	subtest {
		plan 1;

		my $parsed = $pt.parse-source( Q:to[_END_] );
my @a; my @b; @a Z @b
_END_
		ok $pt.validate( $parsed );
	}, Q{Z};

	subtest {
		plan 1;

		my $parsed = $pt.parse-source( Q:to[_END_] );
my @a; my @b; @a minmax @b
_END_
		ok $pt.validate( $parsed );
	}, Q{minmax};

	subtest {
		plan 1;

		my $parsed = $pt.parse-source( Q:to[_END_] );
my @a; my @b; @a X @b
_END_
		ok $pt.validate( $parsed );
	}, Q{X};

	subtest {
		plan 1;

		my $parsed = $pt.parse-source( Q:to[_END_] );
my @a; my @b; @a X~ @b
_END_
		ok $pt.validate( $parsed );
	}, Q{X~};

	subtest {
		plan 1;

		my $parsed = $pt.parse-source( Q:to[_END_] );
my @a; my @b; @a X* @b
_END_
		ok $pt.validate( $parsed );
	}, Q{X*};

	subtest {
		plan 1;

		my $parsed = $pt.parse-source( Q:to[_END_] );
my @a; my @b; @a Xeqv @b
_END_
		ok $pt.validate( $parsed );
	}, Q{Xeqv};
}, Q{list infix};

subtest {
	plan 11;

	subtest {
		plan 1;

		my $parsed = $pt.parse-source( Q:to[_END_] );
my @a; print @a
_END_
		ok $pt.validate( $parsed );
	}, Q{print};

	subtest {
		plan 1;

		my $parsed = $pt.parse-source( Q:to[_END_] );
my @a; push @a, 1
_END_
		ok $pt.validate( $parsed );
	}, Q{push};

	subtest {
		plan 1;

		my $parsed = $pt.parse-source( Q:to[_END_] );
my @a; say @a
_END_
		ok $pt.validate( $parsed );
	}, Q{say};

	subtest {
		plan 1;

		my $parsed = $pt.parse-source( Q:to[_END_] );
my @a; die @a
_END_
		ok $pt.validate( $parsed );
	}, Q{die};

	subtest {
		plan 1;

		my $parsed = $pt.parse-source( Q:to[_END_] );
my @a; map @a, {}
_END_
		ok $pt.validate( $parsed );
	}, Q{map};

	subtest {
		plan 1;

		my $parsed = $pt.parse-source( Q:to[_END_] );
my @a; substr @a
_END_
		ok $pt.validate( $parsed );
	}, Q{substr};

	subtest {
		plan 1;

		my $parsed = $pt.parse-source( Q:to[_END_] );
my @a; ... @a
_END_
		ok $pt.validate( $parsed );
	}, Q{...};

	subtest {
		plan 1;

		my $parsed = $pt.parse-source( Q:to[_END_] );
my @a; [+] @a
_END_
		ok $pt.validate( $parsed );
	}, Q{[+]};

	subtest {
		plan 1;

		my $parsed = $pt.parse-source( Q:to[_END_] );
my @a; [*] @a
_END_
		ok $pt.validate( $parsed );
	}, Q{[*]};

	subtest {
		plan 1;

		my $parsed = $pt.parse-source( Q:to[_END_] );
my @a; any @a
_END_
		ok $pt.validate( $parsed );
	}, Q{any};

	# XXX Is Z= really list *prefix*?
	subtest {
		plan 1;

		my $parsed = $pt.parse-source( Q:to[_END_] );
my @a; my @b; @a Z= @b
_END_
		ok $pt.validate( $parsed );
	}, Q{Z=};
}, Q{list prefix};

subtest {
	plan 2;

	subtest {
		plan 1;

		my $parsed = $pt.parse-source( Q:to[_END_] );
3 and 2
_END_
		ok $pt.validate( $parsed );
	}, Q{and};

	subtest {
		plan 1;

		my $parsed = $pt.parse-source( Q:to[_END_] );
3 andthen 2
_END_
		ok $pt.validate( $parsed );
	}, Q{andthen};
}, Q{loose and};

subtest {
	plan 3;

	subtest {
		plan 1;

		my $parsed = $pt.parse-source( Q:to[_END_] );
3 or 2
_END_
		ok $pt.validate( $parsed );
	}, Q{or};

	subtest {
		plan 1;

		my $parsed = $pt.parse-source( Q:to[_END_] );
3 xor 2
_END_
		ok $pt.validate( $parsed );
	}, Q{xor};

	subtest {
		plan 1;

		my $parsed = $pt.parse-source( Q:to[_END_] );
3 orelse 2
_END_
		ok $pt.validate( $parsed );
	}, Q{orelse};
}, Q{loose or};

subtest {
	plan 2;

	subtest {
		plan 1;

		my $parsed = $pt.parse-source( Q:to[_END_] );
my @a; sort() <== @a
_END_
		ok $pt.validate( $parsed );
	}, Q{<==};

	subtest {
		plan 1;

		my $parsed = $pt.parse-source( Q:to[_END_] );
my @a; @a ==> sort
_END_
		ok $pt.validate( $parsed );
	}, Q{==>};

	todo Q[<<== not implemented yet];
#	subtest {
#		plan 1;
#
#		my $parsed = $pt.parse-source( Q:to[_END_] );
#3 <<== 2
#_END_
#		ok $pt.validate( $parsed );
#	}, Q{<<==};

	todo Q[==>> not implemented yet];
#	subtest {
#		plan 1;
#
#		my $parsed = $pt.parse-source( Q:to[_END_] );
#3 ==>> 2
#_END_
#		ok $pt.validate( $parsed );
#	}, Q{==>>};
}, Q{sequencer};

# vim: ft=perl6
