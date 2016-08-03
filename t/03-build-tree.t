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

	my $my_a_b =
		Perl6::Statement.new(
			:child(
				Perl6::Bareword.new( :content( Q{my} ) ),
				Perl6::WS.new( :content( Q{ } ) ),
#				Perl6::List.new(
#					:delimiters( '(', ')' ),
#					:child(
#						Perl6::Variable::Scalar.new( :content( Q{$a} ) ),
#						Perl6::Operator.new( :content( Q{,} ) ),
#						Perl6::WS.new( :content( Q{ } ) ),
#						Perl6::Variable::Scalar.new( :content( Q{$b} ) ),
#					)
#				),
				Perl6::WS.new( :content( Q{ } ) ),
				Perl6::Operator.new( :content( Q{=} ) ),
				Perl6::WS.new( :content( Q{ } ) ),
				Perl6::Variable::Scalar.new( :content( Q{$*IN} ) ),
				Perl6::Operator.new( :content( Q{.} ) ),
				Perl6::Bareword.new( :content( Q{get} ) ),
				Perl6::Operator.new( :content( Q{.} ) ),
				Perl6::Bareword.new( :content( Q{split} ) ),
#				Perl6::List.new(
#					:child(
#						Perl6::String.new( :content( Q{ } ) )
#					)
#				)
			)
		);

	my $say_a_plus_b =
		Perl6::Statement.new(
			:child(
				Perl6::Bareword.new( :content( Q{say} ) ),
				Perl6::WS.new( :content( Q{ } ) ),
				Perl6::Variable::Scalar.new(
					:content( Q{$a} )
				),
				Perl6::WS.new( :content( Q{ } ) ),
				Perl6::Operator.new( :content( Q{+} ) ),
				Perl6::WS.new( :content( Q{ } ) ),
				Perl6::Variable::Scalar.new(
					:content( Q{$b} )
				),
				Perl6::Semicolon.new( :content( Q{;} ) )
			)
		);

#`(
- EXPR: say $a + $b
  - longname: say
    - name: say
      - identifier: say
  - args:  $a + $b
    - arglist: $a + $b
      - EXPR: +
        - 0: $a
          - variable: $a
            - sigil: $
            - desigilname: a
              - longname: a
                - name: a
                  - identifier: a
        - 1: $b
          - variable: $b
            - sigil: $
            - desigilname: b
              - longname: b
                - name: b
                  - identifier: b
        - infix: +
          - sym: +
          - O: <object>
        - OPER: +
          - sym: +
          - O: <object>
)

	my $p = $pt.parse-text( Q:to[_END_] );
my ($a, $b) = $*IN.get.split(" ");
say $a + $b;
_END_
	my $tree = $pt.build-tree( $p );
	is-deeply $tree,
		Perl6::Document.new(
			:child(
#				$my_a_b,
				$say_a_plus_b
			)
		);
}, Q{File with string};

# vim: ft=perl6
