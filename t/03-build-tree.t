use v6;

use Test;
use Perl6::Tidy;

plan 5;

my $pt = Perl6::Tidy.new;

subtest {
	plan 1;
	
	my $p = $pt.parse-source( Q{} );
	my $t = $pt.build-tree( $p );
	is-deeply $t,
		Perl6::Document.new( :from( 0 ), :to( 0 ), :child() ),
	Q{tree built};
}, Q{no ws};

subtest {
	plan 1;
	
	my $p = $pt.parse-source( Q{ } );
	my $t = $pt.build-tree( $p );
	is-deeply $t,
		Perl6::Document.new( :from( 0 ), :to( 1 ), :child(
			Perl6::Statement.new( :from( 0 ), :to( 1 ), :child(
				Perl6::WS.new(
					:from( 0 ),
					:to( 1 ),
					:content( Q{ } )
				)
			) )
		) ),
	Q{tree built};
}, Q{ws};

subtest {
	plan 5;

	my ($p, $t);

	#                        0123
	$p = $pt.parse-source( Q{my$a} );
	$t = $pt.build-tree( $p );
	is-deeply $t,
		Perl6::Document.new( :from( 0 ), :to( 4 ), :child(
			Perl6::Statement.new( :from( 0 ), :to( 4 ), :child(
				Perl6::Bareword.new(
					:from( 0 ),
					:to( 2 ),
					:content( Q{my} )
				),
				Perl6::Variable::Scalar.new(
					:from( 2 ),
					:to( 4 ),
					:sigil( Q{$} ),
					:content( Q{$a} ),
					:headless( Q{a} )
				)
			) )
		) ),
	Q{without semi, without ws};

	#                        01234
	$p = $pt.parse-source( Q{ my$a} );
	$t = $pt.build-tree( $p );
	is-deeply $t,
		Perl6::Document.new( :from( 0 ), :to( 5 ) :child(
			Perl6::Statement.new( :from( 0 ), :to( 5 ), :child(
				Perl6::WS.new(
					:from( 0 ),
					:to( 1 ),
					:content( Q{ } )
				),
				Perl6::Bareword.new(
					:from( 1 ),
					:to( 3 ),
					:content( Q{my} )
				),
				Perl6::Variable::Scalar.new(
					:from( 3 ),
					:to( 5 ),
					:sigil( Q{$} ),
					:content( Q{$a} ),
					:headless( Q{a} )
				)
			) )
		) ),
	Q{leading ws};

	#                        01234
	$p = $pt.parse-source( Q{my $a} );
	$t = $pt.build-tree( $p );
	is-deeply $t,
		Perl6::Document.new( :from( 0 ), :to( 5 ), :child(
			Perl6::Statement.new( :from( 0 ), :to( 5 ), :child(
				Perl6::Bareword.new(
					:from( 0 ),
					:to( 2 ),
					:content( Q{my} )
				),
				Perl6::WS.new(
					:from( 2 ),
					:to( 3 ),
					:content( Q{ } )
				),
				Perl6::Variable::Scalar.new(
					:from( 3 ),
					:to( 5 ),
					:sigil( Q{$} ),
					:content( Q{$a} ),
					:headless( Q{a} )
				)
			) )
		) ),
	Q{without semi, with ws};

	#                        01234
	$p = $pt.parse-source( Q{my$a;} );
	$t = $pt.build-tree( $p );
	is-deeply $t,
		Perl6::Document.new( :from( 0 ), :to( 5 ), :child(
			Perl6::Statement.new( :from( 0 ), :to( 5 ), :child(
				Perl6::Bareword.new(
					:from( 0 ),
					:to( 2 ),
					:content( Q{my} )
				),
				Perl6::Variable::Scalar.new(
					:from( 2 ),
					:to( 4 ),
					:sigil( Q{$} ),
					:content( Q{$a} ),
					:headless( Q{a} )
				),
				Perl6::Semicolon.new(
					:from( 4 ),
					:to( 5 ),
					:content( Q{;} )
				)
			) )
		) ),
	Q{with semi, without ws};

	#                        012345
	$p = $pt.parse-source( Q{my $a;} );
	$t = $pt.build-tree( $p );
	is-deeply $t,
		Perl6::Document.new( :from( 0 ), :to( 6 ), :child(
			Perl6::Statement.new( :from( 0 ), :to( 6 ), :child(
				Perl6::Bareword.new(
					:from( 0 ),
					:to( 2 ),
					:content( Q{my} )
				),
				Perl6::WS.new(
					:from( 2 ),
					:to( 3 ),
					:content( Q{ } )
				),
				Perl6::Variable::Scalar.new(
					:from( 3 ),
					:to( 5 ),
					:sigil( Q{$} ),
					:content( Q{$a} ),
					:headless( Q{a} )
				),
				Perl6::Semicolon.new(
					:from( 5 ),
					:to( 6 ),
					:content( Q{;} )
				)
			) )
		) ),
	Q{with semi, ws};
}, Q{Declaration, ws/semi permutations};

subtest {
	plan 1;

	#                           012345678
	my $p = $pt.parse-source( Q{my $a = 1} );
	my $t = $pt.build-tree( $p );
	is-deeply $t,
		Perl6::Document.new( :from( 0 ), :to( 9 ), :child(
			Perl6::Statement.new( :from( 0 ), :to( 9 ), :child(
				Perl6::Bareword.new(
					:from( 0 ),
					:to( 2 ),
					:content( Q{my} )
				),
				Perl6::WS.new(
					:from( 2 ),
					:to( 3 ),
					:content( Q{ } )
				),
				Perl6::Variable::Scalar.new(
					:from( 3 ),
					:to( 5 ),
					:sigil( Q{$} ),
					:content( Q{$a} ),
					:headless( Q{a} )
				),
				Perl6::WS.new(
					:from( 5 ),
					:to( 6 ),
					:content( Q{ } )
				),
				Perl6::Operator::Infix.new(
					:from( 6 ),
					:to( 7 ),
					:content( Q{=} )
				),
				Perl6::WS.new(
					:from( 7 ),
					:to( 8 ),
					:content( Q{ } )
				),
				Perl6::Number::Decimal.new(
					:from( 8 ),
					:to( 9 ),
					:content( '1' )
				)
			) )
		) ),
	Q{tree built};
}, Q{Initialization};

subtest {
	plan 2;

	subtest {
		plan 1;

		#                           01234567
		my $p = $pt.parse-source( Q{my$a=1+2} );
		my $t = $pt.build-tree( $p );
		is-deeply $t,
			Perl6::Document.new( :from( 0 ), :to( 8 ), :child(
				Perl6::Statement.new( :from( 0 ), :to( 8 ), :child(
					Perl6::Bareword.new(
						:from( 0 ),
						:to( 2 ),
						:content( Q{my} )
					),
					Perl6::Variable::Scalar.new(
						:from( 2 ),
						:to( 4 ),
						:sigil( Q{$} ),
						:content( Q{$a} ),
						:headless( Q{a} )
					),
					Perl6::Operator::Infix.new(
						:from( 4 ),
						:to( 5 ),
						:content( Q{=} )
					),
					Perl6::Number::Decimal.new(
						:from( 5 ),
						:to( 6 ),
						:content( '1' )
					),
					Perl6::Operator::Infix.new(
						:from( 6 ),
						:to( 7 ),
						:content( Q{+} )
					),
					Perl6::Number::Decimal.new(
						:from( 7 ),
						:to( 8 ),
						:content( '2' )
					)
				) )
			) ),
		Q{tree built};
	}, Q{no ws};

	subtest {
		plan 0;

#`(
		#                                     1  
		#                           0123456789012
		my $p = $pt.parse-source( Q{my $a = 1 + 2} );
		my $t = $pt.build-tree( $p );
		is-deeply $t,
			Perl6::Document.new( :from( 0 ), :to( 13 ), :child(
				Perl6::Statement.new( :from( 0 ), :to( 13 ), :child(
					Perl6::Bareword.new(
						:from( 0 ),
						:to( 2 ),
						:content( Q{my} )
					),
					Perl6::WS.new(
						:from( 2 ),
						:to( 3 ),
						:content( Q{ } )
					),
					Perl6::Variable::Scalar.new(
						:from( 3 ),
						:to( 5 ),
						:sigil( Q{$} ),
						:content( Q{$a} ),
						:headless( Q{a} )
					),
					Perl6::WS.new(
						:from( 5 ),
						:to( 6 ),
						:content( Q{ } )
					),
					Perl6::Operator::Infix.new(
						:from( 6 ),
						:to( 7 ),
						:content( Q{=} )
					),
					Perl6::WS.new(
						:from( 7 ),
						:to( 8 ),
						:content( Q{ } )
					),
					Perl6::Number::Decimal.new(
						:from( 8 ),
						:to( 9 ),
						:content( '1' )
					),
					Perl6::WS.new(
						:from( 9 ),
						:to( 10 ),
						:content( Q{ } )
					),
					Perl6::Operator::Infix.new(
						:from( 10 ),
						:to( 11 ),
						:content( Q{+} )
					),
					Perl6::WS.new(
						:from( 11 ),
						:to( 12 ),
						:content( Q{ } )
					),
					Perl6::Number::Decimal.new(
						:from( 12 ),
						:to( 13 ),
						:content( '2' )
					)
				) )
			) ),
		Q{tree built};
)
	}, Q{ws};
}, Q{Initialization};

# vim: ft=perl6
