use v6;

use Test;
use Perl6::Tidy;

plan 7;

my $pt = Perl6::Tidy.new;

subtest {
	plan 1;

	my $parsed = $pt.tidy( Q:to[_END_] );
# For all positives integers from 1 to Infinity
for 1 .. Inf -> $integer {
    # calculate the square of the integer
    my $square = $integer²;
    # print the integer and square and exit if the square modulo 1000000 is equal to 269696
    print "{$integer}² equals $square" and exit if $square % 1000000 == 269696;
}
_END_
	isa-ok $parsed, Q{Root};
}, Q{Babbage problem};

subtest {
	plan 1;

	my $parsed = $pt.tidy( Q:to[_END_] );
my $secret = q:to/END/;
    This task is to implement a program for encryption and decryption
    of plaintext using the simple alphabet of the Baconian cipher or
    some other kind of representation of this alphabet (make anything
    signify anything). This example will work with anything in the
    ASCII range... even code! $r%_-^&*(){}+~ #=`/\';*1234567890"'
    END
 
my $text = q:to/END/;
    Bah. It isn't really practical to use typeface changes to encode
    information, it is too easy to tell that there is something going
    on and will attract attention. Font changes with enough regularity
    to encode mesages relatively efficiently would need to happen so
    often it would be obvious that there was some kind of manipulation
    going on. Steganographic encryption where it is obvious that there
    has been some tampering with the carrier is not going to be very
    effective. Not that any of these implementations would hold up to
    serious scrutiny anyway. Anyway, here's a semi-bogus implementation
    that hides information in white space. The message is hidden in this
    paragraph of text. Yes, really. It requires a fairly modern file
    viewer to display (not display?) the hidden message, but that isn't
    too unlikely any more. It may be stretching things to call this a
    Bacon cipher, but I think it falls within the spirit of the task,
    if not the exact definition.
    END
#'
my @enc = "﻿", "​";
my %dec = @enc.pairs.invert;
 
sub encode ($c) { @enc[($c.ord).fmt("%07b").comb].join('') }
 
sub hide ($msg is copy, $text) { 
    $msg ~= @enc[0] x (0 - ($msg.chars % 8)).abs;
    my $head = $text.substr(0,$msg.chars div 8);
    my $tail = $text.substr($msg.chars div 8, *-1);
    ($head.comb «~» $msg.comb(/. ** 8/)).join('') ~ $tail;
}
 
sub reveal ($steg) {
    join '', map { :2(%dec{$_.comb}.join('')).chr }, 
    $steg.subst( /\w | <punct> | " " | "\n" /, '', :g).comb(/. ** 7/);
}
 
my $hidden = join '', map  { .&encode }, $secret.comb;
 
my $steganography = hide $hidden, $text;
 
say "Steganograpic message hidden in text:";
say $steganography;
 
say '*' x 70;
 
say "Hidden message revealed:";
say reveal $steganography;
_END_
	isa-ok $parsed, Q{Root};
}, Q{Bacon cipher};

subtest {
	plan 4;

	subtest {
		plan 1;

		my $parsed = $pt.tidy( Q:to[_END_] );
sub balanced($s) {
    my $l = 0;
    for $s.comb {
        when "]" {
            --$l;
            return False if $l < 0;
        }
        when "[" {
            ++$l;
        }
    }
    return $l == 0;
}
 
my $n = prompt "Number of brackets";
my $s = (<[ ]> xx $n).flat.pick(*).join;
say "$s {balanced($s) ?? "is" !! "is not"} well-balanced"
_END_
		isa-ok $parsed, Q{Root};
	}, Q{version 1};

	subtest {
		plan 1;

		my $parsed = $pt.tidy( Q:to[_END_] );
sub balanced($s) {
    .none < 0 and .[*-1] == 0
        given [\+] '\\' «leg« $s.comb;
}
 
my $n = prompt "Number of bracket pairs: ";
my $s = <[ ]>.roll($n*2).join;
say "$s { balanced($s) ?? "is" !! "is not" } well-balanced"
_END_
		isa-ok $parsed, Q{Root};
	}, Q{version 2};

	subtest {
		plan 1;

		my $parsed = $pt.tidy( Q:to[_END_] );
sub balanced($_ is copy) {
    Nil while s:g/'[]'//;
    $_ eq '';
}
 
my $n = prompt "Number of bracket pairs: ";
my $s = <[ ]>.roll($n*2).join;
say "$s is", ' not' x not balanced($s), " well-balanced";
_END_
		isa-ok $parsed, Q{Root};
	}, Q{version 3};

	subtest {
		plan 1;

		my $parsed = $pt.tidy( Q:to[_END_] );
grammar BalBrack { token TOP { '[' <TOP>* ']' } }
 
my $n = prompt "Number of bracket pairs: ";
my $s = ('[' xx $n, ']' xx $n).flat.pick(*).join;
say "$s { BalBrack.parse($s) ?? "is" !! "is not" } well-balanced";
_END_
		isa-ok $parsed, Q{Root};
	}, Q{version 4};
}, Q{Balanced brackets};

subtest {
	plan 1;

	my $parsed = $pt.tidy( Q:to[_END_] );
class BT {
    has @.coeff;
 
    my %co2bt = '-1' => '-', '0' => '0', '1' => '+';
    my %bt2co = %co2bt.invert;
 
    multi method new (Str $s) {
	self.bless(*, coeff => %bt2co{$s.flip.comb});
    }
    multi method new (Int $i where $i >= 0) {
	self.bless(*, coeff => carry $i.base(3).comb.reverse);
    }
    multi method new (Int $i where $i < 0) {
	self.new(-$i).neg;
    }
 
    method Str () { %co2bt{@!coeff}.join.flip }
    method Int () { [+] @!coeff Z* (1,3,9...*) }
 
    multi method neg () {
	self.new: coeff => carry self.coeff X* -1;
    }
}
 
sub carry (*@digits is copy) {
    loop (my $i = 0; $i < @digits; $i++) {
	while @digits[$i] < -1 { @digits[$i] += 3; @digits[$i+1]--; }
	while @digits[$i] > 1  { @digits[$i] -= 3; @digits[$i+1]++; }
    }
    pop @digits while @digits and not @digits[*-1];
    @digits;
}
 
multi prefix:<-> (BT $x) { $x.neg }
 
multi infix:<+> (BT $x, BT $y) {
    my ($b,$a) = sort +*.coeff, $x, $y;
    BT.new: coeff => carry $a.coeff Z+ $b.coeff, 0 xx *;
}
 
multi infix:<-> (BT $x, BT $y) { $x + $y.neg }
 
multi infix:<*> (BT $x, BT $y) {
    my @x = $x.coeff;
    my @y = $y.coeff;
    my @z = 0 xx @x+@y-1;
    my @safe;
    for @x -> $xd {
	@z = @z Z+ (@y X* $xd), 0 xx *;
	@safe.push: @z.shift;
    }
    BT.new: coeff => carry @safe, @z;
}
 
my $a = BT.new: "+-0++0+";
my $b = BT.new: -436;
my $c = BT.new: "+-++-";
my $x = $a * ( $b - $c );
 
say 'a == ', $a.Int;
say 'b == ', $b.Int;
say 'c == ', $c.Int;
say "a × (b − c) == ", ~$x, ' == ', $x.Int;
_END_
	isa-ok $parsed, Q{Root};
}, Q{Balanced ternary};

subtest {
	plan 1;

	# XXX Make up a 'Image::PNG::Portable' class
	my $parsed = $pt.tidy( Q:to[_END_] );
class Image::PNG::Portable { has ( $.width, $.height ); method set { }; method write { } }
#use Image::PNG::Portable;
 
my ($w, $h) = (640, 640);
 
my $png = Image::PNG::Portable.new: :width($w), :height($h);
 
my ($x, $y) = (0, 0);
 
for ^2e5 {
    my $r = 100.rand;
    ($x, $y) = do given $r {
        when  $r <=  1 { (                     0,              0.16 * $y       ) }
        when  $r <=  8 { ( 0.20 * $x - 0.26 * $y,  0.23 * $x + 0.22 * $y + 1.60) }
        when  $r <= 15 { (-0.15 * $x + 0.28 * $y,  0.26 * $x + 0.24 * $y + 0.44) }
        default        { ( 0.85 * $x + 0.04 * $y, -0.04 * $x + 0.85 * $y + 1.60) }
    };
    $png.set(($w / 2 + $x * 60).Int, $h - ($y * 60).Int, 0, 255, 0);
}
 
$png.write: 'Barnsley-fern-perl6.png';
_END_
	isa-ok $parsed, Q{Root};
}, Q{Barnsley fern};

subtest {
	plan 1;

	my $parsed = $pt.tidy( Q:to[_END_] );
sub MAIN {
    my $buf = slurp("/tmp/favicon.ico", :bin);
    say buf-to-Base64($buf);
}
 
my @base64map = 'A' .. 'Z', 'a' .. 'z', ^10, '+', '/';
 
sub buf-to-Base64($buf) {
    join '', gather for $buf.list -> $a, $b = [], $c = [] {
        my $triplet = ($a +< 16) +| ($b +< 8) +| $c;
        take @base64map[($triplet +> (6 * 3)) +& 0x3F];
        take @base64map[($triplet +> (6 * 2)) +& 0x3F];
        if $c.elems {
            take @base64map[($triplet +> (6 * 1)) +& 0x3F];
            take @base64map[($triplet +> (6 * 0)) +& 0x3F];
        }
        elsif $b.elems {
            take @base64map[($triplet +> (6 * 1)) +& 0x3F];
            take '=';
        }
        else { take '==' }
    }
}
_END_
	isa-ok $parsed, Q{Root};
}, Q{Base64 encode data};

subtest {
	plan 1;

	my $parsed = $pt.tidy( Q:to[_END_] );
sub benford(@a) { bag +« flat @a».comb: /<( <[ 1..9 ]> )> <[ , . \d ]>*/ }
 
sub show(%distribution) {
    printf "%9s %9s  %s\n", <Actual Expected Deviation>;
    for 1 .. 9 -> $digit {
        my $actual = %distribution{$digit} * 100 / [+] %distribution.values;
        my $expected = (1 + 1 / $digit).log(10) * 100;
        printf "%d: %5.2f%% | %5.2f%% | %.2f%%\n",
          $digit, $actual, $expected, abs($expected - $actual);
    }
}
 
multi MAIN($file) { show benford $file.IO.lines }
multi MAIN() { show benford ( 1, 1, 2, *+* ... * )[^1000] }
_END_
	isa-ok $parsed, Q{Root};
}, Q{Benford's law};

subtest {
	plan 3;

	subtest {
		plan 1;

		my $parsed = $pt.tidy( Q:to[_END_] );
sub bernoulli($n) {
    my @a;
    for 0..$n -> $m {
        @a[$m] = FatRat.new(1, $m + 1);
        for reverse 1..$m -> $j {
          @a[$j - 1] = $j * (@a[$j - 1] - @a[$j]);
        }
    }
    return @a[0];
}
 
constant @bpairs = grep *.value.so, ($_ => bernoulli($_) for 0..60);
 
my $width = [max] @bpairs.map: *.value.numerator.chars;
my $form = "B(%2d) = \%{$width}d/%d\n";
 
printf $form, .key, .value.nude for @bpairs;
_END_
		isa-ok $parsed, Q{Root};
	}, Q{version 1};

	subtest {
		plan 1;

		my $parsed = $pt.tidy( Q:to[_END_] );
constant bernoulli = gather {
    my @a;
    for 0..* -> $m {
        @a = FatRat.new(1, $m + 1),
                -> $prev {
                    my $j = @a.elems;
                    $j * (@a.shift - $prev);
                } ... { not @a.elems }
        take $m => @a[*-1] if @a[*-1];
    }
}
 
constant @bpairs = bernoulli[^52];
 
my $width = [max] @bpairs.map: *.value.numerator.chars;
my $form = "B(%d)\t= \%{$width}d/%d\n";
 
printf $form, .key, .value.nude for @bpairs;
_END_
		isa-ok $parsed, Q{Root};
	}, Q{version 2};

	subtest {
		plan 1;

		my $parsed = $pt.tidy( Q:to[_END_] );
my sub infix:<bop>(\prev,\this) { this.key => this.key * (this.value - prev.value) }
 
constant bernoulli = grep *.value, map { (.key => .value.[*-1]) }, do
        0 => [FatRat.new(1,1)],
        -> (:key($pm),:value(@pa)) {
             $pm + 1 => [ map *.value, [\bop] ($pm + 2 ... 1) Z=> FatRat.new(1, $pm + 2), @pa ];
        } ... *;
_END_
		isa-ok $parsed, Q{Root};
	}, Q{version 3};
}, Q{Balanced brackets};

subtest {
	plan 1;

	my $parsed = $pt.tidy( Q:to[_END_] );
sub best-shuffle(Str $orig) {
 
    my @s = $orig.comb;
    my @t = @s.pick(*);
 
    for ^@s -> $i {
        for ^@s -> $j {
            if $i != $j and @t[$i] ne @s[$j] and @t[$j] ne @s[$i] {
                @t[$i, $j] = @t[$j, $i];
                last;
            }
        }
    }
 
    my $count = 0;
    for @t.kv -> $k,$v {
        ++$count if $v eq @s[$k]
    }
 
    return (@t.join, $count);
}
 
printf "%s, %s, (%d)\n", $_, best-shuffle $_
    for <abracadabra seesaw elk grrrrrr up a>;
_END_
	isa-ok $parsed, Q{Root};
}, Q{Best shuffle};

subtest {
	plan 1;

	my $parsed = $pt.tidy( Q:to[_END_] );
say .fmt("%b") for 5, 50, 9000;
_END_
	isa-ok $parsed, Q{Root};
}, Q{Binary digits};

subtest {
	plan 2;

	subtest {
		plan 1;

		my $parsed = $pt.tidy( Q:to[_END_] );
###sub search (@a, $x --> Int) {
###    binary_search { $x cmp @a[$^i] }, 0, @a.end
###}
###
###sub binary_search (&p, Int $lo is copy, Int $hi is copy --> Int) {
###    until $lo > $hi {
###        my Int $mid = ($lo + $hi) div 2;
###        given p $mid {
###            when -1 { $hi = $mid - 1; } 
###            when  1 { $lo = $mid + 1; }
###            default { return $mid;    }
###        }
###    }
###    fail;
###}
_END_
		isa-ok $parsed, Q{Root};
	}, Q{version 1};

	subtest {
		plan 1;

		my $parsed = $pt.tidy( Q:to[_END_] );
###sub binary_search (&p, Int $lo, Int $hi --> Int) {
###    $lo <= $hi or fail;
###    my Int $mid = ($lo + $hi) div 2;
###    given p $mid {
###        when -1 { binary_search &p, $lo,      $mid - 1 } 
###        when  1 { binary_search &p, $mid + 1, $hi      }
###        default { $mid                                 }
###    }
###}
_END_
		isa-ok $parsed, Q{Root};
	}, Q{version 2};
}, Q{Binary search};

subtest {
	plan 1;

	my $parsed = $pt.tidy( Q:to[_END_] );
# Perl 6 is perfectly fine with NUL *characters* in strings:
 
my Str $s = 'nema' ~ 0.chr ~ 'problema!';
say $s;
 
# However, Perl 6 makes a clear distinction between strings
# (i.e. sequences of characters), like your name, or …
my Str $str = "My God, it's full of chars!";
# … and sequences of bytes (called Bufs), for example a PNG image, or …
my Buf $buf = Buf.new(255, 0, 1, 2, 3);
say $buf;
 
# Strs can be encoded into Bufs …
my Buf $this = 'foo'.encode('ascii');
# … and Bufs can be decoded into Strs …
my Str $that = $this.decode('ascii');
 
# So it's all there. Nevertheless, let's solve this task explicitly
# in order to see some nice language features:
 
# We define a class …
class ByteStr {
    # … that keeps an array of bytes, and we delegate some
    # straight-forward stuff directly to this attribute:
    # (Note: "has byte @.bytes" would be nicer, but that is
    # not yet implemented in rakudo or niecza.)
    has Int @.bytes handles(< Bool elems gist push >);
 
    # A handful of methods …
    method clone() {
        self.new(:@.bytes);
    }
 
    method substr(Int $pos, Int $length) {
        self.new(:bytes(@.bytes[$pos .. $pos + $length - 1]));
    }
 
    method replace(*@substitutions) {
        my %h = @substitutions;
        @.bytes.=map: { %h{$_} // $_ }
    }
}
 
# A couple of operators for our new type:
multi infix:<cmp>(ByteStr $x, ByteStr $y) { $x.bytes cmp $y.bytes }
multi infix:<~>  (ByteStr $x, ByteStr $y) { ByteStr.new(:bytes($x.bytes, $y.bytes)) }
 
# create some byte strings (destruction not needed due to garbage collection)
my ByteStr $b0 = ByteStr.new;
my ByteStr $b1 = ByteStr.new(:bytes( 'foo'.ords, 0, 10, 'bar'.ords ));
 
# assignment ($b1 and $b2 contain the same ByteStr object afterwards):
my ByteStr $b2 = $b1;
 
# comparing:
say 'b0 cmp b1 = ', $b0 cmp $b1;
say 'b1 cmp b2 = ', $b1 cmp $b2;
 
# cloning:
my $clone = $b1.clone;
$b1.replace('o'.ord => 0);
say 'b1 = ', $b1;
say 'b2 = ', $b2;
say 'clone = ', $clone;
 
# to check for (non-)emptiness we evaluate the ByteStr in boolean context:
say 'b0 is ', $b0 ?? 'not empty' !! 'empty';
say 'b1 is ', $b1 ?? 'not empty' !! 'empty';
 
# appending a byte:
$b1.push: 123;
 
# extracting a substring:
my $sub = $b1.substr(2, 4);
say 'sub = ', $sub;
 
# replacing a byte:
$b2.replace(102 => 103);
say $b2;
 
# joining:
my ByteStr $b3 = $b1 ~ $sub;
say 'joined = ', $b3;
_END_
	isa-ok $parsed, Q{Root};
}, Q{Binary strings};

subtest {
	plan 1;

	# XXX class Digest::SHA is recreated
	my $parsed = $pt.tidy( Q:to[_END_] );
###my $bitcoin-address = rx/
###    <+alnum-[0IOl]> ** 26..*  # an address is at least 26 characters long
###    <?{
###        class Digest::SHA { sub sha256 is export { } }
###        #use Digest::SHA;
###        .subbuf(21, 4) eqv sha256(sha256 .subbuf(0, 21)).subbuf(0, 4) given
###        Blob.new: <
###            1 2 3 4 5 6 7 8 9
###            A B C D E F G H   J K L M N   P Q R S T U V W X Y Z
###            a b c d e f g h i j k   m n o p q r s t u v w x y z
###        >.pairs.invert.hash{$/.comb}
###        .reduce(* * 58 + *)
###        .polymod(256 xx 24)
###        .reverse;
###    }>
###/;

###say "Here is a bitcoin address: 1AGNa15ZQXAZUgFiqJ2i7Z2DPU2J6hW62i" ~~ $bitcoin-address;
_END_
	isa-ok $parsed, Q{Root};
}, Q{Bitcoin validation};

subtest {
	plan 1;

	# XXX class Digest::SHA is recreated
	my $parsed = $pt.tidy( Q:to[_END_] );
###use SSL::Digest;
### 
###constant BASE58 = <
###      1 2 3 4 5 6 7 8 9
###    A B C D E F G H   J K L M N   P Q R S T U V W X Y Z
###    a b c d e f g h i j k   m n o p q r s t u v w x y z
###>;
### 
###sub encode(Int $n) {
###    $n < BASE58 ??
###    BASE58[$n]  !!
###    encode($n div 58) ~ BASE58[$n % 58]
###}
### 
###sub public_point_to_address(Int $x is copy, Int $y is copy) {
###    my @bytes;
###    for 1 .. 32 { push @bytes, $y % 256; $y div= 256 }
###    for 1 .. 32 { push @bytes, $x % 256; $x div= 256 }
###    my $hash = rmd160 sha256 Blob.new: 4, @bytes.reverse;
###    my $checksum = sha256(sha256 Blob.new: 0, $hash.list).subbuf: 0, 4;
###    encode reduce * * 256 + * , 0, ($hash, $checksum)».list 
###}
### 
###say public_point_to_address
###0x50863AD64A87AE8A2FE83C1AF1A8403CB53F53E486D8511DAD8A04887E5B2352,
###0x2CD470243453A299FA9E77237716103ABC11A1DF38855ED6F2EE187E9C582BA6;
_END_
	isa-ok $parsed, Q{Root};
}, Q{Bitcoin public point to address};

# vim: ft=perl6
