use v6;

use Test;
use Perl6::Parser;
use Perl6::Parser::Factory;

plan 7;

my $pt = Perl6::Parser.new;
my $ppf = Perl6::Parser::Factory.new;
my $*CONSISTENCY-CHECK = True;
my $*GRAMMAR-CHECK = True;

# 'a'
subtest {
	my $tree = Perl6::String::Body.new(:from(0),:to(1),:content('a'));
	$ppf.thread( $tree );
#say $pt.dump-tree( $tree );

	ok !$tree.next.defined;
}

# '()'
subtest {
	my $tree =
		Perl6::Operator::Circumfix.new(
			:from(0),
			:to(1),
			:child()
		);
	$ppf.thread( $tree );
#say $pt.dump-tree( $tree );

	ok !$tree.next.defined;
}

# '(a)'
subtest {
	my $tree =
		Perl6::Operator::Circumfix.new(
			:from(0),
			:to(1),
			:child(
				Perl6::String::Body.new(
					:from(0),
					:to(1),
					:content('a')
				),
			)
		);
	$ppf.thread( $tree );
#say $pt.dump-tree( $tree );

	is $tree.next, $tree.child[0];
}

# '(ab)'
subtest {
	my $tree =
		Perl6::Operator::Circumfix.new(
			:from(0),
			:to(2),
			:child(
				Perl6::String::Body.new(
					:from(0),
					:to(1),
					:content('a')
				),
				Perl6::String::Body.new(
					:from(1),
					:to(2),
					:content('b')
				)
			)
		);
	$ppf.thread( $tree );
#say $pt.dump-tree( $tree );

	is $tree.next, $tree.child[0];
	is $tree.child[0].next, $tree.child[1];
}

# '(()b)'
subtest {
	my $tree =
		# $tree -> $tree.child[0]
		Perl6::Operator::Circumfix.new(
			:from(0),
			:to(2),
			:child(
				# $tree.child[0] -> $tree.child[1]
				Perl6::Operator::Circumfix.new(
					:from(0),
					:to(1),
					:child()
				),
				# $tree.child[1] -> Any
				Perl6::String::Body.new(
					:from(1),
					:to(2),
					:content('b')
				)
			)
		);
	$ppf.thread( $tree );
#say $pt.dump-tree( $tree );

	is $tree.next, $tree.child[0];
	is $tree.child[0].next, $tree.child[1];
	ok !$tree.child[1].next;
}

# '((a)b)'
subtest {
	my $tree = # $tree -> $tree.child[0]
		Perl6::Operator::Circumfix.new(
			:from(0),
			:to(2),
			:child(
				# $tree.child[0] -> $tree.child[0].child[0]
				Perl6::Operator::Circumfix.new(
					:from(0),
					:to(1),
					:child(
						# $tree.child[0].child[0]
						# -> $tree.child[1]
						Perl6::String::Body.new(
							:from(1),
							:to(2),
							:content('a')
						)
					)
				),
				# $tree.child[1] -> Any
				Perl6::String::Body.new(
					:from(1),
					:to(2),
					:content('b')
				)
			)
		);
	$ppf.thread( $tree );
#say $pt.dump-tree( $tree );

	is $tree.next, $tree.child[0];
	is $tree.child[0].next, $tree.child[0].child[0];
	is $tree.child[0].child[0].next, $tree.child[1];
	ok !$tree.child[1].next;
}

subtest {
	my $source = Q{'a';2;1};
	my $p = $pt.parse( $source );
	my $tree = $pt.build-tree( $p );
#say $pt.dump-tree( $tree );
	is $pt.to-string( $tree ), $source, Q{formatted};

	is $tree.next,
		$tree.child[0];
	is $tree.child[0].next,
		$tree.child[0].child[0];
	is $tree.child[0].child[0].next,
		$tree.child[0].child[0].child[0];
	is $tree.child[0].child[0].child[0].next,
		$tree.child[0].child[0].child[1];
	is $tree.child[0].child[0].child[1].next,
		$tree.child[0].child[0].child[2];
	is $tree.child[0].child[0].child[2].next,
		$tree.child[0].child[1];
	is $tree.child[0].child[1].next,
		$tree.child[1];
	is $tree.child[1].next,
		$tree.child[1].child[0];
	is $tree.child[1].child[0].next,
		$tree.child[1].child[1];
	is $tree.child[1].child[1].next,
		$tree.child[2];
	is $tree.child[2].next,
		$tree.child[2].child[0];

	done-testing;
}, Q{leading, trailing ws};

# vim: ft=perl6
