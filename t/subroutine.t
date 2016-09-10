use v6;

use Test;
use Perl6::Tidy;

plan 2;

my $pt = Perl6::Tidy.new;
#my $*TRACE = 1;
#my $*DEBUG = 1;

subtest {
	plan 2;

	subtest {
		plan 6;

		subtest {
			plan 3;

			subtest {
				plan 2;

				my $source = Q{sub foo(){}};
				my $parsed = $pt.parse-source( $source );
				my $tree = $pt.build-tree( $parsed );
				ok $pt.validate( $parsed ), Q{valid};
				is $pt.format( $tree ), $source, Q{formatted};
			}, Q{no ws};

			subtest {
				plan 2;

				my $source = Q{sub foo() {}};
				my $parsed = $pt.parse-source( $source );
				my $tree = $pt.build-tree( $parsed );
				ok $pt.validate( $parsed ), Q{valid};
				is $pt.format( $tree ), $source, Q{formatted};
			}, Q{ws};

			subtest {
				plan 2;

				my $source = Q{sub foo( ) { }};
				my $parsed = $pt.parse-source( $source );
				my $tree = $pt.build-tree( $parsed );
				ok $pt.validate( $parsed ), Q{valid};
				is $pt.format( $tree ), $source, Q{formatted};
			}, Q{ws};
		}, Q{empty};

		subtest {
			plan 2;

			subtest {
				plan 2;

				my $source = Q{sub foo(0){}};
				my $parsed = $pt.parse-source( $source );
				my $tree = $pt.build-tree( $parsed );
				ok $pt.validate( $parsed ), Q{valid};
				is $pt.format( $tree ), $source, Q{formatted};
			}, Q{no ws};

			subtest {
				plan 0;
#`(
				my $source = Q:to[_END_];
sub foo( 0 ) { }
_END_
				my $parsed = $pt.parse-source( $source );
				my $tree = $pt.build-tree( $parsed );
				ok $pt.validate( $parsed ), Q{valid};
				is $pt.format( $tree ), $source, Q{formatted};
)
			}, Q{ws};
		}, Q{constant};

		subtest {
			plan 2;

			subtest {
				plan 2;

				my $source = Q{sub foo($a){}};
				my $parsed = $pt.parse-source( $source );
				my $tree = $pt.build-tree( $parsed );
				ok $pt.validate( $parsed ), Q{valid};
				is $pt.format( $tree ), $source, Q{formatted};
			}, Q{no ws};

			subtest {
				plan 0;
#`(
				my $source = Q:to[_END_];
sub foo( $a ) { }
_END_
				my $parsed = $pt.parse-source( $source );
				my $tree = $pt.build-tree( $parsed );
				ok $pt.validate( $parsed ), Q{valid};
				is $pt.format( $tree ), $source, Q{formatted};
)
			}, Q{ws};
		}, Q{untyped};

		subtest {
			plan 4;

			subtest {
				plan 2;

				subtest {
					plan 2;

					my $source = Q{sub foo(Int$a){}};
					my $parsed = $pt.parse-source( $source );
					my $tree = $pt.build-tree( $parsed );
					ok $pt.validate( $parsed ), Q{valid};
					is $pt.format( $tree ), $source, Q{formatted};
				}, Q{no ws};

				subtest {
					plan 0;
#`(
					my $source = Q:to[_END_];
sub foo( Int $a ) { }
_END_
					my $parsed = $pt.parse-source( $source );
					my $tree = $pt.build-tree( $parsed );
					ok $pt.validate( $parsed ), Q{valid};
					is $pt.format( $tree ), $source, Q{formatted};
)
				}, Q{ws};
			}, Q{typed};

			subtest {
				plan 2;

				subtest {
					plan 0;
#`(
					my $source = Q{sub foo(::T$a){}};
					my $parsed = $pt.parse-source( $source );
					my $tree = $pt.build-tree( $parsed );
					ok $pt.validate( $parsed ), Q{valid};
					is $pt.format( $tree ), $source, Q{formatted};
)
				}, Q{no ws};

				subtest {
					plan 0;
#`(
					my $source = Q:to[_END_];
sub foo( ::T $a ) { }
_END_
					my $parsed = $pt.parse-source( $source );
					my $tree = $pt.build-tree( $parsed );
					ok $pt.validate( $parsed ), Q{valid};
					is $pt.format( $tree ), $source, Q{formatted};
)
				}, Q{ws};
			}, Q{type-capture};

			subtest {
				plan 2;

				subtest {
					plan 2;

					my $source = Q{sub foo(Int){}};
					my $parsed = $pt.parse-source( $source );
					my $tree = $pt.build-tree( $parsed );
					ok $pt.validate( $parsed ), Q{valid};
					is $pt.format( $tree ), $source, Q{formatted};
				}, Q{no ws};

				subtest {
					plan 0;
#`(
					my $source = Q:to[_END_];
sub foo( Int ) { }
_END_
					my $parsed = $pt.parse-source( $source );
					my $tree = $pt.build-tree( $parsed );
					ok $pt.validate( $parsed ), Q{valid};
					is $pt.format( $tree ), $source, Q{formatted};
)
				}, Q{ws};
			}, Q{type-only};

			subtest {
				plan 2;

				subtest {
					plan 0;

#`(
					my $source = Q{sub foo(Int$a where 1){}};
					my $parsed = $pt.parse-source( $source );
					my $tree = $pt.build-tree( $parsed );
					ok $pt.validate( $parsed ), Q{valid};
					is $pt.format( $tree ), $source, Q{formatted};
)
				}, Q{no ws};

				subtest {
					plan 0;
#`(
					my $source = Q:to[_END_];
sub foo( Int $a where 1 ) { }
_END_
					my $parsed = $pt.parse-source( $source );
					my $tree = $pt.build-tree( $parsed );
					ok $pt.validate( $parsed ), Q{valid};
					is $pt.format( $tree ), $source, Q{formatted};
)
				}, Q{ws};
			}, Q{type-constrained};
		}, Q{typed};

		subtest {
			plan 2;

			subtest {
				plan 2;

				my $source = Q{sub foo($a=0){}};
				my $parsed = $pt.parse-source( $source );
				my $tree = $pt.build-tree( $parsed );
				ok $pt.validate( $parsed ), Q{valid};
				is $pt.format( $tree ), $source, Q{formatted};
			}, Q{no ws};

			subtest {
				plan 0;
#`(
				my $source = Q:to[_END_];
sub foo( $a = 0 ) { }
_END_
				my $parsed = $pt.parse-source( $source );
				my $tree = $pt.build-tree( $parsed );
				ok $pt.validate( $parsed ), Q{valid};
				is $pt.format( $tree ), $source, Q{formatted};
)
			}, Q{ws};
		}, Q{default};

		subtest {
			plan 2;

			subtest {
				plan 0;
#`(
				my $source = Q{sub foo(:a){}};
				my $parsed = $pt.parse-source( $source );
				my $tree = $pt.build-tree( $parsed );
				ok $pt.validate( $parsed ), Q{valid};
				is $pt.format( $tree ), $source, Q{formatted};
)
			}, Q{no ws};

			subtest {
				plan 0;
#`(
				my $source = Q:to[_END_];
sub foo( :a ) { }
_END_
				my $parsed = $pt.parse-source( $source );
				my $tree = $pt.build-tree( $parsed );
				ok $pt.validate( $parsed ), Q{valid};
				is $pt.format( $tree ), $source, Q{formatted};
)
			}, Q{ws};
		}, Q{optional};
	}, Q{single};

	subtest {
		plan 2;

		subtest {
			plan 0;
#`(
			my $source = Q{sub foo($a,$b){}};
			my $parsed = $pt.parse-source( $source );
			my $tree = $pt.build-tree( $parsed );
			ok $pt.validate( $parsed ), Q{valid};
			is $pt.format( $tree ), $source, Q{formatted};
)
		}, Q{no ws};

		subtest {
			plan 0;
#`(
			my $source = Q:to[_END_];
sub foo( $a, $b ) { }
_END_
			my $parsed = $pt.parse-source( $source );
			my $tree = $pt.build-tree( $parsed );
			ok $pt.validate( $parsed ), Q{valid};
			is $pt.format( $tree ), $source, Q{formatted};
)
		}, Q{ws};
	}, Q{multiple};
}, Q{scalar arguments};

subtest {
	plan 4;

	subtest {
		plan 0;

#`(
		my $source = Q{sub foo($a,Str$b,Str$c where"foo",Int$d=32){}};
		my $parsed = $pt.parse-source( $source );
		my $tree = $pt.build-tree( $parsed );
		ok $pt.validate( $parsed ), Q{valid};
		is $pt.format( $tree ), $source, Q{formatted};
)
	}, Q{christmas tree, minimal spacing};

	subtest {
		plan 0;

#`(
		my $source = Q:to[_END_];
sub foo($a,Str$b,Str$c where"foo",Int$d=32){}
_END_
		my $parsed = $pt.parse-source( $source );
		my $tree = $pt.build-tree( $parsed );
		ok $pt.validate( $parsed ), Q{valid};
		is $pt.format( $tree ), $source, Q{formatted};
)
	}, Q{christmas tree, minimal spacing};

	# Having differing whitespace on each side of an operator assures
	# that Perl6::WS objects aren't being reused, and the WS isn't
	# actually being copied from the wrong RE.
	#
	subtest {
		plan 0;

#`(
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
		my $parsed = $pt.parse-source( $source );
		my $tree = $pt.build-tree( $parsed );
		ok $pt.validate( $parsed ), Q{valid};
		is $pt.format( $tree ), $source, Q{formatted};
)
	}, Q{christmas tree, alternating spacing};

	subtest {
		plan 0;

#`(
		my $source = Q:to[_END_];
sub foo(  $a  ,  Str  $b  ,  Str  $c  where  "foo"  ,  Int  $d  =  32  )  {  }
_END_
		my $parsed = $pt.parse-source( $source );
		my $tree = $pt.build-tree( $parsed );
		ok $pt.validate( $parsed ), Q{valid};
		is $pt.format( $tree ), $source, Q{formatted};
)
	}, Q{christmas tree, maximal spacing};
}, Q{christmas tree};

# vim: ft=perl6
