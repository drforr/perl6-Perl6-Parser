use v6;

use Test;
use Perl6::Tidy;

plan 3;

my $pt = Perl6::Tidy.new;

subtest {
	plan 1;

	my $parsed = $pt.tidy( Q[class Unqualified { }] );
	isa-ok $parsed, Q{Root};
}, Q{empty};

subtest {
	plan 2;

	subtest {
		plan 1;

		my $parsed =
			$pt.tidy( Q[class Unqualified { method foo { } }] );
		isa-ok $parsed, Q{Root};
	}, Q{single};

	subtest {
		plan 1;

		my $parsed =
			$pt.tidy( Q:to[_END_] );
class Unqualified {
	method foo { }
	method bar { }
}
_END_
		isa-ok $parsed, Q{Root};
	}, Q{multiple};
}, Q{method};

subtest {
	plan 4;

	subtest {
		plan 3;

		subtest {
			plan 1;

			my $parsed = $pt.tidy( Q[class Unqualified { has $.a }] );
			isa-ok $parsed, Q{Root};
		}, Q{single};

		subtest {
			plan 1;

			my $parsed = $pt.tidy( Q:to[_END_] );
class Unqualified {
	has $.a;
	has $.b;
}
_END_
			isa-ok $parsed, Q{Root};
		}, Q{multiple};

		subtest {
			plan 1;

			my $parsed = $pt.tidy( Q:to[_END_] );
class Unqualified { has ( $.a, $.b ) }
_END_
			isa-ok $parsed, Q{Root};
		}, Q{list};
	}, Q{$};

	subtest {
		plan 1;

		my $parsed = $pt.tidy( Q[class Unqualified { has @.a }] );
		isa-ok $parsed, Q{Root};
	}, Q{@};

	subtest {
		plan 1;

		my $parsed = $pt.tidy( Q[class Unqualified { has %.a }] );
		isa-ok $parsed, Q{Root};
	}, Q{%};

	subtest {
		plan 1;

		my $parsed = $pt.tidy( Q[class Unqualified { has &.a }] );
		isa-ok $parsed, Q{Root};
	}, Q{&};
}, Q{Attribute};

# vim: ft=perl6
