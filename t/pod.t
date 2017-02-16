use v6;

use Test;
use Perl6::Parser;

plan 1;

my $pt = Perl6::Parser.new;
my $*CONSISTENCY-CHECK = True;
my $*GRAMMAR-CHECK = True;

subtest {
	my $source = Q:to[_END_];
=begin EMPTY
=end EMPTY
_END_
	my $parsed = $pt.parse( $source );
	my $tree = $pt.build-tree( $parsed );
	is $pt.to-string( $tree ), $source, Q{formatted};

	done-testing;
}, Q{empty};

# vim: ft=perl6
