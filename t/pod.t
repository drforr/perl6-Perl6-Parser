use v6;

use Test;
use Perl6::Parser;

plan 1;

my $pt = Perl6::Parser.new;
my $*CONSISTENCY-CHECK = True;
my $*FALL-THROUGH = True;

subtest {
	my $source = Q:to[_END_];
=begin EMPTY
=end EMPTY
_END_
	my $tree = $pt.to-tree( $source );
	is $pt.to-string( $tree ), $source, Q{formatted};

	done-testing;
}, Q{empty};

# vim: ft=perl6
