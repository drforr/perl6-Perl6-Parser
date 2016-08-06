use v6;

use Test;
use Perl6::Tidy;

plan 2;

my $pt = Perl6::Tidy.new;
#my $*TRACE = 1;
#my $*DEBUG = 1;

subtest {
	plan 1;

	my $parsed = $pt.parse-source( Q[sub foo { }] );
	ok $pt.validate( $parsed );
}, Q{empty};

subtest {
	plan 2;

	subtest {
		plan 6;

		subtest {
			plan 1;

			my $parsed = $pt.parse-source( Q:to[_END_] );
sub foo( ) { }
_END_
			ok $pt.validate( $parsed );
		}, Q{empty};

		subtest {
			plan 1;

			my $parsed = $pt.parse-source( Q:to[_END_] );
sub foo( 0 ) { }
_END_
			ok $pt.validate( $parsed );
		}, Q{constant};

		subtest {
			plan 1;

			my $parsed = $pt.parse-source( Q:to[_END_] );
sub foo( $a ) { }
_END_
			ok $pt.validate( $parsed );
		}, Q{untyped};

		subtest {
			plan 4;

			subtest {
				plan 1;

				my $parsed = $pt.parse-source( Q:to[_END_] );
sub foo( Str $a ) { }
_END_
				ok $pt.validate( $parsed );
			}, Q{typed};

			subtest {
				plan 1;

				my $parsed = $pt.parse-source( Q:to[_END_] );
sub foo( ::T $a ) { }
_END_
				ok $pt.validate( $parsed );
			}, Q{type-capture};

			subtest {
				plan 1;

				my $parsed = $pt.parse-source( Q:to[_END_] );
sub foo( Str ) { }
_END_
				ok $pt.validate( $parsed );
			}, Q{type-only};

			subtest {
				plan 1;

				my $parsed = $pt.parse-source( Q:to[_END_] );
sub foo( Str $a where "foo" ) { }
_END_
				ok $pt.validate( $parsed );
			}, Q{type-constrained};
		}, Q{typed};

		subtest {
			plan 1;

			my $parsed = $pt.parse-source( Q:to[_END_] );
sub foo( $a = 0 ) { }
_END_
			ok $pt.validate( $parsed );
		}, Q{default};

		subtest {
			plan 1;

			my $parsed = $pt.parse-source( Q:to[_END_] );
sub foo( :$a ) { }
_END_
			ok $pt.validate( $parsed );
		}, Q{optional};
	}, Q{single};

	subtest {
		plan 1;

		my $parsed = $pt.parse-source( Q:to[_END_] );
sub foo( $a, $b ) { }
_END_
		ok $pt.validate( $parsed );
	}, Q{multiple};
}, Q{scalar arguments};

# vim: ft=perl6
