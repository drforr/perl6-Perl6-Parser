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

=begin DEBUGGING_NOTES

Should you brave the internals in search of a missing term, the first thing you should probably do is get an idea of what your parse tree looks like with the C<.dump> method. After that, you should be aware that C<.dump> only displays keys that actually have content, so there may be other keys that are merely defined. Those go in the third argument of C<.assert-hash-keys>.


=end DEBUGGING_NOTES

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

class Perl6::Element {
}

# XXX There should be a better way to do this.
#
role Child {
	has Perl6::Element @.child;
}
role Branching does Child {
	method perl6( $f ) {
		join( '', map { $_.perl6( $f ) }, @.child )
	}
}
role Branching_Delimited does Child {
	has @.delimiter;
	method perl6( $f ) {
		@.delimiter.[0] ~
		join( '', map { $_.perl6( $f ) }, @.child ) ~
		@.delimiter.[1]
	}
}

role Token {
	has $.content is required;
	has Int $.from is required;
	has Int $.to is required;
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
	also is Perl6::Element;
}

# And now for the most basic tokens...
#
class Perl6::Number does Token {
	also is Perl6::Element;
}
class Perl6::Number::Binary {
	also is Perl6::Number;
	has $.headless is required;
}
class Perl6::Number::Octal {
	also is Perl6::Number;
	has $.headless is required;
}
class Perl6::Number::Decimal {
	also is Perl6::Number;
}
class Perl6::Number::Decimal::Explicit {
	also is Perl6::Number::Decimal;
	has $.headless is required;
}
class Perl6::Number::Hexadecimal {
	also is Perl6::Number;
	has $.headless is required;
}
class Perl6::Number::Radix {
	also is Perl6::Number;
}
class Perl6::Number::Floating {
	also is Perl6::Number;
}

class Perl6::String does Token {
	also is Perl6::Element;
	has Str $.bare; # Easier to grab it from the parser.
}

class Perl6::Bareword does Token {
	also is Perl6::Element;
}
class Perl6::Operator {
	also is Perl6::Element;
}
class Perl6::Operator::Prefix does Token {
	also is Perl6::Operator;
}
class Perl6::Operator::Infix does Token {
	also is Perl6::Operator;
}
class Perl6::Operator::Postfix does Token {
	also is Perl6::Operator;
}
class Perl6::Operator::Circumfix does Branching_Delimited {
	also is Perl6::Operator;
}
class Perl6::Operator::PostCircumfix does Branching_Delimited {
	also is Perl6::Operator;
}
class Perl6::PackageName does Token {
	also is Perl6::Element;
	method namespaces() returns Array {
		$.content.split( '::' )
	}
}
class Perl6::ColonBareword does Token {
	also is Perl6::Bareword;
}
class Perl6::Block does Branching_Delimited {
	also is Perl6::Element
}

# Semicolons should only occur at statement boundaries.
# So they're only generated in the _Statement handler.
#
class Perl6::Semicolon does Token {
	also is Perl6::Element;
}

class Perl6::Variable {
	also is Perl6::Element;
	method headless() returns Str {
		$.content ~~ m/ <[$%@&]> <[*!?<^:=~]>? (.+) /;
		$0
	}
}
class Perl6::Variable::Scalar does Token {
	also is Perl6::Variable;
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
class Perl6::Variable::Scalar::Accessor {
	also is Perl6::Variable::Scalar;
	has $.twigil = Q{.};
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
	also is Perl6::Variable;
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
class Perl6::Variable::Array::Accessor {
	also is Perl6::Variable::Array;
	has $.twigil = Q{.};
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
	also is Perl6::Variable;
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
class Perl6::Variable::Hash::Accessor {
	also is Perl6::Variable::Hash;
	has $.twigil = Q{.};
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
	also is Perl6::Variable;
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
class Perl6::Variable::Callable::Accessor {
	also is Perl6::Variable::Callable;
	has $.twigil = Q{.};
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

	method semicolon-after( Mu $p ) {
		my $to   = $p.to;
		my $orig = $p.orig;
		my $key  = substr($orig, $to, $orig.chars);

		if $key ~~ /^ \; / {
			Perl6::Semicolon.new(
				:from( $to ),
				:to( $to + 1 ),
				:content( Q{;} )
			)
		}
	}

	method semicolon-at-end( Mu $p ) {
		if $p.Str ~~ / \; $/ {
			Perl6::Semicolon.new(
				:from( $p.to ),
				:to( $p.to + 1 ),
				:content( Q{;} )
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
			say $p.hash.keys.gist;
			warn "Unhandled case"
		}
	}

	method _Args( Mu $p ) {
#`(
		if self.assert-hash-keys( $p, [< invocant semiarglist >] );
		if self.assert-hash-keys( $p, [< EXPR >] );
)
		if self.assert-hash-keys( $p, [< semiarglist >] ) {
			$p.Str ~~ m{ ^ (.) }; my $front = ~$0;
			$p.Str ~~ m{ (.) $ }; my $back = ~$0;
			Perl6::Operator::PostCircumfix.new(
				:delimiter( $front, $back ),
				:child( )
			)
		}
		elsif self.assert-hash-keys( $p, [< arglist >] ) {
			self._ArgList( $p.hash.<arglist> );
		}
		elsif $p.Str {
			$p.Str
		}
		elsif $p.Bool {
			return ()
		}
		else {
			say $p.Int if $p.Int;
			say $p.hash.keys.gist;
			warn "Unhandled case"
		}
	}

	method _Assertion( Mu $p ) returns Bool {
say "Assertion fired";
#`(
		if self.assert-hash-keys( $p, [< var >] );
		if self.assert-hash-keys( $p, [< longname >] );
		if self.assert-hash-keys( $p, [< cclass_elem >] );
		if self.assert-hash-keys( $p, [< codeblock >] );
		if $p.Str;
)
	}

	method _Atom( Mu $p ) returns Bool {
say "Atom fired";
#`(
		if self.assert-hash-keys( $p, [< metachar >] );
		if self.assert-Str( $p );
)
	}

	method _Babble( Mu $p ) returns Bool {
say "Babble fired";
#`(
		if self.assert-hash-keys( $p, [< B >], [< quotepair >] );
)
	}

	method _BackMod( Mu $p ) returns Bool { $p.hash.<backmod>.Bool }

	method _BackSlash( Mu $p ) returns Bool {
say "BackSlash fired";
#`(
		if self.assert-hash-keys( $p, [< sym >] );
		if self.assert-Str( $p );
)
	}

	method _BinInt( Mu $p ) {
		Perl6::Number::Binary.new(
			:from( $p.from ),
			:to( $p.to ),
			:content(
				$p.Str
			)
		)
	}

	method _Block( Mu $p ) {
		if self.assert-hash-keys( $p, [< blockoid >] ) {
			self._Blockoid( $p.hash.<blockoid> )
		}
		else {
			say $p.hash.keys.gist;
			warn "Unhandled case"
		}
	}

	method _Blockoid( Mu $p ) {
		if self.assert-hash-keys( $p, [< statementlist >] ) {
			$p.Str ~~ m{ ^ (.) }; my $front = ~$0;
			$p.Str ~~ m{ (.) $ }; my $back = ~$0;
			Perl6::Block.new(
				:delimiter( $front, $back ),
				:child(
					self._StatementList( $p.hash.<statementlist> )
				)
			)
		}
		else {
			say $p.hash.keys.gist;
			warn "Unhandled case"
		}
	}

	method _Blorst( Mu $p ) returns Bool {
say "Blorst fired";
		if self.assert-hash-keys( $p, [< statement >] ) {
			self._Statement( $p.hash.<statement> )
		}
		elsif self.assert-hash-keys( $p, [< block >] ) {
			self._Block( $p.hash.<block> )
		}
		else {
			say $p.hash.keys.gist;
			warn "Unhandled case"
		}
	}

	method _Bracket( Mu $p ) returns Bool {
say "Bracket fired";
		if self.assert-hash-keys( $p, [< semilist >] ) {
			self._SemiList( $p.hash.<semilist> )
		}
		else {
			say $p.hash.keys.gist;
			warn "Unhandled case"
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

	method _Circumfix( Mu $p ) {
#`(
		if self.assert-hash-keys( $p, [< binint VALUE >] );
		if self.assert-hash-keys( $p, [< octint VALUE >] );
		if self.assert-hash-keys( $p, [< hexint VALUE >] );
)
		if self.assert-hash-keys( $p, [< pblock >] ) {
			self._PBlock( $p.hash.<pblock> )
		}
		elsif self.assert-hash-keys( $p, [< semilist >] ) {
			# XXX <semilist> can probably be worked with
			$p.Str ~~ m{ ^ (.) }; my $front = ~$0;
			$p.Str ~~ m{ (.) $ }; my $back = ~$0;
			if $p.hash.<semilist>.hash.<statement>.list.[0].hash.<EXPR> {
				Perl6::Operator::PostCircumfix.new(
					:delimiter( $front, $back ),
					:child(
self._EXPR( $p.hash.<semilist>.hash.<statement>.list.[0].hash.<EXPR> )
					)
				)
			}
			else {
				Perl6::Operator::PostCircumfix.new(
					:delimiter( $front, $back ),
					:child(
					)
				)
			}
		}
		elsif self.assert-hash-keys( $p, [< nibble >] ) {
			# XXX <nibble> can probably be worked with
			$p.Str ~~ m{ ^ (.) }; my $front = ~$0;
			$p.Str ~~ m{ (.) $ }; my $back = ~$0;
			Perl6::Operator::Circumfix.new(
				:delimiter( $front, $back ),
				:child(
					Perl6::Operator::Prefix.new(
						:from( $p.from ),
						:to( $p.to ),
						:content( $p.hash.<nibble>.Str )
					)
				)
			)
		}
		else {
			say $p.hash.keys.gist;
			warn "Unhandled case"
		}
	}

	method _CodeBlock( Mu $p ) returns Bool {
say "CodeBlock fired";
		if self.assert-hash-keys( $p, [< block >] ) {
			self._Block( $p.hash.<block> )
		}
		else {
			say $p.hash.keys.gist;
			warn "Unhandled case"
		}
	}

	method _Coercee( Mu $p ) returns Bool {
say "Coercee fired";
		if self.assert-hash-keys( $p, [< semilist >] ) {
			self._SemiList( $p.hash.<semilist> )
		}
		else {
			say $p.hash.keys.gist;
			warn "Unhandled case"
		}
	}

	method _ColonCircumfix( Mu $p ) {
		if self.assert-hash-keys( $p, [< circumfix >] ) {
			self._Circumfix( $p.hash.<circumfix> )
		}
		else {
			say $p.hash.keys.gist;
			warn "Unhandled case"
		}
	}

	method _ColonPair( Mu $p ) {
		if self.assert-hash-keys( $p,
				     [< identifier coloncircumfix >] ) {
			(
				Perl6::Operator::Infix.new(
					:from( -43 ),
					:to( -42 ),
					:content( Q{:} )
				),
				self._Identifier( $p.hash.<identifier> ),
				self._ColonCircumfix( $p.hash.<coloncircumfix> )
			).flat
		}
		elsif self.assert-hash-keys( $p, [< coloncircumfix >] ) {
			(
				Perl6::Operator::Infix.new(
					:from( -43 ),
					:to( -42 ),
					:content( Q{:} )
				),
				self._ColonCircumfix( $p.hash.<coloncircumfix> )
			).flat
		}
		elsif self.assert-hash-keys( $p, [< identifier >] ) {
			# XXX fix later
			Perl6::ColonBareword.new(
				:from( $p.from ),
				:to( $p.to ),
				:content( $p.Str )
			)
		}
		elsif self.assert-hash-keys( $p, [< fakesignature >] ) {
			(
				Perl6::Operator::Infix.new(
					:from( -43 ),
					:to( -42 ),
					:content( Q{:} )
				),
				self._FakeSignature( $p.hash.<fakesignature> )
			).flat
		}
		elsif self.assert-hash-keys( $p, [< var >] ) {
			(
				Perl6::Operator::Infix.new(
					:from( -43 ),
					:to( -42 ),
					:content( Q{:} )
				),
				self._Var( $p.hash.<var> )
			).flat
		}
		else {
			say $p.hash.keys.gist;
			warn "Unhandled case"
		}
	}

	method _ColonPairs( Mu $p ) {
say "ColonPairs fired";
		if $p ~~ Hash {
			return True if $p.<D>;
			return True if $p.<U>;
		}
		else {
			say $p.hash.keys.gist;
			warn "Unhandled case"
		}
	}

	method _Contextualizer( Mu $p ) {
say "Contextualizer fired";
#`(
		if self.assert-hash-keys( $p, [< coercee circumfix sigil >] );
)
	}

	method _DecInt( Mu $p ) {
		Perl6::Number::Decimal.new(
			:from( $p.from ),
			:to( $p.to ),
			:content(
				$p.Str
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
)

		if self.assert-hash-keys( $p,
				  [< initializer variable_declarator >],
				  [< trait >] ) {
			(
				self._VariableDeclarator(
					$p.hash.<variable_declarator>
				),
				self._Initializer( $p.hash.<initializer> )
			)
		}
		elsif self.assert-hash-keys( $p,
				[< routine_declarator >], [< trait >] ) {
			self._RoutineDeclarator( $p.hash.<routine_declarator> )
		}
		elsif self.assert-hash-keys( $p,
				[< regex_declarator >], [< trait >] ) {
			self._RegexDeclarator( $p.hash.<regex_declarator> )
		}
		elsif self.assert-hash-keys( $p,
				[< variable_declarator >], [< trait >] ) {
			self._VariableDeclarator(
				$p.hash.<variable_declarator>
			)
		}
		elsif self.assert-hash-keys( $p,
				[< signature >], [< trait >] ) {
			self._Signature( $p.hash.<signature> )
		}
		else {
			say $p.hash.keys.gist;
			warn "Unhandled case"
		}
	}

	method _DECL( Mu $p ) {
say "DECL fired";
#`(
		if self.assert-hash-keys( $p,
				[< deftermnow initializer term_init >],
				[< trait >] );
		if self.assert-hash-keys( $p,
				[< deftermnow initializer signature >],
				[< trait >] );
		if self.assert-hash-keys( $p,
				[< initializer signature >], [< trait >] );
		if self.assert-hash-keys( $p,
				[< initializer variable_declarator >],
				[< trait >] );
		if self.assert-hash-keys( $p, [< signature >], [< trait >] );
		if self.assert-hash-keys( $p,
				[< variable_declarator >],
				[< trait >] );
		if self.assert-hash-keys( $p,
				[< regex_declarator >],
				[< trait >] );
		if self.assert-hash-keys( $p,
				[< routine_declarator >],
				[< trait >] );
		if self.assert-hash-keys( $p, [< package_def sym >] );
)
		if self.assert-hash-keys( $p, [< declarator >] ) {
			self._Declarator( $p.hash.<declarator> )
		}
	}

	method _DecNumber( Mu $p ) {
		if self.assert-hash-keys( $p, [< int coeff escale frac >] ) {
			self.__FloatingPoint( $p )
		}
		elsif self.assert-hash-keys( $p, [< coeff frac escale >] ) {
			self.__FloatingPoint( $p )
		}
		elsif self.assert-hash-keys( $p, [< int coeff frac >] ) {
			self.__FloatingPoint( $p )
		}
		elsif self.assert-hash-keys( $p, [< int coeff escale >] ) {
			self.__FloatingPoint( $p )
		}
		else {
			say $p.hash.keys.gist;
			warn "Unhandled case"
		}
	}

	method _DefaultValue( Mu $p ) {
		CATCH { when X::Hash::Store::OddNumber { .resume } }
		my @child;
		for $p.list {
			if self.assert-hash-keys( $_, [< EXPR >] ) {
				@child.push(
					self._EXPR( $_.hash.<EXPR> )
				)
			}
			else {
				say $p.hash.keys.gist;
				warn "Unhandled case"
			}
		}
		@child.flat
	}

	method _DefLongName( Mu $p ) {
		if self.assert-hash-keys( $p, [< name >], [< colonpair >] ) {
			self._Name( $p.hash.<name> )
		}
		else {
			say $p.hash.keys.gist;
			warn "Unhandled case"
		}
	}

	method _DefTerm( Mu $p ) {
say "DefTerm fired";
#`(
		if self.assert-hash-keys( $p, [< identifier colonpair >] );
		if self.assert-hash-keys( $p,
				[< identifier >], [< colonpair >] );
)
	}

	method _DefTermNow( Mu $p ) {
say "DefTermNow fired";
		if self.assert-hash-keys( $p, [< defterm >] ) {
			self._DefTerm( $p.hash.<defterm> )
		}
		else {
			say $p.hash.keys.gist;
			warn "Unhandled case"
		}
	}

	method _DeSigilName( Mu $p ) {
say "DeSigilName fired";
#`(
		if self.assert-hash-keys( $p, [< longname >] );
		if $p.Str;
)
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
		if self.assert-hash-keys( $p, [< sym dottyop O >] ) {
			(
				Perl6::Operator::Prefix.new(
					:from( $p.hash.<sym>.from ),
					:to( $p.hash.<sym>.to ),
					:content( $p.hash.<sym>.Str )
				),
				self._DottyOp( $p.hash.<dottyop> )
			)
		}
		else {
			say $p.hash.keys.gist;
			warn "Unhandled case"
		}
	}

	method _DottyOp( Mu $p ) {
#`(
		return True if self.assert-hash-keys( $p,
				[< sym postop >], [< O >] );
)
		if self.assert-hash-keys( $p, [< colonpair >] ) {
			self._ColonPair( $p.hash.<colonpair> )
		}
		elsif self.assert-hash-keys( $p, [< methodop >] ) {
			self._MethodOp( $p.hash.<methodop> )
		}
		else {
			say $p.hash.keys.gist;
			warn "Unhandled case"
		}
	}

	method _DottyOpish( Mu $p ) {
say "DottyOpish fired";
		if self.assert-hash-keys( $p, [< term >] ) {
			self._Term( $p.hash.<term> )
		}
		else {
			say $p.hash.keys.gist;
			warn "Unhandled case"
		}
	}

	method _E1( Mu $p ) {
say "E1 fired";
		if self.assert-hash-keys( $p, [< scope_declarator >] ) {
			self._ScopeDeclarator( $p.hash.<scope_declarator> )
		}
		else {
			say $p.hash.keys.gist;
			warn "Unhandled case"
		}
	}

	method _E2( Mu $p ) {
say "E2 fired";
#`(
		if self.assert-hash-keys( $p, [< infix OPER >] );
)
	}

	method _E3( Mu $p ) {
say "E3 fired";
#`(
		if self.assert-hash-keys( $p, [< postfix OPER >],
				[< postfix_prefix_meta_operator >] );
)
	}

	method _Else( Mu $p ) {
say "Else fired";
#`(
		if self.assert-hash-keys( $p, [< sym blorst >] );
		if self.assert-hash-keys( $p, [< blockoid >] );
)
	}

	method _EScale( Mu $p ) {
say "EScale fired";
#`(
		if self.assert-hash-keys( $p, [< sign decint >] );
)
	}

	method __Term( Mu $p ) {
		if self.assert-hash-keys( $p,
				[< postfix OPER >],
				[< postfix_prefix_meta_operator >] ) {
			(
				self.__Term( $p.list.[0] ),
				self._Postfix( $p.hash.<postfix> )
			)
		}
		elsif self.assert-hash-keys( $p,
				[< identifier >], [< args >] ) {
			self._Identifier( $p.hash.<identifier> )
		}
		elsif self.assert-hash-keys( $p, [< longname >], [< args >] ) {
			self._LongName( $p.hash.<longname> )
		}
		elsif self.assert-hash-keys( $p, [< longname >] ) {
			self._LongName( $p.hash.<longname> )
		}
		elsif self.assert-hash-keys( $p, [< variable >] ) {
			self._Variable( $p.hash.<variable> )
		}
		elsif self.assert-hash-keys( $p, [< value >] ) {
			my $v = $p.hash.<value>;
			if self.assert-hash-keys( $v, [< number >] ) {
				self._Number( $v.hash.<number> )
			}
			elsif self.assert-hash-keys( $v, [< quote >] ) {
				self._Quote( $v.hash.<quote> )
			}
			else {
				say $p.hash.keys.gist;
				warn "Unhandled case"
			}
		}
		else {
			say $p.hash.keys.gist;
			warn "Unhandled case"
		}
	}

	method _EXPR( Mu $p ) {
		if self.assert-hash-keys( $p,
				[< dotty OPER >],
				[< postfix_prefix_meta_operator >] ) {
			# XXX Look into this at some point.
			if substr( $p.orig, $p.from, 2 ) eq '>>' {
				(
					self.__Term( $p.list.[0] ),
					Perl6::Operator::Prefix.new(
						:from( $p.from ),
						:to( $p.from + 2 ),
						:content( 
							substr( $p.orig, $p.from, 2 )
						)
					),
					self._Dotty( $p.hash.<dotty> )
				).flat
			}
			else {
				(
					self.__Term( $p.list.[0] ),
					self._Dotty( $p.hash.<dotty> )
				).flat
			}
		}
		elsif self.assert-hash-keys( $p,
				[< prefix OPER >],
				[< prefix_postfix_meta_operator >] ) {
			(
				self._Prefix( $p.hash.<prefix> ),
				self.__Term( $p.list.[0] )
			).flat
		}
		elsif self.assert-hash-keys( $p,
				[< postcircumfix OPER >],
				[< postfix_prefix_meta_operator >] ) {
			# XXX Work on this
			$p.hash.<postcircumfix>.Str ~~ m{ ^ (.) }; my $front = ~$0;
			$p.hash.<postcircumfix>.Str ~~ m{ (.) $ }; my $back = ~$0;
			(
				self.__Term( $p.list.[0] ),
				Perl6::Operator::PostCircumfix.new(
					:delimiter( $front, $back ),
					:child(
						self._PostCircumfix( $p.hash.<postcircumfix> )
					)
				)
			).flat
		}
		elsif self.assert-hash-keys( $p,
				[< postfix OPER >],
				[< postfix_prefix_meta_operator >] ) {
			(
				self.__Term( $p.list.[0] ),
				self._Postfix( $p.hash.<postfix> )
			).flat
		}
		elsif self.assert-hash-keys( $p,
				[< infix_prefix_meta_operator OPER >] ) {
			(
				self.__Term( $p.list.[0] ),
				self._InfixPrefixMetaOperator(
					$p.hash.<infix_prefix_meta_operator>
				),
				self.__Term( $p.list.[1] )
			).flat
		}
		elsif self.assert-hash-keys( $p, [< infix OPER >] ) {
			# XXX fix later
			if $p.list.elems == 3 {
				(
					self.__Term( $p.list.[0] ),
					Perl6::Operator::Infix.new(
						:from( $p.list.[0].to + 1 ),
						:to( $p.list.[1].from - 1 ),
						:content( Q{??} )
					),
					self.__Term( $p.list.[1] ),
					Perl6::Operator::Infix.new(
						:from( $p.list.[1].to + 1 ),
						:to( $p.list.[2].from - 1 ),
						:content( Q{!!} )
					),
					self.__Term( $p.list.[2] )
				).flat
			}
			else {
				(
					self.__Term( $p.list.[0] ),
					self._Infix( $p.hash.<infix> ),
					self.__Term( $p.list.[1] )
				).flat
			}
		}
		elsif self.assert-hash-keys( $p, [< identifier args >] ) {
			(
				self._Identifier( $p.hash.<identifier> ),
				self._Args( $p.hash.<args> )
			)
		}
		elsif self.assert-hash-keys( $p, [< sym args >] ) {
			note "Skipping args for the time being";
			Perl6::Operator::Infix.new(
				:from( $p.hash.<sym>.from ),
				:to( $p.hash.<sym>.to ),
				:content( $p.hash.<sym>.Str )
			)
		}
		elsif self.assert-hash-keys( $p, [< longname args >] ) {
			# XXX Needs work later on
			if $p.hash.<args> and
			   $p.hash.<args>.hash.<semiarglist> {
				(
					self._LongName( $p.hash.<longname> ),
					self._Args( $p.hash.<args> )
				)
			}
			else {
				self._LongName( $p.hash.<longname> )
			}
		}
		elsif self.assert-hash-keys( $p, [< circumfix >] ) {
			self._Circumfix( $p.hash.<circumfix> )
		}
		elsif self.assert-hash-keys( $p, [< fatarrow >] ) {
			self._FatArrow( $p.hash.<fatarrow> )
		}
		elsif self.assert-hash-keys( $p, [< regex_declarator >] ) {
			self._RegexDeclarator( $p.hash.<regex_declarator> )
		}
		elsif self.assert-hash-keys( $p, [< routine_declarator >] ) {
			self._RoutineDeclarator( $p.hash.<routine_declarator> )
		}
		elsif self.assert-hash-keys( $p, [< scope_declarator >] ) {
			self._ScopeDeclarator( $p.hash.<scope_declarator> )
		}
		elsif self.assert-hash-keys( $p, [< package_declarator >] ) {
			self._PackageDeclarator( $p.hash.<package_declarator> )
		}
		elsif self.assert-hash-keys( $p, [< value >] ) {
			self._Value( $p.hash.<value> )
		}
		elsif self.assert-hash-keys( $p, [< variable >] ) {
			self._Variable( $p.hash.<variable> )
		}
		elsif self.assert-hash-keys( $p, [< colonpair >] ) {
			self._ColonPair( $p.hash.<colonpair> )
		}
		elsif self.assert-hash-keys( $p, [< longname >] ) {
			self._LongName( $p.hash.<longname> )
		}
		else {
			say $p.hash.keys.gist;
			warn "Unhandled case"
		}
	}

	method _FakeInfix( Mu $p ) {
say "FakeInfix fired";
		if self.assert-hash-keys( $p, [< O >] ) {
			self._O( $p.hash.<O> )
		}
		else {
			say $p.hash.keys.gist;
			warn "Unhandled case"
		}
	}

	method _FakeSignature( Mu $p ) {
		if self.assert-hash-keys( $p, [< signature >] ) {
			# XXX Fix
			Perl6::Operator::PostCircumfix.new(
				:delimiter( '(', ')' ),
				:child( )
			)
		}
		else {
			say $p.hash.keys.gist;
			warn "Unhandled case"
		}
	}

	method _FatArrow( Mu $p ) {
		if self.assert-hash-keys( $p, [< key val >] ) {
			(
				self._Key( $p.hash.<key> ),
				# XXX Note that we synthesize here.
				Perl6::Operator::Infix.new(
					:from( $p.hash.<key>.to + 1 ),
					:to( $p.hash.<val>.from - 1 ),
					:content( Q{=>} )
				),
				self._Val( $p.hash.<val> )
			)
		}
	}

	method __FloatingPoint( Mu $p ) {
		Perl6::Number::Floating.new(
			:from( $p.from ),
			:to( $p.to ),
			:content( $p.Str )
		)
	}

	method _HexInt( Mu $p ) {
		Perl6::Number::Hexadecimal.new(
			:from( $p.from ),
			:to( $p.to ),
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
)
		if $p.Str {
			Perl6::Bareword.new(
				:from( $p.from ),
				:to( $p.to ),
				:content(
					$p.Str
				)
			)
		}
		else {
			say $p.hash.keys.gist;
			warn "Unhandled case"
		}
	}

	method _Infix( Mu $p ) {
#`(
		if self.assert-hash-keys( $p, [< EXPR O >] );
		if self.assert-hash-keys( $p, [< infix OPER >] );
)
		if self.assert-hash-keys( $p, [< sym O >] ) {
			Perl6::Operator::Infix.new(
				:from( $p.hash.<sym>.from ),
				:to( $p.hash.<sym>.to ),
				:content( $p.hash.<sym>.Str )
			)
		}
		else {
			say $p.hash.keys.gist;
			warn "Unhandled case"
		}
	}

	method _Infixish( Mu $p ) {
say "Infixish fired";
#`(
		if self.assert-hash-keys( $p, [< infix OPER >] );
)
	}

	method _InfixPrefixMetaOperator( Mu $p ) {
		if self.assert-hash-keys( $p, [< sym infixish O >] ) {
			Perl6::Operator::Infix.new(
				:from( $p.hash.<sym>.from ),
				:to( $p.hash.<sym>.to ),
				:content(
					$p.hash.<sym>.Str ~ $p.hash.<infixish>
				)
			)
		}
		else {
			say $p.hash.keys.gist;
			warn "Unhandled case"
		}
	}

	method _Initializer( Mu $p ) {
#`(
		if self.assert-hash-keys( $p, [< dottyopish sym >] );
)
		if self.assert-hash-keys( $p, [< sym EXPR >] ) {
			(
				Perl6::Operator::Infix.new(
					:from( $p.hash.<sym>.from ),
					:to( $p.hash.<sym>.to )
					:content(
						$p.hash.<sym>.Str
					)
				),
				self._EXPR( $p.hash.<EXPR> )
			)
		}
		else {
			say $p.hash.keys.gist;
			warn "Unhandled case"
		}
	}

	method _Integer( Mu $p ) {
		if self.assert-hash-keys( $p, [< binint VALUE >] ) {
			Perl6::Number::Binary.new(
				:from( $p.from ),
				:to( $p.to ),
				:content(
					$p.Str
				),
				:headless( $p.hash.<binint>.Str )
			)
		}
		elsif self.assert-hash-keys( $p, [< octint VALUE >] ) {
			Perl6::Number::Octal.new(
				:from( $p.from ),
				:to( $p.to ),
				:content(
					$p.Str
				),
				:headless( $p.hash.<octint>.Str )
			)
		}
		elsif self.assert-hash-keys( $p, [< decint VALUE >] ) {
			Perl6::Number::Decimal.new(
				:from( $p.from ),
				:to( $p.to ),
				:content(
					$p.Str
				),
				:headless( $p.hash.<decint>.Str )
			)
		}
		elsif self.assert-hash-keys( $p, [< hexint VALUE >] ) {
			Perl6::Number::Hexadecimal.new(
				:from( $p.from ),
				:to( $p.to ),
				:content(
					$p.Str
				),
				:headless( $p.hash.<hexint>.Str )
			)
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

	method _Key( Mu $p ) {
		Perl6::Bareword.new(
			:from( $p.from ),
			:to( $p.to ),
			:content( $p.Str )
		)
	}

	method _Lambda( Mu $p ) returns Str { $p.hash.<lambda>.Str }

	method _Left( Mu $p ) {
say "Left fired";
		if self.assert-hash-keys( $p, [< termseq >] ) {
			self._TermSeq( $p.hash.<termseq> )
		}
		else {
			say $p.hash.keys.gist;
			warn "Unhandled case"
		}
	}

	method _LongName( Mu $p ) {
		if self.assert-hash-keys( $p, [< name >], [< colonpair >] ) {
			self._Name( $p.hash.<name> )
		}
		else {
			say $p.hash.keys.gist;
			warn "Unhandled case"
		}
	}

	method _Max( Mu $p ) returns Str { $p.hash.<max>.Str }

	method _MetaChar( Mu $p ) {
say "MetaChar fired";
		if self.assert-hash-keys( $p, [< sym >] ) {
			self._Sym( $p.hash.<sym> )
		}
		elsif self.assert-hash-keys( $p, [< codeblock >] ) {
			self._CodeBlock( $p.hash.<codeblock> )
		}
		elsif self.assert-hash-keys( $p, [< backslash >] ) {
			self._BackSlash( $p.hash.<backslash> )
		}
		elsif self.assert-hash-keys( $p, [< assertion >] ) {
			self._Assertion( $p.hash.<assertion> )
		}
		elsif self.assert-hash-keys( $p, [< nibble >] ) {
			self._Nibble( $p.hash.<nibble> )
		}
		elsif self.assert-hash-keys( $p, [< quote >] ) {
			self._Quote( $p.hash.<quote> )
		}
		elsif self.assert-hash-keys( $p, [< nibbler >] ) {
			self._Nibbler( $p.hash.<nibbler> )
		}
		elsif self.assert-hash-keys( $p, [< statement >] ) {
			self._Statement( $p.hash.<statement> )
		}
		else {
			say $p.hash.keys.gist;
			warn "Unhandled case"
		}
	}

	method _MethodDef( Mu $p ) {
#`(
		if self.assert-hash-keys( $p,
			     [< specials longname blockoid multisig >],
			     [< trait >] );
)
		if self.assert-hash-keys( $p,
			     [< specials longname blockoid >],
			     [< trait >] ) {
			(
				self._LongName( $p.hash.<longname> ),
				self._Blockoid( $p.hash.<blockoid> )
			).flat
		}
		else {
			say $p.hash.keys.gist;
			warn "Unhandled case"
		}
	}

	method _MethodOp( Mu $p ) {
#`(
		if self.assert-hash-keys( $p, [< longname args >] );
)
		if self.assert-hash-keys( $p, [< variable >] ) {
			self._Variable( $p.hash.<variable> )
		}
		elsif self.assert-hash-keys( $p, [< longname >] ) {
			self._LongName( $p.hash.<longname> )
		}
		else {
			say $p.hash.keys.gist;
			warn "Unhandled case"
		}
	}

	method _Min( Mu $p ) {
		# _DecInt is a Str/Int leaf
		return True if self.assert-hash-keys( $p, [< decint VALUE >] );
	}

	method _ModifierExpr( Mu $p ) {
say "ModifierExpr fired";
		if self.assert-hash-keys( $p, [< EXPR >] ) {
			self._EXPR( $p.hash.<EXPR> )
		}
		else {
			say $p.hash.keys.gist;
			warn "Unhandled case"
		}
	}

	method _ModuleName( Mu $p ) {
say "ModuleName fired";
		if self.assert-hash-keys( $p, [< longname >] ) {
			self._LongName( $p.hash.<longname> )
		}
		else {
			say $p.hash.keys.gist;
			warn "Unhandled case"
		}
	}

	method _MoreName( Mu $p ) {
say "MoreName fired";
		for $p.list {
			next if self.assert-hash-keys( $_, [< identifier >] );
		}
	}

	method _MultiDeclarator( Mu $p ) {
#`(
		if self.assert-hash-keys( $p, [< sym routine_def >] );
		if self.assert-hash-keys( $p, [< sym declarator >] );
)
		if self.assert-hash-keys( $p, [< declarator >] ) {
			self._Declarator( $p.hash.<declarator> )
		}
		else {
			say $p.hash.keys.gist;
			warn "Unhandled case"
		}
	}

	method _MultiSig( Mu $p ) {
		if self.assert-hash-keys( $p, [< signature >] ) {
			self._Signature( $p.hash.<signature> )
		}
		else {
			say $p.hash.keys.gist;
			warn "Unhandled case"
		}
	}

	method _NamedParam( Mu $p ) {
		if self.assert-hash-keys( $p, [< param_var >] ) {
			self._ParamVar( $p.hash.<param_var> )
		}
		else {
			say $p.hash.keys.gist;
			warn "Unhandled case"
		}
	}

	method _Name( Mu $p ) {
#`(
		if self.assert-hash-keys( $p,
			[< param_var type_constraint quant >],
			[< default_value modifier trait post_constraint >] );
		if self.assert-hash-keys( $p, [< subshortname >] );
		if self.assert-hash-keys( $p, [< morename >] );
)
		if self.assert-hash-keys( $p,
			[< identifier >], [< morename >] ) {
			Perl6::Bareword.new(
				:from( $p.from ),
				:to( $p.to ),
				:content(
					$p.Str
				)
			)
		}
		elsif self.assert-hash-keys( $p, [< morename >] ) {
			Perl6::Bareword.new(
				:from( $p.from ),
				:to( $p.to ),
				:content(
					$p.Str
				)
			)
		}
		elsif self.assert-Str( $p ) {
			Perl6::Bareword.new(
				:from( $p.from ),
				:to( $p.to ),
				:content(
					$p.Str
				)
			)
		}
		else {
			say $p.hash.keys.gist;
			warn "Unhandled case"
		}
	}

	method _Nibble( Mu $p ) {
#`(
		if $p.Bool;
)
		if self.assert-hash-keys( $p, [< termseq >] ) {
			self._TermSeq( $p.hash.<termseq> )
		}
		else {
			say $p.hash.keys.gist;
			warn "Unhandled case"
		}
	}

	method _Nibbler( Mu $p ) {
say "Nibbler fired";
		if self.assert-hash-keys( $p, [< termseq >] ) {
			self._TermSeq( $p.hash.<termseq> )
		}
		else {
			say $p.hash.keys.gist;
			warn "Unhandled case"
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
			say $p.hash.keys.gist;
			warn "Unhandled case"
		}
	}

	method _Numish( Mu $p ) {
#`(
		if self.assert-Num( $p );
)

		if self.assert-hash-keys( $p, [< dec_number >] ) {
			self._DecNumber( $p.hash.<dec_number> )
		}
		elsif self.assert-hash-keys( $p, [< rad_number >] ) {
			self._RadNumber( $p.hash.<rad_number> )
		}
		elsif self.assert-hash-keys( $p, [< integer >] ) {
			self._Integer( $p.hash.<integer> )
		}
		else {
			say $p.hash.keys.gist;
			warn "Unhandled case"
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
			:from( $p.from ),
			:to( $p.to ),
			:content(
				$p.Str eq '0' ?? 0 !! $p.Int
			)
		)
	}

	method _Op( Mu $p ) {
say "Op fired";
#`(
		if self.assert-hash-keys( $p,
			     [< infix_prefix_meta_operator OPER >] );
		if self.assert-hash-keys( $p, [< infix OPER >] );
)
	}

	method _OPER( Mu $p ) {
#`(
		if self.assert-hash-keys( $p, [< sym infixish O >] );
		if self.assert-hash-keys( $p, [< sym O >] );
		if self.assert-hash-keys( $p, [< EXPR O >] );
		if self.assert-hash-keys( $p, [< semilist O >] );
		if self.assert-hash-keys( $p, [< nibble O >] );
		if self.assert-hash-keys( $p, [< arglist O >] );
		if self.assert-hash-keys( $p, [< dig O >] );;
		if self.assert-hash-keys( $p, [< O >] );
)
		if self.assert-hash-keys( $p, [< sym dottyop O >] ) {
			(
				Perl6::Operator::Infix.new(
					:from( $p.hash.<sym>.from ),
					:to( $p.hash.<sym>.to ),
					:content( $p.hash.<sym>.str )
				),
				self._DottyOp( $p.hash.<dottyop> )
			)
		}
		else {
			say $p.hash.keys.gist;
			warn "Unhandled case"
		}
	}

	method _PackageDeclarator( Mu $p ) {
		if self.assert-hash-keys( $p, [< sym package_def >] ) {
			(
				self._Sym( $p.hash.<sym> ),
				self._PackageDef( $p.hash.<package_def> ),
				self.semicolon-at-end( $p.hash.<package_def> )
			).flat
		}
		else {
			say $p.hash.keys.gist;
			warn "Unhandled case"
		}
	}

	method _PackageDef( Mu $p ) {
#`(
		if self.assert-hash-keys( $p, [< blockoid >], [< trait >] );
)
		if self.assert-hash-keys( $p,
				[< longname statementlist >], [< trait >] ) {
			(
				self._LongName( $p.hash.<longname> ),
				self._StatementList( $p.hash.<statementlist> )
			).flat
		}
		elsif self.assert-hash-keys( $p,
				[< blockoid longname >], [< trait >] ) {
			(
				self._LongName( $p.hash.<longname> ),
				self._Blockoid( $p.hash.<blockoid> )
			).flat
		}
		else {
			say $p.hash.keys.gist;
			warn "Unhandled case"
		}
	}

	method _Parameter( Mu $p ) {
		my @child;
		my $count = 0;
		for $p.list {
			if self.assert-hash-keys( $_,
				[< param_var type_constraint
				   quant post_constraint >],
				[< default_value modifier trait >] ) {
				# XXX
				@child.append(
					Perl6::Operator::Infix.new(
						:from( $_.to + 1 ),
						:to( $_.to + 2 ),
						:content( Q{,} )
					)
				) if $count++ > 0;
				@child.append(
					self._TypeConstraint(
						$_.hash.<type_constraint>
					)
				);
				@child.append(
					self._ParamVar( $_.hash.<param_var> )
				);
				@child.append(
					Perl6::Bareword.new(
						:from( -42 ),
						:to( -42 ),
						:content( Q{where} )
					)
				);
				@child.append(
					self._PostConstraint(
						$_.hash.<post_constraint>
					)
				);
			}
			elsif self.assert-hash-keys( $_,
				[< param_var type_constraint quant >],
				[< default_value modifier trait
				   post_constraint >] ) {
				# XXX
				@child.append(
					Perl6::Operator::Infix.new(
						:from( $_.to + 1 ),
						:to( $_.to + 2 ),
						:content( Q{,} )
					)
				) if $count++ > 0;
				@child.append(
					self._TypeConstraint(
						$_.hash.<type_constraint>
					)
				);
				@child.append(
					self._ParamVar( $_.hash.<param_var> )
				);
			}
			elsif self.assert-hash-keys( $_,
				[< param_var quant default_value >],
				[< modifier trait
				   type_constraint
				   post_constraint >] ) {
				# XXX
				@child.append(
					Perl6::Operator::Infix.new(
						:from( $_.to + 1 ),
						:to( $_.to + 2 ),
						:content( Q{,} )
					)
				) if $count++ > 0;
				@child.append(
					self._ParamVar( $_.hash.<param_var> )
				);
				@child.append(
					Perl6::Operator::Infix.new(
						:from( -42 ),
						:to( -42 ),
						:content( Q{=} )
					)
				);
				@child.append(
					self._DefaultValue(
						$_.hash.<default_value>
					).flat
				);
			}
			elsif self.assert-hash-keys( $_,
				[< param_var quant >],
				[< default_value modifier trait
				   type_constraint
				   post_constraint >] ) {
				# XXX
				@child.append(
					Perl6::Operator::Infix.new(
						:from( $_.to + 1 ),
						:to( $_.to + 2 ),
						:content( Q{,} )
					)
				) if $count++ > 0;
				@child.append(
					self._ParamVar( $_.hash.<param_var> )#,
#					self._Quant( $_.hash.<quant> )
				);
			}
			elsif self.assert-hash-keys( $_,
				[< named_param quant >],
				[< default_value type_constraint modifier
				   trait post_constraint >] ) {
				# XXX
				@child.append(
					Perl6::Operator::Infix.new(
						:from( $_.to + 1 ),
						:to( $_.to + 2 ),
						:content( Q{,} )
					)
				) if $count++ > 0;
				@child.append(
					Perl6::Operator::Infix.new(
						:from( -43 ),
						:to( -42 ),
						:content( Q{:} )
					),
					self._NamedParam(
						$_.hash.<named_param>
					)
				);
			}
			elsif self.assert-hash-keys( $_,
				[< type_constraint >],
				[< default_value modifier trait
				   post_constraint >] ) {
				@child.append(
					self._TypeConstraint(
						$_.hash.<type_constraint>
					)
				)
			}
			else {
				say $_.hash.keys.gist;
				warn "Unhandled case"
			}
		}
		@child
	}

	my %sigil-map = (
		'$' => Perl6::Variable::Scalar,
		'$*' => Perl6::Variable::Scalar::Dynamic,
		'$.' => Perl6::Variable::Scalar::Accessor,
		'$!' => Perl6::Variable::Scalar::Attribute,
		'$?' => Perl6::Variable::Scalar::CompileTime,
		'$<' => Perl6::Variable::Scalar::MatchIndex,
		'$^' => Perl6::Variable::Scalar::Positional,
		'$:' => Perl6::Variable::Scalar::Named,
		'$=' => Perl6::Variable::Scalar::Pod,
		'$~' => Perl6::Variable::Scalar::SubLanguage,
		'%' => Perl6::Variable::Hash,
		'%*' => Perl6::Variable::Hash::Dynamic,
		'%.' => Perl6::Variable::Hash::Accessor,
		'%!' => Perl6::Variable::Hash::Attribute,
		'%?' => Perl6::Variable::Hash::CompileTime,
		'%<' => Perl6::Variable::Hash::MatchIndex,
		'%^' => Perl6::Variable::Hash::Positional,
		'%:' => Perl6::Variable::Hash::Named,
		'%=' => Perl6::Variable::Hash::Pod,
		'%~' => Perl6::Variable::Hash::SubLanguage,
		'@' => Perl6::Variable::Array,
		'@*' => Perl6::Variable::Array::Dynamic,
		'@.' => Perl6::Variable::Array::Accessor,
		'@!' => Perl6::Variable::Array::Attribute,
		'@?' => Perl6::Variable::Array::CompileTime,
		'@<' => Perl6::Variable::Array::MatchIndex,
		'@^' => Perl6::Variable::Array::Positional,
		'@:' => Perl6::Variable::Array::Named,
		'@=' => Perl6::Variable::Array::Pod,
		'@~' => Perl6::Variable::Array::SubLanguage,
		'&' => Perl6::Variable::Callable,
		'&*' => Perl6::Variable::Callable::Dynamic,
		'&.' => Perl6::Variable::Callable::Accessor,
		'&!' => Perl6::Variable::Callable::Attribute,
		'&?' => Perl6::Variable::Callable::CompileTime,
		'&<' => Perl6::Variable::Callable::MatchIndex,
		'&^' => Perl6::Variable::Callable::Positional,
		'&:' => Perl6::Variable::Callable::Named,
		'&=' => Perl6::Variable::Callable::Pod,
		'&~' => Perl6::Variable::Callable::SubLanguage,
	);

	method _ParamVar( Mu $p ) {
#`(
		if self.assert-hash-keys( $p, [< name sigil >] );
		if self.assert-hash-keys( $p, [< signature >] ) {
			self._Signature( $p.hash.<signature> )
		}
		elsif self.assert-hash-keys( $p, [< sigil >] ) {
			self._Sigil( $p.hash.<sigil> )
		}
)
		if self.assert-hash-keys( $p, [< name twigil sigil >] ) {
			# XXX refactor back to a method
			my $sigil       = $p.hash.<sigil>.Str;
			my $twigil      = $p.hash.<twigil> ??
					  $p.hash.<twigil>.Str !! '';
			my $desigilname = $p.hash.<name> ??
					  $p.hash.<name>.Str !! '';
			my $content     = $p.hash.<sigil> ~
					  $twigil ~
					  $desigilname;

			my $leaf = %sigil-map{$sigil ~ $twigil}.new(
				:from( $p.from ),
				:to( $p.to ),
				:content( $content )
			);
			$leaf
		}
		elsif self.assert-hash-keys( $p, [< name sigil >] ) {
			# XXX refactor back to a method
			my $sigil       = $p.hash.<sigil>.Str;
			my $twigil      = $p.hash.<twigil> ??
					  $p.hash.<twigil>.Str !! '';
			my $desigilname = $p.hash.<name> ??
					  $p.hash.<name>.Str !! '';
			my $content     = $p.hash.<sigil> ~
					  $twigil ~
					  $desigilname;

			my $leaf = %sigil-map{$sigil ~ $twigil}.new(
				:from( $p.from ),
				:to( $p.to ),
				:content( $content )
			);
			$leaf
		}
		else {
			say $p.hash.keys.gist;
			warn "Unhandled case"
		}
	}

	method _PBlock( Mu $p ) {
#`(
		if self.assert-hash-keys( $p, [< lambda blockoid signature >] );
)
		if self.assert-hash-keys( $p, [< blockoid >] ) {
			self._Blockoid( $p.hash.<blockoid> )
		}
		else {
			say $p.hash.keys.gist;
			warn "Unhandled case"
		}
	}

	method _PostCircumfix( Mu $p ) {
#`(
		return True if self.assert-hash-keys( $p, [< arglist O >] );
)
		if self.assert-hash-keys( $p, [< semilist O >] ) {
			my $x = $p.hash.<semilist>.Str;
			$x ~~ s{ ^ \s+ } = '';
			$x ~~ s{ \s+ $ } = '';
			Perl6::Bareword.new(
				:from( $p.hash.<semilist>.from ),
				:to( $p.hash.<semilist>.to ),
				:content( $x )
			)
		}
		elsif self.assert-hash-keys( $p, [< nibble O >] ) {
			my $x = $p.hash.<nibble>.Str;
			$x ~~ s{ ^ \s+ } = '';
			$x ~~ s{ \s+ $ } = '';
			Perl6::Bareword.new(
				:from( $p.hash.<nibble>.from ),
				:to( $p.hash.<nibble>.to ),
				:content( $x )
			)
		}
		else {
			say $p.hash.keys.gist;
			warn "Unhandled case"
		}
	}

	method _PostConstraint( Mu $p ) {
		# XXX fix later
		self._EXPR( $p.list.[0].hash.<EXPR> )
	}

	method _Postfix( Mu $p ) {
#`(
		if self.assert-hash-keys( $p, [< dig O >] );
)
		if self.assert-hash-keys( $p, [< sym O >] ) {
			Perl6::Operator::Infix.new(
				:from( $p.hash.<sym>.from ),
				:to( $p.hash.<sym>.to ),
				:content( $p.hash.<sym>.Str )
			)
		}
		else {
			say $p.hash.keys.gist;
			warn "Unhandled case"
		}
	}

	method _PostOp( Mu $p ) {
say "PostOp fired";
		return True if self.assert-hash-keys( $p,
				[< sym postcircumfix O >] );
		return True if self.assert-hash-keys( $p,
				[< sym postcircumfix >], [< O >] );
	}

	method _Prefix( Mu $p ) {
		if self.assert-hash-keys( $p, [< sym O >] ) {
			Perl6::Operator::Prefix.new(
				:from( $p.hash.<sym>.from ),
				:to( $p.hash.<sym>.to ),
				:content( $p.hash.<sym>.Str )
			)
		}
		else {
			say $p.hash.keys.gist;
			warn "Unhandled case"
		}
	}

	method _Quant( Mu $p ) returns Bool { $p.hash.<quant>.Bool }

	method _QuantifiedAtom( Mu $p ) {
say "QuantifiedAtom fired";
#`(
		if self.assert-hash-keys( $p, [< sigfinal atom >] );
)
	}

	method _Quantifier( Mu $p ) {
say "Quantifier fired";
#`(
		if self.assert-hash-keys( $p, [< sym min max backmod >] );
		if self.assert-hash-keys( $p, [< sym backmod >] );
)
	}

	method _Quibble( Mu $p ) {
say "Quibble fired";
#`(
		if self.assert-hash-keys( $p, [< babble nibble >] );
)
	}

	method _Quote( Mu $p ) {
#`(
		if self.assert-hash-keys( $p, [< sym quibble rx_adverbs >] );
		if self.assert-hash-keys( $p, [< sym rx_adverbs sibble >] );
)
		if self.assert-hash-keys( $p, [< quibble >] ) {
			Perl6::String.new(
				:from( $p.from ),
				:to( $p.to ),
				:content( $p.Str ),
				:bare( $p.hash.<quibble>.Str )
			)
		}
		elsif self.assert-hash-keys( $p, [< nibble >] ) {
			Perl6::String.new(
				:from( $p.from ),
				:to( $p.to ),
				:content( $p.Str ),
				:bare( $p.hash.<nibble>.Str )
			)
		}
		else {
			say $p.hash.keys.gist;
			warn "Unhandled case"
		}
	}

	method _QuotePair( Mu $p ) {
say "QuotePair fired";
#`(
		for $p.list {
			next if self.assert-hash-keys( $_, [< identifier >] );
		}
		return True if self.assert-hash-keys( $p,
				[< circumfix bracket radix >], [< exp base >] );
)
		if self.assert-hash-keys( $p, [< identifier >] ) {
			self._Identifier( $p.hash.<identifier> )
		}
		else {
			say $p.hash.keys.gist;
			warn "Unhandled case"
		}
	}

	method _Radix( Mu $p ) returns Int { $p.hash.<radix>.Int }

	method _RadNumber( Mu $p ) {
		if self.assert-hash-keys( $p,
				[< circumfix bracket radix >],
				[< exp base >] ) {
			Perl6::Number::Radix.new(
				:from( $p.from ),
				:to( $p.to ),
				:content( $p.Str )
			)
		}
		elsif self.assert-hash-keys( $p,
				[< circumfix radix >], [< exp base >] ) {
			Perl6::Number::Radix.new(
				:from( $p.from ),
				:to( $p.to ),
				:content( $p.Str )
			)
		}
		else {
			say $p.hash.keys.gist;
			warn "Unhandled case"
		}
	}

	method _RegexDeclarator( Mu $p ) {
		if self.assert-hash-keys( $p, [< sym regex_def >] ) {
			(
				self._Sym( $p.hash.<sym> ),
				self._RegexDef( $p.hash.<regex_def> )
			).flat
		}
		else {
			say $p.hash.keys.gist;
			warn "Unhandled case"
		}
	}

	method _RegexDef( Mu $p ) {
		if self.assert-hash-keys( $p,
				[< deflongname nibble >],
				[< signature trait >] ) {
			(
				self._DefLongName( $p.hash.<deflongname> ),
				Perl6::Block.new(
					:delimiter( '{', '}' ),
					:child(
						self._Nibble( $p.hash.<nibble> )
					)
				)
			).flat
		}
		else {
			say $p.hash.keys.gist;
			warn "Unhandled case"
		}
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
		if self.assert-hash-keys( $p,
				[< sym routine_def >] ) {
			(
				self._Sym( $p.hash.<sym> ),
				self._RoutineDef( $p.hash.<routine_def> )
			).flat
		}
		elsif self.assert-hash-keys( $p, [< sym method_def >] ) {
			(
				self._Sym( $p.hash.<sym> ),
				self._MethodDef( $p.hash.<method_def> )
			).flat
		}
		else {
			say $p.hash.keys.gist;
			warn "Unhandled case"
		}
	}

	method _RoutineDef( Mu $p ) {
#`(
		if self.assert-hash-keys( $p,
				[< blockoid multisig >],
				[< trait >] );
		if self.assert-hash-keys( $p, [< blockoid >], [< trait >] );
)
		if self.assert-hash-keys( $p,
				[< blockoid deflongname multisig >],
				[< trait >] ) {
			(
				self._DefLongName( $p.hash.<deflongname> ),
				self._MultiSig( $p.hash.<multisig> ),
				self._Blockoid( $p.hash.<blockoid> )
			).flat
		}
		elsif self.assert-hash-keys( $p,
				[< blockoid deflongname trait >] ) {
			(
				self._DefLongName( $p.hash.<deflongname> ),
				self._Trait( $p.hash.<trait> ),
				self._Blockoid( $p.hash.<blockoid> )
			).flat
		}
		elsif self.assert-hash-keys( $p,
				[< blockoid deflongname >], [< trait >] ) {
			(
				self._DefLongName( $p.hash.<deflongname> ),
				self._Blockoid( $p.hash.<blockoid> )
			).flat
		}
		else {
			say $p.hash.keys.gist;
			warn "Unhandled case"
		}
	}

	method _RxAdverbs( Mu $p ) {
say "RxAdverbs fired";
#`(
		if self.assert-hash-keys( $p, [< quotepair >] );
		if self.assert-hash-keys( $p, [], [< quotepair >] );
)
	}

	method _Scoped( Mu $p ) {
		# XXX DECL seems to be a mirror of declarator. This probably
		# XXX will turn out to be not true later on.
		#
		if self.assert-hash-keys( $p,
					[< multi_declarator DECL typename >] ) {
			(
				self._TypeName( $p.hash.<typename> ),
				self._MultiDeclarator(
					$p.hash.<multi_declarator>
				)
			)
		}
		elsif self.assert-hash-keys( $p,
				[< package_declarator DECL >],
				[< typename >] ) {
			self._PackageDeclarator( $p.hash.<package_declarator> )
		}
		elsif self.assert-hash-keys( $p,
				[< package_declarator sym >] ) {
			(
				self._Sym( $p.hash.<sym> ),
				self._PackageDeclarator(
					$p.hash.<package_declarator>
				)
			)
		}
		elsif self.assert-hash-keys( $p,
				[< declarator DECL >], [< typename >] ) {
			self._Declarator( $p.hash.<declarator> )
		}
		else {
			say $p.hash.keys.gist;
			warn "Unhandled case"
		}
	}

	method _ScopeDeclarator( Mu $p ) {
		if self.assert-hash-keys( $p, [< sym scoped >] ) {
			(
				self._Sym( $p.hash.<sym> ),
				self._Scoped( $p.hash.<scoped> )
			).flat
		}
		else {
			say $p.hash.keys.gist;
			warn "Unhandled case"
		}
	}

	method _SemiArgList( Mu $p ) {
say "SemiArgList fired";
#`(
		if self.assert-hash-keys( $p, [< arglist >] ) {
			self._ArgList( $p.hash.<arglist> )
		}
)
	}

	method _SemiList( Mu $p ) {
		CATCH {
			when X::Multi::NoMatch { }
		}
#`(
		for $p.list {
			next if self.assert-hash-keys( $_, [< statement >] );
		}
		return True if self.assert-hash-keys( $p, [ ],
			[< statement >] );
);
		if $p.hash.<statement>.list.[0].hash.<EXPR> {
			$p.Str ~~ m{ ^ (.) }; my $front = ~$0;
			$p.Str ~~ m{ (.) $ }; my $back = ~$0;
			Perl6::Operator::PostCircumfix.new(
				:delimiter( $front, $back ),
				:child(
self._EXPR( $p.hash.<statement>.list.[0].hash.<EXPR> )
				)
			)
		}
		if self.assert-hash-keys( $p, [< statement >] ) {
			self._EXPR( $p.hash.<statement>.list.[0].<EXPR> )
		}
		else {
			say $p.hash.keys.gist;
			warn "Unhandled case"
		}
	}

	method _Separator( Mu $p ) {
say "Separator fired";
#`(
		if self.assert-hash-keys( $p, [< septype quantified_atom >] );
)
	}

	method _SepType( Mu $p ) returns Str { $p.hash.<septype>.Str }

	method _Shape( Mu $p ) returns Str { $p.hash.<shape>.Str }

	method _Sibble( Mu $p ) {
say "Sibble fired";
#`(
		if self.assert-hash-keys( $p, [< right babble left >] );
)
	}

	method _SigFinal( Mu $p ) {
say "SigFinal fired";
#`(
		if self.assert-hash-keys( $p, [< normspace >] ) {
			self._NormSpace( $p.hash.<normspace> )
		}
)
	}

	method _Sigil( Mu $p ) returns Str { $p.hash.<sym>.Str }

	method _SigMaybe( Mu $p ) {
say "SigMaybe fired";
#`(
		if self.assert-hash-keys( $p,
				[< parameter typename >],
				[< param_sep >] );
		if self.assert-hash-keys( $p, [], [< param_sep parameter >] );
)
	}

	method _Signature( Mu $p ) {
#`(
		return True if self.assert-hash-keys( $p,
				[< parameter typename >],
				[< param_sep >] );
)
		if self.assert-hash-keys( $p,
				[< parameter >],
				[< param_sep >] ) {
			Perl6::Operator::Circumfix.new(
				:delimiter( '(', ')' ),
				:child(
					self._Parameter( $p.hash.<parameter> )
				)
			)
		}
		elsif self.assert-hash-keys( $p,
				[< param_sep >],
				[< parameter >] ) {
			Perl6::Operator::Circumfix.new(
				:delimiter( '(', ')' ),
				:child(
					self._Parameter( $p.hash.<parameter> )
				)
			)
		}
		elsif self.assert-hash-keys( $p, [< >],
				[< param_sep parameter >] ) {
			Perl6::Operator::Circumfix.new(
				:delimiter( '(', ')' ),
				:child( )
			)
		}
		else {
			say $p.hash.keys.gist;
			warn "Unhandled case"
		}
	}

	method _SMExpr( Mu $p ) {
say "SMExpr fired";
		if self.assert-hash-keys( $p, [< EXPR >] ) {
			self._EXPR( $p.hash.<EXPR> )
		}
		else {
			say $p.hash.keys.gist;
			warn "Unhandled case"
		}
	}

	method _Specials( Mu $p ) returns Bool { $p.hash.<specials>.Bool }

	method _StatementControl( Mu $p ) {
say "StatementControl fired";
#`(
		if self.assert-hash-keys( $p, [< block sym e1 e2 e3 >] );
		if self.assert-hash-keys( $p, [< pblock sym EXPR wu >] );
		if self.assert-hash-keys( $p, [< doc sym module_name >] );
		if self.assert-hash-keys( $p, [< doc sym version >] );
		if self.assert-hash-keys( $p, [< sym else xblock >] );
		if self.assert-hash-keys( $p, [< xblock sym wu >] );
		if self.assert-hash-keys( $p, [< sym xblock >] );
		if self.assert-hash-keys( $p, [< block sym >] );
)
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
				self._EXPR( $_.hash.<EXPR> )
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
			self._StatementControl( $p.hash.<statement_control> )
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
#`(
		if self.assert-hash-keys( $p, [< sym modifier_expr >] );
)
	}

	method _StatementModLoop( Mu $p ) {
say "StatementModLoop fired";
#`(
		if self.assert-hash-keys( $p, [< sym smexpr >] )
)
	}

	method _StatementPrefix( Mu $p ) {
say "StatementPrefix fired";
#`(
		if self.assert-hash-keys( $p, [< sym blorst >] );
)
	}

	method _SubShortName( Mu $p ) {
say "SubShortName fired";
		if self.assert-hash-keys( $p, [< desigilname >] ) {
			self._DeSigilName( $p.hash.<desigilname> )
		}
		else {
			say $p.hash.keys.gist;
			warn "Unhandled case"
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
				:from( $p.from ),
				:to( $p.to ),
				:content(
					$p.Str
				)
			)
		}
		else {
			say $p.hash.keys.gist;
			warn "Unhandled case"
		}
	}

	method _Term( Mu $p ) {
say "Term fired";
		if self.assert-hash-keys( $p, [< methodop >] ) {
			self._MethodOp( $p.hash.<methodop> )
		}
		else {
			say $p.hash.keys.gist;
			warn "Unhandled case"
		}
	}

	method _TermAlt( Mu $p ) {
say "TermAlt fired";
		for $p.list {
			next if self.assert-hash-keys( $_, [< termconj >] );
		}
	}

	method _TermAltSeq( Mu $p ) {
		if self.assert-hash-keys( $p, [< termconjseq >] ) {
			self._TermConjSeq( $p.hash.<termconjseq> )
		}
		else {
			say $p.hash.keys.gist;
			warn "Unhandled case"
		}
	}

	method _TermConj( Mu $p ) {
say "TermConj fired";
		for $p.list {
			next if self.assert-hash-keys( $_, [< termish >] );
		}
	}

	method _TermConjSeq( Mu $p ) {
		# XXX Work on this later.
#`(
		for $p.list {
			next if self.assert-hash-keys( $_, [< termalt >] );
		}
		if self.assert-hash-keys( $p, [< termalt >] ) {
			self._TermAlt( $p.hash.<termalt> )
		}
		else {
			say $p.hash.keys.gist;
			warn "Unhandled case"
		}
)
		# XXX
		my $str = $p.Str;
		$str ~~ s{\s+ $} = '';
		Perl6::Bareword.new(
			:from( $p.from ),
			:to( $p.to ),
			:content( $str )
		)
	}

	method _TermInit( Mu $p ) {
say "TermInit fired";
#`(
		if self.assert-hash-keys( $p, [< sym EXPR >] );
)
	}

	method _Termish( Mu $p ) {
say "Termish fired";
		for $p.list {
			next if self.assert-hash-keys( $_, [< noun >] );
		}
		if self.assert-hash-keys( $p, [< noun >] ) {
			self._Noun( $p.hash.<noun> )
		}
		else {
			say $p.hash.keys.gist;
			warn "Unhandled case"
		}
	}

	method _TermSeq( Mu $p ) {
		if self.assert-hash-keys( $p, [< termaltseq >] ) {
			self._TermAltSeq( $p.hash.<termaltseq> )
		}
		else {
			say $p.hash.keys.gist;
			warn "Unhandled case"
		}
	}

	method _Trait( Mu $p ) {
		# XXX Sigh, something else to fix.
#`(
		my @child = map {
#			if self.assert-hash-keys( $_, [< trait_mod >] ) {
				self._TraitMod( $_.hash.<trait_mod> )
#			}
#			else {
#				say $_.hash.keys.gist;
#				warn "Unhandled case"
#			}
		}, $p.list;
		@child
)
		self._TraitMod( $p.list.[0].hash.<trait_mod> )
	}

	method _TraitMod( Mu $p ) {
		if self.assert-hash-keys( $p, [< sym typename >] ) {
			(
				self._Sym( $p.hash.<sym> ),
				self._TypeName( $p.hash.<typename> )
			).flat
		}
		else {
			say $p.hash.keys.gist;
			warn "Unhandled case"
		}
	}

	method _Twigil( Mu $p ) returns Str { $p.hash.<sym>.Str }

	method _TypeConstraint( Mu $p ) {
		my @child;
		for $p.list {
			if self.assert-hash-keys( $_, [< typename >] ) {
				@child.append(
					self._TypeName( $_.hash.<typename> )
				)
			}
			elsif self.assert-hash-keys( $_, [< value >] ) {
				@child.append(
					self._Value( $_.hash.<value> )
				)
			}
			else {
				say $p.hash.keys.gist;
				warn "Unhandled case"
			}
		}
#		if self.assert-hash-keys( $p, [< value >] ) {
#			self._Value( $p.hash.<value> )
#		}
#		elsif self.assert-hash-keys( $p, [< typename >] ) {
#			self._TypeName( $p.hash.<typename> )
#		}
#		else {
#			say $p.hash.keys.gist;
#			warn "Unhandled case"
#		}
		@child
	}

	method _TypeDeclarator( Mu $p ) {
say "TypeDeclarator fired";
#`(
		if self.assert-hash-keys( $p,
				[< sym initializer variable >], [< trait >] );
		if self.assert-hash-keys( $p,
				[< sym initializer defterm >], [< trait >] );
		if self.assert-hash-keys( $p, [< sym initializer >] );
)
	}

	method _TypeName( Mu $p ) {
		CATCH { when X::Hash::Store::OddNumber { .resume } } # XXX ?...
		for $p.list {
			if self.assert-hash-keys( $_,
					[< longname colonpairs >],
					[< colonpair >] ) {
				# XXX Fix this later.
				return
					Perl6::Bareword.new(
						:from( -42 ),
						:to( -42 ),
						:content( $_.Str )
					)
			}
			elsif self.assert-hash-keys( $_,
					[< longname colonpair >] ) {
				# XXX Fix this later.
				return
					Perl6::Bareword.new(
						:from( -42 ),
						:top( -42 ),
						:content( $_.Str )
					)
			}
			elsif self.assert-hash-keys( $_,
					[< longname >], [< colonpairs >] ) {
				# XXX Fix this later.
				return
					Perl6::Bareword.new(
						:from( -42 ),
						:to( -42 ),
						:content( $_.Str )
					)
			}
			elsif self.assert-hash-keys( $_,
					[< longname >], [< colonpair >] ) {
				# XXX Fix this later.
				return
					self._LongName( $_.hash.<longname> )
			}
			else {
				say $_.hash.keys.gist;
				warn "Unhandled case"
			}
		}

		if self.assert-hash-keys( $p, [< longname colonpairs >] ) {
			self._LongName( $p.hash.<longname> )
		}
		elsif self.assert-hash-keys( $p,
				[< longname >], [< colonpair >] ) {
			self._LongName( $p.hash.<longname> )
		}
		else {
			say $p.hash.keys.gist;
			warn "Unhandled case"
		}
	}

	method _Val( Mu $p ) {
#`(
		return True if self.assert-hash-keys( $p,
				[< prefix OPER >],
				[< prefix_postfix_meta_operator >] );
)
		if self.assert-hash-keys( $p, [< value >] ) {
			self._Value( $p.hash.<value> )
		}
		else {
			say $p.hash.keys.gist;
			warn "Unhandled case"
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
		else {
			say $p.hash.keys.gist;
			warn "Unhandled case"
		}
	}

	method _Var( Mu $p ) {
		if self.assert-hash-keys( $p,
				[< sigil desigilname >] ) {
			# XXX For heavens' sake refactor.
			my $sigil       = $p.hash.<sigil>.Str;
			my $twigil      = $p.hash.<twigil> ??
					  $p.hash.<twigil>.Str !! '';
			my $desigilname = $p.hash.<desigilname> ??
					  $p.hash.<desigilname>.Str !! '';
			my $content     = $p.hash.<sigil> ~ $twigil ~ $desigilname;
			%sigil-map{$sigil ~ $twigil}.new(
				:from( $p.from ),
				:to( $p.to ),
				:content( $content )
			)
		}
		elsif self.assert-hash-keys( $p, [< variable >] ) {
			self._Variable( $p.hash.<variable> )
		}
		else {
			say $p.hash.keys.gist;
			warn "Unhandled case"
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
				[< variable post_constraint >],
				[< semilist postcircumfix signature trait >] ) {
			(
				self._Variable( $p.hash.<variable> ),
				Perl6::Bareword.new(
					:from( -42 ),
					:to( -42 ),
					:content( Q{where} )
				),
				self._PostConstraint(
					$p.hash.<post_constraint>
				)
			)
		}
		elsif self.assert-hash-keys( $p,
				[< variable >],
				[< semilist postcircumfix signature
				   trait post_constraint >] ) {
			self._Variable( $p.hash.<variable> )
		}
		else {
			say $p.hash.keys.gist;
			warn "Unhandled case"
		}
	}

	method _Variable( Mu $p ) {

		if self.assert-hash-keys( $p, [< contextualizer >] ) {
			return;
		}

		my $sigil       = $p.hash.<sigil>.Str;
		my $twigil      = $p.hash.<twigil> ??
			          $p.hash.<twigil>.Str !! '';
		my $desigilname = $p.hash.<desigilname> ??
				  $p.hash.<desigilname>.Str !! '';
		my $content     = $p.hash.<sigil> ~ $twigil ~ $desigilname;
		my $leaf = %sigil-map{$sigil ~ $twigil}.new(
			:from( $p.from ),
			:to( $p.to ),
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
		}
		else {
			say $p.hash.keys.gist;
			warn "Unhandled case"
		}
	}
}
