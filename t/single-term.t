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
			plan 2;

			my $parsed = $pt.parse-source( Q{0} );
			my $tree = $pt.build-tree( $parsed );
			ok $pt.validate( $parsed ), Q{valid};
#			is $pt.format( $tree ), Q{0}, Q{formatted};
			is $pt.format( $tree ), Q{0}, Q{formatted};
		}, Q{Zero};

		subtest {
			plan 2;

			my $parsed = $pt.parse-source( Q{1} );
			my $tree = $pt.build-tree( $parsed );
			ok $pt.validate( $parsed ), Q{valid};
#			is $pt.format( $tree ), Q{1}, Q{formatted};
			is $pt.format( $tree ), Q{1}, Q{formatted};
		}, Q{positive};

		subtest {
			plan 2;

			my $parsed = $pt.parse-source( Q{-1} );
			my $tree = $pt.build-tree( $parsed );
			ok $pt.validate( $parsed ), Q{valid};
#			is $pt.format( $tree ), Q{-1}, Q{formatted};
			is $pt.format( $tree ), Q{-1}, Q{formatted};
		}, Q{negative};

		subtest {
			plan 2;

			my $parsed = $pt.parse-source( Q{1_1} );
			my $tree = $pt.build-tree( $parsed );
			ok $pt.validate( $parsed ), Q{valid};
#			is $pt.format( $tree ), Q{1_1}, Q{formatted};
			is $pt.format( $tree ), Q{1_1}, Q{formatted};
		}, Q{underscores};
	}, Q{decimal};

	subtest {
		plan 3;

		subtest {
			plan 2;

			my $parsed = $pt.parse-source( Q{0b0} );
			my $tree = $pt.build-tree( $parsed );
			ok $pt.validate( $parsed ), Q{valid};
#			is $pt.format( $tree ), Q{0b0}, Q{formatted};
			is $pt.format( $tree ), Q{0b0}, Q{formatted};
		}, Q{zero};

		subtest {
			plan 2;

			my $parsed = $pt.parse-source( Q{0b1} );
			my $tree = $pt.build-tree( $parsed );
			ok $pt.validate( $parsed ), Q{valid};
#			is $pt.format( $tree ), Q{0b1}, Q{formatted};
			is $pt.format( $tree ), Q{0b1}, Q{formatted};
		}, Q{1};

		subtest {
			plan 2;

			my $parsed = $pt.parse-source( Q{-0b1} );
			my $tree = $pt.build-tree( $parsed );
			ok $pt.validate( $parsed ), Q{valid};
#			is $pt.format( $tree ), Q{-0b1}, Q{formatted};
			is $pt.format( $tree ), Q{-0b1}, Q{formatted};
		}, Q{-1};
	}, Q{binary};

	subtest {
		plan 3;

		subtest {
			plan 2;

			my $parsed = $pt.parse-source( Q{0o0} );
			my $tree = $pt.build-tree( $parsed );
			ok $pt.validate( $parsed ), Q{valid};
#			is $pt.format( $tree ), Q{0o0}, Q{formatted};
			is $pt.format( $tree ), Q{0o0}, Q{formatted};
		}, Q{zero};

		subtest {
			plan 2;

			my $parsed = $pt.parse-source( Q{0o1} );
			my $tree = $pt.build-tree( $parsed );
			ok $pt.validate( $parsed ), Q{valid};
#			is $pt.format( $tree ), Q{0o1}, Q{formatted};
			is $pt.format( $tree ), Q{0o1}, Q{formatted};
		}, Q{1};

		subtest {
			plan 2;

			my $parsed = $pt.parse-source( Q{-0o1} );
			my $tree = $pt.build-tree( $parsed );
			ok $pt.validate( $parsed ), Q{valid};
#			is $pt.format( $tree ), Q{-0o1}, Q{formatted};
			is $pt.format( $tree ), Q{-0o1}, Q{formatted};
		}, Q{-1};
	}, Q{octal};

	subtest {
		plan 3;

		subtest {
			plan 2;

			my $parsed = $pt.parse-source( Q{0d0} );
			my $tree = $pt.build-tree( $parsed );
			ok $pt.validate( $parsed ), Q{valid};
#			is $pt.format( $tree ), Q{0d0}, Q{formatted};
			is $pt.format( $tree ), Q{0d0}, Q{formatted};
		}, Q{zero};

		subtest {
			plan 2;

			my $parsed = $pt.parse-source( Q{0d1} );
			my $tree = $pt.build-tree( $parsed );
			ok $pt.validate( $parsed ), Q{valid};
#			is $pt.format( $tree ), Q{0d1}, Q{formatted};
			is $pt.format( $tree ), Q{0d1}, Q{formatted};
		}, Q{1};

		subtest {
			plan 2;

			my $parsed = $pt.parse-source( Q{-0d1} );
			my $tree = $pt.build-tree( $parsed );
			ok $pt.validate( $parsed ), Q{valid};
#			is $pt.format( $tree ), Q{-0d1}, Q{formatted};
			is $pt.format( $tree ), Q{-0d1}, Q{formatted};
		}, Q{-1};
	}, Q{explicit decimal};

	subtest {
		plan 3;

		subtest {
			plan 2;

			my $parsed = $pt.parse-source( Q{0} );
			my $tree = $pt.build-tree( $parsed );
			ok $pt.validate( $parsed ), Q{valid};
#			is $pt.format( $tree ), Q{0}, Q{formatted};
			is $pt.format( $tree ), Q{0}, Q{formatted};
		}, Q{zero};

		subtest {
			plan 2;

			my $parsed = $pt.parse-source( Q{1} );
			my $tree = $pt.build-tree( $parsed );
			ok $pt.validate( $parsed ), Q{valid};
#			is $pt.format( $tree ), Q{1}, Q{formatted};
			is $pt.format( $tree ), Q{1}, Q{formatted};
		}, Q{1};

		subtest {
			plan 2;

			my $parsed = $pt.parse-source( Q{-1} );
			my $tree = $pt.build-tree( $parsed );
			ok $pt.validate( $parsed ), Q{valid};
#			is $pt.format( $tree ), Q{-1}, Q{formatted};
			is $pt.format( $tree ), Q{-1}, Q{formatted};
		}, Q{-1};
	}, Q{implicit decimal};

	subtest {
		plan 3;

		subtest {
			plan 2;

			my $parsed = $pt.parse-source( Q{0x0} );
			my $tree = $pt.build-tree( $parsed );
			ok $pt.validate( $parsed ), Q{valid};
#			is $pt.format( $tree ), Q{0x0}, Q{formatted};
			is $pt.format( $tree ), Q{0x0}, Q{formatted};
		}, Q{zero};

		subtest {
			plan 2;

			my $parsed = $pt.parse-source( Q{0x1} );
			my $tree = $pt.build-tree( $parsed );
			ok $pt.validate( $parsed ), Q{valid};
#			is $pt.format( $tree ), Q{0x1}, Q{formatted};
			is $pt.format( $tree ), Q{0x1}, Q{formatted};
		}, Q{1};

		subtest {
			plan 2;

			my $parsed = $pt.parse-source( Q{-0x1} );
			my $tree = $pt.build-tree( $parsed );
			ok $pt.validate( $parsed ), Q{valid};
#			is $pt.format( $tree ), Q{-0x1}, Q{formatted};
			is $pt.format( $tree ), Q{-0x1}, Q{formatted};
		}, Q{-1};
	}, Q{hexadecimal};

	subtest {
		plan 3;

		subtest {
			plan 2;

			my $parsed = $pt.parse-source( Q{:13(0)} );
			my $tree = $pt.build-tree( $parsed );
			ok $pt.validate( $parsed ), Q{valid};
#			is $pt.format( $tree ), Q{:13(0)}, Q{formatted};
			is $pt.format( $tree ), Q{:13(0)}, Q{formatted};
		}, Q{zero};

		subtest {
			plan 2;

			my $parsed = $pt.parse-source( Q{:13(1)} );
			my $tree = $pt.build-tree( $parsed );
			ok $pt.validate( $parsed ), Q{valid};
#			is $pt.format( $tree ), Q{:13(1)}, Q{formatted};
			is $pt.format( $tree ), Q{:13(1)}, Q{formatted};
		}, Q{1};

		subtest {
			plan 2;

			my $parsed = $pt.parse-source( Q{:13(-1)} );
			my $tree = $pt.build-tree( $parsed );
			ok $pt.validate( $parsed ), Q{valid};
#			is $pt.format( $tree ), Q{:13(-1)}, Q{formatted};
			is $pt.format( $tree ), Q{:13(-1)}, Q{formatted};
		}, Q{-1};
	}, Q{base-13};

	subtest {
		plan 5;

		subtest {
			plan 2;

			my $parsed = $pt.parse-source( Q{0.0} );
			my $tree = $pt.build-tree( $parsed );
			ok $pt.validate( $parsed ), Q{valid};
#			is $pt.format( $tree ), Q{0.0}, Q{formatted};
			is $pt.format( $tree ), Q{0.0}, Q{formatted};
		}, Q{zero};

		subtest {
			plan 2;

			my $parsed = $pt.parse-source( Q{0.1} );
			my $tree = $pt.build-tree( $parsed );
			ok $pt.validate( $parsed ), Q{valid};
#			is $pt.format( $tree ), Q{0.1}, Q{formatted};
			is $pt.format( $tree ), Q{0.1}, Q{formatted};
		}, Q{0.1};

		subtest {
			plan 2;

			my $parsed = $pt.parse-source( Q{-1} );
			my $tree = $pt.build-tree( $parsed );
			ok $pt.validate( $parsed ), Q{valid};
#			is $pt.format( $tree ), Q{-1}, Q{formatted};
			is $pt.format( $tree ), Q{-1}, Q{formatted};
		}, Q{.1};

		subtest {
			plan 2;

			my $parsed = $pt.parse-source( Q{1.0} );
			my $tree = $pt.build-tree( $parsed );
			ok $pt.validate( $parsed ), Q{valid};
#			is $pt.format( $tree ), Q{1.0}, Q{formatted};
			is $pt.format( $tree ), Q{1.0}, Q{formatted};
		}, Q{1.0};

		subtest {
			plan 2;

			my $parsed = $pt.parse-source( Q{-1.0} );
			my $tree = $pt.build-tree( $parsed );
			ok $pt.validate( $parsed ), Q{valid};
#			is $pt.format( $tree ), Q{-1.0}, Q{formatted};
			is $pt.format( $tree ), Q{-1.0}, Q{formatted};
		}, Q{-1.0};
	}, Q{rational};

	subtest {
		plan 6;

		subtest {
			plan 2;

			my $parsed = $pt.parse-source( Q{0e0} );
			my $tree = $pt.build-tree( $parsed );
			ok $pt.validate( $parsed ), Q{valid};
#			is $pt.format( $tree ), Q{0e0}, Q{formatted};
			is $pt.format( $tree ), Q{0e0}, Q{formatted};
		}, Q{zero};

		subtest {
			plan 2;

			my $parsed = $pt.parse-source( Q{0.0e0} );
			my $tree = $pt.build-tree( $parsed );
			ok $pt.validate( $parsed ), Q{valid};
#			is $pt.format( $tree ), Q{0.0e0}, Q{formatted};
			is $pt.format( $tree ), Q{0.0e0}, Q{formatted};
		}, Q{rational zero};

		subtest {
			plan 2;

			my $parsed = $pt.parse-source( Q{.1e0} );
			my $tree = $pt.build-tree( $parsed );
			ok $pt.validate( $parsed ), Q{valid};
#			is $pt.format( $tree ), Q{.1e0}, Q{formatted};
			is $pt.format( $tree ), Q{.1e0}, Q{formatted};
		}, Q{rational .1};

		subtest {
			plan 2;

			my $parsed = $pt.parse-source( Q{0.1e0} );
			my $tree = $pt.build-tree( $parsed );
			ok $pt.validate( $parsed ), Q{valid};
#			is $pt.format( $tree ), Q{0.1e0}, Q{formatted};
			is $pt.format( $tree ), Q{0.1e0}, Q{formatted};
		}, Q{rational 0.1};

		subtest {
			plan 2;

			my $parsed = $pt.parse-source( Q{1e0} );
			my $tree = $pt.build-tree( $parsed );
			ok $pt.validate( $parsed ), Q{valid};
#			is $pt.format( $tree ), Q{1e0}, Q{formatted};
			is $pt.format( $tree ), Q{1e0}, Q{formatted};
		}, Q{1.0e0};

		subtest {
			plan 2;

			my $parsed = $pt.parse-source( Q{-1e0} );
			my $tree = $pt.build-tree( $parsed );
			ok $pt.validate( $parsed ), Q{valid};
#			is $pt.format( $tree ), Q{-1e0}, Q{formatted};
			is $pt.format( $tree ), Q{-1e0}, Q{formatted};
		}, Q{-1.0e0};
	}, Q{Num};

	subtest {
		plan 3;

		subtest {
			plan 2;

			my $parsed = $pt.parse-source( Q{0i} );
			my $tree = $pt.build-tree( $parsed );
			ok $pt.validate( $parsed ), Q{valid};
#			is $pt.format( $tree ), Q{0i}, Q{formatted};
			is $pt.format( $tree ), Q{0i}, Q{formatted};
		}, Q{0i};

		subtest {
			plan 2;

			my $parsed = $pt.parse-source( Q{1i} );
			my $tree = $pt.build-tree( $parsed );
			ok $pt.validate( $parsed ), Q{valid};
#			is $pt.format( $tree ), Q{1i}, Q{formatted};
			is $pt.format( $tree ), Q{1i}, Q{formatted};
		}, Q{11};

		subtest {
			plan 2;

			my $parsed = $pt.parse-source( Q{-1i} );
			my $tree = $pt.build-tree( $parsed );
			ok $pt.validate( $parsed ), Q{valid};
#			is $pt.format( $tree ), Q{-1i}, Q{formatted};
			is $pt.format( $tree ), Q{-1i}, Q{formatted};
		}, Q{-11};
	}, Q{imaginary};
}, Q{integer};

subtest {
	plan 5;

	subtest {
		plan 2;

		my $parsed = $pt.parse-source( Q{'Hello, world!'} );
		my $tree = $pt.build-tree( $parsed );
		ok $pt.validate( $parsed ), Q{valid};
#		is $pt.format( $tree ), Q{'Hello, world!'},
#			Q{formatted};
		is $pt.format( $tree ), Q{'Hello, world!'},
			Q{formatted};
	}, Q{single quote};

	subtest {
		plan 2;

		subtest {
			plan 2;

			my $parsed = $pt.parse-source( Q{"Hello, world!"} );
			my $tree = $pt.build-tree( $parsed );
			ok $pt.validate( $parsed ), Q{valid};
#			is $pt.format( $tree ), Q{"Hello, world!"},
#				Q{formatted};
			is $pt.format( $tree ), Q{"Hello, world!"},
				Q{formatted};
		}, Q{uninterpolated};

		subtest {
			plan 2;

			my $parsed = $pt.parse-source( Q{"Hello, {'world'}!"} );
			my $tree = $pt.build-tree( $parsed );
			ok $pt.validate( $parsed ), Q{valid};
#			is $pt.format( $tree ), Q{"Hello, {'world'}!"},
#				Q{formatted};
			is $pt.format( $tree ), Q{"Hello, {'world'}!"},
				Q{formatted};
		}, Q{interpolated};
	}, Q{double quote};

	subtest {
		plan 2;

		subtest {
			plan 2;

			my $parsed = $pt.parse-source( Q{Q{Hello, world!}} );
			my $tree = $pt.build-tree( $parsed );
			ok $pt.validate( $parsed ), Q{valid};
#			is $pt.format( $tree ), Q{Q{Hello, world!}},
#				Q{formatted};
			is $pt.format( $tree ), Q{Q{Hello, world!}},
				Q{formatted};
		}, Q{Q{} (only uninterpolated)};

		subtest {
			plan 2;

			subtest {
				plan 2;

				my $parsed = $pt.parse-source( Q{q[Hello, world!]} );
				my $tree = $pt.build-tree( $parsed );
				ok $pt.validate( $parsed ), Q{valid};
#				is $pt.format( $tree ), Q{q[Hello, world!]},
#					Q{formatted};
				is $pt.format( $tree ), Q{q[Hello, world!]},
					Q{formatted};
			}, Q{unescaped};

			subtest {
				plan 2;

				my $parsed = $pt.parse-source( Q{q[Hello\, world!]} );
				my $tree = $pt.build-tree( $parsed );
				ok $pt.validate( $parsed ), Q{valid};
#				is $pt.format( $tree ), Q{q[Hello\, world!]},
#					Q{formatted};
				is $pt.format( $tree ), Q{q[Hello\, world!]},
					Q{formatted};
			}, Q{escaped};
		}, Q{q[]};
	}, Q{q{}};

	subtest {
		plan 2;

		subtest {
			plan 2;

			my $parsed = $pt.parse-source( Q{qq[Hello, world!]} );
			my $tree = $pt.build-tree( $parsed );
			ok $pt.validate( $parsed ), Q{valid};
#			is $pt.format( $tree ), Q{qq[Hello, world!]},
#				Q{formatted};
			is $pt.format( $tree ), Q{qq[Hello, world!]},
				Q{formatted};
		}, Q{uninterpolated};

		subtest {
			plan 2;

			my $parsed = $pt.parse-source( Q{qq[Hello\, world!]} );
			my $tree = $pt.build-tree( $parsed );
			ok $pt.validate( $parsed ), Q{valid};
#			is $pt.format( $tree ), Q{qq[Hello\, world!]},
#				Q{formatted};
			is $pt.format( $tree ), Q{qq[Hello\, world!]},
				Q{formatted};
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
#`(
			plan 2;

			my $parsed = $pt.parse-source(
				Q{q:to/END/
Hello world!
END}
			);
			my $tree = $pt.build-tree( $parsed );
			ok $pt.validate( $parsed ), Q{valid};
#			is $pt.format( $tree ), Q{q:to/END/
#Hello world!
#END},
#				Q{formatted};
			is $pt.format( $tree ), Q{q:to/END/Hello world!END},
				Q{formatted};
)
		}, Q{q:to/END/, no spaces};

		subtest {
			plan 1;

			my $parsed = $pt.parse-source(
				Q{q:to/END/
  Hello world!
  END}
			);
			ok $pt.validate( $parsed );
#`(
			plan 2;

			my $parsed = $pt.parse-source(
				Q{q:to/END/
  Hello world!
  END}
			);
			my $tree = $pt.build-tree( $parsed );
			ok $pt.validate( $parsed ), Q{valid};
#			is $pt.format( $tree ), Q{my $a}, Q{formatted};
			is $pt.format( $tree ), Q{my$a}, Q{formatted};
)
		}, Q{q:to/END/, spaces};
	}, Q{q:to[]};
}, Q{string};

subtest {
	plan 8;

	subtest {
		plan 2;

		my $parsed = $pt.parse-source( Q{@*ARGS} );
		my $tree = $pt.build-tree( $parsed );
		ok $pt.validate( $parsed ), Q{valid};
#		is $pt.format( $tree ), Q{@*ARGS}, Q{formatted};
		is $pt.format( $tree ), Q{@*ARGS}, Q{formatted};
	}, Q{@*ARGS (is a global, so available everywhere)};

	subtest {
		plan 2;

		my $parsed = $pt.parse-source( Q{$} );
		my $tree = $pt.build-tree( $parsed );
		ok $pt.validate( $parsed ), Q{valid};
#		is $pt.format( $tree ), Q{$}, Q{formatted};
		is $pt.format( $tree ), Q{$}, Q{formatted};
	}, Q{$};

	subtest {
		plan 2;

		my $parsed = $pt.parse-source( Q{$_} );
		my $tree = $pt.build-tree( $parsed );
		ok $pt.validate( $parsed ), Q{valid};
#		is $pt.format( $tree ), Q{$_}, Q{formatted};
		is $pt.format( $tree ), Q{$_}, Q{formatted};
	}, Q{$_};

	subtest {
		plan 2;

		my $parsed = $pt.parse-source( Q{$/} );
		my $tree = $pt.build-tree( $parsed );
		ok $pt.validate( $parsed ), Q{valid};
#		is $pt.format( $tree ), Q{$/}, Q{formatted};
		is $pt.format( $tree ), Q{$/}, Q{formatted};
	}, Q{$/};

	subtest {
		plan 2;

		my $parsed = $pt.parse-source( Q{$!} );
		my $tree = $pt.build-tree( $parsed );
		ok $pt.validate( $parsed ), Q{valid};
#		is $pt.format( $tree ), Q{$!}, Q{formatted};
		is $pt.format( $tree ), Q{$!}, Q{formatted};
	}, Q{$!};

	subtest {
		plan 2;

		my $parsed = $pt.parse-source( Q{$Foo::Bar} );
		my $tree = $pt.build-tree( $parsed );
		ok $pt.validate( $parsed ), Q{valid};
#		is $pt.format( $tree ), Q{$Foo::Bar}, Q{formatted};
		is $pt.format( $tree ), Q{$Foo::Bar}, Q{formatted};
	}, Q{$Foo::Bar};

	subtest {
		plan 2;

		my $parsed = $pt.parse-source( Q{&sum} );
		my $tree = $pt.build-tree( $parsed );
		ok $pt.validate( $parsed ), Q{valid};
#		is $pt.format( $tree ), Q{&sum}, Q{formatted};
		is $pt.format( $tree ), Q{&sum}, Q{formatted};
	}, Q{&sum};

	todo Q{$Foo::($bar)::Bar (requires a second term) to compile};
	subtest {
		plan 2;

		my $parsed = $pt.parse-source( Q{$Foo::($*GLOBAL)::Bar} );
		my $tree = $pt.build-tree( $parsed );
		ok $pt.validate( $parsed ), Q{valid};
#		is $pt.format( $tree ), Q{$Foo::($*GLOBAL)::Bar},
#			Q{formatted};
		is $pt.format( $tree ), Q{$Foo::($*GLOBAL)::Bar},
			Q{formatted};
	}, Q[$Foo::($*GLOBAL)::Bar (Need $*GLOBAL in order to compile)];
}, Q{variable};

subtest {
	plan 2;

	subtest {
		plan 2;

		my $parsed = $pt.parse-source( Q{Int} );
		my $tree = $pt.build-tree( $parsed );
		ok $pt.validate( $parsed ), Q{valid};
#		is $pt.format( $tree ), Q{Int}, Q{formatted};
		is $pt.format( $tree ), Q{Int}, Q{formatted};
	}, Q{Int};

	subtest {
		plan 2;

		my $parsed = $pt.parse-source( Q{IO::Handle} );
		my $tree = $pt.build-tree( $parsed );
		ok $pt.validate( $parsed ), Q{valid};
#		is $pt.format( $tree ), Q{IO::Handle}, Q{formatted};
		is $pt.format( $tree ), Q{IO::Handle}, Q{formatted};
	}, Q{IO::Handle (Two package names)};
}, Q{type};

subtest {
	plan 1;

	subtest {
		plan 2;

		my $parsed = $pt.parse-source( Q{pi} );
		my $tree = $pt.build-tree( $parsed );
		ok $pt.validate( $parsed ), Q{valid};
#		is $pt.format( $tree ), Q{pi}, Q{formatted};
		is $pt.format( $tree ), Q{pi}, Q{formatted};
	}, Q{pi};
}, Q{constant};

subtest {
	plan 1;

	subtest {
		plan 2;

		my $parsed = $pt.parse-source( Q{sum} );
		my $tree = $pt.build-tree( $parsed );
		ok $pt.validate( $parsed ), Q{valid};
#		is $pt.format( $tree ), Q{sum}, Q{formatted};
		is $pt.format( $tree ), Q{sum}, Q{formatted};
	}, Q{sum};
}, Q{function call};

subtest {
	plan 1;

	subtest {
		plan 2;

		my $parsed = $pt.parse-source( Q{()} );
		my $tree = $pt.build-tree( $parsed );
		ok $pt.validate( $parsed ), Q{valid};
#		is $pt.format( $tree ), Q{()}, Q{formatted};
		is $pt.format( $tree ), Q{()}, Q{formatted};
	}, Q{circumfix};
}, Q{operator};

subtest {
	plan 1;

	subtest {
		plan 2;

		my $parsed = $pt.parse-source( Q{:foo} );
		my $tree = $pt.build-tree( $parsed );
		ok $pt.validate( $parsed ), Q{valid};
#		is $pt.format( $tree ), Q{:foo}, Q{formatted};
		is $pt.format( $tree ), Q{:foo}, Q{formatted};
	}, Q{:foo};
}, Q{adverbial-pair};

subtest {
	plan 1;

	subtest {
		plan 2;

		my $parsed = $pt.parse-source( Q{:()} );
		my $tree = $pt.build-tree( $parsed );
		ok $pt.validate( $parsed ), Q{valid};
#		is $pt.format( $tree ), Q{:()}, Q{formatted};
		is $pt.format( $tree ), Q{:()}, Q{formatted};
	}, Q{:()};
}, Q{signature};

# vim: ft=perl6
