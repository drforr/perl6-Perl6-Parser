use v6;

use Test;
use Perl6::Parser;

plan 8;

my $pt = Perl6::Parser.new;
my $*VALIDATION-FAILURE-FATAL = True;
my $*FACTORY-FAILURE-FATAL = True;
my $*DEBUG = True;

subtest {
	plan 9;

	subtest {
		plan 6;

		ok 1, "Test zero, once the dumper is ready.";

		subtest {
			plan 2;

			subtest {
				plan 3;

				my $source = Q{0};
				my $parsed = $pt.parse( $source );
				my $tree = $pt.build-tree( $parsed );
				ok $pt.validate( $parsed ), Q{valid};
				ok (grep { $_ ~~ Perl6::Number },
						$tree.child.[0].child),
					Q{found number};
				is $pt.format( $tree ), $source, Q{formatted};
			}, Q{no ws};

			subtest {
				plan 3;

				my $source = Q{ 0  };
				my $parsed = $pt.parse( $source );
				my $tree = $pt.build-tree( $parsed );
				ok $pt.validate( $parsed ), Q{valid};
				ok (grep { $_ ~~ Perl6::Number },
						$tree.child.[1].child),
					Q{found number};
				is $pt.format( $tree ), $source, Q{formatted};
			}, Q{ws};
		}, Q{Zero};

		subtest {
			plan 2;

			subtest {
				plan 3;

				my $source = Q{1};
				my $parsed = $pt.parse( $source );
				my $tree = $pt.build-tree( $parsed );
				ok $pt.validate( $parsed ), Q{valid};
				ok (grep { $_ ~~ Perl6::Number },
						$tree.child.[0].child),
					Q{found number};
				is $pt.format( $tree ), $source, Q{formatted};
			}, Q{no ws};

			subtest {
				plan 3;

				my $source = Q{ 1  };
				my $parsed = $pt.parse( $source );
				my $tree = $pt.build-tree( $parsed );
				ok $pt.validate( $parsed ), Q{valid};
				ok (grep { $_ ~~ Perl6::Number },
						$tree.child.[1].child),
					Q{found number};
				is $pt.format( $tree ), $source, Q{formatted};
			}, Q{ws};
		}, Q{1};

		subtest {
			plan 2;

			subtest {
				plan 3;

				my $source = Q{-1};
				my $parsed = $pt.parse( $source );
				my $tree = $pt.build-tree( $parsed );
				ok $pt.validate( $parsed ), Q{valid};
				ok (grep { $_ ~~ Perl6::Number },
						$tree.child.[0].child),
					Q{found number};
				is $pt.format( $tree ), $source, Q{formatted};
			}, Q{no ws};

			subtest {
				plan 3;

				my $source = Q{ -1  };
				my $parsed = $pt.parse( $source );
				my $tree = $pt.build-tree( $parsed );
				ok $pt.validate( $parsed ), Q{valid};
				ok (grep { $_ ~~ Perl6::Number },
						$tree.child.[1].child),
					Q{found number};
				is $pt.format( $tree ), $source, Q{formatted};
			}, Q{ws};
		}, Q{-1};

		subtest {
			plan 2;

			subtest {
				plan 3;

				my $source = Q{1_1};
				my $parsed = $pt.parse( $source );
				my $tree = $pt.build-tree( $parsed );
				ok $pt.validate( $parsed ), Q{valid};
				ok (grep { $_ ~~ Perl6::Number },
						$tree.child.[0].child),
					Q{found number};
				is $pt.format( $tree ), $source, Q{formatted};
			}, Q{no ws};

			subtest {
				plan 3;

				my $source = Q{ 1_1  };
				my $parsed = $pt.parse( $source );
				my $tree = $pt.build-tree( $parsed );
				ok $pt.validate( $parsed ), Q{valid};
				ok (grep { $_ ~~ Perl6::Number },
						$tree.child.[1].child),
					Q{found number};
				is $pt.format( $tree ), $source, Q{formatted};
			}, Q{ws};
		}, Q{1_1};

		subtest {
			plan 2;

			subtest {
				plan 3;

				my $source = Q{Inf};
				my $parsed = $pt.parse( $source );
				my $tree = $pt.build-tree( $parsed );
				ok $pt.validate( $parsed ), Q{valid};
				ok (grep { $_ ~~ Perl6::Infinity },
						$tree.child.[0].child),
					Q{found Infinity};
				is $pt.format( $tree ), $source, Q{formatted};
			}, Q{no ws};

			subtest {
				plan 3;

				my $source = Q{ Inf  };
				my $parsed = $pt.parse( $source );
				my $tree = $pt.build-tree( $parsed );
				ok $pt.validate( $parsed ), Q{valid};
				ok (grep { $_ ~~ Perl6::Infinity },
						$tree.child.[1].child),
					Q{found number};
				is $pt.format( $tree ), $source, Q{formatted};
			}, Q{ws};
		}, Q{Inf};
	}, Q{decimal};

	subtest {
		plan 3;

		subtest {
			plan 2;

			subtest {
				plan 3;

				my $source = Q{0b0};
				my $parsed = $pt.parse( $source );
				my $tree = $pt.build-tree( $parsed );
				ok $pt.validate( $parsed ), Q{valid};
				ok (grep { $_ ~~ Perl6::Number },
						$tree.child.[0].child),
					Q{found number};
				is $pt.format( $tree ), $source, Q{formatted};
			}, Q{no ws};

			subtest {
				plan 3;

				my $source = Q{ 0b0  };
				my $parsed = $pt.parse( $source );
				my $tree = $pt.build-tree( $parsed );
				ok $pt.validate( $parsed ), Q{valid};
				ok (grep { $_ ~~ Perl6::Number },
						$tree.child.[1].child),
					Q{found number};
				is $pt.format( $tree ), $source, Q{formatted};
			}, Q{ws};
		}, Q{0b0};

		subtest {
			plan 2;

			subtest {
				plan 3;

				my $source = Q{0b1};
				my $parsed = $pt.parse( $source );
				my $tree = $pt.build-tree( $parsed );
				ok $pt.validate( $parsed ), Q{valid};
				ok (grep { $_ ~~ Perl6::Number },
						$tree.child.[0].child),
					Q{found number};
				is $pt.format( $tree ), $source, Q{formatted};
			}, Q{no ws};

			subtest {
				plan 3;

				my $source = Q{ 0b1  };
				my $parsed = $pt.parse( $source );
				my $tree = $pt.build-tree( $parsed );
				ok $pt.validate( $parsed ), Q{valid};
				ok (grep { $_ ~~ Perl6::Number },
						$tree.child.[1].child),
					Q{found number};
				is $pt.format( $tree ), $source, Q{formatted};
			}, Q{ws};
		}, Q{0b1};

		subtest {
			plan 2;

			subtest {
				plan 3;

				my $source = Q{-0b1};
				my $parsed = $pt.parse( $source );
				my $tree = $pt.build-tree( $parsed );
				ok $pt.validate( $parsed ), Q{valid};
				ok (grep { $_ ~~ Perl6::Number },
						$tree.child.[0].child),
					Q{found number};
				is $pt.format( $tree ), $source, Q{formatted};
			}, Q{no ws};

			subtest {
				plan 3;

				my $source = Q{ -0b1  };
				my $parsed = $pt.parse( $source );
				my $tree = $pt.build-tree( $parsed );
				ok $pt.validate( $parsed ), Q{valid};
				ok (grep { $_ ~~ Perl6::Number },
						$tree.child.[1].child),
					Q{found number};
				is $pt.format( $tree ), $source, Q{formatted};
			}, Q{ws};
		}, Q{-0b1};
	}, Q{binary};

	subtest {
		plan 3;

		subtest {
			plan 2;

			subtest {
				plan 3;

				my $source = Q{0o0};
				my $parsed = $pt.parse( $source );
				my $tree = $pt.build-tree( $parsed );
				ok $pt.validate( $parsed ), Q{valid};
				ok (grep { $_ ~~ Perl6::Number },
						$tree.child.[0].child),
					Q{found number};
				is $pt.format( $tree ), $source, Q{formatted};
			}, Q{no ws};

			subtest {
				plan 3;

				my $source = Q{ 0o0  };
				my $parsed = $pt.parse( $source );
				my $tree = $pt.build-tree( $parsed );
				ok $pt.validate( $parsed ), Q{valid};
				ok (grep { $_ ~~ Perl6::Number },
						$tree.child.[1].child),
					Q{found number};
				is $pt.format( $tree ), $source, Q{formatted};
			}, Q{ws};
		}, Q{0o0};

		subtest {
			plan 2;

			subtest {
				plan 3;

				my $source = Q{0o1};
				my $parsed = $pt.parse( $source );
				my $tree = $pt.build-tree( $parsed );
				ok $pt.validate( $parsed ), Q{valid};
				ok (grep { $_ ~~ Perl6::Number },
						$tree.child.[0].child),
					Q{found number};
				is $pt.format( $tree ), $source, Q{formatted};
			}, Q{no ws};

			subtest {
				plan 3;

				my $source = Q{ 0o1  };
				my $parsed = $pt.parse( $source );
				my $tree = $pt.build-tree( $parsed );
				ok $pt.validate( $parsed ), Q{valid};
				ok (grep { $_ ~~ Perl6::Number },
						$tree.child.[1].child),
					Q{found number};
				is $pt.format( $tree ), $source, Q{formatted};
			}, Q{ws};
		}, Q{0o1};

		subtest {
			plan 2;

			subtest {
				plan 3;

				my $source = Q{-0o1};
				my $parsed = $pt.parse( $source );
				my $tree = $pt.build-tree( $parsed );
				ok $pt.validate( $parsed ), Q{valid};
				ok (grep { $_ ~~ Perl6::Number },
						$tree.child.[0].child),
					Q{found number};
				is $pt.format( $tree ), $source, Q{formatted};
			}, Q{no ws};

			subtest {
				plan 3;

				my $source = Q{ -0o1  };
				my $parsed = $pt.parse( $source );
				my $tree = $pt.build-tree( $parsed );
				ok $pt.validate( $parsed ), Q{valid};
				ok (grep { $_ ~~ Perl6::Number },
						$tree.child.[1].child),
					Q{found number};
				is $pt.format( $tree ), $source, Q{formatted};
			}, Q{ws};
		}, Q{-0o1};
	}, Q{octal};

	subtest {
		plan 3;

		subtest {
			plan 2;

			subtest {
				plan 3;

				my $source = Q{0d0};
				my $parsed = $pt.parse( $source );
				my $tree = $pt.build-tree( $parsed );
				ok $pt.validate( $parsed ), Q{valid};
				ok (grep { $_ ~~ Perl6::Number },
						$tree.child.[0].child),
					Q{found number};
				is $pt.format( $tree ), $source, Q{formatted};
			}, Q{no ws};

			subtest {
				plan 3;

				my $source = Q{ 0d0  };
				my $parsed = $pt.parse( $source );
				my $tree = $pt.build-tree( $parsed );
				ok $pt.validate( $parsed ), Q{valid};
				ok (grep { $_ ~~ Perl6::Number },
						$tree.child.[1].child),
					Q{found number};
				is $pt.format( $tree ), $source, Q{formatted};
			}, Q{ws};
		}, Q{0d0};

		subtest {
			plan 2;

			subtest {
				plan 3;

				my $source = Q{0d1};
				my $parsed = $pt.parse( $source );
				my $tree = $pt.build-tree( $parsed );
				ok $pt.validate( $parsed ), Q{valid};
				ok (grep { $_ ~~ Perl6::Number },
						$tree.child.[0].child),
					Q{found number};
				is $pt.format( $tree ), $source, Q{formatted};
			}, Q{no ws};

			subtest {
				plan 3;

				my $source = Q{ 0d1  };
				my $parsed = $pt.parse( $source );
				my $tree = $pt.build-tree( $parsed );
				ok $pt.validate( $parsed ), Q{valid};
				ok (grep { $_ ~~ Perl6::Number },
						$tree.child.[1].child),
					Q{found number};
				is $pt.format( $tree ), $source, Q{formatted};
			}, Q{ws};
		}, Q{0d1};

		subtest {
			plan 2;

			subtest {
				plan 3;

				my $source = Q{-0d1};
				my $parsed = $pt.parse( $source );
				my $tree = $pt.build-tree( $parsed );
				ok $pt.validate( $parsed ), Q{valid};
				ok (grep { $_ ~~ Perl6::Number },
						$tree.child.[0].child),
					Q{found number};
				is $pt.format( $tree ), $source, Q{formatted};
			}, Q{no ws};

			subtest {
				plan 3;

				my $source = Q{ -0d1  };
				my $parsed = $pt.parse( $source );
				my $tree = $pt.build-tree( $parsed );
				ok $pt.validate( $parsed ), Q{valid};
				ok (grep { $_ ~~ Perl6::Number },
						$tree.child.[1].child),
					Q{found number};
				is $pt.format( $tree ), $source, Q{formatted};
			}, Q{ws};
		}, Q{-0d1};
	}, Q{explicit decimal};

	subtest {
		plan 3;

		subtest {
			plan 2;

			subtest {
				plan 3;

				my $source = Q{0};
				my $parsed = $pt.parse( $source );
				my $tree = $pt.build-tree( $parsed );
				ok $pt.validate( $parsed ), Q{valid};
				ok (grep { $_ ~~ Perl6::Number },
						$tree.child.[0].child),
					Q{found number};
				is $pt.format( $tree ), $source, Q{formatted};
			}, Q{no ws};

			subtest {
				plan 3;

				my $source = Q{ 0  };
				my $parsed = $pt.parse( $source );
				my $tree = $pt.build-tree( $parsed );
				ok $pt.validate( $parsed ), Q{valid};
				ok (grep { $_ ~~ Perl6::Number },
						$tree.child.[1].child),
					Q{found number};
				is $pt.format( $tree ), $source, Q{formatted};
			}, Q{ws};
		}, Q{0};

		subtest {
			plan 2;

			subtest {
				plan 3;

				my $source = Q{1};
				my $parsed = $pt.parse( $source );
				my $tree = $pt.build-tree( $parsed );
				ok $pt.validate( $parsed ), Q{valid};
				ok (grep { $_ ~~ Perl6::Number },
						$tree.child.[0].child),
					Q{found number};
				is $pt.format( $tree ), $source, Q{formatted};
			}, Q{no ws};

			subtest {
				plan 3;

				my $source = Q{ 1  };
				my $parsed = $pt.parse( $source );
				my $tree = $pt.build-tree( $parsed );
				ok $pt.validate( $parsed ), Q{valid};
				ok (grep { $_ ~~ Perl6::Number },
						$tree.child.[1].child),
					Q{found number};
				is $pt.format( $tree ), $source, Q{formatted};
			}, Q{ws};
		}, Q{1};

		subtest {
			plan 2;

			subtest {
				plan 3;

				my $source = Q{-1};
				my $parsed = $pt.parse( $source );
				my $tree = $pt.build-tree( $parsed );
				ok $pt.validate( $parsed ), Q{valid};
				ok (grep { $_ ~~ Perl6::Number },
						$tree.child.[0].child),
					Q{found number};
				is $pt.format( $tree ), $source, Q{formatted};
			}, Q{no ws};

			subtest {
				plan 3;

				my $source = Q{ -1  };
				my $parsed = $pt.parse( $source );
				my $tree = $pt.build-tree( $parsed );
				ok $pt.validate( $parsed ), Q{valid};
				ok (grep { $_ ~~ Perl6::Number },
						$tree.child.[1].child),
					Q{found number};
				is $pt.format( $tree ), $source, Q{formatted};
			}, Q{ws};
		}, Q{-1};
	}, Q{implicit decimal};

	subtest {
		plan 3;

		subtest {
			plan 2;

			subtest {
				plan 3;

				my $source = Q{0x0};
				my $parsed = $pt.parse( $source );
				my $tree = $pt.build-tree( $parsed );
				ok $pt.validate( $parsed ), Q{valid};
				ok (grep { $_ ~~ Perl6::Number },
						$tree.child.[0].child),
					Q{found number};
				is $pt.format( $tree ), $source, Q{formatted};
			}, Q{no ws};

			subtest {
				plan 3;

				my $source = Q{ 0x0  };
				my $parsed = $pt.parse( $source );
				my $tree = $pt.build-tree( $parsed );
				ok $pt.validate( $parsed ), Q{valid};
				ok (grep { $_ ~~ Perl6::Number },
						$tree.child.[1].child),
					Q{found number};
				is $pt.format( $tree ), $source, Q{formatted};
			}, Q{ws};
		}, Q{0x0};

		subtest {
			plan 2;

			subtest {
				plan 3;

				my $source = Q{0x1};
				my $parsed = $pt.parse( $source );
				my $tree = $pt.build-tree( $parsed );
				ok $pt.validate( $parsed ), Q{valid};
				ok (grep { $_ ~~ Perl6::Number },
						$tree.child.[0].child),
					Q{found number};
				is $pt.format( $tree ), $source, Q{formatted};
			}, Q{no ws};

			subtest {
				plan 3;

				my $source = Q{ 0x1  };
				my $parsed = $pt.parse( $source );
				my $tree = $pt.build-tree( $parsed );
				ok $pt.validate( $parsed ), Q{valid};
				ok (grep { $_ ~~ Perl6::Number },
						$tree.child.[1].child),
					Q{found number};
				is $pt.format( $tree ), $source, Q{formatted};
			}, Q{ws};
		}, Q{0x1};

		subtest {
			plan 2;

			subtest {
				plan 3;

				my $source = Q{-0x1};
				my $parsed = $pt.parse( $source );
				my $tree = $pt.build-tree( $parsed );
				ok $pt.validate( $parsed ), Q{valid};
				ok (grep { $_ ~~ Perl6::Number },
						$tree.child.[0].child),
					Q{found number};
				is $pt.format( $tree ), $source, Q{formatted};
			}, Q{no ws};

			subtest {
				plan 3;

				my $source = Q{ -0x1  };
				my $parsed = $pt.parse( $source );
				my $tree = $pt.build-tree( $parsed );
				ok $pt.validate( $parsed ), Q{valid};
				ok (grep { $_ ~~ Perl6::Number },
						$tree.child.[1].child),
					Q{found number};
				is $pt.format( $tree ), $source, Q{formatted};
			}, Q{ws};
		}, Q{-0x1};
	}, Q{hexadecimal};

	subtest {
		plan 3;

		subtest {
			plan 2;

			subtest {
				plan 3;

				my $source = Q{:13(0)};
				my $parsed = $pt.parse( $source );
				my $tree = $pt.build-tree( $parsed );
				ok $pt.validate( $parsed ), Q{valid};
				ok (grep { $_ ~~ Perl6::Number },
						$tree.child.[0].child),
					Q{found number};
				is $pt.format( $tree ), $source, Q{formatted};
			}, Q{no ws};

			subtest {
				plan 3;

				my $source = Q{ :13(0)  };
				my $parsed = $pt.parse( $source );
				my $tree = $pt.build-tree( $parsed );
				ok $pt.validate( $parsed ), Q{valid};
				ok (grep { $_ ~~ Perl6::Number },
						$tree.child.[1].child),
					Q{found number};
				is $pt.format( $tree ), $source, Q{formatted};
			}, Q{ws};
		}, Q{:13(0)};

		subtest {
			plan 2;

			subtest {
				plan 3;

				my $source = Q{:13(1)};
				my $parsed = $pt.parse( $source );
				my $tree = $pt.build-tree( $parsed );
				ok $pt.validate( $parsed ), Q{valid};
				ok (grep { $_ ~~ Perl6::Number },
						$tree.child.[0].child),
					Q{found number};
				is $pt.format( $tree ), $source, Q{formatted};
			}, Q{no ws};

			subtest {
				plan 3;

				my $source = Q{ :13(1)  };
				my $parsed = $pt.parse( $source );
				my $tree = $pt.build-tree( $parsed );
				ok $pt.validate( $parsed ), Q{valid};
				ok (grep { $_ ~~ Perl6::Number },
						$tree.child.[1].child),
					Q{found number};
				is $pt.format( $tree ), $source, Q{formatted};
			}, Q{ws};
		}, Q{:13(1)};

		subtest {
			plan 2;

			subtest {
				plan 3;

				my $source = Q{:13(-1)};
				my $parsed = $pt.parse( $source );
				my $tree = $pt.build-tree( $parsed );
				ok $pt.validate( $parsed ), Q{valid};
				ok (grep { $_ ~~ Perl6::Number },
						$tree.child.[0].child),
					Q{found number};
				is $pt.format( $tree ), $source, Q{formatted};
			}, Q{no ws};

			subtest {
				plan 3;

				my $source = Q{ :13(-1)  };
				my $parsed = $pt.parse( $source );
				my $tree = $pt.build-tree( $parsed );
				ok $pt.validate( $parsed ), Q{valid};
				ok (grep { $_ ~~ Perl6::Number },
						$tree.child.[1].child),
					Q{found number};
				is $pt.format( $tree ), $source, Q{formatted};
			}, Q{ws};
		}, Q{:13(-1)};
	}, Q{radix};

	subtest {
		plan 4;

		subtest {
			plan 2;

			subtest {
				plan 3;

				my $source = Q{0e0};
				my $parsed = $pt.parse( $source );
				my $tree = $pt.build-tree( $parsed );
				ok $pt.validate( $parsed ), Q{valid};
				ok (grep { $_ ~~ Perl6::Number },
						$tree.child.[0].child),
					Q{found number};
				is $pt.format( $tree ), $source, Q{formatted};
			}, Q{no ws};

			subtest {
				plan 3;

				my $source = Q{ 0e0  };
				my $parsed = $pt.parse( $source );
				my $tree = $pt.build-tree( $parsed );
				ok $pt.validate( $parsed ), Q{valid};
				ok (grep { $_ ~~ Perl6::Number },
						$tree.child.[1].child),
					Q{found number};
				is $pt.format( $tree ), $source, Q{formatted};
			}, Q{ws};
		}, Q{0e0};

		subtest {
			plan 2;

			subtest {
				plan 3;

				my $source = Q{0e1};
				my $parsed = $pt.parse( $source );
				my $tree = $pt.build-tree( $parsed );
				ok $pt.validate( $parsed ), Q{valid};
				ok (grep { $_ ~~ Perl6::Number },
						$tree.child.[0].child),
					Q{found number};
				is $pt.format( $tree ), $source, Q{formatted};
			}, Q{no ws};

			subtest {
				plan 3;

				my $source = Q{ 0e1  };
				my $parsed = $pt.parse( $source );
				my $tree = $pt.build-tree( $parsed );
				ok $pt.validate( $parsed ), Q{valid};
				ok (grep { $_ ~~ Perl6::Number },
						$tree.child.[1].child),
					Q{found number};
				is $pt.format( $tree ), $source, Q{formatted};
			}, Q{ws};
		}, Q{0e1};

		subtest {
			plan 2;

			subtest {
				plan 3;

				my $source = Q{-0e1};
				my $parsed = $pt.parse( $source );
				my $tree = $pt.build-tree( $parsed );
				ok $pt.validate( $parsed ), Q{valid};
				ok (grep { $_ ~~ Perl6::Number },
						$tree.child.[0].child),
					Q{found number};
				is $pt.format( $tree ), $source, Q{formatted};
			}, Q{no ws};

			subtest {
				plan 3;

				my $source = Q{ -0e1  };
				my $parsed = $pt.parse( $source );
				my $tree = $pt.build-tree( $parsed );
				ok $pt.validate( $parsed ), Q{valid};
				ok (grep { $_ ~~ Perl6::Number },
						$tree.child.[1].child),
					Q{found number};
				is $pt.format( $tree ), $source, Q{formatted};
			}, Q{ws};
		}, Q{-0e1};

		subtest {
			plan 2;

			subtest {
				plan 3;

				my $source = Q{0e-1};
				my $parsed = $pt.parse( $source );
				my $tree = $pt.build-tree( $parsed );
				ok $pt.validate( $parsed ), Q{valid};
				ok (grep { $_ ~~ Perl6::Number },
						$tree.child.[0].child),
					Q{found number};
				is $pt.format( $tree ), $source, Q{formatted};
			}, Q{no ws};

			subtest {
				plan 3;

				my $source = Q{ 0e-1  };
				my $parsed = $pt.parse( $source );
				my $tree = $pt.build-tree( $parsed );
				ok $pt.validate( $parsed ), Q{valid};
				ok (grep { $_ ~~ Perl6::Number },
						$tree.child.[1].child),
					Q{found number};
				is $pt.format( $tree ), $source, Q{formatted};
			}, Q{ws};
		}, Q{-0e1};
	}, Q{scientific};

	subtest {
		plan 3;

		subtest {
			plan 2;

			subtest {
				plan 3;

				my $source = Q{0i};
				my $parsed = $pt.parse( $source );
				my $tree = $pt.build-tree( $parsed );
				ok $pt.validate( $parsed ), Q{valid};
				ok (grep { $_ ~~ Perl6::Number },
						$tree.child.[0].child),
					Q{found number};
				is $pt.format( $tree ), $source, Q{formatted};
			}, Q{no ws};

			subtest {
				plan 3;

				my $source = Q{ 0i  };
				my $parsed = $pt.parse( $source );
				my $tree = $pt.build-tree( $parsed );
				ok $pt.validate( $parsed ), Q{valid};
				ok (grep { $_ ~~ Perl6::Number },
						$tree.child.[1].child),
					Q{found number};
				is $pt.format( $tree ), $source, Q{formatted};
			}, Q{ws};
		}, Q{0i};

		subtest {
			plan 2;

			subtest {
				plan 3;

				my $source = Q{1i};
				my $parsed = $pt.parse( $source );
				my $tree = $pt.build-tree( $parsed );
				ok $pt.validate( $parsed ), Q{valid};
				ok (grep { $_ ~~ Perl6::Number },
						$tree.child.[0].child),
					Q{found number};
				is $pt.format( $tree ), $source, Q{formatted};
			}, Q{no ws};

			subtest {
				plan 3;

				my $source = Q{ 1i  };
				my $parsed = $pt.parse( $source );
				my $tree = $pt.build-tree( $parsed );
				ok $pt.validate( $parsed ), Q{valid};
				ok (grep { $_ ~~ Perl6::Number },
						$tree.child.[1].child),
					Q{found number};
				is $pt.format( $tree ), $source, Q{formatted};
			}, Q{ws};
		}, Q{1i};

		subtest {
			plan 2;

			subtest {
				plan 3;

				my $source = Q{-1i};
				my $parsed = $pt.parse( $source );
				my $tree = $pt.build-tree( $parsed );
				ok $pt.validate( $parsed ), Q{valid};
				ok (grep { $_ ~~ Perl6::Number },
						$tree.child.[0].child),
					Q{found number};
				is $pt.format( $tree ), $source, Q{formatted};
			}, Q{no ws};

			subtest {
				plan 3;

				my $source = Q{ -1i  };
				my $parsed = $pt.parse( $source );
				my $tree = $pt.build-tree( $parsed );
				ok $pt.validate( $parsed ), Q{valid};
				ok (grep { $_ ~~ Perl6::Number },
						$tree.child.[1].child),
					Q{found number};
				is $pt.format( $tree ), $source, Q{formatted};
			}, Q{ws};
		}, Q{-1i};
	}, Q{imaginary};
}, Q{number};

subtest {
	plan 8;

	subtest {
		plan 2;

		subtest {
			plan 3;

			my $source = Q{'Hello, world!'};
			my $parsed = $pt.parse( $source );
			my $tree = $pt.build-tree( $parsed );
			ok $pt.validate( $parsed ), Q{valid};
			ok (grep { $_ ~~ Perl6::String },
					$tree.child.[0].child),
				Q{found string};
			is $pt.format( $tree ), $source, Q{formatted};
		}, Q{no ws};

		subtest {
			plan 3;

			my $source = Q{ 'Hello, world!'  };
			my $parsed = $pt.parse( $source );
			my $tree = $pt.build-tree( $parsed );
			ok $pt.validate( $parsed ), Q{valid};
			ok (grep { $_ ~~ Perl6::String },
					$tree.child.[1].child),
				Q{found string};
			is $pt.format( $tree ), $source, Q{formatted};
		}, Q{ws};
	}, Q{'Hello, world!'};

	subtest {
		plan 2;

		subtest {
			plan 3;

			my $source = Q{"Hello, world!"};
			my $parsed = $pt.parse( $source );
			my $tree = $pt.build-tree( $parsed );
			ok $pt.validate( $parsed ), Q{valid};
			ok (grep { $_ ~~ Perl6::String },
					$tree.child.[0].child),
				Q{found string};
			is $pt.format( $tree ), $source, Q{formatted};
		}, Q{no ws};

		subtest {
			plan 3;

			my $source = Q{ "Hello, world!"  };
			my $parsed = $pt.parse( $source );
			my $tree = $pt.build-tree( $parsed );
			ok $pt.validate( $parsed ), Q{valid};
			ok (grep { $_ ~~ Perl6::String },
					$tree.child.[1].child),
				Q{found string};
			is $pt.format( $tree ), $source, Q{formatted};
		}, Q{ws};
	}, Q{"Hello, world!"};

	subtest {
		plan 2;

		subtest {
			plan 3;

			my $source = Q{Q :q ^Hello, world!^};
			my $parsed = $pt.parse( $source );
			my $tree = $pt.build-tree( $parsed );
			ok $pt.validate( $parsed ), Q{valid};
			ok (grep { $_ ~~ Perl6::String },
					$tree.child.[0].child),
				Q{found string};
			is $pt.format( $tree ), $source, Q{formatted};
		}, Q{no ws};

		subtest {
			plan 3;

			my $source = Q{ Q :q ^Hello, world!^  };
			my $parsed = $pt.parse( $source );
			my $tree = $pt.build-tree( $parsed );
			ok $pt.validate( $parsed ), Q{valid};
			ok (grep { $_ ~~ Perl6::String },
					$tree.child.[1].child),
				Q{found string};
			is $pt.format( $tree ), $source, Q{formatted};
		}, Q{ws};
	}, Q{Q :q ^Hello, world!^};

	subtest {
		plan 2;

		subtest {
			plan 3;

			my $source = Q{Q ^Hello, world!^};
			my $parsed = $pt.parse( $source );
			my $tree = $pt.build-tree( $parsed );
			ok $pt.validate( $parsed ), Q{valid};
			ok (grep { $_ ~~ Perl6::String },
					$tree.child.[0].child),
				Q{found string};
			is $pt.format( $tree ), $source, Q{formatted};
		}, Q{no ws};

		subtest {
			plan 3;

			my $source = Q{ Q ^Hello, world!^  };
			my $parsed = $pt.parse( $source );
			my $tree = $pt.build-tree( $parsed );
			ok $pt.validate( $parsed ), Q{valid};
			ok (grep { $_ ~~ Perl6::String },
					$tree.child.[1].child),
				Q{found string};
			is $pt.format( $tree ), $source, Q{formatted};
		}, Q{ws};
	}, Q{Q ^Hello, world!^};

	subtest {
		plan 2;

		subtest {
			plan 3;

			my $source = Q{Q{Hello, world!}};
			my $parsed = $pt.parse( $source );
			my $tree = $pt.build-tree( $parsed );
			ok $pt.validate( $parsed ), Q{valid};
			ok (grep { $_ ~~ Perl6::String },
					$tree.child.[0].child),
				Q{found string};
			is $pt.format( $tree ), $source, Q{formatted};
		}, Q{no ws};

		subtest {
			plan 3;

			my $source = Q{ Q{Hello, world!}  };
			my $parsed = $pt.parse( $source );
			my $tree = $pt.build-tree( $parsed );
			ok $pt.validate( $parsed ), Q{valid};
			ok (grep { $_ ~~ Perl6::String },
					$tree.child.[1].child),
				Q{found string};
			is $pt.format( $tree ), $source, Q{formatted};
		}, Q{ws};
	}, Q{Q{Hello, world!}};

	subtest {
		plan 2;

		subtest {
			plan 3;

			my $source = Q{q[Hello, world!]};
			my $parsed = $pt.parse( $source );
			my $tree = $pt.build-tree( $parsed );
			ok $pt.validate( $parsed ), Q{valid};
			ok (grep { $_ ~~ Perl6::String },
					$tree.child.[0].child),
				Q{found string};
			is $pt.format( $tree ), $source, Q{formatted};
		}, Q{no ws};

		subtest {
			plan 3;

			my $source = Q{ q[Hello, world!]  };
			my $parsed = $pt.parse( $source );
			my $tree = $pt.build-tree( $parsed );
			ok $pt.validate( $parsed ), Q{valid};
			ok (grep { $_ ~~ Perl6::String },
					$tree.child.[1].child),
				Q{found string};
			is $pt.format( $tree ), $source, Q{formatted};
		}, Q{ws};
	}, Q{q[Hello, world!]};

	subtest {
		plan 2;

		subtest {
			plan 3;

			my $source = Q{qq[Hello, world!]};
			my $parsed = $pt.parse( $source );
			my $tree = $pt.build-tree( $parsed );
			ok $pt.validate( $parsed ), Q{valid};
			ok (grep { $_ ~~ Perl6::String },
					$tree.child.[0].child),
				Q{found string};
			is $pt.format( $tree ), $source, Q{formatted};
		}, Q{no ws};

		subtest {
			plan 3;

			my $source = Q{ qq[Hello, world!]  };
			my $parsed = $pt.parse( $source );
			my $tree = $pt.build-tree( $parsed );
			ok $pt.validate( $parsed ), Q{valid};
			ok (grep { $_ ~~ Perl6::String },
					$tree.child.[1].child),
				Q{found string};
			is $pt.format( $tree ), $source, Q{formatted};
		}, Q{ws};
	}, Q{qq[Hello, world!]};

	subtest {
		plan 2;

		subtest {
			plan 3;

			my $source = Q{q:to[_END_]
Hello, world!
_END_};
			my $parsed = $pt.parse( $source );
			my $tree = $pt.build-tree( $parsed );
			ok $pt.validate( $parsed ), Q{valid};
			ok (grep { $_ ~~ Perl6::String },
					$tree.child.[0].child),
				Q{found string};
			is $pt.format( $tree ), $source, Q{formatted};
		}, Q{no ws};

		subtest {
			plan 3;

			my $source = Q{ q:to[_END_]
Hello, world!
_END_};
			my $parsed = $pt.parse( $source );
			my $tree = $pt.build-tree( $parsed );
			ok $pt.validate( $parsed ), Q{valid};
			ok (grep { $_ ~~ Perl6::String },
					$tree.child.[1].child),
				Q{found string};
			is $pt.format( $tree ), $source, Q{formatted};
		}, Q{ws};
	}, Q{q:to[_END_]};
}, Q{string};

subtest {
	plan 8;

	subtest {
		plan 2;

		subtest {
			plan 3;

			my $source = Q{@*ARGS};
			my $parsed = $pt.parse( $source );
			my $tree = $pt.build-tree( $parsed );
			ok $pt.validate( $parsed ), Q{valid};
			ok (grep { $_ ~~ Perl6::Variable }, $tree.child.[0].child),
				Q{found variable};
			is $pt.format( $tree ), $source, Q{formatted};
		}, Q{no ws};

		subtest {
			plan 3;

			my $source = Q{ @*ARGS  };
			my $parsed = $pt.parse( $source );
			my $tree = $pt.build-tree( $parsed );
			ok $pt.validate( $parsed ), Q{valid};
			ok (grep { $_ ~~ Perl6::Variable },
				$tree.child.[1].child),
				Q{found variable};
			is $pt.format( $tree ), $source, Q{formatted};
		}, Q{ws};
	}, Q{@*ARGS (is a global, so available everywhere)};

	subtest {
		plan 2;

		subtest {
			plan 3;

			my $source = Q{$};
			my $parsed = $pt.parse( $source );
			my $tree = $pt.build-tree( $parsed );
			ok $pt.validate( $parsed ), Q{valid};
			ok (grep { $_ ~~ Perl6::Variable }, $tree.child.[0].child),
				Q{found variable};
			is $pt.format( $tree ), $source, Q{formatted};
		}, Q{no ws};

		subtest {
			plan 3;

			my $source = Q{ $  };
			my $parsed = $pt.parse( $source );
			my $tree = $pt.build-tree( $parsed );
			ok $pt.validate( $parsed ), Q{valid};
			ok (grep { $_ ~~ Perl6::Variable },
				$tree.child.[1].child),
				Q{found variable};
			is $pt.format( $tree ), $source, Q{formatted};
		}, Q{ws};
	}, Q{$};

	subtest {
		plan 2;

		subtest {
			plan 3;

			my $source = Q{$_};
			my $parsed = $pt.parse( $source );
			my $tree = $pt.build-tree( $parsed );
			ok $pt.validate( $parsed ), Q{valid};
			ok (grep { $_ ~~ Perl6::Variable }, $tree.child.[0].child),
				Q{found variable};
			is $pt.format( $tree ), $source, Q{formatted};
		}, Q{no ws};

		subtest {
			plan 3;

			my $source = Q{ $_  };
			my $parsed = $pt.parse( $source );
			my $tree = $pt.build-tree( $parsed );
			ok $pt.validate( $parsed ), Q{valid};
			ok (grep { $_ ~~ Perl6::Variable },
				$tree.child.[1].child),
				Q{found variable};
			is $pt.format( $tree ), $source, Q{formatted};
		}, Q{ws};
	}, Q{$_};

	subtest {
		plan 2;

		subtest {
			plan 3;

			my $source = Q{$/};
			my $parsed = $pt.parse( $source );
			my $tree = $pt.build-tree( $parsed );
			ok $pt.validate( $parsed ), Q{valid};
			ok (grep { $_ ~~ Perl6::Variable }, $tree.child.[0].child),
				Q{found variable};
			is $pt.format( $tree ), $source, Q{formatted};
		}, Q{no ws};

		subtest {
			plan 3;

			my $source = Q{ $/  };
			my $parsed = $pt.parse( $source );
			my $tree = $pt.build-tree( $parsed );
			ok $pt.validate( $parsed ), Q{valid};
			ok (grep { $_ ~~ Perl6::Variable },
				$tree.child.[1].child),
				Q{found variable};
			is $pt.format( $tree ), $source, Q{formatted};
		}, Q{ws};
	}, Q{$/};

	subtest {
		plan 2;

		subtest {
			plan 3;

			my $source = Q{$!};
			my $parsed = $pt.parse( $source );
			my $tree = $pt.build-tree( $parsed );
			ok $pt.validate( $parsed ), Q{valid};
			ok (grep { $_ ~~ Perl6::Variable }, $tree.child.[0].child),
				Q{found variable};
			is $pt.format( $tree ), $source, Q{formatted};
		}, Q{no ws};

		subtest {
			plan 3;

			my $source = Q{ $!  };
			my $parsed = $pt.parse( $source );
			my $tree = $pt.build-tree( $parsed );
			ok $pt.validate( $parsed ), Q{valid};
			ok (grep { $_ ~~ Perl6::Variable },
				$tree.child.[1].child),
				Q{found variable};
			is $pt.format( $tree ), $source, Q{formatted};
		}, Q{ws};
	}, Q{$!};

	subtest {
		plan 2;

		subtest {
			plan 3;

			my $source = Q{$Foo::Bar};
			my $parsed = $pt.parse( $source );
			my $tree = $pt.build-tree( $parsed );
			ok $pt.validate( $parsed ), Q{valid};
			ok (grep { $_ ~~ Perl6::Variable }, $tree.child.[0].child),
				Q{found variable};
			is $pt.format( $tree ), $source, Q{formatted};
		}, Q{no ws};

		subtest {
			plan 3;

			my $source = Q{ $Foo::Bar  };
			my $parsed = $pt.parse( $source );
			my $tree = $pt.build-tree( $parsed );
			ok $pt.validate( $parsed ), Q{valid};
			ok (grep { $_ ~~ Perl6::Variable },
				$tree.child.[1].child),
				Q{found variable};
			is $pt.format( $tree ), $source, Q{formatted};
		}, Q{ws};

	}, Q{$Foo::Bar};

	subtest {
		plan 2;

		subtest {
			plan 2;

			my $source = Q{&sum};
			my $parsed = $pt.parse( $source );
			my $tree = $pt.build-tree( $parsed );
			ok $pt.validate( $parsed ), Q{valid};
			is $pt.format( $tree ), $source, Q{formatted};
		}, Q{no ws};

		subtest {
			plan 2;

			my $source = Q{ &sum  };
			my $parsed = $pt.parse( $source );
			my $tree = $pt.build-tree( $parsed );
			ok $pt.validate( $parsed ), Q{valid};
			is $pt.format( $tree ), $source, Q{formatted};
		}, Q{ws};
	}, Q{&sum};

	todo Q{$Foo::($bar)::Bar (requires a second term) to compile};
	subtest {
		plan 2;

		subtest {
			plan 3;

			my $source = Q{$Foo::($*GLOBAL)::Bar};
			my $parsed = $pt.parse( $source );
			my $tree = $pt.build-tree( $parsed );
			ok $pt.validate( $parsed ), Q{valid};
			ok (grep { $_ ~~ Perl6::Variable }, $tree.child.[0].child),
				Q{found variable};
			is $pt.format( $tree ), $source, Q{formatted};
		}, Q{no ws};

		subtest {
			plan 3;

			my $source = Q{ $Foo::($*GLOBAL)::Bar  };
			my $parsed = $pt.parse( $source );
			my $tree = $pt.build-tree( $parsed );
			ok $pt.validate( $parsed ), Q{valid};
			ok (grep { $_ ~~ Perl6::Variable },
				$tree.child.[1].child),
				Q{found variable};
			is $pt.format( $tree ), $source, Q{formatted};
		}, Q{ws};
	}, Q[$Foo::($*GLOBAL)::Bar (Need $*GLOBAL in order to compile)];
}, Q{variable};

subtest {
	plan 2;

	subtest {
		plan 2;

		subtest {
			plan 2;

			my $source = Q{Int};
			my $parsed = $pt.parse( $source );
			my $tree = $pt.build-tree( $parsed );
			ok $pt.validate( $parsed ), Q{valid};
# XXX Probably shouldn't be a bareword...
#			ok (grep { $_ ~~ Perl6::Number },
#					$tree.child.[0].child),
#				Q{found number};
			is $pt.format( $tree ), $source, Q{formatted};
		}, Q{no ws};

		subtest {
			plan 2;

			my $source = Q{ Int  };
			my $parsed = $pt.parse( $source );
			my $tree = $pt.build-tree( $parsed );
			ok $pt.validate( $parsed ), Q{valid};
# XXX Probably shouldn't be a bareword...
#			ok (grep { $_ ~~ Perl6::Number },
#					$tree.child.[0].child),
#				Q{found number};
			is $pt.format( $tree ), $source, Q{formatted};
		}, Q{ws};
	}, Q{Int};

	subtest {
		plan 2;

		subtest {
			plan 2;

			my $source = Q{IO::Handle};
			my $parsed = $pt.parse( $source );
			my $tree = $pt.build-tree( $parsed );
			ok $pt.validate( $parsed ), Q{valid};
# XXX Probably shouldn't be a bareword...
#			ok (grep { $_ ~~ Perl6::Number },
#					$tree.child.[0].child),
#				Q{found number};
			is $pt.format( $tree ), $source, Q{formatted};
		}, Q{no ws};

		subtest {
			plan 2;

			my $source = Q{ IO::Handle  };
			my $parsed = $pt.parse( $source );
			my $tree = $pt.build-tree( $parsed );
			ok $pt.validate( $parsed ), Q{valid};
# XXX Probably shouldn't be a bareword...
#			ok (grep { $_ ~~ Perl6::Number },
#					$tree.child.[0].child),
#				Q{found number};
			is $pt.format( $tree ), $source, Q{formatted};
		}, Q{ws};
	}, Q{IO::Handle (Two package names)};
}, Q{type};

subtest {
	plan 1;

	subtest {
		plan 2;

		subtest {
			plan 2;

			my $source = Q{pi};
			my $parsed = $pt.parse( $source );
			my $tree = $pt.build-tree( $parsed );
			ok $pt.validate( $parsed ), Q{valid};
# XXX Probably shouldn't be a bareword...
#			ok (grep { $_ ~~ Perl6::Number },
#					$tree.child.[0].child),
#				Q{found number};
			is $pt.format( $tree ), $source, Q{formatted};
		}, Q{no ws};

		subtest {
			plan 2;

			my $source = Q{ pi  };
			my $parsed = $pt.parse( $source );
			my $tree = $pt.build-tree( $parsed );
			ok $pt.validate( $parsed ), Q{valid};
# XXX Probably shouldn't be a bareword...
#			ok (grep { $_ ~~ Perl6::Number },
#					$tree.child.[0].child),
#				Q{found number};
			is $pt.format( $tree ), $source, Q{formatted};
		}, Q{ws};
	}, Q{pi};
}, Q{constant};

subtest {
	plan 1;

	subtest {
		plan 2;

		subtest {
			plan 2;

			my $source = Q{sum};
			my $parsed = $pt.parse( $source );
#say $parsed.dump;
			my $tree = $pt.build-tree( $parsed );
			ok $pt.validate( $parsed ), Q{valid};
#			ok (grep { $_ ~~ Perl6::Number },
#					$tree.child.[0].child),
#				Q{found number};
			is $pt.format( $tree ), $source, Q{formatted};
		}, Q{no ws};

		subtest {
			plan 2;

			my $source = Q{ sum  };
			my $parsed = $pt.parse( $source );
			my $tree = $pt.build-tree( $parsed );
			ok $pt.validate( $parsed ), Q{valid};
#			ok (grep { $_ ~~ Perl6::Number },
#					$tree.child.[0].child),
#				Q{found number};
			is $pt.format( $tree ), $source, Q{formatted};
		}, Q{ws};
	}, Q{sum};
}, Q{function call};

subtest {
	plan 1;

	subtest {
		plan 2;

		subtest {
			plan 2;

			my $source = Q{()};
			my $parsed = $pt.parse( $source );
			my $tree = $pt.build-tree( $parsed );
			ok $pt.validate( $parsed ), Q{valid};
#			ok (grep { $_ ~~ Perl6::Number },
#					$tree.child.[0].child),
#				Q{found number};
			is $pt.format( $tree ), $source, Q{formatted};
		}, Q{no ws};

		subtest {
			plan 2;

			my $source = Q{ ()  };
			my $parsed = $pt.parse( $source );
			my $tree = $pt.build-tree( $parsed );
			ok $pt.validate( $parsed ), Q{valid};
#			ok (grep { $_ ~~ Perl6::Number },
#					$tree.child.[0].child),
#				Q{found number};
			is $pt.format( $tree ), $source, Q{formatted};
		}, Q{ws};
	}, Q{circumfix};
}, Q{operator};

# :foo (adverbial-pair) is already tested in t/pair.t

subtest {
	plan 1;

	subtest {
		plan 2;

		subtest {
			plan 2;

			my $source = Q{:()};
			my $parsed = $pt.parse( $source );
			my $tree = $pt.build-tree( $parsed );
			ok $pt.validate( $parsed ), Q{valid};
#			ok (grep { $_ ~~ Perl6::Number },
#					$tree.child.[0].child),
#				Q{found number};
			is $pt.format( $tree ), $source, Q{formatted};
		}, Q{no ws};

		subtest {
			plan 2;

			my $source = Q{ :()  };
			my $parsed = $pt.parse( $source );
			my $tree = $pt.build-tree( $parsed );
			ok $pt.validate( $parsed ), Q{valid};
#			ok (grep { $_ ~~ Perl6::Number },
#					$tree.child.[0].child),
#				Q{found number};
			is $pt.format( $tree ), $source, Q{formatted};
		}, Q{ws};
	}, Q{:()};
}, Q{signature};

# vim: ft=perl6
