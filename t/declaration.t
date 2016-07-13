use v6;

use Test;
use Perl6::Tidy;

plan 3;

my $pt = Perl6::Tidy.new;

subtest {
	subtest {
		plan 3;

		subtest {
			plan 2;

			my $parsed = $pt.tidy( Q{my $a} );
			isa-ok $parsed, 'Perl6::Tidy::Root';
			is $parsed.child.elems, 1;
		}, Q{my $a};

		subtest {
			plan 2;

			my $parsed = $pt.tidy( Q{our $a} );
			isa-ok $parsed, 'Perl6::Tidy::Root';
			is $parsed.child.elems, 1;
		}, Q{our $a};

		todo Q{'anon $a' not implemented yet, maybe not ever.};

		subtest {
			plan 2;

			my $parsed = $pt.tidy( Q{state $a} );
			isa-ok $parsed, 'Perl6::Tidy::Root';
			is $parsed.child.elems, 1;
		}, Q{state $a};

		todo Q{'augment $a' not implemented yet, maybe not ever.};

		todo Q{'supersede $a' not implemented yet, maybe not ever.};
	}, Q{untyped};

	subtest {
		subtest {
			plan 2;

			my $parsed = $pt.tidy( Q{my Int $a} );
			isa-ok $parsed, 'Perl6::Tidy::Root';
			is $parsed.child.elems, 1;
		}, Q{my Int $a};
	}, Q{typed};

	subtest {
		subtest {
			plan 2;

			my $parsed = $pt.tidy( Q{my $a where 1} );
			isa-ok $parsed, 'Perl6::Tidy::Root';
			is $parsed.child.elems, 1;
		}, Q{my $a where 1};
	}, Q{constrained};
}, Q{variable};

subtest {
	plan 2;

	subtest {
		plan 2;

		my $parsed = $pt.tidy( Q[sub foo {}] );
		isa-ok $parsed, 'Perl6::Tidy::Root';
		is $parsed.child.elems, 1;
	}, Q{sub foo {}};

	subtest {
		plan 2;

		diag Q[Whitespace sensitivity - 'returns Int{&body}'];
		my $parsed = $pt.tidy( Q[sub foo returns Int {}] );
		isa-ok $parsed, 'Perl6::Tidy::Root';
		is $parsed.child.elems, 1;
	}, Q{sub foo returns Int {}};
}, Q{subroutine};

subtest {
	plan 7;

	subtest {
		plan 2;

		subtest {
			plan 2;

			diag "Interesting, 'unit module foo' is illegal.";
			my $parsed = $pt.tidy( Q[unit module foo;] );
			isa-ok $parsed, 'Perl6::Tidy::Root';
			is $parsed.child.elems, 1;
		}, Q{unit module foo;};

		subtest {
			plan 2;

			my $parsed = $pt.tidy( Q[module foo{}] );
			isa-ok $parsed, 'Perl6::Tidy::Root';
			is $parsed.child.elems, 1;
		}, Q{module foo {}};
	}, q{module};

	subtest {
		plan 2;

		subtest {
			plan 2;

			diag "Interesting, 'unit class foo' is illegal.";
			my $parsed = $pt.tidy( Q[unit class foo;] );
			isa-ok $parsed, 'Perl6::Tidy::Root';
			is $parsed.child.elems, 1;
		}, Q{unit class foo;};

		subtest {
			plan 2;

			my $parsed = $pt.tidy( Q[class foo{}] );
			isa-ok $parsed, 'Perl6::Tidy::Root';
			is $parsed.child.elems, 1;
		}, Q{class foo {}};
	}, Q{class};

	subtest {
		plan 2;

		subtest {
			plan 2;

			diag "Interesting, 'unit role foo' is illegal.";
			my $parsed = $pt.tidy( Q[unit role foo;] );
			isa-ok $parsed, 'Perl6::Tidy::Root';
			is $parsed.child.elems, 1;
		}, Q{unit role foo;};

		subtest {
			plan 2;

			my $parsed = $pt.tidy( Q[role foo{}] );
			isa-ok $parsed, 'Perl6::Tidy::Root';
			is $parsed.child.elems, 1;
		}, Q{role foo {}};
	}, Q{role};

	subtest {
		plan 2;

		diag "There may be a Q[] bug lurking here.";
		my $parsed = $pt.tidy( Q[my regex foo{a}] );
		isa-ok $parsed, 'Perl6::Tidy::Root';
		is $parsed.child.elems, 1;
	}, Q{my regex foo {a} (null regex not allowed)};

	subtest {
		plan 2;

		subtest {
			plan 2;

			my $parsed = $pt.tidy( Q[unit grammar foo;] );
			isa-ok $parsed, 'Perl6::Tidy::Root';
			is $parsed.child.elems, 1;
		}, Q{unit grammar foo;};

		subtest {
			plan 2;

			my $parsed = $pt.tidy( Q[grammar foo{}] );
			isa-ok $parsed, 'Perl6::Tidy::Root';
			is $parsed.child.elems, 1;
		}, Q{grammar foo {}};
	}, Q{grammar};

	subtest {
		plan 2;

		my $parsed = $pt.tidy( Q[my token foo{a}] );
		isa-ok $parsed, 'Perl6::Tidy::Root';
		is $parsed.child.elems, 1;
	}, Q{my token foo {a} (null regex not allowed, must give it content.)};

	subtest {
		plan 2;

		my $parsed = $pt.tidy( Q[my rule foo{a}] );
		isa-ok $parsed, 'Perl6::Tidy::Root';
		is $parsed.child.elems, 1;
	}, Q{my rule foo {a}};
}, Q{braced things};

# vim: ft=perl6
