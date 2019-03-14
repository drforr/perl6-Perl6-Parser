use v6;

use Test;
use Perl6::Parser;

use lib 't/lib/';
use Utils;

plan 13;

my $*CONSISTENCY-CHECK = True;
my $*FALL-THROUGH      = True;

subtest {
  plan 2;
  
  ok round-trips( Q{a=>1} ), Q{no ws};
  
  ok round-trips( Q:to[_END_] ), Q{ws};
  a => 1
  _END_
}, Q{a => 1};

subtest {
  plan 2;
  
  ok round-trips( Q{'a'=>'b'} ), Q{no ws};
  
  ok round-trips( Q:to[_END_] ), Q{ws};
  'a' => 'b'
  _END_
}, Q{a => 1};

subtest {
  plan 2;
  
  ok round-trips( Q{:a} ), Q{no ws};
  
  ok round-trips( Q:to[_END_] ), Q{ws};
  :a
  _END_
}, Q{:a};

subtest {
  plan 2;
  
  ok round-trips( Q{:!a} ), Q{no ws};
  
  ok round-trips( Q:to[_END_] ), Q{ws};
  :!a
  _END_
}, Q{:!a};

subtest {
  plan 2;
  
  ok round-trips( Q{:a<b>} ), Q{no ws};
  
  ok round-trips( Q:to[_END_] ), Q{ws};
  :a< b >
  _END_
}, Q{:a<b>};

subtest {
  plan 2;
  
  ok round-trips( Q{:a<b c>} ), Q{no ws};
  
  ok round-trips( Q:to[_END_] ), Q{ws};
  :a< b c >
  _END_
}, Q{:a< b c >};

subtest {
  plan 2;
  
  ok round-trips( Q{my$a;:a{$a}} ), Q{no ws};
  
  ok round-trips( Q:to[_END_] ), Q{ws};
  my $a; :a{$a}
  _END_
}, Q{:a{$a}};

subtest {
  plan 2;
  
  ok round-trips( Q{my$a;:a{'a','b'}} ), Q{no ws};
  
  ok round-trips( Q:to[_END_] ), Q{ws};
  my $a; :a{'a', 'b'}
  _END_
}, Q{:a{'a', 'b'}};

subtest {
  plan 2;
  
  ok round-trips( Q{my$a;:a{'a'=>'b'}} ), Q{no ws};
  
  ok round-trips( Q:to[_END_] ), Q{ws};
  my $a; :a{'a' => 'b'}
  _END_
}, Q{:a{'a' => 'b'}};

subtest {
  plan 2;
  
  ok round-trips( Q{my$a;:$a} ), Q{no ws};
  
  ok round-trips( Q:to[_END_] ), Q{ws};
  my $a; :$a
  _END_
}, Q{:$a};

subtest {
  plan 2;
  
  ok round-trips( Q{my@a;:@a} ), Q{no ws};
  
  ok round-trips( Q:to[_END_] ), Q{ws};
  my @a; :@a
  _END_
}, Q{:@a};

subtest {
  plan 2;
  
  ok round-trips( Q{my%a;:%a} ), Q{no ws};
  
  ok round-trips( Q:to[_END_] ), Q{ws};
  my %a; :%a
  _END_
}, Q{:%a};

subtest {
  plan 2;
  
  ok round-trips( Q{my&a;:&a} ), Q{no ws};
  
  ok round-trips( Q:to[_END_] ), Q{ws};
  my &a; :&a
  _END_
}, Q{:&a};

# vim: ft=perl6
