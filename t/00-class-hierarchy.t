use v6;

use Test;
use Perl6::Parser;

use lib 't/lib';
use Utils;

plan 1;

# I've tried to arrange this so one token comes per line.
# Makes it easier to comment out one term at a time.
#
# Or, another way of thinking about it is that commenting out each line
# (excepting those that span multiples) should break a test.
#
# '3.27e5' blows past parser
my $tree = Perl6::Parser.new.to-tree( Q:to[_END_] );
=begin pod

=end pod

1;
0b1;
0o2;
0d3;
0x4;
# Comment - make sure it's not contiguous with a Pod block
:r3<12>;
-0.1;
my $a;
my %a;
my @a;
my &a;
my $*a;
my %*a;
my @*a;
my &*a;
my $=pod;
my %=pod;
my @=pod;
my &=pod;
class Foo {
my $.a;
my %.b;
my @.c;
my &.d;
has $!e;
has %!f;
has @!g;
has &!h;
}
'foo';
"foo";
q{foo};
qq{foo};
qw{foo};
qww{foo};
qqw{foo};
qqx{foo};
qqww{foo};
<foo>;
qx{foo};
qqx{foo};
Q{foo};
Qw{foo};
Qx{foo};
｢foo｣;
q:to[END];
END
Q:to[END];
END

sub foo { };

{ 
say [+] @a;
say ++$a + $a++;
say @a[1];
$a ~~ m{ . };
$a = Inf;
$a = NaN;
};
open 'foo', :r;
_END_

subtest {
  ok Perl6::Element ~~ Mu, Q{has correct parent};
  ok has-a( $tree, Perl6::Element ), Q{found};
  
  subtest {
    ok Perl6::Visible ~~ Perl6::Element, Q{has correct parent};
    ok has-a( $tree, Perl6::Visible ), Q{found};
    
    subtest {
      ok Perl6::Operator ~~ Perl6::Visible, Q{has correct parent};
      ok has-a( $tree, Perl6::Operator ), Q{found};
      
      subtest {
        ok Perl6::Operator::Hyper ~~ Perl6::Operator, Q{has correct parent};
        ok has-a( $tree, Perl6::Operator ), Q{found};
        
        done-testing;
      }, Q{Operator::Hyper};
      
      subtest {
        ok Perl6::Operator::Prefix ~~ Perl6::Operator, Q{has correct parent};
        ok has-a( $tree, Perl6::Operator ), Q{found};
        
        done-testing;
      }, Q{Operator::Prefix};
      
      subtest {
        ok Perl6::Operator::Infix ~~ Perl6::Operator, Q{has correct parent};
        ok has-a( $tree, Perl6::Operator ), Q{found};
        
        done-testing;
      }, Q{Operator::Infix};
      
      subtest {
        ok Perl6::Operator::Postfix ~~ Perl6::Operator, Q{has correct parent};
        ok has-a( $tree, Perl6::Operator ), Q{found};
        
        done-testing;
      }, Q{Operator::Postfix};
      
      subtest {
        ok Perl6::Operator::Circumfix ~~ Perl6::Operator,
           Q{has correct parent};
        ok has-a( $tree, Perl6::Operator ), Q{found};
        
        done-testing;
      }, Q{Operator::Circumfix};
      
      subtest {
        ok Perl6::Operator::PostCircumfix ~~ Perl6::Operator,
           Q{has correct parent};
        ok has-a( $tree, Perl6::Operator ), Q{found};
        
        done-testing;
      }, Q{Operator::PostCircumfix};
      
      done-testing;
    }, Q{Operator};
    
    subtest {
      ok Perl6::String ~~ Perl6::Visible, Q{has correct parent};
      ok has-a( $tree, Perl6::String ), Q{found};
      
      subtest {
        ok Perl6::String::Body ~~ Perl6::String, Q{has correct parent};
        ok has-a( $tree, Perl6::String::Body ), Q{found};
        
        done-testing;
      }, Q{String::Body};
      
      subtest {
        ok Perl6::String::WordQuoting ~~ Perl6::String, Q{has correct parent};
        ok has-a( $tree, Perl6::String::WordQuoting ), Q{found};
        
        subtest {
          ok Perl6::String::WordQuoting::QuoteProtection ~~
             Perl6::String::WordQuoting, Q{has correct parent};
          ok has-a( $tree, Perl6::String::WordQuoting::QuoteProtection ),
             Q{found};
          
          done-testing;
        }, Q{String::WordQuoting::QuoteProtection};
        
        done-testing;
      }, Q{String::WordQuoting};
      
      subtest {
        ok Perl6::String::Interpolation ~~ Perl6::String,
           Q{has correct parent};
        ok has-a( $tree, Perl6::String::Interpolation ), Q{found};
        
        subtest {
          ok Perl6::String::Interpolation::Shell ~~
             Perl6::String::Interpolation,
             Q{has correct parent};
          ok has-a( $tree, Perl6::String::Interpolation::Shell ), Q{found};
          
          done-testing;
        }, Q{String::Interpolation::Shell};
        
        subtest {
          ok Perl6::String::Interpolation::WordQuoting ~~
             Perl6::String::Interpolation, Q{has correct parent};
          ok has-a( $tree, Perl6::String::Interpolation::WordQuoting ),
             Q{found};
          
          subtest {
            ok Perl6::String::Interpolation::WordQuoting::QuoteProtection ~~
               Perl6::String::Interpolation::WordQuoting,
               Q{has correct parent};
            ok has-a(
                 $tree,
                 Perl6::String::Interpolation::WordQuoting::QuoteProtection
               ), Q{found};
            
            done-testing;
          }, Q{String::Interpolation::WordQuoting::QuoteProtection};
          
          done-testing;
        }, Q{String::Interpolation::WordQuoting};
        
        done-testing;
      }, Q{String::Interpolation};
      
      subtest {
        ok Perl6::String::Shell ~~ Perl6::String, Q{has correct parent};
        ok has-a( $tree, Perl6::String::Shell ), Q{found};
        
        done-testing;
      }, Q{String::Shell};
      
      subtest {
        ok Perl6::String::Escaping ~~ Perl6::String, Q{has correct parent};
        ok has-a( $tree, Perl6::String::Escaping ), Q{found};
        
        done-testing;
      }, Q{String::Escaping};
      
      subtest {
        ok Perl6::String::Literal ~~ Perl6::String, Q{has correct parent};
        ok has-a( $tree, Perl6::String::Literal ), Q{found};
        
        subtest {
          ok Perl6::String::Literal::WordQuoting ~~ Perl6::String,
             Q{has correct parent};
          ok has-a( $tree, Perl6::String::Literal::WordQuoting ), Q{found};
          
          done-testing;
        }, Q{String::Literal::WordQuoting};
        
        subtest {
          ok Perl6::String::Literal::Shell ~~ Perl6::String,
             Q{has correct parent};
          ok has-a( $tree, Perl6::String::Literal::Shell ), Q{found};
          
          done-testing;
        }, Q{String::Literal::Shell};
        
        done-testing;
      }, Q{String::Literal};
      
      done-testing;
    }, Q{String};
    
    subtest {
      ok Perl6::Documentation ~~ Perl6::Visible, Q{has correct parent};
      ok has-a( $tree, Perl6::Documentation ), Q{found};
      
      subtest {
        ok Perl6::Pod ~~ Perl6::Documentation, Q{has correct parent};
        ok has-a( $tree, Perl6::Pod ), Q{found};
        
        done-testing;
      }, Q{Pod};
      
      subtest {
        ok Perl6::Comment ~~ Perl6::Documentation, Q{has correct parent};
        ok has-a( $tree, Perl6::Comment ), Q{found};
        
        done-testing;
      }, Q{Comment};
      
      done-testing;
    }, Q{Documentation};
    
    subtest {
      ok Perl6::Balanced ~~ Perl6::Visible, Q{has correct parent};
      ok has-a( $tree, Perl6::Balanced ), Q{found};
      
      subtest {
        ok Perl6::Balanced::Enter ~~ Perl6::Balanced, Q{has correct parent};
        ok has-a( $tree, Perl6::Balanced::Enter ), Q{found};
        
        subtest {
          ok Perl6::Block::Enter ~~ Perl6::Balanced::Enter,
             Q{has correct parent};
          ok has-a( $tree, Perl6::Block::Enter ), Q{found};
          
          done-testing;
        }, Q{Block::Enter};
        
        subtest {
          ok Perl6::String::Enter ~~ Perl6::Balanced::Enter,
             Q{has correct parent};
#`{
          ok has-a( $tree, Perl6::String::Enter ), Q{found};
}
          
          done-testing;
        }, Q{String::Enter};
        
        done-testing;
      }, Q{Balanced::Enter};
      
      subtest {
        ok Perl6::Balanced::Exit ~~ Perl6::Balanced, Q{has correct parent};
        ok has-a( $tree, Perl6::Balanced::Exit ), Q{found};
        
        subtest {
          ok Perl6::Block::Exit ~~ Perl6::Balanced::Exit, Q{has correct parent};
          ok has-a( $tree, Perl6::Block::Exit ), Q{found};
          
          done-testing;
        }, Q{Block::Exit};
        
        subtest {
          ok Perl6::String::Exit ~~ Perl6::Balanced::Exit,
             Q{has correct parent};
#`{
          ok has-a( $tree, Perl6::String::Exit ), Q{found};
}
          
          done-testing;
        }, Q{String::Exit};
        
        done-testing;
      }, Q{Balanced::Exit};
      
      done-testing;
    }, Q{Balanced};
    
    # A proper test makes sure that documents *don't* have these.
    # They shouldn't be generated when validating in tests, and
    # *really* shouldn't be generated by regular code.
    #
    subtest {
      ok Perl6::Catch-All ~~ Perl6::Visible, Q{has correct parent};
      ok !has-a( $tree, Perl6::Catch-All ), Q{found};
      
      done-testing;
    }, Q{Catch-All};
    
    subtest {
      ok Perl6::Whatever ~~ Perl6::Visible, Q{has correct parent};
#`{
      ok has-a( $tree, Perl6::Whatever ), Q{found};
}
      
      done-testing;
    }, Q{Whatever};
    
    subtest {
      ok Perl6::Loop-Separator ~~ Perl6::Visible, Q{has correct parent};
#`{
      ok has-a( $tree, Perl6::Loop-Separator ), Q{found};
}
      
      done-testing;
    }, Q{Loop-Separator};
    
    subtest {
      ok Perl6::Dimension-Separator ~~ Perl6::Visible, Q{has correct parent};
#`{
      ok has-a( $tree, Perl6::Dimension-Separator ), Q{found};
}
      
      done-testing;
    }, Q{Dimension-Separator};
    
    subtest {
      ok Perl6::Semicolon ~~ Perl6::Visible, Q{has correct parent};
      ok has-a( $tree, Perl6::Semicolon ), Q{found};
      
      done-testing;
    }, Q{Semicolon};
    
    subtest {
      ok Perl6::Backslash ~~ Perl6::Visible, Q{has correct parent};
#`{
      ok has-a( $tree, Perl6::Backslash ), Q{found};
}
      
      done-testing;
    }, Q{Backslash};
    
    # XXX is this a bug?... Not really, RTFS to see why.
    subtest {
      ok Perl6::Sir-Not-Appearing-In-This-Statement ~~ Perl6::Visible,
         Q{has correct parent};
      ok has-a( $tree, Perl6::Sir-Not-Appearing-In-This-Statement ), Q{found};
      
      done-testing;
    }, Q{Sir-Not-Appearing-In-This-Statement};
    
    subtest {
      ok Perl6::Number ~~ Perl6::Visible, Q{has correct parent};
      ok has-a( $tree, Perl6::Number ), Q{found};
      
      subtest {
        ok Perl6::Number::Binary ~~ Perl6::Number, Q{has correct parent};
        ok has-a( $tree, Perl6::Number::Binary ), Q{found};
        
        done-testing;
      }, Q{Number::Binary};
      
      subtest {
        ok Perl6::Number::Octal ~~ Perl6::Number, Q{has correct parent};
        ok has-a( $tree, Perl6::Number::Octal ), Q{found};
        
        done-testing;
      }, Q{Number::Octal};
      
      subtest {
        ok Perl6::Number::Decimal ~~ Perl6::Number, Q{has correct parent};
        ok has-a( $tree, Perl6::Number::Decimal ), Q{found};
        
        subtest {
          ok Perl6::Number::Decimal::Explicit ~~ Perl6::Number::Decimal,
             Q{has correct parent};
#`{
          ok has-a( $tree, Perl6::Number::Decimal::Explicit), Q{found};
}
          
          done-testing;
        }, Q{Number::Decimal::Explicit};
        
        done-testing;
      }, Q{Number::Decimal};
      
      subtest {
        ok Perl6::Number::Hexadecimal ~~ Perl6::Number, Q{has correct parent};
        ok has-a( $tree, Perl6::Number::Hexadecimal ), Q{found};
        
        done-testing;
      }, Q{Number::Hexadecimal};
      
      subtest {
        ok Perl6::Number::Radix ~~ Perl6::Number, Q{has correct parent};
#`{
        ok has-a( $tree, Perl6::Number::Radix ), Q{found};
}
        
        done-testing;
      }, Q{Number::Radix};
      
      subtest {
        ok Perl6::Number::FloatingPoint ~~ Perl6::Number, Q{has correct parent};
        ok has-a( $tree, Perl6::Number::FloatingPoint ), Q{found};
        
        done-testing;
      }, Q{Number::FloatingPoint};
      
      done-testing;
    }, Q{Number};
    
    subtest {
      ok Perl6::NotANumber ~~ Perl6::Visible, Q{has correct parent};
      ok has-a( $tree, Perl6::NotANumber ), Q{found};
      
      done-testing;
    }, Q{NotANumber};
    
    subtest {
      ok Perl6::Infinity ~~ Perl6::Visible, Q{has correct parent};
      ok has-a( $tree, Perl6::Infinity ), Q{found};
      
      done-testing;
    }, Q{Infinity};
    
    subtest {
      ok Perl6::Regex ~~ Perl6::Visible, Q{has correct parent};
      ok has-a( $tree, Perl6::Regex ), Q{found};
      
      done-testing;
    }, Q{Regex};
    
    subtest {
      ok Perl6::Bareword ~~ Perl6::Visible, Q{has correct parent};
      ok has-a( $tree, Perl6::Bareword ), Q{found};
      
      subtest {
        ok Perl6::SubroutineDeclaration ~~ Perl6::Bareword,
           Q{has correct parent};
        ok has-a( $tree, Perl6::SubroutineDeclaration ), Q{found};
        
        done-testing;
      }, Q{SubroutineDeclaration};
      
      subtest {
        ok Perl6::ColonBareword ~~ Perl6::Bareword, Q{has correct parent};
        ok has-a( $tree, Perl6::ColonBareword ), Q{found};
        
        done-testing;
      }, Q{ColonBareword};
      
      done-testing;
    }, Q{Bareword};
    
    subtest {
      ok Perl6::Adverb ~~ Perl6::Visible, Q{has correct parent};
#`{
      ok has-a( $tree, Perl6::Adverb ), Q{found};
}
    
      done-testing;
    }, Q{Adverb};
    
    subtest {
      ok Perl6::PackageName ~~ Perl6::Visible, Q{has correct parent};
#`{
      ok has-a( $tree, Perl6::PackageName ), Q{found};
}
      
      done-testing;
    }, Q{PackageName};
    
    subtest {
      ok Perl6::Variable ~~ Perl6::Visible, Q{has correct parent};
      ok has-a( $tree, Perl6::Variable ), Q{found};
      
      subtest {
        ok Perl6::Variable::Scalar ~~ Perl6::Variable, Q{has correct parent};
        ok has-a( $tree, Perl6::Variable::Scalar ), Q{found};
        
        subtest {
          ok Perl6::Variable::Scalar::Contextualizer ~~ Perl6::Variable::Scalar,
             Q{has correct parent};
#`{
          ok has-a( $tree, Perl6::Variable::Scalar::Contextualizer ), Q{found};
}
          
          done-testing;
        }, Q{Variable::Scalar::Contextualizer};
        
        subtest {
          ok Perl6::Variable::Scalar::Dynamic ~~ Perl6::Variable::Scalar,
             Q{has correct parent};
          ok has-a( $tree, Perl6::Variable::Scalar::Dynamic ), Q{found};
          
          done-testing;
        }, Q{Variable::Scalar::Dynamic};
        
        subtest {
          ok Perl6::Variable::Scalar::Attribute ~~ Perl6::Variable::Scalar,
             Q{has correct parent};
          ok has-a( $tree, Perl6::Variable::Scalar::Attribute ), Q{found};
          
          done-testing;
        }, Q{Variable::Scalar::Attribute};
        
        subtest {
          ok Perl6::Variable::Scalar::Accessor ~~ Perl6::Variable::Scalar,
             Q{has correct parent};
          ok has-a( $tree, Perl6::Variable::Scalar::Accessor ), Q{found};
          
          done-testing;
        }, Q{Variable::Scalar::Accessor};
        
        subtest {
          ok Perl6::Variable::Scalar::CompileTime ~~ Perl6::Variable::Scalar,
             Q{has correct parent};
#`{
          ok has-a( $tree, Perl6::Variable::Scalar::CompileTime ), Q{found};
}
          
          done-testing;
        }, Q{Variable::Scalar::CompileTime};
        
        subtest {
          ok Perl6::Variable::Scalar::MatchIndex ~~ Perl6::Variable::Scalar,
             Q{has correct parent};
#`{
          ok has-a( $tree, Perl6::Variable::Scalar::MatchIndex ), Q{found};
}
          
          done-testing;
        }, Q{Variable::Scalar::MatchIndex};
        
        subtest {
          ok Perl6::Variable::Scalar::Positional ~~ Perl6::Variable::Scalar,
             Q{has correct parent};
#`{
          ok has-a( $tree, Perl6::Variable::Scalar::Positional ), Q{found};
}
          
          done-testing;
        }, Q{Variable::Scalar::Positional};
        
        subtest {
          ok Perl6::Variable::Scalar::Named ~~ Perl6::Variable::Scalar,
             Q{has correct parent};
#`{
          ok has-a( $tree, Perl6::Variable::Scalar::Named ), Q{found};
}
        
          done-testing;
        }, Q{Variable::Scalar::Named};
        
        subtest {
          ok Perl6::Variable::Scalar::Pod ~~ Perl6::Variable::Scalar,
             Q{has correct parent};
          ok has-a( $tree, Perl6::Variable::Scalar::Pod ), Q{found};
          
          done-testing;
        }, Q{Variable::Scalar::Pod};
        
        subtest {
          ok Perl6::Variable::Scalar::SubLanguage ~~ Perl6::Variable::Scalar,
             Q{has correct parent};
#`{
          ok has-a( $tree, Perl6::Variable::Scalar::SubLanguage ), Q{found};
}
          
          done-testing;
        }, Q{Variable::Scalar::SubLanguage};
        
        done-testing;
      }, Q{Variable::Scalar};
      
      subtest {
        ok Perl6::Variable::Array ~~ Perl6::Variable, Q{has correct parent};
        ok has-a( $tree, Perl6::Variable::Array ), Q{found};
        
#        subtest {
#          ok Perl6::Variable::Array::Contextualizer ~~ Perl6::Variable::Array,
#             Q{has correct parent};
#          ok has-a( $tree, Perl6::Variable::Array::Contextualizer ), Q{found};
#          
#          done-testing;
#        }, Q{Variable::Array::Contextualizer};
        
        subtest {
          ok Perl6::Variable::Array::Dynamic ~~ Perl6::Variable::Array,
             Q{has correct parent};
          ok has-a( $tree, Perl6::Variable::Array::Dynamic ), Q{found};
          
          done-testing;
        }, Q{Variable::Array::Dynamic};
        
        subtest {
          ok Perl6::Variable::Array::Attribute ~~ Perl6::Variable::Array,
             Q{has correct parent};
          ok has-a( $tree, Perl6::Variable::Array::Attribute ), Q{found};
          
          done-testing;
        }, Q{Variable::Array::Attribute};
        
        subtest {
          ok Perl6::Variable::Array::Accessor ~~ Perl6::Variable::Array,
             Q{has correct parent};
          ok has-a( $tree, Perl6::Variable::Array::Accessor ), Q{found};
          
          done-testing;
        }, Q{Variable::Array::Accessor};
        
        subtest {
          ok Perl6::Variable::Array::CompileTime ~~ Perl6::Variable::Array,
             Q{has correct parent};
#`{
          ok has-a( $tree, Perl6::Variable::Array::CompileTime ), Q{found};
}
          
          done-testing;
        }, Q{Variable::Array::CompileTime};
        
        subtest {
          ok Perl6::Variable::Array::MatchIndex ~~ Perl6::Variable::Array,
             Q{has correct parent};
#`{
          ok has-a( $tree, Perl6::Variable::Array::MatchIndex ), Q{found};
}
          
          done-testing;
        }, Q{Variable::Array::MatchIndex};
        
        subtest {
          ok Perl6::Variable::Array::Positional ~~ Perl6::Variable::Array,
             Q{has correct parent};
#`{
          ok has-a( $tree, Perl6::Variable::Array::Positional ), Q{found};
}
          
          done-testing;
        }, Q{Variable::Array::Positional};
        
        subtest {
          ok Perl6::Variable::Array::Named ~~ Perl6::Variable::Array,
             Q{has correct parent};
#`{
          ok has-a( $tree, Perl6::Variable::Array::Named ), Q{found};
}
        
          done-testing;
        }, Q{Variable::Array::Named};
        
        subtest {
          ok Perl6::Variable::Array::Pod ~~ Perl6::Variable::Array,
             Q{has correct parent};
          ok has-a( $tree, Perl6::Variable::Array::Pod ), Q{found};
          
          done-testing;
        }, Q{Variable::Array::Pod};
        
        subtest {
          ok Perl6::Variable::Array::SubLanguage ~~ Perl6::Variable::Array,
             Q{has correct parent};
#`{
          ok has-a( $tree, Perl6::Variable::Array::SubLanguage ), Q{found};
}
          
          done-testing;
        }, Q{Variable::Array::SubLanguage};
        
        
        done-testing;
      }, Q{Variable::Array};
      
      subtest {
        ok Perl6::Variable::Hash ~~ Perl6::Variable, Q{has correct parent};
        ok has-a( $tree, Perl6::Variable::Hash ), Q{found};
        
#	subtest {
#         ok Perl6::Variable::Hash::Contextualizer ~~ Perl6::Variable::Hash,
#            Q{has correct parent};
#         ok has-a( $tree, Perl6::Variable::Hash::Contextualizer ), Q{found};
#         
#         done-testing;
#	}, Q{Variable::Hash::Contextualizer};
        
        subtest {
          ok Perl6::Variable::Hash::Dynamic ~~ Perl6::Variable::Hash,
             Q{has correct parent};
          ok has-a( $tree, Perl6::Variable::Hash::Dynamic ), Q{found};
          
          done-testing;
        }, Q{Variable::Hash::Dynamic};
        
        subtest {
          ok Perl6::Variable::Hash::Attribute ~~ Perl6::Variable::Hash,
             Q{has correct parent};
 	  ok has-a( $tree, Perl6::Variable::Hash::Attribute ), Q{found};
        
          done-testing;
        }, Q{Variable::Hash::Attribute};
        
        subtest {
          ok Perl6::Variable::Hash::Accessor ~~ Perl6::Variable::Hash,
             Q{has correct parent};
          ok has-a( $tree, Perl6::Variable::Hash::Accessor ), Q{found};
          
          done-testing;
        }, Q{Variable::Hash::Accessor};
        
        subtest {
          ok Perl6::Variable::Hash::CompileTime ~~ Perl6::Variable::Hash,
             Q{has correct parent};
#`{
          ok has-a( $tree, Perl6::Variable::Hash::CompileTime ), Q{found};
}
        
          done-testing;
        }, Q{Variable::Hash::CompileTime};
        
        subtest {
          ok Perl6::Variable::Hash::MatchIndex ~~ Perl6::Variable::Hash,
             Q{has correct parent};
#`{
          ok has-a( $tree, Perl6::Variable::Hash::MatchIndex ), Q{found};
}
        
          done-testing;
        }, Q{Variable::Hash::MatchIndex};
        
        subtest {
          ok Perl6::Variable::Hash::Positional ~~ Perl6::Variable::Hash,
             Q{has correct parent};
#`{
          ok has-a( $tree, Perl6::Variable::Hash::Positional ),	Q{found};
}
          
          done-testing;
        }, Q{Variable::Hash::Positional};
        
        subtest {
          ok Perl6::Variable::Hash::Named ~~ Perl6::Variable::Hash,
             Q{has correct parent};
#`{
          ok has-a( $tree, Perl6::Variable::Hash::Named ), Q{found};
}
          
          done-testing;
        }, Q{Variable::Hash::Named};
        
        subtest {
          ok Perl6::Variable::Hash::Pod ~~ Perl6::Variable::Hash,
             Q{has correct parent};
          ok has-a( $tree, Perl6::Variable::Hash::Pod ), Q{found};
          
          done-testing;
        }, Q{Variable::Hash::Pod};
        
        subtest {
          ok Perl6::Variable::Hash::SubLanguage ~~ Perl6::Variable::Hash,
             Q{has correct parent};
#`{
 	  ok has-a( $tree, Perl6::Variable::Hash::SubLanguage ), Q{found};
}
          
          done-testing;
        }, Q{Variable::Hash::SubLanguage};
        
        done-testing;
      }, Q{Variable::Hash};
      
      subtest {
        ok Perl6::Variable::Callable ~~ Perl6::Variable, Q{has correct parent};
        ok has-a( $tree, Perl6::Variable::Callable ), Q{found};
        
#	subtest {
#	  ok Perl6::Variable::Callable::Contextualizer ~~ Perl6::Variable::Callable,
#	  Q{has correct parent};
#	  ok has-a( $tree, Perl6::Variable::Callable::Contextualizer ),
#	     Q{found};
#
#	  done-testing;
#	}, Q{Variable::Callable::Contextualizer};
        
        subtest {
          ok Perl6::Variable::Callable::Dynamic ~~ Perl6::Variable::Callable,
             Q{has correct parent};
          ok has-a( $tree, Perl6::Variable::Callable::Dynamic ), Q{found};
          
          done-testing;
        }, Q{Variable::Callable::Dynamic};
        
        subtest {
          ok Perl6::Variable::Callable::Attribute ~~ Perl6::Variable::Callable,
             Q{has correct parent};
          ok has-a( $tree, Perl6::Variable::Callable::Attribute ), Q{found};
          
          done-testing;
        }, Q{Variable::Callable::Attribute};
        
        subtest {
          ok Perl6::Variable::Callable::Accessor ~~ Perl6::Variable::Callable,
             Q{has correct parent};
          ok has-a( $tree, Perl6::Variable::Callable::Accessor ), Q{found};
          
          done-testing;
        }, Q{Variable::Callable::Accessor};
        
        subtest {
          ok Perl6::Variable::Callable::CompileTime ~~
             Perl6::Variable::Callable,
             Q{has correct parent};
#`{
          ok has-a( $tree, Perl6::Variable::Callable::CompileTime ), Q{found};
}
          
          done-testing;
        }, Q{Variable::Callable::CompileTime};
        
        subtest {
          ok Perl6::Variable::Callable::MatchIndex ~~ Perl6::Variable::Callable,
             Q{has correct parent};
#`{
          ok has-a( $tree, Perl6::Variable::Callable::MatchIndex ), Q{found};
}
          
          done-testing;
        }, Q{Variable::Callable::MatchIndex};
        
        subtest {
          ok Perl6::Variable::Callable::Positional ~~ Perl6::Variable::Callable,
             Q{has correct parent};
#`{
          ok has-a( $tree, Perl6::Variable::Callable::Positional ), Q{found};
}
          
          done-testing;
        }, Q{Variable::Callable::Positional};
        
        subtest {
          ok Perl6::Variable::Callable::Named ~~ Perl6::Variable::Callable,
             Q{has correct parent};
#`{
          ok has-a( $tree, Perl6::Variable::Callable::Named ), Q{found};
}

          done-testing;
        }, Q{Variable::Callable::Named};
        
        subtest {
          ok Perl6::Variable::Callable::Pod ~~ Perl6::Variable::Callable,
             Q{has correct parent};
          ok has-a( $tree, Perl6::Variable::Callable::Pod ), Q{found};
          
          done-testing;
        }, Q{Variable::Callable::Pod};
        
        subtest {
          ok Perl6::Variable::Callable::SubLanguage ~~
             Perl6::Variable::Callable,
             Q{has correct parent};
#`{
          ok has-a( $tree, Perl6::Variable::Callable::SubLanguage ), Q{found};
}
          
          done-testing;
        }, Q{Variable::Callable::SubLanguage};
        
        done-testing;
      }, Q{Variable::Callable};
      
      done-testing;
    }, Q{Variable};
    
    done-testing;
  }, Q{Visible};
  
  subtest {
    ok Perl6::Invisible ~~ Perl6::Element, Q{has correct parent};
    ok has-a( $tree, Perl6::Invisible ), Q{found};
  
    subtest {
      ok Perl6::WS ~~ Perl6::Invisible, Q{has correct parent};
      ok has-a( $tree, Perl6::Document ), Q{found};
  
      done-testing;
    }, Q{WS};
  
    subtest {
      ok Perl6::Newline ~~ Perl6::Invisible, Q{has correct parent};
      ok has-a( $tree, Perl6::Document ), Q{found};
  
      done-testing;
    }, Q{Newline};
  
    done-testing;
  }, Q{Invisible};
  
  subtest {
    ok Perl6::Document ~~ Perl6::Element, Q{has correct parent};
    ok has-a( $tree, Perl6::Document ), Q{found};
  
    done-testing;
  }, Q{Document};
  
  subtest {
    ok Perl6::Statement ~~ Perl6::Element, Q{has correct parent};
    ok has-a( $tree, Perl6::Statement ), Q{found};
  
    done-testing;
  }, Q{Statement};
  
  subtest {
    ok Perl6::Block ~~ Perl6::Element, Q{has correct parent};
    ok has-a( $tree, Perl6::Block ), Q{found};
  
    done-testing;
  }, Q{Block};
  
  done-testing;
}, Q{Element};

done-testing;

# vim: ft=perl6
