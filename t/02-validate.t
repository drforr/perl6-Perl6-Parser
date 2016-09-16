use v6;

use Test;
use Perl6::Tidy;

plan 3;

my $pt = Perl6::Tidy.new;

my $p = $pt.parse-source( Q{} );
ok $pt.validate( $p ), Q{Empty file};

$p = $pt.parse-source( Q{ } );
ok $pt.validate( $p ),Q{Whitespace only};

$p = $pt.parse-source( Q{'a'} );
ok $pt.validate( $p ), Q{File with string};

# vim: ft=perl6
