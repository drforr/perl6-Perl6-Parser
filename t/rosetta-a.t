use v6;

use Test;
use Perl6::Tidy;

plan 20;

my $pt = Perl6::Tidy.new;

subtest {
	plan 3;

	subtest {
		plan 1;

		my $parsed = $pt.tidy( Q:to[_END_] );
get.words.sum.say;
_END_
		isa-ok $parsed, Q{Perl6::Tidy::Root};
	}, Q{version 1};

	subtest {
		plan 1;

		my $parsed = $pt.tidy( Q:to[_END_] );
say [+] get.words;
_END_
		isa-ok $parsed, Q{Perl6::Tidy::Root};
	}, Q{version 2};

	subtest {
		plan 1;

		my $parsed = $pt.tidy( Q:to[_END_] );
my ($a, $b) = $*IN.get.split(" ");
say $a + $b;
_END_
		isa-ok $parsed, Q{Perl6::Tidy::Root};
	}, Q{version 3};
}, Q{A + B};

subtest {
	plan 1;

	my $parsed = $pt.tidy( Q:to[_END_] );
multi can-spell-word(Str $word, @blocks) {
    my @regex = @blocks.map({ my @c = .comb; rx/<@c>/ }).grep: { .ACCEPTS($word.uc) }
    can-spell-word $word.uc.comb.list, @regex;
}

multi can-spell-word([$head,*@tail], @regex) {
    for @regex -> $re {
        if $head ~~ $re {
            return True unless @tail;
            return False if @regex == 1;
            return True if can-spell-word @tail, list @regex.grep: * !=== $re;
        }
    }
    False;
}

my @b = <BO XK DQ CP NA GT RE TG QD FS JW HU VI AN OB ER FS LY PC ZM>;

for <A BaRK BOoK tREaT COmMOn SqUAD CoNfuSE> {
    say "$_     &can-spell-word($_, @b)";
}
_END_
	isa-ok $parsed, Q{Perl6::Tidy::Root};
}, Q{ABC Problem};

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
	isa-ok $parsed, Q{Perl6::Tidy::Root};
}, Q{Abstract Class};

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
	isa-ok $parsed, Q{Perl6::Tidy::Root};
}, Q{Abundant, Deficient and Perfect numbers};

subtest {
	plan 1;

	my $parsed = $pt.tidy( Q:to[_END_] );
sub accum ($n is copy) { sub { $n += $^x } }
_END_
	isa-ok $parsed, Q{Perl6::Tidy::Root};
}, Q{Accumulator factory};

subtest {
	plan 3;

	subtest {
		plan 1;

		my $parsed = $pt.tidy( Q:to[_END_] );
sub A(Int $m, Int $n) {
    if    $m == 0 { $n + 1 } 
    elsif $n == 0 { A($m - 1, 1) }
    else          { A($m - 1, A($m, $n - 1)) }
}
_END_
		isa-ok $parsed, Q{Perl6::Tidy::Root};
	}, Q{version 1};

	subtest {
		plan 1;

		my $parsed = $pt.tidy( Q:to[_END_] );
multi sub A(0,      Int $n) { $n + 1                   }
multi sub A(Int $m, 0     ) { A($m - 1, 1)             }
multi sub A(Int $m, Int $n) { A($m - 1, A($m, $n - 1)) }
_END_
		isa-ok $parsed, Q{Perl6::Tidy::Root};
	}, Q{version 2};

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
		isa-ok $parsed, Q{Perl6::Tidy::Root};
	}, Q{version 4};
}, Q{Ackermann Function};

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
		isa-ok $parsed, Q{Perl6::Tidy::Root};
	}, Q{version 1};

	subtest {
		plan 1;

		my $parsed = $pt.tidy( Q:to[_END_] );
my $lue = 42 but role { has $.answer = "Life, the Universe, and Everything" }
 
say $lue;          # 42
say $lue.answer;   # Life, the Universe, and Everything
_END_
		isa-ok $parsed, Q{Perl6::Tidy::Root};
	}, Q{version 2};

	subtest {
		plan 1;

		my $parsed = $pt.tidy( Q:to[_END_] );
use MONKEY-TYPING;
augment class Int {
    method answer { "Life, the Universe, and Everything" }
}
say 42.answer;     # Life, the Universe, and Everything
_END_
		isa-ok $parsed, Q{Perl6::Tidy::Root};
	}, Q{version 3};
}, Q{Add a variable to a class at runtime};

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
	isa-ok $parsed, Q{Perl6::Tidy::Root};
}, Q{Address of a variable};

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
	isa-ok $parsed, Q{Perl6::Tidy::Root};
}, Q{AKS test for primality};

subtest {
	plan 3;

	subtest {
		plan 1;

		my $parsed = $pt.tidy( Q:to[_END_] );
#to be called with perl6 columnaligner.pl <orientation>(left, center , right )
#with left as default
my $fh = open  "example.txt" , :r  or die "Can't read text file!\n" ;
my @filelines = $fh.lines ;
close $fh ;
my @maxcolwidths ; #array of the longest words per column
#--------fill the array with values-------------------
for @filelines -> $line {
   my @words = $line.split( "\$" ) ;
   for 0..@words.elems - 1 -> $i {
      if @maxcolwidths[ $i ] {
	 if @words[ $i ].chars > @maxcolwidths[$i] {
	    @maxcolwidths[ $i ] = @words[ $i ].chars ;
	 }
      }
      else {
	 @maxcolwidths.push( @words[ $i ].chars ) ;
      }
   }
}
my $justification = @*ARGS[ 0 ] || "left" ;
##print lines , $gap holds the number of spaces, 1 to be added 
##to allow for space preceding or following longest word
for @filelines -> $line {
   my @words = $line.split( "\$" ) ;
   for 0 ..^ @words -> $i {
      my $gap =  @maxcolwidths[$i] - @words[$i].chars + 1 ;
      if $justification eq "left" {
	 print @words[ $i ] ~ " " x $gap ;
      } elsif $justification eq "right" {
	 print  " " x $gap ~ @words[$i] ;
      } elsif $justification eq "center" {
	 $gap = ( @maxcolwidths[ $i ] + 2 - @words[$i].chars ) div 2 ;
	 print " " x $gap ~ @words[$i] ~ " " x $gap ;
      }
   }
   say ''; #for the newline
}
_END_
		isa-ok $parsed, Q{Perl6::Tidy::Root};
	}, Q{version 1};

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
		isa-ok $parsed, Q{Perl6::Tidy::Root};
	}, Q{version 2};

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
		isa-ok $parsed, Q{Perl6::Tidy::Root};
	}, Q{version 3};
}, Q{Align columns};

subtest {
	plan 1;

	my $parsed = $pt.tidy( Q:to[_END_] );
sub propdivsum (\x) {
    my @l = x > 1, gather for 2 .. x.sqrt.floor -> \d {
        my \y = x div d;
        if y * d == x { take d; take y unless y == d }
    }
    [+] gather @l.deepmap(*.take);
}

multi quality (0,1)  { 'perfect ' }
multi quality (0,2)  { 'amicable' }
multi quality (0,$n) { "sociable-$n" }
multi quality ($,1)  { 'aspiring' }
multi quality ($,$n) { "cyclic-$n" }

sub aliquotidian ($x) {
    my %seen;
    my @seq = $x, &propdivsum ... *;
    for 0..16 -> $to {
        my $this = @seq[$to] or return "$x\tterminating\t[@seq[^$to]]";
        last if $this > 140737488355328;
        if %seen{$this}:exists {
            my $from = %seen{$this};
            return "$x\t&quality($from, $to-$from)\t[@seq[^$to]]";
        }
        %seen{$this} = $to;
    }
    "$x non-terminating";

}

aliquotidian($_).say for flat
    1..10,
    11, 12, 28, 496, 220, 1184, 12496, 1264460,
    790, 909, 562, 1064, 1488,
    15355717786080;
_END_
	isa-ok $parsed, Q{Perl6::Tidy::Root};
}, Q{Aliquot sequence};

subtest {
	plan 2;

	subtest {
		plan 1;

		my $parsed = $pt.tidy( Q:to[_END_] );
sub is-k-almost-prime($n is copy, $k) returns Bool {
    loop (my ($p, $f) = 2, 0; $f < $k && $p*$p <= $n; $p++) {
        $n /= $p, $f++ while $n %% $p;
    }
    $f + ($n > 1) == $k;
}

for 1 .. 5 -> $k {
    say ~.[^10]
        given grep { is-k-almost-prime($_, $k) }, 2 .. *
}
_END_
		isa-ok $parsed, Q{Perl6::Tidy::Root};
	}, Q{version 1};

	subtest {
		plan 1;

		# 'factor^2' was superscript-2
		my $parsed = $pt.tidy( Q:to[_END_] );
constant @primes = 2, |(3, 5, 7 ... *).grep: *.is-prime;

multi sub factors(1) { 1 }
multi sub factors(Int $remainder is copy) {
    gather for @primes -> $factor {
        # if remainder < factor^2, we're done
        if $factor * $factor > $remainder {
            take $remainder if $remainder > 1;
            last;
        }
        # How many times can we divide by this prime?
        while $remainder %% $factor {
            take $factor;
            last if ($remainder div= $factor) === 1;
        }
    }
}

constant @factory = lazy 0..* Z=> flat (0, 0, map { +factors($_) }, 2..*);

sub almost($n) { map *.key, grep *.value == $n, @factory }

put almost($_)[^10] for 1..5;
_END_
		isa-ok $parsed, Q{Perl6::Tidy::Root};
	}, Q[version 2];
}, Q{Almost prime};

subtest {
	plan 3;

	subtest {
		plan 1;

		my $parsed = $pt.tidy( Q:to[_END_] );
#| an array of four words, that have more possible values. 
#| Normally we would want `any' to signify we want any of the values, but well negate later and thus we need `all'
my @a =
(all «the that a»),
(all «frog elephant thing»),
(all «walked treaded grows»),
(all «slowly quickly»);

sub test (Str $l, Str $r) {
    $l.ends-with($r.substr(0,1))
}

(sub ($w1, $w2, $w3, $w4){
  # return if the values are false
  return unless [and] test($w1, $w2), test($w2, $w3),test($w3, $w4);
  # say the results. If there is one more Container layer around them this doesn't work, this is why we need the arguments here.
  say "$w1 $w2 $w3 $w4"
})(|@a); # supply the array as argumetns
_END_
		isa-ok $parsed, Q{Perl6::Tidy::Root};
	}, Q{version 1};
 
	subtest {
		plan 1;

		my $parsed = $pt.tidy( Q:to[_END_] );
sub infix:<lf> ($a,$b) {
    next unless try $a.substr(*-1,1) eq $b.substr(0,1);
    "$a $b";
}

multi dethunk(Callable $x) { try take $x() }
multi dethunk(     Any $x) {     take $x   }

sub amb (*@c) { gather @c».&dethunk }

say first *, do
    amb(<the that a>, { die 'oops'}) Xlf
    amb('frog',{'elephant'},'thing') Xlf
    amb(<walked treaded grows>)      Xlf
    amb { die 'poison dart' },
        {'slowly'},
        {'quickly'},
        { die 'fire' };
_END_
		isa-ok $parsed, Q{Perl6::Tidy::Root};
	}, Q{version 2};

	subtest {
		plan 1;

		my $parsed = $pt.tidy( Q:to[_END_] );
sub amb($var,*@a) {
    "[{
        @a.pick(*).map: {"||\{ $var = '$_' }"}
     }]";
}

sub joins ($word1, $word2) {
    substr($word1,*-1,1) eq substr($word2,0,1)
}

'' ~~ m/
    :my ($a,$b,$c,$d);
    <{ amb '$a', <the that a> }>
    <{ amb '$b', <frog elephant thing> }>
    <?{ joins $a, $b }>
    <{ amb '$c', <walked treaded grows> }>
    <?{ joins $b, $c }>
    <{ amb '$d', <slowly quickly> }>
    <?{ joins $c, $d }>
    { say "$a $b $c $d" }
    <!>
/;
_END_
		isa-ok $parsed, Q{Perl6::Tidy::Root};
	}, Q{version 3};
}, Q{Almost prime};

subtest {
	plan 1;

	my $parsed = $pt.tidy( Q:to[_END_] );
sub propdivsum (\x) {
    my @l = x > 1, gather for 2 .. x.sqrt.floor -> \d {
        my \y = x div d;
        if y * d == x { take d; take y unless y == d }
    }
    [+] gather @l.deepmap(*.take);
}
 
for 1..20000 -> $i {
    my $j = propdivsum($i);
    say "$i $j" if $j > $i and $i == propdivsum($j);
}
_END_
	isa-ok $parsed, Q{Perl6::Tidy::Root};
}, Q{Amicable pairs};

subtest {
	plan 2;

	subtest {
		plan 1;

		my $parsed = $pt.tidy( Q:to[_END_] );
my %anagram = slurp('unixdict.txt').words.classify( { .comb.sort.join } );
 
my $max = [max] map { +@($_) }, %anagram.values;
 
%anagram.values.grep( { +@($_) >= $max } )».join(' ')».say;
_END_
		isa-ok $parsed, Q{Perl6::Tidy::Root};
	}, Q{version 1};

	subtest {
		plan 1;

		my $parsed = $pt.tidy( Q:to[_END_] );
.put for                             # print each element of the array made this way:
slurp('unixdict.txt')\               # load file in memory
.words\                              # extract words
.classify( {.comb.sort.join} )\      # group by common anagram
.classify( *.value.elems ).flat\     # group by number of anagrams in a group
.max( :by(*.key) ).value\            # get the group with highest number of anagrams
.flat».value                         # get all groups of anagrams in the group just selected
_END_
		isa-ok $parsed, Q{Perl6::Tidy::Root};
	}, Q{version 2};
}, Q{Anagrams};

subtest {
	plan 1;

	my $parsed = $pt.tidy( Q:to[_END_] );
my %anagram = slurp('dict.ie').words.map({[.comb]}).classify({ .sort.join });

for %anagram.values.sort({ -@($_[0]) }) -> @aset {
    for     0   ..^ @aset.end -> $i {
        for $i ^..  @aset.end -> $j {
            if none(  @aset[$i].list Zeq @aset[$j].list ) {
                say "{@aset[$i].join}   {@aset[$j].join}";
                exit;
            }
        }
    }
}
_END_
	isa-ok $parsed, Q{Perl6::Tidy::Root};
}, Q{Anagrams / Derangements};

subtest {
	plan 1;

	my $parsed = $pt.tidy( Q:to[_END_] );
sub fib($n) {
    die "Naughty fib" if $n < 0;
    return {
        $_ < 2
            ?? $_
            !!  &?BLOCK($_-1) + &?BLOCK($_-2);
    }($n);
}
 
say fib(10);
_END_
	isa-ok $parsed, Q{Perl6::Tidy::Root};
}, Q{Anonymous recursion};

subtest {
	plan 1;

	my $parsed = $pt.tidy( Q:to[_END_] );
sub function { 2 * $^x + 3 };
my @array = 1 .. 5;
 
# via map function
.say for map &function, @array;
 
# via map method
.say for @array.map(&function);
 
# via for loop
for @array {
    say function($_);
}
 
# via the "hyper" metaoperator and method indirection
say @array».&function;
 
# we neither need a variable for the array nor for the function
say [1,2,3]>>.&({ $^x + 1});
_END_
	isa-ok $parsed, Q{Perl6::Tidy::Root};
}, Q{Apply a callback to an array};

subtest {
	plan 1;

	my $parsed = $pt.tidy( Q:to[_END_] );
given ~[**] 5, 4, 3, 2 {
   say "5**4**3**2 = {.substr: 0,20}...{.substr: *-20} and has {.chars} digits";
}
_END_
	isa-ok $parsed, Q{Perl6::Tidy::Root};
}, Q{Arbitrary-precision integers};

subtest {
	plan 1;

my $*TRACE = 1;
	# XXX Make up a 'Image::PNG::Portable' class
	my $parsed = $pt.tidy( Q:to[_END_] );
###class Image::PNG::Portable { has ( $.width, $.height ); method set { }; method write { } }
####use Image::PNG::Portable;

###my ($w, $h) = (400, 400);

###my $png = Image::PNG::Portable.new: :width($w), :height($h);

###for 0, .025 ... 52*π -> \Θ {
###    $png.set: |((cis( Θ / π ) * Θ).reals »+« ($w/2, $h/2))».Int, 255, 0, 255;
###}

###$png.write: 'Archimedean-spiral-perl6.png';
_END_
	isa-ok $parsed, Q{Perl6::Tidy::Root};
}, Q{Archimedean spiral};

# vim: ft=perl6
