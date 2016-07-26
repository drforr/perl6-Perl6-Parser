use v6;

use Test;
use Perl6::Tidy;

plan 14;

my $pt = Perl6::Tidy.new;
#my $*TRACE = 1;
#my $*DEBUG = 1;

subtest {
	plan 1;

	my $parsed = $pt.tidy( Q{a => 1} );
	isa-ok $parsed, Q{Perl6::Document};
}, Q{a => 1};

subtest {
	plan 1;

	my $parsed = $pt.tidy( Q{'a' => 'b'} );
	isa-ok $parsed, Q{Perl6::Document};
}, Q{'a' => 'b'};

subtest {
	plan 1;

	my $parsed = $pt.tidy( Q{:a} );
	isa-ok $parsed, Q{Perl6::Document};
}, Q{:a};

subtest {
	plan 1;

	my $parsed = $pt.tidy( Q{:!a} );
	isa-ok $parsed, Q{Perl6::Document};
}, Q{:!a};

subtest {
	plan 1;

	my $parsed = $pt.tidy( Q{:a<b>} );
	isa-ok $parsed, Q{Perl6::Document};
}, Q{:a<b>};

subtest {
	plan 1;

	my $parsed = $pt.tidy( Q{:a<b c>} );
	isa-ok $parsed, Q{Perl6::Document};
}, Q{:a<b c>};

subtest {
	plan 1;

	my $parsed = $pt.tidy( Q{my $a; :a{$a}} );
	isa-ok $parsed, Q{Perl6::Document};
}, Q{:a{$a}};

subtest {
	plan 1;

	my $parsed = $pt.tidy( Q{:a{'a', 'b'}} );
	isa-ok $parsed, Q{Perl6::Document};
}, Q{:a{'a', 'b'}};

subtest {
	plan 1;

	my $parsed = $pt.tidy( Q{:a{'a' => 'b'}} );
	isa-ok $parsed, Q{Perl6::Document};
}, Q{:a{'a' => 'b'}};

subtest {
	plan 1;

	my $parsed = $pt.tidy( Q{:a{'a' => 'b'}} );
	isa-ok $parsed, Q{Perl6::Document};
}, Q{:a{'a' => 'b'}};

subtest {
	plan 1;

	my $parsed = $pt.tidy( Q{my $a; :$a} );
	isa-ok $parsed, Q{Perl6::Document};
}, Q{:$a};

subtest {
	plan 1;

	my $parsed = $pt.tidy( Q{my @a; :@a} );
	isa-ok $parsed, Q{Perl6::Document};
}, Q{:@a};

subtest {
	plan 1;

	my $parsed = $pt.tidy( Q{my %a; :%a} );
	isa-ok $parsed, Q{Perl6::Document};
}, Q{:%a};

subtest {
	plan 1;

	my $parsed = $pt.tidy( Q{my &a; :&a} );
	isa-ok $parsed, Q{Perl6::Document};
}, Q{:&a};

# vim: ft=perl6
