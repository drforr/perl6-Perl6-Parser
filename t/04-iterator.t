use v6;

use Test;
use Perl6::Parser;

plan 2;

my $pp                 = Perl6::Parser.new;
my $*CONSISTENCY-CHECK = True;
my $*FALL-THROUGH      = True;

subtest {
	my $source = Q{();2;1;};
	my @token = $pp.to-list( $source );
	my $iterated = '';

	for grep { .textual }, @token {
		$iterated ~= $_.content;
	}
	is $iterated, $source, Q{pull-one returns complete list};

	done-testing;
}, Q{default iterator pull-one};

subtest {
	my $source = Q{();2;1;};
	my @token = $pp.to-tokens-only( $source );
	my $iterated = '';

	for @token {
		$iterated ~= $_.content;
	}
	is $iterated, $source, Q{tokens only display cleanly};

	done-testing;
}, Q{token-only iterator}

# vim: ft=perl6
