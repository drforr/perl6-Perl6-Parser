use v6;

use Test;
use Perl6::Tidy;

plan 4;

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
###        my $temp    = @c[$ym;$yd];
###        @c[$ym;$yd] = @c[$xm;$xd];
###        @c[$xm;$xd] = $temp;
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
###    my ( $x, $y ) = @empties.roll;
###    @board[$x; $y] = (flat 2 xx 9, 4).roll;
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
# vim: ft=perl6
