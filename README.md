Perl6::Tidy
=======

Perl 6's grammar is now pretty much fleshed out, but it's hard to get at from
within. This makes tools like code formatters, coverage and analysis tools
hard to put together.

This module aims to fix that.

The code is *BY NO MEANS READY FOR PRIME TIME*. The API basically isn't even
started, the methods used to walk the grammar are primitive in the extreme.
I desperately want to be able to use macros on this code, and it's already
given me an idea for how I want to write Perl 6 macros.

Its test suite is noisy, because this is very much *still* in author debugging
mode, and effectively spits back the match tree at every level.
The code is woefully unoptimized, and I am very much aware that it could be
written in something approximating proper Perl 6 style, but doing so at the
moment would impede progress.

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
