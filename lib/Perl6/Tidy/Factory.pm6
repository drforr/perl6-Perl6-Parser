=begin pod

=begin NAME

Perl6::Tidy::Factory - Builds client-ready Perl 6 data tree

=end NAME

=begin DESCRIPTION

Generates the complete tree of Perl6-ready objects, shielding the client from the ugly details of the internal L<nqp> representation of the object. None of the elements, hash values or children should have L<NQPMatch> objects associated with them, as trying to view them can cause nasty crashes.

The child classes are described below, and have what's hopefully a reasonable hierarchy of entries. The root is a L<Perl6::Element>, and everything genrated by the factory is a subclass of that.

Read on for a breadth-first survey of the objects, but below is a brief summary.

L<Perl6::Element>
    L<...>
    L<...>
    L<Perl6::Number>
        L<Perl6::Number::Binary>
        L<Perl6::Number::Decimal>
        L<Perl6::Number::Octal>
        L<Perl6::Number::Hexadecimal>
        L<Perl6::Number::Radix>
    L<Perl6::Variable>
	    L<Perl6::Variable::Scalar>
	        L<Perl6::Variable::Scalar::Dynamic>
                L<...>
	    L<Perl6::Variable::Hash>
	    L<Perl6::Variable::Array>
	    L<Perl6::Variable::Callable>
	    L<Perl6::Variable::Contextualizer>
	        L<Perl6::Variable::Contextualizer::Scalar>
	            L<Perl6::Variable::Contextualizer::Scalar::Dynamic>

=end DESCRIPTION

=begin CLASSES

=item L<Perl6::Element>

The root of the object hierarchy.

This hierarchy is mostly for the clients' convenience, so that they can safely ignore the fact that an object is actually a L<Perl6::Number::Complex::Radix::Floating> when all they really want to know is that it's a L<Perl6::Number>.

It'll eventually have a bunch of useful methods attached to it, but for the moment ... well, it doesn't actually exist.

=cut

=item L<Perl6::Number>

All numbers, whether decimal, rational, radix-32 or complex, fall under this class. You should be able to compare C<$x> to L<Perl6::Number> to do a quick check. Under this lies the teeming complexity of the full Perl 6 numeric lattice.

Binary, octal, hex and radix numbers have an additional C<$.headless> attribute, which gives you the binary value without the leading C<0b>. Radix numbers (C<:13(19a)>) have an additional C<$.radix> attribute specifying the radix, and its C<$.headless> attribute works as you'd expect, delivering C<'19a'> without the surrounding C<':13(..)'>.

Imaginary numbers have an alternative C<$.tailless> attribute which gives you the decimal value without the trailing C<i> marker.

Rather than spelling out a huge list, here's how the hierarchy looks:

L<Perl6::Number>
    L<Perl6::Number::Binary>
    L<Perl6::Number::Octal>
    L<Perl6::Number::Decimal>
        L<Perl6::Number::Decimal::Floating>
    L<Perl6::Number::Hexadecimal>
    L<Perl6::Number::Radix>
    L<Perl6::Number::Imaginary>

There likely won't be a L<Perl6::Number::Complex>. While it's relatively easy to figure out that C<my $z = 3+2i;> is a complex number, who's to say what the intet behind C<my $z = 3*$a+2i> is, or a more complex high-order polynomial. Best to just assert that C<2i> is an imaginary number, and leave it to the client to form the proper interpretation.

=cut

=item L<Perl6::Variable>

The catch-all for Perl 6 variable types.

Scalar, Hash, Array and Callable subtypes have C<$.headless> attributes with the variable's name minus the sigil and optional twigil. They also all have C<$.sigil> which keeps the sigil C<$> etc., and C<$.twigil> optionally for the classes that have twigils.

L<Perl6::Variable>
    L<Perl6::Variable::Scalar>
        L<Perl6::Variable::Scalar::Dynamic>
        L<Perl6::Variable::Scalar::Attribute>
        L<Perl6::Variable::Scalar::CompileTimeVariable>
        L<Perl6::Variable::Scalar::MatchIndex>
        L<Perl6::Variable::Scalar::Positional>
        L<Perl6::Variable::Scalar::Named>
        L<Perl6::Variable::Scalar::Pod>
        L<Perl6::Variable::Scalar::Sublanguage>
    L<Perl6::Variable::Hash>
        (and the same subtypes)
    L<Perl6::Variable::Array>
        (and the same subtypes)
    L<Perl6::Variable::Callable>
        (and the same subtypes)

=cut

=item L<Perl6::Variable::Contextualizer>

Children: L<Perl6::Variable::Contextualizer::Scalar> and so forth.

(a side note - These really should be L<Perl6::Variable::Scalar:Contextualizer::>, but that would mean that these were both a Leaf (from the parent L<Perl6::Variable::Scalar> and a Branch (because they have children). Resolving this would mean removing the L<Perl6::Leaf> role from the L<Perl6::Variable::Scalar> class, which means that I either have to create a longer class name for L<Perl6::Variable::JustAPlainScalarVariable> or manually add the L<Perl6::Leaf>'s contents to the L<Perl6::Variable::Scalar>, and forget to update it when I change my mind in a few weeks' time about what L<Perl6::Leaf> does. Adding a separate class for this seems the lesser of two evils, especially given how often they'll appear in "real world" code.)

=cut

=end CLASSES

=begin ROLES

=item L<Perl6::Node>

Purely a virtual role. Client-facing classes use this to require the C<Str()> functionality of the rest of the classes in the system.

=cut

=item Perl6::Leaf

Represents things such as numbers that are a token unto themselves.

Classes such as C<Perl6::Number> and C<Perl6::Quote> mix in this role in order to declare that they represent stand-alone tokens. Any class that uses this can expect a C<$.content> member to contain the full text of the token, whether it be a variable such as C<$a> or a 50-line heredoc string.

Classes can have custom attributes such as a number's radix value, or a string's delimiters, but they'll always have a C<$.content> value.

=cut

=item Perl6::Branch

Represents things such as lists and circumfix operators that have children.

Anything that's not a C<Perl6::Leaf> wil have this role mixed in, and provide a C<@.child> accessor to get at, say, elements in a list or the expressions in a standalone subroutine.

Child elements aren't restricted to leaves, because a document is a tree the C<@.child> elements can be anything, even including the class itself. Although not the object itself, to avoid recursive loops.

=cut

=end ROLES

=end pod

# XXX Expect to see this a lot...
class Perl6::Unimplemented {
	has $.content is required
}

role Perl6::Node {
	method Str() {...}
}

# Documents will be laid out in a typical tree format.
# I'll use 'Leaf' to distinguish nodes that have no children from those that do.
#
role Perl6::Leaf does Perl6::Node {
	has $.content is required;
	method Str() { ~$.content }
}

role Perl6::Branch does Perl6::Node {
	has @.child;
}

# In passing, please note that Factory methods don't have to validate their
# contents.

class Perl6::Document does Perl6::Branch {
	method Str() { '' }
}

class Perl6::ScopeDeclarator does Perl6::Leaf {
	has Str $.scope;
	method Str() { '' }
}

class Perl6::Scoped does Perl6::Leaf {
}

class Perl6::Declarator does Perl6::Leaf {
}

# * 	Dynamic
# ! 	Attribute (class member)
# ? 	Compile-time variable
# . 	Method (not really a variable)
# < 	Index into match object (not really a variable)
# ^ 	Self-declared formal positional parameter
# : 	Self-declared formal named parameter
# = 	Pod variables
# ~ 	The sublanguage seen by the parser at this lexical spot

# Variables themselves are neither Leaves nor Branches, because they could
# be contextualized, such as '$[1]'.
#
class Perl6::Variable {
	has Str $.headless;

	method Str() { ~$.content }
}

class Perl6::Variable::Contextualizer does Perl6::Branch {
	also is Perl6::Variable;

	method Str() { '' }
}

class Perl6::Variable::Contextualizer::Scalar {
	also is Perl6::Variable::Contextualizer;
	has $.sigil = '$';
}
class Perl6::Variable::Contextualizer::Hash {
	also is Perl6::Variable::Contextualizer;
	has $.sigil = '%';
}
class Perl6::Variable::Contextualizer::Array {
	also is Perl6::Variable::Contextualizer;
	has $.sigil = '@';
}
class Perl6::Variable::Contextualizer::Callable {
	also is Perl6::Variable::Contextualizer;
	has $.sigil = '&';
}

class Perl6::Variable::Scalar does Perl6::Leaf {
	also is Perl6::Variable;
	has $.sigil = '$';
}
class Perl6::Variable::Scalar::Dynamic {
	also is Perl6::Variable::Scalar;
	has $.twigil = '*';
}
class Perl6::Variable::Scalar::Attribute {
	also is Perl6::Variable::Scalar;
	has $.twigil = '!';
}
class Perl6::Variable::Scalar::CompileTimeVariable {
	also is Perl6::Variable::Scalar;
	has $.twigil = '?';
}
class Perl6::Variable::Scalar::MatchIndex {
	also is Perl6::Variable::Scalar;
	has $.twigil = '<';
}
class Perl6::Variable::Scalar::Positional {
	also is Perl6::Variable::Scalar;
	has $.twigil = '^';
}
class Perl6::Variable::Scalar::Named {
	also is Perl6::Variable::Scalar;
	has $.twigil = ':';
}
class Perl6::Variable::Scalar::Pod {
	also is Perl6::Variable::Scalar;
	has $.twigil = '~';
}
class Perl6::Variable::Scalar::Sublanguage {
	also is Perl6::Variable::Scalar;
	has $.twigil = '~';
}

class Perl6::Variable::Array does Perl6::Leaf {
	also is Perl6::Variable;
	has $.sigil = '@';
}
class Perl6::Variable::Array::Dynamic {
	also is Perl6::Variable::Array;
	has $.twigil = '*';
}
class Perl6::Variable::Array::Attribute {
	also is Perl6::Variable::Array;
	has $.twigil = '!';
}
class Perl6::Variable::Array::CompileTimeVariable {
	also is Perl6::Variable::Array;
	has $.twigil = '?';
}
class Perl6::Variable::Array::MatchIndex {
	also is Perl6::Variable::Array;
	has $.twigil = '<';
}
class Perl6::Variable::Array::Positional {
	also is Perl6::Variable::Array;
	has $.twigil = '^';
}
class Perl6::Variable::Array::Named {
	also is Perl6::Variable::Array;
	has $.twigil = ':';
}
class Perl6::Variable::Array::Pod {
	also is Perl6::Variable::Array;
	has $.twigil = '~';
}
class Perl6::Variable::Array::Sublanguage {
	also is Perl6::Variable::Array;
	has $.twigil = '~';
}

class Perl6::Variable::Hash does Perl6::Leaf {
	also is Perl6::Variable;
	has $.sigil = '%';
}
class Perl6::Variable::Hash::Dynamic {
	also is Perl6::Variable::Hash;
	has $.twigil = '*';
}
class Perl6::Variable::Hash::Attribute {
	also is Perl6::Variable::Hash;
	has $.twigil = '!';
}
class Perl6::Variable::Hash::CompileTimeVariable {
	also is Perl6::Variable::Hash;
	has $.twigil = '?';
}
class Perl6::Variable::Hash::MatchIndex {
	also is Perl6::Variable::Hash;
	has $.twigil = '<';
}
class Perl6::Variable::Hash::Positional {
	also is Perl6::Variable::Hash;
	has $.twigil = '^';
}
class Perl6::Variable::Hash::Named {
	also is Perl6::Variable::Hash;
	has $.twigil = ':';
}
class Perl6::Variable::Hash::Pod {
	also is Perl6::Variable::Hash;
	has $.twigil = '~';
}
class Perl6::Variable::Hash::Sublanguage {
	also is Perl6::Variable::Hash;
	has $.twigil = '~';
}

class Perl6::Variable::Callable does Perl6::Leaf {
	also is Perl6::Variable;
	has $.sigil = '&';
}
class Perl6::Variable::Callable::Dynamic {
	also is Perl6::Variable::Callable;
	has $.twigil = '*';
}
class Perl6::Variable::Callable::Attribute {
	also is Perl6::Variable::Callable;
	has $.twigil = '!';
}
class Perl6::Variable::Callable::CompileTimeVariable {
	also is Perl6::Variable::Callable;
	has $.twigil = '?';
}
class Perl6::Variable::Callable::MatchIndex {
	also is Perl6::Variable::Callable;
	has $.twigil = '<';
}
class Perl6::Variable::Callable::Positional {
	also is Perl6::Variable::Callable;
	has $.twigil = '^';
}
class Perl6::Variable::Callable::Named {
	also is Perl6::Variable::Callable;
	has $.twigil = ':';
}
class Perl6::Variable::Callable::Pod {
	also is Perl6::Variable::Callable;
	has $.twigil = '~';
}
class Perl6::Variable::Callable::Sublanguage {
	also is Perl6::Variable::Callable;
	has $.twigil = '~';
}

class Perl6::Tidy::Factory {

	sub dump( Mu $parsed ) {
		say $parsed.hash.keys.gist;
	}

	method trace( Str $term ) {
		note $term if $*TRACE;
	}

	method assert-Bool( Mu $parsed ) {
		return False if $parsed.hash;
		return False if $parsed.list;
		return False if $parsed.Int;
		return False if $parsed.Str;

		return True if $parsed.Bool;
		warn "Uncaught type";
		return False
	}

	# $parsed can only be Int, by extension Str, by extension Bool.
	#
	method assert-Int( Mu $parsed ) {
		return False if $parsed.hash;
		return False if $parsed.list;

		return True if $parsed.Int;
		return True if $parsed.Bool;
		warn "Uncaught type";
		return False
	}

	# $parsed can only be Num, by extension Int, by extension Str, by extension Bool.
	#
	method assert-Num( Mu $parsed ) {
		return False if $parsed.hash;
		return False if $parsed.list;

		return True if $parsed.Num;
		warn "Uncaught type";
		return False
	}

	# $parsed can only be Str, by extension Bool
	#
	method assert-Str( Mu $parsed ) {
		return False if $parsed.hash;
		return False if $parsed.list;
		return False if $parsed.Num;
		return False if $parsed.Int;

		return True if $parsed.Str;
		warn "Uncaught type";
		return False
	}

	method assert-hash-keys( Mu $parsed, $keys, $defined-keys = [] ) {
		return False unless $parsed and $parsed.hash;

		my @keys;
		my @defined-keys;
		for $parsed.hash.keys {
			if $parsed.hash.{$_} {
				@keys.push( $_ );
			}
			elsif $parsed.hash:defined{$_} {
				@defined-keys.push( $_ );
			}
		}

		if $parsed.hash.keys.elems !=
			$keys.elems + $defined-keys.elems {
#				warn "Test " ~
#					$keys.gist ~
#					", " ~
#					$defined-keys.gist ~
#					" against parser " ~
#					$parsed.hash.keys.gist;
#				CONTROL { when CX::Warn { warn .message ~ "\n" ~ .backtrace.Str } }
			return False
		}
		
		for @( $keys ) -> $key {
			next if $parsed.hash.{$key};
			return False
		}
		for @( $defined-keys ) -> $key {
			next if $parsed.hash:defined{$key};
			return False
		}
		return True
	}

	method _ArgList( Mu $parsed ) returns Bool {
		self.trace( '_ArgList' );
		CATCH { when X::Hash::Store::OddNumber { .resume } }
		for $parsed.list {
			next if self.assert-hash-keys( $_, [< EXPR >] )
				and self._EXPR( $_.hash.<EXPR> );
			next if self.assert-Bool( $_ );
		}
		return True if self.assert-hash-keys( $parsed,
				[< deftermnow initializer term_init >],
				[< trait >] )
			and self._DefTermNow( $parsed.hash.<deftermnow> )
			and self._Initializer( $parsed.hash.<initializer> )
			and self._TermInit( $parsed.hash.<term_init> );
		return True if self.assert-hash-keys( $parsed, [< EXPR >] )
			and self._EXPR( $parsed.hash.<EXPR> );
		return True if self.assert-Int( $parsed );
		return True if self.assert-Bool( $parsed );
	}

	method _Args( Mu $p ) returns Bool {
		self.trace( '_Args' );
		return True if self.assert-hash-keys( $p,
				[< invocant semiarglist >] )
			and self._Invocant( $p.hash.<invocant> )
			and self._SemiArgList( $p.hash.<semiarglist> );
		return True if self.assert-hash-keys( $p, [< semiarglist >] )
			and self._SemiArgList( $p.hash.<semiarglist> );
		return True if self.assert-hash-keys( $p, [ ],
				[< semiarglist >] );
		return True if self.assert-hash-keys( $p, [< arglist >] )
			and self._ArgList( $p.hash.<arglist> );
		return True if self.assert-hash-keys( $p, [< EXPR >] )
			and self._EXPR( $p.hash.<EXPR> );
		return True if self.assert-Bool( $p );
		return True if self.assert-Str( $p );
	}

	method _Assertion( Mu $p ) returns Bool {
		self.trace( '_Assertion' );
		return True if self.assert-hash-keys( $p, [< var >] )
			and self._Var( $p.hash.<var> );
		return True if self.assert-hash-keys( $p, [< longname >] )
			and self._LongName( $p.hash.<longname> );
		return True if self.assert-hash-keys( $p, [< cclass_elem >] )
			and self._CClassElem( $p.hash.<cclass_elem> );
		return True if self.assert-hash-keys( $p, [< codeblock >] )
			and self._CodeBlock( $p.hash.<codeblock> );
		return True if $p.Str;
	}

	method _Atom( Mu $p ) returns Bool {
		self.trace( '_Atom' );
		return True if self.assert-hash-keys( $p, [< metachar >] )
			and self._MetaChar( $p.hash.<metachar> );
		return True if self.assert-Str( $p );
	}

	method _Babble( Mu $p ) returns Bool {
		self.trace( '_Bubble' );
		# _B is a Bool leaf
		return True if self.assert-hash-keys( $p,
				[< B >], [< quotepair >] );
	}

	method _BackSlash( Mu $p ) returns Bool {
		self.trace( '_BackSlash' );
		return True if self.assert-hash-keys( $p, [< sym >] )
			and self._Sym( $p.hash.<sym> );
		return True if self.assert-Str( $p );
	}

	method _Block( Mu $p ) returns Bool {
		self.trace( '_Block' );
		return True if self.assert-hash-keys( $p, [< blockoid >] )
			and self._Blockoid( $p.hash.<blockoid> );
	}

	method _Blockoid( Mu $p ) returns Bool {
		self.trace( '_Blockoid' );
		return True if self.assert-hash-keys( $p, [< statementlist >] )
			and self._StatementList( $p.hash.<statementlist> );
	}

	method _Blorst( Mu $p ) returns Bool {
		self.trace( '_Blorst' );
		return True if self.assert-hash-keys( $p, [< statement >] )
			and self._Statement( $p.hash.<statement> );
		return True if self.assert-hash-keys( $p, [< block >] )
			and self._Block( $p.hash.<block> );
	}

	method _Bracket( Mu $p ) returns Bool {
		self.trace( '_Bracket' );
		return True if self.assert-hash-keys( $p, [< semilist >] )
			and self._SemiList( $p.hash.<semilist> );
	}

	method _CClassElem( Mu $p ) returns Bool {
		self.trace( '_CClassElem' );
		for $p.list {
			# _Sign is a Str/Bool leaf
			next if self.assert-hash-keys( $_,
					[< identifier name sign >],
					[< charspec >] )
				and self._Identifier( $_.hash.<identifier> )
				and self._Name( $_.hash.<name> );
			# _Sign is a Str/Bool leaf
			next if self.assert-hash-keys( $_,
					[< sign charspec >] )
				and self._CharSpec( $_.hash.<charspec> );
		}
	}

	method _CharSpec( Mu $p ) returns Bool {
		self.trace( '_CharSpec' );
# XXX work on this, of course.
		return True if $p.list;
	}

	method _Circumfix( Mu $p ) returns Bool {
		self.trace( '_Circumfix' );
		return True if self.assert-hash-keys( $p, [< nibble >] )
			and self._Nibble( $p.hash.<nibble> );
		return True if self.assert-hash-keys( $p, [< pblock >] )
			and self._PBlock( $p.hash.<pblock> );
		return True if self.assert-hash-keys( $p, [< semilist >] )
			and self._SemiList( $p.hash.<semilist> );
		# _BinInt is a Str/Int leaf
		# _VALUE is a Str/Int leaf
		return True if self.assert-hash-keys( $p, [< binint VALUE >] );
		# _OctInt is a Str/Int leaf
		# _VALUE is a Str/Int leaf
		return True if self.assert-hash-keys( $p, [< octint VALUE >] );
		# _HexInt is Str/Int leaf
		# _VALUE is a Str/Int leaf
		return True if self.assert-hash-keys( $p, [< hexint VALUE >] );
	}

	method _CodeBlock( Mu $p ) returns Bool {
		self.trace( '_CodeBlock' );
		return True if self.assert-hash-keys( $p, [< block >] )
			and self._Block( $p.hash.<block> );
	}

	method _Coercee( Mu $p ) returns Bool {
		self.trace( '_Coercee' );
		return True if self.assert-hash-keys( $p, [< semilist >] )
			and self._SemiList( $p.hash.<semilist> );
	}

	method _ColonCircumfix( Mu $p ) returns Bool {
		self.trace( '_ColonCircumfix' );
		return True if self.assert-hash-keys( $p, [< circumfix >] )
			and self._Circumfix( $p.hash.<circumfix> );
	}

	method _ColonPair( Mu $p ) returns Bool {
		self.trace( '_ColonPair' );
		return True if self.assert-hash-keys( $p,
				     [< identifier coloncircumfix >] )
			and self._Identifier( $p.hash.<identifier> )
			and self._ColonCircumfix( $p.hash.<coloncircumfix> );
		return True if self.assert-hash-keys( $p, [< identifier >] )
			and self._Identifier( $p.hash.<identifier> );
		return True if self.assert-hash-keys( $p, [< fakesignature >] )
			and self._FakeSignature( $p.hash.<fakesignature> );
		return True if self.assert-hash-keys( $p, [< var >] )
			and self._Var( $p.hash.<var> );
	}

	method _ColonPairs( Mu $p ) {
		self.trace( '_ColonPairs' );
		if $p ~~ Hash {
			return True if $p.<D>;
			return True if $p.<U>;
		}
	}

	method _Contextualizer( Mu $p ) {
		self.trace( '_Contextualizer' );
		# _Sigil is a Str leaf
		return True if self.assert-hash-keys( $p,
				[< coercee circumfix sigil >] )
			and self._Coercee( $p.hash.<coercee> )
			and self._Circumfix( $p.hash.<circumfix> );
	}

	method _Declarator( Mu $p ) {
		if self.assert-hash-keys( $p,
				[< deftermnow initializer term_init >],
				[< trait >] ) {
Perl6::Unimplemented.new(:content( "_Declarator") );
		}
		elsif self.assert-hash-keys( $p,
				[< initializer signature >], [< trait >] ) {
Perl6::Unimplemented.new(:content( "_Declarator") );
		}
		elsif self.assert-hash-keys( $p,
				  [< initializer variable_declarator >],
				  [< trait >] ) {
Perl6::Unimplemented.new(:content( "_Declarator") );
		}
		elsif self.assert-hash-keys( $p,
				[< variable_declarator >], [< trait >] ) {
			self._VariableDeclarator(
				$p.hash.<variable_declarator>
			)
		}
		elsif self.assert-hash-keys( $p,
				[< regex_declarator >], [< trait >] ) {
Perl6::Unimplemented.new(:content( "_Declarator") );
		}
		elsif self.assert-hash-keys( $p,
				[< routine_declarator >], [< trait >] ) {
Perl6::Unimplemented.new(:content( "_Declarator") );
		}
		elsif self.assert-hash-keys( $p,
				[< signature >], [< trait >] ) {
Perl6::Unimplemented.new(:content( "_Declarator") );
		}

#`(
		self.trace( '_Declarator' );
		return True if self.assert-hash-keys( $p,
				[< deftermnow initializer term_init >],
				[< trait >] )
			and self._DefTermNow( $p.hash.<deftermnow> )
			and self._Initializer( $p.hash.<initializer> )
			and self._TermInit( $p.hash.<term_init> );
		return True if self.assert-hash-keys( $p,
				[< initializer signature >], [< trait >] )
			and self._Initializer( $p.hash.<initializer> )
			and self._Signature( $p.hash.<signature> );
		return True if self.assert-hash-keys( $p,
				  [< initializer variable_declarator >],
				  [< trait >] )
			and self._Initializer( $p.hash.<initializer> )
			and self._VariableDeclarator( $p.hash.<variable_declarator> );
		return True if self.assert-hash-keys( $p,
				[< variable_declarator >], [< trait >] )
			and self._VariableDeclarator( $p.hash.<variable_declarator> );
		return True if self.assert-hash-keys( $p,
				[< regex_declarator >], [< trait >] )
			and self._RegexDeclarator( $p.hash.<regex_declarator> );
		return True if self.assert-hash-keys( $p,
				[< routine_declarator >], [< trait >] )
			and self._RoutineDeclarator( $p.hash.<routine_declarator> );
		return True if self.assert-hash-keys( $p,
				[< signature >], [< trait >] )
			and self._Signature( $p.hash.<signature> );
)
	}

	method _DECL( Mu $p ) {
		self.trace( '_DECL' );
		return True if self.assert-hash-keys( $p,
				[< deftermnow initializer term_init >],
				[< trait >] )
			and self._DefTermNow( $p.hash.<deftermnow> )
			and self._Initializer( $p.hash.<initializer> )
			and self._TermInit( $p.hash.<term_init> );
		return True if self.assert-hash-keys( $p,
				[< deftermnow initializer signature >],
				[< trait >] )
			and self._DefTermNow( $p.hash.<deftermnow> )
			and self._Initializer( $p.hash.<initializer> )
			and self._Signature( $p.hash.<signature> );
		return True if self.assert-hash-keys( $p,
				[< initializer signature >], [< trait >] )
			and self._Initializer( $p.hash.<initializer> )
			and self._Signature( $p.hash.<signature> );
		return True if self.assert-hash-keys( $p,
					  [< initializer variable_declarator >],
					  [< trait >] )
			and self._Initializer( $p.hash.<initializer> )
			and self._VariableDeclarator( $p.hash.<variable_declarator> );
		return True if self.assert-hash-keys( $p,
				[< signature >], [< trait >] )
			and self._Signature( $p.hash.<signature> );
		return True if self.assert-hash-keys( $p,
					  [< variable_declarator >],
					  [< trait >] )
			and self._VariableDeclarator( $p.hash.<variable_declarator> );
		return True if self.assert-hash-keys( $p,
					  [< regex_declarator >],
					  [< trait >] )
			and self._RegexDeclarator( $p.hash.<regex_declarator> );
		return True if self.assert-hash-keys( $p,
					  [< routine_declarator >],
					  [< trait >] )
			and self._RoutineDeclarator( $p.hash.<routine_declarator> );
		return True if self.assert-hash-keys( $p,
					  [< package_def sym >] )
			and self._PackageDef( $p.hash.<package_def> )
			and self._Sym( $p.hash.<sym> );
		return True if self.assert-hash-keys( $p,
					  [< declarator >] )
			and self._Declarator( $p.hash.<declarator> );
	}

	method _DecNumber( Mu $p ) {
		self.trace( '_DecNumber' );
		# _Coeff is a Str/Int leaf
		# _Frac is a Str/Int leaf
		# _Int is a Str/Int leaf
		return True if self.assert-hash-keys( $p,
				  [< int coeff frac escale >] )
			and self._EScale( $p.hash.<escale> );
		# _Coeff is a Str/Int leaf
		# _Frac is a Str/Int leaf
		return True if self.assert-hash-keys( $p,
				  [< coeff frac escale >] )
			and self._EScale( $p.hash.<escale> );
		# _Coeff is a Str/Int leaf
		# _Frac is a Str/Int leaf
		# _Int is a Str/Int leaf
		return True if self.assert-hash-keys( $p,
				  [< int coeff frac >] );
		# _Coeff is a Str/Int leaf
		# _Int is a Str/Int leaf
		return True if self.assert-hash-keys( $p,
				  [< int coeff escale >] )
			and self._EScale( $p.hash.<escale> );
		# _Coeff is a Str/Int leaf
		# _Frac is a Str/Int leaf
		return True if self.assert-hash-keys( $p, [< coeff frac >] );
	}

	method _DefLongName( Mu $p ) {
		self.trace( '_DefLongName' );
		return True if self.assert-hash-keys( $p,
				[< name >], [< colonpair >] )
			and self._Name( $p.hash.<name> );
	}

	method _DefTerm( Mu $p ) {
		self.trace( '_DefTerm' );
		return True if self.assert-hash-keys( $p,
				[< identifier colonpair >] )
			and self._Identifier( $p.hash.<identifier> )
			and self._ColonPair( $p.hash.<colonpair> );
		return True if self.assert-hash-keys( $p,
				[< identifier >], [< colonpair >] )
			and self._Identifier( $p.hash.<identifier> );
	}

	method _DefTermNow( Mu $p ) {
		self.trace( '_DefTermNow' );
		return True if self.assert-hash-keys( $p, [< defterm >] )
			and self._DefTerm( $p.hash.<defterm> );
	}

	method _DeSigilName( Mu $p ) {
		self.trace( '_DeSigilName' );
		return True if self.assert-hash-keys( $p, [< longname >] )
			and self._LongName( $p.hash.<longname> );
		return True if $p.Str;
	}

	method _Dig( Mu $p ) {
		self.trace( '_Dig' );
		for $p.list {
			# UTF-8....
			if $_ {
				# XXX
				next
			}
			else {
				next
			}
		}
	}

	method _Dotty( Mu $p ) {
		self.trace( '_Dotty' );
		return True if self.assert-hash-keys( $p, [< sym dottyop O >] )
			and self._Sym( $p.hash.<sym> )
			and self._DottyOp( $p.hash.<dottyop> )
			and self._O( $p.hash.<O> );
	}

	method _DottyOp( Mu $p ) {
		self.trace( '_DottyOp' );
		return True if self.assert-hash-keys( $p,
				[< sym postop >], [< O >] )
			and self._Sym( $p.hash.<sym> )
			and self._PostOp( $p.hash.<postop> );
		return True if self.assert-hash-keys( $p, [< methodop >] )
			and self._MethodOp( $p.hash.<methodop> );
		return True if self.assert-hash-keys( $p, [< colonpair >] )
			and self._ColonPair( $p.hash.<colonpair> );
	}

	method _DottyOpish( Mu $p ) {
		self.trace( '_DottyOpish' );
		return True if self.assert-hash-keys( $p, [< term >] )
			and self._Term( $p.hash.<term> );
	}

	method _E1( Mu $p ) {
		self.trace( '_E1' );
		return True if self.assert-hash-keys( $p,
				[< scope_declarator >] )
			and self._ScopeDeclarator( $p.hash.<scope_declarator> );
	}

	method _E2( Mu $p ) {
		self.trace( '_E2' );
		return True if self.assert-hash-keys( $p, [< infix OPER >] )
			and self._Infix( $p.hash.<infix> )
			and self._OPER( $p.hash.<OPER> );
	}

	method _E3( Mu $p ) {
		self.trace( '_E3' );
		return True if self.assert-hash-keys( $p, [< postfix OPER >],
				[< postfix_prefix_meta_operator >] )
			and self._Postfix( $p.hash.<postfix> )
			and self._OPER( $p.hash.<OPER> );
	}

	method _Else( Mu $p ) {
		self.trace( '_Else' );
		return True if self.assert-hash-keys( $p, [< sym blorst >] )
			and self._Sym( $p.hash.<sym> )
			and self._Blorst( $p.hash.<blorst> );
		return True if self.assert-hash-keys( $p, [< blockoid >] )
			and self._Blockoid( $p.hash.<blockoid> );
	}

	method _EScale( Mu $p ) {
		self.trace( '_EScale' );
		# _DecInt is a Str/Int leaf
		# _Sign is a Str/Bool leaf
		return True if self.assert-hash-keys( $p,
				[< sign decint >] );
	}

	method _EXPR( Mu $p ) {
		if $p.list {
			for $p.list {
				if self.assert-hash-keys( $_,
						[< dotty OPER >],
						[< postfix_prefix_meta_operator >] ) {
Perl6::Unimplemented.new(:content( "_EXPR") );
				}
				elsif self.assert-hash-keys( $_,
					[< postcircumfix OPER >],
					[< postfix_prefix_meta_operator >] ) {
Perl6::Unimplemented.new(:content( "_EXPR") );
				}
				elsif self.assert-hash-keys( $_,
						[< infix OPER >],
						[< infix_postfix_meta_operator >] ) {
Perl6::Unimplemented.new(:content( "_EXPR") );
				}
				elsif self.assert-hash-keys( $_,
						[< prefix OPER >],
						[< prefix_postfix_meta_operator >] ) {
Perl6::Unimplemented.new(:content( "_EXPR") );
				}
				elsif self.assert-hash-keys( $_,
						[< postfix OPER >],
						[< postfix_prefix_meta_operator >] ) {
Perl6::Unimplemented.new(:content( "_EXPR") );
				}
				elsif self.assert-hash-keys( $_,
						[< identifier args >] ) {
Perl6::Unimplemented.new(:content( "_EXPR") );
				}
				elsif self.assert-hash-keys( $_,
					[< infix_prefix_meta_operator OPER >] ) {
Perl6::Unimplemented.new(:content( "_EXPR") );
				}
				elsif self.assert-hash-keys( $_,
						[< longname args >] ) {
Perl6::Unimplemented.new(:content( "_EXPR") );
				}
				elsif self.assert-hash-keys( $_,
						[< args op >] ) {
Perl6::Unimplemented.new(:content( "_EXPR") );
				}
				elsif self.assert-hash-keys( $_, [< value >] ) {
Perl6::Unimplemented.new(:content( "_EXPR") );
				}
				elsif self.assert-hash-keys( $_,
						[< longname >] ) {
Perl6::Unimplemented.new(:content( "_EXPR") );
				}
				elsif self.assert-hash-keys( $_,
						[< variable >] ) {
Perl6::Unimplemented.new(:content( "_EXPR") );
				}
				elsif self.assert-hash-keys( $_,
						[< methodop >] ) {
Perl6::Unimplemented.new(:content( "_EXPR") );
				}
				elsif self.assert-hash-keys( $_,
						[< package_declarator >] ) {
Perl6::Unimplemented.new(:content( "_EXPR") );
				}
				elsif self.assert-hash-keys( $_, [< sym >] ) {
Perl6::Unimplemented.new(:content( "_EXPR") );
				}
				elsif self.assert-hash-keys( $_,
						[< scope_declarator >] ) {
Perl6::Unimplemented.new(:content( "_EXPR") );
				}
				elsif self.assert-hash-keys( $_, [< dotty >] ) {
Perl6::Unimplemented.new(:content( "_EXPR") );
				}
				elsif self.assert-hash-keys( $_,
						[< circumfix >] ) {
Perl6::Unimplemented.new(:content( "_EXPR") );
				}
				elsif self.assert-hash-keys( $_,
						[< fatarrow >] ) {
Perl6::Unimplemented.new(:content( "_EXPR") );
				}
				elsif self.assert-hash-keys( $_,
						[< statement_prefix >] ) {
Perl6::Unimplemented.new(:content( "_EXPR") );
				}
				elsif self.assert-Str( $_ ) {
Perl6::Unimplemented.new(:content( "_EXPR") );
				}
			}
			if self.assert-hash-keys(
					$p,
					[< fake_infix OPER colonpair >] ) {
Perl6::Unimplemented.new(:content( "_EXPR") );
			}
			elsif self.assert-hash-keys(
					$p,
					[< OPER dotty >],
					[< postfix_prefix_meta_operator >] ) {
Perl6::Unimplemented.new(:content( "_EXPR") );
			}
			elsif self.assert-hash-keys(
					$p,
					[< postfix OPER >],
					[< postfix_prefix_meta_operator >] ) {
Perl6::Unimplemented.new(:content( "_EXPR") );
			}
			elsif self.assert-hash-keys(
					$p,
					[< infix OPER >],
					[< prefix_postfix_meta_operator >] ) {
Perl6::Unimplemented.new(:content( "_EXPR") );
			}
			elsif self.assert-hash-keys(
					$p,
					[< prefix OPER >],
					[< prefix_postfix_meta_operator >] ) {
Perl6::Unimplemented.new(:content( "_EXPR") );
			}
			elsif self.assert-hash-keys(
					$p,
					[< postcircumfix OPER >],
					[< postfix_prefix_meta_operator >] ) {
Perl6::Unimplemented.new(:content( "_EXPR") );
			}
			elsif self.assert-hash-keys( $p,
					[< OPER >],
					[< infix_prefix_meta_operator >] ) {
Perl6::Unimplemented.new(:content( "_EXPR") );
			}
		}
		# _Triangle is a Str leaf
		if self.assert-hash-keys( $p,
				[< args op triangle >] ) {
Perl6::Unimplemented.new(:content( "_EXPR") );
		}
		elsif self.assert-hash-keys( $p, [< longname args >] ) {
Perl6::Unimplemented.new(:content( "_EXPR") );
		}
		elsif self.assert-hash-keys( $p, [< identifier args >] ) {
Perl6::Unimplemented.new(:content( "_EXPR") );
		}
		elsif self.assert-hash-keys( $p, [< args op >] ) {
Perl6::Unimplemented.new(:content( "_EXPR") );
		}
		elsif self.assert-hash-keys( $p, [< sym args >] ) {
Perl6::Unimplemented.new(:content( "_EXPR") );
		}
		elsif self.assert-hash-keys( $p, [< statement_prefix >] ) {
Perl6::Unimplemented.new(:content( "_EXPR") );
		}
		elsif self.assert-hash-keys( $p, [< type_declarator >] ) {
Perl6::Unimplemented.new(:content( "_EXPR") );
		}
		elsif self.assert-hash-keys( $p, [< longname >] ) {
Perl6::Unimplemented.new(:content( "_EXPR") );
		}
		elsif self.assert-hash-keys( $p, [< value >] ) {
Perl6::Unimplemented.new(:content( "_EXPR") );
		}
		elsif self.assert-hash-keys( $p, [< variable >] ) {
Perl6::Unimplemented.new(:content( "_EXPR") );
		}
		elsif self.assert-hash-keys( $p, [< circumfix >] ) {
Perl6::Unimplemented.new(:content( "_EXPR") );
		}
		elsif self.assert-hash-keys( $p, [< colonpair >] ) {
Perl6::Unimplemented.new(:content( "_EXPR") );
		}
		elsif self.assert-hash-keys( $p, [< scope_declarator >] ) {
			self._ScopeDeclarator( $p.hash.<scope_declarator> )
		}
		elsif self.assert-hash-keys( $p, [< routine_declarator >] ) {
Perl6::Unimplemented.new(:content( "_EXPR") );
		}
		elsif self.assert-hash-keys( $p, [< package_declarator >] ) {
Perl6::Unimplemented.new(:content( "_EXPR") );
		}
		elsif self.assert-hash-keys( $p, [< fatarrow >] ) {
Perl6::Unimplemented.new(:content( "_EXPR") );
		}
		elsif self.assert-hash-keys( $p, [< multi_declarator >] ) {
Perl6::Unimplemented.new(:content( "_EXPR") );
		}
		elsif self.assert-hash-keys( $p, [< regex_declarator >] ) {
Perl6::Unimplemented.new(:content( "_EXPR") );
		}
		elsif self.assert-hash-keys( $p, [< dotty >] ) {
Perl6::Unimplemented.new(:content( "_EXPR") );
		}
		else {
Perl6::Unimplemented.new(:content( "_EXPR") );
		}
		
#`(
		if $p.list {
			for $p.list {
				next if self.assert-hash-keys( $_,
						[< dotty OPER >],
						[< postfix_prefix_meta_operator >] )
					and self._Dotty( $_.hash.<dotty> )
					and self._OPER( $_.hash.<OPER> );
				next if self.assert-hash-keys( $_,
					[< postcircumfix OPER >],
					[< postfix_prefix_meta_operator >] )
					and self._PostCircumfix( $_.hash.<postcircumfix> )
					and self._OPER( $_.hash.<OPER> );
				next if self.assert-hash-keys( $_,
						[< infix OPER >],
						[< infix_postfix_meta_operator >] )
					and self._Infix( $_.hash.<infix> )
					and self._OPER( $_.hash.<OPER> );
				next if self.assert-hash-keys( $_,
						[< prefix OPER >],
						[< prefix_postfix_meta_operator >] )
					and self._Prefix( $_.hash.<prefix> )
					and self._OPER( $_.hash.<OPER> );
				next if self.assert-hash-keys( $_,
						[< postfix OPER >],
						[< postfix_prefix_meta_operator >] )
					and self._Postfix( $_.hash.<postfix> )
					and self._OPER( $_.hash.<OPER> );
				next if self.assert-hash-keys( $_,
						[< identifier args >] )
					and self._Identifier( $_.hash.<identifier> )
					and self._Args( $_.hash.<args> );
				next if self.assert-hash-keys( $_,
					[< infix_prefix_meta_operator OPER >] )
					and self._InfixPrefixMetaOperator( $_.hash.<infix_prefix_meta_operator> )
					and self._OPER( $_.hash.<OPER> );
				next if self.assert-hash-keys( $_,
						[< longname args >] )
					and self._LongName( $_.hash.<longname> )
					and self._Args( $_.hash.<args> );
				next if self.assert-hash-keys( $_,
						[< args op >] )
					and self._Args( $_.hash.<args> )
					and self._Op( $_.hash.<op> );
				next if self.assert-hash-keys( $_, [< value >] )
					and self._Value( $_.hash.<value> );
				next if self.assert-hash-keys( $_,
						[< longname >] )
					and self._LongName( $_.hash.<longname> );
				next if self.assert-hash-keys( $_,
						[< variable >] )
					and self._Variable( $_.hash.<variable> );
				next if self.assert-hash-keys( $_,
						[< methodop >] )
					and self._MethodOp( $_.hash.<methodop> );
				next if self.assert-hash-keys( $_,
						[< package_declarator >] )
					and self._PackageDeclarator( $_.hash.<package_declarator> );
				next if self.assert-hash-keys( $_, [< sym >] )
					and self._Sym( $_.hash.<sym> );
				next if self.assert-hash-keys( $_,
						[< scope_declarator >] )
					and self._ScopeDeclarator( $_.hash.<scope_declarator> );
				next if self.assert-hash-keys( $_, [< dotty >] )
					and self._Dotty( $_.hash.<dotty> );
				next if self.assert-hash-keys( $_,
						[< circumfix >] )
					and self._Circumfix( $_.hash.<circumfix> );
				next if self.assert-hash-keys( $_,
						[< fatarrow >] )
					and self._FatArrow( $_.hash.<fatarrow> );
				next if self.assert-hash-keys( $_,
						[< statement_prefix >] )
					and self._StatementPrefix( $_.hash.<statement_prefix> );
				next if self.assert-Str( $_ );
			}
			return True if self.assert-hash-keys(
					$p,
					[< fake_infix OPER colonpair >] )
				and self._FakeInfix( $p.hash.<fake_infix> )
				and self._OPER( $p.hash.<OPER> )
				and self._ColonPair( $p.hash.<colonpair> );
			return True if self.assert-hash-keys(
					$p,
					[< OPER dotty >],
					[< postfix_prefix_meta_operator >] )
				and self._OPER( $p.hash.<OPER> )
				and self._Dotty( $p.hash.<dotty> );
			return True if self.assert-hash-keys(
					$p,
					[< postfix OPER >],
					[< postfix_prefix_meta_operator >] )
				and self._Postfix( $p.hash.<postfix> )
				and self._OPER( $p.hash.<OPER> );
			return True if self.assert-hash-keys(
					$p,
					[< infix OPER >],
					[< prefix_postfix_meta_operator >] )
				and self._Infix( $p.hash.<infix> )
				and self._OPER( $p.hash.<OPER> );
			return True if self.assert-hash-keys(
					$p,
					[< prefix OPER >],
					[< prefix_postfix_meta_operator >] )
				and self._Prefix( $p.hash.<prefix> )
				and self._OPER( $p.hash.<OPER> );
			return True if self.assert-hash-keys(
					$p,
					[< postcircumfix OPER >],
					[< postfix_prefix_meta_operator >] )
				and self._PostCircumfix( $p.hash.<postcircumfix> )
				and self._OPER( $p.hash.<OPER> );
			return True if self.assert-hash-keys( $p,
					[< OPER >],
					[< infix_prefix_meta_operator >] )
				and self._OPER( $p.hash.<OPER> );
		}
		# _Triangle is a Str leaf
		return True if self.assert-hash-keys( $p,
				[< args op triangle >] )
			and self._Args( $p.hash.<args> )
			and self._Op( $p.hash.<op> );
		return True if self.assert-hash-keys( $p, [< longname args >] )
			and self._LongName( $p.hash.<longname> )
			and self._Args( $p.hash.<args> );
		return True if self.assert-hash-keys( $p,
				[< identifier args >] )
			and self._Identifier( $p.hash.<identifier> )
			and self._Args( $p.hash.<args> );
		return True if self.assert-hash-keys( $p, [< args op >] )
			and self._Args( $p.hash.<args> )
			and self._Op( $p.hash.<op> );
		return True if self.assert-hash-keys( $p, [< sym args >] )
			and self._Sym( $p.hash.<sym> )
			and self._Args( $p.hash.<args> );
		return True if self.assert-hash-keys( $p,
				[< statement_prefix >] )
			and self._StatementPrefix( $p.hash.<statement_prefix> );
		return True if self.assert-hash-keys( $p,
				[< type_declarator >] )
			and self._TypeDeclarator( $p.hash.<type_declarator> );
		return True if self.assert-hash-keys( $p, [< longname >] )
			and self._LongName( $p.hash.<longname> );
		return True if self.assert-hash-keys( $p, [< value >] )
			and self._Value( $p.hash.<value> );
		return True if self.assert-hash-keys( $p, [< variable >] )
			and self._Variable( $p.hash.<variable> );
		return True if self.assert-hash-keys( $p, [< circumfix >] )
			and self._Circumfix( $p.hash.<circumfix> );
		return True if self.assert-hash-keys( $p, [< colonpair >] )
			and self._ColonPair( $p.hash.<colonpair> );
		return True if self.assert-hash-keys( $p,
				[< scope_declarator >] )
			and self._ScopeDeclarator( $p.hash.<scope_declarator> );
		return True if self.assert-hash-keys( $p,
				[< routine_declarator >] )
			and self._RoutineDeclarator( $p.hash.<routine_declarator> );
		return True if self.assert-hash-keys( $p,
				[< package_declarator >] )
			and self._PackageDeclarator( $p.hash.<package_declarator> );
		return True if self.assert-hash-keys( $p, [< fatarrow >] )
			and self._FatArrow( $p.hash.<fatarrow> );
		return True if self.assert-hash-keys( $p,
				[< multi_declarator >] )
			and self._MultiDeclarator( $p.hash.<multi_declarator> );
		return True if self.assert-hash-keys( $p,
				[< regex_declarator >] )
			and self._RegexDeclarator( $p.hash.<regex_declarator> );
		return True if self.assert-hash-keys( $p, [< dotty >] )
			and self._Dotty( $p.hash.<dotty> );
)
	}

	method _FakeInfix( Mu $p ) {
		self.trace( '_FakeInfix' );
		return True if self.assert-hash-keys( $p, [< O >] )
			and self._O( $p.hash.<O> );
	}

	method _FakeSignature( Mu $p ) {
		self.trace( '_FakeSignature' );
		return True if self.assert-hash-keys( $p, [< signature >] )
			and self._Signature( $p.hash.<signature> );
	}

	method _FatArrow( Mu $p ) {
		self.trace( '_FatArrow' );
		# _Key is a Str leaf
		return True if self.assert-hash-keys( $p, [< val key >] )
			and self._Val( $p.hash.<val> );
	}

	method _Identifier( Mu $p ) {
		self.trace( '_Identifier' );
		for $p.list {
			next if self.assert-Str( $_ );
		}
		return True if $p.Str;
	}

	method _Infix( Mu $p ) {
		self.trace( '_Infix' );
		return True if self.assert-hash-keys( $p, [< EXPR O >] )
			and self._EXPR( $p.hash.<EXPR> )
			and self._O( $p.hash.<O> );
		return True if self.assert-hash-keys( $p, [< infix OPER >] )
			and self._Infix( $p.hash.<infix> )
			and self._OPER( $p.hash.<OPER> );
		return True if self.assert-hash-keys( $p, [< sym O >] )
			and self._Sym( $p.hash.<sym> )
			and self._O( $p.hash.<O> );
	}

	method _Infixish( Mu $p ) {
		self.trace( '_Infixish' );
		return True if self.assert-hash-keys( $p, [< infix OPER >] )
			and self._Infix( $p.hash.<infix> )
			and self._OPER( $p.hash.<OPER> );
	}

	method _InfixPrefixMetaOperator( Mu $p ) {
		self.trace( '_InfixPrefixMetaOperator' );
		return True if self.assert-hash-keys( $p, [< sym infixish O >] )
			and self._Sym( $p.hash.<sym> )
			and self._Infixish( $p.hash.<infixish> )
			and self._O( $p.hash.<O> );
	}

	method _Initializer( Mu $p ) {
		self.trace( '_Initializer' );
		return True if self.assert-hash-keys( $p, [< sym EXPR >] )
			and self._Sym( $p.hash.<sym> )
			and self._EXPR( $p.hash.<EXPR> );
		return True if self.assert-hash-keys( $p, [< dottyopish sym >] )
			and self._DottyOpish( $p.hash.<dottyopish> )
			and self._Sym( $p.hash.<sym> );
	}

	method _Integer( Mu $p ) {
		self.trace( '_Integer' );
		# _DecInt is a Str/Int leaf
		# _VALUE is a Str/Int leaf
		return True if self.assert-hash-keys( $p, [< decint VALUE >] );
		# _BinInt is a Str/Int leaf
		# _VALUE is a Str/Int leaf
		return True if self.assert-hash-keys( $p, [< binint VALUE >] );
		# _OctInt is a Str/Int leaf
		# _VALUE is a Str/Int leaf
		return True if self.assert-hash-keys( $p, [< octint VALUE >] );
		# _HexInt is Str/Int leaf
		# _VALUE is a Str/Int leaf
		return True if self.assert-hash-keys( $p, [< hexint VALUE >] );
	}

	method _Invocant( Mu $p ) {
		self.trace( '_Invocant' );
		CATCH {
			when X::Multi::NoMatch { }
		}
		#return True if $p ~~ QAST::Want;
		#return True if self.assert-hash-keys( $p, [< XXX >] )
		#	and self._VALUE( $p.hash.<XXX> );
# XXX Fixme
#say $p.dump;
#say $p.dump_annotations;
#say "############## " ~$p.<annotations>.gist;#<BY>;
return True;
	}

	method _Left( Mu $p ) {
		self.trace( '_Left' );
		return True if self.assert-hash-keys( $p, [< termseq >] )
			and self._TermSeq( $p.hash.<termseq> );
	}

	method _LongName( Mu $p ) {
		self.trace( '_LongName' );
		return True if self.assert-hash-keys( $p,
				[< name >],
				[< colonpair >] )
			and self._Name( $p.hash.<name> );
	}

	method _MetaChar( Mu $p ) {
		self.trace( '_MetaChar' );
		return True if self.assert-hash-keys( $p, [< sym >] )
			and self._Sym( $p.hash.<sym> );
		return True if self.assert-hash-keys( $p, [< codeblock >] )
			and self._CodeBlock( $p.hash.<codeblock> );
		return True if self.assert-hash-keys( $p, [< backslash >] )
			and self._BackSlash( $p.hash.<backslash> );
		return True if self.assert-hash-keys( $p, [< assertion >] )
			and self._Assertion( $p.hash.<assertion> );
		return True if self.assert-hash-keys( $p, [< nibble >] )
			and self._Nibble( $p.hash.<nibble> );
		return True if self.assert-hash-keys( $p, [< quote >] )
			and self._Quote( $p.hash.<quote> );
		return True if self.assert-hash-keys( $p, [< nibbler >] )
			and self._Nibbler( $p.hash.<nibbler> );
		return True if self.assert-hash-keys( $p, [< statement >] )
			and self._Statement( $p.hash.<statement> );
	}

	method _MethodDef( Mu $p ) {
		self.trace( '_MethodDef' );
		# _Specials is a Bool leaf
		return True if self.assert-hash-keys( $p,
			     [< specials longname blockoid multisig >],
			     [< trait >] )
			and self._LongName( $p.hash.<longname> )
			and self._Blockoid( $p.hash.<blockoid> )
			and self._MultiSig( $p.hash.<multisig> );
		# _Specials is a Bool leaf
		return True if self.assert-hash-keys( $p,
			     [< specials longname blockoid >],
			     [< trait >] )
			and self._LongName( $p.hash.<longname> )
			and self._Blockoid( $p.hash.<blockoid> );
	}

	method _MethodOp( Mu $p ) {
		self.trace( '_MethodOp' );
		return True if self.assert-hash-keys( $p, [< longname args >] )
			and self._LongName( $p.hash.<longname> )
			and self._Args( $p.hash.<args> );
		return True if self.assert-hash-keys( $p, [< longname >] )
			and self._LongName( $p.hash.<longname> );
		return True if self.assert-hash-keys( $p, [< variable >] )
			and self._Variable( $p.hash.<variable> );
	}

	method _Min( Mu $p ) {
		self.trace( '_Min' );
		# _DecInt is a Str/Int leaf
		# _VALUE is a Str/Int leaf
		return True if self.assert-hash-keys( $p, [< decint VALUE >] );
	}

	method _ModifierExpr( Mu $p ) {
		self.trace( '_ModifierExpr' );
		return True if self.assert-hash-keys( $p, [< EXPR >] )
			and self._EXPR( $p.hash.<EXPR> );
	}

	method _ModuleName( Mu $p ) {
		self.trace( '_ModuleName' );
		return True if self.assert-hash-keys( $p, [< longname >] )
			and self._LongName( $p.hash.<longname> );
	}

	method _MoreName( Mu $p ) {
		self.trace( '_MoreName' );
		for $p.list {
			next if self.assert-hash-keys( $_,
					[< identifier >] )
				and self._Identifier( $_.hash.<identifier> );
		}
	}

	method _MultiDeclarator( Mu $p ) {
		self.trace( '_MultiDeclarator' );
		return True if self.assert-hash-keys( $p,
				[< sym routine_def >] )
			and self._Sym( $p.hash.<sym> )
			and self._RoutineDef( $p.hash.<routine_def> );
		return True if self.assert-hash-keys( $p,
				[< sym declarator >] )
			and self._Sym( $p.hash.<sym> )
			and self._Declarator( $p.hash.<declarator> );
		return True if self.assert-hash-keys( $p,
				[< declarator >] )
			and self._Declarator( $p.hash.<declarator> );
	}

	method _MultiSig( Mu $p ) {
		self.trace( '_MultiSig' );
		return True if self.assert-hash-keys( $p, [< signature >] )
			and self._Signature( $p.hash.<signature> );
	}

	method _NamedParam( Mu $p ) {
		self.trace( '_NamedParam' );
		return True if self.assert-hash-keys( $p, [< param_var >] )
			and self._ParamVar( $p.hash.<param_var> );
	}

	method _Name( Mu $p ) {
		self.trace( '_Name' );
		# _Quant is a Bool leaf
		return True if self.assert-hash-keys( $p,
			[< param_var type_constraint quant >],
			[< default_value modifier trait post_constraint >] )
			and self._ParamVar( $p.hash.<param_var> )
			and self._TypeConstraint( $p.hash.<type_constraint> );
		return True if self.assert-hash-keys( $p,
				[< identifier >], [< morename >] )
			and self._Identifier( $p.hash.<identifier> );
		return True if self.assert-hash-keys( $p,
				[< subshortname >] )
			and self._SubShortName( $p.hash.<subshortname> );
		return True if self.assert-hash-keys( $p, [< morename >] )
			and self._MoreName( $p.hash.<morename> );
		return True if self.assert-Str( $p );
	}

	method _Nibble( Mu $p ) {
		self.trace( '_Nibble' );
		return True if self.assert-hash-keys( $p, [< termseq >] )
			and self._TermSeq( $p.hash.<termseq> );
		return True if $p.Str;
		return True if $p.Bool;
	}

	method _Nibbler( Mu $p ) {
		self.trace( '_Nibbler' );
		return True if self.assert-hash-keys( $p, [< termseq >] )
			and self._TermSeq( $p.hash.<termseq> );
	}

	method _Noun( Mu $p ) {
		self.trace( '_Noun' );
		for $p.list {
			next if self.assert-hash-keys( $_,
				[< sigmaybe sigfinal
				   quantifier atom >] )
				and self._SigMaybe( $_.hash.<sigmaybe> )
				and self._SigFinal( $_.hash.<sigfinal> )
				and self._Quantifier( $_.hash.<quantifier> )
				and self._Atom( $_.hash.<atom> );
			next if self.assert-hash-keys( $_,
				[< sigfinal quantifier
				   separator atom >] )
				and self._SigFinal( $_.hash.<sigfinal> )
				and self._Quantifier( $_.hash.<quantifier> )
				and self._Separator( $_.hash.<separator> )
				and self._Atom( $_.hash.<atom> );
			next if self.assert-hash-keys( $_,
				[< sigmaybe sigfinal
				   separator atom >] )
				and self._SigMaybe( $_.hash.<sigmaybe> )
				and self._SigFinal( $_.hash.<sigfinal> )
				and self._Separator( $_.hash.<separator> )
				and self._Atom( $_.hash.<atom> );
			next if self.assert-hash-keys( $_,
				[< atom sigfinal quantifier >] )
				and self._Atom( $_.hash.<atom> )
				and self._SigFinal( $_.hash.<sigfinal> )
				and self._Quantifier( $_.hash.<quantifier> );
			next if self.assert-hash-keys( $_,
					[< atom >], [< sigfinal >] )
				and self._Atom( $_.hash.<atom> );
		}
	}

	method _Number( Mu $p ) {
		self.trace( '_Number' );
		return True if self.assert-hash-keys( $p, [< numish >] )
			and self._Numish( $p.hash.<numish> );
	}

	method _Numish( Mu $p ) {
		self.trace( '_Numish' );
		return True if self.assert-hash-keys( $p, [< integer >] )
			and self._Integer( $p.hash.<integer> );
		return True if self.assert-hash-keys( $p, [< rad_number >] )
			and self._RadNumber( $p.hash.<rad_number> );
		return True if self.assert-hash-keys( $p, [< dec_number >] )
			and self._DecNumber( $p.hash.<dec_number> );
		return True if self.assert-Num( $p );
	}

	method _O( Mu $p ) {
		self.trace( '_O' );
		CATCH {
			when X::Multi::NoMatch { .resume }
			#default { .resume }
			default { }
		}
		return True if $p.<thunky>
			and $p.<prec>
			and $p.<fiddly>
			and $p.<reducecheck>
			and $p.<pasttype>
			and $p.<dba>
			and $p.<assoc>;
		return True if $p.<thunky>
			and $p.<prec>
			and $p.<pasttype>
			and $p.<dba>
			and $p.<iffy>
			and $p.<assoc>;
		return True if $p.<prec>
			and $p.<pasttype>
			and $p.<dba>
			and $p.<diffy>
			and $p.<iffy>
			and $p.<assoc>;
		return True if $p.<prec>
			and $p.<fiddly>
			and $p.<sub>
			and $p.<dba>
			and $p.<assoc>;
		return True if $p.<prec>
			and $p.<nextterm>
			and $p.<fiddly>
			and $p.<dba>
			and $p.<assoc>;
		return True if $p.<thunky>
			and $p.<prec>
			and $p.<dba>
			and $p.<assoc>;
		return True if $p.<prec>
			and $p.<diffy>
			and $p.<dba>
			and $p.<assoc>;
		return True if $p.<prec>
			and $p.<iffy>
			and $p.<dba>
			and $p.<assoc>;
		return True if $p.<prec>
			and $p.<fiddly>
			and $p.<dba>
			and $p.<assoc>;
		return True if $p.<prec>
			and $p.<dba>
			and $p.<assoc>;
	}

	method _Op( Mu $p ) {
		self.trace( '_Op' );
		return True if self.assert-hash-keys( $p,
			     [< infix_prefix_meta_operator OPER >] )
			and self._InfixPrefixMetaOperator( $p.hash.<infix_prefix_meta_operator> )
			and self._OPER( $p.hash.<OPER> );
		return True if self.assert-hash-keys( $p, [< infix OPER >] )
			and self._Infix( $p.hash.<infix> )
			and self._OPER( $p.hash.<OPER> );
	}

	method _OPER( Mu $p ) {
		self.trace( '_OPER' );
		return True if self.assert-hash-keys( $p,
				[< sym dottyop O >] )
			and self._Sym( $p.hash.<sym> )
			and self._DottyOp( $p.hash.<dottyop> )
			and self._O( $p.hash.<O> );
		return True if self.assert-hash-keys( $p,
				[< sym infixish O >] )
			and self._Sym( $p.hash.<sym> )
			and self._Infixish( $p.hash.<infixish> )
			and self._O( $p.hash.<O> );
		return True if self.assert-hash-keys( $p, [< sym O >] )
			and self._Sym( $p.hash.<sym> )
			and self._O( $p.hash.<O> );
		return True if self.assert-hash-keys( $p, [< EXPR O >] )
			and self._EXPR( $p.hash.<EXPR> )
			and self._O( $p.hash.<O> );
		return True if self.assert-hash-keys( $p,
				[< semilist O >] )
			and self._SemiList( $p.hash.<semilist> )
			and self._O( $p.hash.<O> );
		return True if self.assert-hash-keys( $p, [< nibble O >] )
			and self._Nibble( $p.hash.<nibble> )
			and self._O( $p.hash.<O> );
		return True if self.assert-hash-keys( $p, [< arglist O >] )
			and self._ArgList( $p.hash.<arglist> )
			and self._O( $p.hash.<O> );
		return True if self.assert-hash-keys( $p, [< dig O >] )
			and self._Dig( $p.hash.<dig> )
			and self._O( $p.hash.<O> );
		return True if self.assert-hash-keys( $p, [< O >] )
			and self._O( $p.hash.<O> );
	}

	method _PackageDeclarator( Mu $p ) {
		self.trace( '_PackageDeclarator' );
		return True if self.assert-hash-keys( $p,
				[< sym package_def >] )
			and self._Sym( $p.hash.<sym> )
			and self._PackageDef( $p.hash.<package_def> );
	}

	method _PackageDef( Mu $p ) {
		self.trace( '_PackageDef' );
		return True if self.assert-hash-keys( $p,
				[< blockoid longname >], [< trait >] )
			and self._Blockoid( $p.hash.<blockoid> )
			and self._LongName( $p.hash.<longname> );
		return True if self.assert-hash-keys( $p,
				[< longname statementlist >], [< trait >] )
			and self._LongName( $p.hash.<longname> )
			and self._StatementList( $p.hash.<statementlist> );
		return True if self.assert-hash-keys( $p,
				[< blockoid >], [< trait >] )
			and self._Blockoid( $p.hash.<blockoid> );
	}

	method _Parameter( Mu $p ) {
		self.trace( '_Parameter' );
		for $p.list {
			# _Quant is a Bool leaf
			next if self.assert-hash-keys( $_,
				[< param_var type_constraint quant >],
				[< default_value modifier trait
				   post_constraint >] )
				and self._ParamVar( $_.hash.<param_var> )
				and self._TypeConstraint( $_.hash.<type_constraint> );
			# _Quant is a Bool leaf
			next if self.assert-hash-keys( $_,
				[< param_var quant >],
				[< default_value modifier trait
				   type_constraint
				   post_constraint >] )
				and self._ParamVar( $_.hash.<param_var> );

			# _Quant is a Bool leaf
			next if self.assert-hash-keys( $_,
				[< named_param quant >],
				[< default_value modifier
				   post_constraint trait
				   type_constraint >] )
				and self._NamedParam( $_.hash.<named_param> );
			# _Quant is a Bool leaf
			next if self.assert-hash-keys( $_,
				[< defterm quant >],
				[< default_value modifier
				   post_constraint trait
				   type_constraint >] )
				and self._DefTerm( $_.hash.<defterm> );
			next if self.assert-hash-keys( $_,
				[< type_constraint >],
				[< param_var quant default_value						   modifier post_constraint trait
				   type_constraint >] )
				and self._TypeConstraint( $_.hash.<type_constraint> );
		}
	}

	method _ParamVar( Mu $p ) {
		self.trace( '_ParamVar' );
		# _Sigil is a Str leaf
		return True if self.assert-hash-keys( $p,
				[< name twigil sigil >] )
			and self._Name( $p.hash.<name> )
			and self._Twigil( $p.hash.<twigil> );
		# _Sigil is a Str leaf
		return True if self.assert-hash-keys( $p, [< name sigil >] )
			and self._Name( $p.hash.<name> );
		return True if self.assert-hash-keys( $p, [< signature >] )
			and self._Signature( $p.hash.<signature> );
		# _Sigil is a Str leaf
		return True if self.assert-hash-keys( $p, [< sigil >] );
	}

	method _PBlock( Mu $p ) {
		self.trace( '_PBlock' );
		# _Lambda is a Str leaf
		return True if self.assert-hash-keys( $p,
				     [< lambda blockoid signature >] )
			and self._Blockoid( $p.hash.<blockoid> )
			and self._Signature( $p.hash.<signature> );
		return True if self.assert-hash-keys( $p, [< blockoid >] )
			and self._Blockoid( $p.hash.<blockoid> );
	}

	method _PostCircumfix( Mu $p ) {
		self.trace( '_PostCircumfix' );
		return True if self.assert-hash-keys( $p, [< nibble O >] )
			and self._Nibble( $p.hash.<nibble> )
			and self._O( $p.hash.<O> );
		return True if self.assert-hash-keys( $p, [< semilist O >] )
			and self._SemiList( $p.hash.<semilist> )
			and self._O( $p.hash.<O> );
		return True if self.assert-hash-keys( $p, [< arglist O >] )
			and self._ArgList( $p.hash.<arglist> )
			and self._O( $p.hash.<O> );
	}

	method _Postfix( Mu $p ) {
		self.trace( '_Postfix' );
		return True if self.assert-hash-keys( $p, [< dig O >] )
			and self._Dig( $p.hash.<dig> )
			and self._O( $p.hash.<O> );
		return True if self.assert-hash-keys( $p, [< sym O >] )
			and self._Sym( $p.hash.<sym> )
			and self._O( $p.hash.<O> );
	}

	method _PostOp( Mu $p ) {
		self.trace( '_PostOp' );
		return True if self.assert-hash-keys( $p,
				[< sym postcircumfix O >] )
			and self._Sym( $p.hash.<sym> )
			and self._PostCircumfix( $p.hash.<postcircumfix> )
			and self._O( $p.hash.<O> );
		return True if self.assert-hash-keys( $p,
				[< sym postcircumfix >], [< O >] )
			and self._Sym( $p.hash.<sym> )
			and self._PostCircumfix( $p.hash.<postcircumfix> );
	}

	method _Prefix( Mu $p ) {
		self.trace( '_Prefix' );
		return True if self.assert-hash-keys( $p, [< sym O >] )
			and self._Sym( $p.hash.<sym> )
			and self._O( $p.hash.<O> );
	}

	method _QuantifiedAtom( Mu $p ) {
		self.trace( '_QuantifiedAtom' );
		return True if self.assert-hash-keys( $p, [< sigfinal atom >] )
			and self._SigFinal( $p.hash.<sigfinal> )
			and self._Atom( $p.hash.<atom> );
	}

	method _Quantifier( Mu $p ) {
		self.trace( '_Quantifier' );
		# _Max is a Str leaf
		# _BackMod is a Bool leaf
		return True if self.assert-hash-keys( $p,
				[< sym min max backmod >] )
			and self._Sym( $p.hash.<sym> )
			and self._Min( $p.hash.<min> );
		# _BackMod is a Bool leaf
		return True if self.assert-hash-keys( $p,
				[< sym backmod >] )
			and self._Sym( $p.hash.<sym> );
	}

	method _Quibble( Mu $p ) {
		self.trace( '_Quibble' );
		return True if self.assert-hash-keys( $p, [< babble nibble >] )
			and self._Babble( $p.hash.<babble> )
			and self._Nibble( $p.hash.<nibble> );
	}

	method _Quote( Mu $p ) {
		self.trace( '_Quote' );
		return True if self.assert-hash-keys( $p,
				[< sym quibble rx_adverbs >] )
			and self._Sym( $p.hash.<sym> )
			and self._Quibble( $p.hash.<quibble> )
			and self._RxAdverbs( $p.hash.<rx_adverbs> );
		return True if self.assert-hash-keys( $p,
				[< sym rx_adverbs sibble >] )
			and self._Sym( $p.hash.<sym> )
			and self._RxAdverbs( $p.hash.<rx_adverbs> )
			and self._Sibble( $p.hash.<sibble> );
		return True if self.assert-hash-keys( $p, [< nibble >] )
			and self._Nibble( $p.hash.<nibble> );
		return True if self.assert-hash-keys( $p, [< quibble >] )
			and self._Quibble( $p.hash.<quibble> );
	}

	method _QuotePair( Mu $p ) {
		self.trace( '_QuotePair' );
		for $p.list {
			next if self.assert-hash-keys( $_,
				[< identifier >] )
				and self._Identifier( $_.hash.<identifier> );
		}
		# _Radix is a Str/Int leaf
		return True if self.assert-hash-keys( $p,
				[< circumfix bracket radix >], [< exp base >] )
			and self._Circumfix( $p.hash.<circumfix> )
			and self._Bracket( $p.hash.<bracket> );
		return True if self.assert-hash-keys( $p,
				[< identifier >] )
			and self._Identifier( $p.hash.<identifier> );
	}

	method _RadNumber( Mu $p ) {
		self.trace( '_RadNumber' );
		# _Radix is a Str/Int leaf
		return True if self.assert-hash-keys( $p,
				[< circumfix bracket radix >], [< exp base >] )
			and self._Circumfix( $p.hash.<circumfix> )
			and self._Bracket( $p.hash.<bracket> );
		# _Radix is a Str/Int leaf
		return True if self.assert-hash-keys( $p,
				[< circumfix radix >], [< exp base >] )
			and self._Circumfix( $p.hash.<circumfix> );
	}

	method _RegexDeclarator( Mu $p ) {
		self.trace( '_RegexDeclarator' );
		return True if self.assert-hash-keys( $p, [< sym regex_def >] )
			and self._Sym( $p.hash.<sym> )
			and self._RegexDef( $p.hash.<regex_def> );
	}

	method _RegexDef( Mu $p ) {
		self.trace( '_RegexDef' );
		return True if self.assert-hash-keys( $p,
				[< deflongname nibble >],
				[< signature trait >] )
			and self._DefLongName( $p.hash.<deflongname> )
			and self._Nibble( $p.hash.<nibble> );
	}

	method build( Mu $p ) {
		my $statementlist = $p.hash.<statementlist>;
		my $statement     = $statementlist.hash.<statement>;
		my @child;

		for $statement.list {
			@child.push(
				self._Statement( $_ )
			)
		}
		Perl6::Document.new(
			:child( @child )
		)
	}

	method _RoutineDeclarator( Mu $p ) {
		self.trace( '_RoutineDeclarator' );
		return True if self.assert-hash-keys( $p, [< sym method_def >] )
			and self._Sym( $p.hash.<sym> )
			and self._MethodDef( $p.hash.<method_def> );
		return True if self.assert-hash-keys( $p,
				[< sym routine_def >] )
			and self._Sym( $p.hash.<sym> )
			and self._RoutineDef( $p.hash.<routine_def> );
	}

	# DING
	method _RoutineDef( Mu $p ) {
		self.trace( '_RoutineDef' );
		return True if self.assert-hash-keys( $p,
				[< blockoid deflongname multisig >],
				[< trait >] )
			and self._Blockoid( $p.hash.<blockoid> )
			and self._DefLongName( $p.hash.<deflongname> )
			and self._MultiSig( $p.hash.<multisig> );
		return True if self.assert-hash-keys( $p,
				[< blockoid deflongname >],
				[< trait >] )
			and self._Blockoid( $p.hash.<blockoid> )
			and self._DefLongName( $p.hash.<deflongname> );
		return True if self.assert-hash-keys( $p,
				[< blockoid multisig >],
				[< trait >] )
			and self._Blockoid( $p.hash.<blockoid> )
			and self._MultiSig( $p.hash.<multisig> );
		return True if self.assert-hash-keys( $p,
				[< blockoid >], [< trait >] )
			and self._Blockoid( $p.hash.<blockoid> );
	}

	method _RxAdverbs( Mu $p ) {
		self.trace( '_RxAdverbs' );
		return True if self.assert-hash-keys( $p, [< quotepair >] )
			and self._QuotePair( $p.hash.<quotepair> );
		return True if self.assert-hash-keys( $p,
				[], [< quotepair >] );
	}

	method _Scoped( Mu $p ) {
		# XXX DECL seems to be a mirror of declarator. This probably
		# XXX will turn out to be not true later on.
		#
		if self.assert-hash-keys( $p,
				[< declarator DECL >], [< typename >] ) {
			Perl6::Scoped.new(
				:content(
					self._Declarator( $p.hash.<declarator> )
				)
			)
		}
		elsif self.assert-hash-keys( $p,
					[< multi_declarator DECL typename >] ) {
Perl6::Unimplemented.new(:content( "_Scoped") );
		}
		elsif self.assert-hash-keys( $p,
				[< package_declarator DECL >],
				[< typename >] ) {
Perl6::Unimplemented.new(:content( "_Scoped") );
		}
		
#`(
		return True if self.assert-hash-keys( $p,
				[< declarator DECL >], [< typename >] )
			and self._Declarator( $p.hash.<declarator> )
			and self._DECL( $p.hash.<DECL> );
		return True if self.assert-hash-keys( $p,
					[< multi_declarator DECL typename >] )
			and self._MultiDeclarator( $p.hash.<multi_declarator> )
			and self._DECL( $p.hash.<DECL> )
			and self._TypeName( $p.hash.<typename> );
		return True if self.assert-hash-keys( $p,
				[< package_declarator DECL >],
				[< typename >] )
			and self._PackageDeclarator( $p.hash.<package_declarator> )
			and self._DECL( $p.hash.<DECL> );
)
	}

	method _ScopeDeclarator( Mu $p ) {
		Perl6::ScopeDeclarator.new(
			:content( self._Scoped( $p.hash.<scoped> ) ),
			:scope( $p.hash.<sym>.Str ),
		)
	}

	method _SemiArgList( Mu $p ) {
		self.trace( '_SemiArgList' );
		return True if self.assert-hash-keys( $p, [< arglist >] )
			and self._ArgList( $p.hash.<arglist> );
	}

	method _SemiList( Mu $p ) {
		self.trace( '_SemiList' );
		for $p.list {
			next if self.assert-hash-keys( $_,
					[< statement >] )
				and self._Statement( $_.hash.<statement> );
		}
		return True if self.assert-hash-keys( $p, [ ],
			[< statement >] );
	}

	method _Separator( Mu $p ) {
		self.trace( '_Separator' );
		# _SepType is a Str leaf
		return True if self.assert-hash-keys( $p,
				[< septype quantified_atom >] )
			and self._QuantifiedAtom( $p.hash.<quantified_atom> );
	}

	method _Sibble( Mu $p ) {
		self.trace( '_Sibble' );
		# _Right is a Bool leaf
		return True if self.assert-hash-keys( $p,
				[< right babble left >] )
			and self._Babble( $p.hash.<babble> )
			and self._Left( $p.hash.<left> );
	}

	method _SigFinal( Mu $p ) {
		self.trace( '_SigFinal' );
		# _NormSpace is a Str leaf
		return True if self.assert-hash-keys( $p, [< normspace >] );
	}

	method _SigMaybe( Mu $p ) {
		self.trace( '_SigMaybe' );
		return True if self.assert-hash-keys( $p,
				[< parameter typename >],
				[< param_sep >] )
			and self._Parameter( $p.hash.<parameter> )
			and self._TypeName( $p.hash.<typename> );
		return True if self.assert-hash-keys( $p, [],
				[< param_sep parameter >] );
	}

	method _Signature( Mu $p ) {
		self.trace( '_Signature' );
		return True if self.assert-hash-keys( $p,
				[< parameter typename >],
				[< param_sep >] )
			and self._Parameter( $p.hash.<parameter> )
			and self._TypeName( $p.hash.<typename> );
		return True if self.assert-hash-keys( $p,
				[< parameter >],
				[< param_sep >] )
			and self._Parameter( $p.hash.<parameter> );
		return True if self.assert-hash-keys( $p, [],
				[< param_sep parameter >] );
	}

	method _SMExpr( Mu $p ) {
		self.trace( '_SMExpr' );
		return True if self.assert-hash-keys( $p, [< EXPR >] )
			and self._EXPR( $p.hash.<EXPR> );
	}

	method _StatementControl( Mu $p ) {
		self.trace( '_StatementControl' );
		return True if self.assert-hash-keys( $p,
				[< block sym e1 e2 e3 >] )
			and self._Block( $p.hash.<block> )
			and self._Sym( $p.hash.<sym> )
			and self._E1( $p.hash.<e1> )
			and self._E2( $p.hash.<e2> )
			and self._E3( $p.hash.<e3> );
		# _Wu is a Str leaf
		return True if self.assert-hash-keys( $p,
				[< pblock sym EXPR wu >] )
			and self._PBlock( $p.hash.<pblock> )
			and self._Sym( $p.hash.<sym> )
			and self._EXPR( $p.hash.<EXPR> );
		# _Doc is a Bool leaf
		return True if self.assert-hash-keys( $p,
				[< doc sym module_name >] )
			and self._Sym( $p.hash.<sym> )
			and self._ModuleName( $p.hash.<module_name> );
		# _Doc is a Bool leaf
		return True if self.assert-hash-keys( $p,
				[< doc sym version >] )
			and self._Sym( $p.hash.<sym> )
			and self._Version( $p.hash.<version> );
		return True if self.assert-hash-keys( $p,
				[< sym else xblock >] )
			and self._Sym( $p.hash.<sym> )
			and self._Else( $p.hash.<else> )
			and self._XBlock( $p.hash.<xblock> );
		# _Wu is a Str leaf
		return True if self.assert-hash-keys( $p,
				[< xblock sym wu >] )
			and self._XBlock( $p.hash.<xblock> )
			and self._Sym( $p.hash.<sym> );
		return True if self.assert-hash-keys( $p,
				[< sym xblock >] )
			and self._Sym( $p.hash.<sym> )
			and self._XBlock( $p.hash.<xblock> );
		return True if self.assert-hash-keys( $p,
				[< block sym >] )
			and self._Block( $p.hash.<block> )
			and self._Sym( $p.hash.<sym> );
	}

	method _Statement( Mu $p ) {
		# N.B. we don't care so much *if* there's a list as *what's*
		# in the list. In other words we can assume that the content
		# is what we consider valid, so we can relax our requirements.
		for $p.list {
			if self.assert-hash-keys( $_,
					[< statement_mod_loop EXPR >] ) {
Perl6::Unimplemented.new(:content( "_Statement") );
			}
			elsif self.assert-hash-keys( $_,
					[< statement_mod_cond EXPR >] ) {
Perl6::Unimplemented.new(:content( "_Statement") );
			}
			elsif self.assert-hash-keys( $_, [< EXPR >] ) {
Perl6::Unimplemented.new(:content( "_Statement") );
			}
			elsif self.assert-hash-keys( $_,
					[< statement_control >] ) {
Perl6::Unimplemented.new(:content( "_Statement") );
			}
			elsif self.assert-hash-keys( $_, [],
					[< statement_control >] ) {
Perl6::Unimplemented.new(:content( "_Statement") );
			}
		}
		if self.assert-hash-keys( $p, [< statement_control >] ) {
Perl6::Unimplemented.new(:content( "_Statement") );
		}
		elsif self.assert-hash-keys( $p, [< EXPR >] ) {
			self._EXPR( $p.hash.<EXPR> )
		}
		else {
Perl6::Unimplemented.new(:content( "_Statement") );
		}
#`(
		if $p.list {
			for $p.list {
				next if self.assert-hash-keys( $_,
						[< statement_mod_loop EXPR >] )
					and self._StatementModLoop( $_.hash.<statement_mod_loop> )
					and self._EXPR( $_.hash.<EXPR> );
				next if self.assert-hash-keys( $_,
						[< statement_mod_cond EXPR >] )
					and self._StatementModCond( $_.hash.<statement_mod_cond> )
					and self._EXPR( $_.hash.<EXPR> );
				next if self.assert-hash-keys( $_, [< EXPR >] )
					and self._EXPR( $_.hash.<EXPR> );
				next if self.assert-hash-keys( $_,
						[< statement_control >] )
					and self._StatementControl( $_.hash.<statement_control> );
				next if self.assert-hash-keys( $_, [],
						[< statement_control >] );
			}
		}
		return True if self.assert-hash-keys( $p,
				[< statement_control >] )
			and self._StatementControl( $p.hash.<statement_control> );
		return True if self.assert-hash-keys( $p, [< EXPR >] )
			and self._EXPR( $p.hash.<EXPR> );
)
	}

	method _StatementList( Mu $p ) {
		self.trace( '_StatementList' );
		return True if self.assert-hash-keys( $p, [< statement >] )
			and self._Statement( $p.hash.<statement> );
		return True if self.assert-hash-keys( $p, [], [< statement >] );
	}

	method _StatementModCond( Mu $p ) {
		self.trace( '_StatementModCond' );
		return True if self.assert-hash-keys( $p,
				[< sym modifier_expr >] )
			and self._Sym( $p.hash.<sym> )
			and self._ModifierExpr( $p.hash.<modifier_expr> );
	}

	method _StatementModLoop( Mu $p ) {
		self.trace( '_StatementModLoop' );
		return True if self.assert-hash-keys( $p, [< sym smexpr >] )
			and self._Sym( $p.hash.<sym> )
			and self._SMExpr( $p.hash.<smexpr> );
	}

	method _StatementPrefix( Mu $p ) {
		self.trace( '_StatementPrefix' );
		return True if self.assert-hash-keys( $p, [< sym blorst >] )
			and self._Sym( $p.hash.<sym> )
			and self._Blorst( $p.hash.<blorst> );
		return False
	}

	method _SubShortName( Mu $p ) {
		self.trace( '_SubShortName' );
		return True if self.assert-hash-keys( $p, [< desigilname >] )
			and self._DeSigilName( $p.hash.<desigilname> );
	}

	method _Sym( Mu $p ) {
		self.trace( '_Sym' );
		for $p.list {
			next if $_.Str;
		}
		return True if $p.Bool and $p.Str eq '+';
		return True if $p.Bool and $p.Str eq '';
		return True if self.assert-Str( $p );
	}

	method _Term( Mu $p ) {
		self.trace( '_Term' );
		return True if self.assert-hash-keys( $p, [< methodop >] )
			and self._MethodOp( $p.hash.<methodop> );
	}

	method _TermAlt( Mu $p ) {
		for $p.list {
			next if self.assert-hash-keys( $_,
					[< termconj >] )
				and self._TermConj( $_.hash.<termconj> );
		}
	}

	method _TermAltSeq( Mu $p ) {
		self.trace( '_TermAltSeq' );
		return True if self.assert-hash-keys( $p, [< termconjseq >] )
			and self._TermConjSeq( $p.hash.<termconjseq> );
	}

	method _TermConj( Mu $p ) {
		self.trace( '_TermConj' );
		for $p.list {
			next if self.assert-hash-keys( $_,
					[< termish >] )
				and self._Termish( $_.hash.<termish> );
		}
	}

	method _TermConjSeq( Mu $p ) {
		self.trace( '_TermConjSeq' );
		for $p.list {
			next if self.assert-hash-keys( $_,
					[< termalt >] )
				and self._TermAlt( $_.hash.<termalt> );
		}
		return True if self.assert-hash-keys( $p, [< termalt >] )
			and self._TermAlt( $p.hash.<termalt> );
	}

	method _TermInit( Mu $p ) {
		self.trace( '_TermInit' );
		return True if self.assert-hash-keys( $p, [< sym EXPR >] )
			and self._Sym( $p.hash.<sym> )
			and self._EXPR( $p.hash.<EXPR> );
	}

	method _Termish( Mu $p ) {
		self.trace( '_Termish' );
		for $p.list {
			next if self.assert-hash-keys( $_, [< noun >] )
				and self._Noun( $_.hash.<noun> );
		}
		return True if self.assert-hash-keys( $p, [< noun >] )
			and self._Noun( $p.hash.<noun> );
	}

	method _TermSeq( Mu $p ) {
		self.trace( '_TermSeq' );
		return True if self.assert-hash-keys( $p, [< termaltseq >] )
			and self._TermAltSeq( $p.hash.<termaltseq> );
	}

	method _Twigil( Mu $p ) {
		self.trace( '_Twigil' );
		return True if self.assert-hash-keys( $p, [< sym >] )
			and self._Sym( $p.hash.<sym> );
	}

	method _TypeConstraint( Mu $p ) {
		self.trace( '_TypeConstraint' );
		for $p.list {
			next if self.assert-hash-keys( $_,
					[< typename >] )
				and self._TypeName( $_.hash.<typename> );
			next if self.assert-hash-keys( $_, [< value >] )
				and self._Value( $_.hash.<value> );
		}
		return True if self.assert-hash-keys( $p, [< value >] )
			and self._Value( $p.hash.<value> );
		return True if self.assert-hash-keys( $p, [< typename >] )
			and self._TypeName( $p.hash.<typename> );
	}

	method _TypeDeclarator( Mu $p ) {
		self.trace( '_TypeDeclarator' );
		return True if self.assert-hash-keys( $p,
				[< sym initializer variable >], [< trait >] )
			and self._Sym( $p.hash.<sym> )
			and self._Initializer( $p.hash.<initializer> )
			and self._Variable( $p.hash.<variable> );
		return True if self.assert-hash-keys( $p,
				[< sym initializer defterm >], [< trait >] )
			and self._Sym( $p.hash.<sym> )
			and self._Initializer( $p.hash.<initializer> )
			and self._DefTerm( $p.hash.<defterm> );
		return True if self.assert-hash-keys( $p,
				[< sym initializer >] )
			and self._Sym( $p.hash.<sym> )
			and self._Initializer( $p.hash.<initializer> );
	}

	method _TypeName( Mu $p ) {
		self.trace( '_TypeName' );
		for $p.list {
			next if self.assert-hash-keys( $_,
					[< longname colonpairs >],
					[< colonpair >] )
				and self._LongName( $_.hash.<longname> )
				and self._ColonPairs( $_.hash.<colonpairs> );
			next if self.assert-hash-keys( $_,
					[< longname >],
					[< colonpair >] )
				and self._LongName( $_.hash.<longname> );
		}
		return True if self.assert-hash-keys( $p,
				[< longname >], [< colonpair >] )
			and self._LongName( $p.hash.<longname> );
	}

	method _Val( Mu $p ) {
		self.trace( '_Val' );
		return True if self.assert-hash-keys( $p,
				[< prefix OPER >],
				[< prefix_postfix_meta_operator >] )
			and self._Prefix( $p.hash.<prefix> )
			and self._OPER( $p.hash.<OPER> );
		return True if self.assert-hash-keys( $p, [< value >] )
			and self._Value( $p.hash.<value> );
	}

	method _Value( Mu $p ) {
		self.trace( '_Value' );
		return True if self.assert-hash-keys( $p, [< number >] )
			and self._Number( $p.hash.<number> );
		return True if self.assert-hash-keys( $p, [< quote >] )
			and self._Quote( $p.hash.<quote> );
	}

	method _Var( Mu $p ) {
		self.trace( '_Var' );
		# _Sigil is a Str leaf
		return True if self.assert-hash-keys( $p,
				[< sigil desigilname >] )
			and self._DeSigilName( $p.hash.<desigilname> );
		return True if self.assert-hash-keys( $p, [< variable >] )
			and self._Variable( $p.hash.<variable> );
	}

	method _VariableDeclarator( Mu $p ) {
		# _Shape is a Str leaf
		if self.assert-hash-keys( $p,
				[< semilist variable shape >],
				[< postcircumfix signature trait
				   post_constraint >] ) {
Perl6::Unimplemented.new(:content( "_VariableDeclarator") );
		}
		elsif self.assert-hash-keys( $p,
				[< variable >],
				[< semilist postcircumfix signature
				   trait post_constraint >] ) {
			self._Variable( $p.hash.<variable> )
		}
#`(
		# _Shape is a Str leaf
		return True if self.assert-hash-keys( $p,
				[< semilist variable shape >],
				[< postcircumfix signature trait
				   post_constraint >] )
			and self._SemiList( $p.hash.<semilist> )
			and self._Variable( $p.hash.<variable> );
		return True if self.assert-hash-keys( $p,
				[< variable >],
				[< semilist postcircumfix signature
				   trait post_constraint >] )
			and self._Variable( $p.hash.<variable> );
)
	}

	method _Variable( Mu $p ) {
		self.trace( '_Variable' );

		if self.assert-hash-keys( $p, [< contextualizer >] ) {
#die $p.dump;
			return;
		}

		my $sigil       = $p.hash.<sigil>.Str;
		my $twigil      = $p.hash.<twigil> ??
			          $p.hash.<twigil>.Str !! '';
		my $desigilname = $p.hash.<desigilname> ??
				  $p.hash.<desigilname>.Str !! '';
		my $content     = $p.hash.<sigil> ~ $twigil ~ $desigilname;
		my %lookup = (
			'$' => Perl6::Variable::Scalar,
			'$*' => Perl6::Variable::Scalar::Dynamic,
			'$!' => Perl6::Variable::Scalar::Attribute,
			'$?' => Perl6::Variable::Scalar::CompileTimeVariable,
			'$<' => Perl6::Variable::Scalar::MatchIndex,
			'$^' => Perl6::Variable::Scalar::Positional,
			'$:' => Perl6::Variable::Scalar::Named,
			'$=' => Perl6::Variable::Scalar::Pod,
			'$~' => Perl6::Variable::Scalar::Sublanguage,
			'%' => Perl6::Variable::Hash,
			'%*' => Perl6::Variable::Hash::Dynamic,
			'%!' => Perl6::Variable::Hash::Attribute,
			'%?' => Perl6::Variable::Hash::CompileTimeVariable,
			'%<' => Perl6::Variable::Hash::MatchIndex,
			'%^' => Perl6::Variable::Hash::Positional,
			'%:' => Perl6::Variable::Hash::Named,
			'%=' => Perl6::Variable::Hash::Pod,
			'%~' => Perl6::Variable::Hash::Sublanguage,
			'@' => Perl6::Variable::Array,
			'@*' => Perl6::Variable::Array::Dynamic,
			'@!' => Perl6::Variable::Array::Attribute,
			'@?' => Perl6::Variable::Array::CompileTimeVariable,
			'@<' => Perl6::Variable::Array::MatchIndex,
			'@^' => Perl6::Variable::Array::Positional,
			'@:' => Perl6::Variable::Array::Named,
			'@=' => Perl6::Variable::Array::Pod,
			'@~' => Perl6::Variable::Array::Sublanguage,
			'&' => Perl6::Variable::Callable,
			'&*' => Perl6::Variable::Callable::Dynamic,
			'&!' => Perl6::Variable::Callable::Attribute,
			'&?' => Perl6::Variable::Callable::CompileTimeVariable,
			'&<' => Perl6::Variable::Callable::MatchIndex,
			'&^' => Perl6::Variable::Callable::Positional,
			'&:' => Perl6::Variable::Callable::Named,
			'&=' => Perl6::Variable::Callable::Pod,
			'&~' => Perl6::Variable::Callable::Sublanguage,
		);

		my $leaf;
		$leaf = %lookup{$sigil ~ $twigil}.new(
			:content( $content ),
			:headless( $desigilname )
		);
#say $leaf.perl;
		return $leaf;

	}

	method _Version( Mu $p ) {
		self.trace( '_Version' );
		# _VStr is an Int leaf
		return True if self.assert-hash-keys( $p, [< vnum vstr >] )
			and self._VNum( $p.hash.<vnum> );
	}

	method _VNum( Mu $p ) {
		self.trace( '_VNum' );
		for $p.list {
			next if self.assert-Int( $_ );
		}
	}

	method _XBlock( Mu $p ) returns Bool {
		self.trace( '_XBlock' );
		for $p.list {
			next if self.assert-hash-keys( $_,
					[< pblock EXPR >] )
				and self._PBlock( $_.hash.<pblock> )
				and self._EXPR( $_.hash.<EXPR> );
		}
		return True if self.assert-hash-keys( $p, [< pblock EXPR >] )
			and self._PBlock( $p.hash.<pblock> )
			and self._EXPR( $p.hash.<EXPR> );
		return True if self.assert-hash-keys( $p, [< blockoid >] )
			and self._Blockoid( $p.hash.<blockoid> );
	}

}
