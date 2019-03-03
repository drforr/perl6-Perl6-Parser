use v6;

use Test;
use Perl6::Parser;

plan 2 * 1;

my $pp = Perl6::Parser.new;
my $*CONSISTENCY-CHECK = True;
my $*FALL-THROUGH = True;

for ( True, False ) -> $*PURE-PERL {
	subtest {
		my $source = Q:to[_END_];
		=begin EMPTY
		=end EMPTY
		_END_
		my $tree = $pp.to-tree( $source );
		is $pp.to-string( $tree ), $source, Q{formatted};

		done-testing;
	}, Q{empty};
}

# vim: ft=perl6
