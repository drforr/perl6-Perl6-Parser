use v6;

use Test;
use Perl6::Tidy;

#`(

In passing, please note that while it's trivially possible to bum down the
tests, doing so makes it harder to insert 'say $parsed.dump' to view the
AST, and 'say $tree.perl' to view the generated Perl 6 structure.

)

plan 1;

my $pt = Perl6::Tidy.new;
#my $*TRACE = 1;
#my $*DEBUG = 1;

subtest {
	plan 1;

	my $parsed = $pt.parse-source( Q:to[_END_] );
=begin EMPTY
=end EMPTY
_END_
	ok $pt.validate( $parsed );
#`(
	plan 2;

	my $parsed = $pt.parse-source( Q:to[_END_].chomp );
=begin EMPTY
=end EMPTY
_END_
	my $tree = $pt.build-tree( $parsed );
	ok $pt.validate( $parsed ), Q{valid};
#	is $pt.format( $tree ), Q:to[_END_], Q{formatted};
#=begin EMPTY
#=end EMPTY
#_END_
	is $pt.format( $tree ), Q{=beginEMPTY=endEMPTY}, Q{formatted};
)
}, Q{empty};

# vim: ft=perl6
