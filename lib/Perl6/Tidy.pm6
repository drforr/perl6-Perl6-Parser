=begin pod

=begin NAME

Perl6::Tidy - Extract a Perl 6 AST from the NQP Perl 6 Parser

=end NAME

=begin SYNOPSIS

    my $pt = Perl6::Tidy.new;
    my $parsed = $pt.tidy( Q:to[_END_] );
    say $parsed.perl6($format-settings); 
    my $other = $pt.tidy-file( 't/clean-me.t' );

    # This *will* execute phasers such as BEGIN in your existing code.
    # This may constitute a security hole, at least until the author figures
    # out how to truly make the Perl 6 grammar standalone.

=end SYNOPSIS

=begin DESCRIPTION

Uses the built-in Perl 6 parser exposed by the nqp module in order to parse Perl 6 from within Perl 6. If this scares you, well, it probably should. Once this is finished, you should be able to call C<.perl6> on the tidied output, along with a so-far-unspecified formatting object, and get back nicely-formatted Perl 6 code.

Please B<please> note that this, out of necessity, does compile your Perl 6 code, which B<does> mean executing phasers such as C<BEGIN>. There may be a way to oerride this behavior, and if you have suggestions that don't involve rewriting the Perl 6 grammar as a standalone library (which would not be such a bad idea in general) then please let the author know.

As it stands, the C<.tidy> method returns a deeply-nested object representation of the Perl 6 code it's given. It handles the regex language, but not the other braided languages such as embedded blocks in strings. It will do so eventually, but for the moment I'm busy getting the grammar rules covered.

While classes like L<EClass> won't go away, their parent classes like L<DecInteger> will remove them from the tree once their validation job has been done. For example, while the internals need to know that L<< $/<eclass> >> (the exponent for a scientific-notation number) hasn't been renamed or moved elsewhere in the tree, you as a consumer of the L<DecInteger> class don't need to know that. The C<DecInteger.perl6> method will delete the child classes so that we don't end up with a B<horribly> cluttered tree.

Classes representing Perl 6 object code are currently in the same file as the main L<Perl6::Tidy> class, as moving them to separate files caused a severe performance penalty. When the time is right I'll look at moving these to another location, but as shuffling out 20 classes increased my runtime on my little ol' VM from 6 to 20 seconds, it's not worth my time to break them out. And besides, having them all in one file makes editing en masse easier.

=end DESCRIPTION

=begin DEBUGGING

Some notes on how I go about debugging various issues follow.

Let's take the case of the following glitch: The terms C<$_> and C<0> don't show up in the fragment C<[$_, 0 .. 100]>, for various reasons, mostly because there's a branch that's either not being traversed, or simply a term has gone missing.

The first thing is to break the offending bit of code out so it's easier to debug. The test file I make to do this (usually an existing test file I've got lying around) looks partially like this, with boilerplate stripped out:

    my $source = Q:to[_END_];
        my @a; @a[$_, 0 .. 100];
    _END_
    my $p = $pt.parse-source( $source );
    say $p.dump;
    my $tree = $pt.build-tree( $p );
    say $pt.dump-tree($tree);
    ok $pt.validate( $p ), Q{valid};
    is $pt.format( $tree ), $source, Q{formatted};

Already a few things might stand out. First, the code inside the here-doc doesn't actually do anything, it'll never print anything to the screen or do anything interesting. That's not the point at this stage in the game. At this point all I need is a syntactically valid bit of Perl 6 that has the constructs that reproduce the bug. I don't care what the code actually does in the real world.

Second, I'm not doing anything that you as a user of the class would do. As a user of a the class, all you have to do is run the format() method, and it does what you want. I'm breaking things down into their component steps.

(side note - This will probably have changed in detail since I wrote this text - Consult your nearest test file for examples of current usage.)

Internally, the library takes sevaral steps to get to the nicely objectified tree that you see on your output. The two important steps in our case are the C<.parse-source( 'text goes here' )> method call, and C<.build-tree( $parse-tree )>.

The C<.parse-source()> call returns a very raw L<NQPMatch> object, which is the Perl 6 internal we're trying to reparse into a more useful form. Most of the time you can call C<.dump()> on this object and get back a semi-useful object tree. On occasion this B<will> lock up, most often because you're trying to C<.dump()> a L<list> accessor, and that hasn't been implemented for NQPMatch. The actual C<list> accessor works, but the C<.dump()> call will not. A simple workaround is to call C<$p.list.[0].dump> on one of the list elements inside, and hope there is one.

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

=item tidy( Str $perl-code ) returns Perl6::Tidy::Root

Given a Perl 6 code string, return the class structure, so you can see the parse tree in action. This is mostly because the internal L<Perl6::Tidy> objects are poorly named.

=item perl6( Hash %format-settings ) returns Str

Given a so-far undefined hash of format settings, return formatted Perl 6 code to meet the user's expectations.

=end METHODS

=end pod

use Perl6::Tidy::Validator;
use Perl6::Tidy::Factory;

class Perl6::Tidy {
	use nqp;

	# These could easily be a single method, but I'll separate them for
	# testing purposes.
	#
	method parse-source( Str $source ) {
		my $*LINEPOSCACHE;
		my $compiler := nqp::getcomp('perl6');
		my $g := nqp::findmethod($compiler,'parsegrammar')($compiler);
		#$g.HOW.trace-on($g);
		my $a := nqp::findmethod($compiler,'parseactions')($compiler);

		my $parsed = $g.parse(
			$source,
			:p( 0 ),
			:actions( $a )
		);

		return $parsed
	}

	method validate( Mu $parsed ) {
		my $validator = Perl6::Tidy::Validator.new;
		my $res       = $validator.validate( $parsed );

		die "Validation failed!" if !$res and %*ENV<AUTHOR_TESTS>;

		$res
	}

	method build-tree( Mu $parsed ) {
		my $factory = Perl6::Tidy::Factory.new;
		my $tree    = $factory.build( $parsed );

		self.check-tree( $tree );
		$tree
	}

	method check-tree( Perl6::Element $root ) {
		if $root ~~ Perl6::Block {
			unless $root.child.[0] ~~ Perl6::Structural {
				say $root.perl;
				die "First element of block not structural"
			}
			unless $root.child.[*-1] ~~ Perl6::Structural {
				say $root.perl;
				die "Last element of block not structural"
			}
		}
		if $root.^can('child') {
			for $root.child {
				self.check-tree( $_ );
				unless $_.^can('from') {
					say $_.perl;
					note "Element in list does not have 'from' accessor"
				}
			}
			if $root.child.elems > 1 {
				for $root.child.kv -> $index, $_ {
					next if $index == 0;
					next unless $root.child.[$index-1].^can('to');
					next unless $root.child.[$index].^can('from');
					if $root.child.[$index-1] ~~ Perl6::WS and
					   $root.child.[$index] ~~ Perl6::WS {
#						say $root.child.[$index-1].perl;
#						say $root.child.[$index].perl;
						say "Two WS entries in a row"
					}
					if $root.child.[$index-1].to !=
						$root.child.[$index].from {
#						say $root.child.[$index-1].perl;
#						say $root.child.[$index].perl;
						say "Gap between two items"
					}
				}
			}
		}
		if $root.^can('content') {
			if $root.content.chars < $root.to - $root.from {
				say $root.perl;
				warn "Content '{$root.content}' too short for element ({$root.from} - {$root.to}) ({$root.to - $root.from} chars)"
			}
			if $root.content.chars > $root.to - $root.from {
				say $root.perl;
				warn "Content '{$root.content}' too long for element ({$root.from} - {$root.to}) ({$root.to - $root.from} glyphs}"
			}
			if $root !~~ Perl6::WS and
					$root !~~ Perl6::Sir-Not-Appearing-In-This-Statement and
					$root.content ~~ m{ ^ (\s+) } {
				say $root.perl;
				warn "Content '{$root.content}' has leading whitespace"
			}
			if $root !~~ Perl6::WS and
					$root.content ~~ m{ (\s+) $ } {
				say $root.perl;
				warn "Content '{$root.content}' has trailing whitespace"
			}
		}
	}

	method format( $tree, $formatting = { } ) {
		my $str = $tree.perl6( $formatting );

		$str
	}

	method dump-term( Perl6::Element $term ) {
		my $str = $term.WHAT.perl;
		if $term ~~ Perl6::Operator::PostCircumfix or
		      $term ~~ Perl6::Operator::Circumfix {
		}
		elsif $term ~~ Perl6::Bareword or
		      $term ~~ Perl6::Variable or
		      $term ~~ Perl6::Operator or
		      $term ~~ Perl6::Balanced or
		      $term ~~ Perl6::WS {
			$str ~= " ({$term.content.perl})"
		}
		elsif $term ~~ Perl6::Number {
			$str ~= " ({$term.content})"
		}
		elsif $term ~~ Perl6::String {
#			$str ~= " ({$term.content}) ('{$term.bare}')"
			$str ~= " ({$term.content})"
		}

		if $term.^can('from') and not (
				$term ~~ Perl6::Document | Perl6::Statement
			) {
			$str ~= " ({$term.from}-{$term.to})";
		}

		$str ~= " (line {$term.factory-line-number})" if
			$term.factory-line-number;
		$str
	}

	method dump-tree( Perl6::Element $root,
			  Bool $display-ws = True,
			  Int $depth = 0 ) {
		return '' if $root ~~ Perl6::WS and !$display-ws;
		my $str = ( "\t" xx $depth ) ~ self.dump-term( $root ) ~ "\n";
		if $root.^can('child') {
			for ^$root.child {
				my @problem;
				# Mark the tokens that don't overlap.
				#
				if $root.child.[$_+1].defined and
					$root.child.[$_].to !=
					$root.child.[$_+1].from {
					@problem.push( 'G' )
				}
				if $root.child.[$_].^can( 'content' ) {
					if $root.child.[$_] ~~ Perl6::WS and
					   $root.child.[$_].content ~~ / \S / {
						@problem.push( 'WS' )
					}
					if $root.child.[$_] !~~ Perl6::WS and
					   $root.child.[$_].content ~~ / \s / {
						@problem.push( 'WS' )
					}
				}
				$str ~= @problem.join( ' ' ) if @problem;
				$str ~= self.dump-tree(
					$root.child.[$_],
					$display-ws, $depth + 1
				)
			}
		}
		$str
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

	method tidy( Str $source, $formatting = { } ) {
		my $parsed    = self.parse-source( $source );
		my $valid     = self.validate( $parsed );
		my $tree      = self.build-tree( $parsed );
		my $formatted = self.format( $tree, $formatting );

		$formatted
	}
}
