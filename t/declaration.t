use v6;

use Test;
use Perl6::Parser;

use lib 't/lib';
use Utils;

plan 2;

my $*CONSISTENCY-CHECK = True;
my $*FALL-THROUGH      = True;

subtest {
	plan 2;

	subtest {
		plan 3;

		ok round-trips( Q{my Int $a} ), Q{regular};

		ok round-trips( Q{my Int:U $a} ), Q{undefined};

		ok round-trips( Q{my Int:D $a = 0} ), Q{defined};
	}, Q{typed};

	ok round-trips( Q{my $a where 1} ), Q{constrained};
}, Q{variable};

subtest {
	plan 1;

	subtest {
		plan 2;

		ok round-trips( Q{sub foo returns Int {}} ), Q{ws};

		ok round-trips( Q:to[_END_] ), Q{ws};
		sub foo returns Int {}
		_END_
	}, Q{sub foo returns Int {}};
}, Q{subroutine};

# vim: ft=perl6
