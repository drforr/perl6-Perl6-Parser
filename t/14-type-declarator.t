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
my $*VALIDATION-FAILURE-FATAL = True;
my $*FACTORY-FAILURE-FATAL = True;
my $*DEBUG = True;

subtest {
	plan 2;

	subtest {
		plan 4;

		subtest {
			plan 2;

			my $source = Q:to[_END_];
enum Foo()
_END_
			my $p = $pt.parse( $source );
			my $tree = $pt.build-tree( $p );
			ok $pt.validate( $p ), Q{valid};
			is $pt.to-string( $tree ), $source, Q{formatted};
		}, Q{no ws};

		subtest {
			plan 2;

			my $source = Q:to[_END_];
enum Foo     ()
_END_
			my $p = $pt.parse( $source );
			my $tree = $pt.build-tree( $p );
			ok $pt.validate( $p ), Q{valid};
			is $pt.to-string( $tree ), $source, Q{formatted};
		}, Q{leading ws};

		subtest {
			plan 2;

			my $source = Q{enum Foo()  };
			my $p = $pt.parse( $source );
			my $tree = $pt.build-tree( $p );
			ok $pt.validate( $p ), Q{valid};
			is $pt.to-string( $tree ), $source, Q{formatted};
		}, Q{trailing ws};

		subtest {
			plan 2;

			my $source = Q{enum Foo     ()  };
			my $p = $pt.parse( $source );
			my $tree = $pt.build-tree( $p );
			ok $pt.validate( $p ), Q{valid};
			is $pt.to-string( $tree ), $source, Q{formatted};
		}, Q{leading, trailing ws};
	}, Q{no intrabrace spacing};

	subtest {
		plan 4;

		subtest {
			plan 2;

			my $source = Q:to[_END_];
enum Foo(   )
_END_
			my $p = $pt.parse( $source );
			my $tree = $pt.build-tree( $p );
			ok $pt.validate( $p ), Q{valid};
			is $pt.to-string( $tree ), $source, Q{formatted};
		}, Q{no ws};

		subtest {
			plan 2;

			my $source = Q:to[_END_];
enum Foo     (   )
_END_
			my $p = $pt.parse( $source );
			my $tree = $pt.build-tree( $p );
			ok $pt.validate( $p ), Q{valid};
			is $pt.to-string( $tree ), $source, Q{formatted};
		}, Q{leading ws};

		subtest {
			plan 2;

			my $source = Q{enum Foo(   )  };
			my $p = $pt.parse( $source );
			my $tree = $pt.build-tree( $p );
			ok $pt.validate( $p ), Q{valid};
			is $pt.to-string( $tree ), $source, Q{formatted};
		}, Q{trailing ws};

		subtest {
			plan 2;

			my $source = Q{enum Foo     (   )  };
			my $p = $pt.parse( $source );
			my $tree = $pt.build-tree( $p );
			ok $pt.validate( $p ), Q{valid};
			is $pt.to-string( $tree ), $source, Q{formatted};
		}, Q{leading, trailing ws};
	}, Q{intrabrace spacing};
}, Q{enum};

subtest {
	plan 2;

	subtest {
		plan 2;

		subtest {
			plan 2;

			my $source = Q:to[_END_];
subset Foo of Int
_END_
			my $p = $pt.parse( $source );
			my $tree = $pt.build-tree( $p );
			ok $pt.validate( $p ), Q{valid};
			is $pt.to-string( $tree ), $source, Q{formatted};
		}, Q{no ws};

		subtest {
			plan 2;

			my $source = Q{subset Foo of Int  };
			my $p = $pt.parse( $source );
			my $tree = $pt.build-tree( $p );
			ok $pt.validate( $p ), Q{valid};
			is $pt.to-string( $tree ), $source, Q{formatted};
		}, Q{trailing ws};
	}, Q{Normal version};

	subtest {
		plan 2;

		my $source = Q:to[_END_];
unit subset Foo;
_END_
		my $p = $pt.parse( $source );
		my $tree = $pt.build-tree( $p );
		ok $pt.validate( $p ), Q{valid};
		is $pt.to-string( $tree ), $source, Q{formatted};
	}, Q{unit form};
}, Q{subset};

subtest {
	plan 5;

	subtest {
		plan 2;

		my $source = Q:to[_END_];
constant Foo=1
_END_
		my $p = $pt.parse( $source );
		my $tree = $pt.build-tree( $p );
		ok $pt.validate( $p ), Q{valid};
		is $pt.to-string( $tree ), $source, Q{formatted};
	}, Q{no ws};

	subtest {
		plan 2;

		my $source = Q:to[_END_];
constant Foo     =1
_END_
		my $p = $pt.parse( $source );
		my $tree = $pt.build-tree( $p );
		ok $pt.validate( $p ), Q{valid};
		is $pt.to-string( $tree ), $source, Q{formatted};
	}, Q{leading ws};

	subtest {
		plan 2;

		my $source = Q:to[_END_];
constant Foo=   1
_END_
		my $p = $pt.parse( $source );
		my $tree = $pt.build-tree( $p );
		ok $pt.validate( $p ), Q{valid};
		is $pt.to-string( $tree ), $source, Q{formatted};
	}, Q{intermediate ws};

	subtest {
		plan 2;

		my $source = Q:to[_END_];
constant Foo     =   1
_END_
		my $p = $pt.parse( $source );
		my $tree = $pt.build-tree( $p );
		ok $pt.validate( $p ), Q{valid};
		is $pt.to-string( $tree ), $source, Q{formatted};
	}, Q{intermediate ws};

	subtest {
		plan 2;

		my $source = Q{constant Foo=1     };
		my $p = $pt.parse( $source );
		my $tree = $pt.build-tree( $p );
		ok $pt.validate( $p ), Q{valid};
		is $pt.to-string( $tree ), $source, Q{formatted};
	}, Q{trailing ws};
}, Q{constant};

# vim: ft=perl6
