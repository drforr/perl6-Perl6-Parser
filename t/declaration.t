use v6;

use nqp;
use Test;
use Perl6::Tidy;

plan 2;

my $pt = Perl6::Tidy.new( :debugging(True) );

subtest sub {
	subtest sub {
		plan 3;

		subtest sub {
			plan 1;

			my $parsed = $pt.tidy( Q{my $a} );
			is $parsed.child.elems, 1;
		}, Q{my $a};

		subtest sub {
			plan 1;

			my $parsed = $pt.tidy( Q{our $a} );
			is $parsed.child.elems, 1;
		}, Q{our $a};

		todo Q{'anon $a' not implemented yet};
	#	subtest sub {
	#		plan 1;
	#
	#		my $parsed = $pt.tidy( Q{anon $a} );
	#		is $parsed.child.elems, 1;
	#	}, Q{anon $a};

		subtest sub {
			plan 1;

			my $parsed = $pt.tidy( Q{state $a} );
			is $parsed.child.elems, 1;
		}, Q{state $a};

		todo Q{'augment $a' not implemented yet};
	#	subtest sub {
	#		plan 1;
	#
	#		my $parsed = $pt.tidy( Q{augment $a} );
	#		is $parsed.child.elems, 1;
	#	}, Q{augment $a};

		todo Q{'supersede $a' not implemented yet};
	#	subtest sub {
	#		plan 1;
	#
	#		my $parsed = $pt.tidy( Q{supersede $a} );
	#		is $parsed.child.elems, 1;
	#	}, Q{supersede $a};
	}, Q{untyped};

	subtest sub {
		subtest sub {
			plan 1;

			my $parsed = $pt.tidy( Q{my Int $a} );
			is $parsed.child.elems, 1;
		}, Q{my Int $a};
	}, Q{typed};

	subtest sub {
		subtest sub {
			plan 1;

			my $parsed = $pt.tidy( Q{my $a where 1} );
			is $parsed.child.elems, 1;
		}, Q{my $a where 1};
	}, Q{constrained};
}, Q{variable};

subtest sub {
	subtest sub {
		subtest sub {
			plan 1;

			my $parsed = $pt.tidy( Q[sub foo{}] );
			is $parsed.child.elems, 1;
		}, Q{sub foo {}};
	}, Q{...};
}, Q{subroutine};


subtest sub {
	plan 7;

	subtest sub {
		plan 1;

		my $parsed = $pt.tidy( Q[module foo{}] );
		is $parsed.child.elems, 1;
	}, Q{module foo {}};

	subtest sub {
		plan 1;

		my $parsed = $pt.tidy( Q[class foo{}] );
		is $parsed.child.elems, 1;
	}, Q{class foo {}};

	subtest sub {
		plan 1;

		my $parsed = $pt.tidy( Q[role foo{}] );
		is $parsed.child.elems, 1;
	}, Q{role foo {}};

	subtest sub {
		plan 1;

		my $parsed = $pt.tidy( Q[regex foo{}] );
		is $parsed.child.elems, 1;
	}, Q{regex foo {}};

	subtest sub {
		plan 1;

		my $parsed = $pt.tidy( Q[grammar foo{}] );
		is $parsed.child.elems, 1;
	}, Q{grammar foo {}};

	subtest sub {
		plan 1;

		my $parsed = $pt.tidy( Q[token foo{}] );
		is $parsed.child.elems, 1;
	}, Q{token foo {}};

	subtest sub {
		plan 1;

		my $parsed = $pt.tidy( Q[rule foo{}] );
		is $parsed.child.elems, 1;
	}, Q{rule foo {}};
}, Q{braced things};

# vim: ft=perl6
