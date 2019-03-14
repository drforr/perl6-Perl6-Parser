use v6;

use Test;
use Perl6::Parser;

use lib 't/lib';
use Utils;

my $*CONSISTENCY-CHECK = True;
my $*FALL-THROUGH      = True;

# No plan here.

# We're just checking odds and ends here, so no need to rigorously check
# the object tree.

ok round-trips( Q:to[_END_] ), Q{say <closed open>};
say <closed open>;
_END_

ok round-trips( Q:to[_END_] ), Q{flat (99 ... 1)};
my @quantities = flat (99 ... 1), 'No more', 99;
_END_

ok round-trips( Q:to[_END_] ), Q{is copy};
sub foo( $a is copy ) { }
_END_

ok round-trips( gensym-package Q:to[_END_] ), Q{actions in grammars};
grammar %s {
    token TOP { ^ <exp> $ { fail } }
}
_END_

# Despite how it looks, '%%' here isn't doubled-percent.
# The sprintf() format rewrites %% to %.
#
ok round-trips( gensym-package Q:to[_END_] ), Q{mod in grammar};
grammar %s {
    rule exp { <term>+ %% <op> }
}
_END_

ok round-trips( Q:to[_END_] ), Q{grep: { }};
my @blocks;
@blocks.grep: { }
_END_

ok round-trips( Q:to[_END_] ), Q{my \y};
my \y = 1;
_END_

ok round-trips( gensym-package Q:to[_END_] ), Q{method fill-pixel($i)};
class %s {
  method fill-pixel($i) { }
}
_END_

ok round-trips( Q:to[_END_] ), Q{quoted hash};
my %dir = (
   "\e[A" => 'up',
   "\e[B" => 'down',
   "\e[C" => 'left',
);
_END_

ok round-trips( gensym-package Q:to[_END_] ), Q{alternation};
grammar %s { rule term { <exp> | <digits> } }
_END_

ok round-trips( Q:to[_END_] ), Q{contextualized};
say $[0];
_END_

ok round-trips( Q:to[_END_] ), Q{list reference};
my @solved = [1,2,3,4],[5,6,7,8],[9,10,11,12],[13,14,15,' '];
_END_

ok round-trips( Q:to[_END_] ), Q{class attribute traits};
role a_role {             # role to add a variable: foo,
   has $.foo is rw = 2;   # with an initial value of 2
}
_END_

ok round-trips( Q:to[_END_] ), Q{infix period};
constant expansions = 1;
 
expansions[1].[2]
_END_

ok round-trips( Q:to[_END_] ), Q{rx with bracketed array};
my @c;
rx/<@c>/;
_END_

ok round-trips( Q:to[_END_] ), Q{range};
for 99...1 -> $bottles { }

#| Prints a verse about a certain number of beers, possibly on a wall.
_END_

ok round-trips( Q:to[_END_] ), Q{return Sub type};
sub sma(Int \P) returns Sub {
    sub ($x) {
    }
}
_END_

ok round-trips( Q:to[_END_] ), Q{subroutine with 'where' clause};
sub sma(Int \P where * > 0) returns Sub { }
_END_

ok round-trips( Q:to[_END_] ), Q{regex modifier};
/<[ d ]>*/
_END_

ok round-trips( Q:to[_END_] ), Q{guillemot};
my @a;
bag +« flat @a».comb: 1
_END_

ok round-trips( Q:to[_END_] ), Q{dereference};
my @x; @x.grep( +@($_) )
_END_

ok round-trips( Q:to[_END_] ), Q{semicolon in function call};
roundrobin( 1 ; 2 );
_END_

ok round-trips( Q:to[_END_] ), Q{semicolon in array slice};
my @board;
@board[*;1] = 1,2;
_END_

ok round-trips( Q:to[_END_] ), Q{here-doc with text after marker};
    print qq:to/END/;
	Press direction arrows to move.
	Press q to quit. Press n for a new puzzle.
END
_END_

ok round-trips( Q:to[_END_] ), Q{infix-increment};
my ($x,@x);
$x.push: @x[$x] += @x.shift;
_END_

ok round-trips( Q:to[_END_] ), Q{optional arguments};
sub sing( Bool :$wall ) { }
_END_

ok round-trips( Q:to[_END_] ), Q{optional argument w/ trailing comma};
sub sing( Int $a , Int $b , Bool :$wall, ) { }
_END_

ok round-trips( Q:to[_END_] ), Q{loop};
my ($n,$k);
loop (my ($p, $f) = 2, 0; $f < $k && $p*$p <= $n; $p++) { }
_END_

ok round-trips( Q:to[_END_] ), Q{break up args};
my @a;
(sub ($w1, $w2, $w3, $w4){ })(|@a);
_END_

ok round-trips( Q:to[_END_] ), Q{meta-tilde};
("a".comb «~» "a".comb);
_END_

ok round-trips( Q:to[_END_] ), Q{postcircumfix method call};
my $x; $x()
_END_

ok round-trips( Q:to[_END_] ), Q{if-elsif};
if 1 { } elsif 2 { } elsif 3 { }
_END_

ok round-trips( Q:to[_END_] ), Q{operation: bareword};
sub infix:<lf> ($a,$b) { }
_END_

ok round-trips( Q:to[_END_] ), Q{param argument};
do -> (:value(@pa)) { };
_END_

#`( Aha, found another potential lockup
ok round-trips( Q:to[_END_] ), Q{trailing slash};
.put for slurp\
()
_END_
)

ok round-trips( Q:to[_END_] ), Q{zip-equal};
my (@a,@b);
my %h = @a Z=> @b;
_END_

ok round-trips( Q:to[_END_] ), Q{multiple ...};
do 0 => [], -> { 2 ... 1 } ... *
_END_

ok round-trips( Q:to[_END_] ), Q{posfix 'or'};
open  "example.txt" , :r  or 1;
_END_

ok round-trips( Q:to[_END_] ), Q{implicit return type};
sub ev (Str $s --> Num) { }
_END_

ok round-trips( Q:to[_END_] ), Q{ordered alternation};
grammar { token literal { ['.' \d+]? || '.' } }
_END_

ok round-trips( Q:to[_END_] ), Q{repeat block};
repeat { } while 1;
_END_

ok round-trips( Q:to[_END_] ), Q{postcircumfix operator};
$<bulls>
_END_

ok round-trips( Q:to[_END_] ), Q{regex with adverb};
m:s/^ \d $/
_END_

ok round-trips( Q:to[_END_] ), Q{shaped hash};
my %hash{Any};
_END_

ok round-trips( Q:to[_END_] ), Q{hyper triangle};
my $s;
1 given [\+] '\\' «leg« $s.comb;
_END_

#`( Type check fails on the interior
ok round-trips( Q:to[_END_] ), Q{whateverable prototype};
proto A { {*} }
_END_
)

ok round-trips( Q:to[_END_] ), Q{whateverable placeholder};
sub find-loop { %^mapping{*} }
_END_

#`( Another potential lockup - Add '+1' on the next line to make it compile,
    yet it still locks the parser.
ok round-trips( Q:to[_END_] ), Q{Another backslash};
2 for 1\ # foo
_END_
)

ok round-trips( Q:to[_END_] ), Q{guillemot again};
sort()»<name>;
_END_

ok round-trips( Q:to[_END_] ), Q{More comma-separated lists};
sub binary_search (&p, Int $lo, Int $hi --> Int) {
}
_END_

ok round-trips( gensym-package Q:to[_END_] ), Q{Even more comma-separated lists};
class %s {
    method pixel( $i, $j --> Int ) is rw { }
}
_END_

ok round-trips( Q:to[_END_] ), Q{substitution with adverb};
s:g/'[]'//
_END_

done-testing;

# vim: ft=perl6
