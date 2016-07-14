use v6;

use Test;
use Perl6::Tidy;

plan 9;

my $pt = Perl6::Tidy.new;

subtest {
	plan 9;

	subtest {
		plan 5;

		ok 1, "Test zero, once the dumper is ready.";
		subtest {
			plan 1;

			my $parsed = $pt.tidy( Q{0} );
			isa-ok $parsed, 'Perl6::Tidy::Root';
		}, Q{Zero};

		subtest {
			plan 1;

			my $parsed = $pt.tidy( Q{1} );
			isa-ok $parsed, 'Perl6::Tidy::Root';
		}, Q{positive};

		subtest {
			plan 1;

			my $parsed = $pt.tidy( Q{-1} );
			isa-ok $parsed, 'Perl6::Tidy::Root';
		}, Q{negative};

		subtest {
			plan 1;

			my $parsed = $pt.tidy( Q{1_1} );
			isa-ok $parsed, 'Perl6::Tidy::Root';
		}, Q{underscores};
	}, Q{decimal};

	subtest {
		plan 1;

		my $parsed = $pt.tidy( Q{0b1} );
		isa-ok $parsed, 'Perl6::Tidy::Root';
	}, Q{binary};

	subtest {
		plan 1;

		my $parsed = $pt.tidy( Q{0o1} );
		isa-ok $parsed, 'Perl6::Tidy::Root';
	}, Q{octal};

	subtest {
		plan 1;

		my $parsed = $pt.tidy( Q{0o1} );
		isa-ok $parsed, 'Perl6::Tidy::Root';
	}, Q{octal};

	subtest {
		plan 1;

		my $parsed = $pt.tidy( Q{0x1} );
		isa-ok $parsed, 'Perl6::Tidy::Root';
	}, Q{hex};

	subtest {
		plan 1;

		my $parsed = $pt.tidy( Q{:13(1)} );
		isa-ok $parsed, 'Perl6::Tidy::Root';
	}, Q{base-13};

	subtest {
		plan 1;

		my $parsed = $pt.tidy( Q{1.3} );
		isa-ok $parsed, 'Perl6::Tidy::Root';
	}, Q{rational};

	subtest {
		plan 1;

		my $parsed = $pt.tidy( Q{1e3} );
		isa-ok $parsed, 'Perl6::Tidy::Root';
	}, Q{Num};

	subtest {
		plan 1;

		my $parsed = $pt.tidy( Q{2i} );
		isa-ok $parsed, 'Perl6::Tidy::Root';
	}, Q{imaginary};
}, Q{integer};

subtest {
	plan 5;

	subtest {
		plan 1;

		my $parsed = $pt.tidy( Q{'Hello, world!'} );
		isa-ok $parsed, 'Perl6::Tidy::Root';
	}, Q{single quote};

	subtest {
		plan 2;

		subtest {
			plan 1;

			my $parsed = $pt.tidy( Q{"Hello, world!"} );
			isa-ok $parsed, 'Perl6::Tidy::Root';
		}, Q{uninterpolated};

		subtest {
			plan 1;

			my $parsed = $pt.tidy(
				Q{"Hello, {'world'}!"}
			);
			isa-ok $parsed, 'Perl6::Tidy::Root';
		}, Q{interpolated};
	}, Q{double quote};

	subtest {
		plan 2;

		subtest {
			plan 1;

			my $parsed = $pt.tidy(
				Q{Q{Hello, world!}}
			);
			isa-ok $parsed, 'Perl6::Tidy::Root';
		}, Q{Q{} (only uninterpolated)};

		subtest {
			subtest {
				plan 1;

				my $parsed = $pt.tidy(
					Q{q[Hello, world!]}
				);
				isa-ok $parsed, 'Perl6::Tidy::Root';
			}, Q{unescaped};

			subtest {
				plan 1;

				my $parsed = $pt.tidy(
					Q{q[Hello\, world!]}
				);
				isa-ok $parsed, 'Perl6::Tidy::Root';
			}, Q{escaped};
		}, Q{q[]};
	}, Q{q{}};

	subtest {
		plan 2;

		subtest {
			plan 1;

			my $parsed = $pt.tidy(
				Q{qq[Hello, world!]}
			);
			isa-ok $parsed, 'Perl6::Tidy::Root';
		}, Q{uninterpolated};

		subtest {
			plan 1;

			my $parsed = $pt.tidy(
				Q{qq[Hello, {'world'}!]}
			);
			isa-ok $parsed, 'Perl6::Tidy::Root';
		}, Q{interpolated};
	}, Q{qq{}};

	subtest {
		plan 2;

		subtest {
			plan 1;

			my $parsed = $pt.tidy(
				Q{q:to/END/
Hello world!
END}
			);
			isa-ok $parsed, 'Perl6::Tidy::Root';
		}, Q{q:to/END/, no spaces};

		subtest {
			plan 1;

			my $parsed = $pt.tidy(
				Q{q:to/END/
  Hello world!
  END}
			);
			isa-ok $parsed, 'Perl6::Tidy::Root';
		}, Q{q:to/END/, spaces};
	}, Q{q:to[]};
}, Q{string};

subtest {
	plan 8;

	subtest {
		plan 1;

		my $parsed = $pt.tidy( Q{@*ARGS} );
		isa-ok $parsed, 'Perl6::Tidy::Root';
	}, Q{@*ARGS (is a global, so available everywhere)};

	subtest {
		plan 1;

		my $parsed = $pt.tidy( Q{$} );
		isa-ok $parsed, 'Perl6::Tidy::Root';
	}, Q{$};

	subtest {
		plan 1;

		my $parsed = $pt.tidy( Q{$_} );
		isa-ok $parsed, 'Perl6::Tidy::Root';
	}, Q{$_};

	subtest {
		plan 1;

		my $parsed = $pt.tidy( Q{$/} );
		isa-ok $parsed, 'Perl6::Tidy::Root';
	}, Q{$/};

	subtest {
		plan 1;

		my $parsed = $pt.tidy( Q{$!} );
		isa-ok $parsed, 'Perl6::Tidy::Root';
	}, Q{$!};

	subtest {
		plan 1;

		my $parsed = $pt.tidy( Q{$Foo::Bar} );
		isa-ok $parsed, 'Perl6::Tidy::Root';
	}, Q{$Foo::Bar};

	subtest {
		plan 1;

		my $parsed = $pt.tidy( Q{&sum} );
		isa-ok $parsed, 'Perl6::Tidy::Root';
	}, Q{&sum};

	todo Q{$Foo::($bar)::Bar (requires a second term) to compile};
	subtest {
		plan 1;

		my $parsed = $pt.tidy( Q[$Foo::($*GLOBAL)::Bar] );
		isa-ok $parsed, 'Perl6::Tidy::Root';
	}, Q[$Foo::($*GLOBAL)::Bar (Need $*GLOBAL in order to compile)];
}, Q{variable};

subtest {
	plan 2;

	subtest {
		plan 1;

		my $parsed = $pt.tidy( Q{Int} );
		isa-ok $parsed, 'Perl6::Tidy::Root';
	}, Q{Int};

	subtest {
		plan 1;

		my $parsed = $pt.tidy( Q{IO::Handle} );
		isa-ok $parsed, 'Perl6::Tidy::Root';
	}, Q{IO::Handle (Two package names)};
}, Q{type};

subtest {
	plan 1;

	subtest {
		plan 1;

		my $parsed = $pt.tidy( Q{pi} );
		isa-ok $parsed, 'Perl6::Tidy::Root';
	}, Q{pi};
}, Q{constant};

subtest {
	plan 1;

	subtest {
		plan 1;

		my $parsed = $pt.tidy( Q{sum} );
		isa-ok $parsed, 'Perl6::Tidy::Root';
	}, Q{sum};
}, Q{function call};

subtest {
	plan 1;

	subtest {
		plan 1;

		my $parsed = $pt.tidy( Q{()} );
		isa-ok $parsed, 'Perl6::Tidy::Root';
	}, Q{circumfix};
}, Q{operator};

subtest {
	plan 1;

	subtest {
		plan 1;

		my $parsed = $pt.tidy( Q{:foo} );
		isa-ok $parsed, 'Perl6::Tidy::Root';
	}, Q{:foo};
}, Q{adverbial-pair};

subtest {
	plan 1;

	subtest {
		plan 1;

		my $parsed = $pt.tidy( Q{:()} );
		isa-ok $parsed, 'Perl6::Tidy::Root';
	}, Q{:()};
}, Q{signature};

# vim: ft=perl6
