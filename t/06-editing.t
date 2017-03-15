use v6;

use Test;
use Perl6::Parser;
use Perl6::Parser::Factory;

plan 5;

my $pt = Perl6::Parser.new;
my $ppf = Perl6::Parser::Factory.new;
my $*CONSISTENCY-CHECK = True;
my $*GRAMMAR-CHECK = True;
my $*UPDATE-RANGES = True;
my $*FALL-THROUGH = True;

sub check-node(
	Perl6::Element $element, Mu $type, Mu $parent, Int $from, Int $to ) {
	my $is-ok = True;
	unless $element ~~ $type {
		diag "expected type '$type', got type '{$element.WHAT.perl}'";
		$is-ok = False;
	}
	unless $element.parent ~~ $parent {
		diag "expected parent '$type', got type '{$element.WHAT.perl}'";
		$is-ok = False;
	}
	unless $element.from == $from {
		diag "expected from $from, got {$element.from}";
		$is-ok = False;
	}
	unless $element.to == $to {
		diag "expected to $to, got {$element.to}";
		$is-ok = False;
	}
	return $is-ok;
}

subtest {
	my $source = Q{(3);2;1};
	my $edited = Q{();2;1};
	my $tree = $pt.to-tree( $source );
	$ppf.thread( $tree );
	my $head = $ppf.flatten( $tree );

	my $walk-me = $head;
	my $integer = $head.next.next.next.next;

	# Remove the current element, and do so non-recursively.
	# That is, if there are elements "under" it in the tree, they'll
	# still be attached somehow.
	#
	$integer.remove-node;

	# Check links going forward and upward.
	#
	ok check-node( $head, Perl6::Document, Perl6::Document, 0, 7 );
	$head = $head.next;

	ok check-node( $head, Perl6::Statement, Perl6::Document, 0, 4 );
	$head = $head.next;

	ok check-node( $head,
		Perl6::Operator::Circumfix, Perl6::Statement, 0, 3 );
	$head = $head.next;

	ok check-node( $head,
		Perl6::Balanced::Enter, Perl6::Operator::Circumfix, 0, 1 );
	$head = $head.next;

#	ok $head ~~ Perl6::Number::Decimal;
#	is $head.from, 2;
#	$head = $head.next;

	ok check-node( $head,
		Perl6::Balanced::Exit, Perl6::Operator::Circumfix, 1, 2 );
	$head = $head.next;

	ok check-node( $head,
		Perl6::Semicolon, Perl6::Statement, 2, 3 );
	$head = $head.next;

	ok check-node( $head,
		Perl6::Statement, Perl6::Document, 3, 5 );
	$head = $head.next;

	ok check-node( $head,
		Perl6::Number::Decimal, Perl6::Statement, 3, 4 );
	$head = $head.next;

	ok check-node( $head,
		Perl6::Semicolon, Perl6::Statement, 4, 5 );
	$head = $head.next;

	ok check-node( $head,
		Perl6::Statement, Perl6::Document, 5, 6 );
	$head = $head.next;

	ok check-node( $head,
		Perl6::Number::Decimal, Perl6::Statement, 6, 7 );
	$head = $head.next;

	ok check-node( $head,
		Perl6::Number::Decimal, Perl6::Statement, 6, 7 );
	ok $head.is-end;

	# Now that we're at the end, throw this baby into reverse.
	#
	ok $head ~~ Perl6::Number::Decimal;     $head = $head.previous;
	ok $head ~~ Perl6::Statement;           $head = $head.previous;
	ok $head ~~ Perl6::Semicolon;           $head = $head.previous;
	ok $head ~~ Perl6::Number;              $head = $head.previous;
	ok $head ~~ Perl6::Statement;           $head = $head.previous;
	ok $head ~~ Perl6::Semicolon;           $head = $head.previous;
	ok $head ~~ Perl6::Balanced::Exit;      $head = $head.previous;
#	ok $head ~~ Perl6::String::Body;        $head = $head.previous;
	ok $head ~~ Perl6::Balanced::Enter;     $head = $head.previous;
	ok $head ~~ Perl6::Operator::Circumfix; $head = $head.previous;;
	ok $head ~~ Perl6::Statement;           $head = $head.previous;
	ok $head ~~ Perl6::Document;            $head = $head.previous;
	ok $head.is-start;

	my $iterated = '';
	while $walk-me {
		$iterated ~= $walk-me.content if $walk-me.is-leaf;
		last if $walk-me.is-end;
		$walk-me = $walk-me.next;
	}
	is $iterated, $edited, Q{edited document};

	done-testing;
}, Q{Remove internal node};

subtest {
	my $source = Q{(3);2;1};
	my $edited = Q{(42);2;1};
	my $tree = $pt.to-tree( $source );
	$ppf.thread( $tree );
	my $head = $ppf.flatten( $tree );

	my $walk-me = $head;
	my $integer = $head.next.next.next.next;

	$integer.replace-node-with(
		Perl6::Number::Decimal.new(
			:from( 1 ),
			:to( 2 ),
			:content( '42' )
		)
	);

	# Check links going forward and upward.
	#
	ok check-node( $head, Perl6::Document, Perl6::Document, 0, 7 );
	$head = $head.next;

	ok check-node( $head, Perl6::Statement, Perl6::Document, 0, 4 );
	$head = $head.next;

	ok check-node( $head,
		Perl6::Operator::Circumfix, Perl6::Statement, 0, 3 );
	$head = $head.next;

	ok check-node( $head,
		Perl6::Balanced::Enter, Perl6::Operator::Circumfix, 0, 1 );
	$head = $head.next;

	ok check-node( $head,
		Perl6::Number::Decimal,
		Perl6::Operator::Circumfix, 1, 2 );
	$head = $head.next;

	ok check-node( $head,
		Perl6::Balanced::Exit, Perl6::Operator::Circumfix, 2, 3 );
	$head = $head.next;

	ok check-node( $head,
		Perl6::Semicolon, Perl6::Statement, 3, 4 );
	$head = $head.next;

	ok check-node( $head,
		Perl6::Statement, Perl6::Document, 4, 6 );
	$head = $head.next;

	ok check-node( $head,
		Perl6::Number::Decimal, Perl6::Statement, 4, 5 );
	$head = $head.next;

	ok check-node( $head,
		Perl6::Semicolon, Perl6::Statement, 5, 6 );
	$head = $head.next;

	ok check-node( $head,
		Perl6::Statement, Perl6::Document, 6, 7 );
	$head = $head.next;

	ok check-node( $head,
		Perl6::Number::Decimal, Perl6::Statement, 6, 7 );
	$head = $head.next;

	ok check-node( $head,
		Perl6::Number::Decimal, Perl6::Statement, 6, 7 );
	ok $head.is-end;

	# Now that we're at the end, throw this baby into reverse.
	#
	ok $head ~~ Perl6::Number::Decimal;     $head = $head.previous;
	ok $head ~~ Perl6::Statement;           $head = $head.previous;
	ok $head ~~ Perl6::Semicolon;           $head = $head.previous;
	ok $head ~~ Perl6::Number;              $head = $head.previous;
	ok $head ~~ Perl6::Statement;           $head = $head.previous;
	ok $head ~~ Perl6::Semicolon;           $head = $head.previous;
	ok $head ~~ Perl6::Balanced::Exit;      $head = $head.previous;
	ok $head ~~ Perl6::Number::Decimal;     $head = $head.previous;
	ok $head ~~ Perl6::Balanced::Enter;     $head = $head.previous;
	ok $head ~~ Perl6::Operator::Circumfix; $head = $head.previous;;
	ok $head ~~ Perl6::Statement;           $head = $head.previous;
	ok $head ~~ Perl6::Document;            $head = $head.previous;
	ok $head.is-start;

	my $iterated = '';
	while $walk-me {
		$iterated ~= $walk-me.content if $walk-me.is-leaf;
		last if $walk-me.is-end;
		$walk-me = $walk-me.next;
	}
	is $iterated, $edited, Q{edited document};

	done-testing;
}, Q{Replace internal node};

subtest {
	my $source = Q{(3);2;1};
	my $edited = Q{(3);2;};
	my $tree = $pt.to-tree( $source );
	$ppf.thread( $tree );
	my $head = $ppf.flatten( $tree );

	my $walk-me = $head;
	my $one = $head;
	$one = $one.next while !$one.is-end;

	# Remove the current element, and do so non-recursively.
	# That is, if there are elements "under" it in the tree, they'll
	# still be attached somehow.
	#
	$one.remove-node;

	ok $head ~~ Perl6::Document;            $head = $head.next;
	ok $head ~~ Perl6::Statement;           $head = $head.next;
	ok $head ~~ Perl6::Operator::Circumfix; $head = $head.next;
	ok $head ~~ Perl6::Balanced::Enter;     $head = $head.next;
	ok $head ~~ Perl6::Number::Decimal;     $head = $head.next;
	ok $head ~~ Perl6::Balanced::Exit;      $head = $head.next;
	ok $head ~~ Perl6::Semicolon;           $head = $head.next;
	ok $head ~~ Perl6::Statement;           $head = $head.next;
	ok $head ~~ Perl6::Number::Decimal;     $head = $head.next;
	ok $head ~~ Perl6::Semicolon;           $head = $head.next;
	ok $head ~~ Perl6::Statement;           $head = $head.next;
#	ok $head ~~ Perl6::Number::Decimal;     $head = $head.next;
	ok $head.is-end;

#	ok $head ~~ Perl6::Number::Decimal;     $head = $head.previous;
	ok $head ~~ Perl6::Statement;           $head = $head.previous;
	ok $head ~~ Perl6::Semicolon;           $head = $head.previous;
	ok $head ~~ Perl6::Number::Decimal;     $head = $head.previous;
	ok $head ~~ Perl6::Statement;           $head = $head.previous;
	ok $head ~~ Perl6::Semicolon;           $head = $head.previous;
	ok $head ~~ Perl6::Balanced::Exit;      $head = $head.previous;
	ok $head ~~ Perl6::Number::Decimal;     $head = $head.previous;
	ok $head ~~ Perl6::Balanced::Enter;     $head = $head.previous;
	ok $head ~~ Perl6::Operator::Circumfix; $head = $head.previous;
	ok $head ~~ Perl6::Statement;           $head = $head.previous;
	ok $head ~~ Perl6::Document;            $head = $head.previous;

	my $iterated = '';
	while $walk-me {
		$iterated ~= $walk-me.content if $walk-me.is-leaf;
		last if $walk-me.is-end;
		$walk-me = $walk-me.next;
	}
	is $iterated, $edited, Q{edited document};

	done-testing;
}, Q{Remove final node};

subtest {
	my $source = Q{();2;1};
	my $edited = Q{(3);2;1};
	my $tree = $pt.to-tree( $source );
	$ppf.thread( $tree );
	my $head = $ppf.flatten( $tree );

	my $walk-me = $head;
	my $start-paren = $head.next.next.next;

	# insert '3' into the parenthesized list.
	#
	$start-paren.insert-node-after(
		Perl6::Number::Decimal.new(
			:from( 0 ),
			:to( 0 ),
			:content( '3' )
		)
	);

	# Check links going forward and upward.
	#
	ok $head ~~ Perl6::Document;            $head = $head.next;
	ok $head.parent ~~ Perl6::Document;    
	ok $head ~~ Perl6::Statement;           $head = $head.next;
	ok $head.parent ~~ Perl6::Statement;
	ok $head ~~ Perl6::Operator::Circumfix; $head = $head.next;
	ok $head.parent ~~ Perl6::Operator::Circumfix;
	ok $head ~~ Perl6::Balanced::Enter;     $head = $head.next;
	ok $head.parent ~~ Perl6::Operator::Circumfix;
	ok $head ~~ Perl6::Number::Decimal;     $head = $head.next;
	ok $head.parent ~~ Perl6::Operator::Circumfix;
	ok $head ~~ Perl6::Balanced::Exit;      $head = $head.next;
	ok $head.parent ~~ Perl6::Statement;
	ok $head ~~ Perl6::Semicolon;           $head = $head.next;
	ok $head.parent ~~ Perl6::Document;    
	ok $head ~~ Perl6::Statement;           $head = $head.next;
	ok $head.parent ~~ Perl6::Statement;
	ok $head ~~ Perl6::Number::Decimal;     $head = $head.next;
	ok $head.parent ~~ Perl6::Statement;   
	ok $head ~~ Perl6::Semicolon;           $head = $head.next;
	ok $head.parent ~~ Perl6::Document;     
	ok $head ~~ Perl6::Statement;           $head = $head.next;
	ok $head.parent ~~ Perl6::Statement;   
	ok $head ~~ Perl6::Number::Decimal;     $head = $head.next;
	ok $head.is-end;

	# Now that we're at the end, throw this baby into reverse.
	#
	ok $head ~~ Perl6::Number::Decimal;     $head = $head.previous;
	ok $head ~~ Perl6::Statement;           $head = $head.previous;
	ok $head ~~ Perl6::Semicolon;           $head = $head.previous;
	ok $head ~~ Perl6::Number;              $head = $head.previous;
	ok $head ~~ Perl6::Statement;           $head = $head.previous;
	ok $head ~~ Perl6::Semicolon;           $head = $head.previous;
	ok $head ~~ Perl6::Balanced::Exit;      $head = $head.previous;
	ok $head ~~ Perl6::Number::Decimal;     $head = $head.previous;
	ok $head ~~ Perl6::Balanced::Enter;     $head = $head.previous;
	ok $head ~~ Perl6::Operator::Circumfix; $head = $head.previous;;
	ok $head ~~ Perl6::Statement;           $head = $head.previous;
	ok $head ~~ Perl6::Document;            $head = $head.previous;
	ok $head.is-start;

	my $iterated = '';
	while $walk-me {
		$iterated ~= $walk-me.content if $walk-me.is-leaf;
		last if $walk-me.is-end;
		$walk-me = $walk-me.next;
	}
	is $iterated, $edited, Q{edited document};

	done-testing;
}, Q{Insert internal node after '('};

subtest {
	my $source = Q{();2;1};
	my $edited = Q{(3);2;1};
	my $tree = $pt.to-tree( $source );
	$ppf.thread( $tree );
	my $head = $ppf.flatten( $tree );

	my $walk-me = $head;
	my $start-paren = $head.next.next.next.next;

	# insert '3' into the parenthesized list.
	#
	$start-paren.insert-node-before(
		Perl6::Number::Decimal.new(
			:from( 0 ),
			:to( 0 ),
			:content( '3' )
		)
	);

	# Check links going forward and upward.
	#
	ok $head ~~ Perl6::Document;            $head = $head.next;
	ok $head.parent ~~ Perl6::Document;    
	ok $head ~~ Perl6::Statement;           $head = $head.next;
	ok $head.parent ~~ Perl6::Statement;
	ok $head ~~ Perl6::Operator::Circumfix; $head = $head.next;
	ok $head.parent ~~ Perl6::Operator::Circumfix;
	ok $head ~~ Perl6::Balanced::Enter;     $head = $head.next;
	ok $head.parent ~~ Perl6::Operator::Circumfix;
	ok $head ~~ Perl6::Number::Decimal;     $head = $head.next;
	ok $head.parent ~~ Perl6::Operator::Circumfix;
	ok $head ~~ Perl6::Balanced::Exit;      $head = $head.next;
	ok $head.parent ~~ Perl6::Statement;
	ok $head ~~ Perl6::Semicolon;           $head = $head.next;
	ok $head.parent ~~ Perl6::Document;    
	ok $head ~~ Perl6::Statement;           $head = $head.next;
	ok $head.parent ~~ Perl6::Statement;
	ok $head ~~ Perl6::Number::Decimal;     $head = $head.next;
	ok $head.parent ~~ Perl6::Statement;   
	ok $head ~~ Perl6::Semicolon;           $head = $head.next;
	ok $head.parent ~~ Perl6::Document;     
	ok $head ~~ Perl6::Statement;           $head = $head.next;
	ok $head.parent ~~ Perl6::Statement;   
	ok $head ~~ Perl6::Number::Decimal;     $head = $head.next;
	ok $head.is-end;

	# Now that we're at the end, throw this baby into reverse.
	#
	ok $head ~~ Perl6::Number::Decimal;     $head = $head.previous;
	ok $head ~~ Perl6::Statement;           $head = $head.previous;
	ok $head ~~ Perl6::Semicolon;           $head = $head.previous;
	ok $head ~~ Perl6::Number;              $head = $head.previous;
	ok $head ~~ Perl6::Statement;           $head = $head.previous;
	ok $head ~~ Perl6::Semicolon;           $head = $head.previous;
	ok $head ~~ Perl6::Balanced::Exit;      $head = $head.previous;
	ok $head ~~ Perl6::Number::Decimal;     $head = $head.previous;
	ok $head ~~ Perl6::Balanced::Enter;     $head = $head.previous;
	ok $head ~~ Perl6::Operator::Circumfix; $head = $head.previous;;
	ok $head ~~ Perl6::Statement;           $head = $head.previous;
	ok $head ~~ Perl6::Document;            $head = $head.previous;
	ok $head.is-start;

	my $iterated = '';
	while $walk-me {
		$iterated ~= $walk-me.content if $walk-me.is-leaf;
		last if $walk-me.is-end;
		$walk-me = $walk-me.next;
	}
	is $iterated, $edited, Q{edited document};

	done-testing;
}, Q{Insert internal node before ')'};

# vim: ft=perl6
