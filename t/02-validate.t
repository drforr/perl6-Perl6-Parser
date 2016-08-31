use v6;

use Test;
use Perl6::Tidy;

#`(
plan 2;

my $pt = Perl6::Tidy.new;
#my $*TRACE = 1;
#my $*DEBUG = 1;

subtest {
	plan 1;
	
	my $p = $pt.parse-source( Q{} );
	ok $pt.validate( $p ), Q{validates};
}, Q{Empty file};

subtest {
	plan 1;

	my $p = $pt.parse-source( Q{'a'} );
	ok $pt.validate( $p ), Q{validates};
}, Q{File with string};
)

# vim: ft=perl6
