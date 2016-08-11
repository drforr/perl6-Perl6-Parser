use v6;

use Test;
use Perl6::Tidy;

plan 4;

my $pt = Perl6::Tidy.new;
#my $*TRACE = 1;
#my $*DEBUG = 1;

subtest {
	plan 2;

	my $parsed = $pt.parse-source( Q:to[_END_].chomp );
/pi/
_END_
	my $tree = $pt.build-tree( $parsed );
	ok $pt.validate( $parsed ), Q{valid};
#	is $pt.format( $tree ), Q:to[_END_].chomp, Q{formatted};
#/pi/
#_END_
	is $pt.format( $tree ), Q:to[_END_].chomp, Q{formatted};
/pi/
_END_
}, Q{/pi/};

subtest {
	plan 2;

	my $parsed = $pt.parse-source( Q:to[_END_].chomp );
/<[ p i ]>/
_END_
	my $tree = $pt.build-tree( $parsed );
	ok $pt.validate( $parsed ), Q{valid};
#	is $pt.format( $tree ), Q:to[_END_].chomp, Q{formatted};
#/<[ p i ]>/
#_END_
	is $pt.format( $tree ), Q:to[_END_].chomp, Q{formatted};
/<[ p i ]>/
_END_
}, Q{/<[ p i ]>/};

subtest {
	plan 2;

	my $parsed = $pt.parse-source( Q:to[_END_].chomp );
/ \d /
_END_
	my $tree = $pt.build-tree( $parsed );
	ok $pt.validate( $parsed ), Q{valid};
#	is $pt.format( $tree ), Q:to[_END_].chomp, Q{formatted};
#/ \d /
#_END_
	is $pt.format( $tree ), Q:to[_END_].chomp, Q{formatted};
/ \d /
_END_
}, Q{/ \d /};

subtest {
	plan 2;

	my $parsed = $pt.parse-source( Q:to[_END_].chomp );
/ . /
_END_
	my $tree = $pt.build-tree( $parsed );
	ok $pt.validate( $parsed ), Q{valid};
#	is $pt.format( $tree ), Q:to[_END_].chomp, Q{formatted};
#/ . /
#_END_
	is $pt.format( $tree ), Q:to[_END_].chomp, Q{formatted};
/ . /
_END_
}, Q{/ . /};

# vim: ft=perl6
