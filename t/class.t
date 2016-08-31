use v6;

use Test;
use Perl6::Tidy;

#`(

In passing, please note that while it's trivially possible to bum down the
tests, doing so makes it harder to insert 'say $parsed.dump' to view the
AST, and 'say $tree.perl' to view the generated Perl 6 structure.

)

plan 4;

my $pt = Perl6::Tidy.new;
#my $*TRACE = 1;
#my $*DEBUG = 1;

subtest {
	plan 3;

	subtest {
		plan 2;

		my $source = Q:to[_END_].chomp;
class Unqualified{}
_END_
		my $parsed = $pt.parse-source( $source );
		my $tree = $pt.build-tree( $parsed );
		ok $pt.validate( $parsed ), Q{valid};
		is $pt.format( $tree ), $source, Q{formatted};
	}, Q{no ws};

	subtest {
		plan 2;

		my $source = Q:to[_END_];
class Unqualified { }
_END_
		my $parsed = $pt.parse-source( $source );
		my $tree = $pt.build-tree( $parsed );
		ok $pt.validate( $parsed ), Q{valid};
		is $pt.format( $tree ), $source, Q{formatted};
	}, Q{with ws};

	subtest {
		plan 2;

		my $source = Q[class Unqualified  { } ];
		my $parsed = $pt.parse-source( $source );
		my $tree = $pt.build-tree( $parsed );
		ok $pt.validate( $parsed ), Q{valid};
		is $pt.format( $tree ), $source, Q{formatted};
	}, Q{with leading, trailing ws};
}, Q{empty};

subtest {
	plan 3;

	subtest {
		plan 2;

		my $source = Q:to[_END_].chomp;
class Qual::Ified{}
_END_
		my $parsed = $pt.parse-source( $source );
		my $tree = $pt.build-tree( $parsed );
		ok $pt.validate( $parsed ), Q{valid};
		is $pt.format( $tree ), $source, Q{formatted};
	}, Q{no ws};

	subtest {
		plan 2;

		my $source = Q:to[_END_];
class Qual::Ified { }
_END_
		my $parsed = $pt.parse-source( $source );
		my $tree = $pt.build-tree( $parsed );
		ok $pt.validate( $parsed ), Q{valid};
		is $pt.format( $tree ), $source, Q{formatted};
	}, Q{with ws};

	subtest {
		plan 2;

		my $source = Q[class Qual::Ified  { } ];
		my $parsed = $pt.parse-source( $source );
		my $tree = $pt.build-tree( $parsed );
		ok $pt.validate( $parsed ), Q{valid};
		is $pt.format( $tree ), $source, Q{formatted};
	}, Q{with leading, trailing ws (but no NL)};
}, Q{empty};

subtest {
	plan 0;

	subtest {
		plan 2;

		my $source = Q:to[_END_];
class Unqualified { method foo { } }
_END_
		my $parsed = $pt.parse-source( $source );
		my $tree = $pt.build-tree( $parsed );
		ok $pt.validate( $parsed ), Q{valid};
		is $pt.format( $tree ), $source, Q{formatted};
	}, Q{single};

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

#`(
subtest {
	plan 4;

	subtest {
		plan 4;

		subtest {
			plan 2;

			my $source = Q:to[_END_];
class Unqualified{has$.a}
_END_
			my $parsed = $pt.parse-source( $source );
			my $tree = $pt.build-tree( $parsed );
			ok $pt.validate( $parsed ), Q{valid};
			is $pt.format( $tree ), $source, Q{formatted};
		}, Q{single, no WS};

		subtest {
			plan 2;

			my $source = Q:to[_END_];
class Unqualified { has $.a }
_END_
			my $parsed = $pt.parse-source( $source );
			my $tree = $pt.build-tree( $parsed );
			ok $pt.validate( $parsed ), Q{valid};
			is $pt.format( $tree ), $source, Q{formatted};
		}, Q{single};

		subtest {
			plan 2;

			my $source = Q:to[_END_];
class Unqualified {
	has $.a;
	has $.b;
}
_END_
			my $parsed = $pt.parse-source( $source );
			my $tree = $pt.build-tree( $parsed );
			ok $pt.validate( $parsed ), Q{valid};
			is $pt.format( $tree ), $source, Q{formatted};
		}, Q{multiple};

		subtest {
			plan 2;

			my $source = Q:to[_END_];
class Unqualified { has ( $.a, $.b ) }
_END_
			my $parsed = $pt.parse-source( $source );
			my $tree = $pt.build-tree( $parsed );
			ok $pt.validate( $parsed ), Q{valid};
			is $pt.format( $tree ), $source, Q{formatted};
		}, Q{list};
	}, Q{$};

	subtest {
		plan 2;

		my $source = Q:to[_END_];
class Unqualified { has @.a }
_END_
		my $parsed = $pt.parse-source( $source );
		my $tree = $pt.build-tree( $parsed );
		ok $pt.validate( $parsed ), Q{valid};
		is $pt.format( $tree ), $source, Q{formatted};
	}, Q{@};

	subtest {
		plan 2;

		my $source = Q:to[_END_];
class Unqualified { has %.a }
_END_
		my $parsed = $pt.parse-source( $source );
		my $tree = $pt.build-tree( $parsed );
		ok $pt.validate( $parsed ), Q{valid};
		is $pt.format( $tree ), $source, Q{formatted};
	}, Q{%};

	subtest {
		plan 3;

		my $source = Q:to[_END_];
class Unqualified { has &.a }
_END_
		my $parsed = $pt.parse-source( $source );
		my $tree = $pt.build-tree( $parsed );
		ok $pt.validate( $parsed ), Q{valid};
		is $pt.format( $tree ), $source, Q{formatted};
	}, Q{&};
}, Q{Attribute};
)

# vim: ft=perl6
