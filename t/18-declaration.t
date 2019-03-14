use v6;

use Test;
use Perl6::Parser;

use lib 't/lib/';
use Utils;

plan 2;

my $*CONSISTENCY-CHECK = True;
my $*FALL-THROUGH      = True;

subtest {
  plan 3;
  
  subtest {
    plan 3;
    
    ok round-trips( Q{my Int $a} ), Q{regular};
    ok round-trips( Q{my Int:U $a} ), Q{undefined};
    ok round-trips( Q{my Int:D $a = 0} ), Q{defined};

    done-testing;
  }, Q{typed};
  
  ok round-trips( Q{my $a where 1} ), Q{constrained};

  ok round-trips( Q{my $a where 1 = 2} ), Q{constrained};

  done-testing;
}, Q{variable};

subtest {
  plan 2;
  
  subtest {
    plan 2;
    
    ok round-trips( Q{sub foo{}} ), Q{no ws};
    
    ok round-trips( Q:to[_END_] ), Q{ws};
    sub foo {}
    _END_

    done-testing;
  }, Q{sub foo {}};

  subtest {
    plan 2;
    
    ok round-trips( Q{sub foo returns Int {}} ), Q{ws};
    
    ok round-trips( Q:to[_END_] ), Q{ws};
    sub foo returns Int {}
    _END_

    done-testing;
  }, Q{sub foo returns Int {}};

  done-testing;
}, Q{subroutine};

# vim: ft=perl6
