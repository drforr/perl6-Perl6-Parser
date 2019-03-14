use v6;

use Test;
use Perl6::Parser;

plan 3;

my $pp                 = Perl6::Parser.new;
my $*CONSISTENCY-CHECK = True;
my $*FALL-THROUGH      = True;

subtest {
  my $parsed = $pp.to-tree( Q{} );

  ok $parsed ~~ Perl6::Document, Q{document};
  ok $parsed.is-twig, Q{document is a branch};
  is $parsed.child.elems, 0, Q{document has no children};
}, Q{empty file};

subtest {
  my $parsed = $pp.to-tree( Q{ } );

  subtest {
    ok $parsed ~~ Perl6::Document, Q{document};
    ok $parsed.is-twig, Q{document is a branch};
    is $parsed.child.elems, 1, Q{document has one WS child};
    $parsed = $parsed.child.[0];
  }, Q{document root};

  subtest {
    ok $parsed ~~ Perl6::WS, Q{whitespace};
    ok $parsed.is-leaf, Q{whitespace is a leaf};
  }, Q{whitespace};
}, Q{''};

subtest {
  my $parsed = $pp.to-tree( Q{my $a = 1;} );

  subtest {
    ok $parsed ~~ Perl6::Document, Q{type is correct};
    ok $parsed.is-twig, Q{is a branch};
    is $parsed.child.elems, 1, Q{has children};
  }, Q{document root};

  $parsed = $parsed.child.[0];

  subtest {
    ok $parsed ~~ Perl6::Statement, Q{type is correct};
    ok $parsed.is-twig, Q{statement is a leaf};
    is $parsed.child.elems, 8, Q{has children};
#    is $parsed.content, Q{my $a;}, Q{statement has correct content};
  }, Q{Statement 'my $a;'};

  my $count = 0;

  subtest {
    my $_parsed = $parsed.child.[$count++];
    ok $_parsed ~~ Perl6::Bareword, Q{type is correct};
    ok $_parsed.is-leaf, Q{is a leaf};
    is $_parsed.content, Q{my}, Q{has correct content};
  }, Q{Bareword 'my'};

  subtest {
    my $_parsed = $parsed.child.[$count++];
    ok $_parsed ~~ Perl6::WS, Q{type is correct};
    ok $_parsed.is-leaf, Q{whitespace is a leaf};
    is $_parsed.content, Q{ }, Q{has correct content};
  }, Q{WS ' '};

  subtest {
    my $_parsed = $parsed.child.[$count++];
    ok $_parsed ~~ Perl6::Variable::Scalar, Q{type is correct};
    ok $_parsed.is-leaf, Q{is a leaf};
    is $_parsed.content, Q{$a}, Q{has correct content};
  }, Q{Variable::Scalar '$a'};

  subtest {
    my $_parsed = $parsed.child.[$count++];
    ok $_parsed ~~ Perl6::WS, Q{type is correct};
    ok $_parsed.is-leaf, Q{whitespace is a leaf};
    is $_parsed.content, Q{ }, Q{has correct content};
  }, Q{WS ' '};

  subtest {
    my $_parsed = $parsed.child.[$count++];
    ok $_parsed ~~ Perl6::Operator, Q{type is correct};
    ok $_parsed.is-leaf, Q{is a leaf};
    is $_parsed.content, Q{=}, Q{has correct content};
  }, Q{Operator '='};

  subtest {
    my $_parsed = $parsed.child.[$count++];
    ok $_parsed ~~ Perl6::WS, Q{type is correct};
    ok $_parsed.is-leaf, Q{whitespace is a leaf};
    is $_parsed.content, Q{ }, Q{has correct content};
  }, Q{WS ' '};

  subtest {
    my $_parsed = $parsed.child.[$count++];
    ok $_parsed ~~ Perl6::Number::Decimal, Q{type is correct};
    ok $_parsed.is-leaf, Q{is a leaf};
    is $_parsed.content, Q{1}, Q{has correct content};
  }, Q{Operator '1'};

  subtest {
    my $_parsed = $parsed.child.[$count++];
    ok $_parsed ~~ Perl6::Semicolon, Q{type is correct};
    ok $_parsed.is-leaf, Q{is a leaf};
    is $_parsed.content, Q{;}, Q{has correct content};
  }, Q{Semicolon ';'};
}, Q{my $a = 1;};

# vim: ft=perl6
