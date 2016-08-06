use v6;

use Test;
use Perl6::Tidy;

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
}, Q{empty};

# vim: ft=perl6
