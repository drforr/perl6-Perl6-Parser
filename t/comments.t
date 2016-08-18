use v6;

use Test;
use Perl6::Tidy;

#`(

In passing, please note that while it's trivially possible to bum down the
tests, doing so makes it harder to insert 'say $parsed.dump' to view the
AST, and 'say $tree.perl' to view the generated Perl 6 structure.

)

plan 3;

my $pt = Perl6::Tidy.new;
#my $*TRACE = 1;
#my $*DEBUG = 1;

subtest {
	plan 1;

	my $parsed = $pt.parse-source( Q:to[_END_] );
#!/usr/bin/env perl6
_END_
	ok $pt.validate( $parsed );
#`(
	plan 2;

	my $parsed = $pt.parse-source( Q:to[_END_].chomp );
#!/usr/bin/env perl6
_END_
	my $tree = $pt.build-tree( $parsed );
	ok $pt.validate( $parsed ), Q{valid};
#	is $pt.format( $tree ), Q:to[_END_], Q{formatted};
##!/usr/bin/env perl6
#_END_
	is $pt.format( $tree ), Q{#!/usr/bin/env perl6}, Q{formatted};
)
}, Q{shebang line};

subtest {
	plan 2;

	subtest {
		plan 1;

		my $parsed = $pt.parse-source( Q:to[_END_] );
# comment to end of line
_END_
		ok $pt.validate( $parsed );
#`(
		plan 2;

		my $parsed = $pt.parse-source( Q:to[_END_].chomp );
# comment to end of line
_END_
		my $tree = $pt.build-tree( $parsed );
		ok $pt.validate( $parsed ), Q{valid};
#		is $pt.format( $tree ), Q:to[_END_], Q{formatted};
## comment to end of line
#_END_
		is $pt.format( $tree ),
			Q{# comment to end of line}, Q{formatted};
)
	}, Q{single EOL comment};

	subtest {
		plan 1;

		my $parsed = $pt.parse-source( Q:to[_END_] );
# comment to end of line
# comment to end of line
_END_
		ok $pt.validate( $parsed );
#`(
		plan 2;

		my $parsed = $pt.parse-source( Q:to[_END_].chomp );
# comment to end of line
# comment to end of line
_END_
		my $tree = $pt.build-tree( $parsed );
		ok $pt.validate( $parsed ), Q{valid};
#		is $pt.format( $tree ), Q:to[_END_], Q{formatted};
## comment to end of line
## comment to end of line
#_END_
		is $pt.format( $tree ), Q:to[_END_], Q{formatted};
# comment to end of line# comment to end of line
_END_
)
	}, Q{Two EOL comments in a row};
}, Q{full-line comments};

subtest {
	plan 2;

	subtest {
		plan 1;

		my $parsed = $pt.parse-source( Q:to[_END_] );
#`( comment on single line )
_END_
		ok $pt.validate( $parsed );
#`(
		plan 2;

		my $parsed = $pt.parse-source( Q:to[_END_].chomp );
#`( comment on single line )
_END_
		my $tree = $pt.build-tree( $parsed );
		ok $pt.validate( $parsed ), Q{valid};
#		is $pt.format( $tree ), Q:to[_END_], Q{formatted};
##`( comment on single line )
#_END_
		is $pt.format( $tree ), Q:to[_END_], Q{formatted};
#`( comment on single line )
_END_
)
	}, Q{single EOL comment};

	subtest {
		plan 1;

		my $parsed = $pt.parse-source( Q:to[_END_] );
#`( comment
spanning
multiple
lines )
_END_
		ok $pt.validate( $parsed );
#`(
		plan 2;

		my $parsed = $pt.parse-source( Q:to[_END_].chomp );
#`( comment
spanning
multiple
lines )
_END_
		my $tree = $pt.build-tree( $parsed );
		ok $pt.validate( $parsed ), Q{valid};
#		is $pt.format( $tree ), Q:to[_END_], Q{formatted};
##`( comment
#spanning
#multiple
#lines )
#_END_
		is $pt.format( $tree ), Q:to[_END_], Q{formatted};
#`( commentspanningmultiplelines )
_END_
)
	}, Q{Two EOL comments in a row};
}, Q{spanning comment};

# vim: ft=perl6
