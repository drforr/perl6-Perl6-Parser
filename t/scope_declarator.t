use v6;

use Test;
use Perl6::Tidy;

#`(

The terms that get tested here are:

my <name>
our <naem>
has <name>
HAS <name>
augment <name>
anon <name>
state <name>
supersede <name>

class Foo { has <name> } # 'has' is a scope declaration.

)

#`(

These terms either are invalid or need additional support structures.
I'll add them momentarily...

lang <name>

)

plan 5;

my $pt = Perl6::Tidy.new;
#my $*TRACE = 1;
#my $*DEBUG = 1;

subtest {
	plan 2;

	subtest {
		plan 2;

		my $source = Q:to[_END_];
my$x
_END_
		my $p = $pt.parse-source( $source );
		my $tree = $pt.build-tree( $p );
		ok $pt.validate( $p ), Q{valid};
		is $pt.format( $tree ), $source, Q{formatted};
	}, Q{no ws};

	subtest {
		plan 2;

		my $source = Q:to[_END_];
my     $x
_END_
		my $p = $pt.parse-source( $source );
		my $tree = $pt.build-tree( $p );
		ok $pt.validate( $p ), Q{valid};
		is $pt.format( $tree ), $source, Q{formatted};
	}, Q{leading ws};
}, Q{my};

subtest {
	plan 2;

	subtest {
		plan 2;

		my $source = Q:to[_END_];
our$x
_END_
		my $p = $pt.parse-source( $source );
		my $tree = $pt.build-tree( $p );
		ok $pt.validate( $p ), Q{valid};
		is $pt.format( $tree ), $source, Q{formatted};
	}, Q{no ws};

	subtest {
		plan 2;

		my $source = Q:to[_END_];
our     $x
_END_
		my $p = $pt.parse-source( $source );
		my $tree = $pt.build-tree( $p );
		ok $pt.validate( $p ), Q{valid};
		is $pt.format( $tree ), $source, Q{formatted};
	}, Q{leading ws};
}, Q{our};

subtest {
	plan 2;

	subtest {
		plan 2;

		my $source = Q:to[_END_];
class Foo{has$x}
_END_
		my $p = $pt.parse-source( $source );
		my $tree = $pt.build-tree( $p );
		ok $pt.validate( $p ), Q{valid};
		is $pt.format( $tree ), $source, Q{formatted};
	}, Q{no ws};

	subtest {
		plan 2;

		my $source = Q:to[_END_];
class Foo{has     $x}
_END_
		my $p = $pt.parse-source( $source );
		my $tree = $pt.build-tree( $p );
		ok $pt.validate( $p ), Q{valid};
		is $pt.format( $tree ), $source, Q{formatted};
	}, Q{leading ws};
}, Q{has};

subtest {
	plan 2;

	subtest {
		plan 0;

#`(
		my $source = Q:to[_END_];
class Foo{HAS$x}
_END_
		my $p = $pt.parse-source( $source );
		my $tree = $pt.build-tree( $p );
		ok $pt.validate( $p ), Q{valid};
		is $pt.format( $tree ), $source, Q{formatted};
)
	}, Q{no ws};

	subtest {
		plan 0;

#`(
		my $source = Q:to[_END_];
class Foo{HAS     $x}
_END_
		my $p = $pt.parse-source( $source );
		my $tree = $pt.build-tree( $p );
		ok $pt.validate( $p ), Q{valid};
		is $pt.format( $tree ), $source, Q{formatted};
)
	}, Q{leading ws};
}, Q{HAS};

#`( Not implemented yet
subtest {
	plan 2;

	subtest {
		plan 2;

		my $source = Q:to[_END_];
augment$x
_END_
		my $p = $pt.parse-source( $source );
		my $tree = $pt.build-tree( $p );
		ok $pt.validate( $p ), Q{valid};
		is $pt.format( $tree ), $source, Q{formatted};
	}, Q{no ws};

	subtest {
		plan 2;

		my $source = Q:to[_END_];
augment     $x
_END_
		my $p = $pt.parse-source( $source );
		my $tree = $pt.build-tree( $p );
		ok $pt.validate( $p ), Q{valid};
		is $pt.format( $tree ), $source, Q{formatted};
	}, Q{leading ws};
}, Q{augment};
)

#`( Not implemented yet
subtest {
	plan 2;

	subtest {
		plan 2;

		my $source = Q:to[_END_];
anon$x
_END_
		my $p = $pt.parse-source( $source );
		my $tree = $pt.build-tree( $p );
		ok $pt.validate( $p ), Q{valid};
		is $pt.format( $tree ), $source, Q{formatted};
	}, Q{no ws};

	subtest {
		plan 2;

		my $source = Q:to[_END_];
anon     $x
_END_
		my $p = $pt.parse-source( $source );
		my $tree = $pt.build-tree( $p );
		ok $pt.validate( $p ), Q{valid};
		is $pt.format( $tree ), $source, Q{formatted};
	}, Q{leading ws};
}, Q{anon};
)

subtest {
	plan 2;

	subtest {
		plan 2;

		my $source = Q{state$x};
		my $p = $pt.parse-source( $source );
		my $tree = $pt.build-tree( $p );
		ok $pt.validate( $p ), Q{valid};
		is $pt.format( $tree ), $source, Q{formatted};
	}, Q{no ws};

	subtest {
		plan 2;

		my $source = Q:to[_END_];
state     $x
_END_
		my $p = $pt.parse-source( $source );
		my $tree = $pt.build-tree( $p );
		ok $pt.validate( $p ), Q{valid};
		is $pt.format( $tree ), $source, Q{formatted};
	}, Q{leading ws};
}, Q{state};

#`( Not implemented yet
subtest {
	plan 2;

	subtest {
		plan 2;

		my $source = Q:to[_END_];
supersede$x
_END_
		my $p = $pt.parse-source( $source );
		my $tree = $pt.build-tree( $p );
		ok $pt.validate( $p ), Q{valid};
		is $pt.format( $tree ), $source, Q{formatted};
	}, Q{no ws};

	subtest {
		plan 2;

		my $source = Q:to[_END_];
supersede     $x
_END_
		my $p = $pt.parse-source( $source );
		my $tree = $pt.build-tree( $p );
		ok $pt.validate( $p ), Q{valid};
		is $pt.format( $tree ), $source, Q{formatted};
	}, Q{leading ws};
}, Q{supersede};
)

# vim: ft=perl6
