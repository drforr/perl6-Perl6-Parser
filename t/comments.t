use v6;

use Test;
use Perl6::Tidy;

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
}, Q{shebang line};

subtest {
	plan 2;

	subtest {
		plan 1;

		my $parsed = $pt.parse-source( Q:to[_END_] );
# comment to end of line
_END_
		ok $pt.validate( $parsed );
	}, Q{single EOL comment};

	subtest {
		plan 1;

		my $parsed = $pt.parse-source( Q:to[_END_] );
# comment to end of line
# comment to end of line
_END_
		ok $pt.validate( $parsed );
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
	}, Q{Two EOL comments in a row};
}, Q{spanning comment};

# vim: ft=perl6
