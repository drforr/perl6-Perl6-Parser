use v6;

use Test;
use Perl6::Parser;

use lib 't/lib/';
use Utils;

plan 3;

my $*CONSISTENCY-CHECK = True;
my $*FALL-THROUGH      = True;

ok round-trips( Q:to[_END_] ), Q{shebang line};
#!/usr/bin/env perl6
_END_

subtest {
  plan 2;
  
  ok round-trips( Q:to[_END_] ), Q{single EOL comment};
  # comment to end of line
  _END_
  
  ok round-trips( Q:to[_END_] ), Q{Two EOL comments in a row};
  # comment to end of line
  # comment to end of line
  _END_
  
  done-testing;
}, Q{full-line comments};

subtest {
  plan 2;
  
  ok round-trips( Q:to[_END_] ), Q{single EOL comment};
  #`( comment on single line )
  _END_
  
  ok round-trips( Q:to[_END_] ), Q{Two EOL comments in a row};
  #`( comment
  spanning
  multiple
  lines )
  _END_

  done-testing;
}, Q{spanning comment};

# vim: ft=perl6
