use v6;

use Test;
use Perl6::Parser;

plan 13;

my $pt = Perl6::Parser.new;
my $*CONSISTENCY-CHECK = True;
my $*FALL-THROUGH = True;
my ( $source, $tree );

subtest {
	plan 2;

	$source = Q{a=>1};
	$tree = $pt.to-tree( $source );
	is $pt.to-string( $tree ), $source, Q{no ws};

	$source = Q:to[_END_];
	a => 1
	_END_
	$tree = $pt.to-tree( $source );
	is $pt.to-string( $tree ), $source, Q{ws};
}, Q{a => 1};

subtest {
	plan 2;

	$source = Q{'a'=>'b'};
	$tree = $pt.to-tree( $source );
	is $pt.to-string( $tree ), $source, Q{no ws};

	$source = Q:to[_END_];
	'a' => 'b'
	_END_
	$tree = $pt.to-tree( $source );
	is $pt.to-string( $tree ), $source, Q{ws};
}, Q{a => 1};

subtest {
	plan 2;

	$source = Q{:a};
	$tree = $pt.to-tree( $source );
	is $pt.to-string( $tree ), $source, Q{no ws};

	$source = Q:to[_END_];
	:a
	_END_
	$tree = $pt.to-tree( $source );
	is $pt.to-string( $tree ), $source, Q{ws};
}, Q{:a};

subtest {
	plan 2;

	$source = Q{:!a};
	$tree = $pt.to-tree( $source );
	is $pt.to-string( $tree ), $source, Q{no ws};

	$source = Q:to[_END_];
	:!a
	_END_
	$tree = $pt.to-tree( $source );
	is $pt.to-string( $tree ), $source, Q{ws};
}, Q{:!a};

subtest {
	plan 2;

	$source = Q{:a<b>};
	$tree = $pt.to-tree( $source );
	is $pt.to-string( $tree ), $source, Q{no ws};

	$source = Q:to[_END_];
	:a< b >
	_END_
	$tree = $pt.to-tree( $source );
	is $pt.to-string( $tree ), $source, Q{ws};
}, Q{:a<b>};

subtest {
	plan 2;

	$source = Q{:a<b c>};
	$tree = $pt.to-tree( $source );
	is $pt.to-string( $tree ), $source, Q{no ws};

	$source = Q:to[_END_];
	:a< b c >
	_END_
	$tree = $pt.to-tree( $source );
	is $pt.to-string( $tree ), $source, Q{ws};
}, Q{:a< b c >};

subtest {
	plan 2;

	$source = Q{my$a;:a{$a}};
	$tree = $pt.to-tree( $source );
	is $pt.to-string( $tree ), $source, Q{no ws};

	$source = Q:to[_END_];
	my $a; :a{$a}
	_END_
	$tree = $pt.to-tree( $source );
	is $pt.to-string( $tree ), $source, Q{ws};
}, Q{:a{$a}};

subtest {
	plan 2;

	$source = Q{my$a;:a{'a','b'}};
	$tree = $pt.to-tree( $source );
	is $pt.to-string( $tree ), $source, Q{no ws};

	$source = Q:to[_END_];
	my $a; :a{'a', 'b'}
	_END_
	$tree = $pt.to-tree( $source );
	is $pt.to-string( $tree ), $source, Q{ws};
}, Q{:a{'a', 'b'}};

subtest {
	plan 2;

	$source = Q{my$a;:a{'a'=>'b'}};
	$tree = $pt.to-tree( $source );
	is $pt.to-string( $tree ), $source, Q{no ws};

	$source = Q:to[_END_];
	my $a; :a{'a' => 'b'}
	_END_
	$tree = $pt.to-tree( $source );
	is $pt.to-string( $tree ), $source, Q{ws};
}, Q{:a{'a' => 'b'}};

subtest {
	plan 2;

	$source = Q{my$a;:$a};
	$tree = $pt.to-tree( $source );
	is $pt.to-string( $tree ), $source, Q{no ws};

	$source = Q:to[_END_];
	my $a; :$a
	_END_
	$tree = $pt.to-tree( $source );
	is $pt.to-string( $tree ), $source, Q{ws};
}, Q{:$a};

subtest {
	plan 2;

	$source = Q{my@a;:@a};
	$tree = $pt.to-tree( $source );
	is $pt.to-string( $tree ), $source, Q{no ws};

	$source = Q:to[_END_];
	my @a; :@a
	_END_
	$tree = $pt.to-tree( $source );
	is $pt.to-string( $tree ), $source, Q{ws};
}, Q{:@a};

subtest {
	plan 2;

	$source = Q{my%a;:%a};
	$tree = $pt.to-tree( $source );
	is $pt.to-string( $tree ), $source, Q{no ws};

	$source = Q:to[_END_];
	my %a; :%a
	_END_
	$tree = $pt.to-tree( $source );
	is $pt.to-string( $tree ), $source, Q{ws};
}, Q{:%a};

subtest {
	plan 2;

	$source = Q{my&a;:&a};
	$tree = $pt.to-tree( $source );
	is $pt.to-string( $tree ), $source, Q{no ws};

	$source = Q:to[_END_];
	my &a; :&a
	_END_
	$tree = $pt.to-tree( $source );
	is $pt.to-string( $tree ), $source, Q{ws};
}, Q{:&a};

# vim: ft=perl6
