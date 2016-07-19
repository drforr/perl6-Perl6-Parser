use v6;

use Test;
use Perl6::Tidy;

plan 42;

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

# vim: ft=perl6
