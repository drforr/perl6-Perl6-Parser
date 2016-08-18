use v6;

use Test;
use Perl6::Tidy;

#`(

In passing, please note that while it's trivially possible to bum down the
tests, doing so makes it harder to insert 'say $parsed.dump' to view the
AST, and 'say $tree.perl' to view the generated Perl 6 structure.

)

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
#		is $pt.format( $tree ), Q:to[_END_], Q{formatted};
#<a b>
#_END_
		is $pt.format( $tree ), Q:to[_END_].chomp, Q{formatted};
<a b>
_END_
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
#		is $pt.format( $tree ), Q:to[_END_], Q{formatted};
#( 1 )
#_END_
		is $pt.format( $tree ), Q:to[_END_].chomp, Q{formatted};
( 1 )
_END_
	}, Q{()};

	subtest {
		plan 2;

		my $parsed = $pt.parse-source( Q:to[_END_] );
{ 1 }
_END_
		my $tree = $pt.build-tree( $parsed );
		ok $pt.validate( $parsed ), Q{valid};
		# XXX Technically it's an operator, but that could confuse.
#		is $pt.format( $tree ), Q:to[_END_], Q{formatted};
#{ 1 }
#_END_
		is $pt.format( $tree ), Q:to[_END_].chomp, Q{formatted};
{1}
_END_
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
		is $pt.format( $tree ), Q:to[_END_].chomp, Q{formatted};
[ 1 ]
_END_
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
#		is $pt.format( $tree ), Q:to[_END_], Q{formatted};
#my @a; @a[ 2 ]
#_END_
		is $pt.format( $tree ), Q:to[_END_].chomp, Q{formatted};
my @a@a[2]
_END_
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
#		is $pt.format( $tree ), Q:to[_END_], Q{formatted};
#my %a; %a{ "foo" }
#_END_
		is $pt.format( $tree ), Q:to[_END_].chomp, Q{formatted};
my %a%a{"foo"}
_END_
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
#		is $pt.format( $tree ), Q:to[_END_], Q{formatted};
#my %a; %a< foo >
#_END_
		is $pt.format( $tree ), Q:to[_END_].chomp, Q{formatted};
my %a%a<foo>
_END_
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
#		is $pt.format( $tree ), Q:to[_END_], Q{formatted};
#my %a; %a« foo »
#_END_
		is $pt.format( $tree ), Q:to[_END_].chomp, Q{formatted};
my %a%a«foo»
_END_
	}, Q[%a«»];

	subtest {
		plan 2;

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
#		is $pt.format( $tree ), Q:to[_END_], Q{formatted};
#chomp( )
#_END_
		is $pt.format( $tree ), Q:to[_END_].chomp, Q{formatted};
chomp()
_END_
		}, Q{no arguments};

		subtest {
			plan 3;

			# Whitespace sensitive between 'chomp' and '(' ')'
			my $parsed = $pt.parse-source( Q:to[_END_] );
chomp( 1 )
_END_
			my $tree = $pt.build-tree( $parsed );
			ok $pt.validate( $parsed ), Q{valid};
			ok (grep { $_ ~~ Perl6::Operator }, $tree.child.[0].child),
				Q{found operator};
#		is $pt.format( $tree ), Q:to[_END_], Q{formatted};
#chomp( 1 )
#_END_
		is $pt.format( $tree ), Q:to[_END_].chomp, Q{formatted};
chomp(1)
_END_
		}, Q{with arguments};
	}, Q{func()};

	subtest {
		plan 3;

		my $parsed = $pt.parse-source( Q:to[_END_] );
42.round
_END_
		my $tree = $pt.build-tree( $parsed );
		ok $pt.validate( $parsed ), Q{valid};
		ok (grep { $_ ~~ Perl6::Operator }, $tree.child.[0].child),
			Q{found operator};
		is $pt.format( $tree ), Q:to[_END_].chomp, Q{formatted};
42.round
_END_
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
		is $pt.format( $tree ), Q:to[_END_].chomp, Q{formatted};
42.&round
_END_
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
		is $pt.format( $tree ), Q:to[_END_].chomp, Q{formatted};
Int.=round
_END_
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
		is $pt.format( $tree ), Q:to[_END_].chomp, Q{formatted};
42.^name
_END_
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
		is $pt.format( $tree ), Q:to[_END_].chomp, Q{formatted};
42.?name
_END_
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
		is $pt.format( $tree ), Q:to[_END_].chomp, Q{formatted};
42.+name
_END_
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
		is $pt.format( $tree ), Q:to[_END_].chomp, Q{formatted};
42.*name
_END_
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
		is $pt.format( $tree ), Q:to[_END_].chomp, Q{formatted};
42>>.say
_END_
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
#		is $pt.format( $tree ), Q:to[_END_], Q{formatted};
#my $a; $a.:<++>
#_END_
		is $pt.format( $tree ), Q:to[_END_].chomp, Q{formatted};
my $a$a.:<++>
_END_
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
#		is $pt.format( $tree ), Q:to[_END_], Q{formatted};
#my $a; $a.Foo::Bar
#_END_
		is $pt.format( $tree ), Q:to[_END_].chomp, Q{formatted};
my $a$a.Foo::Bar
_END_
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
#		is $pt.format( $tree ), Q:to[_END_], Q{formatted};
#my $a; ++ $a
#_END_
		is $pt.format( $tree ), Q:to[_END_].chomp, Q{formatted};
my $a++$a
_END_
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
#		is $pt.format( $tree ), Q:to[_END_], Q{formatted};
#my $a; -- $a
#_END_
		is $pt.format( $tree ), Q:to[_END_].chomp, Q{formatted};
my $a--$a
_END_
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
#		is $pt.format( $tree ), Q:to[_END_], Q{formatted};
#my $a; $a++
#_END_
		is $pt.format( $tree ), Q:to[_END_].chomp, Q{formatted};
my $a$a++
_END_
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
#		is $pt.format( $tree ), Q:to[_END_], Q{formatted};
#my $a; $a--
#_END_
		is $pt.format( $tree ), Q:to[_END_].chomp, Q{formatted};
my $a$a--
_END_
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
#		is $pt.format( $tree ), Q:to[_END_], Q{formatted};
#1 ** 2
#_END_
		is $pt.format( $tree ), Q:to[_END_].chomp, Q{formatted};
1**2
_END_
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
#		is $pt.format( $tree ), Q:to[_END_], Q{formatted};
#? 2
#_END_
		is $pt.format( $tree ), Q:to[_END_].chomp, Q{formatted};
?2
_END_
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
#		is $pt.format( $tree ), Q:to[_END_], Q{formatted};
#! 2
#_END_
		is $pt.format( $tree ), Q:to[_END_].chomp, Q{formatted};
!2
_END_
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
#		is $pt.format( $tree ), Q:to[_END_], Q{formatted};
#+ 2
#_END_
		is $pt.format( $tree ), Q:to[_END_].chomp, Q{formatted};
+2
_END_
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
#		is $pt.format( $tree ), Q:to[_END_], Q{formatted};
#- 2
#_END_
		is $pt.format( $tree ), Q:to[_END_].chomp, Q{formatted};
-2
_END_
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
#		is $pt.format( $tree ), Q:to[_END_], Q{formatted};
#~ 2
#_END_
		is $pt.format( $tree ), Q:to[_END_].chomp, Q{formatted};
~2
_END_
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
#		is $pt.format( $tree ), Q:to[_END_], Q{formatted};
#| 2
#_END_
		is $pt.format( $tree ), Q:to[_END_].chomp, Q{formatted};
|2
_END_
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
#		is $pt.format( $tree ), Q:to[_END_], Q{formatted};
#+^ 2
#_END_
		is $pt.format( $tree ), Q:to[_END_].chomp, Q{formatted};
+^2
_END_
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
#		is $pt.format( $tree ), Q:to[_END_], Q{formatted};
#?^ 2
#_END_
		is $pt.format( $tree ), Q:to[_END_].chomp, Q{formatted};
?^2
_END_
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
#		is $pt.format( $tree ), Q:to[_END_], Q{formatted};
#^ 2
#_END_
		is $pt.format( $tree ), Q:to[_END_].chomp, Q{formatted};
^2
_END_
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
#		is $pt.format( $tree ), Q:to[_END_], Q{formatted};
#1 * 2
#_END_
		is $pt.format( $tree ), Q:to[_END_].chomp, Q{formatted};
1*2
_END_
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
#		is $pt.format( $tree ), Q:to[_END_], Q{formatted};
#1 / 2
#_END_
		is $pt.format( $tree ), Q:to[_END_].chomp, Q{formatted};
1/2
_END_
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
#		is $pt.format( $tree ), Q:to[_END_], Q{formatted};
#1 div 2
#_END_
		is $pt.format( $tree ), Q:to[_END_].chomp, Q{formatted};
1div2
_END_
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
#		is $pt.format( $tree ), Q:to[_END_], Q{formatted};
#1 % 2
#_END_
		is $pt.format( $tree ), Q:to[_END_].chomp, Q{formatted};
1%2
_END_
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
#		is $pt.format( $tree ), Q:to[_END_], Q{formatted};
#1 %% 2
#_END_
		is $pt.format( $tree ), Q:to[_END_].chomp, Q{formatted};
1%%2
_END_
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
#		is $pt.format( $tree ), Q:to[_END_], Q{formatted};
#1 mod 2
#_END_
		is $pt.format( $tree ), Q:to[_END_].chomp, Q{formatted};
1mod2
_END_
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
#		is $pt.format( $tree ), Q:to[_END_], Q{formatted};
#1 +& 2
#_END_
		is $pt.format( $tree ), Q:to[_END_].chomp, Q{formatted};
1+&2
_END_
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
#		is $pt.format( $tree ), Q:to[_END_], Q{formatted};
#1 +< 2
#_END_
		is $pt.format( $tree ), Q:to[_END_].chomp, Q{formatted};
1+<2
_END_
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
#		is $pt.format( $tree ), Q:to[_END_], Q{formatted};
#1 +> 2
#_END_
		is $pt.format( $tree ), Q:to[_END_].chomp, Q{formatted};
1+>2
_END_
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
#		is $pt.format( $tree ), Q:to[_END_], Q{formatted};
#1 gcd 2
#_END_
		is $pt.format( $tree ), Q:to[_END_].chomp, Q{formatted};
1gcd2
_END_
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
#		is $pt.format( $tree ), Q:to[_END_], Q{formatted};
#1 lcm 2
#_END_
		is $pt.format( $tree ), Q:to[_END_].chomp, Q{formatted};
1lcm2
_END_
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
#		is $pt.format( $tree ), Q:to[_END_], Q{formatted};
#1 + 2
#_END_
		is $pt.format( $tree ), Q:to[_END_].chomp, Q{formatted};
1+2
_END_
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
#		is $pt.format( $tree ), Q:to[_END_], Q{formatted};
#1 - 2
#_END_
		is $pt.format( $tree ), Q:to[_END_].chomp, Q{formatted};
1-2
_END_
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
#		is $pt.format( $tree ), Q:to[_END_], Q{formatted};
#1 +| 2
#_END_
		is $pt.format( $tree ), Q:to[_END_].chomp, Q{formatted};
1+|2
_END_
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
#		is $pt.format( $tree ), Q:to[_END_], Q{formatted};
#1 +^ 2
#_END_
		is $pt.format( $tree ), Q:to[_END_].chomp, Q{formatted};
1+^2
_END_
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
#		is $pt.format( $tree ), Q:to[_END_], Q{formatted};
#1 ?| 2
#_END_
		is $pt.format( $tree ), Q:to[_END_].chomp, Q{formatted};
1?|2
_END_
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
#		is $pt.format( $tree ), Q:to[_END_], Q{formatted};
#1 x 2
#_END_
		is $pt.format( $tree ), Q:to[_END_].chomp, Q{formatted};
1x2
_END_
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
#		is $pt.format( $tree ), Q:to[_END_], Q{formatted};
#1 xx 2
#_END_
		is $pt.format( $tree ), Q:to[_END_].chomp, Q{formatted};
1xx2
_END_
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
#		is $pt.format( $tree ), Q:to[_END_], Q{formatted};
#1 ~ 2
#_END_
		is $pt.format( $tree ), Q:to[_END_].chomp, Q{formatted};
1~2
_END_
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
#		is $pt.format( $tree ), Q:to[_END_], Q{formatted};
#1 & 2
#_END_
		is $pt.format( $tree ), Q:to[_END_].chomp, Q{formatted};
1&2
_END_
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
#		is $pt.format( $tree ), Q:to[_END_], Q{formatted};
#1 | 2
#_END_
		is $pt.format( $tree ), Q:to[_END_].chomp, Q{formatted};
1|2
_END_
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
#		is $pt.format( $tree ), Q:to[_END_], Q{formatted};
#1 ^ 2
#_END_
		is $pt.format( $tree ), Q:to[_END_].chomp, Q{formatted};
1^2
_END_
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
#		is $pt.format( $tree ), Q:to[_END_], Q{formatted};
#my $a; temp $a
#_END_
		is $pt.format( $tree ), Q:to[_END_].chomp, Q{formatted};
my $atemp$a
_END_
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
#		is $pt.format( $tree ), Q:to[_END_], Q{formatted};
#my $a; let $a
#_END_
		is $pt.format( $tree ), Q:to[_END_].chomp, Q{formatted};
my $alet$a
_END_
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
#		is $pt.format( $tree ), Q:to[_END_], Q{formatted};
#1 does 2
#_END_
		is $pt.format( $tree ), Q:to[_END_].chomp, Q{formatted};
1does2
_END_
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
#		is $pt.format( $tree ), Q:to[_END_], Q{formatted};
#1 but 2
#_END_
		is $pt.format( $tree ), Q:to[_END_].chomp, Q{formatted};
1but2
_END_
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
#		is $pt.format( $tree ), Q:to[_END_], Q{formatted};
#1 cmp 2
#_END_
		is $pt.format( $tree ), Q:to[_END_].chomp, Q{formatted};
1cmp2
_END_
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
#		is $pt.format( $tree ), Q:to[_END_], Q{formatted};
#1 leg 2
#_END_
		is $pt.format( $tree ), Q:to[_END_].chomp, Q{formatted};
1leg2
_END_
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
#		is $pt.format( $tree ), Q:to[_END_], Q{formatted};
#1 <=> 2
#_END_
		is $pt.format( $tree ), Q:to[_END_].chomp, Q{formatted};
1<=>2
_END_
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
#		is $pt.format( $tree ), Q:to[_END_], Q{formatted};
#1 .. 2
#_END_
		is $pt.format( $tree ), Q:to[_END_].chomp, Q{formatted};
1..2
_END_
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
#		is $pt.format( $tree ), Q:to[_END_], Q{formatted};
#1 ^.. 2
#_END_
		is $pt.format( $tree ), Q:to[_END_].chomp, Q{formatted};
1^..2
_END_
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
#		is $pt.format( $tree ), Q:to[_END_], Q{formatted};
#1 ..^ 2
#_END_
		is $pt.format( $tree ), Q:to[_END_].chomp, Q{formatted};
1..^2
_END_
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
#		is $pt.format( $tree ), Q:to[_END_], Q{formatted};
#1 ^..^ 2
#_END_
		is $pt.format( $tree ), Q:to[_END_].chomp, Q{formatted};
1^..^2
_END_
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
#		is $pt.format( $tree ), Q:to[_END_], Q{formatted};
#1 == 2
#_END_
		is $pt.format( $tree ), Q:to[_END_].chomp, Q{formatted};
1==2
_END_
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
#		is $pt.format( $tree ), Q:to[_END_], Q{formatted};
#1 != 2
#_END_
		is $pt.format( $tree ), Q:to[_END_].chomp, Q{formatted};
1!=2
_END_
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
#		is $pt.format( $tree ), Q:to[_END_], Q{formatted};
#1 < 2
#_END_
		is $pt.format( $tree ), Q:to[_END_].chomp, Q{formatted};
1<2
_END_
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
#		is $pt.format( $tree ), Q:to[_END_], Q{formatted};
#1 <= 2
#_END_
		is $pt.format( $tree ), Q:to[_END_].chomp, Q{formatted};
1<=2
_END_
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
#		is $pt.format( $tree ), Q:to[_END_], Q{formatted};
#1 > 2
#_END_
		is $pt.format( $tree ), Q:to[_END_].chomp, Q{formatted};
1>2
_END_
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
#		is $pt.format( $tree ), Q:to[_END_], Q{formatted};
#1 <= 2
#_END_
		is $pt.format( $tree ), Q:to[_END_].chomp, Q{formatted};
1<=2
_END_
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
#		is $pt.format( $tree ), Q:to[_END_], Q{formatted};
#1 > 2
#_END_
		is $pt.format( $tree ), Q:to[_END_].chomp, Q{formatted};
1>2
_END_
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
#		is $pt.format( $tree ), Q:to[_END_], Q{formatted};
#1 >= 2
#_END_
		is $pt.format( $tree ), Q:to[_END_].chomp, Q{formatted};
1>=2
_END_
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
#		is $pt.format( $tree ), Q:to[_END_], Q{formatted};
#1 eq 2
#_END_
		is $pt.format( $tree ), Q:to[_END_].chomp, Q{formatted};
1eq2
_END_
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
#		is $pt.format( $tree ), Q:to[_END_], Q{formatted};
#1 ne 2
#_END_
		is $pt.format( $tree ), Q:to[_END_].chomp, Q{formatted};
1ne2
_END_
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
#		is $pt.format( $tree ), Q:to[_END_], Q{formatted};
#1 gt 2
#_END_
		is $pt.format( $tree ), Q:to[_END_].chomp, Q{formatted};
1gt2
_END_
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
#		is $pt.format( $tree ), Q:to[_END_], Q{formatted};
#1 ge 2
#_END_
		is $pt.format( $tree ), Q:to[_END_].chomp, Q{formatted};
1ge2
_END_
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
#		is $pt.format( $tree ), Q:to[_END_], Q{formatted};
#1 lt 2
#_END_
		is $pt.format( $tree ), Q:to[_END_].chomp, Q{formatted};
1lt2
_END_
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
#		is $pt.format( $tree ), Q:to[_END_], Q{formatted};
#1 le 2
#_END_
		is $pt.format( $tree ), Q:to[_END_].chomp, Q{formatted};
1le2
_END_
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
#		is $pt.format( $tree ), Q:to[_END_], Q{formatted};
#1 before 2
#_END_
		is $pt.format( $tree ), Q:to[_END_].chomp, Q{formatted};
1before2
_END_
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
#		is $pt.format( $tree ), Q:to[_END_], Q{formatted};
#1 after 2
#_END_
		is $pt.format( $tree ), Q:to[_END_].chomp, Q{formatted};
1after2
_END_
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
#		is $pt.format( $tree ), Q:to[_END_], Q{formatted};
#1 eqv 2
#_END_
		is $pt.format( $tree ), Q:to[_END_].chomp, Q{formatted};
1eqv2
_END_
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
#		is $pt.format( $tree ), Q:to[_END_], Q{formatted};
#1 === 2
#_END_
		is $pt.format( $tree ), Q:to[_END_].chomp, Q{formatted};
1===2
_END_
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
#		is $pt.format( $tree ), Q:to[_END_], Q{formatted};
#1 =:= 2
#_END_
		is $pt.format( $tree ), Q:to[_END_].chomp, Q{formatted};
1=:=2
_END_
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
#		is $pt.format( $tree ), Q:to[_END_], Q{formatted};
#1 ~~ 2
#_END_
		is $pt.format( $tree ), Q:to[_END_].chomp, Q{formatted};
1~~2
_END_
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
#		is $pt.format( $tree ), Q:to[_END_], Q{formatted};
#1 =~= 2
#_END_
		is $pt.format( $tree ), Q:to[_END_].chomp, Q{formatted};
1=~=2
_END_
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
#		is $pt.format( $tree ), Q:to[_END_], Q{formatted};
#1 && 2
#_END_
		is $pt.format( $tree ), Q:to[_END_].chomp, Q{formatted};
1&&2
_END_
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
#		is $pt.format( $tree ), Q:to[_END_], Q{formatted};
#1 || 2
#_END_
		is $pt.format( $tree ), Q:to[_END_].chomp, Q{formatted};
1||2
_END_
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
#		is $pt.format( $tree ), Q:to[_END_], Q{formatted};
#1 ^^ 2
#_END_
		is $pt.format( $tree ), Q:to[_END_].chomp, Q{formatted};
1^^2
_END_
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
#		is $pt.format( $tree ), Q:to[_END_], Q{formatted};
#1 // 2
#_END_
		is $pt.format( $tree ), Q:to[_END_].chomp, Q{formatted};
1//2
_END_
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
#		is $pt.format( $tree ), Q:to[_END_], Q{formatted};
#1 min 2
#_END_
		is $pt.format( $tree ), Q:to[_END_].chomp, Q{formatted};
1min2
_END_
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
#		is $pt.format( $tree ), Q:to[_END_], Q{formatted};
#1 max 2
#_END_
		is $pt.format( $tree ), Q:to[_END_].chomp, Q{formatted};
1max2
_END_
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
#		is $pt.format( $tree ), Q:to[_END_], Q{formatted};
#1 ?? 2 !! 3
#_END_
		is $pt.format( $tree ), Q:to[_END_].chomp, Q{formatted};
1??2!!3
_END_
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
#		is $pt.format( $tree ), Q:to[_END_], Q{formatted};
#1 ff 2
#_END_
		is $pt.format( $tree ), Q:to[_END_].chomp, Q{formatted};
1ff2
_END_
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
#		is $pt.format( $tree ), Q:to[_END_], Q{formatted};
#1 ^ff 2
#_END_
		is $pt.format( $tree ), Q:to[_END_].chomp, Q{formatted};
1^ff2
_END_
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
#		is $pt.format( $tree ), Q:to[_END_], Q{formatted};
#1 ff^ 2
#_END_
		is $pt.format( $tree ), Q:to[_END_].chomp, Q{formatted};
1ff^2
_END_
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
#		is $pt.format( $tree ), Q:to[_END_], Q{formatted};
#1 ^ff^ 2
#_END_
		is $pt.format( $tree ), Q:to[_END_].chomp, Q{formatted};
1^ff^2
_END_
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
#		is $pt.format( $tree ), Q:to[_END_], Q{formatted};
#1 fff 2
#_END_
		is $pt.format( $tree ), Q:to[_END_].chomp, Q{formatted};
1fff2
_END_
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
#		is $pt.format( $tree ), Q:to[_END_], Q{formatted};
#1 ^fff 2
#_END_
		is $pt.format( $tree ), Q:to[_END_].chomp, Q{formatted};
1^fff2
_END_
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
#		is $pt.format( $tree ), Q:to[_END_], Q{formatted};
#1 fff^ 2
#_END_
		is $pt.format( $tree ), Q:to[_END_].chomp, Q{formatted};
1fff^2
_END_
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
#		is $pt.format( $tree ), Q:to[_END_], Q{formatted};
#1 ^fff^ 2
#_END_
		is $pt.format( $tree ), Q:to[_END_].chomp, Q{formatted};
1^fff^2
_END_
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
		is $pt.format( $tree ), Q:to[_END_], Q{formatted};
my $a = 1
_END_
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
		is $pt.format( $tree ), Q:to[_END_], Q{formatted};
a => 1
_END_
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
#		is $pt.format( $tree ), Q:to[_END_], Q{formatted};
#not 1
#_END_
		is $pt.format( $tree ), Q:to[_END_].chomp, Q{formatted};
not1
_END_
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
#		is $pt.format( $tree ), Q:to[_END_], Q{formatted};
#so 1
#_END_
		is $pt.format( $tree ), Q:to[_END_].chomp, Q{formatted};
so1
_END_
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
#		is $pt.format( $tree ), Q:to[_END_], Q{formatted};
#3 , 2
#_END_
		is $pt.format( $tree ), Q:to[_END_].chomp, Q{formatted};
3,2
_END_
	}, Q{,};
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
#		is $pt.format( $tree ), Q:to[_END_], Q{formatted};
#3 Z 2
#_END_
		is $pt.format( $tree ), Q:to[_END_].chomp, Q{formatted};
3Z2
_END_
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
#		is $pt.format( $tree ), Q:to[_END_], Q{formatted};
#3 X 2
#_END_
		is $pt.format( $tree ), Q:to[_END_].chomp, Q{formatted};
3X2
_END_
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
#		is $pt.format( $tree ), Q:to[_END_], Q{formatted};
#1 ... 2
#_END_
		is $pt.format( $tree ), Q:to[_END_].chomp, Q{formatted};
1...2
_END_
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
		is $pt.format( $tree ), Q:to[_END_], Q{formatted};
my $a = 1
_END_
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
		is $pt.format( $tree ), Q:to[_END_], Q{formatted};
my $a := 1
_END_
	}, Q{:=};

	# XXX "::= NIY";

	subtest {
		plan 3;

		my $parsed = $pt.parse-source( Q:to[_END_] );
...
_END_
		my $tree = $pt.build-tree( $parsed );
		ok $pt.validate( $parsed ), Q{valid};
		ok (grep { $_ ~~ Perl6::Operator }, $tree.child.[0].child),
			Q{found operator};
		is $pt.format( $tree ), Q:to[_END_].chomp, Q{formatted};
...
_END_
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
		is $pt.format( $tree ), Q:to[_END_].chomp, Q{formatted};
!!!
_END_
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
		is $pt.format( $tree ), Q:to[_END_].chomp, Q{formatted};
???
_END_
	}, Q{???};

	# XXX Undecided on [+] implementation
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
#		is $pt.format( $tree ), Q:to[_END_], Q{formatted};
#3 and 2
#_END_
		is $pt.format( $tree ), Q:to[_END_].chomp, Q{formatted};
3and2
_END_
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
#		is $pt.format( $tree ), Q:to[_END_], Q{formatted};
#3 andthen 2
#_END_
		is $pt.format( $tree ), Q:to[_END_].chomp, Q{formatted};
3andthen2
_END_
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
#		is $pt.format( $tree ), Q:to[_END_], Q{formatted};
#3 or 2
#_END_
		is $pt.format( $tree ), Q:to[_END_].chomp, Q{formatted};
3or2
_END_
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
#		is $pt.format( $tree ), Q:to[_END_], Q{formatted};
#3 orelse 2
#_END_
		is $pt.format( $tree ), Q:to[_END_].chomp, Q{formatted};
3orelse2
_END_
	}, Q{orelse};
}, Q{Loose OR Precedence};

subtest {
	plan 2;

	subtest {
		plan 3;

		my $parsed = $pt.parse-source( Q:to[_END_] );
my @a; @a <== 'a'
_END_
		my $tree = $pt.build-tree( $parsed );
		ok $pt.validate( $parsed ), Q{valid};
		ok (grep { $_ ~~ Perl6::Operator }, $tree.child.[1].child),
			Q{found operator};
#		is $pt.format( $tree ), Q:to[_END_], Q{formatted};
#my @a; @a <== 'a'
#_END_
		is $pt.format( $tree ), Q:to[_END_].chomp, Q{formatted};
my @a@a<=='a'
_END_
	}, Q{<==};

	subtest {
		plan 3;

		my $parsed = $pt.parse-source( Q:to[_END_] );
my @a; 'a' ==> @a
_END_
		my $tree = $pt.build-tree( $parsed );
		ok $pt.validate( $parsed ), Q{valid};
		ok (grep { $_ ~~ Perl6::Operator }, $tree.child.[1].child),
			Q{found operator};
#		is $pt.format( $tree ), Q:to[_END_], Q{formatted};
#my @a; 'a' ==> @a
#_END_
		is $pt.format( $tree ), Q:to[_END_].chomp, Q{formatted};
my @a'a'==>@a
_END_
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
