use v6;

use Test;
use Perl6::Tidy;

plan 4;

my $pt = Perl6::Tidy.new;

subtest {
	plan 1;
	
	my $p = $pt.parse-source( Q{} );
	my $t = $pt.build-tree( $p );
	is-deeply $t,
		Perl6::Document.new( :child() ),
	Q{tree built};
}, Q{Empty file};

subtest {
	plan 4;

	my ($p, $t);

	$p = $pt.parse-source( Q{my$a} );
	$t = $pt.build-tree( $p );
	is-deeply $t,
		Perl6::Document.new( :child(
			Perl6::Statement.new( :child(
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

	$p = $pt.parse-source( Q{my $a} );
	$t = $pt.build-tree( $p );
	is-deeply $t,
		Perl6::Document.new( :child(
			Perl6::Statement.new( :child(
				Perl6::Bareword.new(
					:from( 0 ),
					:to( 2 ),
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
	Q{without semi, with ws};

	$p = $pt.parse-source( Q{my$a;} );
	$t = $pt.build-tree( $p );
	is-deeply $t,
		Perl6::Document.new( :child(
			Perl6::Statement.new( :child(
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

	$p = $pt.parse-source( Q{my $a;} );
	$t = $pt.build-tree( $p );
	is-deeply $t,
		Perl6::Document.new( :child(
			Perl6::Statement.new( :child(
				Perl6::Bareword.new(
					:from( 0 ),
					:to( 2 ),
					:content( Q{my} )
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

	my $p = $pt.parse-source( Q{my $a = 1} );
#say $p.hash.<statementlist>.hash.<statement>.list.[0].dump;
	my $t = $pt.build-tree( $p );
	is-deeply $t,
		Perl6::Document.new( :child(
			Perl6::Statement.new( :child(
				Perl6::Bareword.new(
					:from( 0 ),
					:to( 2 ),
					:content( Q{my} )
				),
				Perl6::Variable::Scalar.new(
					:from( 3 ),
					:to( 5 ),
					:sigil( Q{$} ),
					:content( Q{$a} ),
					:headless( Q{a} )
				),
				Perl6::Operator::Infix.new(
					:from( 6 ),
					:to( 7 ),
					:content( Q{=} )
				),
				Perl6::Number::Decimal.new(
					:from( 8 ),
					:to( 9 ),
					:content( 1e0 )
				)
			) )
		) ),
	Q{tree built};
}, Q{Initialization};

subtest {
	plan 1;

	my $p = $pt.parse-source( Q{my $a = 1 + 2} );
#say $p.hash.<statementlist>.hash.<statement>.list.[0].dump;
	my $t = $pt.build-tree( $p );
	is-deeply $t,
		Perl6::Document.new( :child(
			Perl6::Statement.new( :child(
				Perl6::Bareword.new(
					:from( 0 ),
					:to( 2 ),
					:content( Q{my} )
				),
				Perl6::Variable::Scalar.new(
					:from( 3 ),
					:to( 5 ),
					:sigil( Q{$} ),
					:content( Q{$a} ),
					:headless( Q{a} )
				),
				Perl6::Operator::Infix.new(
					:from( 6 ),
					:to( 7 ),
					:content( Q{=} )
				),
				Perl6::Number::Decimal.new(
					:from( 8 ),
					:to( 9 ),
					:content( 1e0 )
				),
				Perl6::Operator::Infix.new(
					:from( 10 ),
					:to( 11 ),
					:content( Q{+} )
				),
				Perl6::Number::Decimal.new(
					:from( 12 ),
					:to( 13 ),
					:content( 2e0 )
				)
			) )
		) ),
	Q{tree built};
}, Q{Initialization};

# vim: ft=perl6
