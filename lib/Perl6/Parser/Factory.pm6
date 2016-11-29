=begin pod

=begin NAME

Perl6::Parser::Factory - Builds client-ready Perl 6 data tree

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
	        L<Perl6::Variable::Scalar::Contextualizer>
                L<...>
	    L<Perl6::Variable::Hash>
	    L<Perl6::Variable::Array>
	    L<Perl6::Variable::Callable>

=end DESCRIPTION

=begin CLASSES

=item L<Perl6::Element>

The root of the object hierarchy.

This hierarchy is mostly for the clients' convenience, so that they can safely ignore the fact that an object is actually a L<Perl6::Number::Complex::Radix::FloatingPoint> when all they really want to know is that it's a L<Perl6::Number>.

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
        L<Perl6::Number::Decimal::FloatingPoint>
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
        L<Perl6::Variable::Scalar::Contextualizer>
    L<Perl6::Variable::Hash>
        (and the same subtypes)
    L<Perl6::Variable::Array>
        (and the same subtypes)
    L<Perl6::Variable::Callable>
        (and the same subtypes)

=cut

=item L<Perl6::Variable::Scalar::Contextualizer>

Children: L<Perl6::Variable::Scalar::Contextualizer> and so forth.

(a side note - These really should be L<Perl6::Variable::Scalar::Contextualizer>, but that would mean that these were both a Leaf (from the parent L<Perl6::Variable::Scalar> and Branching because they have children). Resolving this would mean removing the L<Perl6::Leaf> role from the L<Perl6::Variable::Scalar> class, which means that I either have to create a longer class name for L<Perl6::Variable::JustAPlainScalarVariable> or manually add the L<Perl6::Leaf>'s contents to the L<Perl6::Variable::Scalar>, and forget to update it when I change my mind in a few weeks' time about what L<Perl6::Leaf> does. Adding a separate class for this seems the lesser of two evils, especially given how often they'll appear in "real world" code.)

=cut

=item L<Perl6::Sir-Not-Appearing-In-This-Statement>

By way of caveat: If you stick to the APIs mentioned in the documentation, you should never deal with objects in this class. Ever. If you see this, you're probably debugging internals of this module, and if you're not, please send the author a snippet of code B<and> the associated Perl 6 code that replicates it.

While you should stick to the published APIs, there are of course times when you need to get your proverbial hands dirty. Read on if you want the scoop.

Your humble author has gone to a great deal of trouble to assure that every character of user code is parsed and represented in some fashion, and the internals keep track of the text down to the by..chara...glyph level. More to the point, each Perl6::Parser element has its own start and end point.

The internal method C<check-tree> does a B<rigorous> check of the entire parse tree, at least while self-tests are runnin. Relevant to the discussion at hand are two things: Checking that each element has exactly the number of glyphs that its start and end claim that it has, and checking that each element exactly overlaps its neighbos, with no gaps.

Look at a sample contrived here-doc:

    # It starts
    #   V-- here. V--- But does it end here?
    say Q:to[_END_]; say 2 +
        First line
        _END_
    #   ^--- Wait, it ends here, in the *middle* of the next statement.
    5;

While a contrived example, it'll do to make my points. The first rule the internals assert is that tokens start at glyph X and end at glyph Y. Here-docs break that rule right off the bat. They start at the C<Q:to[_END_]>, skip a bunch of glyphs ahead, then stop at the terninal C<_END_> several lines later.

So, B<internally>, here-docs start at the C<Q> of C<Q:to[_END_]> and end at the closing C<]> of C<Q:to[_END_]>. Any other text that it might have is stored somewhere that the self-test algorithm won't find it. So if you're probing the L<Here-Doc> class for its text directly (which the author disrecommends), you won't find it all there.

There also can't be any gaps between two tokens, and again, here-docs break that rule. If we take it at face value, C<Q:to[_END_]> and C<First line.._END_> are two separate tokens, simply because there's an intervening 'say 2', which (to make matters worse) is in a different L<Perl6::Statement>.

Now L<Perl6::Sir-Not-Appearing-In-This-Statement> comes into play. Since tokens can only be a single block of text, we can't have both the C<Q:to[_END_]> and C<First line> be in the same token; and if we did break them up (which we do), they can't be the same class, because we'd end up with multiple heredocs later on when parsing.

So our single here-doc internally becomes two elements. First comes the official L<Perl6::String> element, which you can query to get the delimiter (C<_END_>), full text (C<Q:to[_END_]>\nFirst line\n_END_> and the body text, C<First line>.

Later on, we run across the actual body of the here-doc, and rather than fiddling with the validation algorithms, we drop in L<Sir-Not-Appearing-In-This-Statement>, a "token" that doesn't exist. It has the bounds of the C<First line\n_END_> text, so that it appears for our validation algorithm. But it's special-cased to not appear in the C<dump-tree> method, or anything that deals with L<Perl6::Statement>s because while B<syntactically> it's in a statement's boundary, it's not B<semantically> part of the statement it "appears" in.

Whew. If you're doing manipulation of statements, B<now> hopefully you'll see why the author recommends sticking to the methods in the API. Eventually this little kink may get ironed out and here-docs may be relegated to a special case somewhere, but not today.

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

role Matchable {

	multi method from-match( Mu $p ) {
		self.bless(
			:factory-line-number( callframe(1).line ),
			:from( $p.from ),
			:to( $p.to ),
			:content( $p.Str )
		)
	}

	multi method from-match-trimmed( Mu $p ) {
		$p.Str ~~ m{ ^ ( \s* ) ( .+? ) ( \s* ) $ };
		self.bless(
			:factory-line-number( callframe(1).line ),
			:from( $p.from + ( $0.Str ?? $0.Str.chars !! 0 ) ),
			:to( $p.to - ( $2.Str ?? $2.Str.chars !! 0 ) ),
			:content( $1.Str )
		)
	}

	multi method from-int( Int $from, Str $str ) {
		self.bless(
			:factory-line-number( callframe(1).line ),
			:from( $from ),
			:to( $from + $str.chars ),
			:content( $str )
		)
	}
}

class Perl6::Element {
	has Int $.from is required;
	has Int $.to is required;
	has $.factory-line-number; # Purely a debugging aid.
}

role Child {
	has Perl6::Element @.child;
}

# XXX There should be a better way to do this.
# XXX I could use wrap() probably...
#
role Branching does Child {
	method to-string( ) {
		join( '', map { .to-string( ) }, @.child )
	}
}

role Token {
	has Str $.content is required;

	method to-string( ) {
		~$.content
	}
}

class Perl6::Structural {
	also is Perl6::Element;
}

# Semicolons should only occur at statement boundaries.
# So they're only generated in the _statement handler.
#
class Perl6::Semicolon does Token {
	also is Perl6::Structural;
	also does Matchable;
}

# Generic balanced character
class Perl6::Balanced {
	also is Perl6::Structural;

	multi method from-int( Int $from, Str $str ) {
		self.bless(
			:factory-line-number( callframe(1).line ),
			:from( $from ),
			:to( $from + $str.chars ),
			:content( $str )
		)
	}
}
class Perl6::Balanced::Enter does Token {
	also is Perl6::Balanced;
}
class Perl6::Balanced::Exit does Token {
	also is Perl6::Balanced;
}

role MatchingBalanced {

	method from-match( Mu $p, @child ) {
		my Perl6::Element @_child;
		$p.Str ~~ m{ ^ (.) .* (.) $ };
		@_child.append(
			Perl6::Balanced::Enter.from-int( $p.from, $0.Str )
		);
		@_child.append( @child );
		@_child.append(
			Perl6::Balanced::Exit.from-int(
				$p.to - $1.Str.chars,
				$1.Str
			)
		);
		self.bless(
			:factory-line-number( callframe(1).line ),
			:from( $p.from ),
			:to( $p.to ),
			:child( @_child )
		)
	}

	method from-int( Int $from, Str $str, @child ) {
		my Perl6::Element @_child;
		$str ~~ m{ ^ (.) .* (.) $ };
		@_child.append(
			Perl6::Balanced::Enter.from-int( $from, $0.Str )
		);
		@_child.append( @child );
		@_child.append(
			Perl6::Balanced::Exit.from-int(
				$from + $str.chars - 1,
				$1.Str
			)
		);
		self.bless(
			:factory-line-number( callframe(1).line ),
			:from( $from ),
			:to( $from + $str.chars ),
			:child( @_child )
		)
	}
}

class Perl6::Operator {
	also is Perl6::Element;
	also does Matchable;
}
class Perl6::Operator::Hyper does Branching {
	also is Perl6::Operator;
}
class Perl6::Operator::Prefix does Token {
	also is Perl6::Operator;
}
class Perl6::Operator::Infix does Token {
	also is Perl6::Operator;

	multi method find-match( Mu $p, Str $token ) {
		$p.Str ~~ m{ ($token) };
		my Int $offset = $0.from;
		self.bless(
			:factory-line-number( callframe(1).line ),
			:from( $p.from + $offset ),
			:to( $p.from + $offset + $token.chars ),
			:content( $token )
		)
	}
}
class Perl6::Operator::Postfix does Token {
	also is Perl6::Operator;
}
class Perl6::Operator::Circumfix does Branching {
	also is Perl6::Operator;
	also does MatchingBalanced;
}
class Perl6::Operator::PostCircumfix does Branching {
	also is Perl6::Operator;
	also does MatchingBalanced;

	method from-delims( Mu $p, Str $front, Str $back, @child ) {
		my Perl6::Element @_child;
		@_child.append(
			Perl6::Balanced::Enter.from-int( $p.from, $front )
		);
		@_child.append( @child );
		@_child.append(
			Perl6::Balanced::Exit.from-int(
				$p.to - $back.chars,
				$back
			)
		);
		self.bless(
			:factory-line-number( callframe(1).line ),
			:from( $p.from ),
			:to( $p.to ),
			:child( @_child )
		)
	}
}

class Perl6::WS does Token {
	also is Perl6::Element;
	also does Matchable;
}

class Perl6::Comment does Token {
	also is Perl6::Element;
	also does Matchable;
}

class Perl6::Document does Branching {
	also is Perl6::Element;

	method from-list( Perl6::Element @child ) {
		self.bless(
			# No line number needed.
			:from( @child ?? @child[0].from !! 0 ),
			:to( @child ?? @child[*-1].to !! 0 ),
			:child( @child )
		)
	}
}

# If you have any curiosity about this, please search for /Sir-Not in the
# docs. This workaround may be gone by the time you read about this class,
# and if so, I'm glad.
#
class Perl6::Sir-Not-Appearing-In-This-Statement {
	also is Perl6::Element;
	has $.content; # XXX because it's not quite a token.

	method to-string( ) {
		~$.content
	}
}

class Perl6::Statement does Branching {
	also is Perl6::Element;

	method from-list( Perl6::Element @child ) {
		self.bless(
			:factory-line-number( callframe(1).line ),
			:from( @child[0].from ),
			:to( @child[*-1].to ),
			:child( @child )
		)
	}
}

role Prefixed {
	method headless() {
		$.content ~~ m/ 0 <[bdox]> (.+) /;
		$0
	}
}

# And now for the most basic tokens...
#
class Perl6::Number does Token {
	also is Perl6::Element;
	also does Matchable;
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
class Perl6::NotANumber is Token {
	also is Perl6::Element;
	also does Matchable;
}
class Perl6::Infinity is Token {
	also is Perl6::Element;
	also does Matchable;
}
class Perl6::Number::Radix {
	also is Perl6::Number;
}
class Perl6::Number::FloatingPoint {
	also is Perl6::Number;
}

class Perl6::Regex does Token {
	also is Perl6::Element;
	also does Matchable;
}

class Perl6::String does Token {
	also is Perl6::Element;
	also does Matchable;

	has @.delimiter;
}
class Perl6::String::Single does Token {
	also is Perl6::String;

	has Str @.delimiter = ( Q{'}, Q{'} );
}
class Perl6::String::Double does Token {
	also is Perl6::String;

	has Str @.delimiter = ( Q{"}, Q{"} );
}

class Perl6::Bareword does Token {
	also is Perl6::Element;
	also does Matchable;
}
class Perl6::PackageName does Token {
	also is Perl6::Element;
	also does Matchable;

	method namespaces() {
		$.content.split( '::' )
	}
}
class Perl6::ColonBareword does Token {
	also is Perl6::Bareword;
}
class Perl6::Block does Branching {
	also is Perl6::Element;
	also does MatchingBalanced;
}

class Perl6::Variable {
	also is Perl6::Element;
	also does Matchable;

	method headless() {
		$.content ~~ m/ <[$%@&]> <[*!?<^:=~]>? (.+) /;
		$0
	}
}
class Perl6::Variable::Scalar does Token {
	also is Perl6::Variable;
	has Str $.sigil = Q{$};
}
class Perl6::Variable::Scalar::Contextualizer does Token does Child {
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

my role Assertions {

	method assert-hash-strict( Mu $p, $required-with, $required-without ) {
		my %classified = classify {
			$p.hash.{$_}.Str ?? 'with' !! 'without'
		}, $p.hash.keys;
		my @keys-with-content = @( %classified<with> );
		my @keys-without-content = @( %classified<without> );

		return True if
			@( $required-with ) ~~ @keys-with-content and
			@( $required-without ) ~~ @keys-without-content;

		if 0 { # For debugging purposes, but it does get in the way.
			$*ERR.say: "Required keys with content: {@( $required-with )}";
			$*ERR.say: "Actually got: {@keys-with-content.gist}";
			$*ERR.say: "Required keys without content: {@( $required-without )}";
			$*ERR.say: "Actually got: {@keys-without-content.gist}";
		}
		return False;
	}

	method assert-hash( Mu $p, $keys, $defined-keys = [] ) {
		return False unless $p and $p.hash;

		my Str @keys;
		my Str @defined-keys;
		for $p.hash.keys {
			if $p.hash.{$_} {
				@keys.push( $_ );
			}
			elsif $p.hash:defined{$_} {
				@defined-keys.push( $_ );
			}
		}

		if $p.hash.keys.elems !=
			$keys.elems + $defined-keys.elems {
			return False
		}
		
		for @( $keys ) {
			next if $p.hash.{$_};
			return False
		}
		for @( $defined-keys ) {
			next if $p.hash:defined{$_};
			return False
		}
		return True
	}
}

class Perl6::Parser::Factory {
	also does Assertions;

	constant VERSION-STR = Q{v};
	constant PAREN-OPEN = Q'(';
	constant PAREN-CLOSE = Q')';
	constant BRACE-OPEN = Q'{';
	constant BRACE-CLOSE = Q'}';
	constant REDUCE-OPEN = Q'[';
	constant REDUCE-CLOSE = Q']';

	constant COLON = Q{:};
	constant COMMA = Q{,};
	constant PERIOD = Q{.};
	constant SEMICOLON = Q{;};
	constant EQUAL = Q{=};
	constant WHERE = Q{where};
	constant QUES-QUES = Q{??};
	constant BANG-BANG = Q{!!};
	constant FAT-ARROW = Q{=>};
	constant HYPER = Q{>>};
	constant BACKSLASH = Q'\'; # because the braces confuse vim.

	has %.here-doc; # Text for here-docs, indexed by their $p.from.

	my class Here-Doc {
		has Int $.delimiter-start; # 'q:to[_FOO_]'
		has Int $.body-from; # 'Hello, world!\n_FOO_'
		has Int $.body-to;   # 'Hello, world!\n_FOO_'
		has Str $.marker;
	}

	method __Build-Heredoc-List( Mu $p ) {
		%.here-doc = ();
		while $p.Str ~~ m:c{ ( 'q:to[' ) \s* ( <-[ \] ]>+ ) } {
			my Int $start = $0.from;
			my Str $marker = $1.Str;
			$p.Str ~~ m{ \s* ']' ( .*? $$ ) (.+?) ( $marker ) };
			%.here-doc{ $start } = Here-Doc.new(
				:factory-line-number(
					callframe(1).line
				),
				:delimiter-start( $start ),
				:body-from( $1.from ),
				:body-to( $1.to ),
				:marker( $marker )
			);
		}
	}

	sub _string-to-tokens( Int $from, Str $str ) {
		my Perl6::Element @child;

		if $str ~~ m{ ^ ( \s* ) '#`' } {
		}
		elsif $str ~~ m{ ^ ( '#' .+ ) $ } {
			@child.append(
				Perl6::Comment.from-int( $from, $0.Str )
			);
		}
		elsif $str ~~ m{ ^ ( \s+ ) ( '#' .+ ) $$ ( \s+ ) $ } {
			@child.append(
				Perl6::WS.from-int( $from, $0.Str )
			);
			@child.append(
				Perl6::Comment.from-int(
					$from + $0.Str.chars,
					$1.Str
				)
			);
			@child.append(
				Perl6::WS.from-int(
					$from + $0.Str.chars + $1.Str.chars,
					$2.Str
				)
			);
		}
		elsif $str ~~ m{ \S } {
		}
		else {
			@child.append(
				Perl6::WS.from-int( $from, $str )
			)
		}
		@child;
	}

	method build( Mu $p ) {
		self.__Build-Heredoc-List( $p );
		my Perl6::Element @_child;
		@_child.append(
			self._statementlist( $p.hash.<statementlist> )
		);
		if $p.hash.<statementlist>.hash.<statement>.list.elems == 1 and
		   @_child[*-1].child[*-1].to < $p.to {
			my $text = $p.Str.substr( @_child[*-1].child[*-1].to );
			unless $text ~~ m{ ^ '#' } {
				my $content = $p.Str.substr(
					@_child[*-1].child[*-1].to
				);
				@_child[*-1].child.append(
					Perl6::Sir-Not-Appearing-In-This-Statement.new(
						:factory-line-number(
							callframe(1).line
						),
						:from(
							@_child[*-1].child[*-1].to
						),
						:to( $p.to ),
						:content( $content )
					)
				);
			}
		}

		my Perl6::Element $root = Perl6::Document.from-list( @_child );
		fill-gaps( $p, $root );
		if $p.from < $root.from {
			my $remainder = $p.orig.Str.substr( 0, $root.from );
			my Perl6::Element @child;
			@child.append(
				_string-to-tokens( $p.from, $remainder )
			);
			$root.child.splice(
				0, 0, @child
			);
		}
		if $root.to < $p.to {
			my $remainder = $p.orig.Str.substr( $root.to );
			my Perl6::Element @child;
			@child.append(
				_string-to-tokens( $p.from, $remainder )
			);
			$root.child.append(
				@child
			);
		}
		$root;
	}

	sub _fill-gap( Mu $p, Perl6::Element $root, Int $index ) {
		my $start = $root.child.[$index].to;
		my $end = $root.child.[$index+1].from;

		if $start < 0 or $end < 0 {
			say "Negative match index!";
			return;
		}
		elsif $start > $end {
			say "Crossing streams";
			return;
		}

		my $x = $p.orig.Str.substr( $start, $end - $start );
		my @child = _string-to-tokens( $start, $x );
		$root.child.splice(
			$index + 1,
			0,
			@child
		);
	}

	sub fill-gaps( Mu $p, Perl6::Element $root, Int $depth = 0 ) {
		if $root.^can( 'child' ) {
			for reverse( 0 .. $root.child.elems - 1 ) {
				fill-gaps( $p, $root.child.[$_], $depth + 1 );
				if $_ < $root.child.elems - 1 {
					if $root.child.[$_].to !=
					   $root.child.[$_+1].from {
						_fill-gap( $p, $root, $_ );
					}
				}
			}
		}
	}

	sub key-bounds( Mu $p ) {
		my $from-to = "{$p.from} {$p.to}";
		if $p.list {
			#say "-1 -1 *list*"
			$*ERR.say: "$from-to [{substr($p.orig,$p.from,$p.to-$p.from)}]"
		}
		elsif $p.orig {
			$*ERR.say: "$from-to [{substr($p.orig,$p.from,$p.to-$p.from)}]"
		}
		else {
			$*ERR.say: "-1 -1 NIL"
		}
	}

	sub debug-match( Mu $p ) {
		my %classified = classify {
			$p.hash.{$_}.Str ?? 'with' !! 'without'
		}, $p.hash.keys;
		my @keys-with-content = @( %classified<with> );
		my @keys-without-content = @( %classified<without> );

		$*ERR.say: "With content: {@keys-with-content.gist}";
		$*ERR.say: "Without content: {@keys-without-content.gist}";
	}

	method _arglist( Mu $p ) {
		my Perl6::Element @child;
		if $p.list {
			for $p.list {
				if self.assert-hash( $_, [< EXPR >] ) {
					@child.append(
						self._EXPR( $_.hash.<EXPR> )
					);
				}
				elsif $_.Bool {
					# XXX Zero-width token
				}
				else {
					debug-match( $_ );
					die "Unhandled case" if
						$*FACTORY-FAILURE-FATAL
				}
			}
		}
		elsif self.assert-hash( $p,
				[< deftermnow initializer term_init >],
				[< trait >] ) {
			@child.append(
				self._deftermnow( $p.hash.<deftermnow> )
			);
			@child.append(
				self._initializer( $p.hash.<initializer> )
			);
			@child.append( self._term_init( $p.hash.<term_init> ) );
		}
		elsif self.assert-hash( $p, [< EXPR >] ) {
			@child.append( self._EXPR( $p.hash.<EXPR> ) );
		}
		else {
			debug-match( $p );
			die "Unhandled case" if
				$*FACTORY-FAILURE-FATAL
		}
		@child;
	}

	method _args( Mu $p ) {
		my Perl6::Element @child;
		given $p {
			when self.assert-hash( $_,
					[< invocant semiarglist >] ) {
				@child.append(
					self._invocant( $p.hash.<invocant> )
				);
				@child.append(
					self._semiarglist(
						$p.hash.<semiarglist>
					)
				);
			}
			when self.assert-hash( $_, [< semiarglist >] ) {
				my Perl6::Element @_child;
				@_child.append(
					self._semiarglist(
						$_.hash.<semiarglist>
					)
				);
				@child.append(
					Perl6::Operator::Circumfix.from-match(
						$_, @_child
					)
				);
			}
			when self.assert-hash( $_, [< arglist >] ) {
				@child.append(
					self._arglist( $_.hash.<arglist> )
				);
			}
			when self.assert-hash( $_, [< EXPR >] ) {
				@child.append( self._EXPR( $_.hash.<EXPR> ) );
			}
			default {
				debug-match( $_ );
				die "Unhandled case" if
					$*FACTORY-FAILURE-FATAL
			}
		}
		@child;
	}

	# { }
	# ?{ }
	# !{ }
	# var
	# name
	# ~~
	#
	method _assertion( Mu $p ) {
		given $p {
			when self.assert-hash( $_, [< var >] ) {
				self._var( $_.hash.<var> );
			}
			when self.assert-hash( $_, [< longname >] ) {
				self._longname( $_.hash.<longname> );
			}
			when self.assert-hash( $_, [< cclass_elem >] ) {
				self._cclass_elem( $_.hash.<cclass_elem> );
			}
			when self.assert-hash( $_, [< codeblock >] ) {
				self._codeblock( $_.hash.<codeblock> );
			}
			default {
				if $_.Str {
					Perl6::Bareword.from-match( $_ );
				}
				else {
					debug-match( $_ );
					die "Unhandled case" if $*FACTORY-FAILURE-FATAL
				}
			}
		}
	}

	method _atom( Mu $p ) {
		if $p.Str {
			Perl6::Bareword.from-match( $p );
		}
		else {
			given $p {
				when self.assert-hash( $_, [< metachar >] ) {
					Perl6::Bareword.from-match( $_ );
				}
				default {
					debug-match( $_ );
					die "Unhandled case" if
						$*FACTORY-FAILURE-FATAL
				}
			}
		}
	}

	method _B( Mu $p ) {
		given $p {
			default {
				debug-match( $_ );
				die "Unhandled case" if
					$*FACTORY-FAILURE-FATAL
			}
		}
	}

	method _babble( Mu $p ) {
		given $p {
			when self.assert-hash( $_, [< B >], [< quotepair >] ) {
				self._B( $_.hash.<B> );
			}
			default {
				debug-match( $_ );
				die "Unhandled case" if
					$*FACTORY-FAILURE-FATAL
			}
		}
	}

	method _backmod( Mu $p ) {
#		warn "backmod finally used";
		( )
	}

	# qq
	# \\
	# miscq # {} . # ?
	# misc # \W
	# a
	# b
	# c
	# e
	# f
	# n
	# o
	# rn
	# t
	#
	method _backslash( Mu $p ) {
		given $p {
			when self.assert-hash( $_, [< sym >] ) {
				self._sym( $_.hash.<sym> );
			}
			default {
				debug-match( $_ );
				die "Unhandled case" if
					$*FACTORY-FAILURE-FATAL
			}
		}
	}

	method _binint( Mu $p ) {
		Perl6::Number::Binary.from-match( $p );
	}

	method _block( Mu $p ) {
		given $p {
			when self.assert-hash( $_, [< blockoid >] ) {
				self._blockoid( $_.hash.<blockoid> );
			}
			default {
				debug-match( $_ );
				die "Unhandled case" if
					$*FACTORY-FAILURE-FATAL
			}
		}
	}

	method _blockoid( Mu $p ) {
		my Perl6::Element @child;
		given $p {
			# $_ doesn't contain WS after the block.
			when self.assert-hash( $_, [< statementlist >] ) {
				my Perl6::Element @_child;
				@_child.append(
					self._statementlist(
						$_.hash.<statementlist>
					)
				);
				@child.append(
					Perl6::Block.from-match( $_, @_child )
				);
			}
			default {
				debug-match( $_ );
				die "Unhandled case" if $*FACTORY-FAILURE-FATAL
			}
		}
		@child;
	}

	method _blorst( Mu $p ) {
		given $p {
			when self.assert-hash( $_, [< statement >] ) {
				self._statement( $_.hash.<statement> );
			}
			when self.assert-hash( $_, [< block >] ) {
				self._block( $_.hash.<block> );
			}
			default {
				debug-match( $_ );
				die "Unhandled case" if
					$*FACTORY-FAILURE-FATAL
			}
		}
	}

	method _bracket( Mu $p ) {
		given $p {
			when self.assert-hash( $_, [< semilist >] ) {
				self._semilist( $_.hash.<semilist> );
			}
			default {
				debug-match( $_ );
				die "Unhandled case" if
					$*FACTORY-FAILURE-FATAL
			}
		}
	} 

	method _cclass_elem( Mu $p ) {
		my Perl6::Element @child;
		if $p.list {
			for $p.list {
				if self.assert-hash( $_,
						[< identifier name sign >],
						[< charspec >] ) {
					@child.append(
						self._identifier(
							$_.hash.<identifier>
						)
					);
					@child.append(
						self._name( $_.hash.<name> )
					);
					@child.append(
						self._sign( $_.hash.<sign> )
					);
				}
				elsif self.assert-hash( $_,
						[< sign charspec >] ) {
					@child.append(
						self._sign( $p.hash.<sign> )
					);
					@child.append(
						self._charspec(
							$p.hash.<charspec>
						)
					);
				}
				else {
					debug-match( $_ );
					die "Unhandled case" if
						$*FACTORY-FAILURE-FATAL
				}
			}
		}
		else {
			debug-match( $p );
			die "Unhandled case" if
				$*FACTORY-FAILURE-FATAL
		}
		@child;
	}

	method _charspec( Mu $p ) {
# XXX work on this, of course.
		warn "Caught _charspec";
		return True if $p.list;
	}

	# ( )
	# STATEMENT_LIST( )
	# ang # < > # ?
	# << >>
	# « »
	# { }
	# [ ]
	# reduce
	#
	method _circumfix( Mu $p ) {
		my Perl6::Element @child;
		if $p.list {
			for $p.list {
				if self.assert-hash( $_, [< semilist >] ) {
					my Perl6::Element @_child;
					@_child.append(
						self._semilist( $_.hash.<semilist> )
					);
					@child.append(
						Perl6::Operator::Circumfix.from-match(
							$_, @_child
						)
					);
				}
				else {
					debug-match( $_ );
					die "Unhandled case" if
						$*FACTORY-FAILURE-FATAL
				}
			}
		}
		else {
			given $p {
				when self.assert-hash( $_, [< binint VALUE >] ) {
					@child.append(
						self._binint( $_.hash.<binint> )
					);
				}
				when self.assert-hash( $_, [< octint VALUE >] ) {
					@child.append(
						self._octint( $_.hash.<octint> )
					);
				}
				when self.assert-hash( $_, [< decint VALUE >] ) {
					@child.append(
						self._decint( $_.hash.<decint> )
					);
				}
				when self.assert-hash( $_, [< hexint VALUE >] ) {
					@child.append(
						self._hexint( $_.hash.<hexint> )
					);
				}
				when self.assert-hash( $_, [< pblock >] ) {
					@child.append(
						self._pblock( $_.hash.<pblock> )
					);
				}
				when self.assert-hash( $_, [< semilist >] ) {
					my Perl6::Element @_child;
					@_child.append(
						self._semilist( $_.hash.<semilist> )
					);
					@child.append(
						Perl6::Operator::Circumfix.from-match(
							$_, @_child
						)
					);
				}
				when self.assert-hash( $_, [< nibble >] ) {
					my Perl6::Element @_child;
					@_child.append(
						Perl6::Operator::Prefix.from-match-trimmed(
							$_.hash.<nibble>
						)
					);
					@child.append(
						Perl6::Operator::Circumfix.from-match(
							$_, @_child
						)
					);
				}
				default {
					debug-match( $_ );
					die "Unhandled case" if
						$*FACTORY-FAILURE-FATAL
				}
			}
		}
		@child;
	}

	method _codeblock( Mu $p ) {
		given $p {
			when self.assert-hash( $_, [< block >] ) {
				self._block( $_.hash.<block> );
			}
			default {
				debug-match( $_ );
				die "Unhandled case" if
					$*FACTORY-FAILURE-FATAL
			}
		}
	}

	method _coercee( Mu $p ) {
		given $p {
			when self.assert-hash( $_, [< semilist >] ) {
				self._semilist( $_.hash.<semilist> );
			}
			default {
				debug-match( $_ );
				die "Unhandled case" if
					$*FACTORY-FAILURE-FATAL
			}
		}
	}

	method _coloncircumfix( Mu $p ) {
		given $p {
			when self.assert-hash( $_, [< circumfix >] ) {
				self._circumfix( $_.hash.<circumfix> );
			}
			default {
				debug-match( $_ ) if $*DEBUG;
				die "Unhandled case" if
					$*FACTORY-FAILURE-FATAL
			}
		}
	}

	method _colonpair( Mu $p ) {
		my Perl6::Element @child;
		given $p {
			when self.assert-hash( $_,
				     [< identifier coloncircumfix >] ) {
				# Synthesize the 'from' marker for ':'
				@child.append(
					Perl6::Operator::Prefix.from-int(
						$_.from, COLON
					)
				);
				@child.append(
					self._identifier( $_.hash.<identifier> )
				);
				@child.append(
					self._coloncircumfix(
						$_.hash.<coloncircumfix>
					)
				);
			}
			when self.assert-hash( $_, [< coloncircumfix >] ) {
				# XXX Note that ':' is part of the expression.
				@child.append(
					Perl6::Operator::Prefix.from-int(
						$_.from, COLON
					)
				);
				@child.append(
					self._coloncircumfix(
						$_.hash.<coloncircumfix>
					)
				);
			}
			when self.assert-hash( $_, [< identifier >] ) {
				@child.append(
					Perl6::ColonBareword.from-match( $_ )
				);
			}
			when self.assert-hash( $_, [< fakesignature >] ) {
				# XXX May not really be "post" in the P6 sense?
				my Perl6::Element @_child;
				@_child.append(
					self._fakesignature(
						$_.hash.<fakesignature>
					)
				);
				# XXX properly match delimiter
				@child.append(
					Perl6::Operator::PostCircumfix.from-delims(
						$_, ':(', ')', @_child
					)
				);
			}
			when self.assert-hash( $_, [< var >] ) {
				# Synthesize the 'from' marker for ':'
				# XXX is this actually a single token?
				# XXX I think it is.
				@child.append(
					Perl6::Operator::Prefix.from-int(
						$_.from, COLON
					)
				);
				@child.append( self._var( $_.hash.<var> ) );
			}
			default {
				debug-match( $_ ) if $*DEBUG;
				die "Unhandled case" if
					$*FACTORY-FAILURE-FATAL
			}
		}
		@child;
	}

	method _colonpairs( Mu $p ) {
		given $p {
			when $_ ~~ Hash {
				return True if $_.<D>;
				return True if $_.<U>;
			}
			default {
				debug-match( $_ ) if $*DEBUG;
				die "Unhandled case" if
					$*FACTORY-FAILURE-FATAL
			}
		}
	}

	method _contextualizer( Mu $p ) {
		my Perl6::Element @child;
		given $p {
			when self.assert-hash( $_,
					[< coercee sigil sequence >] ) {
				@child.append(
					self._sigil(
						$_.hash.<sigil>
					)
				);
				# XXX coercee handled inside circumfix
				@child.append(
					self._sequence(
						$_.hash.<sequence>
					)
				);
			}
			when self.assert-hash( $_,
					[< coercee circumfix sigil >] ) {
				@child.append(
					self._sigil(
						$_.hash.<sigil>
					)
				);
				# XXX coercee handled inside circumfix
				@child.append(
					self._circumfix(
						$_.hash.<circumfix>
					)
				);
			}
			default {
				debug-match( $_ ) if $*DEBUG;
				die "Unhandled case" if
					$*FACTORY-FAILURE-FATAL
			}
		}
		@child;
	}

	method _decint( Mu $p ) {
		Perl6::Number::Decimal.from-match( $p );
	}

	method _declarator( Mu $p ) {
		my Perl6::Element @child;
		given $p {
			when self.assert-hash( $_,
				[< deftermnow initializer term_init >],
				[< trait >] ) {
				# XXX missing term_init....
				@child.append(
					self._deftermnow(
						$_.hash.<deftermnow>
					)
				);
				@child.append(
					self._initializer(
						$_.hash.<initializer>
					)
				);
			}
			when self.assert-hash( $_,
				[< sym defterm initializer >],
				[< trait >] ) {
				@child.append( self._sym( $_.hash.<sym> ) );
				@child.append(
					self._defterm( $_.hash.<defterm> )
				);
				@child.append(
					self._initializer(
						$_.hash.<initializer>
					)
				);
			}
			when self.assert-hash( $_,
				[< initializer signature >], [< trait >] ) {
				my Perl6::Element @_child;
				@_child.append(
					Perl6::Balanced::Enter.from-int(
						$_.hash.<signature>.from -
						PAREN-OPEN.chars,
						PAREN-OPEN
					)
				);
				@_child.append(
					self._signature( $_.hash.<signature> )
				);
				@_child.append(
					Perl6::Balanced::Exit.from-int(
						$_.hash.<signature>.to,
						PAREN-CLOSE
					)
				);
				@child.append(
					Perl6::Operator::Circumfix.new(
						:from( @_child[0].from ),
						:to( @_child[*-1].to ),
						:child( @_child )
					)
				);
				@child.append(
					self._initializer(
						$_.hash.<initializer>
					)
				);
			}
			when self.assert-hash( $_,
				  [< initializer variable_declarator >],
				  [< trait >] ) {
				@child.append(
					self._variable_declarator(
						$_.hash.<variable_declarator>
					)
				);
				@child.append(
					self._initializer(
						$_.hash.<initializer>
					)
				);
			}
			when self.assert-hash( $_,
				[< routine_declarator >], [< trait >] ) {
				@child.append(
					self._routine_declarator(
						$_.hash.<routine_declarator>
					)
				);
			}
			when self.assert-hash( $_,
				[< regex_declarator >], [< trait >] ) {
				@child.append(
					self._regex_declarator(
						$_.hash.<regex_declarator>
					)
				);
			}
			when self.assert-hash( $_,
				[< variable_declarator >], [< trait >] ) {
				@child.append(
					self._variable_declarator(
						$_.hash.<variable_declarator>
					)
				);
			}
			when self.assert-hash( $_,
				[< type_declarator >], [< trait >] ) {
				@child.append(
					self._type_declarator(
						$_.hash.<type_declarator>
					)
				);
			}
			when self.assert-hash( $_,
				[< signature >], [< trait >] ) {
				my Perl6::Element @_child;
				@_child.append(
					self._signature( $_.hash.<signature> )
				);
				@child.append(
					Perl6::Operator::Circumfix.from-match(
						$_, @_child
					)
				);
			}
			default {
				debug-match( $_ ) if $*DEBUG;
				die "Unhandled case" if
					$*FACTORY-FAILURE-FATAL
			}
		}
		@child;
	}

	method _DECL( Mu $p ) {
		my Perl6::Element @child;
		given $p {
			when self.assert-hash( $_,
					[< deftermnow initializer term_init >],
					[< trait >] ) {
				@child.append(
					self._deftermnow(
						$_.hash.<deftermnow>
					)
				);
				@child.append(
					self._initializer(
						$_.hash.<initializer>
					)
				);
				@child.append(
					self._term_init( $_.hash.<term_init> )
				)
			}
			when self.assert-hash( $_,
					[< deftermnow initializer signature >],
					[< trait >] ) {
				@child.append(
					self._deftermnow(
						$_.hash.<deftermnow>
					)
				);
				@child.append(
					self._initializer(
						$_.hash.<initializer>
					)
				);
				@child.append(
					self._signature( $_.hash.<signature> )
				);
			}
			when self.assert-hash( $_,
					[< initializer signature >],
					[< trait >] ) {
				@child.append(
					self._initializer(
						$_.hash.<initializer>
					)
				);
				@child.append(
					self._signature( $_.hash.<signature> )
				);
			}
			when self.assert-hash( $_,
					[< initializer variable_declarator >],
					[< trait >] ) {
				@child.append(
					self._initializer(
						$_.hash.<initializer>
					)
				);
				@child.append(
					self._variable_declarator(
						$_.hash.<variable_declarator>
					)
				);
			}
			when self.assert-hash( $_, [< sym package_def >] ) {
				@child.append( self._sym( $_.hash.<sym> ) );
				@child.append(
					self._package_def(
						$_.hash.<package_def>
					)
				);
			}
			when self.assert-hash( $_,
					[< regex_declarator >],
					[< trait >] ) {
				@child.append(
					self._regex_declarator(
						$_.hash.<regex_declarator>
					)
				);
			}
			when self.assert-hash( $_,
					[< variable_declarator >],
					[< trait >] ) {
				@child.append(
					self._variable_declarator(
						$_.hash.<variable_declarator>
					)
				);
			}
			when self.assert-hash( $_,
					[< routine_declarator >],
					[< trait >] ) {
				@child.append(
					self._routine_declarator(
						$_.hash.<routine_declarator>
					)
				);
			}
			when self.assert-hash( $_, [< declarator >] ) {
				@child.append(
					self._declarator(
						$_.hash.<declarator>
					)
				);
			}
			when self.assert-hash( $_,
					[< signature >], [< trait >] ) {
				@child.append(
					self.signature( $_.hash.<signature> )
				);
			}
			default {
				debug-match( $_ ) if $*DEBUG;
				die "Unhandled case" if
					$*FACTORY-FAILURE-FATAL
			}
		}
		@child;
	}

	method _dec_number( Mu $p ) {
		given $p {
			when self.assert-hash( $_,
					[< int coeff escale frac >] ) {
				self.__FloatingPoint( $_ );
			}
			when self.assert-hash( $_, [< coeff frac escale >] ) {
				self.__FloatingPoint( $_ );
			}
			when self.assert-hash( $_, [< int coeff frac >] ) {
				self.__FloatingPoint( $_ );
			}
			when self.assert-hash( $_, [< int coeff escale >] ) {
				self.__FloatingPoint( $_ );
			}
			when self.assert-hash( $_, [< coeff frac >] ) {
				self.__FloatingPoint( $_ );
			}
			default {
				debug-match( $_ ) if $*DEBUG;
				die "Unhandled case" if
					$*FACTORY-FAILURE-FATAL
			}
		}
	}

	method _default_value( Mu $p ) {
		my Perl6::Element @child;
		if $p.list {
			for $p.list {
				if self.assert-hash( $_, [< EXPR >] ) {
					@child.append(
						self._EXPR( $_.hash.<EXPR> )
					);
				}
				else {
					debug-match( $_ ) if $*DEBUG;
					die "Unhandled case" if
						$*FACTORY-FAILURE-FATAL
				}
			}
		}
		else {
			debug-match( $p ) if $*DEBUG;
			die "Unhandled case" if
				$*FACTORY-FAILURE-FATAL
		}
		@child;
	}

	method _deflongname( Mu $p ) {
		given $p {
			when self.assert-hash( $_,
					[< name >], [< colonpair >] ) {
				self._name( $_.hash.<name> );
			}
			default {
				debug-match( $_ ) if $*DEBUG;
				die "Unhandled case" if
					$*FACTORY-FAILURE-FATAL
			}
		}
	}

	method _defterm( Mu $p ) {
		my Perl6::Element @child;
		given $p {
			when self.assert-hash( $_,
					[< identifier colonpair >] ) {
				@child.append(
					self._identifier(
						$_.hash.<identifier>
					)
				);
				@child.append(
					self._colonpair( $_.hash.<colonpair> )
				);	
			}
			when self.assert-hash( $_,
					[< identifier >],
					[< colonpair >] ) {
				if $_.orig.substr( $_.from - 1, 1 ) eq
						BACKSLASH {
					my $content = $_.orig.substr(
						$_.from - 1,
						$_.to - $_.from + 1
					);
					@child.append(
						Perl6::Bareword.from-int(
							$_.from - 1,
							$content
						)
					);
				}
				else {
					@child.append(
						self._identifier(
							$_.hash.<identifier>
						)
					);
				}
			}
			default {
				debug-match( $_ ) if $*DEBUG;
				die "Unhandled case" if
					$*FACTORY-FAILURE-FATAL
			}
		}
		@child;
	}

	method _deftermnow( Mu $p ) {
		given $p {
			when self.assert-hash( $_, [< defterm >] ) {
				self._defterm( $_.hash.<defterm> );
			}
			default {
				debug-match( $_ ) if $*DEBUG;
				die "Unhandled case" if
					$*FACTORY-FAILURE-FATAL
			}
		}
	}

	method _desigilname( Mu $p ) {
		given $p {
			when self.assert-hash( $_, [< longname >] ) {
				self._longname( $_.hash.<longname> );
			}
			default {
				debug-match( $_ ) if $*DEBUG;
				die "Unhandled case" if
					$*FACTORY-FAILURE-FATAL
			}
		}
	}

	method _dig( Mu $p ) {
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
#		warn "doc finally used";
		( )
	}

	# .
	# .*
	#
	method _dotty( Mu $p ) {
		my Perl6::Element @child;
		given $p {
			when self.assert-hash( $_, [< sym dottyop O >] ) {
				@child.append(
					Perl6::Operator::Prefix.from-match(
						$_.hash.<sym>
					)
				);
				@child.append(
					self._dottyop( $_.hash.<dottyop> )
				);
			}
			default {
				debug-match( $_ ) if $*DEBUG;
				die "Unhandled case" if
					$*FACTORY-FAILURE-FATAL
			}
		}
		@child;
	}

	method _dottyop( Mu $p ) {
		my Perl6::Element @child;
		given $p {
			when self.assert-hash( $_,
					[< sym postop >], [< O >] ) {
				@child.append( self._sym( $p.hash.<sym> ) );
				@child.append(
					self._postop( $p.hash.<postop> )
				);
			}
			when self.assert-hash( $_, [< colonpair >] ) {
				@child.append(
					self._colonpair( $_.hash.<colonpair> )
				);
			}
			when self.assert-hash( $_, [< methodop >] ) {
				@child.append(
					self._methodop( $_.hash.<methodop> )
				);
			}
			default {
				debug-match( $_ ) if $*DEBUG;
				die "Unhandled case" if
					$*FACTORY-FAILURE-FATAL
			}
		}
		@child;
	}

	method _dottyopish( Mu $p ) {
		given $p {
			when self.assert-hash( $_, [< term >] ) {
				self._term( $_.hash.<term> );
			}
			default {
				debug-match( $_ ) if $*DEBUG;
				die "Unhandled case" if
					$*FACTORY-FAILURE-FATAL
			}
		}
	}

	method _e1( Mu $p ) {
		given $p {
			when self.assert-hash( $_, [< scope_declarator >] ) {
				self._scope_declarator(
					$_.hash.<scope_declarator>
				);
			}
			default {
				debug-match( $_ ) if $*DEBUG;
				die "Unhandled case" if
					$*FACTORY-FAILURE-FATAL
			}
		}
	}

	method _e2( Mu $p ) {
		my Perl6::Element @child;
		given $p {
			when self.assert-hash( $_, [< infix OPER >] ) {
				@child.append( self._infix( $p.hash.<infix> ) );
				@child.append( self._OPER( $p.hash.<OPER> ) );
			}
			default {
				debug-match( $_ ) if $*DEBUG;
				die "Unhandled case" if
					$*FACTORY-FAILURE-FATAL
			}
		}
		@child;
	}

	method _e3( Mu $p ) {
		my Perl6::Element @child;
		given $p {
			when self.assert-hash( $_,
					[< postfix OPER >],
					[< postfix_prefix_meta_operator >] ) {
				@child.append(
					self._postfix( $p.hash.<postfix> )
				);
				@child.append( self._OPER( $p.hash.<OPER> ) );
			}
			default {
				debug-match( $_ ) if $*DEBUG;
				die "Unhandled case" if
					$*FACTORY-FAILURE-FATAL
			}
		}
		@child;
	}

	method _else( Mu $p ) {
		my Perl6::Element @child;
		given $p {
			when self.assert-hash( $_, [< sym blorst >] ) {
				@child.append( self._sym( $_.hash.<sym> ) );
				@child.append(
					self._blorst( $_.hash.<blorst> )
				);
			}
			when self.assert-hash( $_, [< blockoid >] ) {
				@child.append(
					self._blockoid( $_.hash.<blockoid> )
				);
			}
			default {
				debug-match( $_ ) if $*DEBUG;
				die "Unhandled case" if
					$*FACTORY-FAILURE-FATAL
			}
		}
		@child;
	}

	method _escale( Mu $p ) {
		my Perl6::Element @child;
		given $p {
			when self.assert-hash( $_, [< sign decint >] ) {
				@child.append( self._sign( $_.hash.<sign> ) );
				@child.append(
					self._decint( $_.hash.<decint> )
				);
			}
			default {
				debug-match( $_ ) if $*DEBUG;
				die "Unhandled case" if
					$*FACTORY-FAILURE-FATAL
			}
		}
		@child;
	}

	# \\
	# {}
	# $
	# @
	# %
	# &
	# ' '
	# " "
	# ‘ ’
	# “ ”
	# colonpair
	#
	method _escape( Mu $p ) {
		my Perl6::Element @child;
		given $p {
			when self.assert-hash( $_, [< sign decint >] ) {
				@child.append(
					self._invocant( $_.hash.<invocant> )
				);
				@child.append(
					self._semiarglist(
						$_.hash.<semiarglist>
					)
				);
			}
			default {
				debug-match( $_ ) if $*DEBUG;
				die "Unhandled case" if
					$*FACTORY-FAILURE-FATAL
			}
		}
		@child;
	}

	method _EXPR( Mu $p ) {
		my Perl6::Element @child;
		if self.assert-hash( $p,
				[< dotty OPER
				  postfix_prefix_meta_operator >] ) {
			@child.append( self._EXPR( $p.list.[0] ) );
			@child.append(
				self._postfix_prefix_meta_operator(
					$p.hash.<postfix_prefix_meta_operator>
				)
			);
			@child.append( self._dotty( $p.hash.<dotty> ) );
		}
		elsif self.assert-hash( $p,
				[< dotty OPER >],
				[< postfix_prefix_meta_operator >] ) {
			# XXX Look into this at some point.
			my $x = $p.Str.substr(
				0,
				HYPER.chars
			);
			if $x eq HYPER {
				@child.append( self._EXPR( $p.list.[0] ) );
				my $str = $p.orig.substr(
					$p.from, HYPER.chars
				);
				@child.append(
					Perl6::Operator::Prefix.from-int(
						$p.from, $str
					)
				);
				@child.append( self._dotty( $p.hash.<dotty> ) );
			}
			else {
				@child.append( self._EXPR( $p.list.[0] ) );
				@child.append( self._dotty( $p.hash.<dotty> ) );
			}
		}
		elsif self.assert-hash( $p,
				[< infix OPER >],
				[< infix_postfix_meta_operator >] ) {
			@child.append( self._infix( $p.hash.<infix> ) );
			@child.append( self._EXPR( $p.list.[0] ) );
		}
		elsif self.assert-hash( $p,
				[< prefix OPER >],
				[< prefix_postfix_meta_operator >] ) {
			@child.append( self._prefix( $p.hash.<prefix> ) );
			@child.append( self._EXPR( $p.list.[0] ) );
		}
		elsif self.assert-hash( $p,
				[< postcircumfix OPER >],
				[< postfix_prefix_meta_operator >] ) {
			@child.append( self._EXPR( $p.list.[0] ) );
			if $p.Str ~~ m{ ^ ( '.' ) } {
				@child.append(
					Perl6::Operator::Infix.from-int(
						$p.from,
						PERIOD
					)
				);
			}
			@child.append(
				self._postcircumfix( $p.hash.<postcircumfix> )
			);
		}
		elsif self.assert-hash( $p,
				[< postfix OPER >],
				[< postfix_prefix_meta_operator >] ) {
			@child.append( self._EXPR( $p.list.[0] ) );
			@child.append( self._postfix( $p.hash.<postfix> ) );
		}
		elsif self.assert-hash( $p,
				[< infix_prefix_meta_operator OPER >] ) {
			@child.append( self._EXPR( $p.list.[0] ) );
			@child.append(
				self._infix_prefix_meta_operator(
					$p.hash.<infix_prefix_meta_operator>
				),
			);
			@child.append( self._EXPR( $p.list.[1] ) );
		}
		# XXX Still needs rewriting to a reasonable size.
		elsif self.assert-hash( $p, [< infix OPER >] ) {
			@child.append( self._EXPR( $p.list.[0] ) );
			if $p.list.elems == 3 {
				given $p.hash.<infix>.Str {
					when COMMA {
						@child.append(
							Perl6::Operator::Infix.from-int(
								@child[*-1].to,
								COMMA
							)
						);
						@child.append(
							self._EXPR( $p.list.[1] )
						);
						@child.append(
							Perl6::Operator::Infix.find-match(
								$p, COMMA
							)
						);
					}
					default {
						@child.append(
							Perl6::Operator::Infix.from-int(
								$p.from, QUES-QUES
							)
						);
						@child.append(
							self._EXPR( $p.list.[1] )
						);
						@child.append(
							Perl6::Operator::Infix.find-match(
								$p, BANG-BANG
							)
						);
					}
				}
				if $p.list.[2].Str {
					@child.append(
						self._EXPR(
							$p.list.[2]
						)
					);
				}
			}
			else {
				for 1 .. $p.list.elems - 1 {
					my Str $y = $p.orig.Str.substr(
						0,
						$p.list.[$_].from
					);
					if $p.hash.<infix>.Str eq ',' and $y ~~ m{ ( ',' ) ( \s* ) $ } {
						@child.append(
							Perl6::Operator::Infix.from-int(
								$p.list.[$_].from - $0.Str.chars - $1.Str.chars,
								COMMA
							)
						);
					}
					else {
						@child.append(
							self._infix( $p.hash.<infix> )
						);
						my Str $x = $p.hash.<infix>.orig.substr(
							$p.hash.<infix>.to
						);
						if $x ~~ m{ ^ ( \s+ ) } {
							@child.append(
								Perl6::WS.from-int(
									$p.hash.<infix>.to, $0.Str
								)
							)
						}
					}
					@child.append(
						self._EXPR(
							$p.list.[$_]
						)
					);
				}
			}
		}
		elsif self.assert-hash( $p, [< args op >] ) {
			my Perl6::Element @_child;
			@_child.append(
				Perl6::Balanced::Enter.from-int(
					$p.hash.<op>.from - REDUCE-OPEN.chars,
					REDUCE-OPEN
				)
			);
			# XXX Should be derived from self._op?
			@_child.append(
				Perl6::Operator::Prefix.from-match(
					$p.hash.<op>
				)
			);
			@_child.append(
				Perl6::Balanced::Exit.from-int(
					$p.hash.<op>.to,
					REDUCE-CLOSE
				)
			);
			@child.append(
				Perl6::Operator::Hyper.new(
					:factory-line-number(
						callframe(1).line
					),
					:from(
						$p.hash.<op>.from -
						REDUCE-OPEN.chars
					),
					:to(
						$p.hash.<op>.to +
						 REDUCE-CLOSE.chars
					),
					:child( @_child )
				)
			);
			@child.append( self._args( $p.hash.<args> ) );
		}
		elsif self.assert-hash( $p, [< identifier args >] ) {
			@child.append(
				self._identifier( $p.hash.<identifier> )
			);
			@child.append( self._args( $p.hash.<args> ) );
		}
		elsif self.assert-hash( $p, [< sym args >] ) {
			@child.append(
				Perl6::Operator::Infix.from-match(
					$p.hash.<sym>
				)
			);
		}
		elsif self.assert-hash( $p, [< longname args >] ) {
			if $p.hash.<args> and
			   $p.hash.<args>.hash.<semiarglist> {
				@child.append(
					self._longname( $p.hash.<longname> )
				);
				@child.append( self._args( $p.hash.<args> ) );
			}
			else {
				@child.append(
					self._longname( $p.hash.<longname> )
				);
				if $p.hash.<args>.hash.keys and
				   $p.hash.<args>.Str ~~ m{ \S } {
					@child.append(
						self._args( $p.hash.<args> )
					);
				}
			}
		}
		elsif self.assert-hash( $p, [< circumfix >] ) {
			@child.append( self._circumfix( $p.hash.<circumfix> ) );
		}
		elsif self.assert-hash( $p, [< dotty >] ) {
			@child.append( self._dotty( $p.hash.<dotty> ) );
		}
		elsif self.assert-hash( $p, [< fatarrow >] ) {
			@child.append( self._fatarrow( $p.hash.<fatarrow> ) );
		}
		elsif self.assert-hash( $p, [< multi_declarator >] ) {
			@child.append(
				self._multi_declarator(
					$p.hash.<multi_declarator>
				)
			);
		}
		elsif self.assert-hash( $p, [< regex_declarator >] ) {
			@child.append(
				self._regex_declarator(
					$p.hash.<regex_declarator>
				)
			);
		}
		elsif self.assert-hash( $p, [< routine_declarator >] ) {
			@child.append(
				self._routine_declarator(
					$p.hash.<routine_declarator>
				)
			);
		}
		elsif self.assert-hash( $p, [< scope_declarator >] ) {
			@child.append(
				self._scope_declarator(
					$p.hash.<scope_declarator>
				)
			);
		}
		elsif self.assert-hash( $p, [< type_declarator >] ) {
			@child.append(
				self._type_declarator(
					$p.hash.<type_declarator>
				)
			);
		}

		# $p doesn't contain WS after the block.
		elsif self.assert-hash( $p, [< package_declarator >] ) {
			@child.append(
				self._package_declarator(
					$p.hash.<package_declarator>
				)
			);
		}
		elsif self.assert-hash( $p, [< value >] ) {
			@child.append( self._value( $p.hash.<value> ) );
		}
		elsif self.assert-hash( $p, [< variable >] ) {
			@child.append( self._variable( $p.hash.<variable> ) );
		}
		elsif self.assert-hash( $p, [< colonpair >] ) {
			@child.append( self._colonpair( $p.hash.<colonpair> ) );
		}
		elsif self.assert-hash( $p, [< longname >] ) {
			@child.append( self._longname( $p.hash.<longname> ) );
		}
		elsif self.assert-hash( $p, [< sym >] ) {
			@child.append( self._sym( $p.hash.<sym> ) );
		}
		elsif self.assert-hash( $p, [< statement_prefix >] ) {
			@child.append(
				self._statement_prefix(
					$p.hash.<statement_prefix>
				)
			);
		}
		elsif self.assert-hash( $p, [< methodop >] ) {
			@child.append( self._methodop( $p.hash.<methodop> ) );
		}
		elsif self.assert-hash( $p, [< pblock >] ) {
			@child.append( self._pblock( $p.hash.<pblock> ) );
		}
		elsif $p.Str {
			@child.append( Perl6::Bareword.from-match( $p ) );
		}
		else {
			debug-match( $p ) if $*DEBUG;
			die "Unhandled case" if
				$*FACTORY-FAILURE-FATAL
		}
		@child;
	}

	method _fake_infix( Mu $p ) {
		given $p {
			when self.assert-hash( $_, [< O >] ) {
				self._O( $_.hash.<O> );
			}
			default {
				debug-match( $_ ) if $*DEBUG;
				die "Unhandled case" if
					$*FACTORY-FAILURE-FATAL
			}
		}
	}

	method _fakesignature( Mu $p ) {
		given $p {
			when self.assert-hash( $_, [< signature >] ) {
				self._signature( $_.hash.<signature> );
			}
			default {
				debug-match( $_ ) if $*DEBUG;
				die "Unhandled case" if
					$*FACTORY-FAILURE-FATAL
			}
		}
	}

	method _fatarrow( Mu $p ) {
		my Perl6::Element @child;
		given $p {
			when self.assert-hash( $_, [< key val >] ) {
				$_.Str ~~ m{ ('=>') };
				@child.append( self._key( $_.hash.<key> ) );
				@child.append(
					Perl6::Operator::Infix.find-match(
						$_, FAT-ARROW
					)
				);
				@child.append( self._val( $_.hash.<val> ) );
			}
			default {
				debug-match( $_ ) if $*DEBUG;
				die "Unhandled case" if
					$*FACTORY-FAILURE-FATAL
			}
		}
		@child;
	}

	method __FloatingPoint( Mu $p ) {
		Perl6::Number::FloatingPoint.from-match( $p );
	}

	# XXX Unused
	method _hexint( Mu $p ) {
		Perl6::Number::Hexadecimal.from-match( $p );
	}

	method _identifier( Mu $p ) {
		my Perl6::Element @child;
		if $p.Str {
			@child.append( Perl6::Bareword.from-match( $p ) );
		}
		elsif $p.list {
			for $p.list {
				if 0 {
				}
				else {
					debug-match( $_ ) if $*DEBUG;
					die "Unhandled case" if
						$*FACTORY-FAILURE-FATAL
				}
			}
		}
		else {
			debug-match( $p ) if $*DEBUG;
			die "Unhandled case" if
				$*FACTORY-FAILURE-FATAL
		}
		@child;
	}

	method _infix( Mu $p ) {
		my Perl6::Element @child;
		given $p {
			when self.assert-hash( $_, [< sym EXPR >], [< O >] ) {
				@child.append(
					self._sym(
						$_.hash.<sym>
					)
				);
				@child.append(
					self._EXPR(
						$_.hash.<EXPR>
					)
				);
			}
			when self.assert-hash( $_, [< sym O >] ) {
				@child.append(
					Perl6::Operator::Infix.from-match(
						$_.hash.<sym>
					)
				);
			}
			when self.assert-hash( $_, [< EXPR O >] ) {
				# XXX fix?
				@child.append(
					Perl6::Operator::Infix.from-match(
						$_.hash.<EXPR>
					)
				);
			}
			default {
				debug-match( $_ ) if $*DEBUG;
				die "Unhandled case" if
					$*FACTORY-FAILURE-FATAL
			}
		}
		@child;
	}

	method _infixish( Mu $p ) {
		my Perl6::Element @child;
		given $p {
			when self.assert-hash( $_, [< infix OPER >] ) {
				@child.append( self._infix( $_.hash.<infix> ) );
				@child.append( self._OPER( $_.hash.<OPER> ) );
			}
			default {
				debug-match( $_ ) if $*DEBUG;
				die "Unhandled case" if
					$*FACTORY-FAILURE-FATAL
			}
		}
		@child;
	}

	# << >>
	# « »
	#
	method _infix_circumfix_meta_operator( Mu $p ) {
		given $p {
			when self.assert-hash( $_, [< sym infixish O >] ) {
				Perl6::Operator::Infix.from-int(
					$_.hash.<sym>.from,
					$_.hash.<sym>.Str ~ $_.hash.<infixish>
				);
			}
			default {
				debug-match( $_ ) if $*DEBUG;
				die "Unhandled case" if
					$*FACTORY-FAILURE-FATAL
			}
		}
	}

	# « »
	#
	method _infix_prefix_meta_operator( Mu $p ) {
		given $p {
			when self.assert-hash( $_, [< sym infixish O >] ) {
				Perl6::Operator::Infix.from-int(
					$_.hash.<sym>.from,
					$_.hash.<sym>.Str ~ $_.hash.<infixish>
				);
			}
			default {
				debug-match( $_ ) if $*DEBUG;
				die "Unhandled case" if
					$*FACTORY-FAILURE-FATAL
			}
		}
	}

	# =
	# :=
	# ::=
	# .=
	# .
	#
	method _initializer( Mu $p ) {
		my Perl6::Element @child;
		given $p {
			when self.assert-hash( $_, [< dottyopish sym >] ) {
				@child.append(
					self._dottyopish(
						$_.hash.<dottyopish>
					)
				);
				@child.append( self._sym( $_.hash.<sym> ) );
			}
			when self.assert-hash( $_, [< sym EXPR >] ) {
				@child.append(
					Perl6::Operator::Infix.from-match(
						$_.hash.<sym>
					)
				);
	# from here
				if $_.hash.<sym>.Str eq EQUAL and
					$_.hash.<EXPR>.list.elems == 2 {
					@child.append(
						self._EXPR(
							$_.hash.<EXPR>.list.[0]
						)
					);
					if $_.hash.<EXPR>.hash.<infix>.Str {
						@child.append(
							self._infix(
								$_.hash.<EXPR>.hash.<infix>
							)
						);
					}
					@child.append(
						self._EXPR(
							$_.hash.<EXPR>.list.[1]
						)
					);
				}
				else {
					@child.append(
						self._EXPR( $_.hash.<EXPR> )
					);
				}
	# to here
				if $_.hash.<EXPR>.to < $_.to and
				   %.here-doc.keys.elems > 0 {
					my $content = $p.Str.substr(
						$_.hash.<EXPR>.to - $p.from
					);
					@child.append(
						Perl6::Sir-Not-Appearing-In-This-Statement.new(
							:factory-line-number(
								callframe(1).line
							),
							:from(
								$_.hash.<EXPR>.to
							),
							:to( $_.to ),
							:content( $content )
						)
					);
				}
			}
			default {
				debug-match( $_ ) if $*DEBUG;
				die "Unhandled case" if
					$*FACTORY-FAILURE-FATAL
			}
		}
		@child;
	}

	method _integer( Mu $p ) {
		given $p {
			when self.assert-hash( $_, [< binint VALUE >] ) {
				Perl6::Number::Binary.from-match( $_ );
			}
			when self.assert-hash( $_, [< octint VALUE >] ) {
				Perl6::Number::Octal.from-match( $_ );
			}
			when self.assert-hash( $_, [< decint VALUE >] ) {
				Perl6::Number::Decimal.from-match( $_ );
			}
			when self.assert-hash( $_, [< hexint VALUE >] ) {
				Perl6::Number::Hexadecimal.from-match( $_ );
			}
			default {
				debug-match( $_ ) if $*DEBUG;
				die "Unhandled case" if
					$*FACTORY-FAILURE-FATAL
			}
		}
	}

	method _invocant( Mu $p ) {
		CATCH {
			when X::Multi::NoMatch { }
		}
		#if $p ~~ QAST::Want;
		#if self.assert-hash( $p, [< XXX >] );
		warn "called invocant";
return True;
	}

	method _key( Mu $p ) {
		Perl6::Bareword.from-match( $p );
	}

	# Special value...
	method _lambda( Mu $p ) {
		Perl6::Operator::Infix.from-match( $p );
	}

	method _left( Mu $p ) {
		given $p {
			when self.assert-hash( $_, [< termseq >] ) {
				self._termseq( $_.hash.<termseq> );
			}
			default {
				debug-match( $_ ) if $*DEBUG;
				die "Unhandled case" if
					$*FACTORY-FAILURE-FATAL
			}
		}
	}

	method _longname( Mu $p ) {
		given $p {
			when self.assert-hash( $_,
					[< name >], [< colonpair >] ) {
				self._name( $_.hash.<name> );
			}
			default {
				debug-match( $_ ) if $*DEBUG;
				die "Unhandled case" if
					$*FACTORY-FAILURE-FATAL
			}
		}
	}

	method _max( Mu $p ) {
		warn "max finally used";
		( )
	}

	# :my
	# { }
	# qw
	# '
	#
	method _metachar( Mu $p ) {
		given $p {
			when self.assert-hash( $_, [< sym >] ) {
				self._sym( $_.hash.<sym> );
			}
			when self.assert-hash( $_, [< codeblock >] ) {
				self._codeblock( $_.hash.<codeblock> );
			}
			when self.assert-hash( $_, [< backslash >] ) {
				self._backslash( $_.hash.<backslash> );
			}
			when self.assert-hash( $_, [< assertion >] ) {
				self._assertion( $_.hash.<assertion> );
			}
			when self.assert-hash( $_, [< nibble >] ) {
				self._nibble( $_.hash.<nibble> );
			}
			when self.assert-hash( $_, [< quote >] ) {
				self._quote( $_.hash.<quote> );
			}
			when self.assert-hash( $_, [< nibbler >] ) {
				self._nibbler( $_.hash.<nibbler> );
			}
			when self.assert-hash( $_, [< statement >] ) {
				self._statement( $_.hash.<statement> );
			}
			default {
				debug-match( $_ ) if $*DEBUG;
				die "Unhandled case" if
					$*FACTORY-FAILURE-FATAL
			}
		}
	}

	method _method_def( Mu $p ) {
		my Perl6::Element @child;
		given $p {
			when self.assert-hash( $_,
				     [< specials longname blockoid multisig >],
				     [< trait >] ) {
				my Perl6::Element @_child;
				@_child.append(
					 self._multisig( $_.hash.<multisig> )
				);
				@child.append(
					self._longname( $_.hash.<longname> )
				);
				my $x = $_.orig.substr(
					0, $_.hash.<multisig>.from
				);
				$x ~~ m{ ( '(' \s* ) $ };
				my $from = $0.Str.chars;
				my $y = $_.orig.substr( $_.hash.<multisig>.to );
				$y ~~ m{ ^ ( \s* ')' ) };
				my $to = $0.Str.chars;
				@child.append(
					Perl6::Operator::Circumfix.from-int(
						$_.hash.<multisig>.from - $from,
						$_.orig.substr(
							$_.hash.<multisig>.from - $from,
							$_.hash.<multisig>.chars + $from + $to
						),
						@_child
					)
				);
				@child.append(
					self._blockoid( $_.hash.<blockoid> )
				);
			}
			when self.assert-hash( $_,
				     [< specials longname blockoid >],
				     [< trait >] ) {
				@child.append(
					self._longname( $_.hash.<longname> )
				);
				@child.append(
					self._blockoid( $_.hash.<blockoid> )
				);
			}
			default {
				debug-match( $_ ) if $*DEBUG;
				die "Unhandled case" if
					$*FACTORY-FAILURE-FATAL
			}
		}
		@child;
	}

	method _methodop( Mu $p ) {
		my Perl6::Element @child;
		given $p {
			when self.assert-hash( $_, [< longname args >] ) {
				@child.append(
					self._longname( $_.hash.<longname> )
				);
				@child.append( self._args( $_.hash.<args> ) );
			}
			when self.assert-hash( $_, [< variable >] ) {
				@child.append(
					self._variable( $_.hash.<variable> )
				);
			}
			when self.assert-hash( $_, [< longname >] ) {
				@child.append(
					self._longname( $_.hash.<longname> )
				);
			}
			default {
				debug-match( $_ ) if $*DEBUG;
				die "Unhandled case" if
					$*FACTORY-FAILURE-FATAL
			}
		}
		@child;
	}

	method _min( Mu $p ) {
		given $p {
			when self.assert-hash( $_, [< decint VALUE >] ) {
				self._decint( $_.hash.<decint> );
			}
			default {
				debug-match( $_ ) if $*DEBUG;
				die "Unhandled case" if
					$*FACTORY-FAILURE-FATAL
			}
		}
	}

	method _modifier_expr( Mu $p ) {
		given $p {
			when self.assert-hash( $_, [< EXPR >] ) {
				self._EXPR( $_.hash.<EXPR> );
			}
			default {
				debug-match( $_ ) if $*DEBUG;
				die "Unhandled case" if
					$*FACTORY-FAILURE-FATAL
			}
		}
	}

	method _module_name( Mu $p ) {
		given $p {
			when self.assert-hash( $_, [< longname >] ) {
				self._longname( $_.hash.<longname> );
			}
			default {
				debug-match( $_ ) if $*DEBUG;
				die "Unhandled case" if
					$*FACTORY-FAILURE-FATAL
			}
		}
	}

	method _morename( Mu $p ) {
		my Perl6::Element @child;
		# XXX This probably needs further work.
		if $p.list {
			for $p.list {
				if self.assert-hash( $p, [< identifier >] ) {
					@child.append(
						Perl6::PackageName.from-match(
							$_.hash.<identifier>
						)
					);
				}
				else {
					debug-match( $_ ) if $*DEBUG;
					die "Unhandled case" if
						$*FACTORY-FAILURE-FATAL
				}
			}
		}
		else {
			debug-match( $p ) if $*DEBUG;
			die "Unhandled case" if
				$*FACTORY-FAILURE-FATAL
		}
		@child;
	}

	# multi
	# proto
	# only
	# null
	#
	method _multi_declarator( Mu $p ) {
		my Perl6::Element @child;
		given $p {
			when self.assert-hash( $_, [< sym routine_def >] ) {
				@child.append( self._sym( $_.hash.<sym> ) );
				@child.append(
					self._routine_def(
						$_.hash.<routine_def>
					)
				);
			}
			when self.assert-hash( $_, [< sym declarator >] ) {
				@child.append( self._sym( $_.hash.<sym> ) );
				@child.append(
					self._declarator(
						$_.hash.<declarator>
					)
				);
			}
			when self.assert-hash( $_, [< declarator >] ) {
				@child.append(
					self._declarator( $_.hash.<declarator> )
				);
			}
			default {
				debug-match( $_ ) if $*DEBUG;
				die "Unhandled case" if
					$*FACTORY-FAILURE-FATAL
			}
		}
		@child;
	}

	method _multisig( Mu $p ) {
		my Perl6::Element @child;
		given $p {
			when self.assert-hash( $_, [< signature >] ) {
				@child.append(
					self._signature( $_.hash.<signature> )
				);
			}
			default {
				debug-match( $_ ) if $*DEBUG;
				die "Unhandled case" if
					$*FACTORY-FAILURE-FATAL
			}
		}
		@child;
	}

	method _named_param( Mu $p ) {
		my Perl6::Element @child;
		given $p {
			when self.assert-hash( $_, [< name param_var >] ) {
# XXX Needs to be added back in...
#				self._name( $_.hash.<name> );
				@child.append(
					self._param_var( $_.hash.<param_var> )
				);
			}
			when self.assert-hash( $_, [< param_var >] ) {
				@child.append(
					self._param_var( $_.hash.<param_var> )
				);
			}
			default {
				debug-match( $_ ) if $*DEBUG;
				die "Unhandled case" if
					$*FACTORY-FAILURE-FATAL
			}
		}
		@child;
	}

	method _name( Mu $p ) {
		my Perl6::Element @child;
		given $p {
			when self.assert-hash( $_,
				[< param_var type_constraint quant >],
				[< default_value modifier trait
				   post_constraint >] ) {
				@child.append(
					self._param_var( $_.hash.<param_var> )
				);
				@child.append(
					self._type_constraint(
						$_.hash.<type_constraint>
					)
				);
				@child.append( self._quant( $_.hash.<quant> ) )
			}
			when self.assert-hash( $_,
					[< identifier >],
					[< morename >] ) {
				# XXX This did descend to _identifier, but that
				# XXX level wouldn't properly catch Foo::Bar
				# XXX second-level qualified names.
				@child.append(
					Perl6::Bareword.from-match( $_ )
				);
				# XXX Probably should be Enter(':')..Exit('')
				if $_.orig.Str.substr( $_.to, 1 ) eq COLON {
					@child.append(
						Perl6::Bareword.from-int(
							$_.to,
							COLON
						)
					)
				}
			}
			when self.assert-hash( $_, [< subshortname >] ) {
				@child.append(
					self._subshortname(
						$_.hash.<subshortname>
					)
				);
			}
			when self.assert-hash( $_, [< morename >] ) {
				@child.append(
					Perl6::PackageName.from-match( $_ )
				);
			}
			default {
				debug-match( $_ ) if $*DEBUG;
				die "Unhandled case" if
					$*FACTORY-FAILURE-FATAL
			}
		}
		@child;
	}

	method _nibble( Mu $p ) {
		my Perl6::Element @child;
		if self.assert-hash( $p, [< termseq >] ) {
			@child.append( self._termseq( $p.hash.<termseq> ) );
		}
		elsif $p.Str {
			if $p.Str ~~ m{ ^ ( .+? ) ( \s+ ) $ } {
				@child.append(
					Perl6::Bareword.from-int( $p.from, $0.Str )
				);
			}
			else {
				@child.append(
					Perl6::Bareword.from-match( $p )
				);
			}
		}
		else {
			debug-match( $_ ) if $*DEBUG;
			die "Unhandled case" if
				$*FACTORY-FAILURE-FATAL
		}
		@child;
	}

	method _nibbler( Mu $p ) {
		given $p {
			when self.assert-hash( $_, [< termseq >] ) {
				self._termseq( $_.hash.<termseq> );
			}
			default {
				debug-match( $_ ) if $*DEBUG;
				die "Unhandled case" if
					$*FACTORY-FAILURE-FATAL
			}
		}
	}

	method _normspace( Mu $p ) {
		warn "normspace finally used";
		( )
	}

	method _noun( Mu $p ) {
		my Perl6::Element @child;
		if $p.list {
			for $p.list {
				if self.assert-hash( $_,
					[< sigmaybe sigfinal
					   quantifier atom >] ) {
					@child.append(
						self._sigmaybe(
							$_.hash.<sigmaybe>
						)
					);
					@child.append(
						self._sigfinal(
							$_.hash.<sigfinal>
						)
					);
					@child.append(
						self._quantifier(
							$_.hash.<quantifier>
						)
					);
					@child.append(
						self._atom( $_.hash.<atom> )
					);
				}
				elsif self.assert-hash( $_,
					[< sigfinal quantifier
					   separator atom >] ) {
					@child.append(
						self._atom( $_.hash.<atom> )
					);
					@child.append(
						self._quantifier(
							$_.hash.<quantifier>
						)
					);
					@child.append(
						self._separator(
							$_.hash.<separator>
						)
					);
				}
				elsif self.assert-hash( $_,
					[< sigmaybe sigfinal
					   separator atom >] ) {
					@child.append(
						self._sigmaybe(
							$_.hash.<sigmaybe>
						)
					);
					@child.append(
						self._sigfinal(
							$_.hash.<sigfinal>
						)
					);
					@child.append(
						self._separator(
							$_.hash.<separator>
						)
					);
					@child.append(
						self._atom( $_.hash.<atom> )
					);
				}
				elsif self.assert-hash( $_,
					[< atom sigfinal quantifier >] ) {
					@child.append(
						self._atom( $_.hash.<atom> )
					);
					@child.append(
						self._sigfinal(
							$_.hash.<sigfinal>
						)
					);
					@child.append(
						self._quantifier(
							$_.hash.<quantifier>
					 	)
					);
				}
				elsif self.assert-hash( $_,
					[< atom sigfinal >] ) {
					@child.append(
						self._atom( $_.hash.<atom> )
					);
					@child.append(
						self._sigfinal(
							$_.hash.<sigfinal>
						)
					);
				}
				elsif self.assert-hash( $_,
					[< atom >], [< sigfinal >] ) {
					@child.append(
						self._atom( $_.hash.<atom> )
					);
				}
				elsif self.assert-hash( $_, [< atom >] ) {
					@child.append(
						self._atom( $_.hash.<atom> )
					);
				}
				else {
					debug-match( $_ ) if $*DEBUG;
					die "Unhandled case" if
						$*FACTORY-FAILURE-FATAL
				}
			}
		}
		else {
			debug-match( $p ) if $*DEBUG;
			die "Unhandled case" if
				$*FACTORY-FAILURE-FATAL
		}
		@child;
	}

	# numish # ?
	#
	method _number( Mu $p ) {
		given $p {
			when self.assert-hash( $_, [< numish >] ) {
				self._numish( $_.hash.<numish> );
			}
			default {
				debug-match( $_ ) if $*DEBUG;
				die "Unhandled case" if
					$*FACTORY-FAILURE-FATAL
			}
		}
	}

	method _numish( Mu $p ) {
		given $p {
			when self.assert-hash( $_, [< dec_number >] ) {
				self._dec_number( $_.hash.<dec_number> );
			}
			when self.assert-hash( $_, [< rad_number >] ) {
				self._rad_number( $_.hash.<rad_number> );
			}
			when self.assert-hash( $_, [< integer >] ) {
				self._integer( $_.hash.<integer> );
			}
			when $_.Str eq 'Inf' {
				Perl6::Infinity.from-match( $_ );
			}
			when $_.Str eq 'NaN' {
				Perl6::NotANumber.from-match( $_ );
			}
			default {
				debug-match( $_ ) if $*DEBUG;
				die "Unhandled case" if
					$*FACTORY-FAILURE-FATAL
			}
		}
	}

	method _O( Mu $p ) {
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
		Perl6::Number::Octal.from-match( $p );
	}

	method _op( Mu $p ) {
		my Perl6::Element @child;
		given $p {
			when self.assert-hash( $_,
				     [< infix_prefix_meta_operator OPER >] ) {
				@child.append(
					self._infix_prefix_meta_operator(
						$_.hash.<infix_prefix_meta_operator>
					)
				);
				@child.append( self._OPER( $_.hash.<OPER> ) );
			}
			when self.assert-hash( $_, [< infix OPER >] ) {
				@child.append( self._infix( $_.hash.<infix> ) );
				@child.append( self._OPER( $_.hash.<OPER> ) );
			}
			default {
				debug-match( $_ ) if $*DEBUG;
				die "Unhandled case" if
					$*FACTORY-FAILURE-FATAL
			}
		}
		@child;
	}

	method _OPER( Mu $p ) {
		my Perl6::Element @child;
		given $p {
			when self.assert-hash( $_, [< sym infixish O >] ) {
				@child.append( self._sym( $_.hash.<sym> ) );
				@child.append(
					self._infixish( $_.hash.<infixish> )
				);
				@child.append( self._O( $_.hash.<O> ) );
			}
			when self.assert-hash( $_, [< sym dottyop O >] ) {
				@child.append(
					Perl6::Operator::Infix.from-match(
						$_.hash.<sym>
					)
				);
				@child.append(
					self._dottyop( $_.hash.<dottyop> )
				);
			}
			when self.assert-hash( $_, [< sym O >] ) {
				@child.append( self._sym( $_.hash.<sym> ) );
# XXX Probably needs to be rethought
#				@child.append( self._O( $_.hash.<O> ) );
			}
			when self.assert-hash( $_, [< EXPR O >] ) {
				@child.append( self._EXPR( $_.hash.<EXPR> ) );
				@child.append( self._O( $_.hash.<O> ) );
			}
			when self.assert-hash( $_, [< semilist O >] ) {
				@child.append(
					self._semilist( $_.hash.<semilist> )
				);
# XXX probably needs to be rethought
#				@child.append( self._O( $_.hash.<O> ) );
			}
			when self.assert-hash( $_, [< nibble O >] ) {
				@child.append(
					self._nibble( $_.hash.<nibble> )
				);
				@child.append( self._O( $_.hash.<O> ) );
			}
			when self.assert-hash( $_, [< arglist O >] ) {
				@child.append(
					self._arglist( $_.hash.<arglist> )
				);
				@child.append( self._O( $_.hash.<O> ) );
			}
			when self.assert-hash( $_, [< dig O >] ) {
				@child.append( self._dig( $_.hash.<dig> ) );
				@child.append( self._O( $_.hash.<O> ) );
			}
			when self.assert-hash( $_, [< O >] ) {
				@child.append( self._O( $_.hash.<O> ) );
			}
			default {
				debug-match( $_ ) if $*DEBUG;
				die "Unhandled case" if
					$*FACTORY-FAILURE-FATAL
			}
		}
		@child;
	}

	# ?{ }
	# ??{ }
	# var
	#
	method _p5metachar( Mu $p ) {
		my Perl6::Element @child;
		given $p {
			# $_ doesn't contain WS after the block.
			when self.assert-hash( $_, [< sym package_def >] ) {
				@child.append( self._sym( $_.hash.<sym> ) );
				@child.append(
					self._package_def(
						$_.hash.<package_def>
					)
				);
			}
			default {
				debug-match( $_ ) if $*DEBUG;
				die "Unhandled case" if
					$*FACTORY-FAILURE-FATAL
			}
		}
		@child;
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
		my Perl6::Element @child;
		# $p doesn't contain WS after the block.
		given $p {
			when self.assert-hash( $_, [< sym package_def >] ) {
				@child.append( self._sym( $_.hash.<sym> ) );
				@child.append(
					self._package_def(
						$_.hash.<package_def>
					)
				);
			}
			when self.assert-hash( $_, [< sym typename >] ) {
				@child.append( self._sym( $_.hash.<sym> ) );
				@child.append(
					self._typename( $_.hash.<typename> )
				);
			}
			when self.assert-hash( $_, [< sym trait >] ) {
				@child.append( self._sym( $_.hash.<sym> ) );
				@child.append( self._trait( $_.hash.<trait> ) );
			}
			default {
				debug-match( $_ ) if $*DEBUG;
				die "Unhandled case" if
					$*FACTORY-FAILURE-FATAL
			}
		}
		@child;
	}

	method _package_def( Mu $p ) {
		my Perl6::Element @child;
		given $p {
			when self.assert-hash( $_,
				[< longname statementlist >], [< trait >] ) {
				@child.append(
					self._longname( $_.hash.<longname> )
				);
				my Str $temp = $_.Str.substr(
					$_.hash.<longname>.to - $_.from
				);
				if $temp ~~ m{ ^ ( \s+ ) ( ';' )? } {
					if $1.chars {
						@child.append(
							Perl6::Semicolon.from-int(
								$_.hash.<longname>.to + $0.chars,
								$1.Str
							)
						);
					}
				}
			}
			when self.assert-hash( $_,
					[< longname >], [< colonpair >] ) {
				@child.append(
					self._longname( $_.hash.<longname> )
				);
			}
			when self.assert-hash( $_,
					[< longname trait blockoid >] ) {
				@child.append(
					self._longname( $_.hash.<longname> )
				);
				@child.append(
					self._trait( $_.hash.<trait> )
				);
				@child.append(
					self._blockoid( $_.hash.<blockoid> )
				);
			}
			when self.assert-hash( $_,
					[< longname blockoid >], [< trait >] ) {
				@child.append(
					self._longname( $_.hash.<longname> )
				);
				my $ws =
					$_.orig.substr(
						$_.hash.<longname>.to,
						$_.hash.<blockoid>.from -
							$_.hash.<longname>.to
					);
				@child.append(
					Perl6::WS.from-int(
						$_.hash.<longname>.to,
						$ws
					)
				);
				@child.append(
					self._blockoid( $_.hash.<blockoid> )
				);
			}
			when self.assert-hash( $_,
					[< blockoid >], [< trait >] ) {
				@child.append(
					self._blockoid( $_.hash.<blockoid> )
				);
			}
			default {
				debug-match( $_ ) if $*DEBUG;
				die "Unhandled case" if
					$*FACTORY-FAILURE-FATAL
			}
		}
		@child;
	}

	method _param_term( Mu $p ) {
		my Perl6::Element @child;
		given $p {
			when self.assert-hash( $_, [< defterm >] ) {
				@child.append(
					self._defterm( $_.hash.<defterm> )
				);
			}
			default {
				debug-match( $_ ) if $*DEBUG;
				die "Unhandled case" if
					$*FACTORY-FAILURE-FATAL
			}
		}
		@child;
	}

	method _parameter( Mu $p ) {
		my Perl6::Element @child;
		for $p.list {
			if self.assert-hash( $_,
				[< param_var type_constraint
				   quant post_constraint >],
				[< default_value modifier trait >] ) {
				# Synthesize the 'from' and 'to' markers for
				# 'where'
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
					Perl6::Bareword.from-int(
						$p.from + $from,
						WHERE
					)
				);
				@child.append(
					self._post_constraint(
						$_.hash.<post_constraint>
					)
				);
			}
			elsif self.assert-hash( $_,
				[< type_constraint param_var quant >],
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
			elsif self.assert-hash( $_,
				[< param_var quant default_value >],
				[< modifier trait
				   type_constraint
				   post_constraint >] ) {
				@child.append(
					self._param_var( $_.hash.<param_var> )
				);
				# XXX Should be possible to refactor...
				@child.append(
					Perl6::Operator::Infix.find-match(
						$p, EQUAL
					)
				);
				@child.append(
					self._default_value(
						$_.hash.<default_value>
					)
				);
			}
			elsif self.assert-hash( $_,
				[< param_var quant >],
				[< default_value modifier trait
				   type_constraint
				   post_constraint >] ) {
				@child.append(
					self._param_var( $_.hash.<param_var> )
				);
			}
			elsif self.assert-hash( $_,
				[< named_param quant >],
				[< default_value type_constraint modifier
				   trait post_constraint >] ) {
				# Synthesize the 'from' and 'to' markers for ':'
				$p.Str ~~ m{ (':') };
				my Int $from = $0.from;
				@child.append(
					Perl6::Operator::Prefix.from-int(
						$from,
						COLON
					)
				);
				@child.append(
					self._named_param(
						$_.hash.<named_param>
					)
				);
			}
			elsif self.assert-hash( $_,
				[< type_constraint >],
				[< default_value modifier trait
				   post_constraint >] ) {
				@child.append(
					self._type_constraint(
						$_.hash.<type_constraint>
					)
				);
			}
			else {
				debug-match( $_ ) if $*DEBUG;
				die "Unhandled case" if
					$*FACTORY-FAILURE-FATAL
			}
		}
		@child;
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
		given $p {
			when self.assert-hash( $_, [< name twigil sigil >] ) {
				# XXX refactor back to a method
				my Str $sigil       = $_.hash.<sigil>.Str;
				my Str $twigil      = $_.hash.<twigil> ??
						      $_.hash.<twigil>.Str !!
						      '';
				my Str $desigilname = $_.hash.<name> ??
						      $_.hash.<name>.Str !! '';
				my Str $content     = $_.hash.<sigil> ~
						      $twigil ~
						      $desigilname;

				my Perl6::Element $leaf =
					%sigil-map{$sigil ~ $twigil}.from-int(
						$_.from,
						$_.Str
					);
				$leaf
			}
			when self.assert-hash( $_, [< name sigil >] ) {
				# XXX refactor back to a method
				my Str $sigil       = $_.hash.<sigil>.Str;
				my Str $twigil      = $_.hash.<twigil> ??
						      $_.hash.<twigil>.Str !!
						      '';
				my Str $desigilname = $_.hash.<name> ??
						      $_.hash.<name>.Str !! '';
				my Str $content     = $_.hash.<sigil> ~
						      $twigil ~
						      $desigilname;

				my Perl6::Element $leaf =
					%sigil-map{$sigil ~ $twigil}.from-int(
						$_.from,
						$content
					);
				$leaf
			}
			when self.assert-hash( $_, [< signature >] ) {
				my Perl6::Element @_child;
				@_child.append(
					self._signature( $_.hash.<signature> )
				);
				Perl6::Operator::Circumfix.from-match(
					$_, @_child
				);
			}
			when self.assert-hash( $_, [< sigil >] ) {
				self._sigil( $_.hash.<sigil> );
			}
			default {
				debug-match( $_ ) if $*DEBUG;
				die "Unhandled case" if
					$*FACTORY-FAILURE-FATAL
			}
		}
	}

	method _pblock( Mu $p ) {
		my Perl6::Element @child;
		given $p {
			when self.assert-hash( $_,
					[< lambda signature blockoid >] ) {
				@child.append(
					self._lambda( $_.hash.<lambda> )
				);
				@child.append(
					self._signature( $_.hash.<signature> )
				);
				@child.append(
					self._blockoid( $_.hash.<blockoid> )
				);
			}
			when self.assert-hash( $_, [< blockoid >] ) {
				@child.append(
					self._blockoid( $p.hash.<blockoid> )
				);
			}
			default {
				debug-match( $_ ) if $*DEBUG;
				die "Unhandled case" if
					$*FACTORY-FAILURE-FATAL
			}
		}
		@child;
	}

	# Needs to be run through a different parser?

	# delimited
	# delimited_comment
	# delimited_table
	# delimited_code
	# paragraph
	# paragraph_comment
	# paragraph_table
	# paragraph_code
	# abbreviated
	# abbreviated_comment
	# abbreviated_table
	# abbreviated_code
	# finish
	# config
	# text
	#
	method _pod_block( Mu $p ) {
		# XXX fix later
		self._EXPR( $p.list.[0].hash.<EXPR> );
	}

	# block
	# text
	#
	method _pod_content( Mu $p ) {
		# XXX fix later
		self._EXPR( $p.list.[0].hash.<EXPR> );
	}

	# regular
	# code
	#
	method _pod_textcontent( Mu $p ) {
		# XXX fix later
		self._EXPR( $p.list.[0].hash.<EXPR> );
	}

	method _postfix_prefix_meta_operator( Mu $p ) {
		my Perl6::Element @child;
		if $p.list {
			for $p.list {
				if self.assert-hash( $_, [< sym >] ) {
					@child.append(
						self._sym( $_.hash.<sym> )
					);
				}
				elsif $_.Str {
					@child.append(
						Perl6::Operator::Infix.from-match(
							$_
						)
					);
				}
				else {
					debug-match( $_ ) if $*DEBUG;
					die "Unhandled case" if
						$*FACTORY-FAILURE-FATAL
				}
			}
		}
		else {
			debug-match( $_ ) if $*DEBUG;
			die "Unhandled case" if
				$*FACTORY-FAILURE-FATAL
		}
		@child;
	}

	method _post_constraint( Mu $p ) {
		my Perl6::Element @child;
		if $p.list {
			for $p.list {
				if self.assert-hash( $_, [< EXPR >] ) {
					@child.append(
						self._EXPR( $_ )
					);
				}
				else {
					debug-match( $_ ) if $*DEBUG;
					die "Unhandled case" if
						$*FACTORY-FAILURE-FATAL
				}
			}
		}
		else {
			debug-match( $_ ) if $*DEBUG;
			die "Unhandled case" if
				$*FACTORY-FAILURE-FATAL
		}
		@child;
	}

	# [ ]
	# { }
	# ang
	# « »
	# ( )
	#
	method _postcircumfix( Mu $p ) {
		my Perl6::Element @child;
		given $p {
			when self.assert-hash( $_, [< arglist O >] ) {
				if $_.hash.<arglist>.Str {
					@child.append(
						self._arglist(
							$_.hash.<arglist>
						)
					);
				}
# XXX Probably unused at this point, actually.
#				@child.append( self._O( $_.hash.<O> ) );
			}
			when self.assert-hash( $_, [< semilist O >] ) {
				my Perl6::Element @_child;
				@_child.append(
					self._semilist( $_.hash.<semilist> )
				);
				@child.append(
					Perl6::Operator::PostCircumfix.from-match(
						$_,
						@_child
					)
				);
			}
			# XXX can probably be rewritten to use utils
			when self.assert-hash( $_, [< nibble O >] ) {
				if $_.Str ~~ m{ ^ (.) ( \s+ )? ( .+? ) ( \s+ )? (.) $ } {
					my Perl6::Element @_child;
					@_child.append(
						Perl6::Bareword.from-int(
							$_.from +
							$0.Str.chars +
							( $1 ?? $1.Str.chars !! 0 ),
							$2.Str
						)
					);
					@child.append(
						Perl6::Operator::PostCircumfix.from-match(
							$_, @_child
						)
					);
				}
				else {
					@child.append(
						Perl6::Bareword.from-match-trimmed(
							$_.hash.<nibble>
						)
					);
				}
			}
			default {
				debug-match( $_ ) if $*DEBUG;
				die "Unhandled case" if
					$*FACTORY-FAILURE-FATAL
			}
		}
		@child;
	}

	# ⁿ
	#
	method _postfix( Mu $p ) {
		my Perl6::Element @child;
		given $p {
			when self.assert-hash( $_, [< sym O >] ) {
				@child.append(
					Perl6::Operator::Postfix.from-match(
						$_.hash.<sym>
					)
				);
			}
			when self.assert-hash( $_, [< dig O >] ) {
				@child.append(
					Perl6::Operator::Postfix.from-match(
						$_.hash.<dig>
					)
				);
			}
			default {
				debug-match( $_ ) if $*DEBUG;
				die "Unhandled case" if
					$*FACTORY-FAILURE-FATAL
			}
		}
		@child;
	}

	method _postop( Mu $p ) {
		my Perl6::Element @child;
		given $p {
			when self.assert-hash( $_,
					[< sym postcircumfix O >] ) {
				@child.append( self._sym( $_.hash.<sym> ) );
				@child.append(
					self._postcircumfix(
						$_.hash.<postcircumfix>
					)
				);
# XXX Probably needs to be rethought
#				@child.append( self._O( $_.hash.<O> ) );
			}
			when self.assert-hash( $_,
					[< sym postcircumfix >], [< O >] ) {
				@child.append( self._sym( $_.hash.<sym> ) );
				@child.append(
					self._postcircumfix(
						$_.hash.<postcircumfix>
					)
				);
			}
			default {
				debug-match( $_ ) if $*DEBUG;
				die "Unhandled case" if
					$*FACTORY-FAILURE-FATAL
			}
		}
		@child;
	}

	method _prefix( Mu $p ) {
		my Perl6::Element @child;
		given $p {
			when self.assert-hash( $_, [< sym O >] ) {
				@child.append(
					Perl6::Operator::Prefix.from-match(
						$_.hash.<sym>
					)
				);
			}
			default {
				debug-match( $_ ) if $*DEBUG;
				die "Unhandled case" if
					$*FACTORY-FAILURE-FATAL
			}
		}
		@child;
	}

	method _quant( Mu $p ) {
		if $p.Str {
			# XXX Need to propagate this back upwards.
			if $p.Str ne BACKSLASH {
				Perl6::Bareword.from-match( $p );
			}
			else {
				( )
			}
		}
		else {
			debug-match( $p ) if $*DEBUG;
			die "Unhandled case" if
				$*FACTORY-FAILURE-FATAL
		}
	}

	method _quantified_atom( Mu $p ) {
		my Perl6::Element @child;
		given $p {
			when self.assert-hash( $_, [< sigfinal atom >] ) {
				@child.append( self._atom( $_.hash.<atom> ) );
				@child.append(
					self._sigfinal( $_.hash.<sigfinal> )
				);
			}
			default {
				debug-match( $_ ) if $*DEBUG;
				die "Unhandled case" if
					$*FACTORY-FAILURE-FATAL
			}
		}
		@child;
	}

	# **
	# rakvar
	#
	method _quantifier( Mu $p ) {
		my Perl6::Element @child;
		given $p {
			when self.assert-hash( $_,
					[< sym min max backmod >] ) {
				@child.append( self._sym( $_.hash.<sym> ) );
				@child.append( self._min( $_.hash.<min> ) );
				@child.append( self._max( $_.hash.<max> ) );
				@child.append(
					self._backmod( $_.hash.<backmod> )
				);
			}
			when self.assert-hash( $_, [< sym backmod >] ) {
				@child.append( self._sym( $_.hash.<sym> ) );
				@child.append(
					self._backmod( $_.hash.<backmod> )
				);
			}
			default {
				debug-match( $_ ) if $*DEBUG;
				die "Unhandled case" if
					$*FACTORY-FAILURE-FATAL
			}
		}
		@child;
	}

	method _quibble( Mu $p ) {
		my Perl6::Element @child;
		given $p {
			when self.assert-hash( $_, [< babble nibble >] ) {
				# XXX Look at this later
				if $_.hash.<babble>.Str {
					@child.append(
						self._babble(
							$_.hash.<babble>
						)
					);
				}
				@child.append(
					self._nibble( $_.hash.<nibble> )
				);
			}
			default {
				debug-match( $_ ) if $*DEBUG;
				die "Unhandled case" if
					$*FACTORY-FAILURE-FATAL
			}
		}
		@child;
	}

	# apos # ' .. '
	# sapos # ('smart single quotes')..()
	# lapos # ('low smart single quotes')..
	# hapos # ('high smart single quotes')..
	# dblq # "
	# sdblq # ('smart double quotes')
	# ldblq # ('low double smart quotes')
	# hdblq # ('high double smart quotes')
	# crnr # ('corner quotes')
	# qq
	# q
	# Q
	# / /
	# rx
	# m
	# tr
	# s
	# quasi
	#
	method _quote( Mu $p ) {
		my Perl6::Element @child;
		if self.assert-hash-strict( $p,
				[< sym quibble >], [< rx_adverbs >] ) {
			given $p {
				when $_.hash.<sym>.Str eq 'rx' {
					# XXX Will need fixing.
					@child.append(
						Perl6::Balanced::Enter.from-int(
							$_.from,
							'rx/'
						)
					);
					@child.append(
						self._quibble(
							$_.hash.<quibble>
						)
					);
					@child.append(
						Perl6::Balanced::Exit.from-int(
							$_.to - '/'.chars,
							'/'
						)
					);
				}
				default {
					@child.append(
						self._quibble(
							$_.hash.<quibble>
						)
					);
				}
			}
		}
		elsif self.assert-hash( $p, [< quibble >] ) {
			my Str $leader = $p.Str.substr(
				0,
				$p.hash.<quibble>.hash.<nibble>.from - $p.from
			);

			my Bool ( $has-q, $has-to ) = False, False;
			$has-q = True if $leader ~~ m{ ':q' };
			$has-to = True if $leader ~~ m{ ':to' };

			my Str $trailer = $p.Str.substr(
				$p.hash.<quibble>.hash.<nibble>.to - $p.from
			);
			my Str $content = $p.Str;
			if $has-to {
				my ( $content, $marker ) =
					%.here-doc{ $p.from };
				$content = $content;
			}
			$leader ~~ m{ ( . ) $ };
			my Str @adverb;
			@adverb.append( ':q' ) if $has-q;
			@adverb.append( ':to' ) if $has-to;

			@child.append(
				Perl6::String.new(
					:factory-line-number(
						callframe(1).line
					),
					:from( $p.from ),
					:to( $p.to ),
					:delimiter( $0.Str, $trailer ),
					:adverb( @adverb ),
					:content( $content )
				)
			);
		}
		elsif self.assert-hash( $p, [< nibble >] ) {
			$p.Str ~~ m{ ^ ( . ) .*? ( . ) $ };
			given $0.Str {
				when Q{'} {
					@child.append(
						Perl6::String::Single.from-match(
							$p
						)
					);
				}
				when Q{"} {
					@child.append(
						Perl6::String::Double.from-match(
							$p
						)
					);
				}
				when Q{/} {
					# XXX Need to pass delimiters in
					@child.append(
						Perl6::Regex.from-match( $p )
					);
				}
				default {
					# XXX
					die "Unknown delimiter '{$0.Str}'"
				}
			}
		}
		else {
			debug-match( $p ) if $*DEBUG;
			die "Unhandled case" if
				$*FACTORY-FAILURE-FATAL
		}
		@child;
	}

	method _quotepair( Mu $p ) {
		my Perl6::Element @child;
		if $p.list {
			for $p.list {
				if self.assert-hash( $_, [< identifier >] ) {
					@child.append(
						self._identifier(
							$_.hash.<identifier>
						)
					);
				}
				else {
					debug-match( $_ ) if $*DEBUG;
					die "Unhandled case" if
						$*FACTORY-FAILURE-FATAL
				}
			}
		}
		elsif self.assert-hash( $p,
				[< circumfix bracket radix >],
				[< exp base >] ) {
			@child.append( self._circumfix( $_.hash.<circumfix> ) );
			@child.append( self._bracket( $_.hash.<bracket> ) );
			@child.append( self._radix( $_.hash.<radix> ) );
		}
		elsif self.assert-hash( $p, [< identifier >] ) {
			@child.append(
				self._identifier( $p.hash.<identifier> )
			);
		}
		else {
			debug-match( $p ) if $*DEBUG;
			die "Unhandled case" if
				$*FACTORY-FAILURE-FATAL
		}
		@child;
	}

	method _radix( Mu $p ) {
		warn "radix finally used";
		( )
	}

	method _rad_number( Mu $p ) {
		given $p {
			when self.assert-hash( $_,
					[< circumfix bracket radix >],
					[< exp rad_digits base >] ) {
				Perl6::Number::Radix.from-match( $_ );
			}
			when self.assert-hash( $_,
					[< circumfix bracket radix >],
					[< exp base >] ) {
				Perl6::Number::Radix.from-match( $_ );
			}
			when self.assert-hash( $_,
					[< circumfix radix >],
					[< exp base >] ) {
				Perl6::Number::Radix.from-match( $_ );
			}
			when self.assert-hash( $_,
					[< circumfix radix >],
					[< exp rad_digits base >] ) {
				Perl6::Number::Radix.from-match( $_ );
			}
			default {
				debug-match( $_ ) if $*DEBUG;
				die "Unhandled case" if
					$*FACTORY-FAILURE-FATAL
			}
		}
	}

	# rule <name> { },
	# token <name> { },
	# regex <name> { },
	#
	method _regex_declarator( Mu $p ) {
		my Perl6::Element @child;
		given $p {
			when self.assert-hash( $_, [< sym regex_def >] ) {
				@child.append( self._sym( $_.hash.<sym> ) );
				@child.append(
					self._regex_def( $_.hash.<regex_def> )
				);
			}
			default {
				debug-match( $_ ) if $*DEBUG;
				die "Unhandled case" if
					$*FACTORY-FAILURE-FATAL
			}
		}
		@child;
	}

	method _regex_def( Mu $p ) {
		my Perl6::Element @child;

		# 'regex Foo { token }'
		#	deflongname = 'Foo'
		#	nibble = 'token '
		#
		if self.assert-hash( $p,
				[< deflongname nibble >],
				[< signature trait >] ) {
			my Perl6::Element @_child;
			@child.append(
				self._deflongname( $p.hash.<deflongname> )
			);
			my Int $left-margin = $p.from;
			my Int $right-margin = $p.to;
			$left-margin += $p.hash.<deflongname>.Str.chars;
			my Str $x = $p.Str.substr(
				$p.hash.<deflongname>.to - $p.from
			);
			if $x ~~ m{ ^ ( \s+ ) } {
				$left-margin += $0.Str.chars;
			}
			if $p.Str ~~ m{ ( \s+ ) $ } {
				$right-margin -= $0.Str.chars;
			}

			@_child.append(
				Perl6::Balanced::Enter.from-int(
					$left-margin,
					BRACE-OPEN
				)
			);
			$x = $p.Str.substr( $left-margin + 1 - $p.from );
			@_child.append( self._nibble( $p.hash.<nibble> ) );
			$x = $p.Str.substr( $p.hash.<nibble>.to - $p.from );
			@_child.append(
				Perl6::Balanced::Exit.from-int(
					$right-margin - 1,
					BRACE-CLOSE
				)
			);
			@child.append(
				Perl6::Block.new(
					:factory-line-number(
						callframe(1).line
					),
					:from( @_child[0].from ),
					:to( @_child[*-1].to ),
					:child( @_child )
				)
			);
		}
		else {
			debug-match( $p ) if $*DEBUG;
			die "Unhandled case" if
				$*FACTORY-FAILURE-FATAL
		}
		@child;
	}

	method _right( Mu $p ) {
		warn "right finally used";
		( )
	}

	# sub <name> ... { },
	# method <name> ... { },
	# submethod <name> ... { },
	# macro <name> ... { }, # XXX ?
	#
	method _routine_declarator( Mu $p ) {
		my Perl6::Element @child;
		if self.assert-hash( $p, [< sym routine_def >] ) {
			@child.append( self._sym( $p.hash.<sym> ) );
			@child.append(
				self._routine_def( $p.hash.<routine_def> )
			);
		}
		elsif self.assert-hash( $p, [< sym method_def >] ) {
			@child.append( self._sym( $p.hash.<sym> ) );
			@child.append(
				self._method_def( $p.hash.<method_def> )
			);
		}
		else {
			debug-match( $p ) if $*DEBUG;
			die "Unhandled case" if
				$*FACTORY-FAILURE-FATAL
		}
		@child;
	}

	method _routine_def( Mu $p ) {
		my Perl6::Element @child;
		given $p {
			when self.assert-hash( $_,
					[< deflongname multisig
					   blockoid trait >] ) {
				my Perl6::Element @_child;
				my $left-margin = $_.Str.substr(
					0, $_.hash.<multisig>.from - $_.from
				);
				$left-margin ~~ m{ ( '(' ) ( \s* ) $ };
				@_child.append(
					Perl6::Balanced::Enter.from-int(
						$p.hash.<multisig>.from -
						PAREN-OPEN.chars - $1.Str.chars,
						PAREN-OPEN
					)
				);
				@_child.append(
					self._multisig( $_.hash.<multisig> )
				);
				@_child.append(
					Perl6::Balanced::Exit.from-int(
						$_.hash.<multisig>.to,
						PAREN-CLOSE
					)
				);
				@child.append(
					self._deflongname(
						$_.hash.<deflongname>
					)
				);
				@child.append(
					Perl6::Operator::Circumfix.new(
						:factory-line-number(
							callframe(1).line 
						),
						:from(
							$_.hash.<multisig>.from -
							$0.Str.chars - $1.Str.chars ),
						:to(
							$_.hash.<multisig>.to +
							PAREN-CLOSE.chars
						),
						:child( @_child ),
					)
				);
				@child.append(
					self._trait( $_.hash.<trait> )
				);
				@child.append(
					self._blockoid( $_.hash.<blockoid> )
				);
			}
			when self.assert-hash( $_,
					[< deflongname multisig
					   blockoid >],
					[< trait >] ) {
				my Perl6::Element @_child;
				my $left-margin = $_.Str.substr(
					0, $_.hash.<multisig>.from - $_.from
				);
				$left-margin ~~ m{ ( '(' ) ( \s* ) $ };
				@_child.append(
					Perl6::Balanced::Enter.from-int(
						$p.hash.<multisig>.from -
						PAREN-OPEN.chars - $1.Str.chars,
						PAREN-OPEN
					)
				);
				@_child.append(
					self._multisig( $_.hash.<multisig> )
				);
				@_child.append(
					Perl6::Balanced::Exit.from-int(
						$_.hash.<multisig>.to,
						PAREN-CLOSE
					)
				);
				@child.append(
					self._deflongname(
						$_.hash.<deflongname>
					)
				);
				@child.append(
					Perl6::Operator::Circumfix.new(
						:factory-line-number(
							callframe(1).line 
						),
						:from(
							$_.hash.<multisig>.from -
							$0.Str.chars - $1.Str.chars ),
						:to(
							$_.hash.<multisig>.to +
							PAREN-CLOSE.chars
						),
						:child( @_child ),
					)
				);
				@child.append(
					self._blockoid( $_.hash.<blockoid> )
				);
			}
			when self.assert-hash( $_,
					[< deflongname statementlist >],
					[< trait >] ) {
				@child.append(
					self._deflongname(
						$_.hash.<deflongname>
					)
				);
				if $_.Str ~~ m{ ( ';' ) ( \s* ) $ } {
					@child.append(
						Perl6::Semicolon.from-int(
							$_.to - $1.chars -
							$0.chars,
							$0.Str
						)
					);
				}
			}
			when self.assert-hash( $_,
					[< deflongname trait blockoid >] ) {
				@child.append(
					self._deflongname(
						$_.hash.<deflongname>
					)
				);
				@child.append( self._trait( $_.hash.<trait> ) );
				@child.append(
					self._blockoid( $_.hash.<blockoid> )
				);
			}
			when self.assert-hash( $_,
					[< blockoid multisig >], [< trait >] ) {
				my Perl6::Element @_child;
				@_child.append(
					self._multisig( $_.hash.<multisig> )
				);
				@child.append(
					Perl6::Operator::Circumfix.new(
						:factory-line-number(
							callframe(1).line
						),
						:from(
							$_.hash.<blockoid>.from
						),
						:to( $_.hash.<blockoid>.to ),
						:child( @_child )
					)
				);
				@child.append( self._blockoid( $_.hash.<blockoid> ) );
			}
			when self.assert-hash( $_,
					[< deflongname blockoid >],
					[< trait >] ) {
				@child.append(
					self._deflongname(
						$_.hash.<deflongname>
					)
				);
				@child.append(
					self._blockoid( $_.hash.<blockoid> )
				);
			}
			when self.assert-hash( $_,
					[< blockoid >], [< trait >] ) {
				@child.append(
					self._blockoid( $_.hash.<blockoid> )
				);
			}
			default {
				debug-match( $_ ) if $*DEBUG;
				die "Unhandled case" if
					$*FACTORY-FAILURE-FATAL
			}
		}
		@child;
	}

	method _rx_adverbs( Mu $p ) {
		given $p {
			when self.assert-hash( $_, [< quotepair >] ) {
				self._quotepair( $_.hash.<quotepair> );
			}
			when self.assert-hash( $_,
					[ ], [< quotepair >] ) {
				die "Not implemented yet"
			}
			default {
				debug-match( $_ ) if $*DEBUG;
				die "Unhandled case" if
					$*FACTORY-FAILURE-FATAL
			}
		}
	}

	method _scoped( Mu $p ) {
		my Perl6::Element @child;
		given $p {
			# XXX DECL seems to be a mirror of declarator.
			# XXX This probably will turn out to be not true.
			#
			if self.assert-hash( $_,
					[< multi_declarator DECL typename >] ) {
				@child.append(
					self._typename( $_.hash.<typename> )
				);
				@child.append(
					self._multi_declarator(
						$_.hash.<multi_declarator>
					)
				);
			}
			elsif self.assert-hash( $_,
					[< package_declarator DECL >],
					[< typename >] ) {
				@child.append(
					self._package_declarator(
						$_.hash.<package_declarator>
					)
				);
			}
			elsif self.assert-hash( $_,
					[< sym package_declarator >] ) {
				@child.append( self._sym( $_.hash.<sym> ) );
				@child.append(
					self._package_declarator(
						$_.hash.<package_declarator>
					)
				);
			}
			elsif self.assert-hash( $_,
					[< declarator DECL >],
					[< typename >] ) {
				@child.append(
					self._declarator(
						$_.hash.<declarator>
					)
				);
			}
			else {
				debug-match( $_ ) if $*DEBUG;
				die "Unhandled case" if
					$*FACTORY-FAILURE-FATAL
			}
		}
		@child;
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
		my Perl6::Element @child;
		if self.assert-hash( $p, [< sym scoped >] ) {
			@child.append( self._sym( $p.hash.<sym> ) );
			@child.append( self._scoped( $p.hash.<scoped> ) );
		}
		else {
			debug-match( $p ) if $*DEBUG;
			die "Unhandled case" if
				$*FACTORY-FAILURE-FATAL
		}
		@child;
	}

	method _semiarglist( Mu $p ) {
		given $p {
			when self.assert-hash( $_, [< arglist >] ) {
				self._arglist( $_.hash.<arglist> );
			}
			default {
				debug-match( $_ ) if $*DEBUG;
				die "Unhandled case" if
					$*FACTORY-FAILURE-FATAL
			}
		}
	}

	method _semilist( Mu $p ) {
		my Perl6::Element @child;
		# XXX remove later
		CATCH {
			when X::Hash::Store::OddNumber { }
		}
		given $p {
			when self.assert-hash( $_, [< statement >] ) {
				@child.append(
					self._statement( $_.hash.<statement> )
				);
			}
			when self.assert-hash( $_, [ ], [< statement >] ) {
				( )
			}
			default {
				debug-match( $_ ) if $*DEBUG;
				die "Unhandled case" if
					$*FACTORY-FAILURE-FATAL
			}
		}
		@child;
	}

	method _separator( Mu $p ) {
		my Perl6::Element @child;
		given $p {
			when self.assert-hash( $_,
					[< septype quantified_atom >] ) {
				@child.append(
					self._septype( $_.hash.<septype> )
				);
				@child.append(
					self._quantified_atom(
						$_.hash.<quantified_atom>
					)
				);
			}
			default {
				debug-match( $_ ) if $*DEBUG;
				die "Unhandled case" if
					$*FACTORY-FAILURE-FATAL
			}
		}
		@child;
	}

	method _septype( Mu $p ) {
		Perl6::Bareword.from-match( $p );
	}

	method _sequence( Mu $p ) {
		my Perl6::Element @child;
		given $p {
			when self.assert-hash( $_,
					[< statement >] ) {
				@child.append(
					self._statement(
						$_.hash.<statement>
					)
				);
			}
			default {
				debug-match( $_ ) if $*DEBUG;
				die "Unhandled case" if
					$*FACTORY-FAILURE-FATAL
			}
		}
		@child;
	}

	method _shape( Mu $p ) {
		my Perl6::Element @_child;
		$p.Str ~~ m{ ^ '{' \s* ( .+ ) \s* '}' };
		@_child.append(
			Perl6::Bareword.from-int(
				$p.from + $0.from,
				$0.Str
			)
		);
		Perl6::Operator::Circumfix.from-match(
			$p, @_child
		);
	}

	method _sibble( Mu $p ) {
		my Perl6::Element @child;
		given $p {
			if self.assert-hash( $_, [< right babble left >] ) {
				@child.append( self._right( $_.hash.<right> ) );
				@child.append(
					self._babble( $_.hash.<babble> )
				);
				@child.append( self._left( $_.hash.<left> ) );
			}
			else {
				debug-match( $_ ) if $*DEBUG;
				die "Unhandled case" if
					$*FACTORY-FAILURE-FATAL
			}
		}
		@child;
	}

	method _sigfinal( Mu $p ) {
		given $p {
			when self.assert-hash( $_, [< normspace >] ) {
				( )
			}
			default {
				debug-match( $_ ) if $*DEBUG;
				die "Unhandled case" if
					$*FACTORY-FAILURE-FATAL
			}
		}
	}

	method _sigil( Mu $p ) {
		Perl6::Bareword.from-match( $p )
	}

	method _sigmaybe( Mu $p ) {
		my Perl6::Element @child;
		given $p {
			when self.assert-hash( $_,
					[< parameter typename >],
					[< param_sep >] ) {
				@child.append(
					self._parameter( $_.hash.<parameter> )
				);
				@child.append(
					self._typename( $_.hash.<typename> )
				);
			}
			when self.assert-hash( $_, [< normspace >] ) {
				@child.append(
					self._normspace( $_.hash.<normspace> )
				);
			}
			when self.assert-hash( $_, [ ],
					[< param_sep parameter >] ) {
				die "Not implemented yet"
			}
			default {
				debug-match( $_ ) if $*DEBUG;
				die "Unhandled case" if
					$*FACTORY-FAILURE-FATAL
			}
		}
		@child;
	}

	method __Parameter( Mu $p ) {
		my Perl6::Element @child;
		if self.assert-hash( $p,
			[< param_term type_constraint quant >],
			[< post_constraint default_value modifier trait >] ) {
			@child.append(
				self._type_constraint(
					$p.hash.<type_constraint>
				)
			);
			@child.append( self._quant( $p.hash.<quant> ) );
			@child.append(
				self._param_term( $p.hash.<param_term> )
			);
		}
		elsif self.assert-hash( $p,
			[< param_term quant >],
			[< default_value type_constraint modifier trait post_constraint >] ) {
			@child.append( self._quant( $p.hash.<quant> ) );
			@child.append(
				self._param_term( $p.hash.<param_term> )
			);
		}
		elsif self.assert-hash( $p,
			[< defterm quant >],
			[< type_constraint post_constraint
			   default_value modifier trait >] ) {
			@child.append( self._defterm( $_.hash.<defterm> ) );
			@child.append( self._quant( $_.hash.<quant> ) );
		}
		elsif self.assert-hash( $p,
			[< type_constraint param_var
			   post_constraint quant >],
			[< default_value modifier trait >] ) {
			@child.append(
				self._type_constraint(
					$p.hash.<type_constraint>
				)
			);
			@child.append(
				self._param_var( $p.hash.<param_var> )
			);
			@child.append(
				self._post_constraint(
					$p.hash.<post_constraint>
				)
			);
		}
		elsif self.assert-hash( $p,
			[< type_constraint param_var quant >],
			[< default_value modifier trait
			   post_constraint >] ) {
			@child.append(
				self._type_constraint(
					$p.hash.<type_constraint>
				)
			);
			@child.append( self._param_var( $p.hash.<param_var> ) );
			if $p.hash.<default_value> {
				if $p.Str ~~ m{ ( \s* ) ('=') ( \s* ) } {
					@child.append(
						Perl6::Operator::Infix.from-int(
							$p.from + $1.from,
							$1.Str
						)
					);
					@child.append(
						self._EXPR( $p.hash.<default_value>.list.[0].hash.<EXPR> )
					);
				}
			}
		}
		elsif self.assert-hash( $p,
			[< param_var quant default_value >],
			[< modifier trait type_constraint post_constraint >] ) {
			@child.append( self._param_var( $p.hash.<param_var> ) );
			# XXX assuming the location for '='
			@child.append(
				Perl6::Operator::Infix.find-match( $p, EQUAL )
			);
			@child.append(
				self._default_value( $p.hash.<default_value> )
			);
		}
		elsif self.assert-hash( $p,
			[< param_var quant post_constraint >],
			[< modifier trait type_constraint default_value >] ) {
			@child.append( self._param_var( $p.hash.<param_var> ) );
			if $p.hash.<quant>.Str {
				@child.append( self._quant( $p.hash.<quant> ) );
			}
			@child.append(
				self._post_constraint(
					$p.hash.<post_constraint>
				)
			);
		}
		elsif self.assert-hash( $p,
			[< param_var quant >],
			[< default_value modifier trait
			   type_constraint post_constraint >] ) {
			if $p.hash.<quant>.Str {
				@child.append( self._quant( $p.hash.<quant> ) );
			}
			@child.append( self._param_var( $p.hash.<param_var> ) );
			if $p.hash.<trait> {
				@child.append( self._trait( $p.hash.<trait> ) );
			}
			if $p.hash.<post_constraint> {
				@child.append(
					self._post_constraint(
						$p.hash.<post_constraint>
					)
				);
			}
		}
		elsif self.assert-hash( $p,
			[< named_param quant >],
			[< default_value type_constraint modifier
			   trait post_constraint >] ) {
			# Synthesize the 'from' and 'to' markers for ':'
			$p.Str ~~ m{ (':') };
			@child.append(
				Perl6::Operator::Prefix.from-int(
					$p.from + $0.from,
					$0.Str
				)
			);
			@child.append(
				self._named_param(
					$p.hash.<named_param>
				)
			);
		}
		elsif self.assert-hash( $p,
			[< type_constraint >],
			[< default_value modifier trait
			   post_constraint >] ) {
			@child.append(
				self._type_constraint(
					$p.hash.<type_constraint>
				)
			);
		}
		else {
			debug-match( $p ) if $*DEBUG;
			die "Unhandled case" if
				$*FACTORY-FAILURE-FATAL
		}
		@child;
	}

	method _signature( Mu $p ) {
		my Perl6::Element @child;
		if self.assert-hash( $p,
				[< parameter typename >],
				[< param_sep >] ) {
			@child.append( self._typename( $p.hash.<typename> ) );
			@child.append( self._parameter( $p.hash.<parameter> ) );
		}
		elsif self.assert-hash( $p,
				[< parameter >],
				[< param_sep >] ) {
			my Mu $parameter = $p.hash.<parameter>;
			my Int $offset = $p.from;
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
					my Int $_start = $start;
					my ( $lhs, $rhs ) = split( COMMA, $str );
					if $lhs and $lhs ne '' {
						$_start += $lhs.chars;
					}
					@child.append(
						Perl6::Operator::Infix.from-int( $_start, COMMA )
					);
				}
				@child.append(
					self.__Parameter( $_ )
				);
			}
		}
		elsif self.assert-hash( $p,
				[< param_sep >],
				[< parameter >] ) {
			@child.append( self._parameter( $p.hash.<parameter> ) );
		}
		elsif self.assert-hash( $p, [ ],
				[< param_sep parameter >] ) {
		}
		else {
			debug-match( $p ) if $*DEBUG;
			die "Unhandled case" if
				$*FACTORY-FAILURE-FATAL
		}
		@child;
	}

	method _smexpr( Mu $p ) {
		given $p {
			when self.assert-hash( $_, [< EXPR >] ) {
				self._EXPR( $_.hash.<EXPR> );
			}
			default {
				debug-match( $_ ) if $*DEBUG;
				die "Unhandled case" if
					$*FACTORY-FAILURE-FATAL
			}
		}
	}

	method _specials( Mu $p ) {
		warn "specials finally used";
		( )
	}

	# if
	# unless
	# while
	# repeat
	# for
	# whenever
	# loop
	# need
	# import
	# use
	# require
	# given
	# when
	# default
	# CATCH
	# CONTROL
	# QUIT
	#
	method _statement_control( Mu $p ) {
		my Perl6::Element @child;
		given $p {
			if self.assert-hash( $_, [< block sym e1 e2 e3 >] ) {
				@child.append( self._block( $_.hash.<block> ) );
				@child.append( self._sym( $_.hash.<sym> ) );
				@child.append( self._e1( $_.hash.<e1> ) );
				@child.append( self._e2( $_.hash.<e2> ) );
				@child.append( self._e3( $_.hash.<e3> ) );
			}
			elsif self.assert-hash( $_,
					[< pblock sym EXPR wu >] ) {
				@child.append(
					self._pblock( $_.hash.<pblock> )
				);
				@child.append( self._sym( $_.hash.<sym> ) );
				@child.append( self._EXPR( $_.hash.<EXPR> ) );
				@child.append( self._wu( $_.hash.<wu> ) );
			}
			elsif self.assert-hash( $_,
					[< doc sym module_name >] ) {
				@child.append( self._sym( $_.hash.<sym> ) );
				@child.append(
					self._module_name(
						$_.hash.<module_name>
					)
				);
			}
			elsif self.assert-hash( $_, [< doc sym version >] ) {
				@child.append( self._doc( $_.hash.<doc> ) );
				@child.append( self._sym( $_.hash.<sym> ) );
				@child.append(
					self._version( $_.hash.<version> )
				);
			}
			elsif self.assert-hash( $_, [< sym else xblock >] ) {
				for 0 .. ( $_.hash.<sym>.list.elems - 1 ) -> $idx {
					@child.append(
						Perl6::Bareword.from-match(
							$_.hash.<sym>.list.[$idx]
						)
					);
					@child.append(
						self._xblock(
							$_.hash.<xblock>.list.[$idx]
						)
					);
				}
				my $x = $_.Str.substr( 0, $_.hash.<else>.from );
				if $x ~~ m{ ('else') } {
					@child.append(
						Perl6::Bareword.from-int(
							$p.from + $0.from,
							$0.Str
						)
					);
				}
				@child.append( self._else( $_.hash.<else> ) );
			}
			elsif self.assert-hash( $_, [< xblock sym wu >] ) {
				@child.append( self._sym( $_.hash.<sym> ) );
				@child.append( self._wu( $_.hash.<wu> ) );
				@child.append(
					self._xblock( $_.hash.<xblock> )
				);
			}
			elsif self.assert-hash( $_, [< sym xblock >] ) {
				@child.append( self._sym( $_.hash.<sym> ) );
				@child.append(
					self._xblock( $_.hash.<xblock> )
				);
			}
			elsif self.assert-hash( $_, [< sym block >] ) {
				@child.append( self._sym( $_.hash.<sym> ) );
				@child.append( self._block( $_.hash.<block> ) );
			}
			else {
				debug-match( $_ ) if $*DEBUG;
				die "Unhandled case" if
					$*FACTORY-FAILURE-FATAL
			}
		}
	}

	method _statement( Mu $p ) {
		my Perl6::Element @child;
		if $p.list {
			for $p.list {
				if self.assert-hash( $_,
						[< EXPR
						   statement_mod_loop >] ) {
					@child.append(
						self._EXPR( $_.hash.<EXPR> )
					);
					@child.append(
						self._statement_mod_loop(
							$_.hash.<statement_mod_loop>
						)
					);
				}
				elsif self.assert-hash( $_,
						[< statement_mod_cond
						   EXPR >] ) {
					@child.append(
						self._statement_mod_cond(
							$_.hash.<statement_mod_cond>
						)
					);
					@child.append(
						self._EXPR( $_.hash.<EXPR> )
					);
				}
				elsif self.assert-hash( $_, [< EXPR >] ) {
					# XXX Aiyee. Ugly but it does work.
					my Mu $q = $_.hash.<EXPR>;
					if $q.list.[0] and
					   $q.hash.<infix> and
					   $q.list.[1] and
					   $q.list.[1].hash.<value> {
						@child.append(
							self._EXPR(
								$q.list.[0]
							)
						);
						for 1 .. ( $q.list.elems - 1 ) -> $idx {
							# XXX Yes, this needs to be fixed
							@child.append(
								self._infix(
									$q.hash.<infix>
								)
							);
if $q.list.[$idx].Str {
							@child.append(
								self._EXPR(
									$q.list.[$idx]
								)
							);
}
						}
					}
					else {
						@child.append(
							self._EXPR(
								$_.hash.<EXPR>
							)
						);
					}
				}
				elsif self.assert-hash( $_,
						[< statement_control >] ) {
					self._statement_control(
						$_.hash.<statement_control>
					);
				}
				elsif self.assert-hash( $_, [< >],
						[< statement_control >] ) {
					die "Not implemented yet"
				}
				else {
					debug-match( $_ ) if $*DEBUG;
					die "Unhandled case" if $*FACTORY-FAILURE-FATAL
				}
			}
		}
		elsif self.assert-hash( $p, [< EXPR statement_mod_cond >] ) {
			if $p.hash.<EXPR>.Str ~~ m{ ( \s+ ) $ } {
				@child.append( self._EXPR( $p.hash.<EXPR> ) );
				@child.append(
					self._statement_mod_cond(
						$p.hash.<statement_mod_cond>
					)
				);
			}
			else {
				@child.append( self._EXPR( $p.hash.<EXPR> ) );
				@child.append(
					self._statement_mod_cond(
						$p.hash.<statement_mod_cond>
					)
				);
			}
		}
		elsif self.assert-hash( $p, [< EXPR statement_mod_loop >] ) {
			if $p.hash.<EXPR>.Str ~~ m{ ( \s+ ) $ } {
				@child.append( self._EXPR( $p.hash.<EXPR> ) );
				@child.append(
					self._statement_mod_loop(
						$p.hash.<statement_mod_loop>
					)
				);
			}
			else {
				@child.append( self._EXPR( $p.hash.<EXPR> ) );
				@child.append(
					self._statement_mod_loop(
						$p.hash.<statement_mod_loop>
					)
				);
			}
		}
		elsif self.assert-hash( $p, [< sym trait >] ) {
			@child.append( self._sym( $p.hash.<sym> ) );
			@child.append( self._trait( $p.hash.<trait> ) );
		}
		# $p contains trailing whitespace for <package_declaration>
		# This *should* be handled in _statementlist
		#
		elsif self.assert-hash( $p, [< EXPR >] ) {
			# XXX Sigh, need to handle *this* where we have the
			# XXX proper matching string available.
			if $p.hash.<EXPR>.hash.<infix> {
				if $p.hash.<EXPR>.list.elems == 3 and
					$p.hash.<EXPR>.hash.<infix> and
					$p.hash.<EXPR>.hash.<OPER> {
					@child.append(
						self._EXPR(
							$p.hash.<EXPR>.list.[0]
						)
					);
					@child.append(
						Perl6::Operator::Infix.from-int(
							$p.hash.<EXPR>.hash.<infix>.from,
							QUES-QUES
						)
					);
					@child.append(
						self._EXPR( $p.hash.<EXPR>.list.[1] )
					);
					@child.append(
						Perl6::Operator::Infix.find-match(
							$p.hash.<EXPR>, BANG-BANG
						)
					);
					@child.append(
						self._EXPR( $p.hash.<EXPR>.list.[2] )
					);
				}
				else {
					my Mu $q = $p.hash.<EXPR>;
					@child.append(
						self._EXPR( $q.list.[0] )
					);
					# XXX Sigh.
					if $p.hash.<EXPR>.Str.chars > 1 {
						@child.append(
							Perl6::Operator::Infix.from-match(
								$p.hash.<EXPR>
							)
						);
					}
					else {
						@child.append(
							self._infix( $q.hash.<infix> )
						);
					}
					@child.append(
						self._EXPR( $q.list.[1] )
					);
				}
			}
			else {
				@child.append( self._EXPR( $p.hash.<EXPR> ) );
			}
		}
		elsif self.assert-hash( $p, [< statement_control >] ) {
			@child.append(
				self._statement_control(
					$p.hash.<statement_control>
				)
			);
		}
		elsif !$p.hash.keys {
			note "Fix null case"
		}
		else {
			debug-match( $p ) if $*DEBUG;
			die "Unhandled case" if
				$*FACTORY-FAILURE-FATAL
		}
		@child;
	}

	method _statementlist( Mu $p ) {
		my Perl6::Element @child;
		my Str $leftover-ws;
		my Int $leftover-ws-from = 0;

		for $p.hash.<statement>.list {
			my Perl6::Element @_child;
			if $leftover-ws {
				$leftover-ws = Nil;
				$leftover-ws-from = 0
			}
			@_child.append( self._statement( $_ ) );
			# Do *NOT* remove this, use it to replace whatever
			# WS trailing terms the grammar below might add
			# redundantly.
			#
			if $_.Str ~~ m{ ( ';' ) ( \s+ ) $ } {
				$leftover-ws = $1.Str;
				$leftover-ws-from =
					$_.to - $1.Str.chars
			}
			else {
				if $_.Str ~~ m{ ( \s+ ) $ } {
					@_child.append(
						Perl6::WS.from-int(
							$_.to - $0.Str.chars,
							$0.Str
						)
					)
				}
			}
			my Str $temp = $p.Str.substr(
				@_child[*-1].to - $p.from
			);
			if $temp ~~ m{ ^ ( ';' ) ( \s+ ) } {
				$leftover-ws = $1.Str;
				$leftover-ws-from = 
					@_child[*-1].to +
					$0.Str.chars;
				@_child.append(
					Perl6::Semicolon.from-int(
						@_child[*-1].to,
						$0.Str
					)
				);
			}
			elsif $temp ~~ m{ ^ ( ';' ) } {
				@_child.append(
					Perl6::Semicolon.from-int(
						@_child[*-1].to,
						$0.Str
					)
				);
			}
			@child.append( Perl6::Statement.from-list( @_child ) );
		}
		if $leftover-ws {
			my Perl6::Element @_child;
			@_child.append(
				Perl6::WS.from-int(
					$leftover-ws-from, $leftover-ws
				)
			);
			@child.append( Perl6::Statement.from-list( @_child ) );
		}
		elsif !$p.hash.<statement> and $p.Str ~~ m{ . } {
			my Perl6::Element @_child;
			if $p.from < $p.to {
				@_child.append( Perl6::WS.from-match( $p ) );
			}
			@child.append( Perl6::Statement.from-list( @_child ) );
		}
		@child;
	}

	# if
	# unless
	# when
	# with
	# without
	# while
	# until
	# for
	# given
	#
	method _statement_mod_cond( Mu $p ) {
		my Perl6::Element @child;
		given $p {
			when self.assert-hash( $_, [< sym modifier_expr >] ) {
				@child.append( self._sym( $_.hash.<sym> ) );
				@child.append(
					self._modifier_expr(
						$_.hash.<modifier_expr>
					)
				);
			}
			default {
				debug-match( $_ ) if $*DEBUG;
				die "Unhandled case" if
					$*FACTORY-FAILURE-FATAL
			}
		}
		@child;
	}

	# while
	# until
	# for
	# given
	#
	method _statement_mod_loop( Mu $p ) {
		my Perl6::Element @child;
		given $p {
			when self.assert-hash( $_, [< sym smexpr >] ) {
				@child.append( self._sym( $_.hash.<sym> ) );
				@child.append(
					self._smexpr( $_.hash.<smexpr> )
				);
			}
			default {
				debug-match( $_ ) if $*DEBUG;
				die "Unhandled case" if
					$*FACTORY-FAILURE-FATAL
			}
		}
		@child;
	}

	# BEGIN
	# CHECK
	# COMPOSE
	# INIT
	# ENTER
	# FIRST
	# END
	# LEAVE
	# KEEP
	# UNDO
	# NEXT
	# LAST
	# PRE
	# POST
	# CLOSE
	# DOC
	# do
	# gather
	# supply
	# react
	# once
	# start
	# lazy
	# eager
	# hyper
	# race
	# sink
	# try
	# quietly
	#
	method _statement_prefix( Mu $p ) {
		my Perl6::Element @child;
		given $p {
			when self.assert-hash( $_, [< sym blorst >] ) {
				@child.append( self._sym( $_.hash.<sym> ) );
				@child.append(
					self._blorst( $_.hash.<blorst> )
				);
			}
			default {
				debug-match( $_ ) if $*DEBUG;
				die "Unhandled case" if
					$*FACTORY-FAILURE-FATAL
			}
		}
		@child;
	}

	method _subshortname( Mu $p ) {
		given $p {
			when self.assert-hash( $_, [< desigilname >] ) {
				self._desigilname( $_.hash.<desigilname> );
			}
			default {
				debug-match( $_ ) if $*DEBUG;
				die "Unhandled case" if
					$*FACTORY-FAILURE-FATAL
			}
		}
	}

	method _sym( Mu $p ) {
		my Perl6::Element @child;
		if $p.list {
			for $p.list {
				if $_.Str {
					@child.append(
						Perl6::Bareword.from-match( $_ )
					);
				}
				else {
					debug-match( $_ ) if $*DEBUG;
					die "Unhandled case" if
						$*FACTORY-FAILURE-FATAL
				}
			}
		}
		elsif $p.Str {
			@child.append( Perl6::Bareword.from-match( $p ) );
		}
		elsif $p.Bool and $p.Str eq '+' {
			@child.append( Perl6::Bareword.from-match( $p ) );
		}
		elsif $p.Bool and $p.Str eq '' {
			@child.append( Perl6::Bareword.from-match( $p ) );
		}
		else {
			debug-match( $p ) if $*DEBUG;
			die "Unhandled case" if
				$*FACTORY-FAILURE-FATAL
		}
		@child;
	}

	# fatarrow
	# colonpair
	# variable
	# package_declarator
	# scope_declarator
	# routine_declarator
	# multi_declarator
	# regex_declarator
	# type_declarator
	# circumfix
	# statement_prefix
	# sigterm
	# ∞
	# lambda
	# unquote
	# ?IDENT
	# self
	# now
	# time
	# empty_set
	# rand
	# ...
	# ???
	# !!!
	# dotty
	# identifier
	# name
	# nqp::op
	# nqp::const
	# *
	# **
	# capterm
	# onlystar
	# value
	#
	method _term( Mu $p ) {
		my Perl6::Element @child;
		given $p {
			when self.assert-hash( $_, [< methodop >] ) {
				@child.append(
					self._methodop( $_.hash.<methodop> )
				);
			}
			when self.assert-hash( $_, [< circumfix >] ) {
				@child.append(
					self._circumfix( $_.hash.<circumfix> )
				);
			}
			when self.assert-hash( $_,
					[< name >], [< colonpair >] ) {
				@child.append( self._name( $_.hash.<name> ) );
			}
			default {
				debug-match( $_ ) if $*DEBUG;
				die "Unhandled case" if
					$*FACTORY-FAILURE-FATAL
			}
		}
		@child;
	}

	method _termalt( Mu $p ) {
		my Perl6::Element @child;
		if $p.list {
			for $p.list {
				if self.assert-hash( $_, [< termconj >] ) {
					@child.append(
						self._termconj(
							$_.hash.<termconj>
						)
					);
				}
				else {
					debug-match( $_ ) if $*DEBUG;
					die "Unhandled case" if
						$*FACTORY-FAILURE-FATAL
				}
			}
		}
		else {
			debug-match( $p ) if $*DEBUG;
			die "Unhandled case" if
				$*FACTORY-FAILURE-FATAL
		}
		@child;
	}

	method _termaltseq( Mu $p ) {
		given $p {
			when self.assert-hash( $_, [< termconjseq >] ) {
				self._termconjseq( $_.hash.<termconjseq> );
			}
			default {
				debug-match( $_ ) if $*DEBUG;
				die "Unhandled case" if
					$*FACTORY-FAILURE-FATAL
			}
		}
	}

	method _termconj( Mu $p ) {
		my Perl6::Element @child;
		if $p.list {
			for $p.list {
				if self.assert-hash( $_, [< termish >] ) {
					@child.append(
						self._termish(
							$_.hash.<termish>
						)
					);
					my $x = $_.orig.Str.substr(
						$_.hash.<termish>.to
					);
					if $x ~~ m{ ^ ( \s* ) ( '|' ) } {
						@child.append(
							Perl6::Operator::Infix.from-int(
								$_.hash.<termish>.to + $1.from,
								$1.Str

							)
						);
					}
				}
				else {
					debug-match( $_ ) if $*DEBUG;
					die "Unhandled case" if
						$*FACTORY-FAILURE-FATAL
				}
			}
		}
		else {
			debug-match( $p ) if $*DEBUG;
			die "Unhandled case" if
				$*FACTORY-FAILURE-FATAL
		}
		@child;
	}

	method _termconjseq( Mu $p ) {
		my Perl6::Element @child;
		# XXX Work on this later.
		if $p.list {
			for $p.list {
				if self.assert-hash( $_, [< termalt >] ) {
					@child.append(
						self._termalt(
							$_.hash.<termalt>
						)
					);
				}
				else {
					debug-match( $_ ) if $*DEBUG;
					die "Unhandled case" if
						$*FACTORY-FAILURE-FATAL
				}
			}
		}
		elsif self.assert-hash( $p, [< termalt >] ) {
			@child.append( self._termalt( $p.hash.<termalt> ) );
		}
		elsif $p.Str {
			# XXX
			my Str $str = $p.Str;
			$str ~~ s{ \s+ $ } = '';
			@child.append(
				Perl6::Bareword.from-int( $p.from, $str )
			);
		}
		else {
			debug-match( $p ) if $*DEBUG;
			die "Unhandled case" if
				$*FACTORY-FAILURE-FATAL
		}
		@child;
	}

	method _term_init( Mu $p ) {
		my Perl6::Element @child;
		given $p {
			when self.assert-hash( $_, [< sym EXPR >] ) {
				@child.append( self._sym( $_.hash.<sym> ) );
				@child.append( self._EXPR( $_.hash.<EXPR> ) );
			}
			default {
				debug-match( $_ ) if $*DEBUG;
				die "Unhandled case" if
					$*FACTORY-FAILURE-FATAL
			}
		}
		@child;
	}

	method _termish( Mu $p ) {
		my Perl6::Element @child;
		if $p.list {
			for $p.list {
				if self.assert-hash( $_, [< noun >] ) {
					@child.append(
						self._noun( $_.hash.<noun> )
					);
				}
				else {
					debug-match( $_ ) if $*DEBUG;
					die "Unhandled case" if
						$*FACTORY-FAILURE-FATAL
				}
			}
		}
		elsif self.assert-hash( $p, [< sym term >] ) {
			@child.append( self._sym( $p.hash.<sym> ) );
			@child.append( self._term( $p.hash.<term> ) );
		}
		elsif self.assert-hash( $p, [< noun >] ) {
			@child.append( self._noun( $p.hash.<noun> ) );
		}
		else {
			debug-match( $p ) if $*DEBUG;
			die "Unhandled case" if
				$*FACTORY-FAILURE-FATAL
		}
		@child;
	}

	method _termseq( Mu $p ) {
		given $p {
			when self.assert-hash( $_, [< termaltseq >] ) {
				self._termaltseq( $_.hash.<termaltseq> );
			}
			default {
				debug-match( $_ ) if $*DEBUG;
				die "Unhandled case" if
					$*FACTORY-FAILURE-FATAL
			}
		}
	}

	method _trait( Mu $p ) {
		my Perl6::Element @child;
		if $p.list {
			for $p.list {
				if self.assert-hash( $_, [< trait_mod >] ) {
					@child.append(
						self._trait_mod(
							$_.hash.<trait_mod>
						)
					);
				}
				else {
					debug-match( $_ );
					die "Unhandled case" if
						$*FACTORY-FAILURE-FATAL
				}
			}
		}
		else {
			debug-match( $p ) if $*DEBUG;
			die "Unhandled case" if
				$*FACTORY-FAILURE-FATAL
		}
		@child;
	}

	# is
	# hides
	# does
	# will
	# of
	# returns
	# handles
	#
	method _trait_mod( Mu $p ) {
		my Perl6::Element @child;
		given $p {
			when self.assert-hash( $_,
					[< sym longname circumfix >] ) {
				@child.append( self._sym( $_.hash.<sym> ) );
				@child.append(
					self._longname( $_.hash.<longname> )
				);
				@child.append(
					self._circumfix( $_.hash.<circumfix> )
				);
			}
			when self.assert-hash( $_,
					[< sym longname >],
					[< circumfix >] ) {
				@child.append( self._sym( $_.hash.<sym> ) );
				@child.append(
					self._longname( $_.hash.<longname> )
				);
			}
			when self.assert-hash( $_, [< sym term >] ) {
				@child.append( self._sym( $_.hash.<sym> ) );
				@child.append( self._term( $_.hash.<term> ) );
			}
			when self.assert-hash( $_, [< sym typename >] ) {
				@child.append( self._sym( $_.hash.<sym> ) );
				@child.append(
					self._typename( $_.hash.<typename> )
				);
			}
			default {
				debug-match( $_ ) if $*DEBUG;
				die "Unhandled case" if
					$*FACTORY-FAILURE-FATAL
			}
		}
		@child;
	}

	method _twigil( Mu $p ) {
		warn "twigil finally used";
		( )
	}

	method _type_constraint( Mu $p ) {
		my Perl6::Element @child;
		if $p.list {
			for $p.list {
				if self.assert-hash( $_, [< typename >] ) {
					@child.append(
						self._typename(
							$_.hash.<typename>
						)
					);
				}
				elsif self.assert-hash( $_, [< value >] ) {
					@child.append(
						self._value( $_.hash.<value> )
					);
				}
				else {
					debug-match( $_ ) if $*DEBUG;
					die "Unhandled case" if
						$*FACTORY-FAILURE-FATAL
				}
			}
		}
		elsif self.assert-hash( $p, [< value >] ) {
			self._value( $p.hash.<value> );
		}
		elsif self.assert-hash( $p, [< typename >] ) {
			self._typename( $p.hash.<typename> );
		}
		else {
			debug-match( $p ) if $*DEBUG;
			die "Unhandled case" if
				$*FACTORY-FAILURE-FATAL
		}
		@child;
	}

	# enum
	# subset
	# constant
	#
	method _type_declarator( Mu $p ) {
		my Perl6::Element @child;
		if self.assert-hash( $p,
				[< sym initializer variable >], [< trait >] ) {
			@child.append( self._sym( $p.hash.<sym> ) );
			@child.append( self._variable( $p.hash.<variable> ) );
			@child.append(
				self._initializer( $p.hash.<initializer> )
			);
		}
		elsif self.assert-hash( $p,
				[< sym defterm initializer >], [< trait >] ) {
			@child.append( self._sym( $p.hash.<sym> ) );
			@child.append( self._defterm( $p.hash.<defterm> ) );
			@child.append(
				self._initializer( $p.hash.<initializer> )
			);
		}
		elsif self.assert-hash( $p,
				[< sym longname term >], [< trait >] ) {
			@child.append( self._sym( $p.hash.<sym> ) );
			@child.append( self._longname( $p.hash.<longname> ) );
			@child.append( self._term( $p.hash.<term> ) );
		}
		elsif self.assert-hash( $p, [< sym longname trait >] ) {
			@child.append( self._sym( $p.hash.<sym> ) );
			@child.append( self._longname( $p.hash.<longname> ) );
			@child.append( self._trait( $p.hash.<trait> ) );
		}
		elsif self.assert-hash( $p, [< sym longname >], [< trait >] ) {
			@child.append( self._sym( $p.hash.<sym> ) );
			@child.append( self._longname( $p.hash.<longname> ) );
		}
		else {
			debug-match( $p ) if $*DEBUG;
			die "Unhandled case" if
				$*FACTORY-FAILURE-FATAL
		}
		@child;
	}

	method _typename( Mu $p ) {
		for $p.list {
			if self.assert-hash( $_,
					[< longname colonpairs >],
					[< colonpair >] ) {
				# XXX Can probably be narrowed
				return Perl6::Bareword.from-match( $_ );
			}
			elsif self.assert-hash( $_,
					[< longname >], [< colonpairs >] ) {
				# XXX Can probably be narrowed
				return Perl6::Bareword.from-match( $_ );
			}
			else {
				debug-match( $_ ) if $*DEBUG;
				die "Unhandled case" if
					$*FACTORY-FAILURE-FATAL
			}
		}

		if self.assert-hash( $p, [< longname colonpairs >] ) {
			self._longname( $p.hash.<longname> );
		}
		elsif self.assert-hash( $p, [< longname >],
				[< colonpairs colonpair >] ) {
			self._longname( $p.hash.<longname> );
		}
		elsif self.assert-hash( $p, [< longname >], [< colonpair >] ) {
			self._longname( $p.hash.<longname> );
		}
		else {
			debug-match( $p ) if $*DEBUG;
			die "Unhandled case" if
				$*FACTORY-FAILURE-FATAL
		}
	}

	method _val( Mu $p ) {
		my Perl6::Element @child;
		given $p {
			when self.assert-hash( $_,
					[< postcircumfix OPER >],
					[< postfix_prefix_meta_operator >] ) {
				@child.append(
					self._postcircumfix(
						$_.hash.<postcircumfix>
					)
				);
				@child.append( self._OPER( $_.hash.<OPER> ) );
			}
			when self.assert-hash( $_,
					[< prefix OPER >],
					[< prefix_postfix_meta_operator >] ) {
				@child.append(
					self._prefix( $_.hash.<prefix> )
				);
				@child.append( self._OPER( $_.hash.<OPER> ) );
			}
			when self.assert-hash( $_,
					[< longname args >] ) {
				@child.append(
					self._longname( $_.hash.<longname> )
				);
				@child.append( self._args( $_.hash.<args> ) );
			}
			when self.assert-hash( $_, [< value >] ) {
				@child.append( self._value( $_.hash.<value> ) );
			}
			default {
				debug-match( $_ ) if $*DEBUG;
				die "Unhandled case" if
					$*FACTORY-FAILURE-FATAL
			}
		}
		@child;
	}

	method _VALUE( Mu $p ) {
#		return $p.hash.<VALUE>.Str if
#			$p.hash.<VALUE>.Str and $p.hash.<VALUE>.Str eq '0';
#		$p.hash.<VALUE>.Int
die "Catching Str";
die "Catching Int";
		$p.hash.<VALUE>.Str || $p.hash.<VALUE>.Int
	}

	# quote
	# number
	# version
	#
	method _value( Mu $p ) {
		given $p {
			when self.assert-hash( $_, [< number >] ) {
				self._number( $_.hash.<number> );
			}
			when self.assert-hash( $_, [< quote >] ) {
				self._quote( $_.hash.<quote> );
			}
			default {
				debug-match( $_ ) if $*DEBUG;
				die "Unhandled case" if
					$*FACTORY-FAILURE-FATAL
			}
		}
	}

	method _var( Mu $p ) {
		given $p {
			when self.assert-hash( $_,
					[< twigil sigil desigilname >] ) {
				# XXX For heavens' sake refactor.
				my Str $sigil	= $_.hash.<sigil>.Str;
				my Str $twigil	= $_.hash.<twigil> ??
						  $_.hash.<twigil>.Str !! '';
				my Str $desigilname =
					$_.hash.<desigilname> ??
					$_.hash.<desigilname>.Str !! '';
				my Str $content =
					$_.hash.<sigil> ~
					$twigil ~
					$desigilname;
				%sigil-map{$sigil ~ $twigil}.from-int(
					$_.from,
					$content
				);
			}
			when self.assert-hash( $_, [< sigil desigilname >] ) {
				# XXX For heavens' sake refactor.
				my Str $sigil	= $_.hash.<sigil>.Str;
				my Str $twigil	= $_.hash.<twigil> ??
						  $_.hash.<twigil>.Str !! '';
				my Str $desigilname =
					$_.hash.<desigilname> ??
					$_.hash.<desigilname>.Str !! '';
				my Str $content =
					$_.hash.<sigil> ~
					$twigil ~
					$desigilname;
				%sigil-map{$sigil ~ $twigil}.from-int(
					$_.from,
					$content
				);
			}
			when self.assert-hash( $_, [< variable >] ) {
				self._variable( $_.hash.<variable> );
			}
			default {
				debug-match( $_ ) if $*DEBUG;
				die "Unhandled case" if
					$*FACTORY-FAILURE-FATAL
			}
		}
	}

	method _variable_declarator( Mu $p ) {
		my Perl6::Element @child;
		given $p {
			when self.assert-hash( $_,
				[< semilist variable shape >],
				[< postcircumfix signature trait
				   post_constraint >] ) {
				@child.append(
					self._semilist( $_.hash.<semilist> )
				);
				@child.append(
					self._variable( $_.hash.<variable> )
				);
				@child.append( self._shape( $_.hash.<shape> ) );
			}
			when self.assert-hash( $_,
					[< variable post_constraint >],
					[< semilist postcircumfix
					   signature trait >] ) {
				# Synthesize the 'from' and 'to' markers
				$_.Str ~~ m{ ( \s* ) ( where ) ( \s* ) };
				my Int $from = $0.from;
				@child.append(
					self._variable( $_.hash.<variable> )
				);
				@child.append(
					self._post_constraint(
						$_.hash.<post_constraint>
					)
				);
			}
			when self.assert-hash( $_,
					[< variable trait >],
					[< semilist postcircumfix signature
					   post_constraint >] ) {
				@child.append(
					self._variable( $_.hash.<variable> )
				);
				@child.append( self._trait( $_.hash.<trait> ) );
			}
			when self.assert-hash( $_,
					[< variable >],
					[< semilist postcircumfix signature
					   trait post_constraint >] ) {
				@child.append(
					self._variable( $_.hash.<variable> )
				);
			}
			default {
				debug-match( $_ ) if $*DEBUG;
				die "Unhandled case" if
					$*FACTORY-FAILURE-FATAL
			}
		}
		@child;
	}

	method _variable( Mu $p ) {
		if self.assert-hash( $p, [< contextualizer >] ) {
			self._contextualizer( $p.hash.<contextualizer> );
		}
		else {
			my Str $sigil	= $p.hash.<sigil>.Str;
			my Str $twigil	= $p.hash.<twigil> ??
					  $p.hash.<twigil>.Str !! '';
			my Str $desigilname =
				$p.hash.<desigilname> ??
				$p.hash.<desigilname>.Str !! '';
			my Str $content =
				$p.hash.<sigil> ~ $twigil ~ $desigilname;
			%sigil-map{$sigil ~ $twigil}.from-int(
				$p.from,
				$content
			);
		}
	}

	method _version( Mu $p ) {
		my Perl6::Element @child;
		given $p {
			when self.assert-hash( $_, [< vnum vstr >] ) {
				@child.append( self._vstr( $_.hash.<vstr> ) );
			}
			default {
				debug-match( $_ ) if $*DEBUG;
				die "Unhandled case" if
					$*FACTORY-FAILURE-FATAL
			}
		}
		@child;
	}

	method _vstr( Mu $p ) {
		Perl6::Bareword.from-int(
			$p.from - VERSION-STR.chars,
			VERSION-STR ~ $p.Str
		)
	}

	method _vnum( Mu $p ) {
		my Perl6::Element @child;
		if $p.list {
			for $p.list {
				if $p.Int {
					Perl6::Number.from-match( $p )
				}
				else {
					debug-match( $_ ) if $*DEBUG;
					die "Unhandled case" if
						$*FACTORY-FAILURE-FATAL
				}
			}
		}
		else {
			debug-match( $p ) if $*DEBUG;
			die "Unhandled case" if
				$*FACTORY-FAILURE-FATAL
		}
		@child;
	}

	method _wu( Mu $p ) {
		Perl6::Bareword.from-match( $p )
	}

	method _xblock( Mu $p ) {
		my Perl6::Element @child;
		if $p.list {
			for $p.list {
				if self.assert-hash( $_, [< EXPR pblock >] ) {
					my $x = $_.Str.substr(
						0, $_.hash.<EXPR>.from
					);
					if $x ~~ m{ ('elsif') } {
						@child.append(
							Perl6::Bareword.from-int(
								$_.from + $0.from,
								$0.Str
							)
						);
					}
					@child.append(
						self._EXPR( $_.hash.<EXPR> )
					);
					@child.append(
						self._pblock(
							$_.hash.<pblock>
						)
					);
				}
				else {
					debug-match( $_ ) if $*DEBUG;
					die "Unhandled case" if
						$*FACTORY-FAILURE-FATAL
				}
			}
		}
		elsif self.assert-hash( $p, [< EXPR pblock >] ) {
			@child.append( self._EXPR( $p.hash.<EXPR> ) );
			@child.append( self._pblock( $p.hash.<pblock> ) );
		}
		elsif self.assert-hash( $p, [< blockoid >] ) {
			@child.append( self._blockoid( $p.hash.<blockoid> ) );
		}
		else {
			debug-match( $p ) if $*DEBUG;
			die "Unhandled case" if
				$*FACTORY-FAILURE-FATAL
		}
		@child;
	}
}
