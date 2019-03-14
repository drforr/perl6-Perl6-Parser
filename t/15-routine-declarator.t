use v6;

use Test;
use Perl6::Parser;

use lib 't/lib';
use Utils;

plan 4;

my $pp                 = Perl6::Parser.new;
my $*CONSISTENCY-CHECK = True;
my $*FALL-THROUGH      = True;

# The terms that get tested here are:
#
# sub <name> ... { }
# method <name> ... { }
# submethod <name> ... { }
#
# class Foo { method Bar { } } # 'method' is a routine_declaration.
# class Foo { submethod Bar { } } # 'submethod' is a routine_declaration.

# These terms either are invalid or need additional support structures.
#
# macro <name> ... { } # NYI

# MAIN is the only subroutine that allows the 'unit sub FOO' form,
# and naturally it can't be redeclared, as there's only one MAIN.
#
# So here it remains, outside the testing block.
#
subtest {
  plan 2;
  
  ok round-trips( Q{unit sub MAIN;} ), Q{no ws};
  
  ok round-trips( Q:to[_END_] ), Q{ws before semi};
  unit sub MAIN  ;
  _END_
}, Q{unit form};

subtest {
  plan 2;
  
  subtest {
    plan 4;
    
    subtest {
      my $source = gensym-package Q:to[_END_];
      sub %s{}
      _END_
      my $tree = $pp.to-tree( $source );
      is $pp.to-string( $tree ), $source, Q{formatted};
      ok $tree.child[0].child[3].child[0] ~~
      	Perl6::Block::Enter, Q{enter brace};
      ok $tree.child[0].child[3].child[1] ~~
      	Perl6::Block::Exit, Q{exit brace};
      
      done-testing;
    }, Q{no ws};
    
    ok round-trips( gensym-package Q:to[_END_] ), Q{leading ws};
    sub %s     {}
    _END_
    
    ok round-trips( gensym-package Q{sub %s{}  } ), Q{trailing ws};
    
    ok round-trips( gensym-package Q{sub %s     {}  } ),
       Q{leading, trailing ws};
  }, Q{no intrabrace spacing};
  
  subtest {
    plan 4;
    
    ok round-trips( gensym-package Q:to[_END_] ), Q{no ws};
    sub %s{   }
    _END_
    
    ok round-trips( gensym-package Q:to[_END_] ), Q{leading ws};
    sub %s     {   }
    _END_
    
    ok round-trips( gensym-package Q{sub %s{   }  } ), Q{trailing ws};
    
    ok round-trips( gensym-package Q{sub %s     {   }  } ),
    	Q{leading, trailing ws};
  }, Q{intrabrace spacing};
}, Q{sub};

subtest {
  plan 2;
  
  subtest {
    plan 4;
    
    subtest {
      my $source = gensym-package Q:to[_END_];
      class %s{method Bar{}}
      _END_
      my $tree = $pp.to-tree( $source );
      is $pp.to-string( $tree ), $source, Q{formatted};

      ok has-a( $tree, Perl6::Block::Enter ), Q{enter brace};
      ok has-a( $tree, Perl6::Block::Exit ),  Q{exit brace};
      ok has-a( $tree, Perl6::Block::Enter ), Q{enter brace};
      ok has-a( $tree, Perl6::Block::Exit ),  Q{exit brace};
      
      done-testing;
    }, Q{no ws};
    
    ok round-trips( gensym-package Q:to[_END_] ), Q{leading ws};
    class %s{method Bar     {}}
    _END_
    
    ok round-trips( gensym-package Q{class %s{method Foo{}  }} ),
       Q{trailing ws};
    
    ok round-trips( gensym-package Q{class %s{method Bar     {}  }} ),
       Q{leading, trailing ws};
  }, Q{no intrabrace spacing};
  
  subtest {
    plan 4;
    
    ok round-trips( gensym-package Q:to[_END_] ), Q{no ws};
    class %s{method Bar   {}}
    _END_
    
    ok round-trips( gensym-package Q:to[_END_] ), Q{leading ws};
    class %s{method Bar     {   }}
    _END_
    
    ok round-trips( gensym-package Q{class %s{method Foo{   }  }} ),
       Q{trailing ws};
    
    ok round-trips( gensym-package Q{class %s{method Bar     {   }  }} ),
       Q{leading, trailing ws};
  }, Q{with intrabrace spacing};
}, Q{method};

subtest {
  plan 2;
  
  subtest {
    plan 4;
    
    ok round-trips( gensym-package Q:to[_END_] ), Q{no ws};
    class %s{submethod Bar{}}
    _END_
    
    ok round-trips( gensym-package Q:to[_END_] ), Q{leading ws};
    class %s{submethod Bar     {}}
    _END_
    
    ok round-trips( gensym-package Q{class %s{submethod Foo{}  }} ),
       Q{trailing ws};
    
    ok round-trips( gensym-package Q{class %s{submethod Bar     {}  }} ),
       Q{leading, trailing ws};
  }, Q{no intrabrace spacing};
  
  subtest {
    plan 4;
    
    ok round-trips( gensym-package Q:to[_END_] ), Q{no ws};
    class %s{submethod Bar   {}}
    _END_
    
    ok round-trips( gensym-package Q:to[_END_] ), Q{leading ws};
    class %s{submethod Bar     {   }}
    _END_
    
    ok round-trips( gensym-package Q{class %s{submethod Foo{   }  }} ),
       Q{trailing ws};
    
    ok round-trips( gensym-package Q{class %s{submethod Bar     {   }  }} ),
       Q{leading, trailing ws};
  }, Q{with intrabrace spacing};
}, Q{submethod};

# XXX 'macro Foo{}' is still experimental.

# vim: ft=perl6
