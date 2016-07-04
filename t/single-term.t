use v6;

use nqp;
use Test;
use Perl6::Tidy;

plan 10;

my $pt = Perl6::Tidy.new( :debugging(True) );

subtest sub {
	plan 9;

	subtest sub {
		plan 2;

		subtest sub {
			plan 1;

			my $parsed = $pt.tidy( Q{1} );
			is $parsed.child.elems, 1;
		}, Q{no underscores};

		subtest sub {
			plan 1;

			my $parsed = $pt.tidy( Q{1_1} );
			is $parsed.child.elems, 1;
		}, Q{underscores};
	}, Q{decimal};

	subtest sub {
		plan 1;

		my $parsed = $pt.tidy( Q{0b1} );
		is $parsed.child.elems, 1;
	}, Q{binary};

	subtest sub {
		plan 1;

		my $parsed = $pt.tidy( Q{0o1} );
		is $parsed.child.elems, 1;
	}, Q{octal};

	subtest sub {
		plan 1;

		my $parsed = $pt.tidy( Q{0o1} );
		is $parsed.child.elems, 1;
	}, Q{octal};

	subtest sub {
		plan 1;

		my $parsed = $pt.tidy( Q{0x1} );
		is $parsed.child.elems, 1;
	}, Q{hex};

	subtest sub {
		plan 1;

		my $parsed = $pt.tidy( Q{:13(1)} );
		is $parsed.child.elems, 1;
	}, Q{base-13};

	subtest sub {
		plan 1;

		my $parsed = $pt.tidy( Q{1.3} );
		is $parsed.child.elems, 1;
	}, Q{rational};

	subtest sub {
		plan 1;

		my $parsed = $pt.tidy( Q{1e3} );
		is $parsed.child.elems, 1;
	}, Q{Num};

	subtest sub {
		plan 1;

		my $parsed = $pt.tidy( Q{2i} );
		is $parsed.child.elems, 1;
	}, Q{imaginary};
}, Q{integer};

subtest sub {
	plan 5;

	subtest sub {
		plan 1;

		my $parsed = $pt.tidy( Q{'Hello, world!'} );
		is $parsed.child.elems, 1;
	}, Q{single quote};

	subtest sub {
		plan 2;

		subtest sub {
			plan 1;

			my $parsed = $pt.tidy( Q{"Hello, world!"} );
			is $parsed.child.elems, 1;
		}, Q{uninterpolated};

		subtest sub {
			plan 1;

			my $parsed = $pt.tidy(
				Q{"Hello, {'world'}!"}
			);
			is $parsed.child.elems, 1;
		}, Q{interpolated};
	}, Q{double quote};

	subtest sub {
		plan 2;

		subtest sub {
			plan 1;

			my $parsed = $pt.tidy(
				Q{Q{Hello, world!}}
			);
			is $parsed.child.elems, 1;
		}, Q{Q{} (only uninterpolated)};

		subtest sub {
			subtest sub {
				plan 1;

				my $parsed = $pt.tidy(
					Q{q[Hello, world!]}
				);
				is $parsed.child.elems, 1;
			}, Q{unescaped};

			subtest sub {
				plan 1;

				my $parsed = $pt.tidy(
					Q{q[Hello\, world!]}
				);
				is $parsed.child.elems, 1;
			}, Q{escaped};
		}, Q{q[]};
	}, Q{q{}};

	subtest sub {
		plan 2;

		subtest sub {
			plan 1;

			my $parsed = $pt.tidy(
				Q{qq[Hello, world!]}
			);
			is $parsed.child.elems, 1;
		}, Q{uninterpolated};

		subtest sub {
			plan 1;

			my $parsed = $pt.tidy(
				Q{qq[Hello, {'world'}!]}
			);
			is $parsed.child.elems, 1;
		}, Q{interpolated};
	}, Q{qq{}};

	subtest sub {
		plan 2;

		subtest sub {
			plan 1;

			my $parsed = $pt.tidy(
				Q{q:to/END/
Hello world!
END}
			);
			is $parsed.child.elems, 1;
		}, Q{q:to/END/, no spaces};

		subtest sub {
			plan 1;

			my $parsed = $pt.tidy(
				Q{q:to/END/
  Hello world!
  END}
			);
			is $parsed.child.elems, 1;
		}, Q{q:to/END/, spaces};
	}, Q{q:to[]};
}, Q{string};

subtest sub {
	plan 4;

	subtest sub {
		plan 1;

		my $parsed = $pt.tidy( Q{@*ARGS} );
		is $parsed.child.elems, 1;
	}, Q{@*ARGS (is a global, so available everywhere)};

	subtest sub {
		plan 1;

		my $parsed = $pt.tidy( Q{$Foo::Bar} );
		is $parsed.child.elems, 1;
	}, Q{$Foo::Bar};

	subtest sub {
		plan 1;

		my $parsed = $pt.tidy( Q{&sum} );
		is $parsed.child.elems, 1;
	}, Q{&sum};

	ok 1, Q{$Foo::($bar)::Bar (requires a second term) to compile};
#	subtest sub {
#		plan 1;
#
#		my $parsed = $pt.tidy( Q[$Foo::($bar)::Bar] );
#		is $parsed.child.elems, 1;
#	}, Q[$Foo::($bar)::Bar];
}, Q{variable};

subtest sub {
	plan 2;

	subtest sub {
		plan 1;

		my $parsed = $pt.tidy( Q{Int} );
		is $parsed.child.elems, 1;
	}, Q{Int};

	subtest sub {
		plan 1;

		my $parsed = $pt.tidy( Q{IO::Handle} );
		is $parsed.child.elems, 1;
	}, Q{IO::Handle (Two package names)};
}, Q{type};

subtest sub {
	plan 1;

	subtest sub {
		plan 1;

		my $parsed = $pt.tidy( Q{pi} );
		is $parsed.child.elems, 1;
	}, Q{pi};
}, Q{constant};

subtest sub {
	plan 1;

	subtest sub {
		plan 1;

		my $parsed = $pt.tidy( Q{/pi/} );
		is $parsed.child.elems, 1;
	}, Q{/pi/};
}, Q{regex};

subtest sub {
	plan 1;

	subtest sub {
		plan 1;

		my $parsed = $pt.tidy( Q{sum} );
		is $parsed.child.elems, 1;
	}, Q{sum};
}, Q{function call};

subtest sub {
	plan 1;

	subtest sub {
		plan 1;

		my $parsed = $pt.tidy( Q{()} );
		is $parsed.child.elems, 1;
	}, Q{circumfix};
}, Q{operator};

subtest sub {
	plan 1;

	subtest sub {
		plan 1;

		my $parsed = $pt.tidy( Q{:foo} );
		is $parsed.child.elems, 1;
	}, Q{:foo};
}, Q{adverbial-pair};

subtest sub {
	plan 1;

	subtest sub {
		plan 1;

		my $parsed = $pt.tidy( Q{:()} );
		is $parsed.child.elems, 1;
	}, Q{:()};
}, Q{signature};

# vim: ft=perl6
