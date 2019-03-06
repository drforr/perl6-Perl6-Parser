[![Build Status](https://travis-ci.org/drforr/perl6-Perl6-Parser.svg?branch=master)](https://travis-ci.org/drforr/perl6-Perl6-Parser)

NAME
====

Perl6::Parser - Extract a Perl 6 AST from the NQP Perl 6 Parser

SYNOPSIS
========

    my $pt = Perl6::Parser.new;
    my $source = Q:to[_END_];
       code-goes-here();
       that you( $want-to, $parse );
    _END_

    # Get a fully-parsed data tree
    #
    my $tree = $pt.to-tree( $source );
    say $pt.dump-tree( $tree );

    # Return only the displayed tokens (including whitespace) in the document
    #
    my @token = $pt.to-tokens-only( $source );

    # Return all tokens and structures in the document
    #
    my @everything = $pt.to-list( $source );

    # This used to fire BEGIN and CHECK phasers, it no longer does so.

    # As of 2019-03-05 $*PURE-PERL has gone away, instead all lines that *can*
    # call the pure Perl 6 parser *do* call it, and I'm replacing calls to the
    # internal Perl6 nqp parser with calls to regular Perl 6 code. This method
    # will eventually get rid of some code that I use to bypass BEGIN and CHECK
    # phasers, but that's a ways off.

DESCRIPTION
===========

Uses the built-in Perl 6 parser exposed by the internal nqp module, so that you can parse Perl 6 using Perl 6 itself. If it scares you... well, it probably should. Assuming everything works out, you'll get back a Perl 6 object tree that exactly mirrors your source file's layout, with every bit of whitespace, POD, and code given one or more tokens.

Redisplaying it becomes a matter of calling the `to-string()` method on the tree, which passes an optional formatting hashref down the tree. You can use the format methods as they are, or add a role or subclass the objects created as you see fit to create new objects.

This process **will** be simplified and encapsulated in the near future, as reformatting Perl 6 code was what this rather extensive module was designed to do.

I've added fairly extensive debugging documentation to the [README.md](README.md) of this module, along with an internal [DEBUGGING.pod](DEBUGGING.pod) file talking about what you're seeing here, and why on **earth** didn't I do it **this** way? I have my reasons, but can be talked out of it with a good argument.

Please note that this does compile your code, but it takes the precaution of munging `BEGIN` and `CHECK` phasers into `ENTER` instead so that it won't run at compile time.

As it stands, the `.parse` method returns a deeply-nested object representation of the Perl 6 code it's given. It handles the regex language, but not the other braided languages such as embedded blocks in strings. It will do so eventually, but for the moment I'm busy getting the grammar rules covered.

While classes like [EClass](EClass) won't go away, their parent classes like [DecInteger](DecInteger) will remove them from the tree once their validation job has been done. For example, while the internals need to know that [$/<eclass> ]($/<eclass> ) (the exponent for a scientific-notation number) hasn't been renamed or moved elsewhere in the tree, you as a consumer of the [DecInteger](DecInteger) class don't need to know that. The `DecInteger.perl6` method will delete the child classes so that we don't end up with a **horribly** cluttered tree.

Classes representing Perl 6 object code are currently in the same file as the main [Perl6::Parser](Perl6::Parser) class, as moving them to separate files caused a severe performance penalty. When the time is right I'll look at moving these to another location, but as shuffling out 20 classes increased my runtime on my little ol' VM from 6 to 20 seconds, it's not worth my time to break them out. And besides, having them all in one file makes editing en masse easier.

DEBUGGING
=========

Some notes on how I go about debugging various issues follow.

Let's take the case of the following glitch: The terms `$_` and `0` don't show up in the fragment `[$_, 0 .. 100]`, for various reasons, mostly because there's a branch that's either not being traversed, or simply a term has gone missing.

The first thing is to break the offending bit of code out so it's easier to debug. The test file I make to do this (usually an existing test file I've got lying around) looks partially like this, with boilerplate stripped out:

    my $source = Q:to[_END_];
        my @a; @a[$_, 0 .. 100];
    _END_
    my $p = $pt.parse( $source );
    say $p.dump;
    my $tree = $pt.build-tree( $p );
    say $pt.dump-tree($tree);
    is $pt.to-string( $tree ), $source, Q{formatted};

Already a few things might stand out. First, the code inside the here-doc doesn't actually do anything, it'll never print anything to the screen or do anything interesting. That's not the point at this stage in the game. At this point all I need is a syntactically valid bit of Perl 6 that has the constructs that reproduce the bug. I don't care what the code actually does in the real world.

Second, I'm not doing anything that you as a user of the class would do. As a user of a the class, all you have to do is run the to-string() method, and it does what you want. I'm breaking things down into their component steps.

(side note - This will probably have changed in detail since I wrote this text - Consult your nearest test file for examples of current usage.)

Internally, the library takes sevaral steps to get to the nicely objectified tree that you see on your output. The two important steps in our case are the `.parse( 'text goes here' )` method call, and `.build-tree( $parse-tree )`.

The `.parse()` call returns a very raw [NQPMatch](NQPMatch) object, which is the Perl 6 internal we're trying to reparse into a more useful form. Most of the time you can call `.dump()` on this object and get back a semi-useful object tree. On occasion this **will** lock up, most often because you're trying to `.dump()` a [list](list) accessor, and that hasn't been implemented for NQPMatch. The actual `list` accessor works, but the `.dump()` call will not. A simple workaround is to call `$p.list.[0].dump` on one of the list elements inside, and hope there is one.

Again, these are NQP internals, and aren't quite as stable as the Perl 6 main support layer.

Once you've got a dump of the offending area, it'll look something like this:

    - postcircumfix: [0, $_ ... 100]
      - semilist: 0, $_ ... 100
        - statement: 1 matches
          - EXPR: ...
            - 0: ,
              - 0: 0
                - value: 0
                # ...
              - 1: $_
                - variable: $_
                  - sigil: $
                  # ...
              - infix: ,
                - sym: ,
                - O: <object>
              - OPER: ,

The full thing will probably go on for a few hundred lines. Hope you've got scrollback, or just use tmux as I do.

With this you can almost immediately jump to what appears to be the offending expression, albeit with a bit of interpretation. You'll see `- 0: 0` and `- 1: $_`, and these are exactly the two bits of syntax that have gone missing in our example. Down below you'll see `- infix: ,` which is where the comma separator goes.

We can combine these facts and reason that we have to search for the bit of code where we find an `infix` operator and two list elements. The `- 0` and `- 1` bits tell us that we're dealing with two list elements, and the `- infix` and `- OPER` bits tell us that we've also got two hash keys to find.

Look down in this file for a `assert-hash-keys()` call attempting to assert the existence of exactly a `infix` and `OPER` tag. There may actually be other hash keys in this data structure, as `.dump()` doesn't report unused hash keys; this caused me a deal of confusion.

Eventually you'll find in the `_EXPR()` method this bit of code: (due to change, obviously)

    when self.assert-hash-keys( $_, [< infix OPER >] ) {
	    @child.append(
		    self._infix( $_.hash.<infix> )
	    )
    }

You're most welcome to use the Perl 6 debugger, but what I just do is add a `say 1;` statement just above the `@child.append()` method call (and anywhere else I find a `infix` and `OPER` hash key hiding, because there are multiple places in the code that match an `infix` and `OPER` hash key) and rerun the test.

Now that we've confirmed where the element `should` be getting generated, but somehow isn't, we need to look at the actual text to verify that this is actually where the `$_` and `0` bits are being matched, and we can use another internal debugging tool to help out with that. Add these lines:

    key-bounds $_.list.[0];
    key-bounds $_.hash.<infix>;
    key-bounds $_.list.[1];
    key-bounds $_.hash.<OPER>;
    key-bounds $_;

And rerun your code. Or make the appropriate calls in the debugger, it's your funeral :) What this function does is return something that looks like this:

    45 60 [[0, $_ ... 100]]

The two numbers are the glyphs where the matched text starts and stops, respectively. The bit in between [..] (in this case seemingly doubled, but that's because the text is itself bracketed) is the actual text that's been matched.

So, by now you know what the text you're matching actually looks like, where it is in the string, and maybe eve have a rough idea of why what you're seeing isn't being displayedk

With any luck you'll see that the code simply isn't adding the variables to the list that is being glommed onto the `@child` array, and can add it.

By convention, when you're dumping a `- semilist:` match, you can always call `self._semilist( $p.hash.<semilist> )` in order to get back the list of tokens generated by matching on the `$p.hash.semilist` object. You might be wondering why I don't just subclass NQPMatch and add this as a generic multimethod or dispatch it in some other way.

Well, the reason it's called `NQP` is because it's Not Quite Perl 6, and like poor Rudolph, Perl 6 won't let NQP objects join in any subclasing or dispatching games, because it's Not Quite Perl. And yes, this leads to quite a bit of frustruation.

Let's assume that you've found the `$_.list.[0]` and `$_.hash.<infix> ` handlers, and now need to add whitespace between the `$_` and `0` elements in your generated code.

Now we turn to the rather bewildering array of methods on the `Perl6::WS` class. This profusion of methods is because of two things:

    * Whitespace can be inside a token, before or after a token, or even simply not be there because it's actually inside the L<NQPMatch> object one or more levels up, so you're never B<quite> sure where your whitespace will be hiding.
    * If each of the ~50 classes handled whitespace on its own, I'd have to track down each of the ~50 whitespace-generating methods in order to see which of the whitespace calls is being made. This way I can just look for L<Perl6::WS> and know that those are the only B<possible> places where a whitespace token could be being generated.

METHODS
=======

  * _roundtrip( Str $perl-code ) returns Perl6::Parser::Root

Given a string containing valid Perl 6 code ... well, return that code. This is mostly a shortcut for testing purposes, and wil probably be moved out of the main file.

  * to-tree( Str $source )

This is normally what you want, it returns the Perl 6 parsed tree corresponding to your source code.

  * parse( Str $source )

Returns the underlying NQPMatch object. This is what gets passed on to `build-tree()` and every other important method in this module. It does some minor wizardry to call the Perl 6 reentrant compiler to compile the string you pass it, and return a match object. Please note that it **has** to compile the string in order to validate things like custom operators, so this step is **not** optional.

  * build-tree( Mu $parsed )

Build the Perl6::Element tree from the NQPMatch object. This is the core, and runs the factory which silly-walks the match tree and returns one or more tokens for every single match entry it finds, and **more**.

  * consistency-check( Perl6::Element $root )

Check the integrity of the data structure. The Factory at its core puts together the structure very sloppily, to give the tree every possible chance to create actual quasi-valid text. This method makes sure that the factory returned valid tokens, which often doesn't happen. But since you really want to see the data round-tripped, most users don't care what the tree loos like internally.

  * to-string( Perl6::Element $tree ) returns Str

Call .perl6 on each element of the tree. You can subclass or override this method in any class as you see fit to properly pretty-print the methods. Right now it's awkward to use, and will probably be removed in favor of an upcoming [Perl6::Tidy](Perl6::Tidy) module. That's why I wrote this yak.. er, module in the first place.

  * dump-tree( Perl6::Element $root ) returns Str

Given a Perl6::Document (or other) object, return a full nested tree of text detailing every single token, for debugging purposes.

  * ruler( Str $source )

Purely a debugging aid, it puts an ASCII ruler above your source so that you don't have to go blind counting whitespace to figure out which ' ' a given token belongs to. As a courtesy it also makes newlines visible so you don't have to count those separately. I might use the visible space character later to make it easier to read, if I happen to like it.

Further-Information
===================

For further information, there's a [DEBUGGING.pod](DEBUGGING.pod) file detailing how to go about tracing down a bug in this module, and an extensive test suite in [t/README.pod](t/README.pod) with some ideas of how I'm structuring the test suite.

