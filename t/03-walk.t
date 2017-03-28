use v6;

use Test;
use Perl6::Parser;
use Perl6::Parser::Factory;

plan 10;

my $pt = Perl6::Parser.new;
my $ppf = Perl6::Parser::Factory.new;
my $*CONSISTENCY-CHECK = True;
my $*FALL-THROUGH = True;

sub make-decimal( Str $value ) {
	Perl6::Number::Decimal.new( :from(0), :to(2), :content($value) );
}
sub make-list {
	Perl6::Operator::Circumfix.new( :from(0), :to(1), :child( ) );
}

sub is-linked( $node, $parent, $next, $previous ) {
	return True if $node.parent === $parent;
	return True if $node.next === $next;
	return True if $node.previous === $previous;
	return False;
}
sub is-linked-leaf( $node, $next-leaf, $previous-leaf ) {
	return True if $node.next-leaf === $next-leaf;
	return True if $node.previous-leaf === $previous-leaf;
	return False;
}

# Just as a reminder, if you're at the end of a list and go to the next item,
# you'll just find yourself back at the end node.
#
# This is mostly to keep typing simple.

# 27
subtest {
	my $tree = make-decimal( '27' );
	$ppf.thread( $tree );

	ok $tree.is-root,
		Q{tree is its own root};
	ok $tree.is-start,
		Q{tree is its own start node};
	ok $tree.is-start-leaf,
		Q{tree is its own start leaf};
	ok $tree.is-end,
		Q{tree is its own end node};
	ok $tree.is-end-leaf,
		Q{tree is its own end leaf};

	ok is-linked( $tree,
		$tree,
		$tree,
		$tree
	), Q{root};
	ok is-linked-leaf( $tree,
		$tree,
		$tree
	), Q{root leaves};
}

# '()'
subtest {
	my $tree = make-list();
	$ppf.thread( $tree );

	ok $tree.is-root,
		Q{tree is its own root};
	ok $tree.is-start,
		Q{tree is its own start node};
	nok $tree.is-start-leaf,
		Q{tree is not its own start leaf};
	ok $tree.is-end,
		Q{tree is its own end node};
	nok $tree.is-end-leaf,
		Q{tree is not its own end leaf};

	ok is-linked( $tree,
		$tree,
		$tree,
		$tree
	), Q{root};
	nok $tree.next-leaf, Q{next leaf node does not exist};
	nok $tree.previous-leaf, Q{previous leaf node does not exist};
}

# '(27)' (not really - '27' because there's no '(',')'
subtest {
	my $tree = Perl6::Operator::Circumfix.new(
		:from(0),
		:to(1),
		:child(
			make-decimal( '27' )
		)
	);
	$ppf.thread( $tree );

	ok is-linked( $tree,
		$tree,
		$tree.child[0],
		$tree
	), Q{root};
	ok $tree.is-root, Q{tree is its own root};
	ok $tree.is-start, Q{tree is its own start node};
	nok $tree.is-start-leaf, Q{tree is not its own start leaf};
	nok $tree.is-end, Q{tree is not its own end node};
	nok $tree.is-end-leaf, Q{tree is not its own end leaf};

	my $twenty-seven = $tree.child[0];

	ok is-linked( $twenty-seven, $tree, $twenty-seven, $tree ), Q{'27'};

	nok $twenty-seven.is-start,
		Q{'27' s not the start};
	ok $twenty-seven.is-start-leaf,
		Q{'27' is the starting leaf};
	ok $twenty-seven.is-end,
		Q{'27' is at the end of the list};
	ok $twenty-seven.is-end-leaf,
		Q{'27' is the ending leaf};
	nok $twenty-seven.is-root,
		Q{'27' is not the root};
}

# '(27 64)' (not really - no '(',')' characters.
subtest {
	my $tree =
		Perl6::Operator::Circumfix.new(
			:from(0),
			:to(2),
			:child(
				make-decimal( '27' ),
				make-decimal( '64' )
			)
		);
	$ppf.thread( $tree );

	ok is-linked( $tree,
		$tree,
		$tree.child[0],
		$tree
	), Q{root};
	ok $tree.is-root;
	ok $tree.is-start;

	ok is-linked( $tree.child[0],
		$tree,
		$tree.child[1],
		$tree
	), Q{'27'};
	ok is-linked( $tree.child[1],
		$tree,
		$tree.child[1],
		$tree.child[0]
	), Q{'64'};
	ok $tree.child[1].is-end;
}

# '(27 64)' (not really - no '(',')' characters.
subtest {
	my $tree =
		Perl6::Operator::Circumfix.new(
			:from(0),
			:to(2),
			:child(
				make-decimal( '27' ),
				make-decimal( '64' )
			)
		);
	$ppf.thread( $tree );

	ok !$tree.is-leaf;

	my $int-node = $tree.next-leaf;

	ok $int-node ~~ Perl6::Number::Decimal;
}

# '(()b)' (not really - '(',')' are missing
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
				make-decimal( '27' )
			)
		);
	$ppf.thread( $tree );

	ok is-linked( $tree,
		$tree,
		$tree.child[0],
		$tree
	), Q{root};
	ok $tree.is-start;
	ok $tree.is-root;
	nok $tree.is-end;

	ok is-linked( $tree.child[0],
		$tree,
		$tree.child[1],
		$tree
	), Q{'()'};
	nok $tree.child[0].is-end;

	ok is-linked( $tree.child[1],
		$tree,
		$tree.child[1],
		$tree.child[0]
	), Q{'b'};
	ok $tree.child[1].is-end;
}

# '((a)b)' - not really, '(',')' are missing.
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
						make-decimal( '27' )
					)
				),
				# $tree.child[1] -> Any
				make-decimal( '64' )
			)
		);
	$ppf.thread( $tree );

	ok is-linked( $tree, $tree, $tree.child[0], $tree );
	ok $tree.is-root;
	ok $tree.is-start;

	ok is-linked( $tree.child[0],
		$tree,
		$tree.child[0].child[0],
		$tree
	), Q{'(a)'};

	ok is-linked( $tree.child[0].child[0],
		$tree.child[0],
		$tree.child[1],
		$tree.child[0]
	), Q{'a'};

	ok is-linked( $tree.child[1],
		$tree,
		$tree.child[1],
		$tree.child[0].child[0]
	), Q{'b'};
	ok $tree.child[1].is-end;
}

subtest {
	my $source = Q{(1);2;1};
	my $tree = $pt.to-tree( $source );
	$ppf.thread( $tree );
	is $pt.to-string( $tree ), $source, Q{formatted};

	ok is-linked( $tree, $tree, $tree.child[0], $tree );
	ok $tree.is-root;
	ok $tree.is-start;

	ok is-linked( $tree.child[0],
		$tree,
		$tree.child[0].child[0],
		$tree
	), Q{root};

	ok is-linked( $tree.child[0].child[0],
		$tree.child[0],
		$tree.child[0].child[0].child[0],
		$tree.child[0]
	);
	ok is-linked( $tree.child[0].child[0].child[0],
		$tree.child[0].child[0],
		$tree.child[0].child[0].child[1],
		$tree.child[0].child[0]
	);
	ok is-linked( $tree.child[0].child[0].child[1],
		$tree.child[0].child[0],
		$tree.child[0].child[0].child[2],
		$tree.child[0].child[0].child[0]
	);
	ok is-linked( $tree.child[0].child[0].child[2],
		$tree.child[0].child[0],
		$tree.child[0].child[1],
		$tree.child[0].child[0].child[1]
	);
	ok is-linked( $tree.child[0].child[1],
		$tree.child[0],
		$tree.child[1],
		$tree.child[0].child[0].child[2]
	);
	ok is-linked( $tree.child[1],
		$tree,
		$tree.child[1].child[0],
		$tree.child[0].child[1]
	);
	ok is-linked( $tree.child[1].child[0],
		$tree.child[1],
		$tree.child[1].child[1],
		$tree.child[1]
	);
	ok is-linked( $tree.child[1].child[1],
		$tree.child[1],
		$tree.child[2],
		$tree.child[1].child[0]
	);
	ok is-linked( $tree.child[2],
		$tree,
		$tree.child[2].child[0],
		$tree.child[1].child[1]
	);
	ok is-linked( $tree.child[2].child[0],
		$tree.child[2],
		$tree.child[2].child[0],
		$tree.child[2]
	);
	ok $tree.child[2].child[0].is-end;

	done-testing;
}, Q{leading, trailing ws};

subtest {
	my $source = Q{(1);2;1};
	my $ecruos = Q{1;2;)1(};
	my $tree = $pt.to-tree( $source );
	$ppf.thread( $tree );

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
	my $source = Q{(3);2;1};
	my $ecruos = Q{1;2;(3)};
	my $tree = $pt.to-tree( $source );
	$ppf.thread( $tree );
	my $head = $ppf.flatten( $tree );

	ok $head.parent ~~ Perl6::Document;
	ok $head ~~ Perl6::Document; $head = $head.next;
	ok $head.parent ~~ Perl6::Document;
	ok $head ~~ Perl6::Statement; $head = $head.next;
	ok $head.parent ~~ Perl6::Statement;
	ok $head ~~ Perl6::Operator::Circumfix; $head = $head.next;
	ok $head.parent ~~ Perl6::Operator::Circumfix;
	ok $head ~~ Perl6::Balanced::Enter; $head = $head.next;
	ok $head.parent ~~ Perl6::Operator::Circumfix;
	ok $head ~~ Perl6::Number::Decimal; $head = $head.next;
	ok $head.parent ~~ Perl6::Operator::Circumfix;
	ok $head ~~ Perl6::Balanced::Exit; $head = $head.next;
	ok $head.parent ~~ Perl6::Statement;
	ok $head ~~ Perl6::Semicolon; $head = $head.next;
	ok $head.parent ~~ Perl6::Document;
	ok $head ~~ Perl6::Statement; $head = $head.next;
	ok $head.parent ~~ Perl6::Statement;
	ok $head ~~ Perl6::Number::Decimal; $head = $head.next;
	ok $head.parent ~~ Perl6::Statement;
	ok $head ~~ Perl6::Semicolon; $head = $head.next;
	ok $head.parent ~~ Perl6::Document;
	ok $head ~~ Perl6::Statement; $head = $head.next;
	ok $head.parent ~~ Perl6::Statement;
	ok $head ~~ Perl6::Number::Decimal; $head = $head.next;
	ok $head.is-end;

	done-testing;
}, Q{check flattened data};

# vim: ft=perl6
