use v6;

use Test;
use Perl6::Parser;
use Perl6::Parser::Factory;

plan 1;

my $pt = Perl6::Parser.new;
my $ppf = Perl6::Parser::Factory.new;
my $*CONSISTENCY-CHECK = True;
my $*GRAMMAR-CHECK = True;

subtest {
	my $source = Q{'a';2;1};
	my $edited = Q{'';2;1};
	my $p = $pt.parse( $source );
	my $tree = $pt.build-tree( $p );
	$ppf.thread( $tree );
#say $pt.dump-tree( $tree );
	my $head = $ppf.flatten( $tree );

	my $walk-me = $head;
	my $body = $head.next.next.next.next;

	# Remove the current element, and do so non-recursively.
	# That is, if there are elements "under" it in the tree, they'll
	# still be attached somehow.
	#
	$body.remove-node;

	ok $head ~~ Perl6::Document; $head = $head.next;
	ok $head ~~ Perl6::Statement; $head = $head.next;
	ok $head ~~ Perl6::String::Escaping; $head = $head.next;
	ok $head ~~ Perl6::Balanced::Enter; $head = $head.next;
#	ok $head ~~ Perl6::String::Body; $head = $head.next;
	ok $head ~~ Perl6::Balanced::Exit; $head = $head.next;
	ok $head ~~ Perl6::Semicolon; $head = $head.next;
	ok $head ~~ Perl6::Statement; $head = $head.next;
	ok $head ~~ Perl6::Number::Decimal; $head = $head.next;
	ok $head ~~ Perl6::Semicolon; $head = $head.next;
	ok $head ~~ Perl6::Statement; $head = $head.next;
	ok $head ~~ Perl6::Number::Decimal; $head = $head.next;
	ok $head.is-end;

	my $iterated = '';
	while $walk-me {
		$iterated ~= $walk-me.content if $walk-me.is-leaf;
		last if $walk-me.is-end;
		$walk-me = $walk-me.next;
	}
	is $iterated, $edited, Q{edited document};

	done-testing;
}, Q{check flattened data};

# vim: ft=perl6
