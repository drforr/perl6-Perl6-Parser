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

=item L<Perl6::Sir-Not-Appearing-In-This-Statement>

By way of caveat: If you stick to the APIs mentioned in the documentation, you should never deal with objects in this class. Ever. If you see this, you're probably debugging internals of this module, and if you're not, please send the author a snippet of code B<and> the associated Perl 6 code that replicates it.

While you should stick to the published APIs, there are of course times when you need to get your proverbial hands dirty. Read on if you want the scoop.

Your humble author has gone to a great deal of trouble to assure that every character of user code is parsed and represented in some fashion, and the internals keep track of the text down to the by..chara...glyph level. More to the point, each Perl6::Tidy element has its own start and end point.

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

# Semicolons should only occur at statement boundaries.
# So they're only generated in the _statement handler.
#
class Perl6::Semicolon does Token {
	also is Perl6::Element;
}

class Perl6::Operator {
	also is Perl6::Element;
}
class Perl6::Operator::Prefix does Token {
	also is Perl6::Operator;

	multi method from-match( Mu $p ) {
		if $p.from < $p.to {
			self.bless(
				:from( $p.from ),
				:to( $p.to ),
				:content( $p.Str )
			)
		}
		else {
			( )
		}
	}

	multi method from-match-trimmed( Mu $p ) {
		$p.Str ~~ m{ ^ ( \s* ) ( .+? ) ( \s* ) $ };
		self.bless(
			:from( $p.from + ( $0.Str ?? $0.Str.chars !! 0 ) ),
			:to( $p.to - ( $2.Str ?? $2.Str.chars !! 0 ) ),
			:content( $1.Str )
		)
	}
}
class Perl6::Operator::Infix does Token {
	also is Perl6::Operator;
	method from-match( Mu $p ) {
		if $p.from < $p.to {
			self.bless(
				:from( $p.from ),
				:to( $p.to ),
				:content( $p.Str )
			)
		}
		else {
			( )
		}
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

	method from-match( Mu $p ) {
		if $p.from < $p.to {
			self.bless(
				:from( $p.from ),
				:to( $p.to ),
				:content( $p.Str )
			)
		}
		else {
			( )
		}
	}
}
class Perl6::Operator::Circumfix does Branching_Delimited does Bounded {
	also is Perl6::Operator;
	method from-match( Mu $p, @child ) {
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

	method from-match( Mu $p, @_child ) {
		if $p.from < $p.to {
			$p.Str ~~ m{ ^ (.) }; my Str $front = ~$0;
			$p.Str ~~ m{ (.) $ }; my Str $back = ~$0;
			self.bless(
				# XXX What is it "post"? Hmm.
				:from( $p.from ),
				:to( $p.to ),
				:delimiter( $front, $back ),
				:child( @_child )
			)
		}
		else {
			( )
		}
	}
}

class Perl6::WS does Token {
	also is Perl6::Element;

	constant COMMA = Q{,};

	multi method new( Int $start, $content ) {
		self.bless(
			:from( $start ),
			:to( $start + $content.chars ),
			:content( $content )
		)
	}

	method from-match( Mu $p ) {
		if $p.from < $p.to {
			self.bless(
				:from( $p.from ),
				:to( $p.to ),
				:content( $p.Str )
			)
		}
		else {
			( )
		}
	}

	multi method between-matches( Mu $p, Str $lhs, Str $rhs ) {
		my $_lhs = $p.hash.{$lhs};
		my $_rhs = $p.hash.{$rhs};
		if $_lhs.to < $_rhs.from {
			self.bless(
				:from( $_lhs.to ),
				:to( $_rhs.from ),
				:content(
					substr(
						$p.Str,
						$_lhs.to - $p.from,
						$_rhs.from - $_lhs.to
					)
				)
			)
		}
		else {
			()
		}
	}

	multi method between-matches( Mu $p, Mu $lhs, Mu $rhs ) {
		if $lhs.to < $rhs.from {
			self.bless(
				:from( $lhs.to ),
				:to( $rhs.from ),
				:content(
					substr(
						$p.Str,
						$lhs.to - $p.from,
						$rhs.from - $lhs.to
					)
				)
			)
		}
		else {
			()
		}
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

	method whitespace-header( Mu $p ) {
		if $p.Str ~~ m{ ( \s+ ) $ } {
			self.bless(
				:from( $p.from ),
				:to( $p.from + $0.Str.chars ),
				:content( $0.Str )
			)
		}
		else {
			()
		}
	}

	method whitespace-trailer( Mu $p ) {
		if $p.Str ~~ m{ ( \s+ ) $ } {
			self.bless(
				:from( $p.to - $0.Str.chars ),
				:to( $p.to ),
				:content( $0.Str )
			)
		}
		else {
			()
		}
	}

	method comma-separator( Int $offset, Str $split-me ) {
		my Perl6::Element @child;
		my Int $start = $offset;
		my ( $lhs, $rhs ) = split( COMMA, $split-me );
		if $lhs and $lhs ne '' {
			@child.append(
				Perl6::WS.new( $start, $lhs )
			);
			$start += $lhs.chars;
		}
		@child.append(
			Perl6::Operator::Infix.new( $start, COMMA )
		);
		$start += COMMA.chars;
		if $rhs and $rhs ne '' {
			@child.append(
				Perl6::WS.new( $start, $rhs )
			);
			$start += $rhs.chars;
		}
		@child.flat
	}

	# Returns the semicolon and preceding whitespace at the end of a
	# string if any.
	#
	method semicolon-terminator( Mu $p ) {
		my Perl6::Element @child;
		if $p.Str ~~ m{ ( \s+ ) ( ';' ) ( \s+ ) $ } {
			@child =
				self.bless(
					:from( $p.to - $2.chars - $1.chars - $0.chars ),
					:to( $p.to - $2.chars - $1.chars ),
					:content( $0.Str )
				),
				Perl6::Semicolon.new(
					:from( $p.to - $2.chars - $1.chars ),
					:to( $p.to - $2.chars ),
					:content( $1.Str )
				)
		}
		elsif $p.Str ~~ m{ ( ';' ) ( \s+ ) $ } {
			@child =
				Perl6::Semicolon.new(
					:from( $p.to - $1.chars - $0.chars ),
					:to( $p.to - $1.chars ),
					:content( $0.Str )
				)
		}
		elsif $p.Str ~~ m{ ( \s+ ) ( ';' ) $ } {
			@child =
				self.bless(
					:from( $p.to - $1.chars - $0.chars ),
					:to( $p.to - $1.chars ),
					:content( $0.Str )
				),
				Perl6::Semicolon.new(
					:from( $p.to - $1.chars ),
					:to( $p.to ),
					:content( $1.Str )
				)
		}
		elsif $p.Str ~~ m{ ( ';' ) $ } {
			@child =
				Perl6::Semicolon.new(
					:from( $p.to - $0.chars ),
					:to( $p.to  ),
					:content( $0.Str )
				)
		}
		else {
			@child = ( )
		}
		@child.flat
	}

	method with-header( Mu $p, *@element ) {
		my Perl6::Element @_child;
		@_child.append( Perl6::WS.whitespace-header( $p ) );
		@_child.append( @element );
		@_child
	}

	method with-header-trailer( Mu $p, *@element ) {
		my Perl6::Element @_child;
		@_child.append( Perl6::WS.whitespace-header( $p ) );
		@_child.append( @element );
		if $p.Str ~~ m{ \S \s+ $ } {
			@_child.append( Perl6::WS.whitespace-trailer( $p ) );
		}
		@_child
	}
}

class Perl6::Comment does Token {
	also is Perl6::Element;
}

class Perl6::Document does Branching does Bounded {
	also is Perl6::Element;
}

# If you have any curiosity about this, please search for /Sir-Not in the
# docs. This workaround may be gone by the time you read about this class,
# and if so, I'm glad.
#
class Perl6::Sir-Not-Appearing-In-This-Statement does Bounded {
	also is Perl6::Element;
	has $.content; # XXX because it's not quite a token.

	method perl6( $f ) {
		~$.content
	}
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
	method headless() {
		$.content ~~ m/ 0 <[bdox]> (.+) /;
		$0
	}
}

# And now for the most basic tokens...
#
class Perl6::Number does Token {
	also is Perl6::Element;
}
class Perl6::Number::Binary does Prefixed {
	also is Perl6::Number;

	method from-match( Mu $p ) {
		if $p.from < $p.to {
			self.bless(
				:from( $p.from ),
				:to( $p.to ),
				:content( $p.Str )
			)
		}
		else {
			( )
		}
	}
}
class Perl6::Number::Octal does Prefixed {
	also is Perl6::Number;

	method from-match( Mu $p ) {
		if $p.from < $p.to {
			self.bless(
				:from( $p.from ),
				:to( $p.to ),
				:content( $p.Str )
			)
		}
		else {
			( )
		}
	}
}
class Perl6::Number::Decimal {
	also is Perl6::Number;

	method from-match( Mu $p ) {
		if $p.from < $p.to {
			self.bless(
				:from( $p.from ),
				:to( $p.to ),
				:content( $p.Str )
			)
		}
		else {
			( )
		}
	}
}
class Perl6::Number::Decimal::Explicit does Prefixed {
	also is Perl6::Number::Decimal;
}
class Perl6::Number::Hexadecimal does Prefixed {
	also is Perl6::Number;

	method from-match( Mu $p ) {
		if $p.from < $p.to {
			self.bless(
				:from( $p.from ),
				:to( $p.to ),
				:content( $p.Str )
			)
		}
		else {
			( )
		}
	}
}
class Perl6::Number::Radix {
	also is Perl6::Number;
}
class Perl6::Number::Floating {
	also is Perl6::Number;

	method from-match( Mu $p ) {
		if $p.from < $p.to {
			self.bless(
				:from( $p.from ),
				:to( $p.to ),
				:content( $p.Str )
			)
		}
		else {
			( )
		}
	}
}

class Perl6::Regex does Token {
	also is Perl6::Element;
#	has Str $.bare; # Easier to grab it from the parser.

#	has $.q;
#	has @.delimiter;
#	has @.adverb;

	multi method from-match( Mu $p ) {
		if $p.from < $p.to {
			self.bless(
				:from( $p.from ),
				:to( $p.to ),
				:content( $p.Str )
			)
		}
		else {
			( )
		}
	}
}

class Perl6::String does Token {
	also is Perl6::Element;
#	has Str $.bare; # Easier to grab it from the parser.

#	has $.q;
	has @.delimiter;
#	has @.adverb;
}
class Perl6::String::Quote::Single does Token {
	also is Perl6::String;

	has Str @.delimiter = ( Q{'}, Q{'} );

	multi method from-match( Mu $p ) {
		if $p.from < $p.to {
			self.bless(
				:from( $p.from ),
				:to( $p.to ),
				:content( $p.Str )
			)
		}
		else {
			( )
		}
	}
}
class Perl6::String::Quote::Double does Token {
	also is Perl6::String;

	has Str @.delimiter = ( Q{"}, Q{"} );

	multi method from-match( Mu $p ) {
		if $p.from < $p.to {
			self.bless(
				:from( $p.from ),
				:to( $p.to ),
				:content( $p.Str )
			)
		}
		else {
			( )
		}
	}
}

class Perl6::Bareword does Token {
	also is Perl6::Element;
	multi method from-match( Mu $p ) {
		if $p.from < $p.to {
			self.bless(
				:from( $p.from ),
				:to( $p.to ),
				:content( $p.Str )
			)
		}
		else {
			( )
		}
	}

	multi method from-match-trimmed( Mu $p ) {
		if $p.from < $p.to {
			$p.Str ~~ m{ ^ ( \s* ) ( .+? ) ( \s* ) $ };
			self.bless(
				:from( $p.from + ( $0.Str ?? $0.Str.chars !! 0 ) ),
				:to( $p.to - ( $2.Str ?? $2.Str.chars !! 0 ) ),
				:content( $1.Str )
			)
		}
		else {
			( )
		}
	}
}
class Perl6::PackageName does Token {
	also is Perl6::Element;

	method from-match( Mu $p ) {
		if $p.from < $p.to {
			self.bless(
				:from( $p.from ),
				:to( $p.to ),
				:content( $p.Str )
			)
		}
		else {
			( )
		}
	}

	method namespaces() {
		$.content.split( '::' )
	}
}
class Perl6::ColonBareword does Token {
	also is Perl6::Bareword;

	method from-match( Mu $p ) {
		if $p.from < $p.to {
			self.bless(
				:from( $p.from ),
				:to( $p.to ),
				:content( $p.Str )
			)
		}
		else {
			( )
		}
	}
}
class Perl6::Block does Branching_Delimited does Bounded {
	also is Perl6::Element;

	method from-match( Mu $p, Perl6::Element @child ) {
		if $p.from < $p.to {
			$p.Str ~~ m{ ^ (.) }; my Str $front = ~$0;
			$p.Str ~~ m{ (.) $ }; my Str $back = ~$0;
			self.bless(
				:from( $p.from ),
				:to( $p.to ),
				:delimiter( $front, $back ),
				:child( @child )
			)
		}
		else {
			( )
		}
	}
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

	constant COLON = Q{:};
	constant SEMICOLON = Q{;};
	constant EQUAL = Q{=};
	constant WHERE = Q{where};
	constant QUES-QUES = Q{??};
	constant BANG-BANG = Q{!!};
	constant FATARROW = Q{=>};
	constant HYPER = Q{>>};

	has %.here-doc; # Text for here-docs, indexed by their $p.from.

	sub substr-match( Mu $p, Int $offset where * >= 0, Int $chars ) {
		substr(
			$p.Str,
			$offset - $p.from,
			$chars
		)
	}

	my class Here-Doc {
		has Int $.delimiter-start; # 'q:to[_FOO_]'
		has Int $.body-from; # 'Hello, world!\n_FOO_'
		has Int $.body-to; #  'Hello, world!\n_FOO_'
		has Str $.marker;
	}

	method __Build-Heredoc-List( Mu $p ) {
		%.here-doc = ();
		while $p.Str ~~ m:c{ ( 'q:to[' ) \s* ( <-[ \] ]>+ ) } {
			my $start = $0.from;
			my $marker = $1.Str;
			$p.Str ~~ m{ \s* ']' ( .*? $$ ) (.+?) ( $marker ) };
			%.here-doc{ $start } =
				Here-Doc.new(
					:delimiter-start( $start ),
					:body-from( $1.from ),
					:body-to( $1.to ),
					:marker( $marker )
				);
		}
	}

	method build( Mu $p ) {
		self.__Build-Heredoc-List( $p );
		my Perl6::Element @_child =
			self._statementlist( $p.hash.<statementlist> );
		if $p.hash.<statementlist>.hash.<statement>.list.elems == 1 and
		   @_child[*-1].child[*-1].to < $p.to {
			@_child[*-1].child.append(
				Perl6::Sir-Not-Appearing-In-This-Statement.new(
					:from( @_child[*-1].child[*-1].to ),
					:to( $p.to ),
					:content(
						$p.Str.substr(
							@_child[*-1].child[*-1].to
						);
					)
				)
			)
		}
		Perl6::Document.new(
			:from( @_child ?? @_child[0].from !! 0 ),
			:to( @_child ?? @_child[*-1].to !! 0 ),
			:child( @_child )
		)
	}

	sub key-bounds( Mu $p ) {
		say "{$p.from} {$p.to} [{substr($p.orig,$p.from,$p.to-$p.from)}]";
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
		my Perl6::Element @child;
		if $p.list {
			for $p.list {
				if self.assert-hash-keys( $_, [< EXPR >] ) {
					@child.append(
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
		@child
	}

	method _args( Mu $p ) {
		if self.assert-hash-keys( $p, [< invocant semiarglist >] ) {
			die "Not implemented yet";
		}
		elsif self.assert-hash-keys( $p, [< semiarglist >] ) {
			my Perl6::Element @_child;
			@_child.append(
				Perl6::WS.with-header-trailer(
					$p.hash.<semiarglist>,
					self._semiarglist(
						$p.hash.<semiarglist>
					)
				)
			);
			Perl6::Operator::Circumfix.from-match( $p, @_child )
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

	# { }
	# ?{ }
	# !{ }
	# var
	# name
	# ~~
	#
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
			Perl6::Bareword.from-match( $p )
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

	method _backmod( Mu $p ) {
		if self.assert-hash-keys( $p, [< backmod >] ) {
			$p.hash.<backmod>.Bool
		}
		else {
			say $p.hash.keys.gist;
			warn "Unhandled case"
		}
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

	method _binint( Mu $p ) {
		Perl6::Number::Binary.from-match( $p )
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
		my Perl6::Element @child;
		# $p doesn't contain WS after the block.
		if self.assert-hash-keys( $p, [< statementlist >] ) {
			my Perl6::Element @_child;
			@_child.append(
				self._statementlist(
					$p.hash.<statementlist>
				)
			);
			@child =
				Perl6::Block.from-match( $p, @_child )
		}
		else {
			say $p.hash.keys.gist;
			warn "Unhandled case"
		}
		@child
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
		my Perl6::Element @child;
		warn "Untested method";
		if $p.list {
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
		}
		else {
			say $p.hash.keys.gist;
			warn "Unhandled case"
		}
		@child
	}

	method _charspec( Mu $p ) {
		warn "Untested method";
# XXX work on this, of course.
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
		if self.assert-hash-keys( $p, [< binint VALUE >] ) {
			@child = self._binint( $p.hash.<binint> )
		}
		elsif self.assert-hash-keys( $p, [< octint VALUE >] ) {
			@child = self._octint( $p.hash.<octint> )
		}
		elsif self.assert-hash-keys( $p, [< decint VALUE >] ) {
			@child = self._decint( $p.hash.<decint> )
		}
		elsif self.assert-hash-keys( $p, [< hexint VALUE >] ) {
			@child = self._hexint( $p.hash.<hexint> )
		}
		elsif self.assert-hash-keys( $p, [< pblock >] ) {
			@child = self._pblock( $p.hash.<pblock> )
		}
		elsif self.assert-hash-keys( $p, [< semilist >] ) {
			my Perl6::Element @_child;
			@_child.append(
				self._semilist( $p.hash.<semilist> )
			);
			@child =
				Perl6::Operator::Circumfix.from-match(
					$p, @_child
				)
		}
		elsif self.assert-hash-keys( $p, [< nibble >] ) {
			my Perl6::Element @_child;
			@_child.append(
				Perl6::WS.with-header-trailer(
					$p.hash.<nibble>,
					Perl6::Operator::Prefix.from-match-trimmed(
						$p.hash.<nibble>
					)
				)
			);
			@child =
				Perl6::Operator::Circumfix.from-match(
					$p, @_child
				)
		}
		else {
			say $p.hash.keys.gist;
			warn "Unhandled case"
		}
		@child
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
		my Perl6::Element @child;
		if self.assert-hash-keys( $p,
				     [< identifier coloncircumfix >] ) {
			# Synthesize the 'from' marker for ':'
			@child =
				Perl6::Operator::Prefix.new(
					:from( $p.from ),
					:to( $p.from + COLON.chars ),
					:content( COLON )
				);
			@child.append(
				self._identifier( $p.hash.<identifier> )
			);
			@child.append(
				self._coloncircumfix(
					$p.hash.<coloncircumfix>
				)
			)
		}
		elsif self.assert-hash-keys( $p, [< coloncircumfix >] ) {
				# XXX Note that ':' is part of the expression.
			@child =
				Perl6::Operator::Prefix.new(
					:from( $p.from ),
					:to( $p.from + COLON.chars ),
					:content( COLON )
				);
			@child.append(
				self._coloncircumfix(
					$p.hash.<coloncircumfix>
				)
			)
		}
		elsif self.assert-hash-keys( $p, [< identifier >] ) {
			@child = Perl6::ColonBareword.from-match( $p )
		}
		elsif self.assert-hash-keys( $p, [< fakesignature >] ) {
			# XXX May not really be "post" in the P6 sense?
			my Perl6::Element @_child =
				self._fakesignature(
					$p.hash.<fakesignature>
				);
			# XXX properly match delimiter
			@child =
				Perl6::Operator::PostCircumfix.new(
					:from( $p.from ),
					:to( $p.to ),
					:delimiter( ':(', ')' ),
					:child( @_child )
				)
		}
		elsif self.assert-hash-keys( $p, [< var >] ) {
			# Synthesize the 'from' marker for ':'
			# XXX is this actually a single token?
			# XXX I think it is.
			@child =
				Perl6::Operator::Prefix.new(
					:from( $p.from ),
					:to( $p.from + COLON.chars ),
					:content( COLON )
				);
			@child.append(
				self._var( $p.hash.<var> )
			)
		}
		else {
			say $p.hash.keys.gist;
			warn "Unhandled case"
		}
		@child.flat
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
		Perl6::Number::Decimal.from-match( $p )
	}

	method _declarator( Mu $p ) {
		my Perl6::Element @child;
		if self.assert-hash-keys( $p,
				[< deftermnow initializer term_init >],
				[< trait >] ) {
			@child =
				self._variable_declarator(
					$p.hash.<variable_declarator>
				);
			@child.append(
				Perl6::WS.between-matches(
					$p,
					'variable_declarator',
					'initializer'
				)
			);
			@child.append(
				self._initializer( $p.hash.<initializer> )
			)
		}
		elsif self.assert-hash-keys( $p,
				[< sym defterm initializer >],
				[< trait >] ) {
			@child = self._sym( $p.hash.<sym> );
			@child.append(
				Perl6::WS.between-matches(
					$p,
					'sym',
					'defterm'
				)
			);
			@child.append(
				self._defterm( $p.hash.<defterm> )
			);
			@child.append(
				Perl6::WS.between-matches(
					$p,
					'defterm',
					'initializer'
				)
			);
			@child.append(
				self._initializer( $p.hash.<initializer> )
			)
		}
		elsif self.assert-hash-keys( $p,
				[< initializer signature >], [< trait >] ) {
			@child = self._signature( $p.hash.<signature> );
			@child.append(
				Perl6::WS.between-matches(
					$p,
					'signature',
					'initializer'
				)
			);
			@child.append(
				self._initializer( $p.hash.<initializer> )
			)
		}
		elsif self.assert-hash-keys( $p,
				  [< initializer variable_declarator >],
				  [< trait >] ) {
			@child =
				self._variable_declarator(
					$p.hash.<variable_declarator>
				);
			@child.append(
				Perl6::WS.between-matches(
					$p,
					'variable_declarator',
					'initializer'
				)
			);
			@child.append(
				self._initializer( $p.hash.<initializer> )
			)
		}
		elsif self.assert-hash-keys( $p,
				[< routine_declarator >], [< trait >] ) {
			@child =
				self._routine_declarator(
					$p.hash.<routine_declarator>
				)
		}
		elsif self.assert-hash-keys( $p,
				[< regex_declarator >], [< trait >] ) {
			@child =
				self._regex_declarator(
					$p.hash.<regex_declarator>
				)
		}
		elsif self.assert-hash-keys( $p,
				[< variable_declarator >], [< trait >] ) {
			@child =
				self._variable_declarator(
					$p.hash.<variable_declarator>
				)
		}
		elsif self.assert-hash-keys( $p,
				[< type_declarator >], [< trait >] ) {
			@child =
				self._type_declarator(
					$p.hash.<type_declarator>
				)
		}
		elsif self.assert-hash-keys( $p,
				[< signature >], [< trait >] ) {
			my Perl6::Element @_child =
				self._signature( $p.hash.<signature> );
			@child = Perl6::Operator::circumfix.new( $p, @_child )
		}
		else {
			say $p.hash.keys.gist;
			warn "Unhandled case"
		}
		@child
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
		elsif self.assert-hash-keys( $p, [< sym package_def >] ) {
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
			self._routine_declarator(
				$p.hash.<routine_declarator>
			)
		}
		elsif self.assert-hash-keys( $p, [< declarator >] ) {
			self._declarator( $p.hash.<declarator> )
		}
		elsif self.assert-hash-keys( $p,
				[< signature >], [< trait >] ) {
			self.signature( $p.hash.<signature> )
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
		my Perl6::Element @child;
		if $p.list {
			for $p.list {
				if self.assert-hash-keys( $_, [< EXPR >] ) {
					@child.append(
						self._EXPR( $_.hash.<EXPR> )
					)
				}
				else {
					say $_.hash.keys.gist;
					warn "Unhandled case"
				}
			}
		}
		else {
			say $p.hash.keys.gist;
			warn "Unhandled case"
		}
		@child.flat
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
		my Perl6::Element @child;
		if self.assert-hash-keys( $p, [< identifier colonpair >] ) {
			@child =
				self._identifier( $p.hash.<identifier> ),
				self._colonpair( $p.hash.<colonpair> ),
		}
		elsif self.assert-hash-keys( $p,
				[< identifier >],
				[< colonpair >] ) {
			@child = self._identifier( $p.hash.<identifier> )
		}
		else {
			say $p.hash.keys.gist;
			warn "Unhandled case"
		}
		@child
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
		if self.assert-hash-keys( $p, [< doc >] ) {
			$p.hash.<doc>.Bool
		}
		else {
			say $p.hash.keys.gist;
			warn "Unhandled case"
		}
	}

	# .
	# .*
	#
	method _dotty( Mu $p ) {
		my Perl6::Element @child;
		if self.assert-hash-keys( $p, [< sym dottyop O >] ) {
			@child =
				Perl6::Operator::Prefix.from-match(
					$p.hash.<sym>
				);
			@child.append(
				self._dottyop( $p.hash.<dottyop> ).flat
			)
		}
		else {
			say $p.hash.keys.gist;
			warn "Unhandled case"
		}
		@child
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
		my Perl6::Element @child;
		warn "Untested method";
		if self.assert-hash-keys( $p, [< sym blorst >] ) {
			@child = self._sym( $p.hash.<sym> );
			@child.append(
				Perl6::WS.between-matches(
					$p,
					'sym',
					'blorst'
				)
			);
			@child.append(
				self._blorst( $p.hash.<blorst> )
			)
		}
		elsif self.assert-hash-keys( $p, [< blockoid >] ) {
			@child = self._blockoid( $p.hash.<blockoid> )
		}
		else {
			say $p.hash.keys.gist;
			warn "Unhandled case"
		}
		@child
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
		warn "Untested method";
#		if self.assert-hash-keys( $p, [< sign decint >] ) {
#			die "Not implemented yet"
#		}
#		else {
			say $p.hash.keys.gist;
			warn "Unhandled case"
#		}
	}

	method __Term( Mu $p ) {
		my Perl6::Element @child;
		if self.assert-hash-keys( $p,
				[< postfix OPER >],
				[< postfix_prefix_meta_operator >] ) {
			@child = self.__Term( $p.list.[0] );
			@child.append(
				self._postfix( $p.hash.<postfix> )
			)
		}
		elsif self.assert-hash-keys( $p,
				[< identifier >], [< args >] ) {
			@child = self._identifier( $p.hash.<identifier> )
		}
		elsif self.assert-hash-keys( $p,
				[< longname >], [< args >] ) {
			@child = self._longname( $p.hash.<longname> )
		}
		elsif self.assert-hash-keys( $p, [< longname >] ) {
			@child = self._longname( $p.hash.<longname> )
		}
		elsif self.assert-hash-keys( $p, [< variable >] ) {
			@child = self._variable( $p.hash.<variable> )
		}
		elsif self.assert-hash-keys( $p, [< value >] ) {
			@child = self._value( $p.hash.<value> )
		}
		else {
			say $p.hash.keys.gist;
			warn "Unhandled case"
		}
		@child
	}

	method _EXPR( Mu $p ) {
		my Perl6::Element @child;
		if self.assert-hash-keys( $p,
				[< dotty OPER >],
				[< postfix_prefix_meta_operator >] ) {
			# XXX Look into this at some point.
			if substr-match( $p, $p.from, HYPER.chars ) eq HYPER {
				@child = self.__Term( $p.list.[0] );
				@child.append(
					# XXX note that '>>' is a substring
					Perl6::Operator::Prefix.new(
						:from( $p.from ),
						:to( $p.from + HYPER.chars ),
						:content( 
							substr( $p.orig, $p.from, HYPER.chars )
						)
					)
				);
				@child.append(
					self._dotty( $p.hash.<dotty> )
				)
			}
			else {
				@child = self.__Term( $p.list.[0] );
				@child.append(
					self._dotty( $p.hash.<dotty> )
				)
			}
		}
		elsif self.assert-hash-keys( $p,
				[< prefix OPER >],
				[< prefix_postfix_meta_operator >] ) {
			@child = self._prefix( $p.hash.<prefix> );
			@child.append(
				Perl6::WS.between-matches(
					$p,
					$p.hash.<prefix>,
					$p.list.[0].list.[0] // $p.list.[0]
				)
			);
			@child.append(
				self.__Term( $p.list.[0] )
			)
		}
		elsif self.assert-hash-keys( $p,
				[< postcircumfix OPER >],
				[< postfix_prefix_meta_operator >] ) {
			my Perl6::Element @_child;
			@_child.append(
				Perl6::WS.with-header-trailer(
					$p.hash.<postcircumfix>,
					self._postcircumfix(
						$p.hash.<postcircumfix>
					)
				)
			);
			@child = self.__Term( $p.list.[0] );
			@child.append(
				Perl6::Operator::PostCircumfix.from-match(
					$p.hash.<postcircumfix>,
					@_child
				)
			);
		}
		elsif self.assert-hash-keys( $p,
				[< postfix OPER >],
				[< postfix_prefix_meta_operator >] ) {
			@child = self.__Term( $p.list.[0] );
			@child.append(
				self._postfix( $p.hash.<postfix> )
			)
		}
		elsif self.assert-hash-keys( $p,
				[< infix_prefix_meta_operator OPER >] ) {
			@child = self.__Term( $p.list.[0] );
			@child.append(
				self._infix_prefix_meta_operator(
					$p.hash.<infix_prefix_meta_operator>
				),
			);
			@child.append(
				self.__Term( $p.list.[1] )
			)
		}
		# XXX ternary operators don't follow the string boundary rules
		# XXX $p.list.[0] is actually the start of the expression.
		elsif self.assert-hash-keys( $p, [< infix OPER >] ) {
			if $p.list.elems == 3 {
				@child = self.__Term( $p.list.[0] );
				@child.append(
					Perl6::Operator::Infix.new(
						$p, QUES-QUES
					)
				);
				@child.append(
					self.__Term( $p.list.[1] )
				);
				@child.append(
					Perl6::Operator::Infix.new(
						$p, BANG-BANG
					)
				);
				@child.append(
					self.__Term( $p.list.[2] )
				)
			}
			else {
				@child = self.__Term( $p.list.[0] );
				@child.append(
					self._infix( $p.hash.<infix> )
				);
				@child.append(
					self.__Term( $p.list.[1] )
				)
			}
		}
		elsif self.assert-hash-keys( $p, [< identifier args >] ) {
			@child = self._identifier( $p.hash.<identifier> );
			@child.append(
				self._args( $p.hash.<args> )
			)
		}
		elsif self.assert-hash-keys( $p, [< sym args >] ) {
			@child = 
				Perl6::Operator::Infix.from-match(
					$p.hash.<sym>
				)
		}
		elsif self.assert-hash-keys( $p, [< longname args >] ) {
			if $p.hash.<args> and
			   $p.hash.<args>.hash.<semiarglist> {
				@child = self._longname( $p.hash.<longname> );
				@child.append(
					self._args( $p.hash.<args> )
				)
			}
			else {
				@child = self._longname( $p.hash.<longname> )
			}
		}
		elsif self.assert-hash-keys( $p, [< circumfix >] ) {
			@child = self._circumfix( $p.hash.<circumfix> )
		}
		elsif self.assert-hash-keys( $p, [< dotty >] ) {
			@child = self._dotty( $p.hash.<dotty> )
		}
		elsif self.assert-hash-keys( $p, [< fatarrow >] ) {
			@child = self._fatarrow( $p.hash.<fatarrow> )
		}
		elsif self.assert-hash-keys( $p, [< multi_declarator >] ) {
			@child =
				self._multi_declarator(
					$p.hash.<multi_declarator>
				)
		}
		elsif self.assert-hash-keys( $p, [< regex_declarator >] ) {
			@child =
				self._regex_declarator(
					$p.hash.<regex_declarator>
				)
		}
		elsif self.assert-hash-keys( $p, [< routine_declarator >] ) {
			@child =
				self._routine_declarator(
					$p.hash.<routine_declarator>
				)
		}
		elsif self.assert-hash-keys( $p, [< scope_declarator >] ) {
			@child =
				self._scope_declarator(
					$p.hash.<scope_declarator>
				)
		}
		elsif self.assert-hash-keys( $p, [< type_declarator >] ) {
			@child =
				self._type_declarator(
					$p.hash.<type_declarator>
				)
		}

		# $p doesn't contain WS after the block.
		elsif self.assert-hash-keys( $p, [< package_declarator >] ) {
			@child =
				self._package_declarator(
					$p.hash.<package_declarator>
				)
		}
		elsif self.assert-hash-keys( $p, [< value >] ) {
			@child = self._value( $p.hash.<value> )
		}
		elsif self.assert-hash-keys( $p, [< variable >] ) {
			@child = self._variable( $p.hash.<variable> )
		}
		elsif self.assert-hash-keys( $p, [< colonpair >] ) {
			@child = self._colonpair( $p.hash.<colonpair> )
		}
		elsif self.assert-hash-keys( $p, [< longname >] ) {
			@child = self._longname( $p.hash.<longname> )
		}
		else {
			say $p.hash.keys.gist;
			warn "Unhandled case"
		}
		@child.flat
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
		my Perl6::Element @child;
		if self.assert-hash-keys( $p, [< key val >] ) {
			$p.Str ~~ m{ ('=>') };
			@child = self._key( $p.hash.<key> );
			if $p.hash.<key>.to < $0.from {
				@child.append(
					Perl6::WS.new(
						$p.hash.<key>.to,
						substr-match(
							$p,
							$p.hash.<key>.to,
							$0.from - $p.hash.<key>.to
						)
					)
				)
			}
			@child.append(
				Perl6::Operator::Infix.new( $p, FATARROW ),
			);
			if $0.to < $p.hash.<val>.from {
				@child.append(
					Perl6::WS.new(
						$0.to,
						substr-match(
							$p,
							$0.to,
							$p.hash.<val>.from - $0.to
						)
					)
				)
			}
			@child.append(
				self._val( $p.hash.<val> )
			);
		}
		else {
			say $p.hash.keys.gist;
			warn "Unhandled case"
		}
		@child
	}

	method __FloatingPoint( Mu $p ) {
		Perl6::Number::Floating.from-match( $p )
	}

	# XXX Unused
	method _hexint( Mu $p ) {
		Perl6::Number::Hexadecimal.from-match( $p )
	}

	method _identifier( Mu $p ) {
		my Perl6::Element @child;
		if $p.list {
			for $p.list {
				if self.assert-Str( $_ ) {
					die "Not implemented yet"
				}
				else {
					say $_.hash.keys.gist;
					warn "Unhandled case"
				}
			}
		}
		elsif $p.Str {
			@child = Perl6::Bareword.from-match( $p )
		}
		else {
			say $p.hash.keys.gist;
			warn "Unhandled case"
		}
		@child
	}

	method _infix( Mu $p ) {
		if self.assert-hash-keys( $p, [< infix OPER >] ) {
			die "Not implemented yet";
		}
		elsif self.assert-hash-keys( $p, [< sym O >] ) {
			Perl6::Operator::Infix.from-match( $p.hash.<sym> )
		}
		elsif self.assert-hash-keys( $p, [< EXPR O >] ) {
			Perl6::Operator::Infix.from-match( $p.hash.<EXPR> )
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

	# << >>
	# « »
	#
	method _infix_circumfix_meta_operator( Mu $p ) {
		if self.assert-hash-keys( $p, [< sym infixish O >] ) {
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
	# « »
	#
	method _infix_prefix_meta_operator( Mu $p ) {
		if self.assert-hash-keys( $p, [< sym infixish O >] ) {
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

	# =
	# :=
	# ::=
	# .=
	# .
	#
	method _initializer( Mu $p ) {
		my Perl6::Element @child;
		if self.assert-hash-keys( $p, [< dottyopish sym >] ) {
			die "Not implemented yet"
		}
		elsif self.assert-hash-keys( $p, [< sym EXPR >] ) {
			@child =
				Perl6::Operator::Infix.from-match(
					$p.hash.<sym>
				);
			if $p.hash.<EXPR>.list.[0] {
				@child.append(
					Perl6::WS.between-matches(
						$p,
						$p.hash.<sym>,
						$p.hash.<EXPR>.list.[0]
					)
				)
			}
			else {
				@child.append(
					Perl6::WS.between-matches(
						$p,
						'sym',
						'EXPR'
					)
				)
			}
			if $p.hash.<sym>.Str eq EQUAL and
				$p.hash.<EXPR>.list.elems == 2 {
				@child.append(
					self.__Term( $p.hash.<EXPR>.list.[0] )
				);
				@child.append(
					Perl6::WS.between-matches(
						$p,
						$p.hash.<EXPR>.list.[0],
						$p.hash.<EXPR>.hash.<infix>
					)
				);
				@child.append(
					self._infix(
						$p.hash.<EXPR>.hash.<infix>
					)
				);
				@child.append(
					Perl6::WS.between-matches(
						$p,
						$p.hash.<EXPR>.hash.<infix>,
						$p.hash.<EXPR>.list.[1]
					)
				);
				@child.append(
					self.__Term( $p.hash.<EXPR>.list.[1] )
				)
			}
			else {
				@child.append(
					self._EXPR( $p.hash.<EXPR> )
				)
			}
			if $p.hash.<EXPR>.to < $p.to and
			   %.here-doc.keys.elems > 0 {
				@child.append(
					Perl6::Sir-Not-Appearing-In-This-Statement.new(
						:from( $p.hash.<EXPR>.to ),
						:to( $p.to ),
						:content(
							$p.Str.substr(
								$p.hash.<EXPR>.to - $p.from
							);
						)
					)

				)
			}
		}
		else {
			say $p.hash.keys.gist;
			warn "Unhandled case"
		}
		@child.flat
	}

	method _integer( Mu $p ) {
		if self.assert-hash-keys( $p, [< binint VALUE >] ) {
			Perl6::Number::Binary.from-match( $p )
		}
		elsif self.assert-hash-keys( $p, [< octint VALUE >] ) {
			Perl6::Number::Octal.from-match( $p )
		}
		elsif self.assert-hash-keys( $p, [< decint VALUE >] ) {
			Perl6::Number::Decimal.from-match( $p )
		}
		elsif self.assert-hash-keys( $p, [< hexint VALUE >] ) {
			Perl6::Number::Hexadecimal.from-match( $p )
		}
		else {
			say $p.hash.keys.gist;
			warn "Unhandled case"
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
		Perl6::Bareword.from-match( $p )
	}

	method _lambda( Mu $p ) {
		if self.assert-hash-keys( $p, [< lambda >] ) {
			$p.hash.<lambda>.Str
		}
		else {
			say $p.hash.keys.gist;
			warn "Unhandled case"
		}
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
		if self.assert-hash-keys( $p, [< max >] ) {
			$p.hash.<max>.Str
		}
		else {
			say $p.hash.keys.gist;
			warn "Unhandled case"
		}
	}

	# :my
	# { }
	# qw
	# '
	#
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
		my Perl6::Element @child;
		if self.assert-hash-keys( $p,
			     [< specials longname blockoid multisig >],
			     [< trait >] ) {
			my Perl6::Element @_child =
				 self._multisig( $p.hash.<multisig> );
			@child =
				self._longname( $p.hash.<longname> ),
				Perl6::Operator::Circumfix.new(
					# XXX Verify from/to
					:from( $p.from ),
					:to( $p.to ),
					:delimiter( '(', ')' ),
					:child( @_child )
				),
				self._blockoid( $p.hash.<blockoid> )
		}
		elsif self.assert-hash-keys( $p,
			     [< specials longname blockoid >],
			     [< trait >] ) {
			@child = self._longname( $p.hash.<longname> );
			@child.append(
				Perl6::WS.between-matches(
					$p,
					'longname',
					'blockoid'
				)
			);
			@child.append(
				self._blockoid( $p.hash.<blockoid> )
			);
		}
		else {
			say $p.hash.keys.gist;
			warn "Unhandled case"
		}
		@child.flat
	}

	method _methodop( Mu $p ) {
		my Perl6::Element @child;
		if self.assert-hash-keys( $p, [< longname args >] ) {
			@child =
				self._longname( $p.hash.<longname> ),
				self._args( $p.hash.<args> )
		}
		elsif self.assert-hash-keys( $p, [< variable >] ) {
			@child = self._variable( $p.hash.<variable> )
		}
		elsif self.assert-hash-keys( $p, [< longname >] ) {
			@child = self._longname( $p.hash.<longname> )
		}
		else {
			say $p.hash.keys.gist;
			warn "Unhandled case"
		}
		@child
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
		my Perl6::Element @child;
		# XXX This probably needs further work.
		if $p.list {
			for $p.list {
				if self.assert-hash-keys( $p, [< identifier >] ) {
					@child.append(
						Perl6::PackageName.from-match(
							$_.hash.<identifier>
						)
					)
				}
			}
		}
		else {
			say $p.hash.keys.gist;
			warn "Unhandled case"
		}
		@child
	}

	# multi
	# proto
	# only
	# null
	#
	method _multi_declarator( Mu $p ) {
		my Perl6::Element @child;
		if self.assert-hash-keys( $p, [< sym routine_def >] ) {
			@child = self._sym( $p.hash.<sym> );
			@child.append(
				Perl6::WS.between-matches(
					$p,
					'sym',
					'routine_def'
				)
			);
			@child.append(
				self._routine_def( $p.hash.<routine_def> )
			)
		}
		elsif self.assert-hash-keys( $p, [< sym declarator >] ) {
			@child = self._sym( $p.hash.<sym> );
			@child.append(
				Perl6::WS.between-matches(
					$p,
					'sym',
					'declarator'
				)
			);
			@child.append(
				self._declarator( $p.hash.<declarator> )
			)
		}
		elsif self.assert-hash-keys( $p, [< declarator >] ) {
			@child = self._declarator( $p.hash.<declarator> )
		}
		else {
			say $p.hash.keys.gist;
			warn "Unhandled case"
		}
		@child
	}

	method _multisig( Mu $p ) {
		my Perl6::Element @child;
		if self.assert-hash-keys( $p, [< signature >] ) {
			@child = self._signature( $p.hash.<signature> );
			@child.append(
				Perl6::WS.whitespace-trailer(
					$p.hash.<signature>
				)
			)
		}
		else {
			say $p.hash.keys.gist;
			warn "Unhandled case"
		}
		@child
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
			Perl6::Bareword.from-match( $p )
		}
		elsif self.assert-hash-keys( $p, [< subshortname >] ) {
			die "Not implemented yet"
		}
		elsif self.assert-hash-keys( $p, [< morename >] ) {
			Perl6::PackageName.from-match( $p )
			#self._morename( $p.hash.<morename> )
		}
		elsif self.assert-Str( $p ) {
			Perl6::Bareword.from-match( $p )
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
		if self.assert-hash-keys( $p, [< normspace >] ) {
			$p.hash.<normspace>.Str
		}
		else {
			say $p.hash.keys.gist;
			warn "Unhandled case"
		}
	}

	method _noun( Mu $p ) {
		my Perl6::Element @child;
		if $p.list {
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
					@child.append(
						self._atom( $_.hash.<atom> )
					)
				}
				elsif self.assert-hash-keys( $_, [< atom >] ) {
					@child.append(
						self._atom( $_.hash.<atom> )
					)
				}
				else {
					say $_.hash.keys.gist;
					warn "Unhandled case"
				}
			}
		}
		else {
			say $p.hash.keys.gist;
			warn "Unhandled case"
		}
		@child
	}

	# numish # ?
	#
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
		Perl6::Number::Octal.from-match( $p )
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
				Perl6::Operator::Infix.from-match(
					$p.hash.<sym>
				),
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

	# ?{ }
	# ??{ }
	# var
	#
	method _p5metachar( Mu $p ) {
		my Perl6::Element @child;
		# $p doesn't contain WS after the block.
		if self.assert-hash-keys( $p, [< sym package_def >] ) {
			@child = self._sym( $p.hash.<sym> );
			@child.append(
				Perl6::WS.between-matches(
					$p,
					'sym',
					'package_def'
				)
			);
			@child.append(
				self._package_def( $p.hash.<package_def> )
			);
		}
		else {
			say $p.hash.keys.gist;
			warn "Unhandled case"
		}
		@child
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
			when self.assert-hash-keys( $_,
				[< sym package_def >] ) {
				@child = self._sym( $_.hash.<sym> );
				@child.append(
					Perl6::WS.between-matches(
						$_,
						'sym',
						'package_def'
					)
				);
				@child.append(
					self._package_def(
						$_.hash.<package_def>
					)
				)
			}
			when self.assert-hash-keys( $_, [< sym typename >] ) {
				@child = self._sym( $_.hash.<sym> );
				@child.append(
					Perl6::WS.between-matches(
						$_,
						'sym',
						'typename'
					)
				);
				@child.append(
					self._package_def( $_.hash.<typename> )
				)
			}
			when self.assert-hash-keys( $_, [< sym trait >] ) {
				@child = self._sym( $_.hash.<sym> );
				@child.append(
					Perl6::WS.between-matches(
						$_,
						'sym',
						'trait'
					)
				);
				@child.append(
					self._trait( $_.hash.<trait> )
				)
			}
			default {
				say $_.hash.keys.gist;
				warn "Unhandled case"
			}
		}
		@child
	}

	method _package_def( Mu $p ) {
		my Perl6::Element @child;
		given $p {
			when self.assert-hash-keys( $_,
				[< longname statementlist >], [< trait >] ) {
				@child = self._longname( $_.hash.<longname> );
				my $temp = substr(
					$_.Str,
					$_.hash.<longname>.to - $_.from
				);
				if $temp ~~ m{ ^ (\s+) (';')? } {
					@child.append(
						Perl6::WS.new(
							:from( $_.hash.<longname>.to ),
							:to( $_.hash.<longname>.to + $0.chars ),
							:content( $0.Str )
							
						)
					);
					if $1.chars {
						@child.append(
							Perl6::Semicolon.new(
								:from( $_.hash.<longname>.to + $0.chars ),
								:to( $_.hash.<longname>.to + $0.chars + $1.chars ),
								:content( $1.Str )
							)

						)
					}
				}
			}
			when self.assert-hash-keys( $_,
					[< longname >], [< colonpair >] ) {
				@child = self._longname( $_.hash.<longname> )
			}
			# $p doesn't contain WS after the block.
			when self.assert-hash-keys( $_,
					[< longname blockoid >], [< trait >] ) {
				@child = self._longname( $_.hash.<longname> );
				@child.append(
					Perl6::WS.between-matches(
						$_,
						'longname',
						'blockoid'
					)
				);
				@child.append(
					self._blockoid( $_.hash.<blockoid> )
				)
			}
			when self.assert-hash-keys( $_,
					[< blockoid >], [< trait >] ) {
				@child = self._blockoid( $_.hash.<blockoid> )
			}
			default {
				say $_.hash.keys.gist;
				warn "Unhandled case"
			}
		}
		@child.flat
	}

	method _parameter( Mu $p ) {
		my Perl6::Element @child;
		for $p.list {
			if self.assert-hash-keys( $_,
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
					Perl6::Bareword.new(
						:from( $p.from + $from ),
						:to(
							$p.from + $from +
							WHERE.chars
						),
						:content( WHERE )
					)
				);
				@child.append(
					self._post_constraint(
						$_.hash.<post_constraint>
					)
				)
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
				)
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
				)
			}
			elsif self.assert-hash-keys( $_,
				[< param_var quant >],
				[< default_value modifier trait
				   type_constraint
				   post_constraint >] ) {
				@child.append(
					self._param_var( $_.hash.<param_var> )#,
#					self._quant( $_.hash.<quant> )
				)
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
				)
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
			my Perl6::Element @_child =
				self._signature( $p.hash.<signature> );
			Perl6::Operator::Circumfix.new(
				:from( $p.from ),
				:to( $p.to ),
				:delimiter( '(', ')' ),
				:child( @_child )
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
		given $p {
			when self.assert-hash-keys( $_,
					[< lambda blockoid signature >] ) {
				die "Not implemented yet"
			}
			when self.assert-hash-keys( $_, [< blockoid >] ) {
				self._blockoid( $p.hash.<blockoid> )
			}
			default {
				say $_.hash.keys.gist;
				warn "Unhandled case"
			}
		}
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
		self._EXPR( $p.list.[0].hash.<EXPR> )
	}

	# block
	# text
	#
	method _pod_content( Mu $p ) {
		# XXX fix later
		self._EXPR( $p.list.[0].hash.<EXPR> )
	}

	# regular
	# code
	#
	method _pod_textcontent( Mu $p ) {
		# XXX fix later
		self._EXPR( $p.list.[0].hash.<EXPR> )
	}

	method _post_constraint( Mu $p ) {
		# XXX fix later
		self._EXPR( $p.list.[0].hash.<EXPR> )
	}

	# [ ]
	# { }
	# ang
	# « »
	# ( )
	#
	method _postcircumfix( Mu $p ) {
		my Perl6::Element @child;
		if self.assert-hash-keys( $p, [< arglist O >] ) {
			die "Not implemented yet"
		}
		elsif self.assert-hash-keys( $p, [< semilist O >] ) {
			if $p.Str ~~ m{ ^ (.) ( \s+ ) } {
				@child.append(
					Perl6::WS.new(
						:from( $p.from + $0.Str.chars ),
						:to( $p.from + $0.Str.chars + $1.Str.chars ),
						:content( $1.Str )
					)
				)
			}
			@child.append(
				Perl6::Bareword.from-match-trimmed(
					$p.hash.<semilist>
				)
			);
			if $p.hash.<semilist>.Str ~~ m{ \S ( \s+ ) $ } {
				@child.append(
					Perl6::WS.whitespace-trailer(
						$p.hash.<semilist>
					)
				)
			}
		}
		elsif self.assert-hash-keys( $p, [< nibble O >] ) {
			if $p.Str ~~ m{ ^ (.) ( \s+ ) ( .+ ) ( \s+ ) (.) $ } {
				@child.append(
					Perl6::WS.new(
						:from( $p.from + $0.Str.chars ),
						:to( $p.from + $0.Str.chars + $1.Str.chars ),
						:content( $1.Str )
					)
				);
				@child.append(
					Perl6::Bareword.new(
						:from( $p.from + $0.Str.chars + $1.Str.chars ),
						:to( $p.to - $4.Str.chars - $3.Str.chars ),
						:content( $2.Str )
					)
				);
				@child.append(
					Perl6::WS.new(
						:from( $p.to - $4.Str.chars - $3.Str.chars ),
						:to( $p.to - $4.Str.chars ),
						:content( $1.Str )
					)
				)
			}
			else {
				if $p.hash.<nibble>.Str ~~ m{ ^ ( \S ) ( \s+ ) } {
					@child.append(
						Perl6::WS.new(
							:from( $p.hash.<nibble>.from + $0.Str.chars ),
							:to( $p.hash.<nibble>.from + $0.Str.chars + $1.Str.chars ),
							:content( $1.Str )
						)
					)
				}
				@child.append(
					Perl6::Bareword.from-match-trimmed(
						$p.hash.<nibble>
					)
				);
				if $p.hash.<nibble>.Str ~~ m{ \S ( \s+ ) ( \S ) $ } {
					@child.append(
						Perl6::WS.whitespace-trailer(
							$p.hash.<nibble>
						)
					)
				}
			}
		}
		else {
			say $p.hash.keys.gist;
			warn "Unhandled case"
		}
		@child
	}

	# ⁿ
	#
	method _postfix( Mu $p ) {
		my Perl6::Element @child;
		given $p {
			when self.assert-hash-keys( $_, [< sym O >] ) {
				@child =
					Perl6::Operator::Postfix.from-match(
						$_.hash.<sym>
					);
			}
			when self.assert-hash-keys( $_, [< dig O >] ) {
				@child =
					Perl6::Operator::Postfix.from-match(
						$_.hash.<dig>
					)
			}
			default {
				say $_.hash.keys.gist;
				warn "Unhandled case"
			}
		}
		@child
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
		my Perl6::Element @child;
		given $p {
			when self.assert-hash-keys( $_, [< sym O >] ) {
				@child =
					Perl6::Operator::Prefix.from-match(
						$_.hash.<sym>
					);
				@child.append(
					Perl6::WS.whitespace-trailer(
						$_
					)
				)
			}
			default {
				say $_.hash.keys.gist;
				warn "Unhandled case"
			}
		}
		@child.flat
	}

	method _quant( Mu $p ) {
		if self.assert-hash-keys( $p, [< quant >] ) {
			$p.hash.<quant>.Bool
		}
		else {
			say $p.hash.keys.gist;
			warn "Unhandled case"
		}
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

	# **
	# rakvar
	#
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
		if self.assert-hash-keys( $p, [< sym quibble rx_adverbs >] ) {
			die "Not implemented yet"
		}
		elsif self.assert-hash-keys( $p, [< sym rx_adverbs sibble >] ) {
			die "Not implemented yet"
		}
		elsif self.assert-hash-keys( $p, [< quibble >] ) {
			my $leader = $p.Str.substr(
				0,
				$p.hash.<quibble>.hash.<nibble>.from - $p.from
			);

			my Bool ( $has-q, $has-to ) = False, False;
			$has-q = True if $leader ~~ m{ ':q' };
			$has-to = True if $leader ~~ m{ ':to' };

			my $trailer = $p.Str.substr(
				$p.hash.<quibble>.hash.<nibble>.to - $p.from
			);
			my $content = $p.Str;
			if $has-to {
				my ( $content, $marker ) =
					%.here-doc{ $p.from };
				$content = $content;
			}
			$leader ~~ m{ ( . ) $ };
			my @adverb;
			@adverb.append( ':q' ) if $has-q;
			@adverb.append( ':to' ) if $has-to;

			Perl6::String.new(
				:from( $p.from ),
				:to( $p.to ),
				:delimiter( $0.Str, $trailer ),
				:adverb( @adverb ),
				:content( $content )
			)
		}
		elsif self.assert-hash-keys( $p, [< nibble >] ) {
			$p.Str ~~ m{ ^ (.) .*? (.) $ };
			given $0.Str {
				when Q{'} {
					Perl6::String::Quote::Single.from-match(
						$p
					)
				}
				when Q{"} {
					Perl6::String::Quote::Double.from-match(
						$p
					)
				}
				when Q{/} {
					# XXX Need to pass delimiters in
					Perl6::Regex.from-match( $p )
				}
				default {
					# XXX
					die "Unknown delimiter '{$0.Str}'"
				}
			}
		}
		else {
			say $p.hash.keys.gist;
			warn "Unhandled case"
		}
	}

	method _quotepair( Mu $p ) {
		my Perl6::Element @child;
		warn "Untested method";
		if $p.list {
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
		}
		elsif self.assert-hash-keys( $p,
				[< circumfix bracket radix >],
				[< exp base >] ) {
			die "Not implemented yet"
		}
		elsif self.assert-hash-keys( $p, [< identifier >] ) {
			@child = self._identifier( $p.hash.<identifier> )
		}
		else {
			say $p.hash.keys.gist;
			warn "Unhandled case"
		}
		@child
	}

	method _radix( Mu $p ) {
		if self.assert-hash-keys( $p, [< radix >] ) {
			$p.hash.<radix>.Int
		}
		else {
			say $p.hash.keys.gist;
			warn "Unhandled case"
		}
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
		my Perl6::Element @child;
		if self.assert-hash-keys( $p, [< sym regex_def >] ) {
			@child = self._sym( $p.hash.<sym> );
			@child.append(
				Perl6::WS.between-matches(
					$p,
					'sym',
					'regex_def'
				)
			);
			@child.append(
				self._regex_def( $p.hash.<regex_def> )
			)
		}
		else {
			say $p.hash.keys.gist;
			warn "Unhandled case"
		}
		@child
	}

	method _regex_def( Mu $p ) {
		my Perl6::Element @child;
		if self.assert-hash-keys( $p,
				[< deflongname nibble >],
				[< signature trait >] ) {
			my Perl6::Element @_child;
			my $x = $p.Str.substr(
				0, $p.hash.<nibble>.from - $p.from
			);
			if $x ~~ m{ ( \s+ ) $ } {
				@_child.append(
					Perl6::WS.new(
						:from( $p.hash.<nibble>.from - $0.Str.chars ),
						:to( $p.hash.<nibble>.from ),
						:content( $0.Str )
					)
				)
			}
			@_child.append(
				self._nibble( $p.hash.<nibble> )
			);
			@_child.append(
				Perl6::WS.whitespace-trailer(
					$p.hash.<nibble>
				)
			);
			@child = self._deflongname( $p.hash.<deflongname> );
			my $remainder = substr( $p.Str, $p.hash.<deflongname>.Str.chars );
			my $inset = 0;
			if $remainder ~~ m{ ^ ( \s+ ) } {
				$inset = $0.chars;
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
						$inset
					),
					:to( $p.to ),
					:delimiter( '{', '}' ),
					:child( @_child )
				)
			);
		}
		else {
			say $p.hash.keys.gist;
			warn "Unhandled case"
		}
		@child
	}

	method _right( Mu $p ) {
		if self.assert-hash-keys( $p, [< right >] ) {
			$p.hash.<right>.Bool
		}
		else {
			say $p.hash.keys.gist;
			warn "Unhandled case"
		}
	}

	# sub <name> ... { },
	# method <name> ... { },
	# submethod <name> ... { },
	# macro <name> ... { }, # XXX ?
	#
	method _routine_declarator( Mu $p ) {
		my Perl6::Element @child;
		if self.assert-hash-keys( $p,
			[< sym routine_def >] ) {
			@child = self._sym( $p.hash.<sym> );
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
			)
		}
		elsif self.assert-hash-keys( $p, [< sym method_def >] ) {
			@child = self._sym( $p.hash.<sym> );
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
			)
		}
		else {
			say $p.hash.keys.gist;
			warn "Unhandled case"
		}
		@child.flat
	}

	method _routine_def( Mu $p ) {
		my Perl6::Element @child;
		if self.assert-hash-keys( $p,
				[< deflongname multisig blockoid >],
				[< trait >] ) {
			my Perl6::Element @_child;
			@_child.append(
				self._multisig( $p.hash.<multisig> )
			);
			my Str $x = substr-match(
				$p,
				$p.from,
				$p.hash.<blockoid>.from - $p.from
			);
			my Int $offset = 0;
			if $x {
				$x ~~ m{ ')' (.*) $ }; $offset = $0.chars;
			}
			@child.append(
				self._deflongname( $p.hash.<deflongname> )
			);
			# XXX Why...
			my Str $strip-sides =
				substr-match(
					$p,
					$p.hash.<deflongname>.to,
					$p.hash.<blockoid>.from -
					$p.hash.<deflongname>.to
				);
			if $strip-sides ~~ m{ '(' ( \s+ ) ')' } {
				@_child.append(
					Perl6::WS.new(
						:from( $p.hash.<deflongname>.to + $0.from ),
						:to( $p.hash.<deflongname>.to + $0.from + $0.chars ),
						:content( $0.Str )
					)
				)
			}
			elsif $strip-sides ~~ m{ '(' ( \s+ ) } {
				@_child.splice( 0, 0,
					Perl6::WS.new(
						:from( $p.hash.<deflongname>.to + $0.from ),
						:to( $p.hash.<deflongname>.to + $0.from + $0.chars ),
						:content( $0.Str )
					)
				)
			}
			elsif $strip-sides ~~ m{ ( \s+ ) ')' } {
				@_child.append(
					Perl6::WS.new(
						:from( $p.hash.<deflongname>.to + $0.from ),
						:to( $p.hash.<deflongname>.to + $0.from + $0.chars ),
						:content( $0.Str )
					)
				)
			}
			@child.append(
				Perl6::Operator::Circumfix.new(
					:from( $p.hash.<deflongname>.to ),
					:to(
						$p.hash.<blockoid>.from -
						$offset
					),
					:delimiter( '(', ')' ),
					:child( @_child )
				),
			);
			my Str $collect-ws = substr(
				$p.Str, 0, $p.hash.<blockoid>.from - $p.from
			);
			if $collect-ws ~~ m{ ( \s+ ) $ } {
				@child.append(
					Perl6::WS.new(
						:from( @child[*-1].to ),
						:to( @child[*-1].to + $0.chars ),
						:content( $0.Str )
					)
				)
			}
			@child.append(
				self._blockoid( $p.hash.<blockoid> )
			)
		}
		elsif self.assert-hash-keys( $p,
				[< deflongname statementlist >],
				[< trait >] ) {
			@child =
				self._deflongname(
					$p.hash.<deflongname>
				);
			@child.append(
				Perl6::WS.semicolon-terminator( $p )
			)
		}
		elsif self.assert-hash-keys( $p,
				[< deflongname trait blockoid >] ) {
			@child =
				self._deflongname(
					$p.hash.<deflongname>
				);
			@child.append(
				Perl6::WS.between-matches(
					$p,
					$p.hash.<deflongname>,
					$p.hash.<trait>.list.[0],
				)
			);
			@child.append(
				self._trait( $p.hash.<trait> )
			);
			@child.append(
				Perl6::WS.whitespace-trailer(
					$p.hash.<trait>.list.[0]
				)
			);
			@child.append(
				self._blockoid( $p.hash.<blockoid> )
			)
		}
		elsif self.assert-hash-keys( $p,
				[< blockoid multisig >], [< trait >] ) {
			my Perl6::Element @_child =
				self._multisig( $p.hash.<multisig> );
			@child =
				Perl6::Operator::Circumfix.new(
					:delimiter( '(', ')' ),
					:child( @_child )
				);
			@child.append(
				Perl6::WS.between-matches(
					$p,
					'multisig',
					'blockoid',
				)
			);
			@child.append(
				self._blockoid( $p.hash.<blockoid> )
			)
		}
		elsif self.assert-hash-keys( $p,
				[< deflongname blockoid >],
				[< trait >] ) {
			@child =
				self._deflongname(
					$p.hash.<deflongname>
				);
			@child.append(
				Perl6::WS.between-matches(
					$p,
					'deflongname',
					'blockoid',
				)
			);
			@child.append(
				self._blockoid( $p.hash.<blockoid> )
			)
		}
		elsif self.assert-hash-keys( $p,
				[< blockoid >], [< trait >] ) {
			@child = self._blockoid( $p.hash.<blockoid> )
		}
		else {
			say $p.hash.keys.gist;
			warn "Unhandled case"
		}
		@child.flat
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
		my Perl6::Element @child;
		# XXX DECL seems to be a mirror of declarator. This probably
		# XXX will turn out to be not true later on.
		#
		if self.assert-hash-keys( $p,
				[< multi_declarator DECL typename >] ) {
			@child = self._typename( $p.hash.<typename> );
			@child.append(
				Perl6::WS.between-matches(
					$p,
					'typename',
					'multi_declarator'
				)
			);
			@child.append(
				self._multi_declarator(
					$p.hash.<multi_declarator>
				)
			)
		}
		elsif self.assert-hash-keys( $p,
				[< package_declarator DECL >],
				[< typename >] ) {
			@child =
				self._package_declarator(
					$p.hash.<package_declarator>
				)
		}
		elsif self.assert-hash-keys( $p,
				[< sym package_declarator >] ) {
			@child = self._sym( $p.hash.<sym> );
			@child.append(
				Perl6::WS.between-matches(
					$p,
					'sym',
					'package_declarator'
				)
			);
			@child.append(
				self._package_declarator(
					$p.hash.<package_declarator>
				)
			)
		}
		elsif self.assert-hash-keys( $p,
				[< declarator DECL >], [< typename >] ) {
			@child = self._declarator( $p.hash.<declarator> )
		}
		else {
			say $p.hash.keys.gist;
			warn "Unhandled case"
		}
		@child.flat
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
		if self.assert-hash-keys( $p, [< sym scoped >] ) {
			@child = self._sym( $p.hash.<sym> );
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
			)
		}
		else {
			say $p.hash.keys.gist;
			warn "Unhandled case"
		}
		@child.flat
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
		my Perl6::Element @child;
		if self.assert-hash-keys( $p, [< statement >] ) {
			@child.append(
				Perl6::WS.whitespace-header(
					$p
				)
			);
			@child.append(
				self._statement( $p.hash.<statement> )
			);
			@child.append(
				Perl6::WS.whitespace-trailer(
					$p
				)
			)
		}
		elsif self.assert-hash-keys( $p, [ ], [< statement >] ) {
			@child.append(
				Perl6::WS.from-match(
					$p
				)
			)
		}
		else {
			say $p.hash.keys.gist;
			warn "Unhandled case"
		}
		@child
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
		if self.assert-hash-keys( $p, [< septype >] ) {
			$p.hash.<septype>.Str
		}
		else {
			say $p.hash.keys.gist;
			warn "Unhandled case"
		}
	}

	method _shape( Mu $p ) {
		if self.assert-hash-keys( $p, [< shape >] ) {
			$p.hash.<shape>.Str
		}
		else {
			say $p.hash.keys.gist;
			warn "Unhandled case"
		}
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
		if self.assert-hash-keys( $p, [< sym >] ) {
			$p.hash.<sym>.Str
		}
		else {
			say $p.hash.keys.gist;
			warn "Unhandled case"
		}
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
			
			# XXX revisit later
			if $p.hash.<type_constraint>.list.[*-1].Str ~~ m{ (\s+) $ } {
				@child.append(
					Perl6::WS.new(
						$p.hash.<type_constraint>.list.[*-1].to - $0.chars,
						$0.Str
					)
				)
			}
			@child.append(
				self._param_var( $p.hash.<param_var> )
			);
			# XXX revisit this later
			if $p.Str ~~ m{ (\s+) ('where') } {
				@child.append(
					Perl6::WS.new(
						$p.hash.<param_var>.to,
						~$0
					)
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
				@child.append(
					Perl6::WS.new( $p.from + $0.to, ~$1 )
				)
			}
			@child.append(
				self._post_constraint(
					$p.hash.<post_constraint>
				)
			)
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
				@child.append(
					Perl6::WS.new( $p.from + $0.from, ~$0 )
				)
			}
			@child.append(
				self._param_var( $p.hash.<param_var> )
			);
			if $p.hash.<default_value> {
				if $p.Str ~~ m{ ( \s* ) ('=') ( \s* ) } {
					if $0 and $0.Str.chars {
						@child.append(
							Perl6::WS.new(
								:from( $p.from ),
								:to( $p.from + $0.Str.chars ),
								:content( $0.Str )
							)
						);
					}
					@child.append(
						Perl6::Operator::Infix.new(
							:from( $p.from + $1.from ),
							:to( $p.from + $1.to ),
							:content( $1.Str )
						)
					);
					if $2 and $2.Str.chars {
						@child.append(
							Perl6::WS.new(
								:from( $p.from + $2.from ),
								:to( $p.from + $2.to ),
								:content( $2.Str )
							)
						);
					}
					@child.append(
						self._EXPR( $p.hash.<default_value>.list.[0].hash.<EXPR> )
					);
				}
			}
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
					Perl6::WS.new(
						$p.hash.<param_var>.to,
						~$0
					)
				)
			}
			@child.append(
				Perl6::Operator::Infix.new( $p, EQUAL )
			);
			if $p.Str ~~ m{ ('=') (\s+) } {
				@child.append(
					Perl6::WS.new( $p.from + $0.to, ~$1 )
				)
			}
			@child.append(
				self._default_value(
					$p.hash.<default_value>
				).flat
			)
		}
		elsif self.assert-hash-keys( $p,
			[< param_var quant >],
			[< default_value modifier trait
			   type_constraint
			   post_constraint >] ) {
			@child.append(
				self._param_var( $p.hash.<param_var> )#,
#					self._quant( $p.hash.<quant> )
			)
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
			)
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
		my Perl6::Element @child;
		if self.assert-hash-keys( $p,
				[< parameter typename >],
				[< param_sep >] ) {
			@child.append(
				self._typename( $p.hash.<typename> )
			);
			@child.append(
				self._parameter( $p.hash.<parameter> )
			)
		}
		elsif self.assert-hash-keys( $p,
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
					@child.append(
						Perl6::WS.comma-separator(
							$start,
							$str
						)
					)
				}
				@child.append(
					self.__Parameter( $_ )
				)
			}
		}
		elsif self.assert-hash-keys( $p,
				[< param_sep >],
				[< parameter >] ) {
			@child = self._parameter( $p.hash.<parameter> )
		}
		elsif self.assert-hash-keys( $p, [< >],
				[< param_sep parameter >] ) {
			@child = ( )
		}
		else {
			say $p.hash.keys.gist;
			warn "Unhandled case"
		}
		@child.flat
	}

	method _smexpr( Mu $p ) {
		if self.assert-hash-keys( $p, [< EXPR >] ) {
			self._EXPR( $p.hash.<EXPR> )
		}
		else {
			say $p.hash.keys.gist;
			warn "Unhandled case"
		}
	}

	method _specials( Mu $p ) {
		if self.assert-hash-keys( $p, [< specials >] ) {
			$p.hash.<specials>.Bool
		}
		else {
			say $p.hash.keys.gist;
			warn "Unhandled case"
		}
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
		my Perl6::Element @child;
		if $p.list {
			for $p.list {
				if self.assert-hash-keys( $_,
						[< EXPR
						   statement_mod_loop >] ) {
					@child.append(
						self._EXPR( $_.hash.<EXPR> )
					);
					@child.append(
						Perl6::WS.between-matches(
							$_,
							'EXPR',
							'statement_mod_loop'
						)
					);
					@child.append(
						self._statement_mod_loop(
							$_.hash.<statement_mod_loop>
						)
					)
				}
				elsif self.assert-hash-keys( $_,
						[< statement_mod_cond
						   EXPR >] ) {
					die "Not implemented yet"
				}
				elsif self.assert-hash-keys( $_,
						[< EXPR >] ) {
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
						[< statement_control >] ) {
					die "Not implemented yet"
				}
				else {
					say $_.hash.keys.gist;
					warn "Unhandled case"
				}
			}
		}
		elsif self.assert-hash-keys( $p,
				[< EXPR statement_mod_loop >] ) {
			@child = self._EXPR( $p.hash.<EXPR> );
			@child.append(
				Perl6::WS.between-matches(
					$p,
					'EXPR',
					'statement_mod_loop'
				)
			);
			@child.append(
				self._statement_mod_loop(
					$p.hash.<statement_mod_loop>
				)
			)
		}
		elsif self.assert-hash-keys( $p, [< sym trait >] ) {
			@child = self._sym( $p.hash.<sym> );
			@child.append(
				self._trait( $p.hash.<trait> )
			)
		}
		# $p contains trailing whitespace for <package_declaration>
		# This *should* be handled in _statementlist
		#
		elsif self.assert-hash-keys( $p, [< EXPR >] ) {
			# XXX Sigh, need to handle *this* where we have the
			# XXX proper matching string available.
			if $p.hash.<EXPR>.hash.<infix> {
				if $p.hash.<EXPR>.list.elems == 3 and
					$p.hash.<EXPR>.hash.<infix> and
					$p.hash.<EXPR>.hash.<OPER> {
					@child = self.__Term(
						$p.hash.<EXPR>.list.[0]
					);
					@child.append(
						Perl6::WS.between-matches(
							$p,
							$p.hash.<EXPR>.list.[0],
							$p.hash.<EXPR>.hash.<infix>
						)
					);
					@child.append(
						Perl6::Operator::Infix.new(
#							$p.hash.<EXPR>, QUES-QUES
							:from( $p.hash.<EXPR>.hash.<infix>.from ),
							:to( $p.hash.<EXPR>.hash.<infix>.from + QUES-QUES.chars ),
							:content( QUES-QUES )
						)
					);
					if $p.hash.<EXPR>.hash.<infix>.Str ~~ m{ '??' ( \s+ ) } {
						@child.append(
							Perl6::WS.new(
								:from( $p.hash.<EXPR>.hash.<infix>.from + QUES-QUES.chars ),
								:to( $p.hash.<EXPR>.hash.<infix>.from + QUES-QUES.chars + $0.Str.chars ),
								:content( $0.Str )
								
							)
						)
					}
					@child.append(
						self.__Term( $p.hash.<EXPR>.list.[1] )
					);
					if $p.hash.<EXPR>.hash.<infix>.Str ~~ m{ ( \s+ ) '!!' } {
						@child.append(
							Perl6::WS.new(
								:from( $p.hash.<EXPR>.hash.<infix>.to - BANG-BANG.chars - $0.Str.chars ),
								:to( $p.hash.<EXPR>.hash.<infix>.to - BANG-BANG.chars ),
								:content( $0.Str )
								
							)
						)
					}
					@child.append(
						Perl6::Operator::Infix.new(
							$p.hash.<EXPR>, BANG-BANG
						)
					);
					@child.append(
						Perl6::WS.between-matches(
							$p,
							$p.hash.<EXPR>.hash.<OPER>,
							$p.hash.<EXPR>.list.[2]
						)
					);
					@child.append(
						self.__Term( $p.hash.<EXPR>.list.[2] )
					)
				}
				else {
					my $q = $p.hash.<EXPR>;
					@child = self.__Term( $q.list.[0] );
					@child.append(
						Perl6::WS.between-matches(
							$p,
							$q.list.[0],
							$q.hash.<infix>
						)
					);
					@child.append(
						self._infix( $q.hash.<infix> )
					);
					@child.append(
						Perl6::WS.between-matches(
							$p,
							$q.hash.<infix>,
							$q.list.[1]
						)
					);
					@child.append(
						self.__Term( $q.list.[1] )
					)
				}
			}
			else {
				@child = self._EXPR( $p.hash.<EXPR> );
			}
		}
		elsif self.assert-hash-keys( $p, [< statement_control >] ) {
			@child =
				self._statement_control(
					$p.hash.<statement_control>
				).flat;
		}
		elsif !$p.hash.keys {
			note "Fix null case"
		}
		else {
			say $p.hash.keys.gist;
			warn "Unhandled case"
		}
		@child
	}

	method _statementlist( Mu $p ) {
		my Perl6::Element @child;
		my $leftover-ws;
		my $leftover-ws-from = 0;
		my $beginning-ws;
		my $beginning-comment;

		# XXX Must fix this at some point.
		my regex comment-eol { \s* '#' .+ $$ };
		my regex comment-balanced { \s* '#`(' .+ ')' };
		my regex comment {
			<comment-eol> |
			<comment-balanced>
		}

		if $p.Str ~~ m{ ^ ( \s+ ) } {
			$beginning-ws = $0.Str
		}
		elsif $p.Str ~~ m{ ^ ( <comment>+ ) } {
			$beginning-comment = $0.Str
		}
		for $p.hash.<statement>.list {
			my Perl6::Element @_child;
			if $beginning-ws {
				@_child.append(
					Perl6::WS.new(
						:from( 0 ),
						:to( $beginning-ws.chars ),
						:content( $beginning-ws )
					)
				);
				$beginning-ws = Nil;
			}
			if $beginning-comment {
				@_child.append(
					Perl6::Comment.new(
						:from( 0 ),
						:to( $beginning-comment.chars ),
						:content( $beginning-comment )
					)
				);
				$beginning-ws = Nil;
			}
			if $leftover-ws {
				@_child.append(
					Perl6::WS.new(
						:from( $leftover-ws-from ),
						:to(
							$leftover-ws-from +
							$leftover-ws.chars
						),
						:content( $leftover-ws )
					)
				);
				$leftover-ws = Nil;
				$leftover-ws-from = 0
			}
			@_child.append(
				self._statement( $_ )
			);
			# Do *NOT* remove this, use it to replace whatever
			# WS trailing terms the grammar below might add
			# redundantly.
			#
			if $_.Str ~~ m{ (';') (\s+) $ } {
				$leftover-ws = $1.Str;
				$leftover-ws-from = 
					@_child[*-1].to +
					SEMICOLON.chars;
			}
			else {
				@_child.append(
					Perl6::WS.whitespace-trailer( $_ )
				);
			}
			my $temp = substr(
				$p.Str,
				@_child[*-1].to - $p.from
			);
			if $temp ~~ m{ ^ (';') (\s+) } {
				$leftover-ws = $1.Str;
				$leftover-ws-from = 
					@_child[*-1].to +
					SEMICOLON.chars;
				@_child.append(
					Perl6::Semicolon.new(
						:from( @_child[*-1].to ),
						:to(
							@_child[*-1].to +
							SEMICOLON.chars
						),
						:content( $0.Str )
					)
				)
			}
			elsif $temp ~~ m{ ^ (';') } {
				@_child.append(
					Perl6::Semicolon.new(
						:from( @_child[*-1].to ),
						:to(
							@_child[*-1].to +
							SEMICOLON.chars
						),
						:content( $0.Str )
					)
				)
			}
			@child.append(
				Perl6::Statement.from-list( @_child )
			)
		}
		if $leftover-ws {
			my Perl6::Element @_child =
				Perl6::WS.new(
					:from( $leftover-ws-from ),
					:to(
						$leftover-ws-from +
						$leftover-ws.chars
					),
					:content( $leftover-ws )
				);
			@child.append(
				Perl6::Statement.from-list( @_child )
			)
		}
		elsif !$p.hash.<statement> and $p.Str ~~ m{ . } {
			my Perl6::Element @_child =
				Perl6::WS.from-match( $p );
			@child.append(
				Perl6::Statement.from-list( @_child )
			)
		}
		@child
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
		warn "Untested method";
		if self.assert-hash-keys( $p, [< sym modifier_expr >] ) {
			die "Not implemented yet"
		}
		else {
			say $p.hash.keys.gist;
			warn "Unhandled case"
		}
	}

	# while
	# until
	# for
	# given
	#
	method _statement_mod_loop( Mu $p ) {
		my Perl6::Element @child;
		if self.assert-hash-keys( $p, [< sym smexpr >] ) {
			@child = self._sym( $p.hash.<sym> );
			@child.append(
				Perl6::WS.between-matches(
					$p,
					'sym',
					'smexpr'
				)
			);
			@child.append(
				self._smexpr( $p.hash.<smexpr> )
			)
		}
		else {
			say $p.hash.keys.gist;
			warn "Unhandled case"
		}
		@child
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
		my Perl6::Element @child;
		if $p.list {
			for $p.list {
				if $_.Str {
					die "Not implemented yet"
				}
				else {
					say $_.hash.keys.gist;
					warn "Unhandled case"
				}
			}
		}
		elsif $p.Str {
			@child = Perl6::Bareword.from-match( $p )
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
		@child
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
		if self.assert-hash-keys( $p, [< circumfix >] ) {
			@child = self._circumfix( $p.hash.<circumfix> )
		}
		elsif self.assert-hash-keys( $p, [< name >], [< colonpair >] ) {
			@child = self._name( $p.hash.<name> );
		}
		else {
			say $p.hash.keys.gist;
			warn "Unhandled case"
		}
		@child
	}

	method _termalt( Mu $p ) {
		my Perl6::Element @child;
		if $p.list {
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
		}
		else {
			say $p.hash.keys.gist;
			warn "Unhandled case"
		}
		@child
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
		my Perl6::Element @child;
		CATCH { when X::Hash::Store::OddNumber { .resume } } # XXX ?...
		if $p.list {
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
		}
		else {
			say $p.hash.keys.gist;
			warn "Unhandled case"
		}
		@child
	}

	method _termconjseq( Mu $p ) {
		my Perl6::Element @child;
		# XXX Work on this later.
		if $p.list {
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
		}
		elsif self.assert-hash-keys( $p, [< termalt >] ) {
			@child = self._termalt( $p.hash.<termalt> )
		}
		elsif $p.Str {
			# XXX
			my Str $str = $p.Str;
			$str ~~ s{\s+ $} = '';
			@child =
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
		@child
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
		my Perl6::Element @child;
		if $p.list {
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
		}
		elsif self.assert-hash-keys( $p, [< noun >] ) {
			@child = self._noun( $p.hash.<noun> )
		}
		else {
			say $p.hash.keys.gist;
			warn "Unhandled case"
		}
		@child
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
		my Perl6::Element @child;
		if $p.list {
			for $p.list {
				@child.append(
					self._trait_mod( $_.hash.<trait_mod> )
				)
			}
		}
		else {
			say $p.hash.keys.gist;
			warn "Unhandled case"
		}
		@child
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
		if self.assert-hash-keys( $p,
				[< sym longname >],
				[< circumfix >] ) {
			@child = self._sym( $p.hash.<sym> );
			@child.append(
				Perl6::WS.between-matches(
					$p,
					'sym',
					'longname'
				)
			);
			@child.append(
				self._longname( $p.hash.<longname> )
			)
		}
		elsif self.assert-hash-keys( $p, [< sym typename >] ) {
			@child = self._sym( $p.hash.<sym> );
			@child.append(
				Perl6::WS.between-matches(
					$p,
					'sym',
					'typename'
				)
			);
			@child.append(
				self._typename( $p.hash.<typename> )
			)
		}
		else {
			say $p.hash.keys.gist;
			warn "Unhandled case"
		}
		@child
	}

	method _twigi( Mu $p ) {
		if self.assert-hash-keys( $p, [< sym >] ) {
			$p.hash.<sym>.Str
		}
		else {
			say $p.hash.keys.gist;
			warn "Unhandled case"
		}
	}

	method _type_constraint( Mu $p ) {
		my Perl6::Element @child;
		if $p.list {
			for $p.list {
				if self.assert-hash-keys( $_,
						[< typename >] ) {
					@child.append(
						self._typename(
							$_.hash.<typename>
						)
					)
				}
				elsif self.assert-hash-keys( $_,
						[< value >] ) {
					@child.append(
						self._value(
							$_.hash.<value>
						)
					)
				}
				else {
					say $_.hash.keys.gist;
					warn "Unhandled case"
				}
			}
		}
		elsif self.assert-hash-keys( $p, [< value >] ) {
			self._value( $p.hash.<value> )
		}
		elsif self.assert-hash-keys( $p, [< typename >] ) {
			self._typename( $p.hash.<typename> )
		}
		else {
			say $p.hash.keys.gist;
			warn "Unhandled case"
		}
		@child
	}

	# enum
	# subset
	# constant
	#
	method _type_declarator( Mu $p ) {
		my Perl6::Element @child;
		if self.assert-hash-keys( $p,
				[< sym defterm initializer >], [< trait >] ) {
			@child = self._sym( $p.hash.<sym> );
			@child.append(
				Perl6::WS.between-matches(
					$p,
					'sym',
					'defterm'
				)
			);
			@child.append(
				self._defterm( $p.hash.<defterm> )
			);
			@child.append(
				Perl6::WS.between-matches(
					$p,
					'defterm',
					'initializer'
				)
			);
			@child.append(
				self._initializer( $p.hash.<initializer> )
			);
		}
		elsif self.assert-hash-keys( $p,
				[< sym longname term >], [< trait >] ) {
			@child = self._sym( $p.hash.<sym> );
			@child.append(
				Perl6::WS.between-matches(
					$p,
					'sym',
					'longname'
				)
			);
			@child.append(
				self._longname( $p.hash.<longname> )
			);
			@child.append(
				Perl6::WS.between-matches(
					$p,
					'longname',
					'term'
				)
			);
			@child.append(
				self._term( $p.hash.<term> )
			)
		}
		elsif self.assert-hash-keys( $p,
				[< sym longname trait >] ) {
			@child = self._sym( $p.hash.<sym> );
			@child.append(
				Perl6::WS.between-matches(
					$p,
					'sym',
					'longname'
				)
			);
			@child.append(
				self._longname( $p.hash.<longname> )
			);
			@child.append(
				Perl6::WS.between-matches(
					$p,
					'longname',
					'trait'
				)
			);
			@child.append(
				self._trait( $p.hash.<trait> )
			)
		}
		elsif self.assert-hash-keys( $p,
				[< sym longname >], [< trait >] ) {
			@child = self._sym( $p.hash.<sym> );
			@child.append(
				Perl6::WS.between-matches(
					$p,
					'sym',
					'longname'
				)
			);
			@child.append(
				self._longname( $p.hash.<longname> )
			)
		}
		else {
			say $p.hash.keys.gist;
			warn "Unhandled case"
		}
		@child
	}

	method _typename( Mu $p ) {
		CATCH {
			when X::Hash::Store::OddNumber { .resume }
		} # XXX ?...
		for $p.list {
			if self.assert-hash-keys( $_,
					[< longname colonpairs >],
					[< colonpair >] ) {
				# XXX Probably could be narrowed.
				return Perl6::Bareword.from-match( $_ )
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
				return Perl6::Bareword.from-match( $_ )
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

	# quote
	# number
	# version
	#
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
		my Perl6::Element @child;
		if self.assert-hash-keys( $p,
			[< semilist variable shape >],
			[< postcircumfix signature trait
			   post_constraint >] ) {
			die "Not implemented yet"
		}
		elsif self.assert-hash-keys( $p,
				[< variable post_constraint >],
				[< semilist postcircumfix
				   signature trait >] ) {
			# Synthesize the 'from' and 'to' markers for 'where'
			$p.Str ~~ m{ (\s*) (where) (\s*) };
			my Int $from = $0.from;
			@child = self._variable( $p.hash.<variable> );
			if $0.Str {
				@child.append(
					Perl6::WS.new(
						:from( $p.from + $0.from ),
						:to( $p.from + $0.to ),
						:content( $0.Str )
					)
				)
			}
			@child.append(
				Perl6::Bareword.new(
					:from( $p.from + $1.from ),
					:to( $p.from + $1.from + 5 ),
					:content( WHERE )
				)
			);
			if $2.Str {
				@child.append(
					Perl6::WS.new(
						:from( $p.from + $2.from ),
						:to( $p.from + $2.to ),
						:content( $2.Str )
					)
				)
			}
			@child.append(
				self._post_constraint(
					$p.hash.<post_constraint>
				)
			)
		}
		elsif self.assert-hash-keys( $p,
				[< variable >],
				[< semilist postcircumfix signature
				   trait post_constraint >] ) {
			@child = self._variable( $p.hash.<variable> )
		}
		else {
			say $p.hash.keys.gist;
			warn "Unhandled case"
		}
		@child.flat
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
		if self.assert-hash-keys( $p, [< vstr >] ) {
			$p.hash.<vstr>.Int
		}
		else {
			say $p.hash.keys.gist;
			warn "Unhandled case"
		}
	}

	method _vnum( Mu $p ) {
		my Perl6::Element @child;
		warn "Untested method";
		if $p.list {
			for $p.list {
				if self.assert-Int( $_ ) {
					die "Not implemented yet";
				}
				else {
					say $_.hash.keys.gist;
					warn "Unhandled case"
				}
			}
		}
		else {
			say $p.hash.keys.gist;
			warn "Unhandled case"
		}
		@child
	}

	method _wu( Mu $p ) {
		if self.assert-hash-keys( $p, [< wu >] ) {
			$p.hash.<wu>.Str
		}
		else {
			say $p.hash.keys.gist;
			warn "Unhandled case"
		}
	}

	method _xblock( Mu $p ) {
		my Perl6::Element @child;
		warn "Untested method";
		if $p.list {
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
		}
		elsif self.assert-hash-keys( $p, [< pblock EXPR >] ) {
			die "Not implemented yet";
		}
		elsif self.assert-hash-keys( $p, [< blockoid >] ) {
			@child = self._blockoid( $p.hash.<blockoid> )
		}
		else {
			say $p.hash.keys.gist;
			warn "Unhandled case"
		}
		@child
	}
}
