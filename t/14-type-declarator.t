use v6;

use Test;
use Perl6::Parser;

use lib 't/lib';
use Utils; # Get gensym-package

# The terms that get tested here are:
#
# enum <name> "foo"
# subset <name> of Type
# constant <name> = 1

plan 2 * 3;

my $*CONSISTENCY-CHECK = True;
my $*FALL-THROUGH      = True;
my ( $source );

for ( True, False ) -> $*PURE-PERL {
	subtest {
		plan 2;

		subtest {
			plan 4;

			$source = gensym-package Q:to[_END_];
			enum %s()
			_END_
			ok round-trips( $source ), Q{no ws};

			$source = gensym-package Q:to[_END_];
			enum %s     ()
			_END_
			ok round-trips( $source ), Q{leading ws};

			$source = gensym-package Q{enum %s()  };
			ok round-trips( $source ), Q{trailing ws};

			$source = gensym-package Q{enum %s     ()  };
			ok round-trips( $source ), Q{leading, trailing ws};
		}, Q{no intrabrace spacing};

		subtest {
			plan 4;

			$source = gensym-package Q:to[_END_];
			enum %s(   )
			_END_
			ok round-trips( $source ), Q{no ws};

			$source = gensym-package Q:to[_END_];
			enum %s     (   )
			_END_
			ok round-trips( $source ), Q{leading ws};

			$source = gensym-package Q{enum %s(   )  };
			ok round-trips( $source ), Q{trailing ws};

			$source = gensym-package Q{enum %s     (   )  };
			ok round-trips( $source ), Q{leading, trailing ws};
		}, Q{intrabrace spacing};
	}, Q{enum};

	subtest {
		plan 2;

		subtest {
			plan 2;

			$source = gensym-package Q:to[_END_];
			subset %s of Int
			_END_
			ok round-trips( $source ), Q{no ws};

			$source = gensym-package Q{subset %s of Int  };
			ok round-trips( $source ), Q{trailing ws};
		}, Q{Normal version};

		$source = gensym-package Q:to[_END_];
		unit subset %s;
		_END_
		ok round-trips( $source ), Q{unit form};
	}, Q{subset};

	subtest {
		plan 5;

		$source = Q:to[_END_];
		constant Foo=1
		_END_
		ok round-trips( $source ), Q{no ws};

		$source = Q:to[_END_];
		constant Foo     =1
		_END_
		ok round-trips( $source ), Q{leading ws};

		$source = Q:to[_END_];
		constant Foo=   1
		_END_
		ok round-trips( $source ), Q{intermediate ws};

		$source = Q:to[_END_];
		constant Foo     =   1
		_END_
		ok round-trips( $source ), Q{intermediate ws};

		$source = Q{constant Foo=1     };
		ok round-trips( $source ), Q{trailing ws};
	}, Q{constant};
}

# vim: ft=perl6
