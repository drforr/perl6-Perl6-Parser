use v6;

use Test;
use Perl6::Tidy;

plan 9;

my $pt = Perl6::Tidy.new;

subtest {
	plan 10;

	subtest {
		plan 5;

		ok 1, "Test zero, once the dumper is ready.";
		subtest {
			plan 1;

			my $parsed = $pt.tidy( Q{0} );
			isa-ok $parsed, Q{Root};
		}, Q{Zero};

		subtest {
			plan 1;

			my $parsed = $pt.tidy( Q{1} );
			isa-ok $parsed, Q{Root};
		}, Q{positive};

		subtest {
			plan 1;

			my $parsed = $pt.tidy( Q{-1} );
			isa-ok $parsed, Q{Root};
		}, Q{negative};

		subtest {
			plan 1;

			my $parsed = $pt.tidy( Q{1_1} );
			isa-ok $parsed, Q{Root};
		}, Q{underscores};
	}, Q{decimal};

	subtest {
		plan 2;

		subtest {
			plan 1;

			my $parsed = $pt.tidy( Q{0b0} );
			isa-ok $parsed, Q{Root};
		}, Q{zero};

		subtest {
			plan 1;

			my $parsed = $pt.tidy( Q{0b1} );
			isa-ok $parsed, Q{Root};
		}, Q{1};
	}, Q{binary};

	subtest {
		plan 2;

		subtest {
			plan 1;

			my $parsed = $pt.tidy( Q{0o0} );
			isa-ok $parsed, Q{Root};
		}, Q{zero};

		subtest {
			plan 1;

			my $parsed = $pt.tidy( Q{0o1} );
			isa-ok $parsed, Q{Root};
		}, Q{1};
	}, Q{octal};

	subtest {
		plan 2;

		subtest {
			plan 1;

			my $parsed = $pt.tidy( Q{0d0} );
			isa-ok $parsed, Q{Root};
		}, Q{zero};

		subtest {
			plan 1;

			my $parsed = $pt.tidy( Q{0d1} );
			isa-ok $parsed, Q{Root};
		}, Q{1};
	}, Q{explicit decimal};

	subtest {
		plan 2;

		subtest {
			plan 1;

			my $parsed = $pt.tidy( Q{0} );
			isa-ok $parsed, Q{Root};
		}, Q{zero};

		subtest {
			plan 1;

			my $parsed = $pt.tidy( Q{1} );
			isa-ok $parsed, Q{Root};
		}, Q{1};
	}, Q{implicit decimal};

	subtest {
		plan 2;

		subtest {
			plan 1;

			my $parsed = $pt.tidy( Q{0x0} );
			isa-ok $parsed, Q{Root};
		}, Q{zero};

		subtest {
			plan 1;

			my $parsed = $pt.tidy( Q{0x1} );
			isa-ok $parsed, Q{Root};
		}, Q{1};
	}, Q{hexadecimal};

	subtest {
		plan 2;

		subtest {
			plan 1;

			my $parsed = $pt.tidy( Q{:13(0)} );
			isa-ok $parsed, Q{Root};
		}, Q{zero};

		subtest {
			plan 1;

			my $parsed = $pt.tidy( Q{:13(1)} );
			isa-ok $parsed, Q{Root};
		}, Q{1};
	}, Q{base-13};

	subtest {
		plan 4;

		subtest {
			plan 1;

			my $parsed = $pt.tidy( Q{0.0} );
			isa-ok $parsed, Q{Root};
		}, Q{zero};

		subtest {
			plan 1;

			my $parsed = $pt.tidy( Q{0.1} );
			isa-ok $parsed, Q{Root};
		}, Q{0.1};

		subtest {
			plan 1;

			my $parsed = $pt.tidy( Q{.1} );
			isa-ok $parsed, Q{Root};
		}, Q{.1};

		subtest {
			plan 1;

			my $parsed = $pt.tidy( Q{1.0} );
			isa-ok $parsed, Q{Root};
		}, Q{1.0};
	}, Q{rational};

	subtest {
		plan 5;

		subtest {
			plan 1;

			my $parsed = $pt.tidy( Q{0e0} );
			isa-ok $parsed, Q{Root};
		}, Q{zero};

		subtest {
			plan 1;

			my $parsed = $pt.tidy( Q{0.0e0} );
			isa-ok $parsed, Q{Root};
		}, Q{rational zero};

		subtest {
			plan 1;

			my $parsed = $pt.tidy( Q{.1e0} );
			isa-ok $parsed, Q{Root};
		}, Q{rational .1};

		subtest {
			plan 1;

			my $parsed = $pt.tidy( Q{0.1e0} );
			isa-ok $parsed, Q{Root};
		}, Q{rational 0.1};

		subtest {
			plan 1;

			my $parsed = $pt.tidy( Q{1e0} );
			isa-ok $parsed, Q{Root};
		}, Q{1.0e0};
	}, Q{Num};

	subtest {
		plan 2;

		subtest {
			plan 1;

			my $parsed = $pt.tidy( Q{0i} );
			isa-ok $parsed, Q{Root};
		}, Q{0i};

		subtest {
			plan 1;

			my $parsed = $pt.tidy( Q{1i} );
			isa-ok $parsed, Q{Root};
		}, Q{11};
	}, Q{imaginary};
}, Q{integer};

subtest {
	plan 5;

	subtest {
		plan 1;

		my $parsed = $pt.tidy( Q{'Hello, world!'} );
		isa-ok $parsed, Q{Root};
	}, Q{single quote};

	subtest {
		plan 2;

		subtest {
			plan 1;

			my $parsed = $pt.tidy( Q{"Hello, world!"} );
			isa-ok $parsed, Q{Root};
		}, Q{uninterpolated};

		subtest {
			plan 1;

			my $parsed = $pt.tidy(
				Q{"Hello, {'world'}!"}
			);
			isa-ok $parsed, Q{Root};
		}, Q{interpolated};
	}, Q{double quote};

	subtest {
		plan 2;

		subtest {
			plan 1;

			my $parsed = $pt.tidy(
				Q{Q{Hello, world!}}
			);
			isa-ok $parsed, Q{Root};
		}, Q{Q{} (only uninterpolated)};

		subtest {
			subtest {
				plan 1;

				my $parsed = $pt.tidy(
					Q{q[Hello, world!]}
				);
				isa-ok $parsed, Q{Root};
			}, Q{unescaped};

			subtest {
				plan 1;

				my $parsed = $pt.tidy(
					Q{q[Hello\, world!]}
				);
				isa-ok $parsed, Q{Root};
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
			isa-ok $parsed, Q{Root};
		}, Q{uninterpolated};

		subtest {
			plan 1;

			my $parsed = $pt.tidy(
				Q{qq[Hello, {'world'}!]}
			);
			isa-ok $parsed, Q{Root};
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
			isa-ok $parsed, Q{Root};
		}, Q{q:to/END/, no spaces};

		subtest {
			plan 1;

			my $parsed = $pt.tidy(
				Q{q:to/END/
  Hello world!
  END}
			);
			isa-ok $parsed, Q{Root};
		}, Q{q:to/END/, spaces};
	}, Q{q:to[]};
}, Q{string};

subtest {
	plan 8;

	subtest {
		plan 1;

		my $parsed = $pt.tidy( Q{@*ARGS} );
		isa-ok $parsed, Q{Root};
	}, Q{@*ARGS (is a global, so available everywhere)};

	subtest {
		plan 1;

		my $parsed = $pt.tidy( Q{$} );
		isa-ok $parsed, Q{Root};
	}, Q{$};

	subtest {
		plan 1;

		my $parsed = $pt.tidy( Q{$_} );
		isa-ok $parsed, Q{Root};
	}, Q{$_};

	subtest {
		plan 1;

		my $parsed = $pt.tidy( Q{$/} );
		isa-ok $parsed, Q{Root};
	}, Q{$/};

	subtest {
		plan 1;

		my $parsed = $pt.tidy( Q{$!} );
		isa-ok $parsed, Q{Root};
	}, Q{$!};

	subtest {
		plan 1;

		my $parsed = $pt.tidy( Q{$Foo::Bar} );
		isa-ok $parsed, Q{Root};
	}, Q{$Foo::Bar};

	subtest {
		plan 1;

		my $parsed = $pt.tidy( Q{&sum} );
		isa-ok $parsed, Q{Root};
	}, Q{&sum};

	todo Q{$Foo::($bar)::Bar (requires a second term) to compile};
	subtest {
		plan 1;

		my $parsed = $pt.tidy( Q[$Foo::($*GLOBAL)::Bar] );
		isa-ok $parsed, Q{Root};
	}, Q[$Foo::($*GLOBAL)::Bar (Need $*GLOBAL in order to compile)];
}, Q{variable};

subtest {
	plan 2;

	subtest {
		plan 1;

		my $parsed = $pt.tidy( Q{Int} );
		isa-ok $parsed, Q{Root};
	}, Q{Int};

	subtest {
		plan 1;

		my $parsed = $pt.tidy( Q{IO::Handle} );
		isa-ok $parsed, Q{Root};
	}, Q{IO::Handle (Two package names)};
}, Q{type};

subtest {
	plan 1;

	subtest {
		plan 1;

		my $parsed = $pt.tidy( Q{pi} );
		isa-ok $parsed, Q{Root};
	}, Q{pi};
}, Q{constant};

subtest {
	plan 1;

	subtest {
		plan 1;

		my $parsed = $pt.tidy( Q{sum} );
		isa-ok $parsed, Q{Root};
	}, Q{sum};
}, Q{function call};

subtest {
	plan 1;

	subtest {
		plan 1;

		my $parsed = $pt.tidy( Q{()} );
		isa-ok $parsed, Q{Root};
	}, Q{circumfix};
}, Q{operator};

subtest {
	plan 1;

	subtest {
		plan 1;

		my $parsed = $pt.tidy( Q{:foo} );
		isa-ok $parsed, Q{Root};
	}, Q{:foo};
}, Q{adverbial-pair};

subtest {
	plan 1;

	subtest {
		plan 1;

		my $parsed = $pt.tidy( Q{:()} );
		isa-ok $parsed, Q{Root};
	}, Q{:()};
}, Q{signature};

# vim: ft=perl6
