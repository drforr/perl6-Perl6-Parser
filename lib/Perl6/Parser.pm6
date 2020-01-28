=begin pod

=begin NAME

Perl6::Parser - Extract a Perl 6 AST from the NQP Perl 6 Parser

=end NAME

=begin SYNOPSIS

    my $pt = Perl6::Parser.new;
    my $source = Q:to[_END_];
       code-goes-here();
       that you( $want-to, $parse );
    _END_

    # Get a fully-parsed data tree
    #
    my $tree = $pt.to-tree( $source );
    say $pt.dump-tree( $tree );

    # Return only the displayed tokens (including whitespace) in the document
    #
    my @token = $pt.to-tokens-only( $source );

    # Return all tokens and structures in the document
    #
    my @everything = $pt.to-list( $source );

    # This used to fire BEGIN and CHECK phasers, it no longer does so.

    # As of 2019-03-05 $*PURE-PERL no longer exists, because it's still
    # a bit of a misnomer. And it tends to mess with the test suites a bit.
    # I've instead chosen to just make it the default, and add a comment to
    # lines that go directly to the pure Perl6 parser.

=end SYNOPSIS

=begin DESCRIPTION

Uses the built-in Perl 6 parser exposed by the internal nqp module, so that you can parse Perl 6 using Perl 6 itself. If it scares you... well, it probably should. Assuming everything works out, you'll get back a Perl 6 object tree that exactly mirrors your source file's layout, with every bit of whitespace, POD, and code given one or more tokens.

Redisplaying it becomes a matter of calling the C<to-string()> method on the tree, which passes an optional formatting hashref down the tree. You can use the format methods as they are, or add a role or subclass the objects created as you see fit to create new objects.

This process B<will> be simplified and encapsulated in the near future, as reformatting Perl 6 code was what this rather extensive module was designed to do.

I've added fairly extensive debugging documentation to the L<README.md> of this module, along with an internal L<DEBUGGING.pod> file talking about what you're seeing here, and why on B<earth> didn't I do it B<this> way? I have my reasons, but can be talked out of it with a good argument.

Please note that this does compile your code, but it takes the precaution of munging C<BEGIN> and C<CHECK> phasers into C<ENTER> instead so that it won't run at compile time.

As it stands, the C<.parse> method returns a deeply-nested object representation of the Perl 6 code it's given. It handles the regex language, but not the other braided languages such as embedded blocks in strings. It will do so eventually, but for the moment I'm busy getting the grammar rules covered.

While classes like L<EClass> won't go away, their parent classes like L<DecInteger> will remove them from the tree once their validation job has been done. For example, while the internals need to know that L<< $/<eclass> >> (the exponent for a scientific-notation number) hasn't been renamed or moved elsewhere in the tree, you as a consumer of the L<DecInteger> class don't need to know that. The C<DecInteger.perl6> method will delete the child classes so that we don't end up with a B<horribly> cluttered tree.

Classes representing Perl 6 object code are currently in the same file as the main L<Perl6::Parser> class, as moving them to separate files caused a severe performance penalty. When the time is right I'll look at moving these to another location, but as shuffling out 20 classes increased my runtime on my little ol' VM from 6 to 20 seconds, it's not worth my time to break them out. And besides, having them all in one file makes editing en masse easier.

=end DESCRIPTION

=begin DEBUGGING

Some notes on how I go about debugging various issues follow.

Let's take the case of the following glitch: The terms C<$_> and C<0> don't show up in the fragment C<[$_, 0 .. 100]>, for various reasons, mostly because there's a branch that's either not being traversed, or simply a term has gone missing.

The first thing is to break the offending bit of code out so it's easier to debug. The test file I make to do this (usually an existing test file I've got lying around) looks partially like this, with boilerplate stripped out:

    my $source = Q:to[_END_];
        my @a; @a[$_, 0 .. 100];
    _END_
    my $p = $pt.parse( $source );
    say $p.dump;
    my $tree = $pt.build-tree( $p );
    say $pt.dump-tree($tree);
    is $pt.to-string( $tree ), $source, Q{formatted};

Already a few things might stand out. First, the code inside the here-doc doesn't actually do anything, it'll never print anything to the screen or do anything interesting. That's not the point at this stage in the game. At this point all I need is a syntactically valid bit of Perl 6 that has the constructs that reproduce the bug. I don't care what the code actually does in the real world.

Second, I'm not doing anything that you as a user of the class would do. As a user of a the class, all you have to do is run the to-string() method, and it does what you want. I'm breaking things down into their component steps.

(side note - This will probably have changed in detail since I wrote this text - Consult your nearest test file for examples of current usage.)

Internally, the library takes sevaral steps to get to the nicely objectified tree that you see on your output. The two important steps in our case are the C<.parse( 'text goes here' )> method call, and C<.build-tree( $parse-tree )>.

The C<.parse()> call returns a very raw L<NQPMatch> object, which is the Perl 6 internal we're trying to reparse into a more useful form. Most of the time you can call C<.dump()> on this object and get back a semi-useful object tree. On occasion this B<will> lock up, most often because you're trying to C<.dump()> a L<list> accessor, and that hasn't been implemented for NQPMatch. The actual C<list> accessor works, but the C<.dump()> call will not. A simple workaround is to call C<$p.list.[0].dump> on one of the list elements inside, and hope there is one.

Again, these are NQP internals, and aren't quite as stable as the Perl 6 main support layer.

Once you've got a dump of the offending area, it'll look something like this:

        - postcircumfix: [0, $_ ... 100]
          - semilist: 0, $_ ... 100
            - statement: 1 matches
              - EXPR: ...
                - 0: ,
                  - 0: 0
                    - value: 0
                    # ...
                  - 1: $_
                    - variable: $_
                      - sigil: $
                      # ...
                  - infix: ,
                    - sym: ,
                    - O: <object>
                  - OPER: ,

The full thing will probably go on for a few hundred lines. Hope you've got scrollback, or just use tmux as I do.

With this you can almost immediately jump to what appears to be the offending expression, albeit with a bit of interpretation. You'll see C<- 0: 0> and C<- 1: $_>, and these are exactly the two bits of syntax that have gone missing in our example. Down below you'll see C<- infix: ,> which is where the comma separator goes.

We can combine these facts and reason that we have to search for the bit of code where we find an C<infix> operator and two list elements. The C<- 0> and C<- 1> bits tell us that we're dealing with two list elements, and the C<- infix> and C<- OPER> bits tell us that we've also got two hash keys to find.

Look down in this file for a C<assert-hash-keys()> call attempting to assert the existence of exactly a C<infix> and C<OPER> tag. There may actually be other hash keys in this data structure, as C<.dump()> doesn't report unused hash keys; this caused me a deal of confusion.

Eventually you'll find in the C<_EXPR()> method this bit of code: (due to change, obviously)

    when self.assert-hash-keys( $_, [< infix OPER >] ) {
    	@child.append(
    		self._infix( $_.hash.<infix> )
    	)
    }

You're most welcome to use the Perl 6 debugger, but what I just do is add a C<say 1;> statement just above the C<@child.append()> method call (and anywhere else I find a C<infix> and C<OPER> hash key hiding, because there are multiple places in the code that match an C<infix> and C<OPER> hash key) and rerun the test.

Now that we've confirmed where the element C<should> be getting generated, but somehow isn't, we need to look at the actual text to verify that this is actually where the C<$_> and C<0> bits are being matched, and we can use another internal debugging tool to help out with that. Add these lines:

    key-bounds $_.list.[0];
    key-bounds $_.hash.<infix>;
    key-bounds $_.list.[1];
    key-bounds $_.hash.<OPER>;
    key-bounds $_;

And rerun your code. Or make the appropriate calls in the debugger, it's your funeral :) What this function does is return something that looks like this:

    45 60 [[0, $_ ... 100]]

The two numbers are the glyphs where the matched text starts and stops, respectively. The bit in between [..] (in this case seemingly doubled, but that's because the text is itself bracketed) is the actual text that's been matched.

So, by now you know what the text you're matching actually looks like, where it is in the string, and maybe eve have a rough idea of why what you're seeing isn't being displayedk

With any luck you'll see that the code simply isn't adding the variables to the list that is being glommed onto the C<@child> array, and can add it.

By convention, when you're dumping a C<- semilist:> match, you can always call C<self._semilist( $p.hash.<semilist> )> in order to get back the list of tokens generated by matching on the C<$p.hash.semilist> object. You might be wondering why I don't just subclass NQPMatch and add this as a generic multimethod or dispatch it in some other way.

Well, the reason it's called C<NQP> is because it's Not Quite Perl 6, and like poor Rudolph, Perl 6 won't let NQP objects join in any subclasing or dispatching games, because it's Not Quite Perl. And yes, this leads to quite a bit of frustruation.

Let's assume that you've found the C<$_.list.[0]> and C<< $_.hash.<infix> >> handlers, and now need to add whitespace between the C<$_> and C<0> elements in your generated code.

Now we turn to the rather bewildering array of methods on the C<Perl6::WS> class. This profusion of methods is because of two things:

    * Whitespace can be inside a token, before or after a token, or even simply not be there because it's actually inside the L<NQPMatch> object one or more levels up, so you're never B<quite> sure where your whitespace will be hiding.
    * If each of the ~50 classes handled whitespace on its own, I'd have to track down each of the ~50 whitespace-generating methods in order to see which of the whitespace calls is being made. This way I can just look for L<Perl6::WS> and know that those are the only B<possible> places where a whitespace token could be being generated.

=end DEBUGGING

=begin METHODS

=item _roundtrip( Str $perl-code ) returns Perl6::Parser::Root

Given a string containing valid Perl 6 code ... well, return that code. This
is mostly a shortcut for testing purposes, and wil probably be moved out of the
main file.

=item to-tree( Str $source )

This is normally what you want, it returns the Perl 6 parsed tree corresponding to your source code.

=item parse( Str $source )

Returns the underlying NQPMatch object. This is what gets passed on to C<build-tree()> and every other important method in this module. It does some minor wizardry to call the Perl 6 reentrant compiler to compile the string you pass it, and return a match object. Please note that it B<has> to compile the string in order to validate things like custom operators, so this step is B<not> optional.

=item build-tree( Mu $parsed )

Build the Perl6::Element tree from the NQPMatch object. This is the core, and runs the factory which silly-walks the match tree and returns one or more tokens for every single match entry it finds, and B<more>.

=item consistency-check( Perl6::Element $root )

Check the integrity of the data structure. The Factory at its core puts together the structure very sloppily, to give the tree every possible chance to create actual quasi-valid text. This method makes sure that the factory returned valid tokens, which often doesn't happen. But since you really want to see the data round-tripped, most users don't care what the tree loos like internally.

=item to-string( Perl6::Element $tree ) returns Str

Call .perl6 on each element of the tree. You can subclass or override this method in any class as you see fit to properly pretty-print the methods. Right now it's awkward to use, and will probably be removed in favor of an upcoming L<Perl6::Tidy> module. That's why I wrote this yak.. er, module in the first place.

=item dump-tree( Perl6::Element $root ) returns Str

Given a Perl6::Document (or other) object, return a full nested tree of text detailing every single token, for debugging purposes.

=item ruler( Str $source )

Purely a debugging aid, it puts an ASCII ruler above your source so that you don't have to go blind counting whitespace to figure out which ' ' a given token belongs to. As a courtesy it also makes newlines visible so you don't have to count those separately. I might use the visible space character later to make it easier to read, if I happen to like it.

=end METHODS

=begin Further-Information

For further information, there's a L<DEBUGGING.pod> file detailing how to go about tracing down a bug in this module, and an extensive test suite in L<t/README.pod> with some ideas of how I'm structuring the test suite.

=end Further-Information

=end pod

use Perl6::Parser::Factory;

my role Debugging {

	method _interrogate-element( Perl6::Element $node ) {
		my @problem;
		if $node.WHAT.perl eq 'Perl6::Element' {
			@problem.push( Q{raw element} );
			return @problem;
		}
		unless $node.^can('is-leaf') {
			@problem.push( Q{no leaf test} );
			return @problem;
		}
		unless $node.^can('is-twig') {
			@problem.push( Q{no twig test} );
			return @problem;
		}
		unless $node.^can('from') {
			@problem.push( Q{no from} );
			return @problem;
		}
		unless $node.^can('to') {
			@problem.push( Q{no to} );
			return @problem;
		}

		@problem.push( Q{from} ) if $node.from < 0;
		@problem.push( Q{to} ) if $node.to < 0;
		@problem.push( Q{cross} ) if $node.from > $node.to;

		if $node.is-twig {
			given $node {
				when Perl6::Block {
					@problem.push( Q{structure start} ) if
						$node.child[0] !~~
							Perl6::Balanced::Enter;
					@problem.push( Q{structure end} ) if
						$node.child[*-1] !~~
							Perl6::Balanced::Exit;
				}
			}
		}
		elsif $node.is-leaf {
			@problem.push( Q{empty} ) if $node.from == $node.to;

			@problem.push( Q{short} ) if
				$node.to - $node.from < $node.content.chars;
			@problem.push( Q{long} ) if
				$node.to - $node.from > $node.content.chars;

			given $node {
				when Perl6::Comment | Perl6::String | Perl6::Sir-Not-Appearing-In-This-Statement { }
				when Perl6::WS | Perl6::Newline {
					@problem.push( Q{WS} ) if
						$node.content ~~ /\S/;
				}
				default {
					@problem.push( Q{WS} ) if
						$node.content ~~ /\s/;
					@problem.push( Q{EMPTY} ) if
						$node.content eq Q{};
				}
			}
		}
		else {
			@problem.push( Q{not tree member} );
		}
		@problem;
	}

	#constant indent = "\t";
	my constant indent = ' ';
	method _dump-tree( Perl6::Element $root,
			  Bool $display-ws = True,
			  Int $depth = 0 ) {
		my $str = ( indent xx $depth ) ~ self.dump-term( $root ) ~ "\n";
		if $root.is-twig {
			for ^$root.child {
				my @problem;
				@problem.append(
					self._interrogate-element(
						$root.child.[$_]
					)
				);

				# Mark the tokens that don't overlap.
				#
				if $root.child.[$_+1].defined and
					$root.child.[$_].to !=
					$root.child.[$_+1].from {
					@problem.push( 'G' )
				}
				$str ~= @problem.join( ' ' ) if @problem;
				$str ~= self._dump-tree(
					$root.child.[$_],
					$display-ws, $depth + 1
				)
			}
		}
		$str
	}

	method dump-tree( Perl6::Element $root,
			  Bool $display-ws = True,
			  Int $depth = 0 ) {
		my $str;

		for $.factory.here-doc.keys.sort -> $k {
			$str ~= "Here-Doc ($k-{$.factory.here-doc.{$k}})" ~
				"\n";
		}
		$str ~= self._dump-tree( $root, $display-ws, $depth );
		$str
	}

	method dump-term( Perl6::Element $term ) {
		my $line = $term.WHAT.perl;
		$line ~~ s/'Perl6::'//;

		if $term.is-leaf {
			if $term ~~ Perl6::Number {
				$line ~= " ({$term.content})"
			}
			# Circumfix operators don't have content.
			# Their children do.
			elsif $term ~~ Perl6::Operator::PostCircumfix or
			      $term ~~ Perl6::Operator::Circumfix {
			}
			else {
				$line ~= " ({$term.content.perl})"
			}
		}

		if $term.^can('from') and not (
				$term ~~ Perl6::Document | Perl6::Statement
			) {
			$line ~= " ({$term.from}-{$term.to})";
		}

		if $term.^can('here-doc') {
			$line ~= " <{$term.here-doc}>" if
				$term.here-doc and $term.here-doc ne '';
		}

		$line ~= " (line {$term.factory-line-number})" if
			$term.factory-line-number;
		if $term.is-end or !$term.next {
			$line ~= " -> END";
		}
		else {
			my $next = $term.next;
			my $name = $next.WHAT.perl;
			$name ~~ s/'Perl6::'//;
			my $next-bounds = "{$next.from}-{$next.to}";
			$line ~= " -> $name ($next-bounds)";
		}
		$line;
	}

	method ruler( Str $source ) {
		my Str $munged = substr( $source, 0, min( $source.chars, 72 ) );
		$munged ~= '...' if $source.chars > 72;
		my Int $blocks = $munged.chars div 10 + 1;
		$munged ~~ s:g{ \n } = Q{␤};
		my Str $nums = '';
		for ^$blocks {
			$nums ~= "         {$_+1}";
		}

		my $ruler = '';
		$ruler ~= '#' ~ ' ' ~ $nums ~ "\n";
		$ruler ~= '#' ~ ('0123456789' x $blocks) ~ "\n";
		$ruler ~= '#' ~ $munged ~ "\n";
	}
}

my role Testing {

	method _roundtrip( Str $source ) {
		my $tree      = self.to-tree( $source );
		my $formatted = self.to-string( $tree );

		$formatted
	}
}

my role Validating {

	method _consistency-check( Perl6::Element $node ) {
		my @problems = self._interrogate-element( $node );
		if @problems {
			$*ERR.say( @problems ~ ": " ~ $node.perl );
		}

		if $node.is-twig {
			if $node.child.elems > 1 {
				for $node.child.kv -> $index, $_ {
					self._consistency-check( $_ );

					next if $index == 0;
					if $node.child.[$index-1] ~~ Perl6::WS and
					   $node.child.[$index] ~~ Perl6::WS {
						$*ERR.say( "Two WS entries in a row" );
					}
					if $node.child.[$index-1].to !=
						$node.child.[$index].from {
						$*ERR.say( "Gap between two items" );
					}
				}
			}
		}
	}

	# Just in case we need to pass in parameters later on...
	# sigh.
	#
	method consistency-check( Perl6::Element $root ) {
		self._consistency-check( $root );
	}
}

my class CompleteIterator {
	also does Iterator;

	has Perl6::Element $.head;
	has Bool $.is-done = False;

	method pull-one {
		if $.head.is-end {
			if $.is-done {
				return IterationEnd;
			}
			else {
				$!is-done = True;
				return $.head;
			}
		}
		else {
			my $elem = $.head;
			$!head = $.head.next;
			$elem;
		}
	}

	method is-lazy { False }
}

my class TokenIterator {
	also does Iterator;

	has Perl6::Element $.head;
	has Bool $.is-done = False;

	method pull-one {
		if $.head.is-end-leaf {
			if $.is-done {
				return IterationEnd;
			}
			else {
				$!is-done = True;
				return $.head;
			}
		}
		else {
			my $elem = $.head;
			$!head = $.head.next;
			$!head = $!head.next while !$.head.is-leaf;
			$elem;
		}
	}

	method is-lazy { False }
}

my class Munge-Phasers {
	has @.munged-BEGIN;
	has @.munged-CHECK;

	method _munge-element( Perl6::Element $node ) {
		return unless $node.^can( 'content' );

		for @.munged-BEGIN -> $from {
			next unless $node.from <= $from <= $node.to;
			next unless $node.content.substr(
				$from - $node.from, 'BEGIN'.chars
			) eq 'ENTER';
			$node.content.substr-rw(
				$from - $node.from,
				#$from,
				'BEGIN'.chars
			) = 'BEGIN';
			last;
		}
		for @.munged-CHECK -> $from {
			next unless $node.from <= $from <= $node.to;
			next unless $node.content.substr(
				$from - $node.from, 'CHECK'.chars
			) eq 'ENTER';
			$node.content.substr-rw(
				$from - $node.from,
				'CHECK'.chars
			) = 'CHECK';
			last;
		}
	}

	method _munge-phasers( Perl6::Element $node ) {
		self._munge-element( $node );

		if $node.is-twig {
			for $node.child.kv -> $index, $_ {
				self._munge-phasers( $_ );
			}
		}
	}

	# Just in case we need to pass in parameters later on...
	# sigh.
	#
	method munge-phasers( Perl6::Element $root ) {
		return unless @.munged-BEGIN or @.munged-CHECK;
		self._munge-phasers( $root );
	}
}

class Perl6::Parser:ver<0.3.0> {
	also does Debugging;
	also does Testing;
	also does Validating;
	use nqp;

	has $.factory = Perl6::Parser::Factory.new;
	has @.munged-BEGIN;
	has @.munged-CHECK;

	# These could easily be a single method, but I'll separate them for
	# testing purposes.
	#
	method parse( Str $source ) {
		my $*LINEPOSCACHE;
		my $compiler := nqp::getcomp('Raku') || nqp::getcomp('perl6');
		my $g := nqp::findmethod(
			$compiler,'parsegrammar'
		)($compiler);
		#$g.HOW.trace-on($g);
		my $a := nqp::findmethod(
			$compiler,'parseactions'
		)($compiler);

		@.munged-BEGIN = ();
		my $munged-source = $source;
		$munged-source ~~ s:g{ 'BEGIN' } = 'ENTER';
		for @( $/ ) -> $BEGIN {
			@.munged-BEGIN.push: $BEGIN.from;
		}
		$munged-source ~~ s:g{ 'CHECK' } = 'ENTER';
		for @( $/ ) -> $CHECK {
			@.munged-CHECK.push: $CHECK.from;
		}
		my $parsed = $g.parse(
			$munged-source,
			:p( 0 ),
			:actions( $a )
		);

		$parsed;
	}

	method build-tree( Mu $parsed ) {
		my $tree   = $.factory.build( $parsed );
		my $munger = Munge-Phasers.new(
			:munged-BEGIN( @.munged-BEGIN ),
			:munged-CHECK( @.munged-CHECK ),
		);
		$munger.munge-phasers( $tree );
		self.consistency-check( $tree ) if
			$*CONSISTENCY-CHECK;
		$tree
	}

	method to-tree( Str $source ) {
		my $parsed = self.parse( $source );
		self.build-tree( $parsed );
	}

	method to-string( Perl6::Element $tree ) {
		my $str = $tree.to-string;

		$str;
	}

	method to-tokens-only( Str $source ) {
		my $tree = self.to-tree( $source );
		$.factory.thread( $tree );
		my $head = $.factory.flatten( $tree );
		$head = $head.next while !$head.is-leaf and !$head.is-end-leaf;

		Seq.new( TokenIterator.new( :head( $head ) ) );
	}

	method to-list( Str $source ) {
		my $tree = self.to-tree( $source );
		$.factory.thread( $tree );
		my $head = $.factory.flatten( $tree );

		Seq.new( CompleteIterator.new( :head( $head ) ) );
	}
}
