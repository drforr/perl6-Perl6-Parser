use v6;

use Test;
use Perl6::Parser;

# We're just checking odds and ends here, so no need to rigorously check
# the object tree.

my $pt = Perl6::Parser.new;
my $*CONSISTENCY-CHECK = True;
my $*FALL-THROUGH = True;
my $source;

sub can-roundtrip( $pt, $source ) {
	$pt._roundtrip( $source ) eq $source
}

$source = Q:to[_END_];
say <closed open>;
_END_
ok can-roundtrip( $pt, $source ), Q{say <closed open>};

$source = Q:to[_END_];
my @quantities = flat (99 ... 1), 'No more', 99;
_END_
ok can-roundtrip( $pt, $source ), Q{flat (99 ... 1)};

$source = Q:to[_END_];
sub foo( $a is copy ) { }
_END_
ok can-roundtrip( $pt, $source ), Q{is copy};

$source = Q:to[_END_];
grammar Foo {
    token TOP { ^ <exp> $ { fail } }
}
_END_
ok can-roundtrip( $pt, $source ), Q{actions in grammars};

$source = Q:to[_END_];
grammar Foo {
    rule exp { <term>+ % <op> }
}
_END_
ok can-roundtrip( $pt, $source ), Q{mod in grammar};

$source = Q:to[_END_];
my @blocks;
@blocks.grep: { }
_END_
ok can-roundtrip( $pt, $source ), Q{grep: {}};

$source = Q:to[_END_];
my \y = 1;
_END_
ok can-roundtrip( $pt, $source ), Q{my \y};

$source = Q:to[_END_];
class Bitmap {
  method fill-pixel($i) { }
}
_END_
ok can-roundtrip( $pt, $source ), Q{method fill-pixel($i)};

$source = Q:to[_END_];
my %dir = (
   "\e[A" => 'up',
   "\e[B" => 'down',
   "\e[C" => 'left',
);
_END_
ok can-roundtrip( $pt, $source ),Q{quoted hash};

$source = Q:to[_END_];
grammar Exp24 { rule term { <exp> | <digits> } }
_END_
ok can-roundtrip( $pt, $source ), Q{alternation};

$source = Q:to[_END_];
say $[0];
_END_
ok can-roundtrip( $pt, $source ), Q{contextualized};

$source = Q:to[_END_];
my @solved = [1,2,3,4],[5,6,7,8],[9,10,11,12],[13,14,15,' '];
_END_
ok can-roundtrip( $pt, $source ), Q{list reference};

$source = Q:to[_END_];
role a_role {             # role to add a variable: foo,
   has $.foo is rw = 2;   # with an initial value of 2
}
_END_
ok can-roundtrip( $pt, $source ), Q{class attribute traits};

$source = Q:to[_END_];
constant expansions = 1;
 
expansions[1].[2]
_END_
ok can-roundtrip( $pt, $source ), Q{infix period};

$source = Q:to[_END_];
my @c;
rx/<@c>/;
_END_
ok can-roundtrip( $pt, $source ), Q{rx with bracketed array};

$source = Q:to[_END_];
for 99...1 -> $bottles { }

#| Prints a verse about a certain number of beers, possibly on a wall.
_END_
ok can-roundtrip( $pt, $source ), Q{range};

$source = Q:to[_END_];
sub sma(Int \P) returns Sub {
    sub ($x) {
    }
}
_END_
ok can-roundtrip( $pt, $source ), Q{return Sub type};

$source = Q:to[_END_];
sub sma(Int \P where * > 0) returns Sub { }
_END_
ok can-roundtrip( $pt, $source ), Q{subroutine with 'where' clause};

$source = Q:to[_END_];
/<[ d ]>*/
_END_
ok can-roundtrip( $pt, $source ), Q{regex modifier};

$source = Q:to[_END_];
my @a;
bag +« flat @a».comb: 1
_END_
ok can-roundtrip( $pt, $source ), Q{guillemot};

$source = Q:to[_END_];
my @x; @x.grep( +@($_) )
_END_
ok can-roundtrip( $pt, $source ), Q{dereference};

$source = Q:to[_END_];
roundrobin( 1 ; 2 );
_END_
ok can-roundtrip( $pt, $source ), Q{semicolon in function call};

$source = Q:to[_END_];
my @board;
@board[*;1] = 1,2;
_END_
ok can-roundtrip( $pt, $source ), Q{semicolon in array slice};

$source = Q:to[_END_];
    print qq:to/END/;
	Press direction arrows to move.
	Press q to quit. Press n for a new puzzle.
END
_END_
ok can-roundtrip( $pt, $source ), Q{here-doc with text after marker};

$source = Q:to[_END_];
my ($x,@x);
$x.push: @x[$x] += @x.shift;
_END_
ok can-roundtrip( $pt, $source ), Q{infix-increment};

$source = Q:to[_END_];
sub sing( Bool :$wall ) { }
_END_
ok can-roundtrip( $pt, $source ), Q{optional argument};

$source = Q:to[_END_];
sub sing( Int $a , Int $b , Bool :$wall, ) { }
_END_
ok can-roundtrip( $pt, $source ), Q{optional argument w/ trailing comma};

$source = Q:to[_END_];
my ($n,$k);
loop (my ($p, $f) = 2, 0; $f < $k && $p*$p <= $n; $p++) { }
_END_
ok can-roundtrip( $pt, $source ), Q{loop};

$source = Q:to[_END_];
my @a;
(sub ($w1, $w2, $w3, $w4){ })(|@a);
_END_
ok can-roundtrip( $pt, $source ), Q{break up args};

$source = Q:to[_END_];
("a".comb «~» "a".comb);
_END_
ok can-roundtrip( $pt, $source ), Q{meta-tilde};

$source = Q:to[_END_];
my $x; $x()
_END_
ok can-roundtrip( $pt, $source ), Q{postcircumfix method call};

$source = Q:to[_END_];
if 1 { } elsif 2 { } elsif 3 { }
_END_
ok can-roundtrip( $pt, $source ), Q{if-elsif};

$source = Q:to[_END_];
sub infix:<lf> ($a,$b) { }
_END_
ok can-roundtrip( $pt, $source ), Q{operation: bareword};

$source = Q:to[_END_];
do -> (:value(@pa)) { };
_END_
ok can-roundtrip( $pt, $source ), Q{param argument};

#`( Aha, found another potential lockup
$source = Q:to[_END_];
.put for slurp\
()
_END_
ok can-roundtrip( $pt, $source ), Q{trailing slash};
)

$source = Q:to[_END_];
my (@a,@b);
my %h = @a Z=> @b;
_END_
ok can-roundtrip( $pt, $source ), Q{zip-equal};

$source = Q:to[_END_];
do 0 => [], -> { 2 ... 1 } ... *
_END_
ok can-roundtrip( $pt, $source ), Q{multiple ...};

$source = Q:to[_END_];
open  "example.txt" , :r  or 1;
_END_
ok can-roundtrip( $pt, $source ), Q{postfix 'or'};

$source = Q:to[_END_];
sub ev (Str $s --> Num) { }
_END_
ok can-roundtrip( $pt, $source ), Q{implicit return type};

$source = Q:to[_END_];
grammar { token literal { ['.' \d+]? || '.' } }
_END_
ok can-roundtrip( $pt, $source ), Q{ordered alternation};

$source = Q:to[_END_];
repeat { } while 1;
_END_
ok can-roundtrip( $pt, $source ), Q{repeat block};

$source = Q:to[_END_];
$<bulls>
_END_
ok can-roundtrip( $pt, $source ), Q{postcircumfix operator};

$source = Q:to[_END_];
m:s/^ \d $/
_END_
ok can-roundtrip( $pt, $source ), Q{regex with adverb};

$source = Q:to[_END_];
my %hash{Any};
_END_
ok can-roundtrip( $pt, $source ), Q{shaped hash};

$source = Q:to[_END_];
my $s;
1 given [\+] '\\' «leg« $s.comb;
_END_
ok can-roundtrip( $pt, $source ), Q{hyper triangle};

#`(
$source = Q:to[_END_];
proto A { {*} }
_END_
ok can-roundtrip( $pt, $source ), Q{whateverable prototype};
)

$source = Q:to[_END_];
sub find-loop { %^mapping{*} }
_END_
ok can-roundtrip( $pt, $source ), Q{whateverable placeholder};

#`( Another potential lockup - Add '+1' on the next line to make it compile,
    yet it still locks the parser.
$source = Q:to[_END_];
2 for 1\ # foo
_END_
ok can-roundtrip( $pt, $source ), Q{Another backslash};
)

$source = Q:to[_END_];
sort()»<name>;
_END_
ok can-roundtrip( $pt, $source ), Q{guillemot again};

$source = Q:to[_END_];
sub binary_search (&p, Int $lo, Int $hi --> Int) {
}
_END_
ok can-roundtrip( $pt, $source ), Q{More comma-separated lists};

$source = Q:to[_END_];
class Bitmap {
    method pixel( $i, $j --> Int ) is rw { }
}
_END_
ok can-roundtrip( $pt, $source ), Q{Even more comma-separated lists};

$source = Q:to[_END_];
s:g/'[]'//
_END_
ok can-roundtrip( $pt, $source ), Q{substitution with adverb};

done-testing; # Because we're going to be adding tests quite often.

# vim: ft=perl6
