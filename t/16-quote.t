use v6;

use Test;
use Perl6::Parser;

plan 18;

my $pt = Perl6::Parser.new;
my $*VALIDATION-FAILURE-FATAL = True;
my $*FACTORY-FAILURE-FATAL = True;
my $*DEBUG = True;

#
# String and qw() delimiters should be balanced.
# The code uses symmetric RE's to parse, and the temptation to reuse the first
# term is strong.
#
# Also, < > for delimiters instead of something closer to the braces of the
# surrounding text, just for visual clarity.
#

#
# It's also worth pointing out that I'm not testing the language itself, so
# variants like Q |foo| and Q $foo$, while entertaining, really aren't in
# the scope of what I'm testing.
#
# All I want to know is whether Q<foo> catches the '<' and '>' individually,
# not whether the parser catches all the variations.
#

# (thankfully :q, even though it's logical as an adverb is illegal)

#
# Longest and loudest (most capitals) prefixes first.
#
# Also, only worry about whitespace *inside* adverb selection.
#

subtest {

	done-testing;
}, Q{Qqww<>};

subtest {

	done-testing;
}, Q{qqww<>};

subtest {

	done-testing;
}, Q{Qqw<>};

subtest {

	done-testing;
}, Q{Qqx<>};

subtest {

	done-testing;
}, Q{qqw<>};

subtest {

	done-testing;
}, Q{qqx<>};

subtest {

	done-testing;
}, Q{Qq<>};

subtest {
	subtest {
		subtest {
			my $source = Q{Qw :q <pi>};
			my $parsed = $pt.parse( $source );
			my $tree = $pt.build-tree( $parsed );
			ok $pt.validate( $parsed ), Q{valid};
			is $pt.to-string( $tree ), $source,
				Q{formatted};
			ok (grep { $_ ~~ Perl6::String::Literal::WordQuoting::Escaping },
					$tree.child.[0].child),
				Q{found string};

			done-testing;
		}, Q{all intervening ws};

		subtest {
			my $source = Q{Qw :q<pi>};
			my $parsed = $pt.parse( $source );
			my $tree = $pt.build-tree( $parsed );
			ok $pt.validate( $parsed ), Q{valid};
			is $pt.to-string( $tree ), $source,
				Q{formatted};
			ok (grep { $_ ~~ Perl6::String::Literal::WordQuoting::Escaping },
					$tree.child.[0].child),
				Q{found string};

			done-testing;
		}, Q{leading intervening ws};

		subtest {
			my $source = Q{Qw:q <pi>};
			my $parsed = $pt.parse( $source );
			my $tree = $pt.build-tree( $parsed );
			ok $pt.validate( $parsed ), Q{valid};
			is $pt.to-string( $tree ), $source,
				Q{formatted};
			ok (grep { $_ ~~ Perl6::String::Literal::WordQuoting::Escaping },
					$tree.child.[0].child),
				Q{found string};

			done-testing;
		}, Q{trailing intervening ws};

		subtest {
			my $source = Q{Qw:q<pi>};
			my $parsed = $pt.parse( $source );
			my $tree = $pt.build-tree( $parsed );
			ok $pt.validate( $parsed ), Q{valid};
			is $pt.to-string( $tree ), $source,
				Q{formatted};
			ok (grep { $_ ~~ Perl6::String::Literal::WordQuoting::Escaping },
					$tree.child.[0].child),
				Q{found string};

			done-testing;
		}, Q{no intervening ws};

		done-testing;
	}, Q{Qw:q<pi>};

#`(
	subtest {
		subtest {
			my $source = Q{Qw :to <END>
pi
END};
			my $parsed = $pt.parse( $source );
			my $tree = $pt.build-tree( $parsed );
			ok $pt.validate( $parsed ), Q{valid};
			is $pt.to-string( $tree ), $source,
				Q{formatted};
			ok (grep { $_ ~~ Perl6::String::Shell::WordQuoting },
					$tree.child.[0].child),
				Q{found string};

			done-testing;
		}, Q{all intervening ws};

		subtest {
			my $source = Q{Qw :to<END>
pi
END};
			my $parsed = $pt.parse( $source );
			my $tree = $pt.build-tree( $parsed );
			ok $pt.validate( $parsed ), Q{valid};
			is $pt.to-string( $tree ), $source,
				Q{formatted};
			ok (grep { $_ ~~ Perl6::String::Shell::WordQuoting },
					$tree.child.[0].child),
				Q{found string};

			done-testing;
		}, Q{leading intervening ws};

		subtest {
			my $source = Q{Qw:to <END>
pi
END};
			my $parsed = $pt.parse( $source );
			my $tree = $pt.build-tree( $parsed );
			ok $pt.validate( $parsed ), Q{valid};
			is $pt.to-string( $tree ), $source,
				Q{formatted};
			ok (grep { $_ ~~ Perl6::String::Shell::WordQuoting },
					$tree.child.[0].child),
				Q{found string};

			done-testing;
		}, Q{trailing intervening ws};

		subtest {
			my $source = Q{Qw:to<END>
pi
END};
			my $parsed = $pt.parse( $source );
			my $tree = $pt.build-tree( $parsed );
			ok $pt.validate( $parsed ), Q{valid};
			is $pt.to-string( $tree ), $source,
				Q{formatted};
			ok (grep { $_ ~~ Perl6::String::Shell::WordQuoting },
					$tree.child.[0].child),
				Q{found string};

			done-testing;
		}, Q{no intervening ws};

		done-testing;
	}, Q{Qx:to<pi>};
)

	subtest {
		subtest {
			my $source = Q{Qw :w <pi>};
			my $parsed = $pt.parse( $source );
			my $tree = $pt.build-tree( $parsed );
			ok $pt.validate( $parsed ), Q{valid};
			is $pt.to-string( $tree ), $source,
				Q{formatted};
			ok (grep { $_ ~~ Perl6::String::Literal::WordQuoting::WordQuoting },
					$tree.child.[0].child),
				Q{found string};

			done-testing;
		}, Q{all intervening ws};

		subtest {
			my $source = Q{Qw :w<pi>};
			my $parsed = $pt.parse( $source );
			my $tree = $pt.build-tree( $parsed );
			ok $pt.validate( $parsed ), Q{valid};
			is $pt.to-string( $tree ), $source,
				Q{formatted};
			ok (grep { $_ ~~ Perl6::String::Literal::WordQuoting::WordQuoting },
					$tree.child.[0].child),
				Q{found string};

			done-testing;
		}, Q{leading intervening ws};

		subtest {
			my $source = Q{Qw:w <pi>};
			my $parsed = $pt.parse( $source );
			my $tree = $pt.build-tree( $parsed );
			ok $pt.validate( $parsed ), Q{valid};
			is $pt.to-string( $tree ), $source,
				Q{formatted};
			ok (grep { $_ ~~ Perl6::String::Literal::WordQuoting::WordQuoting },
					$tree.child.[0].child),
				Q{found string};

			done-testing;
		}, Q{trailing intervening ws};

		subtest {
			my $source = Q{Qw:w<pi>};
			my $parsed = $pt.parse( $source );
			my $tree = $pt.build-tree( $parsed );
			ok $pt.validate( $parsed ), Q{valid};
			is $pt.to-string( $tree ), $source,
				Q{formatted};
			ok (grep { $_ ~~ Perl6::String::Literal::WordQuoting::WordQuoting },
					$tree.child.[0].child),
				Q{found string};

			done-testing;
		}, Q{no intervening ws};

		done-testing;
	}, Q{Qw:w<pi>};

	subtest {
		subtest {
			my $source = Q{Qw :x <pi>};
			my $parsed = $pt.parse( $source );
			my $tree = $pt.build-tree( $parsed );
			ok $pt.validate( $parsed ), Q{valid};
			is $pt.to-string( $tree ), $source,
				Q{formatted};
			ok (grep { $_ ~~ Perl6::String::Literal::WordQuoting::Shell },
					$tree.child.[0].child),
				Q{found string};

			done-testing;
		}, Q{all intervening ws};

		subtest {
			my $source = Q{Qw :x<pi>};
			my $parsed = $pt.parse( $source );
			my $tree = $pt.build-tree( $parsed );
			ok $pt.validate( $parsed ), Q{valid};
			is $pt.to-string( $tree ), $source,
				Q{formatted};
			ok (grep { $_ ~~ Perl6::String::Literal::WordQuoting::Shell },
					$tree.child.[0].child),
				Q{found string};

			done-testing;
		}, Q{leading intervening ws};

		subtest {
			my $source = Q{Qw:x <pi>};
			my $parsed = $pt.parse( $source );
			my $tree = $pt.build-tree( $parsed );
			ok $pt.validate( $parsed ), Q{valid};
			is $pt.to-string( $tree ), $source,
				Q{formatted};
			ok (grep { $_ ~~ Perl6::String::Literal::WordQuoting::Shell },
					$tree.child.[0].child),
				Q{found string};

			done-testing;
		}, Q{trailing intervening ws};

		subtest {
			my $source = Q{Qw:x<pi>};
			my $parsed = $pt.parse( $source );
			my $tree = $pt.build-tree( $parsed );
			ok $pt.validate( $parsed ), Q{valid};
			is $pt.to-string( $tree ), $source,
				Q{formatted};
			ok (grep { $_ ~~ Perl6::String::Literal::WordQuoting::Shell },
					$tree.child.[0].child),
				Q{found string};

			done-testing;
		}, Q{no intervening ws};

		done-testing;
	}, Q{Qw:x<pi>};

	subtest {
		my $source = Q{Qw <pi>};
		my $parsed = $pt.parse( $source );
		my $tree = $pt.build-tree( $parsed );
		ok $pt.validate( $parsed ), Q{valid};
		is $pt.to-string( $tree ), $source,
			Q{formatted};
		ok (grep { $_ ~~ Perl6::String::Literal::WordQuoting },
				$tree.child.[0].child),
			Q{found string};

		done-testing;
	}, Q{ws, no adverbs};

	subtest {
		my $source = Q{Qw<pi>};
		my $parsed = $pt.parse( $source );
		my $tree = $pt.build-tree( $parsed );
		ok $pt.validate( $parsed ), Q{valid};
		is $pt.to-string( $tree ), $source,
			Q{formatted};
		ok (grep { $_ ~~ Perl6::String::Literal::WordQuoting },
				$tree.child.[0].child),
			Q{found string};

		done-testing;
	}, Q{no ws, no adverbs};

	done-testing;
}, Q{Qw<>};

subtest {
	subtest {
		subtest {
			my $source = Q{Qx :q <pi>};
			my $parsed = $pt.parse( $source );
			my $tree = $pt.build-tree( $parsed );
			ok $pt.validate( $parsed ), Q{valid};
			is $pt.to-string( $tree ), $source,
				Q{formatted};
			ok (grep { $_ ~~ Perl6::String::Literal::Shell::Escaping },
					$tree.child.[0].child),
				Q{found string};

			done-testing;
		}, Q{all intervening ws};

		subtest {
			my $source = Q{Qx :q<pi>};
			my $parsed = $pt.parse( $source );
			my $tree = $pt.build-tree( $parsed );
			ok $pt.validate( $parsed ), Q{valid};
			is $pt.to-string( $tree ), $source,
				Q{formatted};
			ok (grep { $_ ~~ Perl6::String::Literal::Shell::Escaping },
					$tree.child.[0].child),
				Q{found string};

			done-testing;
		}, Q{leading intervening ws};

		subtest {
			my $source = Q{Qx:q <pi>};
			my $parsed = $pt.parse( $source );
			my $tree = $pt.build-tree( $parsed );
			ok $pt.validate( $parsed ), Q{valid};
			is $pt.to-string( $tree ), $source,
				Q{formatted};
			ok (grep { $_ ~~ Perl6::String::Literal::Shell::Escaping },
					$tree.child.[0].child),
				Q{found string};

			done-testing;
		}, Q{trailing intervening ws};

		subtest {
			my $source = Q{Qx:q<pi>};
			my $parsed = $pt.parse( $source );
			my $tree = $pt.build-tree( $parsed );
			ok $pt.validate( $parsed ), Q{valid};
			is $pt.to-string( $tree ), $source,
				Q{formatted};
			ok (grep { $_ ~~ Perl6::String::Literal::Shell::Escaping },
					$tree.child.[0].child),
				Q{found string};

			done-testing;
		}, Q{no intervening ws};

		done-testing;
	}, Q{Qx:q<pi>};

#`(
	subtest {
		subtest {
			my $source = Q{Qx :to <END>
pi
END};
			my $parsed = $pt.parse( $source );
			my $tree = $pt.build-tree( $parsed );
			ok $pt.validate( $parsed ), Q{valid};
			is $pt.to-string( $tree ), $source,
				Q{formatted};
			ok (grep { $_ ~~ Perl6::String::Shell::WordQuoting },
					$tree.child.[0].child),
				Q{found string};

			done-testing;
		}, Q{all intervening ws};

		subtest {
			my $source = Q{Qx :to<END>
pi
END};
			my $parsed = $pt.parse( $source );
			my $tree = $pt.build-tree( $parsed );
			ok $pt.validate( $parsed ), Q{valid};
			is $pt.to-string( $tree ), $source,
				Q{formatted};
			ok (grep { $_ ~~ Perl6::String::Shell::WordQuoting },
					$tree.child.[0].child),
				Q{found string};

			done-testing;
		}, Q{leading intervening ws};

		subtest {
			my $source = Q{Qx:to <END>
pi
END};
			my $parsed = $pt.parse( $source );
			my $tree = $pt.build-tree( $parsed );
			ok $pt.validate( $parsed ), Q{valid};
			is $pt.to-string( $tree ), $source,
				Q{formatted};
			ok (grep { $_ ~~ Perl6::String::Shell::WordQuoting },
					$tree.child.[0].child),
				Q{found string};

			done-testing;
		}, Q{trailing intervening ws};

		subtest {
			my $source = Q{Qx:to<END>
pi
END};
			my $parsed = $pt.parse( $source );
			my $tree = $pt.build-tree( $parsed );
			ok $pt.validate( $parsed ), Q{valid};
			is $pt.to-string( $tree ), $source,
				Q{formatted};
			ok (grep { $_ ~~ Perl6::String::Shell::WordQuoting },
					$tree.child.[0].child),
				Q{found string};

			done-testing;
		}, Q{no intervening ws};

		done-testing;
	}, Q{Qx:to<pi>};
)

	subtest {
		subtest {
			my $source = Q{Qx :w <pi>};
			my $parsed = $pt.parse( $source );
			my $tree = $pt.build-tree( $parsed );
			ok $pt.validate( $parsed ), Q{valid};
			is $pt.to-string( $tree ), $source,
				Q{formatted};
			ok (grep { $_ ~~ Perl6::String::Literal::Shell::WordQuoting },
					$tree.child.[0].child),
				Q{found string};

			done-testing;
		}, Q{all intervening ws};

		subtest {
			my $source = Q{Qx :w<pi>};
			my $parsed = $pt.parse( $source );
			my $tree = $pt.build-tree( $parsed );
			ok $pt.validate( $parsed ), Q{valid};
			is $pt.to-string( $tree ), $source,
				Q{formatted};
			ok (grep { $_ ~~ Perl6::String::Literal::Shell::WordQuoting },
					$tree.child.[0].child),
				Q{found string};

			done-testing;
		}, Q{leading intervening ws};

		subtest {
			my $source = Q{Qx:w <pi>};
			my $parsed = $pt.parse( $source );
			my $tree = $pt.build-tree( $parsed );
			ok $pt.validate( $parsed ), Q{valid};
			is $pt.to-string( $tree ), $source,
				Q{formatted};
			ok (grep { $_ ~~ Perl6::String::Literal::Shell::WordQuoting },
					$tree.child.[0].child),
				Q{found string};

			done-testing;
		}, Q{trailing intervening ws};

		subtest {
			my $source = Q{Qx:w<pi>};
			my $parsed = $pt.parse( $source );
			my $tree = $pt.build-tree( $parsed );
			ok $pt.validate( $parsed ), Q{valid};
			is $pt.to-string( $tree ), $source,
				Q{formatted};
			ok (grep { $_ ~~ Perl6::String::Literal::Shell::WordQuoting },
					$tree.child.[0].child),
				Q{found string};

			done-testing;
		}, Q{no intervening ws};

		done-testing;
	}, Q{Qx:w<pi>};

	subtest {
		subtest {
			my $source = Q{Qx :x <pi>};
			my $parsed = $pt.parse( $source );
			my $tree = $pt.build-tree( $parsed );
			ok $pt.validate( $parsed ), Q{valid};
			is $pt.to-string( $tree ), $source,
				Q{formatted};
			ok (grep { $_ ~~ Perl6::String::Literal::Shell },
					$tree.child.[0].child),
				Q{found string};

			done-testing;
		}, Q{all intervening ws};

		subtest {
			my $source = Q{Qx :x<pi>};
			my $parsed = $pt.parse( $source );
			my $tree = $pt.build-tree( $parsed );
			ok $pt.validate( $parsed ), Q{valid};
			is $pt.to-string( $tree ), $source,
				Q{formatted};
			ok (grep { $_ ~~ Perl6::String::Literal::Shell },
					$tree.child.[0].child),
				Q{found string};

			done-testing;
		}, Q{leading intervening ws};

		subtest {
			my $source = Q{Qx:x <pi>};
			my $parsed = $pt.parse( $source );
			my $tree = $pt.build-tree( $parsed );
			ok $pt.validate( $parsed ), Q{valid};
			is $pt.to-string( $tree ), $source,
				Q{formatted};
			ok (grep { $_ ~~ Perl6::String::Literal::Shell },
					$tree.child.[0].child),
				Q{found string};

			done-testing;
		}, Q{trailing intervening ws};

		subtest {
			my $source = Q{Qx:x<pi>};
			my $parsed = $pt.parse( $source );
			my $tree = $pt.build-tree( $parsed );
			ok $pt.validate( $parsed ), Q{valid};
			is $pt.to-string( $tree ), $source,
				Q{formatted};
			ok (grep { $_ ~~ Perl6::String::Literal::Shell },
					$tree.child.[0].child),
				Q{found string};

			done-testing;
		}, Q{no intervening ws};

		done-testing;
	}, Q{Qx:x<pi>};

	subtest {
		my $source = Q{Qx <pi>};
		my $parsed = $pt.parse( $source );
		my $tree = $pt.build-tree( $parsed );
		ok $pt.validate( $parsed ), Q{valid};
		is $pt.to-string( $tree ), $source,
			Q{formatted};
		ok (grep { $_ ~~ Perl6::String::Literal::Shell },
				$tree.child.[0].child),
			Q{found string};

		done-testing;
	}, Q{ws, no adverbs};

	subtest {
		my $source = Q{Qx<pi>};
		my $parsed = $pt.parse( $source );
		my $tree = $pt.build-tree( $parsed );
		ok $pt.validate( $parsed ), Q{valid};
		is $pt.to-string( $tree ), $source,
			Q{formatted};
		ok (grep { $_ ~~ Perl6::String::Literal::Shell },
				$tree.child.[0].child),
			Q{found string};

		done-testing;
	}, Q{no ws, no adverbs};

	done-testing;
}, Q{Qx<>};

subtest {
	subtest {
		subtest {
			my $source = Q{qq :x <pi>};
			my $parsed = $pt.parse( $source );
			my $tree = $pt.build-tree( $parsed );
			ok $pt.validate( $parsed ), Q{valid};
			is $pt.to-string( $tree ), $source,
				Q{formatted};
			ok (grep { $_ ~~ Perl6::String::Interpolation::Shell },
					$tree.child.[0].child),
				Q{found string};

			done-testing;
		}, Q{all intervening ws};

		subtest {
			my $source = Q{qq :x<pi>};
			my $parsed = $pt.parse( $source );
			my $tree = $pt.build-tree( $parsed );
			ok $pt.validate( $parsed ), Q{valid};
			is $pt.to-string( $tree ), $source,
				Q{formatted};
			ok (grep { $_ ~~ Perl6::String::Interpolation::Shell },
					$tree.child.[0].child),
				Q{found string};

			done-testing;
		}, Q{leading intervening ws};

		subtest {
			my $source = Q{qq:x <pi>};
			my $parsed = $pt.parse( $source );
			my $tree = $pt.build-tree( $parsed );
			ok $pt.validate( $parsed ), Q{valid};
			is $pt.to-string( $tree ), $source,
				Q{formatted};
			ok (grep { $_ ~~ Perl6::String::Interpolation::Shell },
					$tree.child.[0].child),
				Q{found string};

			done-testing;
		}, Q{trailing intervening ws};

		subtest {
			my $source = Q{qq:x<pi>};
			my $parsed = $pt.parse( $source );
			my $tree = $pt.build-tree( $parsed );
			ok $pt.validate( $parsed ), Q{valid};
			is $pt.to-string( $tree ), $source,
				Q{formatted};
			ok (grep { $_ ~~ Perl6::String::Interpolation::Shell },
					$tree.child.[0].child),
				Q{found string};

			done-testing;
		}, Q{no intervening ws};

		done-testing;
	}, Q{qq:x<pi>};

	subtest {
		my $source = Q{qq <pi>};
		my $parsed = $pt.parse( $source );
		my $tree = $pt.build-tree( $parsed );
		ok $pt.validate( $parsed ), Q{valid};
		is $pt.to-string( $tree ), $source,
			Q{formatted};
		ok (grep { $_ ~~ Perl6::String::Interpolation },
				$tree.child.[0].child),
			Q{found string};

		done-testing;
	}, Q{ws, no adverbs};

	subtest {
		my $source = Q{qq<pi>};
		my $parsed = $pt.parse( $source );
		my $tree = $pt.build-tree( $parsed );
		ok $pt.validate( $parsed ), Q{valid};
		is $pt.to-string( $tree ), $source,
			Q{formatted};
		ok (grep { $_ ~~ Perl6::String::Interpolation },
				$tree.child.[0].child),
			Q{found string};

		done-testing;
	}, Q{no ws, no adverbs};

	done-testing;
}, Q{qq<>};

subtest {
	# qw:q is illegal
#`(
	subtest {
		subtest {
			my $source = Q{qw :to <END>
pi
END};
			my $parsed = $pt.parse( $source );
			my $tree = $pt.build-tree( $parsed );
			ok $pt.validate( $parsed ), Q{valid};
			is $pt.to-string( $tree ), $source,
				Q{formatted};
			ok (grep { $_ ~~ Perl6::String::WordQuoting::HereDoc },
					$tree.child.[0].child),
				Q{found string};

			done-testing;
		}, Q{all intervening ws};

		subtest {
			my $source = Q{qw :to<END>
pi
END};
			my $parsed = $pt.parse( $source );
			my $tree = $pt.build-tree( $parsed );
			ok $pt.validate( $parsed ), Q{valid};
			is $pt.to-string( $tree ), $source,
				Q{formatted};
			ok (grep { $_ ~~ Perl6::String::WordQuoting::HereDoc },
					$tree.child.[0].child),
				Q{found string};

			done-testing;
		}, Q{leading intervening ws};

		subtest {
			my $source = Q{qw:to <END>
pi
END};
			my $parsed = $pt.parse( $source );
			my $tree = $pt.build-tree( $parsed );
			ok $pt.validate( $parsed ), Q{valid};
			is $pt.to-string( $tree ), $source,
				Q{formatted};
			ok (grep { $_ ~~ Perl6::String::WordQuoting::HereDoc },
					$tree.child.[0].child),
				Q{found string};

			done-testing;
		}, Q{trailing intervening ws};

		subtest {
			my $source = Q{qw:to<END>
pi
END};
			my $parsed = $pt.parse( $source );
			my $tree = $pt.build-tree( $parsed );
			ok $pt.validate( $parsed ), Q{valid};
			is $pt.to-string( $tree ), $source,
				Q{formatted};
			ok (grep { $_ ~~ Perl6::String::WordQuoting::HereDoc },
					$tree.child.[0].child),
				Q{found string};

			done-testing;
		}, Q{no intervening ws};

		done-testing;
	}, Q{qw:to<pi>};
)
	subtest {
		subtest {
			my $source = Q{qw :w <pi>};
			my $parsed = $pt.parse( $source );
			my $tree = $pt.build-tree( $parsed );
			ok $pt.validate( $parsed ), Q{valid};
			is $pt.to-string( $tree ), $source,
				Q{formatted};
			ok (grep { $_ ~~ Perl6::String::WordQuoting::QuoteProtection },
					$tree.child.[0].child),
				Q{found string};

			done-testing;
		}, Q{all intervening ws};

		subtest {
			my $source = Q{qw :w<pi>};
			my $parsed = $pt.parse( $source );
			my $tree = $pt.build-tree( $parsed );
			ok $pt.validate( $parsed ), Q{valid};
			is $pt.to-string( $tree ), $source,
				Q{formatted};
			ok (grep { $_ ~~ Perl6::String::WordQuoting::QuoteProtection },
					$tree.child.[0].child),
				Q{found string};

			done-testing;
		}, Q{leading intervening ws};

		subtest {
			my $source = Q{qw:w <pi>};
			my $parsed = $pt.parse( $source );
			my $tree = $pt.build-tree( $parsed );
			ok $pt.validate( $parsed ), Q{valid};
			is $pt.to-string( $tree ), $source,
				Q{formatted};
			ok (grep { $_ ~~ Perl6::String::WordQuoting::QuoteProtection },
					$tree.child.[0].child),
				Q{found string};

			done-testing;
		}, Q{trailing intervening ws};

		subtest {
			my $source = Q{qw:w<pi>};
			my $parsed = $pt.parse( $source );
			my $tree = $pt.build-tree( $parsed );
			ok $pt.validate( $parsed ), Q{valid};
			is $pt.to-string( $tree ), $source,
				Q{formatted};
			ok (grep { $_ ~~ Perl6::String::WordQuoting::QuoteProtection },
					$tree.child.[0].child),
				Q{found string};

			done-testing;
		}, Q{no intervening ws};

		done-testing;
	}, Q{qw:w<pi>};

	subtest {
		subtest {
			my $source = Q{qw :x <pi>};
			my $parsed = $pt.parse( $source );
			my $tree = $pt.build-tree( $parsed );
			ok $pt.validate( $parsed ), Q{valid};
			is $pt.to-string( $tree ), $source,
				Q{formatted};
			ok (grep { $_ ~~ Perl6::String::Shell },
					$tree.child.[0].child),
				Q{found string};

			done-testing;
		}, Q{all intervening ws};

		subtest {
			my $source = Q{qw :x<pi>};
			my $parsed = $pt.parse( $source );
			my $tree = $pt.build-tree( $parsed );
			ok $pt.validate( $parsed ), Q{valid};
			is $pt.to-string( $tree ), $source,
				Q{formatted};
			ok (grep { $_ ~~ Perl6::String::Shell },
					$tree.child.[0].child),
				Q{found string};

			done-testing;
		}, Q{leading intervening ws};

		subtest {
			my $source = Q{qw:x <pi>};
			my $parsed = $pt.parse( $source );
			my $tree = $pt.build-tree( $parsed );
			ok $pt.validate( $parsed ), Q{valid};
			is $pt.to-string( $tree ), $source,
				Q{formatted};
			ok (grep { $_ ~~ Perl6::String::Shell },
					$tree.child.[0].child),
				Q{found string};

			done-testing;
		}, Q{trailing intervening ws};

		subtest {
			my $source = Q{qw:x<pi>};
			my $parsed = $pt.parse( $source );
			my $tree = $pt.build-tree( $parsed );
			ok $pt.validate( $parsed ), Q{valid};
			is $pt.to-string( $tree ), $source,
				Q{formatted};
			ok (grep { $_ ~~ Perl6::String::Shell },
					$tree.child.[0].child),
				Q{found string};

			done-testing;
		}, Q{no intervening ws};

		done-testing;
	}, Q{qw:x<pi>};

	subtest {
		my $source = Q{qw <pi>};
		my $parsed = $pt.parse( $source );
		my $tree = $pt.build-tree( $parsed );
		ok $pt.validate( $parsed ), Q{valid};
		is $pt.to-string( $tree ), $source,
			Q{formatted};
		ok (grep { $_ ~~ Perl6::String::WordQuoting },
				$tree.child.[0].child),
			Q{found string};

		done-testing;
	}, Q{ws, no adverbs};

	subtest {
		my $source = Q{qw<pi>};
		my $parsed = $pt.parse( $source );
		my $tree = $pt.build-tree( $parsed );
		ok $pt.validate( $parsed ), Q{valid};
		is $pt.to-string( $tree ), $source,
			Q{formatted};
		ok (grep { $_ ~~ Perl6::String::WordQuoting },
				$tree.child.[0].child),
			Q{found string};

		done-testing;
	}, Q{no ws, no adverbs};

	done-testing;
}, Q{qw<>};

subtest {
	# qx:q is illegal
#`(
	subtest {
		subtest {
			my $source = Q{qx :to <END>
pi
END};
			my $parsed = $pt.parse( $source );
			my $tree = $pt.build-tree( $parsed );
			ok $pt.validate( $parsed ), Q{valid};
			is $pt.to-string( $tree ), $source,
				Q{formatted};
			ok (grep { $_ ~~ Perl6::String::Shell::WordQuoting },
					$tree.child.[0].child),
				Q{found string};

			done-testing;
		}, Q{all intervening ws};

		subtest {
			my $source = Q{qx :to<END>
pi
END};
			my $parsed = $pt.parse( $source );
			my $tree = $pt.build-tree( $parsed );
			ok $pt.validate( $parsed ), Q{valid};
			is $pt.to-string( $tree ), $source,
				Q{formatted};
			ok (grep { $_ ~~ Perl6::String::Shell::WordQuoting },
					$tree.child.[0].child),
				Q{found string};

			done-testing;
		}, Q{leading intervening ws};

		subtest {
			my $source = Q{qx:to <END>
pi
END};
			my $parsed = $pt.parse( $source );
			my $tree = $pt.build-tree( $parsed );
			ok $pt.validate( $parsed ), Q{valid};
			is $pt.to-string( $tree ), $source,
				Q{formatted};
			ok (grep { $_ ~~ Perl6::String::Shell::WordQuoting },
					$tree.child.[0].child),
				Q{found string};

			done-testing;
		}, Q{trailing intervening ws};

		subtest {
			my $source = Q{qx:to<END>
pi
END};
			my $parsed = $pt.parse( $source );
			my $tree = $pt.build-tree( $parsed );
			ok $pt.validate( $parsed ), Q{valid};
			is $pt.to-string( $tree ), $source,
				Q{formatted};
			ok (grep { $_ ~~ Perl6::String::Shell::WordQuoting },
					$tree.child.[0].child),
				Q{found string};

			done-testing;
		}, Q{no intervening ws};

		done-testing;
	}, Q{qx:to<pi>};
)

	subtest {
		subtest {
			my $source = Q{qx :w <pi>};
			my $parsed = $pt.parse( $source );
			my $tree = $pt.build-tree( $parsed );
			ok $pt.validate( $parsed ), Q{valid};
			is $pt.to-string( $tree ), $source,
				Q{formatted};
			ok (grep { $_ ~~ Perl6::String::Escaping::Shell::WordQuoting },
					$tree.child.[0].child),
				Q{found string};

			done-testing;
		}, Q{all intervening ws};

		subtest {
			my $source = Q{qx :w<pi>};
			my $parsed = $pt.parse( $source );
			my $tree = $pt.build-tree( $parsed );
			ok $pt.validate( $parsed ), Q{valid};
			is $pt.to-string( $tree ), $source,
				Q{formatted};
			ok (grep { $_ ~~ Perl6::String::Escaping::Shell::WordQuoting },
					$tree.child.[0].child),
				Q{found string};

			done-testing;
		}, Q{leading intervening ws};

		subtest {
			my $source = Q{qx:w <pi>};
			my $parsed = $pt.parse( $source );
			my $tree = $pt.build-tree( $parsed );
			ok $pt.validate( $parsed ), Q{valid};
			is $pt.to-string( $tree ), $source,
				Q{formatted};
			ok (grep { $_ ~~ Perl6::String::Escaping::Shell::WordQuoting },
					$tree.child.[0].child),
				Q{found string};

			done-testing;
		}, Q{trailing intervening ws};

		subtest {
			my $source = Q{qx:w<pi>};
			my $parsed = $pt.parse( $source );
			my $tree = $pt.build-tree( $parsed );
			ok $pt.validate( $parsed ), Q{valid};
			is $pt.to-string( $tree ), $source,
				Q{formatted};
			ok (grep { $_ ~~ Perl6::String::Escaping::Shell::WordQuoting },
					$tree.child.[0].child),
				Q{found string};

			done-testing;
		}, Q{no intervening ws};

		done-testing;
	}, Q{qx:w<pi>};

	subtest {
		subtest {
			my $source = Q{qx :x <pi>};
			my $parsed = $pt.parse( $source );
			my $tree = $pt.build-tree( $parsed );
			ok $pt.validate( $parsed ), Q{valid};
			is $pt.to-string( $tree ), $source,
				Q{formatted};
			ok (grep { $_ ~~ Perl6::String::Escaping::Shell::Shell },
					$tree.child.[0].child),
				Q{found string};

			done-testing;
		}, Q{all intervening ws};

		subtest {
			my $source = Q{qx :x<pi>};
			my $parsed = $pt.parse( $source );
			my $tree = $pt.build-tree( $parsed );
			ok $pt.validate( $parsed ), Q{valid};
			is $pt.to-string( $tree ), $source,
				Q{formatted};
			ok (grep { $_ ~~ Perl6::String::Escaping::Shell::Shell },
					$tree.child.[0].child),
				Q{found string};

			done-testing;
		}, Q{leading intervening ws};

		subtest {
			my $source = Q{qx:x <pi>};
			my $parsed = $pt.parse( $source );
			my $tree = $pt.build-tree( $parsed );
			ok $pt.validate( $parsed ), Q{valid};
			is $pt.to-string( $tree ), $source,
				Q{formatted};
			ok (grep { $_ ~~ Perl6::String::Escaping::Shell::Shell },
					$tree.child.[0].child),
				Q{found string};

			done-testing;
		}, Q{trailing intervening ws};

		subtest {
			my $source = Q{qx:x<pi>};
			my $parsed = $pt.parse( $source );
			my $tree = $pt.build-tree( $parsed );
			ok $pt.validate( $parsed ), Q{valid};
			is $pt.to-string( $tree ), $source,
				Q{formatted};
			ok (grep { $_ ~~ Perl6::String::Escaping::Shell::Shell },
					$tree.child.[0].child),
				Q{found string};

			done-testing;
		}, Q{no intervening ws};

		done-testing;
	}, Q{qx:x<pi>};

	subtest {
		my $source = Q{qx <pi>};
		my $parsed = $pt.parse( $source );
		my $tree = $pt.build-tree( $parsed );
		ok $pt.validate( $parsed ), Q{valid};
		is $pt.to-string( $tree ), $source,
			Q{formatted};
		ok (grep { $_ ~~ Perl6::String::Shell },
				$tree.child.[0].child),
			Q{found string};

		done-testing;
	}, Q{ws, no adverbs};

	subtest {
		my $source = Q{qx<pi>};
		my $parsed = $pt.parse( $source );
		my $tree = $pt.build-tree( $parsed );
		ok $pt.validate( $parsed ), Q{valid};
		is $pt.to-string( $tree ), $source,
			Q{formatted};
		ok (grep { $_ ~~ Perl6::String::Shell },
				$tree.child.[0].child),
			Q{found string};

		done-testing;
	}, Q{no ws, no adverbs};

	done-testing;
}, Q{qx<>};

subtest {
	subtest {
		subtest {
			my $source = Q{Q :q <pi>};
			my $parsed = $pt.parse( $source );
			my $tree = $pt.build-tree( $parsed );
			ok $pt.validate( $parsed ), Q{valid};
			is $pt.to-string( $tree ), $source,
				Q{formatted};
			ok (grep { $_ ~~ Perl6::String::Escaping },
					$tree.child.[0].child),
				Q{found string};

			done-testing;
		}, Q{all intervening ws};

		subtest {
			my $source = Q{Q :q<pi>};
			my $parsed = $pt.parse( $source );
			my $tree = $pt.build-tree( $parsed );
			ok $pt.validate( $parsed ), Q{valid};
			is $pt.to-string( $tree ), $source,
				Q{formatted};
			ok (grep { $_ ~~ Perl6::String::Escaping },
					$tree.child.[0].child),
				Q{found string};

			done-testing;
		}, Q{leading intervening ws};

		subtest {
			my $source = Q{Q:q <pi>};
			my $parsed = $pt.parse( $source );
			my $tree = $pt.build-tree( $parsed );
			ok $pt.validate( $parsed ), Q{valid};
			is $pt.to-string( $tree ), $source,
				Q{formatted};
			ok (grep { $_ ~~ Perl6::String::Escaping },
					$tree.child.[0].child),
				Q{found string};

			done-testing;
		}, Q{trailing intervening ws};

		subtest {
			my $source = Q{Q:q<pi>};
			my $parsed = $pt.parse( $source );
			my $tree = $pt.build-tree( $parsed );
			ok $pt.validate( $parsed ), Q{valid};
			is $pt.to-string( $tree ), $source,
				Q{formatted};
			ok (grep { $_ ~~ Perl6::String::Escaping },
					$tree.child.[0].child),
				Q{found string};

			done-testing;
		}, Q{no intervening ws};

		done-testing;
	}, Q{Q:q<pi>};

#`(
	subtest {
		subtest {
			my $source = Q{Q :to <END>
pi
END
};
			my $parsed = $pt.parse( $source );
			my $tree = $pt.build-tree( $parsed );
			ok $pt.validate( $parsed ), Q{valid};
			is $pt.to-string( $tree ), $source,
				Q{formatted};
			ok (grep { $_ ~~ Perl6::String::HereDoc },
					$tree.child.[0].child),
				Q{found string};

			done-testing;
		}, Q{all intervening ws};

		subtest {
			my $source = Q{Q :to<END>
pi
END
};
			my $parsed = $pt.parse( $source );
			my $tree = $pt.build-tree( $parsed );
			ok $pt.validate( $parsed ), Q{valid};
			is $pt.to-string( $tree ), $source,
				Q{formatted};
			ok (grep { $_ ~~ Perl6::String::HereDoc },
					$tree.child.[0].child),
				Q{found string};

			done-testing;
		}, Q{leading intervening ws};

		subtest {
			my $source = Q{Q:to <END>
pi
END
};
			my $parsed = $pt.parse( $source );
			my $tree = $pt.build-tree( $parsed );
			ok $pt.validate( $parsed ), Q{valid};
			is $pt.to-string( $tree ), $source,
				Q{formatted};
			ok (grep { $_ ~~ Perl6::String::HereDoc },
					$tree.child.[0].child),
				Q{found string};

			done-testing;
		}, Q{trailing intervening ws};

		subtest {
			my $source = Q{Q:to<END>
pi
END
};
			my $parsed = $pt.parse( $source );
			my $tree = $pt.build-tree( $parsed );
			ok $pt.validate( $parsed ), Q{valid};
			is $pt.to-string( $tree ), $source,
				Q{formatted};
			ok (grep { $_ ~~ Perl6::String::HereDoc },
					$tree.child.[0].child),
				Q{found string};

			done-testing;
		}, Q{no intervening ws};

		done-testing;
	}, Q{Q:to<pi>};
)

	subtest {
		subtest {
			my $source = Q{Q :w <pi>};
			my $parsed = $pt.parse( $source );
			my $tree = $pt.build-tree( $parsed );
			ok $pt.validate( $parsed ), Q{valid};
			is $pt.to-string( $tree ), $source,
				Q{formatted};
			ok (grep { $_ ~~ Perl6::String::WordQuoting },
					$tree.child.[0].child),
				Q{found string};

			done-testing;
		}, Q{all intervening ws};

		subtest {
			my $source = Q{Q :w<pi>};
			my $parsed = $pt.parse( $source );
			my $tree = $pt.build-tree( $parsed );
			ok $pt.validate( $parsed ), Q{valid};
			is $pt.to-string( $tree ), $source,
				Q{formatted};
			ok (grep { $_ ~~ Perl6::String::WordQuoting },
					$tree.child.[0].child),
				Q{found string};

			done-testing;
		}, Q{leading intervening ws};

		subtest {
			my $source = Q{Q:w <pi>};
			my $parsed = $pt.parse( $source );
			my $tree = $pt.build-tree( $parsed );
			ok $pt.validate( $parsed ), Q{valid};
			is $pt.to-string( $tree ), $source,
				Q{formatted};
			ok (grep { $_ ~~ Perl6::String::WordQuoting },
					$tree.child.[0].child),
				Q{found string};

			done-testing;
		}, Q{trailing intervening ws};

		subtest {
			my $source = Q{Q:w<pi>};
			my $parsed = $pt.parse( $source );
			my $tree = $pt.build-tree( $parsed );
			ok $pt.validate( $parsed ), Q{valid};
			is $pt.to-string( $tree ), $source,
				Q{formatted};
			ok (grep { $_ ~~ Perl6::String::WordQuoting },
					$tree.child.[0].child),
				Q{found string};

			done-testing;
		}, Q{no intervening ws};

		done-testing;
	}, Q{Q:w<pi>};

	subtest {
		subtest {
			my $source = Q{Q :x <pi>};
			my $parsed = $pt.parse( $source );
			my $tree = $pt.build-tree( $parsed );
			ok $pt.validate( $parsed ), Q{valid};
			is $pt.to-string( $tree ), $source,
				Q{formatted};
			ok (grep { $_ ~~ Perl6::String::Shell },
					$tree.child.[0].child),
				Q{found string};

			done-testing;
		}, Q{all intervening ws};

		subtest {
			my $source = Q{Q :x<pi>};
			my $parsed = $pt.parse( $source );
			my $tree = $pt.build-tree( $parsed );
			ok $pt.validate( $parsed ), Q{valid};
			is $pt.to-string( $tree ), $source,
				Q{formatted};
			ok (grep { $_ ~~ Perl6::String::Shell },
					$tree.child.[0].child),
				Q{found string};

			done-testing;
		}, Q{leading intervening ws};

		subtest {
			my $source = Q{Q:x <pi>};
			my $parsed = $pt.parse( $source );
			my $tree = $pt.build-tree( $parsed );
			ok $pt.validate( $parsed ), Q{valid};
			is $pt.to-string( $tree ), $source,
				Q{formatted};
			ok (grep { $_ ~~ Perl6::String::Shell },
					$tree.child.[0].child),
				Q{found string};

			done-testing;
		}, Q{trailing intervening ws};

		subtest {
			my $source = Q{Q:x<pi>};
			my $parsed = $pt.parse( $source );
			my $tree = $pt.build-tree( $parsed );
			ok $pt.validate( $parsed ), Q{valid};
			is $pt.to-string( $tree ), $source,
				Q{formatted};
			ok (grep { $_ ~~ Perl6::String::Shell },
					$tree.child.[0].child),
				Q{found string};

			done-testing;
		}, Q{no intervening ws};

		done-testing;
	}, Q{Q:x<pi>};

	subtest {
		my $source = Q{Q <pi>};
		my $parsed = $pt.parse( $source );
		my $tree = $pt.build-tree( $parsed );
		ok $pt.validate( $parsed ), Q{valid};
		is $pt.to-string( $tree ), $source,
			Q{formatted};
		ok (grep { $_ ~~ Perl6::String::Literal },
				$tree.child.[0].child),
			Q{found string};

		done-testing;
	}, Q{ws, no adverbs};

	subtest {
		my $source = Q{Q<pi>};
		my $parsed = $pt.parse( $source );
		my $tree = $pt.build-tree( $parsed );
		ok $pt.validate( $parsed ), Q{valid};
		is $pt.to-string( $tree ), $source,
			Q{formatted};
		ok (grep { $_ ~~ Perl6::String::Literal },
				$tree.child.[0].child),
			Q{found string};

		done-testing;
	}, Q{no ws, no adverbs};

	done-testing;
}, Q{Q<>};

subtest {
	# q:q<> is illegal
#`(
	subtest {
		subtest {
			my $source = Q{q :to <END>
pi
END
};
			my $parsed = $pt.parse( $source );
			my $tree = $pt.build-tree( $parsed );
			ok $pt.validate( $parsed ), Q{valid};
			is $pt.to-string( $tree ), $source,
				Q{formatted};
			ok (grep { $_ ~~ Perl6::String::HereDoc },
					$tree.child.[0].child),
				Q{found string};

			done-testing;
		}, Q{all intervening ws};

		subtest {
			my $source = Q{q :to<END>
pi
END
};
			my $parsed = $pt.parse( $source );
			my $tree = $pt.build-tree( $parsed );
			ok $pt.validate( $parsed ), Q{valid};
			is $pt.to-string( $tree ), $source,
				Q{formatted};
			ok (grep { $_ ~~ Perl6::String::HereDoc },
					$tree.child.[0].child),
				Q{found string};

			done-testing;
		}, Q{leading intervening ws};

		subtest {
			my $source = Q{q:to <END>
pi
END
};
			my $parsed = $pt.parse( $source );
			my $tree = $pt.build-tree( $parsed );
			ok $pt.validate( $parsed ), Q{valid};
			is $pt.to-string( $tree ), $source,
				Q{formatted};
			ok (grep { $_ ~~ Perl6::String::HereDoc },
					$tree.child.[0].child),
				Q{found string};

			done-testing;
		}, Q{trailing intervening ws};

		subtest {
			my $source = Q{q:to<END>
pi
END
};
			my $parsed = $pt.parse( $source );
			my $tree = $pt.build-tree( $parsed );
			ok $pt.validate( $parsed ), Q{valid};
			is $pt.to-string( $tree ), $source,
				Q{formatted};
			ok (grep { $_ ~~ Perl6::String::HereDoc },
					$tree.child.[0].child),
				Q{found string};

			done-testing;
		}, Q{no intervening ws};

		done-testing;
	}, Q{q:to<pi>};
)

	subtest {
		subtest {
			my $source = Q{q :w <pi>};
			my $parsed = $pt.parse( $source );
			my $tree = $pt.build-tree( $parsed );
			ok $pt.validate( $parsed ), Q{valid};
			is $pt.to-string( $tree ), $source,
				Q{formatted};
			ok (grep { $_ ~~ Perl6::String::WordQuoting },
					$tree.child.[0].child),
				Q{found string};

			done-testing;
		}, Q{all intervening ws};

		subtest {
			my $source = Q{q :w<pi>};
			my $parsed = $pt.parse( $source );
			my $tree = $pt.build-tree( $parsed );
			ok $pt.validate( $parsed ), Q{valid};
			is $pt.to-string( $tree ), $source,
				Q{formatted};
			ok (grep { $_ ~~ Perl6::String::WordQuoting },
					$tree.child.[0].child),
				Q{found string};

			done-testing;
		}, Q{leading intervening ws};

		subtest {
			my $source = Q{q:w <pi>};
			my $parsed = $pt.parse( $source );
			my $tree = $pt.build-tree( $parsed );
			ok $pt.validate( $parsed ), Q{valid};
			is $pt.to-string( $tree ), $source,
				Q{formatted};
			ok (grep { $_ ~~ Perl6::String::WordQuoting },
					$tree.child.[0].child),
				Q{found string};

			done-testing;
		}, Q{trailing intervening ws};

		subtest {
			my $source = Q{q:w<pi>};
			my $parsed = $pt.parse( $source );
			my $tree = $pt.build-tree( $parsed );
			ok $pt.validate( $parsed ), Q{valid};
			is $pt.to-string( $tree ), $source,
				Q{formatted};
			ok (grep { $_ ~~ Perl6::String::WordQuoting },
					$tree.child.[0].child),
				Q{found string};

			done-testing;
		}, Q{no intervening ws};

		done-testing;
	}, Q{q:w<pi>};

	subtest {
		subtest {
			my $source = Q{q :x <pi>};
			my $parsed = $pt.parse( $source );
			my $tree = $pt.build-tree( $parsed );
			ok $pt.validate( $parsed ), Q{valid};
			is $pt.to-string( $tree ), $source,
				Q{formatted};
			ok (grep { $_ ~~ Perl6::String::Shell },
					$tree.child.[0].child),
				Q{found string};

			done-testing;
		}, Q{all intervening ws};

		subtest {
			my $source = Q{q :x<pi>};
			my $parsed = $pt.parse( $source );
			my $tree = $pt.build-tree( $parsed );
			ok $pt.validate( $parsed ), Q{valid};
			is $pt.to-string( $tree ), $source,
				Q{formatted};
			ok (grep { $_ ~~ Perl6::String::Shell },
					$tree.child.[0].child),
				Q{found string};

			done-testing;
		}, Q{leading intervening ws};

		subtest {
			my $source = Q{q:x <pi>};
			my $parsed = $pt.parse( $source );
			my $tree = $pt.build-tree( $parsed );
			ok $pt.validate( $parsed ), Q{valid};
			is $pt.to-string( $tree ), $source,
				Q{formatted};
			ok (grep { $_ ~~ Perl6::String::Shell },
					$tree.child.[0].child),
				Q{found string};

			done-testing;
		}, Q{trailing intervening ws};

		subtest {
			my $source = Q{q:x<pi>};
			my $parsed = $pt.parse( $source );
			my $tree = $pt.build-tree( $parsed );
			ok $pt.validate( $parsed ), Q{valid};
			is $pt.to-string( $tree ), $source,
				Q{formatted};
			ok (grep { $_ ~~ Perl6::String::Shell },
					$tree.child.[0].child),
				Q{found string};

			done-testing;
		}, Q{no intervening ws};

		done-testing;
	}, Q{q:x<pi>};

	subtest {
		my $source = Q{q <pi>};
		my $parsed = $pt.parse( $source );
		my $tree = $pt.build-tree( $parsed );
		ok $pt.validate( $parsed ), Q{valid};
		is $pt.to-string( $tree ), $source,
			Q{formatted};
		ok (grep { $_ ~~ Perl6::String::Escaping },
				$tree.child.[0].child),
			Q{found string};

		done-testing;
	}, Q{intervening ws, no adverbs};

	subtest {
		my $source = Q{q<pi>};
		my $parsed = $pt.parse( $source );
		my $tree = $pt.build-tree( $parsed );
		ok $pt.validate( $parsed ), Q{valid};
		is $pt.to-string( $tree ), $source,
			Q{formatted};
		ok (grep { $_ ~~ Perl6::String::Escaping },
				$tree.child.[0].child),
			Q{found string};

		done-testing;
	}, Q{no ws, no adverbs};

	done-testing;
}, Q{q<>};

subtest {
	my $source = Q{<pi>};
	my $parsed = $pt.parse( $source );
	my $tree = $pt.build-tree( $parsed );
	ok $pt.validate( $parsed ), Q{valid};
	is $pt.to-string( $tree ), $source, Q{formatted};
	ok (grep { $_ ~~ Perl6::String::WordQuoting },
			$tree.child.[0].child),
		Q{found string};

	done-testing;
}, Q{<>};

subtest {
	my $source = Q{｢pi｣};
	my $parsed = $pt.parse( $source );
	my $tree = $pt.build-tree( $parsed );
	ok $pt.validate( $parsed ), Q{valid};
	is $pt.to-string( $tree ), $source, Q{formatted};
	ok (grep { $_ ~~ Perl6::String::Literal },
			$tree.child.[0].child),
		Q{found string};

	done-testing;
}, Q{｢｣};

subtest {
	my $source = Q{"pi"};
	my $parsed = $pt.parse( $source );
	my $tree = $pt.build-tree( $parsed );
	ok $pt.validate( $parsed ), Q{valid};
	is $pt.to-string( $tree ), $source, Q{formatted};
	ok (grep { $_ ~~ Perl6::String::Interpolation },
			$tree.child.[0].child),
		Q{found string};

	done-testing;
}, Q{""};

subtest {
	my $source = Q{'pi'};
	my $parsed = $pt.parse( $source );
	my $tree = $pt.build-tree( $parsed );
	ok $pt.validate( $parsed ), Q{valid};
	is $pt.to-string( $tree ), $source, Q{formatted};
	ok (grep { $_ ~~ Perl6::String::Escaping },
			$tree.child.[0].child),
		Q{found string};

	done-testing;
}, Q{''};

# vim: ft=perl6
