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
	plan 3;

	subtest {
		plan 1;

		my $parsed = $pt.tidy( Q:to[_END_] );
get.words.sum.say;
_END_
		isa-ok $parsed, Q{Root};
	}, Q{version 1};

	subtest {
		plan 1;

		my $parsed = $pt.tidy( Q:to[_END_] );
say [+] get.words;
_END_
		isa-ok $parsed, Q{Root};
	}, Q{version 2};

	subtest {
		plan 1;

		my $parsed = $pt.tidy( Q:to[_END_] );
my ($a, $b) = $*IN.get.split(" ");
say $a + $b;
_END_
		isa-ok $parsed, Q{Root};
	}, Q{version 3};
}, Q{A + B};

# vim: ft=perl6
