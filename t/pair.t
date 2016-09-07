use v6;

use Test;
use Perl6::Tidy;

#`(

In passing, please note that while it's trivially possible to bum down the
tests, doing so makes it harder to insert 'say $parsed.dump' to view the
AST, and 'say $tree.perl' to view the generated Perl 6 structure.

)

plan 13;

my $pt = Perl6::Tidy.new;
#my $*TRACE = 1;
#my $*DEBUG = 1;

subtest {
	plan 2;

#`(
	my $source = Q:to[_END_];
a => 1
_END_
	my $parsed = $pt.parse-source( $source );
	my $tree = $pt.build-tree( $parsed );
	ok $pt.validate( $parsed ), Q{valid};
	is $pt.format( $tree ), $source, Q{formatted};
)
}, Q{a => 1};

subtest {
	plan 2;

#`(
	my $source = Q:to[_END_];
'a' => 'b'
_END_
	my $parsed = $pt.parse-source( $source );
	my $tree = $pt.build-tree( $parsed );
	ok $pt.validate( $parsed ), Q{valid};
	is $pt.format( $tree ), $source, Q{formatted};
)
}, Q{a => 1};

subtest {
	plan 2;

#`(
	my $source = Q:to[_END_];
:a
_END_
	my $parsed = $pt.parse-source( $source );
	my $tree = $pt.build-tree( $parsed );
	ok $pt.validate( $parsed ), Q{valid};
	is $pt.format( $tree ), $source, Q{formatted};
)
}, Q{:a};

subtest {
	plan 2;

#`(
	my $source = Q:to[_END_];
:!a
_END_
	my $parsed = $pt.parse-source( $source );
	my $tree = $pt.build-tree( $parsed );
	ok $pt.validate( $parsed ), Q{valid};
	is $pt.format( $tree ), $source, Q{formatted};
)
}, Q{:!a};

subtest {
	plan 2;

#`(
	my $source = Q:to[_END_];
:a<b>
_END_
	my $parsed = $pt.parse-source( $source );
	my $tree = $pt.build-tree( $parsed );
	ok $pt.validate( $parsed ), Q{valid};
	is $pt.format( $tree ), $source, Q{formatted};
)
}, Q{:a<b>};

subtest {
	plan 2;

#`(
	my $source = Q:to[_END_];
:a<b c>
_END_
	my $parsed = $pt.parse-source( $source );
	my $tree = $pt.build-tree( $parsed );
	ok $pt.validate( $parsed ), Q{valid};
	is $pt.format( $tree ), $source, Q{formatted};
)
}, Q{:a<b c>};

subtest {
	plan 2;

	subtest {
		plan 2;

#`(
		my $source = Q:to[_END_];
my $a;:a{$a}
_END_
		my $parsed = $pt.parse-source( $source );
		my $tree = $pt.build-tree( $parsed );
		ok $pt.validate( $parsed ), Q{valid};
		is $pt.format( $tree ), $source, Q{formatted};
)
	}, Q{:a{$a}};

	subtest {
		plan 2;

#`(
		my $source = Q:to[_END_];
my $a; :a{$a}
_END_
		my $parsed = $pt.parse-source( $source );
		my $tree = $pt.build-tree( $parsed );
		ok $pt.validate( $parsed ), Q{valid};
		is $pt.format( $tree ), $source, Q{formatted};
)
	}, Q{with WS};
}, Q{:a{$a}};

subtest {
	plan 2;

#`(
	my $source = Q:to[_END_];
:a{'a', 'b'}
_END_
	my $parsed = $pt.parse-source( $source );
	my $tree = $pt.build-tree( $parsed );
	ok $pt.validate( $parsed ), Q{valid};
	is $pt.format( $tree ), $source, Q{formatted};
)
}, Q{:a{'a', 'b'}};

subtest {
	plan 2;

#`(
	my $source = Q:to[_END_];
:a{'a' => 'b'}
_END_
	my $parsed = $pt.parse-source( $source );
	my $tree = $pt.build-tree( $parsed );
	ok $pt.validate( $parsed ), Q{valid};
	is $pt.format( $tree ), $source, Q{formatted};
)
}, Q{:a{'a' => 'b'}};

subtest {
	plan 2;

#`(
	my $source = Q:to[_END_];
my $a; :$a
_END_
	my $parsed = $pt.parse-source( $source );
	my $tree = $pt.build-tree( $parsed );
	ok $pt.validate( $parsed ), Q{valid};
	is $pt.format( $tree ), $source, Q{formatted};
)
}, Q{:$a};

subtest {
	plan 2;

#`(
	my $source = Q:to[_END_];
my @a; :@a
_END_
	my $parsed = $pt.parse-source( $source );
	my $tree = $pt.build-tree( $parsed );
	ok $pt.validate( $parsed ), Q{valid};
	is $pt.format( $tree ), $source, Q{formatted};
)
}, Q{:@a};

subtest {
	plan 2;

#`(
	my $source = Q:to[_END_];
my %a; :%a
_END_
	my $parsed = $pt.parse-source( $source );
	my $tree = $pt.build-tree( $parsed );
	ok $pt.validate( $parsed ), Q{valid};
	is $pt.format( $tree ), $source, Q{formatted};
)
}, Q{:%a};

subtest {
	plan 2;

#`(
	my $source = Q:to[_END_];
my sub a { }; :&a
_END_
	my $parsed = $pt.parse-source( $source );
	my $tree = $pt.build-tree( $parsed );
	ok $pt.validate( $parsed ), Q{valid};
	is $pt.format( $tree ), $source, Q{formatted};
)
}, Q{:&a};

# vim: ft=perl6
