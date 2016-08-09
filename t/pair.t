use v6;

use Test;
use Perl6::Tidy;

plan 14;

my $pt = Perl6::Tidy.new;
#my $*TRACE = 1;
#my $*DEBUG = 1;

subtest {
	plan 2;

	my $parsed = $pt.parse-source( Q:to[_END_].chomp );
a => 1
_END_
	my $tree = $pt.build-tree( $parsed );
	ok $pt.validate( $parsed ), Q{valid};
#	is $pt.format( $tree ), Q:to[_END_].chomp, Q{formatted};
#a => 1
#_END_
	is $pt.format( $tree ), Q:to[_END_].chomp, Q{formatted};
a=>1
_END_
}, Q{a => 1};

subtest {
	plan 2;

	my $parsed = $pt.parse-source( Q:to[_END_].chomp );
'a' => 'b'
_END_
	my $tree = $pt.build-tree( $parsed );
	ok $pt.validate( $parsed ), Q{valid};
#	is $pt.format( $tree ), Q:to[_END_].chomp, Q{formatted};
#'a' => 'b'
#_END_
	is $pt.format( $tree ), Q:to[_END_].chomp, Q{formatted};
'a'=>'b'
_END_
}, Q{'a' => 'b'};

subtest {
	plan 2;

	my $parsed = $pt.parse-source( Q:to[_END_].chomp );
:a
_END_
	my $tree = $pt.build-tree( $parsed );
	ok $pt.validate( $parsed ), Q{valid};
#	is $pt.format( $tree ), Q:to[_END_].chomp, Q{formatted};
#:a
#_END_
	is $pt.format( $tree ), Q:to[_END_].chomp, Q{formatted};
:a
_END_
}, Q{:a};

subtest {
	plan 2;

	my $parsed = $pt.parse-source( Q:to[_END_].chomp );
:!a
_END_
	my $tree = $pt.build-tree( $parsed );
	ok $pt.validate( $parsed ), Q{valid};
#	is $pt.format( $tree ), Q:to[_END_].chomp, Q{formatted};
#:!a
#_END_
	is $pt.format( $tree ), Q:to[_END_].chomp, Q{formatted};
:!a
_END_
}, Q{:!a};

subtest {
	plan 2;

	my $parsed = $pt.parse-source( Q:to[_END_].chomp );
:a<b>
_END_
	my $tree = $pt.build-tree( $parsed );
	ok $pt.validate( $parsed ), Q{valid};
#	is $pt.format( $tree ), Q:to[_END_].chomp, Q{formatted};
#:a<b>
#_END_
	is $pt.format( $tree ), Q:to[_END_].chomp, Q{formatted};
:a<b>
_END_
}, Q{:a<b>};

subtest {
	plan 2;

	my $parsed = $pt.parse-source( Q:to[_END_].chomp );
:a<b c>
_END_
	my $tree = $pt.build-tree( $parsed );
	ok $pt.validate( $parsed ), Q{valid};
#	is $pt.format( $tree ), Q:to[_END_].chomp, Q{formatted};
#:a<b c>
#_END_
	is $pt.format( $tree ), Q:to[_END_].chomp, Q{formatted};
:a<b c>
_END_
}, Q{:a<b c>};

subtest {
	plan 1;

	my $parsed = $pt.parse-source( Q:to[_END_] );
my $a; :a{$a}
_END_
	ok $pt.validate( $parsed );
#`(
	plan 2;

	my $parsed = $pt.parse-source( Q:to[_END_].chomp );
my $a; :a{$a}
my rule foo { a }
_END_
	my $tree = $pt.build-tree( $parsed );
	ok $pt.validate( $parsed ), Q{valid};
#	is $pt.format( $tree ), Q:to[_END_].chomp, Q{formatted};
#my $a; :a{$a}
#_END_
	is $pt.format( $tree ), Q:to[_END_].chomp, Q{formatted};
my$a;:a{$a}
_END_
)
}, Q{:a{$a}};

subtest {
	plan 1;

	my $parsed = $pt.parse-source( Q:to[_END_] );
:a{'a', 'b'}
_END_
	ok $pt.validate( $parsed );
#`(
	plan 2;

	my $parsed = $pt.parse-source( Q:to[_END_].chomp );
:a{'a', 'b'}
_END_
	my $tree = $pt.build-tree( $parsed );
	ok $pt.validate( $parsed ), Q{valid};
#	is $pt.format( $tree ), Q:to[_END_].chomp, Q{formatted};
#:a{'a', 'b'}
#_END_
	is $pt.format( $tree ), Q:to[_END_].chomp, Q{formatted};
:a{'a','b'}
_END_
)
}, Q{:a{'a', 'b'}};

subtest {
	plan 1;

	my $parsed = $pt.parse-source( Q:to[_END_] );
:a{'a' => 'b'}
_END_
	ok $pt.validate( $parsed );
#`(
	plan 2;

	my $parsed = $pt.parse-source( Q:to[_END_].chomp );
:a{'a' => 'b'}
_END_
	my $tree = $pt.build-tree( $parsed );
	ok $pt.validate( $parsed ), Q{valid};
#	is $pt.format( $tree ), Q:to[_END_].chomp, Q{formatted};
#:a{'a' => 'b'}
#_END_
	is $pt.format( $tree ), Q:to[_END_].chomp, Q{formatted};
:a{'a'=>'b'}
_END_
)
}, Q{:a{'a' => 'b'}};

subtest {
	plan 1;

	my $parsed = $pt.parse-source( Q:to[_END_] );
:a{'a' => 'b'}
_END_
	ok $pt.validate( $parsed );
#`(
	plan 2;

	my $parsed = $pt.parse-source( Q:to[_END_].chomp );
:a{'a' => 'b'}
_END_
	my $tree = $pt.build-tree( $parsed );
	ok $pt.validate( $parsed ), Q{valid};
#	is $pt.format( $tree ), Q:to[_END_].chomp, Q{formatted};
#:a{'a' => 'b'}
#_END_
	is $pt.format( $tree ), Q:to[_END_].chomp, Q{formatted};
:a{'a'=>'b'}
_END_
)
}, Q{:a{'a' => 'b'}};

subtest {
	plan 1;

	my $parsed = $pt.parse-source( Q:to[_END_] );
my $a; :$a
_END_
	ok $pt.validate( $parsed );
#`(
	plan 2;

	my $parsed = $pt.parse-source( Q:to[_END_].chomp );
my $a; :$a
_END_
	my $tree = $pt.build-tree( $parsed );
	ok $pt.validate( $parsed ), Q{valid};
#	is $pt.format( $tree ), Q:to[_END_].chomp, Q{formatted};
#my $a; :$a
#_END_
	is $pt.format( $tree ), Q:to[_END_].chomp, Q{formatted};
my$a;:$a
_END_
)
}, Q{:$a};

subtest {
	plan 1;

	my $parsed = $pt.parse-source( Q:to[_END_] );
my @a; :@a
_END_
	ok $pt.validate( $parsed );
#`(
	plan 2;

	my $parsed = $pt.parse-source( Q:to[_END_].chomp );
my @a; :@a
_END_
	my $tree = $pt.build-tree( $parsed );
	ok $pt.validate( $parsed ), Q{valid};
#	is $pt.format( $tree ), Q:to[_END_].chomp, Q{formatted};
#my @a; :@a
#_END_
	is $pt.format( $tree ), Q:to[_END_].chomp, Q{formatted};
my@a;:@a
_END_
)
}, Q{:@a};

subtest {
	plan 1;

	my $parsed = $pt.parse-source( Q:to[_END_] );
my %a; :%a
_END_
	ok $pt.validate( $parsed );
#`(
	plan 2;

	my $parsed = $pt.parse-source( Q:to[_END_].chomp );
my %a; :%a
_END_
	my $tree = $pt.build-tree( $parsed );
	ok $pt.validate( $parsed ), Q{valid};
#	is $pt.format( $tree ), Q:to[_END_].chomp, Q{formatted};
#my %a; :%a
#_END_
	is $pt.format( $tree ), Q:to[_END_].chomp, Q{formatted};
my%a;:%a
_END_
)
}, Q{:%a};

subtest {
	plan 1;

	my $parsed = $pt.parse-source( Q:to[_END_] );
my sub a { }; :&a
_END_
	ok $pt.validate( $parsed );
#`(
	plan 2;

	my $parsed = $pt.parse-source( Q:to[_END_].chomp );
my sub a { }; :&a
_END_
	my $tree = $pt.build-tree( $parsed );
	ok $pt.validate( $parsed ), Q{valid};
#	is $pt.format( $tree ), Q:to[_END_].chomp, Q{formatted};
#my sub a { }; :&a
#_END_
	is $pt.format( $tree ), Q:to[_END_].chomp, Q{formatted};
mysuba{};:&a
_END_
)
}, Q{:&a};

# vim: ft=perl6
