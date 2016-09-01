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

role Bounded {
	has Int $.from is required;
	has Int $.to is required;
}

role Token does Bounded {
	has Str $.content is required;
	method perl6( $f ) {
		~$.content
	}
}


class Perl6::Unimplemented {
	has $.content
}

class Perl6::WS does Token {
	also is Perl6::Element;

	multi method new( Int $start, $content ) {
		self.bless(
			:from( $start ),
			:to( $start + $content.chars ),
			:content( $content )
		)
	}

	method from-match( Mu $p ) {
		self.bless(
			:from( $p.from ),
			:to( $p.to ),
			:content( $p.Str )
		)
	}

	method whitespace-leader( Mu $p, Mu $rhs ) {
		if $p.from < $rhs.from {
			self.bless(
				:from( $p.from ),
				:to( $rhs.from ),
				:content(
					substr(
						$p.Str,
						0,
						$rhs.from - $p.from
					)
				)
			)
		}
		else {
			()
		}
	}

	method whitespace-terminator( Mu $p, Mu $lhs ) {
		if $lhs.to < $p.to {
			self.bless(
				:from( $lhs.to ),
				:to( $p.to ),
				:content(
					substr(
						$p.Str,
						$p.Str.chars - ( $p.to - $lhs.to ),
						$p.to - $lhs.to
					)
				)
			)
		}
		else {
			()
		}
	}
}

class Perl6::Document does Branching {
	also is Perl6::Element;
}

class Perl6::Statement does Branching does Bounded {
	also is Perl6::Element;

	method from-list( Perl6::Element @child ) {
		self.bless(
			:from( @child[0].from ),
			:to( @child[*-1].to ),
			:child( @child )
		)
	}
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

	method from-match( Mu $p ) {
		self.bless(
			:from( $p.from ),
			:to( $p.to ),
			:content( $p.Str )
		)
	}
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
	multi method new( Mu $p ) {
		self.bless(
			:from( $p.from ),
			:to( $p.to ),
			:content( $p.Str )
		)
	}
}
class Perl6::Operator {
	also is Perl6::Element;
}
class Perl6::Operator::Prefix does Token {
	also is Perl6::Operator;
	multi method new( Mu $p ) {
		self.bless(
			:from( $p.from ),
			:to( $p.to ),
			:content( $p.Str )
		)
	}
}
class Perl6::Operator::Infix does Token {
	also is Perl6::Operator;
	multi method new( Mu $p ) {
		self.bless(
			:from( $p.from ),
			:to( $p.to ),
			:content( $p.Str )
		)
	}
	multi method new( Int $from, Str $str ) {
		self.bless(
			:from( $from ),
			:to( $from + $str.chars ),
			:content( $str )
		)
	}
	multi method new( Mu $p, Str $token ) {
		$p.Str ~~ m{ ($token) };
		my Int $offset = $0.from;
		self.bless(
			:from( $p.from + $offset ),
			:to( $p.from + $offset + $token.chars ),
			:content( $token )
		)
	}
}
class Perl6::Operator::Postfix does Token {
	also is Perl6::Operator;
	multi method new( Mu $p ) {
		self.bless(
			:from( $p.from ),
			:to( $p.to ),
			:content( $p.Str )
		)
	}
}
class Perl6::Operator::Circumfix does Branching_Delimited does Bounded {
	also is Perl6::Operator;
	multi method new( Mu $p, @child ) {
		$p.Str ~~ m{ ^ (.) }; my Str $front = ~$0;
		$p.Str ~~ m{ (.) $ }; my Str $back = ~$0;
		self.bless(
			:from( $p.from ),
			:to( $p.to ),
			:delimiter( $front, $back ),
			:child( @child )
		)
	}
}
class Perl6::Operator::PostCircumfix does Branching_Delimited does Bounded {
	also is Perl6::Operator;
}
class Perl6::PackageName does Token {
	also is Perl6::Element;
	method namespaces() {
		$.content.split( '::' )
	}
}
class Perl6::ColonBareword does Token {
	also is Perl6::Bareword;
}
class Perl6::Block does Branching_Delimited does Bounded {
	also is Perl6::Element;

	method from-match( Mu $p, Perl6::Element @child ) {
		$p.Str ~~ m{ ^ (.) }; my Str $front = ~$0;
		$p.Str ~~ m{ (.) $ }; my Str $back = ~$0;
		self.bless(
			:from( $p.from ),
			:to( $p.to ),
			:delimiter( $front, $back ),
			:child( @child )
		)
	}
}

# Semicolons should only occur at statement boundaries.
# So they're only generated in the _statement handler.
#
class Perl6::Semicolon does Token {
	also is Perl6::Element;
}

class Perl6::Variable {
	also is Perl6::Element;
	method headless() {
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

	constant COMMA = Q{,};
	constant COLON = Q{:};
	constant SEMICOLON = Q{;};
	constant EQUAL = Q{=};
	constant WHERE = Q{where};
	constant QUES-QUES = Q{??};
	constant BANG-BANG = Q{!!};
	constant FATARROW = Q{=>};
	constant HYPER = Q{>>};

	sub unhandled-case( Mu $p ) {
		say $p.hash.keys.gist;
		warn "Unhandled case"
	}

	# Return the whitespace separating two tokens, if any.
	#
	sub whitespace-separator( Mu $p, Mu $lhs, Mu $rhs ) {
		if $lhs.to < $rhs.from {
			Perl6::WS.new(
				$lhs.to,
				substr-match(
					$p,
					$lhs.to,
					$rhs.from - $lhs.to
				)
			)
		}
		else {
			()
		}
	}

	sub substr-match( Mu $p, Int $offset where * >= 0, Int $chars ) {
		substr(
			$p.Str,
			$offset - $p.from,
			$chars
		)
	}

	# Returns the semicolon and preceding whitespace at the end of a string
	# if any.
	#
	sub semicolon-terminator( Mu $p ) {
		if $p.Str ~~ m{ ( \s+ ) ( ';' ) ( \s+ ) $ } {
			(
				Perl6::WS.new(
					:from( $p.to - $2.chars - $1.chars - $0.chars ),
					:to( $p.to - $2.chars - $1.chars ),
					:content( $0.Str )
				),
				Perl6::Semicolon.new(
					:from( $p.to - $2.chars - $1.chars ),
					:to( $p.to - $2.chars ),
					:content( $1.Str )
				)
			)
		}
		elsif $p.Str ~~ m{ ( ';' ) ( \s+ ) $ } {
			(
				Perl6::Semicolon.new(
					:from( $p.to - $1.chars - $0.chars ),
					:to( $p.to - $1.chars ),
					:content( $0.Str )
				)
			)
		}
		elsif $p.Str ~~ m{ ( \s+ ) ( ';' ) $ } {
			(
				Perl6::WS.new(
					:from( $p.to - $1.chars - $0.chars ),
					:to( $p.to - $1.chars ),
					:content( $0.Str )
				),
				Perl6::Semicolon.new(
					:from( $p.to - $1.chars ),
					:to( $p.to ),
					:content( $1.Str )
				)
			)
		}
		elsif $p.Str ~~ m{ ( ';' ) $ } {
			(
				Perl6::Semicolon.new(
					:from( $p.to - $0.chars ),
					:to( $p.to  ),
					:content( $0.Str )
				)
			)
		}
		else {
			()
		}
	}

	sub comma-separator( Int $offset, Str $split-me ) {
		my Int $start = $offset;
		my ( $lhs, $rhs ) = split( COMMA, $split-me );
		my Perl6::Element @child;
		if $lhs and $lhs ne '' {
#			@child.append(
#				Perl6::WS.new( $start, $lhs )
#			);
#			$start += $lhs.chars;
		}
		@child.append(
			Perl6::Operator::Infix.new( $start, COMMA )
		);
		$start += COMMA.chars;
		if $rhs and $rhs ne '' {
#			@child.append(
#				Perl6::WS.new( $start, $rhs )
#			);
#			$start += $rhs.chars;
		}
		@child.flat
	}

	method build( Mu $p ) {
		my Perl6::Element @child =
			self._statementlist( $p.hash.<statementlist> );
		Perl6::Document.new(
			:child( @child )
		)
	}

	method make-postcircumfix( Mu $p, @child ) {
		$p.Str ~~ m{ ^ (.) }; my Str $front = ~$0;
		$p.Str ~~ m{ (.) $ }; my Str $back = ~$0;
		Perl6::Operator::PostCircumfix.new(
			# XXX What is it "post"? Hmm.
			:from( $p.from ),
			:to( $p.to ),
			:delimiter( $front, $back ),
			:child( @child )
		)
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

		my Str @keys;
		my Str @defined-keys;
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

	method _arglist( Mu $p ) {
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
			my Perl6::Element @child =
				self._semiarglist( $p.hash.<semiarglist> );
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
		if self.assert-hash-keys( $p, [< metachar >] ) {
			self._metachar( $p.hash.<metachar> )
		}
		elsif $p.Str {
			Perl6::Bareword.new( $p )
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
	method _binint( Mu $p ) {
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
		# $p doesn't contain WS after the block.
		if self.assert-hash-keys( $p, [< statementlist >] ) {
			if $p.hash.<statementlist>.Str ~~ /\S/ {
				my Perl6::Element @child;
				my Perl6::Element @_child =
					self._statementlist(
						$p.hash.<statementlist>
					);
				@child.append(
					Perl6::Block.from-match(
						$p, @_child
					)
				);
				@child
			}
			else {
				(
					Perl6::Statement.new(
						:from( $p.from ),
						:to( $p.to ),
						:child(
							Perl6::WS.from-match(
								$p
							)
						)
					)
				)
			}
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
					say $_.hash.keys.gist;
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
			my Perl6::Element @child;
			if $p.hash.<semilist>.hash.<statement>.list.[0].hash.<EXPR> {
				@child.append(
self._EXPR( $p.hash.<semilist>.hash.<statement>.list.[0].hash.<EXPR> )
				)
			}
			self.make-postcircumfix( $p, @child )
		}
		elsif self.assert-hash-keys( $p, [< nibble >] ) {
			# XXX <nibble> can probably be worked with
			my Perl6::Element @child =
				Perl6::Operator::Prefix.new(
					:from( $p.hash.<nibble>.from ),
					:to( $p.hash.<nibble>.to ),
					:content( $p.hash.<nibble>.Str )
				);
			Perl6::Operator::Circumfix.new( $p, @child )
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
					:to( $p.from + COLON.chars ),
					:content( COLON )
				),
				self._identifier( $p.hash.<identifier> ),
				self._coloncircumfix( $p.hash.<coloncircumfix> )
			).flat
		}
		elsif self.assert-hash-keys( $p, [< coloncircumfix >] ) {
			(
				# XXX Note that ':' is part of the expression.
				Perl6::Operator::Prefix.new(
					:from( $p.from ),
					:to( $p.from + 1 ),
					:content( COLON )
				),
				self._coloncircumfix( $p.hash.<coloncircumfix> )
			).flat
		}
		elsif self.assert-hash-keys( $p, [< identifier >] ) {
			Perl6::ColonBareword.new(
				:from( $p.from ),
				:to( $p.to ),
				:content( $p.Str )
			)
		}
		elsif self.assert-hash-keys( $p, [< fakesignature >] ) {
			# XXX May not really be "post" in the P6 sense?
			my Perl6::Element @child =
				self._fakesignature(
					$p.hash.<fakesignature>
				);
			Perl6::Operator::PostCircumfix.new(
				:from( $p.from ),
				:to( $p.to ),
				:delimiter( ':(', ')' ),
				:child( @child )
			)
		}
		elsif self.assert-hash-keys( $p, [< var >] ) {
			# Synthesize the 'from' marker for ':'
			(
				# XXX is this actually a single token?
				# XXX I think it is.
				Perl6::Operator::Prefix.new(
					:from( $p.from ),
					:to( $p.from + 1 ),
					:content( COLON )
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
		warn "untested method";
		if self.assert-hash-keys( $p, [< coercee circumfix sigil >] ) {
			die "not implemented yet";
		}
		else {
			say $p.hash.keys.gist;
			warn "Unhandled case"
		}
	}

	method _decint( Mu $p ) {
		Perl6::number::decimal.new(
			:from( $p.from ),
			:to( $p.to ),
			:content( $p.str )
		)
	}

	method _declarator( Mu $p ) {
		if self.assert-hash-keys( $p,
				[< deftermnow initializer term_init >],
				[< trait >] ) {
			die "not implemented yet";
		}
		elsif self.assert-hash-keys( $p,
				[< initializer signature >], [< trait >] ) {
			die "not implemented yet";
		}
		elsif self.assert-hash-keys( $p,
				  [< initializer variable_declarator >],
				  [< trait >] ) {
			my @child =
				self._variable_declarator(
					$p.hash.<variable_declarator>
				);
			@child.append(
				whitespace-separator(
					$p,
					$p.hash.<variable_declarator>,
					$p.hash.<initializer>
				)
			);
			@child.append(
				self._initializer( $p.hash.<initializer> )
			)
		}
		elsif self.assert-hash-keys( $p,
				[< routine_declarator >], [< trait >] ) {
			self._routine_declarator(
				$p.hash.<routine_declarator>
			)
		}
		elsif self.assert-hash-keys( $p,
				[< regex_declarator >], [< trait >] ) {
			self._regex_declarator(
				$p.hash.<regex_declarator>
			)
		}
		elsif self.assert-hash-keys( $p,
				[< variable_declarator >], [< trait >] ) {
			self._variable_declarator(
				$p.hash.<variable_declarator>
			)
		}
		elsif self.assert-hash-keys( $p,
				[< signature >], [< trait >] ) {
			my Perl6::Element @child =
				self._signature( $p.hash.<signature> );
			Perl6::Operator::circumfix.new( $p, @child )
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
			self._variable_declarator(
				$p.hash.<variable_declarator>
			)
		}
		elsif self.assert-hash-keys( $p,
				[< routine_declarator >],
				[< trait >] ) {
			self._routine_declarator( $p.hash.<routine_declarator>)
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

	method _dec_number( Mu $p ) {
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
					say $_.hash.keys.gist;
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

	method _doc( Mu $p ) {
		$p.hash.<doc>.Bool
	}

	method _dotty( Mu $p ) {
		if self.assert-hash-keys( $p, [< sym dottyop O >] ) {
			(
				Perl6::Operator::Prefix.new( $p.hash.<sym> ),
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
			my Mu $v = $p.hash.<value>;
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
			if substr-match( $p.orig, $p.from, HYPER.chars ) eq HYPER {
				(
					self.__Term( $p.list.[0] ),
					# XXX note that '>>' is a substring
					Perl6::Operator::Prefix.new(
						:from( $p.from ),
						:to( $p.from + HYPER.chars ),
						:content( 
							substr( $p.orig, $p.from, HYPER.chars )
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
			my Perl6::Element @child =
				self._postcircumfix( $p.hash.<postcircumfix> );
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
			my Perl6::Element @child =
				self.__Term( $p.list.[0] );
			@child.append(
				self._infix_prefix_meta_operator(
					$p.hash.<infix_prefix_meta_operator>
				),
			);
			@child.append(
				self.__Term( $p.list.[1] )
			);

			@child.flat
		}
		# XXX ternary operators don't follow the string boundary rules
		# XXX $p.list.[0] is actually the start of the expression.
		elsif self.assert-hash-keys( $p, [< infix OPER >] ) {
			if $p.list.elems == 3 {
				my Perl6::Element @child =
					self.__Term( $p.list.[0] ),
					Perl6::Operator::Infix.new(
						$p, QUES-QUES
					),
					self.__Term( $p.list.[1] ),
					Perl6::Operator::Infix.new(
						$p, BANG-BANG
					),
					self.__Term( $p.list.[2] );
				@child.flat
			}
			else {
				my Perl6::Element @child =
					self.__Term( $p.list.[0] );
				if $p.list.[0].to < $p.hash.<infix>.from {
					# XXX THIS NEEDS TO CHANGE.
#					@child.append(
#						Perl6::WS.new(
#							$p.list.[0].to,
#							' ' x $p.hash.<infix>.from - $p.list.[0].to
#						)
#					)
				}
				@child.append(
					self._infix( $p.hash.<infix> )
				);
				if $p.hash.<infix>.from < $p.list.[1].from {
					# XXX THIS NEEDS TO CHANGE.
#					@child.append(
#						Perl6::WS.new(
#							$p.hash.<infix>.to,
#							' ' x $p.list.[1].from - $p.hash.<infix>.to
#						)
#					)
				}
				@child.append(
					self.__Term( $p.list.[1] )
				);
				@child.flat
			}
		}
		elsif self.assert-hash-keys( $p, [< identifier args >] ) {
			(
				self._identifier( $p.hash.<identifier> ),
				self._args( $p.hash.<args> )
			)
		}
		elsif self.assert-hash-keys( $p, [< sym args >] ) {
			Perl6::Operator::Infix.new( $p.hash.<sym> )
		}
		elsif self.assert-hash-keys( $p, [< longname args >] ) {
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

		# $p doesn't contain WS after the block.
		elsif self.assert-hash-keys( $p, [< package_declarator >] ) {
			self._package_declarator(
				$p.hash.<package_declarator>
			)
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
			$p.Str ~~ m{ ('=>') };
			my Perl6::Element @child =
				self._key( $p.hash.<key> );
			if $p.hash.<key>.to < $0.from {
#				@child.append(
#					Perl6::WS.new(
#						$p.hash.<key>.to,
#						substr-match(
#							$p,
#							$p.hash.<key>.to,
#							$0.from - $p.hash.<key>.to
#						)
#					)
#				)
			}
			@child.append(
				Perl6::Operator::Infix.new( $p, FATARROW ),
			);
			if $0.to < $p.hash.<val>.from {
#				@child.append(
#					Perl6::WS.new(
#						$0.to,
#						substr-match(
#							$p,
#							$0.to,
#							$p.hash.<val>.from - $0.to
#						)
#					)
#				)
			}
			@child.append(
				self._val( $p.hash.<val> )
			);
			if $p.hash.<val>.to < $p.to {
#				@child.append(
#					Perl6::WS.new(
#						$p.hash.<val>.to,
#						substr-match(
#							$p,
#							$p.hash.<val>.to,
#							$p.to - $p.hash.<val>.to
#						)
#					)
#				)
			}
			@child
		}
		else {
			say $p.hash.keys.gist;
			warn "Unhandled case"
		}
	}

	method __FloatingPoint( Mu $p ) {
		Perl6::Number::Floating.new(
			:from( $p.from ),
			:to( $p.to ),
			:content( $p.Str )
		)
	}

	# XXX Unused
	method _hexint( Mu $p ) {
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
					say $_.hash.keys.gist;
					warn "Unhandled case"
				}
			}
			@child
		}
		elsif $p.Str {
			Perl6::Bareword.new( $p )
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
			Perl6::Operator::Infix.new( $p.hash.<sym> )
		}
		elsif self.assert-hash-keys( $p, [< EXPR O >] ) {
			# XXX Untested
			Perl6::Operator::Infix.new( $p.hash.<EXPR> )
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
				$p.hash.<sym>.from,
				$p.hash.<sym>.Str ~ $p.hash.<infixish>
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
			my @child =
				Perl6::Operator::Infix.new( $p.hash.<sym> );
			@child.append(
				whitespace-separator(
					$p,
					$p.hash.<sym>,
					$p.hash.<EXPR>
				)
			);
			@child.append(
				self._EXPR( $p.hash.<EXPR> )
			);
			@child.flat
		}
		else {
			say $p.hash.keys.gist;
			warn "Unhandled case"
		}
	}

	method _integer( Mu $p ) {
		if self.assert-hash-keys( $p, [< binint VALUE >] ) {
			# XXX Probably should make 'headless' lazy later.
			Perl6::Number::Binary.new(
				:from( $p.from ),
				:to( $p.to ),
				:content( $p.Str ),
				:headless( $p.hash.<binint>.Str )
			)
		}
		elsif self.assert-hash-keys( $p, [< octint VALUE >] ) {
			# XXX Probably should make 'headless' lazy later.
			Perl6::Number::Octal.new(
				:from( $p.from ),
				:to( $p.to ),
				:content( $p.Str ),
				:headless( $p.hash.<octint>.Str )
			)
		}
		elsif self.assert-hash-keys( $p, [< decint VALUE >] ) {
			Perl6::Number::Decimal.new(
				:from( $p.from ),
				:to( $p.to ),
				:content( $p.Str ),
			)
		}
		elsif self.assert-hash-keys( $p, [< hexint VALUE >] ) {
			# XXX Probably should make 'headless' lazy later.
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
return True;
	}

	method _key( Mu $p ) {
		Perl6::Bareword.new( $p )
	}

	method _lambda( Mu $p ) {
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

	method _max( Mu $p ) {
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
say 1;
			my Perl6::Element @child =
				 self._multisig( $p.hash.<multisig> );
			(
				self._longname( $p.hash.<longname> ),
				Perl6::Operator::Circumfix.new(
					# XXX Verify from/to
					:from( $p.from ),
					:to( $p.to ),
					:delimiter( '(', ')' ),
					:child( @child )
				),
				self._blockoid( $p.hash.<blockoid> )
			).flat
		}
		elsif self.assert-hash-keys( $p,
			     [< specials longname blockoid >],
			     [< trait >] ) {
			my Perl6::Element @child =
				self._longname( $p.hash.<longname> );
			@child.append(
				whitespace-separator(
					$p,
					$p.hash.<longname>,
					$p.hash.<blockoid>
				)
			);
			@child.append(
				self._blockoid( $p.hash.<blockoid> )
			);
			@child.append(
				Perl6::WS.whitespace-terminator(
					$p,
					$p.hash.<blockoid>
				)
			);
			@child.flat;
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
					say $_.hash.keys.gist;
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
			(
				self._sym( $p.hash.<sym> ),
				self._declarator( $p.hash.<declarator> )
			)
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
			Perl6::Bareword.new( $p )
		}
		elsif self.assert-hash-keys( $p, [< subshortname >] ) {
			die "Not implemented yet"
		}
		elsif self.assert-hash-keys( $p, [< morename >] ) {
			Perl6::PackageName.new(
				:from( $p.from ),
				:to( $p.to ),
				:content( $p.Str )
			)
		}
		elsif self.assert-Str( $p ) {
			Perl6::Bareword.new( $p )
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

	method _normspace( Mu $p ) {
		$p.hash.<normspace>.Str
	}

	method _noun( Mu $p ) {
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
					@child.push(
						self._atom( $_.hash.<atom> )
					)
				}
				elsif self.assert-hash-keys( $_, [< atom >] ) {
					@child.push(
						self._atom( $_.hash.<atom> )
					)
				}
				else {
					say $_.hash.keys.gist;
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

	method _octint( Mu $p ) {
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
				Perl6::Operator::Infix.new( $p.hash.<sym> ),
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

	# package <name> { }
	# module <name> { }
	# class <name> { }
	# grammar <name> { }
	# role <name> { }
	# knowhow <name> { }
	# native <name> { }
	# lang <name> ...
	# trusts <name>
	# also <name>
	#
	method _package_declarator( Mu $p ) {
		# $p doesn't contain WS after the block.
		if self.assert-hash-keys( $p, [< sym package_def >] ) {
			my Perl6::Element @child =
				self._sym( $p.hash.<sym> );
			@child.append(
				whitespace-separator(
					$p,
					$p.hash.<sym>,
					$p.hash.<package_def>
				)
			);
			@child.append(
				self._package_def( $p.hash.<package_def> )
			);
			@child.append(
				semicolon-terminator( $p )
			);
			@child
		}
		elsif self.assert-hash-keys( $p, [< sym typename >] ) {
			my Perl6::Element @child =
				self._sym( $p.hash.<sym> );
			@child.append(
				whitespace-separator(
					$p,
					$p.hash.<sym>,
					$p.hash.<typename>
				)
			);
			@child.append(
				self._package_def( $p.hash.<typename> )
			);
#			@child.append(
#				semicolon-terminator( $p )
#			);
			@child
		}
		elsif self.assert-hash-keys( $p, [< sym trait >] ) {
			my Perl6::Element @child =
				self._sym( $p.hash.<sym> );
			@child.append(
				whitespace-separator(
					$p,
					$p.hash.<sym>,
					$p.hash.<trait>
				)
			);
			@child.append(
				self._trait( $p.hash.<trait> )
			);
#			@child.append(
#				semicolon-terminator( $p )
#			);
			@child
		}
		else {
			say $p.hash.keys.gist;
			warn "Unhandled case"
		}
	}

	method _package_def( Mu $p ) {
		if self.assert-hash-keys( $p,
				[< longname statementlist >], [< trait >] ) {
			my Perl6::Element @child =
				self._longname( $p.hash.<longname> );
			@child.append(
				self._statementlist( $p.hash.<statementlist> )
			);
			@child.flat
		}
		elsif self.assert-hash-keys( $p,
				[< longname >], [< colonpair >] ) {
			my Perl6::Element @child =
				self._longname( $p.hash.<longname> );
			@child.flat
		}
		# $p doesn't contain WS after the block.
		elsif self.assert-hash-keys( $p,
				[< longname blockoid >], [< trait >] ) {
			my Perl6::Element @child =
				self._longname( $p.hash.<longname> );
			@child.append(
				whitespace-separator(
					$p,
					$p.hash.<longname>,
					$p.hash.<blockoid>
				)
			);
			@child.append(
				self._blockoid( $p.hash.<blockoid> )
			).flat;
			@child
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
		for $p.list {
			if self.assert-hash-keys( $_,
				[< param_var type_constraint
				   quant post_constraint >],
				[< default_value modifier trait >] ) {
				# Synthesize the 'from' and 'to' markers for 'where'
				$p.Str ~~ m{ << (where) >> };
				my Int $from = $0.from;
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
						:from( $p.from + $from ),
						:to( $p.from + $from + WHERE.chars ),
						:content( WHERE )
					)
				);
				@child.append(
					self._post_constraint(
						$_.hash.<post_constraint>
					)
				);
			}
			elsif self.assert-hash-keys( $_,
				[< type_constraint param_var quant >],
				[< default_value modifier trait
				   post_constraint >] ) {
				@child.append(
					self._type_constraint(
						$_.hash.<type_constraint>
					)
				);
				if $_.Str ~~ m{ (\s+) } {
#					@child.append(
#						Perl6::WS.new(
#							$_.from + $0.from,
#							$0.Str
#						)
#					)
				}
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
					Perl6::Operator::Infix.new( $p, EQUAL )
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
				my Int $from = $0.from;
				@child.append(
					Perl6::Operator::Prefix.new(
						:from( $from ),
						:to( $from + COLON.chars ),
						:content( COLON )
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

	my %sigil-map =
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
		'&~' => Perl6::Variable::Callable::SubLanguage;

	method _param_var( Mu $p ) {
		if self.assert-hash-keys( $p, [< name twigil sigil >] ) {
			# XXX refactor back to a method
			my Str $sigil       = $p.hash.<sigil>.Str;
			my Str $twigil      = $p.hash.<twigil> ??
					      $p.hash.<twigil>.Str !! '';
			my Str $desigilname = $p.hash.<name> ??
					      $p.hash.<name>.Str !! '';
			my Str $content     = $p.hash.<sigil> ~
					      $twigil ~
					      $desigilname;

			my Perl6::Element $leaf =
				%sigil-map{$sigil ~ $twigil}.new(
					:from( $p.from ),
					:to( $p.to ),
					:content( $p.Str )
				);
			$leaf
		}
		elsif self.assert-hash-keys( $p, [< name sigil >] ) {
			# XXX refactor back to a method
			my Str $sigil       = $p.hash.<sigil>.Str;
			my Str $twigil      = $p.hash.<twigil> ??
					      $p.hash.<twigil>.Str !! '';
			my Str $desigilname = $p.hash.<name> ??
					      $p.hash.<name>.Str !! '';
			my Str $content     = $p.hash.<sigil> ~
					      $twigil ~
					      $desigilname;

			my Perl6::Element $leaf =
				%sigil-map{$sigil ~ $twigil}.new(
					:from( $p.from ),
					:to( $p.to ),
					:content( $content )
				);
			$leaf
		}
		elsif self.assert-hash-keys( $p, [< signature >] ) {
			my Perl6::Element @child =
				self._signature( $p.hash.<signature> );
			Perl6::Operator::Circumfix.new(
				:from( $p.from ),
				:to( $p.to ),
				:delimiter( '(', ')' ),
				:child( @child )
			)
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
			my Str $x = $p.hash.<semilist>.Str;
			$x ~~ s{ ^ (\s*) } = ''; my Int $leading = $0.chars;
			$x ~~ s{ (\s+) $ } = ''; my Int $trailing = $0.chars;
			# XXX whitespace around text could be done differently?
			Perl6::Bareword.new(
				:from( $p.hash.<semilist>.from + $leading ),
				:to( $p.hash.<semilist>.to - $trailing ),
				:content( $x )
			)
		}
		elsif self.assert-hash-keys( $p, [< nibble O >] ) {
			my Str $x = $p.hash.<nibble>.Str;
			$x ~~ s{ ^ (\s*) } = ''; my Int $leading = $0.chars;
			$x ~~ s{ (\s+) $ } = ''; my Int $trailing = $0.chars;
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
			Perl6::Operator::Infix.new( $p.hash.<sym> )
		}
		elsif self.assert-hash-keys( $p, [< dig O >] ) {
			Perl6::Operator::Infix.new( $p.hash.<dig> )
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
			Perl6::Operator::Prefix.new( $p.hash.<sym> )
		}
		else {
			say $p.hash.keys.gist;
			warn "Unhandled case"
		}
	}

	method _quant( Mu $p ) {
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
			if $p.Str ~~ m:i/^Q/ {
				Perl6::String.new(
					:from( $p.from ),
					:to( $p.to ),
					:content( $p.Str ),
					:bare( $p.hash.<quibble>.hash.<nibble>.Str )
				)
			}
			else {
				Perl6::String.new(
					:from( $p.hash.<quibble>.from ),
					:to( $p.hash.<quibble>.to ),
					:content( $p.Str ),
					:bare( $p.hash.<quibble>.hash.<nibble>.Str )
				)
			}
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
					say $_.hash.keys.gist;
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

	method _radix( Mu $p ) {
		$p.hash.<radix>.Int
	}

	method _rad_number( Mu $p ) {
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

	# rule <name> { },
	# token <name> { },
	# regex <name> { },
	#
	method _regex_declarator( Mu $p ) {
		if self.assert-hash-keys( $p, [< sym regex_def >] ) {
			my Perl6::Element @child =
				self._sym( $p.hash.<sym> );
			@child.append(
				whitespace-separator(
					$p,
					$p.hash.<sym>,
					$p.hash.<regex_def>
				)
			);
			@child.append(
				self._regex_def( $p.hash.<regex_def> )
			);
			@child
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
			my Perl6::Element @_child =
				self._nibble( $p.hash.<nibble> );
			my Perl6::Element @child =
				self._deflongname( $p.hash.<deflongname> );
			my $remainder = substr( $p.Str, $p.hash.<deflongname>.Str.chars );
			if $remainder ~~ m{ ^ ( \s+ ) } {
				@child.append(
					Perl6::WS.new(
						:from(
							$p.hash.<deflongname>.to
						),
						:to(
							$p.hash.<deflongname>.to
							+ $0.Str.chars
						),
						:content( $0.Str )
					)
				)
			}
			# XXX Collect { } from the actual text
			@child.append(
				Perl6::Block.new(
					:from(
						$p.hash.<deflongname>.to +
						$0.chars
					),
					:to( $p.to ),
					:delimiter( '{', '}' ),
					:child( @_child )
				)
			);
			if $p.Str ~~ m{ ( \s+ ) $ } {
				@child.append(
					Perl6::WS.new(
						:from( $p.to - $0.chars ),
						:to( $p.to ),
						:content( $0.Str )
					)
				)
			}
			@child
		}
		else {
			say $p.hash.keys.gist;
			warn "Unhandled case"
		}
	}

	method _right( Mu $p ) {
		$p.hash.<right>.Bool
	}

	# sub <name> ... { },
	# method <name> ... { },
	# submethod <name> ... { },
	# macro <name> ... { }, # XXX ?
	#
	method _routine_declarator( Mu $p ) {
		if self.assert-hash-keys( $p,
			[< sym routine_def >] ) {
			my Perl6::Element @child =
				self._sym( $p.hash.<sym> );
			# XXX subsume this into the Perl6::WS object later
			if $p.hash.<routine_def>.Str ~~ m{ ^ ( \s+ ) } {
				@child.append(
					Perl6::WS.new(
						:from( $p.hash.<routine_def>.from ),
						:to( $p.hash.<routine_def>.from + $0.chars ),
						:content( $0.Str )
					)
				)
			}
			@child.append(
				self._routine_def( $p.hash.<routine_def> )
			);
			@child.flat
		}
		elsif self.assert-hash-keys( $p, [< sym method_def >] ) {
			my Perl6::Element @child =
				self._sym( $p.hash.<sym> );
			# XXX subsume this into the Perl6::WS object later
			if $p.hash.<method_def>.Str ~~ m{ ^ ( \s+ ) } {
				@child.append(
					Perl6::WS.new(
						:from( $p.hash.<method_def>.from ),
						:to( $p.hash.<method_def>.from + $0.chars ),
						:content( $0.Str )
					)
				)
			}
			@child.append(
				self._method_def( $p.hash.<method_def> )
			);
			@child.flat
		}
		else {
			say $p.hash.keys.gist;
			warn "Unhandled case"
		}
	}

	method _routine_def( Mu $p ) {
		if self.assert-hash-keys( $p,
				[< deflongname multisig blockoid >],
				[< trait >] ) {
			my Str $x = substr-match(
				$p,
				$p.from,
				$p.hash.<blockoid>.from - $p.from
			);
			my Int $offset = 0;
			if $x {
				$x ~~ m{ ')' (.*) $ }; $offset = $0.chars;
			}
			my Perl6::Element @child;
			if $p.from < $p.hash.<deflongname>.from {
				@child.append(
#					Perl6::WS.new(
#						$p.from,
#						substr-match( $p, $p.from,
#							$p.hash.<deflongname>.from - $p.from
#						)
#					)
				)
			}
			@child.append(
				self._deflongname( $p.hash.<deflongname> )
			);
			my Perl6::Element @multisig;
			if $p.hash.<deflongname>.to + 1 < $p.hash.<multisig>.from {
				@multisig.append(
#					Perl6::WS.new(
#						$p.hash.<deflongname>.to + 1,
#						substr-match( $p,
#							$p.hash.<deflongname>.to + 1,
#							$p.hash.<multisig>.from - $p.hash.<deflongname>.to - 1
#						)
#					)
				)
			}
			@multisig.append(
				self._multisig( $p.hash.<multisig> )
			);
			@child.append(
				Perl6::Operator::Circumfix.new(
					:from( $p.hash.<deflongname>.to ),
					:to(
						$p.hash.<blockoid>.from - $offset
					),
					:delimiter( '(', ')' ),
					:child( @multisig )
				),
			);
			if $p.hash.<blockoid>.from - $p.hash.<multisig>.to - 1 > 0 {
				my Int $_offset = @child[*-1].to;
				@child.append(
#					Perl6::WS.new(
#						@child[*-1].to,
#						substr-match(
#							$p,
#							$p.hash.<multisig>.to + 1,
#							$p.hash.<blockoid>.from - $p.hash.<multisig>.to - 1
#)
#					)
				)
			}
			@child.append(
				self._blockoid( $p.hash.<blockoid> )
			);
			@child.flat
		}
		elsif self.assert-hash-keys( $p,
				[< deflongname statementlist >],
				[< trait >] ) {
			my Perl6::Element @child =
				self._deflongname( $p.hash.<deflongname> );
			@child.append(
				self._statementlist( $p.hash.<statementlist> )
			);
			@child.append(
				semicolon-terminator( $p )
			);
			@child.flat
		}
		elsif self.assert-hash-keys( $p,
				[< deflongname trait blockoid >] ) {
			(
				self._deflongname( $p.hash.<deflongname> ),
				self._trait( $p.hash.<trait> ),
				self._blockoid( $p.hash.<blockoid> )
			).flat
		}
		elsif self.assert-hash-keys( $p,
				[< blockoid multisig >], [< trait >] ) {
			my Perl6::Element @child =
				self._multisig( $p.hash.<multisig> );
			(
				Perl6::Operator::Circumfix.new(
					:delimiter( '(', ')' ),
					:child( @child )
				),
				self._blockoid( $p.hash.<blockoid> )
			).flat
		}
		elsif self.assert-hash-keys( $p,
				[< deflongname blockoid >], [< trait >] ) {
			my Perl6::Element @child;
			@child.append(
				self._deflongname( $p.hash.<deflongname> )
			);
			@child.append(
				whitespace-separator(
					$p,
					$p.hash.<deflongname>,
					$p.hash.<blockoid>,
				)
			);
			@child.append(
				self._blockoid( $p.hash.<blockoid> )
			);
			@child.flat
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
			my Perl6::Element @child;
			@child.append(
				self._package_declarator(
					$p.hash.<package_declarator>
				)
			);
			@child.flat
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
			(
				self._declarator( $p.hash.<declarator> )
			).flat
		}
		else {
			say $p.hash.keys.gist;
			warn "Unhandled case"
		}
	}

	# my <name>
	# our <naem>
	# has <name>
	# HAS <name>
	# augment <name>
	# anon <name>
	# state <name>
	# supsersede <name>
	# unit {package,module,class...} <name>
	#
	method _scope_declarator( Mu $p ) {
		if self.assert-hash-keys( $p, [< sym scoped >] ) {
			my Perl6::Element @child =
				self._sym( $p.hash.<sym> );
			if $p.hash.<scoped>.Str ~~ m{ ^ ( \s+ ) } {
				@child.append(
					Perl6::WS.new(
						:from( $p.hash.<sym>.to ),
						:to( $p.hash.<sym>.to + $0.chars ),
						:content( $0.Str )
					)
				)
			}
			@child.append(
				self._scoped( $p.hash.<scoped> ).flat
			);
			@child.flat
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
			my Perl6::Element @child =
				self._EXPR(
					$p.hash.<statement>.list.[0].hash.<EXPR>
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

	method _septype( Mu $p ) {
		$p.hash.<septype>.Str
	}

	method _shape( Mu $p ) {
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

	method _sigil( Mu $p ) {
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

	method __Parameter( Mu $p ) {
		my Perl6::Element @child;
		if self.assert-hash-keys( $p,
			[< param_var type_constraint
			   quant post_constraint >],
			[< default_value modifier trait >] ) {
			# Synthesize the 'from' and 'to' markers for 'where'
			$p.Str ~~ m{ << (where) >> };
			my Int $from = $0.from;
			@child.append(
				self._type_constraint(
					$p.hash.<type_constraint>
				)
			);
			
			if $p.hash.<type_constraint>.list.[*-1].Str ~~ m{ (\s+) $ } {
				@child.append(
#					Perl6::WS.new(
#						$p.hash.<type_constraint>.list.[*-1].to - $0.chars,
#						$0.Str
#					)
				)
			}
			@child.append(
				self._param_var( $p.hash.<param_var> )
			);
			if $p.Str ~~ m{ (\s+) ('where') } {
				@child.append(
#					Perl6::WS.new(
#						$p.hash.<param_var>.to,
#						~$0
#					)
				)
			}
			@child.append(
				Perl6::Bareword.new(
					:from( $p.from + $from ),
					:to( $p.from + $from + WHERE.chars ),
					:content( WHERE )
				)
			);
			if $p.Str ~~ m{ ('where') (\s+) } {
#				@child.append(
#					Perl6::WS.new( $p.from + $0.to, ~$1 )
#				)
			}
			@child.append(
				self._post_constraint(
					$p.hash.<post_constraint>
				)
			);
		}
		elsif self.assert-hash-keys( $p,
			[< type_constraint param_var quant >],
			[< default_value modifier trait
			   post_constraint >] ) {
			@child.append(
				self._type_constraint(
					$p.hash.<type_constraint>
				)
			);
			if $p.Str ~~ m{ (\s+) } {
#				@child.append(
#					Perl6::WS.new( $p.from + $0.from, ~$0 )
#				)
			}
			@child.append(
				self._param_var( $p.hash.<param_var> )
			);
		}
		elsif self.assert-hash-keys( $p,
			[< param_var quant default_value >],
			[< modifier trait
			   type_constraint
			   post_constraint >] ) {
			@child.append(
				self._param_var( $p.hash.<param_var> )
			);
			if $p.Str ~~ m{ (\s+) ('=') } {
				@child.append(
#					Perl6::WS.new(
#						$p.hash.<param_var>.to,
#						~$0
#					)
				)
			}
			@child.append(
				Perl6::Operator::Infix.new( $p, EQUAL )
			);
			if $p.Str ~~ m{ ('=') (\s+) } {
#				@child.append(
#					Perl6::WS.new( $p.from + $0.to, ~$1 )
#				)
			}
			@child.append(
				self._default_value(
					$p.hash.<default_value>
				).flat
			);
		}
		elsif self.assert-hash-keys( $p,
			[< param_var quant >],
			[< default_value modifier trait
			   type_constraint
			   post_constraint >] ) {
			@child.append(
				self._param_var( $p.hash.<param_var> )#,
#					self._quant( $p.hash.<quant> )
			);
		}
		elsif self.assert-hash-keys( $p,
			[< named_param quant >],
			[< default_value type_constraint modifier
			   trait post_constraint >] ) {
			# Synthesize the 'from' and 'to' markers for ':'
			$p.Str ~~ m{ (':') };
			my Int $from = $0.from;
			@child.append(
				Perl6::Operator::Prefix.new(
					:from( $p.from + $from ),
					:to( $p.from + $from + COLON.chars ),
					:content( COLON )
				),
				self._named_param(
					$p.hash.<named_param>
				)
			);
		}
		elsif self.assert-hash-keys( $p,
			[< type_constraint >],
			[< default_value modifier trait
			   post_constraint >] ) {
			@child.append(
				self._type_constraint(
					$p.hash.<type_constraint>
				)
			)
		}
		else {
			say $p.hash.keys.gist;
			warn "Unhandled case"
		}
		@child
	}

	method _signature( Mu $p ) {
		if self.assert-hash-keys( $p,
				[< parameter typename >],
				[< param_sep >] ) {
			(
				self._typename( $p.hash.<typename> ),
				self._parameter( $p.hash.<parameter> )
			)
		}
		elsif self.assert-hash-keys( $p,
				[< parameter >],
				[< param_sep >] ) {
			my Mu $parameter = $p.hash.<parameter>;
			my Int $offset = $p.from;
			my Perl6::Element @child;
			if $p.Str ~~ m{ ^ ( \s+ ) } {
				@child.append(
#					Perl6::WS.new(
#						$p.from,
#						$0.Str
#					)
				)
			}
			for $parameter.list.kv -> $index, $_ {
				if $index > 0 {
					my Int $inset = 0;
					if $parameter.list.[$index-1].Str ~~ m{ (\s+) $} {
						$inset = $0.chars
					}
					my Int $start = $parameter.list.[$index-1].to - $inset;
					my Int $end = $parameter.list.[$index].from;
					my Str $str = substr(
						$p.Str, $start - $offset, $end - $start
					);
					@child.append(
						comma-separator(
							$start,
							$str
						)
					)
				}
				@child.append(
					self.__Parameter( $_ )
				);
			}
			if @child[*-1].to < $p.to {
				@child.push(
#					Perl6::WS.new(
#						@child[*-1].to,
#						substr(
#							$p.Str,
#							@child[*-1].to - $offset,
#							$p.to - @child[*-1].to + 1
#						)
#					)
				)
			}
			@child.flat
		}
		elsif self.assert-hash-keys( $p,
				[< param_sep >],
				[< parameter >] ) {
			(
				self._parameter( $p.hash.<parameter> )
			)
		}
		elsif self.assert-hash-keys( $p, [< >],
				[< param_sep parameter >] ) {
			()
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
					self._statement_control(
						$_.hash.<statement_control>
					)
				}
				elsif self.assert-hash-keys( $_, [],
						[< statement_control >] ) {push
					die "Not implemented yet"
				}
				else {
					say $_.hash.keys.gist;
					warn "Unhandled case"
				}
			}
			@child
		}
		elsif self.assert-hash-keys( $p, [< sym trait >] ) {
			my Perl6::Element @child =
				self._sym( $p.hash.<sym> );
			@child.append(
				self._trait( $p.hash.<trait> )
			);
			@child
		}
		# $p contains trailing whitespace for <package_declaration>
		#
		elsif self.assert-hash-keys( $p, [< EXPR >] ) {
			my Perl6::Element @child =
				self._EXPR( $p.hash.<EXPR> );
			@child.append(
				Perl6::WS.whitespace-terminator(
					$p,
					$p.hash.<EXPR>
				)
			);
#`(
# XXX XXX XXX
# XXX This should be pushed into the blocks where they belong.
# XXX XXX XXX
			if $p.hash.<EXPR>.hash.<routine_declarator> {
				if $p.hash.<EXPR>.to < $p.to {
					@child.append(
#						Perl6::WS.new(
#							$p.hash.<EXPR>.to,
#							substr-match( $p,
#								$p.hash.<EXPR>.to,
#								$p.to - $p.hash.<EXPR>.to
#							)
#						)
					)
				}
			}
			elsif $p.hash.<EXPR>.hash.<scope_declarator> {
				if $p.Str ~~ m{ (\s+) $ } {
					@child.append(
#						Perl6::WS.new(
#							$p.hash.<EXPR>.to,
#							$0.Str
#						)
					)
				}
			}
			elsif $p.hash.<EXPR>.list.elems == 2 and
					$p.hash.<EXPR>.hash.<infix> {
				@child.append(
#					Perl6::WS.new(
#						$p.hash.<EXPR>.list.[*-1].to,
#						substr-match(
#							$p,
#							$p.hash.<EXPR>.list.[*-1].to,
#							$p.to - $p.hash.<EXPR>.list.[*-1].to
#						)
#					)
				)
			}
			elsif $p.hash.<EXPR>.hash.<value> {
				@child.append(
#					Perl6::WS.new(
#						$p.hash.<EXPR>.hash.<value>.to,
#						substr-match(
#							$p,
#							$p.hash.<EXPR>.hash.<value>.to,
#							$p.to - $p.hash.<EXPR>.hash.<value>.to
#						)
#					)
				)
			}
			elsif $p.hash.<EXPR>.hash.<colonpair> {
				@child.append(
#					Perl6::WS.new(
#						$p.hash.<EXPR>.hash.<colonpair>.to,
#						substr-match(
#							$p,
#							$p.hash.<EXPR>.hash.<colonpair>.to,
#							$p.to - $p.hash.<EXPR>.hash.<colonpair>.to
#						)
#					)
				)
			}
)
			@child
		}
		elsif self.assert-hash-keys( $p, [< statement_control >] ) {
			my Perl6::Element @child =
				self._statement_control(
					$p.hash.<statement_control>
				).flat;
			@child
		}
		else {
			say $p.hash.keys.gist;
			warn "Unhandled case"
		}
	}

	method _statementlist( Mu $p ) {
		my Mu $statement = $p.hash.<statement>;
		my Perl6::Element @child;
		my Str $trailing-ws = '';
		my Int $trailing-ws-start = 0;
		for $statement.list {
			my Perl6::Element @_child =
				self._statement( $_ );
			if $trailing-ws ~~ m{ \s } {
				@_child.append(
					Perl6::WS.new(
						:from( @_child[0].from - $trailing-ws.chars ),
						:to( @_child[0].from + $trailing-ws.chars - 1 ),
						:content( $trailing-ws )
					)
				);
				$trailing-ws = '';
				$trailing-ws-start = 0
			}
			if $_.Str ~~ m{ ';' ( \s+ ) $ } {
				$trailing-ws = $0.Str;
				$trailing-ws-start = $_.to - $0.chars
			}
			@child.append(
				Perl6::Statement.from-list( @_child )
			)
		}
		if $trailing-ws ~~ m{ \s } {
			my Perl6::Element @_child =
				Perl6::WS.new(
#					:from( @child[*-1].from ),
#					:to( @child[*-1].from + $trailing-ws.chars ),
					:from( $trailing-ws-start ),
					:to( $trailing-ws-start + $trailing-ws.chars ),
					:content( $trailing-ws )
				);
			@child.append(
				Perl6::Statement.from-list( @_child )
			)
		}
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
					say $_.hash.keys.gist;
					warn "Unhandled case"
				}
			}
			@child
		}
		elsif $p.Str {
			Perl6::Bareword.new( $p )
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
		if $p.list {
			my Perl6::Element @child;
			for $p.list {
				if self.assert-hash-keys( $_, [< termconj >] ) {
					@child.append(
						self._termconj(
							$_.hash.<termconj>
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
		CATCH { when X::Hash::Store::OddNumber { .resume } } # XXX ?...
		if $p.list {
			my Perl6::Element @child;
			for $p.list {
				if self.assert-hash-keys( $_, [< termish >] ) {
					@child.append(
						self._termish(
							$_.hash.<termish>
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
					@child.append(
						self._termalt(
							$_.hash.<termalt>
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
		elsif self.assert-hash-keys( $p, [< termalt >] ) {
			self._termalt( $p.hash.<termalt> )
		}
		elsif $p.Str {
			# XXX
			my Str $str = $p.Str;
			$str ~~ s{\s+ $} = '';
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
		if $p.list {
			my Perl6::Element @child;
			for $p.list {
				if self.assert-hash-keys( $_, [< noun >] ) {
					@child.append(
						self._noun(
							$_.hash.<noun>
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
		elsif self.assert-hash-keys( $p, [< noun >] ) {
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
		if self.assert-hash-keys( $p,
				[< sym longname >],
				[< circumfix >] ) {
			my @child = 
				self._sym( $p.hash.<sym> );
			@child.append(
				whitespace-separator(
					$p,
					$p.hash.<sym>,
					$p.hash.<longname>
				)
			);
			@child.append(
				self._longname( $p.hash.<longname> )
			);
			@child
		}
		elsif self.assert-hash-keys( $p, [< sym typename >] ) {
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

	method _twigi( Mu $p ) {
		$p.hash.<sym>.Str
	}

	method _type_constraint( Mu $p ) {
		my Perl6::Element @child;
		if $p.list {
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
					say $_.hash.keys.gist;
					warn "Unhandled case"
				}
			}
		}
#		elsif self.assert-hash-keys( $p, [< value >] ) {
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
				return
					Perl6::Bareword.new( $_ )
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
				# XXX Can probably be narrowed
				return
					Perl6::Bareword.new( $_ )
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

	method _VALUE( Mu $p ) {
#		return $p.hash.<VALUE>.Str if
#			$p.hash.<VALUE>.Str and $p.hash.<VALUE>.Str eq '0';
#		$p.hash.<VALUE>.Int
		$p.hash.<VALUE>.Str || $p.hash.<VALUE>.Int
	}

	method _value( Mu $p ) {
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

	method _var( Mu $p ) {
		if self.assert-hash-keys( $p,
				[< sigil desigilname >] ) {
			# XXX For heavens' sake refactor.
			my Str $sigil	= $p.hash.<sigil>.Str;
			my Str $twigil	= $p.hash.<twigil> ??
					  $p.hash.<twigil>.Str !! '';
			my Str $desigilname = $p.hash.<desigilname> ??
					      $p.hash.<desigilname>.Str !! '';
			my Str $content =
				$p.hash.<sigil> ~ $twigil ~ $desigilname;
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
			my Int $from = $0.from;
			my Perl6::Element @child =
				self._variable( $p.hash.<variable> );
			@child.append(
				Perl6::Bareword.new(
					:from( $p.from + $from ),
					:to( $p.from + $from + 5 ),
					:content( WHERE )
				)
			);
			@child.append(
				self._post_constraint(
					$p.hash.<post_constraint>
				)
			);
			@child.flat
		}
		elsif self.assert-hash-keys( $p,
				[< variable >],
				[< semilist postcircumfix signature
				   trait post_constraint >] ) {
			(
				self._variable( $p.hash.<variable> )
			).flat
		}
		else {
			say $p.hash.keys.gist;
			warn "Unhandled case"
		}
	}

	method _variable( Mu $p ) {
		if self.assert-hash-keys( $p, [< contextualizer >] ) {
			return;
		}

		my Str $sigil	= $p.hash.<sigil>.Str;
		my Str $twigil	= $p.hash.<twigil> ??
			          $p.hash.<twigil>.Str !! '';
		my Str $desigilname =
			$p.hash.<desigilname> ??
			$p.hash.<desigilname>.Str !! '';
		my Str $content =
			$p.hash.<sigil> ~ $twigil ~ $desigilname;

		my Perl6::Element $leaf = %sigil-map{$sigil ~ $twigil}.new(
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

	method _vstr( Mu $p ) {
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
					say $_.hash.keys.gist;
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

	method _wu( Mu $p ) {
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
					say $_.hash.keys.gist;
					warn "Unhandled case"
				}
			}
			@child
		}
		elsif self.assert-hash-keys( $p, [< pblock EXPR >] ) {
			die "Not implemented yet";
		}
		elsif self.assert-hash-keys( $p, [< blockoid >] ) {
			self._blockoid( $p.hash.<blockoid> )
		}
		else {
			say $p.hash.keys.gist;
			warn "Unhandled case"
		}
	}
}
