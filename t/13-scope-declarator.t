use v6;

use Test;
use Perl6::Parser;

use lib 't/lib/';
use Utils;

plan 4;

my $*CONSISTENCY-CHECK = True;
my $*FALL-THROUGH      = True;

# The terms that get tested here are:
#
# my <name>
# our <naem>
# has <name>
# HAS <name>
# augment <name>
# anon <name>
# state <name>
# supersede <name>
#
# class Foo { has <name> } # 'has' is a scope declaration.
# class Foo { HAS <name> } # 'HAS' requires a separate class to work

# These terms are invalid:
#
# lang <name>

subtest {
  plan 3;
  
  subtest {
    my $pp     = Perl6::Parser.new;
    my $source = Q:to[_END_];
    my$x
    _END_
    
    my $tree   = $pp.to-tree( $source );
    
    ok has-a( $tree, Perl6::Bareword ),         Q{'my'};
    ok has-a( $tree, Perl6::Variable::Scalar ), Q{'$x'};
    ok has-a( $tree, Perl6::Newline ),          Q{\n};
    ok !has-a( $tree, Perl6::WS ),              Q{no ' '};
    
    done-testing;
  }, Q{Check the token structure};
  
  ok round-trips( Q:to[_END_] ), Q{no ws};
  my$x
  _END_
  
  ok round-trips( Q:to[_END_] ), Q{leading ws};
  my     $x
  _END_
  
  done-testing;
}, Q{my};

subtest {
  plan 2;
  
  ok round-trips( Q:to[_END_] ), Q{no ws};
  our$x
  _END_
  
  ok round-trips( Q:to[_END_] ), Q{leading ws};
  our     $x
  _END_
  
  done-testing;
}, Q{our};

subtest {
  subtest {
    my $pp = Perl6::Parser.new;
    my $source = gensym-package Q:to[_END_];
    class %s{has$x}
    _END_

    my $tree = $pp.to-tree( $source );
    ok has-a( $tree, Perl6::Block::Enter ), Q{enter brace};
    ok has-a( $tree, Perl6::Block::Exit ),  Q{exit brace};
    
    done-testing;
  }, Q{Check the token structure};
  
  ok round-trips( gensym-package Q:to[_END_] ), Q{no ws};
  class %s{has$x}
  _END_
  
  ok round-trips( gensym-package Q:to[_END_] ), Q{leading ws};
  class %s{has     $x}
  _END_
  
  done-testing;
}, Q{has};

# HAS requires another class definition.
#
#subtest {
#  plan 2;
#  
#  subtest {
#    $source = Q{class Foo is repr('CStruct'){HAS int $x}};
#    ok round-trips( $source ), Q{formatted};
#    
#    done-testing;
#  }, Q{no ws};
#  
#  subtest {
#    source = Q:to[_END_];
#    lass Foo is repr( 'CStruct' ) { HAS int $x }
#    END_
#
#    ok round-trips( $source ), Q{formatted};
#  
#    done-testing;
#  }, Q{leading ws};
#}, Q{HAS};

# XXX 'augment $x' is NIY

# XXX 'anon $x' is NIY

ok round-trips( Q:to[_END_] ), Q{state};
state     $x
_END_

# XXX 'supersede $x' NIY

# vim: ft=perl6
