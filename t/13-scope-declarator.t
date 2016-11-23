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
my $*VALIDATION-FAILURE-FATAL = True;
my $*FACTORY-FAILURE-FATAL = True;
my $*DEBUG = True;

subtest {
	plan 2;

	subtest {
		plan 2;

		my $source = Q:to[_END_];
my$x
_END_
		my $p = $pt.parse( $source );
		my $tree = $pt.build-tree( $p );
		ok $pt.validate( $p ), Q{valid};
		is $pt.to-string( $tree ), $source, Q{formatted};
	}, Q{no ws};

	subtest {
		plan 2;

		my $source = Q:to[_END_];
my     $x
_END_
		my $p = $pt.parse( $source );
		my $tree = $pt.build-tree( $p );
		ok $pt.validate( $p ), Q{valid};
		is $pt.to-string( $tree ), $source, Q{formatted};
	}, Q{leading ws};
}, Q{my};

subtest {
	plan 2;

	subtest {
		plan 2;

		my $source = Q:to[_END_];
our$x
_END_
		my $p = $pt.parse( $source );
		my $tree = $pt.build-tree( $p );
		ok $pt.validate( $p ), Q{valid};
		is $pt.to-string( $tree ), $source, Q{formatted};
	}, Q{no ws};

	subtest {
		plan 2;

		my $source = Q:to[_END_];
our     $x
_END_
		my $p = $pt.parse( $source );
		my $tree = $pt.build-tree( $p );
		ok $pt.validate( $p ), Q{valid};
		is $pt.to-string( $tree ), $source, Q{formatted};
	}, Q{leading ws};
}, Q{our};

subtest {
	plan 2;

	subtest {
		plan 2;

		my $source = Q:to[_END_];
class Foo{has$x}
_END_
		my $p = $pt.parse( $source );
		my $tree = $pt.build-tree( $p );
		ok $pt.validate( $p ), Q{valid};
		is $pt.to-string( $tree ), $source, Q{formatted};
	}, Q{no ws};

	subtest {
		plan 2;

		my $source = Q:to[_END_];
class Foo{has     $x}
_END_
		my $p = $pt.parse( $source );
		my $tree = $pt.build-tree( $p );
		ok $pt.validate( $p ), Q{valid};
		is $pt.to-string( $tree ), $source, Q{formatted};
	}, Q{leading ws};
}, Q{has};

# HAS requires another class definition.
#
#subtest {
#	plan 2;
#
#	subtest {
#		plan 2;
#
#		my $source = Q{class Foo is repr('CStruct'){HAS int $x}};
#		my $p = $pt.parse( $source );
#		my $tree = $pt.build-tree( $p );
#		ok $pt.validate( $p ), Q{valid};
#		is $pt.to-string( $tree ), $source, Q{formatted};
#	}, Q{no ws};
#
#	subtest {
#		plan 2;
#
#		my $source = Q:to[_END_];
#class Foo is repr( 'CStruct' ) { HAS int $x }
#_END_
#		my $p = $pt.parse( $source );
#		my $tree = $pt.build-tree( $p );
#		ok $pt.validate( $p ), Q{valid};
#		is $pt.to-string( $tree ), $source, Q{formatted};
#	}, Q{leading ws};
#}, Q{HAS};

# XXX 'augment $x' is NIY

# XXX 'anon $x' is NIY

subtest {
	plan 2;

	subtest {
		plan 2;

		my $source = Q{state$x};
		my $p = $pt.parse( $source );
		my $tree = $pt.build-tree( $p );
		ok $pt.validate( $p ), Q{valid};
		is $pt.to-string( $tree ), $source, Q{formatted};
	}, Q{no ws};

	subtest {
		plan 2;

		my $source = Q:to[_END_];
state     $x
_END_
		my $p = $pt.parse( $source );
		my $tree = $pt.build-tree( $p );
		ok $pt.validate( $p ), Q{valid};
		is $pt.to-string( $tree ), $source, Q{formatted};
	}, Q{leading ws};
}, Q{state};

# XXX 'supersede $x' NIY

# vim: ft=perl6
