use v6;

use Test;
use Perl6::Tidy;

plan 17;

my $pt = Perl6::Tidy.new;

subtest {
	subtest {
		plan 1;

		my $parsed = $pt.tidy( Q:to[END] );
my @doors = False xx 101;
 
(.=not for @doors[0, $_ ... 100]) for 1..100;
 
say "Door $_ is ", <closed open>[ @doors[$_] ] for 1..100;
END
		isa-ok $parsed, 'Perl6::Tidy::Root';
	}, Q[version 1];

	subtest {
		plan 1;

		my $parsed = $pt.tidy( Q:to[END] );
say "Door $_ is open" for map {$^n ** 2}, 1..10;
END
		isa-ok $parsed, 'Perl6::Tidy::Root';
	}, Q[version 2];
	

	subtest {
		plan 1;

		my $parsed = $pt.tidy( Q:to[END] );
say "Door $_ is open" for 1..10 X** 2;
END
		isa-ok $parsed, 'Perl6::Tidy::Root';
	}, Q[version 3];

	subtest {
		plan 1;

		my $parsed = $pt.tidy( Q:to[END] );
say "Door $_ is ", <closed open>[.sqrt == .sqrt.floor] for 1..100;
END
		isa-ok $parsed, 'Perl6::Tidy::Root';
	}, Q[version 4];
}, '100 doors';

#my $*TRACE = 1;
subtest {
	plan 1;

	subtest {
		plan 1;

# The parser also recursively parses use'd classes, so since Term::termios might
# not be present on all systems, stub it out.
		my $parsed = $pt.tidy( Q:to[_END_] );
class Term::termios { has $fd; method getattr {}; method unset_lflags { }; method unset_iflags { }; method setattr { } }
#use Term::termios;

constant $saved   = Term::termios.new(fd => 1).getattr;
constant $termios = Term::termios.new(fd => 1).getattr;
# raw mode interferes with carriage returns, so
# set flags needed to emulate it manually
$termios.unset_iflags(<BRKINT ICRNL ISTRIP IXON>);
$termios.unset_lflags(< ECHO ICANON IEXTEN ISIG>);
$termios.setattr(:DRAIN);

# reset terminal to original setting on exit
END { $saved.setattr(:NOW) }
 
constant n    = 4; # board size
constant cell = 6; # cell width
 
constant $top = join '─' x cell, '┌', '┬' xx n-1, '┐';
constant $mid = join '─' x cell, '├', '┼' xx n-1, '┤';
constant $bot = join '─' x cell, '└', '┴' xx n-1, '┘';
 
my %dir = (
   "\e[A" => 'up',
   "\e[B" => 'down',
   "\e[C" => 'right',
   "\e[D" => 'left',
);

my @solved = [1,2,3,4],[5,6,7,8],[9,10,11,12],[13,14,15,' '];
my @board;
new();
 
sub new () {
    loop {
        @board = shuffle();
        last if parity-ok(@board);
    }
}
 
sub shuffle () {
    my @c = [1,2,3,4],[5,6,7,8],[9,10,11,12],[13,14,15,' '];
    for (^16).pick(*) -> $y, $x {
        my ($yd, $ym, $xd, $xm) = ($y div n, $y mod n, $x div n, $x mod n);
        my $temp    = @c[$ym;$yd];
        @c[$ym;$yd] = @c[$xm;$xd];
        @c[$xm;$xd] = $temp;
    }
    @c;
}

sub parity-ok (@b) {
    so (sum @b».grep(/' '/,:k).grep(/\d/, :kv)) %% 2;
}

sub row (@row) { '│' ~ (join '│', @row».&center) ~ '│' }

sub center ($s){
    my $c   = cell - $s.chars;
    my $pad = ' ' x ceiling($c/2);
    sprintf "%{cell}s", "$s$pad";
}

sub draw-board {
    run('clear');
    print qq:to/END/;
 
 
	Press direction arrows to move.
 
	Press q to quit. Press n for a new puzzle.
 
	$top
	{ join "\n\t$mid\n\t", map { .&row }, @board }
	$bot
 
	{ (so @board ~~ @solved) ?? 'Solved!!' !! '' }
END
}

sub slide (@c is copy) {
    my $t = (grep { /' '/ }, :k, @c)[0];
    return @c unless $t and $t > 0;
    @c[$t,$t-1] = @c[$t-1,$t];
    @c;
}

multi sub move('up') {
    map { @board[*;$_] = reverse slide reverse @board[*;$_] }, ^n;
}
 
multi sub move('down') {
    map { @board[*;$_] = slide @board[*;$_] }, ^n;
}
 
multi sub move('left') {
    map { @board[$_] = reverse slide reverse @board[$_] }, ^n;
}
 
multi sub move('right') {
    map { @board[$_] = slide @board[$_] }, ^n;
}
 
loop {
    draw-board;
 
    # Read up to 4 bytes from keyboard buffer.
    # Page navigation keys are 3-4 bytes each.
    # Specifically, arrow keys are 3.
    my $key = $*IN.read(4).decode;
 
    move %dir{$key} if so %dir{$key};
    last if $key eq 'q'; # (q)uit
    new() if $key eq 'n';
}
_END_

		isa-ok $parsed, 'Perl6::Tidy::Root';
	}, Q[version 1];
}, '15 Puzzle';

subtest {
	subtest {
		plan 1;

		my $parsed = $pt.tidy( Q:to[_END_] );
class Term::termios { has $fd; method getattr {}; method unset_lflags { }; method unset_iflags { }; method setattr { } }
#use Term::termios;
 
constant $saved   = Term::termios.new(fd => 1).getattr;
constant $termios = Term::termios.new(fd => 1).getattr;
# raw mode interferes with carriage returns, so
# set flags needed to emulate it manually
$termios.unset_iflags(<BRKINT ICRNL ISTRIP IXON>);
$termios.unset_lflags(< ECHO ICANON IEXTEN ISIG>);
$termios.setattr(:DRAIN);
 
# reset terminal to original setting on exit
END { $saved.setattr(:NOW) }
 
constant n    = 4; # board size
constant cell = 6; # cell width
constant ansi = True; # color!
 
my @board = ( ['' xx n] xx n );
my $save  = '';
my $score = 0;
 
constant $top = join '─' x cell, '┌', '┬' xx n-1, '┐';
constant $mid = join '─' x cell, '├', '┼' xx n-1, '┤';
constant $bot = join '─' x cell, '└', '┴' xx n-1, '┘';
 
my %dir = (
   "\e[A" => 'up',
   "\e[B" => 'down',
   "\e[C" => 'right',
   "\e[D" => 'left',
);
 
my @ANSI = <0 1;97 1;93 1;92 1;96 1;91 1;95 1;94 1;30;47 1;43
    1;42 1;46 1;41 1;45 1;44 1;33;43 1;33;42 1;33;41 1;33;44>;
 
sub row (@row) { '│' ~ (join '│', @row».&center) ~ '│' }
 
sub center ($s){
    my $c   = cell - $s.chars;
    my $pad = ' ' x ceiling($c/2);
    my $tile = sprintf "%{cell}s", "$s$pad";
    my $idx = $s ?? $s.log(2) !! 0;
    ansi ?? "\e[{@ANSI[$idx]}m$tile\e[0m" !! $tile;
}
 
sub draw-board {
    run('clear');
    print qq:to/END/;


	Press direction arrows to move.

	Press q to quit.

	$top
	{ join "\n\t$mid\n\t", map { .&row }, @board }
	$bot

	Score: $score

END
}
 
sub squash (@c) {
    my @t = grep { .chars }, @c;
    map { combine(@t[$_], @t[$_+1]) if @t[$_] && @t[$_+1] == @t[$_] }, ^@t-1;
    @t = grep { .chars }, @t;
    @t.push: '' while @t < n;
    @t;
}

sub combine ($v is rw, $w is rw) { $v += $w; $w = ''; $score += $v; }

multi sub move('up') {
    map { @board[*;$_] = squash @board[*;$_] }, ^n;
}
 
multi sub move('down') {
    map { @board[*;$_] = reverse squash reverse @board[*;$_] }, ^n;
}
 
multi sub move('left') {
    map { @board[$_] = squash @board[$_] }, ^n;
}
 
multi sub move('right') {
    map { @board[$_] = reverse squash reverse @board[$_] }, ^n;
}
 
sub another {
    my @empties;
    for @board.kv -> $r, @row {
        @empties.push(($r, $_)) for @row.grep(:k, '');
    }
    my ( $x, $y ) = @empties.roll;
    @board[$x; $y] = (flat 2 xx 9, 4).roll;
}
 
sub save () { join '|', flat @board».list }
 
loop {
    another if $save ne save();
    draw-board;
    $save = save();

    # Read up to 4 bytes from keyboard buffer.
    # Page navigation keys are 3-4 bytes each.
    # Specifically, arrow keys are 3.
    my $key = $*IN.read(4).decode;

    move %dir{$key} if so %dir{$key};
    last if $key eq 'q'; # (q)uit
}
_END_
		isa-ok $parsed, 'Perl6::Tidy::Root';
	}, Q[version 1];
}, '2048';

subtest {
	subtest {
		plan 1;

		my $parsed = $pt.tidy( Q:to[_END_] );
use MONKEY-SEE-NO-EVAL;
 
say "Here are your digits: ", 
constant @digits = (1..9).roll(4)».Str;

grammar Exp24 {
    token TOP { ^ <exp> $ { fail unless EVAL($/) == 24 } }
    rule exp { <term>+ % <op> }
    rule term { '(' <exp> ')' | <@digits> }
    token op { < + - * / > }
}

while my $exp = prompt "\n24? " {
###    if try Exp24.parse: $exp {
        say "You win :)";
        last;
###    } else {
        say (
            'Sorry.  Try again.' xx 20,
            'Try harder.' xx 5,
            'Nope.  Not even close.' xx 2,
            'Are you five or something?',
            'Come on, you can do better than that.'
        ).flat.pick
###    }
}
_END_
		isa-ok $parsed, 'Perl6::Tidy::Root';
	}, Q[version 1];
}, '24 game';

subtest {
	plan 1;

	subtest {
		plan 1;

		my $parsed = $pt.tidy( Q:to[_END_] );
use MONKEY-SEE-NO-EVAL;

my @digits;
my $amount = 4;

# Get $amount digits from the user,
# ask for more if they don't supply enough
while @digits.elems < $amount {
    @digits.append: (prompt "Enter {$amount - @digits} digits from 1 to 9, "
    ~ '(repeats allowed): ').comb(/<[1..9]>/);
}
# Throw away any extras
@digits = @digits[^$amount];

# Generate combinations of operators
my @ops = [X,] <+ - * /> xx 3;

# Enough sprintf formats to cover most precedence orderings
my @formats = (
    '%d %s %d %s %d %s %d',
    '(%d %s %d) %s %d %s %d',
    '(%d %s %d %s %d) %s %d',
    '((%d %s %d) %s %d) %s %d',
    '(%d %s %d) %s (%d %s %d)',
    '%d %s (%d %s %d %s %d)',
    '%d %s (%d %s (%d %s %d))',
);

# Brute force test the different permutations
for unique @digits.permutations -> @p {
    for @ops -> @o {
        for @formats -> $format {
            my $string = sprintf $format, flat roundrobin(|@p; |@o);
            my $result = EVAL($string);
            say "$string = 24" and last if $result and $result == 24;
        }
    }
}

# Only return unique sub-arrays
sub unique (@array) {
    my %h = map { $_.Str => $_ }, @array;
    %h.values;
}
_END_
		isa-ok $parsed, 'Perl6::Tidy::Root';
	}, Q[version 1];
}, '24 game/Solve';

subtest {
	plan 1;

	subtest {
		plan 1;

		my $parsed = $pt.tidy( Q:to[_END_] );
###my @todo = $[1];
my @sums = 0;
sub nextrow($n) {
###    for +@todo .. $n -> $l {
###        @sums[$l] = 0;
###        print $l,"\r" if $l < $n;
        my $r = [];
###        for reverse ^$l -> $x {
###            my @x := @todo[$x];
###            if @x {
###                $r.push: @sums[$x] += @x.shift;
###            }
###            else {
###                $r.push: @sums[$x];
###            }
###        }
###        @todo.push($r);
###    }
###    @todo[$n];
}

say "rows:";
say .fmt('%2d'), ": ", nextrow($_)[] for 1..10;


say "\nsums:";
for 23, 123, 1234, 10000 {
    say $_, "\t", [+] nextrow($_)[];
}
_END_
		isa-ok $parsed, 'Perl6::Tidy::Root';
	}, Q[version 1];
}, '9 billion names of God';

subtest {
	plan 3;

	subtest {
		plan 1;

		my $parsed = $pt.tidy( Q:to[_END_] );
my $b = 99;

###repeat while --$b {
###    say "{b $b} on the wall";
###    say "{b $b}";
    say "Take one down, pass it around";
###    say "{b $b-1} on the wall";
    say "";
###}

sub b($b) {
    "$b bottle{'s' if $b != 1} of beer";
}
_END_
		isa-ok $parsed, 'Perl6::Tidy::Root';
	}, Q[version 1];

	subtest {
		plan 1;

		my $parsed = $pt.tidy( Q:to[_END_] );
for 99...1 -> $bottles {
    sing $bottles, :wall;
    sing $bottles;
    say  "Take one down, pass it around";
    sing $bottles - 1, :wall;
    say  "";
}

#| Prints a verse about a certain number of beers, possibly on a wall.
sub sing(
    Int $number, #= Number of bottles of beer.
    Bool :$wall, #= Mention that the beers are on a wall?
) {
    my $quantity = $number == 0 ?? "No more"      !! $number;
    my $plural   = $number == 1 ?? ""             !! "s";
    my $location = $wall        ?? " on the wall" !! "";
    say "$quantity bottle$plural of beer$location"
}
_END_
		isa-ok $parsed, 'Perl6::Tidy::Root';
	}, Q[version 2];

	subtest {
		plan 1;

		my $parsed = $pt.tidy( Q:to[_END_] );
my @quantities = flat (99 ... 1), 'No more', 99;
my @bottles = flat 'bottles' xx 98, 'bottle', 'bottles' xx 2;
my @actions = flat 'Take one down, pass it around' xx 99,
              'Go to the store, buy some more';

for @quantities Z @bottles Z @actions Z
    @quantities[1 .. *] Z @bottles[1 .. *]
    -> ($a, $b, $c, $d, $e) {
    say "$a $b of beer on the wall";
    say "$a $b of beer";
    say $c;
    say "$d $e of beer on the wall\n";
}
_END_
		isa-ok $parsed, 'Perl6::Tidy::Root';
	}, Q[version 3];
}, '99 bottles of beeer';

subtest {
	plan 3;

	subtest {
		plan 1;

		my $parsed = $pt.tidy( Q:to[_END_] );
get.words.sum.say;
_END_
		isa-ok $parsed, 'Perl6::Tidy::Root';
	}, Q[version 1];

	subtest {
		plan 1;

		my $parsed = $pt.tidy( Q:to[_END_] );
say [+] get.words;
_END_
		isa-ok $parsed, 'Perl6::Tidy::Root';
	}, Q[version 2];

	subtest {
		plan 1;

		my $parsed = $pt.tidy( Q:to[_END_] );
my ($a, $b) = $*IN.get.split(" ");
say $a + $b;
_END_
		isa-ok $parsed, 'Perl6::Tidy::Root';
	}, Q[version 3];
}, 'A + B';

subtest {
	plan 1;

	subtest {
		plan 1;

		my $parsed = $pt.tidy( Q:to[_END_] );
multi can-spell-word(Str $word, @blocks) {
    my @regex = @blocks.map({ my @c = .comb; rx/<@c>/ }).grep: { .ACCEPTS($word.uc) }
    can-spell-word $word.uc.comb.list, @regex;
}

multi can-spell-word([$head,*@tail], @regex) {
    for @regex -> $re {
###        if $head ~~ $re {
            return True unless @tail;
            return False if @regex == 1;
            return True if can-spell-word @tail, list @regex.grep: * !=== $re;
###        }
    }
    False;
}

my @b = <BO XK DQ CP NA GT RE TG QD FS JW HU VI AN OB ER FS LY PC ZM>;

for <A BaRK BOoK tREaT COmMOn SqUAD CoNfuSE> {
    say "$_     &can-spell-word($_, @b)";
}
_END_
		isa-ok $parsed, 'Perl6::Tidy::Root';
	}, Q[version 1];
}, 'ABC Problem';

subtest {
	plan 1;

	subtest {
		plan 1;

		my $parsed = $pt.tidy( Q:to[_END_] );
use v6;

role A {
    # must be filled in by the class it is composed into
    method abstract() { ... };

    # can be overridden in the class, but that's not mandatory
    method concrete() { say '# 42' };
}

class SomeClass does A {
    method abstract() {
        say "# made concrete in class"
    }
}

my $obj = SomeClass.new;
$obj.abstract();
$obj.concrete();
_END_
		isa-ok $parsed, 'Perl6::Tidy::Root';
	}, Q[version 1];
}, 'Abstract Class';

subtest {
	plan 1;

	subtest {
		plan 1;

		my $parsed = $pt.tidy( Q:to[_END_] );
sub propdivsum (\x) {
    [+] flat(x > 1, gather for 2 .. x.sqrt.floor -> \d {
        my \y = x div d;
        if y * d == x { take d; take y unless y == d }
    })
}

say bag map { propdivsum($_) <=> $_ }, 1..20000
_END_
		isa-ok $parsed, 'Perl6::Tidy::Root';
	}, Q[version 1];
}, 'Abundant, Deficient and Perfect numbers';

subtest {
	plan 1;

	subtest {
		plan 1;

		my $parsed = $pt.tidy( Q:to[_END_] );
sub accum ($n is copy) { sub { $n += $^x } }
_END_
		isa-ok $parsed, 'Perl6::Tidy::Root';
	}, Q[version 1];
}, 'Accumulator factory';

subtest {
	plan 3;

	subtest {
		plan 1;

		my $parsed = $pt.tidy( Q:to[_END_] );
sub A(Int $m, Int $n) {
###    if    $m == 0 { $n + 1 } 
###    elsif $n == 0 { A($m - 1, 1) }
###    else          { A($m - 1, A($m, $n - 1)) }
}
_END_
		isa-ok $parsed, 'Perl6::Tidy::Root';
	}, Q[version 1];

	subtest {
		plan 1;

		my $parsed = $pt.tidy( Q:to[_END_] );
multi sub A(0,      Int $n) { $n + 1                   }
multi sub A(Int $m, 0     ) { A($m - 1, 1)             }
multi sub A(Int $m, Int $n) { A($m - 1, A($m, $n - 1)) }
_END_
		isa-ok $parsed, 'Perl6::Tidy::Root';
	}, Q[version 2];

	subtest {
		plan 1;

		my $parsed = $pt.tidy( Q:to[_END_] );
proto A(Int \𝑚, Int \𝑛) { (state @)[𝑚][𝑛] //= {*} }

multi A(0,      Int \𝑛) { 𝑛 + 1 }
multi A(1,      Int \𝑛) { 𝑛 + 2 }
multi A(2,      Int \𝑛) { 3 + 2 * 𝑛 }
multi A(3,      Int \𝑛) { 5 + 8 * (2 ** 𝑛 - 1) }

multi A(Int \𝑚, 0     ) { A(𝑚 - 1, 1) }
multi A(Int \𝑚, Int \𝑛) { A(𝑚 - 1, A(𝑚, 𝑛 - 1)) }

say A(4,1);
say .chars, " digits starting with ", .substr(0,50), "..." given A(4,2);
_END_
		isa-ok $parsed, 'Perl6::Tidy::Root';
	}, Q[version 4];
}, 'Ackermann Function';

subtest {
	plan 3;

	subtest {
		plan 1;

		my $parsed = $pt.tidy( Q:to[_END_] );
class Bar { }             # an empty class
 
my $object = Bar.new;     # new instance
 
role a_role {             # role to add a variable: foo,
   has $.foo is rw = 2;   # with an initial value of 2
}
 
$object does a_role;      # compose in the role
 
say $object.foo;          # prints: 2
$object.foo = 5;          # change the variable
say $object.foo;          # prints: 5
 
my $ohno = Bar.new;       # new Bar object
#say $ohno.foo;           # runtime error, base Bar class doesn't have the variable foo
 
my $this = $object.new;   # instantiate a new Bar derived from $object
say $this.foo;            # prints: 2 - original role value
 
my $that = $object.clone; # instantiate a new Bar derived from $object copying any variables
say $that.foo;            # 5 - value from the cloned object
_END_
		isa-ok $parsed, 'Perl6::Tidy::Root';
	}, Q[version 1];

	subtest {
		plan 1;

		my $parsed = $pt.tidy( Q:to[_END_] );
my $lue = 42 but role { has $.answer = "Life, the Universe, and Everything" }
 
say $lue;          # 42
say $lue.answer;   # Life, the Universe, and Everything
_END_
		isa-ok $parsed, 'Perl6::Tidy::Root';
	}, Q[version 2];

	subtest {
		plan 1;

		my $parsed = $pt.tidy( Q:to[_END_] );
use MONKEY-TYPING;
augment class Int {
    method answer { "Life, the Universe, and Everything" }
}
say 42.answer;     # Life, the Universe, and Everything
_END_
		isa-ok $parsed, 'Perl6::Tidy::Root';
	}, Q[version 3];
}, 'Add a variable to a class at runtime';

subtest {
	plan 1;

	subtest {
		plan 1;

		my $parsed = $pt.tidy( Q:to[_END_] );
my $x;
say $x.WHERE;
 
my $y := $x;   # alias
say $y.WHERE;  # same address as $x
 
say "Same variable" if $y =:= $x;
$x = 42;
say $y;  # 42
_END_
		isa-ok $parsed, 'Perl6::Tidy::Root';
	}, Q[version 1];
}, 'Address of a variable';

subtest {
	plan 1;

	subtest {
		plan 1;

		my $parsed = $pt.tidy( Q:to[_END_] );
constant expansions = [1], [1,-1], -> @prior { [|@prior,0 Z- 0,|@prior] } ... *;
 
sub polyprime($p where 2..*) { so expansions[$p].[1 ..^ */2].all %% $p }

say ' p: (x-1)ᵖ';
say '-----------';
 
sub super ($n) {
    $n.trans: '0123456789'
           => '⁰¹²³⁴⁵⁶⁷⁸⁹';
}
 
for ^13 -> $d {
    say $d.fmt('%2i: '), (
        expansions[$d].kv.map: -> $i, $n {
            my $p = $d - $i;
            [~] gather {
                take < + - >[$n < 0] ~ ' ' unless $p == $d;
                take $n.abs                unless $p == $d > 0;
                take 'x'                   if $p > 0;
                take super $p - $i         if $p > 1;
            }
        }
    )
}
_END_
		isa-ok $parsed, 'Perl6::Tidy::Root';
	}, Q[version 2];
}, 'AKS test for primality';

subtest {
	plan 3;

	subtest {
		plan 1;

		my $parsed = $pt.tidy( Q:to[_END_] );
###to be called with perl6 columnaligner.pl <orientation>(left, center , right )
###with left as default
my $fh = open  "example.txt" , :r  or die "Can't read text file!\n" ;
my @filelines = $fh.lines ;
close $fh ;
my @maxcolwidths ; #array of the longest words per column
#########fill the array with values#####################
for @filelines -> $line {
   my @words = $line.split( "\$" ) ;
   for 0..@words.elems - 1 -> $i {
###      if @maxcolwidths[ $i ] {
###	 if @words[ $i ].chars > @maxcolwidths[$i] {
	    @maxcolwidths[ $i ] = @words[ $i ].chars ;
###	 }
###      }
###      else {
	 @maxcolwidths.push( @words[ $i ].chars ) ;
###      }
   }
}
my $justification = @*ARGS[ 0 ] || "left" ;
##print lines , $gap holds the number of spaces, 1 to be added 
##to allow for space preceding or following longest word
for @filelines -> $line {
   my @words = $line.split( "\$" ) ;
   for 0 ..^ @words -> $i {
      my $gap =  @maxcolwidths[$i] - @words[$i].chars + 1 ;
###      if $justification eq "left" {
	 print @words[ $i ] ~ " " x $gap ;
###      } elsif $justification eq "right" {
	 print  " " x $gap ~ @words[$i] ;
###      } elsif $justification eq "center" {
	 $gap = ( @maxcolwidths[ $i ] + 2 - @words[$i].chars ) div 2 ;
	 print " " x $gap ~ @words[$i] ~ " " x $gap ;
###      }
   }
   say ''; #for the newline
}
_END_
		isa-ok $parsed, 'Perl6::Tidy::Root';
	}, Q[version 1];

	subtest {
		plan 1;

		my $parsed = $pt.tidy( Q:to[_END_] );
my @lines = slurp("example.txt").lines;
my @widths;

for @lines { for .split('$').kv { @widths[$^key] max= $^word.chars; } }
for @lines { say |.split('$').kv.map: { (align @widths[$^key], $^word) ~ " "; } }

sub align($column_width, $word, $aligment = @*ARGS[0]) {
        my $lr = $column_width - $word.chars;
        my $c  = $lr / 2;
        given ($aligment) {
                when "center" { " " x $c.ceiling ~ $word ~ " " x $c.floor }
                when "right"  { " " x $lr        ~ $word                  }
                default       {                    $word ~ " " x $lr      }
        }
}
_END_
		isa-ok $parsed, 'Perl6::Tidy::Root';
	}, Q[version 2];

	subtest {
		plan 1;

		my $parsed = $pt.tidy( Q:to[_END_] );
sub MAIN ($alignment where 'left'|'right', $file) {
    my @lines := $file.IO.lines.map(*.split: '$').List;
    my @widths = roundrobin(|@lines).map(*».chars.max);
    my $align  = {left=>'-', right=>''}{$alignment};
    my $format = @widths.map({ "%{++$}\${$align}{$_}s" }).join(" ") ~ "\n";
    printf $format, |$_ for @lines;
}
_END_
		isa-ok $parsed, 'Perl6::Tidy::Root';
	}, Q[version 3];
}, 'Align columns';

# vim: ft=perl6
