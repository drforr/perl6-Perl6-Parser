use v6;

use Test;
use Perl6::Parser;

plan 3;

my $pt = Perl6::Parser.new;
my $*CONSISTENCY-CHECK = True;
my $*GRAMMAR-CHECK = True;

my $p = $pt.parse( Q{} );
ok $pt.validate( $p ), Q{Empty file};

$p = $pt.parse( Q{ } );
ok $pt.validate( $p ),Q{Whitespace only};

$p = $pt.parse( Q{'a'} );
ok $pt.validate( $p ), Q{File with string};

# vim: ft=perl6
