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

		my $source = Q:to[_END_];
<a b>
_END_
		my $parsed = $pt.parse-source( $source );
		my $tree = $pt.build-tree( $parsed );
		ok $pt.validate( $parsed ), Q{valid};
		ok grep( { $_ ~~ Perl6::Operator }, $tree.child.[0].child) ),
			Q{found operator};
		is $pt.format( $tree ), $source, Q{formatted};
	}, Q{<>};

#	subtest {
#		plan 2;
#
#		subtest {
#			plan 3;
#
#			my $source = Q[(1)];
#			my $parsed = $pt.parse-source( $source );
#			my $tree = $pt.build-tree( $parsed );
#			ok $pt.validate( $parsed ), Q{valid};
#			ok( grep { $_ ~~ Perl6::Operator }, $tree.child.[0].child,
#				Q{found operator} );
#			is $pt.format( $tree ), $source, Q{formatted};
#		}, Q{no ws};
#
#		subtest {
#			plan 3;
#
##`(
#			my $source = Q:to[_END_];
#( 1 )
#_END_
#			my $parsed = $pt.parse-source( $source );
#			my $tree = $pt.build-tree( $parsed );
#			ok $pt.validate( $parsed ), Q{valid};
#			ok (grep { $_ ~~ Perl6::Operator }, $tree.child.[0].child),
#				Q{found operator};
#			is $pt.format( $tree ), $source, Q{formatted};
#)
#		}, Q{ws};
#	}, Q{()};

	subtest {
		plan 2;

		subtest {
			plan 3;

#`(
			my $source = Q[{1}];
			my $parsed = $pt.parse-source( $source );
			my $tree = $pt.build-tree( $parsed );
			ok $pt.validate( $parsed ), Q{valid};
			ok (grep { $_ ~~ Perl6::Operator }, $tree.child.[0].child),
				Q{found operator};
			is $pt.format( $tree ), $source, Q{formatted};
)
		), Q{no ws};

		subtest {
			plan 3;

#`(
			my $source = Q:to[_END_];
{ 1 }
_END_
			my $parsed = $pt.parse-source( $source );
			my $tree = $pt.build-tree( $parsed );
			ok $pt.validate( $parsed ), Q{valid};
			ok (grep { $_ ~~ Perl6::Operator }, $tree.child.[0].child),
				Q{found operator};
			is $pt.format( $tree ), $source, Q{formatted};
)
		), Q{ws};
	}, Q[{}];

	subtest {
		plan 3;

#`(
		my $source = Q:to[_END_];
[ 1 ]
_END_
		my $parsed = $pt.parse-source( $source );
		my $tree = $pt.build-tree( $parsed );
		ok $pt.validate( $parsed ), Q{valid};
		ok (grep { $_ ~~ Perl6::Operator }, $tree.child.[0].child),
			Q{found operator};
		is $pt.format( $tree ), $source, Q{formatted};
)
	}, Q{[]}
}, Q{Term Precedence};

subtest {
	plan 15;

	subtest {
		plan 3;

#`(
		my $source = Q:to[_END_];
my @a; @a[ 2 ]
_END_
		my $parsed = $pt.parse-source( $source );
		my $tree = $pt.build-tree( $parsed );
		ok $pt.validate( $parsed ), Q{valid};
		ok (grep { $_ ~~ Perl6::Operator }, $tree.child.[0].child),
			Q{found operator};
		is $pt.format( $tree ), $source, Q{formatted};
)
	}, Q{[]};

	subtest {
		plan 3;

#`(
		# Whitespace sensitive between 'a' and '{' '}'
		my $source = Q:to[_END_];
my %a; %a{ "foo" }
_END_
		my $parsed = $pt.parse-source( $source );
		my $tree = $pt.build-tree( $parsed );
		ok $pt.validate( $parsed ), Q{valid};
		ok (grep { $_ ~~ Perl6::Operator }, $tree.child.[0].child),
			Q{found operator};
		is $pt.format( $tree ), $source, Q{formatted};
)
	}, Q[%a{}];

	subtest {
		plan 3;

#`(
		# Whitespace sensitive between 'a' and '<'
		my $source = Q:to[_END_];
my %a; %a< foo >
_END_
		my $parsed = $pt.parse-source( $source );
		my $tree = $pt.build-tree( $parsed );
		ok $pt.validate( $parsed ), Q{valid};
		ok (grep { $_ ~~ Perl6::Operator }, $tree.child.[0].child),
			Q{found operator};
		is $pt.format( $tree ), $source, Q{formatted};
)
	}, Q[%a<>];

	subtest {
		plan 3;

#`(
		# Whitespace sensitive between 'a' and '<'
		my $source = Q:to[_END_];
my %a; %a« foo »
_END_
		my $parsed = $pt.parse-source( $source );
		my $tree = $pt.build-tree( $parsed );
		ok $pt.validate( $parsed ), Q{valid};
		ok (grep { $_ ~~ Perl6::Operator }, $tree.child.[0].child),
			Q{found operator};
		is $pt.format( $tree ), $source, Q{formatted};
)
	}, Q[%a«»];

	subtest {
		plan 2;

		subtest {
			plan 3;

#`(
			# Whitespace sensitive between 'chomp' and '(' ')'
			my $source = Q:to[_END_];
chomp( )
_END_
			my $parsed = $pt.parse-source( $source );
			my $tree = $pt.build-tree( $parsed );
			ok $pt.validate( $parsed ), Q{valid};
			ok (grep { $_ ~~ Perl6::Operator }, $tree.child.[0].child),
				Q{found operator};
			is $pt.format( $tree ), $source, Q{formatted};
)
		}, Q{no arguments};

		subtest {
			plan 3;

#`(
			# Whitespace sensitive between 'chomp' and '(' ')'
			my $source = Q:to[_END_];
chomp( 1 )
_END_
			my $parsed = $pt.parse-source( $source );
			my $tree = $pt.build-tree( $parsed );
			ok $pt.validate( $parsed ), Q{valid};
		ok (grep { $_ ~~ Perl6::Operator }, $tree.child.[0].child),
			Q{found operator};
			is $pt.format( $tree ), $source, Q{formatted};
)
		}, Q{with arguments};
	}, Q{func()};

	subtest {
		plan 3;

#`(
		my $source = Q:to[_END_];
42.round
_END_
		my $parsed = $pt.parse-source( $source );
		my $tree = $pt.build-tree( $parsed );
		ok $pt.validate( $parsed ), Q{valid};
		ok (grep { $_ ~~ Perl6::Operator }, $tree.child.[0].child),
			Q{found operator};
		is $pt.format( $tree ), $source, Q{formatted};
)
	}, Q{.};

	subtest {
		plan 3;

#`(
		my $source = Q:to[_END_];
42.&round
_END_
		my $parsed = $pt.parse-source( $source );
		my $tree = $pt.build-tree( $parsed );
		ok $pt.validate( $parsed ), Q{valid};
		ok (grep { $_ ~~ Perl6::Operator }, $tree.child.[0].child),
			Q{found operator};
		is $pt.format( $tree ), $source, Q{formatted};
)
	}, Q{.&};

	subtest {
		plan 3;

#`(
		my $source = Q:to[_END_];
Int.=round
_END_
		my $parsed = $pt.parse-source( $source );
		my $tree = $pt.build-tree( $parsed );
		ok $pt.validate( $parsed ), Q{valid};
		ok (grep { $_ ~~ Perl6::Operator }, $tree.child.[0].child),
			Q{found operator};
		is $pt.format( $tree ), $source, Q{formatted};
)
	}, Q{.=};

	subtest {
		plan 3;

#`(
		my $source = Q:to[_END_];
42.^name
_END_
		my $parsed = $pt.parse-source( $source );
		my $tree = $pt.build-tree( $parsed );
		ok $pt.validate( $parsed ), Q{valid};
		ok (grep { $_ ~~ Perl6::Operator }, $tree.child.[0].child),
			Q{found operator};
		is $pt.format( $tree ), $source, Q{formatted};
)
	}, Q{.^};

	subtest {
		plan 3;

#`(
		my $source = Q:to[_END_];
42.?name
_END_
		my $parsed = $pt.parse-source( $source );
		my $tree = $pt.build-tree( $parsed );
		ok $pt.validate( $parsed ), Q{valid};
		ok (grep { $_ ~~ Perl6::Operator }, $tree.child.[0].child),
			Q{found operator};
		is $pt.format( $tree ), $source, Q{formatted};
)
	}, Q{.?};

	subtest {
		plan 3;

#`(
		my $source = Q:to[_END_];
42.+name
_END_
		my $parsed = $pt.parse-source( $source );
		my $tree = $pt.build-tree( $parsed );
		ok $pt.validate( $parsed ), Q{valid};
		ok (grep { $_ ~~ Perl6::Operator }, $tree.child.[0].child),
			Q{found operator};
		is $pt.format( $tree ), $source, Q{formatted};
)
	}, Q{.+};

	subtest {
		plan 3;

#`(
		my $source = Q:to[_END_];
42.*name
_END_
		my $parsed = $pt.parse-source( $source );
		my $tree = $pt.build-tree( $parsed );
		ok $pt.validate( $parsed ), Q{valid};
		ok (grep { $_ ~~ Perl6::Operator }, $tree.child.[0].child),
			Q{found operator};
		is $pt.format( $tree ), $source, Q{formatted};
)
	}, Q{.*};

	subtest {
		plan 3;

#`(
		my $source = Q:to[_END_];
42>>.say
_END_
		my $parsed = $pt.parse-source( $source );
		my $tree = $pt.build-tree( $parsed );
		ok $pt.validate( $parsed ), Q{valid};
		ok (grep { $_ ~~ Perl6::Operator }, $tree.child.[0].child),
			Q{found operator};
		is $pt.format( $tree ), $source, Q{formatted};
)
	}, Q{>>.};

	subtest {
		plan 3;

#`(
		my $source = Q:to[_END_];
my $a; $a.:<++>
_END_
		my $parsed = $pt.parse-source( $source );
		my $tree = $pt.build-tree( $parsed );
		ok $pt.validate( $parsed ), Q{valid};
		ok (grep { $_ ~~ Perl6::Operator }, $tree.child.[0].child),
			Q{found operator};
		is $pt.format( $tree ), $source, Q{formatted};
)
	}, Q{.:};

	subtest {
		plan 3;

#`(
		my $source = Q:to[_END_];
my $a; $a.Foo::Bar
_END_
		my $parsed = $pt.parse-source( $source );
		my $tree = $pt.build-tree( $parsed );
		ok $pt.validate( $parsed ), Q{valid};
		ok (grep { $_ ~~ Perl6::Operator }, $tree.child.[0].child),
			Q{found operator};
		is $pt.format( $tree ), $source, Q{formatted};
)
	}, Q{.::};
}, Q{Method Postfix Precedence};

subtest {
	plan 4;

	subtest {
		plan 3;

#`(
		my $source = Q:to[_END_];
my $a; ++ $a
_END_
		my $parsed = $pt.parse-source( $source );
		my $tree = $pt.build-tree( $parsed );
		ok $pt.validate( $parsed ), Q{valid};
		ok (grep { $_ ~~ Perl6::Operator }, $tree.child.[0].child),
			Q{found operator};
		is $pt.format( $tree ), $source, Q{formatted};
)
	}, Q{++$a};

	subtest {
		plan 3;

#`(
		my $source = Q:to[_END_];
my $a; -- $a
_END_
		my $parsed = $pt.parse-source( $source );
		my $tree = $pt.build-tree( $parsed );
		ok $pt.validate( $parsed ), Q{valid};
		ok (grep { $_ ~~ Perl6::Operator }, $tree.child.[0].child),
			Q{found operator};
		is $pt.format( $tree ), $source, Q{formatted};
)
	}, Q{--$a};

	subtest {
		plan 3;

#`(
		# XXX Note whitespace sensitivity here.
		my $source = Q:to[_END_];
my $a; $a++
_END_
		my $parsed = $pt.parse-source( $source );
		my $tree = $pt.build-tree( $parsed );
		ok $pt.validate( $parsed ), Q{valid};
		ok (grep { $_ ~~ Perl6::Operator }, $tree.child.[0].child),
			Q{found operator};
		is $pt.format( $tree ), $source, Q{formatted};
)
	}, Q{$a++};

	subtest {
		plan 3;

#`(
		# XXX Note whitespace sensitivity here.
		my $source = Q:to[_END_];
my $a; $a--
_END_
		my $parsed = $pt.parse-source( $source );
		my $tree = $pt.build-tree( $parsed );
		ok $pt.validate( $parsed ), Q{valid};
		ok (grep { $_ ~~ Perl6::Operator }, $tree.child.[0].child),
			Q{found operator};
		is $pt.format( $tree ), $source, Q{formatted};
)
	}, Q{$a--};
}, Q{Autoincrement Precedence};

subtest {
	plan 1;

	subtest {
		plan 3;

#`(
		my $source = Q:to[_END_];
1 ** 2
_END_
		my $parsed = $pt.parse-source( $source );
		my $tree = $pt.build-tree( $parsed );
		ok $pt.validate( $parsed ), Q{valid};
		ok (grep { $_ ~~ Perl6::Operator }, $tree.child.[0].child),
			Q{found operator};
		is $pt.format( $tree ), $source, Q{formatted};
)
	}, Q{?};
}, Q{Exponentiation Precedence};

subtest {
	plan 9;

	subtest {
		plan 3;

#`(
		my $source = Q:to[_END_];
? 2
_END_
		my $parsed = $pt.parse-source( $source );
		my $tree = $pt.build-tree( $parsed );
		ok $pt.validate( $parsed ), Q{valid};
		ok (grep { $_ ~~ Perl6::Operator }, $tree.child.[0].child),
			Q{found operator};
		is $pt.format( $tree ), $source, Q{formatted};
)
	}, Q{?};

	subtest {
		plan 3;

#`(
		my $source = Q:to[_END_];
! 2
_END_
		my $parsed = $pt.parse-source( $source );
		my $tree = $pt.build-tree( $parsed );
		ok $pt.validate( $parsed ), Q{valid};
		ok (grep { $_ ~~ Perl6::Operator }, $tree.child.[0].child),
			Q{found operator};
		is $pt.format( $tree ), $source, Q{formatted};
)
	}, Q{!};

	subtest {
		plan 3;

#`(
		my $source = Q:to[_END_];
+ 2
_END_
		my $parsed = $pt.parse-source( $source );
		my $tree = $pt.build-tree( $parsed );
		ok $pt.validate( $parsed ), Q{valid};
		ok (grep { $_ ~~ Perl6::Operator }, $tree.child.[0].child),
			Q{found operator};
		is $pt.format( $tree ), $source, Q{formatted};
)
	}, Q{+};

	subtest {
		plan 3;

#`(
		my $source = Q:to[_END_];
- 2
_END_
		my $parsed = $pt.parse-source( $source );
		my $tree = $pt.build-tree( $parsed );
		ok $pt.validate( $parsed ), Q{valid};
		ok (grep { $_ ~~ Perl6::Operator }, $tree.child.[0].child),
			Q{found operator};
		is $pt.format( $tree ), $source, Q{formatted};
)
	}, Q{-};

	subtest {
		plan 3;

#`(
		my $source = Q:to[_END_];
~ 2
_END_
		my $parsed = $pt.parse-source( $source );
		my $tree = $pt.build-tree( $parsed );
		ok $pt.validate( $parsed ), Q{valid};
		ok (grep { $_ ~~ Perl6::Operator }, $tree.child.[0].child),
			Q{found operator};
		is $pt.format( $tree ), $source, Q{formatted};
)
	}, Q{~};

	subtest {
		plan 3;

#`(
		my $source = Q:to[_END_];
| 2
_END_
		my $parsed = $pt.parse-source( $source );
		my $tree = $pt.build-tree( $parsed );
		ok $pt.validate( $parsed ), Q{valid};
		ok (grep { $_ ~~ Perl6::Operator }, $tree.child.[0].child),
			Q{found operator};
		is $pt.format( $tree ), $source, Q{formatted};
)
	}, Q{|};

	subtest {
		plan 3;

#`(
		my $source = Q:to[_END_];
+^ 2
_END_
		my $parsed = $pt.parse-source( $source );
		my $tree = $pt.build-tree( $parsed );
		ok $pt.validate( $parsed ), Q{valid};
		ok (grep { $_ ~~ Perl6::Operator }, $tree.child.[0].child),
			Q{found operator};
		is $pt.format( $tree ), $source, Q{formatted};
)
	}, Q{+^};

	subtest {
		plan 3;

#`(
		my $source = Q:to[_END_];
?^ 2
_END_
		my $parsed = $pt.parse-source( $source );
		my $tree = $pt.build-tree( $parsed );
		ok $pt.validate( $parsed ), Q{valid};
		ok (grep { $_ ~~ Perl6::Operator }, $tree.child.[0].child),
			Q{found operator};
		is $pt.format( $tree ), $source, Q{formatted};
)
	}, Q{?^};

	subtest {
		plan 3;

#`(
		my $source = Q:to[_END_];
^ 2
_END_
		my $parsed = $pt.parse-source( $source );
		my $tree = $pt.build-tree( $parsed );
		ok $pt.validate( $parsed ), Q{valid};
		ok (grep { $_ ~~ Perl6::Operator }, $tree.child.[0].child),
			Q{found operator};
		is $pt.format( $tree ), $source, Q{formatted};
)
	}, Q{^};
}, Q{Symbolic Unary Precedence};

subtest {
	plan 11;

	subtest {
		plan 3;

#`(
		my $source = Q:to[_END_];
1 * 2
_END_
		my $parsed = $pt.parse-source( $source );
		my $tree = $pt.build-tree( $parsed );
		ok $pt.validate( $parsed ), Q{valid};
		ok (grep { $_ ~~ Perl6::Operator }, $tree.child.[0].child),
			Q{found operator};
		is $pt.format( $tree ), $source, Q{formatted};
)
	}, Q{*};

	subtest {
		plan 3;

#`(
		my $source = Q:to[_END_];
1 / 2
_END_
		my $parsed = $pt.parse-source( $source );
		my $tree = $pt.build-tree( $parsed );
		ok $pt.validate( $parsed ), Q{valid};
		ok (grep { $_ ~~ Perl6::Operator }, $tree.child.[0].child),
			Q{found operator};
		is $pt.format( $tree ), $source, Q{formatted};
)
	}, Q{/};

	subtest {
		plan 3;

#`(
		my $source = Q:to[_END_];
1 div 2
_END_
		my $parsed = $pt.parse-source( $source );
		my $tree = $pt.build-tree( $parsed );
		ok $pt.validate( $parsed ), Q{valid};
		ok (grep { $_ ~~ Perl6::Operator }, $tree.child.[0].child),
			Q{found operator};
		is $pt.format( $tree ), $source, Q{formatted};
)
	}, Q{div};

	subtest {
		plan 3;

#`(
		my $source = Q:to[_END_];
1 % 2
_END_
		my $parsed = $pt.parse-source( $source );
		my $tree = $pt.build-tree( $parsed );
		ok $pt.validate( $parsed ), Q{valid};
		ok (grep { $_ ~~ Perl6::Operator }, $tree.child.[0].child),
			Q{found operator};
		is $pt.format( $tree ), $source, Q{formatted};
)
	}, Q{%};

	subtest {
		plan 3;

#`(
		my $source = Q:to[_END_];
1 %% 2
_END_
		my $parsed = $pt.parse-source( $source );
		my $tree = $pt.build-tree( $parsed );
		ok $pt.validate( $parsed ), Q{valid};
		ok (grep { $_ ~~ Perl6::Operator }, $tree.child.[0].child),
			Q{found operator};
		is $pt.format( $tree ), $source, Q{formatted};
)
	}, Q{%%};

	subtest {
		plan 3;

#`(
		my $source = Q:to[_END_];
1 mod 2
_END_
		my $parsed = $pt.parse-source( $source );
		my $tree = $pt.build-tree( $parsed );
		ok $pt.validate( $parsed ), Q{valid};
		ok (grep { $_ ~~ Perl6::Operator }, $tree.child.[0].child),
			Q{found operator};
		is $pt.format( $tree ), $source, Q{formatted};
)
	}, Q{mod};

	subtest {
		plan 3;

#`(
		my $source = Q:to[_END_];
1 +& 2
_END_
		my $parsed = $pt.parse-source( $source );
		my $tree = $pt.build-tree( $parsed );
		ok $pt.validate( $parsed ), Q{valid};
		ok (grep { $_ ~~ Perl6::Operator }, $tree.child.[0].child),
			Q{found operator};
		is $pt.format( $tree ), $source, Q{formatted};
)
	}, Q{+&};

	subtest {
		plan 3;

#`(
		my $source = Q:to[_END_];
1 +< 2
_END_
		my $parsed = $pt.parse-source( $source );
		my $tree = $pt.build-tree( $parsed );
		ok $pt.validate( $parsed ), Q{valid};
		ok (grep { $_ ~~ Perl6::Operator }, $tree.child.[0].child),
			Q{found operator};
		is $pt.format( $tree ), $source, Q{formatted};
)
	}, Q{+<};

	subtest {
		plan 3;

#`(
		my $source = Q:to[_END_];
1 +> 2
_END_
		my $parsed = $pt.parse-source( $source );
		my $tree = $pt.build-tree( $parsed );
		ok $pt.validate( $parsed ), Q{valid};
		ok (grep { $_ ~~ Perl6::Operator }, $tree.child.[0].child),
			Q{found operator};
		is $pt.format( $tree ), $source, Q{formatted};
)
	}, Q{+>};

	subtest {
		plan 3;

#`(
		my $source = Q:to[_END_];
1 gcd 2
_END_
		my $parsed = $pt.parse-source( $source );
		my $tree = $pt.build-tree( $parsed );
		ok $pt.validate( $parsed ), Q{valid};
		ok (grep { $_ ~~ Perl6::Operator }, $tree.child.[0].child),
			Q{found operator};
		is $pt.format( $tree ), $source, Q{formatted};
)
	}, Q{gcd};

	subtest {
		plan 3;

#`(
		my $source = Q:to[_END_];
1 lcm 2
_END_
		my $parsed = $pt.parse-source( $source );
		my $tree = $pt.build-tree( $parsed );
		ok $pt.validate( $parsed ), Q{valid};
		ok (grep { $_ ~~ Perl6::Operator }, $tree.child.[0].child),
			Q{found operator};
		is $pt.format( $tree ), $source, Q{formatted};
)
	}, Q{lcm};
}, Q{Multipicative Precedence};

subtest {
	plan 5;

	subtest {
		plan 3;

#`(
		my $source = Q:to[_END_];
1 + 2
_END_
		my $parsed = $pt.parse-source( $source );
		my $tree = $pt.build-tree( $parsed );
		ok $pt.validate( $parsed ), Q{valid};
		ok (grep { $_ ~~ Perl6::Operator }, $tree.child.[0].child),
			Q{found operator};
		is $pt.format( $tree ), $source, Q{formatted};
)
	}, Q{+};

	subtest {
		plan 3;

#`(
		my $source = Q:to[_END_];
1 - 2
_END_
		my $parsed = $pt.parse-source( $source );
		my $tree = $pt.build-tree( $parsed );
		ok $pt.validate( $parsed ), Q{valid};
		ok (grep { $_ ~~ Perl6::Operator }, $tree.child.[0].child),
			Q{found operator};
		is $pt.format( $tree ), $source, Q{formatted};
)
	}, Q{-};

	subtest {
		plan 3;

#`(
		my $source = Q:to[_END_];
1 +| 2
_END_
		my $parsed = $pt.parse-source( $source );
		my $tree = $pt.build-tree( $parsed );
		ok $pt.validate( $parsed ), Q{valid};
		ok (grep { $_ ~~ Perl6::Operator }, $tree.child.[0].child),
			Q{found operator};
		is $pt.format( $tree ), $source, Q{formatted};
)
	}, Q{+|};

	subtest {
		plan 3;

#`(
		my $source = Q:to[_END_];
1 +^ 2
_END_
		my $parsed = $pt.parse-source( $source );
		my $tree = $pt.build-tree( $parsed );
		ok $pt.validate( $parsed ), Q{valid};
		ok (grep { $_ ~~ Perl6::Operator }, $tree.child.[0].child),
			Q{found operator};
		is $pt.format( $tree ), $source, Q{formatted};
)
	}, Q{+^};

	subtest {
		plan 3;

#`(
		my $source = Q:to[_END_];
1 ?| 2
_END_
		my $parsed = $pt.parse-source( $source );
		my $tree = $pt.build-tree( $parsed );
		ok $pt.validate( $parsed ), Q{valid};
		ok (grep { $_ ~~ Perl6::Operator }, $tree.child.[0].child),
			Q{found operator};
		is $pt.format( $tree ), $source, Q{formatted};
)
	}, Q{?|};
}, Q{Additive Precedence};

subtest {
	plan 2;

	subtest {
		plan 3;

#`(
		my $source = Q:to[_END_];
1 x 2
_END_
		my $parsed = $pt.parse-source( $source );
		my $tree = $pt.build-tree( $parsed );
		ok $pt.validate( $parsed ), Q{valid};
		ok (grep { $_ ~~ Perl6::Operator }, $tree.child.[0].child),
			Q{found operator};
		is $pt.format( $tree ), $source, Q{formatted};
)
	}, Q{x};

	subtest {
		plan 3;

#`(
		my $source = Q:to[_END_];
1 xx 2
_END_
		my $parsed = $pt.parse-source( $source );
		my $tree = $pt.build-tree( $parsed );
		ok $pt.validate( $parsed ), Q{valid};
		ok (grep { $_ ~~ Perl6::Operator }, $tree.child.[0].child),
			Q{found operator};
		is $pt.format( $tree ), $source, Q{formatted};
)
	}, Q{xx};
}, Q{Replication Precedence};

subtest {
	plan 1;

	subtest {
		plan 3;

#`(
		my $source = Q:to[_END_];
1 ~ 2
_END_
		my $parsed = $pt.parse-source( $source );
		my $tree = $pt.build-tree( $parsed );
		ok $pt.validate( $parsed ), Q{valid};
		ok (grep { $_ ~~ Perl6::Operator }, $tree.child.[0].child),
			Q{found operator};
		is $pt.format( $tree ), $source, Q{formatted};
)
	}, Q{~};
}, Q{Concatenation Precedence};

subtest {
	plan 1;

	subtest {
		plan 3;

#`(
		my $source = Q:to[_END_];
1 & 2
_END_
		my $parsed = $pt.parse-source( $source );
		my $tree = $pt.build-tree( $parsed );
		ok $pt.validate( $parsed ), Q{valid};
		ok (grep { $_ ~~ Perl6::Operator }, $tree.child.[0].child),
			Q{found operator};
		is $pt.format( $tree ), $source, Q{formatted};
)
	}, Q{&};
}, Q{Junctive AND Precedence};

subtest {
	plan 2;

	subtest {
		plan 3;

#`(
		my $source = Q:to[_END_];
1 | 2
_END_
		my $parsed = $pt.parse-source( $source );
		my $tree = $pt.build-tree( $parsed );
		ok $pt.validate( $parsed ), Q{valid};
		ok (grep { $_ ~~ Perl6::Operator }, $tree.child.[0].child),
			Q{found operator};
		is $pt.format( $tree ), $source, Q{formatted};
)
	}, Q{|};

	subtest {
		plan 3;

#`(
		my $source = Q:to[_END_];
1 ^ 2
_END_
		my $parsed = $pt.parse-source( $source );
		my $tree = $pt.build-tree( $parsed );
		ok $pt.validate( $parsed ), Q{valid};
		ok (grep { $_ ~~ Perl6::Operator }, $tree.child.[0].child),
			Q{found operator};
		is $pt.format( $tree ), $source, Q{formatted};
)
	}, Q{^};
}, Q{Junctive OR Precedence};

subtest {
	plan 2;

	subtest {
		plan 3;

#`(
		my $source = Q:to[_END_];
my $a; temp $a
_END_
		my $parsed = $pt.parse-source( $source );
		my $tree = $pt.build-tree( $parsed );
		ok $pt.validate( $parsed ), Q{valid};
		ok (grep { $_ ~~ Perl6::Operator }, $tree.child.[0].child),
			Q{found operator};
		is $pt.format( $tree ), $source, Q{formatted};
)
	}, Q{temp};

	subtest {
		plan 3;

#`(
		my $source = Q:to[_END_];
my $a; let $a
_END_
		my $parsed = $pt.parse-source( $source );
		my $tree = $pt.build-tree( $parsed );
		ok $pt.validate( $parsed ), Q{valid};
		ok (grep { $_ ~~ Perl6::Operator }, $tree.child.[0].child),
			Q{found operator};
		is $pt.format( $tree ), $source, Q{formatted};
)
	}, Q{let};
}, Q{Named Unary Precedence};

subtest {
	plan 9;

	subtest {
		plan 3;

#`(
		my $source = Q:to[_END_];
1 does 2
_END_
		my $parsed = $pt.parse-source( $source );
		my $tree = $pt.build-tree( $parsed );
		ok $pt.validate( $parsed ), Q{valid};
		ok (grep { $_ ~~ Perl6::Operator }, $tree.child.[0].child),
			Q{found operator};
		is $pt.format( $tree ), $source, Q{formatted};
)
	}, Q{does};

	subtest {
		plan 3;

#`(
		my $source = Q:to[_END_];
1 but 2
_END_
		my $parsed = $pt.parse-source( $source );
		my $tree = $pt.build-tree( $parsed );
		ok $pt.validate( $parsed ), Q{valid};
		ok (grep { $_ ~~ Perl6::Operator }, $tree.child.[0].child),
			Q{found operator};
		is $pt.format( $tree ), $source, Q{formatted};
)
	}, Q{but};

	subtest {
		plan 3;

#`(
		my $source = Q:to[_END_];
1 cmp 2
_END_
		my $parsed = $pt.parse-source( $source );
		my $tree = $pt.build-tree( $parsed );
		ok $pt.validate( $parsed ), Q{valid};
		ok (grep { $_ ~~ Perl6::Operator }, $tree.child.[0].child),
			Q{found operator};
		is $pt.format( $tree ), $source, Q{formatted};
)
	}, Q{cmp};

	subtest {
		plan 3;

#`(
		my $source = Q:to[_END_];
1 leg 2
_END_
		my $parsed = $pt.parse-source( $source );
		my $tree = $pt.build-tree( $parsed );
		ok $pt.validate( $parsed ), Q{valid};
		ok (grep { $_ ~~ Perl6::Operator }, $tree.child.[0].child),
			Q{found operator};
		is $pt.format( $tree ), $source, Q{formatted};
)
	}, Q{leg};

	subtest {
		plan 3;

#`(
		my $source = Q:to[_END_];
1 <=> 2
_END_
		my $parsed = $pt.parse-source( $source );
		my $tree = $pt.build-tree( $parsed );
		ok $pt.validate( $parsed ), Q{valid};
		ok (grep { $_ ~~ Perl6::Operator }, $tree.child.[0].child),
			Q{found operator};
		is $pt.format( $tree ), $source, Q{formatted};
)
	}, Q{<=>};

	subtest {
		plan 3;

#`(
		my $source = Q:to[_END_];
1 .. 2
_END_
		my $parsed = $pt.parse-source( $source );
		my $tree = $pt.build-tree( $parsed );
		ok $pt.validate( $parsed ), Q{valid};
		ok (grep { $_ ~~ Perl6::Operator }, $tree.child.[0].child),
			Q{found operator};
		is $pt.format( $tree ), $source, Q{formatted};
)
	}, Q{..};

	subtest {
		plan 3;

#`(
		my $source = Q:to[_END_];
1 ^.. 2
_END_
		my $parsed = $pt.parse-source( $source );
		my $tree = $pt.build-tree( $parsed );
		ok $pt.validate( $parsed ), Q{valid};
		ok (grep { $_ ~~ Perl6::Operator }, $tree.child.[0].child),
			Q{found operator};
		is $pt.format( $tree ), $source, Q{formatted};
)
	}, Q{^..};

	subtest {
		plan 3;

#`(
		my $source = Q:to[_END_];
1 ..^ 2
_END_
		my $parsed = $pt.parse-source( $source );
		my $tree = $pt.build-tree( $parsed );
		ok $pt.validate( $parsed ), Q{valid};
		ok (grep { $_ ~~ Perl6::Operator }, $tree.child.[0].child),
			Q{found operator};
		is $pt.format( $tree ), $source, Q{formatted};
)
	}, Q{..^};

	subtest {
		plan 3;

#`(
		my $source = Q:to[_END_];
1 ^..^ 2
_END_
		my $parsed = $pt.parse-source( $source );
		my $tree = $pt.build-tree( $parsed );
		ok $pt.validate( $parsed ), Q{valid};
		ok (grep { $_ ~~ Perl6::Operator }, $tree.child.[0].child),
			Q{found operator};
		is $pt.format( $tree ), $source, Q{formatted};
)
	}, Q{^..^};
}, Q{Nonchaining Binary Precedence};

subtest {
	plan 21;

	subtest {
		plan 3;

#`(
		my $source = Q:to[_END_];
1 == 2
_END_
		my $parsed = $pt.parse-source( $source );
		my $tree = $pt.build-tree( $parsed );
		ok $pt.validate( $parsed ), Q{valid};
		ok (grep { $_ ~~ Perl6::Operator }, $tree.child.[0].child),
			Q{found operator};
		is $pt.format( $tree ), $source, Q{formatted};
)
	}, Q{==};

	subtest {
		plan 3;

#`(
		my $source = Q:to[_END_];
1 != 2
_END_
		my $parsed = $pt.parse-source( $source );
		my $tree = $pt.build-tree( $parsed );
		ok $pt.validate( $parsed ), Q{valid};
		ok (grep { $_ ~~ Perl6::Operator }, $tree.child.[0].child),
			Q{found operator};
		is $pt.format( $tree ), $source, Q{formatted};
)
	}, Q{!=};

	subtest {
		plan 3;

#`(
		my $source = Q:to[_END_];
1 < 2
_END_
		my $parsed = $pt.parse-source( $source );
		my $tree = $pt.build-tree( $parsed );
		ok $pt.validate( $parsed ), Q{valid};
		ok (grep { $_ ~~ Perl6::Operator }, $tree.child.[0].child),
			Q{found operator};
		is $pt.format( $tree ), $source, Q{formatted};
)
	}, Q{<};

	subtest {
		plan 3;

#`(
		my $source = Q:to[_END_];
1 <= 2
_END_
		my $parsed = $pt.parse-source( $source );
		my $tree = $pt.build-tree( $parsed );
		ok $pt.validate( $parsed ), Q{valid};
		ok (grep { $_ ~~ Perl6::Operator }, $tree.child.[0].child),
			Q{found operator};
		is $pt.format( $tree ), $source, Q{formatted};
)
	}, Q{<=};

	subtest {
		plan 3;

#`(
		my $source = Q:to[_END_];
1 > 2
_END_
		my $parsed = $pt.parse-source( $source );
		my $tree = $pt.build-tree( $parsed );
		ok $pt.validate( $parsed ), Q{valid};
		ok (grep { $_ ~~ Perl6::Operator }, $tree.child.[0].child),
			Q{found operator};
		is $pt.format( $tree ), $source, Q{formatted};
)
	}, Q{>};

	subtest {
		plan 3;

#`(
		my $source = Q:to[_END_];
1 <= 2
_END_
		my $parsed = $pt.parse-source( $source );
		my $tree = $pt.build-tree( $parsed );
		ok $pt.validate( $parsed ), Q{valid};
		ok (grep { $_ ~~ Perl6::Operator }, $tree.child.[0].child),
			Q{found operator};
		is $pt.format( $tree ), $source, Q{formatted};
)
	}, Q{<=};

	subtest {
		plan 3;

#`(
		my $source = Q:to[_END_];
1 > 2
_END_
		my $parsed = $pt.parse-source( $source );
		my $tree = $pt.build-tree( $parsed );
		ok $pt.validate( $parsed ), Q{valid};
		ok (grep { $_ ~~ Perl6::Operator }, $tree.child.[0].child),
			Q{found operator};
		is $pt.format( $tree ), $source, Q{formatted};
)
	}, Q{>};

	subtest {
		plan 3;

#`(
		my $source = Q:to[_END_];
1 >= 2
_END_
		my $parsed = $pt.parse-source( $source );
		my $tree = $pt.build-tree( $parsed );
		ok $pt.validate( $parsed ), Q{valid};
		ok (grep { $_ ~~ Perl6::Operator }, $tree.child.[0].child),
			Q{found operator};
		is $pt.format( $tree ), $source, Q{formatted};
)
	}, Q{>=};

	subtest {
		plan 3;

#`(
		my $source = Q:to[_END_];
1 eq 2
_END_
		my $parsed = $pt.parse-source( $source );
		my $tree = $pt.build-tree( $parsed );
		ok $pt.validate( $parsed ), Q{valid};
		ok (grep { $_ ~~ Perl6::Operator }, $tree.child.[0].child),
			Q{found operator};
		is $pt.format( $tree ), $source, Q{formatted};
)
	}, Q{eq};

	subtest {
		plan 3;

#`(
		my $source = Q:to[_END_];
1 ne 2
_END_
		my $parsed = $pt.parse-source( $source );
		my $tree = $pt.build-tree( $parsed );
		ok $pt.validate( $parsed ), Q{valid};
		ok (grep { $_ ~~ Perl6::Operator }, $tree.child.[0].child),
			Q{found operator};
		is $pt.format( $tree ), $source, Q{formatted};
)
	}, Q{ne};

	subtest {
		plan 3;

#`(
		my $source = Q:to[_END_];
1 gt 2
_END_
		my $parsed = $pt.parse-source( $source );
		my $tree = $pt.build-tree( $parsed );
		ok $pt.validate( $parsed ), Q{valid};
		ok (grep { $_ ~~ Perl6::Operator }, $tree.child.[0].child),
			Q{found operator};
		is $pt.format( $tree ), $source, Q{formatted};
)
	}, Q{gt};

	subtest {
		plan 3;

#`(
		my $source = Q:to[_END_];
1 ge 2
_END_
		my $parsed = $pt.parse-source( $source );
		my $tree = $pt.build-tree( $parsed );
		ok $pt.validate( $parsed ), Q{valid};
		ok (grep { $_ ~~ Perl6::Operator }, $tree.child.[0].child),
			Q{found operator};
		is $pt.format( $tree ), $source, Q{formatted};
)
	}, Q{ge};

	subtest {
		plan 3;

#`(
		my $source = Q:to[_END_];
( 1 )
_END_
		my $parsed = $pt.parse-source( $source );
		my $tree = $pt.build-tree( $parsed );
		ok $pt.validate( $parsed ), Q{valid};
		ok (grep { $_ ~~ Perl6::Operator }, $tree.child.[0].child),
			Q{found operator};
		is $pt.format( $tree ), $source, Q{formatted};
)
	}, Q{lt};

	subtest {
		plan 3;

#`(
		my $source = Q:to[_END_];
1 le 2
_END_
		my $parsed = $pt.parse-source( $source );
		my $tree = $pt.build-tree( $parsed );
		ok $pt.validate( $parsed ), Q{valid};
		ok (grep { $_ ~~ Perl6::Operator }, $tree.child.[0].child),
			Q{found operator};
		is $pt.format( $tree ), $source, Q{formatted};
)
	}, Q{le};

	subtest {
		plan 3;

#`(
		my $source = Q:to[_END_];
1 before 2
_END_
		my $parsed = $pt.parse-source( $source );
		my $tree = $pt.build-tree( $parsed );
		ok $pt.validate( $parsed ), Q{valid};
		ok (grep { $_ ~~ Perl6::Operator }, $tree.child.[0].child),
			Q{found operator};
		is $pt.format( $tree ), $source, Q{formatted};
)
	}, Q{before};

	subtest {
		plan 3;

#`(
		my $source = Q:to[_END_];
1 after 2
_END_
		my $parsed = $pt.parse-source( $source );
		my $tree = $pt.build-tree( $parsed );
		ok $pt.validate( $parsed ), Q{valid};
		ok (grep { $_ ~~ Perl6::Operator }, $tree.child.[0].child),
			Q{found operator};
		is $pt.format( $tree ), $source, Q{formatted};
)
	}, Q{after};

	subtest {
		plan 3;

#`(
		my $source = Q:to[_END_];
1 eqv 2
_END_
		my $parsed = $pt.parse-source( $source );
		my $tree = $pt.build-tree( $parsed );
		ok $pt.validate( $parsed ), Q{valid};
		ok (grep { $_ ~~ Perl6::Operator }, $tree.child.[0].child),
			Q{found operator};
		is $pt.format( $tree ), $source, Q{formatted};
)
	}, Q{eqv};

	subtest {
		plan 3;

#`(
		my $source = Q:to[_END_];
1 === 2
_END_
		my $parsed = $pt.parse-source( $source );
		my $tree = $pt.build-tree( $parsed );
		ok $pt.validate( $parsed ), Q{valid};
		ok (grep { $_ ~~ Perl6::Operator }, $tree.child.[0].child),
			Q{found operator};
		is $pt.format( $tree ), $source, Q{formatted};
)
	}, Q{===};

	subtest {
		plan 3;

#`(
		my $source = Q:to[_END_];
1 =:= 2
_END_
		my $parsed = $pt.parse-source( $source );
		my $tree = $pt.build-tree( $parsed );
		ok $pt.validate( $parsed ), Q{valid};
		ok (grep { $_ ~~ Perl6::Operator }, $tree.child.[0].child),
			Q{found operator};
		is $pt.format( $tree ), $source, Q{formatted};
)
	}, Q{=:=};

	subtest {
		plan 3;

#`(
		my $source = Q:to[_END_];
1 ~~ 2
_END_
		my $parsed = $pt.parse-source( $source );
		my $tree = $pt.build-tree( $parsed );
		ok $pt.validate( $parsed ), Q{valid};
		ok (grep { $_ ~~ Perl6::Operator }, $tree.child.[0].child),
			Q{found operator};
		is $pt.format( $tree ), $source, Q{formatted};
)
	}, Q{~~};

	subtest {
		plan 3;

#`(
		my $source = Q:to[_END_];
1 =~= 2
_END_
		my $parsed = $pt.parse-source( $source );
		my $tree = $pt.build-tree( $parsed );
		ok $pt.validate( $parsed ), Q{valid};
		ok (grep { $_ ~~ Perl6::Operator }, $tree.child.[0].child),
			Q{found operator};
		is $pt.format( $tree ), $source, Q{formatted};
)
	}, Q{=~=};
}, Q{Chaining Binary Precedence};

subtest {
	plan 1;

	subtest {
		plan 3;

#`(
		my $source = Q:to[_END_];
1 && 2
_END_
		my $parsed = $pt.parse-source( $source );
		my $tree = $pt.build-tree( $parsed );
		ok $pt.validate( $parsed ), Q{valid};
		ok (grep { $_ ~~ Perl6::Operator }, $tree.child.[0].child),
			Q{found operator};
		is $pt.format( $tree ), $source, Q{formatted};
)
	}, Q{&&};
}, Q{Tight AND Precedence};

subtest {
	plan 5;

	subtest {
		plan 3;

#`(
		my $source = Q:to[_END_];
1 || 2
_END_
		my $parsed = $pt.parse-source( $source );
		my $tree = $pt.build-tree( $parsed );
		ok $pt.validate( $parsed ), Q{valid};
		ok (grep { $_ ~~ Perl6::Operator }, $tree.child.[0].child),
			Q{found operator};
		is $pt.format( $tree ), $source, Q{formatted};
)
	}, Q{||};

	subtest {
		plan 3;

#`(
		my $source = Q:to[_END_];
1 ^^ 2
_END_
		my $parsed = $pt.parse-source( $source );
		my $tree = $pt.build-tree( $parsed );
		ok $pt.validate( $parsed ), Q{valid};
		ok (grep { $_ ~~ Perl6::Operator }, $tree.child.[0].child),
			Q{found operator};
		is $pt.format( $tree ), $source, Q{formatted};
)
	}, Q{^^};

	subtest {
		plan 3;

#`(
		my $source = Q:to[_END_];
1 // 2
_END_
		my $parsed = $pt.parse-source( $source );
		my $tree = $pt.build-tree( $parsed );
		ok $pt.validate( $parsed ), Q{valid};
		ok (grep { $_ ~~ Perl6::Operator }, $tree.child.[0].child),
			Q{found operator};
		is $pt.format( $tree ), $source, Q{formatted};
)
	}, Q{//};

	subtest {
		plan 3;

#`(
		my $source = Q:to[_END_];
1 min 2
_END_
		my $parsed = $pt.parse-source( $source );
		my $tree = $pt.build-tree( $parsed );
		ok $pt.validate( $parsed ), Q{valid};
		ok (grep { $_ ~~ Perl6::Operator }, $tree.child.[0].child),
			Q{found operator};
		is $pt.format( $tree ), $source, Q{formatted};
)
	}, Q{min};

	subtest {
		plan 3;

#`(
		my $source = Q:to[_END_];
1 max 2
_END_
		my $parsed = $pt.parse-source( $source );
		my $tree = $pt.build-tree( $parsed );
		ok $pt.validate( $parsed ), Q{valid};
		ok (grep { $_ ~~ Perl6::Operator }, $tree.child.[0].child),
			Q{found operator};
		is $pt.format( $tree ), $source, Q{formatted};
)
	}, Q{max};
}, Q{Tight OR Precedence};

subtest {
	plan 9;

	subtest {
		plan 3;

#`(
		my $source = Q:to[_END_];
1 ?? 2 !! 3
_END_
		my $parsed = $pt.parse-source( $source );
		my $tree = $pt.build-tree( $parsed );
		ok $pt.validate( $parsed ), Q{valid};
		ok (grep { $_ ~~ Perl6::Operator }, $tree.child.[0].child),
			Q{found operator};
		is $pt.format( $tree ), $source, Q{formatted};
)
	}, Q{?? !!};

	subtest {
		plan 3;

#`(
		my $source = Q:to[_END_];
1 ff 2
_END_
		my $parsed = $pt.parse-source( $source );
		my $tree = $pt.build-tree( $parsed );
		ok $pt.validate( $parsed ), Q{valid};
		ok (grep { $_ ~~ Perl6::Operator }, $tree.child.[0].child),
			Q{found operator};
		is $pt.format( $tree ), $source, Q{formatted};
)
	}, Q{ff};

	subtest {
		plan 3;

#`(
		my $source = Q:to[_END_];
1 ^ff 2
_END_
		my $parsed = $pt.parse-source( $source );
		my $tree = $pt.build-tree( $parsed );
		ok $pt.validate( $parsed ), Q{valid};
		ok (grep { $_ ~~ Perl6::Operator }, $tree.child.[0].child),
			Q{found operator};
		is $pt.format( $tree ), $source, Q{formatted};
)
	}, Q{^ff};

	subtest {
		plan 3;

#`(
		my $source = Q:to[_END_];
1 ff^ 2
_END_
		my $parsed = $pt.parse-source( $source );
		my $tree = $pt.build-tree( $parsed );
		ok $pt.validate( $parsed ), Q{valid};
		ok (grep { $_ ~~ Perl6::Operator }, $tree.child.[0].child),
			Q{found operator};
		is $pt.format( $tree ), $source, Q{formatted};
)
	}, Q{ff^};

	subtest {
		plan 3;

#`(
		my $source = Q:to[_END_];
1 ^ff^ 2
_END_
		my $parsed = $pt.parse-source( $source );
		my $tree = $pt.build-tree( $parsed );
		ok $pt.validate( $parsed ), Q{valid};
		ok (grep { $_ ~~ Perl6::Operator }, $tree.child.[0].child),
			Q{found operator};
		is $pt.format( $tree ), $source, Q{formatted};
)
	}, Q{^ff^};

	subtest {
		plan 3;

#`(
		my $source = Q:to[_END_];
1 fff 2
_END_
		my $parsed = $pt.parse-source( $source );
		my $tree = $pt.build-tree( $parsed );
		ok $pt.validate( $parsed ), Q{valid};
		ok (grep { $_ ~~ Perl6::Operator }, $tree.child.[0].child),
			Q{found operator};
		is $pt.format( $tree ), $source, Q{formatted};
)
	}, Q{fff};

	subtest {
		plan 3;

#`(
		my $source = Q:to[_END_];
1 ^fff 2
_END_
		my $parsed = $pt.parse-source( $source );
		my $tree = $pt.build-tree( $parsed );
		ok $pt.validate( $parsed ), Q{valid};
		ok (grep { $_ ~~ Perl6::Operator }, $tree.child.[0].child),
			Q{found operator};
		is $pt.format( $tree ), $source, Q{formatted};
)
	}, Q{^fff};

	subtest {
		plan 3;

#`(
		my $source = Q:to[_END_];
1 fff^ 2
_END_
		my $parsed = $pt.parse-source( $source );
		my $tree = $pt.build-tree( $parsed );
		ok $pt.validate( $parsed ), Q{valid};
		ok (grep { $_ ~~ Perl6::Operator }, $tree.child.[0].child),
			Q{found operator};
		is $pt.format( $tree ), $source, Q{formatted};
)
	}, Q{fff^};

	subtest {
		plan 3;

#`(
		my $source = Q:to[_END_];
1 ^fff^ 2
_END_
		my $parsed = $pt.parse-source( $source );
		my $tree = $pt.build-tree( $parsed );
		ok $pt.validate( $parsed ), Q{valid};
		ok (grep { $_ ~~ Perl6::Operator }, $tree.child.[0].child),
			Q{found operator};
		is $pt.format( $tree ), $source, Q{formatted};
)
	}, Q{^fff^};
}, Q{Conditional Operator Precedence};

subtest {
	plan 2;

	subtest {
		plan 3;

#`(
		my $source = Q:to[_END_];
my $a = 1
_END_
		my $parsed = $pt.parse-source( $source );
		my $tree = $pt.build-tree( $parsed );
		ok $pt.validate( $parsed ), Q{valid};
		ok (grep { $_ ~~ Perl6::Operator }, $tree.child.[0].child),
			Q{found operator};
		is $pt.format( $tree ), $source, Q{formatted};
)
	}, Q{=};

	subtest {
		plan 3;

#`(
		my $source = Q:to[_END_];
a => 1
_END_
		my $parsed = $pt.parse-source( $source );
		my $tree = $pt.build-tree( $parsed );
		ok $pt.validate( $parsed ), Q{valid};
		ok (grep { $_ ~~ Perl6::Operator }, $tree.child.[0].child),
			Q{found operator};
		is $pt.format( $tree ), $source, Q{formatted};
)
	}, Q{=>};
}, Q{Item Assignment Precedence};

subtest {
	plan 2;

	subtest {
		plan 3;

#`(
		my $source = Q:to[_END_];
not 1
_END_
		my $parsed = $pt.parse-source( $source );
		my $tree = $pt.build-tree( $parsed );
		ok $pt.validate( $parsed ), Q{valid};
		ok (grep { $_ ~~ Perl6::Operator }, $tree.child.[0].child),
			Q{found operator};
		is $pt.format( $tree ), $source, Q{formatted};
)
	}, Q{not};

	subtest {
		plan 3;

#`(
		my $source = Q:to[_END_];
so 1
_END_
		my $parsed = $pt.parse-source( $source );
		my $tree = $pt.build-tree( $parsed );
		ok $pt.validate( $parsed ), Q{valid};
		ok (grep { $_ ~~ Perl6::Operator }, $tree.child.[0].child),
			Q{found operator};
		is $pt.format( $tree ), $source, Q{formatted};
)
	}, Q{so};
}, Q{Loose Unary Precedence};

subtest {
	plan 1;

	subtest {
		plan 3;

#`(
		my $source = Q:to[_END_];
3 , 2
_END_
		my $parsed = $pt.parse-source( $source );
		my $tree = $pt.build-tree( $parsed );
		ok $pt.validate( $parsed ), Q{valid};
		ok (grep { $_ ~~ Perl6::Operator }, $tree.child.[0].child),
			Q{found operator};
		is $pt.format( $tree ), $source, Q{formatted};
)
	}, Q{,};
}, Q{Comma Operator Precedence};

# XXX 'X' and 'Z' have a lot of variants, test separately?
#
subtest {
	plan 2;

	subtest {
		plan 3;

#`(
		my $source = Q:to[_END_];
3 Z 2
_END_
		my $parsed = $pt.parse-source( $source );
		my $tree = $pt.build-tree( $parsed );
		ok $pt.validate( $parsed ), Q{valid};
		ok (grep { $_ ~~ Perl6::Operator }, $tree.child.[0].child),
			Q{found operator};
		is $pt.format( $tree ), $source, Q{formatted};
)
	}, Q{Z};

	subtest {
		plan 3;

#`(
		my $source = Q:to[_END_];
3 X 2
_END_
		my $parsed = $pt.parse-source( $source );
		my $tree = $pt.build-tree( $parsed );
		ok $pt.validate( $parsed ), Q{valid};
		ok (grep { $_ ~~ Perl6::Operator }, $tree.child.[0].child),
			Q{found operator};
		is $pt.format( $tree ), $source, Q{formatted};
)
	}, Q{X};

	subtest {
		plan 3;

#`(
		my $source = Q:to[_END_];
1 ... 2
_END_
		my $parsed = $pt.parse-source( $source );
		my $tree = $pt.build-tree( $parsed );
		ok $pt.validate( $parsed ), Q{valid};
		ok (grep { $_ ~~ Perl6::Operator }, $tree.child.[0].child),
			Q{found operator};
		is $pt.format( $tree ), $source, Q{formatted};
)
	}, Q{...};
}, Q{List Infix Precedence};

subtest {
	plan 5;

	subtest {
		plan 3;

#`(
		my $source = Q:to[_END_];
my $a = 1
_END_
		my $parsed = $pt.parse-source( $source );
		my $tree = $pt.build-tree( $parsed );
		ok $pt.validate( $parsed ), Q{valid};
		ok (grep { $_ ~~ Perl6::Operator }, $tree.child.[0].child),
			Q{found operator};
		is $pt.format( $tree ), $source, Q{formatted};
)
	}, Q{=};

	subtest {
		plan 3;

#`(
		my $source = Q:to[_END_];
my $a := 1
_END_
		my $parsed = $pt.parse-source( $source );
		my $tree = $pt.build-tree( $parsed );
		ok $pt.validate( $parsed ), Q{valid};
		ok (grep { $_ ~~ Perl6::Operator }, $tree.child.[0].child),
			Q{found operator};
		is $pt.format( $tree ), $source, Q{formatted};
)
	}, Q{:=};

	# XXX "::= NIY";

	subtest {
		plan 3;

#`(
		my $source = Q:to[_END_];
...
_END_
		my $parsed = $pt.parse-source( $source );
		my $tree = $pt.build-tree( $parsed );
		ok $pt.validate( $parsed ), Q{valid};
		ok (grep { $_ ~~ Perl6::Operator }, $tree.child.[0].child),
			Q{found operator};
		is $pt.format( $tree ), $source, Q{formatted};
)
	}, Q{...};

	subtest {
		plan 3;

#`(
		my $source = Q:to[_END_];
!!!
_END_
		my $parsed = $pt.parse-source( $source );
		my $tree = $pt.build-tree( $parsed );
		ok $pt.validate( $parsed ), Q{valid};
		ok (grep { $_ ~~ Perl6::Operator }, $tree.child.[0].child),
			Q{found operator};
		is $pt.format( $tree ), $source, Q{formatted};
)
	}, Q{!!!};

	subtest {
		plan 3;

#`(
		my $source = Q:to[_END_];
???
_END_
		my $parsed = $pt.parse-source( $source );
		my $tree = $pt.build-tree( $parsed );
		ok $pt.validate( $parsed ), Q{valid};
		ok (grep { $_ ~~ Perl6::Operator }, $tree.child.[0].child),
			Q{found operator};
		is $pt.format( $tree ), $source, Q{formatted};
)
	}, Q{???};

	# XXX Undecided on [+] implementation
}, Q{List Prefix Precedence};

subtest {
	plan 2;

	subtest {
		plan 3;

#`(
		my $source = Q:to[_END_];
3 and 2
_END_
		my $parsed = $pt.parse-source( $source );
		my $tree = $pt.build-tree( $parsed );
		ok $pt.validate( $parsed ), Q{valid};
		ok (grep { $_ ~~ Perl6::Operator }, $tree.child.[0].child),
			Q{found operator};
		is $pt.format( $tree ), $source, Q{formatted};
)
	}, Q{and};

	subtest {
		plan 3;

#`(
		my $source = Q:to[_END_];
3 andthen 2
_END_
		my $parsed = $pt.parse-source( $source );
		my $tree = $pt.build-tree( $parsed );
		ok $pt.validate( $parsed ), Q{valid};
		ok (grep { $_ ~~ Perl6::Operator }, $tree.child.[0].child),
			Q{found operator};
		is $pt.format( $tree ), $source, Q{formatted};
)
	}, Q{andthen};
}, Q{Loose AND Precedence};

subtest {
	plan 2;

	subtest {
		plan 3;

#`(
		my $source = Q:to[_END_];
3 or 2
_END_
		my $parsed = $pt.parse-source( $source );
		my $tree = $pt.build-tree( $parsed );
		ok $pt.validate( $parsed ), Q{valid};
		ok (grep { $_ ~~ Perl6::Operator }, $tree.child.[0].child),
			Q{found operator};
		is $pt.format( $tree ), $source, Q{formatted};
)
	}, Q{or};

	subtest {
		plan 3;

#`(
		my $source = Q:to[_END_];
3 orelse 2
_END_
		my $parsed = $pt.parse-source( $source );
		my $tree = $pt.build-tree( $parsed );
		ok $pt.validate( $parsed ), Q{valid};
		ok (grep { $_ ~~ Perl6::Operator }, $tree.child.[0].child),
			Q{found operator};
		is $pt.format( $tree ), $source, Q{formatted};
)
	}, Q{orelse};
}, Q{Loose OR Precedence};

subtest {
	plan 2;

	subtest {
		plan 3;

#`(
		my $source = Q:to[_END_];
my @a; @a <== 'a'
_END_
		my $parsed = $pt.parse-source( $source );
		my $tree = $pt.build-tree( $parsed );
		ok $pt.validate( $parsed ), Q{valid};
		ok (grep { $_ ~~ Perl6::Operator }, $tree.child.[0].child),
			Q{found operator};
		is $pt.format( $tree ), $source, Q{formatted};
)
	}, Q{<==};

	subtest {
		plan 3;

#`(
		my $source = Q:to[_END_];
my @a; 'a' ==> @a
_END_
		my $parsed = $pt.parse-source( $source );
		my $tree = $pt.build-tree( $parsed );
		ok $pt.validate( $parsed ), Q{valid};
		ok (grep { $_ ~~ Perl6::Operator }, $tree.child.[0].child),
			Q{found operator};
		is $pt.format( $tree ), $source, Q{formatted};
)
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
