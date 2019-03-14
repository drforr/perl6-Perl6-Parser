use v6;

use Test;
use Perl6::Parser;

use lib 't/lib/';
use Utils;

plan 3;

my $*CONSISTENCY-CHECK = True;
my $*FALL-THROUGH      = True;

# The terms that get tested here are:
#
# enum <name> "foo"
# subset <name> of Type
# constant <name> = 1

subtest {
  plan 3;
  
  subtest {
    my $pp     = Perl6::Parser.new;
    my $source = gensym-package Q:to[_END_];
    enum %s()
    _END_
    
    my $tree   = $pp.to-tree( $source );
    
    ok has-a( $tree, Perl6::Bareword ), Q{'my'};
    ok has-a( $tree, Perl6::WS ), Q{' '};
    ok has-a( $tree, Perl6::Bareword ), Q{Foo%s};
    ok has-a( $tree, Perl6::Operator::Circumfix) , q{open};
    ok has-a( $tree, Perl6::Balanced::Enter ), Q{enter brace};
    ok has-a( $tree, Perl6::Balanced::Exit ), Q{exit brace};
    ok has-a( $tree, Perl6::Newline ), Q{\n};
    
    done-testing;
  }, Q{Check the token structure};
  
  subtest {
    plan 4;
    
    ok round-trips( gensym-package Q:to[_END_] ), Q{no ws};
    enum %s()
    _END_
    
    ok round-trips( gensym-package Q:to[_END_] ), Q{leading ws};
    enum %s     ()
    _END_
    
    ok round-trips( gensym-package Q{enum %s()  } ), Q{trailing ws};
    
    ok round-trips( gensym-package Q{enum %s     ()  } ),
    	Q{leading, trailing ws};
  }, Q{no intrabrace spacing};
  
  subtest {
    plan 4;
    
    ok round-trips( gensym-package Q:to[_END_] ), Q{no ws};
    enum %s(   )
    _END_
    
    ok round-trips( gensym-package Q:to[_END_] ), Q{leading ws};
    enum %s     (   )
    _END_
    
    ok round-trips( gensym-package Q{enum %s(   )  } ), Q{trailing ws};
    
    ok round-trips( gensym-package Q{enum %s     (   )  } ),
    	Q{leading, trailing ws};
  }, Q{intrabrace spacing};
}, Q{enum};

subtest {
  plan 2;
  
  subtest {
    plan 2;
    
    ok round-trips( gensym-package Q:to[_END_] ), Q{no ws};
    subset %s of Int
    _END_
    
    ok round-trips( gensym-package Q{subset %s of Int  } ), Q{trailing ws};
  }, Q{Normal version};
  
  ok round-trips( gensym-package Q:to[_END_] ), Q{unit form};
  unit subset %s;
  _END_
}, Q{subset};

subtest {
  plan 5;
  
  ok round-trips( Q:to[_END_] ), Q{no ws};
  constant Foo=1
  _END_
  
  ok round-trips( Q:to[_END_] ), Q{leading ws};
  constant Foo     =1
  _END_
  
  ok round-trips( Q:to[_END_] ), Q{intermediate ws};
  constant Foo=   1
  _END_
  
  ok round-trips( Q:to[_END_] ), Q{intermediate ws};
  constant Foo     =   1
  _END_
  
  ok round-trips( Q{constant Foo=1     } ), Q{trailing ws};
}, Q{constant};

# vim: ft=perl6
