use v6;

use Test;
use Perl6::Parser;

sub hash-matches( Mu $parsed, $key, $from, $to, $text ) returns Bool {
  $parsed.hash:exists{$key} or
    diag "Key '$key' missing";
  $parsed.hash.{$key}.from == $from or
    diag "Key starts at {$parsed.hash.{$key}.from}, not $from";
  $parsed.hash.{$key}.to == $to or
    diag "Key does not end at {$parsed.hash.{$key}.to}, not $to";
  $parsed.hash.{$key}.Str eq $text or
    diag "Key is '{$parsed.hash.{$key}.Str}', not '$text'";

  return ?( ( $parsed.hash:exists{$key} ) and
            ( $parsed.hash.{$key}.from == $from ) and
            ( $parsed.hash.{$key}.to == $to ) and
            ( $parsed.hash.{$key}.Str eq $text ) );
}

plan 2;

# Reuse $pp so that we can make sure state is cleaned up.
#
# Also, just check that we have the keys we're expecting in the hash/list.
#
my $pp                 = Perl6::Parser.new;
my $*CONSISTENCY-CHECK = True;
my $*FALL-THROUGH      = True;

subtest {
  my $parsed = $pp.parse( Q{} );

  ok $parsed.hash:exists<statementlist>, Q{statement list};
  $parsed = $parsed.hash.<statementlist>;

  ok $parsed.hash:exists<statement>, Q{statement};
}, Q{empty file};

subtest {
  my $parsed = $pp.parse( Q{'a'} );

  ok hash-matches( $parsed, 'statementlist', 0, 3, Q{'a'} ), Q{statementlist};
  $parsed = $parsed.hash.<statementlist>;

  ok hash-matches( $parsed, 'statement', 0, 3, Q{'a'} ), Q{statement};
  $parsed = $parsed.hash.<statement>;

  ok $parsed.list.elems > 0, q{list has at least one element};
  $parsed = $parsed.list.[0];

  ok hash-matches( $parsed, 'EXPR', 0, 3, Q{'a'} ), Q{EXPR};
  $parsed = $parsed.hash.<EXPR>;

  ok hash-matches( $parsed, 'value', 0, 3, Q{'a'} ), Q{value};
  $parsed = $parsed.hash.<value>;

  ok hash-matches( $parsed, 'quote', 0, 3, Q{'a'} ), Q{quote};
  $parsed = $parsed.hash.<quote>;

  ok hash-matches( $parsed, 'nibble', 1, 2, Q{a} ), Q{nibble};
  $parsed = $parsed.hash.<nibble>;

  ok !$parsed.hash, Q{tree ends};
}, Q{'a'};

# vim: ft=perl6
