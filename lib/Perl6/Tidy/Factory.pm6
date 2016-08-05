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
        L<Perl6::Variable::Scalar::CompileTime>
        L<Perl6::Variable::Scalar::MatchIndex>
        L<Perl6::Variable::Scalar::Positional>
        L<Perl6::Variable::Scalar::Named>
        L<Perl6::Variable::Scalar::Pod>
        L<Perl6::Variable::Scalar::SubLanguage>
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

=begin DEVELOPER_NOTES

Just to keep the hierarchy reasonably clean, classes do only the preprocessing necessary to generate the C<:content()> attribute. Everything else is done by methods. See L<Perl6::PackageName> and the L<Perl6::Variable> hierarchy for examples.

=end DEVELOPER_NOTES

=end pod

#`(

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
)

role Branching {
	has @.child;
	method perl6( $f ) {
		join( '', map { $_.perl6( $f ) }, @.child )
	}
}

role Token {
	has $.content;
	method perl6( $f ) {
		~$.content
	}
}

class Perl6::Unimplemented {
	has $.content
}

class Perl6::Document does Branching {
}

class Perl6::Statement does Branching {
}

# And now for the most basic tokens...
#
class Perl6::Number does Token {
}
class Perl6::Number::Binary {
	also is Perl6::Number;
}
class Perl6::Number::Octal {
	also is Perl6::Number;
}
class Perl6::Number::Decimal {
	also is Perl6::Number;
}
class Perl6::Number::Decimal::Explicit {
	also is Perl6::Number::Decimal;
}
class Perl6::Number::Hexadecimal {
	also is Perl6::Number;
}
class Perl6::Number::Radix {
	also is Perl6::Number;
}

class Perl6::Bareword does Token {
}
class Perl6::Operator does Token {
}
class Perl6::PackageName does Token {
	method namespaces() returns Array {
		$.content.split( '::' )
	}
}

# Semicolons should only occur at statement boundaries.
# So they're only generated in the _Statement handler.
#
# And the BUILD method is there so I can still have the role, and get the
# stringification behavior by default.
#
class Perl6::Semicolon does Token {
	submethod BUILD() { $!content = Q{;} }
}
class Perl6::WS does Token {
}

class Perl6::Variable {
	method headless() returns Str {
		$.content ~~ m/ <[$%@&]> <[*!?<^:=~]>? (.+) /;
		$0
	}
}
class Perl6::Variable::Scalar does Token {
	has $.sigil = Q{$};
}
class Perl6::Variable::Scalar::Dynamic {
	also is Perl6::Variable::Scalar;
	has $.twigil = Q{*};
}
class Perl6::Variable::Scalar::Attribute {
	also is Perl6::Variable::Scalar;
	has $.twigil = Q{!};
}
class Perl6::Variable::Scalar::CompileTime {
	also is Perl6::Variable::Scalar;
	has $.twigil = Q{?};
}
class Perl6::Variable::Scalar::MatchIndex {
	also is Perl6::Variable::Scalar;
	has $.twigil = Q{<};
}
class Perl6::Variable::Scalar::Positional {
	also is Perl6::Variable::Scalar;
	has $.twigil = Q{^};
}
class Perl6::Variable::Scalar::Named {
	also is Perl6::Variable::Scalar;
	has $.twigil = Q{:};
}
class Perl6::Variable::Scalar::Pod {
	also is Perl6::Variable::Scalar;
	has $.twigil = Q{=};
}
class Perl6::Variable::Scalar::SubLanguage {
	also is Perl6::Variable::Scalar;
	has $.twigil = Q{~};
}
class Perl6::Variable::Array does Token {
	has $.sigil = Q{@};
}
class Perl6::Variable::Array::Dynamic {
	also is Perl6::Variable::Array;
	has $.twigil = Q{*};
}
class Perl6::Variable::Array::Attribute {
	also is Perl6::Variable::Array;
	has $.twigil = Q{!};
}
class Perl6::Variable::Array::CompileTime {
	also is Perl6::Variable::Array;
	has $.twigil = Q{?};
}
class Perl6::Variable::Array::MatchIndex {
	also is Perl6::Variable::Array;
	has $.twigil = Q{<};
}
class Perl6::Variable::Array::Positional {
	also is Perl6::Variable::Array;
	has $.twigil = Q{^};
}
class Perl6::Variable::Array::Named {
	also is Perl6::Variable::Array;
	has $.twigil = Q{:};
}
class Perl6::Variable::Array::Pod {
	also is Perl6::Variable::Array;
	has $.twigil = Q{=};
}
class Perl6::Variable::Array::SubLanguage {
	also is Perl6::Variable::Array;
	has $.twigil = Q{~};
}
class Perl6::Variable::Hash does Token {
	has $.sigil = Q{%};
}
class Perl6::Variable::Hash::Dynamic {
	also is Perl6::Variable::Hash;
	has $.twigil = Q{*};
}
class Perl6::Variable::Hash::Attribute {
	also is Perl6::Variable::Hash;
	has $.twigil = Q{!};
}
class Perl6::Variable::Hash::CompileTime {
	also is Perl6::Variable::Hash;
	has $.twigil = Q{?};
}
class Perl6::Variable::Hash::MatchIndex {
	also is Perl6::Variable::Hash;
	has $.twigil = Q{<};
}
class Perl6::Variable::Hash::Positional {
	also is Perl6::Variable::Hash;
	has $.twigil = Q{^};
}
class Perl6::Variable::Hash::Named {
	also is Perl6::Variable::Hash;
	has $.twigil = Q{:};
}
class Perl6::Variable::Hash::Pod {
	also is Perl6::Variable::Hash;
	has $.twigil = Q{=};
}
class Perl6::Variable::Hash::SubLanguage {
	also is Perl6::Variable::Hash;
	has $.twigil = Q{~};
}
class Perl6::Variable::Callable does Token {
	has $.sigil = Q{&};
}
class Perl6::Variable::Callable::Dynamic {
	also is Perl6::Variable::Callable;
	has $.twigil = Q{*};
}
class Perl6::Variable::Callable::Attribute {
	also is Perl6::Variable::Callable;
	has $.twigil = Q{!};
}
class Perl6::Variable::Callable::CompileTime {
	also is Perl6::Variable::Callable;
	has $.twigil = Q{?};
}
class Perl6::Variable::Callable::MatchIndex {
	also is Perl6::Variable::Callable;
	has $.twigil = Q{<};
}
class Perl6::Variable::Callable::Positional {
	also is Perl6::Variable::Callable;
	has $.twigil = Q{^};
}
class Perl6::Variable::Callable::Named {
	also is Perl6::Variable::Callable;
	has $.twigil = Q{:};
}
class Perl6::Variable::Callable::Pod {
	also is Perl6::Variable::Callable;
	has $.twigil = Q{=};
}
class Perl6::Variable::Callable::SubLanguage {
	also is Perl6::Variable::Callable;
	has $.twigil = Q{~};
}

class Perl6::Tidy::Factory {

	sub key-boundary( Mu $p ) {
		say "{$p.from} {$p.to} [{substr($p.orig,$p.from,$p.to-$p.from)}]";
	}

	method ws-at-start( Mu $p ) {
		my $from = $p.from;
		my $to   = $p.to;
		my $orig = $p.orig;
		my $key  = substr( $orig, $from, $to - $from );
		
		if $key ~~ m/^ ( \s+ ) / {
			Perl6::WS.new(
				:content(
					~$0
				)
			)
		}
	}

	method ws-before( Mu $p ) {
		my $from = $p.from;
		my $to   = $p.to;
		my $orig = $p.orig;
		my $key  = substr( $orig, 0, $from );
		
		if $key ~~ / ( \s+ ) $/ {
			Perl6::WS.new(
				:content(
					~$0
				)
			)
		}
	}

	method ws-after( Mu $p ) {
		my $from = $p.from;
		my $to   = $p.to;
		my $orig = $p.orig;
		my $key  = substr( $orig, $to, $orig.chars - $from );
		
		if $key ~~ /^ ( \s+ ) / {
			Perl6::WS.new(
				:content(
					~$0
				)
			)
		}
	}

	method semicolon-after( Mu $p ) {
		my $to   = $p.to;
		my $orig = $p.orig;
		my $key  = substr($orig, $to, $orig.chars);

		if $key ~~ /^ ( \s* ) \; / {
			if $0 and $0 ne '' {
				return (
					Perl6::WS.new(
						:content(
							~$0
						)
					),
					Perl6::Semicolon.new
				)
			}
			return (
				Perl6::Semicolon.new
			)
		}
	}

	sub dump( Mu $parsed ) {
		say $parsed.hash.keys.gist;
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

	# $parsed can only be Num, by extension Int, by extension Str,
	# by extension Bool.
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

	method _ArgList( Mu $p ) {
		CATCH { when X::Hash::Store::OddNumber { .resume } }
#`(
		for $parsed.list {
			next if self.assert-hash-keys( $_, [< EXPR >] );
			next if self.assert-Bool( $_ );
		}
		if self.assert-hash-keys( $parsed,
				[< deftermnow initializer term_init >],
				[< trait >] );
		if self.assert-Int( $parsed );
		if self.assert-Bool( $parsed );
)
		if self.assert-hash-keys( $p, [< EXPR >] ) {
			self._EXPR( $p.hash.<EXPR> )
		}
		else {
			warn "Unhandled _ArgList case"
		}
	}

	method _Args( Mu $p ) {
#`(
		if self.assert-hash-keys( $p, [< invocant semiarglist >] );
		if self.assert-hash-keys( $p, [< semiarglist >] );
		if self.assert-hash-keys( $p, [ ], [< semiarglist >] );
		if self.assert-hash-keys( $p, [< EXPR >] );
		if self.assert-Bool( $p );
		if self.assert-Str( $p );
)
		if self.assert-hash-keys( $p, [< arglist >] ) {
			self._ArgList( $p.hash.<arglist> );
		}
		else {
			warn "Unhandled _Arg case"
		}
	}

	method _Assertion( Mu $p ) returns Bool {
say "Assertion fired";
		return True if self.assert-hash-keys( $p, [< var >] );
		return True if self.assert-hash-keys( $p, [< longname >] );
		return True if self.assert-hash-keys( $p, [< cclass_elem >] );
		return True if self.assert-hash-keys( $p, [< codeblock >] );
		return True if $p.Str;
	}

	method _Atom( Mu $p ) returns Bool {
say "Atom fired";
		return True if self.assert-hash-keys( $p, [< metachar >] );
		return True if self.assert-Str( $p );
	}

	method _Babble( Mu $p ) returns Bool {
say "Babble fired";
		# _B is a Bool leaf
		return True if self.assert-hash-keys( $p,
				[< B >], [< quotepair >] );
	}

	method _BackMod( Mu $p ) returns Bool { $p.hash.<backmod>.Bool }

	method _BackSlash( Mu $p ) returns Bool {
say "BackSlash fired";
		return True if self.assert-hash-keys( $p, [< sym >] );
		return True if self.assert-Str( $p );
	}

	method _BinInt( Mu $p ) {
		Perl6::Number::Binary.new(
			:content(
				$p.Str eq '0' ?? 0 !! $p.Int
			)
		)
	}

	method _Block( Mu $p ) {
		if self.assert-hash-keys( $p, [< blockoid >] ) {
			self._Blockoid( $p.hash.<blockoid> )
		}
		else {
			warn "Unhandled _Block case"
		}
	}

	method _Blockoid( Mu $p ) {
		if self.assert-hash-keys( $p, [< statementlist >] ) {
			self._StatementList( $p.hash.<statementlist> )
		}
		else {
			warn "Unhandled _Blockoid case"
		}
	}

	method _Blorst( Mu $p ) returns Bool {
say "Blorst fired";
		if self.assert-hash-keys( $p, [< statement >] ) {
#			self._Statement( $p.hash.<statement> )
Perl6::Unimplemented.new(:content( "_Declarator") );
		}
		if self.assert-hash-keys( $p, [< block >] ) {
#			self._Block( $p.hash.<block> )
Perl6::Unimplemented.new(:content( "_Declarator") );
		}
	}

	method _Bracket( Mu $p ) returns Bool {
say "Bracket fired";
		if self.assert-hash-keys( $p, [< semilist >] ) {
#			self._SemiList( $p.hash.<semilist> )
Perl6::Unimplemented.new(:content( "_Declarator") );
		}
	}

	method _CClassElem( Mu $p ) returns Bool {
say "CClassElem fired";
		for $p.list {
			# _Sign is a Str/Bool leaf
			next if self.assert-hash-keys( $_,
					[< identifier name sign >],
					[< charspec >] );
			# _Sign is a Str/Bool leaf
			next if self.assert-hash-keys( $_,
					[< sign charspec >] );
		}
	}

	method _CharSpec( Mu $p ) returns Bool {
say "CharSpec fired";
# XXX work on this, of course.
		return True if $p.list;
	}

	method _Circumfix( Mu $p ) returns Bool {
say "Circumfix fired";
		return True if self.assert-hash-keys( $p, [< nibble >] );
		return True if self.assert-hash-keys( $p, [< pblock >] );
		return True if self.assert-hash-keys( $p, [< semilist >] );
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
say "CodeBlock fired";
		if self.assert-hash-keys( $p, [< block >] ) {
#			self._Block( $p.hash.<block> )
Perl6::Unimplemented.new(:content( "_Declarator") );
		}
	}

	method _Coercee( Mu $p ) returns Bool {
say "Coercee fired";
		if self.assert-hash-keys( $p, [< semilist >] ) {
#			self._SemiList( $p.hash.<semilist> )
Perl6::Unimplemented.new(:content( "_Declarator") );
		}
	}

	method _ColonCircumfix( Mu $p ) returns Bool {
say "ColonCircumfix fired";
		if self.assert-hash-keys( $p, [< circumfix >] ) {
#			self._Circumfix( $p.hash.<circumfix> )
Perl6::Unimplemented.new(:content( "_Declarator") );
		}
	}

	method _ColonPair( Mu $p ) {
say "ColonPair fired";
		return True if self.assert-hash-keys( $p,
				     [< identifier coloncircumfix >] );
		if self.assert-hash-keys( $p, [< identifier >] ) {
#			self._Identifier( $p.hash.<identifier> )
Perl6::Unimplemented.new(:content( "_Declarator") );
		}
		if self.assert-hash-keys( $p, [< fakesignature >] ) {
#			self._FakeSignature( $p.hash.<fakesignature> )
Perl6::Unimplemented.new(:content( "_Declarator") );
		}
		if self.assert-hash-keys( $p, [< var >] ) {
#			self._Var( $p.hash.<var> )
Perl6::Unimplemented.new(:content( "_Declarator") );
		}
	}

	method _ColonPairs( Mu $p ) {
say "ColonPairs fired";
		if $p ~~ Hash {
			return True if $p.<D>;
			return True if $p.<U>;
		}
	}

	method _Contextualizer( Mu $p ) {
say "Contextualizer fired";
		# _Sigil is a Str leaf
		return True if self.assert-hash-keys( $p,
				[< coercee circumfix sigil >] );
	}

	method _DecInt( Mu $p ) {
		Perl6::Number::Decimal.new(
			:content(
				$p.Str eq '0' ?? 0 !! $p.Int
			)
		)
	}

	method _Declarator( Mu $p ) {
#`(
		if self.assert-hash-keys( $p,
				[< deftermnow initializer term_init >],
				[< trait >] );
		if self.assert-hash-keys( $p,
				[< initializer signature >], [< trait >] );
		if self.assert-hash-keys( $p,
				[< regex_declarator >], [< trait >] );
		if self.assert-hash-keys( $p,
				[< routine_declarator >], [< trait >] );
		if self.assert-hash-keys( $p, [< signature >], [< trait >] );
)

		if self.assert-hash-keys( $p,
				  [< initializer variable_declarator >],
				  [< trait >] ) {
			(
				self._VariableDeclarator(
					$p.hash.<variable_declarator>
				),
				self._Initializer(
					$p.hash.<initializer>
				)
			)
		}
		elsif self.assert-hash-keys( $p,
				[< variable_declarator >], [< trait >] ) {
			self._VariableDeclarator(
				$p.hash.<variable_declarator>
			)
		}
		else {
			warn "Unhandled _Declarator case"
		}
	}

	method _DECL( Mu $p ) {
say "DECL fired";
		return True if self.assert-hash-keys( $p,
				[< deftermnow initializer term_init >],
				[< trait >] );
		return True if self.assert-hash-keys( $p,
				[< deftermnow initializer signature >],
				[< trait >] );
		return True if self.assert-hash-keys( $p,
				[< initializer signature >], [< trait >] );
		return True if self.assert-hash-keys( $p,
					  [< initializer variable_declarator >],
					  [< trait >] );
		return True if self.assert-hash-keys( $p,
				[< signature >], [< trait >] );
		return True if self.assert-hash-keys( $p,
					  [< variable_declarator >],
					  [< trait >] );
		return True if self.assert-hash-keys( $p,
					  [< regex_declarator >],
					  [< trait >] );
		return True if self.assert-hash-keys( $p,
					  [< routine_declarator >],
					  [< trait >] );
		return True if self.assert-hash-keys( $p,
					  [< package_def sym >] );
		if self.assert-hash-keys( $p, [< declarator >] ) {
#			self._Declarator( $p.hash.<declarator> )
Perl6::Unimplemented.new(:content( "_Declarator") );
		}
	}

	method _DecNumber( Mu $p ) {
say "DecNumber fired";
		# _Coeff is a Str/Int leaf
		# _Frac is a Str/Int leaf
		# _Int is a Str/Int leaf
		return True if self.assert-hash-keys( $p,
				  [< int coeff frac escale >] );
		# _Coeff is a Str/Int leaf
		# _Frac is a Str/Int leaf
		return True if self.assert-hash-keys( $p,
				  [< coeff frac escale >] );
		# _Coeff is a Str/Int leaf
		# _Frac is a Str/Int leaf
		# _Int is a Str/Int leaf
		return True if self.assert-hash-keys( $p,
				  [< int coeff frac >] );
		# _Coeff is a Str/Int leaf
		# _Int is a Str/Int leaf
		return True if self.assert-hash-keys( $p,
				  [< int coeff escale >] );
		# _Coeff is a Str/Int leaf
		# _Frac is a Str/Int leaf
		return True if self.assert-hash-keys( $p, [< coeff frac >] );
	}

	method _DefLongName( Mu $p ) {
say "DefLongName fired";
		return True if self.assert-hash-keys( $p,
				[< name >], [< colonpair >] );
	}

	method _DefTerm( Mu $p ) {
say "DefTerm fired";
		return True if self.assert-hash-keys( $p,
				[< identifier colonpair >] );
		return True if self.assert-hash-keys( $p,
				[< identifier >], [< colonpair >] );
	}

	method _DefTermNow( Mu $p ) {
say "DefTermNow fired";
		if self.assert-hash-keys( $p, [< defterm >] ) {
#			self._DefTerm( $p.hash.<defterm> )
Perl6::Unimplemented.new(:content( "_Declarator") );
		}
	}

	method _DeSigilName( Mu $p ) {
say "DeSigilName fired";
		return True if self.assert-hash-keys( $p, [< longname >] );
		return True if $p.Str;
	}

	method _Dig( Mu $p ) {
say "Dig fired";
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

	method _Doc( Mu $p ) returns Bool { $p.hash.<doc>.Bool }

	method _Dotty( Mu $p ) {
say "Dotty fired";
		return True if self.assert-hash-keys( $p, [< sym dottyop O >] );
	}

	method _DottyOp( Mu $p ) {
say "DottyOp fired";
		return True if self.assert-hash-keys( $p,
				[< sym postop >], [< O >] );
		if self.assert-hash-keys( $p, [< methodop >] ) {
#			self._MethodOp( $p.hash.<methodop> )
Perl6::Unimplemented.new(:content( "_Declarator") );
		}
		if self.assert-hash-keys( $p, [< colonpair >] ) {
#			self._ColonPair( $p.hash.<colonpair> )
Perl6::Unimplemented.new(:content( "_Declarator") );
		}
	}

	method _DottyOpish( Mu $p ) {
say "DottyOpish fired";
		if self.assert-hash-keys( $p, [< term >] ) {
#			self._Term( $p.hash.<term> )
Perl6::Unimplemented.new(:content( "_Declarator") );
		}
	}

	method _E1( Mu $p ) {
say "E1 fired";
		if self.assert-hash-keys( $p, [< scope_declarator >] ) {
#			self._ScopeDeclarator( $p.hash.<scope_declarator> )
Perl6::Unimplemented.new(:content( "_Declarator") );
		}
	}

	method _E2( Mu $p ) {
say "E2 fired";
		return True if self.assert-hash-keys( $p, [< infix OPER >] );
	}

	method _E3( Mu $p ) {
say "E3 fired";
		return True if self.assert-hash-keys( $p, [< postfix OPER >],
				[< postfix_prefix_meta_operator >] );
	}

	method _Else( Mu $p ) {
say "Else fired";
		return True if self.assert-hash-keys( $p, [< sym blorst >] );
		return True if self.assert-hash-keys( $p, [< blockoid >] );
	}

	method _EScale( Mu $p ) {
say "EScale fired";
		# _DecInt is a Str/Int leaf
		# _Sign is a Str/Bool leaf
		return True if self.assert-hash-keys( $p, [< sign decint >] );
	}

	method __Term( Mu $p ) {
		if $p.hash.<variable> {
			(
				self._Variable( $p.hash.<variable> ),
				self.ws-after( $p.hash.<variable> )
			)
		}
		elsif $p.hash.<value> {
			my $v = $p.hash.<value>;
			if $v.hash.<number> {
				(
					self._Number( $v.hash.<number> ),
					self.ws-after( $v.hash.<number> )
				)
			}
			elsif $v.hash.<quote> {
				(
					self._Quote( $v.hash.<quote> ),
					self.ws-after( $v.hash.<quote> )
				)
			}
			else {
				warn "Unhandled __Term case"
			}
		}
		else {
			warn "Unhandled __Term case"
		}
	}

	method _EXPR( Mu $p ) {
#`(
		if $p.list {
			for $p.list {
				if self.assert-hash-keys( $_,
						[< dotty OPER >],
						[< postfix_prefix_meta_operator >] ) {
				}
				elsif self.assert-hash-keys( $_,
					[< postcircumfix OPER >],
					[< postfix_prefix_meta_operator >] ) {
				}
				elsif self.assert-hash-keys( $_,
						[< infix OPER >],
						[< infix_postfix_meta_operator >] ) {
				}
				elsif self.assert-hash-keys( $_,
						[< prefix OPER >],
						[< prefix_postfix_meta_operator >] ) {
				}
				elsif self.assert-hash-keys( $_,
						[< postfix OPER >],
						[< postfix_prefix_meta_operator >] ) {
				}
				elsif self.assert-hash-keys( $_,
						[< identifier args >] ) {
				}
				elsif self.assert-hash-keys( $_,
					[< infix_prefix_meta_operator OPER >] ) {
				}
				elsif self.assert-hash-keys( $_,
						[< longname args >] ) {
				}
				elsif self.assert-hash-keys( $_,
						[< args op >] ) {
				}
				elsif self.assert-hash-keys( $_, [< value >] ) {
				}
				elsif self.assert-hash-keys( $_,
						[< variable >] ) {
				}
				elsif self.assert-hash-keys( $_,
						[< methodop >] ) {
				}
				elsif self.assert-hash-keys( $_,
						[< package_declarator >] ) {
				}
				elsif self.assert-hash-keys( $_, [< sym >] ) {
				}
				elsif self.assert-hash-keys( $_,
						[< scope_declarator >] ) {
				}
				elsif self.assert-hash-keys( $_, [< dotty >] ) {
				}
				elsif self.assert-hash-keys( $_,
						[< circumfix >] ) {
				}
				elsif self.assert-hash-keys( $_,
						[< fatarrow >] ) {
				}
				elsif self.assert-hash-keys( $_,
						[< statement_prefix >] ) {
				}
				elsif self.assert-Str( $_ ) {
				}
			}
			if self.assert-hash-keys(
					$p,
					[< fake_infix OPER colonpair >] ) {
			}
			elsif self.assert-hash-keys(
					$p,
					[< OPER dotty >],
					[< postfix_prefix_meta_operator >] ) {
			}
			elsif self.assert-hash-keys(
					$p,
					[< postfix OPER >],
					[< postfix_prefix_meta_operator >] ) {
			}
			elsif self.assert-hash-keys(
					$p,
					[< infix OPER >],
					[< prefix_postfix_meta_operator >] ) {
			}
			elsif self.assert-hash-keys(
					$p,
					[< prefix OPER >],
					[< prefix_postfix_meta_operator >] ) {
			}
			elsif self.assert-hash-keys(
					$p,
					[< postcircumfix OPER >],
					[< postfix_prefix_meta_operator >] ) {
			}
			elsif self.assert-hash-keys( $p,
					[< OPER >],
					[< infix_prefix_meta_operator >] ) {
			}
		}
		# _Triangle is a Str leaf
		if self.assert-hash-keys( $p, [< args op triangle >] ) {
		}
		elsif self.assert-hash-keys( $p, [< identifier args >] ) {
		}
		elsif self.assert-hash-keys( $p, [< args op >] ) {
		}
		elsif self.assert-hash-keys( $p, [< sym args >] ) {
		}
		elsif self.assert-hash-keys( $p, [< statement_prefix >] ) {
#			self._StatementPrefix( $p.hash.<statement_prefix> )
		}
		elsif self.assert-hash-keys( $p, [< type_declarator >] ) {
#			self._TypeDeclarator( $p.hash.<type_declarator> )
		}
		elsif self.assert-hash-keys( $p, [< longname >] ) {
#			self._LongName( $p.hash.<longname> )
		}
		elsif self.assert-hash-keys( $p, [< value >] ) {
#			self._Value( $p.hash.<value> )
		}
		elsif self.assert-hash-keys( $p, [< variable >] ) {
#			self._Variable( $p.hash.<variable> )
		}
		elsif self.assert-hash-keys( $p, [< circumfix >] ) {
#			self._Circumfix( $p.hash.<circumfix> )
		}
		elsif self.assert-hash-keys( $p, [< colonpair >] ) {
#			self._ColonPair( $p.hash.<colonpair> )
		}
		elsif self.assert-hash-keys( $p, [< scope_declarator >] ) {
#			self._ScopeDeclarator( $p.hash.<scope_declarator> )
		}
		elsif self.assert-hash-keys( $p, [< routine_declarator >] ) {
#			self._RoutineDeclarator( $p.hash.<routine_declarator> )
		}
		elsif self.assert-hash-keys( $p, [< package_declarator >] ) {
#			self._PackageDeclarator( $p.hash.<package_declarator> )
		}
		elsif self.assert-hash-keys( $p, [< fatarrow >] ) {
#			self._FatArrow( $p.hash.<fatarrow> )
		}
		elsif self.assert-hash-keys( $p, [< multi_declarator >] ) {
#			self._MultiDeclarator( $p.hash.<multi_declarator> )
		}
		elsif self.assert-hash-keys( $p, [< regex_declarator >] ) {
#			self._RegexDeclarator( $p.hash.<regex_declarator> )
		}
		elsif self.assert-hash-keys( $p, [< dotty >] ) {
#			self._Dotty( $p.hash.<dotty> )
		}
)

		my @child;
		if self.assert-hash-keys( $p, [< infix OPER >] ) {
			@child = (
				self.__Term( $p.list.[0] ),
				self._Infix( $p.hash.<infix> ),
				self.ws-after( $p.hash.<infix> ),
				self.__Term( $p.list.[1] )
			).flat
		}
		elsif self.assert-hash-keys( $p, [< longname args >] ) {
			@child = (
				self._LongName( $p.hash.<longname> ),
				self.ws-at-start( $p.hash.<args> ),
				self._Args( $p.hash.<args> )
			)
		}
		elsif self.assert-hash-keys( $p, [< scope_declarator >] ) {
			@child = (
				self._ScopeDeclarator(
					$p.hash.<scope_declarator>
				)
			)
		}
		elsif self.assert-hash-keys( $p, [< package_declarator >] ) {
			@child = (
				self._PackageDeclarator(
					$p.hash.<package_declarator>
				)
			)
		}
		elsif self.assert-hash-keys( $p, [< value >] ) {
			@child = (
				self._Value(
					$p.hash.<value>
				)
			)
		}
		else {
			warn "Unhandled _EXPR case"
		}
		@child
	}

	method _FakeInfix( Mu $p ) {
say "FakeInfix fired";
		if self.assert-hash-keys( $p, [< O >] ) {
#			self._O( $p.hash.<O> )
Perl6::Unimplemented.new(:content( "_Declarator") );
		}
	}

	method _FakeSignature( Mu $p ) {
say "FakeSignature fired";
		if self.assert-hash-keys( $p, [< signature >] ) {
#			self._Signature( $p.hash.<signature> )
Perl6::Unimplemented.new(:content( "_Declarator") );
		}
	}

	method _FatArrow( Mu $p ) {
say "FatArrow fired";
		# _Key is a Str leaf
		return True if self.assert-hash-keys( $p, [< val key >] );
	}

	method _HexInt( Mu $p ) {
		Perl6::Number::Hexadecimal.new(
			:content(
				$p.Str eq '0' ?? 0 !! $p.Int
			)
		)
	}

	method _Identifier( Mu $p ) {
#`(
		for $p.list {
			next if self.assert-Str( $_ );
		}
		return True if $p.Str;
)
		if $p.Str {
			$p.Str
		}
	}

	method _Infix( Mu $p ) {
#`(
		if self.assert-hash-keys( $p, [< EXPR O >] );
		if self.assert-hash-keys( $p, [< infix OPER >] );
)
		if self.assert-hash-keys( $p, [< sym O >] ) {
			Perl6::Operator.new( :content( ~$p.hash.<sym>.Str ) )
		}
		else {
			warn "Unhandled _Infix case"
		}
	}

	method _Infixish( Mu $p ) {
say "Infixish fired";
		return True if self.assert-hash-keys( $p, [< infix OPER >] );
	}

	method _InfixPrefixMetaOperator( Mu $p ) {
say "InfixPrefixMetaOperator fired";
		return True if self.assert-hash-keys( $p,
			[< sym infixish O >] );
	}

	method _Initializer( Mu $p ) {
#`(
		if self.assert-hash-keys( $p, [< dottyopish sym >] );
)
		if self.assert-hash-keys( $p, [< sym EXPR >] ) {
			(
				self.ws-before( $p.hash.<sym> ),
				Perl6::Operator.new(
					:content(
						$p.hash.<sym>.Str
					)
				),
				self.ws-after( $p.hash.<sym> ),
				self._EXPR( $p.hash.<EXPR> )
			)
		}
		else {
			warn "Unhandled _Initializer case"
		}
	}

	method _Integer( Mu $p ) {
		if self.assert-hash-keys( $p, [< binint VALUE >] ) {
			self._BinInt( $p.hash.<binint> )
		}
		elsif self.assert-hash-keys( $p, [< octint VALUE >] ) {
			self._OctInt( $p.hash.<octint> )
		}
		elsif self.assert-hash-keys( $p, [< decint VALUE >] ) {
			self._DecInt( $p.hash.<decint> )
		}
		elsif self.assert-hash-keys( $p, [< hexint VALUE >] ) {
			self._HexInt( $p.hash.<hexint> )
		}
		else {
			Perl6::Unimplemented.new(
				:content( "Unknown integer type" )
			);
		}
	}

	method _Invocant( Mu $p ) {
say "Invocant fired";
		CATCH {
			when X::Multi::NoMatch { }
		}
		#return True if $p ~~ QAST::Want;
		#return True if self.assert-hash-keys( $p, [< XXX >] );
# XXX Fixme
#say $p.dump;
#say $p.dump_annotations;
#say "############## " ~$p.<annotations>.gist;#<BY>;
return True;
	}

	method _Lambda( Mu $p ) returns Str { $p.hash.<lambda>.Str }

	method _Left( Mu $p ) {
say "Left fired";
		if self.assert-hash-keys( $p, [< termseq >] ) {
#			self._TermSeq( $p.hash.<termseq> )
Perl6::Unimplemented.new(:content( "_Declarator") );
		}
	}

	method _LongName( Mu $p ) {
		if self.assert-hash-keys( $p, [< name >], [< colonpair >] ) {
			Perl6::PackageName.new(
				:content(
					$p.hash.<name>.Str
				)
			)
		}
		else {
			warn "Unhandled _LongName case"
		}
	}

	method _Max( Mu $p ) returns Str { $p.hash.<max>.Str }

	method _MetaChar( Mu $p ) {
say "MetaChar fired";
		if self.assert-hash-keys( $p, [< sym >] ) {
#			self._Sym( $p.hash.<sym> )
Perl6::Unimplemented.new(:content( "_Declarator") );
		}
		if self.assert-hash-keys( $p, [< codeblock >] ) {
#			self._CodeBlock( $p.hash.<codeblock> )
Perl6::Unimplemented.new(:content( "_Declarator") );
		}
		if self.assert-hash-keys( $p, [< backslash >] ) {
#			self._BackSlash( $p.hash.<backslash> )
Perl6::Unimplemented.new(:content( "_Declarator") );
		}
		if self.assert-hash-keys( $p, [< assertion >] ) {
#			self._Assertion( $p.hash.<assertion> )
Perl6::Unimplemented.new(:content( "_Declarator") );
		}
		if self.assert-hash-keys( $p, [< nibble >] ) {
#			self._Nibble( $p.hash.<nibble> )
Perl6::Unimplemented.new(:content( "_Declarator") );
		}
		if self.assert-hash-keys( $p, [< quote >] ) {
#			self._Quote( $p.hash.<quote> )
Perl6::Unimplemented.new(:content( "_Declarator") );
		}
		if self.assert-hash-keys( $p, [< nibbler >] ) {
#			self._Nibbler( $p.hash.<nibbler> )
Perl6::Unimplemented.new(:content( "_Declarator") );
		}
		if self.assert-hash-keys( $p, [< statement >] ) {
#			self._Statement( $p.hash.<statement> )
Perl6::Unimplemented.new(:content( "_Declarator") );
		}
	}

	method _MethodDef( Mu $p ) {
say "MethodDef fired";
		return True if self.assert-hash-keys( $p,
			     [< specials longname blockoid multisig >],
			     [< trait >] );
		return True if self.assert-hash-keys( $p,
			     [< specials longname blockoid >],
			     [< trait >] );
	}

	method _MethodOp( Mu $p ) {
say "MethodOp fired";
		return True if self.assert-hash-keys( $p, [< longname args >] );
		if self.assert-hash-keys( $p, [< longname >] ) {
#			self._LongName( $p.hash.<longname> )
Perl6::Unimplemented.new(:content( "_Declarator") );
		}
		if self.assert-hash-keys( $p, [< variable >] ) {
#			self._Variable( $p.hash.<variable> )
Perl6::Unimplemented.new(:content( "_Declarator") );
		}
	}

	method _Min( Mu $p ) {
		# _DecInt is a Str/Int leaf
		return True if self.assert-hash-keys( $p, [< decint VALUE >] );
	}

	method _ModifierExpr( Mu $p ) {
say "ModifierExpr fired";
		if self.assert-hash-keys( $p, [< EXPR >] ) {
#			self._EXPR( $p.hash.<EXPR> )
Perl6::Unimplemented.new(:content( "_Declarator") );
		}
	}

	method _ModuleName( Mu $p ) {
say "ModuleName fired";
		if self.assert-hash-keys( $p, [< longname >] ) {
#			self._LongName( $p.hash.<longname> )
Perl6::Unimplemented.new(:content( "_Declarator") );
		}
	}

	method _MoreName( Mu $p ) {
say "MoreName fired";
		for $p.list {
			next if self.assert-hash-keys( $_, [< identifier >] );
		}
	}

	method _MultiDeclarator( Mu $p ) {
say "MultiDeclarator fired";
		return True if self.assert-hash-keys( $p,
				[< sym routine_def >] );
		return True if self.assert-hash-keys( $p,
				[< sym declarator >] );
		if self.assert-hash-keys( $p, [< declarator >] ) {
#			self._Declarator( $p.hash.<declarator> )
Perl6::Unimplemented.new(:content( "_Declarator") );
		}
	}

	method _MultiSig( Mu $p ) {
say "MultiSig fired";
		if self.assert-hash-keys( $p, [< signature >] ) {
#			self._Signature( $p.hash.<signature> )
Perl6::Unimplemented.new(:content( "_Declarator") );
		}
	}

	method _NamedParam( Mu $p ) {
say "NamedParam fired";
		if self.assert-hash-keys( $p, [< param_var >] ) {
#			self._ParamVar( $p.hash.<param_var> )
Perl6::Unimplemented.new(:content( "_Declarator") );
		}
	}

	method _Name( Mu $p ) {
#`(
		if self.assert-hash-keys( $p,
			[< param_var type_constraint quant >],
			[< default_value modifier trait post_constraint >] );
		if self.assert-hash-keys( $p,
			[< identifier >], [< morename >] );
		if self.assert-hash-keys( $p, [< subshortname >] );
		if self.assert-hash-keys( $p, [< morename >] );
		True if self.assert-Str( $p );
)
		if self.assert-hash-keys( $p,
			[< identifier >], [< morename >] ) {
			self._Identifier( $p.hash.<identifier> )
		}
		elsif self.assert-Str( $p ) {
			Perl6::Bareword.new(
				:content(
					$p.Str
				)
			)
		}
		else {
			warn "Unhandled _Name case"
		}
	}

	method _Nibble( Mu $p ) {
#`(
		if self.assert-hash-keys( $p, [< termseq >] );
		if $p.Bool;
)
		if $p.Str {
			$p.Str
		}
		else {
			warn "Unhandled _Nibble case"
		}
	}

	method _Nibbler( Mu $p ) {
say "Nibbler fired";
		if self.assert-hash-keys( $p, [< termseq >] ) {
#			self._TermSeq( $p.hash.<termseq> )
Perl6::Unimplemented.new(:content( "_Declarator") );
		}
	}

	method _NormSpace( Mu $p ) returns Str { $p.hash.<normspace>.Str }

	method _Noun( Mu $p ) {
say "Noun fired";
		for $p.list {
			next if self.assert-hash-keys( $_,
				[< sigmaybe sigfinal quantifier atom >] );
			next if self.assert-hash-keys( $_,
				[< sigfinal quantifier separator atom >] );
			next if self.assert-hash-keys( $_,
				[< sigmaybe sigfinal separator atom >] );
			next if self.assert-hash-keys( $_,
				[< atom sigfinal quantifier >] );
			next if self.assert-hash-keys( $_,
				[< atom >], [< sigfinal >] );
		}
	}

	method _Number( Mu $p ) {
		if self.assert-hash-keys( $p, [< numish >] ) {
			self._Numish( $p.hash.<numish> )
		}
		else {
			warn "Unhandled _Number case"
		}
	}

	method _Numish( Mu $p ) {
#`(
		if self.assert-hash-keys( $p, [< rad_number >] );
		if self.assert-hash-keys( $p, [< dec_number >] );
		if self.assert-Num( $p );
)

		if self.assert-hash-keys( $p, [< integer >] ) {
			self._Integer( $p.hash.<integer> )
		}
		else {
			warn "Unhandled _Numish case"
		}
	}

	method _O( Mu $p ) {
say "O fired";
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

	method _OctInt( Mu $p ) {
		Perl6::Number::Octal.new(
			:content(
				$p.Str eq '0' ?? 0 !! $p.Int
			)
		)
	}

	method _Op( Mu $p ) {
say "Op fired";
		return True if self.assert-hash-keys( $p,
			     [< infix_prefix_meta_operator OPER >] );
		return True if self.assert-hash-keys( $p, [< infix OPER >] );
	}

	method _OPER( Mu $p ) {
say "OPER fired";
		return True if self.assert-hash-keys( $p, [< sym dottyop O >] );
		return True if self.assert-hash-keys( $p,
				[< sym infixish O >] );
		return True if self.assert-hash-keys( $p, [< sym O >] );
		return True if self.assert-hash-keys( $p, [< EXPR O >] );
		return True if self.assert-hash-keys( $p,
				[< semilist O >] );
		return True if self.assert-hash-keys( $p, [< nibble O >] );
		return True if self.assert-hash-keys( $p, [< arglist O >] );
		return True if self.assert-hash-keys( $p, [< dig O >] );;
		return True if self.assert-hash-keys( $p, [< O >] );
	}

	method _PackageDeclarator( Mu $p ) {
		if self.assert-hash-keys( $p, [< sym package_def >] ) {
			(
				self._Sym( $p.hash.<sym> ),
				self.ws-at-start( $p.hash.<package_def> ),
				self._PackageDef( $p.hash.<package_def> )
			).flat
		}
	}

	method _PackageDef( Mu $p ) {
#`(
		return True if self.assert-hash-keys( $p,
				[< blockoid longname >], [< trait >] );
		return True if self.assert-hash-keys( $p,
				[< longname statementlist >], [< trait >] );
		return True if self.assert-hash-keys( $p,
				[< blockoid >], [< trait >] );
)
		if self.assert-hash-keys( $p,
				[< blockoid longname >], [< trait >] ) {
			(
				self._LongName( $p.hash.<longname> ),
				self.ws-after( $p.hash.<longname> ),
				self._Blockoid( $p.hash.<blockoid> )
			).flat
		}
	}

	method _Parameter( Mu $p ) {
say "Parameter fired";
		for $p.list {
			next if self.assert-hash-keys( $_,
				[< param_var type_constraint quant >],
				[< default_value modifier trait
				   post_constraint >] );
			next if self.assert-hash-keys( $_,
				[< param_var quant >],
				[< default_value modifier trait
				   type_constraint
				   post_constraint >] );

			next if self.assert-hash-keys( $_,
				[< named_param quant >],
				[< default_value modifier
				   post_constraint trait
				   type_constraint >] );
			next if self.assert-hash-keys( $_,
				[< defterm quant >],
				[< default_value modifier
				   post_constraint trait
				   type_constraint >] );
			next if self.assert-hash-keys( $_,
				[< type_constraint >],
				[< param_var quant default_value						   modifier post_constraint trait
				   type_constraint >] );
		}
	}

	method _ParamVar( Mu $p ) {
say "ParamVar fired";
		return True if self.assert-hash-keys( $p,
				[< name twigil sigil >] );
		return True if self.assert-hash-keys( $p, [< name sigil >] );
		if self.assert-hash-keys( $p, [< signature >] ) {
#			self._Signature( $p.hash.<signature> )
Perl6::Unimplemented.new(:content( "_Declarator") );
		}
		if self.assert-hash-keys( $p, [< sigil >] ) {
#			self._Sigil( $p.hash.<sigil> )
Perl6::Unimplemented.new(:content( "_Declarator") );
		}
	}

	method _PBlock( Mu $p ) {
say "PBlock fired";
		return True if self.assert-hash-keys( $p,
				     [< lambda blockoid signature >] );
		if self.assert-hash-keys( $p, [< blockoid >] ) {
#			self._Blockoid( $p.hash.<blockoid> )
Perl6::Unimplemented.new(:content( "_Declarator") );
		}
	}

	method _PostCircumfix( Mu $p ) {
say "PostCircumfix fired";
		return True if self.assert-hash-keys( $p, [< nibble O >] );
		return True if self.assert-hash-keys( $p, [< semilist O >] );
		return True if self.assert-hash-keys( $p, [< arglist O >] );
	}

	method _Postfix( Mu $p ) {
say "Postfix fired";
		return True if self.assert-hash-keys( $p, [< dig O >] );
		return True if self.assert-hash-keys( $p, [< sym O >] );
	}

	method _PostOp( Mu $p ) {
say "PostOp fired";
		return True if self.assert-hash-keys( $p,
				[< sym postcircumfix O >] );
		return True if self.assert-hash-keys( $p,
				[< sym postcircumfix >], [< O >] );
	}

	method _Prefix( Mu $p ) {
say "Prefix fired";
		return True if self.assert-hash-keys( $p, [< sym O >] );
	}

	method _Quant( Mu $p ) returns Bool { $p.hash.<quant>.Bool }

	method _QuantifiedAtom( Mu $p ) {
say "QuantifiedAtom fired";
		return True if self.assert-hash-keys( $p, [< sigfinal atom >] );
	}

	method _Quantifier( Mu $p ) {
say "Quantifier fired";
		return True if self.assert-hash-keys( $p,
				[< sym min max backmod >] );
		return True if self.assert-hash-keys( $p, [< sym backmod >] );
	}

	method _Quibble( Mu $p ) {
say "Quibble fired";
		return True if self.assert-hash-keys( $p, [< babble nibble >] );
	}

	method _Quote( Mu $p ) {
#`(
		if self.assert-hash-keys( $p, [< sym quibble rx_adverbs >] );
		if self.assert-hash-keys( $p, [< sym rx_adverbs sibble >] );
		if self.assert-hash-keys( $p, [< quibble >] ) {
#			self._Quibble( $p.hash.<quibble> )
Perl6::Unimplemented.new(:content( "_Declarator") );
		}
)
		if self.assert-hash-keys( $p, [< nibble >] ) {
			self._Nibble( $p.hash.<nibble> )
		}
	}

	method _QuotePair( Mu $p ) {
say "QuotePair fired";
		for $p.list {
			next if self.assert-hash-keys( $_, [< identifier >] );
		}
		return True if self.assert-hash-keys( $p,
				[< circumfix bracket radix >], [< exp base >] );
		if self.assert-hash-keys( $p, [< identifier >] ) {
#			self._Identifier( $p.hash.<identifier> )
Perl6::Unimplemented.new(:content( "_Declarator") );
		}
	}

	method _Radix( Mu $p ) returns Int { $p.hash.<radix>.Int }

	method _RadNumber( Mu $p ) {
say "RadNumber fired";
		return True if self.assert-hash-keys( $p,
				[< circumfix bracket radix >], [< exp base >] );
		return True if self.assert-hash-keys( $p,
				[< circumfix radix >], [< exp base >] );
	}

	method _RegexDeclarator( Mu $p ) {
say "RegexDeclarator fired";
		return True if self.assert-hash-keys( $p, [< sym regex_def >] );
	}

	method _RegexDef( Mu $p ) {
say "RegexDef fired";
		return True if self.assert-hash-keys( $p,
				[< deflongname nibble >],
				[< signature trait >] );
	}

	method _Right( Mu $p ) returns Bool { $p.hash.<right>.Bool }

	method build( Mu $p ) {
		my @child =
			self._StatementList( $p.hash.<statementlist> );
		Perl6::Document.new(
			:child(
				@child
			)
		)
	}

	method _RoutineDeclarator( Mu $p ) {
say "RoutineDeclarator fired";
		return True if self.assert-hash-keys( $p,
				[< sym method_def >] );
		return True if self.assert-hash-keys( $p,
				[< sym routine_def >] );
	}

	method _RoutineDef( Mu $p ) {
say "RoutineDef fired";
		return True if self.assert-hash-keys( $p,
				[< blockoid deflongname multisig >],
				[< trait >] );
		return True if self.assert-hash-keys( $p,
				[< blockoid deflongname >],
				[< trait >] );
		return True if self.assert-hash-keys( $p,
				[< blockoid multisig >],
				[< trait >] );
		return True if self.assert-hash-keys( $p,
				[< blockoid >], [< trait >] );
	}

	method _RxAdverbs( Mu $p ) {
say "RxAdverbs fired";
		return True if self.assert-hash-keys( $p, [< quotepair >] );
		return True if self.assert-hash-keys( $p, [], [< quotepair >] );
	}

	method _Scoped( Mu $p ) {
#`(
		# XXX DECL seems to be a mirror of declarator. This probably
		# XXX will turn out to be not true later on.
		#
		if self.assert-hash-keys( $p,
					[< multi_declarator DECL typename >] ) {
		}
		elsif self.assert-hash-keys( $p,
				[< package_declarator DECL >],
				[< typename >] ) {
		}
)
		
		if self.assert-hash-keys( $p,
				[< declarator DECL >], [< typename >] ) {
			self._Declarator( $p.hash.<declarator> )
		}
	}

	method _ScopeDeclarator( Mu $p ) {
		(
			self._Sym( $p.hash.<sym>.Str ),
			self.ws-at-start( $p.hash.<scoped> ),
			self._Scoped( $p.hash.<scoped> )
		).flat
	}

	method _SemiArgList( Mu $p ) {
say "SemiArgList fired";
#		if self.assert-hash-keys( $p, [< arglist >] ) {
#			self._ArgList( $p.hash.<arglist> )
Perl6::Unimplemented.new(:content( "_Declarator") );
#		}
	}

	method _SemiList( Mu $p ) {
say "SemiList fired";
		for $p.list {
			next if self.assert-hash-keys( $_, [< statement >] );
		}
		return True if self.assert-hash-keys( $p, [ ],
			[< statement >] );
	}

	method _Separator( Mu $p ) {
say "Separator fired";
		return True if self.assert-hash-keys( $p,
				[< septype quantified_atom >] );
	}

	method _SepType( Mu $p ) returns Str { $p.hash.<septype>.Str }

	method _Shape( Mu $p ) returns Str { $p.hash.<shape>.Str }

	method _Sibble( Mu $p ) {
say "Sibble fired";
		return True if self.assert-hash-keys( $p,
				[< right babble left >] );
	}

	method _SigFinal( Mu $p ) {
say "SigFinal fired";
#		if self.assert-hash-keys( $p, [< normspace >] ) {
#			self._NormSpace( $p.hash.<normspace> )
Perl6::Unimplemented.new(:content( "_Declarator") );
#		}
	}

	method _Sigil( Mu $p ) returns Str { $p.hash.<sym>.Str }

	method _SigMaybe( Mu $p ) {
say "SigMaybe fired";
		return True if self.assert-hash-keys( $p,
				[< parameter typename >],
				[< param_sep >] );
		return True if self.assert-hash-keys( $p, [],
				[< param_sep parameter >] );
	}

	method _Signature( Mu $p ) {
say "Signature fired";
		return True if self.assert-hash-keys( $p,
				[< parameter typename >],
				[< param_sep >] );
		return True if self.assert-hash-keys( $p,
				[< parameter >],
				[< param_sep >] );
		return True if self.assert-hash-keys( $p, [],
				[< param_sep parameter >] );
	}

	method _SMExpr( Mu $p ) {
say "SMExpr fired";
		if self.assert-hash-keys( $p, [< EXPR >] ) {
#			self._EXPR( $p.hash.<EXPR> )
Perl6::Unimplemented.new(:content( "_Declarator") );
		}
	}

	method _Specials( Mu $p ) returns Bool { $p.hash.<specials>.Bool }

	method _StatementControl( Mu $p ) {
say "StatementControl fired";
		return True if self.assert-hash-keys( $p,
				[< block sym e1 e2 e3 >] );
		return True if self.assert-hash-keys( $p,
				[< pblock sym EXPR wu >] );
		return True if self.assert-hash-keys( $p,
				[< doc sym module_name >] );
		return True if self.assert-hash-keys( $p,
				[< doc sym version >] );
		return True if self.assert-hash-keys( $p,
				[< sym else xblock >] );
		return True if self.assert-hash-keys( $p, [< xblock sym wu >] );
		return True if self.assert-hash-keys( $p, [< sym xblock >] );
		return True if self.assert-hash-keys( $p, [< block sym >] );
	}

	method _Statement( Mu $p ) {
		# N.B. we don't care so much *if* there's a list as *what's*
		# in the list. In other words we can assume that the content
		# is what we consider valid, so we can relax our requirements.
#`(
		for $p.list {
			if self.assert-hash-keys( $_,
					[< statement_mod_loop EXPR >] ) {
			}
			elsif self.assert-hash-keys( $_,
					[< statement_mod_cond EXPR >] ) {
			}
			elsif self.assert-hash-keys( $_, [< EXPR >] ) {
#				self._EXPR(
#					$_.hash.<EXPR>
#				)
			}
			elsif self.assert-hash-keys( $_,
					[< statement_control >] ) {
#				self._StatementControl(
#					$_.hash.<statement_control>
#				)
			}
			elsif self.assert-hash-keys( $_, [],
					[< statement_control >] ) {
			}
		}
)

#`(
		if self.assert-hash-keys( $p, [< statement_control >] ) {
#			self._StatementControl( $p.hash.<statement_control> )
		}
)

		my @child;
		if self.assert-hash-keys( $p, [< EXPR >] ) {
			@child.append( self._EXPR( $p.hash.<EXPR> ) );
			@child.append( self.semicolon-after( $p.hash.<EXPR> ) )
		}

		Perl6::Statement.new(
			:child(
				@child
			)
		)
	}

	method _StatementList( Mu $p ) {
		my $statement = $p.hash.<statement>;
		my @child = map {
			self._Statement( $_ )
		}, $statement.list;
		@child
	}

	method _StatementModCond( Mu $p ) {
say "StatementModCond fired";
		return True if self.assert-hash-keys( $p,
				[< sym modifier_expr >] );
	}

	method _StatementModLoop( Mu $p ) {
say "StatementModLoop fired";
		return True if self.assert-hash-keys( $p, [< sym smexpr >] )
	}

	method _StatementPrefix( Mu $p ) {
say "StatementPrefix fired";
		return True if self.assert-hash-keys( $p, [< sym blorst >] );
	}

	method _SubShortName( Mu $p ) {
say "SubShortName fired";
		if self.assert-hash-keys( $p, [< desigilname >] ) {
#			self._DeSigilName( $p.hash.<desigilname> )
Perl6::Unimplemented.new(:content( "_Declarator") );
		}
	}

	method _Sym( Mu $p ) {
#`(
		for $p.list {
			next if $_.Str;
		}
		if $p.Bool and $p.Str eq '+';
		if $p.Bool and $p.Str eq '';
)
		if $p.Str {
			Perl6::Bareword.new(
				:content(
					$p.Str
				)
			)
		}
	}

	method _Term( Mu $p ) {
say "Term fired";
		if self.assert-hash-keys( $p, [< methodop >] ) {
#			self._MethodOp( $p.hash.<methodop> )
Perl6::Unimplemented.new(:content( "_Declarator") );
		}
	}

	method _TermAlt( Mu $p ) {
say "TermAlt fired";
		for $p.list {
			next if self.assert-hash-keys( $_, [< termconj >] );
		}
	}

	method _TermAltSeq( Mu $p ) {
say "TermAltSeq fired";
		if self.assert-hash-keys( $p, [< termconjseq >] ) {
#			self._TermConjSeq( $p.hash.<termconjseq> )
Perl6::Unimplemented.new(:content( "_Declarator") );
		}
	}

	method _TermConj( Mu $p ) {
say "TermConj fired";
		for $p.list {
			next if self.assert-hash-keys( $_, [< termish >] );
		}
	}

	method _TermConjSeq( Mu $p ) {
say "TermConjSeq fired";
		for $p.list {
			next if self.assert-hash-keys( $_, [< termalt >] );
		}
		if self.assert-hash-keys( $p, [< termalt >] ) {
#			self._TermAlt( $p.hash.<termalt> )
		}
	}

	method _TermInit( Mu $p ) {
say "TermInit fired";
		return True if self.assert-hash-keys( $p, [< sym EXPR >] );
	}

	method _Termish( Mu $p ) {
say "Termish fired";
		for $p.list {
			next if self.assert-hash-keys( $_, [< noun >] );
		}
		if self.assert-hash-keys( $p, [< noun >] ) {
#			self._Noun( $p.hash.<noun> )
		}
	}

	method _TermSeq( Mu $p ) {
say "TermSeq fired";
		if self.assert-hash-keys( $p, [< termaltseq >] ) {
#			self._TermAltSeq( $p.hash.<termaltseq> )
		}
	}

	method _Twigil( Mu $p ) returns Str { $p.hash.<sym>.Str }

	method _TypeConstraint( Mu $p ) {
say "TypeConstraint fired";
		for $p.list {
			next if self.assert-hash-keys( $_, [< typename >] );
			next if self.assert-hash-keys( $_, [< value >] );
		}
		if self.assert-hash-keys( $p, [< value >] ) {
#			self._Value( $p.hash.<value> )
		}
		elsif self.assert-hash-keys( $p, [< typename >] ) {
#			self._TypeName( $p.hash.<typename> )
		}
	}

	method _TypeDeclarator( Mu $p ) {
say "TypeDeclarator fired";
		return True if self.assert-hash-keys( $p,
				[< sym initializer variable >], [< trait >] );
		return True if self.assert-hash-keys( $p,
				[< sym initializer defterm >], [< trait >] );
		return True if self.assert-hash-keys( $p,
				[< sym initializer >] );
	}

	method _TypeName( Mu $p ) {
say "TypeName fired";
		for $p.list {
			next if self.assert-hash-keys( $_,
					[< longname colonpairs >],
					[< colonpair >] );
			next if self.assert-hash-keys( $_,
					[< longname >],
					[< colonpair >] );
		}
		if self.assert-hash-keys( $p,
				[< longname >], [< colonpair >] ) {
#			self._LongName( $p.hash.<longname> )
Perl6::Unimplemented.new(:content( "_Declarator") );
		}
	}

	method _Val( Mu $p ) {
say "Val fired";
		return True if self.assert-hash-keys( $p,
				[< prefix OPER >],
				[< prefix_postfix_meta_operator >] );
		if self.assert-hash-keys( $p, [< value >] ) {
#			self._Value( $p.hash.<value> )
Perl6::Unimplemented.new(:content( "_Declarator") );
		}
	}

	method _VALUE( Mu $p ) returns Int {
#		return $p.hash.<VALUE>.Str if
#			$p.hash.<VALUE>.Str and $p.hash.<VALUE>.Str eq '0';
#		$p.hash.<VALUE>.Int
		$p.hash.<VALUE>.Str || $p.hash.<VALUE>.Int
	}

	method _Value( Mu $p ) {
		if self.assert-hash-keys( $p, [< number >] ) {
			self._Number( $p.hash.<number> )
		}
		elsif self.assert-hash-keys( $p, [< quote >] ) {
			self._Quote( $p.hash.<quote> )
		}
	}

	method _Var( Mu $p ) {
say "Var fired";
		return True if self.assert-hash-keys( $p,
				[< sigil desigilname >] );
		if self.assert-hash-keys( $p, [< variable >] ) {
#			self._Variable( $p.hash.<variable> )
Perl6::Unimplemented.new(:content( "_Declarator") );
		}
	}

	method _VariableDeclarator( Mu $p ) {
#`(
		if self.assert-hash-keys( $p,
				[< semilist variable shape >],
				[< postcircumfix signature trait
				   post_constraint >] ) {
		}
)

		if self.assert-hash-keys( $p,
				[< variable >],
				[< semilist postcircumfix signature
				   trait post_constraint >] ) {
			self._Variable( $p.hash.<variable> );
		}
	}

	method _Variable( Mu $p ) {

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
			'$?' => Perl6::Variable::Scalar::CompileTime,
			'$<' => Perl6::Variable::Scalar::MatchIndex,
			'$^' => Perl6::Variable::Scalar::Positional,
			'$:' => Perl6::Variable::Scalar::Named,
			'$=' => Perl6::Variable::Scalar::Pod,
			'$~' => Perl6::Variable::Scalar::SubLanguage,
			'%' => Perl6::Variable::Hash,
			'%*' => Perl6::Variable::Hash::Dynamic,
			'%!' => Perl6::Variable::Hash::Attribute,
			'%?' => Perl6::Variable::Hash::CompileTime,
			'%<' => Perl6::Variable::Hash::MatchIndex,
			'%^' => Perl6::Variable::Hash::Positional,
			'%:' => Perl6::Variable::Hash::Named,
			'%=' => Perl6::Variable::Hash::Pod,
			'%~' => Perl6::Variable::Hash::SubLanguage,
			'@' => Perl6::Variable::Array,
			'@*' => Perl6::Variable::Array::Dynamic,
			'@!' => Perl6::Variable::Array::Attribute,
			'@?' => Perl6::Variable::Array::CompileTime,
			'@<' => Perl6::Variable::Array::MatchIndex,
			'@^' => Perl6::Variable::Array::Positional,
			'@:' => Perl6::Variable::Array::Named,
			'@=' => Perl6::Variable::Array::Pod,
			'@~' => Perl6::Variable::Array::SubLanguage,
			'&' => Perl6::Variable::Callable,
			'&*' => Perl6::Variable::Callable::Dynamic,
			'&!' => Perl6::Variable::Callable::Attribute,
			'&?' => Perl6::Variable::Callable::CompileTime,
			'&<' => Perl6::Variable::Callable::MatchIndex,
			'&^' => Perl6::Variable::Callable::Positional,
			'&:' => Perl6::Variable::Callable::Named,
			'&=' => Perl6::Variable::Callable::Pod,
			'&~' => Perl6::Variable::Callable::SubLanguage,
		);

		my $leaf = %lookup{$sigil ~ $twigil}.new(
			:content( $content )
		);
		return $leaf;
	}

	method _Version( Mu $p ) {
say "Version fired";
		return True if self.assert-hash-keys( $p, [< vnum vstr >] );
	}

	method _VStr( Mu $p ) returns Int { $p.hash.<vstr>.Int }

	method _VNum( Mu $p ) {
say "VNum fired";
		for $p.list {
			next if self.assert-Int( $_ );
		}
	}

	method _Wu( Mu $p ) returns Str { $p.hash.<wu>.Str }

	method _XBlock( Mu $p ) returns Bool {
say "XBlock fired";
		for $p.list {
			next if self.assert-hash-keys( $_, [< pblock EXPR >] );
		}
		return True if self.assert-hash-keys( $p, [< pblock EXPR >] );
		if self.assert-hash-keys( $p, [< blockoid >] ) {
#			self._Blockoid( $p.hash.<blockoid> )
Perl6::Unimplemented.new(:content( "_Declarator") );
		}
	}
}
