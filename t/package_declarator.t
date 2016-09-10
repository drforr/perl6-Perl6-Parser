use v6;

use Test;
use Perl6::Tidy;

#`(

In passing, please note that while it's trivially possible to bum down the
tests, doing so makes it harder to insert 'say $p.dump' to view the
AST, and 'say $tree.perl' to view the generated Perl 6 structure.

)

#`(

As much as I dislike explicitly handling whitespace, here's the rationale:

Leading WS, intrabrace WS and trailing WS are all different lengths. This is
by design, so that in case I've matched the wrong whitespace section (they all
look alike) during testing, the different lengths will break the test.

Leading is 5 characters, intra is 3, trailing is 2.
It's a happy coincidence that these are the 3rd-5th terms in the Fibonacci
sequence.

It's not a coincidence, however, that leading, trailing and intrabrace spacing
all get tested in the same file, however.

)

#`(

The terms that get tested here are:

package <name> { }
module <name> { }
class <name> { }
grammar <name> { }
role <name> { }
knowhow <name> { }
native <name> { }
also is <name>
trusts <name>

class Foo { also is Int } # 'also' is a package_declaration.
class Foo { trusts Int } # 'trusts' is a package_declaration.

)

#`(

These terms either are invalid or need additional support structures.
I'll add them momentarily...

lang <name>

)

plan 11;

my $pt = Perl6::Tidy.new;
#my $*TRACE = 1;
#my $*DEBUG = 1;

subtest {
	plan 3;

	subtest {
		plan 4;

		subtest {
			plan 2;

			my $source = Q:to[_END_];
package Foo{}
_END_
			my $p = $pt.parse-source( $source );
			my $tree = $pt.build-tree( $p );
			ok $pt.validate( $p ), Q{valid};
			is $pt.format( $tree ), $source, Q{formatted};
		}, Q{no ws};

		subtest {
			plan 2;

			my $source = Q:to[_END_];
package Foo     {}
_END_
			my $p = $pt.parse-source( $source );
			my $tree = $pt.build-tree( $p );
			ok $pt.validate( $p ), Q{valid};
			is $pt.format( $tree ), $source, Q{formatted};
		}, Q{leading ws};

		subtest {
			plan 2;

			my $source = Q{package Foo{}  };
			my $p = $pt.parse-source( $source );
			my $tree = $pt.build-tree( $p );
			ok $pt.validate( $p ), Q{valid};
			is $pt.format( $tree ), $source, Q{formatted};
		}, Q{trailing ws};

		subtest {
			plan 2;

			my $source = Q{package Foo     {}  };
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
package Foo{   }
_END_
			my $p = $pt.parse-source( $source );
			my $tree = $pt.build-tree( $p );
			ok $pt.validate( $p ), Q{valid};
			is $pt.format( $tree ), $source, Q{formatted};
		}, Q{no ws};

		subtest {
			plan 2;

			my $source = Q:to[_END_];
package Foo     {   }
_END_
			my $p = $pt.parse-source( $source );
			my $tree = $pt.build-tree( $p );
			ok $pt.validate( $p ), Q{valid};
			is $pt.format( $tree ), $source, Q{formatted};
		}, Q{leading ws};

		subtest {
			plan 2;

			my $source = Q{package Foo{   }  };
			my $p = $pt.parse-source( $source );
			my $tree = $pt.build-tree( $p );
			ok $pt.validate( $p ), Q{valid};
			is $pt.format( $tree ), $source, Q{formatted};
		}, Q{trailing ws};

		subtest {
			plan 2;

			my $source = Q{package Foo     {   }  };
			my $p = $pt.parse-source( $source );
			my $tree = $pt.build-tree( $p );
			ok $pt.validate( $p ), Q{valid};
			is $pt.format( $tree ), $source, Q{formatted};
		}, Q{leading, trailing ws};
	}, Q{intrabrace spacing};

	subtest {
		plan 2;

		subtest {
			plan 2;

			my $source = Q:to[_END_];
unit package Foo;
_END_
			my $p = $pt.parse-source( $source );
			my $tree = $pt.build-tree( $p );
			ok $pt.validate( $p ), Q{valid};
			is $pt.format( $tree ), $source, Q{formatted};
		}, Q{no ws};

		subtest {
			plan 2;

			my $source = Q:to[_END_];
unit package Foo  ;
_END_
			my $p = $pt.parse-source( $source );
			my $tree = $pt.build-tree( $p );
			ok $pt.validate( $p ), Q{valid};
			is $pt.format( $tree ), $source, Q{formatted};
		}, Q{ws before semi};
	}, Q{unit form};
}, Q{package};

subtest {
	plan 3;

	subtest {
		plan 4;

		subtest {
			plan 2;

			my $source = Q:to[_END_];
module Foo{}
_END_
			my $p = $pt.parse-source( $source );
			my $tree = $pt.build-tree( $p );
			ok $pt.validate( $p ), Q{valid};
			is $pt.format( $tree ), $source, Q{formatted};
		}, Q{no ws};

		subtest {
			plan 2;

			my $source = Q:to[_END_];
module Foo     {}
_END_
			my $p = $pt.parse-source( $source );
			my $tree = $pt.build-tree( $p );
			ok $pt.validate( $p ), Q{valid};
			is $pt.format( $tree ), $source, Q{formatted};
		}, Q{leading ws};

		subtest {
			plan 2;

			my $source = Q{module Foo{}  };
			my $p = $pt.parse-source( $source );
			my $tree = $pt.build-tree( $p );
			ok $pt.validate( $p ), Q{valid};
			is $pt.format( $tree ), $source, Q{formatted};
		}, Q{trailing ws};

		subtest {
			plan 2;

			my $source = Q{module Foo     {}  };
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
module Foo{   }
_END_
			my $p = $pt.parse-source( $source );
			my $tree = $pt.build-tree( $p );
			ok $pt.validate( $p ), Q{valid};
			is $pt.format( $tree ), $source, Q{formatted};
		}, Q{no ws};

		subtest {
			plan 2;

			my $source = Q:to[_END_];
module Foo     {   }
_END_
			my $p = $pt.parse-source( $source );
			my $tree = $pt.build-tree( $p );
			ok $pt.validate( $p ), Q{valid};
			is $pt.format( $tree ), $source, Q{formatted};
		}, Q{leading ws};

		subtest {
			plan 2;

			my $source = Q{module Foo{   }  };
			my $p = $pt.parse-source( $source );
			my $tree = $pt.build-tree( $p );
			ok $pt.validate( $p ), Q{valid};
			is $pt.format( $tree ), $source, Q{formatted};
		}, Q{trailing ws};

		subtest {
			plan 2;

			my $source = Q{module Foo     {   }  };
			my $p = $pt.parse-source( $source );
			my $tree = $pt.build-tree( $p );
			ok $pt.validate( $p ), Q{valid};
			is $pt.format( $tree ), $source, Q{formatted};
		}, Q{leading, trailing ws};
	}, Q{intrabrace spacing};

	subtest {
		plan 2;

		my $source = Q:to[_END_];
unit module Foo;
_END_
		my $p = $pt.parse-source( $source );
		my $tree = $pt.build-tree( $p );
		ok $pt.validate( $p ), Q{valid};
		is $pt.format( $tree ), $source, Q{formatted};
	}, Q{unit form};
}, Q{module};

subtest {
	plan 3;

	subtest {
		plan 4;

		subtest {
			plan 2;

			my $source = Q:to[_END_];
class Foo{}
_END_
			my $p = $pt.parse-source( $source );
			my $tree = $pt.build-tree( $p );
			ok $pt.validate( $p ), Q{valid};
			is $pt.format( $tree ), $source, Q{formatted};
		}, Q{no ws};

		subtest {
			plan 2;

			my $source = Q:to[_END_];
class Foo     {}
_END_
			my $p = $pt.parse-source( $source );
			my $tree = $pt.build-tree( $p );
			ok $pt.validate( $p ), Q{valid};
			is $pt.format( $tree ), $source, Q{formatted};
		}, Q{leading ws};

		subtest {
			plan 2;

			my $source = Q{class Foo{}  };
			my $p = $pt.parse-source( $source );
			my $tree = $pt.build-tree( $p );
			ok $pt.validate( $p ), Q{valid};
			is $pt.format( $tree ), $source, Q{formatted};
		}, Q{trailing ws};

		subtest {
			plan 2;

			my $source = Q{class Foo     {}  };
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
class Foo{   }
_END_
			my $p = $pt.parse-source( $source );
			my $tree = $pt.build-tree( $p );
			ok $pt.validate( $p ), Q{valid};
			is $pt.format( $tree ), $source, Q{formatted};
		}, Q{no ws};

		subtest {
			plan 2;

			my $source = Q:to[_END_];
class Foo     {   }
_END_
			my $p = $pt.parse-source( $source );
			my $tree = $pt.build-tree( $p );
			ok $pt.validate( $p ), Q{valid};
			is $pt.format( $tree ), $source, Q{formatted};
		}, Q{leading ws};

		subtest {
			plan 2;

			my $source = Q{class Foo{   }  };
			my $p = $pt.parse-source( $source );
			my $tree = $pt.build-tree( $p );
			ok $pt.validate( $p ), Q{valid};
			is $pt.format( $tree ), $source, Q{formatted};
		}, Q{trailing ws};

		subtest {
			plan 2;

			my $source = Q{class Foo     {   }  };
			my $p = $pt.parse-source( $source );
			my $tree = $pt.build-tree( $p );
			ok $pt.validate( $p ), Q{valid};
			is $pt.format( $tree ), $source, Q{formatted};
		}, Q{leading, trailing ws};
	}, Q{intrabrace spacing};

	subtest {
		plan 2;

		my $source = Q:to[_END_];
unit class Foo;
_END_
		my $p = $pt.parse-source( $source );
		my $tree = $pt.build-tree( $p );
		ok $pt.validate( $p ), Q{valid};
		is $pt.format( $tree ), $source, Q{formatted};
	}, Q{unit form};
}, Q{class};

subtest {
	plan 2;

	my $source = Q:to[_END_];
class Foo{also     is   Int}
_END_
	my $p = $pt.parse-source( $source );
	my $tree = $pt.build-tree( $p );
	ok $pt.validate( $p ), Q{valid};
	is $pt.format( $tree ), $source, Q{formatted};
}, Q{class Foo also is};

subtest {
	plan 0;

#`(
	my $source = Q:to[_END_];
class Foo is Test{}
_END_
	my $p = $pt.parse-source( $source );
	my $tree = $pt.build-tree( $p );
	ok $pt.validate( $p ), Q{valid};
	is $pt.format( $tree ), $source, Q{formatted};
)
}, Q{class Foo is};

subtest {
	plan 0;

#`(
	my $source = Q:to[_END_];
class Foo is repr('CStruct'){}
_END_
	my $p = $pt.parse-source( $source );
	my $tree = $pt.build-tree( $p );
	ok $pt.validate( $p ), Q{valid};
	is $pt.format( $tree ), $source, Q{formatted};
)
}, Q{class Foo is repr()};

subtest {
	plan 2;

	my $source = Q:to[_END_];
class Foo{trusts     Int}
_END_
	my $p = $pt.parse-source( $source );
 	my $tree = $pt.build-tree( $p );
	ok $pt.validate( $p ), Q{valid};
	is $pt.format( $tree ), $source, Q{formatted};
}, Q{class Foo trusts Int};

subtest {
	plan 3;

	subtest {
		plan 4;

		subtest {
			plan 2;

			my $source = Q:to[_END_];
grammar Foo{}
_END_
			my $p = $pt.parse-source( $source );
			my $tree = $pt.build-tree( $p );
			ok $pt.validate( $p ), Q{valid};
			is $pt.format( $tree ), $source, Q{formatted};
		}, Q{no ws};

		subtest {
			plan 2;

			my $source = Q:to[_END_];
grammar Foo     {}
_END_
			my $p = $pt.parse-source( $source );
			my $tree = $pt.build-tree( $p );
			ok $pt.validate( $p ), Q{valid};
			is $pt.format( $tree ), $source, Q{formatted};
		}, Q{leading ws};

		subtest {
			plan 2;

			my $source = Q{grammar Foo{}  };
			my $p = $pt.parse-source( $source );
			my $tree = $pt.build-tree( $p );
			ok $pt.validate( $p ), Q{valid};
			is $pt.format( $tree ), $source, Q{formatted};
		}, Q{trailing ws};

		subtest {
			plan 2;

			my $source = Q{grammar Foo     {}  };
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
grammar Foo{   }
_END_
			my $p = $pt.parse-source( $source );
			my $tree = $pt.build-tree( $p );
			ok $pt.validate( $p ), Q{valid};
			is $pt.format( $tree ), $source, Q{formatted};
		}, Q{no ws};

		subtest {
			plan 2;

			my $source = Q:to[_END_];
grammar Foo     {   }
_END_
			my $p = $pt.parse-source( $source );
			my $tree = $pt.build-tree( $p );
			ok $pt.validate( $p ), Q{valid};
			is $pt.format( $tree ), $source, Q{formatted};
		}, Q{leading ws};

		subtest {
			plan 2;

			my $source = Q{grammar Foo{   }  };
			my $p = $pt.parse-source( $source );
			my $tree = $pt.build-tree( $p );
			ok $pt.validate( $p ), Q{valid};
			is $pt.format( $tree ), $source, Q{formatted};
		}, Q{trailing ws};

		subtest {
			plan 2;

			my $source = Q{grammar Foo     {   }  };
			my $p = $pt.parse-source( $source );
			my $tree = $pt.build-tree( $p );
			ok $pt.validate( $p ), Q{valid};
			is $pt.format( $tree ), $source, Q{formatted};
		}, Q{leading, trailing ws};
	}, Q{intrabrace spacing};

	subtest {
		plan 2;

		my $source = Q:to[_END_];
unit grammar Foo;
_END_
		my $p = $pt.parse-source( $source );
		my $tree = $pt.build-tree( $p );
		ok $pt.validate( $p ), Q{valid};
		is $pt.format( $tree ), $source, Q{formatted};
	}, Q{unit form};
}, Q{grammar};

subtest {
	plan 3;

	subtest {
		plan 4;

		subtest {
			plan 2;

			my $source = Q:to[_END_];
role Foo{}
_END_
			my $p = $pt.parse-source( $source );
			my $tree = $pt.build-tree( $p );
			ok $pt.validate( $p ), Q{valid};
			is $pt.format( $tree ), $source, Q{formatted};
		}, Q{no ws};

		subtest {
			plan 2;

			my $source = Q:to[_END_];
role Foo     {}
_END_
			my $p = $pt.parse-source( $source );
			my $tree = $pt.build-tree( $p );
			ok $pt.validate( $p ), Q{valid};
			is $pt.format( $tree ), $source, Q{formatted};
		}, Q{leading ws};

		subtest {
			plan 2;

			my $source = Q{role Foo{}  };
			my $p = $pt.parse-source( $source );
			my $tree = $pt.build-tree( $p );
			ok $pt.validate( $p ), Q{valid};
			is $pt.format( $tree ), $source, Q{formatted};
		}, Q{trailing ws};

		subtest {
			plan 2;

			my $source = Q{role Foo     {}  };
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
role Foo{   }
_END_
			my $p = $pt.parse-source( $source );
			my $tree = $pt.build-tree( $p );
			ok $pt.validate( $p ), Q{valid};
			is $pt.format( $tree ), $source, Q{formatted};
		}, Q{no ws};

		subtest {
			plan 2;

			my $source = Q:to[_END_];
role Foo     {   }
_END_
			my $p = $pt.parse-source( $source );
			my $tree = $pt.build-tree( $p );
			ok $pt.validate( $p ), Q{valid};
			is $pt.format( $tree ), $source, Q{formatted};
		}, Q{leading ws};

		subtest {
			plan 2;

			my $source = Q{role Foo{   }  };
			my $p = $pt.parse-source( $source );
			my $tree = $pt.build-tree( $p );
			ok $pt.validate( $p ), Q{valid};
			is $pt.format( $tree ), $source, Q{formatted};
		}, Q{trailing ws};

		subtest {
			plan 2;

			my $source = Q{role Foo     {   }  };
			my $p = $pt.parse-source( $source );
			my $tree = $pt.build-tree( $p );
			ok $pt.validate( $p ), Q{valid};
			is $pt.format( $tree ), $source, Q{formatted};
		}, Q{leading, trailing ws};
	}, Q{intrabrace spacing};

	subtest {
		plan 2;

		my $source = Q:to[_END_];
unit role Foo;
_END_
		my $p = $pt.parse-source( $source );
		my $tree = $pt.build-tree( $p );
		ok $pt.validate( $p ), Q{valid};
		is $pt.format( $tree ), $source, Q{formatted};
	}, Q{unit form};
}, Q{role};

subtest {
	plan 3;

	subtest {
		plan 4;

		subtest {
			plan 2;

			my $source = Q:to[_END_];
knowhow Foo{}
_END_
			my $p = $pt.parse-source( $source );
			my $tree = $pt.build-tree( $p );
			ok $pt.validate( $p ), Q{valid};
			is $pt.format( $tree ), $source, Q{formatted};
		}, Q{no ws};

		subtest {
			plan 2;

			my $source = Q:to[_END_];
knowhow Foo     {}
_END_
			my $p = $pt.parse-source( $source );
			my $tree = $pt.build-tree( $p );
			ok $pt.validate( $p ), Q{valid};
			is $pt.format( $tree ), $source, Q{formatted};
		}, Q{leading ws};

		subtest {
			plan 2;

			my $source = Q{knowhow Foo{}  };
			my $p = $pt.parse-source( $source );
			my $tree = $pt.build-tree( $p );
			ok $pt.validate( $p ), Q{valid};
			is $pt.format( $tree ), $source, Q{formatted};
		}, Q{trailing ws};

		subtest {
			plan 2;

			my $source = Q{knowhow Foo     {}  };
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
knowhow Foo{   }
_END_
			my $p = $pt.parse-source( $source );
			my $tree = $pt.build-tree( $p );
			ok $pt.validate( $p ), Q{valid};
			is $pt.format( $tree ), $source, Q{formatted};
		}, Q{no ws};

		subtest {
			plan 2;

			my $source = Q:to[_END_];
knowhow Foo     {   }
_END_
			my $p = $pt.parse-source( $source );
			my $tree = $pt.build-tree( $p );
			ok $pt.validate( $p ), Q{valid};
			is $pt.format( $tree ), $source, Q{formatted};
		}, Q{leading ws};

		subtest {
			plan 2;

			my $source = Q{knowhow Foo{   }  };
			my $p = $pt.parse-source( $source );
			my $tree = $pt.build-tree( $p );
			ok $pt.validate( $p ), Q{valid};
			is $pt.format( $tree ), $source, Q{formatted};
		}, Q{trailing ws};

		subtest {
			plan 2;

			my $source = Q{knowhow Foo     {   }  };
			my $p = $pt.parse-source( $source );
			my $tree = $pt.build-tree( $p );
			ok $pt.validate( $p ), Q{valid};
			is $pt.format( $tree ), $source, Q{formatted};
		}, Q{leading, trailing ws};
	}, Q{intrabrace spacing};

	subtest {
		plan 2;

		my $source = Q:to[_END_];
unit knowhow Foo;
_END_
		my $p = $pt.parse-source( $source );
		my $tree = $pt.build-tree( $p );
		ok $pt.validate( $p ), Q{valid};
		is $pt.format( $tree ), $source, Q{formatted};
	}, Q{unit form};
}, Q{knowhow};

subtest {
	plan 3;

	subtest {
		plan 4;

		subtest {
			plan 2;

			my $source = Q:to[_END_];
native Foo{}
_END_
			my $p = $pt.parse-source( $source );
			my $tree = $pt.build-tree( $p );
			ok $pt.validate( $p ), Q{valid};
			is $pt.format( $tree ), $source, Q{formatted};
		}, Q{no ws};

		subtest {
			plan 2;

			my $source = Q:to[_END_];
native Foo     {}
_END_
			my $p = $pt.parse-source( $source );
			my $tree = $pt.build-tree( $p );
			ok $pt.validate( $p ), Q{valid};
			is $pt.format( $tree ), $source, Q{formatted};
		}, Q{leading ws};

		subtest {
			plan 2;

			my $source = Q{native Foo{}  };
			my $p = $pt.parse-source( $source );
			my $tree = $pt.build-tree( $p );
			ok $pt.validate( $p ), Q{valid};
			is $pt.format( $tree ), $source, Q{formatted};
		}, Q{trailing ws};

		subtest {
			plan 2;

			my $source = Q{native Foo     {}  };
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
native Foo{   }
_END_
			my $p = $pt.parse-source( $source );
			my $tree = $pt.build-tree( $p );
			ok $pt.validate( $p ), Q{valid};
			is $pt.format( $tree ), $source, Q{formatted};
		}, Q{no ws};

		subtest {
			plan 2;

			my $source = Q:to[_END_];
native Foo     {   }
_END_
			my $p = $pt.parse-source( $source );
			my $tree = $pt.build-tree( $p );
			ok $pt.validate( $p ), Q{valid};
			is $pt.format( $tree ), $source, Q{formatted};
		}, Q{leading ws};

		subtest {
			plan 2;

			my $source = Q{native Foo{   }  };
			my $p = $pt.parse-source( $source );
			my $tree = $pt.build-tree( $p );
			ok $pt.validate( $p ), Q{valid};
			is $pt.format( $tree ), $source, Q{formatted};
		}, Q{trailing ws};

		subtest {
			plan 2;

			my $source = Q{native Foo     {   }  };
			my $p = $pt.parse-source( $source );
			my $tree = $pt.build-tree( $p );
			ok $pt.validate( $p ), Q{valid};
			is $pt.format( $tree ), $source, Q{formatted};
		}, Q{leading, trailing ws};
	}, Q{intrabrace spacing};

	subtest {
		plan 2;

		my $source = Q:to[_END_];
unit native Foo;
_END_
		my $p = $pt.parse-source( $source );
		my $tree = $pt.build-tree( $p );
		ok $pt.validate( $p ), Q{valid};
		is $pt.format( $tree ), $source, Q{formatted};
	}, Q{unit form};
}, Q{native};

#`(

I guess 'lang Foo { }' and 'unit lang Foo;' aren't valid constructs.

subtest {
	plan 3;

	subtest {
		plan 4;

		subtest {
			plan 2;

			my $source = Q:to[_END_];
lang Foo{}
_END_
			my $p = $pt.parse-source( $source );
			my $tree = $pt.build-tree( $p );
			ok $pt.validate( $p ), Q{valid};
			is $pt.format( $tree ), $source, Q{formatted};
		}, Q{no ws};

		subtest {
			plan 2;

			my $source = Q:to[_END_];
lang Foo     {}
_END_
			my $p = $pt.parse-source( $source );
			my $tree = $pt.build-tree( $p );
			ok $pt.validate( $p ), Q{valid};
			is $pt.format( $tree ), $source, Q{formatted};
		}, Q{leading ws};

		subtest {
			plan 2;

			my $source = Q{lang Foo{}  };
			my $p = $pt.parse-source( $source );
			my $tree = $pt.build-tree( $p );
			ok $pt.validate( $p ), Q{valid};
			is $pt.format( $tree ), $source, Q{formatted};
		}, Q{trailing ws};

		subtest {
			plan 2;

			my $source = Q{lang Foo     {}  };
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
lang Foo{   }
_END_
			my $p = $pt.parse-source( $source );
			my $tree = $pt.build-tree( $p );
			ok $pt.validate( $p ), Q{valid};
			is $pt.format( $tree ), $source, Q{formatted};
		}, Q{no ws};

		subtest {
			plan 2;

			my $source = Q:to[_END_];
lang Foo     {   }
_END_
			my $p = $pt.parse-source( $source );
			my $tree = $pt.build-tree( $p );
			ok $pt.validate( $p ), Q{valid};
			is $pt.format( $tree ), $source, Q{formatted};
		}, Q{leading ws};

		subtest {
			plan 2;

			my $source = Q{lang Foo{   }  };
			my $p = $pt.parse-source( $source );
			my $tree = $pt.build-tree( $p );
			ok $pt.validate( $p ), Q{valid};
			is $pt.format( $tree ), $source, Q{formatted};
		}, Q{trailing ws};

		subtest {
			plan 2;

			my $source = Q{lang Foo     {   }  };
			my $p = $pt.parse-source( $source );
			my $tree = $pt.build-tree( $p );
			ok $pt.validate( $p ), Q{valid};
			is $pt.format( $tree ), $source, Q{formatted};
		}, Q{leading, trailing ws};
	}, Q{intrabrace spacing};

	subtest {
		plan 2;

		my $source = Q:to[_END_];
unit lang Foo;
_END_
		my $p = $pt.parse-source( $source );
		my $tree = $pt.build-tree( $p );
		ok $pt.validate( $p ), Q{valid};
		is $pt.format( $tree ), $source, Q{formatted};
	}, Q{unit form};
}, Q{lang};
)

# vim: ft=perl6
