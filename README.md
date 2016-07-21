Perl6::Tidy
=======

Perl 6's grammar is now pretty much fleshed out, but it's hard to get at from
within. This makes tools like code formatters, coverage and analysis tools
hard to put together.

This module aims to fix that.

*THIS IS NOT READY FOR PRIME TIME*. This is very much a work in progress. At
the moment I'm working on covering the grammar rules. The code is very much
paranoid, for good reason, as it relies on the underlying match tree, in the
murky area of NQP, or /Not Quite Perl/. It's pretty stable, but slow and
relentlessly checks the details of the match object.

Next steps will be to properly populate the whitespace in between tokens, and
after that I'll take the time to make the classes behave more sanely.

If you want to play with it, then the only thing to do right now is dump the
$parsed output from a test suite, and I hope you have a pretty-printer. It
currently handles non-trivial code as you can see by running the t/inception.t
test, where the test suite parses itself.

I make no guarantees that any of the tokens in the code are present in the
final output, although it is my sincere hope that I haven't missed anything. In
point of fact you'll note that the test suite only checks that the top-level
object exists. I do intend to do some deeper tests shortly, but getting full
coverage of the grammar is my current priority.

PLEASE DO NOT ASSUME THIS IS STABLE OR IN ANY WAY REPRESENTATIVE OF THE FINAL
PRODUCT. Doing so will void your warranty, and may cause demons to fly from
your nose. YOU HAVE BEEN WARNED.

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
    panda update && panda install Perl6::Tidy
```

* Is ufo even still a thing?
* Using ufo (a project Makefile creation script bundled with Rakudo Star) and make:

```
    ufo                    
    make
    make test
    make install
```

## Testing

To run tests:

```
    prove -e perl6
```

## Author

Jeffrey Goff, DrForr on #perl6, https://github.com/drforr/

## License

Artistic License 2.0
