use v6;

use Test;
use Perl6::Tidy;

#`(

In passing, please note that while it's trivially possible to bum down the
tests, doing so makes it harder to insert 'say $parsed.dump' to view the
AST, and 'say $tree.perl' to view the generated Perl 6 structure.

)

plan 4;

my $pt = Perl6::Tidy.new;
#my $*TRACE = 1;
#my $*DEBUG = 1;

subtest {
	plan 2;

#`(
	my $source = Q:to[_END_];
/pi/
_END_
	my $parsed = $pt.parse-source( $source );
	my $tree = $pt.build-tree( $parsed );
	ok $pt.validate( $parsed ), Q{valid};
	is $pt.format( $tree ), $source, Q{formatted};
)
}, Q{/pi/};

subtest {
	plan 2;

#`(
	my $source = Q:to[_END_];
/<[ p i ]>/
_END_
	my $parsed = $pt.parse-source( $source );
	my $tree = $pt.build-tree( $parsed );
	ok $pt.validate( $parsed ), Q{valid};
	is $pt.format( $tree ), $source, Q{formatted};
)
}, Q{/<[ p i ]>/};

subtest {
	plan 2;

#`(
	my $source = Q:to[_END_];
/ \d /
_END_
	my $parsed = $pt.parse-source( $source );
	my $tree = $pt.build-tree( $parsed );
	ok $pt.validate( $parsed ), Q{valid};
	is $pt.format( $tree ), $source, Q{formatted};
)
}, Q{/ \d /};

subtest {
	plan 2;

#`(
	my $source = Q:to[_END_];
/ . /
_END_
	my $parsed = $pt.parse-source( $source );
	my $tree = $pt.build-tree( $parsed );
	ok $pt.validate( $parsed ), Q{valid};
	is $pt.format( $tree ), $source, Q{formatted};
)
}, Q{/ . /};

# vim: ft=perl6
