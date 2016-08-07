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
	plan 4;

	subtest {
		plan 3;

		my $parsed = $pt.parse-source( Q:to[_END_] );
<a b>
_END_
		my $tree = $pt.build-tree( $parsed );
		ok $pt.validate( $parsed ), Q{valid};
		ok (grep { $_ ~~ Perl6::Operator }, $tree.child.[0].child),
			Q{found operator};
#		is $pt.format( $tree ), Q{<a b>}, Q{formatted};
		is $pt.format( $tree ), Q{<a b>}, Q{formatted};
	}, Q{<>};

	subtest {
		plan 3;

		my $parsed = $pt.parse-source( Q:to[_END_] );
( 1 )
_END_
		my $tree = $pt.build-tree( $parsed );
		ok $pt.validate( $parsed ), Q{valid};
		ok (grep { $_ ~~ Perl6::Operator }, $tree.child.[0].child),
			Q{found operator};
#		is $pt.format( $tree ), Q{( 1 )}, Q{formatted};
		is $pt.format( $tree ), Q{(1)}, Q{formatted};
	}, Q{()};

	subtest {
		plan 2;

		my $parsed = $pt.parse-source( Q:to[_END_] );
{ 1 }
_END_
		my $tree = $pt.build-tree( $parsed );
		ok $pt.validate( $parsed ), Q{valid};
		# XXX Technically it's an operator, but that could confuse.
#		is $pt.format( $tree ), Q[{ 1 }], Q{formatted};
		is $pt.format( $tree ), Q[{1}], Q{formatted};
	}, Q[{}];

	subtest {
		plan 3;

		my $parsed = $pt.parse-source( Q:to[_END_] );
[ 1 ]
_END_
		my $tree = $pt.build-tree( $parsed );
		ok $pt.validate( $parsed ), Q{valid};
		ok (grep { $_ ~~ Perl6::Operator }, $tree.child.[0].child),
			Q{found operator};
#		is $pt.format( $tree ), Q{[ 1 ]}, Q{formatted};
		is $pt.format( $tree ), Q{[1]}, Q{formatted};
	}, Q{[]}
}, Q{Term Precedence};

subtest {
	plan 15;

	subtest {
		plan 3;

		# Whitespace sensitive between 'a' and '[' ']'
		my $parsed = $pt.parse-source( Q:to[_END_] );
my @a; @a[ 2 ]
_END_
		my $tree = $pt.build-tree( $parsed );
		ok $pt.validate( $parsed ), Q{valid};
		ok (grep { $_ ~~ Perl6::Operator }, $tree.child.[1].child),
			Q{found operator};
#		is $pt.format( $tree ), Q{my @a; @a[ 2 ]}, Q{formatted};
		is $pt.format( $tree ), Q{my@a;@a[2]}, Q{formatted};
	}, Q{[]};

	subtest {
		plan 3;

		# Whitespace sensitive between 'a' and '{' '}'
		# {} need [] as delimiters (due to braiding?)
		my $parsed = $pt.parse-source( Q:to[_END_] );
my %a; %a{ "foo" }
_END_
		my $tree = $pt.build-tree( $parsed );
		ok $pt.validate( $parsed ), Q{valid};
		ok (grep { $_ ~~ Perl6::Operator }, $tree.child.[1].child),
			Q{found operator};
#		is $pt.format( $tree ), Q[my %a; %a{ "foo" }], Q{formatted};
		is $pt.format( $tree ), Q[my%a;%a{"foo"}], Q{formatted};
	}, Q[%a{}];

	subtest {
		plan 3;

		# Whitespace sensitive between 'a' and '<'
		my $parsed = $pt.parse-source( Q:to[_END_] );
my %a; %a< foo >
_END_
		my $tree = $pt.build-tree( $parsed );
		ok $pt.validate( $parsed ), Q{valid};
		ok (grep { $_ ~~ Perl6::Operator }, $tree.child.[1].child),
			Q{found operator};
#		is $pt.format( $tree ), Q[my %a; %a< foo >], Q{formatted};
		is $pt.format( $tree ), Q[my%a;%a<foo>], Q{formatted};
	}, Q[%a<>];

	subtest {
		plan 3;

		# Whitespace sensitive between 'a' and '<'
		my $parsed = $pt.parse-source( Q:to[_END_] );
my %a; %a« foo »
_END_
		my $tree = $pt.build-tree( $parsed );
		ok $pt.validate( $parsed ), Q{valid};
		ok (grep { $_ ~~ Perl6::Operator }, $tree.child.[1].child),
			Q{found operator};
#		is $pt.format( $tree ), Q[my %a; %a« foo »], Q{formatted};
		is $pt.format( $tree ), Q[my%a;%a«foo»], Q{formatted};
	}, Q[%a«»];

	subtest {
		plan 3;

		# Whitespace sensitive between 'chomp' and '(' ')'
		my $parsed = $pt.parse-source( Q:to[_END_] );
chomp( )
_END_
		my $tree = $pt.build-tree( $parsed );
		ok $pt.validate( $parsed ), Q{valid};
		ok (grep { $_ ~~ Perl6::Operator }, $tree.child.[0].child),
			Q{found operator};
#		is $pt.format( $tree ), Q{chomp( )}, Q{formatted};
		is $pt.format( $tree ), Q{chomp()}, Q{formatted};
	}, Q{()};

	subtest {
		plan 3;

		my $parsed = $pt.parse-source( Q:to[_END_] );
42.round
_END_
		my $tree = $pt.build-tree( $parsed );
		ok $pt.validate( $parsed ), Q{valid};
		ok (grep { $_ ~~ Perl6::Operator }, $tree.child.[0].child),
			Q{found operator};
#		is $pt.format( $tree ), Q{42.round}, Q{formatted};
		is $pt.format( $tree ), Q{42.round}, Q{formatted};
	}, Q{.};

	subtest {
		plan 3;

		my $parsed = $pt.parse-source( Q:to[_END_] );
42.&round
_END_
		my $tree = $pt.build-tree( $parsed );
		ok $pt.validate( $parsed ), Q{valid};
		ok (grep { $_ ~~ Perl6::Operator }, $tree.child.[0].child),
			Q{found operator};
#		is $pt.format( $tree ), Q{42.&round}, Q{formatted};
		is $pt.format( $tree ), Q{42.&round}, Q{formatted};
	}, Q{.&};

	subtest {
		plan 3;

		my $parsed = $pt.parse-source( Q:to[_END_] );
Int.=round
_END_
		my $tree = $pt.build-tree( $parsed );
		ok $pt.validate( $parsed ), Q{valid};
		ok (grep { $_ ~~ Perl6::Operator }, $tree.child.[0].child),
			Q{found operator};
#		is $pt.format( $tree ), Q{Int.=round}, Q{formatted};
		is $pt.format( $tree ), Q{Int.=round}, Q{formatted};
	}, Q{.=};

	subtest {
		plan 3;

		my $parsed = $pt.parse-source( Q:to[_END_] );
42.^name
_END_
		my $tree = $pt.build-tree( $parsed );
		ok $pt.validate( $parsed ), Q{valid};
		ok (grep { $_ ~~ Perl6::Operator }, $tree.child.[0].child),
			Q{found operator};
#		is $pt.format( $tree ), Q{42.^name}, Q{formatted};
		is $pt.format( $tree ), Q{42.^name}, Q{formatted};
	}, Q{.^};

	subtest {
		plan 3;

		my $parsed = $pt.parse-source( Q:to[_END_] );
42.?name
_END_
		my $tree = $pt.build-tree( $parsed );
		ok $pt.validate( $parsed ), Q{valid};
		ok (grep { $_ ~~ Perl6::Operator }, $tree.child.[0].child),
			Q{found operator};
#		is $pt.format( $tree ), Q{42.?name}, Q{formatted};
		is $pt.format( $tree ), Q{42.?name}, Q{formatted};
	}, Q{.?};

	subtest {
		plan 3;

		my $parsed = $pt.parse-source( Q:to[_END_] );
42.+name
_END_
		my $tree = $pt.build-tree( $parsed );
		ok $pt.validate( $parsed ), Q{valid};
		ok (grep { $_ ~~ Perl6::Operator }, $tree.child.[0].child),
			Q{found operator};
#		is $pt.format( $tree ), Q{42.+name}, Q{formatted};
		is $pt.format( $tree ), Q{42.+name}, Q{formatted};
	}, Q{.+};

	subtest {
		plan 3;

		my $parsed = $pt.parse-source( Q:to[_END_] );
42.*name
_END_
		my $tree = $pt.build-tree( $parsed );
		ok $pt.validate( $parsed ), Q{valid};
		ok (grep { $_ ~~ Perl6::Operator }, $tree.child.[0].child),
			Q{found operator};
#		is $pt.format( $tree ), Q{42.*name}, Q{formatted};
		is $pt.format( $tree ), Q{42.*name}, Q{formatted};
	}, Q{.*};

	subtest {
		plan 3;

		my $parsed = $pt.parse-source( Q:to[_END_] );
42>>.say
_END_
		my $tree = $pt.build-tree( $parsed );
		ok $pt.validate( $parsed ), Q{valid};
		ok (grep { $_ ~~ Perl6::Operator }, $tree.child.[0].child),
			Q{found operator};
#		is $pt.format( $tree ), Q{42>>.say}, Q{formatted};
		is $pt.format( $tree ), Q{42>>.say}, Q{formatted};
	}, Q{>>.};

	subtest {
		plan 3;

		my $parsed = $pt.parse-source( Q:to[_END_] );
my $a; $a.:<++>
_END_
		my $tree = $pt.build-tree( $parsed );
		ok $pt.validate( $parsed ), Q{valid};
		ok (grep { $_ ~~ Perl6::Operator }, $tree.child.[1].child),
			Q{found operator};
#		is $pt.format( $tree ), Q{my $a; $a.:<++>}, Q{formatted};
		is $pt.format( $tree ), Q{my$a;$a.:<++>}, Q{formatted};
	}, Q{.:};

	subtest {
		plan 3;

		my $parsed = $pt.parse-source( Q:to[_END_] );
my $a; $a.Foo::Bar
_END_
		my $tree = $pt.build-tree( $parsed );
		ok $pt.validate( $parsed ), Q{valid};
		ok (grep { $_ ~~ Perl6::Operator }, $tree.child.[1].child),
			Q{found operator};
#		is $pt.format( $tree ), Q{my $a; $a.Foo::Bar}, Q{formatted};
		is $pt.format( $tree ), Q{my$a;$a.Foo::Bar}, Q{formatted};
	}, Q{.::};
}, Q{Method Postfix Precedence};

subtest {
	plan 4;

	subtest {
		plan 3;

		my $parsed = $pt.parse-source( Q:to[_END_] );
my $a; ++ $a
_END_
		my $tree = $pt.build-tree( $parsed );
		ok $pt.validate( $parsed ), Q{valid};
		ok (grep { $_ ~~ Perl6::Operator }, $tree.child.[1].child),
			Q{found operator};
#		is $pt.format( $tree ), Q{my $a; ++ $a}, Q{formatted};
		is $pt.format( $tree ), Q{my$a;++$a}, Q{formatted};
	}, Q{++$a};

	subtest {
		plan 3;

		my $parsed = $pt.parse-source( Q:to[_END_] );
my $a; -- $a
_END_
		my $tree = $pt.build-tree( $parsed );
		ok $pt.validate( $parsed ), Q{valid};
		ok (grep { $_ ~~ Perl6::Operator }, $tree.child.[1].child),
			Q{found operator};
#		is $pt.format( $tree ), Q{my $a; -- $a}, Q{formatted};
		is $pt.format( $tree ), Q{my$a;--$a}, Q{formatted};
	}, Q{--$a};

	subtest {
		plan 3;

		# XXX Note whitespace sensitivity here.
		my $parsed = $pt.parse-source( Q:to[_END_] );
my $a; $a++
_END_
		my $tree = $pt.build-tree( $parsed );
		ok $pt.validate( $parsed ), Q{valid};
		ok (grep { $_ ~~ Perl6::Operator }, $tree.child.[1].child),
			Q{found operator};
#		is $pt.format( $tree ), Q{my $a; $a++}, Q{formatted};
		is $pt.format( $tree ), Q{my$a;$a++}, Q{formatted};
	}, Q{$a++};

	subtest {
		plan 3;

		# XXX Note whitespace sensitivity here.
		my $parsed = $pt.parse-source( Q:to[_END_] );
my $a; $a--
_END_
		my $tree = $pt.build-tree( $parsed );
		ok $pt.validate( $parsed ), Q{valid};
		ok (grep { $_ ~~ Perl6::Operator }, $tree.child.[1].child),
			Q{found operator};
#		is $pt.format( $tree ), Q{my $a; $a--}, Q{formatted};
		is $pt.format( $tree ), Q{my$a;$a--}, Q{formatted};
	}, Q{$a--};
}, Q{Autoincrement Precedence};

subtest {
	plan 1;

	subtest {
		plan 3;

		my $parsed = $pt.parse-source( Q:to[_END_] );
1 ** 2
_END_
		my $tree = $pt.build-tree( $parsed );
		ok $pt.validate( $parsed ), Q{valid};
		ok (grep { $_ ~~ Perl6::Operator }, $tree.child.[0].child),
			Q{found operator};
#		is $pt.format( $tree ), Q{1 ** 2}, Q{formatted};
		is $pt.format( $tree ), Q{1**2}, Q{formatted};
	}, Q{?};
}, Q{Exponentiation Precedence};

subtest {
	plan 9;

	subtest {
		plan 3;

		my $parsed = $pt.parse-source( Q:to[_END_] );
? 2
_END_
		my $tree = $pt.build-tree( $parsed );
		ok $pt.validate( $parsed ), Q{valid};
		ok (grep { $_ ~~ Perl6::Operator }, $tree.child.[0].child),
			Q{found operator};
#		is $pt.format( $tree ), Q{? 2}, Q{formatted};
		is $pt.format( $tree ), Q{?2}, Q{formatted};
	}, Q{?};

	subtest {
		plan 3;

		my $parsed = $pt.parse-source( Q:to[_END_] );
! 2
_END_
		my $tree = $pt.build-tree( $parsed );
		ok $pt.validate( $parsed ), Q{valid};
		ok (grep { $_ ~~ Perl6::Operator }, $tree.child.[0].child),
			Q{found operator};
#		is $pt.format( $tree ), Q{! 2}, Q{formatted};
		is $pt.format( $tree ), Q{!2}, Q{formatted};
	}, Q{!};

	subtest {
		plan 3;

		my $parsed = $pt.parse-source( Q:to[_END_] );
+ 2
_END_
		my $tree = $pt.build-tree( $parsed );
		ok $pt.validate( $parsed ), Q{valid};
		ok (grep { $_ ~~ Perl6::Operator }, $tree.child.[0].child),
			Q{found operator};
#		is $pt.format( $tree ), Q{+ 2}, Q{formatted};
		is $pt.format( $tree ), Q{+2}, Q{formatted};
	}, Q{+};

	subtest {
		plan 3;

		my $parsed = $pt.parse-source( Q:to[_END_] );
- 2
_END_
		my $tree = $pt.build-tree( $parsed );
		ok $pt.validate( $parsed ), Q{valid};
		ok (grep { $_ ~~ Perl6::Operator }, $tree.child.[0].child),
			Q{found operator};
#		is $pt.format( $tree ), Q{- 2}, Q{formatted};
		is $pt.format( $tree ), Q{-2}, Q{formatted};
	}, Q{-};

	subtest {
		plan 3;

		my $parsed = $pt.parse-source( Q:to[_END_] );
~ 2
_END_
		my $tree = $pt.build-tree( $parsed );
		ok $pt.validate( $parsed ), Q{valid};
		ok (grep { $_ ~~ Perl6::Operator }, $tree.child.[0].child),
			Q{found operator};
#		is $pt.format( $tree ), Q{~ 2}, Q{formatted};
		is $pt.format( $tree ), Q{~2}, Q{formatted};
	}, Q{~};

	subtest {
		plan 3;

		my $parsed = $pt.parse-source( Q:to[_END_] );
| 2
_END_
		my $tree = $pt.build-tree( $parsed );
		ok $pt.validate( $parsed ), Q{valid};
		ok (grep { $_ ~~ Perl6::Operator }, $tree.child.[0].child),
			Q{found operator};
#		is $pt.format( $tree ), Q{| 2}, Q{formatted};
		is $pt.format( $tree ), Q{|2}, Q{formatted};
	}, Q{|};

	subtest {
		plan 3;

		my $parsed = $pt.parse-source( Q:to[_END_] );
+^ 2
_END_
		my $tree = $pt.build-tree( $parsed );
		ok $pt.validate( $parsed ), Q{valid};
		ok (grep { $_ ~~ Perl6::Operator }, $tree.child.[0].child),
			Q{found operator};
#		is $pt.format( $tree ), Q{+^ 2}, Q{formatted};
		is $pt.format( $tree ), Q{+^2}, Q{formatted};
	}, Q{+^};

	subtest {
		plan 3;

		my $parsed = $pt.parse-source( Q:to[_END_] );
?^ 2
_END_
		my $tree = $pt.build-tree( $parsed );
		ok $pt.validate( $parsed ), Q{valid};
		ok (grep { $_ ~~ Perl6::Operator }, $tree.child.[0].child),
			Q{found operator};
#		is $pt.format( $tree ), Q{?^ 2}, Q{formatted};
		is $pt.format( $tree ), Q{?^2}, Q{formatted};
	}, Q{?^};

	subtest {
		plan 3;

		my $parsed = $pt.parse-source( Q:to[_END_] );
^ 2
_END_
		my $tree = $pt.build-tree( $parsed );
		ok $pt.validate( $parsed ), Q{valid};
		ok (grep { $_ ~~ Perl6::Operator }, $tree.child.[0].child),
			Q{found operator};
#		is $pt.format( $tree ), Q{^ 2}, Q{formatted};
		is $pt.format( $tree ), Q{^2}, Q{formatted};
	}, Q{^};
}, Q{Symbolic Unary Precedence};

subtest {
	plan 11;

	subtest {
		plan 3;

		my $parsed = $pt.parse-source( Q:to[_END_] );
1 * 2
_END_
		my $tree = $pt.build-tree( $parsed );
		ok $pt.validate( $parsed ), Q{valid};
		ok (grep { $_ ~~ Perl6::Operator }, $tree.child.[0].child),
			Q{found operator};
#		is $pt.format( $tree ), Q{1 * 2}, Q{formatted};
		is $pt.format( $tree ), Q{1*2}, Q{formatted};
	}, Q{*};

	subtest {
		plan 3;

		my $parsed = $pt.parse-source( Q:to[_END_] );
1 / 2
_END_
		my $tree = $pt.build-tree( $parsed );
		ok $pt.validate( $parsed ), Q{valid};
		ok (grep { $_ ~~ Perl6::Operator }, $tree.child.[0].child),
			Q{found operator};
#		is $pt.format( $tree ), Q{1 / 2}, Q{formatted};
		is $pt.format( $tree ), Q{1/2}, Q{formatted};
	}, Q{/};

	subtest {
		plan 3;

		my $parsed = $pt.parse-source( Q:to[_END_] );
1 div 2
_END_
		my $tree = $pt.build-tree( $parsed );
		ok $pt.validate( $parsed ), Q{valid};
		ok (grep { $_ ~~ Perl6::Operator }, $tree.child.[0].child),
			Q{found operator};
#		is $pt.format( $tree ), Q{1 div 2}, Q{formatted};
		is $pt.format( $tree ), Q{1div2}, Q{formatted};
	}, Q{div};

	subtest {
		plan 3;

		my $parsed = $pt.parse-source( Q:to[_END_] );
1 % 2
_END_
		my $tree = $pt.build-tree( $parsed );
		ok $pt.validate( $parsed ), Q{valid};
		ok (grep { $_ ~~ Perl6::Operator }, $tree.child.[0].child),
			Q{found operator};
#		is $pt.format( $tree ), Q{1 % 2}, Q{formatted};
		is $pt.format( $tree ), Q{1%2}, Q{formatted};
	}, Q{%};

	subtest {
		plan 3;

		my $parsed = $pt.parse-source( Q:to[_END_] );
1 %% 2
_END_
		my $tree = $pt.build-tree( $parsed );
		ok $pt.validate( $parsed ), Q{valid};
		ok (grep { $_ ~~ Perl6::Operator }, $tree.child.[0].child),
			Q{found operator};
#		is $pt.format( $tree ), Q{1 %% 2}, Q{formatted};
		is $pt.format( $tree ), Q{1%%2}, Q{formatted};
	}, Q{%%};

	subtest {
		plan 3;

		my $parsed = $pt.parse-source( Q:to[_END_] );
1 mod 2
_END_
		my $tree = $pt.build-tree( $parsed );
		ok $pt.validate( $parsed ), Q{valid};
		ok (grep { $_ ~~ Perl6::Operator }, $tree.child.[0].child),
			Q{found operator};
#		is $pt.format( $tree ), Q{1 mod 2}, Q{formatted};
		is $pt.format( $tree ), Q{1mod2}, Q{formatted};
	}, Q{mod};

	subtest {
		plan 3;

		my $parsed = $pt.parse-source( Q:to[_END_] );
1 +& 2
_END_
		my $tree = $pt.build-tree( $parsed );
		ok $pt.validate( $parsed ), Q{valid};
		ok (grep { $_ ~~ Perl6::Operator }, $tree.child.[0].child),
			Q{found operator};
#		is $pt.format( $tree ), Q{1 +& 2}, Q{formatted};
		is $pt.format( $tree ), Q{1+&2}, Q{formatted};
	}, Q{+&};

	subtest {
		plan 3;

		my $parsed = $pt.parse-source( Q:to[_END_] );
1 +< 2
_END_
		my $tree = $pt.build-tree( $parsed );
		ok $pt.validate( $parsed ), Q{valid};
		ok (grep { $_ ~~ Perl6::Operator }, $tree.child.[0].child),
			Q{found operator};
#		is $pt.format( $tree ), Q{1 +< 2}, Q{formatted};
		is $pt.format( $tree ), Q{1+<2}, Q{formatted};
	}, Q{+<};

	subtest {
		plan 3;

		my $parsed = $pt.parse-source( Q:to[_END_] );
1 +> 2
_END_
		my $tree = $pt.build-tree( $parsed );
		ok $pt.validate( $parsed ), Q{valid};
		ok (grep { $_ ~~ Perl6::Operator }, $tree.child.[0].child),
			Q{found operator};
#		is $pt.format( $tree ), Q{1 +> 2}, Q{formatted};
		is $pt.format( $tree ), Q{1+>2}, Q{formatted};
	}, Q{+>};

	subtest {
		plan 3;

		my $parsed = $pt.parse-source( Q:to[_END_] );
1 gcd 2
_END_
		my $tree = $pt.build-tree( $parsed );
		ok $pt.validate( $parsed ), Q{valid};
		ok (grep { $_ ~~ Perl6::Operator }, $tree.child.[0].child),
			Q{found operator};
#		is $pt.format( $tree ), Q{1 gcd 2}, Q{formatted};
		is $pt.format( $tree ), Q{1gcd2}, Q{formatted};
	}, Q{gcd};

	subtest {
		plan 3;

		my $parsed = $pt.parse-source( Q:to[_END_] );
1 lcm 2
_END_
		my $tree = $pt.build-tree( $parsed );
		ok $pt.validate( $parsed ), Q{valid};
		ok (grep { $_ ~~ Perl6::Operator }, $tree.child.[0].child),
			Q{found operator};
#		is $pt.format( $tree ), Q{1 lcm 2}, Q{formatted};
		is $pt.format( $tree ), Q{1lcm2}, Q{formatted};
	}, Q{lcm};
}, Q{Multipicative Precedence};

subtest {
	plan 5;

	subtest {
		plan 3;

		my $parsed = $pt.parse-source( Q:to[_END_] );
1 + 2
_END_
		my $tree = $pt.build-tree( $parsed );
		ok $pt.validate( $parsed ), Q{valid};
		ok (grep { $_ ~~ Perl6::Operator }, $tree.child.[0].child),
			Q{found operator};
#		is $pt.format( $tree ), Q{1 + 2}, Q{formatted};
		is $pt.format( $tree ), Q{1+2}, Q{formatted};
	}, Q{+};

	subtest {
		plan 3;

		my $parsed = $pt.parse-source( Q:to[_END_] );
1 - 2
_END_
		my $tree = $pt.build-tree( $parsed );
		ok $pt.validate( $parsed ), Q{valid};
		ok (grep { $_ ~~ Perl6::Operator }, $tree.child.[0].child),
			Q{found operator};
#		is $pt.format( $tree ), Q{1 - 2}, Q{formatted};
		is $pt.format( $tree ), Q{1-2}, Q{formatted};
	}, Q{-};

	subtest {
		plan 3;

		my $parsed = $pt.parse-source( Q:to[_END_] );
1 +| 2
_END_
		my $tree = $pt.build-tree( $parsed );
		ok $pt.validate( $parsed ), Q{valid};
		ok (grep { $_ ~~ Perl6::Operator }, $tree.child.[0].child),
			Q{found operator};
#		is $pt.format( $tree ), Q{1 +| 2}, Q{formatted};
		is $pt.format( $tree ), Q{1+|2}, Q{formatted};
	}, Q{+|};

	subtest {
		plan 3;

		my $parsed = $pt.parse-source( Q:to[_END_] );
1 +^ 2
_END_
		my $tree = $pt.build-tree( $parsed );
		ok $pt.validate( $parsed ), Q{valid};
		ok (grep { $_ ~~ Perl6::Operator }, $tree.child.[0].child),
			Q{found operator};
#		is $pt.format( $tree ), Q{1 +^ 2}, Q{formatted};
		is $pt.format( $tree ), Q{1+^2}, Q{formatted};
	}, Q{+^};

	subtest {
		plan 3;

		my $parsed = $pt.parse-source( Q:to[_END_] );
1 ?| 2
_END_
		my $tree = $pt.build-tree( $parsed );
		ok $pt.validate( $parsed ), Q{valid};
		ok (grep { $_ ~~ Perl6::Operator }, $tree.child.[0].child),
			Q{found operator};
#		is $pt.format( $tree ), Q{1 ?| 2}, Q{formatted};
		is $pt.format( $tree ), Q{1?|2}, Q{formatted};
	}, Q{?|};
}, Q{Additive Precedence};

subtest {
	plan 2;

	subtest {
		plan 3;

		my $parsed = $pt.parse-source( Q:to[_END_] );
1 x 2
_END_
		my $tree = $pt.build-tree( $parsed );
		ok $pt.validate( $parsed ), Q{valid};
		ok (grep { $_ ~~ Perl6::Operator }, $tree.child.[0].child),
			Q{found operator};
#		is $pt.format( $tree ), Q{1 x 2}, Q{formatted};
		is $pt.format( $tree ), Q{1x2}, Q{formatted};
	}, Q{x};

	subtest {
		plan 3;

		my $parsed = $pt.parse-source( Q:to[_END_] );
1 xx 2
_END_
		my $tree = $pt.build-tree( $parsed );
		ok $pt.validate( $parsed ), Q{valid};
		ok (grep { $_ ~~ Perl6::Operator }, $tree.child.[0].child),
			Q{found operator};
#		is $pt.format( $tree ), Q{1 xx 2}, Q{formatted};
		is $pt.format( $tree ), Q{1xx2}, Q{formatted};
	}, Q{xx};
}, Q{Replication Precedence};

subtest {
	plan 1;

	subtest {
		plan 3;

		my $parsed = $pt.parse-source( Q:to[_END_] );
1 ~ 2
_END_
		my $tree = $pt.build-tree( $parsed );
		ok $pt.validate( $parsed ), Q{valid};
		ok (grep { $_ ~~ Perl6::Operator }, $tree.child.[0].child),
			Q{found operator};
#		is $pt.format( $tree ), Q{1 ~ 2}, Q{formatted};
		is $pt.format( $tree ), Q{1~2}, Q{formatted};
	}, Q{~};
}, Q{Concatenation Precedence};

subtest {
	plan 1;

	subtest {
		plan 3;

		my $parsed = $pt.parse-source( Q:to[_END_] );
1 & 2
_END_
		my $tree = $pt.build-tree( $parsed );
		ok $pt.validate( $parsed ), Q{valid};
		ok (grep { $_ ~~ Perl6::Operator }, $tree.child.[0].child),
			Q{found operator};
#		is $pt.format( $tree ), Q{1 & 2}, Q{formatted};
		is $pt.format( $tree ), Q{1&2}, Q{formatted};
	}, Q{&};
}, Q{Junctive AND Precedence};

subtest {
	plan 2;

	subtest {
		plan 3;

		my $parsed = $pt.parse-source( Q:to[_END_] );
1 | 2
_END_
		my $tree = $pt.build-tree( $parsed );
		ok $pt.validate( $parsed ), Q{valid};
		ok (grep { $_ ~~ Perl6::Operator }, $tree.child.[0].child),
			Q{found operator};
#		is $pt.format( $tree ), Q{1 | 2}, Q{formatted};
		is $pt.format( $tree ), Q{1|2}, Q{formatted};
	}, Q{|};

	subtest {
		plan 3;

		my $parsed = $pt.parse-source( Q:to[_END_] );
1 ^ 2
_END_
		my $tree = $pt.build-tree( $parsed );
		ok $pt.validate( $parsed ), Q{valid};
		ok (grep { $_ ~~ Perl6::Operator }, $tree.child.[0].child),
			Q{found operator};
#		is $pt.format( $tree ), Q{1 ^ 2}, Q{formatted};
		is $pt.format( $tree ), Q{1^2}, Q{formatted};
	}, Q{^};
}, Q{Junctive OR Precedence};

subtest {
	plan 2;

	subtest {
		plan 3;

		my $parsed = $pt.parse-source( Q:to[_END_] );
my $a; temp $a
_END_
		my $tree = $pt.build-tree( $parsed );
		ok $pt.validate( $parsed ), Q{valid};
		ok (grep { $_ ~~ Perl6::Operator }, $tree.child.[1].child),
			Q{found operator};
#		is $pt.format( $tree ), Q{my $a; temp $a}, Q{formatted};
		is $pt.format( $tree ), Q{my$a;temp$a}, Q{formatted};
	}, Q{temp};

	subtest {
		plan 3;

		my $parsed = $pt.parse-source( Q:to[_END_] );
my $a; let $a
_END_
		my $tree = $pt.build-tree( $parsed );
		ok $pt.validate( $parsed ), Q{valid};
		ok (grep { $_ ~~ Perl6::Operator }, $tree.child.[1].child),
			Q{found operator};
#		is $pt.format( $tree ), Q{my $a; let $a}, Q{formatted};
		is $pt.format( $tree ), Q{my$a;let$a}, Q{formatted};
	}, Q{let};
}, Q{Named Unary Precedence};

subtest {
	plan 9;

	subtest {
		plan 3;

		my $parsed = $pt.parse-source( Q:to[_END_] );
1 does 2
_END_
		my $tree = $pt.build-tree( $parsed );
		ok $pt.validate( $parsed ), Q{valid};
		ok (grep { $_ ~~ Perl6::Operator }, $tree.child.[0].child),
			Q{found operator};
#		is $pt.format( $tree ), Q{1 does 2}, Q{formatted};
		is $pt.format( $tree ), Q{1does2}, Q{formatted};
	}, Q{does};

	subtest {
		plan 3;

		my $parsed = $pt.parse-source( Q:to[_END_] );
1 but 2
_END_
		my $tree = $pt.build-tree( $parsed );
		ok $pt.validate( $parsed ), Q{valid};
		ok (grep { $_ ~~ Perl6::Operator }, $tree.child.[0].child),
			Q{found operator};
#		is $pt.format( $tree ), Q{1 but 2}, Q{formatted};
		is $pt.format( $tree ), Q{1but2}, Q{formatted};
	}, Q{but};

	subtest {
		plan 3;

		my $parsed = $pt.parse-source( Q:to[_END_] );
1 cmp 2
_END_
		my $tree = $pt.build-tree( $parsed );
		ok $pt.validate( $parsed ), Q{valid};
		ok (grep { $_ ~~ Perl6::Operator }, $tree.child.[0].child),
			Q{found operator};
#		is $pt.format( $tree ), Q{1 cmp 2}, Q{formatted};
		is $pt.format( $tree ), Q{1cmp2}, Q{formatted};
	}, Q{cmp};

	subtest {
		plan 3;

		my $parsed = $pt.parse-source( Q:to[_END_] );
1 leg 2
_END_
		my $tree = $pt.build-tree( $parsed );
		ok $pt.validate( $parsed ), Q{valid};
		ok (grep { $_ ~~ Perl6::Operator }, $tree.child.[0].child),
			Q{found operator};
#		is $pt.format( $tree ), Q{1 leg 2}, Q{formatted};
		is $pt.format( $tree ), Q{1leg2}, Q{formatted};
	}, Q{leg};

	subtest {
		plan 3;

		my $parsed = $pt.parse-source( Q:to[_END_] );
1 <=> 2
_END_
		my $tree = $pt.build-tree( $parsed );
		ok $pt.validate( $parsed ), Q{valid};
		ok (grep { $_ ~~ Perl6::Operator }, $tree.child.[0].child),
			Q{found operator};
#		is $pt.format( $tree ), Q{1 <=> 2}, Q{formatted};
		is $pt.format( $tree ), Q{1<=>2}, Q{formatted};
	}, Q{<=>};

	subtest {
		plan 3;

		my $parsed = $pt.parse-source( Q:to[_END_] );
1 .. 2
_END_
		my $tree = $pt.build-tree( $parsed );
		ok $pt.validate( $parsed ), Q{valid};
		ok (grep { $_ ~~ Perl6::Operator }, $tree.child.[0].child),
			Q{found operator};
#		is $pt.format( $tree ), Q{1 .. 2}, Q{formatted};
		is $pt.format( $tree ), Q{1..2}, Q{formatted};
	}, Q{..};

	subtest {
		plan 3;

		my $parsed = $pt.parse-source( Q:to[_END_] );
1 ^.. 2
_END_
		my $tree = $pt.build-tree( $parsed );
		ok $pt.validate( $parsed ), Q{valid};
		ok (grep { $_ ~~ Perl6::Operator }, $tree.child.[0].child),
			Q{found operator};
#		is $pt.format( $tree ), Q{1 ^.. 2}, Q{formatted};
		is $pt.format( $tree ), Q{1^..2}, Q{formatted};
	}, Q{^..};

	subtest {
		plan 3;

		my $parsed = $pt.parse-source( Q:to[_END_] );
1 ..^ 2
_END_
		my $tree = $pt.build-tree( $parsed );
		ok $pt.validate( $parsed ), Q{valid};
		ok (grep { $_ ~~ Perl6::Operator }, $tree.child.[0].child),
			Q{found operator};
#		is $pt.format( $tree ), Q{1 ..^ 2}, Q{formatted};
		is $pt.format( $tree ), Q{1..^2}, Q{formatted};
	}, Q{..^};

	subtest {
		plan 3;

		my $parsed = $pt.parse-source( Q:to[_END_] );
1 ^..^ 2
_END_
		my $tree = $pt.build-tree( $parsed );
		ok $pt.validate( $parsed ), Q{valid};
		ok (grep { $_ ~~ Perl6::Operator }, $tree.child.[0].child),
			Q{found operator};
#		is $pt.format( $tree ), Q{1 ^..^ 2}, Q{formatted};
		is $pt.format( $tree ), Q{1^..^2}, Q{formatted};
	}, Q{^..^};
}, Q{Nonchaining Binary Precedence};

subtest {
	plan 21;

	subtest {
		plan 3;

		my $parsed = $pt.parse-source( Q:to[_END_] );
1 == 2
_END_
		my $tree = $pt.build-tree( $parsed );
		ok $pt.validate( $parsed ), Q{valid};
		ok (grep { $_ ~~ Perl6::Operator }, $tree.child.[0].child),
			Q{found operator};
#		is $pt.format( $tree ), Q{1 == 2}, Q{formatted};
		is $pt.format( $tree ), Q{1==2}, Q{formatted};
	}, Q{==};

	subtest {
		plan 3;

		my $parsed = $pt.parse-source( Q:to[_END_] );
1 != 2
_END_
		my $tree = $pt.build-tree( $parsed );
		ok $pt.validate( $parsed ), Q{valid};
		ok (grep { $_ ~~ Perl6::Operator }, $tree.child.[0].child),
			Q{found operator};
#		is $pt.format( $tree ), Q{1 != 2}, Q{formatted};
		is $pt.format( $tree ), Q{1!=2}, Q{formatted};
	}, Q{!=};

	subtest {
		plan 3;

		my $parsed = $pt.parse-source( Q:to[_END_] );
1 < 2
_END_
		my $tree = $pt.build-tree( $parsed );
		ok $pt.validate( $parsed ), Q{valid};
		ok (grep { $_ ~~ Perl6::Operator }, $tree.child.[0].child),
			Q{found operator};
#		is $pt.format( $tree ), Q{1 < 2}, Q{formatted};
		is $pt.format( $tree ), Q{1<2}, Q{formatted};
	}, Q{<};

	subtest {
		plan 3;

		my $parsed = $pt.parse-source( Q:to[_END_] );
1 <= 2
_END_
		my $tree = $pt.build-tree( $parsed );
		ok $pt.validate( $parsed ), Q{valid};
		ok (grep { $_ ~~ Perl6::Operator }, $tree.child.[0].child),
			Q{found operator};
#		is $pt.format( $tree ), Q{1 <= 2}, Q{formatted};
		is $pt.format( $tree ), Q{1<=2}, Q{formatted};
	}, Q{<=};

	subtest {
		plan 3;

		my $parsed = $pt.parse-source( Q:to[_END_] );
1 > 2
_END_
		my $tree = $pt.build-tree( $parsed );
		ok $pt.validate( $parsed ), Q{valid};
		ok (grep { $_ ~~ Perl6::Operator }, $tree.child.[0].child),
			Q{found operator};
#		is $pt.format( $tree ), Q{1 > 2}, Q{formatted};
		is $pt.format( $tree ), Q{1>2}, Q{formatted};
	}, Q{>};

	subtest {
		plan 3;

		my $parsed = $pt.parse-source( Q:to[_END_] );
1 <= 2
_END_
		my $tree = $pt.build-tree( $parsed );
		ok $pt.validate( $parsed ), Q{valid};
		ok (grep { $_ ~~ Perl6::Operator }, $tree.child.[0].child),
			Q{found operator};
#		is $pt.format( $tree ), Q{1 <= 2}, Q{formatted};
		is $pt.format( $tree ), Q{1<=2}, Q{formatted};
	}, Q{<=};

	subtest {
		plan 3;

		my $parsed = $pt.parse-source( Q:to[_END_] );
1 > 2
_END_
		my $tree = $pt.build-tree( $parsed );
		ok $pt.validate( $parsed ), Q{valid};
		ok (grep { $_ ~~ Perl6::Operator }, $tree.child.[0].child),
			Q{found operator};
#		is $pt.format( $tree ), Q{1 > 2}, Q{formatted};
		is $pt.format( $tree ), Q{1>2}, Q{formatted};
	}, Q{>};

	subtest {
		plan 3;

		my $parsed = $pt.parse-source( Q:to[_END_] );
1 >= 2
_END_
		my $tree = $pt.build-tree( $parsed );
		ok $pt.validate( $parsed ), Q{valid};
		ok (grep { $_ ~~ Perl6::Operator }, $tree.child.[0].child),
			Q{found operator};
#		is $pt.format( $tree ), Q{1 >= 2}, Q{formatted};
		is $pt.format( $tree ), Q{1>=2}, Q{formatted};
	}, Q{>=};

	subtest {
		plan 3;

		my $parsed = $pt.parse-source( Q:to[_END_] );
1 eq 2
_END_
		my $tree = $pt.build-tree( $parsed );
		ok $pt.validate( $parsed ), Q{valid};
		ok (grep { $_ ~~ Perl6::Operator }, $tree.child.[0].child),
			Q{found operator};
#		is $pt.format( $tree ), Q{1 eq 2}, Q{formatted};
		is $pt.format( $tree ), Q{1eq2}, Q{formatted};
	}, Q{eq};

	subtest {
		plan 3;

		my $parsed = $pt.parse-source( Q:to[_END_] );
1 ne 2
_END_
		my $tree = $pt.build-tree( $parsed );
		ok $pt.validate( $parsed ), Q{valid};
		ok (grep { $_ ~~ Perl6::Operator }, $tree.child.[0].child),
			Q{found operator};
#		is $pt.format( $tree ), Q{1 ne 2}, Q{formatted};
		is $pt.format( $tree ), Q{1ne2}, Q{formatted};
	}, Q{ne};

	subtest {
		plan 3;

		my $parsed = $pt.parse-source( Q:to[_END_] );
1 gt 2
_END_
		my $tree = $pt.build-tree( $parsed );
		ok $pt.validate( $parsed ), Q{valid};
		ok (grep { $_ ~~ Perl6::Operator }, $tree.child.[0].child),
			Q{found operator};
#		is $pt.format( $tree ), Q{1 gt 2}, Q{formatted};
		is $pt.format( $tree ), Q{1gt2}, Q{formatted};
	}, Q{gt};

	subtest {
		plan 3;

		my $parsed = $pt.parse-source( Q:to[_END_] );
1 ge 2
_END_
		my $tree = $pt.build-tree( $parsed );
		ok $pt.validate( $parsed ), Q{valid};
		ok (grep { $_ ~~ Perl6::Operator }, $tree.child.[0].child),
			Q{found operator};
#		is $pt.format( $tree ), Q{1 ge 2}, Q{formatted};
		is $pt.format( $tree ), Q{1ge2}, Q{formatted};
	}, Q{ge};

	subtest {
		plan 3;

		my $parsed = $pt.parse-source( Q:to[_END_] );
1 lt 2
_END_
		my $tree = $pt.build-tree( $parsed );
		ok $pt.validate( $parsed ), Q{valid};
		ok (grep { $_ ~~ Perl6::Operator }, $tree.child.[0].child),
			Q{found operator};
#		is $pt.format( $tree ), Q{1 lt 2}, Q{formatted};
		is $pt.format( $tree ), Q{1lt2}, Q{formatted};
	}, Q{lt};

	subtest {
		plan 3;

		my $parsed = $pt.parse-source( Q:to[_END_] );
1 le 2
_END_
		my $tree = $pt.build-tree( $parsed );
		ok $pt.validate( $parsed ), Q{valid};
		ok (grep { $_ ~~ Perl6::Operator }, $tree.child.[0].child),
			Q{found operator};
#		is $pt.format( $tree ), Q{1 le 2}, Q{formatted};
		is $pt.format( $tree ), Q{1le2}, Q{formatted};
	}, Q{le};

	subtest {
		plan 3;

		my $parsed = $pt.parse-source( Q:to[_END_] );
1 before 2
_END_
		my $tree = $pt.build-tree( $parsed );
		ok $pt.validate( $parsed ), Q{valid};
		ok (grep { $_ ~~ Perl6::Operator }, $tree.child.[0].child),
			Q{found operator};
#		is $pt.format( $tree ), Q{1 before 2}, Q{formatted};
		is $pt.format( $tree ), Q{1before2}, Q{formatted};
	}, Q{before};

	subtest {
		plan 3;

		my $parsed = $pt.parse-source( Q:to[_END_] );
1 after 2
_END_
		my $tree = $pt.build-tree( $parsed );
		ok $pt.validate( $parsed ), Q{valid};
		ok (grep { $_ ~~ Perl6::Operator }, $tree.child.[0].child),
			Q{found operator};
#		is $pt.format( $tree ), Q{1 after 2}, Q{formatted};
		is $pt.format( $tree ), Q{1after2}, Q{formatted};
	}, Q{after};

	subtest {
		plan 3;

		my $parsed = $pt.parse-source( Q:to[_END_] );
1 eqv 2
_END_
		my $tree = $pt.build-tree( $parsed );
		ok $pt.validate( $parsed ), Q{valid};
		ok (grep { $_ ~~ Perl6::Operator }, $tree.child.[0].child),
			Q{found operator};
#		is $pt.format( $tree ), Q{1 eqv 2}, Q{formatted};
		is $pt.format( $tree ), Q{1eqv2}, Q{formatted};
	}, Q{eqv};

	subtest {
		plan 3;

		my $parsed = $pt.parse-source( Q:to[_END_] );
1 === 2
_END_
		my $tree = $pt.build-tree( $parsed );
		ok $pt.validate( $parsed ), Q{valid};
		ok (grep { $_ ~~ Perl6::Operator }, $tree.child.[0].child),
			Q{found operator};
#		is $pt.format( $tree ), Q{1 === 2}, Q{formatted};
		is $pt.format( $tree ), Q{1===2}, Q{formatted};
	}, Q{===};

	subtest {
		plan 3;

		my $parsed = $pt.parse-source( Q:to[_END_] );
1 =:= 2
_END_
		my $tree = $pt.build-tree( $parsed );
		ok $pt.validate( $parsed ), Q{valid};
		ok (grep { $_ ~~ Perl6::Operator }, $tree.child.[0].child),
			Q{found operator};
#		is $pt.format( $tree ), Q{1 =:= 2}, Q{formatted};
		is $pt.format( $tree ), Q{1=:=2}, Q{formatted};
	}, Q{=:=};

	subtest {
		plan 3;

		my $parsed = $pt.parse-source( Q:to[_END_] );
1 ~~ 2
_END_
		my $tree = $pt.build-tree( $parsed );
		ok $pt.validate( $parsed ), Q{valid};
		ok (grep { $_ ~~ Perl6::Operator }, $tree.child.[0].child),
			Q{found operator};
#		is $pt.format( $tree ), Q{1 ~~ 2}, Q{formatted};
		is $pt.format( $tree ), Q{1~~2}, Q{formatted};
	}, Q{~~};

	subtest {
		plan 3;

		my $parsed = $pt.parse-source( Q:to[_END_] );
1 =~= 2
_END_
		my $tree = $pt.build-tree( $parsed );
		ok $pt.validate( $parsed ), Q{valid};
		ok (grep { $_ ~~ Perl6::Operator }, $tree.child.[0].child),
			Q{found operator};
#		is $pt.format( $tree ), Q{1 =~= 2}, Q{formatted};
		is $pt.format( $tree ), Q{1=~=2}, Q{formatted};
	}, Q{=~=};
}, Q{Chaining Binary Precedence};

subtest {
	plan 1;

	subtest {
		plan 3;

		my $parsed = $pt.parse-source( Q:to[_END_] );
1 && 2
_END_
		my $tree = $pt.build-tree( $parsed );
		ok $pt.validate( $parsed ), Q{valid};
		ok (grep { $_ ~~ Perl6::Operator }, $tree.child.[0].child),
			Q{found operator};
#		is $pt.format( $tree ), Q{1 && 2}, Q{formatted};
		is $pt.format( $tree ), Q{1&&2}, Q{formatted};
	}, Q{&&};
}, Q{Tight AND Precedence};

subtest {
	plan 5;

	subtest {
		plan 3;

		my $parsed = $pt.parse-source( Q:to[_END_] );
1 || 2
_END_
		my $tree = $pt.build-tree( $parsed );
		ok $pt.validate( $parsed ), Q{valid};
		ok (grep { $_ ~~ Perl6::Operator }, $tree.child.[0].child),
			Q{found operator};
#		is $pt.format( $tree ), Q{1 || 2}, Q{formatted};
		is $pt.format( $tree ), Q{1||2}, Q{formatted};
	}, Q{||};

	subtest {
		plan 3;

		my $parsed = $pt.parse-source( Q:to[_END_] );
1 ^^ 2
_END_
		my $tree = $pt.build-tree( $parsed );
		ok $pt.validate( $parsed ), Q{valid};
		ok (grep { $_ ~~ Perl6::Operator }, $tree.child.[0].child),
			Q{found operator};
#		is $pt.format( $tree ), Q{1 ^^ 2}, Q{formatted};
		is $pt.format( $tree ), Q{1^^2}, Q{formatted};
	}, Q{^^};

	subtest {
		plan 3;

		my $parsed = $pt.parse-source( Q:to[_END_] );
1 // 2
_END_
		my $tree = $pt.build-tree( $parsed );
		ok $pt.validate( $parsed ), Q{valid};
		ok (grep { $_ ~~ Perl6::Operator }, $tree.child.[0].child),
			Q{found operator};
#		is $pt.format( $tree ), Q{1 // 2}, Q{formatted};
		is $pt.format( $tree ), Q{1//2}, Q{formatted};
	}, Q{//};

	subtest {
		plan 3;

		my $parsed = $pt.parse-source( Q:to[_END_] );
1 min 2
_END_
		my $tree = $pt.build-tree( $parsed );
		ok $pt.validate( $parsed ), Q{valid};
		ok (grep { $_ ~~ Perl6::Operator }, $tree.child.[0].child),
			Q{found operator};
#		is $pt.format( $tree ), Q{1 min 2}, Q{formatted};
		is $pt.format( $tree ), Q{1min2}, Q{formatted};
	}, Q{min};

	subtest {
		plan 3;

		my $parsed = $pt.parse-source( Q:to[_END_] );
1 max 2
_END_
		my $tree = $pt.build-tree( $parsed );
		ok $pt.validate( $parsed ), Q{valid};
		ok (grep { $_ ~~ Perl6::Operator }, $tree.child.[0].child),
			Q{found operator};
#		is $pt.format( $tree ), Q{1 max 2}, Q{formatted};
		is $pt.format( $tree ), Q{1max2}, Q{formatted};
	}, Q{max};
}, Q{Tight OR Precedence};

subtest {
	plan 9;

	subtest {
		plan 3;

		my $parsed = $pt.parse-source( Q:to[_END_] );
1 ?? 2 !! 3
_END_
		my $tree = $pt.build-tree( $parsed );
		ok $pt.validate( $parsed ), Q{valid};
		ok (grep { $_ ~~ Perl6::Operator }, $tree.child.[0].child),
			Q{found operator};
#		is $pt.format( $tree ), Q{1 ?? 2 !! 3}, Q{formatted};
		is $pt.format( $tree ), Q{1??2!!3}, Q{formatted};
	}, Q{?? !!};

	subtest {
		plan 3;

		my $parsed = $pt.parse-source( Q:to[_END_] );
1 ff 2
_END_
		my $tree = $pt.build-tree( $parsed );
		ok $pt.validate( $parsed ), Q{valid};
		ok (grep { $_ ~~ Perl6::Operator }, $tree.child.[0].child),
			Q{found operator};
#		is $pt.format( $tree ), Q{1 ff 2}, Q{formatted};
		is $pt.format( $tree ), Q{1ff2}, Q{formatted};
	}, Q{ff};

	subtest {
		plan 3;

		my $parsed = $pt.parse-source( Q:to[_END_] );
1 ^ff 2
_END_
		my $tree = $pt.build-tree( $parsed );
		ok $pt.validate( $parsed ), Q{valid};
		ok (grep { $_ ~~ Perl6::Operator }, $tree.child.[0].child),
			Q{found operator};
#		is $pt.format( $tree ), Q{1 ^ff 2}, Q{formatted};
		is $pt.format( $tree ), Q{1^ff2}, Q{formatted};
	}, Q{^ff};

	subtest {
		plan 3;

		my $parsed = $pt.parse-source( Q:to[_END_] );
1 ff^ 2
_END_
		my $tree = $pt.build-tree( $parsed );
		ok $pt.validate( $parsed ), Q{valid};
		ok (grep { $_ ~~ Perl6::Operator }, $tree.child.[0].child),
			Q{found operator};
#		is $pt.format( $tree ), Q{1 ff^ 2}, Q{formatted};
		is $pt.format( $tree ), Q{1ff^2}, Q{formatted};
	}, Q{ff^};

	subtest {
		plan 3;

		my $parsed = $pt.parse-source( Q:to[_END_] );
1 ^ff^ 2
_END_
		my $tree = $pt.build-tree( $parsed );
		ok $pt.validate( $parsed ), Q{valid};
		ok (grep { $_ ~~ Perl6::Operator }, $tree.child.[0].child),
			Q{found operator};
#		is $pt.format( $tree ), Q{1 ^ff^ 2}, Q{formatted};
		is $pt.format( $tree ), Q{1^ff^2}, Q{formatted};
	}, Q{^ff^};

	subtest {
		plan 3;

		my $parsed = $pt.parse-source( Q:to[_END_] );
1 fff 2
_END_
		my $tree = $pt.build-tree( $parsed );
		ok $pt.validate( $parsed ), Q{valid};
		ok (grep { $_ ~~ Perl6::Operator }, $tree.child.[0].child),
			Q{found operator};
#		is $pt.format( $tree ), Q{1 fff 2}, Q{formatted};
		is $pt.format( $tree ), Q{1fff2}, Q{formatted};
	}, Q{fff};

	subtest {
		plan 3;

		my $parsed = $pt.parse-source( Q:to[_END_] );
1 ^fff 2
_END_
		my $tree = $pt.build-tree( $parsed );
		ok $pt.validate( $parsed ), Q{valid};
		ok (grep { $_ ~~ Perl6::Operator }, $tree.child.[0].child),
			Q{found operator};
#		is $pt.format( $tree ), Q{1 ^fff 2}, Q{formatted};
		is $pt.format( $tree ), Q{1^fff2}, Q{formatted};
	}, Q{^fff};

	subtest {
		plan 3;

		my $parsed = $pt.parse-source( Q:to[_END_] );
1 fff^ 2
_END_
		my $tree = $pt.build-tree( $parsed );
		ok $pt.validate( $parsed ), Q{valid};
		ok (grep { $_ ~~ Perl6::Operator }, $tree.child.[0].child),
			Q{found operator};
#		is $pt.format( $tree ), Q{1 fff^ 2}, Q{formatted};
		is $pt.format( $tree ), Q{1fff^2}, Q{formatted};
	}, Q{fff^};

	subtest {
		plan 3;

		my $parsed = $pt.parse-source( Q:to[_END_] );
1 ^fff^ 2
_END_
		my $tree = $pt.build-tree( $parsed );
		ok $pt.validate( $parsed ), Q{valid};
		ok (grep { $_ ~~ Perl6::Operator }, $tree.child.[0].child),
			Q{found operator};
#		is $pt.format( $tree ), Q{1 ^fff^ 2}, Q{formatted};
		is $pt.format( $tree ), Q{1^fff^2}, Q{formatted};
	}, Q{^fff^};
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
	}, Q{=>};
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

my $x; $x.say
my $x; $x.()
my $x; $x.[]
my $x; $x.{}
my $x; $x.<>
my $x; $x.«»
my $x; ||$x

3 ~& 2
3 ~< 2
3 ~> 2
3 ?& 2
3 ~| 2
3 ~^ 2
3 ?^ 2

3 !eqv 2

substr('a': 2)

my @a; my @b; @a minmax @b
my @a; my @b; @a X~ @b
my @a; my @b; @a X* @b
my @a; my @b; @a Xeqv @b
my @a; print @a
my @a; push @a, 1
my @a; say @a
my @a; die @a
my @a; map @a, {}
my @a; substr @a

)

# vim: ft=perl6
