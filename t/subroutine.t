use v6;

use Test;
use Perl6::Tidy;

plan 2;

my $pt = Perl6::Tidy.new;
#my $*TRACE = 1;
#my $*DEBUG = 1;

subtest {
	plan 2;

	my $source = Q:to[_END_];
sub foo { }
_END_
	my $parsed = $pt.parse-source( $source );
	my $tree = $pt.build-tree( $parsed );
	ok $pt.validate( $parsed ), Q{valid};
	is $pt.format( $tree ), $source, Q{formatted};
}, Q{empty};

subtest {
	plan 2;

	subtest {
		plan 6;

		subtest {
			plan 2;

			my $source = Q:to[_END_];
sub foo( ) { }
_END_
			my $parsed = $pt.parse-source( $source );
			my $tree = $pt.build-tree( $parsed );
			ok $pt.validate( $parsed ), Q{valid};
			is $pt.format( $tree ), $source, Q{formatted};
		}, Q{empty};

		subtest {
			plan 2;

			my $source = Q:to[_END_];
sub foo( 0 ) { }
_END_
			my $parsed = $pt.parse-source( $source );
			my $tree = $pt.build-tree( $parsed );
			ok $pt.validate( $parsed ), Q{valid};
			is $pt.format( $tree ), $source, Q{formatted};
		}, Q{constant};

		subtest {
			plan 2;

			my $source = Q:to[_END_];
sub foo( $a ) { }
_END_
			my $parsed = $pt.parse-source( $source );
			my $tree = $pt.build-tree( $parsed );
			ok $pt.validate( $parsed ), Q{valid};
			is $pt.format( $tree ), $source, Q{formatted};
		}, Q{untyped};

		subtest {
			plan 4;

			subtest {
				plan 2;

				my $source = Q:to[_END_];
sub foo( Str $a ) { }
_END_
				my $parsed = $pt.parse-source( $source );
				my $tree = $pt.build-tree( $parsed );
				ok $pt.validate( $parsed ), Q{valid};
				is $pt.format( $tree ), $source, Q{formatted};
			}, Q{typed};

			subtest {
				plan 2;

				my $source = Q:to[_END_];
sub foo( ::T $a ) { }
_END_
				my $parsed = $pt.parse-source( $source );
				my $tree = $pt.build-tree( $parsed );
				ok $pt.validate( $parsed ), Q{valid};
				is $pt.format( $tree ), $source, Q{formatted};
			}, Q{type-capture};

			subtest {
				plan 2;

				my $source = Q:to[_END_];
sub foo( Str ) { }
_END_
				my $parsed = $pt.parse-source( $source );
				my $tree = $pt.build-tree( $parsed );
				ok $pt.validate( $parsed ), Q{valid};
				is $pt.format( $tree ), $source, Q{formatted};
			}, Q{type-only};

			subtest {
				plan 2;

				my $source = Q:to[_END_];
sub foo( Str $a where "foo" ) { }
_END_
				my $parsed = $pt.parse-source( $source );
				my $tree = $pt.build-tree( $parsed );
				ok $pt.validate( $parsed ), Q{valid};
				is $pt.format( $tree ), $source, Q{formatted};
			}, Q{type-constrained};
		}, Q{typed};

		subtest {
			plan 2;

			my $source = Q:to[_END_];
sub foo( $a = 0 ) { }
_END_
			my $parsed = $pt.parse-source( $source );
			my $tree = $pt.build-tree( $parsed );
			ok $pt.validate( $parsed ), Q{valid};
			is $pt.format( $tree ), $source, Q{formatted};
		}, Q{default};

		subtest {
			plan 2;

			my $source = Q:to[_END_];
sub foo( :$a ) { }
_END_
			my $parsed = $pt.parse-source( $source );
			my $tree = $pt.build-tree( $parsed );
			ok $pt.validate( $parsed ), Q{valid};
			is $pt.format( $tree ), $source, Q{formatted};
		}, Q{optional};
	}, Q{single};

	subtest {
		plan 2;

		my $source = Q:to[_END_];
sub foo( $a, $b ) { }
_END_
		my $parsed = $pt.parse-source( $source );
		my $tree = $pt.build-tree( $parsed );
		ok $pt.validate( $parsed ), Q{valid};
		is $pt.format( $tree ), $source, Q{formatted};
	}, Q{multiple};
}, Q{scalar arguments};

# vim: ft=perl6
