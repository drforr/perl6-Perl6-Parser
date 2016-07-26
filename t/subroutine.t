use v6;

use Test;
use Perl6::Tidy;

plan 2;

my $pt = Perl6::Tidy.new;
my $*TRACE = 1;
my $*DEBUG = 1;

subtest {
	plan 1;

	my $parsed = $pt.tidy( Q[sub foo { }] );
	isa-ok $parsed, Q{Perl6::Tidy::Root};
}, Q{empty};

subtest {
	plan 2;

	subtest {
		plan 5;

		subtest {
			plan 1;

			my $parsed = $pt.tidy( Q:to[_END_] );
sub foo( 0 ) { }
_END_
			isa-ok $parsed, Q{Perl6::Tidy::Root};
		}, Q{constant};

		subtest {
			plan 1;

			my $parsed = $pt.tidy( Q:to[_END_] );
sub foo( $a ) { }
_END_
			isa-ok $parsed, Q{Perl6::Tidy::Root};
		}, Q{untyped};

		subtest {
			plan 4;

			subtest {
				plan 1;

				my $parsed = $pt.tidy( Q:to[_END_] );
sub foo( Str $a ) { }
_END_
				isa-ok $parsed, Q{Perl6::Tidy::Root};
			}, Q{typed};

			subtest {
				plan 1;

				my $parsed = $pt.tidy( Q:to[_END_] );
sub foo( ::T $a ) { }
_END_
				isa-ok $parsed, Q{Perl6::Tidy::Root};
			}, Q{type-capture};

			subtest {
				plan 1;

				my $parsed = $pt.tidy( Q:to[_END_] );
sub foo( Str ) { }
_END_
				isa-ok $parsed, Q{Perl6::Tidy::Root};
			}, Q{type-only};

			subtest {
				plan 1;

				my $parsed = $pt.tidy( Q:to[_END_] );
sub foo( Str $a where "foo" ) { }
_END_
				isa-ok $parsed, Q{Perl6::Tidy::Root};
			}, Q{type-constrained};
		}, Q{typed};

		subtest {
			plan 1;

			my $parsed = $pt.tidy( Q:to[_END_] );
sub foo( $a = 0 ) { }
_END_
			isa-ok $parsed, Q{Perl6::Tidy::Root};
		}, Q{default};

		subtest {
			plan 1;

			my $parsed = $pt.tidy( Q:to[_END_] );
sub foo( :$a ) { }
_END_
			isa-ok $parsed, Q{Perl6::Tidy::Root};
		}, Q{optional};
	}, Q{single};

	subtest {
		plan 1;

		my $parsed = $pt.tidy( Q:to[_END_] );
sub foo( $a, $b ) { }
_END_
		isa-ok $parsed, Q{Perl6::Tidy::Root};
	}, Q{multiple};
}, Q{scalar arguments};

# vim: ft=perl6
