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
my $*FALL-THROUGH = True;
my ( $source, $tree );

subtest {
	$source = Q:to[_END_];
	my$x
	_END_
	$tree = $pt.to-tree( $source );
	is $pt.to-string( $tree ), $source, Q{no ws};

	$source = Q:to[_END_];
	my     $x
	_END_
	$tree = $pt.to-tree( $source );
	is $pt.to-string( $tree ), $source, Q{leading ws};

	done-testing;
}, Q{my};

subtest {
	$source = Q:to[_END_];
	our$x
	_END_
	$tree = $pt.to-tree( $source );
	is $pt.to-string( $tree ), $source, Q{no ws};

	$source = Q:to[_END_];
	our     $x
	_END_
	$tree = $pt.to-tree( $source );
	is $pt.to-string( $tree ), $source, Q{leading ws};

	done-testing;
}, Q{our};

subtest {
	subtest {
		$source = Q:to[_END_];
		class Foo{has$x}
		_END_
		$tree = $pt.to-tree( $source );
		is $pt.to-string( $tree ), $source, Q{formatted};
		ok $tree.child[0].child[3].child[0] ~~
			Perl6::Block::Enter, Q{enter brace};
		ok $tree.child[0].child[3].child[2] ~~
			Perl6::Block::Exit, Q{exit brace};

		done-testing;
	}, Q{no ws};

	$source = Q:to[_END_];
	class Foo{has     $x}
	_END_
	$tree = $pt.to-tree( $source );
	is $pt.to-string( $tree ), $source, Q{leading ws};

	done-testing;
}, Q{has};

# HAS requires another class definition.
#
#subtest {
#	plan 2;
#
#	subtest {
#		$source = Q{class Foo is repr('CStruct'){HAS int $x}};
#		$tree = $pt.to-tree( $source );
#		is $pt.to-string( $tree ), $source, Q{formatted};
#
#		done-testing;
#	}, Q{no ws};
#
#	subtest {
#		$source = Q:to[_END_];
#class Foo is repr( 'CStruct' ) { HAS int $x }
#_END_
#		$tree = $pt.to-tree( $source );
#		is $pt.to-string( $tree ), $source, Q{formatted};
#
#		done-testing;
#	}, Q{leading ws};
#}, Q{HAS};

# XXX 'augment $x' is NIY

# XXX 'anon $x' is NIY

subtest {
	plan 2;

	$source = Q{state$x};
	$tree = $pt.to-tree( $source );
	is $pt.to-string( $tree ), $source, Q{no ws};

	$source = Q:to[_END_];
	state     $x
	_END_
	$tree = $pt.to-tree( $source );
	is $pt.to-string( $tree ), $source, Q{leading ws};
}, Q{state};

# XXX 'supersede $x' NIY

# vim: ft=perl6
