use v6;

use nqp;
use Test;
use Perl6::Tidy;

plan 1;

my $pt = Perl6::Tidy.new;

subtest {
	plan 4;

	subtest {
		plan 2;

		my $parsed = $pt.tidy( Q{1 + 1} );
		isa-ok $parsed, 'Perl6::Tidy::Root';
		is $parsed.child.elems, 1;
	}, Q{add};

	subtest {
		plan 2;

		my $parsed = $pt.tidy( Q{1 - 1} );
		isa-ok $parsed, 'Perl6::Tidy::Root';
		is $parsed.child.elems, 1;
	}, Q{subtract};

	subtest {
		plan 2;

		my $parsed = $pt.tidy( Q{1 * 1} );
		isa-ok $parsed, 'Perl6::Tidy::Root';
		is $parsed.child.elems, 1;
	}, Q{multiply};

	subtest {
		plan 2;

		my $parsed = $pt.tidy( Q{1 / 1} );
		isa-ok $parsed, 'Perl6::Tidy::Root';
		is $parsed.child.elems, 1;
	}, Q{divide};
}, Q{asmd};

# vim: ft=perl6
