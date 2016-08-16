use v6;

use Test;
use Perl6::Tidy;

plan 4;

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
	is $pt.format( $tree ), Q:to[_END_].chomp, Q{formatted};
classUnqualified {}
_END_
}, Q{empty};

subtest {
	plan 2;

	my $parsed = $pt.parse-source( Q:to[_END_].chomp );
class Qual::Ified { }
_END_
	my $tree = $pt.build-tree( $parsed );
	ok $pt.validate( $parsed ), Q{valid};
#	is $pt.format( $tree ), Q:to[_END_], Q{formatted};
#class Qual::Ified { }
#_END_
	is $pt.format( $tree ), Q:to[_END_].chomp, Q{formatted};
classQual::Ified {}
_END_
}, Q{empty, multiple namespaces};

subtest {
	plan 0;

#	subtest {
#		plan 2;
#
#		my $parsed = $pt.parse-source( Q:to[_END_].chomp );
#class Unqualified { method foo { } }
#_END_
#		my $tree = $pt.build-tree( $parsed );
#		ok $pt.validate( $parsed ), Q{valid};
##		is $pt.format( $tree ), Q:to[_END_], Q{formatted};
##class Unqualified { method foo { } }
##_END_
#		is $pt.format( $tree ), Q:to[_END_].chomp, Q{formatted};
#classUnqualified{methodfoo{}}
#_END_
#	}, Q{single};

#	subtest {
#		plan 2;
#
#		my $parsed = $pt.parse-source( Q:to[_END_].chomp );
#class Unqualified {
#	method foo { }
#	method bar { }
#}
#_END_
#		my $tree = $pt.build-tree( $parsed );
#		ok $pt.validate( $parsed ), Q{valid};
##		is $pt.format( $tree ), Q:to[_END_], Q{formatted};
##class Unqualified {
##	method foo { }
##	method bar { }
##}
##_END_
#		is $pt.format( $tree ), Q:to[_END_].chomp, Q{formatted};
#classUnqualified{methodfoo{}methodbar{}}
#_END_
#	}, Q{multiple};
}, Q{method};

subtest {
	plan 4;

	subtest {
		plan 4;

		subtest {
			plan 2;

			my $parsed = $pt.parse-source( Q:to[_END_].chomp );
class Unqualified{has$.a}
_END_
			my $tree = $pt.build-tree( $parsed );
			ok $pt.validate( $parsed ), Q{valid};
#			is $pt.format( $tree ),
#				Q{class Unqualified{has$.a}}, Q{formatted};
			is $pt.format( $tree ),Q:to[_END_].chomp, Q{formatted};
classUnqualified{has$.a}
_END_
		}, Q{single, no WS};

		subtest {
			plan 2;

			my $parsed = $pt.parse-source( Q:to[_END_].chomp );
class Unqualified { has $.a }
_END_
			my $tree = $pt.build-tree( $parsed );
			ok $pt.validate( $parsed ), Q{valid};
#			is $pt.format( $tree ),
#				Q{class Unqualified { has $.a }}, Q{formatted};
			is $pt.format( $tree ),Q:to[_END_].chomp, Q{formatted};
classUnqualified {has $.a}
_END_
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
			is $pt.format( $tree ),Q:to[_END_].chomp, Q{formatted};
classUnqualified {has $.ahas $.b}
_END_
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
			is $pt.format( $tree ), Q:to[_END_].chomp, Q{formatted};
classUnqualified {has ($.a$.b)}
_END_
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
		is $pt.format( $tree ), Q:to[_END_].chomp, Q{formatted};
classUnqualified {has @.a}
_END_
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
		is $pt.format( $tree ), Q:to[_END_].chomp, Q{formatted};
classUnqualified {has %.a}
_END_
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
		is $pt.format( $tree ), Q:to[_END_].chomp, Q{formatted};
classUnqualified {has &.a}
_END_
	}, Q{&};
}, Q{Attribute};

# vim: ft=perl6
