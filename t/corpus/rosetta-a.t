use v6;

use Test;
use Perl6::Parser;

plan 42;

my $pt = Perl6::Parser.new;
my $*CONSISTENCY-CHECK = True;
my $*GRAMMAR-CHECK = True;

subtest {
	subtest {
		my $source = Q:to[_END_];
get.words.sum.say;
_END_
		my $p = $pt.parse( $source );
		my $tree = $pt.build-tree( $p );
		is $pt.to-string( $tree ), $source, Q{formatted};

		done-testing;
	}, Q{version 1};

	subtest {
		my $source = Q:to[_END_];
say [+] get.words;
_END_
		my $p = $pt.parse( $source );
		my $tree = $pt.build-tree( $p );
		is $pt.to-string( $tree ), $source, Q{formatted};

		done-testing;
	}, Q{version 2};

	subtest {
		my $source = Q:to[_END_];
my ($a, $b) = $*IN.get.split(" ");
say $a + $b;
_END_
		my $p = $pt.parse( $source );
		my $tree = $pt.build-tree( $p );
		is $pt.to-string( $tree ), $source, Q{formatted};

		done-testing;
	}, Q{version 3};

	done-testing;
}, Q{A + B};

subtest {
	my $source = Q:to[_END_];
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
	my $p = $pt.parse( $source );
	my $tree = $pt.build-tree( $p );
	is $pt.to-string( $tree ), $source, Q{formatted};

	done-testing;
}, Q{ABC Problem};

subtest {
	my $source = Q:to[_END_];
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
	my $p = $pt.parse( $source );
	my $tree = $pt.build-tree( $p );
	is $pt.to-string( $tree ), $source, Q{formatted};

	done-testing;
}, Q{Abstract Class};

subtest {
	my $source = Q:to[_END_];
sub propdivsum (\x) {
    [+] flat(x > 1, gather for 2 .. x.sqrt.floor -> \d {
        my \y = x div d;
        if y * d == x { take d; take y unless y == d }
    })
}

say bag map { propdivsum($_) <=> $_ }, 1..20000
_END_
	my $p = $pt.parse( $source );
	my $tree = $pt.build-tree( $p );
	is $pt.to-string( $tree ), $source, Q{formatted};

	done-testing;
}, Q{Abundant, Deficient and Perfect numbers};

subtest {
	my $source = Q:to[_END_];
sub accum ($n is copy) { sub { $n += $^x } }
_END_
	my $p = $pt.parse( $source );
	my $tree = $pt.build-tree( $p );
	is $pt.to-string( $tree ), $source, Q{formatted};

	done-testing;
}, Q{Accumulator factory};

subtest {
	subtest {
		my $source = Q:to[_END_];
sub A(Int $m, Int $n) {
    if    $m == 0 { $n + 1 } 
    elsif $n == 0 { A($m - 1, 1) }
    else          { A($m - 1, A($m, $n - 1)) }
}
_END_
		my $p = $pt.parse( $source );
		my $tree = $pt.build-tree( $p );
		is $pt.to-string( $tree ), $source, Q{formatted};

		done-testing;
	}, Q{version 1};

	subtest {
		my $source = Q:to[_END_];
multi sub A(0,      Int $n) { $n + 1                   }
multi sub A(Int $m, 0     ) { A($m - 1, 1)             }
multi sub A(Int $m, Int $n) { A($m - 1, A($m, $n - 1)) }
_END_
		my $p = $pt.parse( $source );
		my $tree = $pt.build-tree( $p );
		is $pt.to-string( $tree ), $source, Q{formatted};

		done-testing;
	}, Q{version 2};

	subtest {
		my $source = Q:to[_END_];
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
		my $p = $pt.parse( $source );
		my $tree = $pt.build-tree( $p );
		is $pt.to-string( $tree ), $source, Q{formatted};

		done-testing;
	}, Q{version 3};

	done-testing;
}, Q{Ackermann Function};

subtest {
	subtest {
		my $source = Q:to[_END_];
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
		my $p = $pt.parse( $source );
		my $tree = $pt.build-tree( $p );
		is $pt.to-string( $tree ), $source, Q{formatted};

		done-testing;
	}, Q{version 1};

	subtest {
		my $source = Q:to[_END_];
my $lue = 42 but role { has $.answer = "Life, the Universe, and Everything" }
 
say $lue;          # 42
say $lue.answer;   # Life, the Universe, and Everything
_END_
		my $p = $pt.parse( $source );
		my $tree = $pt.build-tree( $p );
		is $pt.to-string( $tree ), $source, Q{formatted};

		done-testing;
	}, Q{version 2};

	subtest {
		my $source = Q:to[_END_];
use MONKEY-TYPING;
augment class Int {
    method answer { "Life, the Universe, and Everything" }
}
say 42.answer;     # Life, the Universe, and Everything
_END_
		my $p = $pt.parse( $source );
		my $tree = $pt.build-tree( $p );
		is $pt.to-string( $tree ), $source, Q{formatted};

		done-testing;
	}, Q{version 3};

	done-testing;
}, Q{Add a variable to a class at runtime};

subtest {
	my $source = Q:to[_END_];
my $x;
say $x.WHERE;
 
my $y := $x;   # alias
say $y.WHERE;  # same address as $x
 
say "Same variable" if $y =:= $x;
$x = 42;
say $y;  # 42
_END_
	my $p = $pt.parse( $source );
	my $tree = $pt.build-tree( $p );
	is $pt.to-string( $tree ), $source, Q{formatted};

	done-testing;
}, Q{Address of a variable};

subtest {
	my $source = Q:to[_END_];
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
	my $p = $pt.parse( $source );
	my $tree = $pt.build-tree( $p );
	is $pt.to-string( $tree ), $source, Q{formatted};

	done-testing;
}, Q{AKS test for primality};

subtest {
	subtest {
		my $source = Q:to[_END_];
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
		my $p = $pt.parse( $source );
		my $tree = $pt.build-tree( $p );
		is $pt.to-string( $tree ), $source, Q{formatted};

		done-testing;
	}, Q{version 1};

	subtest {
		my $source = Q:to[_END_];
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
		my $p = $pt.parse( $source );
		my $tree = $pt.build-tree( $p );
		is $pt.to-string( $tree ), $source, Q{formatted};

		done-testing;
	}, Q{version 2};

	subtest {
		my $source = Q:to[_END_];
sub MAIN ($alignment where 'left'|'right', $file) {
    my @lines := $file.IO.lines.map(*.split: '$').List;
    my @widths = roundrobin(|@lines).map(*».chars.max);
    my $align  = {left=>'-', right=>''}{$alignment};
    my $format = @widths.map({ "%{++$}\${$align}{$_}s" }).join(" ") ~ "\n";
    printf $format, |$_ for @lines;
}
_END_
		my $p = $pt.parse( $source );
		my $tree = $pt.build-tree( $p );
		is $pt.to-string( $tree ), $source, Q{formatted};

		done-testing;
	}, Q{version 3};

	done-testing;
}, Q{Align columns};

subtest {
	my $source = Q:to[_END_];
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
	my $p = $pt.parse( $source );
	my $tree = $pt.build-tree( $p );
	is $pt.to-string( $tree ), $source, Q{formatted};

	done-testing;
}, Q{Aliquot sequence};

subtest {
	subtest {
		my $source = Q:to[_END_];
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
		my $p = $pt.parse( $source );
		my $tree = $pt.build-tree( $p );
		is $pt.to-string( $tree ), $source, Q{formatted};

		done-testing;
	}, Q{version 1};

	subtest {
		# 'factor^2' was superscript-2
		my $source = Q:to[_END_];
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
		my $p = $pt.parse( $source );
		my $tree = $pt.build-tree( $p );
		is $pt.to-string( $tree ), $source, Q{formatted};

		done-testing;
	}, Q[version 2];

	done-testing;
}, Q{Almost prime};

subtest {
	subtest {
		my $source = Q:to[_END_];
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
		my $p = $pt.parse( $source );
		my $tree = $pt.build-tree( $p );
		is $pt.to-string( $tree ), $source, Q{formatted};

		done-testing;
	}, Q{version 1};
 
	subtest {
		my $source = Q:to[_END_];
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
		my $p = $pt.parse( $source );
		my $tree = $pt.build-tree( $p );
		is $pt.to-string( $tree ), $source, Q{formatted};

		done-testing;
	}, Q{version 2};

	subtest {
		my $source = Q:to[_END_];
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
		my $p = $pt.parse( $source );
		my $tree = $pt.build-tree( $p );
		is $pt.to-string( $tree ), $source, Q{formatted};

		done-testing;
	}, Q{version 3};

	done-testing;
}, Q{Almost prime};

subtest {
	my $source = Q:to[_END_];
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
	my $p = $pt.parse( $source );
	my $tree = $pt.build-tree( $p );
	is $pt.to-string( $tree ), $source, Q{formatted};

	done-testing;
}, Q{Amicable pairs};

subtest {
	subtest {
		my $source = Q:to[_END_];
my %anagram = slurp('unixdict.txt').words.classify( { .comb.sort.join } );
 
my $max = [max] map { +@($_) }, %anagram.values;
 
%anagram.values.grep( { +@($_) >= $max } )».join(' ')».say;
_END_
		my $p = $pt.parse( $source );
		my $tree = $pt.build-tree( $p );
		is $pt.to-string( $tree ), $source, Q{formatted};

		done-testing;
	}, Q{version 1};

	subtest {
#`[
		my $source = Q:to[_END_];
.put for                             # print each element of the array made this way:
slurp('unixdict.txt')\               # load file in memory
.words\                              # extract words
.classify( {.comb.sort.join} )\      # group by common anagram
.classify( *.value.elems ).flat\     # group by number of anagrams in a group
.max( :by(*.key) ).value\            # get the group with highest number of anagrams
.flat».value                         # get all groups of anagrams in the group just selected
_END_
		my $p = $pt.parse( $source );
		my $tree = $pt.build-tree( $p );
		is $pt.to-string( $tree ), $source, Q{formatted};
]

		done-testing;
	}, Q{version 2};

	done-testing;
}, Q{Anagrams};

subtest {
	my $source = Q:to[_END_];
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
	my $p = $pt.parse( $source );
	my $tree = $pt.build-tree( $p );
	is $pt.to-string( $tree ), $source, Q{formatted};

	done-testing;
}, Q{Anagrams / Derangements};

subtest {
	my $source = Q:to[_END_];
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
	my $p = $pt.parse( $source );
	my $tree = $pt.build-tree( $p );
	is $pt.to-string( $tree ), $source, Q{formatted};

	done-testing;
}, Q{Anonymous recursion};

subtest {
	my $source = Q:to[_END_];
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
	my $p = $pt.parse( $source );
	my $tree = $pt.build-tree( $p );
	is $pt.to-string( $tree ), $source, Q{formatted};

	done-testing;
}, Q{Apply a callback to an array};

subtest {
	my $source = Q:to[_END_];
given ~[**] 5, 4, 3, 2 {
   say "5**4**3**2 = {.substr: 0,20}...{.substr: *-20} and has {.chars} digits";
}
_END_
	my $p = $pt.parse( $source );
	my $tree = $pt.build-tree( $p );
	is $pt.to-string( $tree ), $source, Q{formatted};

	done-testing;
}, Q{Arbitrary-precision integers};

subtest {
	# XXX Make up a 'Image::PNG::Portable' class
	my $source = Q:to[_END_];
class Image::PNG::Portable { has ( $.width, $.height ); method set { }; method write { } }
#use Image::PNG::Portable;

my ($w, $h) = (400, 400);

my $png = Image::PNG::Portable.new: :width($w), :height($h);

for 0, .025 ... 52*π -> \Θ {
    $png.set: |((cis( Θ / π ) * Θ).reals »+« ($w/2, $h/2))».Int, 255, 0, 255;
}

$png.write: 'Archimedean-spiral-perl6.png';
_END_
	my $p = $pt.parse( $source );
	my $tree = $pt.build-tree( $p );
	is $pt.to-string( $tree ), $source, Q{formatted};

	done-testing;
}, Q{Archimedean spiral};

subtest {
	my $source = Q:to[_END_];
sub cumulative_freq(%freq) {
    my %cf;
    my $total = 0;
    for %freq.keys.sort -> $c {
        %cf{$c} = $total;
        $total += %freq{$c};
    }
    return %cf;
}
 
sub arithmethic_coding($str, $radix) {
    my @chars = $str.comb;
 
    # The frequency characters
    my %freq;
    %freq{$_}++ for @chars;
 
    # The cumulative frequency table
    my %cf = cumulative_freq(%freq);
 
    # Base
    my $base = @chars.elems;
 
    # Lower bound
    my $L = 0;
 
    # Product of all frequencies
    my $pf = 1;
 
    # Each term is multiplied by the product of the
    # frequencies of all previously occurring symbols
    for @chars -> $c {
        $L = $L*$base + %cf{$c}*$pf;
        $pf *= %freq{$c};
    }
 
    # Upper bound
    my $U = $L + $pf;
 
    my $pow = 0;
    loop {
        $pf div= $radix;
        last if $pf == 0;
        ++$pow;
    }
 
    my $enc = ($U - 1) div ($radix ** $pow);
    ($enc, $pow, %freq);
}
 
sub arithmethic_decoding($encoding, $radix, $pow, %freq) {
 
    # Multiply encoding by radix^pow
    my $enc = $encoding * $radix**$pow;
 
    # Base
    my $base = [+] %freq.values;
 
    # Create the cumulative frequency table
    my %cf = cumulative_freq(%freq);
 
    # Create the dictionary
    my %dict;
    for %cf.kv -> $k,$v {
        %dict{$v} = $k;
    }
 
    # Fill the gaps in the dictionary
    my $lchar;
    for ^$base -> $i {
        if (%dict{$i}:exists) {
            $lchar = %dict{$i};
        }
        elsif (defined $lchar) {
            %dict{$i} = $lchar;
        }
    }
 
    # Decode the input number
    my $decoded = '';
    for reverse(^$base) -> $i {
 
        my $pow = $base**$i;
        my $div = $enc div $pow;
 
        my $c  = %dict{$div};
        my $fv = %freq{$c};
        my $cv = %cf{$c};
 
        my $rem = ($enc - $pow*$cv) div $fv;
 
        $enc = $rem;
        $decoded ~= $c;
    }
 
    # Return the decoded output
    return $decoded;
}
 
my $radix = 10;    # can be any integer greater or equal with 2
 
for <DABDDB DABDDBBDDBA ABRACADABRA TOBEORNOTTOBEORTOBEORNOT> -> $str {
    my ($enc, $pow, %freq) = arithmethic_coding($str, $radix);
    my $dec = arithmethic_decoding($enc, $radix, $pow, %freq);
 
    printf("%-25s=> %19s * %d^%s\n", $str, $enc, $radix, $pow);
 
    if ($str ne $dec) {
        die "\tHowever that is incorrect!";
    }
}
_END_
	my $p = $pt.parse( $source );
	my $tree = $pt.build-tree( $p );
	is $pt.to-string( $tree ), $source, Q{formatted};

	done-testing;
}, Q{Arithmetic coding};

subtest {
	my $source = Q:to[_END_];
sub ev (Str $s --> Num) {
 
    grammar expr {
        token TOP { ^ <sum> $ }
        token sum { <product> (('+' || '-') <product>)* }
        token product { <factor> (('*' || '/') <factor>)* }
        token factor { <unary_minus>? [ <parens> || <literal> ] }
        token unary_minus { '-' }
        token parens { '(' <sum> ')' }
        token literal { \d+ ['.' \d+]? || '.' \d+ }
    }
 
    my sub minus ($b) { $b ?? -1 !! +1 }
 
    my sub sum ($x) {
        [+] flat product($x<product>), map
            { minus($^y[0] eq '-') * product $^y<product> },
            |($x[0] or [])
    }
 
    my sub product ($x) {
        [*] flat factor($x<factor>), map
            { factor($^y<factor>) ** minus($^y[0] eq '/') },
            |($x[0] or [])
    }
 
    my sub factor ($x) {
        minus($x<unary_minus>) * ($x<parens>
          ?? sum $x<parens><sum>
          !! $x<literal>)
    }
 
    expr.parse([~] split /\s+/, $s);
    $/ or fail 'No parse.';
    sum $/<sum>;
 
}

say ev '5';                                    #   5
say ev '1 + 2 - 3 * 4 / 5';                    #   0.6
say ev '1 + 5*3.4 - .5  -4 / -2 * (3+4) -6';   #  25.5
say ev '((11+15)*15)* 2 + (3) * -4 *1';        # 768
_END_
	my $p = $pt.parse( $source );
	my $tree = $pt.build-tree( $p );
	is $pt.to-string( $tree ), $source, Q{formatted};

	done-testing;
}, Q{Arithmetic evaluation};

subtest {
	subtest {
		# XXX Restore this bit.
    		#($a, $g) = ($a + $g)/2, sqrt $a * $g until $a ≅ $g;
		my $source = Q:to[_END_];
sub agm( $a is copy, $g is copy ) {
    ($a, $g) = ($a + $g)/2, sqrt $a * $g until $a = $g;
    return $a;
}
 
say agm 1, 1/sqrt 2;
_END_
		my $p = $pt.parse( $source );
		my $tree = $pt.build-tree( $p );
		is $pt.to-string( $tree ), $source, Q{formatted};

		done-testing;
	}, Q{version 1};

	subtest {
    #$a ≅ $g ?? $a !! agm(|@$_)
		my $source = Q:to[_END_];
sub agm( $a, $g ) {
    $a = $g ?? $a !! agm(|@$_)
        given ($a + $g)/2, sqrt $a * $g;
}
 
say agm 1, 1/sqrt 2;
_END_
		my $p = $pt.parse( $source );
		my $tree = $pt.build-tree( $p );
		is $pt.to-string( $tree ), $source, Q{formatted};

		done-testing;
	}, Q{version 2};

	done-testing;
}, Q{Arithmetic-geometric mean};

subtest {
	my $source = Q:to[_END_];
constant number-of-decimals = 100;
 
multi sqrt(Int $n) {
    .[*-1] given
    1, { ($_ + $n div $_) div 2 } ... * == *
}
multi sqrt(FatRat $r --> FatRat) {
    return FatRat.new:
    sqrt($r.nude[0] * 10**(number-of-decimals*2) div $r.nude[1]),
    10**number-of-decimals;
}
 
my FatRat ($a, $n) = 1.FatRat xx 2;
my FatRat $g = sqrt(1/2.FatRat);
my $z = .25;
 
for ^10 {
    given [ ($a + $g)/2, sqrt($a * $g) ] {
	$z -= (.[0] - $a)**2 * $n;
	$n += $n;
	($a, $g) = @$_;
	say ($a ** 2 / $z).substr: 0, 2 + number-of-decimals;
    }
}
_END_
	my $p = $pt.parse( $source );
	my $tree = $pt.build-tree( $p );
	is $pt.to-string( $tree ), $source, Q{formatted};

	done-testing;
}, Q{Arithmetic-geometric mean/Calculate pi};

subtest {
	my $source = Q:to[_END_];
my $a = 1 + i;
my $b = pi + 1.25i;
 
.say for $a + $b, $a * $b, -$a, 1 / $a, $a.conj;
.say for $a.abs, $a.sqrt, $a.re, $a.im;
_END_
	my $p = $pt.parse( $source );
	my $tree = $pt.build-tree( $p );
	is $pt.to-string( $tree ), $source, Q{formatted};

	done-testing;
}, Q{Arithmetic/complex};

subtest {
	my $source = Q:to[_END_];
my Int $a = get.floor;
my Int $b = get.floor;
 
say 'sum:              ', $a + $b;
say 'difference:       ', $a - $b;
say 'product:          ', $a * $b;
say 'integer quotient: ', $a div $b;
say 'remainder:        ', $a % $b;
say 'exponentiation:   ', $a**$b;
_END_
	my $p = $pt.parse( $source );
	my $tree = $pt.build-tree( $p );
	is $pt.to-string( $tree ), $source, Q{formatted};

	done-testing;
}, Q{Arithmetic/integer};

subtest {
	subtest {
		my $source = Q:to[_END_];
for 2..2**19 -> $candidate {
    my $sum = 1 / $candidate;
    for 2 .. ceiling(sqrt($candidate)) -> $factor {
        if $candidate %% $factor {
            $sum += 1 / $factor + 1 / ($candidate / $factor);
        }
    }
    if $sum.denominator == 1 {
        say "Sum of reciprocal factors of $candidate = $sum exactly", ($sum == 1 ?? ", perfect!" !! ".");
    }
}
_END_
		my $p = $pt.parse( $source );
		my $tree = $pt.build-tree( $p );
		is $pt.to-string( $tree ), $source, Q{formatted};

		done-testing;
	}, Q{version 1};

	subtest {
		my $source = Q:to[_END_];
for 1.0, 1.1, 1.2 ... 10 { .say }
_END_
		my $p = $pt.parse( $source );
		my $tree = $pt.build-tree( $p );
		is $pt.to-string( $tree ), $source, Q{formatted};

		done-testing;
	}, Q{version 2};

	done-testing;
}, Q{Arithmetic/rational};

subtest {
	my $source = Q:to[_END_];
# the prefix:<|> operator (called "slip") can be used to interpolate arrays into a list:
sub cat-arrays(@a, @b) { 
	|@a, |@b 
}
 
my @a1 = (1,2,3);
my @a2 = (2,3,4);
cat-arrays(@a1,@a2).join(", ").say;
_END_
	my $p = $pt.parse( $source );
	my $tree = $pt.build-tree( $p );
	is $pt.to-string( $tree ), $source, Q{formatted};

	done-testing;
}, Q{Array concatenation};

subtest {
	subtest {
		my $source = Q:to[_END_];
my @array = <apple orange banana>;
 
say @array.elems;  # 3
say elems @array;  # 3
say +@array;       # 3
say @array + 1;    # 4
_END_
		my $p = $pt.parse( $source );
		my $tree = $pt.build-tree( $p );
		is $pt.to-string( $tree ), $source, Q{formatted};

		done-testing;
	}, Q{version 1};

	subtest {
		my $source = Q:to[_END_];
my @infinite = 1 .. Inf;  # 1, 2, 3, 4, ...
 
say @infinite[5000];  # 5001
say @infinite.elems;  # Throws exception "Cannot .elems a lazy list"
_END_
		my $p = $pt.parse( $source );
		my $tree = $pt.build-tree( $p );
		is $pt.to-string( $tree ), $source, Q{formatted};

		done-testing;
	}, Q{version 2};

	done-testing;
}, Q{Array length};

subtest {
#`[
	# XXX Synthesize JSON::Tiny
	my $source = Q:to[_END_];
class JSON::Tiny { sub from-json is export { } }
#use JSON::Tiny;
 
my $cities = from-json('
[{"name":"Lagos", "population":21}, {"name":"Cairo", "population":15.2}, {"name":"Kinshasa-Brazzaville", "population":11.3}, {"name":"Greater Johannesburg", "population":7.55}, {"name":"Mogadishu", "population":5.85}, {"name":"Khartoum-Omdurman", "population":4.98}, {"name":"Dar Es Salaam", "population":4.7}, {"name":"Alexandria", "population":4.58}, {"name":"Abidjan", "population":4.4}, {"name":"Casablanca", "population":3.98}]
');
 
# Find the indicies of the cities named 'Dar Es Salaam'.
say grep { $_<name> eq 'Dar Es Salaam'}, :k, @$cities; # (6)
 
# Find the name of the first city with a population less
# than 5 when sorted by population, largest to smallest.
say ($cities.sort( -*.<population> ).first: *.<population> < 5)<name>; # Khartoum-Omdurman
 
 
# Find all of the city names that contain an 'm' 
say join ', ', sort grep( {$_<name>.lc ~~ /'m'/}, @$cities )»<name>; # Dar Es Salaam, Khartoum-Omdurman, Mogadishu
_END_
	my $p = $pt.parse( $source );
	my $tree = $pt.build-tree( $p );
	is $pt.to-string( $tree ), $source, Q{formatted};
]

	done-testing;
}, Q{Array search};

subtest {
	my $source = Q:to[_END_];
my @arr;
 
push @arr, 1;
push @arr, 3;
 
@arr[0] = 2;
 
say @arr[0];
_END_
	my $p = $pt.parse( $source );
	my $tree = $pt.build-tree( $p );
	is $pt.to-string( $tree ), $source, Q{formatted};

	done-testing;
}, Q{Arrays};

subtest {
	subtest {
		my $source = Q:to[_END_];
my %h1 = key1 => 'val1', 'key-2' => 2, three => -238.83, 4 => 'val3';
my %h2 = 'key1', 'val1', 'key-2', 2, 'three', -238.83, 4, 'val3';
_END_
		my $p = $pt.parse( $source );
		my $tree = $pt.build-tree( $p );
		is $pt.to-string( $tree ), $source, Q{formatted};

		done-testing;
	}, Q{version 1};

	subtest {
		my $source = Q:to[_END_];
my @a = 1..5;
my @b = 'a'..'e';
my %h = @a Z=> @b;
_END_
		my $p = $pt.parse( $source );
		my $tree = $pt.build-tree( $p );
		is $pt.to-string( $tree ), $source, Q{formatted};

		done-testing;
	}, Q{version 2};

	subtest {
		my $source = Q:to[_END_];
my %h1;
say %h1{'key1'};
say %h1<key1>;
%h1<key1> = 'val1';
%h1<key1 three> = 'val1', -238.83;
_END_
		my $p = $pt.parse( $source );
		my $tree = $pt.build-tree( $p );
		is $pt.to-string( $tree ), $source, Q{formatted};

		done-testing;
	}, Q{version 3};

	subtest {
		my $source = Q:to[_END_];
my $h = {key1 => 'val1', 'key-2' => 2, three => -238.83, 4 => 'val3'};
say $h<key1>;
_END_
		my $p = $pt.parse( $source );
		my $tree = $pt.build-tree( $p );
		is $pt.to-string( $tree ), $source, Q{formatted};

		done-testing;
	}, Q{version 4};

	subtest {
		my $source = Q:to[_END_];
my %hash{Any}; # same as %hash{*}
class C {};
my %cash{C};
%cash{C.new} = 1;
_END_
		my $p = $pt.parse( $source );
		my $tree = $pt.build-tree( $p );
		is $pt.to-string( $tree ), $source, Q{formatted};

		done-testing;
	}, Q{version 5};

	subtest {
		my $source = Q:to[_END_];
my @infinite = 1 .. Inf;  # 1, 2, 3, 4, ...
 
say @infinite[5000];  # 5001
say @infinite.elems;  # Throws exception "Cannot .elems a lazy list"
_END_
		my $p = $pt.parse( $source );
		my $tree = $pt.build-tree( $p );
		is $pt.to-string( $tree ), $source, Q{formatted};

		done-testing;
	}, Q{version 6};

	done-testing;
}, Q{Associative array/creation};

subtest {
	my $source = Q:to[_END_];
my %pairs = hello => 13, world => 31, '!' => 71;
 
for %pairs.kv -> $k, $v {
    say "(k,v) = ($k, $v)";
}
 
{ say "$^a => $^b" } for %pairs.kv;
 
say "key = $_" for %pairs.keys;
 
say "value = $_" for %pairs.values;
_END_
	my $p = $pt.parse( $source );
	my $tree = $pt.build-tree( $p );
	is $pt.to-string( $tree ), $source, Q{formatted};

	done-testing;
}, Q{Associative array/iteration};

subtest {
	my $source = Q:to[_END_];
constant MAX_N  = 20;
constant TRIALS = 100;
 
for 1 .. MAX_N -> $N {
    my $empiric = TRIALS R/ [+] find-loop(random-mapping($N)).elems xx TRIALS;
    my $theoric = [+]
        map -> $k { $N ** ($k + 1) R/ [*] $k**2, $N - $k + 1 .. $N }, 1 .. $N;
 
    FIRST say " N    empiric      theoric      (error)";
    FIRST say "===  =========  ============  =========";
 
    printf "%3d  %9.4f  %12.4f    (%4.2f%%)\n",
            $N,  $empiric,
                        $theoric, 100 * abs($theoric - $empiric) / $theoric;
}
 
sub random-mapping { hash .list Z=> .roll given ^$^size }
sub find-loop { 0, %^mapping{*} ...^ { (state %){$_}++ } }
_END_
	my $p = $pt.parse( $source );
	my $tree = $pt.build-tree( $p );
	is $pt.to-string( $tree ), $source, Q{formatted};

	done-testing;
}, Q{Average loop length};

subtest {
	my $source = Q:to[_END_];
multi mean([]){ Failure.new('mean on empty list is not defined') }; # Failure-objects are lazy exceptions
multi mean (@a) { ([+] @a) / @a }
_END_
	my $p = $pt.parse( $source );
	my $tree = $pt.build-tree( $p );
	is $pt.to-string( $tree ), $source, Q{formatted};

	done-testing;
}, Q{Averages/arithmetic mean};

subtest {
	my $source = Q:to[_END_];
# Of course, you can still use pi and 180.
sub deg2rad { $^d * tau / 360 }
sub rad2deg { $^r * 360 / tau }
 
sub phase ($c)  {
    my ($mag,$ang) = $c.polar;
    return NaN if $mag < 1e-16;
    $ang;
}
 
sub meanAngle { rad2deg phase [+] map { cis deg2rad $_ }, @^angles }
 
say meanAngle($_).fmt("%.2f\tis the mean angle of "), $_ for
    [350, 10],
    [90, 180, 270, 360],
    [10, 20, 30];
_END_
	my $p = $pt.parse( $source );
	my $tree = $pt.build-tree( $p );
	is $pt.to-string( $tree ), $source, Q{formatted};

	done-testing;
}, Q{Averages/mean angle};

subtest {
	my $source = Q:to[_END_];
sub tod2rad($_) { [+](.comb(/\d+/) Z* 3600,60,1) * tau / 86400 }
 
sub rad2tod ($r) {
    my $x = $r * 86400 / tau;
    (($x xx 3 Z/ 3600,60,1) Z% 24,60,60).fmt('%02d',':');
}
 
sub phase ($c) { $c.polar[1] }
 
sub mean-time (@t) { rad2tod phase [+] map { cis tod2rad $_ }, @t }
 
my @times = ["23:00:17", "23:40:20", "00:12:45", "00:17:19"];
 
say "{ mean-time(@times) } is the mean time of @times[]";
_END_
	my $p = $pt.parse( $source );
	my $tree = $pt.build-tree( $p );
	is $pt.to-string( $tree ), $source, Q{formatted};

	done-testing;
}, Q{Averages/mean time of day};

subtest {
	my $source = Q:to[_END_];
sub median {
  my @a = sort @_;
  return (@a[@a.end / 2] + @a[@a / 2]) / 2;
}
_END_
	my $p = $pt.parse( $source );
	my $tree = $pt.build-tree( $p );
	is $pt.to-string( $tree ), $source, Q{formatted};

	done-testing;
}, Q{Averages/median};

subtest {
	my $source = Q:to[_END_];
sub mode (*@a) {
    my %counts;
    ++%counts{$_} for @a;
    my $max = [max] values %counts;
    return |map { .key }, grep { .value == $max }, %counts.pairs;
}
_END_
	my $p = $pt.parse( $source );
	my $tree = $pt.build-tree( $p );
	is $pt.to-string( $tree ), $source, Q{formatted};

	done-testing;
}, Q{Averages/mode};

subtest {
	my $source = Q:to[_END_];
sub A { ([+] @_) / @_ }
sub G { ([*] @_) ** (1 / @_) }
sub H { @_ / [+] 1 X/ @_ }
 
say "A(1,...,10) = ", A(1..10);
say "G(1,...,10) = ", G(1..10);
say "H(1,...,10) = ", H(1..10);
_END_
	my $p = $pt.parse( $source );
	my $tree = $pt.build-tree( $p );
	is $pt.to-string( $tree ), $source, Q{formatted};

	done-testing;
}, Q{Averages/Pythagorean means};

subtest {
	subtest {
		my $source = Q:to[_END_];
sub rms(*@nums) { sqrt [+](@nums X** 2) / @nums }
 
say rms 1..10;
_END_
		my $p = $pt.parse( $source );
		my $tree = $pt.build-tree( $p );
		is $pt.to-string( $tree ), $source, Q{formatted};

		done-testing;
	}, Q{version 1};

	subtest {
		my $source = Q:to[_END_];
sub rms { sqrt @_ R/ [+] @_ X** 2 }
_END_
		my $p = $pt.parse( $source );
		my $tree = $pt.build-tree( $p );
		is $pt.to-string( $tree ), $source, Q{formatted};

		done-testing;
	}, Q{version 2};

	done-testing;
}, Q{Averages/root mean square};

subtest {
	my $source = Q:to[_END_];
sub sma(Int \P where * > 0) returns Sub {
    sub ($x) {
        state @a = 0 xx P;
        @a.push($x).shift;
        P R/ [+] @a;
    }
}
_END_
	my $p = $pt.parse( $source );
	my $tree = $pt.build-tree( $p );
	is $pt.to-string( $tree ), $source, Q{formatted};

	done-testing;
}, Q{Averages/simple moving average};

done-testing;
# vim: ft=perl6
