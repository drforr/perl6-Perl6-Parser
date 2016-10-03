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
	has $.factory-line-number; # Purely a debugging aid.
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

class Perl6::Structural {
	also is Perl6::Element;
}

# Semicolons should only occur at statement boundaries.
# So they're only generated in the _statement handler.
#
class Perl6::Semicolon does Token {
	also is Perl6::Structural;
}

# Generic balanced character
class Perl6::Balanced {
	also is Perl6::Structural;
}
class Perl6::Balanced::Enter does Token {
	also is Perl6::Balanced;
}
class Perl6::Balanced::Exit does Token {
	also is Perl6::Balanced;
}

class Perl6::Operator {
	also is Perl6::Element;
}
class Perl6::Operator::Prefix does Token {
	also is Perl6::Operator;

	multi method from-match( Mu $p ) {
		if $p.from < $p.to {
			self.bless(
				:factory-line-number( callframe(1).line ),
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
			:factory-line-number( callframe(1).line ),
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
				:factory-line-number( callframe(1).line ),
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
			:factory-line-number( callframe(1).line ),
			:from( $from ),
			:to( $from + $str.chars ),
			:content( $str )
		)
	}
	multi method new( Mu $p, Str $token ) {
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

	method from-match( Mu $p ) {
		if $p.from < $p.to {
			self.bless(
				:factory-line-number( callframe(1).line ),
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
class Perl6::Operator::Circumfix does Branching does Bounded {
	also is Perl6::Operator;
	method from-match( Mu $p, @child ) {
		my Perl6::Element @_child;
		$p.Str ~~ m{ ^ (.) }; my Str $front = ~$0;
		$p.Str ~~ m{ (.) $ }; my Str $back = ~$0;
		@_child.append(
			Perl6::Balanced::Enter.new(
				:factory-line-number( callframe(1).line ),
				:from( $p.from ),
				:to( $p.from + $front.chars ),
				:content( $front )
			)
		);
		@_child.append( @child );
		@_child.append(
			Perl6::Balanced::Exit.new(
				:factory-line-number( callframe(1).line ),
				:from( $p.to - $back.chars ),
				:to( $p.to ),
				:content( $back )
			)
		);
		self.bless(
			:factory-line-number( callframe(1).line ),
			:from( $p.from ),
			:to( $p.to ),
			:child( @_child )
		)
	}

	method from-from-to-XXX( Int $from, Int $to, Str $front, Str $back, @child ) {
		if $from < $to {
			my Perl6::Element @_child;
			@_child.append(
				Perl6::Balanced::Enter.new(
					:factory-line-number( callframe(1).line ),
					:from( $from ),
					:to( $from + $front.chars ),
					:content( $front )
				)
			);
			@_child.append( @child );
			@_child.append(
				Perl6::Balanced::Exit.new(
					:factory-line-number( callframe(1).line ),
					:from( $to - $back.chars ),
					:to( $to ),
					:content( $back )
				)
			);
			self.bless(
				:factory-line-number( callframe(1).line ),
				:from( $from ),
				:to( $to ),
				:child( @_child )
			)
		}
		else {
			( )
		}
	}
}
class Perl6::Operator::PostCircumfix does Branching does Bounded {
	also is Perl6::Operator;

	method from-match( Mu $p, @child ) {
		if $p.from < $p.to {
			my Perl6::Element @_child;
			$p.Str ~~ m{ ^ (.) }; my Str $front = ~$0;
			$p.Str ~~ m{ (.) $ }; my Str $back = ~$0;
			@_child.append(
				Perl6::Balanced::Enter.new(
					:factory-line-number( callframe(1).line ),
					:from( $p.from ),
					:to( $p.from + $front.chars ),
					:content( $front )
				)
			);
			@_child.append( @child );
			@_child.append(
				Perl6::Balanced::Exit.new(
					:factory-line-number( callframe(1).line ),
					:from( $p.to - $back.chars ),
					:to( $p.to ),
					:content( $back )
				)
			);
			self.bless(
				:factory-line-number( callframe(1).line ),
				:from( $p.from ),
				:to( $p.to ),
				:child( @_child )
			)
		}
		else {
			( )
		}
	}

	method from-delims( Mu $p, Str $front, Str $back, @child ) {
		if $p.from < $p.to {
			my Perl6::Element @_child;
			@_child.append(
				Perl6::Balanced::Enter.new(
					:factory-line-number( callframe(1).line ),
					:from( $p.from ),
					:to( $p.from + $front.chars ),
					:content( $front )
				)
			);
			@_child.append( @child );
			@_child.append(
				Perl6::Balanced::Exit.new(
					:factory-line-number( callframe(1).line ),
					:from( $p.to - $back.chars ),
					:to( $p.to ),
					:content( $back )
				)
			);
			self.bless(
				:factory-line-number( callframe(1).line ),
				:from( $p.from ),
				:to( $p.to ),
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

	# Returns a WS token starting at character $start, consisting of
	# $content.chars characters.
	#
	# If there is no whitespace, returns () which is treated as a
	# nonexistent array element by append().
	#
	multi method new( Int $start, $content ) {
		if $content {
			self.bless(
				:factory-line-number( callframe(1).line ),
				:from( $start ),
				:to( $start + $content.chars ),
				:content( $content )
			)
		}
		else {
			self.bless(
				:factory-line-number( callframe(1).line ),
				:from( $start ),
				:to( $start + $content.chars ),
				:content( '' )
			)
		}
	}

	# Returns a WS token consisting entirely of a given match $m
	#
	# If there is no whitespace, returns () which is treated as a
	# nonexistent array element by append().
	#
	method from-match( Mu $m ) {
		if $m.from < $m.to {
			self.bless(
				:factory-line-number( callframe(1).line ),
				:from( $m.from ),
				:to( $m.to ),
				:content( $m.Str )
			)
		}
		else {
			( )
		}
	}

	# Returns a WS token starting at the end of match $m.hash.{$lhs},
	# extending to the start of match $m.hash.{$rhs}.
	# (uses the whitespace in match $m)
	#
	# If there is no whitespace, returns () which is treated as a
	# nonexistent array element by append().
	#
	multi method between-matches( Mu $m, Str $lhs, Str $rhs ) {
		my $_lhs = $m.hash.{$lhs};
		my $_rhs = $m.hash.{$rhs};
		if $_lhs.to < $_rhs.from {
			self.bless(
				:factory-line-number( callframe(1).line ),
				:from( $_lhs.to ),
				:to( $_rhs.from ),
				:content(
					substr(
						$m.orig,
						$_lhs.to,
						$_rhs.from - $_lhs.to
					)
				)
			)
		}
		else {
			()
		}
	}

	# The same as above, but instead of $m.hash.{$lhs}, $lhs and $rhs are
	# the actual matches.
	#
	# If there is no whitespace, returns () which is treated as a
	# nonexistent array element by append().
	#
	multi method between-matches( Mu $m, Mu $lhs, Mu $rhs ) {
		if $lhs.to < $rhs.from {
			self.bless(
				:factory-line-number( callframe(1).line ),
				:from( $lhs.to ),
				:to( $rhs.from ),
				:content(
					substr(
						$m.orig,
						$lhs.to,
						$rhs.from - $lhs.to
					)
				)
			)
		}
		else {
			()
		}
	}
	multi method between-matches-orig( Mu $lhs, Mu $rhs ) {
		if $lhs.to < $rhs.from {
			self.bless(
				:factory-line-number( callframe(1).line ),
				:from( $lhs.to ),
				:to( $rhs.from ),
				:content(
					substr(
						$lhs.orig,
						$lhs.to,
						$rhs.from - $lhs.to
					)
				)
			)
		}
		else {
			()
		}
	}

	# Returns a WS token starting at the beginning of match $m, extending
	# to the start of match $rhs.
	#
	# If there is no whitespace, returns () which is treated as a
	# nonexistent array element by append().
	#
	method leader( Mu $m, Mu $rhs ) {
		if $m.from < $rhs.from {
			self.bless(
				:factory-line-number( callframe(1).line ),
				:from( $m.from ),
				:to( $rhs.from ),
				:content(
					substr(
						$m.Str,
						0,
						$rhs.from - $m.from
					)
				)
			)
		}
		else {
			()
		}
	}

	# Returns a WS token starting at the end of match $lhs, extending to
	# the end of match $m.
	#
	# If there is no whitespace, returns () which is treated as a
	# nonexistent array element by append().
	#
	method terminator( Mu $p, Mu $lhs ) {
		if $lhs.to < $p.to {
			self.bless(
				:factory-line-number( callframe(1).line ),
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

	# Returns a WS token starting at the beginning of match $m, extending
	# to the first non-whitespace character (or the end of the match.)
	#
	# If there is no whitespace, returns () which is treated as a
	# nonexistent array element by append().
	#
	method header( Mu $m ) {
		if $m.Str ~~ m{ ^ ( \s+ ) } {
			self.bless(
				:factory-line-number( callframe(1).line ),
				:from( $m.from ),
				:to( $m.from + $0.Str.chars ),
				:content( $0.Str )
			)
		}
		else {
			()
		}
	}

	# Returns a WS token starting at the start of the last WS in the match
	# $m, extending to the end of the string.
	#
	# If there is no whitespace, returns () which is treated as a
	# nonexistent array element by append().
	#
	method trailer( Mu $p ) {
		if $p.Str ~~ m{ ( \s+ ) $ } {
			self.bless(
				:factory-line-number( callframe(1).line ),
				:from( $p.to - $0.Str.chars ),
				:to( $p.to ),
				:content( $0.Str )
			)
		}
		else {
			()
		}
	}

	# Returns a sequence of (maybe WS), (,), (maybe WS) given the string
	# $split-me. $offset is the offset from the start of the entire
	# match, since we don't pass in the match object.
	#
	# XXX Really should be rethought.
	#
	# If there is no whitespace, returns () which is treated as a
	# nonexistent array element by append().
	#
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

	# Returns (maybe WS), (;), (maybe WS) at thee end of match.
	# XXX This can definitely be trimmed down.
	#
	# If there is no whitespace, returns () which is treated as a
	# nonexistent array element by append().
	#
	method semicolon-terminator( Mu $m ) {
		my Perl6::Element @child;
		if $m.Str ~~ m{ ( \s+ ) ( ';' ) ( \s+ ) $ } {
			@child =
				self.bless(
					:factory-line-number( callframe(1).line ),
					:from( $m.to - $2.chars - $1.chars - $0.chars ),
					:to( $m.to - $2.chars - $1.chars ),
					:content( $0.Str )
				),
				Perl6::Semicolon.new(
					:factory-line-number( callframe(1).line ),
					:from( $m.to - $2.chars - $1.chars ),
					:to( $m.to - $2.chars ),
					:content( $1.Str )
				)
		}
		elsif $m.Str ~~ m{ ( ';' ) ( \s+ ) $ } {
			@child =
				Perl6::Semicolon.new(
					:factory-line-number( callframe(1).line ),
					:from( $m.to - $1.chars - $0.chars ),
					:to( $m.to - $1.chars ),
					:content( $0.Str )
				)
		}
		elsif $m.Str ~~ m{ ( \s+ ) ( ';' ) $ } {
			@child =
				self.bless(
					:factory-line-number( callframe(1).line ),
					:from( $m.to - $1.chars - $0.chars ),
					:to( $m.to - $1.chars ),
					:content( $0.Str )
				),
				Perl6::Semicolon.new(
					:factory-line-number( callframe(1).line ),
					:from( $m.to - $1.chars ),
					:to( $m.to ),
					:content( $1.Str )
				)
		}
		elsif $m.Str ~~ m{ ( ';' ) $ } {
			@child =
				Perl6::Semicolon.new(
					:factory-line-number( callframe(1).line ),
					:from( $m.to - $0.chars ),
					:to( $m.to  ),
					:content( $0.Str )
				)
		}
		else {
			@child = ( )
		}
		@child.flat
	}

	# Returns the header WS at the start of match $m, followed by
	# whatever tokens are passed in.
	#
	# This really is a splice() operation, and may be rethought.
	# Of course the real issue is wanting to keep immutability.
	#
	# If there is no whitespace, returns () which is treated as a
	# nonexistent array element by append().
	#
	method with-header( Mu $p, *@element ) {
		my Perl6::Element @_child;
		@_child.append( Perl6::WS.header( $p ) );
		@_child.append( @element );
		@_child
	}

	# Returns whatever tokens are passed in, followed by the trailer WS.
	#
	# This really is a splice() operation, and may be rethought.
	# Of course the real issue is wanting to keep immutability.
	#
	# If there is no whitespace, returns () which is treated as a
	# nonexistent array element by append().
	#
	method with-trailer( Mu $p, *@element ) {
		my Perl6::Element @_child;
		@_child.append( @element );
		@_child.append( Perl6::WS.trailer( $p ) );
		@_child
	}

	# Returns the header WS at the start of $m, whatever tokens there
	# happen to be in the string, then the trailer WS.
	#
	# Like its predecessor, it is just a splice() and will be rethought.
	#
	# If there is no whitespace, returns () which is treated as a
	# nonexistent array element by append().
	#
	method with-header-trailer( Mu $p, *@element ) {
		my Perl6::Element @_child;
		@_child.append( Perl6::WS.header( $p ) );
		@_child.append( @element );
		if $p.Str ~~ m{ \S \s+ $ } {
			@_child.append( Perl6::WS.trailer( $p ) );
		}
		@_child
	}

	# Return tokes before a WS, the WS itself, and the tokens after a WS.
	# Here $start and $end are the names of the hash keys inside $p.
	#
	# If there is no whitespace, returns () which is treated as a
	# nonexistent array element by append().
	#
	multi method with-inter-ws( Mu $p,
				Str $start, $start-list,
				Str $end, $end-list ) {
		my Perl6::Element @_child;
		@_child.append( @( $start-list ) );
		@_child.append( Perl6::WS.between-matches( $p, $start, $end ) );
		@_child.append( @( $end-list ) );
		@_child
	}

	# Return tokes before a WS, the WS itself, and the tokens after a WS.
	# Here $start and $end are the match objects at the start and end of
	# the main match $p.
	#
	# If there is no whitespace, returns () which is treated as a
	# nonexistent array element by append().
	#
	multi method with-inter-ws( Mu $p,
				Mu $start, $start-list,
				Mu $end, $end-list ) {
		my Perl6::Element @_child;
		@_child.append( @( $start-list ) );
		@_child.append( Perl6::WS.between-matches( $p, $start, $end ) );
		@_child.append( @( $end-list ) );
		@_child
	}

	# Returns a WS token consisting of the whitespace before the start of
	# match object $lhs.
	#
	# If there is no whitespace, returns () which is treated as a
	# nonexistent array element by append().
	#
	method before( Mu $p, Mu $lhs ) {
		my $x = $p.Str.substr( 0, $lhs.from - $p.from );
		if $x ~~ m{ ( \s+ ) $ } {
			self.bless(
				:factory-line-number( callframe(1).line ),
				:from( $lhs.from - $0.Str.chars ),
				:to( $lhs.from ),
				:content( $0.Str )
			)
		}
		else {
			()
		}
	}
	method before-orig( Mu $lhs ) {
		my $x = $lhs.orig.substr( 0, $lhs.from );
		if $x ~~ m{ ( \s+ ) $ } {
			self.bless(
				:factory-line-number( callframe(1).line ),
				:from( $lhs.from - $0.Str.chars ),
				:to( $lhs.from ),
				:content( $0.Str )
			)
		}
		else {
			()
		}
	}

	# Returns a WS token consisting of the whitespace after the end of
	# match object $lhs.
	#
	# If there is no whitespace, returns () which is treated as a
	# nonexistent array element by append().
	#
	method after( Mu $p, Mu $lhs ) {
		my $x = $p.Str.substr( $lhs.to - $p.from );
		if $x ~~ m{ ^ ( \s+ ) } {
			self.bless(
				:factory-line-number( callframe(1).line ),
				:from( $lhs.to ),
				:to( $lhs.to + $0.Str.chars ),
				:content( $0.Str )
			)
		}
		else {
			()
		}
	}
	method after-orig( Mu $lhs ) {
		my $x = $lhs.orig.substr( $lhs.to );
		if $x ~~ m{ ^ ( \s+ ) } {
			self.bless(
				:factory-line-number( callframe(1).line ),
				:from( $lhs.to ),
				:to( $lhs.to + $0.Str.chars ),
				:content( $0.Str )
			)
		}
		else {
			()
		}
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

	method from-match( Mu $p ) {
		if $p.from < $p.to {
			self.bless(
				:factory-line-number( callframe(1).line ),
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
class Perl6::Infinity is Token {
	also is Perl6::Element;

	method from-match( Mu $p ) {
		if $p.from < $p.to {
			self.bless(
				:factory-line-number( callframe(1).line ),
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
				:factory-line-number( callframe(1).line ),
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
				:factory-line-number( callframe(1).line ),
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
				:factory-line-number( callframe(1).line ),
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
				:factory-line-number( callframe(1).line ),
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
				:factory-line-number( callframe(1).line ),
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
				:factory-line-number( callframe(1).line ),
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
				:factory-line-number( callframe(1).line ),
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
class Perl6::Block does Branching does Bounded {
	also is Perl6::Element;

	method from-match( Mu $p, Perl6::Element @child ) {
		if $p.from < $p.to {
			my Perl6::Element @_child;
			$p.Str ~~ m{ ^ (.) }; my Str $front = ~$0;
			$p.Str ~~ m{ (.) $ }; my Str $back = ~$0;
			@_child.append(
				Perl6::Balanced::Enter.new(
					:factory-line-number( callframe(1).line ),
					:from( $p.from ),
					:to( $p.from + $front.chars ),
					:content( $front )
				)
			);
			@_child.append( @child );
			@_child.append(
				Perl6::Balanced::Exit.new(
					:factory-line-number( callframe(1).line ),
					:from( $p.to - $back.chars ),
					:to( $p.to ),
					:content( $back )
				)
			);
			self.bless(
				:factory-line-number( callframe(1).line ),
				:from( $p.from ),
				:to( $p.to ),
				:child( @_child )
			)
		}
		else {
			( )
		}
	}

	method from-from-to-XXX( Int $from, Int $to, Str $front, Str $back, @child ) {
		if $from < $to {
			my Perl6::Element @_child;
			@_child.append(
				Perl6::Balanced::Enter.new(
					:factory-line-number( callframe(1).line ),
					:from( $from ),
					:to( $from + $front.chars ),
					:content( $front )
				)
			);
			@_child.append( @child );
			@_child.append(
				Perl6::Balanced::Exit.new(
					:factory-line-number( callframe(1).line ),
					:from( $to - $back.chars ),
					:to( $to ),
					:content( $back )
				)
			);
			self.bless(
				:factory-line-number( callframe(1).line ),
				:from( $from ),
				:to( $to ),
				:child( @_child )
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
	constant COMMA = Q{,};
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
					:factory-line-number( callframe(1).line ),
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
					:factory-line-number( callframe(1).line ),
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
			# No line number needed.
			:from( @_child ?? @_child[0].from !! 0 ),
			:to( @_child ?? @_child[*-1].to !! 0 ),
			:child( @_child )
		)
	}

	sub key-bounds( Mu $p ) {
		if $p.list {
			#say "-1 -1 *list*"
			say "{$p.from} {$p.to} [{substr($p.orig,$p.from,$p.to-$p.from)}]"
		}
		elsif $p.orig {
			say "{$p.from} {$p.to} [{substr($p.orig,$p.from,$p.to-$p.from)}]"
		}
		else {
			say "-1 -1 NIL"
		}
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
					# XXX Zero-width token
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
			@child = self._deftermnow( $p.hash.<deftermnow> );
			@child.append(
				Perl6::WS.between-matches(
					$p,
					'deftermnow',
					'initializer'
				)
			);
			@child.append(
				self._initializer( $p.hash.<initializer> )
			);
			@child.append(
				Perl6::WS.between-matches(
					$p,
					'initializer',
					'term_init'
				)
			);
			@child.append(
				self._term_init( $p.hash.<term_init> )
			)
		}
		elsif self.assert-hash-keys( $p, [< EXPR >] ) {
			@child.append(
				self._EXPR( $p.hash.<EXPR> )
			)
		}
		elsif self.assert-Int( $p ) {
			@child.append(
				Perl6::Number::Decimal.from-match( $p )
			)
		}
		else {
			say $p.hash.keys.gist;
			warn "Unhandled case"
		}
		@child
	}

	method _args( Mu $p ) {
		my Perl6::Element @child;
		given $p {
			when self.assert-hash-keys( $_,
					[< invocant semiarglist >] ) {
				@child = self._invocant( $p.hash.<invocant> );
				@child.append(
					Perl6::WS.between-matches(
						$p,
						'invocant',
						'semiarglist'
					)
				);
				@child.append(
					self._semiarglist(
						$p.hash.<semiarglist>
					)
				)
			}
			when self.assert-hash-keys( $_, [< semiarglist >] ) {
				my Perl6::Element @_child;
				@_child.append(
					Perl6::WS.with-header-trailer(
						$_.hash.<semiarglist>,
						self._semiarglist(
							$_.hash.<semiarglist>
						)
					)
				);
				@child.append(
					Perl6::Operator::Circumfix.from-match(
						$_, @_child
					)
				)
			}
			when self.assert-hash-keys( $_, [< arglist >] ) {
				@child.append(
					self._arglist( $_.hash.<arglist> )
				)
			}
			when self.assert-hash-keys( $_, [< EXPR >] ) {
				@child.append(
					self._EXPR( $_.hash.<EXPR> )
				)
			}
			default {
				say $_.hash.keys.gist;
				warn "Unhandled case"
			}
		}
		@child
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
			when self.assert-hash-keys( $_, [< var >] ) {
				self._var( $_.hash.<var> )
			}
			when self.assert-hash-keys( $_, [< longname >] ) {
				self._longname( $_.hash.<longname> )
			}
			when self.assert-hash-keys( $_, [< cclass_elem >] ) {
				self._cclass_elem( $_.hash.<cclass_elem> )
			}
			when self.assert-hash-keys( $_, [< codeblock >] ) {
				self._codeblock( $_.hash.<codeblock> )
			}
			default {
				say $_.hash.keys.gist;
				warn "Unhandled case"
			}
		}
	}

	method _atom( Mu $p ) {
		# XXX Interesting, this can't be converted to given-when?
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
		given $p {
			when self.assert-hash-keys( $_,
					[< B >], [< quotepair >] ) {
				self._B( $_.hash.<B> )
			}
			default {
				say $_.hash.keys.gist;
				warn "Unhandled case"
			}
		}
	}

	method _backmod( Mu $p ) {
		given $p {
			default {
				say $_.hash.keys.gist;
				warn "Unhandled case"
			}
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
		given $p {
			when self.assert-hash-keys( $_, [< sym >] ) {
				self._sym( $_.hash.<sym> )
			}
			default {
				say $_.hash.keys.gist;
				warn "Unhandled case"
			}
		}
	}

	method _binint( Mu $p ) {
		Perl6::Number::Binary.from-match( $p )
	}

	method _block( Mu $p ) {
		given $p {
			when self.assert-hash-keys( $_, [< blockoid >] ) {
				self._blockoid( $_.hash.<blockoid> )
			}
			default {
				say $_.hash.keys.gist;
				warn "Unhandled case"
			}
		}
	}

	method _blockoid( Mu $p ) {
		my Perl6::Element @child;
		given $p {
			# $_ doesn't contain WS after the block.
			when self.assert-hash-keys( $_, [< statementlist >] ) {
				my Perl6::Element @_child;
				@_child.append(
					self._statementlist(
						$_.hash.<statementlist>
					)
				);
				@child =
					Perl6::Block.from-match( $_, @_child )
			}
			default {
				say $_.hash.keys.gist;
				warn "Unhandled case"
			}
		}
		@child
	}

	method _blorst( Mu $p ) {
		given $p {
			when self.assert-hash-keys( $_, [< statement >] ) {
				self._statement( $_.hash.<statement> )
			}
			when self.assert-hash-keys( $_, [< block >] ) {
				self._block( $_.hash.<block> )
			}
			default {
				say $_.hash.keys.gist;
				warn "Unhandled case"
			}
		}
	}

	method _bracket( Mu $p ) {
		given $p {
			when self.assert-hash-keys( $_, [< semilist >] ) {
				self._semilist( $_.hash.<semilist> )
			}
			default {
				say $_.hash.keys.gist;
				warn "Unhandled case"
			}
		}
	} 

	method _cclass_elem( Mu $p ) {
		my Perl6::Element @child;
		if $p.list {
			for $p.list {
				if self.assert-hash-keys( $_,
						[< identifier name sign >],
						[< charspec >] ) {
					@child = self._identifier( $_.hash.<identifier> );
					@child.append(
						Perl6::WS.between-matches(
							$_,
							'identifier',
							'name'
						)
					);
					@child.append(
						self._name( $_.hash.<name> )
					);
					@child.append(
						Perl6::WS.between-matches(
							$_,
							'name',
							'sign'
						)
					);
					@child.append(
						self._sign( $_.hash.<sign> )
					)
				}
				elsif self.assert-hash-keys( $_,
						[< sign charspec >] ) {
					@child = self._sign( $p.hash.<sign> );
					@child.append(
						Perl6::WS.between-matches(
							$p,
							'sign',
							'charspec'
						)
					);
					@child.append(
						self._charspec(
							$p.hash.<charspec>
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

	method _charspec( Mu $p ) {
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
		given $p {
			when self.assert-hash-keys( $_, [< binint VALUE >] ) {
				@child = self._binint( $_.hash.<binint> )
			}
			when self.assert-hash-keys( $_, [< octint VALUE >] ) {
				@child = self._octint( $_.hash.<octint> )
			}
			when self.assert-hash-keys( $_, [< decint VALUE >] ) {
				@child = self._decint( $_.hash.<decint> )
			}
			when self.assert-hash-keys( $_, [< hexint VALUE >] ) {
				@child = self._hexint( $_.hash.<hexint> )
			}
			when self.assert-hash-keys( $_, [< pblock >] ) {
				@child = self._pblock( $_.hash.<pblock> )
			}
			when self.assert-hash-keys( $_, [< semilist >] ) {
				my Perl6::Element @_child;
				@_child.append(
					self._semilist( $_.hash.<semilist> )
				);
				@child =
					Perl6::Operator::Circumfix.from-match(
						$_, @_child
					)
			}
			when self.assert-hash-keys( $_, [< nibble >] ) {
				my Perl6::Element @_child;
				@_child.append(
					Perl6::WS.with-header-trailer(
						$_.hash.<nibble>,
						Perl6::Operator::Prefix.from-match-trimmed(
							$_.hash.<nibble>
						)
					)
				);
				@child =
					Perl6::Operator::Circumfix.from-match(
						$_, @_child
					)
			}
			default {
				say $_.hash.keys.gist;
				warn "Unhandled case"
			}
		}
		@child
	}

	method _codeblock( Mu $p ) {
		given $p {
			when self.assert-hash-keys( $_, [< block >] ) {
				self._block( $_.hash.<block> )
			}
			default {
				say $_.hash.keys.gist;
				warn "Unhandled case"
			}
		}
	}

	method _coercee( Mu $p ) {
		given $p {
			when self.assert-hash-keys( $_, [< semilist >] ) {
				self._semilist( $_.hash.<semilist> )
			}
			default {
				say $_.hash.keys.gist;
				warn "Unhandled case"
			}
		}
	}

	method _coloncircumfix( Mu $p ) {
		given $p {
			when self.assert-hash-keys( $_, [< circumfix >] ) {
				self._circumfix( $_.hash.<circumfix> )
			}
			default {
				say $_.hash.keys.gist;
				warn "Unhandled case"
			}
		}
	}

	method _colonpair( Mu $p ) {
		my Perl6::Element @child;
		given $p {
			when self.assert-hash-keys( $_,
					     [< identifier coloncircumfix >] ) {
				# Synthesize the 'from' marker for ':'
				@child =
					Perl6::Operator::Prefix.new(
						:factory-line-number(
							callframe(1).line
						),
						:from( $_.from ),
						:to( $_.from + COLON.chars ),
						:content( COLON )
					);
				@child.append(
					self._identifier( $_.hash.<identifier> )
				);
				@child.append(
					self._coloncircumfix(
						$_.hash.<coloncircumfix>
					)
				)
			}
			when self.assert-hash-keys( $_, [< coloncircumfix >] ) {
				# XXX Note that ':' is part of the expression.
				@child =
					Perl6::Operator::Prefix.new(
						:factory-line-number(
							callframe(1).line
						),
						:from( $_.from ),
						:to( $_.from + COLON.chars ),
						:content( COLON )
					);
				@child.append(
					self._coloncircumfix(
						$_.hash.<coloncircumfix>
					)
				)
			}
			when self.assert-hash-keys( $_, [< identifier >] ) {
				@child = Perl6::ColonBareword.from-match( $_ )
			}
			when self.assert-hash-keys( $_, [< fakesignature >] ) {
				# XXX May not really be "post" in the P6 sense?
				my Perl6::Element @_child =
					self._fakesignature(
						$_.hash.<fakesignature>
					);
				# XXX properly match delimiter
				@child =
					Perl6::Operator::PostCircumfix.from-delims(
						$_, ':(', ')', @_child
					)
			}
			when self.assert-hash-keys( $_, [< var >] ) {
				# Synthesize the 'from' marker for ':'
				# XXX is this actually a single token?
				# XXX I think it is.
				@child =
					Perl6::Operator::Prefix.new(
						:factory-line-number(
							callframe(1).line
						),
						:from( $_.from ),
						:to( $_.from + COLON.chars ),
						:content( COLON )
					);
				@child.append(
					self._var( $_.hash.<var> )
				)
			}
			default {
				say $_.hash.keys.gist;
				warn "Unhandled case"
			}
		}
		@child.flat
	}

	method _colonpairs( Mu $p ) {
		given $p {
			when $_ ~~ Hash {
				return True if $_.<D>;
				return True if $_.<U>;
			}
			default {
				say $_.hash.keys.gist;
				warn "Unhandled case"
			}
		}
	}

	method _contextualizer( Mu $p ) {
		warn "untested method";
		given $p {
			when self.assert-hash-keys( $_,
					[< coercee circumfix sigil >] ) {
				die "not implemented yet";
			}
			default {
				say $_.hash.keys.gist;
				warn "Unhandled case"
			}
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
			@child.append(
				Perl6::WS.with-inter-ws(
					$p,
					$p.hash.<variable_declarator>,
					[
						self._variable_declarator(
							$p.hash.<variable_declarator>
						)
					],
					$p.hash.<initializer>,
					[
						self._initializer(
							$p.hash.<initializer>
						)
					]
				)
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
			my Perl6::Element @_child;
			@_child.append(
				Perl6::Balanced::Enter.new(
					:factory-line-number(
						callframe(1).line
					),
					:from( $p.hash.<signature>.from - 1 ),
					:to( $p.hash.<signature>.from ),
					:content( '(' )
				)
			);
			@_child.append(
				Perl6::WS.header(
					$p.hash.<signature>
				)
			);
			@_child.append(
				self._signature(
					$p.hash.<signature>
				)
			);
			@_child.append(
				Perl6::WS.trailer(
					$p.hash.<signature>
				)
			);
			@_child.append(
				Perl6::Balanced::Exit.new(
					:factory-line-number(
						callframe(1).line
					),
					:from( $p.hash.<signature>.to ),
					:to( $p.hash.<signature>.to + 1 ),
					:content( ')' )
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
				Perl6::WS.before-orig(
					$p.hash.<initializer>
				)
			);
			@child.append(
				self._initializer(
					$p.hash.<initializer>
				)
			)
		}
		elsif self.assert-hash-keys( $p,
				  [< initializer variable_declarator >],
				  [< trait >] ) {
			@child.append(
				Perl6::WS.with-inter-ws(
					$p,
					$p.hash.<variable_declarator>,
					[
						self._variable_declarator(
							$p.hash.<variable_declarator>
						)
					],
					$p.hash.<initializer>,
					[
						self._initializer(
							$p.hash.<initializer>
						)
					]
				)
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
			@child = Perl6::Operator::Circumfix.new( $p, @_child )
		}
		else {
			say $p.hash.keys.gist;
			warn "Unhandled case"
		}
		@child
	}

	method _DECL( Mu $p ) {
		my Perl6::Element @child;
		if self.assert-hash-keys( $p,
				[< deftermnow initializer term_init >],
				[< trait >] ) {
			@child = self._deftermnow( $p.hash.<deftermnow> );
			@child.append(
				Perl6::WS.between-matches(
					$p,
					'deftermnow',
					'initializer'
				)
			);
			@child.append(
				self._initializer( $p.hash.<initializer> )
			);
			@child.append(
				Perl6::WS.between-matches(
					$p,
					'initializer',
					'term_init'
				)
			);
			@child.append(
				self._term_init( $p.hash.<term_init> )
			)
		}
		elsif self.assert-hash-keys( $p,
				[< deftermnow initializer signature >],
				[< trait >] ) {
			@child = self._deftermnow( $p.hash.<deftermnow> );
			@child.append(
				Perl6::WS.between-matches(
					$p,
					'deftermnow',
					'initializer'
				)
			);
			@child.append(
				self._initializer( $p.hash.<initializer> )
			);
			@child.append(
				Perl6::WS.between-matches(
					$p,
					'initializer',
					'signature'
				)
			);
			@child.append(
				self._signature( $p.hash.<signature> )
			)
		}
		elsif self.assert-hash-keys( $p,
				[< initializer signature >], [< trait >] ) {
			@child = self._initializer( $p.hash.<initializer> );
			@child.append(
				Perl6::WS.between-matches(
					$p,
					'initializer',
					'signature'
				)
			);
			@child.append(
				self._signature(
					$p.hash.<signature>
				)
			)
		}
		elsif self.assert-hash-keys( $p,
				[< initializer variable_declarator >],
				[< trait >] ) {
			@child = self._initializer(
				$p.hash.<initializer>
			);
			@child.append(
				Perl6::WS.between-matches(
					$p,
					'initializer',
					'variable_declarator'
				)
			);
			@child.append(
				self._variable_declarator(
					$p.hash.<variable_declarator>
				)
			)
		}
		elsif self.assert-hash-keys( $p, [< sym package_def >] ) {
			@child = self._sym(
				$p.hash.<sym>
			);
			@child.append(
				Perl6::WS.between-matches(
					$p,
					'sym',
					'package_def'
				)
			);
			@child.append(
				self._package_def(
					$p.hash.<package_def>
				)
			)
		}
		elsif self.assert-hash-keys( $p,
				[< regex_declarator >],
				[< trait >] ) {
			@child.append(
				self._regex_declarator(
					$p.hash.<regex_declarator>
				)
			)
		}
		elsif self.assert-hash-keys( $p,
				[< variable_declarator >],
				[< trait >] ) {
			@child.append(
				self._variable_declarator(
					$p.hash.<variable_declarator>
				)
			)
		}
		elsif self.assert-hash-keys( $p,
				[< routine_declarator >],
				[< trait >] ) {
			@child.append(
				self._routine_declarator(
					$p.hash.<routine_declarator>
				)
			)
		}
		elsif self.assert-hash-keys( $p, [< declarator >] ) {
			@child.append(
				self._declarator( $p.hash.<declarator> )
			)
		}
		elsif self.assert-hash-keys( $p,
				[< signature >], [< trait >] ) {
			@child.append(
				self.signature( $p.hash.<signature> )
			)
		}
		else {
			say $p.hash.keys.gist;
			warn "Unhandled case"
		}
		@child
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
		elsif self.assert-hash-keys( $p, [< coeff frac >] ) {
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
		given $p {
			when self.assert-hash-keys( $_,
					[< name >], [< colonpair >] ) {
				self._name( $_.hash.<name> )
			}
			default {
				say $_.hash.keys.gist;
				warn "Unhandled case"
			}
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
		given $p {
			when self.assert-hash-keys( $_, [< defterm >] ) {
				self._defterm( $_.hash.<defterm> )
			}
			default {
				say $_.hash.keys.gist;
				warn "Unhandled case"
			}
		}
	}

	method _desigilname( Mu $p ) {
		given $p {
			when self.assert-hash-keys( $_, [< longname >] ) {
				self._longname( $_.hash.<longname> )
			}
			default {
				say $_.hash.keys.gist;
				warn "Unhandled case"
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
		given $p {
			default {
				say $_.hash.keys.gist;
				warn "Unhandled case"
			}
		}
	}

	# .
	# .*
	#
	method _dotty( Mu $p ) {
		my Perl6::Element @child;
		given $p {
			when self.assert-hash-keys( $_, [< sym dottyop O >] ) {
				@child =
					Perl6::Operator::Prefix.from-match(
						$_.hash.<sym>
					);
				@child.append(
					self._dottyop( $_.hash.<dottyop> ).flat
				)
			}
			default {
				say $_.hash.keys.gist;
				warn "Unhandled case"
			}
		}
		@child
	}

	method _dottyop( Mu $p ) {
		my Perl6::Element @child;
		given $p {
			when self.assert-hash-keys( $_,
					[< sym postop >], [< O >] ) {
				@child = self._sym(
					$p.hash.<sym>
				);
				@child.append(
					Perl6::WS.between-matches(
						$p,
						'sym',
						'postop'
					)
				);
				@child.append(
					self._postop(
						$p.hash.<postop>
					)
				)
			}
			when self.assert-hash-keys( $_, [< colonpair >] ) {
				@child.append(
					self._colonpair( $_.hash.<colonpair> )
				)
			}
			when self.assert-hash-keys( $_, [< methodop >] ) {
				@child.append(
					self._methodop( $_.hash.<methodop> )
				)
			}
			default {
				say $_.hash.keys.gist;
				warn "Unhandled case"
			}
		}
		@child
	}

	method _dottyopish( Mu $p ) {
		given $p {
			when self.assert-hash-keys( $_, [< term >] ) {
				self._term( $_.hash.<term> )
			}
			default {
				say $_.hash.keys.gist;
				warn "Unhandled case"
			}
		}
	}

	method _e1( Mu $p ) {
		given $p {
			when self.assert-hash-keys( $_,
					[< scope_declarator >] ) {
				self._scope_declarator(
					$_.hash.<scope_declarator>
				)
			}
			default {
				say $_.hash.keys.gist;
				warn "Unhandled case"
			}
		}
	}

	method _e2( Mu $p ) {
		my Perl6::Element @child;
		given $p {
			when self.assert-hash-keys( $_, [< infix OPER >] ) {
				@child = self._infix(
					$p.hash.<infix>
				);
				@child.append(
					Perl6::WS.between-matches(
						$p,
						'infix',
						'OPER'
					)
				);
				@child.append(
					self._OPER(
						$p.hash.<OPER>
					)
				)
			}
			default {
				say $_.hash.keys.gist;
				warn "Unhandled case"
			}
		}
		@child
	}

	method _e3( Mu $p ) {
		my Perl6::Element @child;
		given $p {
			when self.assert-hash-keys( $_, [< postfix OPER >],
					[< postfix_prefix_meta_operator >] ) {
				@child = self._postfix(
					$p.hash.<postfix>
				);
				@child.append(
					Perl6::WS.between-matches(
						$p,
						'postfix',
						'OPER'
					)
				);
				@child.append(
					self._OPER(
						$p.hash.<OPER>
					)
				)
			}
			default {
				say $_.hash.keys.gist;
				warn "Unhandled case"
			}
		}
		@child
	}

	method _else( Mu $p ) {
		my Perl6::Element @child;
		given $p {
			when self.assert-hash-keys( $_, [< sym blorst >] ) {
				@child.append(
					Perl6::WS.with-inter-ws(
						$_,
						$_.hash.<sym>,
						[
							self._sym(
								$_.hash.<sym>
							)
						],
						$_.hash.<blorst>,
						[
							self._blorst(
								$_.hash.<blorst>
							)
						]
					)
				)
			}
			when self.assert-hash-keys( $_, [< blockoid >] ) {
				@child = self._blockoid( $_.hash.<blockoid> )
			}
			default {
				say $_.hash.keys.gist;
				warn "Unhandled case"
			}
		}
		@child
	}

	method _escale( Mu $p ) {
		my Perl6::Element @child;
		given $p {
			when self.assert-hash-keys( $_, [< sign decint >] ) {
				@child = self._sign(
					$_.hash.<sign>
				);
				@child.append(
					Perl6::WS.between-matches(
						$_,
						'sign',
						'decint'
					)
				);
				@child.append(
					self._decint(
						$_.hash.<decint>
					)
				)
			}
			default {
				say $_.hash.keys.gist;
				warn "Unhandled case"
			}
		}
		@child
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
			when self.assert-hash-keys( $_, [< sign decint >] ) {
				@child = self._invocant(
					$_.hash.<invocant>
				);
				@child.append(
					Perl6::WS.between-matches(
						$_,
						'invocant',
						'semiarglist'
					)
				);
				@child.append(
					self._semiarglist(
						$_.hash.<semiarglist>
					)
				)
			}
			default {
				say $_.hash.keys.gist;
				warn "Unhandled case"
			}
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
				@child = self._EXPR( $p.list.[0] );
				@child.append(
					# XXX note that '>>' is a substring
					Perl6::Operator::Prefix.new(
						:factory-line-number( callframe(1).line ),
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
				@child = self._EXPR( $p.list.[0] );
				@child.append(
					self._dotty( $p.hash.<dotty> )
				)
			}
		}
		elsif self.assert-hash-keys( $p,
				[< infix OPER >],
				[< infix_postfix_meta_operator >] ) {
			@child.append(
				Perl6::WS.with-inter-ws(
					$p,
					$p.hash.<infix>,
					[
						self._infix( $p.hash.<infix> )
					],
					$p.list.[0].list.[0] // $p.list.[0],
					[
						self._EXPR( $p.list.[0] )
					]
				)
			)
		}
		elsif self.assert-hash-keys( $p,
				[< prefix OPER >],
				[< prefix_postfix_meta_operator >] ) {
			@child.append(
				Perl6::WS.with-inter-ws(
					$p,
					$p.hash.<prefix>,
					[
						self._prefix( $p.hash.<prefix> )
					],
					$p.list.[0].list.[0] // $p.list.[0],
					[
						self._EXPR( $p.list.[0] )
					]
				)
			)
		}
		elsif self.assert-hash-keys( $p,
				[< postcircumfix OPER >],
				[< postfix_prefix_meta_operator >] ) {
			@child = self._EXPR( $p.list.[0] );
			@child.append(
				self._postcircumfix(
					$p.hash.<postcircumfix>
				)
			)
		}
		elsif self.assert-hash-keys( $p,
				[< postfix OPER >],
				[< postfix_prefix_meta_operator >] ) {
			@child = self._EXPR( $p.list.[0] );
			@child.append(
				self._postfix( $p.hash.<postfix> )
			)
		}
		elsif self.assert-hash-keys( $p,
				[< infix_prefix_meta_operator OPER >] ) {
			@child = self._EXPR( $p.list.[0] );
			@child.append(
				Perl6::WS.before-orig(
					$p.hash.<infix_prefix_meta_operator>
				),
			);
			@child.append(
				self._infix_prefix_meta_operator(
					$p.hash.<infix_prefix_meta_operator>
				),
			);
			@child.append(
				Perl6::WS.after-orig(
					$p.hash.<infix_prefix_meta_operator>
				),
			);
			@child.append(
				self._EXPR( $p.list.[1] )
			)
		}
		# XXX ternary operators don't follow the string boundary rules
		# XXX $p.list.[0] is actually the start of the expression.
		elsif self.assert-hash-keys( $p, [< infix OPER >] ) {
			if $p.list.elems == 3 {
				if $p.hash.<infix>.Str eq COMMA {
					@child.append(
						Perl6::WS.before-orig(
							$p.list.[0]
						)
					);
					@child = self._EXPR( $p.list.[0] );
					@child.append(
						Perl6::Operator::Infix.new(
							:factory-line-number(
								callframe(0).line
							),
							:from( @child[*-1].to ),
							:to( @child[*-1].to + COMMA.chars ),
							:content( COMMA )
						)
					);
					@child.append(
						Perl6::WS.before-orig(
							$p.list.[1]
						)
					);
					@child.append(
						self._EXPR( $p.list.[1] )
					);
					@child.append(
						Perl6::WS.after-orig(
							$p.list.[1]
						)
					);
					@child.append(
						Perl6::Operator::Infix.new(
							$p, COMMA
						)
					);
					my $x = $p.orig.substr(
						$p.hash.<infix>.to# + COMMA.chars
					);
					if $x ~~ m{ ^ ( \s+ ) } {
						@child.append(
							Perl6::WS.new(
								:factory-line-number( callframe(1).line ),
								:from( $p.hash.<infix>.to ),
								:to( $p.hash.<infix>.to + $0.Str.chars ),
								:content( $0.Str )
							)
						)
					}
					@child.append(
						self._EXPR( $p.list.[2] )
					)
				}
				else {
					# XXX Sigh, unify this later.
					@child = self._EXPR( $p.list.[0] );
					@child.append(
						Perl6::Operator::Infix.new(
							$p, QUES-QUES
						)
					);
					@child.append(
						self._EXPR( $p.list.[1] )
					);
					@child.append(
						Perl6::Operator::Infix.new(
							$p, BANG-BANG
						)
					);
					@child.append(
						self._EXPR( $p.list.[2] )
					)
				}
			}
			else {
				@child.append(
					self._EXPR( $p.list.[0] )
				);
				my $x = $p.orig.substr(
					@child[*-1].to
				);
				if $x ~~ m{ ^ ( \s+ ) } {
					@child.append(
						Perl6::WS.new(
							:factory-line-number( callframe(1).line ),
							:from( @child[*-1].to ),
							:to( @child[*-1].to + $0.chars ),
							:content( $0.Str )
						)
					)
				}
				@child.append(
					self._infix( $p.hash.<infix> )
				);
				@child.append(
					Perl6::WS.after-orig(
						$p.hash.<infix>
					)
				);
				@child.append(
					self._EXPR( $p.list.[1] )
				)
			}
		}
		elsif self.assert-hash-keys( $p, [< args op >] ) {
#			@child = self._op( $p.hash.<op> );
			@child.append(
				self._args( $p.hash.<args> )
			)
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
				@child.append(
					self._longname(
						$p.hash.<longname>
					)
				);
				if $p.hash.<args>.hash.keys and
				   $p.hash.<args>.Str ~~ m{ \S } {
					@child.append(
						Perl6::WS.with-header(
							$p.hash.<args>,
							self._args(
								$p.hash.<args>
							)
						)
					)
				}
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
		elsif self.assert-hash-keys( $p, [< sym >] ) {
			@child = self._sym( $p.hash.<sym> )
		}
		elsif self.assert-hash-keys( $p, [< statement_prefix >] ) {
			@child = self._statement_prefix(
				$p.hash.<statement_prefix>
			)
		}
		elsif self.assert-hash-keys( $p, [< methodop >] ) {
			@child = self._methodop(
				$p.hash.<methodop>
			)
		}
		else {
			say $p.hash.keys.gist;
			warn "Unhandled case"
		}
		@child.flat
	}

	method _fake_infix( Mu $p ) {
		given $p {
			when self.assert-hash-keys( $_, [< O >] ) {
				self._O( $_.hash.<O> )
			}
			default {
				say $_.hash.keys.gist;
				warn "Unhandled case"
			}
		}
	}

	method _fakesignature( Mu $p ) {
		given $p {
			if self.assert-hash-keys( $_, [< signature >] ) {
				self._signature( $_.hash.<signature> )
			}
			else {
				say $_.hash.keys.gist;
				warn "Unhandled case"
			}
		}
	}

	method _fatarrow( Mu $p ) {
		my Perl6::Element @child;
		if self.assert-hash-keys( $p, [< key val >] ) {
			$p.Str ~~ m{ ('=>') };
			@child = self._key( $p.hash.<key> );
			@child.append(
				Perl6::WS.after(
					$p,
					$p.hash.<key>
				)
			);
			@child.append(
				Perl6::Operator::Infix.new( $p, FATARROW ),
			);
			@child.append(
				Perl6::WS.before(
					$p,
					$p.hash.<val>
				)
			);
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
				if 0 {
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
		my Perl6::Element @child;
		given $p {
			when self.assert-hash-keys( $_, [< infix OPER >] ) {
				@child = self._infix(
					$_.hash.<infix>
				);
				@child.append(
					Perl6::WS.between-matches(
						$_,
						'infix',
						'OPER'
					)
				);
				@child.append(
					self._OPER(
						$_.hash.<OPER>
					)
				)
			}
			when self.assert-hash-keys( $_, [< sym O >] ) {
				# XXX fix?
				@child.append(
					Perl6::Operator::Infix.from-match(
						$_.hash.<sym>
					)
				)
			}
			when self.assert-hash-keys( $_, [< EXPR O >] ) {
				# XXX fix?
				@child.append(
					Perl6::Operator::Infix.from-match(
						$_.hash.<EXPR>
					)
				)
			}
			default {
				say $_.hash.keys.gist;
				warn "Unhandled case"
			}
		}
		@child
	}

	method _infixish( Mu $p ) {
		my Perl6::Element @child;
		given $p {
			when self.assert-hash-keys( $_, [< infix OPER >] ) {
				@child = self._infix(
					$_.hash.<infix>
				);
				@child.append(
					Perl6::WS.between-matches(
						$_,
						'infix',
						'OPER'
					)
				);
				@child.append(
					self._OPER(
						$_.hash.<OPER>
					)
				)
			}
			default {
				say $_.hash.keys.gist;
				warn "Unhandled case"
			}
		}
		@child
	}

	# << >>
	# « »
	#
	method _infix_circumfix_meta_operator( Mu $p ) {
		given $p {
			when self.assert-hash-keys( $_, [< sym infixish O >] ) {
				Perl6::Operator::Infix.new(
					$_.hash.<sym>.from,
					$_.hash.<sym>.Str ~ $_.hash.<infixish>
				)
			}
			default {
				say $_.hash.keys.gist;
				warn "Unhandled case"
			}
		}
	}
	# « »
	#
	method _infix_prefix_meta_operator( Mu $p ) {
		given $p {
			when self.assert-hash-keys( $_, [< sym infixish O >] ) {
				Perl6::Operator::Infix.new(
					$_.hash.<sym>.from,
					$_.hash.<sym>.Str ~ $_.hash.<infixish>
				)
			}
			default {
				say $_.hash.keys.gist;
				warn "Unhandled case"
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
		if self.assert-hash-keys( $p, [< dottyopish sym >] ) {
			@child = self._dottyopish(
				$p.hash.<dottyopish>
			);
			@child.append(
				Perl6::WS.between-matches(
					$p,
					'dottyopish',
					'sym'
				)
			);
			@child.append(
				self._sym(
					$p.hash.<sym>
				)
			)
		}
		elsif self.assert-hash-keys( $p, [< sym EXPR >] ) {
			@child =
				Perl6::Operator::Infix.from-match(
					$p.hash.<sym>
				);
			if $p.hash.<EXPR>.list.[0] {
				@child.append(
					Perl6::WS.after(
						$p,
						$p.hash.<sym>
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
					self._EXPR( $p.hash.<EXPR>.list.[0] )
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
					self._EXPR( $p.hash.<EXPR>.list.[1] )
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
						:factory-line-number( callframe(1).line ),
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
		given $p {
			when self.assert-hash-keys( $_, [< binint VALUE >] ) {
				Perl6::Number::Binary.from-match( $_ )
			}
			when self.assert-hash-keys( $_, [< octint VALUE >] ) {
				Perl6::Number::Octal.from-match( $_ )
			}
			when self.assert-hash-keys( $_, [< decint VALUE >] ) {
				Perl6::Number::Decimal.from-match( $_ )
			}
			when self.assert-hash-keys( $_, [< hexint VALUE >] ) {
				Perl6::Number::Hexadecimal.from-match( $_ )
			}
			default {
				say $_.hash.keys.gist;
				warn "Unhandled case"
			}
		}
	}

	method _invocant( Mu $p ) {
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

	# Special value...
	method _lambda( Mu $p ) {
		Perl6::Operator::Infix.from-match( $p )
	}

	method _left( Mu $p ) {
		given $p {
			when self.assert-hash-keys( $_, [< termseq >] ) {
				self._termseq( $_.hash.<termseq> )
			}
			default {
				say $_.hash.keys.gist;
				warn "Unhandled case"
			}
		}
	}

	method _longname( Mu $p ) {
		given $p {
			when self.assert-hash-keys( $_,
					[< name >], [< colonpair >] ) {
				self._name( $_.hash.<name> )
			}
			default {
				say $_.hash.keys.gist;
				warn "Unhandled case"
			}
		}
	}

	method _max( Mu $p ) {
		given $p {
			default {
				say $_.hash.keys.gist;
				warn "Unhandled case"
			}
		}
	}

	# :my
	# { }
	# qw
	# '
	#
	method _metachar( Mu $p ) {
		given $p {
			when self.assert-hash-keys( $_, [< sym >] ) {
				self._sym( $_.hash.<sym> )
			}
			when self.assert-hash-keys( $_, [< codeblock >] ) {
				self._codeblock( $_.hash.<codeblock> )
			}
			when self.assert-hash-keys( $_, [< backslash >] ) {
				self._backslash( $_.hash.<backslash> )
			}
			when self.assert-hash-keys( $_, [< assertion >] ) {
				self._assertion( $_.hash.<assertion> )
			}
			when self.assert-hash-keys( $_, [< nibble >] ) {
				self._nibble( $_.hash.<nibble> )
			}
			when self.assert-hash-keys( $_, [< quote >] ) {
				self._quote( $_.hash.<quote> )
			}
			when self.assert-hash-keys( $_, [< nibbler >] ) {
				self._nibbler( $_.hash.<nibbler> )
			}
			when self.assert-hash-keys( $_, [< statement >] ) {
				self._statement( $_.hash.<statement> )
			}
			default {
				say $_.hash.keys.gist;
				warn "Unhandled case"
			}
		}
	}

	method _method_def( Mu $p ) {
		my Perl6::Element @child;
		given $p {
			when self.assert-hash-keys( $_,
				     [< specials longname blockoid multisig >],
				     [< trait >] ) {
				my Perl6::Element @_child =
					 self._multisig( $_.hash.<multisig> );
				@child =
					self._longname( $_.hash.<longname> );
				@child.append(
					Perl6::Operator::Circumfix.from-match(
						$_, @_child
					)
				);
				@child.append(
					self._blockoid( $_.hash.<blockoid> )
				)
			}
			when self.assert-hash-keys( $_,
				     [< specials longname blockoid >],
				     [< trait >] ) {
				@child.append(
					Perl6::WS.with-inter-ws(
						$_,
						$_.hash.<longname>,
						[
							self._longname(
								$_.hash.<longname>
							)
						],
						$_.hash.<blockoid>,
						[
							self._blockoid(
								$_.hash.<blockoid>
							)
						]
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

	method _methodop( Mu $p ) {
		my Perl6::Element @child;
		given $p {
			when self.assert-hash-keys( $_, [< longname args >] ) {
				@child = self._longname(
					$_.hash.<longname>
				);
				@child.append(
					Perl6::WS.between-matches(
						$_,
						'longname',
						'args'
					)
				);
				@child.append(
					self._args(
						$_.hash.<args>
					)
				)
			}
			when self.assert-hash-keys( $_, [< variable >] ) {
				@child = self._variable( $_.hash.<variable> )
			}
			when self.assert-hash-keys( $_, [< longname >] ) {
				@child = self._longname( $_.hash.<longname> )
			}
			default {
				say $_.hash.keys.gist;
				warn "Unhandled case"
			}
		}
		@child
	}

	method _min( Mu $p ) {
		given $p {
			when self.assert-hash-keys( $_, [< decint VALUE >] ) {
				self._decint( $_.hash.<decint> )
			}
			default {
				say $_.hash.keys.gist;
				warn "Unhandled case"
			}
		}
	}

	method _modifier_expr( Mu $p ) {
		given $p {
			when self.assert-hash-keys( $_, [< EXPR >] ) {
				self._EXPR( $_.hash.<EXPR> )
			}
			default {
				say $_.hash.keys.gist;
				warn "Unhandled case"
			}
		}
	}

	method _module_name( Mu $p ) {
		given $p {
			when self.assert-hash-keys( $_, [< longname >] ) {
				self._longname( $_.hash.<longname> )
			}
			default {
				say $_.hash.keys.gist;
				warn "Unhandled case"
			}
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
		given $p {
			when self.assert-hash-keys( $_,
					[< sym routine_def >] ) {
				@child.append(
					Perl6::WS.with-inter-ws(
						$_,
						$_.hash.<sym>,
						[
							self._sym(
								$_.hash.<sym>
							)
						],
						$_.hash.<routine_def>,
						[
							self._routine_def(
								$_.hash.<routine_def>
							)
						]
					)
				)
			}
			when self.assert-hash-keys( $_,
					[< sym declarator >] ) {
				@child.append(
					Perl6::WS.with-inter-ws(
						$_,
						$_.hash.<sym>,
						[
							self._sym(
								$_.hash.<sym>
							)
						],
						$_.hash.<declarator>,
						[
							self._declarator(
								$_.hash.<declarator>
							)
						]
					)
				)
			}
			when self.assert-hash-keys( $_, [< declarator >] ) {
				@child = self._declarator(
					$_.hash.<declarator>
				)
			}
			default {
				say $_.hash.keys.gist;
				warn "Unhandled case"
			}
		}
		@child
	}

	method _multisig( Mu $p ) {
		my Perl6::Element @child;
		given $p {
			when self.assert-hash-keys( $_, [< signature >] ) {
				@child.append(
					Perl6::WS.with-trailer(
						$_.hash.<signature>,
						self._signature(
							$_.hash.<signature>
						)
					)
				)
			}
			default {
				say $_.hash.keys.gist;
				warn "Unhandled case"
			}
		}
		@child
	}

	method _named_param( Mu $p ) {
		given $p {
			when self.assert-hash-keys( $_, [< param_var >] ) {
				self._param_var( $_.hash.<param_var> )
			}
			default {
				say $_.hash.keys.gist;
				warn "Unhandled case"
			}
		}
	}

	method _name( Mu $p ) {
		my Perl6::Element @child;
		given $p {
			when self.assert-hash-keys( $_,
				[< param_var type_constraint quant >],
				[< default_value modifier trait
				   post_constraint >] ) {
				@child = self._param_var( $_.hash.<param_var> );
				@child.append(
					Perl6::WS.between-matches(
						$_,
						'param_var',
						'type_constraint'
					)
				);
				@child.append(
					self._type_constraint(
						$_.hash.<type_constraint>
					)
				);
				@child.append(
					Perl6::WS.between-matches(
						$_,
						'type_constraint',
						'quant'
					)
				);
				@child.append(
					self._quant( $_.hash.<quant> )
				)
			}
			when self.assert-hash-keys( $_,
				[< identifier >], [< morename >] ) {
				@child.append(
					Perl6::Bareword.from-match( $_ )
				)
			}
			when self.assert-hash-keys( $_, [< subshortname >] ) {
				@child.append(
					self._subshortname(
						$_.hash.<subshortname>
					)
				)
			}
			when self.assert-hash-keys( $_, [< morename >] ) {
				@child.append(
					Perl6::PackageName.from-match( $_ )
				)
				#self._morename( $_.hash.<morename> )
			}
			when self.assert-Str( $_ ) {
				@child.append(
					Perl6::Bareword.from-match( $_ )
				)
			}
			default {
				say $_.hash.keys.gist;
				warn "Unhandled case"
			}
		}
		@child
	}

	method _nibble( Mu $p ) {
		given $p {
			when self.assert-hash-keys( $_, [< termseq >] ) {
				self._termseq( $_.hash.<termseq> )
			}
			default {
				say $_.hash.keys.gist;
				warn "Unhandled case"
			}
		}
	}

	method _nibbler( Mu $p ) {
		given $p {
			when self.assert-hash-keys( $_, [< termseq >] ) {
				self._termseq( $_.hash.<termseq> )
			}
			default {
				say $_.hash.keys.gist;
				warn "Unhandled case"
			}
		}
	}

	method _normspace( Mu $p ) {
		given $p {
			default {
				say $_.hash.keys.gist;
				warn "Unhandled case"
			}
		}
	}

	method _noun( Mu $p ) {
		my Perl6::Element @child;
		if $p.list {
			for $p.list {
				if self.assert-hash-keys( $_,
					[< sigmaybe sigfinal
					   quantifier atom >] ) {
					@child = self._sigmaybe(
						$_.hash.<sigmaybe>
					);
					@child.append(
						Perl6::WS.between-matches(
							$_,
							'sigmaybe',
							'sigfinal'
						)
					);
					@child.append(
						self._sigfinal(
							$_.hash.<sigfinal>
						)
					);
					@child.append(
						Perl6::WS.between-matches(
							$_,
							'sigfinal',
							'quantifier'
						)
					);
					@child.append(
						self._quantifier(
							$_.hash.<quantifier>
						)
					);
					@child.append(
						Perl6::WS.between-matches(
							$_,
							'quantifier',
							'atom'
						)
					);
					@child.append(
						self._atom(
							$_.hash.<atom>
						)
					)
				}
				elsif self.assert-hash-keys( $_,
					[< sigfinal quantifier
					   separator atom >] ) {
					@child = self._sigfinal(
						$_.hash.<sigfinal>
					);
					@child.append(
						Perl6::WS.between-matches(
							$_,
							'sigfinal',
							'quantifier'
						)
					);
					@child.append(
						self._quantifier(
							$_.hash.<quantifier>
						)
					);
					@child.append(
						Perl6::WS.between-matches(
							$_,
							'quantifier',
							'separator'
						)
					);
					@child.append(
						self._separator(
							$_.hash.<separator>
						)
					);
					@child.append(
						Perl6::WS.between-matches(
							$_,
							'separator',
							'atom'
						)
					);
					@child.append(
						self._atom(
							$_.hash.<atom>
						)
					)
				}
				elsif self.assert-hash-keys( $_,
					[< sigmaybe sigfinal
					   separator atom >] ) {
					@child = self._sigmaybe(
						$_.hash.<sigmaybe>
					);
					@child.append(
						Perl6::WS.between-matches(
							$_,
							'sigmaybe',
							'sigfinal'
						)
					);
					@child.append(
						self._sigfinal(
							$_.hash.<sigfinal>
						)
					);
					@child.append(
						Perl6::WS.between-matches(
							$_,
							'sigfinal',
							'separator'
						)
					);
					@child.append(
						self._separator(
							$_.hash.<separator>
						)
					);
					@child.append(
						Perl6::WS.between-matches(
							$_,
							'separator',
							'atom'
						)
					);
					@child.append(
						self._atom(
							$_.hash.<atom>
						)
					)
				}
				elsif self.assert-hash-keys( $_,
					[< atom sigfinal quantifier >] ) {
					@child = self._atom( $_.hash.<atom> );
					@child.append(
						Perl6::WS.between-matches(
							$_,
							'atom',
							'sigfinal'
						)
					);
					@child.append(
						self._sigfinal(
							$_.hash.<sigfinal>
						)
					);
					@child.append(
						Perl6::WS.between-matches(
							$_,
							'sigfinal',
							'quantifier'
						)
					);
					@child.append(
						self._quantifier(
							$_.hash.<quantifier>
					 	)
					)
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
		given $p {
			when self.assert-hash-keys( $_, [< numish >] ) {
				self._numish( $_.hash.<numish> )
			}
			default {
				say $_.hash.keys.gist;
				warn "Unhandled case"
			}
		}
	}

	method _numish( Mu $p ) {
		given $p {
			when self.assert-hash-keys( $_, [< dec_number >] ) {
				self._dec_number( $_.hash.<dec_number> )
			}
			when self.assert-hash-keys( $_, [< rad_number >] ) {
				self._rad_number( $_.hash.<rad_number> )
			}
			when self.assert-hash-keys( $_, [< integer >] ) {
				self._integer( $_.hash.<integer> )
			}
			when $_.Str eq 'Inf' {
				Perl6::Infinity.from-match( $_ )
			}
			default {
				say $_.hash.keys.gist;
				warn "Unhandled case"
			}
		}
	}

	method _O( Mu $p ) {
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
		my Perl6::Element @child;
		given $p {
			when self.assert-hash-keys( $_,
				     [< infix_prefix_meta_operator OPER >] ) {
				@child.append(
					self._infix_prefix_meta_operator(
						$_.hash.<infix_prefix_meta_operator>
					)
				);
				@child.append(
					Perl6::WS.between-matches(
						$_,
						'infix_prefix_meta_operator',
						'OPER'
					)
				);
				@child.append(
					self._OPER(
						$_.hash.<OPER>
					)
				)
			}
			when self.assert-hash-keys( $_, [< infix OPER >] ) {
				@child = self._infix(
					$_.hash.<infix>
				);
				@child.append(
					Perl6::WS.between-matches(
						$_,
						'infix',
						'OPER'
					)
				);
				@child.append(
					self._OPER(
						$_.hash.<OPER>
					)
				)
			}
			default {
				say $_.hash.keys.gist;
				warn "Unhandled case"
			}
		}
		@child
	}

	method _OPER( Mu $p ) {
		my Perl6::Element @child;
		given $p {
			when self.assert-hash-keys( $_, [< sym infixish O >] ) {
				@child = self._sym( $_.hash.<sym> );
				@child.append(
					Perl6::WS.between-matches(
						$_,
						'sym',
						'infixish'
					)
				);
				@child.append(
					self._infixish(
						$_.hash.<infixish>
					)
				);
				@child.append(
					Perl6::WS.between-matches(
						$_,
						'infixish',
						'O'
					)
				);
				@child.append(
					self._O(
						$_.hash.<O>
					)
				)
			}
			when self.assert-hash-keys( $_, [< sym dottyop O >] ) {
				@child.append(
					Perl6::Operator::Infix.from-match(
						$_.hash.<sym>
					)
				);
				@child.append(
					self._dottyop( $_.hash.<dottyop> )
				)
			}
			when self.assert-hash-keys( $_, [< sym O >] ) {
				@child = self._sym(
					$_.hash.<sym>
				);
				@child.append(
					Perl6::WS.between-matches(
						$_,
						'sym',
						'O'
					)
				);
				@child.append(
					self._O(
						$_.hash.<O>
					)
				)
			}
			when self.assert-hash-keys( $_, [< EXPR O >] ) {
				@child = self._EXPR(
					$_.hash.<EXPR>
				);
				@child.append(
					Perl6::WS.between-matches(
						$_,
						'EXPR',
						'O'
					)
				);
				@child.append(
					self._O(
						$_.hash.<O>
					)
				)
			}
			when self.assert-hash-keys( $_, [< semilist O >] ) {
				@child = self._semilist(
					$_.hash.<semilist>
				);
				@child.append(
					Perl6::WS.between-matches(
						$_,
						'semilist',
						'O'
					)
				);
				@child.append(
					self._O(
						$_.hash.<O>
					)
				)
			}
			when self.assert-hash-keys( $_, [< nibble O >] ) {
				@child = self._nibble(
					$_.hash.<nibble>
				);
				@child.append(
					Perl6::WS.between-matches(
						$_,
						'nibble',
						'O'
					)
				);
				@child.append(
					self._O(
						$_.hash.<O>
					)
				)
			}
			when self.assert-hash-keys( $_, [< arglist O >] ) {
				@child = self._arglist(
					$_.hash.<arglist>
				);
				@child.append(
					Perl6::WS.between-matches(
						$_,
						'arglist',
						'O'
					)
				);
				@child.append(
					self._O(
						$_.hash.<O>
					)
				)
			}
			when self.assert-hash-keys( $_, [< dig O >] ) {
				@child = self._dig(
					$_.hash.<dig>
				);
				@child.append(
					Perl6::WS.between-matches(
						$_,
						'dig',
						'O'
					)
				);
				@child.append(
					self._O(
						$_.hash.<O>
					)
				)
			}
			when self.assert-hash-keys( $_, [< O >] ) {
				@child.append(
					self._O(
						$_.hash.<O>
					)
				)
			}
			default {
				say $_.hash.keys.gist;
				warn "Unhandled case"
			}
		}
		@child
	}

	# ?{ }
	# ??{ }
	# var
	#
	method _p5metachar( Mu $p ) {
		my Perl6::Element @child;
		given $p {
			# $_ doesn't contain WS after the block.
			when self.assert-hash-keys( $_,
					[< sym package_def >] ) {
				@child.append(
					Perl6::WS.with-inter-ws(
						$_,
						$_.hash.<sym>,
						[
							self._sym(
								$_.hash.<sym>
							)
						],
						$_.hash.<package_def>,
						[
							self._package_def(
								$_.hash.<package_def>
							)
						]
					)
				)
			}
			default {
				say $_.hash.keys.gist;
				warn "Unhandled case"
			}
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
				@child.append(
					Perl6::WS.with-inter-ws(
						$_,
						$_.hash.<sym>,
						[
							self._sym(
								$_.hash.<sym>
							)
						],
						$_.hash.<package_def>,
						[
							self._package_def(
								$_.hash.<package_def>
							)
						]
					)
				)
			}
			when self.assert-hash-keys( $_, [< sym typename >] ) {
				@child.append(
					Perl6::WS.with-inter-ws(
						$_,
						$_.hash.<sym>,
						[
							self._sym(
								$_.hash.<sym>
							)
						],
						$_.hash.<typename>,
						[
							self._typename(
								$_.hash.<typename>
							)
						]
					)
				)
			}
			when self.assert-hash-keys( $_, [< sym trait >] ) {
				@child.append(
					Perl6::WS.with-inter-ws(
						$_,
						$_.hash.<sym>,
						[
							self._sym(
								$_.hash.<sym>
							)
						],
						$_.hash.<trait>,
						[
							self._trait(
								$_.hash.<trait>
							)
						]
					)
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
				if $temp ~~ m{ ^ ( \s+ ) ( ';' )? } {
					@child.append(
						Perl6::WS.new(
							:factory-line-number( callframe(1).line ),
							:from( $_.hash.<longname>.to ),
							:to( $_.hash.<longname>.to + $0.chars ),
							:content( $0.Str )
							
						)
					);
					if $1.chars {
						@child.append(
							Perl6::Semicolon.new(
								:factory-line-number( callframe(1).line ),
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
				@child.append(
					Perl6::WS.with-inter-ws(
						$_,
						$_.hash.<longname>,
						[
							self._longname(
								$p.hash.<longname>
							)
						],
						$_.hash.<blockoid>,
						[
							self._blockoid(
								$_.hash.<blockoid>
							)
						]
					)
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
						:factory-line-number( callframe(1).line ),
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
						:factory-line-number( callframe(1).line ),
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
		given $p {
			when self.assert-hash-keys( $_,
					[< name twigil sigil >] ) {
				# XXX refactor back to a method
				my Str $sigil       = $_.hash.<sigil>.Str;
				my Str $twigil      = $_.hash.<twigil> ??
						      $_.hash.<twigil>.Str !! '';
				my Str $desigilname = $_.hash.<name> ??
						      $_.hash.<name>.Str !! '';
				my Str $content     = $_.hash.<sigil> ~
						      $twigil ~
						      $desigilname;

				my Perl6::Element $leaf =
					%sigil-map{$sigil ~ $twigil}.new(
						:factory-line-number( callframe(1).line ),
						:from( $_.from ),
						:to( $_.to ),
						:content( $_.Str )
					);
				$leaf
			}
			when self.assert-hash-keys( $_, [< name sigil >] ) {
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
					%sigil-map{$sigil ~ $twigil}.new(
						:factory-line-number( callframe(1).line ),
						:from( $_.from ),
						:to( $_.to ),
						:content( $content )
					);
				$leaf
			}
			when self.assert-hash-keys( $_, [< signature >] ) {
				my Perl6::Element @_child =
					self._signature( $_.hash.<signature> );
				Perl6::Operator::Circumfix.from-match(
					$_, @_child
				)
			}
			when self.assert-hash-keys( $_, [< sigil >] ) {
				self._sigil( $_.hash.<sigil> )
			}
			default {
				say $_.hash.keys.gist;
				warn "Unhandled case"
			}
		}
	}

	method _pblock( Mu $p ) {
		my Perl6::Element @child;
		given $p {
			when self.assert-hash-keys( $_,
					[< lambda signature blockoid >] ) {
				@child = self._lambda( $_.hash.<lambda> );
				@child.append(
					Perl6::WS.between-matches(
						$_,
						'lambda',
						'signature'
					)
				);
				@child.append(
					self._signature( $_.hash.<signature> )
				);
				@child.append(
					self._blockoid( $_.hash.<blockoid> )
				)
			}
			when self.assert-hash-keys( $_, [< blockoid >] ) {
				@child.append(
					self._blockoid( $p.hash.<blockoid> )
				)
			}
			default {
				say $_.hash.keys.gist;
				warn "Unhandled case"
			}
		}
		@child
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
		given $p {
			when self.assert-hash-keys( $_, [< arglist O >] ) {
				@child = self._arglist(
					$_.hash.<arglist>
				);
				@child.append(
					Perl6::WS.between-matches(
						$_,
						'arglist',
						'O'
					)
				);
				@child.append(
					self._O(
						$_.hash.<O>
					)
				)
			}
			when self.assert-hash-keys( $_, [< semilist O >] ) {
				my Perl6::Element @_child;
				@_child.append(
					Perl6::WS.before(
						$_,
						$_.hash.<semilist>
					)
				);
				@_child.append(
					self._semilist(
						$_.hash.<semilist>
					)
				);
				@child.append(
					Perl6::Operator::PostCircumfix.from-match(
						$_,
						@_child
					)
				)
			}
			# XXX can probably be rewritten to use utils
			when self.assert-hash-keys( $_, [< nibble O >] ) {
				if $_.Str ~~ m{ ^ (.) ( \s+ )? ( .+? ) ( \s+ )? (.) $ } {
					my Perl6::Element @_child;
					if $1 and $1.Str.chars {
						@_child.append(
							Perl6::WS.new(
								:factory-line-number( callframe(1).line ),
								:from( $_.from + $0.Str.chars ),
								:to( $_.from + $0.Str.chars + $1.Str.chars ),
								:content( $1.Str )
							)
						)
					}
					@_child.append(
						Perl6::Bareword.new(
							:factory-line-number( callframe(1).line ),
							:from( $_.from + $0.Str.chars + ( $1 ?? $1.Str.chars !! 0 ) ),
							:to( $_.to - $4.Str.chars - ( $3 ?? $3.Str.chars !! 0 ) ),
							:content( $2.Str )
						)
					);
					if $3 and $3.Str.chars {
						@_child.append(
							Perl6::WS.new(
								:factory-line-number( callframe(1).line ),
								:from( $_.to - $4.Str.chars - $3.Str.chars ),
								:to( $_.to - $4.Str.chars ),
								:content( $3.Str )
							)
						)
					}
					@child.append(
						Perl6::Operator::PostCircumfix.from-match(
							$_, @_child
						)
					)
				}
				else {
					if $_.hash.<nibble>.Str ~~ m{ ^ ( \S ) ( \s+ ) } {
						@child.append(
							Perl6::WS.new(
								:factory-line-number( callframe(1).line ),
								:from( $_.hash.<nibble>.from + $0.Str.chars ),
								:to( $_.hash.<nibble>.from + $0.Str.chars + $1.Str.chars ),
								:content( $1.Str )
							)
						)
					}
					@child.append(
						Perl6::WS.with-trailer(
							$_.hash.<nibble>,
							Perl6::Bareword.from-match-trimmed(
								$_.hash.<nibble>
							)
						)
					)
				}
			}
			default {
				say $_.hash.keys.gist;
				warn "Unhandled case"
			}
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
		my Perl6::Element @child;
		given $p {
			when self.assert-hash-keys( $_,
					[< sym postcircumfix O >] ) {
				@child = self._sym( $_.hash.<sym> );
				@child.append(
					Perl6::WS.between-matches(
						$_,
						'sym',
						'postcircumfix'
					)
				);
				@child.append(
					self._postcircumfix(
						$_.hash.<postcircumfix>
					)
				);
				@child.append(
					Perl6::WS.between-matches(
						$_,
						'postcircumfix',
						'O'
					)
				);
				@child.append(
					self._O(
						$_.hash.<O>
					)
				)
			}
			when self.assert-hash-keys( $_,
					[< sym postcircumfix >], [< O >] ) {
				@child = self._sym(
					$_.hash.<sym>
				);
				@child.append(
					Perl6::WS.between-matches(
						$_,
						'sym',
						'postcircumfix'
					)
				);
				@child.append(
					self._postcircumfix(
						$_.hash.<postcircumfix>
					)
				)
			}
			default {
				say $_.hash.keys.gist;
				warn "Unhandled case"
			}
		}
		@child
	}

	method _prefix( Mu $p ) {
		my Perl6::Element @child;
		given $p {
			when self.assert-hash-keys( $_, [< sym O >] ) {
				@child.append(
					Perl6::WS.with-trailer(
						$_,
						Perl6::Operator::Prefix.from-match(
							$_.hash.<sym>
						)
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
		given $p {
			default {
				say $_.hash.keys.gist;
				warn "Unhandled case"
			}
		}
	}

	method _quantified_atom( Mu $p ) {
		my Perl6::Element @child;
		given $p {
			when self.assert-hash-keys( $_, [< sigfinal atom >] ) {
				@child = self._sigfinal(
					$_.hash.<sigfinal>
				);
				@child.append(
					Perl6::WS.between-matches(
						$_,
						'sigfinal',
						'atom'
					)
				);
				@child.append(
					self._atom(
						$_.hash.<atom>
					)
				)
			}
			default {
				say $_.hash.keys.gist;
				warn "Unhandled case"
			}
		}
		@child
	}

	# **
	# rakvar
	#
	method _quantifier( Mu $p ) {
		my Perl6::Element @child;
		given $p {
			when self.assert-hash-keys( $_,
					[< sym min max backmod >] ) {
				@child = self._sym(
					$_.hash.<sym>
				);
				@child.append(
					Perl6::WS.between-matches(
						$_,
						'sym',
						'min'
					)
				);
				@child.append(
					self._min(
						$_.hash.<min>
					)
				);
				@child.append(
					Perl6::WS.between-matches(
						$_,
						'min',
						'max'
					)
				);
				@child.append(
					self._max(
						$_.hash.<max>
					)
				);
				@child.append(
					Perl6::WS.between-matches(
						$_,
						'max',
						'backmod'
					)
				);
				@child.append(
					self._backmod(
						$_.hash.<backmod>
					)
				)
			}
			when self.assert-hash-keys( $_, [< sym backmod >] ) {
				@child = self._sym(
					$_.hash.<sym>
				);
				@child.append(
					Perl6::WS.between-matches(
						$_,
						'sym',
						'backmod'
					)
				);
				@child.append(
					self._backmod(
						$_.hash.<backmod>
					)
				)
			}
			default {
				say $_.hash.keys.gist;
				warn "Unhandled case"
			}
		}
		@child
	}

	method _quibble( Mu $p ) {
		my Perl6::Element @child;
		given $p {
			when self.assert-hash-keys( $_, [< babble nibble >] ) {
				@child = self._babble(
					$_.hash.<babble>
				);
				@child.append(
					Perl6::WS.between-matches(
						$_,
						'babble',
						'nibble'
					)
				);
				@child.append(
					self._nibble(
						$_.hash.<nibble>
					)
				)
			}
			default {
				say $_.hash.keys.gist;
				warn "Unhandled case"
			}
		}
		@child
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
		if self.assert-hash-keys( $p, [< sym quibble rx_adverbs >] ) {
			@child = self._sym( $_.hash.<sym> );
			@child.append(
				Perl6::WS.between-matches(
					$_,
					'sym',
					'quibble'
				)
			);
			@child.append(
				self._quibble(
					$_.hash.<quibble>
				)
			);
			@child.append(
				Perl6::WS.between-matches(
					$_,
					'quibble',
					'rx_adverbs'
				)
			);
			@child.append(
				self._rx_adverbs(
					$_.hash.<rx_adverbs>
				)
			)
		}
		elsif self.assert-hash-keys( $p, [< sym rx_adverbs sibble >] ) {
			@child = self._sym( $_.hash.<sym> );
			@child.append(
				Perl6::WS.between-matches(
					$_,
					'sym',
					'quibble'
				)
			);
			@child.append(
				self._sibble(
					$_.hash.<sibble>
				)
			);
			@child.append(
				Perl6::WS.between-matches(
					$_,
					'sibble',
					'rx_adverbs'
				)
			);
			@child.append(
				self._rx_adverbs(
					$_.hash.<rx_adverbs>
				)
			)
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

			@child.append(
				Perl6::String.new(
					:factory-line-number( callframe(1).line ),
					:from( $p.from ),
					:to( $p.to ),
					:delimiter( $0.Str, $trailer ),
					:adverb( @adverb ),
					:content( $content )
				)
			)
		}
		elsif self.assert-hash-keys( $p, [< nibble >] ) {
			$p.Str ~~ m{ ^ ( . ) .*? ( . ) $ };
			given $0.Str {
				when Q{'} {
					@child.append(
						Perl6::String::Quote::Single.from-match(
							$p
						)
					)
				}
				when Q{"} {
					@child.append(
						Perl6::String::Quote::Double.from-match(
							$p
						)
					)
				}
				when Q{/} {
					# XXX Need to pass delimiters in
					@child.append(
						Perl6::Regex.from-match( $p )
					)
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
		@child
	}

	method _quotepair( Mu $p ) {
		my Perl6::Element @child;
		if $p.list {
			for $p.list {
				if self.assert-hash-keys( $_,
						[< identifier >] ) {
					@child.append(
						self._identifier(
							$_.hash.<identifier>
						)
					)
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
			@child = self._circumfix( $_.hash.<circumfix> );
			@child.append(
				Perl6::WS.between-matches(
					$_,
					'circumfix',
					'bracket'
				)
			);
			@child.append(
				self._bracket(
					$_.hash.<bracket>
				)
			);
			@child.append(
				Perl6::WS.between-matches(
					$_,
					'bracket',
					'radix'
				)
			);
			@child.append(
				self._radix(
					$_.hash.<radix>
				)
			)
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
		given $p {
			default {
				say $_.hash.keys.gist;
				warn "Unhandled case"
			}
		}
	}

	method _rad_number( Mu $p ) {
		given $p {
			when self.assert-hash-keys( $_,
					[< circumfix bracket radix >],
					[< exp base >] ) {
				Perl6::Number::Radix.from-match( $_ )
			}
			when self.assert-hash-keys( $_,
					[< circumfix radix >],
					[< exp base >] ) {
				Perl6::Number::Radix.from-match( $_ )
			}
			default {
				say $_.hash.keys.gist;
				warn "Unhandled case"
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
			when self.assert-hash-keys( $_, [< sym regex_def >] ) {
				@child.append(
					Perl6::WS.with-inter-ws(
						$_,
						$_.hash.<sym>,
						[
							self._sym(
								$_.hash.<sym>
							)
						],
						$_.hash.<regex_def>,
						[
							self._regex_def(
								$_.hash.<regex_def>
							)
						]
					)
				)
			}
			default {
				say $_.hash.keys.gist;
				warn "Unhandled case"
			}
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
						:factory-line-number( callframe(1).line ),
						:from(	$p.hash.<nibble>.from -
							$0.Str.chars ),
						:to( $p.hash.<nibble>.from ),
						:content( $0.Str )
					)
				)
			}
			@_child.append(
				Perl6::WS.with-trailer(
					$p.hash.<nibble>,
					self._nibble( $p.hash.<nibble> )
				)
			);
			@child = self._deflongname( $p.hash.<deflongname> );
			my $remainder = substr(
				$p.Str, $p.hash.<deflongname>.Str.chars
			);
			my $inset = 0;
			if $remainder ~~ m{ ^ ( \s+ ) } {
				$inset = $0.chars;
				@child.append(
					Perl6::WS.new(
						:factory-line-number( callframe(1).line ),
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
			my $right-inset = 0;
			$p.Str ~~ m{ ( . ) ( \s* ) $ }; my $back = $0.Str;
			if $1.Str {
				$right-inset = $1.Str.chars;
			}
			# XXX Collect { } from the actual text
			@child.append(
				Perl6::Block.from-from-to-XXX(
					$p.hash.<deflongname>.to + $inset,
					$p.to - $right-inset,
					'{',
					$back,
					@_child
					
				)
			)
		}
		else {
			say $p.hash.keys.gist;
			warn "Unhandled case"
		}
		@child
	}

	method _right( Mu $p ) {
		given $p {
			default {
				say $_.hash.keys.gist;
				warn "Unhandled case"
			}
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
			@child.append(
				Perl6::WS.with-header(
					$p.hash.<routine_def>,
					self._routine_def(
						$p.hash.<routine_def>
					)
				)
			)
		}
		elsif self.assert-hash-keys( $p, [< sym method_def >] ) {
			@child = self._sym( $p.hash.<sym> );
			# XXX subsume this into the Perl6::WS object later
			@child.append(
				Perl6::WS.with-header(
					$p.hash.<method_def>,
					self._method_def( $p.hash.<method_def> )
				)
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
						:factory-line-number( callframe(1).line ),
						:from( $p.hash.<deflongname>.to + $0.from ),
						:to( $p.hash.<deflongname>.to + $0.from + $0.chars ),
						:content( $0.Str )
					)
				)
			}
			elsif $strip-sides ~~ m{ '(' ( \s+ ) } {
				@_child.splice( 0, 0,
					Perl6::WS.new(
						:factory-line-number( callframe(1).line ),
						:from( $p.hash.<deflongname>.to + $0.from ),
						:to( $p.hash.<deflongname>.to + $0.from + $0.chars ),
						:content( $0.Str )
					)
				)
			}
			elsif $strip-sides ~~ m{ ( \s+ ) ')' } {
				@_child.append(
					Perl6::WS.new(
						:factory-line-number( callframe(1).line ),
						:from( $p.hash.<deflongname>.to + $0.from ),
						:to( $p.hash.<deflongname>.to + $0.from + $0.chars ),
						:content( $0.Str )
					)
				)
			}
			@child.append(
				Perl6::Operator::Circumfix.from-from-to-XXX(
					$p.hash.<deflongname>.to,
					$p.hash.<blockoid>.from - $offset,
					'(',
					')',
					@_child
				)
			);
			my Str $collect-ws = substr(
				$p.Str, 0, $p.hash.<blockoid>.from - $p.from
			);
			if $collect-ws ~~ m{ ( \s+ ) $ } {
				@child.append(
					Perl6::WS.new(
						:factory-line-number( callframe(1).line ),
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
				Perl6::WS.with-trailer(
					$p.hash.<trait>.list.[0],
					self._trait( $p.hash.<trait> )
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
			# XXX broken
			@child =
				Perl6::Operator::Circumfix.new(
					:factory-line-number( callframe(1).line ),
					:from( $p.hash.<blockoid>.from ),
					:to( $p.hash.<blockoid>.to ),
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
			@child.append(
				Perl6::WS.with-inter-ws(
					$p,
					$p.hash.<deflongname>,
					[
						self._deflongname(
							$p.hash.<deflongname>
						)
					],
					$p.hash.<blockoid>,
					[
						self._blockoid(
							$p.hash.<blockoid>
						)
					]
				)
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
		given $p {
			when self.assert-hash-keys( $_, [< quotepair >] ) {
				self._quotepair( $_.hash.<quotepair> )
			}
			when self.assert-hash-keys( $_,
					[< >], [< quotepair >] ) {
				die "Not implemented yet"
			}
			default {
				say $_.hash.keys.gist;
				warn "Unhandled case"
			}
		}
	}

	method _scoped( Mu $p ) {
		my Perl6::Element @child;
		given $p {
			# XXX DECL seems to be a mirror of declarator.
			# XXX This probably will turn out to be not true.
			#
			if self.assert-hash-keys( $_,
					[< multi_declarator DECL typename >] ) {
				@child.append(
					Perl6::WS.with-inter-ws(
						$_,
						$_.hash.<typename>,
						[
							self._typename(
								$_.hash.<typename>
							)
						],
						$_.hash.<multi_declarator>,
						[
							self._multi_declarator(
								$_.hash.<multi_declarator>
							)
						]
					)
				)
			}
			elsif self.assert-hash-keys( $_,
					[< package_declarator DECL >],
					[< typename >] ) {
				@child =
					self._package_declarator(
						$_.hash.<package_declarator>
					)
			}
			elsif self.assert-hash-keys( $_,
					[< sym package_declarator >] ) {
				@child.append(
					Perl6::WS.with-inter-ws(
						$_,
						$_.hash.<sym>,
						[
							self._sym(
								$_.hash.<sym>
							)
						],
						$_.hash.<package_declarator>,
						[
							self._package_declarator(
								$_.hash.<package_declarator>
							)
						]
					)
				)
			}
			elsif self.assert-hash-keys( $_,
					[< declarator DECL >],
					[< typename >] ) {
				@child = self._declarator(
					$_.hash.<declarator>
				)
			}
			else {
				say $_.hash.keys.gist;
				warn "Unhandled case"
			}
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
						:factory-line-number( callframe(1).line ),
						:from( $p.hash.<sym>.to ),
						:to( $p.hash.<sym>.to +
							$0.chars ),
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
		given $p {
			when self.assert-hash-keys( $_, [< arglist >] ) {
				self._arglist( $_.hash.<arglist> )
			}
			default {
				say $_.hash.keys.gist;
				warn "Unhandled case"
			}
		}
	}

	method _semilist( Mu $p ) {
		my Perl6::Element @child;
		given $p {
			when self.assert-hash-keys( $_, [< statement >] ) {
				@child.append(
					Perl6::WS.with-header-trailer(
						$_,
						self._statement(
							$_.hash.<statement>
						)
					)
				)
			}
			when self.assert-hash-keys( $_,
					[< >], [< statement >] ) {
				@child.append(
					Perl6::WS.from-match(
						$_
					)
				)
			}
			default {
				say $_.hash.keys.gist;
				warn "Unhandled case"
			}
		}
		@child
	}

	method _separator( Mu $p ) {
		my Perl6::Element @child;
		given $p {
			when self.assert-hash-keys( $_,
					[< septype quantified_atom >] ) {
				@child.append(
					self._septype(
						$_.hash.<septype>
					)
				);
				@child.append(
					Perl6::WS.between-matches(
						$_,
						'septype',
						'quantified_atom'
					)
				);
				@child.append(
					self._quantified_atom(
						$_.hash.<quantified_atom>
					)
				)
			}
			default {
				say $_.hash.keys.gist;
				warn "Unhandled case"
			}
		}
		@child
	}

	method _septype( Mu $p ) {
		given $p {
			default {
				say $_.hash.keys.gist;
				warn "Unhandled case"
			}
		}
	}

	method _shape( Mu $p ) {
		given $p {
			default {
				say $_.hash.keys.gist;
				warn "Unhandled case"
			}
		}
	}

	method _sibble( Mu $p ) {
		my Perl6::Element @child;
		given $p {
			if self.assert-hash-keys( $_,
					[< right babble left >] ) {
				@child = self._right( $_.hash.<right> );
				@child.append(
					Perl6::WS.between-matches(
						$_,
						'right',
						'babble'
					)
				);
				@child.append(
					self._babble(
						$_.hash.<babble>
					)
				);
				@child.append(
					Perl6::WS.between-matches(
						$_,
						'babble',
						'left'
					)
				);
				@child.append(
					self._left(
						$_.hash.<left>
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

	method _sigfinal( Mu $p ) {
		given $p {
			when self.assert-hash-keys( $_, [< normspace >] ) {
				self._normspace( $_.hash.<normspace> )
			}
			default {
				say $_.hash.keys.gist;
				warn "Unhandled case"
			}
		}
	}

	method _sigil( Mu $p ) {
		given $p {
			default {
				say $_.hash.keys.gist;
				warn "Unhandled case"
			}
		}
	}

	method _sigmaybe( Mu $p ) {
		my Perl6::Element @child;
		given $p {
			when self.assert-hash-keys( $_,
					[< parameter typename >],
					[< param_sep >] ) {
				@child = self._parameter(
					$_.hash.<parameter>
				);
				@child.append(
					Perl6::WS.between-matches(
						$_,
						'parameter',
						'typename'
					)
				);
				@child.append(
					self._typename(
						$_.hash.<typename>
					)
				)
			}
			when self.assert-hash-keys( $_, [],
					[< param_sep parameter >] ) {
				die "Not implemented yet"
			}
			default {
				say $_.hash.keys.gist;
				warn "Unhandled case"
			}
		}
		@child
	}

	method __Parameter( Mu $p ) {
		my Perl6::Element @child;
		if self.assert-hash-keys( $p,
			[< defterm quant >],
			[< type_constraint post_constraint
			   default_value modifier trait >] ) {
			@child = self._defterm(
				$_.hash.<defterm>
			);
			@child.append(
				Perl6::WS.between-matches(
					$_,
					'defterm',
					'quant'
				)
			);
			@child.append(
				self._quant(
					$_.hash.<quant>
				)
			)
		}
		elsif self.assert-hash-keys( $p,
			[< type_constraint param_var
			   post_constraint quant >],
			[< default_value modifier trait >] ) {
			# Synthesize the 'from' and 'to' markers for 'where'
			$p.Str ~~ m{ << (where) >> };
			my Int $from = $0.from;
			@child.append(
				self._type_constraint(
					$p.hash.<type_constraint>
				)
			);
			@child.append(
				Perl6::WS.trailer(
					$p.hash.<type_constraint>.list.[*-1]
				)
			);
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
					:factory-line-number( callframe(1).line ),
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
								:factory-line-number( callframe(1).line ),
								:from( $p.from + $0.from ),
								:to( $p.from + $0.from + $0.Str.chars ),
								:content( $0.Str )
							)
						);
					}
					@child.append(
						Perl6::Operator::Infix.new(
							:factory-line-number( callframe(1).line ),
							:from( $p.from + $1.from ),
							:to( $p.from + $1.to ),
							:content( $1.Str )
						)
					);
					if $2 and $2.Str.chars {
						@child.append(
							Perl6::WS.new(
								:factory-line-number( callframe(1).line ),
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
			@child.append(
				Perl6::Operator::Prefix.new(
					:factory-line-number( callframe(1).line ),
					:from( $p.from + $0.from ),
					:to( $p.from + $0.from +
						$0.Str.chars ),
					:content( $0.Str )
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
		given $p {
			when self.assert-hash-keys( $_, [< EXPR >] ) {
				self._EXPR( $_.hash.<EXPR> )
			}
			default {
				say $_.hash.keys.gist;
				warn "Unhandled case"
			}
		}
	}

	method _specials( Mu $p ) {
		given $p {
			default {
				say $_.hash.keys.gist;
				warn "Unhandled case"
			}
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
		my Perl6::Element @child;
		given $p {
			if self.assert-hash-keys( $_,
					[< block sym e1 e2 e3 >] ) {
				@child = self._block(
					$_.hash.<block>
				);
				@child.append(
					Perl6::WS.between-matches(
						$_,
						'block',
						'sym'
					)
				);
				@child.append(
					self._sym(
						$_.hash.<sym>
					)
				);
				@child.append(
					Perl6::WS.between-matches(
						$_,
						'sym',
						'e1'
					)
				);
				@child.append(
					self._e1(
						$_.hash.<e1>
					)
				);
				@child.append(
					Perl6::WS.between-matches(
						$_,
						'e1',
						'e2'
					)
				);
				@child.append(
					self._e2(
						$_.hash.<e2>
					)
				);
				@child.append(
					Perl6::WS.between-matches(
						$_,
						'e2',
						'e3'
					)
				);
				@child.append(
					self._e3(
						$_.hash.<e3>
					)
				)
			}
			elsif self.assert-hash-keys( $_,
					[< pblock sym EXPR wu >] ) {
				@child = self._pblock(
					$_.hash.<pblock>
				);
				@child.append(
					Perl6::WS.between-matches(
						$_,
						'pblock',
						'sym'
					)
				);
				@child.append(
					self._sym(
						$_.hash.<sym>
					)
				);
				@child.append(
					Perl6::WS.between-matches(
						$_,
						'sym',
						'EXPR'
					)
				);
				@child.append(
					self._EXPR(
						$_.hash.<EXPR>
					)
				);
				@child.append(
					Perl6::WS.between-matches(
						$_,
						'EXPR',
						'wu'
					)
				);
				@child.append(
					self._wu(
						$_.hash.<wu>
					)
				)
			}
			elsif self.assert-hash-keys( $_,
					[< doc sym module_name >] ) {
				@child = self._doc( $_.hash.<doc> );
				@child.append(
					Perl6::WS.between-matches(
						$_,
						'doc',
						'sym'
					)
				);
				@child.append(
					self._sym(
						$_.hash.<sym>
					)
				);
				@child.append(
					Perl6::WS.between-matches(
						$_,
						'sym',
						'module_name'
					)
				);
				@child.append(
					self._module_name(
						$_.hash.<module_name>
					)
				)
			}
			elsif self.assert-hash-keys( $_,
					[< doc sym version >] ) {
				@child = self._doc( $_.hash.<doc> );
				@child.append(
					Perl6::WS.between-matches(
						$_,
						'doc',
						'sym'
					)
				);
				@child.append(
					self._sym(
						$_.hash.<sym>
					)
				);
				@child.append(
					Perl6::WS.between-matches(
						$_,
						'sym',
						'version'
					)
				);
				@child.append(
					self._version(
						$_.hash.<version>
					)
				)
			}
			elsif self.assert-hash-keys( $_,
					[< sym else xblock >] ) {
				@child = self._sym( $_.hash.<sym> );
				@child.append(
					Perl6::WS.between-matches(
						$_,
						'sym',
						'else'
					)
				);
				@child.append(
					self._else(
						$_.hash.<else>
					)
				);
				@child.append(
					Perl6::WS.between-matches(
						$_,
						'else',
						'xblock'
					)
				);
				@child.append(
					self._xblock(
						$_.hash.<xblock>
					)
				)
			}
			elsif self.assert-hash-keys( $_, [< xblock sym wu >] ) {
				@child = self._xblock( $_.hash.<xblock> );
				@child.append(
					Perl6::WS.between-matches(
						$_,
						'xblock',
						'sym'
					)
				);
				@child.append(
					self._sym(
						$_.hash.<sym>
					)
				);
				@child.append(
					Perl6::WS.between-matches(
						$_,
						'sym',
						'wu'
					)
				);
				@child.append(
					self._wu(
						$_.hash.<wu>
					)
				)
			}
			elsif self.assert-hash-keys( $_, [< sym xblock >] ) {
				@child = self._sym( $_.hash.<sym> );
				@child.append(
					Perl6::WS.between-matches(
						$_,
						'sym',
						'xblock'
					)
				);
				@child.append(
					self._xblock( $_.hash.<xblock> )
				);
			}
			elsif self.assert-hash-keys( $_, [< sym block >] ) {
				@child.append(
					self._sym(
						$_.hash.<sym>
					)
				);
				@child.append(
					Perl6::WS.between-matches(
						$_,
						'sym',
						'block'
					)
				);
				@child = self._block(
					$_.hash.<block>
				)
			}
			else {
				say $_.hash.keys.gist;
				warn "Unhandled case"
			}
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
						Perl6::WS.with-inter-ws(
							$_,
							$_.hash.<EXPR>,
							[
								self._EXPR(
									$_.hash.<EXPR>
								)
							],
							$_.hash.<statement_mod_loop>,
							[
								self._statement_mod_loop(
									$_.hash.<statement_mod_loop>
								)
							]
						)
					)
				}
				elsif self.assert-hash-keys( $_,
						[< statement_mod_cond
						   EXPR >] ) {
					@child = self._statement_mod_cond(
						$_.hash.<statement_mod_cond>
					);
					@child.append(
						Perl6::WS.between-matches(
							$_,
							'statement_mod_cond',
							'EXPR'
						)
					);
					@child.append(
						self._EXPR(
							$_.hash.<EXPR>
						)
					)
				}
				elsif self.assert-hash-keys( $_,
						[< EXPR >] ) {
# XXX Aiyee. Ugly but it does work.
my $q = $_.hash.<EXPR>;
if $q.list.[0] and
   $q.hash.<infix> and
   $q.list.[1] and
   $q.list.[1].hash.<value> {
	@child.append(
		self._EXPR(
			$q.list.[0]
		)
	);
	@child.append(
		Perl6::WS.before(
			$p,
			$q.hash.<infix>
		)
	);
	@child.append(
		self._infix(
			$q.hash.<infix>
		)
	);
	@child.append(
		Perl6::WS.between-matches-orig(
			$q.hash.<infix>,
			$q.list.[1].hash.<value>
		)
	);
	@child.append(
		self._EXPR(
			$q.list.[1]
		)
	);
}
else {
					@child.append(
						self._EXPR(
							$_.hash.<EXPR>
						)
					)
}
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
				[< EXPR statement_mod_cond >] ) {
			if $p.hash.<EXPR>.Str ~~ m{ ( \s+ ) $ } {
				@child.append(
					Perl6::WS.with-trailer(
						$p.hash.<EXPR>,
						self._EXPR(
							$p.hash.<EXPR>,
						)
					)
				);
				@child.append(
					self._statement_mod_cond(
						$p.hash.<statement_mod_cond>
					)
				)
			}
			else {
				@child.append(
					Perl6::WS.with-inter-ws(
						$p,
						$p.hash.<EXPR>,
						[
							self._EXPR(
								$p.hash.<EXPR>
							)
						],
						$p.hash.<statement_mod_cond>,
						[
							self._statement_mod_cond(
								$p.hash.<statement_mod_cond>
							)
						]
					)
				)
			}
		}
		elsif self.assert-hash-keys( $p,
				[< EXPR statement_mod_loop >] ) {
			if $p.hash.<EXPR>.Str ~~ m{ ( \s+ ) $ } {
				@child.append(
					Perl6::WS.with-trailer(
						$p.hash.<EXPR>,
						self._EXPR(
							$p.hash.<EXPR>,
						)
					)
				);
				@child.append(
					self._statement_mod_loop(
						$p.hash.<statement_mod_loop>
					)
				)
			}
			else {
				@child.append(
					Perl6::WS.with-inter-ws(
						$p,
						$p.hash.<EXPR>,
						[
							self._EXPR(
								$p.hash.<EXPR>
							)
						],
						$p.hash.<statement_mod_loop>,
						[
							self._statement_mod_loop(
								$p.hash.<statement_mod_loop>
							)
						]
					)
				)
			}
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
					@child = self._EXPR(
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
							:factory-line-number( callframe(1).line ),
							:from( $p.hash.<EXPR>.hash.<infix>.from ),
							:to( $p.hash.<EXPR>.hash.<infix>.from + QUES-QUES.chars ),
							:content( QUES-QUES )
						)
					);
					if $p.hash.<EXPR>.hash.<infix>.Str ~~ m{ '??' ( \s+ ) } {
						@child.append(
							Perl6::WS.new(
								:factory-line-number( callframe(1).line ),
								:from( $p.hash.<EXPR>.hash.<infix>.from + QUES-QUES.chars ),
								:to( $p.hash.<EXPR>.hash.<infix>.from + QUES-QUES.chars + $0.Str.chars ),
								:content( $0.Str )
								
							)
						)
					}
					@child.append(
						self._EXPR( $p.hash.<EXPR>.list.[1] )
					);
					if $p.hash.<EXPR>.hash.<infix>.Str ~~ m{ ( \s+ ) '!!' } {
						@child.append(
							Perl6::WS.new(
								:factory-line-number( callframe(1).line ),
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
						self._EXPR( $p.hash.<EXPR>.list.[2] )
					)
				}
				else {
					my $q = $p.hash.<EXPR>;
					@child = self._EXPR( $q.list.[0] );
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
						Perl6::WS.after(
							$p,
							$q.hash.<infix>
						)
					);
					@child.append(
						self._EXPR( $q.list.[1] )
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
						:factory-line-number( callframe(1).line ),
						:from( $p.from ),
						:to( $p.from + $beginning-ws.chars ),
						:content( $beginning-ws )
					)
				);
				$beginning-ws = Nil;
			}
			if $beginning-comment {
				@_child.append(
					Perl6::Comment.new(
						:factory-line-number( callframe(1).line ),
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
						:factory-line-number( callframe(1).line ),
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
			if $_.Str ~~ m{ ( ';' ) ( \s+ ) $ } {
				$leftover-ws = $1.Str;
				$leftover-ws-from =
					$_.to - $1.Str.chars
			}
			else {
				@_child.append(
					Perl6::WS.trailer( $_ )
				);
			}
			my $temp = substr(
				$p.Str,
				@_child[*-1].to - $p.from
			);
			if $temp ~~ m{ ^ ( ';' ) ( \s+ ) } {
				$leftover-ws = $1.Str;
				$leftover-ws-from = 
					@_child[*-1].to +
					$0.Str.chars;
				@_child.append(
					Perl6::Semicolon.new(
						:factory-line-number( callframe(1).line ),
						:from( @_child[*-1].to ),
						:to(
							@_child[*-1].to +
							$0.Str.chars
						),
						:content( $0.Str )
					)
				)
			}
			elsif $temp ~~ m{ ^ ( ';' ) } {
				@_child.append(
					Perl6::Semicolon.new(
						:factory-line-number( callframe(1).line ),
						:from( @_child[*-1].to ),
						:to(
							@_child[*-1].to +
							$0.Str.chars
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
					:factory-line-number( callframe(1).line ),
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
		my Perl6::Element @child;
		given $p {
			when self.assert-hash-keys( $_,
					[< sym modifier_expr >] ) {
				@child = self._sym(
					$_.hash.<sym>
				);
				@child.append(
					Perl6::WS.between-matches(
						$_,
						'sym',
						'modifier_expr'
					)
				);
				@child.append(
					self._modifier_expr(
						$_.hash.<modifier_expr>
					)
				)
			}
			default {
				say $_.hash.keys.gist;
				warn "Unhandled case"
			}
		}
		@child
	}

	# while
	# until
	# for
	# given
	#
	method _statement_mod_loop( Mu $p ) {
		my Perl6::Element @child;
		given $p {
			when self.assert-hash-keys( $_, [< sym smexpr >] ) {
				@child.append(
					Perl6::WS.with-inter-ws(
						$_,
						$_.hash.<sym>,
						[
							self._sym(
								$_.hash.<sym>
							)
						],
						$_.hash.<smexpr>,
						[
							self._smexpr(
								$_.hash.<smexpr>
							)
						]
					)
				)
			}
			default {
				say $_.hash.keys.gist;
				warn "Unhandled case"
			}
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
		my Perl6::Element @child;
		given $p {
			when self.assert-hash-keys( $_, [< sym blorst >] ) {
				@child = self._sym(
					$_.hash.<sym>
				);
				@child.append(
					Perl6::WS.between-matches(
						$_,
						'sym',
						'blorst'
					)
				);
				@child.append(
					self._blorst(
						$_.hash.<blorst>
					)
				)
			}
			default {
				say $_.hash.keys.gist;
				warn "Unhandled case"
			}
		}
		@child
	}

	method _subshortname( Mu $p ) {
		given $p {
			when self.assert-hash-keys( $_, [< desigilname >] ) {
				self._desigilname( $_.hash.<desigilname> )
			}
			default {
				say $_.hash.keys.gist;
				warn "Unhandled case"
			}
		}
	}

	method _sym( Mu $p ) {
		my Perl6::Element @child;
		if $p.list {
			for $p.list {
				if $_.Str {
					@child.append(
						Perl6::Bareword.from-match(
							$_
						)
					)
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
			@child = Perl6::Bareword.from-match( $p )
		}
		elsif $p.Bool and $p.Str eq '' {
			@child = Perl6::Bareword.from-match( $p )
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
		given $p {
			when self.assert-hash-keys( $_, [< methodop >] ) {
				@child = self._methodop( $_.hash.<methodop> )
			}
			when self.assert-hash-keys( $_, [< circumfix >] ) {
				@child = self._circumfix( $_.hash.<circumfix> )
			}
			when self.assert-hash-keys( $_,
					[< name >], [< colonpair >] ) {
				@child = self._name( $_.hash.<name> );
			}
			default {
				say $_.hash.keys.gist;
				warn "Unhandled case"
			}
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
		given $p {
			when self.assert-hash-keys( $_, [< termconjseq >] ) {
				self._termconjseq( $_.hash.<termconjseq> )
			}
			default {
				say $_.hash.keys.gist;
				warn "Unhandled case"
			}
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
			$str ~~ s{ \s+ $ } = '';
			@child =
				Perl6::Bareword.new(
					:factory-line-number( callframe(1).line ),
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
		my Perl6::Element @child;
		given $p {
			when self.assert-hash-keys( $_, [< sym EXPR >] ) {
				@child = self._sym(
					$_.hash.<sym>
				);
				@child.append(
					Perl6::WS.between-matches(
						$_,
						'sym',
						'EXPR'
					)
				);
				@child.append(
					self._EXPR(
						$_.hash.<EXPR>
					)
				)
			}
			default {
				say $_.hash.keys.gist;
				warn "Unhandled case"
			}
		}
		@child
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
		given $p {
			when self.assert-hash-keys( $_, [< termaltseq >] ) {
				self._termaltseq( $_.hash.<termaltseq> )
			}
			default {
				say $_.hash.keys.gist;
				warn "Unhandled case"
			}
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
		given $p {
			when self.assert-hash-keys( $_,
					[< sym longname >],
					[< circumfix >] ) {
				@child.append(
					Perl6::WS.with-inter-ws(
						$_,
						$_.hash.<sym>,
						[
							self._sym(
								$_.hash.<sym>
							)
						],
						$_.hash.<longname>,
						[
							self._longname(
								$_.hash.<longname>
							)
						]
					)
				)
			}
			when self.assert-hash-keys( $_, [< sym typename >] ) {
				@child.append(
					Perl6::WS.with-inter-ws(
						$_,
						$_.hash.<sym>,
						[
							self._sym(
								$_.hash.<sym>
							)
						],
						$_.hash.<typename>,
						[
							self._typename(
								$_.hash.<typename>
							)
						]
					)
				)
			}
			default {
				say $_.hash.keys.gist;
				warn "Unhandled case"
			}
		}
		@child
	}

	method _twigil( Mu $p ) {
		given $p {
			default {
				say $_.hash.keys.gist;
				warn "Unhandled case"
			}
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
				[< sym initializer variable >], [< trait >] ) {
			@child = self._sym( $p.hash.<sym> );
			@child.append(
				Perl6::WS.between-matches(
					$p,
					'sym',
					'variable'
				)
			);
			@child.append(
				self._variable( $p.hash.<variable> )
			);
			@child.append(
				Perl6::WS.between-matches(
					$p,
					'variable',
					'initializer'
				)
			);
			@child.append(
				self._initializer( $p.hash.<initializer> )
			)
		}
		elsif self.assert-hash-keys( $p,
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
			@child.append(
				Perl6::WS.with-inter-ws(
					$p,
					$p.hash.<sym>,
					[
						self._sym(
							$p.hash.<sym>
						)
					],
					$p.hash.<longname>,
					[
						self._longname(
							$p.hash.<longname>
						)
					]
				)
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
						:factory-line-number( callframe(1).line ),
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
		my Perl6::Element @child;
		given $p {
			when self.assert-hash-keys( $_,
					[< postcircumfix OPER >],
					[< postfix_prefix_meta_operator >] ) {
				@child = self._postcircumfix(
					$_.hash.<postcircumfix>
				);
				@child.append(
					Perl6::WS.between-matches(
						$_,
						'postcircumfix',
						'OPER'
					)
				);
				@child.append(
					self._OPER(
						$_.hash.<OPER>
					)
				)
			}
			when self.assert-hash-keys( $_,
					[< prefix OPER >],
					[< prefix_postfix_meta_operator >] ) {
				@child = self._prefix(
					$_.hash.<prefix>
				);
				@child.append(
					Perl6::WS.between-matches(
						$_,
						'prefix',
						'OPER'
					)
				);
				@child.append(
					self._OPER(
						$_.hash.<OPER>
					)
				)
			}
			when self.assert-hash-keys( $_, [< value >] ) {
				@child.append(
					self._value( $_.hash.<value> )
				)
			}
			default {
				say $_.hash.keys.gist;
				warn "Unhandled case"
			}
		}
		@child
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
			when self.assert-hash-keys( $_, [< number >] ) {
				self._number( $_.hash.<number> )
			}
			when self.assert-hash-keys( $_, [< quote >] ) {
				self._quote( $_.hash.<quote> )
			}
			default {
				say $_.hash.keys.gist;
				warn "Unhandled case"
			}
		}
	}

	method _var( Mu $p ) {
		given $p {
			when self.assert-hash-keys( $_,
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
				%sigil-map{$sigil ~ $twigil}.new(
					:factory-line-number( callframe(1).line ),
					:from( $_.from ),
					:to( $_.to ),
					:content( $content )
				)
			}
			when self.assert-hash-keys( $_,
					[< sigil desigilname >] ) {
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
				%sigil-map{$sigil ~ $twigil}.new(
					:factory-line-number( callframe(1).line ),
					:from( $_.from ),
					:to( $_.to ),
					:content( $content )
				)
			}
			when self.assert-hash-keys( $_, [< variable >] ) {
				self._variable( $_.hash.<variable> )
			}
			default {
				say $_.hash.keys.gist;
				warn "Unhandled case"
			}
		}
	}

	method _variable_declarator( Mu $p ) {
		my Perl6::Element @child;
		if self.assert-hash-keys( $p,
			[< semilist variable shape >],
			[< postcircumfix signature trait
			   post_constraint >] ) {
			@child = self._semilist( $p.hash.<semilist> );
			@child.append(
				Perl6::WS.between-matches(
					$p,
					'semilist',
					'variable'
				)
			);
			@child.append(
				self._variable(
					$p.hash.<variable>
				)
			);
			@child.append(
				Perl6::WS.between-matches(
					$p,
					'variable',
					'shape'
				)
			);
			@child.append(
				self._shape(
					$p.hash.<shape>
				)
			)
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
						:factory-line-number( callframe(1).line ),
						:from( $p.from + $0.from ),
						:to( $p.from + $0.to ),
						:content( $0.Str )
					)
				)
			}
			@child.append(
				Perl6::Bareword.new(
					:factory-line-number( callframe(1).line ),
					:from( $p.from + $1.from ),
					:to( $p.from + $1.from + 5 ),
					:content( WHERE )
				)
			);
			if $2.Str {
				@child.append(
					Perl6::WS.new(
						:factory-line-number( callframe(1).line ),
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
			:factory-line-number( callframe(1).line ),
			:from( $p.from ),
			:to( $p.to ),
			:content( $content )
		);
		return $leaf;
	}

	method _version( Mu $p ) {
		my Perl6::Element @child;
		given $p {
			when self.assert-hash-keys( $_, [< vnum vstr >] ) {
				@child = self._vnum(
					$_.hash.<vnum>
				);
				@child.append(
					Perl6::WS.between-matches(
						$_,
						'vnum',
						'vstr'
					)
				);
				@child.append(
					self._vstr(
						$_.hash.<vstr>
					)
				)
			}
			default {
				say $_.hash.keys.gist;
				warn "Unhandled case"
			}
		}
		@child
	}

	method _vstr( Mu $p ) {
		given $p {
			default {
				say $_.hash.keys.gist;
				warn "Unhandled case"
			}
		}
	}

	method _vnum( Mu $p ) {
		my Perl6::Element @child;
		if $p.list {
			for $p.list {
				if 0 {
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
		given $p {
			default {
				say $_.hash.keys.gist;
				warn "Unhandled case"
			}
		}
	}

	method _xblock( Mu $p ) {
		my Perl6::Element @child;
		if $p.list {
			for $p.list {
				if self.assert-hash-keys( $_,
						[< pblock EXPR >] ) {
					@child = self._pblock(
						$_.hash.<pblock>
					);
					@child.append(
						Perl6::WS.between-matches(
							$_,
							'pblock',
							'EXPR'
						)
					);
					@child.append(
						self._EXPR(
							$_.hash.<EXPR>
						)
					)
				}
				else {
					say $_.hash.keys.gist;
					warn "Unhandled case"
				}
			}
		}
		elsif self.assert-hash-keys( $p, [< EXPR pblock >] ) {
			@child = self._EXPR( $p.hash.<EXPR> );
			@child.append(
				Perl6::WS.before-orig(
					$p.hash.<pblock>
				)
			);
			@child.append(
				self._pblock( $p.hash.<pblock> )
			);
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
