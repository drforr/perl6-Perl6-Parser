use v6;

use nqp;
use Test;
use Perl6::Tidy;

plan 1;

my $pt = Perl6::Tidy.new( :debugging(True) );

subtest {
	plan 4;

	subtest {
		plan 2;

		my $parsed = $pt.tidy( Q{/pi/} );
		isa-ok $parsed, 'Perl6::Tidy::Root';
		is $parsed.child.elems, 1;
	}, Q{/pi/};

	subtest {
		plan 2;

		my $parsed = $pt.tidy( Q{/<[ p i ]>/} );
		isa-ok $parsed, 'Perl6::Tidy::Root';
		is $parsed.child.elems, 1;
	}, Q{/<[ p i ]>/};

	subtest {
		plan 2;

		my $parsed = $pt.tidy( Q{/ \d /} );
		isa-ok $parsed, 'Perl6::Tidy::Root';
		is $parsed.child.elems, 1;
	}, Q{/ \d /};

	subtest {
		plan 2;

		my $parsed = $pt.tidy( Q{/ . /} );
		isa-ok $parsed, 'Perl6::Tidy::Root';
		is $parsed.child.elems, 1;
	}, Q{/ . /};
}, Q{regex};

# vim: ft=perl6
