use v6;

use Test;
use Perl6::Parser;

plan 2 * 4;

my $pp = Perl6::Parser.new;
my $*CONSISTENCY-CHECK = True;
my $*FALL-THROUGH = True;
my ( $source, $tree );

for ( True, False ) -> $*PURE-PERL {
	subtest {
		plan 2;

		$source = Q{/pi/};
		$tree = $pp.to-tree( $source );
		is $pp.to-string( $tree ), $source, Q{no ws};

		$source = Q:to[_END_];
		/pi/
		_END_
		$tree = $pp.to-tree( $source );
		is $pp.to-string( $tree ), $source, Q{ws};
	}, Q{/pi/};

	subtest {
		plan 2;

		$source = Q{/<[ p i ]>/};
		$tree = $pp.to-tree( $source );
		is $pp.to-string( $tree ), $source, Q{no ws};

		$source = Q:to[_END_];
		/ <[ p i ]> /
		_END_
		$tree = $pp.to-tree( $source );
		is $pp.to-string( $tree ), $source, Q{ws};
	}, Q{/<[ p i ]>/};

	subtest {
		plan 2;

		$source = Q{/\d/};
		$tree = $pp.to-tree( $source );
		is $pp.to-string( $tree ), $source, Q{no ws};

		$source = Q:to[_END_];
		/ \d /
		_END_
		$tree = $pp.to-tree( $source );
		is $pp.to-string( $tree ), $source, Q{ws};
	}, Q{/ \d /};

	subtest {
		plan 2;

		$source = Q{/./};
		$tree = $pp.to-tree( $source );
		is $pp.to-string( $tree ), $source, Q{no ws};

		$source = Q:to[_END_];
		/ . /
		_END_
		$tree = $pp.to-tree( $source );
		is $pp.to-string( $tree ), $source, Q{ws};
	}, Q{/ . /};
}

# vim: ft=perl6
