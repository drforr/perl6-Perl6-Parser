use v6;

use Test;
use Perl6::Tidy;

plan 2;

my $pt = Perl6::Tidy.new;

is $pt.tidy( Q{} ),
	Q{},
	Q{Empty string};

subtest {
	plan 2;

	subtest {
		plan 4;

		is $pt.tidy( Q{my$a} ),
			Q{my$a},
			Q{no WS};

		is $pt.tidy( Q{my $a} ),
#			Q{my $a},
			Q{my$a},
			Q{single WS};

		is $pt.tidy( Q{my$a;} ),
			Q{my$a;},
			Q{semi, no WS};

		is $pt.tidy( Q{my $a;} ),
#			Q{my $a;},
			Q{my$a;},
			Q{semi, single WS};
	}, Q{simple declaration};

	subtest {
		plan 4;

		is $pt.tidy( Q{my$a=1} ),
			Q{my$a=1},
			Q{no WS};

		is $pt.tidy( Q{my $a=1} ),
#			Q{my $a=1},
			Q{my$a=1},
			Q{single WS};

		is $pt.tidy( Q{my$a=1;} ),
			Q{my$a=1;},
			Q{semi, no WS};

		is $pt.tidy( Q{my $a=1;} ),
#			Q{my $a=1;},
			Q{my$a=1;},
			Q{semi, single WS};
	}, Q{initializer};
}, Q{passthrough};

# vim: ft=perl6
