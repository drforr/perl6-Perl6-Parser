use v6;

use Test;
use Perl6::Parser;

use lib 't/lib';
use Utils; # Get gensym-package

# We're just checking odds and ends here, so no need to rigorously check
# the object tree.

my $pp                 = Perl6::Parser.new;
my $*CONSISTENCY-CHECK = True;
my $*FALL-THROUGH      = True;
my $source;

sub can-roundtrip( $pp, $source ) {
	$pp._roundtrip( $source ) eq $source
}

for ( True, False ) -> $*PURE-PERL {
	$source = Q:to[_END_];
	say <closed open>;
	_END_
	ok can-roundtrip( $pp, $source ), Q{say <closed open>};

	$source = Q:to[_END_];
	my @quantities = flat (99 ... 1), 'No more', 99;
	_END_
	ok can-roundtrip( $pp, $source ), Q{flat (99 ... 1)};

	$source = Q:to[_END_];
	sub foo( $a is copy ) { }
	_END_
	ok can-roundtrip( $pp, $source ), Q{is copy};

	$source = gensym-package Q:to[_END_];
	grammar %s {
	    token TOP { ^ <exp> $ { fail } }
	}
	_END_
	ok can-roundtrip( $pp, $source ), Q{actions in grammars};

	# Despite how it looks, '%%' here isn't doubled-percent.
	# The sprintf() format rewrites %% to %.
	#
	$source = gensym-package Q:to[_END_];
	grammar %s {
	    rule exp { <term>+ %% <op> }
	}
	_END_
	ok can-roundtrip( $pp, $source ), Q{mod in grammar};

	$source = Q:to[_END_];
	my @blocks;
	@blocks.grep: { }
	_END_
	ok can-roundtrip( $pp, $source ), Q{grep: {}};

	$source = Q:to[_END_];
	my \y = 1;
	_END_
	ok can-roundtrip( $pp, $source ), Q{my \y};

	$source = gensym-package Q:to[_END_];
	class %s {
	  method fill-pixel($i) { }
	}
	_END_
	ok can-roundtrip( $pp, $source ), Q{method fill-pixel($i)};

	$source = Q:to[_END_];
	my %dir = (
	   "\e[A" => 'up',
	   "\e[B" => 'down',
	   "\e[C" => 'left',
	);
	_END_
	ok can-roundtrip( $pp, $source ),Q{quoted hash};

	$source = gensym-package Q:to[_END_];
	grammar %s { rule term { <exp> | <digits> } }
	_END_
	ok can-roundtrip( $pp, $source ), Q{alternation};

	$source = Q:to[_END_];
	say $[0];
	_END_
	ok can-roundtrip( $pp, $source ), Q{contextualized};

	$source = Q:to[_END_];
	my @solved = [1,2,3,4],[5,6,7,8],[9,10,11,12],[13,14,15,' '];
	_END_
	ok can-roundtrip( $pp, $source ), Q{list reference};

	$source = Q:to[_END_];
	role a_role {             # role to add a variable: foo,
	   has $.foo is rw = 2;   # with an initial value of 2
	}
	_END_
	ok can-roundtrip( $pp, $source ), Q{class attribute traits};

	$source = Q:to[_END_];
	constant expansions = 1;
	 
	expansions[1].[2]
	_END_
	ok can-roundtrip( $pp, $source ), Q{infix period};

	$source = Q:to[_END_];
	my @c;
	rx/<@c>/;
	_END_
	ok can-roundtrip( $pp, $source ), Q{rx with bracketed array};

	$source = Q:to[_END_];
	for 99...1 -> $bottles { }

	#| Prints a verse about a certain number of beers, possibly on a wall.
	_END_
	ok can-roundtrip( $pp, $source ), Q{range};

	$source = Q:to[_END_];
	sub sma(Int \P) returns Sub {
	    sub ($x) {
	    }
	}
	_END_
	ok can-roundtrip( $pp, $source ), Q{return Sub type};

	$source = Q:to[_END_];
	sub sma(Int \P where * > 0) returns Sub { }
	_END_
	ok can-roundtrip( $pp, $source ), Q{subroutine with 'where' clause};

	$source = Q:to[_END_];
	/<[ d ]>*/
	_END_
	ok can-roundtrip( $pp, $source ), Q{regex modifier};

	$source = Q:to[_END_];
	my @a;
	bag +« flat @a».comb: 1
	_END_
	ok can-roundtrip( $pp, $source ), Q{guillemot};

	$source = Q:to[_END_];
	my @x; @x.grep( +@($_) )
	_END_
	ok can-roundtrip( $pp, $source ), Q{dereference};

	$source = Q:to[_END_];
	roundrobin( 1 ; 2 );
	_END_
	ok can-roundtrip( $pp, $source ), Q{semicolon in function call};

	$source = Q:to[_END_];
	my @board;
	@board[*;1] = 1,2;
	_END_
	ok can-roundtrip( $pp, $source ), Q{semicolon in array slice};

	$source = Q:to[_END_];
	    print qq:to/END/;
		Press direction arrows to move.
		Press q to quit. Press n for a new puzzle.
	END
	_END_
	ok can-roundtrip( $pp, $source ), Q{here-doc with text after marker};

	$source = Q:to[_END_];
	my ($x,@x);
	$x.push: @x[$x] += @x.shift;
	_END_
	ok can-roundtrip( $pp, $source ), Q{infix-increment};

	$source = Q:to[_END_];
	sub sing( Bool :$wall ) { }
	_END_
	ok can-roundtrip( $pp, $source ), Q{optional argument};

	$source = Q:to[_END_];
	sub sing( Int $a , Int $b , Bool :$wall, ) { }
	_END_
	ok can-roundtrip( $pp, $source ), Q{optional argument w/ trailing comma};

	$source = Q:to[_END_];
	my ($n,$k);
	loop (my ($p, $f) = 2, 0; $f < $k && $p*$p <= $n; $p++) { }
	_END_
	ok can-roundtrip( $pp, $source ), Q{loop};

	$source = Q:to[_END_];
	my @a;
	(sub ($w1, $w2, $w3, $w4){ })(|@a);
	_END_
	ok can-roundtrip( $pp, $source ), Q{break up args};

	$source = Q:to[_END_];
	("a".comb «~» "a".comb);
	_END_
	ok can-roundtrip( $pp, $source ), Q{meta-tilde};

	$source = Q:to[_END_];
	my $x; $x()
	_END_
	ok can-roundtrip( $pp, $source ), Q{postcircumfix method call};

	$source = Q:to[_END_];
	if 1 { } elsif 2 { } elsif 3 { }
	_END_
	ok can-roundtrip( $pp, $source ), Q{if-elsif};

	$source = Q:to[_END_];
	sub infix:<lf> ($a,$b) { }
	_END_
	ok can-roundtrip( $pp, $source ), Q{operation: bareword};

	$source = Q:to[_END_];
	do -> (:value(@pa)) { };
	_END_
	ok can-roundtrip( $pp, $source ), Q{param argument};

	#`( Aha, found another potential lockup
	$source = Q:to[_END_];
	.put for slurp\
	()
	_END_
	ok can-roundtrip( $pp, $source ), Q{trailing slash};
	)

	$source = Q:to[_END_];
	my (@a,@b);
	my %h = @a Z=> @b;
	_END_
	ok can-roundtrip( $pp, $source ), Q{zip-equal};

	$source = Q:to[_END_];
	do 0 => [], -> { 2 ... 1 } ... *
	_END_
	ok can-roundtrip( $pp, $source ), Q{multiple ...};

	$source = Q:to[_END_];
	open  "example.txt" , :r  or 1;
	_END_
	ok can-roundtrip( $pp, $source ), Q{postfix 'or'};

	$source = Q:to[_END_];
	sub ev (Str $s --> Num) { }
	_END_
	ok can-roundtrip( $pp, $source ), Q{implicit return type};

	$source = Q:to[_END_];
	grammar { token literal { ['.' \d+]? || '.' } }
	_END_
	ok can-roundtrip( $pp, $source ), Q{ordered alternation};

	$source = Q:to[_END_];
	repeat { } while 1;
	_END_
	ok can-roundtrip( $pp, $source ), Q{repeat block};

	$source = Q:to[_END_];
	$<bulls>
	_END_
	ok can-roundtrip( $pp, $source ), Q{postcircumfix operator};

	$source = Q:to[_END_];
	m:s/^ \d $/
	_END_
	ok can-roundtrip( $pp, $source ), Q{regex with adverb};

	$source = Q:to[_END_];
	my %hash{Any};
	_END_
	ok can-roundtrip( $pp, $source ), Q{shaped hash};

	$source = Q:to[_END_];
	my $s;
	1 given [\+] '\\' «leg« $s.comb;
	_END_
	ok can-roundtrip( $pp, $source ), Q{hyper triangle};

	#`( Type check fails on the interior
	$source = Q:to[_END_];
	proto A { {*} }
	_END_
	ok can-roundtrip( $pp, $source ), Q{whateverable prototype};
	)

	$source = Q:to[_END_];
	sub find-loop { %^mapping{*} }
	_END_
	ok can-roundtrip( $pp, $source ), Q{whateverable placeholder};

	#`( Another potential lockup - Add '+1' on the next line to make it compile,
	    yet it still locks the parser.
	$source = Q:to[_END_];
	2 for 1\ # foo
	_END_
	ok can-roundtrip( $pp, $source ), Q{Another backslash};
	)

	$source = Q:to[_END_];
	sort()»<name>;
	_END_
	ok can-roundtrip( $pp, $source ), Q{guillemot again};

	$source = Q:to[_END_];
	sub binary_search (&p, Int $lo, Int $hi --> Int) {
	}
	_END_
	ok can-roundtrip( $pp, $source ), Q{More comma-separated lists};

	$source = gensym-package Q:to[_END_];
	class %s {
	    method pixel( $i, $j --> Int ) is rw { }
	}
	_END_
	ok can-roundtrip( $pp, $source ), Q{Even more comma-separated lists};

	$source = Q:to[_END_];
	s:g/'[]'//
	_END_
	ok can-roundtrip( $pp, $source ), Q{substitution with adverb};
}

done-testing; # Because we're going to be adding tests quite often.

# vim: ft=perl6
