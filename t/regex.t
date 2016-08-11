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
#`(
	plan 2;

	my $parsed = $pt.parse-source( Q:to[_END_].chomp );
class Unqualified { }
_END_
	my $tree = $pt.build-tree( $parsed );
	ok $pt.validate( $parsed ), Q{valid};
#	is $pt.format( $tree ), Q:to[_END_], Q{formatted};
#class Unqualified { }
#_END_
	is $pt.format( $tree ), Q{classUnqualified{}}, Q{formatted};
)
}, Q{/pi/};

subtest {
	plan 1;

	my $parsed = $pt.parse-source( Q:to[_END_] );
/<[ p i ]>/
_END_
	ok $pt.validate( $parsed );
#`(
	plan 2;

	my $parsed = $pt.parse-source( Q:to[_END_].chomp );
class Unqualified { }
_END_
	my $tree = $pt.build-tree( $parsed );
	ok $pt.validate( $parsed ), Q{valid};
#	is $pt.format( $tree ), Q:to[_END_], Q{formatted};
#class Unqualified { }
#_END_
	is $pt.format( $tree ), Q{classUnqualified{}}, Q{formatted};
)
}, Q{/<[ p i ]>/};

subtest {
	plan 1;

	my $parsed = $pt.parse-source( Q:to[_END_] );
/ \d /
_END_
	ok $pt.validate( $parsed );
#`(
	plan 2;

	my $parsed = $pt.parse-source( Q:to[_END_].chomp );
class Unqualified { }
_END_
	my $tree = $pt.build-tree( $parsed );
	ok $pt.validate( $parsed ), Q{valid};
#	is $pt.format( $tree ), Q:to[_END_], Q{formatted};
#class Unqualified { }
#_END_
	is $pt.format( $tree ), Q{classUnqualified{}}, Q{formatted};
)
}, Q{/ \d /};

subtest {
	plan 1;

	my $parsed = $pt.parse-source( Q:to[_END_] );
/ . /
_END_
	ok $pt.validate( $parsed );
#`(
	plan 2;

	my $parsed = $pt.parse-source( Q:to[_END_].chomp );
class Unqualified { }
_END_
	my $tree = $pt.build-tree( $parsed );
	ok $pt.validate( $parsed ), Q{valid};
#	is $pt.format( $tree ), Q:to[_END_], Q{formatted};
#class Unqualified { }
#_END_
	is $pt.format( $tree ), Q{classUnqualified{}}, Q{formatted};
)
}, Q{/ . /};

# vim: ft=perl6
