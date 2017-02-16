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
my $*GRAMMAR-CHECK = True;

subtest {
	plan 3;

	subtest {
		plan 4;

		subtest {
			my $source = Q:to[_END_];
sub Foo{}
_END_
			my $p = $pt.parse( $source );
			my $tree = $pt.build-tree( $p );
			is $pt.to-string( $tree ), $source, Q{formatted};

			done-testing;
		}, Q{no ws};

		subtest {
			my $source = Q:to[_END_];
sub Foo     {}
_END_
			my $p = $pt.parse( $source );
			my $tree = $pt.build-tree( $p );
			is $pt.to-string( $tree ), $source, Q{formatted};

			done-testing;
		}, Q{leading ws};

		subtest {
			my $source = Q{sub Foo{}  };
			my $p = $pt.parse( $source );
			my $tree = $pt.build-tree( $p );
			is $pt.to-string( $tree ), $source, Q{formatted};

			done-testing;
		}, Q{trailing ws};

		subtest {
			my $source = Q{sub Foo     {}  };
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
sub Foo{   }
_END_
			my $p = $pt.parse( $source );
			my $tree = $pt.build-tree( $p );
			is $pt.to-string( $tree ), $source, Q{formatted};

			done-testing;
		}, Q{no ws};

		subtest {
			my $source = Q:to[_END_];
sub Foo     {   }
_END_
			my $p = $pt.parse( $source );
			my $tree = $pt.build-tree( $p );
			is $pt.to-string( $tree ), $source, Q{formatted};

			done-testing;
		}, Q{leading ws};

		subtest {
			my $source = Q{sub Foo{   }  };
			my $p = $pt.parse( $source );
			my $tree = $pt.build-tree( $p );
			is $pt.to-string( $tree ), $source, Q{formatted};

			done-testing;
		}, Q{trailing ws};

		subtest {
			my $source = Q{sub Foo     {   }  };
			my $p = $pt.parse( $source );
			my $tree = $pt.build-tree( $p );
			is $pt.to-string( $tree ), $source, Q{formatted};

			done-testing;
		}, Q{leading, trailing ws};
	}, Q{intrabrace spacing};

	subtest {
		plan 2;

		subtest {
			my $source = Q{unit sub MAIN;};
			my $p = $pt.parse( $source );
			my $tree = $pt.build-tree( $p );
			is $pt.to-string( $tree ), $source, Q{formatted};

			done-testing;
		}, Q{no ws};

		subtest {
			my $source = Q:to[_END_];
unit sub MAIN  ;
_END_
			my $p = $pt.parse( $source );
			my $tree = $pt.build-tree( $p );
			is $pt.to-string( $tree ), $source, Q{formatted};

			done-testing;
		}, Q{ws before semi};
	}, Q{unit form};
}, Q{sub};

subtest {
	plan 2;

	subtest {
		plan 4;

		subtest {
			my $source = Q:to[_END_];
class Foo{method Bar{}}
_END_
			my $p = $pt.parse( $source );
			my $tree = $pt.build-tree( $p );
			is $pt.to-string( $tree ), $source, Q{formatted};

			done-testing;
		}, Q{no ws};

		subtest {
			my $source = Q:to[_END_];
class Foo{method Bar     {}}
_END_
			my $p = $pt.parse( $source );
			my $tree = $pt.build-tree( $p );
			is $pt.to-string( $tree ), $source, Q{formatted};

			done-testing;
		}, Q{leading ws};

		subtest {
			my $source = Q{class Foo{method Foo{}  }};
			my $p = $pt.parse( $source );
			my $tree = $pt.build-tree( $p );
			is $pt.to-string( $tree ), $source, Q{formatted};

			done-testing;
		}, Q{trailing ws};

		subtest {
			my $source = Q{class Foo{method Bar     {}  }};
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
class Foo{method Bar   {}}
_END_
			my $p = $pt.parse( $source );
			my $tree = $pt.build-tree( $p );
			is $pt.to-string( $tree ), $source, Q{formatted};

			done-testing;
		}, Q{no ws};

		subtest {
			my $source = Q:to[_END_];
class Foo{method Bar     {   }}
_END_
			my $p = $pt.parse( $source );
			my $tree = $pt.build-tree( $p );
			is $pt.to-string( $tree ), $source, Q{formatted};

			done-testing;
		}, Q{leading ws};

		subtest {
			my $source = Q{class Foo{method Foo{   }  }};
			my $p = $pt.parse( $source );
			my $tree = $pt.build-tree( $p );
			is $pt.to-string( $tree ), $source, Q{formatted};

			done-testing;
		}, Q{trailing ws};

		subtest {
			my $source = Q{class Foo{method Bar     {   }  }};
			my $p = $pt.parse( $source );
			my $tree = $pt.build-tree( $p );
			is $pt.to-string( $tree ), $source, Q{formatted};

			done-testing;
		}, Q{leading, trailing ws};
	}, Q{with intrabrace spacing};
}, Q{method};

subtest {
	plan 2;

	subtest {
		plan 4;

		subtest {
			my $source = Q:to[_END_];
class Foo{submethod Bar{}}
_END_
			my $p = $pt.parse( $source );
			my $tree = $pt.build-tree( $p );
			is $pt.to-string( $tree ), $source, Q{formatted};

			done-testing;
		}, Q{no ws};

		subtest {
			my $source = Q:to[_END_];
class Foo{submethod Bar     {}}
_END_
			my $p = $pt.parse( $source );
			my $tree = $pt.build-tree( $p );
			is $pt.to-string( $tree ), $source, Q{formatted};

			done-testing;
		}, Q{leading ws};

		subtest {
			my $source = Q{class Foo{submethod Foo{}  }};
			my $p = $pt.parse( $source );
			my $tree = $pt.build-tree( $p );
			is $pt.to-string( $tree ), $source, Q{formatted};

			done-testing;
		}, Q{trailing ws};

		subtest {
			my $source = Q{class Foo{submethod Bar     {}  }};
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
class Foo{submethod Bar   {}}
_END_
			my $p = $pt.parse( $source );
			my $tree = $pt.build-tree( $p );
			is $pt.to-string( $tree ), $source, Q{formatted};

			done-testing;
		}, Q{no ws};

		subtest {
			my $source = Q:to[_END_];
class Foo{submethod Bar     {   }}
_END_
			my $p = $pt.parse( $source );
			my $tree = $pt.build-tree( $p );
			is $pt.to-string( $tree ), $source, Q{formatted};

			done-testing;
		}, Q{leading ws};

		subtest {
			my $source = Q{class Foo{submethod Foo{   }  }};
			my $p = $pt.parse( $source );
			my $tree = $pt.build-tree( $p );
			is $pt.to-string( $tree ), $source, Q{formatted};

			done-testing;
		}, Q{trailing ws};

		subtest {
			my $source = Q{class Foo{submethod Bar     {   }  }};
			my $p = $pt.parse( $source );
			my $tree = $pt.build-tree( $p );
			is $pt.to-string( $tree ), $source, Q{formatted};

			done-testing;
		}, Q{leading, trailing ws};
	}, Q{with intrabrace spacing};
}, Q{submethod};

# XXX 'macro Foo{}' is still experimental.

# vim: ft=perl6
