use v6;

use Test;
use Perl6::Parser;

use lib 't/lib/';
use Utils;

plan 1;

my $*CONSISTENCY-CHECK = True;
my $*FALL-THROUGH      = True;

constant %tests = { "test.pod6" => /extension/,
                    "multi.pod6" => /mortals/ };

subtest {
    my $p6p = Perl6::Parser.new;
    for %tests.kv -> $file, $re {
        my $prefix = $file.IO.e??"corpus/"!!"t/corpus/";
        my $file-name = $prefix ~ $file;
        my $pod = $file-name.IO.slurp;
        my @pod = $p6p.to-tree($pod);
        like( @pod[0].^name, /Perl6\:\:/, "File parses to a Pod");
        like( @pod.gist, $re, "$file gets the content right" );

    }
}, "Files";

subtest {
  ok round-trips( Q:to[_END_] ), Q{formatted};
  =begin EMPTY
  =end EMPTY
_END_

  ok round-trips( Q:to[_END_] ), Q{formatted};
=begin pod
This ordinary paragraph introduces a code block:
    $this = 1 * code('block');
    $which.is_specified(:by<indenting>);
=end pod
_END_

  done-testing;
}, Q{empty};

# vim: ft=perl6
