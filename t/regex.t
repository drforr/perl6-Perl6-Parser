use v6;

use Test;
use Perl6::Parser;

plan 4;

my $pt = Perl6::Parser.new;
my $*CONSISTENCY-CHECK = True;
my $*GRAMMAR-CHECK = True;
my $*FALL-THROUGH = True;

subtest {
	plan 2;

	subtest {
		my $source = Q{/pi/};
		my $tree = $pt.to-tree( $source );
		is $pt.to-string( $tree ), $source, Q{formatted};

		done-testing;
	}, Q{no ws};

	subtest {
		my $source = Q:to[_END_];
/pi/
_END_
		my $tree = $pt.to-tree( $source );
		is $pt.to-string( $tree ), $source, Q{formatted};

		done-testing;
	}, Q{ws};
}, Q{/pi/};

subtest {
	plan 2;

	subtest {
		my $source = Q{/<[ p i ]>/};
		my $tree = $pt.to-tree( $source );
		is $pt.to-string( $tree ), $source, Q{formatted};

		done-testing;
	}, Q{no ws};

	subtest {
		my $source = Q:to[_END_];
/ <[ p i ]> /
_END_
		my $tree = $pt.to-tree( $source );
		is $pt.to-string( $tree ), $source, Q{formatted};

		done-testing;
	}, Q{ws};
}, Q{/<[ p i ]>/};

subtest {
	plan 2;

	subtest {
		my $source = Q{/\d/};
		my $tree = $pt.to-tree( $source );
		is $pt.to-string( $tree ), $source, Q{formatted};

		done-testing;
	}, Q{no ws};

	subtest {
		my $source = Q:to[_END_];
/ \d /
_END_
		my $tree = $pt.to-tree( $source );
		is $pt.to-string( $tree ), $source, Q{formatted};

		done-testing;
	}, Q{ws};
}, Q{/ \d /};

subtest {
	plan 2;

	subtest {
		my $source = Q{/./};
		my $tree = $pt.to-tree( $source );
		is $pt.to-string( $tree ), $source, Q{formatted};

		done-testing;
	}, Q{no ws};

	subtest {
		my $source = Q:to[_END_];
/ . /
_END_
		my $tree = $pt.to-tree( $source );
		is $pt.to-string( $tree ), $source, Q{formatted};

		done-testing;
	}, Q{ws};
}, Q{/ . /};

# vim: ft=perl6
