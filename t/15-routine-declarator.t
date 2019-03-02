use v6;

use Test;
use Perl6::Parser;

use lib 't/lib';
use Utils; # Get gensym-package

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

plan 2 * 3 + 1;

my $pt = Perl6::Parser.new;
my $*CONSISTENCY-CHECK = True;
my $*FALL-THROUGH = True;
my ( $source, $tree );

# MAIN is the only subroutine that allows the 'unit sub FOO' form,
# and naturally it can't be redeclared, as there's only one MAIN.
#
# So here it remains, outside the testing block.
#
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

for ( True, False ) -> $*PURE-PERL {
	subtest {
		plan 2;

		subtest {
			plan 4;

			subtest {
				$source = gensym-package Q:to[_END_];
				sub %s{}
				_END_
				$tree = $pt.to-tree( $source );
				is $pt.to-string( $tree ), $source, Q{formatted};
				ok $tree.child[0].child[3].child[0] ~~
					Perl6::Block::Enter, Q{enter brace};
				ok $tree.child[0].child[3].child[1] ~~
					Perl6::Block::Exit, Q{exit brace};

				done-testing;
			}, Q{no ws};

			$source = gensym-package Q:to[_END_];
			sub %s     {}
			_END_
			$tree = $pt.to-tree( $source );
			is $pt.to-string( $tree ), $source, Q{leading ws};

			$source = gensym-package Q{sub %s{}  };
			$tree = $pt.to-tree( $source );
			is $pt.to-string( $tree ), $source, Q{trailing ws};

			$source = gensym-package Q{sub %s     {}  };
			$tree = $pt.to-tree( $source );
			is $pt.to-string( $tree ), $source, Q{leading, trailing ws};
		}, Q{no intrabrace spacing};

		subtest {
			plan 4;

			$source = gensym-package Q:to[_END_];
			sub %s{   }
			_END_
			$tree = $pt.to-tree( $source );
			is $pt.to-string( $tree ), $source, Q{no ws};

			$source = gensym-package Q:to[_END_];
			sub %s     {   }
			_END_
			$tree = $pt.to-tree( $source );
			is $pt.to-string( $tree ), $source, Q{leading ws};

			$source = gensym-package Q{sub %s{   }  };
			$tree = $pt.to-tree( $source );
			is $pt.to-string( $tree ), $source, Q{trailing ws};

			$source = gensym-package Q{sub %s     {   }  };
			$tree = $pt.to-tree( $source );
			is $pt.to-string( $tree ), $source, Q{leading, trailing ws};
		}, Q{intrabrace spacing};
	}, Q{sub};

	subtest {
		plan 2;

		subtest {
			plan 4;

			subtest {
				$source = gensym-package Q:to[_END_];
				class %s{method Bar{}}
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

			$source = gensym-package Q:to[_END_];
			class %s{method Bar     {}}
			_END_
			$tree = $pt.to-tree( $source );
			is $pt.to-string( $tree ), $source, Q{leading ws};

			$source = gensym-package Q{class %s{method Foo{}  }};
			$tree = $pt.to-tree( $source );
			is $pt.to-string( $tree ), $source, Q{trailing ws};

			$source = gensym-package Q{class %s{method Bar     {}  }};
			$tree = $pt.to-tree( $source );
			is $pt.to-string( $tree ), $source, Q{leading, trailing ws};
		}, Q{no intrabrace spacing};

		subtest {
			plan 4;

			$source = gensym-package Q:to[_END_];
			class %s{method Bar   {}}
			_END_
			$tree = $pt.to-tree( $source );
			is $pt.to-string( $tree ), $source, Q{no ws};

			$source = gensym-package Q:to[_END_];
			class %s{method Bar     {   }}
			_END_
			$tree = $pt.to-tree( $source );
			is $pt.to-string( $tree ), $source, Q{leading ws};

			$source = gensym-package Q{class %s{method Foo{   }  }};
			$tree = $pt.to-tree( $source );
			is $pt.to-string( $tree ), $source, Q{trailing ws};

			$source = gensym-package Q{class %s{method Bar     {   }  }};
			$tree = $pt.to-tree( $source );
			is $pt.to-string( $tree ), $source, Q{leading, trailing ws};
		}, Q{with intrabrace spacing};
	}, Q{method};
#
	subtest {
		plan 2;

		subtest {
			plan 4;

			$source = gensym-package Q:to[_END_];
			class %s{submethod Bar{}}
			_END_
			$tree = $pt.to-tree( $source );
			is $pt.to-string( $tree ), $source, Q{no ws};

			$source = gensym-package Q:to[_END_];
			class %s{submethod Bar     {}}
			_END_
			$tree = $pt.to-tree( $source );
			is $pt.to-string( $tree ), $source, Q{leading ws};

			$source = gensym-package Q{class %s{submethod Foo{}  }};
			$tree = $pt.to-tree( $source );
			is $pt.to-string( $tree ), $source, Q{trailing ws};

			$source = gensym-package Q{class %s{submethod Bar     {}  }};
			$tree = $pt.to-tree( $source );
			is $pt.to-string( $tree ), $source, Q{leading, trailing ws};
		}, Q{no intrabrace spacing};

		subtest {
			plan 4;

			$source = gensym-package Q:to[_END_];
			class %s{submethod Bar   {}}
			_END_
			$tree = $pt.to-tree( $source );
			is $pt.to-string( $tree ), $source, Q{no ws};

			$source = gensym-package Q:to[_END_];
			class %s{submethod Bar     {   }}
			_END_
			$tree = $pt.to-tree( $source );
			is $pt.to-string( $tree ), $source, Q{leading ws};

			$source = gensym-package Q{class %s{submethod Foo{   }  }};
			$tree = $pt.to-tree( $source );
			is $pt.to-string( $tree ), $source, Q{trailing ws};

			$source = gensym-package Q{class %s{submethod Bar     {   }  }};
			$tree = $pt.to-tree( $source );
			is $pt.to-string( $tree ), $source, Q{leading, trailing ws};
		}, Q{with intrabrace spacing};
	}, Q{submethod};
}

# XXX 'macro Foo{}' is still experimental.

# vim: ft=perl6
