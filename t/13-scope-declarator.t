use v6;

use Test;
use Perl6::Parser;

# The terms that get tested here are:
#
# my <name>
# our <naem>
# has <name>
# HAS <name>
# augment <name>
# anon <name>
# state <name>
# supersede <name>
#
# class Foo { has <name> } # 'has' is a scope declaration.
# class Foo { HAS <name> } # 'HAS' requires a separate class to work

# These terms are invalid:
#
# lang <name>

plan 4;

my $pt = Perl6::Parser.new;
my $*CONSISTENCY-CHECK = True;
my $*GRAMMAR-CHECK = True;

subtest {
	subtest {
		my $source = Q:to[_END_];
my$x
_END_
		my $p = $pt.parse( $source );
		my $tree = $pt.build-tree( $p );
		is $pt.to-string( $tree ), $source, Q{formatted};

		done-testing;
	}, Q{no ws};

	subtest {
		my $source = Q:to[_END_];
my     $x
_END_
		my $p = $pt.parse( $source );
		my $tree = $pt.build-tree( $p );
		is $pt.to-string( $tree ), $source, Q{formatted};

		done-testing;
	}, Q{leading ws};

	done-testing;
}, Q{my};

subtest {
	subtest {
		my $source = Q:to[_END_];
our$x
_END_
		my $p = $pt.parse( $source );
		my $tree = $pt.build-tree( $p );
		is $pt.to-string( $tree ), $source, Q{formatted};

		done-testing;
	}, Q{no ws};

	subtest {
		my $source = Q:to[_END_];
our     $x
_END_
		my $p = $pt.parse( $source );
		my $tree = $pt.build-tree( $p );
		is $pt.to-string( $tree ), $source, Q{formatted};

		done-testing;
	}, Q{leading ws};

	done-testing;
}, Q{our};

subtest {
	subtest {
		my $source = Q:to[_END_];
class Foo{has$x}
_END_
		my $p = $pt.parse( $source );
		my $tree = $pt.build-tree( $p );
		is $pt.to-string( $tree ), $source, Q{formatted};

		done-testing;
	}, Q{no ws};

	subtest {
		my $source = Q:to[_END_];
class Foo{has     $x}
_END_
		my $p = $pt.parse( $source );
		my $tree = $pt.build-tree( $p );
		is $pt.to-string( $tree ), $source, Q{formatted};

		done-testing;
	}, Q{leading ws};

	done-testing;
}, Q{has};

# HAS requires another class definition.
#
#subtest {
#	plan 2;
#
#	subtest {
#		my $source = Q{class Foo is repr('CStruct'){HAS int $x}};
#		my $p = $pt.parse( $source );
#		my $tree = $pt.build-tree( $p );
#		is $pt.to-string( $tree ), $source, Q{formatted};
#
#		done-testing;
#	}, Q{no ws};
#
#	subtest {
#		my $source = Q:to[_END_];
#class Foo is repr( 'CStruct' ) { HAS int $x }
#_END_
#		my $p = $pt.parse( $source );
#		my $tree = $pt.build-tree( $p );
#		is $pt.to-string( $tree ), $source, Q{formatted};
#
#		done-testing;
#	}, Q{leading ws};
#}, Q{HAS};

# XXX 'augment $x' is NIY

# XXX 'anon $x' is NIY

subtest {
	plan 2;

	subtest {
		my $source = Q{state$x};
		my $p = $pt.parse( $source );
		my $tree = $pt.build-tree( $p );
		is $pt.to-string( $tree ), $source, Q{formatted};

		done-testing;
	}, Q{no ws};

	subtest {
		my $source = Q:to[_END_];
state     $x
_END_
		my $p = $pt.parse( $source );
		my $tree = $pt.build-tree( $p );
		is $pt.to-string( $tree ), $source, Q{formatted};

		done-testing;
	}, Q{leading ws};
}, Q{state};

# XXX 'supersede $x' NIY

# vim: ft=perl6
