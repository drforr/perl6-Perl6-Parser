use v6;

use Test;
use Perl6::Parser;

use lib 't/lib/';
use Utils;

plan 4;

# The terms that get tested here are:
#
# multi 
# proto 
# only
# null

my $*CONSISTENCY-CHECK = True;
my $*FALL-THROUGH      = True;

subtest {
  my $pp   = Perl6::Parser.new;
  my $tree = $pp.to-tree( Q:to[_END_] );
  multi Foo{}
  _END_
  
  ok has-a( $tree, Perl6::Block::Enter ), Q{enter brace};
  ok has-a( $tree, Perl6::Block::Exit ),  Q{exit brace};
  
  done-testing;
}, Q{Check the token structure};

subtest {
  plan 2;
  
  subtest {
    plan 4;
    
    ok round-trips( Q:to[_END_] ), Q{no ws};
    multi Foo{}
    _END_
    
    ok round-trips( Q:to[_END_] ), Q{leading ws};
    multi Foo     {}
    _END_
    
    ok round-trips( Q{multi Foo{}  } ), Q{trailing ws};
    
    ok round-trips( Q{multi Foo     {}  } ), Q{leading, trailing ws};
  }, Q{no intrabrace spacing};
  
  subtest {
    plan 4;
    
    ok round-trips( Q:to[_END_] ), Q{no ws};
    multi Foo{   }
    _END_
    
    ok round-trips( Q:to[_END_] ), Q{leading ws};
    multi Foo     {   }
    _END_
    
    ok round-trips( Q{multi Foo{   }  } ), Q{trailing ws};
    
    ok round-trips( Q{multi Foo     {   }  } ), Q{leading, trailing ws};
  }, Q{intrabrace spacing};
}, Q{multi};

subtest {
  plan 2;
  
  subtest {
    plan 4;
    
    ok round-trips( Q:to[_END_] ), Q{no ws};
    proto Foo{}
    _END_
    
    ok round-trips( Q:to[_END_] ), Q{leading ws};
    proto Foo     {}
    _END_
    
    ok round-trips( Q{proto Foo{}  } ), Q{trailing ws};
    
    ok round-trips( Q{proto Foo     {}  } ), Q{leading, trailing ws};
  }, Q{no intrabrace spacing};
  
  subtest {
    plan 4;
    
    ok round-trips( Q:to[_END_] ), Q{no ws};
    proto Foo{   }
    _END_
    
    ok round-trips( Q:to[_END_] ), Q{leading ws};
    proto Foo     {   }
    _END_
    
    ok round-trips( Q{proto Foo{   }  } ), Q{trailing ws};
    
    ok round-trips( Q{proto Foo     {   }  } ), Q{leading, trailing ws};
  }, Q{intrabrace spacing};
}, Q{proto};

subtest {
  plan 2;
  
  subtest {
    plan 4;
    
    ok round-trips( Q:to[_END_] ), Q{no ws};
    only Foo{}
    _END_
    
    ok round-trips( Q:to[_END_] ), Q{leading ws};
    only Foo     {}
    _END_
    
    ok round-trips( Q{only Foo{}  } ), Q{trailing ws};
    
    ok round-trips( Q{only Foo     {}  } ), Q{leading, trailing ws};
  }, Q{no intrabrace spacing};
  
  subtest {
    plan 4;
    
    ok round-trips( Q:to[_END_] ), Q{no ws};
    only Foo{   }
    _END_
    
    ok round-trips( Q:to[_END_] ), Q{no leading ws};
    only Foo     {   }
    _END_
    
    ok round-trips( Q{only Foo{   }  } ), Q{trailing ws};
    
    ok round-trips( Q{only Foo     {   }  } ), Q{leading, trailing ws};
  }, Q{intrabrace spacing};
}, Q{only};

# 'null' does not exist

# vim: ft=perl6
