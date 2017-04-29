use v6;

use Test;
use Perl6::Parser;

# The terms that get tested here are:
#
# my rule Foo { } # 'rule' is a regex_declaration
# my token Foo { } # 'token' is a regex_declaration
# my regex Foo { } # 'regex' is a regex_declaration

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
			$source = Q{my token Foo{a}};
			$tree = $pt.to-tree( $source );
			is $pt.to-string( $tree ), $source, Q{formatted};
			ok $tree.child[0].child[5].child[0] ~~
				Perl6::Block::Enter, Q{enter brace};
			ok $tree.child[0].child[5].child[2] ~~
				Perl6::Block::Exit, Q{exit brace};

			done-testing;
		}, Q{no ws};

		$source = Q:to[_END_];
		my token Foo     {a}
		_END_
		$tree = $pt.to-tree( $source );
		is $pt.to-string( $tree ), $source, Q{leading ws};

		$source = Q{my token Foo{a}  };
		$tree = $pt.to-tree( $source );
		is $pt.to-string( $tree ), $source, Q{trailing ws};

		$source = Q{my token Foo     {a}  };
		$tree = $pt.to-tree( $source );
		is $pt.to-string( $tree ), $source, Q{leading, trailing ws};
	}, Q{no intrabrace spacing};

	subtest {
		plan 4;

		$source = Q:to[_END_];
		my token Foo{ a  }
		_END_
		$tree = $pt.to-tree( $source );
		is $pt.to-string( $tree ), $source, Q{no ws};

		$source = Q:to[_END_];
		my token Foo     { a  }
		_END_
		$tree = $pt.to-tree( $source );
		is $pt.to-string( $tree ), $source, Q{leading ws};

		$source = Q{my token Foo{ a  }  };
		$tree = $pt.to-tree( $source );
		is $pt.to-string( $tree ), $source, Q{trailing ws};

		$source = Q{my token Foo     { a  }  };
		$tree = $pt.to-tree( $source );
		is $pt.to-string( $tree ), $source, Q{leading, trailing ws};
	}, Q{intrabrace spacing};
}, Q{token};

subtest {
	plan 2;

	subtest {
		plan 4;

		$source = Q{my rule Foo{a}};
		$tree = $pt.to-tree( $source );
		is $pt.to-string( $tree ), $source, Q{no ws};

		$source = Q:to[_END_];
		my rule Foo     {a}
		_END_
		$tree = $pt.to-tree( $source );
		is $pt.to-string( $tree ), $source, Q{leading ws};

		$source = Q{my rule Foo{a}  };
		$tree = $pt.to-tree( $source );
		is $pt.to-string( $tree ), $source, Q{trailing ws};

		$source = Q{my rule Foo     {a}  };
		$tree = $pt.to-tree( $source );
		is $pt.to-string( $tree ), $source, Q{leading, trailing ws};
	}, Q{no intrabrace spacing};

	subtest {
		plan 4;

		$source = Q{my rule Foo{ a  }};
		$tree = $pt.to-tree( $source );
		is $pt.to-string( $tree ), $source, Q{no ws};

		$source = Q{my rule Foo     { a  }};
		$tree = $pt.to-tree( $source );
		is $pt.to-string( $tree ), $source, Q{leading ws};

		$source = Q{my rule Foo{ a  }  };
		$tree = $pt.to-tree( $source );
		is $pt.to-string( $tree ), $source, Q{trailing ws};

		$source = Q{my rule Foo     { a  }  };
		$tree = $pt.to-tree( $source );
		is $pt.to-string( $tree ), $source, Q{leading, trailing ws};
	}, Q{intrabrace spacing};
}, Q{rule};

subtest {
	plan 2;

	subtest {
		plan 4;

		$source = Q{my regex Foo{a}};
		$tree = $pt.to-tree( $source );
		is $pt.to-string( $tree ), $source, Q{no ws};

		$source = Q{my regex Foo     {a}};
		$tree = $pt.to-tree( $source );
		is $pt.to-string( $tree ), $source, Q{leading ws};

		$source = Q{my regex Foo{a}  };
		$tree = $pt.to-tree( $source );
		is $pt.to-string( $tree ), $source, Q{trailing ws};

		$source = Q{my regex Foo     {a}  };
		$tree = $pt.to-tree( $source );
		is $pt.to-string( $tree ), $source, Q{leading, trailing ws};
	}, Q{no intrabrace spacing};

	subtest {
		plan 4;

		$source = Q{my regex Foo{ a  }};
		$tree = $pt.to-tree( $source );
		is $pt.to-string( $tree ), $source, Q{no ws};

		$source = Q{my regex Foo     { a  }};
		$tree = $pt.to-tree( $source );
		is $pt.to-string( $tree ), $source, Q{leading ws};

		$source = Q{my regex Foo{ a  }   };
		$tree = $pt.to-tree( $source );
		is $pt.to-string( $tree ), $source, Q{trailing ws};

		$source = Q{my regex Foo     { a  }   };
		$tree = $pt.to-tree( $source );
		is $pt.to-string( $tree ), $source, Q{leading, trailing ws};
	}, Q{intrabrace spacing};
}, Q{regex};

# vim: ft=perl6
