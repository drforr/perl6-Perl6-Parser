use v6;

use Test;
use Perl6::Parser;

plan 3;

my $pt = Perl6::Parser.new;
my $*CONSISTENCY-CHECK = True;
my $*FALL-THROUGH = True;
my ( $source, $tree );

$source = Q:to[_END_];
#!/usr/bin/env perl6
_END_
$tree = $pt.to-tree( $source );
is $pt.to-string( $tree ), $source, Q{shebang line};

subtest {
	plan 2;

	$source = Q:to[_END_];
	# comment to end of line
	_END_
	$tree = $pt.to-tree( $source );
	is $pt.to-string( $tree ), $source, Q{single EOL comment};

	$source = Q:to[_END_];
	# comment to end of line
	# comment to end of line
	_END_
	$tree = $pt.to-tree( $source );
	is $pt.to-string( $tree ), $source, Q{Two EOL comments in a row};
}, Q{full-line comments};

subtest {
	plan 2;

	$source = Q:to[_END_];
	#`( comment on single line )
	_END_
	$tree = $pt.to-tree( $source );
	is $pt.to-string( $tree ), $source, Q{single EOL comment};

	$source = Q:to[_END_];
	#`( comment
	spanning
	multiple
	lines )
	_END_
	$tree = $pt.to-tree( $source );
	is $pt.to-string( $tree ), $source, Q{Two EOL comments in a row};
}, Q{spanning comment};

# vim: ft=perl6
