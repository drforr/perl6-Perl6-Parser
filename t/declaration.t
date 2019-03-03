use v6;

use Test;
use Perl6::Parser;

plan 2 * 2;

my $pp = Perl6::Parser.new;
my $*CONSISTENCY-CHECK = True;
my $*FALL-THROUGH = True;
my ( $source, $tree );

for ( True, False ) -> $*PURE-PERL {
	subtest {
		plan 2;

		subtest {
			plan 3;

			$source = Q{my Int $a};
			$tree = $pp.to-tree( $source );
			is $pp.to-string( $tree ), $source, Q{regular};

			$source = Q{my Int:U $a};
			$tree = $pp.to-tree( $source );
			is $pp.to-string( $tree ), $source, Q{undefined};

			$source = Q{my Int:D $a = 0};
			$tree = $pp.to-tree( $source );
			is $pp.to-string( $tree ), $source, Q{defined};
		}, Q{typed};

		$source = Q{my $a where 1};
		$tree = $pp.to-tree( $source );
		is $pp.to-string( $tree ), $source, Q{constrained};
	}, Q{variable};

	subtest {
		plan 1;

		subtest {
			plan 2;

			$source = Q{sub foo returns Int {}};
			$tree = $pp.to-tree( $source );
			is $pp.to-string( $tree ), $source, Q{ws};

			$source = Q:to[_END_];
			sub foo returns Int {}
			_END_
			$tree = $pp.to-tree( $source );
			is $pp.to-string( $tree ), $source, Q{ws};
		}, Q{sub foo returns Int {}};
	}, Q{subroutine};
}

# vim: ft=perl6
