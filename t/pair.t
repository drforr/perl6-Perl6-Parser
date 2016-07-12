use v6;

use nqp;
use Test;
use Perl6::Tidy;

plan 1;

my $pt = Perl6::Tidy.new;

subtest {
	plan 14;

	subtest {
		plan 2;

		my $parsed = $pt.tidy( Q{a => 1} );
		isa-ok $parsed, 'Perl6::Tidy::Root';
		is $parsed.child.elems, 1;
	}, Q[a => 1];

	subtest {
		plan 2;

		my $parsed = $pt.tidy( Q{'a' => 'b'} );
		isa-ok $parsed, 'Perl6::Tidy::Root';
		is $parsed.child.elems, 1;
	}, Q['a' => 'b'];

	subtest {
		plan 2;

		my $parsed = $pt.tidy( Q{:a} );
		isa-ok $parsed, 'Perl6::Tidy::Root';
		is $parsed.child.elems, 1;
	}, Q[:a];

	subtest {
		plan 2;

		my $parsed = $pt.tidy( Q{:!a} );
		isa-ok $parsed, 'Perl6::Tidy::Root';
		is $parsed.child.elems, 1;
	}, Q[:!a];

	subtest {
		plan 2;

		my $parsed = $pt.tidy( Q{:a<b>} );
		isa-ok $parsed, 'Perl6::Tidy::Root';
		is $parsed.child.elems, 1;
	}, Q[:a<b>];

	subtest {
		plan 2;

		my $parsed = $pt.tidy( Q{:a<b c>} );
		isa-ok $parsed, 'Perl6::Tidy::Root';
		is $parsed.child.elems, 1;
	}, Q[:a<b c>];

	subtest {
		plan 2;

		my $parsed = $pt.tidy( Q{my $a; :a{$a}} );
		isa-ok $parsed, 'Perl6::Tidy::Root';
		is $parsed.child.elems, 1;
	}, Q[:a{$a}];

	subtest {
		plan 2;

		my $parsed = $pt.tidy( Q{:a{'a', 'b'}} );
		isa-ok $parsed, 'Perl6::Tidy::Root';
		is $parsed.child.elems, 1;
	}, Q[:a{'a', 'b'}];

	subtest {
		plan 2;

		my $parsed = $pt.tidy( Q{:a{'a' => 'b'}} );
		isa-ok $parsed, 'Perl6::Tidy::Root';
		is $parsed.child.elems, 1;
	}, Q[:a{'a' => 'b'}];

	subtest {
		plan 2;

		my $parsed = $pt.tidy( Q{:a{'a' => 'b'}} );
		isa-ok $parsed, 'Perl6::Tidy::Root';
		is $parsed.child.elems, 1;
	}, Q[:a{'a' => 'b'}];

	subtest {
		plan 2;

		my $parsed = $pt.tidy( Q{my $a; :$a} );
		isa-ok $parsed, 'Perl6::Tidy::Root';
		is $parsed.child.elems, 1;
	}, Q[:$a];

	subtest {
		plan 2;

		my $parsed = $pt.tidy( Q{my @a; :@a} );
		isa-ok $parsed, 'Perl6::Tidy::Root';
		is $parsed.child.elems, 1;
	}, Q[:@a];

	subtest {
		plan 2;

		my $parsed = $pt.tidy( Q{my %a; :%a} );
		isa-ok $parsed, 'Perl6::Tidy::Root';
		is $parsed.child.elems, 1;
	}, Q[:%a];

	subtest {
		plan 2;

		my $parsed = $pt.tidy( Q{my &a; :&a} );
		isa-ok $parsed, 'Perl6::Tidy::Root';
		is $parsed.child.elems, 1;
	}, Q[:&a];
}, 'pair';

# vim: ft=perl6
