use v6;

use Test;
use Perl6::Tidy;

plan 3;

my $pt = Perl6::Tidy.new;
#my $*TRACE = 1;
#my $*DEBUG = 1;

subtest {
	plan 1;

	my $parsed = $pt.parse-source( Q[class Unqualified { }] );
	ok $pt.validate( $parsed );
}, Q{empty};

subtest {
	plan 2;

	subtest {
		plan 1;

		my $parsed = $pt.parse-source( Q:to[_END_] );
class Unqualified { method foo { } }
_END_
		ok $pt.validate( $parsed );
	}, Q{single};

	subtest {
		plan 1;

		my $parsed = $pt.parse-source( Q:to[_END_] );
class Unqualified {
	method foo { }
	method bar { }
}
_END_
		ok $pt.validate( $parsed );
	}, Q{multiple};
}, Q{method};

subtest {
	plan 4;

	subtest {
		plan 3;

		subtest {
			plan 1;

			my $parsed = $pt.parse-source( Q:to[_END_] );
class Unqualified { has $.a }
_END_
			ok $pt.validate( $parsed );
		}, Q{single};

		subtest {
			plan 1;

			my $parsed = $pt.parse-source( Q:to[_END_] );
class Unqualified {
	has $.a;
	has $.b;
}
_END_
			ok $pt.validate( $parsed );
		}, Q{multiple};

		subtest {
			plan 1;

			my $parsed = $pt.parse-source( Q:to[_END_] );
class Unqualified { has ( $.a, $.b ) }
_END_
			ok $pt.validate( $parsed );
		}, Q{list};
	}, Q{$};

	subtest {
		plan 1;

		my $parsed = $pt.parse-source( Q:to[_END_] );
class Unqualified { has @.a }
_END_
		ok $pt.validate( $parsed );
	}, Q{@};

	subtest {
		plan 1;

		my $parsed = $pt.parse-source( Q:to[_END_] );
class Unqualified { has %.a }
_END_
		ok $pt.validate( $parsed );
	}, Q{%};

	subtest {
		plan 1;

		my $parsed = $pt.parse-source( Q:to[_END_] );
class Unqualified { has &.a }
_END_
		ok $pt.validate( $parsed );
	}, Q{&};
}, Q{Attribute};

# vim: ft=perl6
