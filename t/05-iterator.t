use v6;

use Test;
use Perl6::Parser;
use Perl6::Parser::Factory;

plan 9;

my $pt = Perl6::Parser.new;
my $ppf = Perl6::Parser::Factory.new;
my $*CONSISTENCY-CHECK = True;
my $*GRAMMAR-CHECK = True;

# 'a'
subtest {
	my $tree = Perl6::String::Body.new(:from(0),:to(1),:content('a'));
	$ppf.thread( $tree );
#say $pt.dump-tree( $tree );

	is $tree.parent,
		$tree;
	ok $tree.is-root;

	is $tree.next,
		$tree;
	ok $tree.is-end;

	is $tree.previous,
		$tree;
	ok $tree.is-start;
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

	is $tree.parent,
		$tree;
	ok $tree.is-root;

	is $tree.next,
		$tree;
	ok $tree.is-end;

	is $tree.previous,
		$tree;
	ok $tree.is-start;
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

	is $tree.parent,
		$tree;
	is $tree.child[0].parent,
		$tree;
	ok $tree.is-root;

	is $tree.next,
		$tree.child[0];
	is $tree.child[0].next,
		$tree.child[0];
	ok $tree.child[0].is-end;

	is $tree.child[0].previous,
		$tree;
	is $tree.previous,
		$tree;
	ok $tree.is-start;
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

	is $tree.parent,
		$tree;
	is $tree.child[0].parent,
		$tree;
	is $tree.child[1].parent,
		$tree;
	ok $tree.is-root;

	is $tree.next,
		$tree.child[0];
	is $tree.child[0].next,
		$tree.child[1];
	is $tree.child[1].next,
		$tree.child[1];
	ok $tree.child[1].is-end;

	is $tree.child[1].previous,
		$tree.child[0];
	is $tree.child[0].previous,
		$tree;
	is $tree.previous,
		$tree;
	ok $tree.is-start;
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

	is $tree.parent,
		$tree;
	is $tree.child[0].parent,
		$tree;
	is $tree.child[1].parent,
		$tree;
	ok $tree.is-root;

	is $tree.next,
		$tree.child[0];
	is $tree.child[0].next,
		$tree.child[1];
	is $tree.child[1].next,
		$tree.child[1];
	ok $tree.child[1].is-end;

	is $tree.child[1].previous,
		$tree.child[0];
	is $tree.child[0].previous,
		$tree;
	is $tree.previous,
		$tree;
	ok $tree.is-start;
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

	is $tree.parent,
		$tree;
	is $tree.child[0].parent,
		$tree;
	is $tree.child[0].child[0].parent,
		$tree.child[0];
	is $tree.child[1].parent,
		$tree;
	ok $tree.is-root;

	is $tree.next,
		$tree.child[0];
	is $tree.child[0].next,
		$tree.child[0].child[0];
	is $tree.child[0].child[0].next,
		$tree.child[1];
	is $tree.child[1].next,
		$tree.child[1];
	ok $tree.child[1].is-end;

	is $tree.child[1].previous,
		$tree.child[0].child[0];
	is $tree.child[0].child[0].previous,
		$tree.child[0];
	is $tree.child[0].previous,
		$tree;
	is $tree.previous,
		$tree;
	ok $tree.is-start;
}

subtest {
	my $source = Q{'a';2;1};
	my $p = $pt.parse( $source );
	my $tree = $pt.build-tree( $p );
	$ppf.thread( $tree );
#say $pt.dump-tree( $tree );
	is $pt.to-string( $tree ), $source, Q{formatted};

	is $tree.parent,
		$tree;
	is $tree.child[0].parent,
		$tree;
	is $tree.child[0].child[0].parent,
		$tree.child[0];
	is $tree.child[0].child[0].child[0].parent,
		$tree.child[0].child[0];
	is $tree.child[0].child[0].child[1].parent,
		$tree.child[0].child[0];
	is $tree.child[0].child[0].child[2].parent,
		$tree.child[0].child[0];
	is $tree.child[0].child[1].parent,
		$tree.child[0];
	is $tree.child[1].parent,
		$tree;
	is $tree.child[1].child[0].parent,
		$tree.child[1];
	is $tree.child[1].child[1].parent,
		$tree.child[1];
	is $tree.child[2].parent,
		$tree;
	is $tree.child[2].child[0].parent,
		$tree.child[2];
	ok $tree.is-root;

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
	is $tree.child[2].child[0].next,
		$tree.child[2].child[0];
	ok $tree.child[2].child[0].is-end;

	is $tree.child[2].child[0].previous,
		$tree.child[2];
	is $tree.child[2].previous,
		$tree.child[1].child[1];
	is $tree.child[1].child[1].previous,
		$tree.child[1].child[0];
	is $tree.child[1].child[0].previous,
		$tree.child[1];
	is $tree.child[1].previous,
		$tree.child[0].child[1];
	is $tree.child[0].child[1].previous,
		$tree.child[0].child[0].child[2];
	is $tree.child[0].child[0].child[2].previous,
		$tree.child[0].child[0].child[1];
	is $tree.child[0].child[0].child[1].previous,
		$tree.child[0].child[0].child[0];
	is $tree.child[0].child[0].child[0].previous,
		$tree.child[0].child[0];
	is $tree.child[0].child[0].previous,
		$tree.child[0];
	is $tree.child[0].previous,
		$tree;
	is $tree.previous,
		$tree;
	ok $tree.is-start;

	done-testing;
}, Q{leading, trailing ws};

subtest {
	my $source = Q{'a';2;1};
	my $ecruos = Q{1;2;'a'};
	my $p = $pt.parse( $source );
	my $tree = $pt.build-tree( $p );
	$ppf.thread( $tree );
#say $pt.dump-tree( $tree );

	my $head = $tree;
	my $iterated = '';
	while $head {
		$iterated ~= $head.content if $head.is-leaf;
		last if $head.is-end;
		$head = $head.next;
	}
	is $iterated, $source, Q{iterated forward};

	my $detareti = '';
	while $head {
		$detareti ~= $head.content if $head.is-leaf;
		last if $head.is-start;
		$head = $head.previous;
	}
	is $detareti, $ecruos, Q{iterated backwards};

	done-testing;
}, Q{simple iteration};

subtest {
	my $source = Q{'a';2;1};
	my $ecruos = Q{1;2;'a'};
	my $p = $pt.parse( $source );
	my $tree = $pt.build-tree( $p );
	$ppf.thread( $tree );
#say $pt.dump-tree( $tree );
	my $head = $ppf.flatten( $tree );

	ok $head ~~ Perl6::Document; $head = $head.next;
	ok $head ~~ Perl6::Statement; $head = $head.next;
	ok $head ~~ Perl6::String::Escaping; $head = $head.next;
	ok $head ~~ Perl6::Balanced::Enter; $head = $head.next;
	ok $head ~~ Perl6::String::Body; $head = $head.next;
	ok $head ~~ Perl6::Balanced::Exit; $head = $head.next;
	ok $head ~~ Perl6::Semicolon; $head = $head.next;
	ok $head ~~ Perl6::Statement; $head = $head.next;
	ok $head ~~ Perl6::Number::Decimal; $head = $head.next;
	ok $head ~~ Perl6::Semicolon; $head = $head.next;
	ok $head ~~ Perl6::Statement; $head = $head.next;
	ok $head ~~ Perl6::Number::Decimal; $head = $head.next;
	ok $head.is-end;

	done-testing;
}, Q{check flattened data};

# vim: ft=perl6
