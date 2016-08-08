use v6;

use Test;
use Perl6::Tidy;

plan 3;

my $pt = Perl6::Tidy.new;
#my $*TRACE = 1;
#my $*DEBUG = 1;

subtest {
	plan 2;

	my $parsed = $pt.parse-source( Q:to[_END_].chomp );
class Unqualified { }
_END_
	my $tree = $pt.build-tree( $parsed );
	ok $pt.validate( $parsed ), Q{valid};
#	is $pt.format( $tree ), Q:to[_END_], Q{formatted};
#class Unqualified { }
#_END_
	is $pt.format( $tree ), Q{classUnqualified{}}, Q{formatted};
}, Q{empty};

subtest {
	plan 2;

	subtest {
		plan 2;

		my $parsed = $pt.parse-source( Q:to[_END_].chomp );
class Unqualified { method foo { } }
_END_
		my $tree = $pt.build-tree( $parsed );
		ok $pt.validate( $parsed ), Q{valid};
#		is $pt.format( $tree ), Q:to[_END_], Q{formatted};
#class Unqualified { method foo { } }
#_END_
		is $pt.format( $tree ),
			Q{classUnqualified{methodfoo{}}},
			Q{formatted};
	}, Q{single};

	subtest {
		plan 2;

		my $parsed = $pt.parse-source( Q:to[_END_].chomp );
class Unqualified {
	method foo { }
	method bar { }
}
_END_
		my $tree = $pt.build-tree( $parsed );
		ok $pt.validate( $parsed ), Q{valid};
#		is $pt.format( $tree ), Q:to[_END_], Q{formatted};
#class Unqualified {
#	method foo { }
#	method bar { }
#}
#_END_
		is $pt.format( $tree ),
			Q{classUnqualified{methodfoo{}methodbar{}}},
			Q{formatted};
	}, Q{multiple};
}, Q{method};

subtest {
	plan 4;

	subtest {
		plan 3;

		subtest {
			plan 2;

			my $parsed = $pt.parse-source( Q:to[_END_].chomp );
class Unqualified { has $.a }
_END_
			my $tree = $pt.build-tree( $parsed );
			ok $pt.validate( $parsed ), Q{valid};
#			is $pt.format( $tree ),
#				Q{class Unqualified { has $.a }}, Q{formatted};
			is $pt.format( $tree ),
				Q{classUnqualified{has$.a}}, Q{formatted};
		}, Q{single};

		subtest {
			plan 2;

			my $parsed = $pt.parse-source( Q:to[_END_].chomp );
class Unqualified {
	has $.a;
	has $.b;
}
_END_
			my $tree = $pt.build-tree( $parsed );
			ok $pt.validate( $parsed ), Q{valid};
#			is $pt.format( $tree ), Q:to[_END_], Q{formatted};
#class Unqualified {
#	has $.a;
#	has $.b;
#}
#_END_
			is $pt.format( $tree ), Q{classUnqualified{has$.a;has$.b;}}, Q{formatted};
		}, Q{multiple};

		subtest {
			plan 2;

			my $parsed = $pt.parse-source( Q:to[_END_].chomp );
class Unqualified { has ( $.a, $.b ) }
_END_
			my $tree = $pt.build-tree( $parsed );
			ok $pt.validate( $parsed ), Q{valid};
#			is $pt.format( $tree ),
#				Q{class Unqualified { has ( $.a, $.b ) }},
#				Q{formatted};
			is $pt.format( $tree ),
				Q{classUnqualified{has($.a,$.b)}},
				Q{formatted};
		}, Q{list};
	}, Q{$};

	subtest {
		plan 2;

		my $parsed = $pt.parse-source( Q:to[_END_].chomp );
class Unqualified { has @.a }
_END_
		my $tree = $pt.build-tree( $parsed );
		ok $pt.validate( $parsed ), Q{valid};
#		is $pt.format( $tree ), Q{class Unqualified { has @.a }},
#			Q{formatted};
		is $pt.format( $tree ), Q{classUnqualified{has@.a}},
			Q{formatted};
	}, Q{@};

	subtest {
		plan 2;

		my $parsed = $pt.parse-source( Q:to[_END_].chomp );
class Unqualified { has %.a }
_END_
		my $tree = $pt.build-tree( $parsed );
		ok $pt.validate( $parsed ), Q{valid};
#		is $pt.format( $tree ), Q{class Unqualified { has %.a }},
#			Q{formatted};
		is $pt.format( $tree ), Q{classUnqualified{has%.a}},
			Q{formatted};
	}, Q{%};

	subtest {
		plan 2;

		my $parsed = $pt.parse-source( Q:to[_END_] );
class Unqualified { has &.a }
_END_
		my $tree = $pt.build-tree( $parsed );
		ok $pt.validate( $parsed ), Q{valid};
#		is $pt.format( $tree ), Q{class Unqualified { has &.a }},
#			Q{formatted};
		is $pt.format( $tree ), Q{classUnqualified{has&.a}},
			Q{formatted};
	}, Q{&};
}, Q{Attribute};

# vim: ft=perl6
