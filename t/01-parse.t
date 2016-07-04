use v6;

use nqp;
use Test;
use Perl6::Tidy;

plan 1;

my $pt = Perl6::Tidy.new( :debugging(True) );

subtest sub {
	plan 1;

	my $parsed = $pt.tidy( Q{} );
	is $parsed.child.elems, 1;
}, 'Empty file';

# vim: ft=perl6
