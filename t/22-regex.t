use v6;

use Test;
use Perl6::Parser;

use lib 't/lib/';
use Utils;

plan 4;

my $*CONSISTENCY-CHECK = True;
my $*FALL-THROUGH      = True;

subtest {
  plan 2;
  
  ok round-trips( Q{/pi/} ), Q{no ws};
  
  ok round-trips( Q:to[_END_] ), Q{ws};
  /pi/
  _END_
}, Q{/pi/};

subtest {
  plan 2;
  
  ok round-trips( Q{/<[ p i ]>/} ), Q{no ws};
  
  ok round-trips( Q:to[_END_] ), Q{ws};
  / <[ p i ]> /
  _END_
}, Q{/<[ p i ]>/};

subtest {
  plan 2;
  
  ok round-trips( Q{/\d/} ), Q{no ws};
  
  ok round-trips( Q:to[_END_] ), Q{ws};
  / \d /
  _END_
}, Q{/ \d /};

subtest {
  plan 2;
  
  ok round-trips( Q{/./} ), Q{no ws};
  
  ok round-trips( Q:to[_END_] ), Q{ws};
  / . /
  _END_
}, Q{/ . /};

# vim: ft=perl6
