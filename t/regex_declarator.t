use v6;

use Test;
use Perl6::Tidy;

#`(

The terms that get tested here are:

my rule Foo { } # 'rule' is a regex_declaration
my token Foo { } # 'token' is a regex_declaration
my regex Foo { } # 'regex' is a regex_declaration

)

plan 3;

my $pt = Perl6::Tidy.new;
#my $*TRACE = 1;
#my $*DEBUG = 1;

subtest {
	plan 2;

	subtest {
		plan 4;

		subtest {
			plan 2;

			my $source = Q{my token Foo{a}};
			my $p = $pt.parse-source( $source );
			my $tree = $pt.build-tree( $p );
			ok $pt.validate( $p ), Q{valid};
			is $pt.format( $tree ), $source, Q{formatted};
		}, Q{no ws};

		subtest {
			plan 2;

			my $source = Q:to[_END_];
my token Foo     {a}
_END_
			my $p = $pt.parse-source( $source );
			my $tree = $pt.build-tree( $p );
			ok $pt.validate( $p ), Q{valid};
			is $pt.format( $tree ), $source, Q{formatted};
		}, Q{leading ws};

		subtest {
			plan 2;

			my $source = Q{my token Foo{a}  };
			my $p = $pt.parse-source( $source );
			my $tree = $pt.build-tree( $p );
			ok $pt.validate( $p ), Q{valid};
			is $pt.format( $tree ), $source, Q{formatted};
		}, Q{trailing ws};

		subtest {
			plan 2;

			my $source = Q{my token Foo     {a}  };
			my $p = $pt.parse-source( $source );
			my $tree = $pt.build-tree( $p );
			ok $pt.validate( $p ), Q{valid};
			is $pt.format( $tree ), $source, Q{formatted};
		}, Q{leading, trailing ws};
	}, Q{no intrabrace spacing};

	subtest {
		plan 4;

		subtest {
			plan 2;

			my $source = Q:to[_END_];
my token Foo{ a  }
_END_
			my $p = $pt.parse-source( $source );
			my $tree = $pt.build-tree( $p );
			ok $pt.validate( $p ), Q{valid};
			is $pt.format( $tree ), $source, Q{formatted};
		}, Q{no ws};

		subtest {
			plan 2;

			my $source = Q:to[_END_];
my token Foo     { a  }
_END_
			my $p = $pt.parse-source( $source );
			my $tree = $pt.build-tree( $p );
			ok $pt.validate( $p ), Q{valid};
			is $pt.format( $tree ), $source, Q{formatted};
		}, Q{leading ws};

		subtest {
			plan 2;

			my $source = Q{my token Foo{ a  }  };
			my $p = $pt.parse-source( $source );
			my $tree = $pt.build-tree( $p );
			ok $pt.validate( $p ), Q{valid};
			is $pt.format( $tree ), $source, Q{formatted};
		}, Q{trailing ws};

		subtest {
			plan 2;

			my $source = Q{my token Foo     { a  }  };
			my $p = $pt.parse-source( $source );
			my $tree = $pt.build-tree( $p );
			ok $pt.validate( $p ), Q{valid};
			is $pt.format( $tree ), $source, Q{formatted};
		}, Q{leading, trailing ws};
	}, Q{intrabrace spacing};
}, Q{token};

subtest {
	plan 2;

	subtest {
		plan 4;

		subtest {
			plan 2;

			my $source = Q{my rule Foo{a}};
			my $p = $pt.parse-source( $source );
			my $tree = $pt.build-tree( $p );
			ok $pt.validate( $p ), Q{valid};
			is $pt.format( $tree ), $source, Q{formatted};
		}, Q{no ws};

		subtest {
			plan 2;

			my $source = Q:to[_END_];
my rule Foo     {a}
_END_
			my $p = $pt.parse-source( $source );
			my $tree = $pt.build-tree( $p );
			ok $pt.validate( $p ), Q{valid};
			is $pt.format( $tree ), $source, Q{formatted};
		}, Q{leading ws};

		subtest {
			plan 2;

			my $source = Q{my rule Foo{a}  };
			my $p = $pt.parse-source( $source );
			my $tree = $pt.build-tree( $p );
			ok $pt.validate( $p ), Q{valid};
			is $pt.format( $tree ), $source, Q{formatted};
		}, Q{trailing ws};

		subtest {
			plan 2;

			my $source = Q{my rule Foo     {a}  };
			my $p = $pt.parse-source( $source );
			my $tree = $pt.build-tree( $p );
			ok $pt.validate( $p ), Q{valid};
			is $pt.format( $tree ), $source, Q{formatted};
		}, Q{leading, trailing ws};
	}, Q{no intrabrace spacing};

	subtest {
		plan 4;

		subtest {
			plan 2;

			my $source = Q{my rule Foo{ a  }};
			my $p = $pt.parse-source( $source );
			my $tree = $pt.build-tree( $p );
			ok $pt.validate( $p ), Q{valid};
			is $pt.format( $tree ), $source, Q{formatted};
		}, Q{no ws};

		subtest {
			plan 2;

			my $source = Q{my rule Foo     { a  }};
			my $p = $pt.parse-source( $source );
			my $tree = $pt.build-tree( $p );
			ok $pt.validate( $p ), Q{valid};
			is $pt.format( $tree ), $source, Q{formatted};
		}, Q{leading ws};

		subtest {
			plan 2;

			my $source = Q{my rule Foo{ a  }  };
			my $p = $pt.parse-source( $source );
			my $tree = $pt.build-tree( $p );
			ok $pt.validate( $p ), Q{valid};
			is $pt.format( $tree ), $source, Q{formatted};
		}, Q{trailing ws};

		subtest {
			plan 2;

			my $source = Q{my rule Foo     { a  }  };
			my $p = $pt.parse-source( $source );
			my $tree = $pt.build-tree( $p );
			ok $pt.validate( $p ), Q{valid};
			is $pt.format( $tree ), $source, Q{formatted};
		}, Q{leading, trailing ws};
	}, Q{intrabrace spacing};
}, Q{rule};

subtest {
	plan 2;

	subtest {
		plan 4;

		subtest {
			plan 2;

			my $source = Q{my regex Foo{a}};
			my $p = $pt.parse-source( $source );
			my $tree = $pt.build-tree( $p );
			ok $pt.validate( $p ), Q{valid};
			is $pt.format( $tree ), $source, Q{formatted};
		}, Q{no ws};

		subtest {
			plan 2;

			my $source = Q{my regex Foo     {a}};
			my $p = $pt.parse-source( $source );
			my $tree = $pt.build-tree( $p );
			ok $pt.validate( $p ), Q{valid};
			is $pt.format( $tree ), $source, Q{formatted};
		}, Q{leading ws};

		subtest {
			plan 2;

			my $source = Q{my regex Foo{a}  };
			my $p = $pt.parse-source( $source );
			my $tree = $pt.build-tree( $p );
			ok $pt.validate( $p ), Q{valid};
			is $pt.format( $tree ), $source, Q{formatted};
		}, Q{trailing ws};

		subtest {
			plan 2;

			my $source = Q{my regex Foo     {a}  };
			my $p = $pt.parse-source( $source );
			my $tree = $pt.build-tree( $p );
			ok $pt.validate( $p ), Q{valid};
			is $pt.format( $tree ), $source, Q{formatted};
		}, Q{leading, trailing ws};
	}, Q{no intrabrace spacing};

	subtest {
		plan 4;

		subtest {
			plan 2;

			my $source = Q{my regex Foo{ a  }};
			my $p = $pt.parse-source( $source );
			my $tree = $pt.build-tree( $p );
			ok $pt.validate( $p ), Q{valid};
			is $pt.format( $tree ), $source, Q{formatted};
		}, Q{no ws};

		subtest {
			plan 2;

			my $source = Q{my regex Foo     { a  }};
			my $p = $pt.parse-source( $source );
			my $tree = $pt.build-tree( $p );
			ok $pt.validate( $p ), Q{valid};
			is $pt.format( $tree ), $source, Q{formatted};
		}, Q{leading ws};

		subtest {
			plan 2;

			my $source = Q{my regex Foo{ a  }  };
			my $p = $pt.parse-source( $source );
			my $tree = $pt.build-tree( $p );
			ok $pt.validate( $p ), Q{valid};
			is $pt.format( $tree ), $source, Q{formatted};
		}, Q{trailing ws};

		subtest {
			plan 2;

			my $source = Q{my regex Foo     { a  }  };
			my $p = $pt.parse-source( $source );
			my $tree = $pt.build-tree( $p );
			ok $pt.validate( $p ), Q{valid};
			is $pt.format( $tree ), $source, Q{formatted};
		}, Q{leading, trailing ws};
	}, Q{intrabrace spacing};
}, Q{regex};

# vim: ft=perl6
