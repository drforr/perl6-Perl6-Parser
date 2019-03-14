use v6;

use Test;
use Perl6::Parser;

use lib 't/lib';
use Utils;

plan 9;

my $*CONSISTENCY-CHECK = True;
my $*FALL-THROUGH      = True;

# The terms that get tested here are:

# package <name> { }
# module <name> { }
# class <name> { }
# grammar <name> { }
# role <name> { }
# knowhow <name> { }
# native <name> { }
# also is <name>
# trusts <name>
#
# class Foo { also is Int } # 'also' is a package_declaration.
# class Foo { trusts Int } # 'trusts' is a package_declaration.

# These terms either are invalid or need additional support structures.
# I'll add them momentarily...
#
# lang <name>

subtest {
  my $pp     = Perl6::Parser.new;
  my $source = gensym-package Q{package %s{}};
  my $tree   = $pp.to-tree( $source );
  
  ok has-a( $tree, Perl6::Block::Enter ), Q{enter brace};
  ok has-a( $tree, Perl6::Block::Exit ),  Q{exit brace};
  
  done-testing;
}, Q{Check the token structure};

subtest {
  subtest {
    plan 4;
    
    ok round-trips( gensym-package Q{package %s{}} ), Q{no ws};
    
    ok round-trips( gensym-package Q:to[_END_] ), Q{leading ws};
    package %s     {}
    _END_
    
    ok round-trips( gensym-package Q{package %s{}  } ),
       Q{trailing ws};
    
    ok round-trips( gensym-package Q{package %s     {}  } ),
       Q{leading, trailing ws};
  }, Q{no intrabrace spacing};
  
  subtest {
    plan 4;
    
    ok round-trips( gensym-package Q{package %s{   }} ), Q{no ws};
    
    ok round-trips( gensym-package Q:to[_END_] ), Q{leading ws};
    package %s     {   }
    _END_
    
    ok round-trips( gensym-package Q{package %s{   }  } ), Q{trailing ws};
    
    ok round-trips( gensym-package Q{package %s     {   }  } ),
       Q{leading, trailing ws};
  }, Q{intrabrace spacing};
  
  subtest {
    plan 2;
    
    ok round-trips( gensym-package Q{unit package %s;} ), Q{no ws};
    
    ok round-trips( gensym-package Q:to[_END_] ), Q{ws before semi};
    unit package %s  ;
    _END_
  }, Q{unit form};
}, Q{package};

subtest {
  subtest {
    plan 4;
    
    ok round-trips( gensym-package Q{module %s{}} ), Q{no ws};
    
    ok round-trips( gensym-package Q:to[_END_] ), Q{leading ws};
    module %s     {}
    _END_
    
    ok round-trips( gensym-package Q{module %s{}  } ), Q{trailing ws};
    
    ok round-trips( gensym-package Q{module %s     {}  } ),
       Q{leading, trailing ws};
  }, Q{no intrabrace spacing};
  
  subtest {
    plan 4;
    
    ok round-trips( gensym-package Q{module %s{   }} ), Q{no ws};
    
    ok round-trips( gensym-package Q:to[_END_] ), Q{leading ws};
    module %s     {   }
    _END_
    
    ok round-trips( gensym-package Q{module %s{   }  } ), Q{trailing ws};
    
    ok round-trips( gensym-package Q{module %s     {   }  } ),
       Q{leading, trailing ws};
  }, Q{intrabrace spacing};
  
  subtest {
    plan 2;
    
    ok round-trips( gensym-package Q{unit module %s;} ), Q{no ws};
    
    ok round-trips( gensym-package Q:to[_END_] ), Q{ws};
    unit module %s;
    _END_
  }, Q{unit form};
}, Q{module};

subtest {
  subtest {
    plan 4;
    
    ok round-trips( gensym-package Q{class %s{}} ), Q{no ws};
    
    ok round-trips( gensym-package Q:to[_END_] ), Q{leading ws};
    class %s     {}
    _END_
    
    ok round-trips( gensym-package Q{class %s{}  } ), Q{trailing ws};
    
    ok round-trips( gensym-package Q{class %s     {}  } ),
       Q{leading, trailing ws};
  }, Q{no intrabrace spacing};
  
  subtest {
    plan 4;
    
    ok round-trips( gensym-package Q{class %s{   }} ), Q{no ws};
    
    ok round-trips( gensym-package Q:to[_END_] ), Q{leading ws};
    class %s     {   }
    _END_
    
    ok round-trips( gensym-package Q{class %s{   }  } ), Q{trailing ws};
    
    ok round-trips( gensym-package Q{class %s     {   }  } ),
       Q{leading, trailing ws};
  }, Q{intrabrace spacing};
  
  subtest {
    plan 2;
    
    ok round-trips( gensym-package Q{unit class %s;} ), Q{no ws};
    
    ok round-trips( gensym-package Q:to[_END_] ), Q{ws};
    unit class %s;
    _END_
  }, Q{unit form};
  
  subtest {
    plan 2;
    
    ok round-trips( gensym-package Q{class %s{also is Int}} ), Q{no ws};
    
    ok round-trips( gensym-package Q:to[_END_] ), Q{ws};
    class %s{also     is   Int}
    _END_
  }, Q{also is};
  
  subtest {
    plan 2;
    
    # space between 'Int' and {} is required
    ok round-trips( gensym-package Q{class %s is Int {}} ), Q{no ws};
    
    ok round-trips( gensym-package Q:to[_END_] ), Q{ws};
    class %s is Int {}
    _END_
  }, Q{is};
  
  subtest {
    plan 4;
    
    ok round-trips( gensym-package Q{class %s is repr('CStruct'){has int8$i}} ),
       Q{no ws};
    
    ok round-trips( gensym-package Q:to[_END_] ), Q{ws};
    class %s is repr('CStruct'){has int8$i}
    _END_
    
    ok round-trips( gensym-package Q:to[_END_] ), Q{more ws};
    class %s is repr('CStruct') { has int8 $i }
    _END_
    
    ok round-trips( gensym-package Q:to[_END_] ), Q{even more ws};
    class %s is repr( 'CStruct' ) { has int8 $i }
    _END_
  }, Q{is repr()};
}, Q{class};

subtest {
  plan 2;
  
  # space between 'Int' and {} is required
  ok round-trips( gensym-package Q{class %s{trusts Int}} ), Q{no ws};
  
  ok round-trips( gensym-package Q:to[_END_] ), Q{ws};
  class %s { trusts Int }
  _END_
}, Q{class Foo trusts};

# grammar
subtest {
  subtest {
    plan 4;
    
    ok round-trips( gensym-package Q{grammar %s{}} ), Q{no ws};
    
    ok round-trips( gensym-package Q:to[_END_] ), Q{leading ws};
    grammar %s     {}
    _END_
    
    ok round-trips( gensym-package Q{grammar %s{}  } ), Q{trailing ws};
    
    ok round-trips( gensym-package Q{grammar %s     {}  } ),
       Q{leading, trailing ws};
  }, Q{no intrabrace spacing};
  
  subtest {
    plan 4;
    
    ok round-trips( gensym-package Q{grammar %s{   }} ), Q{no ws};
    
    ok round-trips( gensym-package Q:to[_END_] ), Q{leading ws};
    grammar %s     {   }
    _END_
    
    ok round-trips( gensym-package Q{grammar %s{   }  } ), Q{trailing ws};
    
    ok round-trips( gensym-package Q{grammar %s     {   }  } ),
       Q{leading, trailing ws};
  }, Q{intrabrace spacing};
  
  subtest {
    plan 2;
    
    ok round-trips( gensym-package Q{unit grammar %s;} ),
       Q{no ws};
    
    ok round-trips( gensym-package Q:to[_END_] ), Q{ws};
    unit grammar %s;
    _END_
  }, Q{unit form};
}, Q{grammar};

subtest {
  subtest {
    plan 4;
    
    ok round-trips( gensym-package Q{role %s{}} ), Q{no ws};
    
    ok round-trips( gensym-package Q:to[_END_] ), Q{leading ws};
    role %s     {}
    _END_
    
    ok round-trips( gensym-package Q{role %s{}  } ), Q{trailing ws};
    
    ok round-trips( gensym-package Q{role %s     {}  } ),
       Q{leading, trailing ws};
  }, Q{no intrabrace spacing};
  
  subtest {
    plan 4;
    
    ok round-trips( Q{role Foo{   }} ), Q{no ws};
    
    ok round-trips( Q:to[_END_] ), Q{leading ws};
    role Foo     {   }
    _END_
    
    ok round-trips( Q{role Foo{   }  } ), Q{trailing ws};
    
    ok round-trips( Q{role Foo     {   }  } ), Q{leading, trailing ws};
  }, Q{intrabrace spacing};
  
  subtest {
    plan 2;
    
    ok round-trips( gensym-package Q{unit role %s;} ), Q{no ws};
    
    ok round-trips( gensym-package Q:to[_END_] ), Q{ws};
    unit role %s;
    _END_
  }, Q{unit form};
}, Q{role};

subtest {
  subtest {
    plan 4;
    
    ok round-trips( gensym-package Q{knowhow %s{}} ), Q{no ws};
    
    ok round-trips( gensym-package Q:to[_END_] ), Q{leading ws};
    knowhow %s     {}
    _END_
    
    ok round-trips( gensym-package Q{knowhow %s{}  } ), Q{trailing ws};
    
    ok round-trips( gensym-package Q{knowhow %s     {}  } ),
       Q{leading, trailing ws};
  }, Q{no intrabrace spacing};
  
  subtest {
    plan 4;
    
    ok round-trips( gensym-package Q{knowhow %s{   }} ), Q{no ws};
    
    ok round-trips( gensym-package Q:to[_END_] ), Q{leading ws};
    knowhow %s     {   }
    _END_
    
    ok round-trips( gensym-package Q{knowhow %s{   }  } ), Q{trailing ws};
    
    ok round-trips( gensym-package Q{knowhow %s     {   }  } ),
       Q{leading, trailing ws};
  }, Q{intrabrace spacing};
  
  subtest {
    plan 2;
    
    ok round-trips( gensym-package Q{unit knowhow %s;} ), Q{no ws};
    
    ok round-trips( gensym-package Q:to[_END_] ), Q{ws};
    unit knowhow %s;
    _END_
  }, Q{unit form};
}, Q{knowhow};

subtest {
  subtest {
    plan 4;
    
    ok round-trips( gensym-package Q{native %s{}} ), Q{no ws};
    
    ok round-trips( gensym-package Q:to[_END_] ), Q{leading ws};
    native %s     {}
    _END_
    
    ok round-trips( gensym-package Q{native %s{}  } ), Q{trailing ws};
    
    ok round-trips( gensym-package Q{native %s     {}  } ),
       Q{leading, trailing ws};
  }, Q{native - no intrabrace spacing};
  
  subtest {
    plan 4;
    
    ok round-trips( gensym-package Q{native %s{   }} ), Q{no ws};
    
    ok round-trips( gensym-package Q:to[_END_] ), Q{leading ws};
    native %s     {   }
    _END_
    
    ok round-trips( gensym-package Q{native %s{   }  } ), Q{trailing ws};
    
    ok round-trips( gensym-package Q{native %s     {   }  } ),
       Q{leading, trailing ws};
  }, Q{native - intrabrace spacing};
  
  subtest {
    plan 2;
    
    ok round-trips( gensym-package Q{unit native %s;} ), Q{no ws};
    
    ok round-trips( gensym-package Q:to[_END_] ), Q{ws};
    unit native %s;
    _END_
  }, Q{native - unit form};
}, Q{native};

# XXX 'lang Foo{}' illegal
# XXX 'unit lang Foo;' illegal

# vim: ft=perl6
