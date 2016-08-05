use v6;

use Test;
use Perl6::Tidy;

plan 9;

my $pt = Perl6::Tidy.new;
#my $*TRACE = 1;
#my $*DEBUG = 1;

#my $*TRACE = 1;
subtest {
	plan 10;

	subtest {
		plan 5;

		ok 1, "Test zero, once the dumper is ready.";
		subtest {
			plan 1;

			my $parsed = $pt.get-tree( Q{0} );
			isa-ok $parsed, Q{Perl6::Document};
		}, Q{Zero};

		subtest {
			plan 1;

			my $parsed = $pt.get-tree( Q{1} );
			isa-ok $parsed, Q{Perl6::Document};
		}, Q{positive};

		subtest {
			plan 1;

			my $parsed = $pt.get-tree( Q{-1} );
			isa-ok $parsed, Q{Perl6::Document};
		}, Q{negative};

		subtest {
			plan 1;

			my $parsed = $pt.get-tree( Q{1_1} );
			isa-ok $parsed, Q{Perl6::Document};
		}, Q{underscores};
	}, Q{decimal};

	subtest {
		plan 3;

		subtest {
			plan 1;

			my $parsed = $pt.get-tree( Q{0b0} );
			isa-ok $parsed, Q{Perl6::Document};
		}, Q{zero};

		subtest {
			plan 1;

			my $parsed = $pt.get-tree( Q{0b1} );
			isa-ok $parsed, Q{Perl6::Document};
		}, Q{1};

		subtest {
			plan 1;

			my $parsed = $pt.get-tree( Q{-0b1} );
			isa-ok $parsed, Q{Perl6::Document};
		}, Q{-1};
	}, Q{binary};

	subtest {
		plan 3;

		subtest {
			plan 1;

			my $parsed = $pt.get-tree( Q{0o0} );
			isa-ok $parsed, Q{Perl6::Document};
		}, Q{zero};

		subtest {
			plan 1;

			my $parsed = $pt.get-tree( Q{0o1} );
			isa-ok $parsed, Q{Perl6::Document};
		}, Q{1};

		subtest {
			plan 1;

			my $parsed = $pt.get-tree( Q{-0o1} );
			isa-ok $parsed, Q{Perl6::Document};
		}, Q{-1};
	}, Q{octal};

	subtest {
		plan 3;

		subtest {
			plan 1;

			my $parsed = $pt.get-tree( Q{0d0} );
			isa-ok $parsed, Q{Perl6::Document};
		}, Q{zero};

		subtest {
			plan 1;

			my $parsed = $pt.get-tree( Q{0d1} );
			isa-ok $parsed, Q{Perl6::Document};
		}, Q{1};

		subtest {
			plan 1;

			my $parsed = $pt.get-tree( Q{-0d1} );
			isa-ok $parsed, Q{Perl6::Document};
		}, Q{-1};
	}, Q{explicit decimal};

	subtest {
		plan 3;

		subtest {
			plan 1;

			my $parsed = $pt.get-tree( Q{0} );
			isa-ok $parsed, Q{Perl6::Document};
		}, Q{zero};

		subtest {
			plan 1;

			my $parsed = $pt.get-tree( Q{1} );
			isa-ok $parsed, Q{Perl6::Document};
		}, Q{1};

		subtest {
			plan 1;

			my $parsed = $pt.get-tree( Q{-1} );
			isa-ok $parsed, Q{Perl6::Document};
		}, Q{-1};
	}, Q{implicit decimal};

	subtest {
		plan 3;

		subtest {
			plan 1;

			my $parsed = $pt.get-tree( Q{0x0} );
			isa-ok $parsed, Q{Perl6::Document};
		}, Q{zero};

		subtest {
			plan 1;

			my $parsed = $pt.get-tree( Q{0x1} );
			isa-ok $parsed, Q{Perl6::Document};
		}, Q{1};

		subtest {
			plan 1;

			my $parsed = $pt.get-tree( Q{-0x1} );
			isa-ok $parsed, Q{Perl6::Document};
		}, Q{-1};
	}, Q{hexadecimal};

	subtest {
		plan 3;

		subtest {
			plan 1;

			my $parsed = $pt.get-tree( Q{:13(0)} );
			isa-ok $parsed, Q{Perl6::Document};
		}, Q{zero};

		subtest {
			plan 1;

			my $parsed = $pt.get-tree( Q{:13(1)} );
			isa-ok $parsed, Q{Perl6::Document};
		}, Q{1};

		subtest {
			plan 1;

			my $parsed = $pt.get-tree( Q{:13(-1)} );
			isa-ok $parsed, Q{Perl6::Document};
		}, Q{-1};
	}, Q{base-13};

	subtest {
		plan 5;

		subtest {
			plan 1;

			my $parsed = $pt.get-tree( Q{0.0} );
			isa-ok $parsed, Q{Perl6::Document};
		}, Q{zero};

		subtest {
			plan 1;

			my $parsed = $pt.get-tree( Q{0.1} );
			isa-ok $parsed, Q{Perl6::Document};
		}, Q{0.1};

		subtest {
			plan 1;

			my $parsed = $pt.get-tree( Q{.1} );
			isa-ok $parsed, Q{Perl6::Document};
		}, Q{.1};

		subtest {
			plan 1;

			my $parsed = $pt.get-tree( Q{1.0} );
			isa-ok $parsed, Q{Perl6::Document};
		}, Q{1.0};

		subtest {
			plan 1;

			my $parsed = $pt.get-tree( Q{-1.0} );
			isa-ok $parsed, Q{Perl6::Document};
		}, Q{-1.0};
	}, Q{rational};

	subtest {
		plan 6;

		subtest {
			plan 1;

			my $parsed = $pt.get-tree( Q{0e0} );
			isa-ok $parsed, Q{Perl6::Document};
		}, Q{zero};

		subtest {
			plan 1;

			my $parsed = $pt.get-tree( Q{0.0e0} );
			isa-ok $parsed, Q{Perl6::Document};
		}, Q{rational zero};

		subtest {
			plan 1;

			my $parsed = $pt.get-tree( Q{.1e0} );
			isa-ok $parsed, Q{Perl6::Document};
		}, Q{rational .1};

		subtest {
			plan 1;

			my $parsed = $pt.get-tree( Q{0.1e0} );
			isa-ok $parsed, Q{Perl6::Document};
		}, Q{rational 0.1};

		subtest {
			plan 1;

			my $parsed = $pt.get-tree( Q{1e0} );
			isa-ok $parsed, Q{Perl6::Document};
		}, Q{1.0e0};

		subtest {
			plan 1;

			my $parsed = $pt.get-tree( Q{-1e0} );
			isa-ok $parsed, Q{Perl6::Document};
		}, Q{-1.0e0};
	}, Q{Num};

	subtest {
		plan 3;

		subtest {
			plan 1;

			my $parsed = $pt.get-tree( Q{0i} );
			isa-ok $parsed, Q{Perl6::Document};
		}, Q{0i};

		subtest {
			plan 1;

			my $parsed = $pt.get-tree( Q{1i} );
			isa-ok $parsed, Q{Perl6::Document};
		}, Q{11};

		subtest {
			plan 1;

			my $parsed = $pt.get-tree( Q{-1i} );
			isa-ok $parsed, Q{Perl6::Document};
		}, Q{-11};
	}, Q{imaginary};
}, Q{integer};

subtest {
	plan 5;

	subtest {
		plan 1;

		my $parsed = $pt.get-tree( Q{'Hello, world!'} );
		isa-ok $parsed, Q{Perl6::Document};
	}, Q{single quote};

	subtest {
		plan 2;

		subtest {
			plan 1;

			my $parsed = $pt.get-tree( Q{"Hello, world!"} );
			isa-ok $parsed, Q{Perl6::Document};
		}, Q{uninterpolated};

		subtest {
			plan 1;

			my $parsed = $pt.get-tree(
				Q{"Hello, {'world'}!"}
			);
			isa-ok $parsed, Q{Perl6::Document};
		}, Q{interpolated};
	}, Q{double quote};

	subtest {
		plan 2;

		subtest {
			plan 1;

			my $parsed = $pt.get-tree(
				Q{Q{Hello, world!}}
			);
			isa-ok $parsed, Q{Perl6::Document};
		}, Q{Q{} (only uninterpolated)};

		subtest {
			subtest {
				plan 1;

				my $parsed = $pt.get-tree(
					Q{q[Hello, world!]}
				);
				isa-ok $parsed, Q{Perl6::Document};
			}, Q{unescaped};

			subtest {
				plan 1;

				my $parsed = $pt.get-tree(
					Q{q[Hello\, world!]}
				);
				isa-ok $parsed, Q{Perl6::Document};
			}, Q{escaped};
		}, Q{q[]};
	}, Q{q{}};

	subtest {
		plan 2;

		subtest {
			plan 1;

			my $parsed = $pt.get-tree(
				Q{qq[Hello, world!]}
			);
			isa-ok $parsed, Q{Perl6::Document};
		}, Q{uninterpolated};

		subtest {
			plan 1;

			my $parsed = $pt.get-tree(
				Q{qq[Hello, {'world'}!]}
			);
			isa-ok $parsed, Q{Perl6::Document};
		}, Q{interpolated};
	}, Q{qq{}};

	subtest {
		plan 2;

		subtest {
			plan 1;

			my $parsed = $pt.get-tree(
				Q{q:to/END/
Hello world!
END}
			);
			isa-ok $parsed, Q{Perl6::Document};
		}, Q{q:to/END/, no spaces};

		subtest {
			plan 1;

			my $parsed = $pt.get-tree(
				Q{q:to/END/
  Hello world!
  END}
			);
			isa-ok $parsed, Q{Perl6::Document};
		}, Q{q:to/END/, spaces};
	}, Q{q:to[]};
}, Q{string};

subtest {
	plan 8;

	subtest {
		plan 1;

		my $parsed = $pt.get-tree( Q{@*ARGS} );
		isa-ok $parsed, Q{Perl6::Document};
	}, Q{@*ARGS (is a global, so available everywhere)};

	subtest {
		plan 1;

		my $parsed = $pt.get-tree( Q{$} );
		isa-ok $parsed, Q{Perl6::Document};
	}, Q{$};

	subtest {
		plan 1;

		my $parsed = $pt.get-tree( Q{$_} );
		isa-ok $parsed, Q{Perl6::Document};
	}, Q{$_};

	subtest {
		plan 1;

		my $parsed = $pt.get-tree( Q{$/} );
		isa-ok $parsed, Q{Perl6::Document};
	}, Q{$/};

	subtest {
		plan 1;

		my $parsed = $pt.get-tree( Q{$!} );
		isa-ok $parsed, Q{Perl6::Document};
	}, Q{$!};

	subtest {
		plan 1;

		my $parsed = $pt.get-tree( Q{$Foo::Bar} );
		isa-ok $parsed, Q{Perl6::Document};
	}, Q{$Foo::Bar};

	subtest {
		plan 1;

		my $parsed = $pt.get-tree( Q{&sum} );
		isa-ok $parsed, Q{Perl6::Document};
	}, Q{&sum};

	todo Q{$Foo::($bar)::Bar (requires a second term) to compile};
	subtest {
		plan 1;

		my $parsed = $pt.get-tree( Q[$Foo::($*GLOBAL)::Bar] );
		isa-ok $parsed, Q{Perl6::Document};
	}, Q[$Foo::($*GLOBAL)::Bar (Need $*GLOBAL in order to compile)];
}, Q{variable};

subtest {
	plan 2;

	subtest {
		plan 1;

		my $parsed = $pt.get-tree( Q{Int} );
		isa-ok $parsed, Q{Perl6::Document};
	}, Q{Int};

	subtest {
		plan 1;

		my $parsed = $pt.get-tree( Q{IO::Handle} );
		isa-ok $parsed, Q{Perl6::Document};
	}, Q{IO::Handle (Two package names)};
}, Q{type};

subtest {
	plan 1;

	subtest {
		plan 1;

		my $parsed = $pt.get-tree( Q{pi} );
		isa-ok $parsed, Q{Perl6::Document};
	}, Q{pi};
}, Q{constant};

subtest {
	plan 1;

	subtest {
		plan 1;

		my $parsed = $pt.get-tree( Q{sum} );
		isa-ok $parsed, Q{Perl6::Document};
	}, Q{sum};
}, Q{function call};

subtest {
	plan 1;

	subtest {
		plan 1;

		my $parsed = $pt.get-tree( Q{()} );
		isa-ok $parsed, Q{Perl6::Document};
	}, Q{circumfix};
}, Q{operator};

subtest {
	plan 1;

	subtest {
		plan 1;

		my $parsed = $pt.get-tree( Q{:foo} );
		isa-ok $parsed, Q{Perl6::Document};
	}, Q{:foo};
}, Q{adverbial-pair};

subtest {
	plan 1;

	subtest {
		plan 1;

		my $parsed = $pt.get-tree( Q{:()} );
		isa-ok $parsed, Q{Perl6::Document};
	}, Q{:()};
}, Q{signature};

# vim: ft=perl6
