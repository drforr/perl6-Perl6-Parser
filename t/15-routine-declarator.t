use v6;

use Test;
use Perl6::Parser;

# The terms that get tested here are:
#
# sub <name> ... { }
# method <name> ... { }
# submethod <name> ... { }
#
# class Foo { method Bar { } } # 'method' is a routine_declaration.
# class Foo { submethod Bar { } } # 'submethod' is a routine_declaration.

# These terms either are invalid or need additional support structures.
#
# macro <name> ... { } # NYI

plan 3;

my $pt = Perl6::Parser.new;
my $*CONSISTENCY-CHECK = True;
my $*FALL-THROUGH = True;
my ( $source, $tree );

subtest {
	plan 3;

	subtest {
		plan 4;

		subtest {
			$source = Q:to[_END_];
			sub Foo{}
			_END_
			$tree = $pt.to-tree( $source );
			is $pt.to-string( $tree ), $source, Q{formatted};
			ok $tree.child[0].child[3].child[0] ~~
				Perl6::Block::Enter, Q{enter brace};
			ok $tree.child[0].child[3].child[1] ~~
				Perl6::Block::Exit, Q{exit brace};

			done-testing;
		}, Q{no ws};

		$source = Q:to[_END_];
		sub Foo     {}
		_END_
		$tree = $pt.to-tree( $source );
		is $pt.to-string( $tree ), $source, Q{leading ws};

		$source = Q{sub Foo{}  };
		$tree = $pt.to-tree( $source );
		is $pt.to-string( $tree ), $source, Q{trailing ws};

		$source = Q{sub Foo     {}  };
		$tree = $pt.to-tree( $source );
		is $pt.to-string( $tree ), $source, Q{leading, trailing ws};
	}, Q{no intrabrace spacing};

	subtest {
		plan 4;

		$source = Q:to[_END_];
		sub Foo{   }
		_END_
		$tree = $pt.to-tree( $source );
		is $pt.to-string( $tree ), $source, Q{no ws};

		$source = Q:to[_END_];
		sub Foo     {   }
		_END_
		$tree = $pt.to-tree( $source );
		is $pt.to-string( $tree ), $source, Q{leading ws};

		$source = Q{sub Foo{   }  };
		$tree = $pt.to-tree( $source );
		is $pt.to-string( $tree ), $source, Q{trailing ws};

		$source = Q{sub Foo     {   }  };
		$tree = $pt.to-tree( $source );
		is $pt.to-string( $tree ), $source, Q{leading, trailing ws};
	}, Q{intrabrace spacing};

	subtest {
		plan 2;

		$source = Q{unit sub MAIN;};
		$tree = $pt.to-tree( $source );
		is $pt.to-string( $tree ), $source, Q{no ws};

		$source = Q:to[_END_];
		unit sub MAIN  ;
		_END_
		$tree = $pt.to-tree( $source );
		is $pt.to-string( $tree ), $source, Q{ws before semi};
	}, Q{unit form};
}, Q{sub};

subtest {
	plan 2;

	subtest {
		plan 4;

		subtest {
			$source = Q:to[_END_];
			class Foo{method Bar{}}
			_END_
			$tree = $pt.to-tree( $source );
			is $pt.to-string( $tree ), $source, Q{formatted};
			ok $tree.child[0].child[3].child[0] ~~
				Perl6::Block::Enter, Q{enter brace};
			ok $tree.child[0].child[3].child[2] ~~
				Perl6::Block::Exit, Q{exit brace};
			ok $tree.child[0].child[3].child[1].child[3].child[0] ~~
				Perl6::Block::Enter, Q{enter brace};
			ok $tree.child[0].child[3].child[1].child[3].child[1] ~~
				Perl6::Block::Exit, Q{exit brace};

			done-testing;
		}, Q{no ws};

		$source = Q:to[_END_];
		class Foo{method Bar     {}}
		_END_
		$tree = $pt.to-tree( $source );
		is $pt.to-string( $tree ), $source, Q{leading ws};

		$source = Q{class Foo{method Foo{}  }};
		$tree = $pt.to-tree( $source );
		is $pt.to-string( $tree ), $source, Q{trailing ws};

		$source = Q{class Foo{method Bar     {}  }};
		$tree = $pt.to-tree( $source );
		is $pt.to-string( $tree ), $source, Q{leading, trailing ws};
	}, Q{no intrabrace spacing};

	subtest {
		plan 4;

		$source = Q:to[_END_];
		class Foo{method Bar   {}}
		_END_
		$tree = $pt.to-tree( $source );
		is $pt.to-string( $tree ), $source, Q{no ws};

		$source = Q:to[_END_];
		class Foo{method Bar     {   }}
		_END_
		$tree = $pt.to-tree( $source );
		is $pt.to-string( $tree ), $source, Q{leading ws};

		$source = Q{class Foo{method Foo{   }  }};
		$tree = $pt.to-tree( $source );
		is $pt.to-string( $tree ), $source, Q{trailing ws};

		$source = Q{class Foo{method Bar     {   }  }};
		$tree = $pt.to-tree( $source );
		is $pt.to-string( $tree ), $source, Q{leading, trailing ws};
	}, Q{with intrabrace spacing};
}, Q{method};

subtest {
	plan 2;

	subtest {
		plan 4;

		$source = Q:to[_END_];
		class Foo{submethod Bar{}}
		_END_
		$tree = $pt.to-tree( $source );
		is $pt.to-string( $tree ), $source, Q{no ws};

		$source = Q:to[_END_];
		class Foo{submethod Bar     {}}
		_END_
		$tree = $pt.to-tree( $source );
		is $pt.to-string( $tree ), $source, Q{leading ws};

		$source = Q{class Foo{submethod Foo{}  }};
		$tree = $pt.to-tree( $source );
		is $pt.to-string( $tree ), $source, Q{trailing ws};

		$source = Q{class Foo{submethod Bar     {}  }};
		$tree = $pt.to-tree( $source );
		is $pt.to-string( $tree ), $source, Q{leading, trailing ws};
	}, Q{no intrabrace spacing};

	subtest {
		plan 4;

		$source = Q:to[_END_];
		class Foo{submethod Bar   {}}
		_END_
		$tree = $pt.to-tree( $source );
		is $pt.to-string( $tree ), $source, Q{no ws};

		$source = Q:to[_END_];
		class Foo{submethod Bar     {   }}
		_END_
		$tree = $pt.to-tree( $source );
		is $pt.to-string( $tree ), $source, Q{leading ws};

		$source = Q{class Foo{submethod Foo{   }  }};
		$tree = $pt.to-tree( $source );
		is $pt.to-string( $tree ), $source, Q{trailing ws};

		$source = Q{class Foo{submethod Bar     {   }  }};
		$tree = $pt.to-tree( $source );
		is $pt.to-string( $tree ), $source, Q{leading, trailing ws};
	}, Q{with intrabrace spacing};
}, Q{submethod};

# XXX 'macro Foo{}' is still experimental.

# vim: ft=perl6
