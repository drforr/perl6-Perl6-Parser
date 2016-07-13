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
