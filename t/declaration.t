use v6;

use Test;
use Perl6::Tidy;

plan 2;

my $pt = Perl6::Tidy.new;
#my $*TRACE = 1;
#my $*DEBUG = 1;

subtest {
	plan 2;

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
	plan 1;

	subtest {
		plan 0;

#`(
		my $source = Q:to[_END_];
sub foo returns Int {}
_END_
		my $parsed = $pt.parse-source( $source );
		my $tree = $pt.build-tree( $parsed );
		ok $pt.validate( $parsed ), Q{valid};
		is $pt.format( $tree ), $source, Q{formatted};
)
	}, Q{sub foo returns Int {}};
}, Q{subroutine};

# vim: ft=perl6
