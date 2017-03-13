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
my $*GRAMMAR-CHECK = True;
my $*FALL-THROUGH = True;

subtest {
	plan 2;

	subtest {
		plan 4;

		subtest {
			my $source = Q{my token Foo{a}};
			my $p = $pt.parse( $source );
			my $tree = $pt.build-tree( $p );
			is $pt.to-string( $tree ), $source, Q{formatted};

			done-testing;
		}, Q{no ws};

		subtest {
			my $source = Q:to[_END_];
my token Foo     {a}
_END_
			my $p = $pt.parse( $source );
			my $tree = $pt.build-tree( $p );
			is $pt.to-string( $tree ), $source, Q{formatted};

			done-testing;
		}, Q{leading ws};

		subtest {
			my $source = Q{my token Foo{a}  };
			my $p = $pt.parse( $source );
			my $tree = $pt.build-tree( $p );
			is $pt.to-string( $tree ), $source, Q{formatted};

			done-testing;
		}, Q{trailing ws};

		subtest {
			my $source = Q{my token Foo     {a}  };
			my $p = $pt.parse( $source );
			my $tree = $pt.build-tree( $p );
			is $pt.to-string( $tree ), $source, Q{formatted};

			done-testing;
		}, Q{leading, trailing ws};
	}, Q{no intrabrace spacing};

	subtest {
		plan 4;

		subtest {
			my $source = Q:to[_END_];
my token Foo{ a  }
_END_
			my $p = $pt.parse( $source );
			my $tree = $pt.build-tree( $p );
			is $pt.to-string( $tree ), $source, Q{formatted};

			done-testing;
		}, Q{no ws};

		subtest {
			my $source = Q:to[_END_];
my token Foo     { a  }
_END_
			my $p = $pt.parse( $source );
			my $tree = $pt.build-tree( $p );
			is $pt.to-string( $tree ), $source, Q{formatted};

			done-testing;
		}, Q{leading ws};

		subtest {
			my $source = Q{my token Foo{ a  }  };
			my $p = $pt.parse( $source );
			my $tree = $pt.build-tree( $p );
			is $pt.to-string( $tree ), $source, Q{formatted};

			done-testing;
		}, Q{trailing ws};

		subtest {
			my $source = Q{my token Foo     { a  }  };
			my $p = $pt.parse( $source );
			my $tree = $pt.build-tree( $p );
			is $pt.to-string( $tree ), $source, Q{formatted};

			done-testing;
		}, Q{leading, trailing ws};
	}, Q{intrabrace spacing};
}, Q{token};

subtest {
	plan 2;

	subtest {
		plan 4;

		subtest {
			my $source = Q{my rule Foo{a}};
			my $p = $pt.parse( $source );
			my $tree = $pt.build-tree( $p );
			is $pt.to-string( $tree ), $source, Q{formatted};

			done-testing;
		}, Q{no ws};

		subtest {
			my $source = Q:to[_END_];
my rule Foo     {a}
_END_
			my $p = $pt.parse( $source );
			my $tree = $pt.build-tree( $p );
			is $pt.to-string( $tree ), $source, Q{formatted};

			done-testing;
		}, Q{leading ws};

		subtest {
			my $source = Q{my rule Foo{a}  };
			my $p = $pt.parse( $source );
			my $tree = $pt.build-tree( $p );
			is $pt.to-string( $tree ), $source, Q{formatted};

			done-testing;
		}, Q{trailing ws};

		subtest {
			my $source = Q{my rule Foo     {a}  };
			my $p = $pt.parse( $source );
			my $tree = $pt.build-tree( $p );
			is $pt.to-string( $tree ), $source, Q{formatted};

			done-testing;
		}, Q{leading, trailing ws};
	}, Q{no intrabrace spacing};

	subtest {
		plan 4;

		subtest {
			my $source = Q{my rule Foo{ a  }};
			my $p = $pt.parse( $source );
			my $tree = $pt.build-tree( $p );
			is $pt.to-string( $tree ), $source, Q{formatted};

			done-testing;
		}, Q{no ws};

		subtest {
			my $source = Q{my rule Foo     { a  }};
			my $p = $pt.parse( $source );
			my $tree = $pt.build-tree( $p );
			is $pt.to-string( $tree ), $source, Q{formatted};

			done-testing;
		}, Q{leading ws};

		subtest {
			my $source = Q{my rule Foo{ a  }  };
			my $p = $pt.parse( $source );
			my $tree = $pt.build-tree( $p );
			is $pt.to-string( $tree ), $source, Q{formatted};

			done-testing;
		}, Q{trailing ws};

		subtest {
			my $source = Q{my rule Foo     { a  }  };
			my $p = $pt.parse( $source );
			my $tree = $pt.build-tree( $p );
			is $pt.to-string( $tree ), $source, Q{formatted};

			done-testing;
		}, Q{leading, trailing ws};
	}, Q{intrabrace spacing};
}, Q{rule};

subtest {
	plan 2;

	subtest {
		plan 4;

		subtest {
			my $source = Q{my regex Foo{a}};
			my $p = $pt.parse( $source );
			my $tree = $pt.build-tree( $p );
			is $pt.to-string( $tree ), $source, Q{formatted};

			done-testing;
		}, Q{no ws};

		subtest {
			my $source = Q{my regex Foo     {a}};
			my $p = $pt.parse( $source );
			my $tree = $pt.build-tree( $p );
			is $pt.to-string( $tree ), $source, Q{formatted};

			done-testing;
		}, Q{leading ws};

		subtest {
			my $source = Q{my regex Foo{a}  };
			my $p = $pt.parse( $source );
			my $tree = $pt.build-tree( $p );
			is $pt.to-string( $tree ), $source, Q{formatted};

			done-testing;
		}, Q{trailing ws};

		subtest {
			my $source = Q{my regex Foo     {a}  };
			my $p = $pt.parse( $source );
			my $tree = $pt.build-tree( $p );
			is $pt.to-string( $tree ), $source, Q{formatted};

			done-testing;
		}, Q{leading, trailing ws};
	}, Q{no intrabrace spacing};

	subtest {
		plan 4;

		subtest {
			my $source = Q{my regex Foo{ a  }};
			my $p = $pt.parse( $source );
			my $tree = $pt.build-tree( $p );
			is $pt.to-string( $tree ), $source, Q{formatted};

			done-testing;
		}, Q{no ws};

		subtest {
			my $source = Q{my regex Foo     { a  }};
			my $p = $pt.parse( $source );
			my $tree = $pt.build-tree( $p );
			is $pt.to-string( $tree ), $source, Q{formatted};

			done-testing;
		}, Q{leading ws};

		subtest {
			my $source = Q{my regex Foo{ a  }   };
			my $p = $pt.parse( $source );
			my $tree = $pt.build-tree( $p );
			is $pt.to-string( $tree ), $source, Q{formatted};

			done-testing;
		}, Q{trailing ws};

		subtest {
			my $source = Q{my regex Foo     { a  }   };
			my $p = $pt.parse( $source );
			my $tree = $pt.build-tree( $p );
			is $pt.to-string( $tree ), $source, Q{formatted};

			done-testing;
		}, Q{leading, trailing ws};
	}, Q{intrabrace spacing};
}, Q{regex};

# vim: ft=perl6
