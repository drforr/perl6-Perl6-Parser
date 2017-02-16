use v6;

use Test;
use Perl6::Parser;

plan 3;

my $pt = Perl6::Parser.new;
my $*CONSISTENCY-CHECK = True;
my $*GRAMMAR-CHECK = True;

is $pt.roundtrip( Q{} ),
	Q{},
	Q{Empty string};

is $pt.roundtrip( Q{ } ),
	Q{ },
	Q{whitespace only};

subtest {
	plan 2;

	subtest {
		plan 5;

		my $source;

		$source = Q{my$a};
		is $pt.roundtrip( $source ), $source, Q{my$a};

		$source = Q{my$a;};
		is $pt.roundtrip( $source ), $source, Q{my$a;};

		$source = Q{my $a};
		is $pt.roundtrip( $source ), $source, Q{my $a};

		$source = Q{my $a;};
		is $pt.roundtrip( $source ), $source, Q{my $a;};

		$source = Q{my $a ;};
		is $pt.roundtrip( $source ), $source, Q{my $a ;};
	}, Q{simple declaration};

	subtest {
		plan 5;

		my $source;

		$source = Q{my$a=1};
		is $pt.roundtrip( $source ), $source, Q{my$a=1};

		$source = Q{my$a=1;};
		is $pt.roundtrip( $source ), $source, Q{my$a=1;};

		$source = Q{my $a=1};
		is $pt.roundtrip( $source ), $source, Q{my $a=1};

		$source = Q{my $a=1;};
		is $pt.roundtrip( $source ), $source, Q{my $a=1;};

		$source = Q{my $a=1 ;};
		is $pt.roundtrip( $source ), $source, Q{my $a=1 ;};
	}, Q{initializer};
}, Q{passthrough};

# vim: ft=perl6
