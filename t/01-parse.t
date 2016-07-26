use v6;

use Test;
use Perl6::Tidy;

plan 1;

my $pt = Perl6::Tidy.new;
#my $*TRACE = 1;
#my $*DEBUG = 1;

subtest {
	plan 2;

	my $document = $pt.tidy( Q{} );
	isa-ok $document, Q{Perl6::Document};
	is $document, Q:to[_END_], Q{Document stringifies};
_END_
}, Q{Empty file};

# vim: ft=perl6
