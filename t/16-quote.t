use v6;

use Test;
use Perl6::Parser;

plan 16;

my $pt = Perl6::Parser.new;
my $*CONSISTENCY-CHECK = True;
my $*FALL-THROUGH = True;

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
			my $tree = $pt.to-tree( $source );
			my $node = $tree.child.[0].child.[0];

			is $pt.to-string( $tree ), $source, Q{formatted};
			ok $node ~~
				Perl6::String::Interpolation::WordQuoting::QuoteProtection;
			is $node.quote, Q{qqww}, Q{quote name};
			is $node.delimiter-start, Q{<}, Q{start delimiter};
			is $node.delimiter-end, Q{>}, Q{end delimiter};

			done-testing;
		}, Q{all intervening ws};

		subtest {
			my $source = Q{qqww :to<END>
pi
END};
			my $tree = $pt.to-tree( $source );
			my $node = $tree.child.[0].child.[0];

			is $pt.to-string( $tree ), $source, Q{formatted};
			ok $node ~~
				Perl6::String::Interpolation::WordQuoting::QuoteProtection;
			is $node.quote, Q{qqww}, Q{quote name};
			is $node.delimiter-start, Q{<}, Q{start delimiter};
			is $node.delimiter-end, Q{>}, Q{end delimiter};

			done-testing;
		}, Q{leading intervening ws};

		subtest {
			my $source = Q{qqww:to <END>
pi
END};
			my $tree = $pt.to-tree( $source );
			my $node = $tree.child.[0].child.[0];

			is $pt.to-string( $tree ), $source, Q{formatted};
			ok $node ~~
				Perl6::String::Interpolation::WordQuoting::QuoteProtection;
			is $node.quote, Q{qqww}, Q{quote name};
			is $node.delimiter-start, Q{<}, Q{start delimiter};
			is $node.delimiter-end, Q{>}, Q{end delimiter};

			done-testing;
		}, Q{trailing intervening ws};

		subtest {
			my $source = Q{qqww:to<END>
pi
END};
			my $tree = $pt.to-tree( $source );
			my $node = $tree.child.[0].child.[0];

			is $pt.to-string( $tree ), $source, Q{formatted};
			ok $node ~~
				Perl6::String::Interpolation::WordQuoting::QuoteProtection;
			is $node.quote, Q{qqww}, Q{quote name};
			is $node.delimiter-start, Q{<}, Q{start delimiter};
			is $node.delimiter-end, Q{>}, Q{end delimiter};

			done-testing;
		}, Q{no intervening ws};

		done-testing;
	}, Q{Qx:to<pi>};

	subtest {
		subtest {
			my $source = Q{qqww :w <pi>};
			my $tree = $pt.to-tree( $source );
			my $node = $tree.child.[0].child.[0];

			is $pt.to-string( $tree ), $source, Q{formatted};
			ok $node ~~
				Perl6::String::Interpolation::WordQuoting::QuoteProtection;
			is $node.quote, Q{qqww}, Q{quote name};
			is $node.delimiter-start, Q{<}, Q{start delimiter};
			is $node.delimiter-end, Q{>}, Q{end delimiter};

			done-testing;
		}, Q{all intervening ws};

		subtest {
			my $source = Q{qqww :w<pi>};
			my $tree = $pt.to-tree( $source );
			my $node = $tree.child.[0].child.[0];

			is $pt.to-string( $tree ), $source, Q{formatted};
			ok $node ~~
				Perl6::String::Interpolation::WordQuoting::QuoteProtection;
			is $node.quote, Q{qqww}, Q{quote name};
			is $node.delimiter-start, Q{<}, Q{start delimiter};
			is $node.delimiter-end, Q{>}, Q{end delimiter};

			done-testing;
		}, Q{leading intervening ws};

		subtest {
			my $source = Q{qqww:w <pi>};
			my $tree = $pt.to-tree( $source );
			my $node = $tree.child.[0].child.[0];

			is $pt.to-string( $tree ), $source, Q{formatted};
			ok $node ~~
				Perl6::String::Interpolation::WordQuoting::QuoteProtection;
			is $node.quote, Q{qqww}, Q{quote name};
			is $node.delimiter-start, Q{<}, Q{start delimiter};
			is $node.delimiter-end, Q{>}, Q{end delimiter};

			done-testing;
		}, Q{trailing intervening ws};

		subtest {
			my $source = Q{qqww:w<pi>};
			my $tree = $pt.to-tree( $source );
			my $node = $tree.child.[0].child.[0];

			is $pt.to-string( $tree ), $source, Q{formatted};
			ok $node ~~
				Perl6::String::Interpolation::WordQuoting::QuoteProtection;
			is $node.quote, Q{qqww}, Q{quote name};
			is $node.delimiter-start, Q{<}, Q{start delimiter};
			is $node.delimiter-end, Q{>}, Q{end delimiter};

			done-testing;
		}, Q{no intervening ws};

		done-testing;
	}, Q{qqww:w<pi>};

	subtest {
		subtest {
			my $source = Q{qqww :x <pi>};
			my $tree = $pt.to-tree( $source );
			my $node = $tree.child.[0].child.[0];

			is $pt.to-string( $tree ), $source, Q{formatted};
			ok $node ~~
				Perl6::String::Interpolation::WordQuoting::QuoteProtection;
			is $node.quote, Q{qqww}, Q{quote name};
			is $node.delimiter-start, Q{<}, Q{start delimiter};
			is $node.delimiter-end, Q{>}, Q{end delimiter};

			done-testing;
		}, Q{all intervening ws};

		subtest {
			my $source = Q{qqww :x<pi>};
			my $tree = $pt.to-tree( $source );
			my $node = $tree.child.[0].child.[0];

			is $pt.to-string( $tree ), $source, Q{formatted};
			ok $node ~~
				Perl6::String::Interpolation::WordQuoting::QuoteProtection;
			is $node.quote, Q{qqww}, Q{quote name};
			is $node.delimiter-start, Q{<}, Q{start delimiter};
			is $node.delimiter-end, Q{>}, Q{end delimiter};

			done-testing;
		}, Q{leading intervening ws};

		subtest {
			my $source = Q{qqww:x <pi>};
			my $tree = $pt.to-tree( $source );
			my $node = $tree.child.[0].child.[0];

			is $pt.to-string( $tree ), $source, Q{formatted};
			ok $node ~~
				Perl6::String::Interpolation::WordQuoting::QuoteProtection;
			is $node.quote, Q{qqww}, Q{quote name};
			is $node.delimiter-start, Q{<}, Q{start delimiter};
			is $node.delimiter-end, Q{>}, Q{end delimiter};

			done-testing;
		}, Q{trailing intervening ws};

		subtest {
			my $source = Q{qqww:x<pi>};
			my $tree = $pt.to-tree( $source );
			my $node = $tree.child.[0].child.[0];

			is $pt.to-string( $tree ), $source, Q{formatted};
			ok $node ~~
				Perl6::String::Interpolation::WordQuoting::QuoteProtection;
			is $node.quote, Q{qqww}, Q{quote name};
			is $node.delimiter-start, Q{<}, Q{start delimiter};
			is $node.delimiter-end, Q{>}, Q{end delimiter};

			done-testing;
		}, Q{no intervening ws};

		done-testing;
	}, Q{qqww:x<pi>};

	subtest {
		my $source = Q{qqww <pi>};
		my $tree = $pt.to-tree( $source );
		my $node = $tree.child.[0].child.[0];

		is $pt.to-string( $tree ), $source, Q{formatted};
		ok $node ~~
			Perl6::String::Interpolation::WordQuoting::QuoteProtection;
		is $node.quote, Q{qqww}, Q{quote name};
		is $node.delimiter-start, Q{<}, Q{start delimiter};
		is $node.delimiter-end, Q{>}, Q{end delimiter};

		done-testing;
	}, Q{ws, no adverbs};

	subtest {
		my $source = Q{qqww<pi>};
		my $tree = $pt.to-tree( $source );
		my $node = $tree.child.[0].child.[0];

		is $pt.to-string( $tree ), $source, Q{formatted};
		ok $node ~~
			Perl6::String::Interpolation::WordQuoting::QuoteProtection;
		is $node.quote, Q{qqww}, Q{quote name};
		is $node.delimiter-start, Q{<}, Q{start delimiter};
		is $node.delimiter-end, Q{>}, Q{end delimiter};

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
			my $tree = $pt.to-tree( $source );
			my $node = $tree.child.[0].child.[0];

			is $pt.to-string( $tree ), $source, Q{formatted};
			ok $node ~~ Perl6::String::Interpolation::WordQuoting;
			is $node.quote, Q{qqw}, Q{quote name};
			is $node.delimiter-start, Q{<}, Q{start delimiter};
			is $node.delimiter-end, Q{>}, Q{end delimiter};

			done-testing;
		}, Q{all intervening ws};

		subtest {
			my $source = Q{qqw :to<END>
pi
END};
			my $tree = $pt.to-tree( $source );
			my $node = $tree.child.[0].child.[0];

			is $pt.to-string( $tree ), $source, Q{formatted};
			ok $node ~~ Perl6::String::Interpolation::WordQuoting;
			is $node.quote, Q{qqw}, Q{quote name};
			is $node.delimiter-start, Q{<}, Q{start delimiter};
			is $node.delimiter-end, Q{>}, Q{end delimiter};

			done-testing;
		}, Q{leading intervening ws};

		subtest {
			my $source = Q{qqw:to <END>
pi
END};
			my $tree = $pt.to-tree( $source );
			my $node = $tree.child.[0].child.[0];

			is $pt.to-string( $tree ), $source, Q{formatted};
			ok $node ~~ Perl6::String::Interpolation::WordQuoting;
			is $node.quote, Q{qqw}, Q{quote name};
			is $node.delimiter-start, Q{<}, Q{start delimiter};
			is $node.delimiter-end, Q{>}, Q{end delimiter};

			done-testing;
		}, Q{trailing intervening ws};

		subtest {
			my $source = Q{qqw:to<END>
pi
END};
			my $tree = $pt.to-tree( $source );
			my $node = $tree.child.[0].child.[0];

			is $pt.to-string( $tree ), $source, Q{formatted};
			ok $node ~~ Perl6::String::Interpolation::WordQuoting;
			is $node.quote, Q{qqw}, Q{quote name};
			is $node.delimiter-start, Q{<}, Q{start delimiter};
			is $node.delimiter-end, Q{>}, Q{end delimiter};

			done-testing;
		}, Q{no intervening ws};

		done-testing;
	}, Q{adverb :to};

	subtest {
		subtest {
			my $source = Q{qqw :w <pi>};
			my $tree = $pt.to-tree( $source );
			my $node = $tree.child.[0].child.[0];

			is $pt.to-string( $tree ), $source, Q{formatted};
			ok $node ~~ Perl6::String::Interpolation::WordQuoting;
			is $node.quote, Q{qqw}, Q{quote name};
			is $node.delimiter-start, Q{<}, Q{start delimiter};
			is $node.delimiter-end, Q{>}, Q{end delimiter};

			done-testing;
		}, Q{all intervening ws};

		subtest {
			my $source = Q{qqw :w<pi>};
			my $tree = $pt.to-tree( $source );
			my $node = $tree.child.[0].child.[0];

			is $pt.to-string( $tree ), $source, Q{formatted};
			ok $node ~~ Perl6::String::Interpolation::WordQuoting;
			is $node.quote, Q{qqw}, Q{quote name};
			is $node.delimiter-start, Q{<}, Q{start delimiter};
			is $node.delimiter-end, Q{>}, Q{end delimiter};

			done-testing;
		}, Q{leading intervening ws};

		subtest {
			my $source = Q{qqw:w <pi>};
			my $tree = $pt.to-tree( $source );
			my $node = $tree.child.[0].child.[0];

			is $pt.to-string( $tree ), $source, Q{formatted};
			ok $node ~~ Perl6::String::Interpolation::WordQuoting;
			is $node.quote, Q{qqw}, Q{quote name};
			is $node.delimiter-start, Q{<}, Q{start delimiter};
			is $node.delimiter-end, Q{>}, Q{end delimiter};

			done-testing;
		}, Q{trailing intervening ws};

		subtest {
			my $source = Q{qqw:w<pi>};
			my $tree = $pt.to-tree( $source );
			my $node = $tree.child.[0].child.[0];

			is $pt.to-string( $tree ), $source, Q{formatted};
			ok $node ~~ Perl6::String::Interpolation::WordQuoting;
			is $node.quote, Q{qqw}, Q{quote name};
			is $node.delimiter-start, Q{<}, Q{start delimiter};
			is $node.delimiter-end, Q{>}, Q{end delimiter};

			done-testing;
		}, Q{no intervening ws};

		done-testing;
	}, Q{adverb :w};

	subtest {
		subtest {
			my $source = Q{qqw :x <pi>};
			my $tree = $pt.to-tree( $source );
			my $node = $tree.child.[0].child.[0];

			is $pt.to-string( $tree ), $source, Q{formatted};
			ok $node ~~ Perl6::String::Interpolation::WordQuoting;
			is $node.quote, Q{qqw}, Q{quote name};
			is $node.delimiter-start, Q{<}, Q{start delimiter};
			is $node.delimiter-end, Q{>}, Q{end delimiter};

			done-testing;
		}, Q{all intervening ws};

		subtest {
			my $source = Q{qqw :x<pi>};
			my $tree = $pt.to-tree( $source );
			my $node = $tree.child.[0].child.[0];

			is $pt.to-string( $tree ), $source, Q{formatted};
			ok $node ~~ Perl6::String::Interpolation::WordQuoting;
			is $node.quote, Q{qqw}, Q{quote name};
			is $node.delimiter-start, Q{<}, Q{start delimiter};
			is $node.delimiter-end, Q{>}, Q{end delimiter};

			done-testing;
		}, Q{leading intervening ws};

		subtest {
			my $source = Q{qqw:x <pi>};
			my $tree = $pt.to-tree( $source );
			my $node = $tree.child.[0].child.[0];

			is $pt.to-string( $tree ), $source, Q{formatted};
			ok $node ~~ Perl6::String::Interpolation::WordQuoting;
			is $node.quote, Q{qqw}, Q{quote name};
			is $node.delimiter-start, Q{<}, Q{start delimiter};
			is $node.delimiter-end, Q{>}, Q{end delimiter};

			done-testing;
		}, Q{trailing intervening ws};

		subtest {
			my $source = Q{qqw:x<pi>};
			my $tree = $pt.to-tree( $source );
			my $node = $tree.child.[0].child.[0];

			is $pt.to-string( $tree ), $source, Q{formatted};
			ok $node ~~ Perl6::String::Interpolation::WordQuoting;
			is $node.quote, Q{qqw}, Q{quote name};
			is $node.delimiter-start, Q{<}, Q{start delimiter};
			is $node.delimiter-end, Q{>}, Q{end delimiter};

			done-testing;
		}, Q{no intervening ws};

		done-testing;
	}, Q{adverb :x};

	subtest {
		my $source = Q{qqw <pi>};
		my $tree = $pt.to-tree( $source );
		my $node = $tree.child.[0].child.[0];

		is $pt.to-string( $tree ), $source, Q{formatted};
		ok $node ~~ Perl6::String::Interpolation::WordQuoting;
		is $node.quote, Q{qqw}, Q{quote name};
		is $node.delimiter-start, Q{<}, Q{start delimiter};
		is $node.delimiter-end, Q{>}, Q{end delimiter};

		done-testing;
	}, Q{ws, no adverbs};

	subtest {
		my $source = Q{qqw<pi>};
		my $tree = $pt.to-tree( $source );
		my $node = $tree.child.[0].child.[0];

		is $pt.to-string( $tree ), $source, Q{formatted};
		ok $node ~~ Perl6::String::Interpolation::WordQuoting;
		is $node.quote, Q{qqw}, Q{quote name};
		is $node.delimiter-start, Q{<}, Q{start delimiter};
		is $node.delimiter-end, Q{>}, Q{end delimiter};

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
			my $tree = $pt.to-tree( $source );
			my $node = $tree.child.[0].child.[0];

			is $pt.to-string( $tree ), $source, Q{formatted};
			ok $node ~~ Perl6::String::Interpolation::Shell;
			is $node.quote, Q{qqx}, Q{quote name};
			is $node.delimiter-start, Q{<}, Q{start delimiter};
			is $node.delimiter-end, Q{>}, Q{end delimiter};

			done-testing;
		}, Q{all intervening ws};

		subtest {
			my $source = Q{qqx :to<END>
pi
END};
			my $tree = $pt.to-tree( $source );
			my $node = $tree.child.[0].child.[0];

			is $pt.to-string( $tree ), $source, Q{formatted};
			ok $node ~~ Perl6::String::Interpolation::Shell;
			is $node.quote, Q{qqx}, Q{quote name};
			is $node.delimiter-start, Q{<}, Q{start delimiter};
			is $node.delimiter-end, Q{>}, Q{end delimiter};

			done-testing;
		}, Q{leading intervening ws};

		subtest {
			my $source = Q{qqx:to <END>
pi
END};
			my $tree = $pt.to-tree( $source );
			my $node = $tree.child.[0].child.[0];

			is $pt.to-string( $tree ), $source, Q{formatted};
			ok $node ~~ Perl6::String::Interpolation::Shell;
			is $node.quote, Q{qqx}, Q{quote name};
			is $node.delimiter-start, Q{<}, Q{start delimiter};
			is $node.delimiter-end, Q{>}, Q{end delimiter};

			done-testing;
		}, Q{trailing intervening ws};

		subtest {
			my $source = Q{qqx:to<END>
pi
END};
			my $tree = $pt.to-tree( $source );
			my $node = $tree.child.[0].child.[0];

			is $pt.to-string( $tree ), $source, Q{formatted};
			ok $node ~~ Perl6::String::Interpolation::Shell;
			is $node.quote, Q{qqx}, Q{quote name};
			is $node.delimiter-start, Q{<}, Q{start delimiter};
			is $node.delimiter-end, Q{>}, Q{end delimiter};

			done-testing;
		}, Q{no intervening ws};

		done-testing;
	}, Q{adverb :to};

	subtest {
		subtest {
			my $source = Q{qqx :w <pi>};
			my $tree = $pt.to-tree( $source );
			my $node = $tree.child.[0].child.[0];

			is $pt.to-string( $tree ), $source, Q{formatted};
			ok $node ~~ Perl6::String::Interpolation::Shell;
			is $node.quote, Q{qqx}, Q{quote name};
			is $node.delimiter-start, Q{<}, Q{start delimiter};
			is $node.delimiter-end, Q{>}, Q{end delimiter};

			done-testing;
		}, Q{all intervening ws};

		subtest {
			my $source = Q{qqx :w<pi>};
			my $tree = $pt.to-tree( $source );
			my $node = $tree.child.[0].child.[0];

			is $pt.to-string( $tree ), $source, Q{formatted};
			ok $node ~~ Perl6::String::Interpolation::Shell;
			is $node.quote, Q{qqx}, Q{quote name};
			is $node.delimiter-start, Q{<}, Q{start delimiter};
			is $node.delimiter-end, Q{>}, Q{end delimiter};

			done-testing;
		}, Q{leading intervening ws};

		subtest {
			my $source = Q{qqx:w <pi>};
			my $tree = $pt.to-tree( $source );
			my $node = $tree.child.[0].child.[0];

			is $pt.to-string( $tree ), $source, Q{formatted};
			ok $node ~~ Perl6::String::Interpolation::Shell;
			is $node.quote, Q{qqx}, Q{quote name};
			is $node.delimiter-start, Q{<}, Q{start delimiter};
			is $node.delimiter-end, Q{>}, Q{end delimiter};

			done-testing;
		}, Q{trailing intervening ws};

		subtest {
			my $source = Q{qqx:w<pi>};
			my $tree = $pt.to-tree( $source );
			my $node = $tree.child.[0].child.[0];

			is $pt.to-string( $tree ), $source, Q{formatted};
			ok $node ~~ Perl6::String::Interpolation::Shell;
			is $node.quote, Q{qqx}, Q{quote name};
			is $node.delimiter-start, Q{<}, Q{start delimiter};
			is $node.delimiter-end, Q{>}, Q{end delimiter};

			done-testing;
		}, Q{no intervening ws};

		done-testing;
	}, Q{adverb :w};

	subtest {
		subtest {
			my $source = Q{qqx :x <pi>};
			my $tree = $pt.to-tree( $source );
			my $node = $tree.child.[0].child.[0];

			is $pt.to-string( $tree ), $source, Q{formatted};
			ok $node ~~ Perl6::String::Interpolation::Shell;
			is $node.quote, Q{qqx}, Q{quote name};
			is $node.delimiter-start, Q{<}, Q{start delimiter};
			is $node.delimiter-end, Q{>}, Q{end delimiter};

			done-testing;
		}, Q{all intervening ws};

		subtest {
			my $source = Q{qqx :x<pi>};
			my $tree = $pt.to-tree( $source );
			my $node = $tree.child.[0].child.[0];

			is $pt.to-string( $tree ), $source, Q{formatted};
			ok $node ~~ Perl6::String::Interpolation::Shell;
			is $node.quote, Q{qqx}, Q{quote name};
			is $node.delimiter-start, Q{<}, Q{start delimiter};
			is $node.delimiter-end, Q{>}, Q{end delimiter};

			done-testing;
		}, Q{leading intervening ws};

		subtest {
			my $source = Q{qqx:x <pi>};
			my $tree = $pt.to-tree( $source );
			my $node = $tree.child.[0].child.[0];

			is $pt.to-string( $tree ), $source, Q{formatted};
			ok $node ~~ Perl6::String::Interpolation::Shell;
			is $node.quote, Q{qqx}, Q{quote name};
			is $node.delimiter-start, Q{<}, Q{start delimiter};
			is $node.delimiter-end, Q{>}, Q{end delimiter};

			done-testing;
		}, Q{trailing intervening ws};

		subtest {
			my $source = Q{qqx:x<pi>};
			my $tree = $pt.to-tree( $source );
			my $node = $tree.child.[0].child.[0];

			is $pt.to-string( $tree ), $source, Q{formatted};
			ok $node ~~ Perl6::String::Interpolation::Shell;
			is $node.quote, Q{qqx}, Q{quote name};
			is $node.delimiter-start, Q{<}, Q{start delimiter};
			is $node.delimiter-end, Q{>}, Q{end delimiter};

			done-testing;
		}, Q{no intervening ws};

		done-testing;
	}, Q{adverb :x};

	subtest {
		my $source = Q{qqx <pi>};
		my $tree = $pt.to-tree( $source );
		my $node = $tree.child.[0].child.[0];

		is $pt.to-string( $tree ), $source, Q{formatted};
		ok $node ~~ Perl6::String::Interpolation::Shell;
		is $node.quote, Q{qqx}, Q{quote name};
		is $node.delimiter-start, Q{<}, Q{start delimiter};
		is $node.delimiter-end, Q{>}, Q{end delimiter};

		done-testing;
	}, Q{ws, no adverbs};

	subtest {
		my $source = Q{qqx<pi>};
		my $tree = $pt.to-tree( $source );
		my $node = $tree.child.[0].child.[0];

		is $pt.to-string( $tree ), $source, Q{formatted};
		ok $node ~~ Perl6::String::Interpolation::Shell;
		is $node.quote, Q{qqx}, Q{quote name};
		is $node.delimiter-start, Q{<}, Q{start delimiter};
		is $node.delimiter-end, Q{>}, Q{end delimiter};

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
			my $tree = $pt.to-tree( $source );
			my $node = $tree.child.[0].child.[0];

			is $pt.to-string( $tree ), $source, Q{formatted};
			ok $node ~~ Perl6::String::WordQuoting::QuoteProtection;
			is $node.quote, Q{qww}, Q{quote name};
			is $node.delimiter-start, Q{<}, Q{start delimiter};
			is $node.delimiter-end, Q{>}, Q{end delimiter};

			done-testing;
		}, Q{all intervening ws};

		subtest {
			my $source = Q{qww :to<END>
pi
END};
			my $tree = $pt.to-tree( $source );
			my $node = $tree.child.[0].child.[0];

			is $pt.to-string( $tree ), $source, Q{formatted};
			ok $node ~~ Perl6::String::WordQuoting::QuoteProtection;
			is $node.quote, Q{qww}, Q{quote name};
			is $node.delimiter-start, Q{<}, Q{start delimiter};
			is $node.delimiter-end, Q{>}, Q{end delimiter};

			done-testing;
		}, Q{leading intervening ws};

		subtest {
			my $source = Q{qww:to <END>
pi
END};
			my $tree = $pt.to-tree( $source );
			my $node = $tree.child.[0].child.[0];

			is $pt.to-string( $tree ), $source, Q{formatted};
			ok $node ~~ Perl6::String::WordQuoting::QuoteProtection;
			is $node.quote, Q{qww}, Q{quote name};
			is $node.delimiter-start, Q{<}, Q{start delimiter};
			is $node.delimiter-end, Q{>}, Q{end delimiter};

			done-testing;
		}, Q{trailing intervening ws};

		subtest {
			my $source = Q{qww:to<END>
pi
END};
			my $tree = $pt.to-tree( $source );
			my $node = $tree.child.[0].child.[0];

			is $pt.to-string( $tree ), $source, Q{formatted};
			ok $node ~~ Perl6::String::WordQuoting::QuoteProtection;
			is $node.quote, Q{qww}, Q{quote name};
			is $node.delimiter-start, Q{<}, Q{start delimiter};
			is $node.delimiter-end, Q{>}, Q{end delimiter};

			done-testing;
		}, Q{no intervening ws};

		done-testing;
	}, Q{adverb :to};

	subtest {
		subtest {
			my $source = Q{qww :w <pi>};
			my $tree = $pt.to-tree( $source );
			my $node = $tree.child.[0].child.[0];

			is $pt.to-string( $tree ), $source, Q{formatted};
			ok $node ~~ Perl6::String::WordQuoting::QuoteProtection;
			is $node.quote, Q{qww}, Q{quote name};
			is $node.delimiter-start, Q{<}, Q{start delimiter};
			is $node.delimiter-end, Q{>}, Q{end delimiter};

			done-testing;
		}, Q{all intervening ws};

		subtest {
			my $source = Q{qww :w<pi>};
			my $tree = $pt.to-tree( $source );
			my $node = $tree.child.[0].child.[0];

			is $pt.to-string( $tree ), $source, Q{formatted};
			ok $node ~~ Perl6::String::WordQuoting::QuoteProtection;
			is $node.quote, Q{qww}, Q{quote name};
			is $node.delimiter-start, Q{<}, Q{start delimiter};
			is $node.delimiter-end, Q{>}, Q{end delimiter};

			done-testing;
		}, Q{leading intervening ws};

		subtest {
			my $source = Q{qww:w <pi>};
			my $tree = $pt.to-tree( $source );
			my $node = $tree.child.[0].child.[0];

			is $pt.to-string( $tree ), $source, Q{formatted};
			ok $node ~~ Perl6::String::WordQuoting::QuoteProtection;
			is $node.quote, Q{qww}, Q{quote name};
			is $node.delimiter-start, Q{<}, Q{start delimiter};
			is $node.delimiter-end, Q{>}, Q{end delimiter};

			done-testing;
		}, Q{trailing intervening ws};

		subtest {
			my $source = Q{qww:w<pi>};
			my $tree = $pt.to-tree( $source );
			my $node = $tree.child.[0].child.[0];

			is $pt.to-string( $tree ), $source, Q{formatted};
			ok $node ~~ Perl6::String::WordQuoting::QuoteProtection;
			is $node.quote, Q{qww}, Q{quote name};
			is $node.delimiter-start, Q{<}, Q{start delimiter};
			is $node.delimiter-end, Q{>}, Q{end delimiter};

			done-testing;
		}, Q{no intervening ws};

		done-testing;
	}, Q{adverb :w};

	subtest {
		subtest {
			my $source = Q{qww :x <pi>};
			my $tree = $pt.to-tree( $source );
			my $node = $tree.child.[0].child.[0];

			is $pt.to-string( $tree ), $source, Q{formatted};
			ok $node ~~ Perl6::String::WordQuoting::QuoteProtection;
			is $node.quote, Q{qww}, Q{quote name};
			is $node.delimiter-start, Q{<}, Q{start delimiter};
			is $node.delimiter-end, Q{>}, Q{end delimiter};

			done-testing;
		}, Q{all intervening ws};

		subtest {
			my $source = Q{qww :x<pi>};
			my $tree = $pt.to-tree( $source );
			my $node = $tree.child.[0].child.[0];

			is $pt.to-string( $tree ), $source, Q{formatted};
			ok $node ~~ Perl6::String::WordQuoting::QuoteProtection;
			is $node.quote, Q{qww}, Q{quote name};
			is $node.delimiter-start, Q{<}, Q{start delimiter};
			is $node.delimiter-end, Q{>}, Q{end delimiter};

			done-testing;
		}, Q{leading intervening ws};

		subtest {
			my $source = Q{qww:x <pi>};
			my $tree = $pt.to-tree( $source );
			my $node = $tree.child.[0].child.[0];

			is $pt.to-string( $tree ), $source, Q{formatted};
			ok $node ~~ Perl6::String::WordQuoting::QuoteProtection;
			is $node.quote, Q{qww}, Q{quote name};
			is $node.delimiter-start, Q{<}, Q{start delimiter};
			is $node.delimiter-end, Q{>}, Q{end delimiter};

			done-testing;
		}, Q{trailing intervening ws};

		subtest {
			my $source = Q{qww:x<pi>};
			my $tree = $pt.to-tree( $source );
			my $node = $tree.child.[0].child.[0];

			is $pt.to-string( $tree ), $source, Q{formatted};
			ok $node ~~ Perl6::String::WordQuoting::QuoteProtection;
			is $node.quote, Q{qww}, Q{quote name};
			is $node.delimiter-start, Q{<}, Q{start delimiter};
			is $node.delimiter-end, Q{>}, Q{end delimiter};

			done-testing;
		}, Q{no intervening ws};

		done-testing;
	}, Q{adverb :x};

	subtest {
		my $source = Q{qww <pi>};
		my $tree = $pt.to-tree( $source );
		my $node = $tree.child.[0].child.[0];

		is $pt.to-string( $tree ), $source, Q{formatted};
		ok $node ~~ Perl6::String::WordQuoting::QuoteProtection;
		is $node.quote, Q{qww}, Q{quote name};
		is $node.delimiter-start, Q{<}, Q{start delimiter};
		is $node.delimiter-end, Q{>}, Q{end delimiter};

		done-testing;
	}, Q{ws, no adverbs};

	subtest {
		my $source = Q{qww<pi>};
		my $tree = $pt.to-tree( $source );
		my $node = $tree.child.[0].child.[0];

		is $pt.to-string( $tree ), $source, Q{formatted};
		ok $node ~~ Perl6::String::WordQuoting::QuoteProtection;
		is $node.quote, Q{qww}, Q{quote name};
		is $node.delimiter-start, Q{<}, Q{start delimiter};
		is $node.delimiter-end, Q{>}, Q{end delimiter};

		done-testing;
	}, Q{no ws, no adverbs};

	done-testing;
}, Q{qww<>};

# Qq is illegal

subtest {
	subtest {
		subtest {
			my $source = Q{Qw :q <pi>};
			my $tree = $pt.to-tree( $source );
			my $node = $tree.child.[0].child.[0];

			is $pt.to-string( $tree ), $source, Q{formatted};
			ok $node ~~ Perl6::String::Literal::WordQuoting;
			is $node.quote, Q{Qw}, Q{quote name};
			is $node.delimiter-start, Q{<}, Q{start delimiter};
			is $node.delimiter-end, Q{>}, Q{end delimiter};

			done-testing;
		}, Q{all intervening ws};

		subtest {
			my $source = Q{Qw :q<pi>};
			my $tree = $pt.to-tree( $source );
			my $node = $tree.child.[0].child.[0];

			is $pt.to-string( $tree ), $source, Q{formatted};
			ok $node ~~ Perl6::String::Literal::WordQuoting;
			is $node.quote, Q{Qw}, Q{quote name};
			is $node.delimiter-start, Q{<}, Q{start delimiter};
			is $node.delimiter-end, Q{>}, Q{end delimiter};

			done-testing;
		}, Q{leading intervening ws};

		subtest {
			my $source = Q{Qw:q <pi>};
			my $tree = $pt.to-tree( $source );
			my $node = $tree.child.[0].child.[0];

			is $pt.to-string( $tree ), $source, Q{formatted};
			ok $node ~~ Perl6::String::Literal::WordQuoting;
			is $node.quote, Q{Qw}, Q{quote name};
			is $node.delimiter-start, Q{<}, Q{start delimiter};
			is $node.delimiter-end, Q{>}, Q{end delimiter};

			done-testing;
		}, Q{trailing intervening ws};

		subtest {
			my $source = Q{Qw:q<pi>};
			my $tree = $pt.to-tree( $source );
			my $node = $tree.child.[0].child.[0];

			is $pt.to-string( $tree ), $source, Q{formatted};
			ok $node ~~ Perl6::String::Literal::WordQuoting;
			is $node.quote, Q{Qw}, Q{quote name};
			is $node.delimiter-start, Q{<}, Q{start delimiter};
			is $node.delimiter-end, Q{>}, Q{end delimiter};

			done-testing;
		}, Q{no intervening ws};

		done-testing;
	}, Q{adverb :q};

	subtest {
		subtest {
			my $source = Q{Qw :to <END>
pi
END};
			my $tree = $pt.to-tree( $source );
			my $node = $tree.child.[0].child.[0];

			is $pt.to-string( $tree ), $source, Q{formatted};
			ok $node ~~ Perl6::String::Literal::WordQuoting;
			is $node.quote, Q{Qw}, Q{quote name};
			is $node.delimiter-start, Q{<}, Q{start delimiter};
			is $node.delimiter-end, Q{>}, Q{end delimiter};

			done-testing;
		}, Q{all intervening ws};

		subtest {
			my $source = Q{Qw :to<END>
pi
END};
			my $tree = $pt.to-tree( $source );
			my $node = $tree.child.[0].child.[0];

			is $pt.to-string( $tree ), $source, Q{formatted};
			ok $node ~~ Perl6::String::Literal::WordQuoting;
			is $node.quote, Q{Qw}, Q{quote name};
			is $node.delimiter-start, Q{<}, Q{start delimiter};
			is $node.delimiter-end, Q{>}, Q{end delimiter};

			done-testing;
		}, Q{leading intervening ws};

		subtest {
			my $source = Q{Qw:to <END>
pi
END};
			my $tree = $pt.to-tree( $source );
			my $node = $tree.child.[0].child.[0];

			is $pt.to-string( $tree ), $source, Q{formatted};
			ok $node ~~ Perl6::String::Literal::WordQuoting;
			is $node.quote, Q{Qw}, Q{quote name};
			is $node.delimiter-start, Q{<}, Q{start delimiter};
			is $node.delimiter-end, Q{>}, Q{end delimiter};

			done-testing;
		}, Q{trailing intervening ws};

		subtest {
			my $source = Q{Qw:to<END>
pi
END};
			my $tree = $pt.to-tree( $source );
			my $node = $tree.child.[0].child.[0];

			is $pt.to-string( $tree ), $source, Q{formatted};
			ok $node ~~ Perl6::String::Literal::WordQuoting;
			is $node.quote, Q{Qw}, Q{quote name};
			is $node.delimiter-start, Q{<}, Q{start delimiter};
			is $node.delimiter-end, Q{>}, Q{end delimiter};

			done-testing;
		}, Q{no intervening ws};

		done-testing;
	}, Q{adverb :to};

	subtest {
		subtest {
			my $source = Q{Qw :w <pi>};
			my $tree = $pt.to-tree( $source );
			my $node = $tree.child.[0].child.[0];

			is $pt.to-string( $tree ), $source, Q{formatted};
			ok $node ~~ Perl6::String::Literal::WordQuoting;
			is $node.quote, Q{Qw}, Q{quote name};
			is $node.delimiter-start, Q{<}, Q{start delimiter};
			is $node.delimiter-end, Q{>}, Q{end delimiter};

			done-testing;
		}, Q{all intervening ws};

		subtest {
			my $source = Q{Qw :w<pi>};
			my $tree = $pt.to-tree( $source );
			my $node = $tree.child.[0].child.[0];

			is $pt.to-string( $tree ), $source, Q{formatted};
			ok $node ~~ Perl6::String::Literal::WordQuoting;
			is $node.quote, Q{Qw}, Q{quote name};
			is $node.delimiter-start, Q{<}, Q{start delimiter};
			is $node.delimiter-end, Q{>}, Q{end delimiter};

			done-testing;
		}, Q{leading intervening ws};

		subtest {
			my $source = Q{Qw:w <pi>};
			my $tree = $pt.to-tree( $source );
			my $node = $tree.child.[0].child.[0];

			is $pt.to-string( $tree ), $source, Q{formatted};
			ok $node ~~ Perl6::String::Literal::WordQuoting;
			is $node.quote, Q{Qw}, Q{quote name};
			is $node.delimiter-start, Q{<}, Q{start delimiter};
			is $node.delimiter-end, Q{>}, Q{end delimiter};

			done-testing;
		}, Q{trailing intervening ws};

		subtest {
			my $source = Q{Qw:w<pi>};
			my $tree = $pt.to-tree( $source );
			my $node = $tree.child.[0].child.[0];

			is $pt.to-string( $tree ), $source, Q{formatted};
			ok $node ~~ Perl6::String::Literal::WordQuoting;
			is $node.quote, Q{Qw}, Q{quote name};
			is $node.delimiter-start, Q{<}, Q{start delimiter};
			is $node.delimiter-end, Q{>}, Q{end delimiter};

			done-testing;
		}, Q{no intervening ws};

		done-testing;
	}, Q{adverb :w};

	subtest {
		subtest {
			my $source = Q{Qw :x <pi>};
			my $tree = $pt.to-tree( $source );
			my $node = $tree.child.[0].child.[0];

			is $pt.to-string( $tree ), $source, Q{formatted};
			ok $node ~~ Perl6::String::Literal::WordQuoting;
			is $node.quote, Q{Qw}, Q{quote name};
			is $node.delimiter-start, Q{<}, Q{start delimiter};
			is $node.delimiter-end, Q{>}, Q{end delimiter};

			done-testing;
		}, Q{all intervening ws};

		subtest {
			my $source = Q{Qw :x<pi>};
			my $tree = $pt.to-tree( $source );
			my $node = $tree.child.[0].child.[0];

			is $pt.to-string( $tree ), $source, Q{formatted};
			ok $node ~~ Perl6::String::Literal::WordQuoting;
			is $node.quote, Q{Qw}, Q{quote name};
			is $node.delimiter-start, Q{<}, Q{start delimiter};
			is $node.delimiter-end, Q{>}, Q{end delimiter};

			done-testing;
		}, Q{leading intervening ws};

		subtest {
			my $source = Q{Qw:x <pi>};
			my $tree = $pt.to-tree( $source );
			my $node = $tree.child.[0].child.[0];

			is $pt.to-string( $tree ), $source, Q{formatted};
			ok $node ~~ Perl6::String::Literal::WordQuoting;
			is $node.quote, Q{Qw}, Q{quote name};
			is $node.delimiter-start, Q{<}, Q{start delimiter};
			is $node.delimiter-end, Q{>}, Q{end delimiter};

			done-testing;
		}, Q{trailing intervening ws};

		subtest {
			my $source = Q{Qw:x<pi>};
			my $tree = $pt.to-tree( $source );
			my $node = $tree.child.[0].child.[0];

			is $pt.to-string( $tree ), $source, Q{formatted};
			ok $node ~~ Perl6::String::Literal::WordQuoting;
			is $node.quote, Q{Qw}, Q{quote name};
			is $node.delimiter-start, Q{<}, Q{start delimiter};
			is $node.delimiter-end, Q{>}, Q{end delimiter};

			done-testing;
		}, Q{no intervening ws};

		done-testing;
	}, Q{adverb :x};

	subtest {
		my $source = Q{Qw <pi>};
		my $tree = $pt.to-tree( $source );
		my $node = $tree.child.[0].child.[0];

		is $pt.to-string( $tree ), $source, Q{formatted};
		ok $node ~~ Perl6::String::Literal::WordQuoting;
		is $node.quote, Q{Qw}, Q{quote name};
		is $node.delimiter-start, Q{<}, Q{start delimiter};
		is $node.delimiter-end, Q{>}, Q{end delimiter};

		done-testing;
	}, Q{ws, no adverbs};

	subtest {
		my $source = Q{Qw<pi>};
		my $tree = $pt.to-tree( $source );
		my $node = $tree.child.[0].child.[0];

		is $pt.to-string( $tree ), $source, Q{formatted};
		ok $node ~~ Perl6::String::Literal::WordQuoting;
		is $node.quote, Q{Qw}, Q{quote name};
		is $node.delimiter-start, Q{<}, Q{start delimiter};
		is $node.delimiter-end, Q{>}, Q{end delimiter};

		done-testing;
	}, Q{no ws, no adverbs};

	done-testing;
}, Q{Qw<>};

subtest {
	subtest {
		subtest {
			my $source = Q{Qx :q <pi>};
			my $tree = $pt.to-tree( $source );
			my $node = $tree.child.[0].child.[0];

			is $pt.to-string( $tree ), $source, Q{formatted};
			ok $node ~~ Perl6::String::Literal::Shell;
			is $node.quote, Q{Qx}, Q{quote name};
			is $node.delimiter-start, Q{<}, Q{start delimiter};
			is $node.delimiter-end, Q{>}, Q{end delimiter};

			done-testing;
		}, Q{all intervening ws};

		subtest {
			my $source = Q{Qx :q<pi>};
			my $tree = $pt.to-tree( $source );
			my $node = $tree.child.[0].child.[0];

			is $pt.to-string( $tree ), $source, Q{formatted};
			ok $node ~~ Perl6::String::Literal::Shell;
			is $node.quote, Q{Qx}, Q{quote name};
			is $node.delimiter-start, Q{<}, Q{start delimiter};
			is $node.delimiter-end, Q{>}, Q{end delimiter};

			done-testing;
		}, Q{leading intervening ws};

		subtest {
			my $source = Q{Qx:q <pi>};
			my $tree = $pt.to-tree( $source );
			my $node = $tree.child.[0].child.[0];

			is $pt.to-string( $tree ), $source, Q{formatted};
			ok $node ~~ Perl6::String::Literal::Shell;
			is $node.quote, Q{Qx}, Q{quote name};
			is $node.delimiter-start, Q{<}, Q{start delimiter};
			is $node.delimiter-end, Q{>}, Q{end delimiter};

			done-testing;
		}, Q{trailing intervening ws};

		subtest {
			my $source = Q{Qx:q<pi>};
			my $tree = $pt.to-tree( $source );
			my $node = $tree.child.[0].child.[0];

			is $pt.to-string( $tree ), $source, Q{formatted};
			ok $node ~~ Perl6::String::Literal::Shell;
			is $node.quote, Q{Qx}, Q{quote name};
			is $node.delimiter-start, Q{<}, Q{start delimiter};
			is $node.delimiter-end, Q{>}, Q{end delimiter};

			done-testing;
		}, Q{no intervening ws};

		done-testing;
	}, Q{adverb :q};

	subtest {
		subtest {
			my $source = Q{Qx :to <END>
pi
END};
			my $tree = $pt.to-tree( $source );
			my $node = $tree.child.[0].child.[0];

			is $pt.to-string( $tree ), $source, Q{formatted};
			ok $node ~~ Perl6::String::Literal::Shell;
			is $node.quote, Q{Qx}, Q{quote name};
			is $node.delimiter-start, Q{<}, Q{start delimiter};
			is $node.delimiter-end, Q{>}, Q{end delimiter};

			done-testing;
		}, Q{all intervening ws};

		subtest {
			my $source = Q{Qx :to<END>
pi
END};
			my $tree = $pt.to-tree( $source );
			my $node = $tree.child.[0].child.[0];

			is $pt.to-string( $tree ), $source, Q{formatted};
			ok $node ~~ Perl6::String::Literal::Shell;
			is $node.quote, Q{Qx}, Q{quote name};
			is $node.delimiter-start, Q{<}, Q{start delimiter};
			is $node.delimiter-end, Q{>}, Q{end delimiter};

			done-testing;
		}, Q{leading intervening ws};

		subtest {
			my $source = Q{Qx:to <END>
pi
END};
			my $tree = $pt.to-tree( $source );
			my $node = $tree.child.[0].child.[0];

			is $pt.to-string( $tree ), $source, Q{formatted};
			ok $node ~~ Perl6::String::Literal::Shell;
			is $node.quote, Q{Qx}, Q{quote name};
			is $node.delimiter-start, Q{<}, Q{start delimiter};
			is $node.delimiter-end, Q{>}, Q{end delimiter};

			done-testing;
		}, Q{trailing intervening ws};

		subtest {
			my $source = Q{Qx:to<END>
pi
END};
			my $tree = $pt.to-tree( $source );
			my $node = $tree.child.[0].child.[0];

			is $pt.to-string( $tree ), $source, Q{formatted};
			ok $node ~~ Perl6::String::Literal::Shell;
			is $node.quote, Q{Qx}, Q{quote name};
			is $node.delimiter-start, Q{<}, Q{start delimiter};
			is $node.delimiter-end, Q{>}, Q{end delimiter};

			done-testing;
		}, Q{no intervening ws};

		done-testing;
	}, Q{adverb :to};

	subtest {
		subtest {
			my $source = Q{Qx :w <pi>};
			my $tree = $pt.to-tree( $source );
			my $node = $tree.child.[0].child.[0];

			is $pt.to-string( $tree ), $source, Q{formatted};
			ok $node ~~ Perl6::String::Literal::Shell;
			is $node.quote, Q{Qx}, Q{quote name};
			is $node.delimiter-start, Q{<}, Q{start delimiter};
			is $node.delimiter-end, Q{>}, Q{end delimiter};

			done-testing;
		}, Q{all intervening ws};

		subtest {
			my $source = Q{Qx :w<pi>};
			my $tree = $pt.to-tree( $source );
			my $node = $tree.child.[0].child.[0];

			is $pt.to-string( $tree ), $source, Q{formatted};
			ok $node ~~ Perl6::String::Literal::Shell;
			is $node.quote, Q{Qx}, Q{quote name};
			is $node.delimiter-start, Q{<}, Q{start delimiter};
			is $node.delimiter-end, Q{>}, Q{end delimiter};

			done-testing;
		}, Q{leading intervening ws};

		subtest {
			my $source = Q{Qx:w <pi>};
			my $tree = $pt.to-tree( $source );
			my $node = $tree.child.[0].child.[0];

			is $pt.to-string( $tree ), $source, Q{formatted};
			ok $node ~~ Perl6::String::Literal::Shell;
			is $node.quote, Q{Qx}, Q{quote name};
			is $node.delimiter-start, Q{<}, Q{start delimiter};
			is $node.delimiter-end, Q{>}, Q{end delimiter};

			done-testing;
		}, Q{trailing intervening ws};

		subtest {
			my $source = Q{Qx:w<pi>};
			my $tree = $pt.to-tree( $source );
			my $node = $tree.child.[0].child.[0];

			is $pt.to-string( $tree ), $source, Q{formatted};
			ok $node ~~ Perl6::String::Literal::Shell;
			is $node.quote, Q{Qx}, Q{quote name};
			is $node.delimiter-start, Q{<}, Q{start delimiter};
			is $node.delimiter-end, Q{>}, Q{end delimiter};

			done-testing;
		}, Q{no intervening ws};

		done-testing;
	}, Q{adverb :w};

	subtest {
		subtest {
			my $source = Q{Qx :x <pi>};
			my $tree = $pt.to-tree( $source );
			my $node = $tree.child.[0].child.[0];

			is $pt.to-string( $tree ), $source, Q{formatted};
			ok $node ~~ Perl6::String::Literal::Shell;
			is $node.quote, Q{Qx}, Q{quote name};
			is $node.delimiter-start, Q{<}, Q{start delimiter};
			is $node.delimiter-end, Q{>}, Q{end delimiter};

			done-testing;
		}, Q{all intervening ws};

		subtest {
			my $source = Q{Qx :x<pi>};
			my $tree = $pt.to-tree( $source );
			my $node = $tree.child.[0].child.[0];

			is $pt.to-string( $tree ), $source, Q{formatted};
			ok $node ~~ Perl6::String::Literal::Shell;
			is $node.quote, Q{Qx}, Q{quote name};
			is $node.delimiter-start, Q{<}, Q{start delimiter};
			is $node.delimiter-end, Q{>}, Q{end delimiter};

			done-testing;
		}, Q{leading intervening ws};

		subtest {
			my $source = Q{Qx:x <pi>};
			my $tree = $pt.to-tree( $source );
			my $node = $tree.child.[0].child.[0];

			is $pt.to-string( $tree ), $source, Q{formatted};
			ok $node ~~ Perl6::String::Literal::Shell;
			is $node.quote, Q{Qx}, Q{quote name};
			is $node.delimiter-start, Q{<}, Q{start delimiter};
			is $node.delimiter-end, Q{>}, Q{end delimiter};

			done-testing;
		}, Q{trailing intervening ws};

		subtest {
			my $source = Q{Qx:x<pi>};
			my $tree = $pt.to-tree( $source );
			my $node = $tree.child.[0].child.[0];

			is $pt.to-string( $tree ), $source, Q{formatted};
			ok $node ~~ Perl6::String::Literal::Shell;
			is $node.quote, Q{Qx}, Q{quote name};
			is $node.delimiter-start, Q{<}, Q{start delimiter};
			is $node.delimiter-end, Q{>}, Q{end delimiter};

			done-testing;
		}, Q{no intervening ws};

		done-testing;
	}, Q{adverb :x};

	subtest {
		my $source = Q{Qx <pi>};
		my $tree = $pt.to-tree( $source );
		my $node = $tree.child.[0].child.[0];

		is $pt.to-string( $tree ), $source, Q{formatted};
		ok $node ~~ Perl6::String::Literal::Shell;
		is $node.quote, Q{Qx}, Q{quote name};
		is $node.delimiter-start, Q{<}, Q{start delimiter};
		is $node.delimiter-end, Q{>}, Q{end delimiter};

		done-testing;
	}, Q{ws, no adverbs};

	subtest {
		my $source = Q{Qx<pi>};
		my $tree = $pt.to-tree( $source );
		my $node = $tree.child.[0].child.[0];

		is $pt.to-string( $tree ), $source, Q{formatted};
		ok $node ~~ Perl6::String::Literal::Shell;
		is $node.quote, Q{Qx}, Q{quote name};
		is $node.delimiter-start, Q{<}, Q{start delimiter};
		is $node.delimiter-end, Q{>}, Q{end delimiter};

		done-testing;
	}, Q{no ws, no adverbs};

	done-testing;
}, Q{Qx<>};

subtest {
	subtest {
		subtest {
			my $source = Q{qq :w <pi>};
			my $tree = $pt.to-tree( $source );
			my $node = $tree.child.[0].child.[0];

			is $pt.to-string( $tree ), $source, Q{formatted};
			ok $node ~~ Perl6::String::Interpolation;
			is $node.quote, Q{qq}, Q{quote name};
			is $node.delimiter-start, Q{<}, Q{start delimiter};
			is $node.delimiter-end, Q{>}, Q{end delimiter};

			done-testing;
		}, Q{all intervening ws};

		subtest {
			my $source = Q{qq :w<pi>};
			my $tree = $pt.to-tree( $source );
			my $node = $tree.child.[0].child.[0];

			is $pt.to-string( $tree ), $source, Q{formatted};
			ok $node ~~ Perl6::String::Interpolation;
			is $node.quote, Q{qq}, Q{quote name};
			is $node.delimiter-start, Q{<}, Q{start delimiter};
			is $node.delimiter-end, Q{>}, Q{end delimiter};

			done-testing;
		}, Q{leading intervening ws};

		subtest {
			my $source = Q{qq:w <pi>};
			my $tree = $pt.to-tree( $source );
			my $node = $tree.child.[0].child.[0];

			is $pt.to-string( $tree ), $source, Q{formatted};
			ok $node ~~ Perl6::String::Interpolation;
			is $node.quote, Q{qq}, Q{quote name};
			is $node.delimiter-start, Q{<}, Q{start delimiter};
			is $node.delimiter-end, Q{>}, Q{end delimiter};

			done-testing;
		}, Q{trailing intervening ws};

		subtest {
			my $source = Q{qq:w<pi>};
			my $tree = $pt.to-tree( $source );
			my $node = $tree.child.[0].child.[0];

			is $pt.to-string( $tree ), $source, Q{formatted};
			ok $node ~~ Perl6::String::Interpolation;
			is $node.quote, Q{qq}, Q{quote name};
			is $node.delimiter-start, Q{<}, Q{start delimiter};
			is $node.delimiter-end, Q{>}, Q{end delimiter};

			done-testing;
		}, Q{no intervening ws};

		done-testing;
	}, Q{adverb :w};

	subtest {
		subtest {
			my $source = Q{qq :x <pi>};
			my $tree = $pt.to-tree( $source );
			my $node = $tree.child.[0].child.[0];

			is $pt.to-string( $tree ), $source, Q{formatted};
			ok $node ~~ Perl6::String::Interpolation;
			is $node.quote, Q{qq}, Q{quote name};
			is $node.delimiter-start, Q{<}, Q{start delimiter};
			is $node.delimiter-end, Q{>}, Q{end delimiter};

			done-testing;
		}, Q{all intervening ws};

		subtest {
			my $source = Q{qq :x<pi>};
			my $tree = $pt.to-tree( $source );
			my $node = $tree.child.[0].child.[0];

			is $pt.to-string( $tree ), $source, Q{formatted};
			ok $node ~~ Perl6::String::Interpolation;
			is $node.quote, Q{qq}, Q{quote name};
			is $node.delimiter-start, Q{<}, Q{start delimiter};
			is $node.delimiter-end, Q{>}, Q{end delimiter};

			done-testing;
		}, Q{leading intervening ws};

		subtest {
			my $source = Q{qq:x <pi>};
			my $tree = $pt.to-tree( $source );
			my $node = $tree.child.[0].child.[0];

			is $pt.to-string( $tree ), $source, Q{formatted};
			ok $node ~~ Perl6::String::Interpolation;
			is $node.quote, Q{qq}, Q{quote name};
			is $node.delimiter-start, Q{<}, Q{start delimiter};
			is $node.delimiter-end, Q{>}, Q{end delimiter};

			done-testing;
		}, Q{trailing intervening ws};

		subtest {
			my $source = Q{qq:x<pi>};
			my $tree = $pt.to-tree( $source );
			my $node = $tree.child.[0].child.[0];

			is $pt.to-string( $tree ), $source, Q{formatted};
			ok $node ~~ Perl6::String::Interpolation;
			is $node.quote, Q{qq}, Q{quote name};
			is $node.delimiter-start, Q{<}, Q{start delimiter};
			is $node.delimiter-end, Q{>}, Q{end delimiter};

			done-testing;
		}, Q{no intervening ws};

		done-testing;
	}, Q{adverb :x};

	subtest {
		my $source = Q{qq <pi>};
		my $tree = $pt.to-tree( $source );
		my $node = $tree.child.[0].child.[0];

		is $pt.to-string( $tree ), $source, Q{formatted};
		ok $node ~~ Perl6::String::Interpolation;
		is $node.quote, Q{qq}, Q{quote name};
		is $node.delimiter-start, Q{<}, Q{start delimiter};
		is $node.delimiter-end, Q{>}, Q{end delimiter};

		done-testing;
	}, Q{ws, no adverbs};

	subtest {
		my $source = Q{qq<pi>};
		my $tree = $pt.to-tree( $source );
		my $node = $tree.child.[0].child.[0];

		is $pt.to-string( $tree ), $source, Q{formatted};
		ok $node ~~ Perl6::String::Interpolation;
		is $node.quote, Q{qq}, Q{quote name};
		is $node.delimiter-start, Q{<}, Q{start delimiter};
		is $node.delimiter-end, Q{>}, Q{end delimiter};

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
			my $tree = $pt.to-tree( $source );
			my $node = $tree.child.[0].child.[0];

			is $pt.to-string( $tree ), $source, Q{formatted};
			ok $node ~~ Perl6::String::WordQuoting;
			is $node.quote, Q{qw}, Q{quote name};
			is $node.delimiter-start, Q{<}, Q{start delimiter};
			is $node.delimiter-end, Q{>}, Q{end delimiter};

			done-testing;
		}, Q{all intervening ws};

		subtest {
			my $source = Q{qw :to<END>
pi
END};
			my $tree = $pt.to-tree( $source );
			my $node = $tree.child.[0].child.[0];

			is $pt.to-string( $tree ), $source, Q{formatted};
			ok $node ~~ Perl6::String::WordQuoting;
			is $node.quote, Q{qw}, Q{quote name};
			is $node.delimiter-start, Q{<}, Q{start delimiter};
			is $node.delimiter-end, Q{>}, Q{end delimiter};

			done-testing;
		}, Q{leading intervening ws};

		subtest {
			my $source = Q{qw:to <END>
pi
END};
			my $tree = $pt.to-tree( $source );
			my $node = $tree.child.[0].child.[0];

			is $pt.to-string( $tree ), $source, Q{formatted};
			ok $node ~~ Perl6::String::WordQuoting;
			is $node.quote, Q{qw}, Q{quote name};
			is $node.delimiter-start, Q{<}, Q{start delimiter};
			is $node.delimiter-end, Q{>}, Q{end delimiter};

			done-testing;
		}, Q{trailing intervening ws};

		subtest {
			my $source = Q{qw:to<END>
pi
END};
			my $tree = $pt.to-tree( $source );
			my $node = $tree.child.[0].child.[0];

			is $pt.to-string( $tree ), $source, Q{formatted};
			ok $node ~~ Perl6::String::WordQuoting;
			is $node.quote, Q{qw}, Q{quote name};
			is $node.delimiter-start, Q{<}, Q{start delimiter};
			is $node.delimiter-end, Q{>}, Q{end delimiter};

			done-testing;
		}, Q{no intervening ws};

		done-testing;
	}, Q{adverb :to};

	subtest {
		subtest {
			my $source = Q{qw :w <pi>};
			my $tree = $pt.to-tree( $source );
			my $node = $tree.child.[0].child.[0];

			is $pt.to-string( $tree ), $source, Q{formatted};
			ok $node ~~ Perl6::String::WordQuoting;
			is $node.quote, Q{qw}, Q{quote name};
			is $node.delimiter-start, Q{<}, Q{start delimiter};
			is $node.delimiter-end, Q{>}, Q{end delimiter};

			done-testing;
		}, Q{all intervening ws};

		subtest {
			my $source = Q{qw :w<pi>};
			my $tree = $pt.to-tree( $source );
			my $node = $tree.child.[0].child.[0];

			is $pt.to-string( $tree ), $source, Q{formatted};
			ok $node ~~ Perl6::String::WordQuoting;
			is $node.quote, Q{qw}, Q{quote name};
			is $node.delimiter-start, Q{<}, Q{start delimiter};
			is $node.delimiter-end, Q{>}, Q{end delimiter};

			done-testing;
		}, Q{leading intervening ws};

		subtest {
			my $source = Q{qw:w <pi>};
			my $tree = $pt.to-tree( $source );
			my $node = $tree.child.[0].child.[0];

			is $pt.to-string( $tree ), $source, Q{formatted};
			ok $node ~~ Perl6::String::WordQuoting;
			is $node.quote, Q{qw}, Q{quote name};
			is $node.delimiter-start, Q{<}, Q{start delimiter};
			is $node.delimiter-end, Q{>}, Q{end delimiter};

			done-testing;
		}, Q{trailing intervening ws};

		subtest {
			my $source = Q{qw:w<pi>};
			my $tree = $pt.to-tree( $source );
			my $node = $tree.child.[0].child.[0];

			is $pt.to-string( $tree ), $source, Q{formatted};
			ok $node ~~ Perl6::String::WordQuoting;
			is $node.quote, Q{qw}, Q{quote name};
			is $node.delimiter-start, Q{<}, Q{start delimiter};
			is $node.delimiter-end, Q{>}, Q{end delimiter};

			done-testing;
		}, Q{no intervening ws};

		done-testing;
	}, Q{adverb :w};

	subtest {
		subtest {
			my $source = Q{qw :x <pi>};
			my $tree = $pt.to-tree( $source );
			my $node = $tree.child.[0].child.[0];

			is $pt.to-string( $tree ), $source, Q{formatted};
			ok $node ~~ Perl6::String::WordQuoting;
			is $node.quote, Q{qw}, Q{quote name};
			is $node.delimiter-start, Q{<}, Q{start delimiter};
			is $node.delimiter-end, Q{>}, Q{end delimiter};

			done-testing;
		}, Q{all intervening ws};

		subtest {
			my $source = Q{qw :x<pi>};
			my $tree = $pt.to-tree( $source );
			my $node = $tree.child.[0].child.[0];

			is $pt.to-string( $tree ), $source, Q{formatted};
			ok $node ~~ Perl6::String::WordQuoting;
			is $node.quote, Q{qw}, Q{quote name};
			is $node.delimiter-start, Q{<}, Q{start delimiter};
			is $node.delimiter-end, Q{>}, Q{end delimiter};

			done-testing;
		}, Q{leading intervening ws};

		subtest {
			my $source = Q{qw:x <pi>};
			my $tree = $pt.to-tree( $source );
			my $node = $tree.child.[0].child.[0];

			is $pt.to-string( $tree ), $source, Q{formatted};
			ok $node ~~ Perl6::String::WordQuoting;
			is $node.quote, Q{qw}, Q{quote name};
			is $node.delimiter-start, Q{<}, Q{start delimiter};
			is $node.delimiter-end, Q{>}, Q{end delimiter};

			done-testing;
		}, Q{trailing intervening ws};

		subtest {
			my $source = Q{qw:x<pi>};
			my $tree = $pt.to-tree( $source );
			my $node = $tree.child.[0].child.[0];

			is $pt.to-string( $tree ), $source, Q{formatted};
			ok $node ~~ Perl6::String::WordQuoting;
			is $node.quote, Q{qw}, Q{quote name};
			is $node.delimiter-start, Q{<}, Q{start delimiter};
			is $node.delimiter-end, Q{>}, Q{end delimiter};

			done-testing;
		}, Q{no intervening ws};

		done-testing;
	}, Q{adverb :x};

	subtest {
		my $source = Q{qw <pi>};
		my $tree = $pt.to-tree( $source );
		my $node = $tree.child.[0].child.[0];

		is $pt.to-string( $tree ), $source, Q{formatted};
		ok $node ~~ Perl6::String::WordQuoting;
		is $node.quote, Q{qw}, Q{quote name};
		is $node.delimiter-start, Q{<}, Q{start delimiter};
		is $node.delimiter-end, Q{>}, Q{end delimiter};

		done-testing;
	}, Q{ws, no adverbs};

	subtest {
		my $source = Q{qw<pi>};
		my $tree = $pt.to-tree( $source );
		my $node = $tree.child.[0].child.[0];

		is $pt.to-string( $tree ), $source, Q{formatted};
		ok $node ~~ Perl6::String::WordQuoting;
		is $node.quote, Q{qw}, Q{quote name};
		is $node.delimiter-start, Q{<}, Q{start delimiter};
		is $node.delimiter-end, Q{>}, Q{end delimiter};

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
			my $tree = $pt.to-tree( $source );
			my $node = $tree.child.[0].child.[0];

			is $pt.to-string( $tree ), $source, Q{formatted};
			ok $node ~~ Perl6::String::Shell;
			is $node.quote, Q{qx}, Q{quote name};
			is $node.delimiter-start, Q{<}, Q{start delimiter};
			is $node.delimiter-end, Q{>}, Q{end delimiter};

			done-testing;
		}, Q{all intervening ws};

		subtest {
			my $source = Q{qx :to<END>
pi
END};
			my $tree = $pt.to-tree( $source );
			my $node = $tree.child.[0].child.[0];

			is $pt.to-string( $tree ), $source, Q{formatted};
			ok $node ~~ Perl6::String::Shell;
			is $node.quote, Q{qx}, Q{quote name};
			is $node.delimiter-start, Q{<}, Q{start delimiter};
			is $node.delimiter-end, Q{>}, Q{end delimiter};

			done-testing;
		}, Q{leading intervening ws};

		subtest {
			my $source = Q{qx:to <END>
pi
END};
			my $tree = $pt.to-tree( $source );
			my $node = $tree.child.[0].child.[0];

			is $pt.to-string( $tree ), $source, Q{formatted};
			ok $node ~~ Perl6::String::Shell;
			is $node.quote, Q{qx}, Q{quote name};
			is $node.delimiter-start, Q{<}, Q{start delimiter};
			is $node.delimiter-end, Q{>}, Q{end delimiter};

			done-testing;
		}, Q{trailing intervening ws};

		subtest {
			my $source = Q{qx:to<END>
pi
END};
			my $tree = $pt.to-tree( $source );
			my $node = $tree.child.[0].child.[0];

			is $pt.to-string( $tree ), $source, Q{formatted};
			ok $node ~~ Perl6::String::Shell;
			is $node.quote, Q{qx}, Q{quote name};
			is $node.delimiter-start, Q{<}, Q{start delimiter};
			is $node.delimiter-end, Q{>}, Q{end delimiter};

			done-testing;
		}, Q{no intervening ws};

		done-testing;
	}, Q{adverb :to};

	subtest {
		subtest {
			my $source = Q{qx :w <pi>};
			my $tree = $pt.to-tree( $source );
			my $node = $tree.child.[0].child.[0];

			is $pt.to-string( $tree ), $source, Q{formatted};
			ok $node ~~ Perl6::String::Shell;
			is $node.quote, Q{qx}, Q{quote name};
			is $node.delimiter-start, Q{<}, Q{start delimiter};
			is $node.delimiter-end, Q{>}, Q{end delimiter};

			done-testing;
		}, Q{all intervening ws};

		subtest {
			my $source = Q{qx :w<pi>};
			my $tree = $pt.to-tree( $source );
			my $node = $tree.child.[0].child.[0];

			is $pt.to-string( $tree ), $source, Q{formatted};
			ok $node ~~ Perl6::String::Shell;
			is $node.quote, Q{qx}, Q{quote name};
			is $node.delimiter-start, Q{<}, Q{start delimiter};
			is $node.delimiter-end, Q{>}, Q{end delimiter};

			done-testing;
		}, Q{leading intervening ws};

		subtest {
			my $source = Q{qx:w <pi>};
			my $tree = $pt.to-tree( $source );
			my $node = $tree.child.[0].child.[0];

			is $pt.to-string( $tree ), $source, Q{formatted};
			ok $node ~~ Perl6::String::Shell;
			is $node.quote, Q{qx}, Q{quote name};
			is $node.delimiter-start, Q{<}, Q{start delimiter};
			is $node.delimiter-end, Q{>}, Q{end delimiter};

			done-testing;
		}, Q{trailing intervening ws};

		subtest {
			my $source = Q{qx:w<pi>};
			my $tree = $pt.to-tree( $source );
			my $node = $tree.child.[0].child.[0];

			is $pt.to-string( $tree ), $source, Q{formatted};
			ok $node ~~ Perl6::String::Shell;
			is $node.quote, Q{qx}, Q{quote name};
			is $node.delimiter-start, Q{<}, Q{start delimiter};
			is $node.delimiter-end, Q{>}, Q{end delimiter};

			done-testing;
		}, Q{no intervening ws};

		done-testing;
	}, Q{adverb :w};

	subtest {
		subtest {
			my $source = Q{qx :x <pi>};
			my $tree = $pt.to-tree( $source );
			my $node = $tree.child.[0].child.[0];

			is $pt.to-string( $tree ), $source, Q{formatted};
			ok $node ~~ Perl6::String::Shell;
			is $node.quote, Q{qx}, Q{quote name};
			is $node.delimiter-start, Q{<}, Q{start delimiter};
			is $node.delimiter-end, Q{>}, Q{end delimiter};

			done-testing;
		}, Q{all intervening ws};

		subtest {
			my $source = Q{qx :x<pi>};
			my $tree = $pt.to-tree( $source );
			my $node = $tree.child.[0].child.[0];

			is $pt.to-string( $tree ), $source, Q{formatted};
			ok $node ~~ Perl6::String::Shell;
			is $node.quote, Q{qx}, Q{quote name};
			is $node.delimiter-start, Q{<}, Q{start delimiter};
			is $node.delimiter-end, Q{>}, Q{end delimiter};

			done-testing;
		}, Q{leading intervening ws};

		subtest {
			my $source = Q{qx:x <pi>};
			my $tree = $pt.to-tree( $source );
			my $node = $tree.child.[0].child.[0];

			is $pt.to-string( $tree ), $source, Q{formatted};
			ok $node ~~ Perl6::String::Shell;
			is $node.quote, Q{qx}, Q{quote name};
			is $node.delimiter-start, Q{<}, Q{start delimiter};
			is $node.delimiter-end, Q{>}, Q{end delimiter};

			done-testing;
		}, Q{trailing intervening ws};

		subtest {
			my $source = Q{qx:x<pi>};
			my $tree = $pt.to-tree( $source );
			my $node = $tree.child.[0].child.[0];

			is $pt.to-string( $tree ), $source, Q{formatted};
			ok $node ~~ Perl6::String::Shell;
			is $node.quote, Q{qx}, Q{quote name};
			is $node.delimiter-start, Q{<}, Q{start delimiter};
			is $node.delimiter-end, Q{>}, Q{end delimiter};

			done-testing;
		}, Q{no intervening ws};

		done-testing;
	}, Q{adverb :x};

	subtest {
		my $source = Q{qx <pi>};
		my $tree = $pt.to-tree( $source );
			my $node = $tree.child.[0].child.[0];

		is $pt.to-string( $tree ), $source, Q{formatted};
		ok $node ~~ Perl6::String::Shell;
		is $node.quote, Q{qx}, Q{quote name};
		is $node.delimiter-start, Q{<}, Q{start delimiter};
		is $node.delimiter-end, Q{>}, Q{end delimiter};

		done-testing;
	}, Q{ws, no adverbs};

	subtest {
		my $source = Q{qx<pi>};
		my $tree = $pt.to-tree( $source );
		my $node = $tree.child.[0].child.[0];

		is $pt.to-string( $tree ), $source, Q{formatted};
		ok $node ~~ Perl6::String::Shell;
		is $node.quote, Q{qx}, Q{quote name};
		is $node.delimiter-start, Q{<}, Q{start delimiter};
		is $node.delimiter-end, Q{>}, Q{end delimiter};

		done-testing;
	}, Q{no ws, no adverbs};

	done-testing;
}, Q{qx<>};

subtest {
	subtest {
		subtest {
			my $source = Q{Q :q <pi>};
			my $tree = $pt.to-tree( $source );
			my $node = $tree.child.[0].child.[0];

			is $pt.to-string( $tree ), $source, Q{formatted};
			ok $node ~~ Perl6::String::Literal;
			is $node.quote, Q{Q}, Q{quote name};
			is $node.delimiter-start, Q{<}, Q{start delimiter};
			is $node.delimiter-end, Q{>}, Q{end delimiter};

			done-testing;
		}, Q{all intervening ws};

		subtest {
			my $source = Q{Q :q<pi>};
			my $tree = $pt.to-tree( $source );
			my $node = $tree.child.[0].child.[0];

			is $pt.to-string( $tree ), $source, Q{formatted};
			ok $node ~~ Perl6::String::Literal;
			is $node.quote, Q{Q}, Q{quote name};
			is $node.delimiter-start, Q{<}, Q{start delimiter};
			is $node.delimiter-end, Q{>}, Q{end delimiter};

			done-testing;
		}, Q{leading intervening ws};

		subtest {
			my $source = Q{Q:q <pi>};
			my $tree = $pt.to-tree( $source );
			my $node = $tree.child.[0].child.[0];

			is $pt.to-string( $tree ), $source, Q{formatted};
			ok $node ~~ Perl6::String::Literal;
			is $node.quote, Q{Q}, Q{quote name};
			is $node.delimiter-start, Q{<}, Q{start delimiter};
			is $node.delimiter-end, Q{>}, Q{end delimiter};

			done-testing;
		}, Q{trailing intervening ws};

		subtest {
			my $source = Q{Q:q<pi>};
			my $tree = $pt.to-tree( $source );
			my $node = $tree.child.[0].child.[0];

			is $pt.to-string( $tree ), $source, Q{formatted};
			ok $node ~~ Perl6::String::Literal;
			is $node.quote, Q{Q}, Q{quote name};
			is $node.delimiter-start, Q{<}, Q{start delimiter};
			is $node.delimiter-end, Q{>}, Q{end delimiter};

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
			my $tree = $pt.to-tree( $source );
			my $node = $tree.child.[0].child.[0];

			is $pt.to-string( $tree ), $source, Q{formatted};
			ok $node ~~ Perl6::String::Literal;
			is $node.quote, Q{Q}, Q{quote name};
			is $node.delimiter-start, Q{<}, Q{start delimiter};
			is $node.delimiter-end, Q{>}, Q{end delimiter};

			done-testing;
		}, Q{all intervening ws};

		subtest {
			my $source = Q{Q :to<END>
pi
END
};
			my $tree = $pt.to-tree( $source );
			my $node = $tree.child.[0].child.[0];

			is $pt.to-string( $tree ), $source, Q{formatted};
			ok $node ~~ Perl6::String::Literal;
			is $node.quote, Q{Q}, Q{quote name};
			is $node.delimiter-start, Q{<}, Q{start delimiter};
			is $node.delimiter-end, Q{>}, Q{end delimiter};

			done-testing;
		}, Q{leading intervening ws};

		subtest {
			my $source = Q{Q:to <END>
pi
END
};
			my $tree = $pt.to-tree( $source );
			my $node = $tree.child.[0].child.[0];

			is $pt.to-string( $tree ), $source, Q{formatted};
			ok $node ~~ Perl6::String::Literal;
			is $node.quote, Q{Q}, Q{quote name};
			is $node.delimiter-start, Q{<}, Q{start delimiter};
			is $node.delimiter-end, Q{>}, Q{end delimiter};

			done-testing;
		}, Q{trailing intervening ws};

		subtest {
			my $source = Q{Q:to<END>
pi
END
};
			my $tree = $pt.to-tree( $source );
			my $node = $tree.child.[0].child.[0];

			is $pt.to-string( $tree ), $source, Q{formatted};
			ok $node ~~ Perl6::String::Literal;
			is $node.quote, Q{Q}, Q{quote name};
			is $node.delimiter-start, Q{<}, Q{start delimiter};
			is $node.delimiter-end, Q{>}, Q{end delimiter};

			done-testing;
		}, Q{no intervening ws};

		done-testing;
	}, Q{adverb :to};

	subtest {
		subtest {
			my $source = Q{Q :w <pi>};
			my $tree = $pt.to-tree( $source );
			my $node = $tree.child.[0].child.[0];

			is $pt.to-string( $tree ), $source, Q{formatted};
			ok $node ~~ Perl6::String::Literal;
			is $node.quote, Q{Q}, Q{quote name};
			is $node.delimiter-start, Q{<}, Q{start delimiter};
			is $node.delimiter-end, Q{>}, Q{end delimiter};

			done-testing;
		}, Q{all intervening ws};

		subtest {
			my $source = Q{Q :w<pi>};
			my $tree = $pt.to-tree( $source );
			my $node = $tree.child.[0].child.[0];

			is $pt.to-string( $tree ), $source, Q{formatted};
			ok $node ~~ Perl6::String::Literal;
			is $node.quote, Q{Q}, Q{quote name};
			is $node.delimiter-start, Q{<}, Q{start delimiter};
			is $node.delimiter-end, Q{>}, Q{end delimiter};

			done-testing;
		}, Q{leading intervening ws};

		subtest {
			my $source = Q{Q:w <pi>};
			my $tree = $pt.to-tree( $source );
			my $node = $tree.child.[0].child.[0];

			is $pt.to-string( $tree ), $source, Q{formatted};
			ok $node ~~ Perl6::String::Literal;
			is $node.quote, Q{Q}, Q{quote name};
			is $node.delimiter-start, Q{<}, Q{start delimiter};
			is $node.delimiter-end, Q{>}, Q{end delimiter};

			done-testing;
		}, Q{trailing intervening ws};

		subtest {
			my $source = Q{Q:w<pi>};
			my $tree = $pt.to-tree( $source );
			my $node = $tree.child.[0].child.[0];

			is $pt.to-string( $tree ), $source, Q{formatted};
			ok $node ~~ Perl6::String::Literal;
			is $node.quote, Q{Q}, Q{quote name};
			is $node.delimiter-start, Q{<}, Q{start delimiter};
			is $node.delimiter-end, Q{>}, Q{end delimiter};

			done-testing;
		}, Q{no intervening ws};

		done-testing;
	}, Q{adverb :w};

	subtest {
		subtest {
			my $source = Q{Q :x <pi>};
			my $tree = $pt.to-tree( $source );
			my $node = $tree.child.[0].child.[0];

			is $pt.to-string( $tree ), $source, Q{formatted};
			ok $node ~~ Perl6::String::Literal;
			is $node.quote, Q{Q}, Q{quote name};
			is $node.delimiter-start, Q{<}, Q{start delimiter};
			is $node.delimiter-end, Q{>}, Q{end delimiter};

			done-testing;
		}, Q{all intervening ws};

		subtest {
			my $source = Q{Q :x<pi>};
			my $tree = $pt.to-tree( $source );
			my $node = $tree.child.[0].child.[0];

			is $pt.to-string( $tree ), $source, Q{formatted};
			ok $node ~~ Perl6::String::Literal;
			is $node.quote, Q{Q}, Q{quote name};
			is $node.delimiter-start, Q{<}, Q{start delimiter};
			is $node.delimiter-end, Q{>}, Q{end delimiter};

			done-testing;
		}, Q{leading intervening ws};

		subtest {
			my $source = Q{Q:x <pi>};
			my $tree = $pt.to-tree( $source );
			my $node = $tree.child.[0].child.[0];

			is $pt.to-string( $tree ), $source, Q{formatted};
			ok $node ~~ Perl6::String::Literal;
			is $node.quote, Q{Q}, Q{quote name};
			is $node.delimiter-start, Q{<}, Q{start delimiter};
			is $node.delimiter-end, Q{>}, Q{end delimiter};

			done-testing;
		}, Q{trailing intervening ws};

		subtest {
			my $source = Q{Q:x<pi>};
			my $tree = $pt.to-tree( $source );
			my $node = $tree.child.[0].child.[0];

			is $pt.to-string( $tree ), $source, Q{formatted};
			ok $node ~~ Perl6::String::Literal;
			is $node.quote, Q{Q}, Q{quote name};
			is $node.delimiter-start, Q{<}, Q{start delimiter};
			is $node.delimiter-end, Q{>}, Q{end delimiter};

			done-testing;
		}, Q{no intervening ws};

		done-testing;
	}, Q{adverb :x};

	subtest {
		my $source = Q{Q <pi>};
		my $tree = $pt.to-tree( $source );
		my $node = $tree.child.[0].child.[0];

		is $pt.to-string( $tree ), $source, Q{formatted};
		ok $node ~~ Perl6::String::Literal;
		is $node.quote, Q{Q}, Q{quote name};
		is $node.delimiter-start, Q{<}, Q{start delimiter};
		is $node.delimiter-end, Q{>}, Q{end delimiter};

		done-testing;
	}, Q{ws, no adverbs};

	subtest {
		my $source = Q{Q<pi>};
		my $tree = $pt.to-tree( $source );
		my $node = $tree.child.[0].child.[0];

		is $pt.to-string( $tree ), $source, Q{formatted};
		ok $node ~~ Perl6::String::Literal;
		is $node.quote, Q{Q}, Q{quote name};
		is $node.delimiter-start, Q{<}, Q{start delimiter};
		is $node.delimiter-end, Q{>}, Q{end delimiter};

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
			my $tree = $pt.to-tree( $source );
			my $node = $tree.child.[0].child.[0];

			is $pt.to-string( $tree ), $source, Q{formatted};
			ok $node ~~ Perl6::String::Escaping;
			is $node.quote, Q{q}, Q{quote name};
			is $node.delimiter-start, Q{<}, Q{start delimiter};
			is $node.delimiter-end, Q{>}, Q{end delimiter};

			done-testing;
		}, Q{all intervening ws};

		subtest {
			my $source = Q{q :to<END>
pi
END
};
			my $tree = $pt.to-tree( $source );
			my $node = $tree.child.[0].child.[0];

			is $pt.to-string( $tree ), $source, Q{formatted};
			ok $node ~~ Perl6::String::Escaping;
			is $node.quote, Q{q}, Q{quote name};
			is $node.delimiter-start, Q{<}, Q{start delimiter};
			is $node.delimiter-end, Q{>}, Q{end delimiter};

			done-testing;
		}, Q{leading intervening ws};

		subtest {
			my $source = Q{q:to <END>
pi
END
};
			my $tree = $pt.to-tree( $source );
			my $node = $tree.child.[0].child.[0];

			is $pt.to-string( $tree ), $source, Q{formatted};
			ok $node ~~ Perl6::String::Escaping;
			is $node.quote, Q{q}, Q{quote name};
			is $node.delimiter-start, Q{<}, Q{start delimiter};
			is $node.delimiter-end, Q{>}, Q{end delimiter};

			done-testing;
		}, Q{trailing intervening ws};

		subtest {
			my $source = Q{q:to<END>
pi
END
};
			my $tree = $pt.to-tree( $source );
			my $node = $tree.child.[0].child.[0];

			is $pt.to-string( $tree ), $source, Q{formatted};
			ok $node ~~ Perl6::String::Escaping;
			is $node.quote, Q{q}, Q{quote name};
			is $node.delimiter-start, Q{<}, Q{start delimiter};
			is $node.delimiter-end, Q{>}, Q{end delimiter};

			done-testing;
		}, Q{no intervening ws};

		done-testing;
	}, Q{adverb :to};

	subtest {
		subtest {
			my $source = Q{q :w <pi>};
			my $tree = $pt.to-tree( $source );
			my $node = $tree.child.[0].child.[0];

			is $pt.to-string( $tree ), $source, Q{formatted};
			ok $node ~~ Perl6::String::Escaping;
			is $node.quote, Q{q}, Q{quote name};
			is $node.delimiter-start, Q{<}, Q{start delimiter};
			is $node.delimiter-end, Q{>}, Q{end delimiter};

			done-testing;
		}, Q{all intervening ws};

		subtest {
			my $source = Q{q :w<pi>};
			my $tree = $pt.to-tree( $source );
			my $node = $tree.child.[0].child.[0];

			is $pt.to-string( $tree ), $source, Q{formatted};
			ok $node ~~ Perl6::String::Escaping;
			is $node.quote, Q{q}, Q{quote name};
			is $node.delimiter-start, Q{<}, Q{start delimiter};
			is $node.delimiter-end, Q{>}, Q{end delimiter};

			done-testing;
		}, Q{leading intervening ws};

		subtest {
			my $source = Q{q:w <pi>};
			my $tree = $pt.to-tree( $source );
			my $node = $tree.child.[0].child.[0];

			is $pt.to-string( $tree ), $source, Q{formatted};
			ok $node ~~ Perl6::String::Escaping;
			is $node.quote, Q{q}, Q{quote name};
			is $node.delimiter-start, Q{<}, Q{start delimiter};
			is $node.delimiter-end, Q{>}, Q{end delimiter};

			done-testing;
		}, Q{trailing intervening ws};

		subtest {
			my $source = Q{q:w<pi>};
			my $tree = $pt.to-tree( $source );
			my $node = $tree.child.[0].child.[0];

			is $pt.to-string( $tree ), $source, Q{formatted};
			ok $node ~~ Perl6::String::Escaping;
			is $node.quote, Q{q}, Q{quote name};
			is $node.delimiter-start, Q{<}, Q{start delimiter};
			is $node.delimiter-end, Q{>}, Q{end delimiter};

			done-testing;
		}, Q{no intervening ws};

		done-testing;
	}, Q{adverb :w};

	subtest {
		subtest {
			my $source = Q{q :x <pi>};
			my $tree = $pt.to-tree( $source );
			my $node = $tree.child.[0].child.[0];

			is $pt.to-string( $tree ), $source, Q{formatted};
			ok $node ~~ Perl6::String::Escaping;
			is $node.quote, Q{q}, Q{quote name};
			is $node.delimiter-start, Q{<}, Q{start delimiter};
			is $node.delimiter-end, Q{>}, Q{end delimiter};

			done-testing;
		}, Q{all intervening ws};

		subtest {
			my $source = Q{q :x<pi>};
			my $tree = $pt.to-tree( $source );
			my $node = $tree.child.[0].child.[0];

			is $pt.to-string( $tree ), $source, Q{formatted};
			ok $node ~~ Perl6::String::Escaping;
			is $node.quote, Q{q}, Q{quote name};
			is $node.delimiter-start, Q{<}, Q{start delimiter};
			is $node.delimiter-end, Q{>}, Q{end delimiter};

			done-testing;
		}, Q{leading intervening ws};

		subtest {
			my $source = Q{q:x <pi>};
			my $tree = $pt.to-tree( $source );
			my $node = $tree.child.[0].child.[0];

			is $pt.to-string( $tree ), $source, Q{formatted};
			ok $node ~~ Perl6::String::Escaping;
			is $node.quote, Q{q}, Q{quote name};
			is $node.delimiter-start, Q{<}, Q{start delimiter};
			is $node.delimiter-end, Q{>}, Q{end delimiter};

			done-testing;
		}, Q{trailing intervening ws};

		subtest {
			my $source = Q{q:x<pi>};
			my $tree = $pt.to-tree( $source );
			my $node = $tree.child.[0].child.[0];

			is $pt.to-string( $tree ), $source, Q{formatted};
			ok $node ~~ Perl6::String::Escaping;
			is $node.quote, Q{q}, Q{quote name};
			is $node.delimiter-start, Q{<}, Q{start delimiter};
			is $node.delimiter-end, Q{>}, Q{end delimiter};

			done-testing;
		}, Q{no intervening ws};

		done-testing;
	}, Q{adverb :x};

	subtest {
		my $source = Q{q <pi>};
		my $tree = $pt.to-tree( $source );
		my $node = $tree.child.[0].child.[0];

		is $pt.to-string( $tree ), $source, Q{formatted};
		ok $node ~~ Perl6::String::Escaping;
		is $node.quote, Q{q}, Q{quote name};
		is $node.delimiter-start, Q{<}, Q{start delimiter};
		is $node.delimiter-end, Q{>}, Q{end delimiter};

		done-testing;
	}, Q{intervening ws, no adverbs};

	subtest {
		my $source = Q{q<pi>};
		my $tree = $pt.to-tree( $source );
		my $node = $tree.child.[0].child.[0];

		is $pt.to-string( $tree ), $source, Q{formatted};
		ok $node ~~ Perl6::String::Escaping;
		is $node.quote, Q{q}, Q{quote name};
		is $node.delimiter-start, Q{<}, Q{start delimiter};
		is $node.delimiter-end, Q{>}, Q{end delimiter};

		done-testing;
	}, Q{no ws, no adverbs};

	done-testing;
}, Q{q<>};

subtest {
	my $source = Q{<pi>};
	my $tree = $pt.to-tree( $source );
	my $node = $tree.child.[0].child.[0];

	is $pt.to-string( $tree ), $source, Q{formatted};
	ok $node ~~ Perl6::String::WordQuoting;
#	is $node.quote, Q{<>}, Q{quote name};
#	is $node.delimiter-start, Q{<}, Q{start delimiter};
#	is $node.delimiter-end, Q{>}, Q{end delimiter};

	done-testing;
}, Q{<>};

subtest {
	my $source = Q{｢pi｣};
	my $tree = $pt.to-tree( $source );
	my $node = $tree.child.[0].child.[0];

	is $pt.to-string( $tree ), $source, Q{formatted};
	ok $node ~~ Perl6::String::Literal;
#	is $node.quote, Q{｢｣}, Q{quote name};
	is $node.delimiter-start, Q{｢}, Q{start delimiter};
	is $node.delimiter-end, Q{｣}, Q{end delimiter};

	done-testing;
}, Q{｢｣};

subtest {
	my $source = Q{"pi"};
	my $tree = $pt.to-tree( $source );
	my $node = $tree.child.[0].child.[0];

	is $pt.to-string( $tree ), $source, Q{formatted};
	ok $node ~~ Perl6::String::Interpolation;
#	is $node.quote, Q{""}, Q{quote name};
	is $node.delimiter-start, Q{"}, Q{start delimiter};
	is $node.delimiter-end, Q{"}, Q{end delimiter};

	done-testing;
}, Q{"" (double-quote)};

subtest {
	my $source = Q{'pi'};
	my $tree = $pt.to-tree( $source );
	my $node = $tree.child.[0].child.[0];

	is $pt.to-string( $tree ), $source, Q{formatted};
	ok $node ~~ Perl6::String::Escaping;
#	is $node.quote, Q{''}, Q{quote name};
	is $node.delimiter-start, Q{'}, Q{start delimiter};
	is $node.delimiter-end, Q{'}, Q{end delimiter};

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
	my $tree = $pt.to-tree( $source );
	my $node = $tree.child.[0].child.[0];

	is $pt.to-string( $tree ), $source, Q{formatted};
	ok $node ~~
		Perl6::String::Escaping;
#	is $node.quote, Q{qqww}, Q{quote name};
	is $node.delimiter-start, Q{<}, Q{start delimiter};
	is $node.delimiter-end, Q{>}, Q{end delimiter};
]

	done-testing;
}, Q{here-doc torture test};

# vim: ft=perl6
