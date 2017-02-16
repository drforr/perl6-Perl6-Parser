use v6;

use Test;
use Perl6::Parser;

plan 7;

my $pt = Perl6::Parser.new;
my $*CONSISTENCY-CHECK = True;
my $*GRAMMAR-CHECK = True;

subtest {
	subtest {
		my $source = Q:to[_END_];
my @doors = False xx 101;
 
(.=not for @doors[0, $_ ... 100]) for 1..100;
 
say "Door $_ is ", <closed open>[ @doors[$_] ] for 1..100;
_END_
		my $p = $pt.parse( $source );
		my $tree = $pt.build-tree( $p );
		is $pt.to-string( $tree ), $source, Q{formatted};

		done-testing;
	}, Q{version 1};

	subtest {
		my $source = Q:to[_END_];
say "Door $_ is open" for map {$^n ** 2}, 1..10;
_END_
		my $p = $pt.parse( $source );
		my $tree = $pt.build-tree( $p );
#say $pt.dump-tree( $tree );
		is $pt.to-string( $tree ), $source, Q{formatted};

		done-testing;
	}, Q{version 2};

	subtest {
		my $source = Q:to[_END_];
say "Door $_ is open" for 1..10 X** 2;
_END_
		my $p = $pt.parse( $source );
		my $tree = $pt.build-tree( $p );
		is $pt.to-string( $tree ), $source, Q{formatted};

		done-testing;
	}, Q{version 3};

	subtest {
		my $source = Q:to[_END_];
say "Door $_ is ", <closed open>[.sqrt == .sqrt.floor] for 1..100;
_END_
		my $p = $pt.parse( $source );
		my $tree = $pt.build-tree( $p );
		is $pt.to-string( $tree ), $source, Q{formatted};

		done-testing;
	}, Q{version 4};

	done-testing;
}, Q{100 doors};

subtest {
# The parser also recursively parses use'd classes, so since Term::termios might
# not be present on all systems, stub it out.
	my $source = Q:to[_END_];
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
	my $p = $pt.parse( $source );
	my $tree = $pt.build-tree( $p );
	is $pt.to-string( $tree ), $source, Q{formatted};

	done-testing;
}, Q{15 Puzzle};

subtest {
	my $source = Q:to[_END_];
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
	my $p = $pt.parse( $source );
	my $tree = $pt.build-tree( $p );
	is $pt.to-string( $tree ), $source, Q{formatted};

	done-testing;
}, Q{2048};

subtest {
	my $source = Q:to[_END_];
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
    if try Exp24.parse: $exp {
        say "You win :)";
        last;
    } else {
        say (
            'Sorry.  Try again.' xx 20,
            'Try harder.' xx 5,
            'Nope.  Not even close.' xx 2,
            'Are you five or something?',
            'Come on, you can do better than that.'
        ).flat.pick
    }
}
_END_
	my $p = $pt.parse( $source );
	my $tree = $pt.build-tree( $p );
	is $pt.to-string( $tree ), $source, Q{formatted};

	done-testing;
}, Q{24 game};

subtest {
	my $source = Q:to[_END_];
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
	my $p = $pt.parse( $source );
	my $tree = $pt.build-tree( $p );
	is $pt.to-string( $tree ), $source, Q{formatted};

	done-testing;
}, Q{24 game/Solve};

subtest {
	my $source = Q:to[_END_];
my @todo = $[1];
my @sums = 0;
sub nextrow($n) {
    for +@todo .. $n -> $l {
        @sums[$l] = 0;
        print $l,"\r" if $l < $n;
        my $r = [];
        for reverse ^$l -> $x {
            my @x := @todo[$x];
            if @x {
                $r.push: @sums[$x] += @x.shift;
            }
            else {
                $r.push: @sums[$x];
            }
        }
        @todo.push($r);
    }
    @todo[$n];
}

say "rows:";
say .fmt('%2d'), ": ", nextrow($_)[] for 1..10;


say "\nsums:";
for 23, 123, 1234, 10000 {
    say $_, "\t", [+] nextrow($_)[];
}
_END_
	my $p = $pt.parse( $source );
	my $tree = $pt.build-tree( $p );
	is $pt.to-string( $tree ), $source, Q{formatted};

	done-testing;
}, Q{9 billion names of God};

subtest {
	subtest {
		my $source = Q:to[_END_];
my $b = 99;

repeat while --$b {
    say "{b $b} on the wall";
    say "{b $b}";
    say "Take one down, pass it around";
    say "{b $b-1} on the wall";
    say "";
}

sub b($b) {
    "$b bottle{'s' if $b != 1} of beer";
}
_END_
		my $p = $pt.parse( $source );
		my $tree = $pt.build-tree( $p );
		is $pt.to-string( $tree ), $source, Q{formatted};

	done-testing;
	}, Q{version 1};

	subtest {
		my $source = Q:to[_END_];
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
		my $p = $pt.parse( $source );
		my $tree = $pt.build-tree( $p );
		is $pt.to-string( $tree ), $source, Q{formatted};

		done-testing;
	}, Q{version 2};

	subtest {
		my $source = Q:to[_END_];
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
		my $p = $pt.parse( $source );
		my $tree = $pt.build-tree( $p );
		is $pt.to-string( $tree ), $source, Q{formatted};

		done-testing;
	}, Q{version 3};

	done-testing;
}, Q{99 bottles of beer};

done-testing;

# vim: ft=perl6
