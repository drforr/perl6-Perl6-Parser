use v6;

use Test;
use Perl6::Tidy;

plan 2;

my $pt = Perl6::Tidy.new;

subtest {
	plan 1;

	my $parsed = $pt.tidy( Q[sub unqualified { }] );
	isa-ok $parsed, Q{Perl6::Tidy::Root};
}, Q{empty};

subtest {
	plan 2;

	subtest {
		plan 5;

		subtest {
			plan 1;

			my $parsed = $pt.tidy( Q[sub unqualified( 0 ) { }] );
			isa-ok $parsed, Q{Perl6::Tidy::Root};
		}, Q{constant};

		subtest {
			plan 1;

			my $parsed = $pt.tidy( Q[sub unqualified( $a ) { }] );
			isa-ok $parsed, Q{Perl6::Tidy::Root};
		}, Q{untyped};

		subtest {
			plan 4;

			subtest {
				plan 1;

				my $parsed = $pt.tidy( Q:to[_END_] );
sub unqualified( Str $a ) { }
_END_
				isa-ok $parsed, Q{Perl6::Tidy::Root};
			}, Q{typed};

			subtest {
				plan 1;

				my $parsed = $pt.tidy( Q:to[_END_] );
sub unqualified( ::T $a ) { }
_END_
				isa-ok $parsed, Q{Perl6::Tidy::Root};
			}, Q{type-capture};

			subtest {
				plan 1;

				my $parsed = $pt.tidy( Q:to[_END_] );
sub unqualified( Str ) { }
_END_
				isa-ok $parsed, Q{Perl6::Tidy::Root};
			}, Q{type-only};

			subtest {
				plan 1;

				my $parsed = $pt.tidy( Q:to[_END_] );
sub unqualified( Str $a where "foo" ) { }
_END_
				isa-ok $parsed, Q{Perl6::Tidy::Root};
			}, Q{type-constrained};
		}, Q{typed};

		subtest {
			plan 1;

			my $parsed = $pt.tidy( Q:to[_END_] );
sub unqualified( $a = 0 ) { }
_END_
			isa-ok $parsed, Q{Perl6::Tidy::Root};
		}, Q{default};

		subtest {
			plan 1;

			my $parsed = $pt.tidy( Q:to[_END_] );
sub unqualified( :$a ) { }
_END_
			isa-ok $parsed, Q{Perl6::Tidy::Root};
		}, Q{optional};
	}, Q{single};

	subtest {
		plan 1;

		my $parsed = $pt.tidy( Q[sub unqualified( $a, $b ) { }] );
		isa-ok $parsed, Q{Perl6::Tidy::Root};
	}, Q{multiple};
}, Q{scalar arguments};

# vim: ft=perl6
