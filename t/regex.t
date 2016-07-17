use v6;

use Test;
use Perl6::Tidy;

plan 4;

my $pt = Perl6::Tidy.new;

subtest {
	plan 1;

	my $parsed = $pt.tidy( Q{/pi/} );
	isa-ok $parsed, Q{Perl6::Tidy::Root};
}, Q{/pi/};

subtest {
	plan 1;

	my $parsed = $pt.tidy( Q{/<[ p i ]>/} );
	isa-ok $parsed, Q{Perl6::Tidy::Root};
}, Q{/<[ p i ]>/};

subtest {
	plan 1;

	my $parsed = $pt.tidy( Q{/ \d /} );
	isa-ok $parsed, Q{Perl6::Tidy::Root};
}, Q{/ \d /};

subtest {
	plan 1;

	my $parsed = $pt.tidy( Q{/ . /} );
	isa-ok $parsed, Q{Perl6::Tidy::Root};
}, Q{/ . /};

# vim: ft=perl6
