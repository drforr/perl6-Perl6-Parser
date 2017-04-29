use v6;

use Test;
use Perl6::Parser;

plan 4;

my $pt = Perl6::Parser.new;
my $*CONSISTENCY-CHECK = True;
my $*FALL-THROUGH = True;
my ( $source, $tree );

subtest {
	plan 2;

	$source = Q{/pi/};
	$tree = $pt.to-tree( $source );
	is $pt.to-string( $tree ), $source, Q{no ws};

	$source = Q:to[_END_];
	/pi/
	_END_
	$tree = $pt.to-tree( $source );
	is $pt.to-string( $tree ), $source, Q{ws};
}, Q{/pi/};

subtest {
	plan 2;

	$source = Q{/<[ p i ]>/};
	$tree = $pt.to-tree( $source );
	is $pt.to-string( $tree ), $source, Q{no ws};

	$source = Q:to[_END_];
	/ <[ p i ]> /
	_END_
	$tree = $pt.to-tree( $source );
	is $pt.to-string( $tree ), $source, Q{ws};
}, Q{/<[ p i ]>/};

subtest {
	plan 2;

	$source = Q{/\d/};
	$tree = $pt.to-tree( $source );
	is $pt.to-string( $tree ), $source, Q{no ws};

	$source = Q:to[_END_];
	/ \d /
	_END_
	$tree = $pt.to-tree( $source );
	is $pt.to-string( $tree ), $source, Q{ws};
}, Q{/ \d /};

subtest {
	plan 2;

	$source = Q{/./};
	$tree = $pt.to-tree( $source );
	is $pt.to-string( $tree ), $source, Q{no ws};

	$source = Q:to[_END_];
	/ . /
	_END_
	$tree = $pt.to-tree( $source );
	is $pt.to-string( $tree ), $source, Q{ws};
}, Q{/ . /};

# vim: ft=perl6
