use v6;

use Test;
use Perl6::Tidy;

plan 14;

my $pt = Perl6::Tidy.new;
#my $*TRACE = 1;
#my $*DEBUG = 1;

subtest {
	plan 1;

	my $parsed = $pt.parse-source( Q:to[_END_] );
a => 1
_END_
	ok $pt.validate( $parsed );
}, Q{a => 1};

subtest {
	plan 1;

	my $parsed = $pt.parse-source( Q:to[_END_] );
'a' => 'b'
_END_
	ok $pt.validate( $parsed );
}, Q{'a' => 'b'};

subtest {
	plan 1;

	my $parsed = $pt.parse-source( Q:to[_END_] );
:a
_END_
	ok $pt.validate( $parsed );
}, Q{:a};

subtest {
	plan 1;

	my $parsed = $pt.parse-source( Q:to[_END_] );
:!a
_END_
	ok $pt.validate( $parsed );
}, Q{:!a};

subtest {
	plan 1;

	my $parsed = $pt.parse-source( Q:to[_END_] );
:a<b>
_END_
	ok $pt.validate( $parsed );
}, Q{:a<b>};

subtest {
	plan 1;

	my $parsed = $pt.parse-source( Q:to[_END_] );
:a<b c>
_END_
	ok $pt.validate( $parsed );
}, Q{:a<b c>};

subtest {
	plan 1;

	my $parsed = $pt.parse-source( Q:to[_END_] );
my $a; :a{$a}
_END_
	ok $pt.validate( $parsed );
}, Q{:a{$a}};

subtest {
	plan 1;

	my $parsed = $pt.parse-source( Q:to[_END_] );
:a{'a', 'b'}
_END_
	ok $pt.validate( $parsed );
}, Q{:a{'a', 'b'}};

subtest {
	plan 1;

	my $parsed = $pt.parse-source( Q:to[_END_] );
:a{'a' => 'b'}
_END_
	ok $pt.validate( $parsed );
}, Q{:a{'a' => 'b'}};

subtest {
	plan 1;

	my $parsed = $pt.parse-source( Q:to[_END_] );
:a{'a' => 'b'}
_END_
	ok $pt.validate( $parsed );
}, Q{:a{'a' => 'b'}};

subtest {
	plan 1;

	my $parsed = $pt.parse-source( Q:to[_END_] );
my $a; :$a
_END_
	ok $pt.validate( $parsed );
}, Q{:$a};

subtest {
	plan 1;

	my $parsed = $pt.parse-source( Q:to[_END_] );
my @a; :@a
_END_
	ok $pt.validate( $parsed );
}, Q{:@a};

subtest {
	plan 1;

	my $parsed = $pt.parse-source( Q:to[_END_] );
my %a; :%a
_END_
	ok $pt.validate( $parsed );
}, Q{:%a};

subtest {
	plan 1;

	my $parsed = $pt.parse-source( Q:to[_END_] );
my sub a { }; :&a
_END_
	ok $pt.validate( $parsed );
}, Q{:&a};

# vim: ft=perl6
