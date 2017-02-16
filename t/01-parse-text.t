use v6;

use Test;
use Perl6::Parser;

plan 3;

my $pt = Perl6::Parser.new;
my $*CONSISTENCY-CHECK = True;
my $*GRAMMAR-CHECK = True;

subtest {
	plan 1;
	
	my $parsed = $pt.parse( Q{} );
	ok $parsed.hash.<statementlist>, Q{statementlist};
}, Q{Empty file};

subtest {
	plan 1;
	
	my $parsed = $pt.parse( Q {} );
	ok $parsed.hash.<statementlist>, Q{statementlist};
}, Q{whitespace-only};

subtest {
	plan 11;

	my $p = $pt.parse( Q{'a'} );
	is-deeply [ $p.hash.keys ], [< statementlist >],
		Q{document has correct hash keys};

	my $a = $p.hash.<statementlist>;
	is-deeply [ $a.hash.keys ], [< statement >],
		Q{statementlist has correct hash keys};

	my $b = $a.hash.<statement>;
	is $b.list.elems, 1, Q{list has correct length};

	my $c = $b.list.[0];
	is-deeply [ $c.hash.keys ], [< EXPR >],
		Q{list has correct hash keys};
	is $c.hash.<EXPR>.Str, Q{'a'}, Q{EXPR has correct Str};

	my $d = $c.hash.<EXPR>;
	is-deeply [ $d.hash.keys ], [< value >],
		Q{EXPR has correct hash keys};
	is $d.hash.<value>.Str, Q{'a'}, Q{value has correct Str};

	my $e = $d.hash.<value>;
	is-deeply [ $e.hash.keys ], [< quote >],
		Q{value has correct hash keys};
	is $e.hash.<quote>.Str, Q{'a'}, Q{quote has correct Str};

	my $f = $e.hash.<quote>;
	is-deeply [ $f.hash.keys ], [< nibble >],
		Q{quote has correct hash keys};
	is $f.hash.<nibble>.Str, Q{a}, Q{nibble has correct Str};
}, Q{Smoketest hash structure};

# vim: ft=perl6
