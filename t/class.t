use v6;

use Test;
use Perl6::Tidy;

plan 3;

my $pt = Perl6::Tidy.new;
#my $*TRACE = 1;
#my $*DEBUG = 1;

subtest {
	plan 1;

	my $parsed = $pt.get-tree( Q[class Unqualified { }] );
	isa-ok $parsed, Q{Perl6::Document};
}, Q{empty};

subtest {
	plan 2;

	subtest {
		plan 1;

		my $parsed =
			$pt.get-tree( Q[class Unqualified { method foo { } }] );
		isa-ok $parsed, Q{Perl6::Document};
	}, Q{single};

	subtest {
		plan 1;

		my $parsed =
			$pt.get-tree( Q:to[_END_] );
class Unqualified {
	method foo { }
	method bar { }
}
_END_
		isa-ok $parsed, Q{Perl6::Document};
	}, Q{multiple};
}, Q{method};

subtest {
	plan 4;

	subtest {
		plan 3;

		subtest {
			plan 1;

			my $parsed = $pt.get-tree( Q[class Unqualified { has $.a }] );
			isa-ok $parsed, Q{Perl6::Document};
		}, Q{single};

		subtest {
			plan 1;

			my $parsed = $pt.get-tree( Q:to[_END_] );
class Unqualified {
	has $.a;
	has $.b;
}
_END_
			isa-ok $parsed, Q{Perl6::Document};
		}, Q{multiple};

		subtest {
			plan 1;

			my $parsed = $pt.get-tree( Q:to[_END_] );
class Unqualified { has ( $.a, $.b ) }
_END_
			isa-ok $parsed, Q{Perl6::Document};
		}, Q{list};
	}, Q{$};

	subtest {
		plan 1;

		my $parsed = $pt.get-tree( Q[class Unqualified { has @.a }] );
		isa-ok $parsed, Q{Perl6::Document};
	}, Q{@};

	subtest {
		plan 1;

		my $parsed = $pt.get-tree( Q[class Unqualified { has %.a }] );
		isa-ok $parsed, Q{Perl6::Document};
	}, Q{%};

	subtest {
		plan 1;

		my $parsed = $pt.get-tree( Q[class Unqualified { has &.a }] );
		isa-ok $parsed, Q{Perl6::Document};
	}, Q{&};
}, Q{Attribute};

# vim: ft=perl6
