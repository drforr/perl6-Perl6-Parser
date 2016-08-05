use v6;

use Test;
use Perl6::Tidy;

plan 2;

my $pt = Perl6::Tidy.new;
#my $*TRACE = 1;
#my $*DEBUG = 1;

subtest {
	plan 1;
	
	my $p = $pt.parse-text( Q{} );
	my $t = $pt.build-tree( $p );
	is-deeply $t,
		Perl6::Document.new( :child() ),
	Q{tree built};
}, Q{Empty file};

subtest {
	plan 1;

	my $p = $pt.parse-text( Q{my $a} );
	my $t = $pt.build-tree( $p );
	is-deeply $t,
		Perl6::Document.new( :child(
			Perl6::Statement.new( :child(
				Perl6::Bareword.new( :content( Q{my} ) ),
				Perl6::WS.new( :content( Q{ } ) ),
				Perl6::Variable::Scalar.new(
					:sigil( Q{$} ),
					:content( Q{$a} ),
					:headless( Q{a} )
				)
			) )
		) ),
	Q{tree built};
}, Q{Declaration};

subtest {
	plan 1;

	my $p = $pt.parse-text( Q{my $a = 1} );
say $p.hash.<statementlist>.hash.<statement>.list.[0].dump;
	my $t = $pt.build-tree( $p );
	is-deeply $t,
		Perl6::Document.new( :child(
			Perl6::Statement.new( :child(
				Perl6::Bareword.new( :content( Q{my} ) ),
				Perl6::WS.new( :content( Q{ } ) ),
				Perl6::Variable::Scalar.new(
					:sigil( Q{$} ),
					:content( Q{$a} ),
					:headless( Q{a} )
				),
				Perl6::WS.new( :content( Q{ } ) ),
				Perl6::Operator.new( :content( Q{=} ) ),
				Perl6::WS.new( :content( Q{ } ) ),
				Perl6::Number::Decimal.new( :content( Q{1} ) )
			) )
		) ),
	Q{tree built};
}, Q{Initialization};

# vim: ft=perl6
