use v6;

use Test;
use Perl6::Tidy;

plan 3;

my $pt = Perl6::Tidy.new;
#my $*TRACE = 1;
#my $*DEBUG = 1;

subtest {
	plan 3;

	subtest {
		plan 3;

		subtest {
			plan 1;

			my $parsed = $pt.parse-source( Q{my $a} );
			ok $pt.validate( $parsed );
		}, Q{my $a};

		subtest {
			plan 1;

			my $parsed = $pt.parse-source( Q{our $a} );
			ok $pt.validate( $parsed );
		}, Q{our $a};

		todo Q{'anon $a' not implemented yet, maybe not ever.};

		subtest {
			plan 1;

			my $parsed = $pt.parse-source( Q{state $a} );
			ok $pt.validate( $parsed );
		}, Q{state $a};

		todo Q{'augment $a' not implemented yet, maybe not ever.};

		todo Q{'supersede $a' not implemented yet, maybe not ever.};
	}, Q{untyped};

	subtest {
		plan 3;

		subtest {
			plan 1;

			my $parsed = $pt.parse-source( Q{my Int $a} );
			ok $pt.validate( $parsed );
		}, Q{regular};

		subtest {
			plan 1;

			my $parsed = $pt.parse-source( Q{my Int:D $a = 0} );
			ok $pt.validate( $parsed );
		}, Q{defined};

		subtest {
			plan 1;

			my $parsed = $pt.parse-source( Q{my Int:U $a} );
			ok $pt.validate( $parsed );
		}, Q{undefined};
	}, Q{typed};

	subtest {
		plan 1;

		subtest {
			plan 1;

			my $parsed = $pt.parse-source( Q{my $a where 1} );
			ok $pt.validate( $parsed );
		}, Q{my $a where 1};
	}, Q{constrained};
}, Q{variable};

subtest {
	plan 2;

	subtest {
		plan 1;

		my $parsed = $pt.parse-source( Q[sub foo {}] );
		ok $pt.validate( $parsed );
	}, Q{sub foo {}};

	subtest {
		plan 1;

		my $parsed = $pt.parse-source( Q[sub foo returns Int {}] );
		ok $pt.validate( $parsed );
	}, Q{sub foo returns Int {}};
}, Q{subroutine};

subtest {
	plan 7;

	subtest {
		plan 2;

		subtest {
			plan 1;

			my $parsed = $pt.parse-source( Q[unit module foo;] );
			ok $pt.validate( $parsed );
		}, Q{unit module foo;};

		subtest {
			plan 1;

			my $parsed = $pt.parse-source( Q[module foo{}] );
			ok $pt.validate( $parsed );
		}, Q{module foo {}};
	}, q{module};

	subtest {
		plan 2;

		subtest {
			plan 1;

			my $parsed = $pt.parse-source(  Q[unit class foo;] );
			ok $pt.validate( $parsed );
		}, Q{unit class foo;};

		subtest {
			plan 1;

			my $parsed = $pt.parse-source( Q[class foo{}] );
			ok $pt.validate( $parsed );
		}, Q{class foo {}};
	}, Q{class};

	subtest {
		plan 2;

		subtest {
			plan 1;

			my $parsed = $pt.parse-source( Q[unit role foo;] );
			ok $pt.validate( $parsed );
		}, Q{unit role foo;};

		subtest {
			plan 1;

			my $parsed = $pt.parse-source( Q[role foo {}] );
			ok $pt.validate( $parsed );
		}, Q{role foo {}};
	}, Q{role};

	subtest {
		plan 1;

		my $parsed = $pt.parse-source( Q[my regex foo {a}] );
		ok $pt.validate( $parsed );
	}, Q{my regex foo {a} (null regex not allowed)};

	subtest {
		plan 2;

		subtest {
			plan 1;

			my $parsed = $pt.parse-source( Q[unit grammar foo;] );
			ok $pt.validate( $parsed );
		}, Q{unit grammar foo;};

		subtest {
			plan 1;

			my $parsed = $pt.parse-source( Q[grammar foo {}] );
			ok $pt.validate( $parsed );
		}, Q{grammar foo {}};
	}, Q{grammar};

	subtest {
		plan 1;

		my $parsed = $pt.parse-source( Q[my token foo {a}] );
		ok $pt.validate( $parsed );
	}, Q{my token foo {a} (null regex not allowed, must give it content.)};

	subtest {
		plan 1;

		my $parsed = $pt.parse-source( Q[my rule foo {a}] );
		ok $pt.validate( $parsed );
	}, Q{my rule foo {a}};
}, Q{braced things};

# vim: ft=perl6
