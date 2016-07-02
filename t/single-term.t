use v6;

use nqp;
use Test;
use Perl6::Tidy;

plan 2;

my $pt = Perl6::Tidy.new( :debugging(True) );

plan 2;

subtest sub {
	plan 7;

	subtest sub {
		plan 2;

		subtest sub {
			plan 2;

			my $parsed = $pt.tidy( Q{1} );
			isa-ok $parsed, Q{Perl6::Tidy::statementlist};
			is $parsed.children.elems, 1;
		}, Q{no underscores};

		subtest sub {
			plan 2;

			my $parsed = $pt.tidy( Q{1_1} );
			isa-ok $parsed, Q{Perl6::Tidy::statementlist};
			is $parsed.children.elems, 1;
		}, Q{underscores};
	}, Q{decimal};

	subtest sub {
		plan 2;

		my $parsed = $pt.tidy( Q{0b1} );
		isa-ok $parsed, Q{Perl6::Tidy::statementlist};
		is $parsed.children.elems, 1;
	}, Q{binary};

	subtest sub {
		plan 2;

		my $parsed = $pt.tidy( Q{0o1} );
		isa-ok $parsed, Q{Perl6::Tidy::statementlist};
		is $parsed.children.elems, 1;
	}, Q{octal};

	subtest sub {
		plan 2;

		my $parsed = $pt.tidy( Q{0o1} );
		isa-ok $parsed, Q{Perl6::Tidy::statementlist};
		is $parsed.children.elems, 1;
	}, Q{octal};

	subtest sub {
		plan 2;

		my $parsed = $pt.tidy( Q{0x1} );
		isa-ok $parsed, Q{Perl6::Tidy::statementlist};
		is $parsed.children.elems, 1;
	}, Q{hex};

	subtest sub {
		plan 2;

		my $parsed = $pt.tidy( Q{:13(1)} );
		isa-ok $parsed, Q{Perl6::Tidy::statementlist};
		is $parsed.children.elems, 1;
	}, Q{base-13};

	subtest sub {
		plan 2;

		my $parsed = $pt.tidy( Q{2i} );
		isa-ok $parsed, Q{Perl6::Tidy::statementlist};
		is $parsed.children.elems, 1;
	}, Q{imaginary};
}, Q{integer};

subtest sub {
	plan 4;

	subtest sub {
		plan 2;

		my $parsed = $pt.tidy( Q{'Hello, world!'} );
		isa-ok $parsed, Q{Perl6::Tidy::statementlist};
		is $parsed.children.elems, 1;
	}, Q{single quote};

	subtest sub {
		plan 2;

		subtest sub {
			plan 2;

			my $parsed = $pt.tidy( Q{"Hello, world!"} );
			isa-ok $parsed, Q{Perl6::Tidy::statementlist};
			is $parsed.children.elems, 1;
		}, Q{uninterpolated};

		subtest sub {
			plan 2;

			my $parsed = $pt.tidy(
				Q{"Hello, {'world'}!"}
			);
			isa-ok $parsed, 'Perl6::Tidy::statementlist';
			is $parsed.children.elems, 1;
		}, Q{interpolated};
	}, Q{double quote};

	subtest sub {
		plan 2;

		subtest sub {
			plan 2;

			my $parsed = $pt.tidy(
				Q{Q{Hello, world!}}
			);
			isa-ok $parsed, Q{Perl6::Tidy::statementlist};
			is $parsed.children.elems, 1;
		}, Q{Q{} (only uninterpolated)};

		subtest sub {
			subtest sub {
				plan 2;

				my $parsed = $pt.tidy(
					Q{q[Hello, world!]}
				);
				isa-ok $parsed, Q{Perl6::Tidy::statementlist};
				is $parsed.children.elems, 1;
			}, Q{unescaped};

			subtest sub {
				plan 2;

				my $parsed = $pt.tidy(
					Q{q[Hello\, world!]}
				);
				isa-ok $parsed, Q{Perl6::Tidy::statementlist};
				is $parsed.children.elems, 1;
			}, Q{escaped};
		}, Q{q[]};
	}, Q{q{}};

	subtest sub {
		plan 2;

		subtest sub {
			plan 2;

			my $parsed = $pt.tidy(
				Q{qq[Hello, world!]}
			);
			isa-ok $parsed, Q{Perl6::Tidy::statementlist};
			is $parsed.children.elems, 1;
		}, Q{uninterpolated};

		subtest sub {
			plan 2;

			my $parsed = $pt.tidy(
				Q{qq[Hello, {'world'}!]}
			);
			isa-ok $parsed, Q{Perl6::Tidy::statementlist};
			is $parsed.children.elems, 1;
		}, Q{interpolated};
	}, Q{qq{}};
}, Q{string};

# vim: ft=perl6
