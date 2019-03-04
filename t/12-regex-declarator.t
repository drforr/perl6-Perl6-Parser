use v6;

use Test;
use Perl6::Parser;

use lib 't/lib';
use Utils; # Get gensym-package

# The terms that get tested here are:
#
# my rule Foo { } # 'rule' is a regex_declaration
# my token Foo { } # 'token' is a regex_declaration
# my regex Foo { } # 'regex' is a regex_declaration

plan 2 * 4;

my $*CONSISTENCY-CHECK = True;
my $*FALL-THROUGH      = True;

# Token - get rid of an indent level
#
for ( True, False ) -> $*PURE-PERL {
	subtest {
		plan 4;

		subtest {
			my $pp     = Perl6::Parser.new;
			my $source = Q{my token Foo{a}};
			my $tree   = $pp.to-tree( $source );

			is $pp.to-string( $tree ), $source, Q{formatted};
			ok $tree.child[0].child[5].child[0] ~~
				Perl6::Block::Enter, Q{enter brace};
			ok $tree.child[0].child[5].child[2] ~~
				Perl6::Block::Exit, Q{exit brace};

			done-testing;
		}, Q{no ws};

		ok round-trips( Q:to[_END_] ), Q{leading ws};
		my token Foo     {a}
		_END_

		ok round-trips( Q{my token Foo{a}  } ), Q{trailing ws};

		ok round-trips( Q{my token Foo     {a}  } ), 
		   Q{leading, trailing ws};
	}, Q{no intrabrace spacing};

	subtest {
		plan 4;

		ok round-trips( Q:to[_END_] ), Q{no ws};
		my token Foo{ a  }
		_END_

		
		ok round-trips( Q:to[_END_] ), Q{leading ws};
		my token Foo     { a  }
		_END_

		ok round-trips( Q{my token Foo{ a  }  } ), Q{trailing ws};

		ok round-trips( Q{my token Foo     { a  }  } ),
		   Q{leading, trailing ws};
	}, Q{intrabrace spacing};
}

# Rules
#
for ( True, False ) -> $*PURE-PERL {
	subtest {
		plan 2;

		subtest {
			plan 4;

			ok round-trips( Q{my rule Foo{a}} ), Q{no ws};

			ok round-trips( Q:to[_END_] ), Q{leading ws};
			my rule Foo     {a}
			_END_

			ok round-trips( Q{my rule Foo{a}  } ), Q{trailing ws};

			ok round-trips( Q{my rule Foo     {a}  } ),
			   Q{leading, trailing ws};
		}, Q{no intrabrace spacing};

		subtest {
			plan 4;

			ok round-trips( Q{my rule Foo{ a  }} ), Q{no ws};

			ok round-trips( Q{my rule Foo     { a  }} ),
			   Q{leading ws};

			ok round-trips( Q{my rule Foo{ a  }  } ),
			   Q{trailing ws};

			ok round-trips( Q{my rule Foo     { a  }  } ),
			   Q{leading, trailing ws};
		}, Q{intrabrace spacing};
	}, Q{rule};

	subtest {
		plan 2;

		subtest {
			plan 4;

			ok round-trips( Q{my regex Foo{a}} ), Q{no ws};

			ok round-trips( Q{my regex Foo     {a}} ),
			   Q{leading ws};

			ok round-trips( Q{my regex Foo{a}  } ),
			   Q{trailing ws};

			ok round-trips( Q{my regex Foo     {a}  } ),
			   Q{leading, trailing ws};
		}, Q{no intrabrace spacing};

		subtest {
			plan 4;

			ok round-trips( Q{my regex Foo{ a  }} ), Q{no ws};

			ok round-trips( Q{my regex Foo     { a  }} ),
			   Q{leading ws};

			ok round-trips( Q{my regex Foo{ a  }   } ),
			   Q{trailing ws};

			ok round-trips( Q{my regex Foo     { a  }   } ),
			   Q{leading, trailing ws};
		}, Q{intrabrace spacing};
	}, Q{regex};
}

# vim: ft=perl6
