use v6;

use Test;
use Perl6::Parser;

use lib 't/lib';
use Utils;

plan 5;

my $*CONSISTENCY-CHECK = True;
my $*FALL-THROUGH      = True;

# Make certain that BEGIN {}, CHECK {}, phasers don't halt compilation.
# Also check that 'my $x will begin { }', 'my $x will check { }' phasers
# don't halt compilation.
#

ok round-trips( Q{BEGIN { die "HALT!" }} ),
   Q{BEGIN};
ok round-trips( Q{BEGIN { die "HALT!" }; BEGIN { die "HALT!" }} ),
   Q{BEGIN BEGIN};
ok round-trips( Q{CHECK { die "HALT!" }} ),
   Q{CHECK};
ok round-trips( Q{CHECK { die "HALT!" }; CHECK { die "HALT!" }} ),
   Q{CHECK CHECK};
ok round-trips( Q{BEGIN { die "HALT!" }; CHECK { die "HALT!" }} ),
   Q{BEGIN CHECK};

# XXX Yes, there is Q{my $x will begin { die "HALT!" }} as well.
# XXX The simple answer doesn't seem to work, I'll work on it later.

# vim: ft=perl6
