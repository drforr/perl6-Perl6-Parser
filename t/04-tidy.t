use v6;

use Test;
use Perl6::Tidy;

plan 3;

my $pt = Perl6::Tidy.new;

is $pt.tidy( Q{} ),
	Q{},
	Q{Empty string};

is $pt.tidy( Q{ } ),
	Q{ },
	Q{whitespace only};

subtest {
	plan 2;

	subtest {
		plan 5;

		subtest {
			plan 1;

			my $source = Q{my$a};
			is $pt.tidy( $source ), $source, Q{roundtrip};
		}, Q{my$a};

		subtest {
			plan 1;

			my $source = Q{my$a;};
			is $pt.tidy( $source ), $source, Q{roundtrip};
		}, Q{my$a;};

		subtest {
			plan 1;

			my $source = Q{my $a};
			is $pt.tidy( $source ), $source, Q{roundtrip};
		}, Q{my $a};

		subtest {
			plan 1;

			my $source = Q{my $a;};
			is $pt.tidy( $source ), $source, Q{roundtrip};
		}, Q{my $a;};

		subtest {
			plan 1;

			my $source = Q{my $a ;};
			is $pt.tidy( $source ), $source, Q{roundtrip};
		}, Q{my $a ;};
	}, Q{simple declaration};

	subtest {
		plan 5;

		subtest {
			plan 1;

			my $source = Q{my$a=1};
			is $pt.tidy( $source ), $source, Q{roundtrip};
		}, Q{my$a=1};

		subtest {
			plan 1;

			my $source = Q{my$a=1;};
			is $pt.tidy( $source ), $source, Q{roundtrip};
		}, Q{my$a=1;};

		subtest {
			plan 1;

			my $source = Q{my $a=1};
			is $pt.tidy( $source ), $source, Q{roundtrip};
		}, Q{my $a=1};

		subtest {
			plan 1;

			my $source = Q{my $a=1;};
			is $pt.tidy( $source ), $source, Q{roundtrip};
		}, Q{my $a=1;};

		subtest {
			plan 1;

			my $source = Q{my $a=1 ;};
			is $pt.tidy( $source ), $source, Q{roundtrip};
		}, Q{my $a=1 ;};
	}, Q{initializer};
}, Q{passthrough};

# vim: ft=perl6
