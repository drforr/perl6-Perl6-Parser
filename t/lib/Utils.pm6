class Utils {

	use Perl6::Parser;

	# Classes, modules, packages &c can no longer be redeclared.
	# Which is probably a good thing, but plays havoc with testing here.
	#
	# This is a little ol' tool that generates a fresh package name every
	# time through the testing suite. I can't just make up new names as
	# the test suite goes along because I'm running the full test suite
	# twice, once with the original Perl6 parser-aided version, and once
	# with the new regex-based parser.
	#
	# Use it to build out package names and such.
	#
	sub gensym-package( Str $code ) is export {
		state $appendix = 'A';
		my $num-package-uses = $code.indices( '%s' ).elems;
		my $package = 'Foo' ~ $appendix++;

		return sprintf $code, ( $package ) xx $num-package-uses;
	}

	sub round-trips( Str $code ) returns Bool is export {
		my $pp   = Perl6::Parser.new;
		my $tree = $pp.to-tree( $code );

		return $pp.to-string( $tree ) eq $code;
	}

	sub has-a( $root, $type-object ) returns Bool  is export {
		return True if $root ~~ $type-object;
		if $root.is-twig {
			for $root.child -> $child {
				return True if has-a( $child, $type-object );
			}
		}
		return False;
	}
}
