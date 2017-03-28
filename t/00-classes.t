use v6;

use Test;
use Perl6::Parser;

plan 1;

# Note to future self - classes are in alphabetized order, with subtests for
# child clases *immediately* following the test for their parent class.
#
subtest {
	subtest {
		ok Perl6::Block ~~ Perl6::Element;
		ok Perl6::Document ~~ Perl6::Element;
		ok Perl6::Statement ~~ Perl6::Element;

		done-testing;
	}, Q{Element};

	subtest {
		ok Perl6::Invisible ~~ Perl6::Element;

		subtest {
			ok Perl6::Newline ~~ Perl6::Invisible;
			ok Perl6::WS ~~ Perl6::Invisible;

			done-testing;
		}, Q{Invisible};

		ok Perl6::Visible ~~ Perl6::Element;

		subtest {
			ok Perl6::Adverb ~~ Perl6::Visible;
			ok Perl6::Backslash ~~ Perl6::Visible;
			ok Perl6::Balanced ~~ Perl6::Visible;

			subtest {
				ok Perl6::Balanced::Enter ~~ Perl6::Balanced;
				ok Perl6::Balanced::Exit ~~ Perl6::Balanced;

				done-testing;
			}, Q{Balanced};

			ok Perl6::Bareword ~~ Perl6::Visible;

			subtest {
				ok Perl6::ColonBareword ~~ Perl6::Bareword;

				done-testing;
			}, Q{Bareword};

			ok Perl6::Catch-All ~~ Perl6::Visible;
			ok Perl6::Documentation ~~ Perl6::Visible;

			subtest {
				ok Perl6::Comment ~~ Perl6::Documentation;
				ok Perl6::Pod ~~ Perl6::Documentation;

				done-testing;
			}, Q{Documentation};

			ok Perl6::Infinity ~~ Perl6::Visible;

			ok Perl6::NotANumber ~~ Perl6::Visible;
			ok Perl6::Number ~~ Perl6::Visible;

			subtest {
				ok Perl6::Number::Binary ~~ Perl6::Number;
				ok Perl6::Number::Decimal ~~ Perl6::Number;

				subtest {
					ok Perl6::Number::Decimal::Explicit ~~
						Perl6::Number::Decimal;

					done-testing;
				}, Q{Explicit};

				ok Perl6::Number::FloatingPoint ~~
					Perl6::Number;
				ok Perl6::Number::Hexadecimal ~~ Perl6::Number;
				ok Perl6::Number::Octal ~~ Perl6::Number;

				ok Perl6::Number::Radix ~~ Perl6::Number;

				done-testing;
			}, Q{Number};

			ok Perl6::Operator ~~ Perl6::Visible;
			ok Perl6::PackageName ~~ Perl6::Visible;
			ok Perl6::Regex ~~ Perl6::Visible;
			ok Perl6::Semicolon ~~ Perl6::Visible;
			ok Perl6::Sir-Not-Appearing-In-This-Statement ~~
				Perl6::Visible;
			ok Perl6::String ~~ Perl6::Visible;

			subtest {
				ok Perl6::String::Body ~~ Perl6::String;
				ok Perl6::String::Escaping ~~ Perl6::String;
				ok Perl6::String::Interpolation ~~
					Perl6::String;

				subtest {
					ok Perl6::String::Interpolation::Shell ~~
						Perl6::String::Interpolation;

					done-testing;
				}, Q{Interpolation};

				ok Perl6::String::Literal ~~ Perl6::String;

				subtest {
					ok Perl6::String::Literal::Shell ~~
						Perl6::String::Literal;

					done-testing;
				}, Q{Literal};

				ok Perl6::String::Shell ~~ Perl6::String;

				ok Perl6::String::WordQuoting ~~ Perl6::String;

				subtest {
					ok Perl6::String::WordQuoting::QuoteProtection ~~
						Perl6::String::WordQuoting;

					done-testing;
				}, Q{WordQuoting};

				done-testing;
			}, Q{String};

			ok Perl6::Variable ~~ Perl6::Visible;
			subtest {
				ok Perl6::Variable::Array ~~ Perl6::Variable;

				subtest {
					ok Perl6::Variable::Array::Attribute ~~
						Perl6::Variable::Array;
					ok Perl6::Variable::Array::CompileTime ~~
						Perl6::Variable::Array;
					ok Perl6::Variable::Array::Dynamic ~~
						Perl6::Variable::Array;
					ok Perl6::Variable::Array::MatchIndex ~~
						Perl6::Variable::Array;
					ok Perl6::Variable::Array::Named ~~
						Perl6::Variable::Array;
					ok Perl6::Variable::Array::Pod ~~
						Perl6::Variable::Array;
					ok Perl6::Variable::Array::Positional ~~
						Perl6::Variable::Array;
					ok Perl6::Variable::Array::SubLanguage ~~
						Perl6::Variable::Array;

					done-testing;
				}, Q{Array};

				ok Perl6::Variable::Callable ~~ Perl6::Variable;

				subtest {
					ok Perl6::Variable::Callable::Attribute ~~
						Perl6::Variable::Callable;
					ok Perl6::Variable::Callable::CompileTime ~~
						Perl6::Variable::Callable;
					ok Perl6::Variable::Callable::Dynamic ~~
						Perl6::Variable::Callable;
					ok Perl6::Variable::Callable::MatchIndex ~~
						Perl6::Variable::Callable;
					ok Perl6::Variable::Callable::Named ~~
						Perl6::Variable::Callable;
					ok Perl6::Variable::Callable::Pod ~~
						Perl6::Variable::Callable;
					ok Perl6::Variable::Callable::Positional ~~
						Perl6::Variable::Callable;
					ok Perl6::Variable::Callable::SubLanguage ~~
						Perl6::Variable::Callable;

					done-testing;
				}, Q{Callable};

				ok Perl6::Variable::Hash ~~ Perl6::Variable;

				subtest {
					ok Perl6::Variable::Hash::Attribute ~~
						Perl6::Variable::Hash;
					ok Perl6::Variable::Hash::CompileTime ~~
						Perl6::Variable::Hash;
					ok Perl6::Variable::Hash::Dynamic ~~
						Perl6::Variable::Hash;
					ok Perl6::Variable::Hash::MatchIndex ~~
						Perl6::Variable::Hash;
					ok Perl6::Variable::Hash::Named ~~
						Perl6::Variable::Hash;
					ok Perl6::Variable::Hash::Pod ~~
						Perl6::Variable::Hash;
					ok Perl6::Variable::Hash::Positional ~~
						Perl6::Variable::Hash;
					ok Perl6::Variable::Hash::SubLanguage ~~
						Perl6::Variable::Hash;

					done-testing;
				}, Q{Hash};

				ok Perl6::Variable::Scalar ~~ Perl6::Variable;

				subtest {
					ok Perl6::Variable::Scalar::Accessor ~~
						Perl6::Variable::Scalar;
					ok Perl6::Variable::Scalar::Attribute ~~
						Perl6::Variable::Scalar;
					ok Perl6::Variable::Scalar::CompileTime ~~
						Perl6::Variable::Scalar;
					ok Perl6::Variable::Scalar::Contextualizer ~~
						Perl6::Variable;
					ok Perl6::Variable::Scalar::Dynamic ~~
						Perl6::Variable::Scalar;
					ok Perl6::Variable::Scalar::MatchIndex ~~
						Perl6::Variable::Scalar;
					ok Perl6::Variable::Scalar::Named ~~
						Perl6::Variable::Scalar;
					ok Perl6::Variable::Scalar::Pod ~~
						Perl6::Variable::Scalar;
					ok Perl6::Variable::Scalar::Positional ~~
						Perl6::Variable::Scalar;
					ok Perl6::Variable::Scalar::SubLanguage ~~
						Perl6::Variable::Scalar;

					done-testing;
				}, Q{Scalar};

				done-testing;
			}, Q{Variable};

			ok Perl6::Whatever ~~ Perl6::Visible;

			done-testing;
		}, Q{Visible};

		done-testing;
	}, Q{Element};

	done-testing;
}, Q{Element};

done-testing;

# vim: ft=perl6
