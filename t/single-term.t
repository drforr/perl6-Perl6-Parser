use v6;

use nqp;
use Test;
use Perl6::Tidy;

plan 9;

my $pt = Perl6::Tidy.new( :debugging(True) );

subtest {
	plan 9;

	subtest {
		plan 2;

		subtest {
			plan 1;

			my $parsed = $pt.tidy( Q{1} );
			is $parsed.child.elems, 1;
		}, Q{no underscores};

		subtest {
			plan 1;

			my $parsed = $pt.tidy( Q{1_1} );
			is $parsed.child.elems, 1;
		}, Q{underscores};
	}, Q{decimal};

	subtest {
		plan 1;

		my $parsed = $pt.tidy( Q{0b1} );
		is $parsed.child.elems, 1;
	}, Q{binary};

	subtest {
		plan 1;

		my $parsed = $pt.tidy( Q{0o1} );
		is $parsed.child.elems, 1;
	}, Q{octal};

	subtest {
		plan 1;

		my $parsed = $pt.tidy( Q{0o1} );
		is $parsed.child.elems, 1;
	}, Q{octal};

	subtest {
		plan 1;

		my $parsed = $pt.tidy( Q{0x1} );
		is $parsed.child.elems, 1;
	}, Q{hex};

	subtest {
		plan 1;

		my $parsed = $pt.tidy( Q{:13(1)} );
		is $parsed.child.elems, 1;
	}, Q{base-13};

	subtest {
		plan 1;

		my $parsed = $pt.tidy( Q{1.3} );
		is $parsed.child.elems, 1;
	}, Q{rational};

	subtest {
		plan 1;

		my $parsed = $pt.tidy( Q{1e3} );
		is $parsed.child.elems, 1;
	}, Q{Num};

	subtest {
		plan 1;

		my $parsed = $pt.tidy( Q{2i} );
		is $parsed.child.elems, 1;
	}, Q{imaginary};
}, Q{integer};

subtest {
	plan 5;

	subtest {
		plan 1;

		my $parsed = $pt.tidy( Q{'Hello, world!'} );
		is $parsed.child.elems, 1;
	}, Q{single quote};

	subtest {
		plan 2;

		subtest {
			plan 1;

			my $parsed = $pt.tidy( Q{"Hello, world!"} );
			is $parsed.child.elems, 1;
		}, Q{uninterpolated};

		subtest {
			plan 1;

			my $parsed = $pt.tidy(
				Q{"Hello, {'world'}!"}
			);
			is $parsed.child.elems, 1;
		}, Q{interpolated};
	}, Q{double quote};

	subtest {
		plan 2;

		subtest {
			plan 1;

			my $parsed = $pt.tidy(
				Q{Q{Hello, world!}}
			);
			is $parsed.child.elems, 1;
		}, Q{Q{} (only uninterpolated)};

		subtest {
			subtest {
				plan 1;

				my $parsed = $pt.tidy(
					Q{q[Hello, world!]}
				);
				is $parsed.child.elems, 1;
			}, Q{unescaped};

			subtest {
				plan 1;

				my $parsed = $pt.tidy(
					Q{q[Hello\, world!]}
				);
				is $parsed.child.elems, 1;
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
			is $parsed.child.elems, 1;
		}, Q{uninterpolated};

		subtest {
			plan 1;

			my $parsed = $pt.tidy(
				Q{qq[Hello, {'world'}!]}
			);
			is $parsed.child.elems, 1;
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
			is $parsed.child.elems, 1;
		}, Q{q:to/END/, no spaces};

		subtest {
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

subtest {
	plan 8;

	subtest {
		plan 1;

		my $parsed = $pt.tidy( Q{@*ARGS} );
		is $parsed.child.elems, 1;
	}, Q{@*ARGS (is a global, so available everywhere)};

	subtest {
		plan 1;

		my $parsed = $pt.tidy( Q{$} );
		is $parsed.child.elems, 1;
	}, Q{$};

	subtest {
		plan 1;

		my $parsed = $pt.tidy( Q{$_} );
		is $parsed.child.elems, 1;
	}, Q{$_};

	subtest {
		plan 1;

		my $parsed = $pt.tidy( Q{$/} );
		is $parsed.child.elems, 1;
	}, Q{$/};

	subtest {
		plan 1;

		my $parsed = $pt.tidy( Q{$!} );
		is $parsed.child.elems, 1;
	}, Q{$!};

	subtest {
		plan 1;

		my $parsed = $pt.tidy( Q{$Foo::Bar} );
		is $parsed.child.elems, 1;
	}, Q{$Foo::Bar};

	subtest {
		plan 1;

		my $parsed = $pt.tidy( Q{&sum} );
		is $parsed.child.elems, 1;
	}, Q{&sum};

	todo Q{$Foo::($bar)::Bar (requires a second term) to compile};
	subtest {
		plan 1;

		my $parsed = $pt.tidy( Q[$Foo::($*GLOBAL)::Bar] );
		is $parsed.child.elems, 1;
	}, Q[$Foo::($*GLOBAL)::Bar (Need $*GLOBAL in order to compile)];
}, Q{variable};

subtest {
	plan 2;

	subtest {
		plan 1;

		my $parsed = $pt.tidy( Q{Int} );
		is $parsed.child.elems, 1;
	}, Q{Int};

	subtest {
		plan 1;

		my $parsed = $pt.tidy( Q{IO::Handle} );
		is $parsed.child.elems, 1;
	}, Q{IO::Handle (Two package names)};
}, Q{type};

subtest {
	plan 1;

	subtest {
		plan 1;

		my $parsed = $pt.tidy( Q{pi} );
		is $parsed.child.elems, 1;
	}, Q{pi};
}, Q{constant};

subtest {
	plan 1;

	subtest {
		plan 1;

		my $parsed = $pt.tidy( Q{sum} );
		is $parsed.child.elems, 1;
	}, Q{sum};
}, Q{function call};

subtest {
	plan 1;

	subtest {
		plan 1;

		my $parsed = $pt.tidy( Q{()} );
		is $parsed.child.elems, 1;
	}, Q{circumfix};
}, Q{operator};

subtest {
	plan 1;

	subtest {
		plan 1;

		my $parsed = $pt.tidy( Q{:foo} );
		is $parsed.child.elems, 1;
	}, Q{:foo};
}, Q{adverbial-pair};

subtest {
	plan 1;

	subtest {
		plan 1;

		my $parsed = $pt.tidy( Q{:()} );
		is $parsed.child.elems, 1;
	}, Q{:()};
}, Q{signature};

# vim: ft=perl6
