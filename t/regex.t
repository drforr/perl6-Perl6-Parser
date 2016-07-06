use v6;

use nqp;
use Test;
use Perl6::Tidy;

plan 1;

my $pt = Perl6::Tidy.new( :debugging(True) );

subtest {
	plan 2;

	subtest {
		plan 1;

		my $parsed = $pt.tidy( Q{/pi/} );
		is $parsed.child.elems, 1;
	}, Q{/pi/};

	subtest {
		plan 1;

		my $parsed = $pt.tidy( Q{/<[ p i ]>/} );
		is $parsed.child.elems, 1;
	}, Q{/<[ p i ]>/};
}, Q{regex};

# vim: ft=perl6
