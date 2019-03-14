use v6;

use Test;
use Perl6::Parser;

use lib 't/lib/';
use Utils;

plan 4;

my $*CONSISTENCY-CHECK = True;
my $*FALL-THROUGH      = True;

# Scalar arguments
#
subtest {
  plan 5;

  subtest {
    plan 2;

    ok round-trips( Q{sub foo(){}} ), Q{no ws};

    ok round-trips( Q{sub foo( ) { }} ),
       Q{intra-term ws};
  }, Q{empty};

  subtest {
    plan 2;

    ok round-trips( Q{sub foo(0){}} ), Q{no ws};

    ok round-trips( Q:to[_END_] ), Q{ws};
    sub foo( 0 ) { }
    _END_
  }, Q{constant};

  subtest {
    plan 2;

    ok round-trips( Q{sub foo($a){}} ), Q{no ws};

    ok round-trips( Q:to[_END_] ), Q{ws};
    sub foo( $a ) { }
    _END_
  }, Q{untyped};

  subtest {
    plan 5;

    subtest {
      plan 2;

      ok round-trips( Q{sub foo(Int$a){}} ), Q{no ws};

      ok round-trips( Q:to[_END_] ), Q{ws};
      sub foo( Int $a ) { }
      _END_
    }, Q{typed};

    subtest {
      plan 2;

      ok round-trips( Q{sub foo(Int$a=32){}} ),
         Q{no ws};

      ok round-trips( Q:to[_END_] ), Q{ws};
      sub foo( Int $a = 32 ) { }
      _END_
    }, Q{typed and declared};

    subtest {
      plan 2;

      ok round-trips( Q{sub foo(::T$a){}} ), Q{no ws};

      ok round-trips( Q:to[_END_] ), Q{ws};
      sub foo( ::T $a ) { }
      _END_
    }, Q{type-capture};

    subtest {
      plan 2;

      ok round-trips( Q{sub foo(Int){}} ), Q{no ws};

      ok round-trips( Q:to[_END_] ), Q{no ws};
      sub foo( Int ) { }
      _END_
    }, Q{type-only};

    subtest {
      plan 2;

      ok round-trips( Q{sub foo(Int$a where 1){}} ),
         Q{no ws};

      ok round-trips( Q:to[_END_] ), Q{ws};
      sub foo( Int $a where 1 ) { }
      _END_
    }, Q{type-constrained};
  }, Q{typed};

  subtest {
    plan 2;

    ok round-trips( Q{sub foo($a=0){}} ), Q{no ws};

    ok round-trips( Q:to[_END_] ), Q{ws};
    sub foo( $a = 0 ) { }
    _END_
  }, Q{default};

  # XXX 'sub foo(:a) { }' illegal
}, Q{single};

subtest {
  plan 2;

  ok round-trips( Q{sub foo($a,$b){}} ), Q{no ws};

  ok round-trips( Q:to[_END_] ), Q{ws};
  sub foo( $a, $b ) { }
  _END_
}, Q{multiple};

subtest {
	plan 4;

	ok round-trips( Q{sub foo($a,Str$b,Str$c where"foo",Int$d=32){}} ),
	   Q{minimal spacing};

	ok round-trips( Q:to[_END_] ), Q{minimal spacing with newline};
	sub foo($a,Str$b,Str$c where"foo",Int$d=32){}
	_END_

	# Having differing whitespace on each side of an operator
	# assures that Perl6::WS objects aren't being reused, and the
	# WS isn't actually being copied from the wrong RE.
	#
	ok round-trips( Q:to[_END_] ), Q{alternating spacing};
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

	ok round-trips( Q:to[_END_] ), Q{maximal spacing};
	sub foo(  $a  ,  Str  $b  ,  Str  $c  where  "foo"  ,  Int  $d  =  32  )  {  }
	_END_
}, Q{christmas tree};

ok round-trips( Q:to[_END_] ), Q{separate function name and body};
sub foo ( ) { }
_END_

# vim: ft=perl6
