use v6;

use Test;
use Perl6::Tidy;

plan 1;

my $pt = Perl6::Tidy.new;
my $*TRACE = 1;
my $*DEBUG = 1;

subtest {
	plan 1;

	my $parsed = $pt.tidy( Q{} );
	isa-ok $parsed, Q{Perl6::Tidy::Root};
}, Q{Empty file};

# vim: ft=perl6
