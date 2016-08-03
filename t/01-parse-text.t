use v6;

use Test;
use Perl6::Tidy;

plan 2;

my $pt = Perl6::Tidy.new;
#my $*TRACE = 1;
#my $*DEBUG = 1;

subtest {
	plan 1;
	
	my $parsed = $pt.parse-text( Q{} );
	ok $parsed.hash.<statementlist>, Q{statementlist};
}, Q{Empty file};

subtest {
	plan 12;

	my $p = $pt.parse-text( Q{'a'} );
	ok $p.hash.<statementlist>, Q{statementlist};
	my $a = $p.hash.<statementlist>;
	ok $a.hash.<statement>, Q{statement};
	my $b = $a.hash.<statement>;
	ok $b.list, Q{list};
	is $b.list.elems, 1, Q{list has correct length};
	my $c = $b.list.[0];
	ok $c.hash.<EXPR>, Q{EXPR};
	is $c.hash.<EXPR>.Str, Q{'a'}, Q{EXPR has correct Str};
	my $d = $c.hash.<EXPR>;
	ok $d.hash.<value>, Q{value};
	is $d.hash.<value>.Str, Q{'a'}, Q{value has correct Str};
	my $e = $d.hash.<value>;
	ok $e.hash.<quote>, Q{quote};
	is $e.hash.<quote>.Str, Q{'a'}, Q{quote has correct Str};
	my $f = $e.hash.<quote>;
	ok $f.hash.<nibble>, Q{nibble};
	is $f.hash.<nibble>.Str, Q{a}, Q{nibble has correct Str};
}, Q{Smoketest hash structure};

# vim: ft=perl6
