use v6;

use Test;
use Perl6::Parser;

use lib 't/lib';
use Utils; # Get gensym-package

# The terms that get tested here are:

# package <name> { }
# module <name> { }
# class <name> { }
# grammar <name> { }
# role <name> { }
# knowhow <name> { }
# native <name> { }
# also is <name>
# trusts <name>
#
# class Foo { also is Int } # 'also' is a package_declaration.
# class Foo { trusts Int } # 'trusts' is a package_declaration.

# These terms either are invalid or need additional support structures.
# I'll add them momentarily...
#
# lang <name>

plan 2 * 11;

my $pt = Perl6::Parser.new;
my $*CONSISTENCY-CHECK = True;
my $*FALL-THROUGH = True;
my ( $source, $tree );

# Classes, modules, packages &c can no longer be redeclared.
# Which is probably a good thing, but plays havoc with testing here.
#
# This is a little ol' tool that generates a fresh package name every time
# through the testing suite. I can't just make up new names as the test suite
# goes along because I'm running the full test suite twice, once with the
# original Perl6 parser-aided version, and once with the new regex-based parser.
#
# Use it to build out package names and such.
#

for ( True, False ) -> $*PURE-PERL {
	subtest {
		plan 3;

		subtest {
			plan 4;

			subtest {
				$source = gensym-package Q{package %s{}};
				$tree = $pt.to-tree( $source );
				is $pt.to-string( $tree ), $source, Q{formatted};
				ok $tree.child[0].child[3].child[0] ~~
					Perl6::Block::Enter, Q{enter brace};
				ok $tree.child[0].child[3].child[1] ~~
					Perl6::Block::Exit, Q{exit brace};

				done-testing;
			}, Q{no ws};

			$source = gensym-package Q:to[_END_];
			package %s     {}
			_END_
			$tree = $pt.to-tree( $source );
			is $pt.to-string( $tree ), $source, Q{leading ws};

			$source = gensym-package Q{package %s{}  };
			$tree = $pt.to-tree( $source );
			is $pt.to-string( $tree ), $source, Q{trailing ws};

			$source = gensym-package Q{package %s     {}  };
			$tree = $pt.to-tree( $source );
			is $pt.to-string( $tree ), $source, Q{leading, trailing ws};
		}, Q{no intrabrace spacing};

		subtest {
			plan 4;

			$source = gensym-package Q{package %s{   }};
			$tree = $pt.to-tree( $source );
			is $pt.to-string( $tree ), $source, Q{no ws};

			$source = gensym-package Q:to[_END_];
			package %s     {   }
			_END_
			$tree = $pt.to-tree( $source );
			is $pt.to-string( $tree ), $source, Q{leading ws};

			$source = gensym-package Q{package %s{   }  };
			$tree = $pt.to-tree( $source );
			is $pt.to-string( $tree ), $source, Q{trailing ws};

			$source = gensym-package Q{package %s     {   }  };
			$tree = $pt.to-tree( $source );
			is $pt.to-string( $tree ), $source, Q{leading, trailing ws};
		}, Q{intrabrace spacing};

		subtest {
			plan 2;

			$source = gensym-package Q{unit package %s;};
			$tree = $pt.to-tree( $source );
			is $pt.to-string( $tree ), $source, Q{no ws};

			$source = gensym-package Q:to[_END_];
			unit package %s  ;
			_END_
			$tree = $pt.to-tree( $source );
			is $pt.to-string( $tree ), $source, Q{ws before semi};
		}, Q{unit form};
	}, Q{package};

	subtest {
		plan 3;

		subtest {
			plan 4;

			$source = gensym-package Q{module %s{}};
			$tree = $pt.to-tree( $source );
			is $pt.to-string( $tree ), $source, Q{no ws};

			$source = gensym-package Q:to[_END_];
			module %s     {}
			_END_
			$tree = $pt.to-tree( $source );
			is $pt.to-string( $tree ), $source, Q{leading ws};

			$source = gensym-package Q{module %s{}  };
			$tree = $pt.to-tree( $source );
			is $pt.to-string( $tree ), $source, Q{trailing ws};

			$source = gensym-package Q{module %s     {}  };
			$tree = $pt.to-tree( $source );
			is $pt.to-string( $tree ), $source, Q{leading, trailing ws};
		}, Q{no intrabrace spacing};

		subtest {
			plan 4;

			$source = gensym-package Q{module %s{   }};
			$tree = $pt.to-tree( $source );
			is $pt.to-string( $tree ), $source, Q{no ws};

			$source = gensym-package Q:to[_END_];
			module %s     {   }
			_END_
			$tree = $pt.to-tree( $source );
			is $pt.to-string( $tree ), $source, Q{leading ws};

			$source = gensym-package Q{module %s{   }  };
			$tree = $pt.to-tree( $source );
			is $pt.to-string( $tree ), $source, Q{trailing ws};

			$source = gensym-package Q{module %s     {   }  };
			$tree = $pt.to-tree( $source );
			is $pt.to-string( $tree ), $source, Q{leading, trailing ws};
		}, Q{intrabrace spacing};

		subtest {
			plan 2;

			$source = gensym-package Q{unit module %s;};
			$tree = $pt.to-tree( $source );
			is $pt.to-string( $tree ), $source, Q{no ws};

			$source = gensym-package Q:to[_END_];
			unit module %s;
			_END_
			$tree = $pt.to-tree( $source );
			is $pt.to-string( $tree ), $source, Q{ws};
		}, Q{unit form};
	}, Q{module};

	subtest {
		plan 3;

		subtest {
			plan 4;

			$source = gensym-package Q{class %s{}};
			$tree = $pt.to-tree( $source );
			is $pt.to-string( $tree ), $source, Q{no ws};

			$source = gensym-package Q:to[_END_];
			class %s     {}
			_END_
			$tree = $pt.to-tree( $source );
			is $pt.to-string( $tree ), $source, Q{leading ws};

			$source = gensym-package Q{class %s{}  };
			$tree = $pt.to-tree( $source );
			is $pt.to-string( $tree ), $source, Q{trailing ws};

			$source = gensym-package Q{class %s     {}  };
			$tree = $pt.to-tree( $source );
			is $pt.to-string( $tree ), $source, Q{leading, trailing ws};
		}, Q{no intrabrace spacing};

		subtest {
			plan 4;

			$source = gensym-package Q{class %s{   }};
			$tree = $pt.to-tree( $source );
			is $pt.to-string( $tree ), $source, Q{no ws};

			$source = gensym-package Q:to[_END_];
			class %s     {   }
			_END_
			$tree = $pt.to-tree( $source );
			is $pt.to-string( $tree ), $source, Q{leading ws};

			$source = gensym-package Q{class %s{   }  };
			$tree = $pt.to-tree( $source );
			is $pt.to-string( $tree ), $source, Q{trailing ws};

			$source = gensym-package Q{class %s     {   }  };
			$tree = $pt.to-tree( $source );
			is $pt.to-string( $tree ), $source, Q{leading, trailing ws};
		}, Q{intrabrace spacing};

		subtest {
			plan 2;

			$source = gensym-package Q{unit class %s;};
			$tree = $pt.to-tree( $source );
			is $pt.to-string( $tree ), $source, Q{no ws};

			$source = gensym-package Q:to[_END_];
			unit class %s;
			_END_
			$tree = $pt.to-tree( $source );
			is $pt.to-string( $tree ), $source, Q{ws};
		}, Q{unit form};
	}, Q{class};

	subtest {
		plan 2;

		$source = gensym-package Q{class %s{also is Int}};
		$tree = $pt.to-tree( $source );
		is $pt.to-string( $tree ), $source, Q{no ws};

		$source = gensym-package Q:to[_END_];
		class %s{also     is   Int}
		_END_
		$tree = $pt.to-tree( $source );
		is $pt.to-string( $tree ), $source, Q{ws};
	}, Q{class Foo also is};

	subtest {
		plan 2;

		# space between 'Int' and {} is required
		$source = gensym-package Q{class %s is Int {}};
		$tree = $pt.to-tree( $source );
		is $pt.to-string( $tree ), $source, Q{no ws};

		$source = gensym-package Q:to[_END_];
		class %s is Int {}
		_END_
		$tree = $pt.to-tree( $source );
		is $pt.to-string( $tree ), $source, Q{ws};
	}, Q{class Foo is};

	subtest {
		plan 4;

		$source = gensym-package Q{class %s is repr('CStruct'){has int8$i}};
		$tree = $pt.to-tree( $source );
		is $pt.to-string( $tree ), $source, Q{no ws};

		$source = gensym-package Q:to[_END_];
		class %s is repr('CStruct'){has int8$i}
		_END_
		$tree = $pt.to-tree( $source );
		is $pt.to-string( $tree ), $source, Q{ws};

		$source = gensym-package Q:to[_END_];
		class %s is repr('CStruct') { has int8 $i }
		_END_
		$tree = $pt.to-tree( $source );
		is $pt.to-string( $tree ), $source, Q{more ws};

		$source = gensym-package Q:to[_END_];
		class %s is repr( 'CStruct' ) { has int8 $i }
		_END_
		$tree = $pt.to-tree( $source );
		is $pt.to-string( $tree ), $source, Q{even more ws};
	}, Q{class Foo is repr()};

	subtest {
		plan 2;

		# space between 'Int' and {} is required
		$source = gensym-package Q{class %s{trusts Int}};
		$tree = $pt.to-tree( $source );
		is $pt.to-string( $tree ), $source, Q{no ws};

		$source = gensym-package Q:to[_END_];
		class %s { trusts Int }
		_END_
		$tree = $pt.to-tree( $source );
		is $pt.to-string( $tree ), $source, Q{ws};
	}, Q{class Foo trusts};

	subtest {
		plan 3;

		subtest {
			plan 4;

			$source = gensym-package Q{grammar %s{}};
			$tree = $pt.to-tree( $source );
			is $pt.to-string( $tree ), $source, Q{no ws};

			$source = gensym-package Q:to[_END_];
			grammar %s     {}
			_END_
			$tree = $pt.to-tree( $source );
			is $pt.to-string( $tree ), $source, Q{leading ws};

			$source = gensym-package Q{grammar %s{}  };
			$tree = $pt.to-tree( $source );
			is $pt.to-string( $tree ), $source, Q{trailing ws};

			$source = gensym-package Q{grammar %s     {}  };
			$tree = $pt.to-tree( $source );
			is $pt.to-string( $tree ), $source, Q{leading, trailing ws};
		}, Q{no intrabrace spacing};

		subtest {
			plan 4;

			$source = gensym-package Q{grammar %s{   }};
			$tree = $pt.to-tree( $source );
			is $pt.to-string( $tree ), $source, Q{no ws};

			$source = gensym-package Q:to[_END_];
			grammar %s     {   }
			_END_
			$tree = $pt.to-tree( $source );
			is $pt.to-string( $tree ), $source, Q{leading ws};

			$source = gensym-package Q{grammar %s{   }  };
			$tree = $pt.to-tree( $source );
			is $pt.to-string( $tree ), $source, Q{trailing ws};

			$source = gensym-package Q{grammar %s     {   }  };
			$tree = $pt.to-tree( $source );
			is $pt.to-string( $tree ), $source, Q{leading, trailing ws};
		}, Q{intrabrace spacing};

		subtest {
			plan 2;

			$source = gensym-package Q{unit grammar %s;};
			$tree = $pt.to-tree( $source );
			is $pt.to-string( $tree ), $source, Q{no ws};

			$source = gensym-package Q:to[_END_];
			unit grammar %s;
			_END_
			$tree = $pt.to-tree( $source );
			is $pt.to-string( $tree ), $source, Q{ws};
		}, Q{unit form};
	}, Q{grammar};

	subtest {
		plan 3;

		subtest {
			plan 4;

			$source = gensym-package Q{role %s{}};
			$tree = $pt.to-tree( $source );
			is $pt.to-string( $tree ), $source, Q{no ws};

			$source = gensym-package Q:to[_END_];
			role %s     {}
			_END_
			$tree = $pt.to-tree( $source );
			is $pt.to-string( $tree ), $source, Q{leading ws};

			$source = gensym-package Q{role %s{}  };
			$tree = $pt.to-tree( $source );
			is $pt.to-string( $tree ), $source, Q{trailing ws};

			$source = gensym-package Q{role %s     {}  };
			$tree = $pt.to-tree( $source );
			is $pt.to-string( $tree ), $source, Q{leading, trailing ws};
		}, Q{no intrabrace spacing};

		subtest {
			plan 4;

			$source = Q{role Foo{   }};
			$tree = $pt.to-tree( $source );
			is $pt.to-string( $tree ), $source, Q{no ws};

			$source = Q:to[_END_];
			role Foo     {   }
			_END_
			$tree = $pt.to-tree( $source );
			is $pt.to-string( $tree ), $source, Q{leading ws};

			$source = Q{role Foo{   }  };
			$tree = $pt.to-tree( $source );
			is $pt.to-string( $tree ), $source, Q{trailing ws};

			$source = Q{role Foo     {   }  };
			$tree = $pt.to-tree( $source );
			is $pt.to-string( $tree ), $source, Q{leading, trailing ws};
		}, Q{intrabrace spacing};

		subtest {
			plan 2;

			$source = gensym-package Q{unit role %s;};
			$tree = $pt.to-tree( $source );
			is $pt.to-string( $tree ), $source, Q{no ws};

			$source = gensym-package Q:to[_END_];
			unit role %s;
			_END_
			$tree = $pt.to-tree( $source );
			is $pt.to-string( $tree ), $source,  Q{ws};
		}, Q{unit form};
	}, Q{role};

	subtest {
		plan 3;

		subtest {
			plan 4;

			$source = gensym-package Q{knowhow %s{}};
			$tree = $pt.to-tree( $source );
			is $pt.to-string( $tree ), $source, Q{no ws};

			$source = gensym-package Q:to[_END_];
			knowhow %s     {}
			_END_
			$tree = $pt.to-tree( $source );
			is $pt.to-string( $tree ), $source, Q{leading ws};

			$source = gensym-package Q{knowhow %s{}  };
			$tree = $pt.to-tree( $source );
			is $pt.to-string( $tree ), $source, Q{trailing ws};

			$source = gensym-package Q{knowhow %s     {}  };
			$tree = $pt.to-tree( $source );
			is $pt.to-string( $tree ), $source, Q{leading, trailing ws};
		}, Q{no intrabrace spacing};

		subtest {
			plan 4;

			$source = gensym-package Q{knowhow %s{   }};
			$tree = $pt.to-tree( $source );
			is $pt.to-string( $tree ), $source, Q{no ws};

			$source = gensym-package Q:to[_END_];
			knowhow %s     {   }
			_END_
			$tree = $pt.to-tree( $source );
			is $pt.to-string( $tree ), $source, Q{leading ws};

			$source = gensym-package Q{knowhow %s{   }  };
			$tree = $pt.to-tree( $source );
			is $pt.to-string( $tree ), $source, Q{trailing ws};

			$source = gensym-package Q{knowhow %s     {   }  };
			$tree = $pt.to-tree( $source );
			is $pt.to-string( $tree ), $source, Q{leading, trailing ws};
		}, Q{intrabrace spacing};

		subtest {
			plan 2;

			$source = gensym-package Q{unit knowhow %s;};
			$tree = $pt.to-tree( $source );
			is $pt.to-string( $tree ), $source, Q{no ws};

			$source = gensym-package Q:to[_END_];
			unit knowhow %s;
			_END_
			$tree = $pt.to-tree( $source );
			is $pt.to-string( $tree ), $source, Q{ws};
		}, Q{unit form};
	}, Q{knowhow};

	subtest {
		plan 3;

		subtest {
			plan 4;

			$source = gensym-package Q{native %s{}};
			$tree = $pt.to-tree( $source );
			is $pt.to-string( $tree ), $source, Q{no ws};

			$source = gensym-package Q:to[_END_];
			native %s     {}
			_END_
			$tree = $pt.to-tree( $source );
			is $pt.to-string( $tree ), $source, Q{leading ws};

			$source = gensym-package Q{native %s{}  };
			$tree = $pt.to-tree( $source );
			is $pt.to-string( $tree ), $source, Q{trailing ws};

			$source = gensym-package Q{native %s     {}  };
			$tree = $pt.to-tree( $source );
			is $pt.to-string( $tree ), $source, Q{leading, trailing ws};
		}, Q{no intrabrace spacing};

		subtest {
			plan 4;

			$source = gensym-package Q{native %s{   }};
			$tree = $pt.to-tree( $source );
			is $pt.to-string( $tree ), $source, Q{no ws};

			$source = gensym-package Q:to[_END_];
			native %s     {   }
			_END_
			$tree = $pt.to-tree( $source );
			is $pt.to-string( $tree ), $source, Q{leading ws};

			$source = gensym-package Q{native %s{   }  };
			$tree = $pt.to-tree( $source );
			is $pt.to-string( $tree ), $source, Q{trailing ws};

			$source = gensym-package Q{native %s     {   }  };
			$tree = $pt.to-tree( $source );
			is $pt.to-string( $tree ), $source, Q{leading, trailing ws};
		}, Q{intrabrace spacing};

		subtest {
			plan 2;

			$source = gensym-package Q{unit native %s;};
			$tree = $pt.to-tree( $source );
			is $pt.to-string( $tree ), $source, Q{no ws};

			$source = gensym-package Q:to[_END_];
			unit native %s;
			_END_
			$tree = $pt.to-tree( $source );
			is $pt.to-string( $tree ), $source, Q{ws};
		}, Q{unit form};
	}, Q{native};
}

# XXX 'lang Foo{}' illegal
# XXX 'unit lang Foo;' illegal

# vim: ft=perl6
