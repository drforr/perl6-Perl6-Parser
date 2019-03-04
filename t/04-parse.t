use v6;

use Test;
use Perl6::Parser;

use lib 't/lib';
use Utils;

plan 3;

my $pp                 = Perl6::Parser.new;
my $*CONSISTENCY-CHECK = True;
my $*FALL-THROUGH      = True;

ok round-trips( Q{} ), Q{Empty string};

ok round-trips( Q{ } ), Q{whitespace only};

subtest {
	plan 2;

	subtest {
		plan 5;

		ok round-trips( Q{my$a}    ), Q{my$a};
		ok round-trips( Q{my$a;}   ), Q{my$a;};
		ok round-trips( Q{my $a}   ), Q{my $a};
		ok round-trips( Q{my $a;}  ), Q{my $a;};
		ok round-trips( Q{my $a ;} ), Q{my $a ;};
	}, Q{simple declaration};

	subtest {
		plan 5;

		ok round-trips( Q{my$a=1}    ), Q{my$a=1};
		ok round-trips( Q{my$a=1;}   ), Q{my$a=1;};
		ok round-trips( Q{my $a=1}   ), Q{my $a=1};
		ok round-trips( Q{my $a=1;}  ), Q{my $a=1;};
		ok round-trips( Q{my $a=1 ;} ), Q{my $a=1 ;};
	}, Q{initializer};
}, Q{passthrough};

# vim: ft=perl6
