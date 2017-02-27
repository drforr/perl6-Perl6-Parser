use v6;

use Test;
use Perl6::Parser;

plan 16;

my $pt = Perl6::Parser.new;
my $*CONSISTENCY-CHECK = True;
my $*GRAMMAR-CHECK = True;

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

# Qqww is illegal

subtest {
	# qqww:q is illegal
	subtest {
		subtest {
			my $source = Q{qqww :to <END>
pi
END};
			my $parsed = $pt.parse( $source );
			my $tree = $pt.build-tree( $parsed );
			is $pt.to-string( $tree ), $source,
				Q{formatted};
			ok $tree.child.[0].child.[0] ~~
				Perl6::String::Interpolation::WordQuoting::QuoteProtection;
			is $tree.child.[0].child.[0].quote, Q{qqww},
				Q{quote name};
			is $tree.child.[0].child.[0].delimiter-start, Q{<},
				Q{start delimiter};
			is $tree.child.[0].child.[0].delimiter-end, Q{>},
				Q{end delimiter};

			done-testing;
		}, Q{all intervening ws};

		subtest {
			my $source = Q{qqww :to<END>
pi
END};
			my $parsed = $pt.parse( $source );
			my $tree = $pt.build-tree( $parsed );
			is $pt.to-string( $tree ), $source,
				Q{formatted};
			ok (grep { $_ ~~ Perl6::String::Interpolation::WordQuoting::QuoteProtection },
					$tree.child.[0].child),
				Q{found string};

			done-testing;
		}, Q{leading intervening ws};

		subtest {
			my $source = Q{qqww:to <END>
pi
END};
			my $parsed = $pt.parse( $source );
			my $tree = $pt.build-tree( $parsed );
			is $pt.to-string( $tree ), $source,
				Q{formatted};
			ok (grep { $_ ~~ Perl6::String::Interpolation::WordQuoting::QuoteProtection },
					$tree.child.[0].child),
				Q{found string};

			done-testing;
		}, Q{trailing intervening ws};

		subtest {
			my $source = Q{qqww:to<END>
pi
END};
			my $parsed = $pt.parse( $source );
			my $tree = $pt.build-tree( $parsed );
			is $pt.to-string( $tree ), $source,
				Q{formatted};
			ok (grep { $_ ~~ Perl6::String::Interpolation::WordQuoting::QuoteProtection },
					$tree.child.[0].child),
				Q{found string};

			done-testing;
		}, Q{no intervening ws};

		done-testing;
	}, Q{Qx:to<pi>};

	subtest {
		subtest {
			my $source = Q{qqww :w <pi>};
			my $parsed = $pt.parse( $source );
			my $tree = $pt.build-tree( $parsed );
			is $pt.to-string( $tree ), $source,
				Q{formatted};
			ok (grep { $_ ~~ Perl6::String::Interpolation::WordQuoting::QuoteProtection },
					$tree.child.[0].child),
				Q{found string};

			done-testing;
		}, Q{all intervening ws};

		subtest {
			my $source = Q{qqww :w<pi>};
			my $parsed = $pt.parse( $source );
			my $tree = $pt.build-tree( $parsed );
			is $pt.to-string( $tree ), $source,
				Q{formatted};
			ok (grep { $_ ~~ Perl6::String::Interpolation::WordQuoting::QuoteProtection },
					$tree.child.[0].child),
				Q{found string};

			done-testing;
		}, Q{leading intervening ws};

		subtest {
			my $source = Q{qqww:w <pi>};
			my $parsed = $pt.parse( $source );
			my $tree = $pt.build-tree( $parsed );
			is $pt.to-string( $tree ), $source,
				Q{formatted};
			ok (grep { $_ ~~ Perl6::String::Interpolation::WordQuoting::QuoteProtection },
					$tree.child.[0].child),
				Q{found string};

			done-testing;
		}, Q{trailing intervening ws};

		subtest {
			my $source = Q{qqww:w<pi>};
			my $parsed = $pt.parse( $source );
			my $tree = $pt.build-tree( $parsed );
			is $pt.to-string( $tree ), $source,
				Q{formatted};
			ok (grep { $_ ~~ Perl6::String::Interpolation::WordQuoting::QuoteProtection },
					$tree.child.[0].child),
				Q{found string};

			done-testing;
		}, Q{no intervening ws};

		done-testing;
	}, Q{qqww:w<pi>};

	subtest {
		subtest {
			my $source = Q{qqww :x <pi>};
			my $parsed = $pt.parse( $source );
			my $tree = $pt.build-tree( $parsed );
			is $pt.to-string( $tree ), $source,
				Q{formatted};
			ok (grep { $_ ~~ Perl6::String::Interpolation::WordQuoting::QuoteProtection },
					$tree.child.[0].child),
				Q{found string};

			done-testing;
		}, Q{all intervening ws};

		subtest {
			my $source = Q{qqww :x<pi>};
			my $parsed = $pt.parse( $source );
			my $tree = $pt.build-tree( $parsed );
			is $pt.to-string( $tree ), $source,
				Q{formatted};
			ok (grep { $_ ~~ Perl6::String::Interpolation::WordQuoting::QuoteProtection },
					$tree.child.[0].child),
				Q{found string};

			done-testing;
		}, Q{leading intervening ws};

		subtest {
			my $source = Q{qqww:x <pi>};
			my $parsed = $pt.parse( $source );
			my $tree = $pt.build-tree( $parsed );
			is $pt.to-string( $tree ), $source,
				Q{formatted};
			ok (grep { $_ ~~ Perl6::String::Interpolation::WordQuoting::QuoteProtection },
					$tree.child.[0].child),
				Q{found string};

			done-testing;
		}, Q{trailing intervening ws};

		subtest {
			my $source = Q{qqww:x<pi>};
			my $parsed = $pt.parse( $source );
			my $tree = $pt.build-tree( $parsed );
			is $pt.to-string( $tree ), $source,
				Q{formatted};
			ok (grep { $_ ~~ Perl6::String::Interpolation::WordQuoting::QuoteProtection },
					$tree.child.[0].child),
				Q{found string};

			done-testing;
		}, Q{no intervening ws};

		done-testing;
	}, Q{qqww:x<pi>};

	subtest {
		my $source = Q{qqww <pi>};
		my $parsed = $pt.parse( $source );
		my $tree = $pt.build-tree( $parsed );
		is $pt.to-string( $tree ), $source,
			Q{formatted};
		ok (grep { $_ ~~ Perl6::String::Interpolation::WordQuoting::QuoteProtection },
				$tree.child.[0].child),
			Q{found string};

		done-testing;
	}, Q{ws, no adverbs};

	subtest {
		my $source = Q{qqww<pi>};
		my $parsed = $pt.parse( $source );
		my $tree = $pt.build-tree( $parsed );
		is $pt.to-string( $tree ), $source,
			Q{formatted};
		ok (grep { $_ ~~ Perl6::String::Interpolation::WordQuoting::QuoteProtection },
				$tree.child.[0].child),
			Q{found string};

		done-testing;
	}, Q{no ws, no adverbs};

	done-testing;
}, Q{qqww<>};

# Qqw is illegal

# Qqx is illegal

subtest {
	# qqw:q is illegal

	subtest {
		subtest {
			my $source = Q{qqw :to <END>
pi
END};
			my $parsed = $pt.parse( $source );
			my $tree = $pt.build-tree( $parsed );
			is $pt.to-string( $tree ), $source,
				Q{formatted};
			ok (grep { $_ ~~ Perl6::String::Interpolation::WordQuoting },
					$tree.child.[0].child),
				Q{found string};

			done-testing;
		}, Q{all intervening ws};

		subtest {
			my $source = Q{qqw :to<END>
pi
END};
			my $parsed = $pt.parse( $source );
			my $tree = $pt.build-tree( $parsed );
			is $pt.to-string( $tree ), $source,
				Q{formatted};
			ok (grep { $_ ~~ Perl6::String::Interpolation::WordQuoting },
					$tree.child.[0].child),
				Q{found string};

			done-testing;
		}, Q{leading intervening ws};

		subtest {
			my $source = Q{qqw:to <END>
pi
END};
			my $parsed = $pt.parse( $source );
			my $tree = $pt.build-tree( $parsed );
			is $pt.to-string( $tree ), $source,
				Q{formatted};
			ok (grep { $_ ~~ Perl6::String::Interpolation::WordQuoting },
					$tree.child.[0].child),
				Q{found string};

			done-testing;
		}, Q{trailing intervening ws};

		subtest {
			my $source = Q{qqw:to<END>
pi
END};
			my $parsed = $pt.parse( $source );
			my $tree = $pt.build-tree( $parsed );
			is $pt.to-string( $tree ), $source,
				Q{formatted};
			ok (grep { $_ ~~ Perl6::String::Interpolation::WordQuoting },
					$tree.child.[0].child),
				Q{found string};

			done-testing;
		}, Q{no intervening ws};

		done-testing;
	}, Q{adverb :to};

	subtest {
		subtest {
			my $source = Q{qqw :w <pi>};
			my $parsed = $pt.parse( $source );
			my $tree = $pt.build-tree( $parsed );
			is $pt.to-string( $tree ), $source,
				Q{formatted};
			ok (grep { $_ ~~ Perl6::String::Interpolation::WordQuoting },
					$tree.child.[0].child),
				Q{found string};

			done-testing;
		}, Q{all intervening ws};

		subtest {
			my $source = Q{qqw :w<pi>};
			my $parsed = $pt.parse( $source );
			my $tree = $pt.build-tree( $parsed );
			is $pt.to-string( $tree ), $source,
				Q{formatted};
			ok (grep { $_ ~~ Perl6::String::Interpolation::WordQuoting },
					$tree.child.[0].child),
				Q{found string};

			done-testing;
		}, Q{leading intervening ws};

		subtest {
			my $source = Q{qqw:w <pi>};
			my $parsed = $pt.parse( $source );
			my $tree = $pt.build-tree( $parsed );
			is $pt.to-string( $tree ), $source,
				Q{formatted};
			ok (grep { $_ ~~ Perl6::String::Interpolation::WordQuoting },
					$tree.child.[0].child),
				Q{found string};

			done-testing;
		}, Q{trailing intervening ws};

		subtest {
			my $source = Q{qqw:w<pi>};
			my $parsed = $pt.parse( $source );
			my $tree = $pt.build-tree( $parsed );
			is $pt.to-string( $tree ), $source,
				Q{formatted};
			ok (grep { $_ ~~ Perl6::String::Interpolation::WordQuoting },
					$tree.child.[0].child),
				Q{found string};

			done-testing;
		}, Q{no intervening ws};

		done-testing;
	}, Q{adverb :w};

	subtest {
		subtest {
			my $source = Q{qqw :x <pi>};
			my $parsed = $pt.parse( $source );
			my $tree = $pt.build-tree( $parsed );
			is $pt.to-string( $tree ), $source,
				Q{formatted};
			ok (grep { $_ ~~ Perl6::String::Interpolation::WordQuoting },
					$tree.child.[0].child),
				Q{found string};

			done-testing;
		}, Q{all intervening ws};

		subtest {
			my $source = Q{qqw :x<pi>};
			my $parsed = $pt.parse( $source );
			my $tree = $pt.build-tree( $parsed );
			is $pt.to-string( $tree ), $source,
				Q{formatted};
			ok (grep { $_ ~~ Perl6::String::Interpolation::WordQuoting },
					$tree.child.[0].child),
				Q{found string};

			done-testing;
		}, Q{leading intervening ws};

		subtest {
			my $source = Q{qqw:x <pi>};
			my $parsed = $pt.parse( $source );
			my $tree = $pt.build-tree( $parsed );
			is $pt.to-string( $tree ), $source,
				Q{formatted};
			ok (grep { $_ ~~ Perl6::String::Interpolation::WordQuoting },
					$tree.child.[0].child),
				Q{found string};

			done-testing;
		}, Q{trailing intervening ws};

		subtest {
			my $source = Q{qqw:x<pi>};
			my $parsed = $pt.parse( $source );
			my $tree = $pt.build-tree( $parsed );
			is $pt.to-string( $tree ), $source,
				Q{formatted};
			ok (grep { $_ ~~ Perl6::String::Interpolation::WordQuoting },
					$tree.child.[0].child),
				Q{found string};

			done-testing;
		}, Q{no intervening ws};

		done-testing;
	}, Q{adverb :x};

	subtest {
		my $source = Q{qqw <pi>};
		my $parsed = $pt.parse( $source );
		my $tree = $pt.build-tree( $parsed );
		is $pt.to-string( $tree ), $source,
			Q{formatted};
		ok (grep { $_ ~~ Perl6::String::Interpolation::WordQuoting },
				$tree.child.[0].child),
			Q{found string};

		done-testing;
	}, Q{ws, no adverbs};

	subtest {
		my $source = Q{qqw<pi>};
		my $parsed = $pt.parse( $source );
		my $tree = $pt.build-tree( $parsed );
		is $pt.to-string( $tree ), $source,
			Q{formatted};
		ok (grep { $_ ~~ Perl6::String::Interpolation::WordQuoting },
				$tree.child.[0].child),
			Q{found string};

		done-testing;
	}, Q{no ws, no adverbs};

	done-testing;
}, Q{qqw<>};

subtest {
	# qqx:q is illegal

	subtest {
		subtest {
			my $source = Q{qqx :to <END>
pi
END};
			my $parsed = $pt.parse( $source );
			my $tree = $pt.build-tree( $parsed );
			is $pt.to-string( $tree ), $source,
				Q{formatted};
			ok (grep { $_ ~~ Perl6::String::Interpolation::Shell },
					$tree.child.[0].child),
				Q{found string};

			done-testing;
		}, Q{all intervening ws};

		subtest {
			my $source = Q{qqx :to<END>
pi
END};
			my $parsed = $pt.parse( $source );
			my $tree = $pt.build-tree( $parsed );
			is $pt.to-string( $tree ), $source,
				Q{formatted};
			ok (grep { $_ ~~ Perl6::String::Interpolation::Shell },
					$tree.child.[0].child),
				Q{found string};

			done-testing;
		}, Q{leading intervening ws};

		subtest {
			my $source = Q{qqx:to <END>
pi
END};
			my $parsed = $pt.parse( $source );
			my $tree = $pt.build-tree( $parsed );
			is $pt.to-string( $tree ), $source,
				Q{formatted};
			ok (grep { $_ ~~ Perl6::String::Interpolation::Shell },
					$tree.child.[0].child),
				Q{found string};

			done-testing;
		}, Q{trailing intervening ws};

		subtest {
			my $source = Q{qqx:to<END>
pi
END};
			my $parsed = $pt.parse( $source );
			my $tree = $pt.build-tree( $parsed );
			is $pt.to-string( $tree ), $source,
				Q{formatted};
			ok (grep { $_ ~~ Perl6::String::Interpolation::Shell },
					$tree.child.[0].child),
				Q{found string};

			done-testing;
		}, Q{no intervening ws};

		done-testing;
	}, Q{adverb :to};

	subtest {
		subtest {
			my $source = Q{qqx :w <pi>};
			my $parsed = $pt.parse( $source );
			my $tree = $pt.build-tree( $parsed );
			is $pt.to-string( $tree ), $source,
				Q{formatted};
			ok (grep { $_ ~~ Perl6::String::Interpolation::Shell },
					$tree.child.[0].child),
				Q{found string};

			done-testing;
		}, Q{all intervening ws};

		subtest {
			my $source = Q{qqx :w<pi>};
			my $parsed = $pt.parse( $source );
			my $tree = $pt.build-tree( $parsed );
			is $pt.to-string( $tree ), $source,
				Q{formatted};
			ok (grep { $_ ~~ Perl6::String::Interpolation::Shell },
					$tree.child.[0].child),
				Q{found string};

			done-testing;
		}, Q{leading intervening ws};

		subtest {
			my $source = Q{qqx:w <pi>};
			my $parsed = $pt.parse( $source );
			my $tree = $pt.build-tree( $parsed );
			is $pt.to-string( $tree ), $source,
				Q{formatted};
			ok (grep { $_ ~~ Perl6::String::Interpolation::Shell },
					$tree.child.[0].child),
				Q{found string};

			done-testing;
		}, Q{trailing intervening ws};

		subtest {
			my $source = Q{qqx:w<pi>};
			my $parsed = $pt.parse( $source );
			my $tree = $pt.build-tree( $parsed );
			is $pt.to-string( $tree ), $source,
				Q{formatted};
			ok (grep { $_ ~~ Perl6::String::Interpolation::Shell },
					$tree.child.[0].child),
				Q{found string};

			done-testing;
		}, Q{no intervening ws};

		done-testing;
	}, Q{adverb :w};

	subtest {
		subtest {
			my $source = Q{qqx :x <pi>};
			my $parsed = $pt.parse( $source );
			my $tree = $pt.build-tree( $parsed );
			is $pt.to-string( $tree ), $source,
				Q{formatted};
			ok (grep { $_ ~~ Perl6::String::Interpolation::Shell },
					$tree.child.[0].child),
				Q{found string};

			done-testing;
		}, Q{all intervening ws};

		subtest {
			my $source = Q{qqx :x<pi>};
			my $parsed = $pt.parse( $source );
			my $tree = $pt.build-tree( $parsed );
			is $pt.to-string( $tree ), $source,
				Q{formatted};
			ok (grep { $_ ~~ Perl6::String::Interpolation::Shell },
					$tree.child.[0].child),
				Q{found string};

			done-testing;
		}, Q{leading intervening ws};

		subtest {
			my $source = Q{qqx:x <pi>};
			my $parsed = $pt.parse( $source );
			my $tree = $pt.build-tree( $parsed );
			is $pt.to-string( $tree ), $source,
				Q{formatted};
			ok (grep { $_ ~~ Perl6::String::Interpolation::Shell },
					$tree.child.[0].child),
				Q{found string};

			done-testing;
		}, Q{trailing intervening ws};

		subtest {
			my $source = Q{qqx:x<pi>};
			my $parsed = $pt.parse( $source );
			my $tree = $pt.build-tree( $parsed );
			is $pt.to-string( $tree ), $source,
				Q{formatted};
			ok (grep { $_ ~~ Perl6::String::Interpolation::Shell },
					$tree.child.[0].child),
				Q{found string};

			done-testing;
		}, Q{no intervening ws};

		done-testing;
	}, Q{adverb :x};

	subtest {
		my $source = Q{qqx <pi>};
		my $parsed = $pt.parse( $source );
		my $tree = $pt.build-tree( $parsed );
		is $pt.to-string( $tree ), $source,
			Q{formatted};
		ok (grep { $_ ~~ Perl6::String::Interpolation::Shell },
				$tree.child.[0].child),
			Q{found string};

		done-testing;
	}, Q{ws, no adverbs};

	subtest {
		my $source = Q{qqx<pi>};
		my $parsed = $pt.parse( $source );
		my $tree = $pt.build-tree( $parsed );
		is $pt.to-string( $tree ), $source,
			Q{formatted};
		ok (grep { $_ ~~ Perl6::String::Interpolation::Shell },
				$tree.child.[0].child),
			Q{found string};

		done-testing;
	}, Q{no ws, no adverbs};

	done-testing;
}, Q{qqx<>};

subtest {
	# qww:q is illegal

	subtest {
		subtest {
			my $source = Q{qww :to <END>
pi
END};
			my $parsed = $pt.parse( $source );
			my $tree = $pt.build-tree( $parsed );
			is $pt.to-string( $tree ), $source,
				Q{formatted};
			ok (grep { $_ ~~ Perl6::String::WordQuoting::QuoteProtection },
					$tree.child.[0].child),
				Q{found string};

			done-testing;
		}, Q{all intervening ws};

		subtest {
			my $source = Q{qww :to<END>
pi
END};
			my $parsed = $pt.parse( $source );
			my $tree = $pt.build-tree( $parsed );
			is $pt.to-string( $tree ), $source,
				Q{formatted};
			ok (grep { $_ ~~ Perl6::String::WordQuoting::QuoteProtection },
					$tree.child.[0].child),
				Q{found string};

			done-testing;
		}, Q{leading intervening ws};

		subtest {
			my $source = Q{qww:to <END>
pi
END};
			my $parsed = $pt.parse( $source );
			my $tree = $pt.build-tree( $parsed );
			is $pt.to-string( $tree ), $source,
				Q{formatted};
			ok (grep { $_ ~~ Perl6::String::WordQuoting::QuoteProtection },
					$tree.child.[0].child),
				Q{found string};

			done-testing;
		}, Q{trailing intervening ws};

		subtest {
			my $source = Q{qww:to<END>
pi
END};
			my $parsed = $pt.parse( $source );
			my $tree = $pt.build-tree( $parsed );
			is $pt.to-string( $tree ), $source,
				Q{formatted};
			ok (grep { $_ ~~ Perl6::String::WordQuoting::QuoteProtection },
					$tree.child.[0].child),
				Q{found string};

			done-testing;
		}, Q{no intervening ws};

		done-testing;
	}, Q{adverb :to};

	subtest {
		subtest {
			my $source = Q{qww :w <pi>};
			my $parsed = $pt.parse( $source );
			my $tree = $pt.build-tree( $parsed );
			is $pt.to-string( $tree ), $source,
				Q{formatted};
			ok (grep { $_ ~~ Perl6::String::WordQuoting::QuoteProtection },
					$tree.child.[0].child),
				Q{found string};

			done-testing;
		}, Q{all intervening ws};

		subtest {
			my $source = Q{qww :w<pi>};
			my $parsed = $pt.parse( $source );
			my $tree = $pt.build-tree( $parsed );
			is $pt.to-string( $tree ), $source,
				Q{formatted};
			ok (grep { $_ ~~ Perl6::String::WordQuoting::QuoteProtection },
					$tree.child.[0].child),
				Q{found string};

			done-testing;
		}, Q{leading intervening ws};

		subtest {
			my $source = Q{qww:w <pi>};
			my $parsed = $pt.parse( $source );
			my $tree = $pt.build-tree( $parsed );
			is $pt.to-string( $tree ), $source,
				Q{formatted};
			ok (grep { $_ ~~ Perl6::String::WordQuoting::QuoteProtection },
					$tree.child.[0].child),
				Q{found string};

			done-testing;
		}, Q{trailing intervening ws};

		subtest {
			my $source = Q{qww:w<pi>};
			my $parsed = $pt.parse( $source );
			my $tree = $pt.build-tree( $parsed );
			is $pt.to-string( $tree ), $source,
				Q{formatted};
			ok (grep { $_ ~~ Perl6::String::WordQuoting::QuoteProtection },
					$tree.child.[0].child),
				Q{found string};

			done-testing;
		}, Q{no intervening ws};

		done-testing;
	}, Q{adverb :w};

	subtest {
		subtest {
			my $source = Q{qww :x <pi>};
			my $parsed = $pt.parse( $source );
			my $tree = $pt.build-tree( $parsed );
			is $pt.to-string( $tree ), $source,
				Q{formatted};
			ok (grep { $_ ~~ Perl6::String::WordQuoting::QuoteProtection },
					$tree.child.[0].child),
				Q{found string};

			done-testing;
		}, Q{all intervening ws};

		subtest {
			my $source = Q{qww :x<pi>};
			my $parsed = $pt.parse( $source );
			my $tree = $pt.build-tree( $parsed );
			is $pt.to-string( $tree ), $source,
				Q{formatted};
			ok (grep { $_ ~~ Perl6::String::WordQuoting::QuoteProtection },
					$tree.child.[0].child),
				Q{found string};

			done-testing;
		}, Q{leading intervening ws};

		subtest {
			my $source = Q{qww:x <pi>};
			my $parsed = $pt.parse( $source );
			my $tree = $pt.build-tree( $parsed );
			is $pt.to-string( $tree ), $source,
				Q{formatted};
			ok (grep { $_ ~~ Perl6::String::WordQuoting::QuoteProtection },
					$tree.child.[0].child),
				Q{found string};

			done-testing;
		}, Q{trailing intervening ws};

		subtest {
			my $source = Q{qww:x<pi>};
			my $parsed = $pt.parse( $source );
			my $tree = $pt.build-tree( $parsed );
			is $pt.to-string( $tree ), $source,
				Q{formatted};
			ok (grep { $_ ~~ Perl6::String::WordQuoting::QuoteProtection },
					$tree.child.[0].child),
				Q{found string};

			done-testing;
		}, Q{no intervening ws};

		done-testing;
	}, Q{adverb :x};

	subtest {
		my $source = Q{qww <pi>};
		my $parsed = $pt.parse( $source );
		my $tree = $pt.build-tree( $parsed );
		is $pt.to-string( $tree ), $source,
			Q{formatted};
		ok (grep { $_ ~~ Perl6::String::WordQuoting::QuoteProtection },
				$tree.child.[0].child),
			Q{found string};

		done-testing;
	}, Q{ws, no adverbs};

	subtest {
		my $source = Q{qww<pi>};
		my $parsed = $pt.parse( $source );
		my $tree = $pt.build-tree( $parsed );
		is $pt.to-string( $tree ), $source,
			Q{formatted};
		ok (grep { $_ ~~ Perl6::String::WordQuoting::QuoteProtection },
				$tree.child.[0].child),
			Q{found string};

		done-testing;
	}, Q{no ws, no adverbs};

	done-testing;
}, Q{qww<>};

# Qq is illegal

subtest {
	subtest {
		subtest {
			my $source = Q{Qw :q <pi>};
			my $parsed = $pt.parse( $source );
			my $tree = $pt.build-tree( $parsed );
			is $pt.to-string( $tree ), $source,
				Q{formatted};
			ok (grep { $_ ~~ Perl6::String::Literal::WordQuoting },
					$tree.child.[0].child),
				Q{found string};

			done-testing;
		}, Q{all intervening ws};

		subtest {
			my $source = Q{Qw :q<pi>};
			my $parsed = $pt.parse( $source );
			my $tree = $pt.build-tree( $parsed );
			is $pt.to-string( $tree ), $source,
				Q{formatted};
			ok (grep { $_ ~~ Perl6::String::Literal::WordQuoting },
					$tree.child.[0].child),
				Q{found string};

			done-testing;
		}, Q{leading intervening ws};

		subtest {
			my $source = Q{Qw:q <pi>};
			my $parsed = $pt.parse( $source );
			my $tree = $pt.build-tree( $parsed );
			is $pt.to-string( $tree ), $source,
				Q{formatted};
			ok (grep { $_ ~~ Perl6::String::Literal::WordQuoting },
					$tree.child.[0].child),
				Q{found string};

			done-testing;
		}, Q{trailing intervening ws};

		subtest {
			my $source = Q{Qw:q<pi>};
			my $parsed = $pt.parse( $source );
			my $tree = $pt.build-tree( $parsed );
			is $pt.to-string( $tree ), $source,
				Q{formatted};
			ok (grep { $_ ~~ Perl6::String::Literal::WordQuoting },
					$tree.child.[0].child),
				Q{found string};

			done-testing;
		}, Q{no intervening ws};

		done-testing;
	}, Q{adverb :q};

	subtest {
		subtest {
			my $source = Q{Qw :to <END>
pi
END};
			my $parsed = $pt.parse( $source );
			my $tree = $pt.build-tree( $parsed );
			is $pt.to-string( $tree ), $source,
				Q{formatted};
			ok (grep { $_ ~~ Perl6::String::Literal::WordQuoting },
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
			is $pt.to-string( $tree ), $source,
				Q{formatted};
			ok (grep { $_ ~~ Perl6::String::Literal::WordQuoting },
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
			is $pt.to-string( $tree ), $source,
				Q{formatted};
			ok (grep { $_ ~~ Perl6::String::Literal::WordQuoting },
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
			is $pt.to-string( $tree ), $source,
				Q{formatted};
			ok (grep { $_ ~~ Perl6::String::Literal::WordQuoting },
					$tree.child.[0].child),
				Q{found string};

			done-testing;
		}, Q{no intervening ws};

		done-testing;
	}, Q{adverb :to};

	subtest {
		subtest {
			my $source = Q{Qw :w <pi>};
			my $parsed = $pt.parse( $source );
			my $tree = $pt.build-tree( $parsed );
			is $pt.to-string( $tree ), $source,
				Q{formatted};
			ok (grep { $_ ~~ Perl6::String::Literal::WordQuoting },
					$tree.child.[0].child),
				Q{found string};

			done-testing;
		}, Q{all intervening ws};

		subtest {
			my $source = Q{Qw :w<pi>};
			my $parsed = $pt.parse( $source );
			my $tree = $pt.build-tree( $parsed );
			is $pt.to-string( $tree ), $source,
				Q{formatted};
			ok (grep { $_ ~~ Perl6::String::Literal::WordQuoting },
					$tree.child.[0].child),
				Q{found string};

			done-testing;
		}, Q{leading intervening ws};

		subtest {
			my $source = Q{Qw:w <pi>};
			my $parsed = $pt.parse( $source );
			my $tree = $pt.build-tree( $parsed );
			is $pt.to-string( $tree ), $source,
				Q{formatted};
			ok (grep { $_ ~~ Perl6::String::Literal::WordQuoting },
					$tree.child.[0].child),
				Q{found string};

			done-testing;
		}, Q{trailing intervening ws};

		subtest {
			my $source = Q{Qw:w<pi>};
			my $parsed = $pt.parse( $source );
			my $tree = $pt.build-tree( $parsed );
			is $pt.to-string( $tree ), $source,
				Q{formatted};
			ok (grep { $_ ~~ Perl6::String::Literal::WordQuoting },
					$tree.child.[0].child),
				Q{found string};

			done-testing;
		}, Q{no intervening ws};

		done-testing;
	}, Q{adverb :w};

	subtest {
		subtest {
			my $source = Q{Qw :x <pi>};
			my $parsed = $pt.parse( $source );
			my $tree = $pt.build-tree( $parsed );
			is $pt.to-string( $tree ), $source,
				Q{formatted};
			ok (grep { $_ ~~ Perl6::String::Literal::WordQuoting },
					$tree.child.[0].child),
				Q{found string};

			done-testing;
		}, Q{all intervening ws};

		subtest {
			my $source = Q{Qw :x<pi>};
			my $parsed = $pt.parse( $source );
			my $tree = $pt.build-tree( $parsed );
			is $pt.to-string( $tree ), $source,
				Q{formatted};
			ok (grep { $_ ~~ Perl6::String::Literal::WordQuoting },
					$tree.child.[0].child),
				Q{found string};

			done-testing;
		}, Q{leading intervening ws};

		subtest {
			my $source = Q{Qw:x <pi>};
			my $parsed = $pt.parse( $source );
			my $tree = $pt.build-tree( $parsed );
			is $pt.to-string( $tree ), $source,
				Q{formatted};
			ok (grep { $_ ~~ Perl6::String::Literal::WordQuoting },
					$tree.child.[0].child),
				Q{found string};

			done-testing;
		}, Q{trailing intervening ws};

		subtest {
			my $source = Q{Qw:x<pi>};
			my $parsed = $pt.parse( $source );
			my $tree = $pt.build-tree( $parsed );
			is $pt.to-string( $tree ), $source,
				Q{formatted};
			ok (grep { $_ ~~ Perl6::String::Literal::WordQuoting },
					$tree.child.[0].child),
				Q{found string};

			done-testing;
		}, Q{no intervening ws};

		done-testing;
	}, Q{adverb :x};

	subtest {
		my $source = Q{Qw <pi>};
		my $parsed = $pt.parse( $source );
		my $tree = $pt.build-tree( $parsed );
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
			is $pt.to-string( $tree ), $source,
				Q{formatted};
			ok (grep { $_ ~~ Perl6::String::Literal::Shell },
					$tree.child.[0].child),
				Q{found string};

			done-testing;
		}, Q{all intervening ws};

		subtest {
			my $source = Q{Qx :q<pi>};
			my $parsed = $pt.parse( $source );
			my $tree = $pt.build-tree( $parsed );
			is $pt.to-string( $tree ), $source,
				Q{formatted};
			ok (grep { $_ ~~ Perl6::String::Literal::Shell },
					$tree.child.[0].child),
				Q{found string};

			done-testing;
		}, Q{leading intervening ws};

		subtest {
			my $source = Q{Qx:q <pi>};
			my $parsed = $pt.parse( $source );
			my $tree = $pt.build-tree( $parsed );
			is $pt.to-string( $tree ), $source,
				Q{formatted};
			ok (grep { $_ ~~ Perl6::String::Literal::Shell },
					$tree.child.[0].child),
				Q{found string};

			done-testing;
		}, Q{trailing intervening ws};

		subtest {
			my $source = Q{Qx:q<pi>};
			my $parsed = $pt.parse( $source );
			my $tree = $pt.build-tree( $parsed );
			is $pt.to-string( $tree ), $source,
				Q{formatted};
			ok (grep { $_ ~~ Perl6::String::Literal::Shell },
					$tree.child.[0].child),
				Q{found string};

			done-testing;
		}, Q{no intervening ws};

		done-testing;
	}, Q{adverb :q};

	subtest {
		subtest {
			my $source = Q{Qx :to <END>
pi
END};
			my $parsed = $pt.parse( $source );
			my $tree = $pt.build-tree( $parsed );
			is $pt.to-string( $tree ), $source,
				Q{formatted};
			ok (grep { $_ ~~ Perl6::String::Literal::Shell },
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
			is $pt.to-string( $tree ), $source,
				Q{formatted};
			ok (grep { $_ ~~ Perl6::String::Literal::Shell },
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
			is $pt.to-string( $tree ), $source,
				Q{formatted};
			ok (grep { $_ ~~ Perl6::String::Literal::Shell },
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
			is $pt.to-string( $tree ), $source,
				Q{formatted};
			ok (grep { $_ ~~ Perl6::String::Literal::Shell },
					$tree.child.[0].child),
				Q{found string};

			done-testing;
		}, Q{no intervening ws};

		done-testing;
	}, Q{adverb :to};

	subtest {
		subtest {
			my $source = Q{Qx :w <pi>};
			my $parsed = $pt.parse( $source );
			my $tree = $pt.build-tree( $parsed );
			is $pt.to-string( $tree ), $source,
				Q{formatted};
			ok (grep { $_ ~~ Perl6::String::Literal::Shell },
					$tree.child.[0].child),
				Q{found string};

			done-testing;
		}, Q{all intervening ws};

		subtest {
			my $source = Q{Qx :w<pi>};
			my $parsed = $pt.parse( $source );
			my $tree = $pt.build-tree( $parsed );
			is $pt.to-string( $tree ), $source,
				Q{formatted};
			ok (grep { $_ ~~ Perl6::String::Literal::Shell },
					$tree.child.[0].child),
				Q{found string};

			done-testing;
		}, Q{leading intervening ws};

		subtest {
			my $source = Q{Qx:w <pi>};
			my $parsed = $pt.parse( $source );
			my $tree = $pt.build-tree( $parsed );
			is $pt.to-string( $tree ), $source,
				Q{formatted};
			ok (grep { $_ ~~ Perl6::String::Literal::Shell },
					$tree.child.[0].child),
				Q{found string};

			done-testing;
		}, Q{trailing intervening ws};

		subtest {
			my $source = Q{Qx:w<pi>};
			my $parsed = $pt.parse( $source );
			my $tree = $pt.build-tree( $parsed );
			is $pt.to-string( $tree ), $source,
				Q{formatted};
			ok (grep { $_ ~~ Perl6::String::Literal::Shell },
					$tree.child.[0].child),
				Q{found string};

			done-testing;
		}, Q{no intervening ws};

		done-testing;
	}, Q{adverb :w};

	subtest {
		subtest {
			my $source = Q{Qx :x <pi>};
			my $parsed = $pt.parse( $source );
			my $tree = $pt.build-tree( $parsed );
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
			is $pt.to-string( $tree ), $source,
				Q{formatted};
			ok (grep { $_ ~~ Perl6::String::Literal::Shell },
					$tree.child.[0].child),
				Q{found string};

			done-testing;
		}, Q{no intervening ws};

		done-testing;
	}, Q{adverb :x};

	subtest {
		my $source = Q{Qx <pi>};
		my $parsed = $pt.parse( $source );
		my $tree = $pt.build-tree( $parsed );
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
			my $source = Q{qq :w <pi>};
			my $parsed = $pt.parse( $source );
			my $tree = $pt.build-tree( $parsed );
			is $pt.to-string( $tree ), $source,
				Q{formatted};
			ok (grep { $_ ~~ Perl6::String::Interpolation },
					$tree.child.[0].child),
				Q{found string};

			done-testing;
		}, Q{all intervening ws};

		subtest {
			my $source = Q{qq :w<pi>};
			my $parsed = $pt.parse( $source );
			my $tree = $pt.build-tree( $parsed );
			is $pt.to-string( $tree ), $source,
				Q{formatted};
			ok (grep { $_ ~~ Perl6::String::Interpolation },
					$tree.child.[0].child),
				Q{found string};

			done-testing;
		}, Q{leading intervening ws};

		subtest {
			my $source = Q{qq:w <pi>};
			my $parsed = $pt.parse( $source );
			my $tree = $pt.build-tree( $parsed );
			is $pt.to-string( $tree ), $source,
				Q{formatted};
			ok (grep { $_ ~~ Perl6::String::Interpolation },
					$tree.child.[0].child),
				Q{found string};

			done-testing;
		}, Q{trailing intervening ws};

		subtest {
			my $source = Q{qq:w<pi>};
			my $parsed = $pt.parse( $source );
			my $tree = $pt.build-tree( $parsed );
			is $pt.to-string( $tree ), $source,
				Q{formatted};
			ok (grep { $_ ~~ Perl6::String::Interpolation },
					$tree.child.[0].child),
				Q{found string};

			done-testing;
		}, Q{no intervening ws};

		done-testing;
	}, Q{adverb :w};

	subtest {
		subtest {
			my $source = Q{qq :x <pi>};
			my $parsed = $pt.parse( $source );
			my $tree = $pt.build-tree( $parsed );
			is $pt.to-string( $tree ), $source,
				Q{formatted};
			ok (grep { $_ ~~ Perl6::String::Interpolation },
					$tree.child.[0].child),
				Q{found string};

			done-testing;
		}, Q{all intervening ws};

		subtest {
			my $source = Q{qq :x<pi>};
			my $parsed = $pt.parse( $source );
			my $tree = $pt.build-tree( $parsed );
			is $pt.to-string( $tree ), $source,
				Q{formatted};
			ok (grep { $_ ~~ Perl6::String::Interpolation },
					$tree.child.[0].child),
				Q{found string};

			done-testing;
		}, Q{leading intervening ws};

		subtest {
			my $source = Q{qq:x <pi>};
			my $parsed = $pt.parse( $source );
			my $tree = $pt.build-tree( $parsed );
			is $pt.to-string( $tree ), $source,
				Q{formatted};
			ok (grep { $_ ~~ Perl6::String::Interpolation },
					$tree.child.[0].child),
				Q{found string};

			done-testing;
		}, Q{trailing intervening ws};

		subtest {
			my $source = Q{qq:x<pi>};
			my $parsed = $pt.parse( $source );
			my $tree = $pt.build-tree( $parsed );
			is $pt.to-string( $tree ), $source,
				Q{formatted};
			ok (grep { $_ ~~ Perl6::String::Interpolation },
					$tree.child.[0].child),
				Q{found string};

			done-testing;
		}, Q{no intervening ws};

		done-testing;
	}, Q{adverb :x};

	subtest {
		my $source = Q{qq <pi>};
		my $parsed = $pt.parse( $source );
		my $tree = $pt.build-tree( $parsed );
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

	subtest {
		subtest {
			my $source = Q{qw :to <END>
pi
END};
			my $parsed = $pt.parse( $source );
			my $tree = $pt.build-tree( $parsed );
			is $pt.to-string( $tree ), $source,
				Q{formatted};
			ok (grep { $_ ~~ Perl6::String::WordQuoting },
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
			is $pt.to-string( $tree ), $source,
				Q{formatted};
			ok (grep { $_ ~~ Perl6::String::WordQuoting },
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
			is $pt.to-string( $tree ), $source,
				Q{formatted};
			ok (grep { $_ ~~ Perl6::String::WordQuoting },
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
			is $pt.to-string( $tree ), $source,
				Q{formatted};
			ok (grep { $_ ~~ Perl6::String::WordQuoting },
					$tree.child.[0].child),
				Q{found string};

			done-testing;
		}, Q{no intervening ws};

		done-testing;
	}, Q{adverb :to};

	subtest {
		subtest {
			my $source = Q{qw :w <pi>};
			my $parsed = $pt.parse( $source );
			my $tree = $pt.build-tree( $parsed );
			is $pt.to-string( $tree ), $source,
				Q{formatted};
			ok (grep { $_ ~~ Perl6::String::WordQuoting },
					$tree.child.[0].child),
				Q{found string};

			done-testing;
		}, Q{all intervening ws};

		subtest {
			my $source = Q{qw :w<pi>};
			my $parsed = $pt.parse( $source );
			my $tree = $pt.build-tree( $parsed );
			is $pt.to-string( $tree ), $source,
				Q{formatted};
			ok (grep { $_ ~~ Perl6::String::WordQuoting },
					$tree.child.[0].child),
				Q{found string};

			done-testing;
		}, Q{leading intervening ws};

		subtest {
			my $source = Q{qw:w <pi>};
			my $parsed = $pt.parse( $source );
			my $tree = $pt.build-tree( $parsed );
			is $pt.to-string( $tree ), $source,
				Q{formatted};
			ok (grep { $_ ~~ Perl6::String::WordQuoting },
					$tree.child.[0].child),
				Q{found string};

			done-testing;
		}, Q{trailing intervening ws};

		subtest {
			my $source = Q{qw:w<pi>};
			my $parsed = $pt.parse( $source );
			my $tree = $pt.build-tree( $parsed );
			is $pt.to-string( $tree ), $source,
				Q{formatted};
			ok (grep { $_ ~~ Perl6::String::WordQuoting },
					$tree.child.[0].child),
				Q{found string};

			done-testing;
		}, Q{no intervening ws};

		done-testing;
	}, Q{adverb :w};

	subtest {
		subtest {
			my $source = Q{qw :x <pi>};
			my $parsed = $pt.parse( $source );
			my $tree = $pt.build-tree( $parsed );
			is $pt.to-string( $tree ), $source,
				Q{formatted};
			ok (grep { $_ ~~ Perl6::String::WordQuoting },
					$tree.child.[0].child),
				Q{found string};

			done-testing;
		}, Q{all intervening ws};

		subtest {
			my $source = Q{qw :x<pi>};
			my $parsed = $pt.parse( $source );
			my $tree = $pt.build-tree( $parsed );
			is $pt.to-string( $tree ), $source,
				Q{formatted};
			ok (grep { $_ ~~ Perl6::String::WordQuoting },
					$tree.child.[0].child),
				Q{found string};

			done-testing;
		}, Q{leading intervening ws};

		subtest {
			my $source = Q{qw:x <pi>};
			my $parsed = $pt.parse( $source );
			my $tree = $pt.build-tree( $parsed );
			is $pt.to-string( $tree ), $source,
				Q{formatted};
			ok (grep { $_ ~~ Perl6::String::WordQuoting },
					$tree.child.[0].child),
				Q{found string};

			done-testing;
		}, Q{trailing intervening ws};

		subtest {
			my $source = Q{qw:x<pi>};
			my $parsed = $pt.parse( $source );
			my $tree = $pt.build-tree( $parsed );
			is $pt.to-string( $tree ), $source,
				Q{formatted};
			ok (grep { $_ ~~ Perl6::String::WordQuoting },
					$tree.child.[0].child),
				Q{found string};

			done-testing;
		}, Q{no intervening ws};

		done-testing;
	}, Q{adverb :x};

	subtest {
		my $source = Q{qw <pi>};
		my $parsed = $pt.parse( $source );
		my $tree = $pt.build-tree( $parsed );
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

	subtest {
		subtest {
			my $source = Q{qx :to <END>
pi
END};
			my $parsed = $pt.parse( $source );
			my $tree = $pt.build-tree( $parsed );
			is $pt.to-string( $tree ), $source,
				Q{formatted};
			ok (grep { $_ ~~ Perl6::String::Shell },
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
			is $pt.to-string( $tree ), $source,
				Q{formatted};
			ok (grep { $_ ~~ Perl6::String::Shell },
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
			is $pt.to-string( $tree ), $source,
				Q{formatted};
			ok (grep { $_ ~~ Perl6::String::Shell },
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
			is $pt.to-string( $tree ), $source,
				Q{formatted};
			ok (grep { $_ ~~ Perl6::String::Shell },
					$tree.child.[0].child),
				Q{found string};

			done-testing;
		}, Q{no intervening ws};

		done-testing;
	}, Q{adverb :to};

	subtest {
		subtest {
			my $source = Q{qx :w <pi>};
			my $parsed = $pt.parse( $source );
			my $tree = $pt.build-tree( $parsed );
			is $pt.to-string( $tree ), $source,
				Q{formatted};
			ok (grep { $_ ~~ Perl6::String::Shell },
					$tree.child.[0].child),
				Q{found string};

			done-testing;
		}, Q{all intervening ws};

		subtest {
			my $source = Q{qx :w<pi>};
			my $parsed = $pt.parse( $source );
			my $tree = $pt.build-tree( $parsed );
			is $pt.to-string( $tree ), $source,
				Q{formatted};
			ok (grep { $_ ~~ Perl6::String::Shell },
					$tree.child.[0].child),
				Q{found string};

			done-testing;
		}, Q{leading intervening ws};

		subtest {
			my $source = Q{qx:w <pi>};
			my $parsed = $pt.parse( $source );
			my $tree = $pt.build-tree( $parsed );
			is $pt.to-string( $tree ), $source,
				Q{formatted};
			ok (grep { $_ ~~ Perl6::String::Shell },
					$tree.child.[0].child),
				Q{found string};

			done-testing;
		}, Q{trailing intervening ws};

		subtest {
			my $source = Q{qx:w<pi>};
			my $parsed = $pt.parse( $source );
			my $tree = $pt.build-tree( $parsed );
			is $pt.to-string( $tree ), $source,
				Q{formatted};
			ok (grep { $_ ~~ Perl6::String::Shell },
					$tree.child.[0].child),
				Q{found string};

			done-testing;
		}, Q{no intervening ws};

		done-testing;
	}, Q{adverb :w};

	subtest {
		subtest {
			my $source = Q{qx :x <pi>};
			my $parsed = $pt.parse( $source );
			my $tree = $pt.build-tree( $parsed );
			is $pt.to-string( $tree ), $source,
				Q{formatted};
			ok (grep { $_ ~~ Perl6::String::Shell },
					$tree.child.[0].child),
				Q{found string};

			done-testing;
		}, Q{all intervening ws};

		subtest {
			my $source = Q{qx :x<pi>};
			my $parsed = $pt.parse( $source );
			my $tree = $pt.build-tree( $parsed );
			is $pt.to-string( $tree ), $source,
				Q{formatted};
			ok (grep { $_ ~~ Perl6::String::Shell },
					$tree.child.[0].child),
				Q{found string};

			done-testing;
		}, Q{leading intervening ws};

		subtest {
			my $source = Q{qx:x <pi>};
			my $parsed = $pt.parse( $source );
			my $tree = $pt.build-tree( $parsed );
			is $pt.to-string( $tree ), $source,
				Q{formatted};
			ok (grep { $_ ~~ Perl6::String::Shell },
					$tree.child.[0].child),
				Q{found string};

			done-testing;
		}, Q{trailing intervening ws};

		subtest {
			my $source = Q{qx:x<pi>};
			my $parsed = $pt.parse( $source );
			my $tree = $pt.build-tree( $parsed );
			is $pt.to-string( $tree ), $source,
				Q{formatted};
			ok (grep { $_ ~~ Perl6::String::Shell },
					$tree.child.[0].child),
				Q{found string};

			done-testing;
		}, Q{no intervening ws};

		done-testing;
	}, Q{adverb :x};

	subtest {
		my $source = Q{qx <pi>};
		my $parsed = $pt.parse( $source );
		my $tree = $pt.build-tree( $parsed );
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
			is $pt.to-string( $tree ), $source,
				Q{formatted};
			ok (grep { $_ ~~ Perl6::String::Literal },
					$tree.child.[0].child),
				Q{found string};

			done-testing;
		}, Q{all intervening ws};

		subtest {
			my $source = Q{Q :q<pi>};
			my $parsed = $pt.parse( $source );
			my $tree = $pt.build-tree( $parsed );
			is $pt.to-string( $tree ), $source,
				Q{formatted};
			ok (grep { $_ ~~ Perl6::String::Literal },
					$tree.child.[0].child),
				Q{found string};

			done-testing;
		}, Q{leading intervening ws};

		subtest {
			my $source = Q{Q:q <pi>};
			my $parsed = $pt.parse( $source );
			my $tree = $pt.build-tree( $parsed );
			is $pt.to-string( $tree ), $source,
				Q{formatted};
			ok (grep { $_ ~~ Perl6::String::Literal },
					$tree.child.[0].child),
				Q{found string};

			done-testing;
		}, Q{trailing intervening ws};

		subtest {
			my $source = Q{Q:q<pi>};
			my $parsed = $pt.parse( $source );
			my $tree = $pt.build-tree( $parsed );
			is $pt.to-string( $tree ), $source,
				Q{formatted};
			ok (grep { $_ ~~ Perl6::String::Literal },
					$tree.child.[0].child),
				Q{found string};

			done-testing;
		}, Q{no intervening ws};

		done-testing;
	}, Q{adverb :q};

	subtest {
		subtest {
			my $source = Q{Q :to <END>
pi
END
};
			my $parsed = $pt.parse( $source );
			my $tree = $pt.build-tree( $parsed );
			is $pt.to-string( $tree ), $source,
				Q{formatted};
			ok (grep { $_ ~~ Perl6::String::Literal },
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
			is $pt.to-string( $tree ), $source,
				Q{formatted};
			ok (grep { $_ ~~ Perl6::String::Literal },
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
			is $pt.to-string( $tree ), $source,
				Q{formatted};
			ok (grep { $_ ~~ Perl6::String::Literal },
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
			is $pt.to-string( $tree ), $source,
				Q{formatted};
			ok (grep { $_ ~~ Perl6::String::Literal },
					$tree.child.[0].child),
				Q{found string};

			done-testing;
		}, Q{no intervening ws};

		done-testing;
	}, Q{adverb :to};

	subtest {
		subtest {
			my $source = Q{Q :w <pi>};
			my $parsed = $pt.parse( $source );
			my $tree = $pt.build-tree( $parsed );
			is $pt.to-string( $tree ), $source,
				Q{formatted};
			ok (grep { $_ ~~ Perl6::String::Literal },
					$tree.child.[0].child),
				Q{found string};

			done-testing;
		}, Q{all intervening ws};

		subtest {
			my $source = Q{Q :w<pi>};
			my $parsed = $pt.parse( $source );
			my $tree = $pt.build-tree( $parsed );
			is $pt.to-string( $tree ), $source,
				Q{formatted};
			ok (grep { $_ ~~ Perl6::String::Literal },
					$tree.child.[0].child),
				Q{found string};

			done-testing;
		}, Q{leading intervening ws};

		subtest {
			my $source = Q{Q:w <pi>};
			my $parsed = $pt.parse( $source );
			my $tree = $pt.build-tree( $parsed );
			is $pt.to-string( $tree ), $source,
				Q{formatted};
			ok (grep { $_ ~~ Perl6::String::Literal },
					$tree.child.[0].child),
				Q{found string};

			done-testing;
		}, Q{trailing intervening ws};

		subtest {
			my $source = Q{Q:w<pi>};
			my $parsed = $pt.parse( $source );
			my $tree = $pt.build-tree( $parsed );
			is $pt.to-string( $tree ), $source,
				Q{formatted};
			ok (grep { $_ ~~ Perl6::String::Literal },
					$tree.child.[0].child),
				Q{found string};

			done-testing;
		}, Q{no intervening ws};

		done-testing;
	}, Q{adverb :w};

	subtest {
		subtest {
			my $source = Q{Q :x <pi>};
			my $parsed = $pt.parse( $source );
			my $tree = $pt.build-tree( $parsed );
			is $pt.to-string( $tree ), $source,
				Q{formatted};
			ok (grep { $_ ~~ Perl6::String::Literal },
					$tree.child.[0].child),
				Q{found string};

			done-testing;
		}, Q{all intervening ws};

		subtest {
			my $source = Q{Q :x<pi>};
			my $parsed = $pt.parse( $source );
			my $tree = $pt.build-tree( $parsed );
			is $pt.to-string( $tree ), $source,
				Q{formatted};
			ok (grep { $_ ~~ Perl6::String::Literal },
					$tree.child.[0].child),
				Q{found string};

			done-testing;
		}, Q{leading intervening ws};

		subtest {
			my $source = Q{Q:x <pi>};
			my $parsed = $pt.parse( $source );
			my $tree = $pt.build-tree( $parsed );
			is $pt.to-string( $tree ), $source,
				Q{formatted};
			ok (grep { $_ ~~ Perl6::String::Literal },
					$tree.child.[0].child),
				Q{found string};

			done-testing;
		}, Q{trailing intervening ws};

		subtest {
			my $source = Q{Q:x<pi>};
			my $parsed = $pt.parse( $source );
			my $tree = $pt.build-tree( $parsed );
			is $pt.to-string( $tree ), $source,
				Q{formatted};
			ok (grep { $_ ~~ Perl6::String::Literal },
					$tree.child.[0].child),
				Q{found string};

			done-testing;
		}, Q{no intervening ws};

		done-testing;
	}, Q{adverb :x};

	subtest {
		my $source = Q{Q <pi>};
		my $parsed = $pt.parse( $source );
		my $tree = $pt.build-tree( $parsed );
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

	subtest {
		subtest {
			my $source = Q{q :to <END>
pi
END
};
			my $parsed = $pt.parse( $source );
			my $tree = $pt.build-tree( $parsed );
			is $pt.to-string( $tree ), $source,
				Q{formatted};
			# XXX Make sure to check the here-doc contents exist
			ok (grep { $_ ~~ Perl6::String::Escaping },
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
			is $pt.to-string( $tree ), $source,
				Q{formatted};
			ok (grep { $_ ~~ Perl6::String::Escaping },
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
			is $pt.to-string( $tree ), $source,
				Q{formatted};
			ok (grep { $_ ~~ Perl6::String::Escaping },
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
			is $pt.to-string( $tree ), $source,
				Q{formatted};
			ok (grep { $_ ~~ Perl6::String::Escaping },
					$tree.child.[0].child),
				Q{found string};

			done-testing;
		}, Q{no intervening ws};

		done-testing;
	}, Q{adverb :to};

	subtest {
		subtest {
			my $source = Q{q :w <pi>};
			my $parsed = $pt.parse( $source );
			my $tree = $pt.build-tree( $parsed );
			is $pt.to-string( $tree ), $source,
				Q{formatted};
			ok (grep { $_ ~~ Perl6::String::Escaping },
					$tree.child.[0].child),
				Q{found string};

			done-testing;
		}, Q{all intervening ws};

		subtest {
			my $source = Q{q :w<pi>};
			my $parsed = $pt.parse( $source );
			my $tree = $pt.build-tree( $parsed );
			is $pt.to-string( $tree ), $source,
				Q{formatted};
			ok (grep { $_ ~~ Perl6::String::Escaping },
					$tree.child.[0].child),
				Q{found string};

			done-testing;
		}, Q{leading intervening ws};

		subtest {
			my $source = Q{q:w <pi>};
			my $parsed = $pt.parse( $source );
			my $tree = $pt.build-tree( $parsed );
			is $pt.to-string( $tree ), $source,
				Q{formatted};
			ok (grep { $_ ~~ Perl6::String::Escaping },
					$tree.child.[0].child),
				Q{found string};

			done-testing;
		}, Q{trailing intervening ws};

		subtest {
			my $source = Q{q:w<pi>};
			my $parsed = $pt.parse( $source );
			my $tree = $pt.build-tree( $parsed );
			is $pt.to-string( $tree ), $source,
				Q{formatted};
			ok (grep { $_ ~~ Perl6::String::Escaping },
					$tree.child.[0].child),
				Q{found string};

			done-testing;
		}, Q{no intervening ws};

		done-testing;
	}, Q{adverb :w};

	subtest {
		subtest {
			my $source = Q{q :x <pi>};
			my $parsed = $pt.parse( $source );
			my $tree = $pt.build-tree( $parsed );
			is $pt.to-string( $tree ), $source,
				Q{formatted};
			ok (grep { $_ ~~ Perl6::String::Escaping },
					$tree.child.[0].child),
				Q{found string};

			done-testing;
		}, Q{all intervening ws};

		subtest {
			my $source = Q{q :x<pi>};
			my $parsed = $pt.parse( $source );
			my $tree = $pt.build-tree( $parsed );
			is $pt.to-string( $tree ), $source,
				Q{formatted};
			ok (grep { $_ ~~ Perl6::String::Escaping },
					$tree.child.[0].child),
				Q{found string};

			done-testing;
		}, Q{leading intervening ws};

		subtest {
			my $source = Q{q:x <pi>};
			my $parsed = $pt.parse( $source );
			my $tree = $pt.build-tree( $parsed );
			is $pt.to-string( $tree ), $source,
				Q{formatted};
			ok (grep { $_ ~~ Perl6::String::Escaping },
					$tree.child.[0].child),
				Q{found string};

			done-testing;
		}, Q{trailing intervening ws};

		subtest {
			my $source = Q{q:x<pi>};
			my $parsed = $pt.parse( $source );
			my $tree = $pt.build-tree( $parsed );
			is $pt.to-string( $tree ), $source,
				Q{formatted};
			ok (grep { $_ ~~ Perl6::String::Escaping },
					$tree.child.[0].child),
				Q{found string};

			done-testing;
		}, Q{no intervening ws};

		done-testing;
	}, Q{adverb :x};

	subtest {
		my $source = Q{q <pi>};
		my $parsed = $pt.parse( $source );
		my $tree = $pt.build-tree( $parsed );
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
	is $pt.to-string( $tree ), $source, Q{formatted};
	ok $tree.child.[0].child.[0] ~~ Perl6::String::Literal;
	is $tree.child.[0].child.[0].delimiter-start, Q{｢}, Q{start delimiter};
	is $tree.child.[0].child.[0].delimiter-end, Q{｣}, Q{end delimiter};

	done-testing;
}, Q{｢｣};

subtest {
	my $source = Q{"pi"};
	my $parsed = $pt.parse( $source );
	my $tree = $pt.build-tree( $parsed );
	is $pt.to-string( $tree ), $source, Q{formatted};
	ok $tree.child.[0].child.[0] ~~ Perl6::String::Interpolation;
	is $tree.child.[0].child.[0].delimiter-start, Q{"}, Q{start delimiter};
	is $tree.child.[0].child.[0].delimiter-end, Q{"}, Q{end delimiter};

	done-testing;
}, Q{"" (double-quote)};

subtest {
	my $source = Q{'pi'};
	my $parsed = $pt.parse( $source );
	my $tree = $pt.build-tree( $parsed );
	is $pt.to-string( $tree ), $source, Q{formatted};
	ok $tree.child.[0].child.[0] ~~ Perl6::String::Escaping;
	is $tree.child.[0].child.[0].delimiter-start, Q{'}, Q{start delimiter};
	is $tree.child.[0].child.[0].delimiter-end, Q{'}, Q{end delimiter};

	done-testing;
}, Q{'' (single-quote)};

subtest {
#`[
	my $source = Q:to[END];
say join " ", .lines given q:to/📝/, qq:to/📝/
Hey,
📝
    dawg {
        [~] q:to/📝/, qq:to/📝/
        I heard you
        📝
            liked heredocs {
                [~] q:to/📝/, qq:to/📝/
                so here's
                📝
                    a heredoc {
                        [~] q:to/📝/, q:to/📝/
                        in a
                        📝
                            heredoc
                            📝
                    }
                    📝
            }
            📝
    }
    📝
END
	my $parsed = $pt.parse( $source );
	my $tree = $pt.build-tree( $parsed );
	is $pt.to-string( $tree ), $source, Q{formatted};
	ok (grep { $_ ~~ Perl6::String::Escaping },
			$tree.child.[0].child),
		Q{found string};
]

	done-testing;
}, Q{here-doc torture test};

# vim: ft=perl6
