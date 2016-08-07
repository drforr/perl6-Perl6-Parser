use v6;

use Test;
use Perl6::Tidy;

plan 25;

#`(
Please note for the record that these tests aren't meant to cover the
admittedly bewildering array (hee) of inputs these operators can take, they're
just meant to cover the fact that the basic operators format correctly.

The code being tested will never be executed, so I'm not concerned about whether
a sample produces warnings or not. It'd be nice if it didn't, but not at the
cost of extraneous terms.

There are probably ways to bum down some of these tests as well, but as long
as the operators remain operators I don't mind.

For those operators that can generate or exist in list context, we're also not
concerned about the context they generate in these tests. The text is meant to
be very simple.

There are also +=, R= and /= variants, those will be in separate files.
As will the [+] hyperoperator, as it'll probably get a test suite of its own.
)

my $pt = Perl6::Tidy.new;
#my $*TRACE = 1;
#my $*DEBUG = 1;

subtest {
	plan 0;
}, Q{Term Precedence};

subtest {
	plan 0;
}, Q{Method Postfix Precedence};

subtest {
	plan 0;
}, Q{Autoincrement Precedence};

subtest {
	plan 0;
}, Q{Exponentiation Precedence};

subtest {
	plan 0;
}, Q{Symbolic Unary Precedence};

subtest {
	plan 0;
}, Q{Multipicative Precedence};

subtest {
	plan 0;
}, Q{Additive Precedence};

subtest {
	plan 0;
}, Q{Replication Precedence};

subtest {
	plan 0;
}, Q{Concatenation Precedence};

subtest {
	plan 0;
}, Q{Junctive AND Precedence};

subtest {
	plan 0;
}, Q{Junctive OR Precedence};

subtest {
	plan 0;
}, Q{Named Unary Precedence};

subtest {
	plan 0;
}, Q{Nonchaining Binary Precedence};

subtest {
	plan 0;
}, Q{Chaining Binary Precedence};

subtest {
	plan 0;
}, Q{Tight AND Precedence};

subtest {
	plan 0;
}, Q{Tight OR Precedence};

subtest {
	plan 0;
}, Q{Conditional Operator Precedence};

subtest {
	plan 2;

	subtest {
		plan 3;

		my $parsed = $pt.parse-source( Q:to[_END_] );
my $a = 1
_END_
		my $tree = $pt.build-tree( $parsed );
		ok $pt.validate( $parsed ), Q{valid};
		ok (grep { $_ ~~ Perl6::Operator }, $tree.child.[0].child),
			Q{found operator};
#		is $pt.format( $tree ), Q{my $a = 1}, Q{formatted};
		is $pt.format( $tree ), Q{my$a=1}, Q{formatted};
	}, Q{=};

	subtest {
		plan 3;

		my $parsed = $pt.parse-source( Q:to[_END_] );
a => 1
_END_
		my $tree = $pt.build-tree( $parsed );
		ok $pt.validate( $parsed ), Q{valid};
		ok (grep { $_ ~~ Perl6::Operator }, $tree.child.[0].child),
			Q{found operator};
#		is $pt.format( $tree ), Q{a => 1}, Q{formatted};
		is $pt.format( $tree ), Q{a=>1}, Q{formatted};
	}, Q{so};
}, Q{Item Assignment Precedence};

subtest {
	plan 2;

	subtest {
		plan 3;

		my $parsed = $pt.parse-source( Q:to[_END_] );
not 1
_END_
		my $tree = $pt.build-tree( $parsed );
		ok $pt.validate( $parsed ), Q{valid};
		ok (grep { $_ ~~ Perl6::Operator }, $tree.child.[0].child),
			Q{found operator};
#		is $pt.format( $tree ), Q{not 1}, Q{formatted};
		is $pt.format( $tree ), Q{not1}, Q{formatted};
	}, Q{not};

	subtest {
		plan 3;

		my $parsed = $pt.parse-source( Q:to[_END_] );
so 1
_END_
		my $tree = $pt.build-tree( $parsed );
		ok $pt.validate( $parsed ), Q{valid};
		ok (grep { $_ ~~ Perl6::Operator }, $tree.child.[0].child),
			Q{found operator};
#		is $pt.format( $tree ), Q{so 1}, Q{formatted};
		is $pt.format( $tree ), Q{so1}, Q{formatted};
	}, Q{so};
}, Q{Loose Unary Precedence};

subtest {
	plan 1;

	subtest {
		plan 3;

		my $parsed = $pt.parse-source( Q:to[_END_] );
3 , 2
_END_
		my $tree = $pt.build-tree( $parsed );
		ok $pt.validate( $parsed ), Q{valid};
		ok (grep { $_ ~~ Perl6::Operator }, $tree.child.[0].child),
			Q{found operator};
#		is $pt.format( $tree ), Q{3 , 2}, Q{formatted};
		is $pt.format( $tree ), Q{3,2}, Q{formatted};
	}, Q{,};

	note ": may need list context";
}, Q{Comma Operator Precedence};

# XXX 'X' and 'Z' have a lot of variants, test separately?
#
subtest {
	plan 3;

	subtest {
		plan 3;

		my $parsed = $pt.parse-source( Q:to[_END_] );
3 Z 2
_END_
		my $tree = $pt.build-tree( $parsed );
		ok (grep { $_ ~~ Perl6::Operator }, $tree.child.[0].child),
			Q{found operator};
		ok $pt.validate( $parsed ), Q{valid};
#		is $pt.format( $tree ), Q{3 Z 2}, Q{formatted};
		is $pt.format( $tree ), Q{3Z2}, Q{formatted};
	}, Q{Z};

	subtest {
		plan 3;

		my $parsed = $pt.parse-source( Q:to[_END_] );
3 X 2
_END_
		my $tree = $pt.build-tree( $parsed );
		ok $pt.validate( $parsed ), Q{valid};
		ok (grep { $_ ~~ Perl6::Operator }, $tree.child.[0].child),
			Q{found operator};
#		is $pt.format( $tree ), Q{3 X 2}, Q{formatted};
		is $pt.format( $tree ), Q{3X2}, Q{formatted};
	}, Q{X};

	subtest {
		plan 3;

		my $parsed = $pt.parse-source( Q:to[_END_] );
1 ... 2
_END_
		my $tree = $pt.build-tree( $parsed );
		ok $pt.validate( $parsed ), Q{valid};
		ok (grep { $_ ~~ Perl6::Operator }, $tree.child.[0].child),
			Q{found operator};
#		is $pt.format( $tree ), Q{1 ... 2}, Q{formatted};
		is $pt.format( $tree ), Q{1...2}, Q{formatted};
	}, Q{...};
}, Q{List Infix Precedence};

subtest {
	plan 5;

	subtest {
		plan 3;

		my $parsed = $pt.parse-source( Q:to[_END_] );
my $a = 1
_END_
		my $tree = $pt.build-tree( $parsed );
		ok $pt.validate( $parsed ), Q{valid};
		ok (grep { $_ ~~ Perl6::Operator }, $tree.child.[0].child),
			Q{found operator};
#		is $pt.format( $tree ), Q{my $a = 1}, Q{formatted};
		is $pt.format( $tree ), Q{my$a=1}, Q{formatted};
	}, Q{=};

	subtest {
		plan 3;

		my $parsed = $pt.parse-source( Q:to[_END_] );
my $a := 1
_END_
		my $tree = $pt.build-tree( $parsed );
		ok $pt.validate( $parsed ), Q{valid};
		ok (grep { $_ ~~ Perl6::Operator }, $tree.child.[0].child),
			Q{found operator};
#		is $pt.format( $tree ), Q{my $a := 1}, Q{formatted};
		is $pt.format( $tree ), Q{my$a:=1}, Q{formatted};
	}, Q{:=};

	note "::= NIY";

	subtest {
		plan 3;

		my $parsed = $pt.parse-source( Q:to[_END_] );
...
_END_
		my $tree = $pt.build-tree( $parsed );
		ok $pt.validate( $parsed ), Q{valid};
		ok (grep { $_ ~~ Perl6::Operator }, $tree.child.[0].child),
			Q{found operator};
#		is $pt.format( $tree ), Q{...}, Q{formatted};
		is $pt.format( $tree ), Q{...}, Q{formatted};
	}, Q{...};

	subtest {
		plan 3;

		my $parsed = $pt.parse-source( Q:to[_END_] );
!!!
_END_
		my $tree = $pt.build-tree( $parsed );
		ok $pt.validate( $parsed ), Q{valid};
		ok (grep { $_ ~~ Perl6::Operator }, $tree.child.[0].child),
			Q{found operator};
#		is $pt.format( $tree ), Q{!!!}, Q{formatted};
		is $pt.format( $tree ), Q{!!!}, Q{formatted};
	}, Q{!!!};

	subtest {
		plan 3;

		my $parsed = $pt.parse-source( Q:to[_END_] );
???
_END_
		my $tree = $pt.build-tree( $parsed );
		ok $pt.validate( $parsed ), Q{valid};
		ok (grep { $_ ~~ Perl6::Operator }, $tree.child.[0].child),
			Q{found operator};
#		is $pt.format( $tree ), Q{???}, Q{formatted};
		is $pt.format( $tree ), Q{???}, Q{formatted};
	}, Q{???};

	note "Undecided on [+] implementation";
}, Q{List Prefix Precedence};

subtest {
	plan 2;

	subtest {
		plan 3;

		my $parsed = $pt.parse-source( Q:to[_END_] );
3 and 2
_END_
		my $tree = $pt.build-tree( $parsed );
		ok $pt.validate( $parsed ), Q{valid};
		ok (grep { $_ ~~ Perl6::Operator }, $tree.child.[0].child),
			Q{found operator};
#		is $pt.format( $tree ), Q{3 and 2}, Q{formatted};
		is $pt.format( $tree ), Q{3and2}, Q{formatted};
	}, Q{and};

	subtest {
		plan 3;

		my $parsed = $pt.parse-source( Q:to[_END_] );
3 andthen 2
_END_
		my $tree = $pt.build-tree( $parsed );
		ok $pt.validate( $parsed ), Q{valid};
		ok (grep { $_ ~~ Perl6::Operator }, $tree.child.[0].child),
			Q{found operator};
#		is $pt.format( $tree ), Q{3 andthen 2}, Q{formatted};
		is $pt.format( $tree ), Q{3andthen2}, Q{formatted};
	}, Q{andthen};
}, Q{Loose AND Precedence};

subtest {
	plan 2;

	subtest {
		plan 3;

		my $parsed = $pt.parse-source( Q:to[_END_] );
3 or 2
_END_
		my $tree = $pt.build-tree( $parsed );
		ok $pt.validate( $parsed ), Q{valid};
		ok (grep { $_ ~~ Perl6::Operator }, $tree.child.[0].child),
			Q{found operator};
#		is $pt.format( $tree ), Q{3 or 2}, Q{formatted};
		is $pt.format( $tree ), Q{3or2}, Q{formatted};
	}, Q{or};

	subtest {
		plan 3;

		my $parsed = $pt.parse-source( Q:to[_END_] );
3 orelse 2
_END_
		my $tree = $pt.build-tree( $parsed );
		ok $pt.validate( $parsed ), Q{valid};
		ok (grep { $_ ~~ Perl6::Operator }, $tree.child.[0].child),
			Q{found operator};
#		is $pt.format( $tree ), Q{3 orelse 2}, Q{formatted};
		is $pt.format( $tree ), Q{3orelse2}, Q{formatted};
	}, Q{orelse};
}, Q{Loose OR Precedence};

subtest {
	plan 2;

	subtest {
		plan 3;

		my $parsed = $pt.parse-source( Q:to[_END_].chomp );
my @a; @a <== 'a'
_END_
		my $tree = $pt.build-tree( $parsed );
		ok $pt.validate( $parsed ), Q{valid};
		ok (grep { $_ ~~ Perl6::Operator }, $tree.child.[1].child),
			Q{found operator};
#		is $pt.format( $tree ), Q{my @a; @a <== 'a'}, Q{formatted};
		is $pt.format( $tree ), Q[my@a;@a<=='a'], Q{formatted};
	}, Q{<==};

	subtest {
		plan 3;

		my $parsed = $pt.parse-source( Q:to[_END_].chomp );
my @a; 'a' ==> @a
_END_
		my $tree = $pt.build-tree( $parsed );
		ok $pt.validate( $parsed ), Q{valid};
		ok (grep { $_ ~~ Perl6::Operator }, $tree.child.[1].child),
			Q{found operator};
#		is $pt.format( $tree ), Q{my @a; 'a' ==> @a}, Q{formatted};
		is $pt.format( $tree ), Q{my@a;'a'==>@a}, Q{formatted};
	}, Q{==>};
}, Q{Sequencer Precedence};

#`(

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

}, Q{list prefix};

)

# vim: ft=perl6
