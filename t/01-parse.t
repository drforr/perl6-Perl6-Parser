use v6;

use Test;
use Perl6::Tidy;

plan 1;

my $pt = Perl6::Tidy.new;

subtest {
	plan 2;

	my $parsed = $pt.tidy( Q{} );
	isa-ok $parsed, 'Perl6::Tidy::Root';
	is $parsed.child.elems, 1;
}, 'Empty file';

# vim: ft=perl6
