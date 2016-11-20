use v6;

use Test;
use Perl6::Parser;

my $pt = Perl6::Parser.new;
my $*VALIDATION-FAILURE-FATAL = True;
my $*FACTORY-FAILURE-FATAL = True;
my $*DEBUG = True;

subtest {
	plan 2;

	my $source = Q:to[_END_];
say <closed open>;
_END_
	my $p = $pt.parse( $source );
	my $tree = $pt.build-tree( $p );
#say $pt.dump-tree($tree);
	ok $pt.validate( $p ), Q{valid};
	is $pt.format( $tree ), $source, Q{formatted};
}, Q{say <closed open>};

my @quantities = flat (99 ... 1), 'No more', 99;

subtest {
	plan 2;

	my $source = Q:to[_END_];
my @quantities = flat (99 ... 1), 'No more', 99;
_END_
	my $p = $pt.parse( $source );
	my $tree = $pt.build-tree( $p );
#say $pt.dump-tree($tree);
	ok $pt.validate( $p ), Q{valid};
	is $pt.format( $tree ), $source, Q{formatted};
}, Q{flat (99 ... 1)};

subtest {
	plan 2;

	my $source = Q:to[_END_];
sub foo( $a is copy ) { }
_END_
	my $p = $pt.parse( $source );
	my $tree = $pt.build-tree( $p );
#say $pt.dump-tree($tree);
	ok $pt.validate( $p ), Q{valid};
	is $pt.format( $tree ), $source, Q{formatted};
}, Q{flat (99 ... 1)};

subtest {
	plan 2;

	my $source = Q:to[_END_];
grammar Foo {
    token TOP { ^ <exp> $ { fail } }
}
_END_
	my $p = $pt.parse( $source );
	my $tree = $pt.build-tree( $p );
#say $pt.dump-tree($tree);
	ok $pt.validate( $p ), Q{valid};
	is $pt.format( $tree ), $source, Q{formatted};
}, Q{flat (99 ... 1)};

subtest {
	plan 2;

	my $source = Q:to[_END_];
grammar Foo {
    rule exp { <term>+ % <op> }
}
_END_
	my $p = $pt.parse( $source );
	my $tree = $pt.build-tree( $p );
#say $pt.dump-tree($tree);
	ok $pt.validate( $p ), Q{valid};
	is $pt.format( $tree ), $source, Q{formatted};
}, Q{flat (99 ... 1)};

subtest {
	plan 2;

	my $source = Q:to[_END_];
my @blocks;
@blocks.grep: { }
_END_
	my $p = $pt.parse( $source );
	my $tree = $pt.build-tree( $p );
#say $pt.dump-tree($tree);
	ok $pt.validate( $p ), Q{valid};
	is $pt.format( $tree ), $source, Q{formatted};
}, Q{grep: {}};

subtest {
	plan 2;

	my $source = Q:to[_END_];
my \y = 1;
_END_
	my $p = $pt.parse( $source );
	my $tree = $pt.build-tree( $p );
#say $pt.dump-tree($tree);
	ok $pt.validate( $p ), Q{valid};
	is $pt.format( $tree ), $source, Q{formatted};
}, Q{my \y};

subtest {
	plan 2;

	my $source = Q:to[_END_];
class Bitmap {
  method fill-pixel($i) { }
}
_END_
	my $p = $pt.parse( $source );
	my $tree = $pt.build-tree( $p );
	ok $pt.validate( $p ), Q{valid};
	is $pt.format( $tree ), $source, Q{formatted};
}, Q{method fill-pixel($i)};

subtest {
	plan 2;

	my $source = Q:to[_END_];
my %dir = (
   "\e[A" => 'up',
   "\e[B" => 'down',
);
_END_
	my $p = $pt.parse( $source );
	my $tree = $pt.build-tree( $p );
	ok $pt.validate( $p ), Q{valid};
	is $pt.format( $tree ), $source, Q{formatted};
}, Q{method fill-pixel($i)};

done-testing;

# vim: ft=perl6
