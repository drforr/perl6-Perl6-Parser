use v6;

use nqp;
use Test;
use Perl6::Tidy;

plan 2;

my $pt = Perl6::Tidy.new( :debugging(True) );

subtest sub {
	plan 2;

	my $parsed = $pt.tidy( Q{} );
	isa-ok $parsed, 'Perl6::Tidy::statementlist';
	is $parsed.children.elems, 0;
}, 'Empty file';

# vim: ft=perl6
