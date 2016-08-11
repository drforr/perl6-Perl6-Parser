use v6;

use Test;
use Perl6::Tidy;

plan 2;

my $pt = Perl6::Tidy.new;
#my $*TRACE = 1;
#my $*DEBUG = 1;

subtest {
	plan 2;

	my $parsed = $pt.parse-source( Q:to[_END_].chomp );
sub foo { }
_END_
	my $tree = $pt.build-tree( $parsed );
	ok $pt.validate( $parsed ), Q{valid};
#	is $pt.format( $tree ), Q:to[_END_].chomp, Q{formatted};
#sub foo { }
#_END_
	is $pt.format( $tree ), Q{subfoo{}}, Q{formatted};
}, Q{empty};

subtest {
	plan 2;

	subtest {
		plan 6;

		subtest {
			plan 2;

			my $parsed = $pt.parse-source( Q:to[_END_].chomp );
sub foo( ) { }
_END_
			my $tree = $pt.build-tree( $parsed );
			ok $pt.validate( $parsed ), Q{valid};
#			is $pt.format( $tree ), Q:to[_END_], Q{formatted};
#sub foo( ) { }
#_END_
			is $pt.format( $tree ), Q{subfoo(){}}, Q{formatted};
		}, Q{empty};

		subtest {
			plan 2;

			my $parsed = $pt.parse-source( Q:to[_END_].chomp );
sub foo( 0 ) { }
_END_
say $parsed.dump;
			my $tree = $pt.build-tree( $parsed );
say $tree.perl;
			ok $pt.validate( $parsed ), Q{valid};
#			is $pt.format( $tree ), Q:to[_END_], Q{formatted};
#sub foo( 0 ) { }
#_END_
			is $pt.format( $tree ), Q{subfoo(0){}}, Q{formatted};
		}, Q{constant};

		subtest {
			plan 1;

			my $parsed = $pt.parse-source( Q:to[_END_] );
sub foo( $a ) { }
_END_
			ok $pt.validate( $parsed );
#`(
			plan 2;

			my $parsed = $pt.parse-source( Q:to[_END_].chomp );
sub foo( $a ) { }
_END_
			my $tree = $pt.build-tree( $parsed );
			ok $pt.validate( $parsed ), Q{valid};
#			is $pt.format( $tree ), Q:to[_END_], Q{formatted};
#sub foo( $a ) { }
#_END_
			is $pt.format( $tree ), Q{subfoo($a){}}, Q{formatted};
)
		}, Q{untyped};

		subtest {
			plan 4;

			subtest {
				plan 1;

				my $parsed = $pt.parse-source( Q:to[_END_] );
sub foo( Str $a ) { }
_END_
				ok $pt.validate( $parsed );
#`(
				plan 2;

				my $parsed = $pt.parse-source( Q:to[_END_].chomp );
sub foo( Str $a ) { }
_END_
				my $tree = $pt.build-tree( $parsed );
				ok $pt.validate( $parsed ), Q{valid};
#				is $pt.format( $tree ), Q:to[_END_].chomp, Q{formatted};
#sub foo( Str $a ) { }
#_END_
				is $pt.format( $tree ), Q{subfoo(Str$a){}}, Q{formatted};
)
			}, Q{typed};

			subtest {
				plan 1;

				my $parsed = $pt.parse-source( Q:to[_END_] );
sub foo( ::T $a ) { }
_END_
				ok $pt.validate( $parsed );
#`(
				plan 2;

				my $parsed = $pt.parse-source( Q:to[_END_].chomp );
sub foo( ::T $a ) { }
_END_
				my $tree = $pt.build-tree( $parsed );
				ok $pt.validate( $parsed ), Q{valid};
#				is $pt.format( $tree ), Q:to[_END_].chomp, Q{formatted};
#sub foo( ::T $a ) { }
#_END_
				is $pt.format( $tree ), Q{subfoo(::T$a){}}, Q{formatted};
)
			}, Q{type-capture};

			subtest {
				plan 1;

				my $parsed = $pt.parse-source( Q:to[_END_] );
sub foo( Str ) { }
_END_
				ok $pt.validate( $parsed );
#`(
				plan 2;

				my $parsed = $pt.parse-source( Q:to[_END_].chomp );
sub foo( Str ) { }
_END_
				my $tree = $pt.build-tree( $parsed );
				ok $pt.validate( $parsed ), Q{valid};
#				is $pt.format( $tree ), Q:to[_END_].chomp, Q{formatted};
#sub foo( Str ) { }
#_END_
				is $pt.format( $tree ), Q{subfoo(Str){}}, Q{formatted};
)
			}, Q{type-only};

			subtest {
				plan 1;

				my $parsed = $pt.parse-source( Q:to[_END_] );
sub foo( Str $a where "foo" ) { }
_END_
				ok $pt.validate( $parsed );
#`(
				plan 2;

				my $parsed = $pt.parse-source( Q:to[_END_].chomp );
sub foo( Str $a where "foo" ) { }
_END_
				my $tree = $pt.build-tree( $parsed );
				ok $pt.validate( $parsed ), Q{valid};
#				is $pt.format( $tree ), Q:to[_END_].chomp, Q{formatted};
#sub foo( Str $a where "foo" ) { }
#_END_
				is $pt.format( $tree ), Q{subfoo(Str$awhere"foo"){}}, Q{formatted};
)
			}, Q{type-constrained};
		}, Q{typed};

		subtest {
			plan 1;

			my $parsed = $pt.parse-source( Q:to[_END_] );
sub foo( $a = 0 ) { }
_END_
			ok $pt.validate( $parsed );
#`(
			plan 2;

			my $parsed = $pt.parse-source( Q:to[_END_].chomp );
sub foo( $a = 0 ) { }
_END_
			my $tree = $pt.build-tree( $parsed );
			ok $pt.validate( $parsed ), Q{valid};
#			is $pt.format( $tree ), Q:to[_END_].chomp, Q{formatted};
#sub foo( $a = 0 ) { }
#_END_
			is $pt.format( $tree ), Q{subfoo($a=0){}}, Q{formatted};
)
		}, Q{default};

		subtest {
			plan 1;

			my $parsed = $pt.parse-source( Q:to[_END_] );
sub foo( :$a ) { }
_END_
			ok $pt.validate( $parsed );
#`(
			plan 2;

			my $parsed = $pt.parse-source( Q:to[_END_].chomp );
sub foo( :$a ) { }
_END_
			my $tree = $pt.build-tree( $parsed );
			ok $pt.validate( $parsed ), Q{valid};
#			is $pt.format( $tree ), Q:to[_END_].chomp, Q{formatted};
#sub foo( :$a ) { }
#_END_
			is $pt.format( $tree ), Q{subfoo(:$a){}}, Q{formatted};
)
		}, Q{optional};
	}, Q{single};

	subtest {
		plan 1;

		my $parsed = $pt.parse-source( Q:to[_END_] );
sub foo( $a, $b ) { }
_END_
		ok $pt.validate( $parsed );
#`(
		plan 2;

		my $parsed = $pt.parse-source( Q:to[_END_].chomp );
sub foo( $a, $b ) { }
_END_
		my $tree = $pt.build-tree( $parsed );
		ok $pt.validate( $parsed ), Q{valid};
#		is $pt.format( $tree ), Q:to[_END_].chomp, Q{formatted};
#sub foo( $a, $b ) { }
#_END_
		is $pt.format( $tree ), Q{subfoo($a,$b){}}, Q{formatted};
)
	}, Q{multiple};
}, Q{scalar arguments};

# vim: ft=perl6
