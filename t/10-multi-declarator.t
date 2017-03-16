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
my $*GRAMMAR-CHECK = True;
my $*FALL-THROUGH = True;

subtest {
	plan 2;

	subtest {
		plan 4;

		subtest {
			my $source = Q:to[_END_];
multi Foo{}
_END_
			my $tree = $pt.to-tree( $source );
			is $pt.to-string( $tree ), $source, Q{formatted};

			done-testing;
		}, Q{no ws};

		subtest {
			my $source = Q:to[_END_];
multi Foo     {}
_END_
			my $tree = $pt.to-tree( $source );
			is $pt.to-string( $tree ), $source, Q{formatted};

			done-testing;
		}, Q{leading ws};

		subtest {
			my $source = Q{multi Foo{}  };
			my $tree = $pt.to-tree( $source );
			is $pt.to-string( $tree ), $source, Q{formatted};

			done-testing;
		}, Q{trailing ws};

		subtest {
			my $source = Q{multi Foo     {}  };
			my $tree = $pt.to-tree( $source );
			is $pt.to-string( $tree ), $source, Q{formatted};

			done-testing;
		}, Q{leading, trailing ws};
	}, Q{no intrabrace spacing};

	subtest {
		plan 4;

		subtest {
			my $source = Q:to[_END_];
multi Foo{   }
_END_
			my $tree = $pt.to-tree( $source );
			is $pt.to-string( $tree ), $source, Q{formatted};

			done-testing;
		}, Q{no ws};

		subtest {
			my $source = Q:to[_END_];
multi Foo     {   }
_END_
			my $tree = $pt.to-tree( $source );
			is $pt.to-string( $tree ), $source, Q{formatted};

			done-testing;
		}, Q{leading ws};

		subtest {
			my $source = Q{multi Foo{   }  };
			my $tree = $pt.to-tree( $source );
			is $pt.to-string( $tree ), $source, Q{formatted};

			done-testing;
		}, Q{trailing ws};

		subtest {
			my $source = Q{multi Foo     {   }  };
			my $tree = $pt.to-tree( $source );
			is $pt.to-string( $tree ), $source, Q{formatted};

			done-testing;
		}, Q{leading, trailing ws};
	}, Q{intrabrace spacing};
}, Q{multi};

subtest {
	plan 2;

	subtest {
		plan 4;

		subtest {
			my $source = Q:to[_END_];
proto Foo{}
_END_
			my $tree = $pt.to-tree( $source );
			is $pt.to-string( $tree ), $source, Q{formatted};

			done-testing;
		}, Q{no ws};

		subtest {
			my $source = Q:to[_END_];
proto Foo     {}
_END_
			my $tree = $pt.to-tree( $source );
			is $pt.to-string( $tree ), $source, Q{formatted};

			done-testing;
		}, Q{leading ws};

		subtest {
			my $source = Q{proto Foo{}  };
			my $tree = $pt.to-tree( $source );
			is $pt.to-string( $tree ), $source, Q{formatted};

			done-testing;
		}, Q{trailing ws};

		subtest {
			my $source = Q{proto Foo     {}  };
			my $tree = $pt.to-tree( $source );
			is $pt.to-string( $tree ), $source, Q{formatted};

			done-testing;
		}, Q{leading, trailing ws};
	}, Q{no intrabrace spacing};

	subtest {
		plan 4;

		subtest {
			my $source = Q:to[_END_];
proto Foo{   }
_END_
			my $tree = $pt.to-tree( $source );
			is $pt.to-string( $tree ), $source, Q{formatted};

			done-testing;
		}, Q{no ws};

		subtest {
			my $source = Q:to[_END_];
proto Foo     {   }
_END_
			my $tree = $pt.to-tree( $source );
			is $pt.to-string( $tree ), $source, Q{formatted};

			done-testing;
		}, Q{leading ws};

		subtest {
			my $source = Q{proto Foo{   }  };
			my $tree = $pt.to-tree( $source );
			is $pt.to-string( $tree ), $source, Q{formatted};

			done-testing;
		}, Q{trailing ws};

		subtest {
			my $source = Q{proto Foo     {   }  };
			my $tree = $pt.to-tree( $source );
			is $pt.to-string( $tree ), $source, Q{formatted};

			done-testing;
		}, Q{leading, trailing ws};
	}, Q{intrabrace spacing};
}, Q{proto};

subtest {
	plan 2;

	subtest {
		plan 4;

		subtest {
			my $source = Q:to[_END_];
only Foo{}
_END_
			my $tree = $pt.to-tree( $source );
			is $pt.to-string( $tree ), $source, Q{formatted};

			done-testing;
		}, Q{no ws};

		subtest {
			my $source = Q:to[_END_];
only Foo     {}
_END_
			my $tree = $pt.to-tree( $source );
			is $pt.to-string( $tree ), $source, Q{formatted};

			done-testing;
		}, Q{leading ws};

		subtest {
			my $source = Q{only Foo{}  };
			my $tree = $pt.to-tree( $source );
			is $pt.to-string( $tree ), $source, Q{formatted};

			done-testing;
		}, Q{trailing ws};

		subtest {
			my $source = Q{only Foo     {}  };
			my $tree = $pt.to-tree( $source );
			is $pt.to-string( $tree ), $source, Q{formatted};

			done-testing;
		}, Q{leading, trailing ws};
	}, Q{no intrabrace spacing};

	subtest {
		plan 4;

		subtest {
			my $source = Q:to[_END_];
only Foo{   }
_END_
			my $tree = $pt.to-tree( $source );
			is $pt.to-string( $tree ), $source, Q{formatted};

			done-testing;
		}, Q{no ws};

		subtest {
			my $source = Q:to[_END_];
only Foo     {   }
_END_
			my $tree = $pt.to-tree( $source );
			is $pt.to-string( $tree ), $source, Q{formatted};

			done-testing;
		}, Q{leading ws};

		subtest {
			my $source = Q{only Foo{   }  };
			my $tree = $pt.to-tree( $source );
			is $pt.to-string( $tree ), $source, Q{formatted};

			done-testing;
		}, Q{trailing ws};

		subtest {
			my $source = Q{only Foo     {   }  };
			my $tree = $pt.to-tree( $source );
			is $pt.to-string( $tree ), $source, Q{formatted};

			done-testing;
		}, Q{leading, trailing ws};
	}, Q{intrabrace spacing};
}, Q{only};

# 'null' does not exist

# vim: ft=perl6
