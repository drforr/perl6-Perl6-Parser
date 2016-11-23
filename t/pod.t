use v6;

use Test;
use Perl6::Parser;

plan 1;

my $pt = Perl6::Parser.new;
my $*VALIDATION-FAILURE-FATAL = True;
my $*FACTORY-FAILURE-FATAL = True;
my $*DEBUG = True;

subtest {
	plan 2;

	my $source = Q:to[_END_];
=begin EMPTY
=end EMPTY
_END_
	my $parsed = $pt.parse( $source );
	my $tree = $pt.build-tree( $parsed );
	ok $pt.validate( $parsed ), Q{valid};
	is $pt.to-string( $tree ), $source, Q{formatted};
}, Q{empty};

# vim: ft=perl6
