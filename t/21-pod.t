use v6;

use Test;
use Perl6::Parser;

use lib 't/lib/';
use Utils;

plan 1;

my $*CONSISTENCY-CHECK = True;
my $*FALL-THROUGH      = True;

subtest {
  ok round-trips( Q:to[_END_] ), Q{formatted};
  =begin EMPTY
  =end EMPTY
  _END_
  
  done-testing;
}, Q{empty};

# vim: ft=perl6
