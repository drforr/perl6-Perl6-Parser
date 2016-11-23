use v6;

use Test;
use Perl6::Parser;

plan 2;

my $pt = Perl6::Parser.new;
my $*VALIDATION-FAILURE-FATAL = True;
my $*FACTORY-FAILURE-FATAL = True;
my $*DEBUG = True;

subtest {
	plan 2;

	subtest {
		plan 3;

		subtest {
			plan 2;

			my $p = $pt.parse( Q{my Int $a} );
			my $tree = $pt.build-tree( $p );
			ok $pt.validate( $p ), Q{valid};
			is $pt.to-string( $tree ), Q{my Int $a}, Q{formatted};
		}, Q{regular};

		subtest {
			plan 2;

			my $p = $pt.parse( Q{my Int:U $a} );
			my $tree = $pt.build-tree( $p );
			ok $pt.validate( $p ), Q{valid};
			is $pt.to-string( $tree ), Q{my Int:U $a}, Q{formatted};
		}, Q{undefined};

		subtest {
			plan 2;

			my $p = $pt.parse( Q{my Int:D $a = 0} );
			my $tree = $pt.build-tree( $p );
			ok $pt.validate( $p ), Q{valid};
			is $pt.to-string( $tree ),
				Q{my Int:D $a = 0},
				Q{formatted};
		}, Q{defined};
	}, Q{typed};

	subtest {
		plan 1;

		subtest {
			plan 2;

			my $p = $pt.parse( Q{my $a where 1} );
			my $tree = $pt.build-tree( $p );
			ok $pt.validate( $p ), Q{valid};
			is $pt.to-string( $tree ), Q{my $a where 1}, Q{formatted};
		}, Q{my $a where 1};
	}, Q{constrained};
}, Q{variable};

subtest {
	plan 1;

	subtest {
		plan 2;

		subtest {
			plan 2;

			my $source = Q{sub foo returns Int {}};
			my $p = $pt.parse( $source );
			my $tree = $pt.build-tree( $p );
			ok $pt.validate( $p ), Q{valid};
			is $pt.to-string( $tree ), $source, Q{formatted};
		}, Q{ws};
		subtest {
			plan 2;

			my $source = Q:to[_END_];
sub foo returns Int {}
_END_
			my $p = $pt.parse( $source );
			my $tree = $pt.build-tree( $p );
			ok $pt.validate( $p ), Q{valid};
			is $pt.to-string( $tree ), $source, Q{formatted};
		}, Q{ws};
	}, Q{sub foo returns Int {}};
}, Q{subroutine};

# vim: ft=perl6
