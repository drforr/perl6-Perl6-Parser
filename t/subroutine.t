use v6;

use Test;
use Perl6::Parser;

plan 3;

my $pt = Perl6::Parser.new;
my $*CONSISTENCY-CHECK = True;
my $*GRAMMAR-CHECK = True;

subtest {
	plan 2;

	subtest {
		plan 5;

		subtest {
			plan 2;

			subtest {
				my $source = Q{sub foo(){}};
				my $p = $pt.parse( $source );
				my $tree = $pt.build-tree( $p );
				is $pt.to-string( $tree ),
					$source, Q{formatted};

				done-testing;
			}, Q{no ws};

			subtest {
				my $source = Q{sub foo( ) { }};
				my $p = $pt.parse( $source );
				my $tree = $pt.build-tree( $p );
				is $pt.to-string( $tree ),
					$source, Q{formatted};

				done-testing;
			}, Q{intra-term ws};
		}, Q{empty};

		subtest {
			plan 2;

			subtest {
				my $source = Q{sub foo(0){}};
				my $p = $pt.parse( $source );
				my $tree = $pt.build-tree( $p );
				is $pt.to-string( $tree ),
					$source, Q{formatted};

				done-testing;
			}, Q{no ws};

			subtest {
				my $source = Q:to[_END_];
sub foo( 0 ) { }
_END_
				my $p = $pt.parse( $source );
				my $tree = $pt.build-tree( $p );
				is $pt.to-string( $tree ),
					$source, Q{formatted};

				done-testing;
			}, Q{ws};
		}, Q{constant};

		subtest {
			plan 2;

			subtest {
				my $source = Q{sub foo($a){}};
				my $p = $pt.parse( $source );
				my $tree = $pt.build-tree( $p );
				is $pt.to-string( $tree ),
					$source, Q{formatted};

				done-testing;
			}, Q{no ws};

			subtest {
				my $source = Q:to[_END_];
sub foo( $a ) { }
_END_
				my $p = $pt.parse( $source );
				my $tree = $pt.build-tree( $p );
				is $pt.to-string( $tree ),
					$source, Q{formatted};

				done-testing;
			}, Q{ws};
		}, Q{untyped};

		subtest {
			plan 5;

			subtest {
				plan 2;

				subtest {
					my $source = Q{sub foo(Int$a){}};
					my $p = $pt.parse( $source );
					my $tree = $pt.build-tree( $p );
					is $pt.to-string( $tree ),
						$source, Q{formatted};

					done-testing;
				}, Q{no ws};

				subtest {
					my $source = Q:to[_END_];
sub foo( Int $a ) { }
_END_
					my $p = $pt.parse( $source );
					my $tree = $pt.build-tree( $p );
					is $pt.to-string( $tree ),
						$source, Q{formatted};

					done-testing;
				}, Q{ws};
			}, Q{typed};

			subtest {
				plan 2;

				subtest {
					my $source = Q{sub foo(Int$a=32){}};
					my $p = $pt.parse( $source );
					my $tree = $pt.build-tree( $p );
					is $pt.to-string( $tree ),
						$source, Q{formatted};

					done-testing;
				}, Q{no ws};

				subtest {
					my $source = Q:to[_END_];
sub foo( Int $a = 32 ) { }
_END_
					my $p = $pt.parse( $source );
					my $tree = $pt.build-tree( $p );
					is $pt.to-string( $tree ),
						$source, Q{formatted};

					done-testing;
				}, Q{ws};
			}, Q{typed and declared};

			subtest {
				plan 2;

				subtest {
					my $source = Q{sub foo(::T$a){}};
					my $p = $pt.parse( $source );
					my $tree = $pt.build-tree( $p );
					is $pt.to-string( $tree ),
						$source, Q{formatted};

					done-testing;
				}, Q{no ws};

				subtest {
					my $source = Q:to[_END_];
sub foo( ::T $a ) { }
_END_
					my $p = $pt.parse( $source );
					my $tree = $pt.build-tree( $p );
					is $pt.to-string( $tree ),
						$source, Q{formatted};

					done-testing;
				}, Q{ws};
			}, Q{type-capture};

			subtest {
				plan 2;

				subtest {
					my $source = Q{sub foo(Int){}};
					my $p = $pt.parse( $source );
					my $tree = $pt.build-tree( $p );
					is $pt.to-string( $tree ),
						$source, Q{formatted};

					done-testing;
				}, Q{no ws};

				subtest {
					my $source = Q:to[_END_];
sub foo( Int ) { }
_END_
					my $p = $pt.parse( $source );
					my $tree = $pt.build-tree( $p );
					is $pt.to-string( $tree ),
						$source, Q{formatted};

					done-testing;
				}, Q{ws};
			}, Q{type-only};

			subtest {
				plan 2;

				subtest {
					my $source = Q{sub foo(Int$a where 1){}};
					my $p = $pt.parse( $source );
					my $tree = $pt.build-tree( $p );
					is $pt.to-string( $tree ),
						$source, Q{formatted};

					done-testing;
				}, Q{no ws};

				subtest {
					my $source = Q:to[_END_];
sub foo( Int $a where 1 ) { }
_END_
					my $p = $pt.parse( $source );
					my $tree = $pt.build-tree( $p );
					is $pt.to-string( $tree ),
						$source, Q{formatted};

					done-testing;
				}, Q{ws};
			}, Q{type-constrained};
		}, Q{typed};

		subtest {
			plan 2;

			subtest {
				my $source = Q{sub foo($a=0){}};
				my $p = $pt.parse( $source );
				my $tree = $pt.build-tree( $p );
				is $pt.to-string( $tree ),
					$source, Q{formatted};

				done-testing;
			}, Q{no ws};

			subtest {
				my $source = Q:to[_END_];
sub foo( $a = 0 ) { }
_END_
				my $p = $pt.parse( $source );
				my $tree = $pt.build-tree( $p );
				is $pt.to-string( $tree ),
					$source, Q{formatted};

				done-testing;
			}, Q{ws};
		}, Q{default};

		# XXX 'sub foo(:a) { }' illegal
	}, Q{single};

	subtest {
		plan 2;

		subtest {
			my $source = Q{sub foo($a,$b){}};
			my $p = $pt.parse( $source );
			my $tree = $pt.build-tree( $p );
			is $pt.to-string( $tree ), $source, Q{formatted};

			done-testing;
		}, Q{no ws};

		subtest {
			my $source = Q:to[_END_];
sub foo( $a, $b ) { }
_END_
			my $p = $pt.parse( $source );
			my $tree = $pt.build-tree( $p );
			is $pt.to-string( $tree ), $source, Q{formatted};

			done-testing;
		}, Q{ws};
	}, Q{multiple};
}, Q{scalar arguments};

subtest {
	plan 4;

	subtest {
		my $source = Q{sub foo($a,Str$b,Str$c where"foo",Int$d=32){}};
		my $p = $pt.parse( $source );
		my $tree = $pt.build-tree( $p );
		is $pt.to-string( $tree ), $source, Q{formatted};

		done-testing;
	}, Q{christmas tree, minimal spacing};

	subtest {
		my $source = Q:to[_END_];
sub foo($a,Str$b,Str$c where"foo",Int$d=32){}
_END_
		my $p = $pt.parse( $source );
		my $tree = $pt.build-tree( $p );
		is $pt.to-string( $tree ), $source, Q{formatted};

		done-testing;
	}, Q{christmas tree, minimal spacing};

	# Having differing whitespace on each side of an operator assures
	# that Perl6::WS objects aren't being reused, and the WS isn't
	# actually being copied from the wrong RE.
	#
	subtest {
		my $source = Q:to[_END_];
sub foo(
$a  ,
Str  $b
,  Str
$c  where
"foo"  ,
Int  $d
=  32
)  {
}
_END_
		my $p = $pt.parse( $source );
		my $tree = $pt.build-tree( $p );
		is $pt.to-string( $tree ), $source, Q{formatted};

		done-testing;
	}, Q{christmas tree, alternating spacing};

	subtest {
		my $source = Q:to[_END_];
sub foo(  $a  ,  Str  $b  ,  Str  $c  where  "foo"  ,  Int  $d  =  32  )  {  }
_END_
		my $p = $pt.parse( $source );
		my $tree = $pt.build-tree( $p );
		is $pt.to-string( $tree ), $source, Q{formatted};

		done-testing;
	}, Q{christmas tree, maximal spacing};
}, Q{christmas tree};

subtest {
	my $source = Q:to[_END_];
sub foo ( ) { }
_END_
	my $p = $pt.parse( $source );
	my $tree = $pt.build-tree( $p );
	is $pt.to-string( $tree ), $source, Q{formatted};

	done-testing;
}, Q{separate function name and open paren};

# vim: ft=perl6
