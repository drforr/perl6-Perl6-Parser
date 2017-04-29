use v6;

use Test;
use Perl6::Parser;

# The terms that get tested here are:
#
# enum <name> "foo"
# subset <name> of Type
# constant <name> = 1

plan 3;

my $pt = Perl6::Parser.new;
my $*CONSISTENCY-CHECK = True;
my $*FALL-THROUGH = True;
my ( $source, $tree );

subtest {
	plan 2;

	subtest {
		plan 4;

		$source = Q:to[_END_];
		enum Foo()
		_END_
		$tree = $pt.to-tree( $source );
		is $pt.to-string( $tree ), $source, Q{no ws};

		$source = Q:to[_END_];
		enum Foo     ()
		_END_
		$tree = $pt.to-tree( $source );
		is $pt.to-string( $tree ), $source, Q{leading ws};

		$source = Q{enum Foo()  };
		$tree = $pt.to-tree( $source );
		is $pt.to-string( $tree ), $source, Q{trailing ws};

		$source = Q{enum Foo     ()  };
		$tree = $pt.to-tree( $source );
		is $pt.to-string( $tree ), $source, Q{leading, trailing ws};
	}, Q{no intrabrace spacing};

	subtest {
		plan 4;

		$source = Q:to[_END_];
		enum Foo(   )
		_END_
		$tree = $pt.to-tree( $source );
		is $pt.to-string( $tree ), $source, Q{no ws};

		$source = Q:to[_END_];
		enum Foo     (   )
		_END_
		$tree = $pt.to-tree( $source );
		is $pt.to-string( $tree ), $source, Q{leading ws};

		$source = Q{enum Foo(   )  };
		$tree = $pt.to-tree( $source );
		is $pt.to-string( $tree ), $source, Q{trailing ws};

		$source = Q{enum Foo     (   )  };
		$tree = $pt.to-tree( $source );
		is $pt.to-string( $tree ), $source, Q{leading, trailing ws};
	}, Q{intrabrace spacing};
}, Q{enum};

subtest {
	plan 2;

	subtest {
		plan 2;

		$source = Q:to[_END_];
		subset Foo of Int
		_END_
		$tree = $pt.to-tree( $source );
		is $pt.to-string( $tree ), $source, Q{no ws};

		$source = Q{subset Foo of Int  };
		$tree = $pt.to-tree( $source );
		is $pt.to-string( $tree ), $source, Q{trailing ws};
	}, Q{Normal version};

	$source = Q:to[_END_];
	unit subset Foo;
	_END_
	$tree = $pt.to-tree( $source );
	is $pt.to-string( $tree ), $source, Q{unit form};
}, Q{subset};

subtest {
	plan 5;

	$source = Q:to[_END_];
	constant Foo=1
	_END_
	$tree = $pt.to-tree( $source );
	is $pt.to-string( $tree ), $source, Q{no ws};

	$source = Q:to[_END_];
	constant Foo     =1
	_END_
	$tree = $pt.to-tree( $source );
	is $pt.to-string( $tree ), $source, Q{leading ws};

	$source = Q:to[_END_];
	constant Foo=   1
	_END_
	$tree = $pt.to-tree( $source );
	is $pt.to-string( $tree ), $source, Q{intermediate ws};

	$source = Q:to[_END_];
	constant Foo     =   1
	_END_
	$tree = $pt.to-tree( $source );
	is $pt.to-string( $tree ), $source, Q{intermediate ws};

	$source = Q{constant Foo=1     };
	$tree = $pt.to-tree( $source );
	is $pt.to-string( $tree ), $source, Q{trailing ws};
}, Q{constant};

# vim: ft=perl6
