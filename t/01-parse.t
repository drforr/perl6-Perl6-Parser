use v6;

use nqp;
use Test;
use Perl6::Tidy;

plan 2;

my $pt = Perl6::Tidy.new( :debugging(True) );

subtest sub {
	plan 2;

	my $parsed = $pt.tidy( q{} );
	isa-ok $parsed, 'Perl6::Tidy::statementlist';
	is $parsed.children.elems, 0;
}, 'Empty file';

subtest sub {
	plan 2;

	subtest sub {
		plan 7;

		subtest sub {
			plan 2;

			subtest sub {
				plan 2;

				my $parsed = $pt.tidy( q{1} );
				isa-ok $parsed, 'Perl6::Tidy::statementlist';
				is $parsed.children.elems, 1;
			}, 'no underscores';

			subtest sub {
				plan 2;

				my $parsed = $pt.tidy( q{1_1} );
				isa-ok $parsed, 'Perl6::Tidy::statementlist';
				is $parsed.children.elems, 1;
			}, 'underscores';
		}, 'decimal';

		subtest sub {
			plan 2;

			my $parsed = $pt.tidy( q{0b1} );
			isa-ok $parsed, 'Perl6::Tidy::statementlist';
			is $parsed.children.elems, 1;
		}, 'binary';

		subtest sub {
			plan 2;

			my $parsed = $pt.tidy( q{0o1} );
			isa-ok $parsed, 'Perl6::Tidy::statementlist';
			is $parsed.children.elems, 1;
		}, 'octal';

		subtest sub {
			plan 2;

			my $parsed = $pt.tidy( q{0o1} );
			isa-ok $parsed, 'Perl6::Tidy::statementlist';
			is $parsed.children.elems, 1;
		}, 'octal';

		subtest sub {
			plan 2;

			my $parsed = $pt.tidy( q{0x1} );
			isa-ok $parsed, 'Perl6::Tidy::statementlist';
			is $parsed.children.elems, 1;
		}, 'hex';

		subtest sub {
			plan 2;

			my $parsed = $pt.tidy( q{:13(1)} );
			isa-ok $parsed, 'Perl6::Tidy::statementlist';
			is $parsed.children.elems, 1;
		}, 'base-13';

		subtest sub {
			plan 2;

			my $parsed = $pt.tidy( q{2i} );
			isa-ok $parsed, 'Perl6::Tidy::statementlist';
			is $parsed.children.elems, 1;
		}, 'imaginary';
	}, 'integer';

	subtest sub {
		plan 3;

		subtest sub {
			plan 2;

			my $parsed = $pt.tidy( q{'Hello, world!'} );
			isa-ok $parsed, 'Perl6::Tidy::statementlist';
			is $parsed.children.elems, 1;
		}, 'single quote';

		subtest sub {
			plan 2;

			subtest sub {
				plan 2;

				my $parsed = $pt.tidy( q{"Hello, world!"} );
				isa-ok $parsed, 'Perl6::Tidy::statementlist';
				is $parsed.children.elems, 1;
			}, 'uninterpolated';

			subtest sub {
				plan 2;

				my $parsed = $pt.tidy( q["Hello, {'world'}!"] );
				isa-ok $parsed, 'Perl6::Tidy::statementlist';
				is $parsed.children.elems, 1;
			}, 'interpolated';
		}, 'double quote';

		subtest sub {
			plan 2;

			subtest sub {
				plan 2;

				my $parsed = $pt.tidy(
					q[q{Hello, {'world'}!}]
				);
				isa-ok $parsed, 'Perl6::Tidy::statementlist';
				is $parsed.children.elems, 1;
			}, 'q{}';

			subtest sub {
				plan 2;

				my $parsed = $pt.tidy(
					q[q[Hello, {'world'}!]]
				);
				isa-ok $parsed, 'Perl6::Tidy::statementlist';
				is $parsed.children.elems, 1;
			}, 'q[]';
		}, 'q{}';
	}, 'string';
}, 'single term';

# vim: ft=perl6
