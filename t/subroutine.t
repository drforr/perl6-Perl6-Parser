use v6;

use Test;
use Perl6::Parser;

plan 3;

my $pt = Perl6::Parser.new;
my $*CONSISTENCY-CHECK = True;
my $*FALL-THROUGH = True;
my ( $source, $tree );

subtest {
	plan 2;

	subtest {
		plan 5;

		subtest {
			plan 2;

			$source = Q{sub foo(){}};
			$tree = $pt.to-tree( $source );
			is $pt.to-string( $tree ), $source, Q{no ws};

			$source = Q{sub foo( ) { }};
			$tree = $pt.to-tree( $source );
			is $pt.to-string( $tree ), $source, Q{intra-term ws};
		}, Q{empty};

		subtest {
			plan 2;

			$source = Q{sub foo(0){}};
			$tree = $pt.to-tree( $source );
			is $pt.to-string( $tree ), $source, Q{no ws};

			$source = Q:to[_END_];
sub foo( 0 ) { }
_END_
			$tree = $pt.to-tree( $source );
			is $pt.to-string( $tree ), $source, Q{ws};
		}, Q{constant};

		subtest {
			plan 2;

			$source = Q{sub foo($a){}};
			$tree = $pt.to-tree( $source );
			is $pt.to-string( $tree ), $source, Q{no ws};

			$source = Q:to[_END_];
sub foo( $a ) { }
_END_
			$tree = $pt.to-tree( $source );
			is $pt.to-string( $tree ), $source, Q{ws};
		}, Q{untyped};

		subtest {
			plan 5;

			subtest {
				plan 2;

				$source = Q{sub foo(Int$a){}};
				$tree = $pt.to-tree( $source );
				is $pt.to-string( $tree ), $source, Q{no ws};

				$source = Q:to[_END_];
sub foo( Int $a ) { }
_END_
				$tree = $pt.to-tree( $source );
				is $pt.to-string( $tree ), $source, Q{ws};
			}, Q{typed};

			subtest {
				plan 2;

				$source = Q{sub foo(Int$a=32){}};
				$tree = $pt.to-tree( $source );
				is $pt.to-string( $tree ), $source, Q{no ws};

				$source = Q:to[_END_];
sub foo( Int $a = 32 ) { }
_END_
				$tree = $pt.to-tree( $source );
				is $pt.to-string( $tree ), $source, Q{ws};
			}, Q{typed and declared};

			subtest {
				plan 2;

				$source = Q{sub foo(::T$a){}};
				$tree = $pt.to-tree( $source );
				is $pt.to-string( $tree ), $source, Q{no ws};

				$source = Q:to[_END_];
sub foo( ::T $a ) { }
_END_
				$tree = $pt.to-tree( $source );
				is $pt.to-string( $tree ), $source, Q{ws};
			}, Q{type-capture};

			subtest {
				plan 2;

				$source = Q{sub foo(Int){}};
				$tree = $pt.to-tree( $source );
				is $pt.to-string( $tree ), $source, Q{no ws};

				$source = Q:to[_END_];
sub foo( Int ) { }
_END_
				$tree = $pt.to-tree( $source );
				is $pt.to-string( $tree ), $source, Q{ws};
			}, Q{type-only};

			subtest {
				plan 2;

				$source = Q{sub foo(Int$a where 1){}};
				$tree = $pt.to-tree( $source );
				is $pt.to-string( $tree ), $source, Q{no ws};

				$source = Q:to[_END_];
sub foo( Int $a where 1 ) { }
_END_
				$tree = $pt.to-tree( $source );
				is $pt.to-string( $tree ), $source, Q{ws};
			}, Q{type-constrained};
		}, Q{typed};

		subtest {
			plan 2;

			$source = Q{sub foo($a=0){}};
			$tree = $pt.to-tree( $source );
			is $pt.to-string( $tree ), $source, Q{no ws};

			$source = Q:to[_END_];
sub foo( $a = 0 ) { }
_END_
			$tree = $pt.to-tree( $source );
			is $pt.to-string( $tree ), $source, Q{ws};
		}, Q{default};

		# XXX 'sub foo(:a) { }' illegal
	}, Q{single};

	subtest {
		plan 2;

		$source = Q{sub foo($a,$b){}};
		$tree = $pt.to-tree( $source );
		is $pt.to-string( $tree ), $source, Q{no ws};

		$source = Q:to[_END_];
sub foo( $a, $b ) { }
_END_
		$tree = $pt.to-tree( $source );
		is $pt.to-string( $tree ), $source, Q{ws};
	}, Q{multiple};
}, Q{scalar arguments};

subtest {
	plan 4;

	$source = Q{sub foo($a,Str$b,Str$c where"foo",Int$d=32){}};
	$tree = $pt.to-tree( $source );
	is $pt.to-string( $tree ), $source, Q{christmas tree, minimal spacing};

	$source = Q:to[_END_];
sub foo($a,Str$b,Str$c where"foo",Int$d=32){}
_END_
	$tree = $pt.to-tree( $source );
	is $pt.to-string( $tree ), $source, Q{christmas tree, minimal spacing};

	# Having differing whitespace on each side of an operator assures
	# that Perl6::WS objects aren't being reused, and the WS isn't
	# actually being copied from the wrong RE.
	#
	$source = Q:to[_END_];
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
	$tree = $pt.to-tree( $source );
	is $pt.to-string( $tree ), $source,
		Q{christmas tree, alternating spacing};

	$source = Q:to[_END_];
sub foo(  $a  ,  Str  $b  ,  Str  $c  where  "foo"  ,  Int  $d  =  32  )  {  }
_END_
	$tree = $pt.to-tree( $source );
	is $pt.to-string( $tree ), $source, Q{christmas tree, maximal spacing};
}, Q{christmas tree};

$source = Q:to[_END_];
sub foo ( ) { }
_END_
$tree = $pt.to-tree( $source );
is $pt.to-string( $tree ), $source, Q{separate function name and open paren};

# vim: ft=perl6
