use v6;

use Test;
use Perl6::Parser;

plan 3;

my $pt = Perl6::Parser.new;
my $*VALIDATION-FAILURE-FATAL = True;
my $*FACTORY-FAILURE-FATAL = True;
my $*DEBUG = True;

subtest {
	plan 2;

	my $source = Q:to[_END_];
#!/usr/bin/env perl6
_END_
	my $parsed = $pt.parse( $source );
	my $tree = $pt.build-tree( $parsed );
	ok $pt.validate( $parsed ), Q{valid};
	is $pt.to-string( $tree ), $source, Q{formatted};
}, Q{shebang line};

subtest {
	plan 2;

	subtest {
		plan 2;

		my $source = Q:to[_END_];
# comment to end of line
_END_
		my $parsed = $pt.parse( $source );
		my $tree = $pt.build-tree( $parsed );
		ok $pt.validate( $parsed ), Q{valid};
		is $pt.to-string( $tree ), $source, Q{formatted};
	}, Q{single EOL comment};

	subtest {
		plan 2;

		my $source = Q:to[_END_];
# comment to end of line
# comment to end of line
_END_
		my $parsed = $pt.parse( $source );
		my $tree = $pt.build-tree( $parsed );
		ok $pt.validate( $parsed ), Q{valid};
		is $pt.to-string( $tree ), $source, Q{formatted};
	}, Q{Two EOL comments in a row};
}, Q{full-line comments};

subtest {
	plan 2;

	subtest {
		plan 2;

		my $source = Q:to[_END_];
#`( comment on single line )
_END_
		my $parsed = $pt.parse( $source );
		my $tree = $pt.build-tree( $parsed );
		ok $pt.validate( $parsed ), Q{valid};
		is $pt.to-string( $tree ), $source, Q{formatted};
	}, Q{single EOL comment};

	subtest {
		plan 2;

		my $source = Q:to[_END_];
#`( comment
spanning
multiple
lines )
_END_
		my $parsed = $pt.parse( $source );
		my $tree = $pt.build-tree( $parsed );
		ok $pt.validate( $parsed ), Q{valid};
		is $pt.to-string( $tree ), $source, Q{formatted};
	}, Q{Two EOL comments in a row};
}, Q{spanning comment};

# vim: ft=perl6
