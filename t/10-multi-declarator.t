use v6;

use Test;
use Perl6::Parser;

# The terms that get tested here are:
#
# multi 
# proto 
# only
# null

plan 3;

my $pt = Perl6::Parser.new;
my $*CONSISTENCY-CHECK = True;
my $*FALL-THROUGH = True;
my ( $source, $tree );

subtest {
	plan 2;

	subtest {
		plan 4;

		subtest {
			$source = Q:to[_END_];
			multi Foo{}
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
		multi Foo     {}
		_END_
		$tree = $pt.to-tree( $source );
		is $pt.to-string( $tree ), $source, Q{leading ws};

		$source = Q{multi Foo{}  };
		$tree = $pt.to-tree( $source );
		is $pt.to-string( $tree ), $source, Q{trailing ws};

		$source = Q{multi Foo     {}  };
		$tree = $pt.to-tree( $source );
		is $pt.to-string( $tree ), $source, Q{leading, trailing ws};
	}, Q{no intrabrace spacing};

	subtest {
		plan 4;

		$source = Q:to[_END_];
		multi Foo{   }
		_END_
		$tree = $pt.to-tree( $source );
		is $pt.to-string( $tree ), $source, Q{no ws};

		$source = Q:to[_END_];
		multi Foo     {   }
		_END_
		$tree = $pt.to-tree( $source );
		is $pt.to-string( $tree ), $source, Q{leading ws};

		$source = Q{multi Foo{   }  };
		$tree = $pt.to-tree( $source );
		is $pt.to-string( $tree ), $source, Q{trailing ws};

		$source = Q{multi Foo     {   }  };
		$tree = $pt.to-tree( $source );
		is $pt.to-string( $tree ), $source, Q{leading, trailing ws};
	}, Q{intrabrace spacing};
}, Q{multi};

subtest {
	plan 2;

	subtest {
		plan 4;

		$source = Q:to[_END_];
		proto Foo{}
		_END_
		$tree = $pt.to-tree( $source );
		is $pt.to-string( $tree ), $source, Q{no ws};

		$source = Q:to[_END_];
		proto Foo     {}
		_END_
		$tree = $pt.to-tree( $source );
		is $pt.to-string( $tree ), $source, Q{leading ws};

		$source = Q{proto Foo{}  };
		$tree = $pt.to-tree( $source );
		is $pt.to-string( $tree ), $source, Q{trailing ws};

		$source = Q{proto Foo     {}  };
		$tree = $pt.to-tree( $source );
		is $pt.to-string( $tree ), $source, Q{leading, trailing ws};
	}, Q{no intrabrace spacing};

	subtest {
		plan 4;

		$source = Q:to[_END_];
		proto Foo{   }
		_END_
		$tree = $pt.to-tree( $source );
		is $pt.to-string( $tree ), $source, Q{no ws};

		$source = Q:to[_END_];
		proto Foo     {   }
		_END_
		$tree = $pt.to-tree( $source );
		is $pt.to-string( $tree ), $source, Q{leading ws};

		$source = Q{proto Foo{   }  };
		$tree = $pt.to-tree( $source );
		is $pt.to-string( $tree ), $source, Q{trailing ws};

		$source = Q{proto Foo     {   }  };
		$tree = $pt.to-tree( $source );
		is $pt.to-string( $tree ), $source, Q{leading, trailing ws};
	}, Q{intrabrace spacing};
}, Q{proto};

subtest {
	plan 2;

	subtest {
		plan 4;

		$source = Q:to[_END_];
		only Foo{}
		_END_
		$tree = $pt.to-tree( $source );
		is $pt.to-string( $tree ), $source, Q{no ws};

		$source = Q:to[_END_];
		only Foo     {}
		_END_
		$tree = $pt.to-tree( $source );
		is $pt.to-string( $tree ), $source, Q{leading ws};

		$source = Q{only Foo{}  };
		$tree = $pt.to-tree( $source );
		is $pt.to-string( $tree ), $source, Q{trailing ws};

		$source = Q{only Foo     {}  };
		$tree = $pt.to-tree( $source );
		is $pt.to-string( $tree ), $source, Q{leading, trailing ws};
	}, Q{no intrabrace spacing};

	subtest {
		plan 4;

		$source = Q:to[_END_];
		only Foo{   }
		_END_
		$tree = $pt.to-tree( $source );
		is $pt.to-string( $tree ), $source, Q{no ws};

		$source = Q:to[_END_];
		only Foo     {   }
		_END_
		$tree = $pt.to-tree( $source );
		is $pt.to-string( $tree ), $source, Q{leading ws};

		$source = Q{only Foo{   }  };
		$tree = $pt.to-tree( $source );
		is $pt.to-string( $tree ), $source, Q{trailing ws};

		$source = Q{only Foo     {   }  };
		$tree = $pt.to-tree( $source );
		is $pt.to-string( $tree ), $source, Q{leading, trailing ws};
	}, Q{intrabrace spacing};
}, Q{only};

# 'null' does not exist

# vim: ft=perl6
