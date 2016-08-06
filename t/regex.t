use v6;

use Test;
use Perl6::Tidy;

plan 4;

my $pt = Perl6::Tidy.new;
#my $*TRACE = 1;
#my $*DEBUG = 1;

subtest {
	plan 1;

	my $parsed = $pt.parse-source( Q:to[_END_] );
/pi/
_END_
	ok $pt.validate( $parsed );
}, Q{/pi/};

subtest {
	plan 1;

	my $parsed = $pt.parse-source( Q:to[_END_] );
/<[ p i ]>/
_END_
	ok $pt.validate( $parsed );
}, Q{/<[ p i ]>/};

subtest {
	plan 1;

	my $parsed = $pt.parse-source( Q:to[_END_] );
/ \d /
_END_
	ok $pt.validate( $parsed );
}, Q{/ \d /};

subtest {
	plan 1;

	my $parsed = $pt.parse-source( Q:to[_END_] );
/ . /
_END_
	ok $pt.validate( $parsed );
}, Q{/ . /};

# vim: ft=perl6
