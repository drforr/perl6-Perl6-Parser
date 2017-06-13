#!/usr/bin/env perl6

if !@*ARGS {
    say "Usage: $*PROGRAM-NAME go";
    exit;
}

foo;

sub foo() {
    say "Hi from sub foo!";
}
