use v6;

use Test;
use Perl6::Tidy;

plan 3;

my $pt = Perl6::Tidy.new;
#my $*TRACE = 1;
#my $*DEBUG = 1;

subtest {
	plan 3;

	subtest {
		plan 3;

		subtest {
			plan 2;

			my $parsed = $pt.parse-source( Q{my $a} );
			my $tree = $pt.build-tree( $parsed );
			ok $pt.validate( $parsed ), Q{valid};
			is $pt.format( $tree ), Q{my $a}, Q{formatted};
		}, Q{my $a};

		subtest {
			plan 2;

			my $parsed = $pt.parse-source( Q{our $a} );
			my $tree = $pt.build-tree( $parsed );
			ok $pt.validate( $parsed ), Q{valid};
			is $pt.format( $tree ), Q{our $a}, Q{formatted};
		}, Q{our $a};

		todo Q{'anon $a' not implemented yet, maybe not ever.};

		subtest {
			plan 2;

			my $parsed = $pt.parse-source( Q{state $a} );
			my $tree = $pt.build-tree( $parsed );
			ok $pt.validate( $parsed ), Q{valid};
			is $pt.format( $tree ), Q{state $a}, Q{formatted};
		}, Q{state $a};

		todo Q{'augment $a' not implemented yet, maybe not ever.};

		todo Q{'supersede $a' not implemented yet, maybe not ever.};
	}, Q{untyped};

	subtest {
		plan 3;

		subtest {
			plan 2;

			my $parsed = $pt.parse-source( Q{my Int $a} );
			my $tree = $pt.build-tree( $parsed );
			ok $pt.validate( $parsed ), Q{valid};
			is $pt.format( $tree ), Q{my Int $a}, Q{formatted};
		}, Q{regular};

		subtest {
			plan 2;

			my $parsed = $pt.parse-source( Q{my Int:D $a = 0} );
			my $tree = $pt.build-tree( $parsed );
			ok $pt.validate( $parsed ), Q{valid};
			is $pt.format( $tree ),
				Q{my Int:D $a = 0},
				Q{formatted};
		}, Q{defined};

		subtest {
			plan 2;

			my $parsed = $pt.parse-source( Q{my Int:U $a} );
			my $tree = $pt.build-tree( $parsed );
			ok $pt.validate( $parsed ), Q{valid};
			is $pt.format( $tree ), Q{my Int:U $a}, Q{formatted};
		}, Q{undefined};
	}, Q{typed};

	subtest {
		plan 1;

		subtest {
			plan 2;

			my $parsed = $pt.parse-source( Q{my $a where 1} );
			my $tree = $pt.build-tree( $parsed );
			ok $pt.validate( $parsed ), Q{valid};
			is $pt.format( $tree ), Q{my $a where 1}, Q{formatted};
		}, Q{my $a where 1};
	}, Q{constrained};
}, Q{variable};

subtest {
	plan 2;

	subtest {
		plan 2;

		my $parsed = $pt.parse-source( Q[sub foo {}] );
		my $tree = $pt.build-tree( $parsed );
		ok $pt.validate( $parsed ), Q{valid};
		is $pt.format( $tree ), Q[sub foo {}], Q{formatted};
	}, Q{sub foo {}};

	subtest {
		plan 2;

		my $parsed = $pt.parse-source( Q:to[_END_].chomp );
sub foo returns Int {}
_END_
		my $tree = $pt.build-tree( $parsed );
		ok $pt.validate( $parsed ), Q{valid};
		is $pt.format( $tree ), Q:to[_END_].chomp, Q{formatted};
sub foo returns Int {}
_END_
	}, Q{sub foo returns Int {}};
}, Q{subroutine};

subtest {
	plan 7;

	subtest {
		plan 2;

		subtest {
			plan 2;

			my $parsed = $pt.parse-source( Q:to[_END_].chomp );
unit module foo;
_END_
			my $tree = $pt.build-tree( $parsed );
			ok $pt.validate( $parsed ), Q{valid};
#			is $pt.format( $tree ), Q:to[_END_], Q{formatted};
#unit module foo;
#_END_
			is $pt.format( $tree ), Q:to[_END_].chomp, Q{formatted};
unit module foo;
_END_
		}, Q{unit module foo;};

		subtest {
			plan 2;

			my $parsed = $pt.parse-source( Q:to[_END_].chomp );
module foo { }
_END_
			my $tree = $pt.build-tree( $parsed );
			ok $pt.validate( $parsed ), Q{valid};
#			is $pt.format( $tree ), Q:to[_END_], Q{formatted};
#module foo { }
#_END_
			is $pt.format( $tree ), Q:to[_END_].chomp, Q{formatted};
modulefoo {}
_END_
		}, Q{module foo {}};
	}, q{module};

	subtest {
		plan 2;

		subtest {
			plan 2;

			my $parsed = $pt.parse-source( Q:to[_END_].chomp );
unit class foo;
_END_
			my $tree = $pt.build-tree( $parsed );
			ok $pt.validate( $parsed ), Q{valid};
#			is $pt.format( $tree ), Q:to[_END_], Q{formatted};
#unit class foo;
#_END_
			is $pt.format( $tree ), Q:to[_END_].chomp, Q{formatted};
unit class foo;
_END_
		}, Q{unit class foo;};

		subtest {
			plan 2;

			my $parsed = $pt.parse-source( Q:to[_END_].chomp );
class foo { }
_END_
			my $tree = $pt.build-tree( $parsed );
			ok $pt.validate( $parsed ), Q{valid};
#			is $pt.format( $tree ), Q:to[_END_], Q{formatted};
#class foo { }
#_END_
			is $pt.format( $tree ), Q:to[_END_].chomp, Q{formatted};
classfoo {}
_END_
		}, Q{class foo {}};
	}, Q{class};

	subtest {
		plan 2;

		subtest {
			plan 2;

			my $parsed = $pt.parse-source( Q:to[_END_].chomp );
unit role foo;
_END_
			my $tree = $pt.build-tree( $parsed );
			ok $pt.validate( $parsed ), Q{valid};
#			is $pt.format( $tree ), Q:to[_END_], Q{formatted};
#unit role foo;
#_END_
			is $pt.format( $tree ), Q:to[_END_].chomp, Q{formatted};
unit role foo;
_END_
		}, Q{unit role foo;};

		subtest {
			plan 2;

			my $parsed = $pt.parse-source( Q:to[_END_].chomp );
role foo { }
_END_
			my $tree = $pt.build-tree( $parsed );
			ok $pt.validate( $parsed ), Q{valid};
#			is $pt.format( $tree ), Q:to[_END_], Q{formatted};
#role foo { }
#_END_
			is $pt.format( $tree ), Q:to[_END_].chomp, Q{formatted};
rolefoo {}
_END_
		}, Q{role foo {}};
	}, Q{role};

	subtest {
		plan 2;

		my $parsed = $pt.parse-source( Q:to[_END_].chomp );
my regex foo { a }
_END_
		my $tree = $pt.build-tree( $parsed );
		ok $pt.validate( $parsed ), Q{valid};
#		is $pt.format( $tree ), Q:to[_END_], Q{formatted};
#my regex foo { a }
#_END_
		is $pt.format( $tree ), Q:to[_END_].chomp, Q{formatted};
my regex foo {a}
_END_
	}, Q{my regex foo {a} (null regex not allowed)};

	subtest {
		plan 2;

		subtest {
			plan 2;

			my $parsed = $pt.parse-source( Q:to[_END_].chomp );
unit grammar foo;
_END_
			my $tree = $pt.build-tree( $parsed );
			ok $pt.validate( $parsed ), Q{valid};
#			is $pt.format( $tree ), Q:to[_END_], Q{formatted};
#unit grammar foo;
#_END_
			is $pt.format( $tree ), Q:to[_END_].chomp, Q{formatted};
unit grammar foo;
_END_
		}, Q{unit grammar foo;};

		subtest {
			plan 2;

			my $parsed = $pt.parse-source( Q:to[_END_].chomp );
grammar foo { }
_END_
			my $tree = $pt.build-tree( $parsed );
			ok $pt.validate( $parsed ), Q{valid};
#			is $pt.format( $tree ), Q:to[_END_], Q{formatted};
#grammar foo { }
#_END_
			is $pt.format( $tree ), Q:to[_END_].chomp, Q{formatted};
grammarfoo {}
_END_
		}, Q{grammar foo {}};
	}, Q{grammar};

	subtest {
		plan 2;

		my $parsed = $pt.parse-source( Q:to[_END_].chomp );
my token foo { a }
_END_
		my $tree = $pt.build-tree( $parsed );
		ok $pt.validate( $parsed ), Q{valid};
#		is $pt.format( $tree ), Q:to[_END_].chomp, Q{formatted};
#my token foo { a }
#_END_
		is $pt.format( $tree ), Q:to[_END_].chomp, Q{formatted};
my token foo {a}
_END_
	}, Q{my token foo {a} (null regex not allowed, must give it content.)};

	subtest {
		plan 2;

		my $parsed = $pt.parse-source( Q:to[_END_].chomp );
my rule foo { a }
_END_
		my $tree = $pt.build-tree( $parsed );
		ok $pt.validate( $parsed ), Q{valid};
#		is $pt.format( $tree ), Q:to[_END_].chomp, Q{formatted};
#my rule foo { a }
#_END_
		is $pt.format( $tree ), Q:to[_END_].chomp, Q{formatted};
my rule foo {a}
_END_
	}, Q{my rule foo {a}};
}, Q{braced things};

# vim: ft=perl6
