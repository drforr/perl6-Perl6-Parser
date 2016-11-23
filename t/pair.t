use v6;

use Test;
use Perl6::Parser;

plan 13;

my $pt = Perl6::Parser.new;
my $*VALIDATION-FAILURE-FATAL = True;
my $*FACTORY-FAILURE-FATAL = True;
my $*DEBUG = True;

subtest {
	plan 2;

	subtest {
		plan 2;

		my $source = Q{a=>1};
		my $parsed = $pt.parse( $source );
		my $tree = $pt.build-tree( $parsed );
		ok $pt.validate( $parsed ), Q{valid};
		is $pt.to-string( $tree ), $source, Q{formatted};
	}, Q{no ws};

	subtest {
		plan 2;

		my $source = Q:to[_END_];
a => 1
_END_
		my $parsed = $pt.parse( $source );
		my $tree = $pt.build-tree( $parsed );
		ok $pt.validate( $parsed ), Q{valid};
		is $pt.to-string( $tree ), $source, Q{formatted};
	}, Q{ws};
}, Q{a => 1};

subtest {
	plan 2;

	subtest {
		plan 2;

		my $source = Q{'a'=>'b'};
		my $parsed = $pt.parse( $source );
		my $tree = $pt.build-tree( $parsed );
		ok $pt.validate( $parsed ), Q{valid};
		is $pt.to-string( $tree ), $source, Q{formatted};
	}, Q{no ws};

	subtest {
		plan 2;

		my $source = Q:to[_END_];
'a' => 'b'
_END_
		my $parsed = $pt.parse( $source );
		my $tree = $pt.build-tree( $parsed );
		ok $pt.validate( $parsed ), Q{valid};
		is $pt.to-string( $tree ), $source, Q{formatted};
	}, Q{ws};
}, Q{a => 1};

subtest {
	plan 2;

	subtest {
		plan 2;

		my $source = Q{:a};
		my $parsed = $pt.parse( $source );
		my $tree = $pt.build-tree( $parsed );
		ok $pt.validate( $parsed ), Q{valid};
		is $pt.to-string( $tree ), $source, Q{formatted};
	}, Q{no ws};

	subtest {
		plan 2;

		my $source = Q:to[_END_];
:a
_END_
		my $parsed = $pt.parse( $source );
		my $tree = $pt.build-tree( $parsed );
		ok $pt.validate( $parsed ), Q{valid};
		is $pt.to-string( $tree ), $source, Q{formatted};
	}, Q{ws};
}, Q{:a};

subtest {
	plan 2;

	subtest {
		plan 2;

		my $source = Q{:!a};
		my $parsed = $pt.parse( $source );
		my $tree = $pt.build-tree( $parsed );
		ok $pt.validate( $parsed ), Q{valid};
		is $pt.to-string( $tree ), $source, Q{formatted};
	}, Q{no ws};

	subtest {
		plan 2;

		my $source = Q:to[_END_];
:!a
_END_
		my $parsed = $pt.parse( $source );
		my $tree = $pt.build-tree( $parsed );
		ok $pt.validate( $parsed ), Q{valid};
		is $pt.to-string( $tree ), $source, Q{formatted};
	}, Q{ws};
}, Q{:!a};

subtest {
	plan 2;

	subtest {
		plan 2;

		my $source = Q{:a<b>};
		my $parsed = $pt.parse( $source );
		my $tree = $pt.build-tree( $parsed );
		ok $pt.validate( $parsed ), Q{valid};
		is $pt.to-string( $tree ), $source, Q{formatted};
	}, Q{no ws};

	subtest {
		plan 2;

		my $source = Q:to[_END_];
:a< b >
_END_
		my $parsed = $pt.parse( $source );
		my $tree = $pt.build-tree( $parsed );
		ok $pt.validate( $parsed ), Q{valid};
		is $pt.to-string( $tree ), $source, Q{formatted};
	}, Q{ws};
}, Q{:a<b>};

subtest {
	plan 2;

	subtest {
		plan 2;

		my $source = Q{:a<b c>};
		my $parsed = $pt.parse( $source );
		my $tree = $pt.build-tree( $parsed );
		ok $pt.validate( $parsed ), Q{valid};
		is $pt.to-string( $tree ), $source, Q{formatted};
	}, Q{no ws};

	subtest {
		plan 2;

		my $source = Q:to[_END_];
:a< b c >
_END_
		my $parsed = $pt.parse( $source );
		my $tree = $pt.build-tree( $parsed );
		ok $pt.validate( $parsed ), Q{valid};
		is $pt.to-string( $tree ), $source, Q{formatted};
	}, Q{ws};
}, Q{:a< b c >};

subtest {
	plan 2;

	subtest {
		plan 2;

		my $source = Q{my$a;:a{$a}};
		my $parsed = $pt.parse( $source );
		my $tree = $pt.build-tree( $parsed );
		ok $pt.validate( $parsed ), Q{valid};
		is $pt.to-string( $tree ), $source, Q{formatted};
	}, Q{no ws};

	subtest {
		plan 2;

		my $source = Q:to[_END_];
my $a; :a{$a}
_END_
		my $parsed = $pt.parse( $source );
		my $tree = $pt.build-tree( $parsed );
		ok $pt.validate( $parsed ), Q{valid};
		is $pt.to-string( $tree ), $source, Q{formatted};
	}, Q{ws};
}, Q{:a{$a}};

subtest {
	plan 2;

	subtest {
		plan 2;

		my $source = Q{my$a;:a{'a','b'}};
		my $parsed = $pt.parse( $source );
		my $tree = $pt.build-tree( $parsed );
		ok $pt.validate( $parsed ), Q{valid};
		is $pt.to-string( $tree ), $source, Q{formatted};
	}, Q{no ws};

	subtest {
		plan 2;

		my $source = Q:to[_END_];
my $a; :a{'a', 'b'}
_END_
		my $parsed = $pt.parse( $source );
		my $tree = $pt.build-tree( $parsed );
		ok $pt.validate( $parsed ), Q{valid};
		is $pt.to-string( $tree ), $source, Q{formatted};
	}, Q{ws};
}, Q{:a{'a', 'b'}};

subtest {
	plan 2;

	subtest {
		plan 2;

		my $source = Q{my$a;:a{'a'=>'b'}};
		my $parsed = $pt.parse( $source );
		my $tree = $pt.build-tree( $parsed );
		ok $pt.validate( $parsed ), Q{valid};
		is $pt.to-string( $tree ), $source, Q{formatted};
	}, Q{no ws};

	subtest {
		plan 2;

		my $source = Q:to[_END_];
my $a; :a{'a' => 'b'}
_END_
		my $parsed = $pt.parse( $source );
		my $tree = $pt.build-tree( $parsed );
		ok $pt.validate( $parsed ), Q{valid};
		is $pt.to-string( $tree ), $source, Q{formatted};
	}, Q{ws};
}, Q{:a{'a' => 'b'}};

subtest {
	plan 2;

	subtest {
		plan 2;

		my $source = Q{my$a;:$a};
		my $parsed = $pt.parse( $source );
		my $tree = $pt.build-tree( $parsed );
		ok $pt.validate( $parsed ), Q{valid};
		is $pt.to-string( $tree ), $source, Q{formatted};
	}, Q{no ws};

	subtest {
		plan 2;

		my $source = Q:to[_END_];
my $a; :$a
_END_
		my $parsed = $pt.parse( $source );
		my $tree = $pt.build-tree( $parsed );
		ok $pt.validate( $parsed ), Q{valid};
		is $pt.to-string( $tree ), $source, Q{formatted};
	}, Q{ws};
}, Q{:$a};

subtest {
	plan 2;

	subtest {
		plan 2;

		my $source = Q{my@a;:@a};
		my $parsed = $pt.parse( $source );
		my $tree = $pt.build-tree( $parsed );
		ok $pt.validate( $parsed ), Q{valid};
		is $pt.to-string( $tree ), $source, Q{formatted};
	}, Q{no ws};

	subtest {
		plan 2;

		my $source = Q:to[_END_];
my @a; :@a
_END_
		my $parsed = $pt.parse( $source );
		my $tree = $pt.build-tree( $parsed );
		ok $pt.validate( $parsed ), Q{valid};
		is $pt.to-string( $tree ), $source, Q{formatted};
	}, Q{ws};
}, Q{:@a};

subtest {
	plan 2;

	subtest {
		plan 2;

		my $source = Q{my%a;:%a};
		my $parsed = $pt.parse( $source );
		my $tree = $pt.build-tree( $parsed );
		ok $pt.validate( $parsed ), Q{valid};
		is $pt.to-string( $tree ), $source, Q{formatted};
	}, Q{no ws};

	subtest {
		plan 2;

		my $source = Q:to[_END_];
my %a; :%a
_END_
		my $parsed = $pt.parse( $source );
		my $tree = $pt.build-tree( $parsed );
		ok $pt.validate( $parsed ), Q{valid};
		is $pt.to-string( $tree ), $source, Q{formatted};
	}, Q{ws};
}, Q{:%a};

subtest {
	plan 2;

	subtest {
		plan 2;

		my $source = Q{my&a;:&a};
		my $parsed = $pt.parse( $source );
		my $tree = $pt.build-tree( $parsed );
		ok $pt.validate( $parsed ), Q{valid};
		is $pt.to-string( $tree ), $source, Q{formatted};
	}, Q{no ws};

	subtest {
		plan 2;

		my $source = Q:to[_END_];
my &a; :&a
_END_
		my $parsed = $pt.parse( $source );
		my $tree = $pt.build-tree( $parsed );
		ok $pt.validate( $parsed ), Q{valid};
		is $pt.to-string( $tree ), $source, Q{formatted};
	}, Q{ws};
}, Q{:&a};

# vim: ft=perl6
