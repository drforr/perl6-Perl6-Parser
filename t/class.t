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
	plan 0;

	subtest {
		plan 2;

		my $source = Q:to[_END_];
class Unqualified { method foo { } }
_END_
		my $parsed = $pt.parse-source( $source );
		my $tree = $pt.build-tree( $parsed );
		ok $pt.validate( $parsed ), Q{valid};
		is $pt.format( $tree ), $source, Q{formatted};
	}, Q{single};

#	subtest {
#		plan 2;
#
#		my $parsed = $pt.parse-source( Q:to[_END_].chomp );
#class Unqualified {
#	method foo { }
#	method bar { }
#}
#_END_
#		my $tree = $pt.build-tree( $parsed );
#		ok $pt.validate( $parsed ), Q{valid};
##		is $pt.format( $tree ), Q:to[_END_], Q{formatted};
##class Unqualified {
##	method foo { }
##	method bar { }
##}
##_END_
#		is $pt.format( $tree ), Q:to[_END_].chomp, Q{formatted};
#classUnqualified{methodfoo{}methodbar{}}
#_END_
#	}, Q{multiple};
}, Q{method};

# vim: ft=perl6
