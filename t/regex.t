use v6;

use Test;
use Perl6::Tidy;

plan 1;

my $pt = Perl6::Tidy.new;

subtest {
	plan 4;

	subtest {
		plan 1;

		my $parsed = $pt.tidy( Q{/pi/} );
		isa-ok $parsed, 'Perl6::Tidy::Root';
	}, Q{/pi/};

	subtest {
		plan 1;

		my $parsed = $pt.tidy( Q{/<[ p i ]>/} );
		isa-ok $parsed, 'Perl6::Tidy::Root';
	}, Q{/<[ p i ]>/};

	subtest {
		plan 1;

		my $parsed = $pt.tidy( Q{/ \d /} );
		isa-ok $parsed, 'Perl6::Tidy::Root';
	}, Q{/ \d /};

	subtest {
		plan 1;

		my $parsed = $pt.tidy( Q{/ . /} );
		isa-ok $parsed, 'Perl6::Tidy::Root';
	}, Q{/ . /};
}, Q{regex};

# vim: ft=perl6
