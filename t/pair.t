use v6;

use Test;
use Perl6::Parser;

plan 13;

my $pt = Perl6::Parser.new;
my $*CONSISTENCY-CHECK = True;
my $*FALL-THROUGH = True;

subtest {
	plan 2;

	subtest {
		my $source = Q{a=>1};
		my $tree = $pt.to-tree( $source );
		is $pt.to-string( $tree ), $source, Q{formatted};

		done-testing;
	}, Q{no ws};

	subtest {
		my $source = Q:to[_END_];
a => 1
_END_
		my $tree = $pt.to-tree( $source );
		is $pt.to-string( $tree ), $source, Q{formatted};

		done-testing;
	}, Q{ws};
}, Q{a => 1};

subtest {
	plan 2;

	subtest {
		my $source = Q{'a'=>'b'};
		my $tree = $pt.to-tree( $source );
		is $pt.to-string( $tree ), $source, Q{formatted};

		done-testing;
	}, Q{no ws};

	subtest {
		my $source = Q:to[_END_];
'a' => 'b'
_END_
		my $tree = $pt.to-tree( $source );
		is $pt.to-string( $tree ), $source, Q{formatted};

		done-testing;
	}, Q{ws};
}, Q{a => 1};

subtest {
	plan 2;

	subtest {
		my $source = Q{:a};
		my $tree = $pt.to-tree( $source );
		is $pt.to-string( $tree ), $source, Q{formatted};

		done-testing;
	}, Q{no ws};

	subtest {
		my $source = Q:to[_END_];
:a
_END_
		my $tree = $pt.to-tree( $source );
		is $pt.to-string( $tree ), $source, Q{formatted};

		done-testing;
	}, Q{ws};
}, Q{:a};

subtest {
	plan 2;

	subtest {
		my $source = Q{:!a};
		my $tree = $pt.to-tree( $source );
		is $pt.to-string( $tree ), $source, Q{formatted};

		done-testing;
	}, Q{no ws};

	subtest {
		my $source = Q:to[_END_];
:!a
_END_
		my $tree = $pt.to-tree( $source );
		is $pt.to-string( $tree ), $source, Q{formatted};

		done-testing;
	}, Q{ws};
}, Q{:!a};

subtest {
	plan 2;

	subtest {
		my $source = Q{:a<b>};
		my $tree = $pt.to-tree( $source );
		is $pt.to-string( $tree ), $source, Q{formatted};

		done-testing;
	}, Q{no ws};

	subtest {
		my $source = Q:to[_END_];
:a< b >
_END_
		my $tree = $pt.to-tree( $source );
		is $pt.to-string( $tree ), $source, Q{formatted};

		done-testing;
	}, Q{ws};
}, Q{:a<b>};

subtest {
	plan 2;

	subtest {
		my $source = Q{:a<b c>};
		my $tree = $pt.to-tree( $source );
		is $pt.to-string( $tree ), $source, Q{formatted};

		done-testing;
	}, Q{no ws};

	subtest {
		my $source = Q:to[_END_];
:a< b c >
_END_
		my $tree = $pt.to-tree( $source );
		is $pt.to-string( $tree ), $source, Q{formatted};

		done-testing;
	}, Q{ws};
}, Q{:a< b c >};

subtest {
	plan 2;

	subtest {
		my $source = Q{my$a;:a{$a}};
		my $tree = $pt.to-tree( $source );
		is $pt.to-string( $tree ), $source, Q{formatted};

		done-testing;
	}, Q{no ws};

	subtest {
		my $source = Q:to[_END_];
my $a; :a{$a}
_END_
		my $tree = $pt.to-tree( $source );
		is $pt.to-string( $tree ), $source, Q{formatted};

		done-testing;
	}, Q{ws};
}, Q{:a{$a}};

subtest {
	plan 2;

	subtest {
		my $source = Q{my$a;:a{'a','b'}};
		my $tree = $pt.to-tree( $source );
		is $pt.to-string( $tree ), $source, Q{formatted};

		done-testing;
	}, Q{no ws};

	subtest {
		my $source = Q:to[_END_];
my $a; :a{'a', 'b'}
_END_
		my $tree = $pt.to-tree( $source );
		is $pt.to-string( $tree ), $source, Q{formatted};

		done-testing;
	}, Q{ws};
}, Q{:a{'a', 'b'}};

subtest {
	plan 2;

	subtest {
		my $source = Q{my$a;:a{'a'=>'b'}};
		my $tree = $pt.to-tree( $source );
		is $pt.to-string( $tree ), $source, Q{formatted};

		done-testing;
	}, Q{no ws};

	subtest {
		my $source = Q:to[_END_];
my $a; :a{'a' => 'b'}
_END_
		my $tree = $pt.to-tree( $source );
		is $pt.to-string( $tree ), $source, Q{formatted};

		done-testing;
	}, Q{ws};
}, Q{:a{'a' => 'b'}};

subtest {
	plan 2;

	subtest {
		my $source = Q{my$a;:$a};
		my $tree = $pt.to-tree( $source );
		is $pt.to-string( $tree ), $source, Q{formatted};

		done-testing;
	}, Q{no ws};

	subtest {
		my $source = Q:to[_END_];
my $a; :$a
_END_
		my $tree = $pt.to-tree( $source );
		is $pt.to-string( $tree ), $source, Q{formatted};

		done-testing;
	}, Q{ws};
}, Q{:$a};

subtest {
	plan 2;

	subtest {
		my $source = Q{my@a;:@a};
		my $tree = $pt.to-tree( $source );
		is $pt.to-string( $tree ), $source, Q{formatted};

		done-testing;
	}, Q{no ws};

	subtest {
		my $source = Q:to[_END_];
my @a; :@a
_END_
		my $tree = $pt.to-tree( $source );
		is $pt.to-string( $tree ), $source, Q{formatted};

		done-testing;
	}, Q{ws};
}, Q{:@a};

subtest {
	plan 2;

	subtest {
		my $source = Q{my%a;:%a};
		my $tree = $pt.to-tree( $source );
		is $pt.to-string( $tree ), $source, Q{formatted};

		done-testing;
	}, Q{no ws};

	subtest {
		my $source = Q:to[_END_];
my %a; :%a
_END_
		my $tree = $pt.to-tree( $source );
		is $pt.to-string( $tree ), $source, Q{formatted};

		done-testing;
	}, Q{ws};
}, Q{:%a};

subtest {
	plan 2;

	subtest {
		my $source = Q{my&a;:&a};
		my $tree = $pt.to-tree( $source );
		is $pt.to-string( $tree ), $source, Q{formatted};

		done-testing;
	}, Q{no ws};

	subtest {
		my $source = Q:to[_END_];
my &a; :&a
_END_
		my $tree = $pt.to-tree( $source );
		is $pt.to-string( $tree ), $source, Q{formatted};

		done-testing;
	}, Q{ws};
}, Q{:&a};

# vim: ft=perl6
