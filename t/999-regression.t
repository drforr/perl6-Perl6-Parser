use v6;

use Test;
use Perl6::Parser;

my $pt = Perl6::Parser.new;
my $*CONSISTENCY-CHECK = True;
my $*GRAMMAR-CHECK = True;
my $*FALL-THROUGH = True;

subtest {
	my $source = Q:to[_END_];
say <closed open>;
_END_
	my $tree = $pt.to-tree( $source );
	is $pt.to-string( $tree ), $source, Q{formatted};

	done-testing;
}, Q{say <closed open>};

my @quantities = flat (99 ... 1), 'No more', 99;

subtest {
	my $source = Q:to[_END_];
my @quantities = flat (99 ... 1), 'No more', 99;
_END_
	my $tree = $pt.to-tree( $source );
	is $pt.to-string( $tree ), $source, Q{formatted};

	done-testing;
}, Q{flat (99 ... 1)};

subtest {
	my $source = Q:to[_END_];
sub foo( $a is copy ) { }
_END_
	my $tree = $pt.to-tree( $source );
	is $pt.to-string( $tree ), $source, Q{formatted};

	done-testing;
}, Q{flat (99 ... 1)};

subtest {
	my $source = Q:to[_END_];
grammar Foo {
    token TOP { ^ <exp> $ { fail } }
}
_END_
	my $tree = $pt.to-tree( $source );
	is $pt.to-string( $tree ), $source, Q{formatted};

	done-testing;
}, Q{flat (99 ... 1)};

subtest {
	my $source = Q:to[_END_];
grammar Foo {
    rule exp { <term>+ % <op> }
}
_END_
	my $tree = $pt.to-tree( $source );
	is $pt.to-string( $tree ), $source, Q{formatted};

	done-testing;
}, Q{flat (99 ... 1)};

subtest {
	my $source = Q:to[_END_];
my @blocks;
@blocks.grep: { }
_END_
	my $tree = $pt.to-tree( $source );
	is $pt.to-string( $tree ), $source, Q{formatted};

	done-testing;
}, Q{grep: {}};

subtest {
	my $source = Q:to[_END_];
my \y = 1;
_END_
	my $tree = $pt.to-tree( $source );
	is $pt.to-string( $tree ), $source, Q{formatted};

	done-testing;
}, Q{my \y};

subtest {
	my $source = Q:to[_END_];
class Bitmap {
  method fill-pixel($i) { }
}
_END_
	my $tree = $pt.to-tree( $source );
	is $pt.to-string( $tree ), $source, Q{formatted};

	done-testing;
}, Q{method fill-pixel($i)};

subtest {
	my $source = Q:to[_END_];
my %dir = (
   "\e[A" => 'up',
   "\e[B" => 'down',
   "\e[C" => 'left',
);
_END_
	my $tree = $pt.to-tree( $source );
	is $pt.to-string( $tree ), $source, Q{formatted};

	done-testing;
}, Q{method fill-pixel($i)};

grammar Exp24 { rule term { <exp> | <digits> } }

subtest {
	my $source = Q:to[_END_];
grammar Exp24 { rule term { <exp> | <digits> } }
_END_
	my $tree = $pt.to-tree( $source );
	is $pt.to-string( $tree ), $source, Q{formatted};

	done-testing;
}, Q{alternation};

subtest {
	my $source = Q:to[_END_];
say $[0];
_END_
	my $tree = $pt.to-tree( $source );
	is $pt.to-string( $tree ), $source, Q{formatted};

	done-testing;
}, Q{contextualized};

subtest {
	my $source = Q:to[_END_];
my @solved = [1,2,3,4],[5,6,7,8],[9,10,11,12],[13,14,15,' '];
_END_
	my $tree = $pt.to-tree( $source );
	is $pt.to-string( $tree ), $source, Q{formatted};

	done-testing;
}, Q{list reference};

subtest {
	my $source = Q:to[_END_];
role a_role {             # role to add a variable: foo,
   has $.foo is rw = 2;   # with an initial value of 2
}
_END_
	my $tree = $pt.to-tree( $source );
	is $pt.to-string( $tree ), $source, Q{formatted};

	done-testing;
}, Q{class attribute traits};

subtest {
	my $source = Q:to[_END_];
constant expansions = 1;
 
expansions[1].[2]
_END_
	my $tree = $pt.to-tree( $source );
	is $pt.to-string( $tree ), $source, Q{formatted};

	done-testing;
}, Q{infix period};

subtest {
	my $source = Q:to[_END_];
my @c;
rx/<@c>/;
_END_
	my $tree = $pt.to-tree( $source );
	is $pt.to-string( $tree ), $source, Q{formatted};

	done-testing;
}, Q{rx with bracketed array};

subtest {
	my $source = Q:to[_END_];
for 99...1 -> $bottles { }

#| Prints a verse about a certain number of beers, possibly on a wall.
_END_
	my $tree = $pt.to-tree( $source );
	is $pt.to-string( $tree ), $source, Q{formatted};

	done-testing;
}, Q{rx with bracketed array};

subtest {
	my $source = Q:to[_END_];
sub sma(Int \P) returns Sub {
    sub ($x) {
    }
}
_END_
	my $tree = $pt.to-tree( $source );
	is $pt.to-string( $tree ), $source, Q{formatted};

	done-testing;
}, Q{rx with bracketed array};

subtest {
	my $source = Q:to[_END_];
sub sma(Int \P where * > 0) returns Sub { }
_END_
	my $tree = $pt.to-tree( $source );
	is $pt.to-string( $tree ), $source, Q{formatted};

	done-testing;
}, Q{subroutine with 'where' clause};

subtest {
	my $source = Q:to[_END_];
/<[ d ]>*/
_END_
	my $tree = $pt.to-tree( $source );
	is $pt.to-string( $tree ), $source, Q{formatted};

	done-testing;
}, Q{regex modifier};

subtest {
	my $source = Q:to[_END_];
my @a;
bag +« flat @a».comb: 1
_END_
	my $tree = $pt.to-tree( $source );
	is $pt.to-string( $tree ), $source, Q{formatted};

	done-testing;
}, Q{guillemot};

subtest {
	my $source = Q:to[_END_];
my @x; @x.grep( +@($_) )
_END_
	my $tree = $pt.to-tree( $source );
	is $pt.to-string( $tree ), $source, Q{formatted};

	done-testing;
}, Q{Dereference};

subtest {
	my $source = Q:to[_END_];
roundrobin( 1 ; 2 );
_END_
	my $tree = $pt.to-tree( $source );
	is $pt.to-string( $tree ), $source, Q{formatted};

	done-testing;
}, Q{semicolon in function call};

subtest {
	my $source = Q:to[_END_];
my @board;
@board[*;1] = 1,2;
_END_
	my $tree = $pt.to-tree( $source );
	is $pt.to-string( $tree ), $source, Q{formatted};

	done-testing;
}, Q{semicolon in array slice};

subtest {
	my $source = Q:to[_END_];
    print qq:to/END/;
	Press direction arrows to move.
	Press q to quit. Press n for a new puzzle.
END
_END_
	my $tree = $pt.to-tree( $source );
	is $pt.to-string( $tree ), $source, Q{formatted};

	done-testing;
}, Q{here-doc with text after marker};

subtest {
	my $source = Q:to[_END_];
my ($x,@x);
$x.push: @x[$x] += @x.shift;
_END_
	my $tree = $pt.to-tree( $source );
	is $pt.to-string( $tree ), $source, Q{formatted};

	done-testing;
}, Q{infix-increment};

subtest {
	my $source = Q:to[_END_];
sub sing( Bool :$wall ) { }
_END_
	my $tree = $pt.to-tree( $source );
	is $pt.to-string( $tree ), $source, Q{formatted};

	done-testing;
}, Q{optional argument};

subtest {
	my $source = Q:to[_END_];
sub sing( Int $a , Int $b , Bool :$wall, ) { }
_END_
	my $tree = $pt.to-tree( $source );
	is $pt.to-string( $tree ), $source, Q{formatted};

	done-testing;
}, Q{optional argument w/ trailing comma};

subtest {
	my $source = Q:to[_END_];
my ($n,$k);
loop (my ($p, $f) = 2, 0; $f < $k && $p*$p <= $n; $p++) { }
_END_
	my $tree = $pt.to-tree( $source );
	is $pt.to-string( $tree ), $source, Q{formatted};

	done-testing;
}, Q{loop};

subtest {
	my $source = Q:to[_END_];
my @a;
(sub ($w1, $w2, $w3, $w4){ })(|@a);
_END_
	my $tree = $pt.to-tree( $source );
	is $pt.to-string( $tree ), $source, Q{formatted};

	done-testing;
}, Q{loop};

subtest {
	my $source = Q:to[_END_];
("a".comb «~» "a".comb);
_END_
	my $tree = $pt.to-tree( $source );
	is $pt.to-string( $tree ), $source, Q{formatted};

	done-testing;
}, Q{meta-tilde};

subtest {
	my $source = Q:to[_END_];
my $x; $x()
_END_
	my $tree = $pt.to-tree( $source );
	is $pt.to-string( $tree ), $source, Q{formatted};

	done-testing;
}, Q{postcircumfix method call};

subtest {
	my $source = Q:to[_END_];
if 1 { } elsif 2 { } elsif 3 { }
_END_
	my $tree = $pt.to-tree( $source );
	is $pt.to-string( $tree ), $source, Q{formatted};

	done-testing;
}, Q{if-elsif};

subtest {
	my $source = Q:to[_END_];
sub infix:<lf> ($a,$b) { }
_END_
	my $tree = $pt.to-tree( $source );
	is $pt.to-string( $tree ), $source, Q{formatted};

	done-testing;
}, Q{operation bareword};

subtest {
	my $source = Q:to[_END_];
do -> (:value(@pa)) { };
_END_
	my $tree = $pt.to-tree( $source );
	is $pt.to-string( $tree ), $source, Q{formatted};

	done-testing;
}, Q{param argument};

subtest {
	my $source = Q:to[_END_];
.put for slurp\
_END_
	my $tree = $pt.to-tree( $source );
	is $pt.to-string( $tree ), $source, Q{formatted};

	done-testing;
}, Q{trailing slash};

subtest {
	my $source = Q:to[_END_];
my (@a,@b);
my %h = @a Z=> @b;
_END_
	my $tree = $pt.to-tree( $source );
	is $pt.to-string( $tree ), $source, Q{formatted};

	done-testing;
}, Q{zip-equal};

subtest {
	my $source = Q:to[_END_];
do 0 => [], -> { 2 ... 1 } ... *
_END_
	my $tree = $pt.to-tree( $source );
	is $pt.to-string( $tree ), $source, Q{formatted};

	done-testing;
}, Q{multiple ...};

subtest {
	my $source = Q:to[_END_];
open  "example.txt" , :r  or 1;
_END_
	my $tree = $pt.to-tree( $source );
	is $pt.to-string( $tree ), $source, Q{formatted};

	done-testing;
}, Q{postfix 'or'};

subtest {
	my $source = Q:to[_END_];
sub ev (Str $s --> Num) { }
_END_
	my $tree = $pt.to-tree( $source );
	is $pt.to-string( $tree ), $source, Q{formatted};

	done-testing;
}, Q{implicit return type};

subtest {
	my $source = Q:to[_END_];
grammar { token literal { ['.' \d+]? || '.' } }
_END_
	my $tree = $pt.to-tree( $source );
	is $pt.to-string( $tree ), $source, Q{formatted};

	done-testing;
}, Q{ordered alternation};

subtest {
	my $source = Q:to[_END_];
repeat { } while 1;
_END_
	my $tree = $pt.to-tree( $source );
	is $pt.to-string( $tree ), $source, Q{formatted};

	done-testing;
}, Q{repeat block};

subtest {
	my $source = Q:to[_END_];
$<bulls>
_END_
	my $tree = $pt.to-tree( $source );
	is $pt.to-string( $tree ), $source, Q{formatted};

	done-testing;
}, Q{postcircumfix operator};

subtest {
	my $source = Q:to[_END_];
m:s/^ \d $/
_END_
	my $tree = $pt.to-tree( $source );
	is $pt.to-string( $tree ), $source, Q{formatted};

	done-testing;
}, Q{regex with adverb};

subtest {
	my $source = Q:to[_END_];
my %hash{Any};
_END_
	my $tree = $pt.to-tree( $source );
	is $pt.to-string( $tree ), $source, Q{formatted};

	done-testing;
}, Q{shaped hash};

subtest {
	my $source = Q:to[_END_];
my $s;
1 given [\+] '\\' «leg« $s.comb;
_END_
	my $tree = $pt.to-tree( $source );
	is $pt.to-string( $tree ), $source, Q{formatted};

	done-testing;
}, Q{hyper triangle};

subtest {
	my $source = Q:to[_END_];
proto A { {*} }
_END_
	my $tree = $pt.to-tree( $source );
	is $pt.to-string( $tree ), $source, Q{formatted};

	done-testing;
}, Q{whateverable prototype};

subtest {
	my $source = Q:to[_END_];
sub find-loop { %^mapping{*} }
_END_
	my $tree = $pt.to-tree( $source );
	is $pt.to-string( $tree ), $source, Q{formatted};

	done-testing;
}, Q{whateverable placeholder};

subtest {
	my $source = Q:to[_END_];
2 for 1\ # foo
_END_
	my $tree = $pt.to-tree( $source );
	is $pt.to-string( $tree ), $source, Q{formatted};

	done-testing;
}, Q{Another backslash};

subtest {
	my $source = Q:to[_END_];
sort()»<name>;
_END_
	my $tree = $pt.to-tree( $source );
	is $pt.to-string( $tree ), $source, Q{formatted};

	done-testing;
}, Q{Another backslash};

subtest {
	my $source = Q:to[_END_];
sub binary_search (&p, Int $lo, Int $hi --> Int) {
}
_END_
	my $p = $pt.parse( $source );
	my $tree = $pt.build-tree( $p );
	is $pt.to-string( $tree ), $source, Q{formatted};

	done-testing;
}, Q{More comma-separated lists};

subtest {
	my $source = Q:to[_END_];
class Bitmap {
    method pixel( $i, $j --> Int ) is rw { }
}
_END_
	my $tree = $pt.to-tree( $source );
	is $pt.to-string( $tree ), $source, Q{formatted};

	done-testing;
}, Q{More comma-separated lists};

done-testing; # Because we're going to be adding tests quite often.

# vim: ft=perl6
