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

(a side note - These really should be L<Perl6::Variable::Scalar:Contextualizer::>, but that would mean that these were both a Leaf (from the parent L<Perl6::Variable::Scalar> and Branching because they have children). Resolving this would mean removing the L<Perl6::Leaf> role from the L<Perl6::Variable::Scalar> class, which means that I either have to create a longer class name for L<Perl6::Variable::JustAPlainScalarVariable> or manually add the L<Perl6::Leaf>'s contents to the L<Perl6::Variable::Scalar>, and forget to update it when I change my mind in a few weeks' time about what L<Perl6::Leaf> does. Adding a separate class for this seems the lesser of two evils, especially given how often they'll appear in "real world" code.)

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

role Child {
	has Perl6::Element @.child;
}
role Delimited {
	has Str @.delimiter is required;
}

# XXX There should be a better way to do this.
# XXX I could use wrap() probably...
#
role Branching does Child {
	method perl6( $f ) {
		join( '', map { $_.perl6( $f ) }, @.child )
	}
}
role Branching_Delimited does Child does Delimited {
	method perl6( $f ) {
		@.delimiter.[0] ~
		join( '', map { $_.perl6( $f ) }, @.child ) ~
		@.delimiter.[1]
	}
}

role Token {
	has Str $.content is required;
	has Int $.from is required;
	has Int $.to is required;
	method perl6( $f ) {
		~$.content
	}
}


class Perl6::Unimplemented {
	has $.content
}

class Perl6::WS does Token {
	also is Perl6::Element;
}

class Perl6::Document does Branching {
}

class Perl6::Statement does Branching {
	also is Perl6::Element;
}

role Prefixed {
	has Str $.headless is required;
}

# And now for the most basic tokens...
#
class Perl6::Number does Token {
	also is Perl6::Element;
}
class Perl6::Number::Binary does Prefixed {
	also is Perl6::Number;
}
class Perl6::Number::Octal does Prefixed {
	also is Perl6::Number;
}
class Perl6::Number::Decimal {
	also is Perl6::Number;
}
class Perl6::Number::Decimal::Explicit does Prefixed {
	also is Perl6::Number::Decimal;
}
class Perl6::Number::Hexadecimal does Prefixed {
	also is Perl6::Number;
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

# XXX Needs work
class Perl6::Regex does Token {
	also is Perl6::Element;
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
# So they're only generated in the _statement handler.
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
	has Str $.sigil = Q{$};
}
class Perl6::Variable::Scalar::Dynamic {
	also is Perl6::Variable::Scalar;
	has Str $.twigil = Q{*};
}
class Perl6::Variable::Scalar::Attribute {
	also is Perl6::Variable::Scalar;
	has Str $.twigil = Q{!};
}
class Perl6::Variable::Scalar::Accessor {
	also is Perl6::Variable::Scalar;
	has Str $.twigil = Q{.};
}
class Perl6::Variable::Scalar::CompileTime {
	also is Perl6::Variable::Scalar;
	has Str $.twigil = Q{?};
}
class Perl6::Variable::Scalar::MatchIndex {
	also is Perl6::Variable::Scalar;
	has Str $.twigil = Q{<};
}
class Perl6::Variable::Scalar::Positional {
	also is Perl6::Variable::Scalar;
	has Str $.twigil = Q{^};
}
class Perl6::Variable::Scalar::Named {
	also is Perl6::Variable::Scalar;
	has Str $.twigil = Q{:};
}
class Perl6::Variable::Scalar::Pod {
	also is Perl6::Variable::Scalar;
	has Str $.twigil = Q{=};
}
class Perl6::Variable::Scalar::SubLanguage {
	also is Perl6::Variable::Scalar;
	has Str $.twigil = Q{~};
}
class Perl6::Variable::Array does Token {
	also is Perl6::Variable;
	has Str $.sigil = Q{@};
}
class Perl6::Variable::Array::Dynamic {
	also is Perl6::Variable::Array;
	has Str $.twigil = Q{*};
}
class Perl6::Variable::Array::Attribute {
	also is Perl6::Variable::Array;
	has Str $.twigil = Q{!};
}
class Perl6::Variable::Array::Accessor {
	also is Perl6::Variable::Array;
	has Str $.twigil = Q{.};
}
class Perl6::Variable::Array::CompileTime {
	also is Perl6::Variable::Array;
	has Str $.twigil = Q{?};
}
class Perl6::Variable::Array::MatchIndex {
	also is Perl6::Variable::Array;
	has Str $.twigil = Q{<};
}
class Perl6::Variable::Array::Positional {
	also is Perl6::Variable::Array;
	has Str $.twigil = Q{^};
}
class Perl6::Variable::Array::Named {
	also is Perl6::Variable::Array;
	has Str $.twigil = Q{:};
}
class Perl6::Variable::Array::Pod {
	also is Perl6::Variable::Array;
	has Str $.twigil = Q{=};
}
class Perl6::Variable::Array::SubLanguage {
	also is Perl6::Variable::Array;
	has Str $.twigil = Q{~};
}
class Perl6::Variable::Hash does Token {
	also is Perl6::Variable;
	has Str $.sigil = Q{%};
}
class Perl6::Variable::Hash::Dynamic {
	also is Perl6::Variable::Hash;
	has Str $.twigil = Q{*};
}
class Perl6::Variable::Hash::Attribute {
	also is Perl6::Variable::Hash;
	has Str $.twigil = Q{!};
}
class Perl6::Variable::Hash::Accessor {
	also is Perl6::Variable::Hash;
	has Str $.twigil = Q{.};
}
class Perl6::Variable::Hash::CompileTime {
	also is Perl6::Variable::Hash;
	has Str $.twigil = Q{?};
}
class Perl6::Variable::Hash::MatchIndex {
	also is Perl6::Variable::Hash;
	has Str $.twigil = Q{<};
}
class Perl6::Variable::Hash::Positional {
	also is Perl6::Variable::Hash;
	has Str $.twigil = Q{^};
}
class Perl6::Variable::Hash::Named {
	also is Perl6::Variable::Hash;
	has Str $.twigil = Q{:};
}
class Perl6::Variable::Hash::Pod {
	also is Perl6::Variable::Hash;
	has Str $.twigil = Q{=};
}
class Perl6::Variable::Hash::SubLanguage {
	also is Perl6::Variable::Hash;
	has Str $.twigil = Q{~};
}
class Perl6::Variable::Callable does Token {
	also is Perl6::Variable;
	has Str $.sigil = Q{&};
}
class Perl6::Variable::Callable::Dynamic {
	also is Perl6::Variable::Callable;
	has Str $.twigil = Q{*};
}
class Perl6::Variable::Callable::Attribute {
	also is Perl6::Variable::Callable;
	has Str $.twigil = Q{!};
}
class Perl6::Variable::Callable::Accessor {
	also is Perl6::Variable::Callable;
	has Str $.twigil = Q{.};
}
class Perl6::Variable::Callable::CompileTime {
	also is Perl6::Variable::Callable;
	has Str $.twigil = Q{?};
}
class Perl6::Variable::Callable::MatchIndex {
	also is Perl6::Variable::Callable;
	has Str $.twigil = Q{<};
}
class Perl6::Variable::Callable::Positional {
	also is Perl6::Variable::Callable;
	has Str $.twigil = Q{^};
}
class Perl6::Variable::Callable::Named {
	also is Perl6::Variable::Callable;
	has Str $.twigil = Q{:};
}
class Perl6::Variable::Callable::Pod {
	also is Perl6::Variable::Callable;
	has Str $.twigil = Q{=};
}
class Perl6::Variable::Callable::SubLanguage {
	also is Perl6::Variable::Callable;
	has Str $.twigil = Q{~};
}

class Perl6::Tidy::Factory {

	method build( Mu $p ) {
		my Perl6::Element @child =
			self._statementlist( $p.hash.<statementlist> );
		Perl6::Document.new(
			:child( @child )
		)
	}

	multi method make-prefix-from( Mu $p ) {
		Perl6::Operator::Prefix.new(
			:from( $p.from ),
			:to( $p.to ),
			:content( $p.Str )
		)
	}

	multi method make-infix-from( Mu $p ) {
		Perl6::Operator::Infix.new(
			:from( $p.from ),
			:to( $p.to ),
			:content( $p.Str )
		)
	}

	multi method make-infix-from( Mu $p, Str $token ) {
		$p.Str ~~ m{ ($token) };
		my ( $offset ) = $0.from;
		Perl6::Operator::Infix.new(
			:from( $p.from + $offset ),
			:to( $p.from + $offset + 2 ),
			:content( $token )
		)
	}

	method make-postcircumfix( Mu $p, @child ) {
		$p.Str ~~ m{ ^ (.) }; my $front = ~$0;
		$p.Str ~~ m{ (.) $ }; my $back = ~$0;
		Perl6::Operator::PostCircumfix.new(
			# XXX What is it "post"? Hmm.
			:delimiter( $front, $back ),
			:child( @child )
		)
	}

	method make-circumfix( Mu $p, @child ) {
		$p.Str ~~ m{ ^ (.) }; my $front = ~$0;
		$p.Str ~~ m{ (.) $ }; my $back = ~$0;
		Perl6::Operator::Circumfix.new(
			:delimiter( $front, $back ),
			:child( @child )
		)
	}

	method make-whitespace( Str $orig, Int $from, Int $to ) {
		Perl6::WS.new(
			:from( $from ),
			:to( $to ),
			:content(
				substr( $orig, $from, $to - $from )
			)
		)
	}

	method populate-whitespace( Str $orig, Int $from, Int $to, @child ) {
		my Perl6::Element @ws;
		my $start = $from;
		my $end = $to;

		for @child {
			if $start < $_.from {
				@ws.push(
					self.make-whitespace(
						$orig, $start, $_.from
					)
				)
			}
			$start = $_.to;
			@ws.push( $_ )
		}
		if $start < $end {
			@ws.push(
				self.make-whitespace(
					$orig, $start, $end
				)
			)
		}
		@ws
	}

	sub key-boundary( Mu $p ) {
		say "{$p.from} {$p.to} [{substr($p.orig,$p.from,$p.to-$p.from)}]";
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

	method _arglist( Mu $p ) returns Array[Perl6::Element] {
		if $p.list {
			my Perl6::Element @child;
			for $p.list {
				if self.assert-hash-keys( $_, [< EXPR >] ) {
					@child.push(
						self._EXPR( $_.hash.<EXPR> )
					)
				}
				elsif $_.Bool {
					# XXX Boolean represents blank?
				}
				else {
					say $_.hash.keys.gist;
					warn "Unhandled case"
				}
			}
			@child
		}
		elsif self.assert-hash-keys( $p,
				[< deftermnow initializer term_init >],
				[< trait >] ) {
			die "Not implemented yet";
		}
		elsif self.assert-Int( $p ) {
			die "Not implemented yet";
		}
		elsif self.assert-Bool( $p ) {
			die "Not implemented yet";
		}
		else {
			say $p.hash.keys.gist;
			warn "Unhandled case"
		}
	}

	method _args( Mu $p ) {
		if self.assert-hash-keys( $p, [< invocant semiarglist >] ) {
			die "Not implemented yet";
		}
		elsif self.assert-hash-keys( $p, [< semiarglist >] ) {
			my Perl6::Element @child;
			@child.append(
				self._semiarglist( $p.hash.<semiarglist> )
			);
			self.make-postcircumfix( $p, @child )
		}
		elsif self.assert-hash-keys( $p, [< arglist >] ) {
			self._arglist( $p.hash.<arglist> );
		}
		elsif self.assert-hash-keys( $p, [< EXPR >] ) {
			self._EXPR( $p.hash.<EXPR> );
		}
		elsif $p.Str {
			die "Not implemented yet"
		}
		elsif $p.Bool {
			die "Not implemented yet"
		}
		else {
			say $p.Int if $p.Int;
			say $p.hash.keys.gist;
			warn "Unhandled case"
		}
	}

	method _assertion( Mu $p ) {
		warn "Untested method";
		if self.assert-hash-keys( $p, [< var >] ) {
			self._var( $p.hash.<var> )
		}
		elsif self.assert-hash-keys( $p, [< longname >] ) {
			self._longname( $p.hash.<longname> )
		}
		elsif self.assert-hash-keys( $p, [< cclass_elem >] ) {
			self._cclass_elem( $p.hash.<cclass_elem> )
		}
		elsif self.assert-hash-keys( $p, [< codeblock >] ) {
			self._codeblock( $p.hash.<codeblock> )
		}
		elsif $p.Str {
			die "Not implemented yet";
		}
		else {
			say $p.hash.keys.gist;
			warn "Unhandled case"
		}
	}

	method _atom( Mu $p ) {
		warn "Untested method";
		if self.assert-hash-keys( $p, [< metachar >] ) {
			self._metachar( $p.hash.<metachar> )
		}
		elsif $p.Str {
			die "Not implemented yet";
		}
		else {
			say $p.hash.keys.gist;
			warn "Unhandled case"
		}
	}

	method _babble( Mu $p ) {
		warn "Untested method";
		if self.assert-hash-keys( $p, [< B >], [< quotepair >] ) {
			self._B( $p.hash.<B> )
		}
		else {
			say $p.hash.keys.gist;
			warn "Unhandled case"
		}
	}

	method _backmod( Mu $p ) { $p.hash.<backmod>.Bool }

	method _backslash( Mu $p ) {
		warn "Untested method";
		if self.assert-hash-keys( $p, [< sym >] ) {
			self._sym( $p.hash.<sym> )
		}
		elsif $p.Str {
			die "Not implemented yet";
		}
		else {
			say $p.hash.keys.gist;
			warn "Unhandled case"
		}
	}

	# XXX Unused
	method _binint( Mu $p ) returns Perl6::Element {
		Perl6::Number::Binary.new(
			:from( $p.from ),
			:to( $p.to ),
			:content( $p.Str )
		)
	}

	method _block( Mu $p ) {
		if self.assert-hash-keys( $p, [< blockoid >] ) {
			self._blockoid( $p.hash.<blockoid> )
		}
		else {
			say $p.hash.keys.gist;
			warn "Unhandled case"
		}
	}

	method _blockoid( Mu $p ) {
		if self.assert-hash-keys( $p, [< statementlist >] ) {
			my Perl6::Element @child;
			@child.append(
				self._statementlist(
					$p.hash.<statementlist>
				)
			);
			$p.Str ~~ m{ ^ (.) }; my $front = ~$0;
			$p.Str ~~ m{ (.) $ }; my $back = ~$0;
			Perl6::Block.new(
				:delimiter( $front, $back ),
				:child( @child )
			)
		}
		else {
			say $p.hash.keys.gist;
			warn "Unhandled case"
		}
	}

	method _blorst( Mu $p ) {
		warn "Untested method";
		if self.assert-hash-keys( $p, [< statement >] ) {
			self._statement( $p.hash.<statement> )
		}
		elsif self.assert-hash-keys( $p, [< block >] ) {
			self._block( $p.hash.<block> )
		}
		else {
			say $p.hash.keys.gist;
			warn "Unhandled case"
		}
	}

	method _bracket( Mu $p ) {
		warn "Untested method";
		if self.assert-hash-keys( $p, [< semilist >] ) {
			self._semilist( $p.hash.<semilist> )
		}
		else {
			say $p.hash.keys.gist;
			warn "Unhandled case"
		}
	} 

	method _cclass_elem( Mu $p ) {
		warn "Untested method";
		if $p.list {
			my Perl6::Element @child;
			for $p.list {
				if self.assert-hash-keys( $_,
						[< identifier name sign >],
						[< charspec >] ) {
					die "Not implemented yet"
				}
				elsif self.assert-hash-keys( $_,
						[< sign charspec >] ) {
					die "Not implemented yet"
				}
				else {
					say $p.hash.keys.gist;
					warn "Unhandled case"
				}
			}
			@child
		}
		else {
			say $p.hash.keys.gist;
			warn "Unhandled case"
		}
	}

	method _charspec( Mu $p ) {
		warn "Untested method";
# XXX work on this, of course.
		return True if $p.list;
	}

	method _circumfix( Mu $p ) {
		if self.assert-hash-keys( $p, [< binint VALUE >] ) {
			self._binint( $p.hash.<binint> )
		}
		elsif self.assert-hash-keys( $p, [< octint VALUE >] ) {
			self._octint( $p.hash.<octint> )
		}
		elsif self.assert-hash-keys( $p, [< decint VALUE >] ) {
			self._decint( $p.hash.<decint> )
		}
		elsif self.assert-hash-keys( $p, [< hexint VALUE >] ) {
			self._hexint( $p.hash.<hexint> )
		}
		elsif self.assert-hash-keys( $p, [< pblock >] ) {
			self._pblock( $p.hash.<pblock> )
		}
		elsif self.assert-hash-keys( $p, [< semilist >] ) {
			# XXX <semilist> can probably be worked with
			my @ws;
			if $p.hash.<semilist>.hash.<statement>.list.[0].hash.<EXPR> {
				my Perl6::Element @child;
				@child.push(
self._EXPR( $p.hash.<semilist>.hash.<statement>.list.[0].hash.<EXPR> )
				);
				@ws = self.populate-whitespace(
					$p.Str,
					$p.from + 1, $p.to - 1, @child
				)
			}
			self.make-postcircumfix( $p, @ws )
		}
		elsif self.assert-hash-keys( $p, [< nibble >] ) {
			# XXX <nibble> can probably be worked with
			my Perl6::Element @child;
			@child.push(
				# leading and trailing space elided
				Perl6::Operator::Prefix.new(
					:from( $p.from ),
					:to( $p.to ),
					:content( $p.hash.<nibble>.Str )
				)
			);
			self.make-circumfix( $p, @child )
		}
		else {
			say $p.hash.keys.gist;
			warn "Unhandled case"
		}
	}

	method _codeblock( Mu $p ) {
		warn "Untested method";
		if self.assert-hash-keys( $p, [< block >] ) {
			self._block( $p.hash.<block> )
		}
		else {
			say $p.hash.keys.gist;
			warn "Unhandled case"
		}
	}

	method _coercee( Mu $p ) {
		warn "Untested method";
		if self.assert-hash-keys( $p, [< semilist >] ) {
			self._semilist( $p.hash.<semilist> )
		}
		else {
			say $p.hash.keys.gist;
			warn "Unhandled case"
		}
	}

	method _coloncircumfix( Mu $p ) {
		if self.assert-hash-keys( $p, [< circumfix >] ) {
			self._circumfix( $p.hash.<circumfix> )
		}
		else {
			say $p.hash.keys.gist;
			warn "Unhandled case"
		}
	}

	method _colonpair( Mu $p ) {
		if self.assert-hash-keys( $p,
				     [< identifier coloncircumfix >] ) {
			# Synthesize the 'from' marker for ':'
			(
				Perl6::Operator::Prefix.new(
					:from( $p.from ),
					:to( $p.from + 1 ),
					:content( Q{:} )
				),
				self._identifier( $p.hash.<identifier> ),
				self._coloncircumfix( $p.hash.<coloncircumfix> )
			).flat
		}
		elsif self.assert-hash-keys( $p, [< coloncircumfix >] ) {
			(
				# leading and trailing space elided
				# XXX Note that ':' is part of the expression.
				Perl6::Operator::Prefix.new(
					:from( $p.from ),
					:to( $p.from + 1 ),
					:content( Q{:} )
				),
				self._coloncircumfix( $p.hash.<coloncircumfix> )
			).flat
		}
		elsif self.assert-hash-keys( $p, [< identifier >] ) {
			# leading and trailing space elided
			Perl6::ColonBareword.new(
				:from( $p.from ),
				:to( $p.to ),
				:content( $p.Str )
			)
		}
		elsif self.assert-hash-keys( $p, [< fakesignature >] ) {
			# Synthesize the 'from' marker for ':'
			(
				Perl6::Operator::Prefix.new(
					:from( $p.from ),
					:to( $p.from + 1 ),
					:content( Q{:} )
				),
				self._fakesignature( $p.hash.<fakesignature> )
			).flat
		}
		elsif self.assert-hash-keys( $p, [< var >] ) {
			# Synthesize the 'from' marker for ':'
			(
				# XXX is this actually a single token?
				# XXX I think it is.
				Perl6::Operator::Prefix.new(
					:from( $p.from ),
					:to( $p.from + 1 ),
					:content( Q{:} )
				),
				self._var( $p.hash.<var> )
			).flat
		}
		else {
			say $p.hash.keys.gist;
			warn "Unhandled case"
		}
	}

	method _colonpairs( Mu $p ) {
		warn "Untested method";
		if $p ~~ Hash {
			return True if $p.<D>;
			return True if $p.<U>;
		}
		else {
			say $p.hash.keys.gist;
			warn "Unhandled case"
		}
	}

	method _contextualizer( Mu $p ) {
		warn "Untested method";
		if self.assert-hash-keys( $p, [< coercee circumfix sigil >] ) {
			die "Not implemented yet";
		}
		else {
			say $p.hash.keys.gist;
			warn "Unhandled case"
		}
	}

	method _decint( Mu $p ) returns Perl6::Element {
		Perl6::Number::Decimal.new(
			:from( $p.from ),
			:to( $p.to ),
			:content( $p.Str )
		)
	}

	method _declarator( Mu $p ) {
		if self.assert-hash-keys( $p,
				[< deftermnow initializer term_init >],
				[< trait >] ) {
			die "Not implemented yet";
		}
		elsif self.assert-hash-keys( $p,
				[< initializer signature >], [< trait >] ) {
			die "Not implemented yet";
		}
		elsif self.assert-hash-keys( $p,
				  [< initializer variable_declarator >],
				  [< trait >] ) {
			(
				self._variable_declarator(
					$p.hash.<variable_declarator>
				),
				self._initializer( $p.hash.<initializer> )
			)
		}
		elsif self.assert-hash-keys( $p,
				[< routine_declarator >], [< trait >] ) {
			self._routine_declarator( $p.hash.<routine_declarator> )
		}
		elsif self.assert-hash-keys( $p,
				[< regex_declarator >], [< trait >] ) {
			self._regex_declarator( $p.hash.<regex_declarator> )
		}
		elsif self.assert-hash-keys( $p,
				[< variable_declarator >], [< trait >] ) {
			self._variable_declarator(
				$p.hash.<variable_declarator>
			)
		}
		elsif self.assert-hash-keys( $p,
				[< signature >], [< trait >] ) {
			self._signature( $p.hash.<signature> )
		}
		else {
			say $p.hash.keys.gist;
			warn "Unhandled case"
		}
	}

	method _DECL( Mu $p ) {
		warn "Untested method";
		if self.assert-hash-keys( $p,
				[< deftermnow initializer term_init >],
				[< trait >] ) {
			die "Not implemented yet";
		}
		elsif self.assert-hash-keys( $p,
				[< deftermnow initializer signature >],
				[< trait >] ) {
			die "Not implemented yet";
		}
		elsif self.assert-hash-keys( $p,
				[< initializer signature >], [< trait >] ) {
			die "Not implemented yet";
		}
		elsif self.assert-hash-keys( $p,
				[< initializer variable_declarator >],
				[< trait >] ) {
			die "Not implemented yet";
		}
		elsif self.assert-hash-keys( $p, [< package_def sym >] ) {
			die "Not implemented yet";
		}
		elsif self.assert-hash-keys( $p,
				[< regex_declarator >],
				[< trait >] ) {
			self._regex_declarator( $p.hash.<regex_declarator> )
		}
		elsif self.assert-hash-keys( $p,
				[< variable_declarator >],
				[< trait >] ) {
			self._variable_declarator( $p.hash.<variable_declarator> )
		}
		elsif self.assert-hash-keys( $p,
				[< routine_declarator >],
				[< trait >] ) {
			self._routine_declarator( $p.hash.<routine_declarator> )
		}
		elsif self.assert-hash-keys( $p, [< declarator >] ) {
			self._declarator( $p.hash.<declarator> )
		}
		elsif self.assert-hash-keys( $p,
				[< signature >], [< trait >] ) {
			self._declarator( $p.hash.<declarator> )
		}
		else {
			say $p.hash.keys.gist;
			warn "Unhandled case"
		}
	}

	method _dec_number( Mu $p ) returns Perl6::Element {
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

	method _default_value( Mu $p ) {
		if $p.list {
			my Perl6::Element @child;
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
		else {
			say $p.hash.keys.gist;
			warn "Unhandled case"
		}
	}

	method _deflongname( Mu $p ) {
		if self.assert-hash-keys( $p, [< name >], [< colonpair >] ) {
			self._name( $p.hash.<name> )
		}
		else {
			say $p.hash.keys.gist;
			warn "Unhandled case"
		}
	}

	method _defterm( Mu $p ) {
		warn "Untested method";
		if self.assert-hash-keys( $p, [< identifier colonpair >] ) {
			(
				self._identifier( $p.hash.<identifier> ),
				self._colonpair( $p.hash.<colonpair> ),
			)
		}
		elsif self.assert-hash-keys( $p,
				[< identifier >],
				[< colonpair >] ) {
			self._identifier( $p.hash.<identifier> )
		}
		else {
			say $p.hash.keys.gist;
			warn "Unhandled case"
		}
	}

	method _deftermnow( Mu $p ) {
		warn "Untested method";
		if self.assert-hash-keys( $p, [< defterm >] ) {
			self._defterm( $p.hash.<defterm> )
		}
		else {
			say $p.hash.keys.gist;
			warn "Unhandled case"
		}
	}

	method _desigilname( Mu $p ) {
		if self.assert-hash-keys( $p, [< longname >] ) {
			self._longname( $p.hash.<longname> )
		}
		elsif $p.Str {
			die "Not implemented yet"
		}
		else {
			say $p.hash.keys.gist;
			warn "Unhandled case"
		}
	}

	method _dig( Mu $p ) {
		warn "Untested method";
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

	method _doc( Mu $p ) returns Bool {
		$p.hash.<doc>.Bool
	}

	method _dotty( Mu $p ) {
		if self.assert-hash-keys( $p, [< sym dottyop O >] ) {
			(
				# leading and trailing space elided
				self.make-prefix-from( $p.hash.<sym> ),
				self._dottyop( $p.hash.<dottyop> )
			)
		}
		else {
			say $p.hash.keys.gist;
			warn "Unhandled case"
		}
	}

	method _dottyop( Mu $p ) {
		if self.assert-hash-keys( $p, [< sym postop >], [< O >] ) {
			die "Not implemented yet"
		}
		elsif self.assert-hash-keys( $p, [< colonpair >] ) {
			self._colonpair( $p.hash.<colonpair> )
		}
		elsif self.assert-hash-keys( $p, [< methodop >] ) {
			self._methodop( $p.hash.<methodop> )
		}
		else {
			say $p.hash.keys.gist;
			warn "Unhandled case"
		}
	}

	method _dottyopish( Mu $p ) {
		warn "Untested method";
		if self.assert-hash-keys( $p, [< term >] ) {
			self._term( $p.hash.<term> )
		}
		else {
			say $p.hash.keys.gist;
			warn "Unhandled case"
		}
	}

	method _e1( Mu $p ) {
		warn "Untested method";
		if self.assert-hash-keys( $p, [< scope_declarator >] ) {
			self._scope_declarator( $p.hash.<scope_declarator> )
		}
		else {
			say $p.hash.keys.gist;
			warn "Unhandled case"
		}
	}

	method _e2( Mu $p ) {
		warn "Untested method";
		if self.assert-hash-keys( $p, [< infix OPER >] ) {
			die "Not implemented yet"
		}
		else {
			say $p.hash.keys.gist;
			warn "Unhandled case"
		}
	}

	method _e3( Mu $p ) {
		warn "Untested method";
		if self.assert-hash-keys( $p, [< postfix OPER >],
				[< postfix_prefix_meta_operator >] ) {
			die "Not implemented yet"
		}
		else {
			say $p.hash.keys.gist;
			warn "Unhandled case"
		}
	}

	method _else( Mu $p ) {
		warn "Untested method";
		if self.assert-hash-keys( $p, [< sym blorst >] ) {
			die "Not implemented yet"
		}
		elsif self.assert-hash-keys( $p, [< blockoid >] ) {
			self._blockoid( $p.hash.<blockoid> )
		}
		else {
			say $p.hash.keys.gist;
			warn "Unhandled case"
		}
	}

	method _escale( Mu $p ) {
		warn "Untested method";
		if self.assert-hash-keys( $p, [< sign decint >] ) {
			die "Not implemented yet"
		}
		else {
			say $p.hash.keys.gist;
			warn "Unhandled case"
		}
	}

	method __Term( Mu $p ) {
		if self.assert-hash-keys( $p,
				[< postfix OPER >],
				[< postfix_prefix_meta_operator >] ) {
			(
				self.__Term( $p.list.[0] ),
				self._postfix( $p.hash.<postfix> )
			)
		}
		elsif self.assert-hash-keys( $p,
				[< identifier >], [< args >] ) {
			self._identifier( $p.hash.<identifier> )
		}
		elsif self.assert-hash-keys( $p, [< longname >], [< args >] ) {
			self._longname( $p.hash.<longname> )
		}
		elsif self.assert-hash-keys( $p, [< longname >] ) {
			self._longname( $p.hash.<longname> )
		}
		elsif self.assert-hash-keys( $p, [< variable >] ) {
			self._variable( $p.hash.<variable> )
		}
		elsif self.assert-hash-keys( $p, [< value >] ) {
			my $v = $p.hash.<value>;
			if self.assert-hash-keys( $v, [< number >] ) {
				self._number( $v.hash.<number> )
			}
			elsif self.assert-hash-keys( $v, [< quote >] ) {
				self._quote( $v.hash.<quote> )
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
					# leading and trailing space elided
					# XXX note that '>>' is a substring
					Perl6::Operator::Prefix.new(
						:from( $p.from ),
						:to( $p.from + 2 ),
						:content( 
							substr( $p.orig, $p.from, 2 )
						)
					),
					self._dotty( $p.hash.<dotty> )
				).flat
			}
			else {
				(
					self.__Term( $p.list.[0] ),
					self._dotty( $p.hash.<dotty> )
				).flat
			}
		}
		elsif self.assert-hash-keys( $p,
				[< prefix OPER >],
				[< prefix_postfix_meta_operator >] ) {
			(
				self._prefix( $p.hash.<prefix> ),
				self.__Term( $p.list.[0] )
			).flat
		}
		elsif self.assert-hash-keys( $p,
				[< postcircumfix OPER >],
				[< postfix_prefix_meta_operator >] ) {
			# XXX Work on this
			my Perl6::Element @child;
			@child.push(
				self._postcircumfix( $p.hash.<postcircumfix> )
			);
			(
				self.__Term( $p.list.[0] ),
				self.make-postcircumfix(
					$p.hash.<postcircumfix>,
					@child
				)
			).flat
		}
		elsif self.assert-hash-keys( $p,
				[< postfix OPER >],
				[< postfix_prefix_meta_operator >] ) {
			(
				self.__Term( $p.list.[0] ),
				self._postfix( $p.hash.<postfix> )
			).flat
		}
		elsif self.assert-hash-keys( $p,
				[< infix_prefix_meta_operator OPER >] ) {
			(
				self.__Term( $p.list.[0] ),
				self._infix_prefix_meta_operator(
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
					self.make-infix-from( $p, Q{??} ),
					self.__Term( $p.list.[1] ),
					self.make-infix-from( $p, Q{!!} ),
					self.__Term( $p.list.[2] )
				).flat
			}
			else {
				(
					self.__Term( $p.list.[0] ),
					self._infix( $p.hash.<infix> ),
					self.__Term( $p.list.[1] )
				).flat
			}
		}
		elsif self.assert-hash-keys( $p, [< identifier args >] ) {
			(
				self._identifier( $p.hash.<identifier> ),
				self._args( $p.hash.<args> )
			)
		}
		elsif self.assert-hash-keys( $p, [< sym args >] ) {
			# leading and trailing space elided
			self.make-infix-from( $p.hash.<sym> )
		}
		elsif self.assert-hash-keys( $p, [< longname args >] ) {
			# XXX Needs work later on
			if $p.hash.<args> and
			   $p.hash.<args>.hash.<semiarglist> {
				(
					self._longname( $p.hash.<longname> ),
					self._args( $p.hash.<args> )
				)
			}
			else {
				self._longname( $p.hash.<longname> )
			}
		}
		elsif self.assert-hash-keys( $p, [< circumfix >] ) {
			self._circumfix( $p.hash.<circumfix> )
		}
		elsif self.assert-hash-keys( $p, [< fatarrow >] ) {
			self._fatarrow( $p.hash.<fatarrow> )
		}
		elsif self.assert-hash-keys( $p, [< regex_declarator >] ) {
			self._regex_declarator( $p.hash.<regex_declarator> )
		}
		elsif self.assert-hash-keys( $p, [< routine_declarator >] ) {
			self._routine_declarator( $p.hash.<routine_declarator> )
		}
		elsif self.assert-hash-keys( $p, [< scope_declarator >] ) {
			self._scope_declarator( $p.hash.<scope_declarator> )
		}
		elsif self.assert-hash-keys( $p, [< package_declarator >] ) {
			self._package_declarator( $p.hash.<package_declarator> )
		}
		elsif self.assert-hash-keys( $p, [< value >] ) {
			self._value( $p.hash.<value> )
		}
		elsif self.assert-hash-keys( $p, [< variable >] ) {
			self._variable( $p.hash.<variable> )
		}
		elsif self.assert-hash-keys( $p, [< colonpair >] ) {
			self._colonpair( $p.hash.<colonpair> )
		}
		elsif self.assert-hash-keys( $p, [< longname >] ) {
			self._longname( $p.hash.<longname> )
		}
		else {
			say $p.hash.keys.gist;
			warn "Unhandled case"
		}
	}

	method _fake_infix( Mu $p ) {
		warn "Untested method";
		if self.assert-hash-keys( $p, [< O >] ) {
			self._O( $p.hash.<O> )
		}
		else {
			say $p.hash.keys.gist;
			warn "Unhandled case"
		}
	}

	method _fakesignature( Mu $p ) {
		if self.assert-hash-keys( $p, [< signature >] ) {
			self._signature( $p.hash.<signature> )
		}
		else {
			say $p.hash.keys.gist;
			warn "Unhandled case"
		}
	}

	method _fatarrow( Mu $p ) {
		if self.assert-hash-keys( $p, [< key val >] ) {
say $p.Str;
			my @child = (
				self._key( $p.hash.<key> ),
				self.make-infix-from( $p, Q{=>} ),
				self._val( $p.hash.<val> )
			);
			my @ws = self.populate-whitespace(
				$p.Str,
				$p.from, $p.to, @child
			);
			@ws
		}
		else {
			say $p.hash.keys.gist;
			warn "Unhandled case"
		}
	}

	method __FloatingPoint( Mu $p ) returns Perl6::Element {
		# leading and trailing space elided
		Perl6::Number::Floating.new(
			:from( $p.from ),
			:to( $p.to ),
			:content( $p.Str )
		)
	}

	# XXX Unused
	method _hexint( Mu $p ) returns Perl6::Element {
		Perl6::Number::Hexadecimal.new(
			:from( $p.from ),
			:to( $p.to ),
			:content( $p.Str eq '0' ?? 0 !! $p.Int )
		)
	}

	method _identifier( Mu $p ) {
		if $p.list {
			my Perl6::Element @child;
			for $p.list {
				if self.assert-Str( $_ ) {
					die "Not implemented yet"
				}
				else {
					say $p.hash.keys.gist;
					warn "Unhandled case"
				}
			}
			@child
		}
		elsif $p.Str {
			# leading and trailing space elided
			Perl6::Bareword.new(
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

	method _infix( Mu $p ) {
		if self.assert-hash-keys( $p, [< infix OPER >] ) {
			die "Not implemented yet";
		}
		elsif self.assert-hash-keys( $p, [< sym O >] ) {
			# leading and trailing space elided
			self.make-infix-from( $p.hash.<sym> )
		}
		elsif self.assert-hash-keys( $p, [< EXPR O >] ) {
			# XXX Untested
			self.make-infix-from( $p.hash.<EXPR> )
		}
		else {
			say $p.hash.keys.gist;
			warn "Unhandled case"
		}
	}

	method _infixish( Mu $p ) {
		warn "Untested method";
		if self.assert-hash-keys( $p, [< infix OPER >] ) {
			die "Not implemented yet";
		}
		else {
			say $p.hash.keys.gist;
			warn "Unhandled case"
		}
	}

	method _infix_prefix_meta_operator( Mu $p ) {
		if self.assert-hash-keys( $p, [< sym infixish O >] ) {
			# XXX Untested
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

	method _initializer( Mu $p ) {
		if self.assert-hash-keys( $p, [< dottyopish sym >] ) {
			die "Not implemented yet"
		}
		elsif self.assert-hash-keys( $p, [< sym EXPR >] ) {
			(
				# XXX refactor down?
				# leading and trailing space elided
				self.make-infix-from( $p.hash.<sym> ),
				self._EXPR( $p.hash.<EXPR> )
			)
		}
		else {
			say $p.hash.keys.gist;
			warn "Unhandled case"
		}
	}

	method _integer( Mu $p ) {
		if self.assert-hash-keys( $p, [< binint VALUE >] ) {
			# XXX Probably should make 'headless' lazy later.
			# leading and trailing space elided
			Perl6::Number::Binary.new(
				:from( $p.from ),
				:to( $p.to ),
				:content( $p.Str ),
				:headless( $p.hash.<binint>.Str )
			)
		}
		elsif self.assert-hash-keys( $p, [< octint VALUE >] ) {
			# XXX Probably should make 'headless' lazy later.
			# leading and trailing space elided
			Perl6::Number::Octal.new(
				:from( $p.from ),
				:to( $p.to ),
				:content( $p.Str ),
				:headless( $p.hash.<octint>.Str )
			)
		}
		elsif self.assert-hash-keys( $p, [< decint VALUE >] ) {
			# leading and trailing space elided
			Perl6::Number::Decimal.new(
				:from( $p.from ),
				:to( $p.to ),
				:content( $p.Str ),
			)
		}
		elsif self.assert-hash-keys( $p, [< hexint VALUE >] ) {
			# XXX Probably should make 'headless' lazy later.
			# leading and trailing space elided
			Perl6::Number::Hexadecimal.new(
				:from( $p.from ),
				:to( $p.to ),
				:content( $p.Str ),
				:headless( $p.hash.<hexint>.Str )
			)
		}
		else {
			Perl6::Unimplemented.new(
				:content( "Unknown integer type" )
			)
		}
	}

	method _invocant( Mu $p ) {
		warn "Untested method";
		CATCH {
			when X::Multi::NoMatch { }
		}
		#if $p ~~ QAST::Want;
		#if self.assert-hash-keys( $p, [< XXX >] );
# XXX Fixme
#say $p.dump;
#say $p.dump_annotations;
#say "############## " ~$p.<annotations>.gist;#<BY>;
return True;
	}

	method _key( Mu $p ) returns Perl6::Element {
		# leading and trailing space elided
		Perl6::Bareword.new(
			:from( $p.from ),
			:to( $p.to ),
			:content( $p.Str )
		)
	}

	method _lambda( Mu $p ) returns Str {
		$p.hash.<lambda>.Str
	}

	method _left( Mu $p ) {
		warn "Untested method";
		if self.assert-hash-keys( $p, [< termseq >] ) {
			self._termseq( $p.hash.<termseq> )
		}
		else {
			say $p.hash.keys.gist;
			warn "Unhandled case"
		}
	}

	method _longname( Mu $p ) {
		if self.assert-hash-keys( $p, [< name >], [< colonpair >] ) {
			self._name( $p.hash.<name> )
		}
		else {
			say $p.hash.keys.gist;
			warn "Unhandled case"
		}
	}

	method _max( Mu $p ) returns Str {
		$p.hash.<max>.Str
	}

	method _metachar( Mu $p ) {
		warn "Untested method";
		if self.assert-hash-keys( $p, [< sym >] ) {
			self._sym( $p.hash.<sym> )
		}
		elsif self.assert-hash-keys( $p, [< codeblock >] ) {
			self._codeblock( $p.hash.<codeblock> )
		}
		elsif self.assert-hash-keys( $p, [< backslash >] ) {
			self._backslash( $p.hash.<backslash> )
		}
		elsif self.assert-hash-keys( $p, [< assertion >] ) {
			self._assertion( $p.hash.<assertion> )
		}
		elsif self.assert-hash-keys( $p, [< nibble >] ) {
			self._nibble( $p.hash.<nibble> )
		}
		elsif self.assert-hash-keys( $p, [< quote >] ) {
			self._quote( $p.hash.<quote> )
		}
		elsif self.assert-hash-keys( $p, [< nibbler >] ) {
			self._nibbler( $p.hash.<nibbler> )
		}
		elsif self.assert-hash-keys( $p, [< statement >] ) {
			self._statement( $p.hash.<statement> )
		}
		else {
			say $p.hash.keys.gist;
			warn "Unhandled case"
		}
	}

	method _method_def( Mu $p ) {
		if self.assert-hash-keys( $p,
			     [< specials longname blockoid multisig >],
			     [< trait >] ) {
			(
				self._longname( $p.hash.<longname> ),
				self._multisig( $p.hash.<multisig> ),
				self._blockoid( $p.hash.<blockoid> )
			).flat
		}
		elsif self.assert-hash-keys( $p,
			     [< specials longname blockoid >],
			     [< trait >] ) {
			(
				self._longname( $p.hash.<longname> ),
				self._blockoid( $p.hash.<blockoid> )
			).flat
		}
		else {
			say $p.hash.keys.gist;
			warn "Unhandled case"
		}
	}

	method _methodop( Mu $p ) {
		if self.assert-hash-keys( $p, [< longname args >] ) {
			(
				self._longname( $p.hash.<longname> ),
				self._args( $p.hash.<args> )
			)
		}
		elsif self.assert-hash-keys( $p, [< variable >] ) {
			self._variable( $p.hash.<variable> )
		}
		elsif self.assert-hash-keys( $p, [< longname >] ) {
			self._longname( $p.hash.<longname> )
		}
		else {
			say $p.hash.keys.gist;
			warn "Unhandled case"
		}
	}

	method _min( Mu $p ) {
		warn "Untested method";
		if self.assert-hash-keys( $p, [< decint VALUE >] ) {
			self._decint( $p.hash.<decint> )
		}
		else {
			say $p.hash.keys.gist;
			warn "Unhandled case"
		}
	}

	method _modifier_expr( Mu $p ) {
		warn "Untested method";
		if self.assert-hash-keys( $p, [< EXPR >] ) {
			self._EXPR( $p.hash.<EXPR> )
		}
		else {
			say $p.hash.keys.gist;
			warn "Unhandled case"
		}
	}

	method _module_name( Mu $p ) {
		warn "Untested method";
		if self.assert-hash-keys( $p, [< longname >] ) {
			self._longname( $p.hash.<longname> )
		}
		else {
			say $p.hash.keys.gist;
			warn "Unhandled case"
		}
	}

	method _morename( Mu $p ) {
		warn "Untested method";
		if $p.list {
			my Perl6::Element @child;
			for $p.list {
				if self.assert-hash-keys( $_,
					[< identifier >] ) {
					die "Not implemented yet"
				}
				else {
					say $p.hash.keys.gist;
					warn "Unhandled case"
				}
			}
			@child
		}
		else {
			say $p.hash.keys.gist;
			warn "Unhandled case"
		}
	}

	method _multi_declarator( Mu $p ) {
		if self.assert-hash-keys( $p, [< sym routine_def >] ) {
			die "Not implemented yet"
		}
		elsif self.assert-hash-keys( $p, [< sym declarator >] ) {
			self._sym( $p.hash.<sym> ),
			self._declarator( $p.hash.<declarator> )
		}
		elsif self.assert-hash-keys( $p, [< declarator >] ) {
			self._declarator( $p.hash.<declarator> )
		}
		else {
			say $p.hash.keys.gist;
			warn "Unhandled case"
		}
	}

	method _multisig( Mu $p ) {
		if self.assert-hash-keys( $p, [< signature >] ) {
			self._signature( $p.hash.<signature> )
		}
		else {
			say $p.hash.keys.gist;
			warn "Unhandled case"
		}
	}

	method _named_param( Mu $p ) {
		if self.assert-hash-keys( $p, [< param_var >] ) {
			self._param_var( $p.hash.<param_var> )
		}
		else {
			say $p.hash.keys.gist;
			warn "Unhandled case"
		}
	}

	method _name( Mu $p ) {
		if self.assert-hash-keys( $p,
			[< param_var type_constraint quant >],
			[< default_value modifier trait post_constraint >] ) {
			die "Not implemented yet"
		}
		elsif self.assert-hash-keys( $p,
			[< identifier >], [< morename >] ) {
			# leading and trailing space elided
			Perl6::Bareword.new(
				:from( $p.from ),
				:to( $p.to ),
				:content( $p.Str )
			)
		}
		elsif self.assert-hash-keys( $p, [< subshortname >] ) {
			die "Not implemented yet"
		}
		elsif self.assert-hash-keys( $p, [< morename >] ) {
			# leading and trailing space elided
			Perl6::PackageName.new(
				:from( $p.from ),
				:to( $p.to ),
				:content( $p.Str )
			)
		}
		elsif self.assert-Str( $p ) {
key-boundary $p;
warn 28;
			Perl6::Bareword.new(
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

	method _nibble( Mu $p ) {
		if self.assert-hash-keys( $p, [< termseq >] ) {
			self._termseq( $p.hash.<termseq> )
		}
		elsif $p.Bool {
			die "Not implemented yet"
		}
		else {
			say $p.hash.keys.gist;
			warn "Unhandled case"
		}
	}

	method _nibbler( Mu $p ) {
		warn "Untested method";
		if self.assert-hash-keys( $p, [< termseq >] ) {
			self._termseq( $p.hash.<termseq> )
		}
		else {
			say $p.hash.keys.gist;
			warn "Unhandled case"
		}
	}

	method _normspace( Mu $p ) returns Str {
		$p.hash.<normspace>.Str
	}

	method _noun( Mu $p ) {
		warn "Untested method";
		if $p.list {
			my Perl6::Element @child;
			for $p.list {
				if self.assert-hash-keys( $_,
					[< sigmaybe sigfinal
					   quantifier atom >] ) {
					die "Not implemented yet"
				}
				elsif self.assert-hash-keys( $_,
					[< sigfinal quantifier
					   separator atom >] ) {
					die "Not implemented yet"
				}
				elsif self.assert-hash-keys( $_,
					[< sigmaybe sigfinal
					   separator atom >] ) {
					die "Not implemented yet"
				}
				elsif self.assert-hash-keys( $_,
					[< atom sigfinal quantifier >] ) {
					die "Not implemented yet"
				}
				elsif self.assert-hash-keys( $_,
					[< atom >], [< sigfinal >] ) {
					die "Not implemented yet"
				}
				else {
					say $p.hash.keys.gist;
					warn "Unhandled case"
				}
			}
			@child;
		}
		else {
			say $p.hash.keys.gist;
			warn "Unhandled case"
		}
	}

	method _number( Mu $p ) {
		if self.assert-hash-keys( $p, [< numish >] ) {
			self._numish( $p.hash.<numish> )
		}
		else {
			say $p.hash.keys.gist;
			warn "Unhandled case"
		}
	}

	method _numish( Mu $p ) {
		if self.assert-hash-keys( $p, [< dec_number >] ) {
			self._dec_number( $p.hash.<dec_number> )
		}
		elsif self.assert-hash-keys( $p, [< rad_number >] ) {
			self._rad_number( $p.hash.<rad_number> )
		}
		elsif self.assert-hash-keys( $p, [< integer >] ) {
			self._integer( $p.hash.<integer> )
		}
		elsif $p.Bool {
			die "Not implemented yet"
		}
		else {
			say $p.hash.keys.gist;
			warn "Unhandled case"
		}
	}

	method _O( Mu $p ) {
		warn "Untested method";
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

	method _octint( Mu $p ) returns Perl6::Element {
		Perl6::Number::Octal.new(
			:from( $p.from ),
			:to( $p.to ),
			:content( $p.Str eq '0' ?? 0 !! $p.Int )
		)
	}

	method _op( Mu $p ) {
		warn "Untested method";
		if self.assert-hash-keys( $p,
			     [< infix_prefix_meta_operator OPER >] ) {
			die "Not implemented yet"
		}
		elsif self.assert-hash-keys( $p, [< infix OPER >] ) {
			die "Not implemented yet"
		}
		else {
			say $p.hash.keys.gist;
			warn "Unhandled case"
		}
	}

	method _OPER( Mu $p ) {
		if self.assert-hash-keys( $p, [< sym infixish O >] ) {
			die "Not implemented yet"
		}
		elsif self.assert-hash-keys( $p, [< sym dottyop O >] ) {
			(
				self.make-infix-from( $p.hash.<sym> ),
				self._dottyop( $p.hash.<dottyop> )
			)
		}
		elsif self.assert-hash-keys( $p, [< sym O >] ) {
			die "Not implemented yet"
		}
		elsif self.assert-hash-keys( $p, [< EXPR O >] ) {
			die "Not implemented yet"
		}
		elsif self.assert-hash-keys( $p, [< semilist O >] ) {
			die "Not implemented yet"
		}
		elsif self.assert-hash-keys( $p, [< nibble O >] ) {
			die "Not implemented yet"
		}
		elsif self.assert-hash-keys( $p, [< arglist O >] ) {
			die "Not implemented yet"
		}
		elsif self.assert-hash-keys( $p, [< dig O >] ) {
			die "Not implemented yet"
		}
		elsif self.assert-hash-keys( $p, [< O >] ) {
			die "Not implemented yet"
		}
		else {
			say $p.hash.keys.gist;
			warn "Unhandled case"
		}
	}

	method _package_declarator( Mu $p ) {
		if self.assert-hash-keys( $p, [< sym package_def >] ) {
			(
				self._sym( $p.hash.<sym> ),
				self._package_def( $p.hash.<package_def> )
			).flat
		}
		else {
			say $p.hash.keys.gist;
			warn "Unhandled case"
		}
	}

	method _package_def( Mu $p ) {
		if self.assert-hash-keys( $p,
				[< longname statementlist >], [< trait >] ) {
			(
				self._longname( $p.hash.<longname> ),
				self._statementlist( $p.hash.<statementlist> )
			).flat
		}
		elsif self.assert-hash-keys( $p,
				[< blockoid longname >], [< trait >] ) {
			(
				self._longname( $p.hash.<longname> ),
				self._blockoid( $p.hash.<blockoid> )
			).flat
		}
		elsif self.assert-hash-keys( $p, [< blockoid >], [< trait >] ) {
			self._blockoid( $p.hash.<blockoid> )
		}
		else {
			say $p.hash.keys.gist;
			warn "Unhandled case"
		}
	}

	method _parameter( Mu $p ) {
		my Perl6::Element @child;
		my $count = 0;
		for $p.list {
			if self.assert-hash-keys( $_,
				[< param_var type_constraint
				   quant post_constraint >],
				[< default_value modifier trait >] ) {
				# Synthesize the 'from' and 'to' markers for 'where'
				$p.Str ~~ m{ << (where) >> };
				my ( $from ) = $0.from;
				@child.append(
					self._type_constraint(
						$_.hash.<type_constraint>
					)
				);
				@child.append(
					self._param_var( $_.hash.<param_var> )
				);
				@child.append(
					Perl6::Bareword.new(
						:from( $from ),
						:to( $from + 5 ),
						:content( Q{where} )
					)
				);
				@child.append(
					self._post_constraint(
						$_.hash.<post_constraint>
					)
				);
			}
			elsif self.assert-hash-keys( $_,
				[< param_var type_constraint quant >],
				[< default_value modifier trait
				   post_constraint >] ) {
				@child.append(
					self._type_constraint(
						$_.hash.<type_constraint>
					)
				);
				@child.append(
					self._param_var( $_.hash.<param_var> )
				);
			}
			elsif self.assert-hash-keys( $_,
				[< param_var quant default_value >],
				[< modifier trait
				   type_constraint
				   post_constraint >] ) {
				@child.append(
					self._param_var( $_.hash.<param_var> )
				);
				# XXX Should be possible to refactor...
				@child.append(
					self.make-infix-from( $p, Q{=} )
				);
				@child.append(
					self._default_value(
						$_.hash.<default_value>
					).flat
				);
			}
			elsif self.assert-hash-keys( $_,
				[< param_var quant >],
				[< default_value modifier trait
				   type_constraint
				   post_constraint >] ) {
				@child.append(
					self._param_var( $_.hash.<param_var> )#,
#					self._quant( $_.hash.<quant> )
				);
			}
			elsif self.assert-hash-keys( $_,
				[< named_param quant >],
				[< default_value type_constraint modifier
				   trait post_constraint >] ) {
				# Synthesize the 'from' and 'to' markers for ':'
				$p.Str ~~ m{ (':') };
				my ( $from ) = $0.from;
				@child.append(
					Perl6::Operator::Prefix.new(
						:from( $from ),
						:to( $from + 1 ),
						:content( Q{:} )
					),
					self._named_param(
						$_.hash.<named_param>
					)
				);
			}
			elsif self.assert-hash-keys( $_,
				[< type_constraint >],
				[< default_value modifier trait
				   post_constraint >] ) {
				@child.append(
					self._type_constraint(
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

	method _param_var( Mu $p ) {
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

			# leading and trailing space elided
			my $leaf = %sigil-map{$sigil ~ $twigil}.new(
				:from( $p.from ),
				:to( $p.to ),
				:content( $p.Str )
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

			# leading and trailing space elided
			my $leaf = %sigil-map{$sigil ~ $twigil}.new(
				:from( $p.from ),
				:to( $p.to ),
				:content( $content )
			);
			$leaf
		}
		elsif self.assert-hash-keys( $p, [< signature >] ) {
			self._signature( $p.hash.<signature> )
		}
		elsif self.assert-hash-keys( $p, [< sigil >] ) {
			self._sigil( $p.hash.<sigil> )
		}
		else {
			say $p.hash.keys.gist;
			warn "Unhandled case"
		}
	}

	method _pblock( Mu $p ) {
		if self.assert-hash-keys( $p,
				[< lambda blockoid signature >] ) {
			die "Not implemented yet"
		}
		elsif self.assert-hash-keys( $p, [< blockoid >] ) {
			self._blockoid( $p.hash.<blockoid> )
		}
		else {
			say $p.hash.keys.gist;
			warn "Unhandled case"
		}
	}

	method _postcircumfix( Mu $p ) {
		if self.assert-hash-keys( $p, [< arglist O >] ) {
			die "Not implemented yet"
		}
		elsif self.assert-hash-keys( $p, [< semilist O >] ) {
			my $x = $p.hash.<semilist>.Str;
			$x ~~ s{ ^ (\s*) } = ''; my $leading = $0.chars;
			$x ~~ s{ (\s+) $ } = ''; my $trailing = $0.chars;
			# leading and trailing space elided
			# XXX whitespace around text could be done differently?
			Perl6::Bareword.new(
				:from( $p.hash.<semilist>.from + $leading ),
				:to( $p.hash.<semilist>.to - $trailing ),
				:content( $x )
			)
		}
		elsif self.assert-hash-keys( $p, [< nibble O >] ) {
			my $x = $p.hash.<nibble>.Str;
			$x ~~ s{ ^ (\s*) } = ''; my $leading = $0.chars;
			$x ~~ s{ (\s+) $ } = ''; my $trailing = $0.chars;
			# leading and trailing space elided
			# XXX whitespace around text could be done differently?
			Perl6::Bareword.new(
				:from( $p.hash.<nibble>.from + $leading ),
				:to( $p.hash.<nibble>.to - $trailing ),
				:content( $x )
			)
		}
		else {
			say $p.hash.keys.gist;
			warn "Unhandled case"
		}
	}

	method _post_constraint( Mu $p ) {
		# XXX fix later
		self._EXPR( $p.list.[0].hash.<EXPR> )
	}

	method _postfix( Mu $p ) {
		if self.assert-hash-keys( $p, [< sym O >] ) {
			# leading and trailing space elided
			self.make-infix-from( $p.hash.<sym> )
		}
		elsif self.assert-hash-keys( $p, [< dig O >] ) {
			self.make-infix-from( $p.hash.<dig> )
		}
		else {
			say $p.hash.keys.gist;
			warn "Unhandled case"
		}
	}

	method _postop( Mu $p ) {
		warn "Untested method";
		if self.assert-hash-keys( $p,
				[< sym postcircumfix O >] ) {
			die "Not implemented yet"
		}
		elsif self.assert-hash-keys( $p,
				[< sym postcircumfix >], [< O >] ) {
			die "Not implemented yet"
		}
		else {
			say $p.hash.keys.gist;
			warn "Unhandled case"
		}
	}

	method _prefix( Mu $p ) {
		if self.assert-hash-keys( $p, [< sym O >] ) {
			# leading and trailing space elided
			self.make-prefix-from( $p.hash.<sym> )
		}
		else {
			say $p.hash.keys.gist;
			warn "Unhandled case"
		}
	}

	method _quant( Mu $p ) returns Bool {
		$p.hash.<quant>.Bool
	}

	method _quantified_atom( Mu $p ) {
		warn "Untested method";
		if self.assert-hash-keys( $p, [< sigfinal atom >] ) {
			die "Not implemented yet"
		}
		else {
			say $p.hash.keys.gist;
			warn "Unhandled case"
		}
	}

	method _quantifier( Mu $p ) {
		warn "Untested method";
		if self.assert-hash-keys( $p, [< sym min max backmod >] ) {
			die "Not implemented yet"
		}
		elsif self.assert-hash-keys( $p, [< sym backmod >] ) {
			die "Not implemented yet"
		}
		else {
			say $p.hash.keys.gist;
			warn "Unhandled case"
		}
	}

	method _quibble( Mu $p ) {
		warn "Untested method";
		if self.assert-hash-keys( $p, [< babble nibble >] ) {
			die "Not implemented yet"
		}
		else {
			say $p.hash.keys.gist;
			warn "Unhandled case"
		}
	}

	method _quote( Mu $p ) {
		if self.assert-hash-keys( $p, [< sym quibble rx_adverbs >] ) {
			die "Not implemented yet"
		}
		elsif self.assert-hash-keys( $p, [< sym rx_adverbs sibble >] ) {
			die "Not implemented yet"
		}
		elsif self.assert-hash-keys( $p, [< quibble >] ) {
			# XXX This should properly call quibble, but that's
			# XXX for later.
			# leading and trailing space elided
			Perl6::String.new(
				:from( $p.from ),
				:to( $p.to ),
				:content( $p.Str ),
				:bare( $p.hash.<quibble>.hash.<nibble>.Str )
			)
		}
		elsif self.assert-hash-keys( $p, [< nibble >] ) {
			Perl6::String.new(
				:from( $p.hash.<nibble>.from ),
				:to( $p.hash.<nibble>.to ),
				:content( $p.Str ),
				:bare( $p.hash.<nibble>.Str )
			)
		}
		else {
			say $p.hash.keys.gist;
			warn "Unhandled case"
		}
	}

	method _quotepair( Mu $p ) {
		warn "Untested method";
		if $p.list {
			my Perl6::Element @child;
			for $p.list {
				if self.assert-hash-keys( $_,
						[< identifier >] ) {
					die "Not implemented yet"
				}
				else {
					say $p.hash.keys.gist;
					warn "Unhandled case"
				}
			}
			@child
		}
		elsif self.assert-hash-keys( $p,
				[< circumfix bracket radix >],
				[< exp base >] ) {
			die "Not implemented yet"
		}
		elsif self.assert-hash-keys( $p, [< identifier >] ) {
			self._identifier( $p.hash.<identifier> )
		}
		else {
			say $p.hash.keys.gist;
			warn "Unhandled case"
		}
	}

	method _radix( Mu $p ) returns Int {
		$p.hash.<radix>.Int
	}

	method _rad_number( Mu $p ) returns Perl6::Element {
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
			# leading and trailing space elided
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

	method _regex_declarator( Mu $p ) {
		if self.assert-hash-keys( $p, [< sym regex_def >] ) {
			(
				self._sym( $p.hash.<sym> ),
				self._regex_def( $p.hash.<regex_def> )
			).flat
		}
		else {
			say $p.hash.keys.gist;
			warn "Unhandled case"
		}
	}

	method _regex_def( Mu $p ) {
		if self.assert-hash-keys( $p,
				[< deflongname nibble >],
				[< signature trait >] ) {
			# leading and trailing space elided
			my $nibble = $p.hash.<nibble>.Str;
			$nibble ~~ s{ (\s+) } = ''; my $inset = $0.chars;
			my Perl6::Element @child;
			@child.push(
				# XXX Should this be expanded?
				# XXX And if so, as an attribute
				Perl6::Regex.new(
					:from( $p.hash.<nibble>.from ),
					:to( $p.hash.<nibble>.to - $inset ),
					:content( $nibble )
				)
			);
			(
				self._deflongname( $p.hash.<deflongname> ),
				Perl6::Block.new(
					:delimiter( '{', '}' ),
					:child( @child )
				)
			).flat
		}
		else {
			say $p.hash.keys.gist;
			warn "Unhandled case"
		}
	}

	method _right( Mu $p ) returns Perl6::Element {
		$p.hash.<right>.Bool
	}

	method _routine_declarator( Mu $p ) {
		if self.assert-hash-keys( $p,
				[< sym routine_def >] ) {
			(
				self._sym( $p.hash.<sym> ),
				self._routine_def( $p.hash.<routine_def> )
			).flat
		}
		elsif self.assert-hash-keys( $p, [< sym method_def >] ) {
			(
				self._sym( $p.hash.<sym> ),
				self._method_def( $p.hash.<method_def> )
			).flat
		}
		else {
			say $p.hash.keys.gist;
			warn "Unhandled case"
		}
	}

	method _routine_def( Mu $p ) {
		if self.assert-hash-keys( $p,
				[< blockoid deflongname multisig >],
				[< trait >] ) {
			(
				self._deflongname( $p.hash.<deflongname> ),
				self._multisig( $p.hash.<multisig> ),
				self._blockoid( $p.hash.<blockoid> )
			).flat
		}
		elsif self.assert-hash-keys( $p,
				[< blockoid deflongname trait >] ) {
			(
				self._deflongname( $p.hash.<deflongname> ),
				self._trait( $p.hash.<trait> ),
				self._blockoid( $p.hash.<blockoid> )
			).flat
		}
		elsif self.assert-hash-keys( $p,
				[< blockoid multisig >], [< trait >] ) {
			(
				self._multisig( $p.hash.<multisig> ),
				self._blockoid( $p.hash.<blockoid> )
			).flat
		}
		elsif self.assert-hash-keys( $p,
				[< blockoid deflongname >], [< trait >] ) {
			(
				self._deflongname( $p.hash.<deflongname> ),
				self._blockoid( $p.hash.<blockoid> )
			).flat
		}
		elsif self.assert-hash-keys( $p, [< blockoid >], [< trait >] ) {
			self._blockoid( $p.hash.<blockoid> )
		}
		else {
			say $p.hash.keys.gist;
			warn "Unhandled case"
		}
	}

	method _rx_adverbs( Mu $p ) {
		warn "Untested method";
		if self.assert-hash-keys( $p, [< quotepair >] ) {
			self._quotepair( $p.hash.<quotepair> )
		}
		elsif self.assert-hash-keys( $p, [< >], [< quotepair >] ) {
			die "Not implemented yet"
		}
		else {
			say $p.hash.keys.gist;
			warn "Unhandled case"
		}
	}

	method _scoped( Mu $p ) {
		# XXX DECL seems to be a mirror of declarator. This probably
		# XXX will turn out to be not true later on.
		#
		if self.assert-hash-keys( $p,
					[< multi_declarator DECL typename >] ) {
			(
				self._typename( $p.hash.<typename> ),
				self._multi_declarator(
					$p.hash.<multi_declarator>
				)
			)
		}
		elsif self.assert-hash-keys( $p,
				[< package_declarator DECL >],
				[< typename >] ) {
			self._package_declarator( $p.hash.<package_declarator> )
		}
		elsif self.assert-hash-keys( $p,
				[< package_declarator sym >] ) {
			(
				self._sym( $p.hash.<sym> ),
				self._package_declarator(
					$p.hash.<package_declarator>
				)
			)
		}
		elsif self.assert-hash-keys( $p,
				[< declarator DECL >], [< typename >] ) {
			self._declarator( $p.hash.<declarator> )
		}
		else {
			say $p.hash.keys.gist;
			warn "Unhandled case"
		}
	}

	method _scope_declarator( Mu $p ) {
		if self.assert-hash-keys( $p, [< sym scoped >] ) {
			(
				self._sym( $p.hash.<sym> ),
				self._scoped( $p.hash.<scoped> )
			).flat
		}
		else {
			say $p.hash.keys.gist;
			warn "Unhandled case"
		}
	}

	method _semiarglist( Mu $p ) {
		if self.assert-hash-keys( $p, [< arglist >] ) {
			self._arglist( $p.hash.<arglist> )
		}
		else {
			say $p.hash.keys.gist;
			warn "Unhandled case"
		}
	}

	method _semilist( Mu $p ) {
		CATCH {
			when X::Multi::NoMatch { }
		}
		if $p.hash.<statement>.list.[0].hash.<EXPR> {
			my Perl6::Element @child;
			@child.push(
				self._EXPR( $p.hash.<statement>.list.[0].hash.<EXPR> )
			);
			self.make-postcircumfix( $p, @child )
		}
		elsif self.assert-hash-keys( $p, [< statement >] ) {
			self._EXPR( $p.hash.<statement>.list.[0].<EXPR> )
		}
		else {
			say $p.hash.keys.gist;
			warn "Unhandled case"
		}
	}

	method _separator( Mu $p ) {
		warn "Untested method";
		if self.assert-hash-keys( $p, [< septype quantified_atom >] ) {
			die "Not implemented yet"
		}
		else {
			say $p.hash.keys.gist;
			warn "Unhandled case"
		}
	}

	method _septype( Mu $p ) returns Str {
		$p.hash.<septype>.Str
	}

	method _shape( Mu $p ) returns Str {
		$p.hash.<shape>.Str
	}

	method _sibble( Mu $p ) {
		warn "Untested method";
		if self.assert-hash-keys( $p, [< right babble left >] ) {
			die "Not implemented yet"
		}
		else {
			say $p.hash.keys.gist;
			warn "Unhandled case"
		}
	}

	method _sigfinal( Mu $p ) {
		warn "Untested method";
		if self.assert-hash-keys( $p, [< normspace >] ) {
			self._normspace( $p.hash.<normspace> )
		}
		else {
			say $p.hash.keys.gist;
			warn "Unhandled case"
		}
	}

	method _sigil( Mu $p ) returns Str {
		$p.hash.<sym>.Str
	}

	method _sigmaybe( Mu $p ) {
		warn "Untested method";
		if self.assert-hash-keys( $p,
				[< parameter typename >],
				[< param_sep >] ) {
			die "Not implemented yet"
		}
		elsif self.assert-hash-keys( $p, [],
				[< param_sep parameter >] ) {
			die "Not implemented yet"
		}
		else {
			say $p.hash.keys.gist;
			warn "Unhandled case"
		}
	}

	# XXX Move Circumfix out
	method _signature( Mu $p ) {
		if self.assert-hash-keys( $p,
				[< parameter typename >],
				[< param_sep >] ) {
			my Perl6::Element @child;
			@child.push( self._typename( $p.hash.<typename> ) );
			@child.push( self._parameter( $p.hash.<parameter> ) );
			Perl6::Operator::Circumfix.new(
				:delimiter( '(', ')' ),
				:child( @child )
			)
		}
		elsif self.assert-hash-keys( $p,
				[< parameter >],
				[< param_sep >] ) {
			my Perl6::Element @child;
			@child.append( self._parameter( $p.hash.<parameter> ) );
			Perl6::Operator::Circumfix.new(
				:delimiter( '(', ')' ),
				:child( @child )
			)
		}
		elsif self.assert-hash-keys( $p,
				[< param_sep >],
				[< parameter >] ) {
			my Perl6::Element @child;
			@child.push( self._parameter( $p.hash.<parameter> ) );
			Perl6::Operator::Circumfix.new(
				:delimiter( '(', ')' ),
				:child( @child )
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

	method _smexpr( Mu $p ) {
		warn "Untested method";
		if self.assert-hash-keys( $p, [< EXPR >] ) {
			self._EXPR( $p.hash.<EXPR> )
		}
		else {
			say $p.hash.keys.gist;
			warn "Unhandled case"
		}
	}

	method _specials( Mu $p ) {
		$p.hash.<specials>.Bool
	}

	method _statement_control( Mu $p ) {
		warn "Untested method";
		if self.assert-hash-keys( $p, [< block sym e1 e2 e3 >] ) {
			die "Not implemented yet"
		}
		elsif self.assert-hash-keys( $p, [< pblock sym EXPR wu >] ) {
			die "Not implemented yet"
		}
		elsif self.assert-hash-keys( $p, [< doc sym module_name >] ) {
			die "Not implemented yet"
		}
		elsif self.assert-hash-keys( $p, [< doc sym version >] ) {
			die "Not implemented yet"
		}
		elsif self.assert-hash-keys( $p, [< sym else xblock >] ) {
			die "Not implemented yet"
		}
		elsif self.assert-hash-keys( $p, [< xblock sym wu >] ) {
			die "Not implemented yet"
		}
		elsif self.assert-hash-keys( $p, [< sym xblock >] ) {
			die "Not implemented yet"
		}
		elsif self.assert-hash-keys( $p, [< block sym >] ) {
			die "Not implemented yet"
		}
		else {
			say $p.hash.keys.gist;
			warn "Unhandled case"
		}
	}

	method _statement( Mu $p ) {
		# N.B. we don't care so much *if* there's a list as *what's*
		# in the list. In other words we can assume that the content
		# is what we consider valid, so we can relax our requirements.
		if $p.list {
			my Perl6::Element @child;
			for $p.list {
				if self.assert-hash-keys( $_,
						[< statement_mod_loop
						   EXPR >] ) {
					die "Not implemented yet"
				}
				elsif self.assert-hash-keys( $_,
						[< statement_mod_cond
						   EXPR >] ) {
					die "Not implemented yet"
				}
				elsif self.assert-hash-keys( $_, [< EXPR >] ) {
					@child.append(
						self._EXPR( $_.hash.<EXPR> )
					)
				}
				elsif self.assert-hash-keys( $_,
						[< statement_control >] ) {
#					self._statement_control(
#						$_.hash.<statement_control>
#					)
				}
				elsif self.assert-hash-keys( $_, [],
						[< statement_control >] ) {push
					die "Not implemented yet"
				}
				else {
					say $p.hash.keys.gist;
					warn "Unhandled case"
				}
			}
			@child
		}
		elsif self.assert-hash-keys( $p, [< EXPR >] ) {
			Perl6::Statement.new(
				:child(
					self._EXPR( $p.hash.<EXPR> )
				)
			)
		}
		elsif self.assert-hash-keys( $p, [< statement_control >] ) {
			Perl6::Statement.new(
				:child(
					self._statement_control(
						$p.hash.<statement_control>
					)
				)
			)
		}
		else {
			say $p.hash.keys.gist;
			warn "Unhandled case"
		}
	}

	method _statementlist( Mu $p ) returns Array[Perl6::Element] {
		my $statement = $p.hash.<statement>;
		my Perl6::Element @child = map {
			self._statement( $_ )
		}, $statement.list;
		@child
	}

	method _statement_mod_cond( Mu $p ) {
		warn "Untested method";
		if self.assert-hash-keys( $p, [< sym modifier_expr >] ) {
			die "Not implemented yet"
		}
		else {
			say $p.hash.keys.gist;
			warn "Unhandled case"
		}
	}

	method _statement_mod_loop( Mu $p ) {
		warn "Untested method";
		if self.assert-hash-keys( $p, [< sym smexpr >] ) {
			die "Not implemented yet"
		}
		else {
			say $p.hash.keys.gist;
			warn "Unhandled case"
		}
	}

	method _statement_prefix( Mu $p ) {
		warn "Untested method";
		if self.assert-hash-keys( $p, [< sym blorst >] ) {
			die "Not implemented yet"
		}
		else {
			say $p.hash.keys.gist;
			warn "Unhandled case"
		}
	}

	method _subshortname( Mu $p ) {
		warn "Untested method";
		if self.assert-hash-keys( $p, [< desigilname >] ) {
			self._desigilname( $p.hash.<desigilname> )
		}
		else {
			say $p.hash.keys.gist;
			warn "Unhandled case"
		}
	}

	method _sym( Mu $p ) {
		if $p.list {
			my Perl6::Element @child;
			for $p.list {
				if $_.Str {
					die "Not implemented yet"
				}
				else {
					say $p.hash.keys.gist;
					warn "Unhandled case"
				}
			}
			@child
		}
		elsif $p.Str {
			# leading and trailing space elided
			Perl6::Bareword.new(
				:from( $p.from ),
				:to( $p.to ),
				:content( $p.Str )
			)
		}
		elsif $p.Bool and $p.Str eq '+' {
			die "Not implemented yet"
		}
		elsif $p.Bool and $p.Str eq '' {
			die "Not implemented yet"
		}
		else {
			say $p.hash.keys.gist;
			warn "Unhandled case"
		}
	}

	method _term( Mu $p ) {
		warn "Untested method";
		if self.assert-hash-keys( $p, [< methodop >] ) {
			self._methodop( $p.hash.<methodop> )
		}
		else {
			say $p.hash.keys.gist;
			warn "Unhandled case"
		}
	}

	method _termalt( Mu $p ) {
		warn "Untested method";
		if $p.list {
			my Perl6::Element @child;
			for $p.list {
				if self.assert-hash-keys( $_, [< termconj >] ) {
					die "Not implemented yet"
				}
				else {
					say $p.hash.keys.gist;
					warn "Unhandled case"
				}
			}
			@child
		}
		else {
			say $p.hash.keys.gist;
			warn "Unhandled case"
		}
	}

	method _termaltseq( Mu $p ) {
		if self.assert-hash-keys( $p, [< termconjseq >] ) {
			self._termconjseq( $p.hash.<termconjseq> )
		}
		else {
			say $p.hash.keys.gist;
			warn "Unhandled case"
		}
	}

	method _termconj( Mu $p ) {
		warn "Untested method";
		if $p.list {
			my Perl6::Element @child;
			for $p.list {
				if self.assert-hash-keys( $_, [< termish >] ) {
					@child.push(
						self._termish(
							$p.hash.<termish>
						)
					)
				}
				else {
					say $p.hash.keys.gist;
					warn "Unhandled case"
				}
			}
			@child
		}
		else {
			say $p.hash.keys.gist;
			warn "Unhandled case"
		}
	}

	method _termconjseq( Mu $p ) {
		# XXX Work on this later.
		if $p.list {
			my Perl6::Element @child;
			for $p.list {
				if self.assert-hash-keys( $_, [< termalt >] ) {
					die "Not implemented yet"
				}
				else {
					say $p.hash.keys.gist;
					warn "Unhandled case"
				}
			}
			@child
		}
		elsif self.assert-hash-keys( $p, [< termalt >] ) {
			self._termalt( $p.hash.<termalt> )
		}
		elsif $p.Str {
			# XXX
			my $str = $p.Str;
			$str ~~ s{\s+ $} = '';
key-boundary $p if $p.Str;
warn 46;
			Perl6::Bareword.new(
				:from( $p.from ),
				:to( $p.to ),
				:content( $str )
			)
		}
		else {
			say $p.hash.keys.gist;
			warn "Unhandled case"
		}
	}

	method _term_init( Mu $p ) {
		warn "Untested method";
		if self.assert-hash-keys( $p, [< sym EXPR >] ) {
			die "Not implemented yet"
		}
		else {
			say $p.hash.keys.gist;
			warn "Unhandled case"
		}
	}

	method _termish( Mu $p ) {
		warn "Untested method";
		for $p.list {
			next if self.assert-hash-keys( $_, [< noun >] );
		}
		if self.assert-hash-keys( $p, [< noun >] ) {
			self._noun( $p.hash.<noun> )
		}
		else {
			say $p.hash.keys.gist;
			warn "Unhandled case"
		}
	}

	method _termseq( Mu $p ) {
		if self.assert-hash-keys( $p, [< termaltseq >] ) {
			self._termaltseq( $p.hash.<termaltseq> )
		}
		else {
			say $p.hash.keys.gist;
			warn "Unhandled case"
		}
	}

	method _trait( Mu $p ) {
		# XXX Sigh, something else to fix.
#`(
		my Perl6::Element @child = map {
#			if self.assert-hash-keys( $_, [< trait_mod >] ) {
				self._trait_mod( $_.hash.<trait_mod> )
#			}
#			else {
#				say $_.hash.keys.gist;
#				warn "Unhandled case"
#			}
		}, $p.list;
		@child
)
		self._trait_mod( $p.list.[0].hash.<trait_mod> )
	}

	method _trait_mod( Mu $p ) {
		if self.assert-hash-keys( $p, [< sym typename >] ) {
			(
				self._sym( $p.hash.<sym> ),
				self._typename( $p.hash.<typename> )
			).flat
		}
		else {
			say $p.hash.keys.gist;
			warn "Unhandled case"
		}
	}

	method _twigi( Mu $p ) returns Str {
		$p.hash.<sym>.Str
	}

	method _type_constraint( Mu $p ) {
		my Perl6::Element @child;
		for $p.list {
			if self.assert-hash-keys( $_, [< typename >] ) {
				@child.append(
					self._typename( $_.hash.<typename> )
				)
			}
			elsif self.assert-hash-keys( $_, [< value >] ) {
				@child.append(
					self._value( $_.hash.<value> )
				)
			}
			else {
				say $p.hash.keys.gist;
				warn "Unhandled case"
			}
		}
#		if self.assert-hash-keys( $p, [< value >] ) {
#			self._value( $p.hash.<value> )
#		}
#		elsif self.assert-hash-keys( $p, [< typename >] ) {
#			self._typename( $p.hash.<typename> )
#		}
#		else {
#			say $p.hash.keys.gist;
#			warn "Unhandled case"
#		}
		@child
	}

	method _type_declarator( Mu $p ) {
		warn "Untested method";
		if self.assert-hash-keys( $p,
				[< sym initializer variable >], [< trait >] ) {
			die "Not implemented yet"
		}
		elsif self.assert-hash-keys( $p,
				[< sym initializer defterm >], [< trait >] ) {
			die "Not implemented yet"
		}
		elsif self.assert-hash-keys( $p, [< sym initializer >] ) {
			die "Not implemented yet"
		}
		else {
			say $p.hash.keys.gist;
			warn "Unhandled case"
		}
	}

	method _typename( Mu $p ) {
		CATCH { when X::Hash::Store::OddNumber { .resume } } # XXX ?...
		for $p.list {
			if self.assert-hash-keys( $_,
					[< longname colonpairs >],
					[< colonpair >] ) {
				# XXX Probably could be narrowed.
				# leading and trailing space elided
				return
					Perl6::Bareword.new(
						:from( $_.from ),
						:to( $_.to ),
						:content( $_.Str )
					)
			}
			elsif self.assert-hash-keys( $_,
					[< longname colonpair >] ) {
				# XXX Fix this later.
key-boundary $_;
warn 48;
				return
					Perl6::Bareword.new(
						:from( -42 ),
						:top( -42 ),
						:content( $_.Str )
					)
			}
			elsif self.assert-hash-keys( $_,
					[< longname >], [< colonpairs >] ) {
				# XXX Can probably be narrowed
				# leading and trailing space elided
				return
					Perl6::Bareword.new(
						:from( $_.from ),
						:to( $_.to ),
						:content( $_.Str )
					)
			}
			elsif self.assert-hash-keys( $_,
					[< longname >], [< colonpair >] ) {
				# XXX Fix this later.
				return
					self._longname( $_.hash.<longname> )
			}
			else {
				say $_.hash.keys.gist;
				warn "Unhandled case"
			}
		}

		if self.assert-hash-keys( $p, [< longname colonpairs >] ) {
			self._longname( $p.hash.<longname> )
		}
		elsif self.assert-hash-keys( $p,
				[< longname >], [< colonpair >] ) {
			self._longname( $p.hash.<longname> )
		}
		else {
			say $p.hash.keys.gist;
			warn "Unhandled case"
		}
	}

	method _val( Mu $p ) {
		if self.assert-hash-keys( $p,
				[< prefix OPER >],
				[< prefix_postfix_meta_operator >] ) {
			die "Not implemented yet"
		}
		elsif self.assert-hash-keys( $p, [< value >] ) {
			self._value( $p.hash.<value> )
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

	method _value( Mu $p ) returns Perl6::Element {
		if self.assert-hash-keys( $p, [< number >] ) {
			self._number( $p.hash.<number> )
		}
		elsif self.assert-hash-keys( $p, [< quote >] ) {
			self._quote( $p.hash.<quote> )
		}
		else {
			say $p.hash.keys.gist;
			warn "Unhandled case"
		}
	}

	method _var( Mu $p ) returns Perl6::Element {
		if self.assert-hash-keys( $p,
				[< sigil desigilname >] ) {
			# XXX For heavens' sake refactor.
			my $sigil       = $p.hash.<sigil>.Str;
			my $twigil      = $p.hash.<twigil> ??
					  $p.hash.<twigil>.Str !! '';
			my $desigilname = $p.hash.<desigilname> ??
					  $p.hash.<desigilname>.Str !! '';
			my $content     = $p.hash.<sigil> ~ $twigil ~ $desigilname;
			# leading and trailing space elided
			%sigil-map{$sigil ~ $twigil}.new(
				:from( $p.from ),
				:to( $p.to ),
				:content( $content )
			)
		}
		elsif self.assert-hash-keys( $p, [< variable >] ) {
			self._variable( $p.hash.<variable> )
		}
		else {
			say $p.hash.keys.gist;
			warn "Unhandled case"
		}
	}

	method _variable_declarator( Mu $p ) {
		if self.assert-hash-keys( $p,
			[< semilist variable shape >],
			[< postcircumfix signature trait
			   post_constraint >] ) {
			die "Not implemented yet"
		}
		elsif self.assert-hash-keys( $p,
				[< variable post_constraint >],
				[< semilist postcircumfix signature trait >] ) {
			# Synthesize the 'from' and 'to' markers for 'where'
			$p.Str ~~ m{ << (where) >> };
			my ( $from ) = $0.from;
			(
				self._variable( $p.hash.<variable> ),
				# leading and trailing space elided
				Perl6::Bareword.new(
					:from( $p.from + $from ),
					:to( $p.from + $from + 5 ),
					:content( Q{where} )
				),
				self._post_constraint(
					$p.hash.<post_constraint>
				)
			)
		}
		elsif self.assert-hash-keys( $p,
				[< variable >],
				[< semilist postcircumfix signature
				   trait post_constraint >] ) {
			self._variable( $p.hash.<variable> )
		}
		else {
			say $p.hash.keys.gist;
			warn "Unhandled case"
		}
	}

	method _variable( Mu $p ) {
		if self.assert-hash-keys( $p, [< contextualizer >] ) {
warn "*** contextualizer fired";
			return;
		}

		my $sigil       = $p.hash.<sigil>.Str;
		my $twigil      = $p.hash.<twigil> ??
			          $p.hash.<twigil>.Str !! '';
		my $desigilname = $p.hash.<desigilname> ??
				  $p.hash.<desigilname>.Str !! '';
		my $content     = $p.hash.<sigil> ~ $twigil ~ $desigilname;

		# leading and trailing space elided
		my $leaf = %sigil-map{$sigil ~ $twigil}.new(
			:from( $p.from ),
			:to( $p.to ),
			:content( $content )
		);
		return $leaf;
	}

	method _version( Mu $p ) {
		warn "Untested method";
		if self.assert-hash-keys( $p, [< vnum vstr >] ) {
			die "Not implemented yet"
		}
		else {
			say $p.hash.keys.gist;
			warn "Unhandled case"
		}
	}

	method _vstr( Mu $p ) returns Int {
		$p.hash.<vstr>.Int
	}

	method _vnum( Mu $p ) {
		warn "Untested method";
		if $p.list {
			my Perl6::Element @child;
			for $p.list {
				if self.assert-Int( $_ ) {
					die "Not implemented yet";
				}
				else {
					say $p.hash.keys.gist;
					warn "Unhandled case"
				}
			}
			@child
		}
		else {
			say $p.hash.keys.gist;
			warn "Unhandled case"
		}
	}

	method _wu( Mu $p ) returns Str {
		$p.hash.<wu>.Str
	}

	method _xblock( Mu $p ) {
		warn "Untested method";
		if $p.list {
			my Perl6::Element @child;
			for $p.list {
				if self.assert-hash-keys( $_,
						[< pblock EXPR >] ) {
					die "Not implemented yet";
				}
				else {
					say $p.hash.keys.gist;
					warn "Unhandled case"
				}
			}
			@child
		}
		elsif self.assert-hash-keys( $p, [< pblock EXPR >] ) {
			die "Not implemented yet";
		}
		elsif self.assert-hash-keys( $p, [< blockoid >] ) {
#			self._blockoid( $p.hash.<blockoid> )
		}
		else {
			say $p.hash.keys.gist;
			warn "Unhandled case"
		}
	}
}

#`(

Here's a collection of all the terms I could find in the grammars, with the
ones I've caught marked with 'XXX' just so they'll stand out.

I actually expect most of these to be unreachable.

role STD {
    token opener {}
    method balanced {}
    method unbalanced {}

    token starter {}
    token stopper {}

    method quote_lang {}
    token babble {}

    my class Herestub {
        method delim {}
        method orignode {}
        method lang {}
    }

    role herestop {
        method parsing_heredoc {}
    }

    method heredoc {}
    token cheat_heredoc {}
    method queue_heredoc {}
    token quibble {}
    method nibble {}
    token obsbrace {}

    method FAILGOAL {}

    method security($payload) {}

    method malformed($what) {}
    method missing_block() {}
    method missing($what) {}

    token experimental($feature) {}

    method EXPR_nonassoc($cur, $left, $right) {}

    method obs($old, $new, $when = 'in Perl 6') {}
    method obsvar($name) {}

    method dupprefix($prefixes) {}

    method mark_variable_used($name) {}

    method check_variable($var) {}

    token RESTRICTED {}
}

grammar Perl6::Grammar {
    method TOP { }

    ## Lexer stuff

    token apostrophe { }
    token identifier { }
    token name { }
    token morename { }
    token longname { }
    token deflongname { }
    token subshortname { }
    token sublongname { }
    token deftermnow { }
    token defterm { }
    token module_name { }
    token end_keyword { }
    token end_prefix { }
    token spacey { }
    token kok { }
    token tok { }
    token ENDSTMT { }
    method ws() { }
    token _ws { }
    token unsp { }
    token vws { }
    token unv { }

    proto token comment {}

    token comment:sym<#> { }
    token comment:sym<#`(...)> { }
    token comment:sym<#|(...)> { }
    token comment:sym<#|> { }
    token comment:sym<#=(...)> { }
    token comment:sym<#=> { }

    method attach_leading_docs() { }
    method attach_trailing_docs($doc) { }
    token pod_content_toplevel { }

    proto token pod_content { }
    token pod_content:sym<block> { }
    token pod_content:sym<text> { }
    token pod_content:sym<config> { }

    proto token pod_textcontent { }
    token pod_textcontent:sym<regular> { }
    token pod_textcontent:sym<code> { }
    token pod_formatting_code { }
    token pod_balanced_braces { }
    token pod_string { }
    token pod_string_character { }

    proto token pod_block { }
    token pod_configuration($spaces = '') { }
    token pod_block:sym<delimited_comment> { }
    token pod_block:sym<delimited> { }
    token pod_block:sym<delimited_table> { }
    token pod_block:sym<delimited_code> { }

    token delimited_code_content($spaces = '') { }
    token table_row { }
    token table_row_or_blank { }

    token pod_block:sym<finish> { }
    token pod_block:sym<paragraph> { }
    token pod_block:sym<paragraph_comment> { }
    token pod_block:sym<paragraph_table> { }
    token pod_block:sym<paragraph_code> { }
    token pod_block:sym<abbreviated> { }
    token pod_block:sym<abbreviated_comment> { }
    token pod_block:sym<abbreviated_table> { }
    token pod_block:sym<abbreviated_code> { }

    token pod_line { }
    token pod_newline { }
    token pod_code_parent { }

    token install_doc_phaser { }
    token vnum { }
    token version { }

    ## Top-level rules

    token comp_unit { }
    rule statementlist { }
    method shallow_copy { }
    rule semilist { }
    rule sequence { }
    token label { }
    token statement { }
    token eat_terminator { }
    token xblock { }
    token pblock { }
    token lambda { }
    token block { }
    token blockoid { }
    token unitstart { }
    token you_are_here { }
    token newpad { }
    token finishpad { }

    token bom { }

    proto token terminator { }

    token terminator:sym<;> {}
    token terminator:sym<()> { }
    token terminator:sym<[]> { }
    token terminator:sym<{}> { }
    token terminator:sym<ang> { }
    token terminator:sym<if>     {  }
    token terminator:sym<unless> {  }
    token terminator:sym<while>  {  }
    token terminator:sym<until>  {  }
    token terminator:sym<for>    {  }
    token terminator:sym<given>  {  }
    token terminator:sym<when>   {  }
    token terminator:sym<with>   {  }
    token terminator:sym<without> { }
    token terminator:sym<arrow>  { }


    token stdstopper { }

    ## Statement control

    proto rule statement_control { <...> }

    rule statement_control:sym<if> { }

    rule statement_control:sym<unless> { }

    rule statement_control:sym<while> { }

    rule statement_control:sym<repeat> { }

    rule statement_control:sym<for> { }

    rule statement_control:sym<whenever> { }

    rule statement_control:sym<foreach> { }

    token statement_control:sym<loop> { }

    rule statement_control:sym<need> { }

    token statement_control:sym<import> { }

    token statement_control:sym<no> { }

    token statement_control:sym<use> { }

    method FOREIGN_LANG($lang, $regex, *@args) { }

    rule statement_control:sym<require> { }

    rule statement_control:sym<given> { }
    rule statement_control:sym<when> { }
    rule statement_control:sym<default> { }

    rule statement_control:sym<CATCH> {}
    rule statement_control:sym<CONTROL> {}
    rule statement_control:sym<QUIT> {}

    proto token statement_prefix {}
    token statement_prefix:sym<BEGIN>   { }
    token statement_prefix:sym<COMPOSE> { }
    token statement_prefix:sym<TEMP>    { }
    token statement_prefix:sym<CHECK>   { }
    token statement_prefix:sym<INIT>    { }
    token statement_prefix:sym<ENTER>   { }
    token statement_prefix:sym<FIRST>   { }

    token statement_prefix:sym<END>   {  }
    token statement_prefix:sym<LEAVE> {  }
    token statement_prefix:sym<KEEP>  {  }
    token statement_prefix:sym<UNDO>  {  }
    token statement_prefix:sym<NEXT>  {  }
    token statement_prefix:sym<LAST>  {  }
    token statement_prefix:sym<PRE>   {  }
    token statement_prefix:sym<POST>  {  }
    token statement_prefix:sym<CLOSE> {  }

    token statement_prefix:sym<race>    { }
    token statement_prefix:sym<hyper>   { }
    token statement_prefix:sym<eager>   { }
    token statement_prefix:sym<lazy>    { }
    token statement_prefix:sym<sink>    { }
    token statement_prefix:sym<try>     { }
    token statement_prefix:sym<quietly> { }
    token statement_prefix:sym<gather>  { }
    token statement_prefix:sym<once>    { }
    token statement_prefix:sym<start>   { }
    token statement_prefix:sym<supply>  { }
    token statement_prefix:sym<react>   { }
    token statement_prefix:sym<do>      { }
    token statement_prefix:sym<DOC>     { }

    token blorst { }

    ## Statement modifiers

    proto rule statement_mod_cond { }

    token modifier_expr { }
    token smexpr { }

    rule statement_mod_cond:sym<if>     { }
    rule statement_mod_cond:sym<unless> { }
    rule statement_mod_cond:sym<when>   { }
    rule statement_mod_cond:sym<with>   { }
    rule statement_mod_cond:sym<without>{ }

    proto rule statement_mod_loop  { }

    rule statement_mod_loop:sym<while> { }
    rule statement_mod_loop:sym<until> { }
    rule statement_mod_loop:sym<for>   { }
    rule statement_mod_loop:sym<given> { }

    ## Terms

    token term:sym<fatarrow>           { }
    token term:sym<colonpair>          { }
    token term:sym<variable>           { }
    token term:sym<package_declarator> { }
    token term:sym<scope_declarator>   { }
    token term:sym<routine_declarator> { }
    token term:sym<multi_declarator>   { }
    token term:sym<regex_declarator>   { }
    token term:sym<circumfix>          { }
    token term:sym<statement_prefix>   { }
    token term:sym<**>                 { }
    token term:sym<*>                  { }
    token term:sym<lambda>             { }
    token term:sym<type_declarator>    { }
    token term:sym<value>              { }
    token term:sym<unquote>            { }
    token term:sym<!!>                 { }
    token term:sym<∞>                  { }

    token term:sym<::?IDENT> { }
    token term:sym<p5end> { }
    token term:sym<p5data> { }

    token infix:sym<lambda> { }

    token term:sym<undef> { }

    token term:sym<new> { }

    token fatarrow { }

    token coloncircumfix { }

    token colonpair { }

    token colonpair_variable { }

    proto token special_variable { }

    token special_variable:sym<$!{ }> { }

    token special_variable:sym<$~> { }

    token special_variable:sym<$`> { }

    token special_variable:sym<$@> { }

    # TODO: use actual variable in error message
    token special_variable:sym<$#> { }

    token special_variable:sym<$$> { }
    token special_variable:sym<$%> { }

    # TODO: $^X and other "caret" variables

    token special_variable:sym<$^> { }
    token special_variable:sym<$&> { }
    token special_variable:sym<$*> { }
    token special_variable:sym<$=> { }
    token special_variable:sym<@+> { }
    token special_variable:sym<%+> { }
    token special_variable:sym<$+[ ]> { }
    token special_variable:sym<@+[ ]> { }
    token special_variable:sym<@+{ }> { }
    token special_variable:sym<@-> { }
    token special_variable:sym<%-> { }
    token special_variable:sym<$-[ ]> { }
    token special_variable:sym<@-[ ]> { }
    token special_variable:sym<%-{ }> { }
    token special_variable:sym<$/> { }
    token special_variable:sym<$\\> { }
    token special_variable:sym<$|> { }
    token special_variable:sym<$:> { }
    token special_variable:sym<$;> { }
    token special_variable:sym<$'> { }
    token special_variable:sym<$"> { }
    token special_variable:sym<$,> { }
    token special_variable:sym<$.> { }
    token special_variable:sym<$?> { }
    token special_variable:sym<$]> { }
    regex special_variable:sym<${ }> { }

    token desigilname { }

    token variable { }

    token contextualizer { }

    token sigil { }

    proto token twigil { }
    token twigil:sym<.> { }
    token twigil:sym<!> { }
    token twigil:sym<^> { }
    token twigil:sym<:> { }
    token twigil:sym<*> { }
    token twigil:sym<?> { }
    token twigil:sym<=> { }
    token twigil:sym<~> { }

    proto token package_declarator { }
    token package_declarator:sym<package> { }
    token package_declarator:sym<module> { }
    token package_declarator:sym<class> { }
    token package_declarator:sym<grammar> { }
    token package_declarator:sym<role> { }
    token package_declarator:sym<knowhow> { }
    token package_declarator:sym<native> { }
    token package_declarator:sym<slang> { }
    token package_declarator:sym<trusts> { }
    rule package_declarator:sym<also> { }

    rule package_def { }

    token declarator { }

    proto token multi_declarator { }
    token multi_declarator:sym<multi> { }
    token multi_declarator:sym<proto> { }
    token multi_declarator:sym<only> { }
    token multi_declarator:sym<null> { }

    proto token scope_declarator { }
    token scope_declarator:sym<my>        { }
    token scope_declarator:sym<our>       { }
    token scope_declarator:sym<has>       { }
    token scope_declarator:sym<HAS>       { }
    token scope_declarator:sym<augment>   { }
    token scope_declarator:sym<anon>      { }
    token scope_declarator:sym<state>     { }
    token scope_declarator:sym<supersede> { }
    token scope_declarator:sym<unit>      { }

    token scoped($*SCOPE) { }

    token variable_declarator { }

    proto token routine_declarator { }
    token routine_declarator:sym<sub> { }
    token routine_declarator:sym<method> { }
    token routine_declarator:sym<submethod> { }
    token routine_declarator:sym<macro> { }

    rule routine_def { }

    rule method_def { }

    rule macro_def { }

    token onlystar { }

    ###########################
    # Captures and Signatures #
    ###########################

    token capterm { }

    rule param_sep { }

    # XXX Not really implemented yet.
    token multisig { }

    token sigterm { }

    token fakesignature { }

    token signature { }

    token parameter { }

    token param_var { }

    token named_param { }

    rule default_value { }

    token type_constraint { }

    rule post_constraint { } 
    proto token regex_declarator { <...> }
    token regex_declarator:sym<rule> { }
    token regex_declarator:sym<token> { }
    token regex_declarator:sym<regex> { }

    rule regex_def { }

    proto token type_declarator { <...> }

    token type_declarator:sym<enum> { }

    rule type_declarator:sym<subset> { }

    token type_declarator:sym<constant> { }

    proto token initializer { <...> }
    token initializer:sym<=> { }
    token initializer:sym<:=> { }
    token initializer:sym<::=> { }
    token initializer:sym<.=> { }

    rule trait { }

    proto rule trait_mod { <...> }
    rule trait_mod:sym<is> { }
    rule trait_mod:sym<hides>   {  }
    rule trait_mod:sym<does>    {  }
    rule trait_mod:sym<will>    { }
    rule trait_mod:sym<of>      {  }
    rule trait_mod:sym<returns> {  }
    rule trait_mod:sym<handles> { }

    token bad_trait_typename { }

    ## Terms

    proto token term { }

    token term:sym<self> { }

    token term:sym<now> { }

    token term:sym<time> { }

    token term:sym<empty_set> { }

    token term:sym<rand> { }

    token term:sym<...> { }
    token term:sym<???> { }
    token term:sym<!!!> { }

    token term:sym<identifier> { }

    token term:sym<nqp::op> { }

    token term:sym<nqp::const> { }

    token term:sym<name> { }

    token term:sym<dotty> { }

    token term:sym<capterm> { }

    token term:sym<onlystar> { }

    token args($*INVOCANT_OK = 0) { }

    token semiarglist { }

    token arglist { }

    proto token value { }
    token value:sym<quote>  { }
    token value:sym<number> { }
    token value:sym<version> { }

    proto token number { }
    token number:sym<numish>   { }

    token signed-number { }

    token numish { }

    token dec_number { }

    token signed-integer { }

    token integer { }

    token rad_number { }

    token radint { }

    token escale { }

    token sign { }

    token rat_number { }
    token bare_rat_number { }

    token complex_number { }
    token bare_complex_number { }

    token typename { }

    token typo_typename($panic = 0) { }


    token quotepair($*purpose = 'quoteadverb') { }

    token rx_adverbs { }

    token qok($x) { }

    proto token quote_mod   { }
    token quote_mod:sym<w>  {  }
    token quote_mod:sym<ww> {  }
    #token quote_mod:sym<p>  { }
    token quote_mod:sym<x>  {  }
    token quote_mod:sym<to> {  }
    token quote_mod:sym<s>  {  }
    token quote_mod:sym<a>  {  }
    token quote_mod:sym<h>  {  }
    token quote_mod:sym<f>  {  }
    token quote_mod:sym<c>  {  }
    token quote_mod:sym<b>  {  }

    proto token quote { }
    token quote:sym<apos>  { }
    token quote:sym<sapos> { }
    token quote:sym<lapos> { }
    token quote:sym<hapos> { }
    token quote:sym<dblq>  { }
    token quote:sym<sdblq> { }
    token quote:sym<ldblq> { }
    token quote:sym<hdblq> { }
    token quote:sym<crnr>  { }
    token quote:sym<q> { }
    token quote:sym<qq> { }
    token quote:sym<Q> { }

    token quote:sym</null/> { }
    token quote:sym</ />  { }
    token quote:sym<rx>   { }

    token quote:sym<m> { }

    token quote:sym<qr> { }

    token setup_quotepair { '' }

    token sibble($l, $lang2, @lang2tweaks?) { }

    token quote:sym<s> { }

    token tribble ($l, $lang2 = $l, @lang2tweaks?) { }

    token quote:sym<tr> { }

    token quote:sym<y> { }

    token old_rx_mods { }

    token quote:sym<quasi> { }

    token circumfix:sym<STATEMENT_LIST( )> { }

    token circumfix:sym<( )> { }
    token circumfix:sym<[ ]> { }
    token circumfix:sym<ang> { }
    token circumfix:sym«<< >>» { }
    token circumfix:sym<« »> { }
    token circumfix:sym<{ }> { }

    ## Operators

    INIT {
        Perl6::Grammar.O(':prec<y=>, :assoc<unary>, :dba<methodcall>, :fiddly<1>', '%methodcall');
        Perl6::Grammar.O(':prec<x=>, :assoc<unary>, :dba<autoincrement>', '%autoincrement');
        Perl6::Grammar.O(':prec<w=>, :assoc<right>, :dba<exponentiation>', '%exponentiation');
        Perl6::Grammar.O(':prec<v=>, :assoc<unary>, :dba<symbolic unary>', '%symbolic_unary');
        Perl6::Grammar.O(':prec<v=>, :assoc<left>, :dba<dotty infix>, :nextterm<dottyopish>, :sub<z=>, :fiddly<1>', '%dottyinfix');
        Perl6::Grammar.O(':prec<u=>, :assoc<left>, :dba<multiplicative>',  '%multiplicative');
        Perl6::Grammar.O(':prec<t=>, :assoc<left>, :dba<additive>',  '%additive');
        Perl6::Grammar.O(':prec<s=>, :assoc<left>, :dba<replication>', '%replication');
        Perl6::Grammar.O(':prec<s=>, :assoc<left>, :dba<replication> :thunky<t.>', '%replication_xx');
        Perl6::Grammar.O(':prec<r=>, :assoc<left>, :dba<concatenation>',  '%concatenation');
        Perl6::Grammar.O(':prec<q=>, :assoc<list>, :dba<junctive and>', '%junctive_and');
        Perl6::Grammar.O(':prec<p=>, :assoc<list>, :dba<junctive or>', '%junctive_or');
        Perl6::Grammar.O(':prec<o=>, :assoc<unary>, :dba<named unary>', '%named_unary');
        Perl6::Grammar.O(':prec<n=>, :assoc<non>, :dba<structural infix>, :diffy<1>',  '%structural');
        Perl6::Grammar.O(':prec<m=>, :assoc<left>, :dba<chaining>, :iffy<1>, :diffy<1> :pasttype<chain>',  '%chaining');
        Perl6::Grammar.O(':prec<l=>, :assoc<left>, :dba<tight and>, :thunky<.t>',  '%tight_and');
        Perl6::Grammar.O(':prec<k=>, :assoc<list>, :dba<tight or>, :thunky<.t>',  '%tight_or');
        Perl6::Grammar.O(':prec<k=>, :assoc<list>, :dba<tight or>',  '%tight_or_minmax');
        Perl6::Grammar.O(':prec<j=>, :assoc<right>, :dba<conditional>, :fiddly<1>, :thunky<.tt>', '%conditional');
        Perl6::Grammar.O(':prec<j=>, :assoc<right>, :dba<conditional>, :fiddly<1>, :thunky<tt>', '%conditional_ff');
        Perl6::Grammar.O(':prec<i=>, :assoc<right>, :dba<item assignment>', '%item_assignment');
        Perl6::Grammar.O(':prec<i=>, :assoc<right>, :dba<list assignment>, :sub<e=>, :fiddly<1>', '%list_assignment');
        Perl6::Grammar.O(':prec<h=>, :assoc<unary>, :dba<loose unary>', '%loose_unary');
        Perl6::Grammar.O(':prec<g=>, :assoc<list>, :dba<comma>, :nextterm<nulltermish>, :fiddly<1>',  '%comma');
        Perl6::Grammar.O(':prec<f=>, :assoc<list>, :dba<list infix>',  '%list_infix');
        Perl6::Grammar.O(':prec<e=>, :assoc<right>, :dba<list prefix>', '%list_prefix');
        Perl6::Grammar.O(':prec<d=>, :assoc<left>, :dba<loose and>, :thunky<.t>',  '%loose_and');
        Perl6::Grammar.O(':prec<d=>, :assoc<left>, :dba<loose and>, :thunky<.b>',  '%loose_andthen');
        Perl6::Grammar.O(':prec<c=>, :assoc<list>, :dba<loose or>, :thunky<.t>',  '%loose_or');
        Perl6::Grammar.O(':prec<c=>, :assoc<list>, :dba<loose or>, :thunky<.b>',  '%loose_orelse');
        Perl6::Grammar.O(':prec<b=>, :assoc<list>, :dba<sequencer>',  '%sequencer');
    }

    token termish { }

    token arg_flat_nok { }

    sub bracket_ending($matches) { }

    method EXPR(str $preclim = '') { }

    token prefixish { }

    token infixish($in_meta = nqp::getlexdyn('$*IN_META')) { }

    token fake_infix { }

    regex infixstopper { }

    token postfixish { }

    token postop { }

    proto token prefix_circumfix_meta_operator { }

    proto token infix_postfix_meta_operator { }

    proto token infix_prefix_meta_operator { }

    proto token infix_circumfix_meta_operator {}

    proto token postfix_prefix_meta_operator { }

    proto token prefix_postfix_meta_operator { }

    method can_meta($op, $meta, $reason = "fiddly") { }

    regex term:sym<reduce> { }

    token postfix_prefix_meta_operator:sym<»> { }

    token prefix_postfix_meta_operator:sym<«> { }

    token infix_circumfix_meta_operator:sym<« »> { }

    token infix_circumfix_meta_operator:sym«<< >>» { }

    method AS_MATCH($v) { }
    method revO($from) { }

    proto token dotty { } 
    token dotty:sym<.> { }

    token dotty:sym<.*> { }

    token dottyop { }

    token privop { }

    token methodop { }

    token dottyopish { }

    token postcircumfix:sym<[ ]> { }

    token postcircumfix:sym<{ }> { }

    token postcircumfix:sym<ang> { }

    token postcircumfix:sym«<< >>» { }

    token postcircumfix:sym<« »> { }

    token postcircumfix:sym<( )> { }

    token postcircumfix:sym<[; ]> { }

    token postfix:sym<i>  { }

    token prefix:sym<++>  {  }
    token prefix:sym<-->  {  }
    token postfix:sym<++> {  }
    token postfix:sym<--> {  }
    token postfix:sym<ⁿ> { }

    token postfix:sym«->» { }

    token infix:sym<**>   { }

    token prefix:sym<+>   { }
    token prefix:sym<~~>  { }
    token prefix:sym<~>   { }
    token prefix:sym<->   {}
    token prefix:sym<−>   {}
    token prefix:sym<??>  {}
    token prefix:sym<?>   {}
    token prefix:sym<!>   {}
    token prefix:sym<|>   { }
    token prefix:sym<+^>  { }
    token prefix:sym<~^>  { }
    token prefix:sym<?^>  { }
    token prefix:sym<^^>  {}
    token prefix:sym<^>   { }

    token infix:sym<*>    {  }
    token infix:sym<×>    {  }
    token infix:sym</>    {  }
    token infix:sym<÷>    {  }
    token infix:sym<div>  {  }
    token infix:sym<gcd>  {  }
    token infix:sym<lcm>  {  }
    token infix:sym<%>    {  }
    token infix:sym<mod>  {  }
    token infix:sym<%%>   {  }
    token infix:sym<+&>   {  }
    token infix:sym<~&>   {  }
    token infix:sym<?&>   {  }
    token infix:sym«+<»   {  }
    token infix:sym«+>»   {  }
    token infix:sym«~<»   {  }
    token infix:sym«~>»   {  }

    token infix:sym«<<» { }

    token infix:sym«>>» { }

    token infix:sym<+>    { }
    token infix:sym<->    { }
    token infix:sym<−>    {  }
    token infix:sym<+|>   {  }
    token infix:sym<+^>   {  }
    token infix:sym<~|>   {  }
    token infix:sym<~^>   {  }
    token infix:sym<?|>   { }
    token infix:sym<?^>   { }

    token infix:sym<x>    { }
    token infix:sym<xx>    { }

    token infix:sym<~>    {  }
    token infix:sym<.>    { }
    token infix:sym<∘>   {  }
    token infix:sym<o>   {  }

    token infix:sym<&>   { }
    token infix:sym<(&)> {  }
    token infix:sym«∩»   {  }
    token infix:sym<(.)> {  }
    token infix:sym«⊍»   {  }

    token infix:sym<|>    {  }
    token infix:sym<^>    {  }
    token infix:sym<(|)>  {  }
    token infix:sym«∪»    {  }
    token infix:sym<(^)>  {  }
    token infix:sym«⊖»    {  }
    token infix:sym<(+)>  {  }
    token infix:sym«⊎»    {  }
    token infix:sym<(-)>  {  }
    token infix:sym«∖»    {  }

    token prefix:sym<let>  { }
    token prefix:sym<temp> { }

    token infix:sym«=~=»  {  }
    token infix:sym«≅»    {  }
    token infix:sym«==»   {  }
    token infix:sym«!=»   { }
    token infix:sym«<=»   {  }
    token infix:sym«>=»   {  }
    token infix:sym«<»    {  }
    token infix:sym«>»    {  }
    token infix:sym«eq»   {  }
    token infix:sym«ne»   {  }
    token infix:sym«le»   {  }
    token infix:sym«ge»   {  }
    token infix:sym«lt»   {  }
    token infix:sym«gt»   {  }
    token infix:sym«=:=»  {  }
    token infix:sym<===>  {  }
    token infix:sym<eqv>    {  }
    token infix:sym<before> {  }
    token infix:sym<after>  {  }
    token infix:sym<~~>   { }
    token infix:sym<!~~>  { }
    token infix:sym<(elem)> {  }
    token infix:sym«∈»      {  }
    token infix:sym«∉»      {  }
    token infix:sym<(cont)> {  }
    token infix:sym«∋»      {  }
    token infix:sym«∌»      {  }
    token infix:sym«(<)»    {  }
    token infix:sym«⊂»      {  }
    token infix:sym«⊄»      {  }
    token infix:sym«(>)»    {  }
    token infix:sym«⊃»      {  }
    token infix:sym«⊅»      {  }
    token infix:sym«(<=)»   {  }
    token infix:sym«⊆»      {  }
    token infix:sym«⊈»      {  }
    token infix:sym«(>=)»   {  }
    token infix:sym«⊇»      {  }
    token infix:sym«⊉»      {  }
    token infix:sym«(<+)»   {  }
    token infix:sym«≼»      {  }
    token infix:sym«(>+)»   {  }
    token infix:sym«≽»      {  }

    token infix:sym<&&>   {  }

    token infix:sym<||>   {  }
    token infix:sym<^^>   {  }
    token infix:sym<//>   { }
    token infix:sym<min>  {  }
    token infix:sym<max>  {  }

    token infix:sym<?? !!> { }

    token infix_prefix_meta_operator:sym<!> { }

    token infix_prefix_meta_operator:sym<R> { }

    token infix_prefix_meta_operator:sym<S> { }

    token infix_prefix_meta_operator:sym<X> { }

    token infix_prefix_meta_operator:sym<Z> { }

    token infix:sym<minmax> { }

    token infix:sym<:=> { }

    token infix:sym<::=> { }

    token infix:sym<.=> { }

    # Should probably have <!after '='> to agree w/spec, but after NYI.
    # Modified infix != below instead to prevent misparse
    # token infix_postfix_meta_operator:sym<=>($op) { }
    # use $*OPER until NQP/Rakudo supports proto tokens with arguments
    token infix_postfix_meta_operator:sym<=> { }

    token infix:sym«=>» { }

    token prefix:sym<so> { }
    token prefix:sym<not>  { }

    token infix:sym<,>    { }
    token infix:sym<:>    { }

    token infix:sym<Z>    { }
    token infix:sym<X>    { }

    token infix:sym<...>  { }
    token infix:sym<…>    { }
    token infix:sym<...^> {  }
    token infix:sym<…^>   {  }
    # token term:sym<...>   {}

    token infix:sym<?>    { }

    token infix:sym<ff> { }
    token infix:sym<^ff> { }
    token infix:sym<ff^> { }
    token infix:sym<^ff^> { }

    token infix:sym<fff> { }
    token infix:sym<^fff> { }
    token infix:sym<fff^> { }
    token infix:sym<^fff^> { }

    
    token infix:sym<and>  { }
    token infix:sym<andthen> { }
    token infix:sym<notandthen> { }

    token infix:sym<or>   {  }
    token infix:sym<xor>  {  }
    token infix:sym<orelse> { }

    token infix:sym«<==»  { }
    token infix:sym«==>»  { }
    token infix:sym«<<==» { }
    token infix:sym«==>>» { }

    token infix:sym<..>   {}
    token infix:sym<^..>  {  }
    token infix:sym<..^>  {  }
    token infix:sym<^..^> {  }

    token infix:sym<leg>  { }
    token infix:sym<cmp>  {  }
    token infix:sym«<=>»  { }

    token infix:sym<but>  {  }
    token infix:sym<does> {  }

    token infix:sym<!~> { }
    token infix:sym<=~> { }

    method add_mystery { }

    method explain_mystery { }

    method cry_sorrows { }

    method add_variable { }

    # Called when we add a new choice to an existing syntactic category, for
    # example new infix operators add to the infix category. Augments the
    # grammar as needed.
    method add_categorical { }

    method genO($default, $declarand) { }
}

grammar Perl6::QGrammar {

    method throw_unrecog_backslash_seq ($sequence) { }

    proto token escape { }
    proto token backslash { }

    role b1 {
        token escape:sym<\\> { }
        token backslash:sym<qq> { }
        token backslash:sym<\\> {} 
        token backslash:delim { }
        token backslash:sym<a> { }
        token backslash:sym<b> { }
        token backslash:sym<c> { }
        token backslash:sym<e> { }
        token backslash:sym<f> { }
        token backslash:sym<N> { }
        token backslash:sym<n> { }
        token backslash:sym<o> { }
        token backslash:sym<r> { }
        token backslash:sym<rn> { }
        token backslash:sym<t> { }
        token backslash:sym<x> { }
        token backslash:sym<0> { }
        token backslash:sym<1> { }
    }

    role b0 { token escape:sym<\\> { } }
    role c1 { token escape:sym<{ }> { } }
    role c0 { token escape:sym<{ }> { } }
    role s1 { token escape:sym<$> { } }
    role s0 { token escape:sym<$> { } }
    role a1 { token escape:sym<@> { } }
    role a0 { token escape:sym<@> { } }
    role h1 { token escape:sym<%> { } }
    role h0 { token escape:sym<%> { } }
    role f1 { token escape:sym<&> { } }
    role f0 { token escape:sym<&> { } }

    role ww {
        token escape:sym<' '> { }
        token escape:sym<‘ ’> { }
        token escape:sym<" "> { }
        token escape:sym<“ ”> { }
        token escape:sym<colonpair> { }
        token escape:sym<#> { }
    }

    role to[$herelang] {
        method herelang() { }
        method postprocessors () {}
    }

    role q {
        token starter { }
        token stopper { }

        token escape:sym<\\> { }

        token backslash:sym<qq> {}
        token backslash:sym<\\> {}
        token backslash:delim { }

        token backslash:sym<miscq> {}

        method tweak_q($v) { }
        method tweak_qq($v) { }
    }

    role qq does b1 does c1 does s1 does a1 does h1 does f1 {
        token starter { }
        token stopper { }
        token backslash:sym<unrec> { }
        token backslash:sym<misc> { }
        method tweak_q($v) { }
        method tweak_qq($v) { }
    }

    token nibbler { }

    token do_nibbling { }

    role cc {
        method ccstate ($s) { }

        token escape:ws { }
        token escape:sym<#> { }
        token escape:sym<\\> { }
        token escape:sym<..> { }

        token escape:sym<-> { }
        token escape:ch { }

        token backslash:delim { }
        token backslash:<\\> { }
        token backslash:sym<a> {  }
        token backslash:sym<b> {  }
        token backslash:sym<c> {  }
        token backslash:sym<d> {  }
        token backslash:sym<e> {  }
        token backslash:sym<f> {  }
        token backslash:sym<h> {  }
        token backslash:sym<N> {  }
        token backslash:sym<n> {  }
        token backslash:sym<o> {  }
        token backslash:sym<r> {  }
        token backslash:sym<s> {  }
        token backslash:sym<t> {  }
        token backslash:sym<v> {  }
        token backslash:sym<w> {  }
        token backslash:sym<x> {  }
        token backslash:sym<0> {  }

        # keep random backslashes like qq does
        token backslash:misc {  }
    }

    method truly($bool, $opt) { }

    method apply_tweak($role) { }

    method tweak_q          { }
    method tweak_single     { }
    method tweak_qq        { }
    method tweak_double     { }

    method tweak_b          { }
    method tweak_backslash  {  }
    method tweak_s          { }
    method tweak_scalar     {  }
    method tweak_a          { }
    method tweak_array      {  }
    method tweak_h          { }
    method tweak_hash       {  }
    method tweak_f          { }
    method tweak_function   {  }
    method tweak_c          { }
    method tweak_closure    {  }

    method add-postproc(str $newpp) { }

# path() NYI
#    method tweak_p          {  }
#    method tweak_path       {  }

    method tweak_x          { }
    method tweak_exec       { }
    method tweak_w          { }
    method tweak_words      { }
    method tweak_ww         { }
    method tweak_quotewords { }

    method tweak_v          { }
    method tweak_val        { }

    method tweak_cc         {}

    method tweak_to { }
    method tweak_heredoc    {}

    method tweak_regex { }
}

my role CursorPackageNibbler {
    method nibble-in-cursor { }
}

grammar Perl6::RegexGrammar {
    method nibbler { }

    token normspace { }

    token rxstopper { }

    token metachar:sym<:my> { }
    token metachar:sym<{ }> { }
    token metachar:sym<rakvar> { }
    token metachar:sym<qw> { }
    token metachar:sym<'> { }
    token metachar:sym<{}> { }
    token backslash:sym<1> { }
    token assertion:sym<{ }> { }
    token assertion:sym<?{ }> { }
    token assertion:sym<!{ }> { }
    token assertion:sym<var> { }
    token assertion:sym<~~> { }

    token codeblock { }
    token arglist { }
    token assertion:sym<name> { }
}

grammar Perl6::P5RegexGrammar {
    method nibbler { } 
    token rxstopper { <stopper> }

    token p5metachar:sym<(?{ })> { }
    token p5metachar:sym<(??{ })> { }
    token p5metachar:sym<var> { }

    token codeblock { }
}

)
