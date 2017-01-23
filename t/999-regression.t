use v6;

use Test;
use Perl6::Parser;

my $pt = Perl6::Parser.new;
my $*VALIDATION-FAILURE-FATAL = True;
my $*FACTORY-FAILURE-FATAL = True;
my $*DEBUG = True;

subtest {
	plan 2;

	my $source = Q:to[_END_];
say <closed open>;
_END_
	my $p = $pt.parse( $source );
	my $tree = $pt.build-tree( $p );
#say $pt.dump-tree($tree);
	ok $pt.validate( $p ), Q{valid};
	is $pt.to-string( $tree ), $source, Q{formatted};
}, Q{say <closed open>};

my @quantities = flat (99 ... 1), 'No more', 99;

subtest {
	plan 2;

	my $source = Q:to[_END_];
my @quantities = flat (99 ... 1), 'No more', 99;
_END_
	my $p = $pt.parse( $source );
	my $tree = $pt.build-tree( $p );
#say $pt.dump-tree($tree);
	ok $pt.validate( $p ), Q{valid};
	is $pt.to-string( $tree ), $source, Q{formatted};
}, Q{flat (99 ... 1)};

subtest {
	plan 2;

	my $source = Q:to[_END_];
sub foo( $a is copy ) { }
_END_
	my $p = $pt.parse( $source );
	my $tree = $pt.build-tree( $p );
#say $pt.dump-tree($tree);
	ok $pt.validate( $p ), Q{valid};
	is $pt.to-string( $tree ), $source, Q{formatted};
}, Q{flat (99 ... 1)};

subtest {
	plan 2;

	my $source = Q:to[_END_];
grammar Foo {
    token TOP { ^ <exp> $ { fail } }
}
_END_
	my $p = $pt.parse( $source );
	my $tree = $pt.build-tree( $p );
#say $pt.dump-tree($tree);
	ok $pt.validate( $p ), Q{valid};
	is $pt.to-string( $tree ), $source, Q{formatted};
}, Q{flat (99 ... 1)};

subtest {
	plan 2;

	my $source = Q:to[_END_];
grammar Foo {
    rule exp { <term>+ % <op> }
}
_END_
	my $p = $pt.parse( $source );
	my $tree = $pt.build-tree( $p );
#say $pt.dump-tree($tree);
	ok $pt.validate( $p ), Q{valid};
	is $pt.to-string( $tree ), $source, Q{formatted};
}, Q{flat (99 ... 1)};

subtest {
	plan 2;

	my $source = Q:to[_END_];
my @blocks;
@blocks.grep: { }
_END_
	my $p = $pt.parse( $source );
	my $tree = $pt.build-tree( $p );
#say $pt.dump-tree($tree);
	ok $pt.validate( $p ), Q{valid};
	is $pt.to-string( $tree ), $source, Q{formatted};
}, Q{grep: {}};

subtest {
	plan 2;

	my $source = Q:to[_END_];
my \y = 1;
_END_
	my $p = $pt.parse( $source );
	my $tree = $pt.build-tree( $p );
#say $pt.dump-tree($tree);
	ok $pt.validate( $p ), Q{valid};
	is $pt.to-string( $tree ), $source, Q{formatted};
}, Q{my \y};

subtest {
	plan 2;

	my $source = Q:to[_END_];
class Bitmap {
  method fill-pixel($i) { }
}
_END_
	my $p = $pt.parse( $source );
	my $tree = $pt.build-tree( $p );
	ok $pt.validate( $p ), Q{valid};
	is $pt.to-string( $tree ), $source, Q{formatted};
}, Q{method fill-pixel($i)};

subtest {
	plan 2;

	my $source = Q:to[_END_];
my %dir = (
   "\e[A" => 'up',
   "\e[B" => 'down',
   "\e[C" => 'left',
);
_END_
	my $p = $pt.parse( $source );
	my $tree = $pt.build-tree( $p );
	ok $pt.validate( $p ), Q{valid};
	is $pt.to-string( $tree ), $source, Q{formatted};
}, Q{method fill-pixel($i)};

grammar Exp24 { rule term { <exp> | <digits> } }

subtest {
	plan 2;

	my $source = Q:to[_END_];
grammar Exp24 { rule term { <exp> | <digits> } }
_END_
	my $p = $pt.parse( $source );
	my $tree = $pt.build-tree( $p );
	ok $pt.validate( $p ), Q{valid};
	is $pt.to-string( $tree ), $source, Q{formatted};
}, Q{alternation};

subtest {
	plan 2;

	my $source = Q:to[_END_];
say $[0];
_END_
	my $p = $pt.parse( $source );
	my $tree = $pt.build-tree( $p );
	ok $pt.validate( $p ), Q{valid};
	is $pt.to-string( $tree ), $source, Q{formatted};
}, Q{contextualized};

subtest {
	plan 2;

	my $source = Q:to[_END_];
my @solved = [1,2,3,4],[5,6,7,8],[9,10,11,12],[13,14,15,' '];
_END_
	my $p = $pt.parse( $source );
	my $tree = $pt.build-tree( $p );
	ok $pt.validate( $p ), Q{valid};
	is $pt.to-string( $tree ), $source, Q{formatted};
}, Q{list reference};

subtest {
	plan 2;

	my $source = Q:to[_END_];
role a_role {             # role to add a variable: foo,
   has $.foo is rw = 2;   # with an initial value of 2
}
_END_
	my $p = $pt.parse( $source );
	my $tree = $pt.build-tree( $p );
	ok $pt.validate( $p ), Q{valid};
	is $pt.to-string( $tree ), $source, Q{formatted};
}, Q{class attribute traits};

subtest {
	plan 2;

	my $source = Q:to[_END_];
constant expansions = 1;
 
expansions[1].[2]
_END_
	my $p = $pt.parse( $source );
	my $tree = $pt.build-tree( $p );
	ok $pt.validate( $p ), Q{valid};
	is $pt.to-string( $tree ), $source, Q{formatted};
}, Q{infix period};

subtest {
	plan 2;

	my $source = Q:to[_END_];
my @c;
rx/<@c>/;
_END_
	my $p = $pt.parse( $source );
	my $tree = $pt.build-tree( $p );
	ok $pt.validate( $p ), Q{valid};
	is $pt.to-string( $tree ), $source, Q{formatted};
}, Q{rx with bracketed array};

subtest {
	plan 2;

	my $source = Q:to[_END_];
for 99...1 -> $bottles { }

#| Prints a verse about a certain number of beers, possibly on a wall.
_END_
	my $p = $pt.parse( $source );
	my $tree = $pt.build-tree( $p );
	ok $pt.validate( $p ), Q{valid};
	is $pt.to-string( $tree ), $source, Q{formatted};
}, Q{rx with bracketed array};

sub sma(Int \P where * > 0) returns Sub {
    sub ($x) {
    }
}

subtest {
	plan 2;

	my $source = Q:to[_END_];
sub sma(Int \P) returns Sub {
    sub ($x) {
    }
}
_END_
	my $p = $pt.parse( $source );
	my $tree = $pt.build-tree( $p );
	ok $pt.validate( $p ), Q{valid};
	is $pt.to-string( $tree ), $source, Q{formatted};
}, Q{rx with bracketed array};

subtest {
	plan 2;

	my $source = Q:to[_END_];
sub sma(Int \P where * > 0) returns Sub { }
_END_
	my $p = $pt.parse( $source );
	my $tree = $pt.build-tree( $p );
	ok $pt.validate( $p ), Q{valid};
	is $pt.to-string( $tree ), $source, Q{formatted};
}, Q{subroutine with 'where' clause};

subtest {
	plan 2;

	my $source = Q:to[_END_];
/<[ d ]>*/
_END_
	my $p = $pt.parse( $source );
	my $tree = $pt.build-tree( $p );
	ok $pt.validate( $p ), Q{valid};
	is $pt.to-string( $tree ), $source, Q{formatted};
}, Q{regex modifier};

subtest {
	plan 2;

	my $source = Q:to[_END_];
my @a;
bag +« flat @a».comb: 1
_END_
	my $p = $pt.parse( $source );
	my $tree = $pt.build-tree( $p );
	ok $pt.validate( $p ), Q{valid};
	is $pt.to-string( $tree ), $source, Q{formatted};
}, Q{guillemot};

subtest {
	plan 2;

	my $source = Q:to[_END_];
my @x; @x.grep( +@($_) )
_END_
	my $p = $pt.parse( $source );
	my $tree = $pt.build-tree( $p );
	ok $pt.validate( $p ), Q{valid};
	is $pt.to-string( $tree ), $source, Q{formatted};
}, Q{Dereference};

subtest {
	plan 2;

	my $source = Q:to[_END_];
roundrobin( 1 ; 2 );
_END_
	my $p = $pt.parse( $source );
	my $tree = $pt.build-tree( $p );
	ok $pt.validate( $p ), Q{valid};
	is $pt.to-string( $tree ), $source, Q{formatted};
}, Q{semicolon in function call};

subtest {
	plan 2;

	my $source = Q:to[_END_];
my @board;
@board[*;1] = 1,2;
_END_
	my $p = $pt.parse( $source );
	my $tree = $pt.build-tree( $p );
	ok $pt.validate( $p ), Q{valid};
	is $pt.to-string( $tree ), $source, Q{formatted};
}, Q{semicolon in array slice};

subtest {
	plan 2;

	my $source = Q:to[_END_];
    print qq:to/END/;
	Press direction arrows to move.
	Press q to quit. Press n for a new puzzle.
END
_END_
	my $p = $pt.parse( $source );
	my $tree = $pt.build-tree( $p );
	ok $pt.validate( $p ), Q{valid};
	is $pt.to-string( $tree ), $source, Q{formatted};
}, Q{here-doc with text after marker};

subtest {
	plan 2;

	my $source = Q:to[_END_];
my ($x,@x);
$x.push: @x[$x] += @x.shift;
_END_
	my $p = $pt.parse( $source );
	my $tree = $pt.build-tree( $p );
	ok $pt.validate( $p ), Q{valid};
	is $pt.to-string( $tree ), $source, Q{formatted};
}, Q{infix-increment};

subtest {
	plan 2;

	my $source = Q:to[_END_];
sub sing( Bool :$wall ) { }
_END_
	my $p = $pt.parse( $source );
	my $tree = $pt.build-tree( $p );
	ok $pt.validate( $p ), Q{valid};
	is $pt.to-string( $tree ), $source, Q{formatted};
}, Q{optional argument};

subtest {
	plan 2;

	my $source = Q:to[_END_];
sub sing( Int $a , Int $b , Bool :$wall, ) { }
_END_
	my $p = $pt.parse( $source );
	my $tree = $pt.build-tree( $p );
	ok $pt.validate( $p ), Q{valid};
	is $pt.to-string( $tree ), $source, Q{formatted};
}, Q{optional argument w/ trailing comma};

subtest {
	plan 2;

	my $source = Q:to[_END_];
my ($n,$k);
loop (my ($p, $f) = 2, 0; $f < $k && $p*$p <= $n; $p++) { }
_END_
	my $p = $pt.parse( $source );
	my $tree = $pt.build-tree( $p );
	ok $pt.validate( $p ), Q{valid};
	is $pt.to-string( $tree ), $source, Q{formatted};
}, Q{loop};

subtest {
	plan 2;

	my $source = Q:to[_END_];
my @a;
(sub ($w1, $w2, $w3, $w4){ })(|@a);
_END_
	my $p = $pt.parse( $source );
	my $tree = $pt.build-tree( $p );
	ok $pt.validate( $p ), Q{valid};
	is $pt.to-string( $tree ), $source, Q{formatted};
}, Q{loop};

subtest {
	plan 2;

	my $source = Q:to[_END_];
("a".comb «~» "a".comb);
_END_
	my $p = $pt.parse( $source );
	my $tree = $pt.build-tree( $p );
	ok $pt.validate( $p ), Q{valid};
	is $pt.to-string( $tree ), $source, Q{formatted};
}, Q{meta-tilde};

subtest {
	plan 2;

	my $source = Q:to[_END_];
my $x; $x()
_END_
	my $p = $pt.parse( $source );
	my $tree = $pt.build-tree( $p );
	ok $pt.validate( $p ), Q{valid};
	is $pt.to-string( $tree ), $source, Q{formatted};
}, Q{postcircumfix method call};

subtest {
	plan 2;

	my $source = Q:to[_END_];
if 1 { } elsif 2 { } elsif 3 { }
_END_
	my $p = $pt.parse( $source );
	my $tree = $pt.build-tree( $p );
	ok $pt.validate( $p ), Q{valid};
	is $pt.to-string( $tree ), $source, Q{formatted};
}, Q{if-elsif};

subtest {
	plan 2;

	my $source = Q:to[_END_];
sub infix:<lf> ($a,$b) { }
_END_
	my $p = $pt.parse( $source );
	my $tree = $pt.build-tree( $p );
	ok $pt.validate( $p ), Q{valid};
	is $pt.to-string( $tree ), $source, Q{formatted};
}, Q{operation bareword};

subtest {
	plan 2;

	my $source = Q:to[_END_];
do -> (:value(@pa)) { };
_END_
	my $p = $pt.parse( $source );
	my $tree = $pt.build-tree( $p );
	ok $pt.validate( $p ), Q{valid};
	is $pt.to-string( $tree ), $source, Q{formatted};
}, Q{param argument};

subtest {
	plan 2;

	my $source = Q:to[_END_];
.put for slurp\
_END_
	my $p = $pt.parse( $source );
	my $tree = $pt.build-tree( $p );
	ok $pt.validate( $p ), Q{valid};
	is $pt.to-string( $tree ), $source, Q{formatted};
}, Q{trailing slash};

subtest {
	plan 2;

	my $source = Q:to[_END_];
my (@a,@b);
my %h = @a Z=> @b;
_END_
	my $p = $pt.parse( $source );
	my $tree = $pt.build-tree( $p );
	ok $pt.validate( $p ), Q{valid};
	is $pt.to-string( $tree ), $source, Q{formatted};
}, Q{zip-equal};

done-testing;

# vim: ft=perl6
