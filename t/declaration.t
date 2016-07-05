use v6;

use nqp;
use Test;
use Perl6::Tidy;

plan 3;

my $pt = Perl6::Tidy.new( :debugging(True) );

subtest {
	subtest {
		plan 3;

		subtest {
			plan 1;

			my $parsed = $pt.tidy( Q{my $a} );
			is $parsed.child.elems, 1;
		}, Q{my $a};

		subtest {
			plan 1;

			my $parsed = $pt.tidy( Q{our $a} );
			is $parsed.child.elems, 1;
		}, Q{our $a};

		todo Q{'anon $a' not implemented yet};
	#	subtest {
	#		plan 1;
	#
	#		my $parsed = $pt.tidy( Q{anon $a} );
	#		is $parsed.child.elems, 1;
	#	}, Q{anon $a};

		subtest {
			plan 1;

			my $parsed = $pt.tidy( Q{state $a} );
			is $parsed.child.elems, 1;
		}, Q{state $a};

		todo Q{'augment $a' not implemented yet};
	#	subtest {
	#		plan 1;
	#
	#		my $parsed = $pt.tidy( Q{augment $a} );
	#		is $parsed.child.elems, 1;
	#	}, Q{augment $a};

		todo Q{'supersede $a' not implemented yet};
	#	subtest {
	#		plan 1;
	#
	#		my $parsed = $pt.tidy( Q{supersede $a} );
	#		is $parsed.child.elems, 1;
	#	}, Q{supersede $a};
	}, Q{untyped};

	subtest {
		subtest {
			plan 1;

			my $parsed = $pt.tidy( Q{my Int $a} );
			is $parsed.child.elems, 1;
		}, Q{my Int $a};
	}, Q{typed};

	subtest {
		subtest {
			plan 1;

			my $parsed = $pt.tidy( Q{my $a where 1} );
			is $parsed.child.elems, 1;
		}, Q{my $a where 1};
	}, Q{constrained};
}, Q{variable};

subtest {
	plan 2;

	subtest {
		plan 1;

		my $parsed = $pt.tidy( Q[sub foo {}] );
		is $parsed.child.elems, 1;
	}, Q{sub foo {}};

	subtest {
		plan 1;

		diag Q[Whitespace sensitivity - 'returns Int{&body}'];
		my $parsed = $pt.tidy( Q[sub foo returns Int {}] );
		is $parsed.child.elems, 1;
	}, Q{sub foo returns Int {}};
}, Q{subroutine};


subtest {
	plan 7;

	subtest {
		plan 2;

		subtest {
			plan 1;

			diag "Interesting, 'unit module foo' is illegal.";
			my $parsed = $pt.tidy( Q[unit module foo;] );
			is $parsed.child.elems, 1;
		}, Q{unit module foo;};

		subtest {
			plan 1;

			my $parsed = $pt.tidy( Q[module foo{}] );
			is $parsed.child.elems, 1;
		}, Q{module foo {}};
	}, q{module};

	subtest {
		plan 2;

		subtest {
			plan 1;

			diag "Interesting, 'unit class foo' is illegal.";
			my $parsed = $pt.tidy( Q[unit class foo;] );
			is $parsed.child.elems, 1;
		}, Q{unit class foo;};

		subtest {
			plan 1;

			my $parsed = $pt.tidy( Q[class foo{}] );
			is $parsed.child.elems, 1;
		}, Q{class foo {}};
	}, Q{class};

	subtest {
		plan 2;

		subtest {
			plan 1;

			diag "Interesting, 'unit role foo' is illegal.";
			my $parsed = $pt.tidy( Q[unit role foo;] );
			is $parsed.child.elems, 1;
		}, Q{unit role foo;};

		subtest {
			plan 1;

			my $parsed = $pt.tidy( Q[role foo{}] );
			is $parsed.child.elems, 1;
		}, Q{role foo {}};
	}, Q{role};

	subtest {
		plan 1;

		diag "There may be a Q[] bug lurking here.";
		my $parsed = $pt.tidy( Q[my regex foo{a}] );
		is $parsed.child.elems, 1;
	}, Q{my regex foo {a} (null regex not allowed)};

	subtest {
		plan 2;

		subtest {
			plan 1;

			my $parsed = $pt.tidy( Q[unit grammar foo;] );
			is $parsed.child.elems, 1;
		}, Q{unit grammar foo;};

		subtest {
			plan 1;

			my $parsed = $pt.tidy( Q[grammar foo{}] );
			is $parsed.child.elems, 1;
		}, Q{grammar foo {}};
	}, Q{grammar};

	subtest {
		plan 1;

		my $parsed = $pt.tidy( Q[my token foo{a}] );
		is $parsed.child.elems, 1;
	}, Q{my token foo {a} (null regex not allowed, must give it content.)};

	subtest {
		plan 1;

		my $parsed = $pt.tidy( Q[my rule foo{a}] );
		is $parsed.child.elems, 1;
	}, Q{my rule foo {a}};
}, Q{braced things};

# vim: ft=perl6
