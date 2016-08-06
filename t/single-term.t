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

			my $parsed = $pt.parse-source( Q{0} );
			ok $pt.validate( $parsed );
		}, Q{Zero};

		subtest {
			plan 1;

			my $parsed = $pt.parse-source( Q{1} );
			ok $pt.validate( $parsed );
		}, Q{positive};

		subtest {
			plan 1;

			my $parsed = $pt.parse-source( Q{-1} );
			ok $pt.validate( $parsed );
		}, Q{negative};

		subtest {
			plan 1;

			my $parsed = $pt.parse-source( Q{1_1} );
			ok $pt.validate( $parsed );
		}, Q{underscores};
	}, Q{decimal};

	subtest {
		plan 3;

		subtest {
			plan 1;

			my $parsed = $pt.parse-source( Q{0b0} );
			ok $pt.validate( $parsed );
		}, Q{zero};

		subtest {
			plan 1;

			my $parsed = $pt.parse-source( Q{0b1} );
			ok $pt.validate( $parsed );
		}, Q{1};

		subtest {
			plan 1;

			my $parsed = $pt.parse-source( Q{-0b1} );
			ok $pt.validate( $parsed );
		}, Q{-1};
	}, Q{binary};

	subtest {
		plan 3;

		subtest {
			plan 1;

			my $parsed = $pt.parse-source( Q{0o0} );
			ok $pt.validate( $parsed );
		}, Q{zero};

		subtest {
			plan 1;

			my $parsed = $pt.parse-source( Q{0o1} );
			ok $pt.validate( $parsed );
		}, Q{1};

		subtest {
			plan 1;

			my $parsed = $pt.parse-source( Q{-0o1} );
			ok $pt.validate( $parsed );
		}, Q{-1};
	}, Q{octal};

	subtest {
		plan 3;

		subtest {
			plan 1;

			my $parsed = $pt.parse-source( Q{0d0} );
			ok $pt.validate( $parsed );
		}, Q{zero};

		subtest {
			plan 1;

			my $parsed = $pt.parse-source( Q{0d1} );
			ok $pt.validate( $parsed );
		}, Q{1};

		subtest {
			plan 1;

			my $parsed = $pt.parse-source( Q{-0d1} );
			ok $pt.validate( $parsed );
		}, Q{-1};
	}, Q{explicit decimal};

	subtest {
		plan 3;

		subtest {
			plan 1;

			my $parsed = $pt.parse-source( Q{0} );
			ok $pt.validate( $parsed );
		}, Q{zero};

		subtest {
			plan 1;

			my $parsed = $pt.parse-source( Q{1} );
			ok $pt.validate( $parsed );
		}, Q{1};

		subtest {
			plan 1;

			my $parsed = $pt.parse-source( Q{-1} );
			ok $pt.validate( $parsed );
		}, Q{-1};
	}, Q{implicit decimal};

	subtest {
		plan 3;

		subtest {
			plan 1;

			my $parsed = $pt.parse-source( Q{0x0} );
			ok $pt.validate( $parsed );
		}, Q{zero};

		subtest {
			plan 1;

			my $parsed = $pt.parse-source( Q{0x1} );
			ok $pt.validate( $parsed );
		}, Q{1};

		subtest {
			plan 1;

			my $parsed = $pt.parse-source( Q{-0x1} );
			ok $pt.validate( $parsed );
		}, Q{-1};
	}, Q{hexadecimal};

	subtest {
		plan 3;

		subtest {
			plan 1;

			my $parsed = $pt.parse-source( Q{:13(0)} );
			ok $pt.validate( $parsed );
		}, Q{zero};

		subtest {
			plan 1;

			my $parsed = $pt.parse-source( Q{:13(1)} );
			ok $pt.validate( $parsed );
		}, Q{1};

		subtest {
			plan 1;

			my $parsed = $pt.parse-source( Q{:13(-1)} );
			ok $pt.validate( $parsed );
		}, Q{-1};
	}, Q{base-13};

	subtest {
		plan 5;

		subtest {
			plan 1;

			my $parsed = $pt.parse-source( Q{0.0} );
			ok $pt.validate( $parsed );
		}, Q{zero};

		subtest {
			plan 1;

			my $parsed = $pt.parse-source( Q{0.1} );
			ok $pt.validate( $parsed );
		}, Q{0.1};

		subtest {
			plan 1;

			my $parsed = $pt.parse-source( Q{.1} );
			ok $pt.validate( $parsed );
		}, Q{.1};

		subtest {
			plan 1;

			my $parsed = $pt.parse-source( Q{1.0} );
			ok $pt.validate( $parsed );
		}, Q{1.0};

		subtest {
			plan 1;

			my $parsed = $pt.parse-source( Q{-1.0} );
			ok $pt.validate( $parsed );
		}, Q{-1.0};
	}, Q{rational};

	subtest {
		plan 6;

		subtest {
			plan 1;

			my $parsed = $pt.parse-source( Q{0e0} );
			ok $pt.validate( $parsed );
		}, Q{zero};

		subtest {
			plan 1;

			my $parsed = $pt.parse-source( Q{0.0e0} );
			ok $pt.validate( $parsed );
		}, Q{rational zero};

		subtest {
			plan 1;

			my $parsed = $pt.parse-source( Q{.1e0} );
			ok $pt.validate( $parsed );
		}, Q{rational .1};

		subtest {
			plan 1;

			my $parsed = $pt.parse-source( Q{0.1e0} );
			ok $pt.validate( $parsed );
		}, Q{rational 0.1};

		subtest {
			plan 1;

			my $parsed = $pt.parse-source( Q{1e0} );
			ok $pt.validate( $parsed );
		}, Q{1.0e0};

		subtest {
			plan 1;

			my $parsed = $pt.parse-source( Q{-1e0} );
			ok $pt.validate( $parsed );
		}, Q{-1.0e0};
	}, Q{Num};

	subtest {
		plan 3;

		subtest {
			plan 1;

			my $parsed = $pt.parse-source( Q{0i} );
			ok $pt.validate( $parsed );
		}, Q{0i};

		subtest {
			plan 1;

			my $parsed = $pt.parse-source( Q{1i} );
			ok $pt.validate( $parsed );
		}, Q{11};

		subtest {
			plan 1;

			my $parsed = $pt.parse-source( Q{-1i} );
			ok $pt.validate( $parsed );
		}, Q{-11};
	}, Q{imaginary};
}, Q{integer};

subtest {
	plan 5;

	subtest {
		plan 1;

		my $parsed = $pt.parse-source( Q{'Hello, world!'} );
		ok $pt.validate( $parsed );
	}, Q{single quote};

	subtest {
		plan 2;

		subtest {
			plan 1;

			my $parsed = $pt.parse-source( Q{"Hello, world!"} );
			ok $pt.validate( $parsed );
		}, Q{uninterpolated};

		subtest {
			plan 1;

			my $parsed = $pt.parse-source( Q{"Hello, {'world'}!"} );
			ok $pt.validate( $parsed );
		}, Q{interpolated};
	}, Q{double quote};

	subtest {
		plan 2;

		subtest {
			plan 1;

			my $parsed = $pt.parse-source( Q{Q{Hello, world!}} );
			ok $pt.validate( $parsed );
		}, Q{Q{} (only uninterpolated)};

		subtest {
			subtest {
				plan 1;

				my $parsed = $pt.parse-source(
					Q{q[Hello, world!]}
				);
				ok $pt.validate( $parsed );
			}, Q{unescaped};

			subtest {
				plan 1;

				my $parsed = $pt.parse-source(
					Q{q[Hello\, world!]}
				);
				ok $pt.validate( $parsed );
			}, Q{escaped};
		}, Q{q[]};
	}, Q{q{}};

	subtest {
		plan 2;

		subtest {
			plan 1;

			my $parsed = $pt.parse-source( Q{qq[Hello, world!]} );
			ok $pt.validate( $parsed );
		}, Q{uninterpolated};

		subtest {
			plan 1;

			my $parsed = $pt.parse-source(
				Q{qq[Hello, {'world'}!]}
			);
			ok $pt.validate( $parsed );
		}, Q{interpolated};
	}, Q{qq{}};

	subtest {
		plan 2;

		subtest {
			plan 1;

			my $parsed = $pt.parse-source(
				Q{q:to/END/
Hello world!
END}
			);
			ok $pt.validate( $parsed );
		}, Q{q:to/END/, no spaces};

		subtest {
			plan 1;

			my $parsed = $pt.parse-source(
				Q{q:to/END/
  Hello world!
  END}
			);
			ok $pt.validate( $parsed );
		}, Q{q:to/END/, spaces};
	}, Q{q:to[]};
}, Q{string};

subtest {
	plan 8;

	subtest {
		plan 1;

		my $parsed = $pt.parse-source( Q{@*ARGS} );
		ok $pt.validate( $parsed );
	}, Q{@*ARGS (is a global, so available everywhere)};

	subtest {
		plan 1;

		my $parsed = $pt.parse-source( Q{$} );
		ok $pt.validate( $parsed );
	}, Q{$};

	subtest {
		plan 1;

		my $parsed = $pt.parse-source( Q{$_} );
		ok $pt.validate( $parsed );
	}, Q{$_};

	subtest {
		plan 1;

		my $parsed = $pt.parse-source( Q{$/} );
		ok $pt.validate( $parsed );
	}, Q{$/};

	subtest {
		plan 1;

		my $parsed = $pt.parse-source( Q{$!} );
		ok $pt.validate( $parsed );
	}, Q{$!};

	subtest {
		plan 1;

		my $parsed = $pt.parse-source( Q{$Foo::Bar} );
		ok $pt.validate( $parsed );
	}, Q{$Foo::Bar};

	subtest {
		plan 1;

		my $parsed = $pt.parse-source( Q{&sum} );
		ok $pt.validate( $parsed );
	}, Q{&sum};

	todo Q{$Foo::($bar)::Bar (requires a second term) to compile};
	subtest {
		plan 1;

		my $parsed = $pt.parse-source( Q[$Foo::($*GLOBAL)::Bar] );
		ok $pt.validate( $parsed );
	}, Q[$Foo::($*GLOBAL)::Bar (Need $*GLOBAL in order to compile)];
}, Q{variable};

subtest {
	plan 2;

	subtest {
		plan 1;

		my $parsed = $pt.parse-source( Q{Int} );
		ok $pt.validate( $parsed );
	}, Q{Int};

	subtest {
		plan 1;

		my $parsed = $pt.parse-source( Q{IO::Handle} );
		ok $pt.validate( $parsed );
	}, Q{IO::Handle (Two package names)};
}, Q{type};

subtest {
	plan 1;

	subtest {
		plan 1;

		my $parsed = $pt.parse-source( Q{pi} );
		ok $pt.validate( $parsed );
	}, Q{pi};
}, Q{constant};

subtest {
	plan 1;

	subtest {
		plan 1;

		my $parsed = $pt.parse-source( Q{sum} );
		ok $pt.validate( $parsed );
	}, Q{sum};
}, Q{function call};

subtest {
	plan 1;

	subtest {
		plan 1;

		my $parsed = $pt.parse-source( Q{()} );
		ok $pt.validate( $parsed );
	}, Q{circumfix};
}, Q{operator};

subtest {
	plan 1;

	subtest {
		plan 1;

		my $parsed = $pt.parse-source( Q{:foo} );
		ok $pt.validate( $parsed );
	}, Q{:foo};
}, Q{adverbial-pair};

subtest {
	plan 1;

	subtest {
		plan 1;

		my $parsed = $pt.parse-source( Q{:()} );
		ok $pt.validate( $parsed );
	}, Q{:()};
}, Q{signature};

# vim: ft=perl6
