# Perl6::Parser [![Build Status](https://secure.travis-ci.org/drforr/perl6-Perl6-Parser.svg?branch=master)](http://travis-ci.org/drforr/perl6-Perl6-Parser)
Perl6::Parser
=======

## Caveat

This is very much an Alpha release. The code style here is in *NO WAY* meant to reflect common Perl 6 usage patterns. I'm *deliberately* keeping this simple so that as many people as possible can understand the code and try to improve it.

Most common Perl 6 constructs work at the moment.

Actually, almost all of them do, but not all are referenced "correctly." For instance, ',' is used in lists, obviously. The Perl 6 compiler has to know that a list is comma-separated, but it doesn't have to match each comma explicitly. Perl6::Parser, however, has to know where each one is. So any construct that's not explicitly matched, I have to seek out in the text and find.

Not all of the classes representing the full complexity of Perl 6 terms are there, and looking at the output of the tree (please look at the .dump-tree method for more info) there are probably a lot of keywords and operators that are mis-classified.

## Contributing

Read DEBUGGING.pod in this distribution for more information, but on the whole I *encourage* you to liberally copy/paste from the existing code. If other people go and write the same branch in their own style, it just makes it that much harder for me to search for the code later when I want to refactor. So please, copy/paste as much as you like.

### APIs

Send a PR with a t/20-my-failing-API.t file in it, and I'll either just code it right up if it looks good, or ask questions trying to figure out what you're trying to achieve.

* Searching for a class of tokens
* Walking the token tree (see the Debugging role in lib/Perl6/Parser.pm for inspiration)
* Ignoring whitespace and/or structural tags like ()[]{}; while walking
* Editing existing code

### Out-of-scope

(but likely to be modules in the Perl6::Parser space)

* Dataflow
* method, subroutine, variable and keyword completion
* Perl6::Tidy - This is what I started out working on, will be next.
* Perl6::Critic - This is where I want to get to.

## Back to documentation

Perl 6's grammar is now pretty much fleshed out, but it's hard to get at from
within. This makes tools like code formatters, coverage and analysis tools
hard to put together.

This module aims to fix that.

As such, it is very much a work in progress. At the moment I'm working on
covering the grammar rules. The code is very paranoid, for good reason, as it
relies on the underlying match tree, in the murky area of NQP, or
/Not Quite Perl/. It's pretty stable, but slow and relentlessly checks the
details of the match object.

It comes with a single tool, examples/perl6-dumper. Run this tool on a Perl 6
source file, and with any luck you'll get back a detailed syntax tree, like the
following:

```
Document
        Statement (line 7095)
                Bareword ("use") (0-3) (line 7286)
                WS (" ") (3-4) (line 6537)
                Bareword ("MONKEY-SEE-NO-EVAL") (4-22) (line 3775)
                Semicolon (22-23) (line 5017)
        Statement (line 7095)
		...
                Operator::Circumfix (75-81) (line 1911)
                        Balanced::Enter ("(") (75-76) (line 1911)
                        Number::Decimal (1) (76-77) (line 3406)
                        Operator::Infix ("..") (77-79) (line 3209)
                        Number::Decimal (9) (79-80) (line 3406)
                        Balanced::Exit (")") (80-81) (line 1911)

```

This is an absurdly detailed breakdown of every character in your Perl 6 source
file, and it deserves a bit of explanation.

The module is designed with the following principles in mind:

    * Each glyph, including WS, comments and POD, is part of exactly one token.
    * Tokens must never overlap.
    * Tokens must always abut one another.

(Here-docs of course break all of these rules, but they're accounted for.)

In a typical Perl6:: dump, here's what you'll see:

    * Document - The root of the Perl 6 source tree.
    * Statement - `my $a = 1;', `class foo {...}' and so on.
    * Bareword - Terms such as `my', `use', `class'.
    * WS - Whitespace
    * Operator::Circumfix - Function signatures, lists, lots of things.
    * Balanced::{Enter,Exit}
        * Blocks and circumfix operators generally have balanced delimiters.
        * `Balanced::Enter' is used for the start, ::Exit for the end.
    * Number::Decimal - Decimal values.
        * `Number' is their parent class, so you can just check against
           $x ~~ Perl6::Number if you don't care what base it's in.

Whitespace, semicolons and braces also belong to a generic `Structure' category
so you can ignore those if you want to.

What do all the `(...)' mean? And why are there G and WS cluttering up the
far left side of the display? Well, I'm glad you asked.

    * ("use") is the actual text of the bareword, string or variable name.
    * (75-76) is the start and end glyph (not character) of the token.
    * (line 3406) is the line where this object was created.

    * 'G' on the left means there's a gap between the end of token N and the start of token N+1.
        * This should not happen, and is a bug.
    * 'WS' on the left means that either a Whitespace token has non-WS, or a non-Whitespace token (strings excepted) has whitespace.
    * '' means either:
        * A null token (start == end, shouldn't happen)
        * A token (for example) spanning (76-78) doesn't have (78-76=2) glyphs.

These are mainly debugging aids, as for performance reasons the entire parser
core is a single large class. If you'd like to know my reasoning, please ask
directly; but the TL;DR is that NQPMatch objects and regular Perl 6 objects
don't play nicely.

In essence, I can take this tool, run it over a source file, and when it breaks
I've got a good idea of where the problem happens. This parser contains
waterbed problems on top of waterbed problems - The type where you refactor one
bit of code from where it is to a higher level, and find out you've broken code
5 tokens *before* the change.

When testing changes it's very important to run the verification suite,
especially if you've changed where you're returning whitespace.

Again, the included examples/perl6-dumper tool should help show you the variety
of what the tool can already parse. There are many known problems, and many more
unknowns I've yet to encounter.


I make no guarantees that any of the tokens in the code are present in the
final output, although it is my sincere hope that I haven't missed anything. In
point of fact you'll note that the test suite only checks that the top-level
object exists. I do intend to do some deeper tests shortly, but getting full
coverage of the grammar is my current priority.

PLEASE DO NOT ASSUME THIS IS STABLE OR IN ANY WAY REPRESENTATIVE OF THE FINAL
PRODUCT. Doing so will void your warranty, and may cause demons to fly from
your nose. YOU HAVE BEEN WARNED.

=begin DEBUGGING UTILITIES

There are two methods in L<Perl6::Parser>, and one core method that you'll find
useful as you delve into the murky waters of the code.

The first one is useful after C<$pt.parse-source( $source )> - You can use
C<.dump> on the resultant object, and (usually) get a dump of the NQPMatch
object that the Perl 6 parser has generated for your source. I say "usually"
because there are some conditions under which C<.dump> will hang, most of the
time because you've passed it a list element. This is an issue with the
NQP core, and deprioritized as such.

The next one is useful after C<$pt.build-tree( $p )>, and that is
C<$pt.dump-tree( $tree )>. This gives a nicely-annotated view of the
L<Perl6::Parser> tree, complete with text that it's matched in gist form, and
the start and end markers of each leaf on the tree.
(Start and end markers for constructs like L<Perl6::Document> and
L<Perl6::Statement> are elided because they're computed from the underlying
C<:child> elements. My rationale for ignoring those is that when I'm
debugging line boundaries, I'm most concerned with what I can immediately
affect in the code; since statement and document boundaries are generated for
me, they're not something I can/should be tweaking.

Finally, there's a little C<$pt.ruler( $source )> helper. All it does is put
up a bit of text like so:

#          1         2
#01234567890123456789
#unit subset Foo;␤

First it puts up a tiny ASCII-art ruler that helps you count characters, with
every 10 characters called out w/an extra tick above. This way you don't go
blind counting characters. It renders just the first 72 characters so that
things don't go wrapping around the terminal, and adds an ellipsis ('...') if
the source text is more than 72 characters.

It munges UNIX newlines (eventually CRLF when I get around to it) into the
equivalent Unicode control pictures, so they don't wrap around to the next
line of the screen.

And then, so you can copy the text into another buffer without worrying about
whether it'll be accidentally run as code, adds '#' to the start so that it's
automatically a valid comment.

=end DEBUGGING UTILITIES

=begin DEVELOPER NOTES

Internal classes are labeled with a leading C<_> so they will never be confused with native Perl6 classes. This is very likely with this sort of grammar, see L<_Signature> vs. the existing L<Signature> class.

At the moment, moving the 160+ separate classes out into a separate directory causes a severe run-time penalty on my VM, so they'll stay in a single file. Doing search-and-destroy on one file is easier than search-n-destroy on 160 different files, and I run less of a risk of forgetting something if the internal classes are all in one file.

Classes that will be exposed to the outside world won't have the leading C<_> of course, and will have names that reflect their place in the grammar more closely.

If the flow of control inside a C<new()> or C<is-valid()> method ever gets to the end of its block, the code should simply die. Something went wrong, and it's better to get information as close to the point of failure as possible. Also once this goes into the ecosystem I want to be terribly paranoid about changes to Perl6 core code.

Flow of control should never make it to the bottom of a loop block either, because one of the validators inside the loop should handle at least one of the cases.

Until I come up with a better scheme, validators should be ordered in descending number of terms, regardless of whether the terms are defined or not.

I'm eventually going to remove all the compound classes such as L<_Atom_SigFinal> because that's where the combinatoric explosion will start to happen, and I'm already starting to see that q.v. L<_Atom_SigFinal> and L<_Atom_SigFinal_Quantifier> - Better to have just the separate L<_Atom> and L<_SigFinal> classes, and let the grammar put them together naturally.

When it comes to debugging the NQP internals, one simple thing to do is not to dump the $parsed object right at the point of invocation, but look one layer up the stack and debug from inside that function. It's a happy coincidence that usually any C<Mu $parsed> argument can be C<.dump>'d cleanly.

It's a habit of mine, though by no means a requirement, to stuff test data into the L<t/> files with every line starting with C<###>, so that I have a simple marker to search for when I'm parsing new lines.

Incidentally, L<t/rosetta-*> files are just meant to be echoes of the RosettaCode examples, not an exhaustive Christmas-tree test of the entire grammar. There doesn't appear to be an existing test of the actual parsing in the Rakudo test suite beyond "Lookie here, it can read 'hello, world!'", which is fine; If the grammar has gone south then any test suites are probably going to generate more noise than they're worth.

=end DEVELOPER NOTES


Installation
============

* Using panda (a module management tool bundled with Rakudo Star):

```
    panda update && panda install Perl6::Parser
```

## Testing

To run tests:

```
    prove -e perl6
```

## Known Bugs

```
    max=
    #`(..)
    Some comma-separated lists
    Z=>
    Z in certain situations
    here-docs
       I wrote one pass at it, but two corner cases in the grammar cause a
       problem.
```
By all means, please file bugs as you see them.


## Author

Jeffrey Goff, DrForr on #perl6, https://github.com/drforr/

## License

Artistic License 2.0
