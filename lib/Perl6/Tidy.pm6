class Perl6::Tidy {
	use nqp;

	has $.debugging = False;

	# convert-hex-integers is just a sample.
	role Formatter {
		has Bool $.convert-hex-integers = False;
	}

	method tidy( Str $text ) {
		my $compiler := nqp::getcomp('perl6');
		my $g := nqp::findmethod($compiler,'parsegrammar')($compiler);
		#$g.HOW.trace-on($g);
		my $a := nqp::findmethod($compiler,'parseactions')($compiler);

		my $root = $g.parse( $text, :p( 0 ), :actions( $a ) );
		die "root is not a hash"
			unless $root.hash;
		die "root does not have a statementlist"
			unless $root.hash.<statementlist>;

		my $statementlist =
			self.statementlist( $root.hash.<statementlist> );
say $statementlist.perl;
	}

	class StatementList is Formatter {
		has $.statement;
	}

	method root( Mu $parsed ) {
say "Root:\n" ~ $parsed.dump if $.debugging;
		die "root is not a hash"
			unless $parsed.hash;
		die "root does not have a statementlist"
			unless $parsed.hash.<statementlist>;

		self.statementlist( $parsed.hash.<statementlist> )
	}

	class Statement is Formatter {
		has @.items;
	}

	method statementlist( Mu $parsed ) {
say "statementlist:\n" ~ $parsed.dump if $.debugging;
		die "statementlist is not a hash"
			unless $parsed.hash;
		die "statementlist does not have a statement"
			unless $parsed.hash.<statement>;

		self.statement( $parsed.hash.<statement> )
	}

	method statement( Mu $parsed ) {
		die "statement is not a list"
			unless $parsed.list;

		my @items;
		for $parsed.list {
say "statement[]:\n" ~ $_.dump if $.debugging;
			die "statement is not a hash"
				unless $_.hash;
			die "statement has no EXPR"
				unless $_.hash.<EXPR>;

			my $expr = self.EXPR( $_.hash.<EXPR> );
			@items.push( $expr )
		}
		Statement.new( :items(
			@items
		) )
	}

	class EXPR is Formatter {
		has @.items;
	}

	method EXPR( Mu $parsed ) {
say "EXPR:\n" ~ $parsed.dump if $.debugging;
		die "EXPR is not a hash"
			unless $parsed.hash;

		if $parsed.hash.<longname> and
		   $parsed.hash.<args> {
			self.args( $parsed.hash.<args> )
		}
		elsif $parsed.hash.<value> {
			self.value( $parsed.hash.<value> )
		}
		elsif $parsed.list {
			my @items;
			for $parsed.list {
				my $item = self.EXPR-item( $_ );
				@items.push( $item )
			}
			EXPR.new( :items(
				@items
			) )
		}
	}

	method EXPR-item( Mu $parsed ) {
say "EXPR-item:\n" ~ $parsed.dump if $.debugging;
		die "EXPR-item is not a hash"
			unless $parsed.hash;
		die "EXPR-item does not have a value"
			unless $parsed.hash.<value>;
			
		self.value( $parsed.hash.<value> )
	}

	method value( Mu $parsed ) {
say "value:\n" ~ $parsed.dump if $.debugging;
		die "value is not a hash"
			unless $parsed.hash;

		if $parsed.hash.<quote> {
			self.quote( $parsed.hash.<quote> )
		}
		elsif $parsed.hash.<number> {
			self.number( $parsed.hash.<number> )
		}
		else {
die "uncaught type";
		}
	}

	class Quote does Formatter {
		has $.value
	}

	method quote( Mu $parsed ) {
say "quote:\n" ~ $parsed.dump if $.debugging;
		die "quote is not a hash"
			unless $parsed.hash;
		die "quote does not have a nibble"
			unless $parsed.hash.<nibble>;

		self.nibble( $parsed.hash.<nibble> )
	}

	class Nibble does Formatter {
		has $.value
	}

	method nibble( Mu $parsed ) {
say "nibble:\n" ~ $parsed.Str if $.debugging;
say "End of Line." if $.debugging;

		Nibble.new( :value(
			$parsed.Str
		) )
	}

	method number( Mu $parsed ) {
say "number:\n" ~ $parsed.dump if $.debugging;
		die "number is not a hash"
			unless $parsed.hash;
		die "number does not have a numish"
			unless $parsed.hash.<numish>;

		self.numish( $parsed.hash.<numish> )
	}

	method numish( Mu $parsed ) {
say "numish:\n" ~ $parsed.dump if $.debugging;
		die "numish is not a hash"
			unless $parsed.hash;
		die "numish does not have an integer"
			unless $parsed.hash.<integer>;

		self.integer( $parsed.hash.<integer> )
	}

	method integer( Mu $parsed ) {
say "integer:\n" ~ $parsed.dump if $.debugging;
		die "integer is not a hash"
			unless $parsed.hash;

		if $parsed.hash.<decint> {
			self.decint( $parsed.hash.<decint> )
		}
		elsif $parsed.hash.<hexint> {
			self.hexint( $parsed.hash.<hexint> )
		}
		else {
die "uncaught type";
		}
	}

	class DecInt does Formatter {
		has $.value;
	}

	method decint( Mu $parsed ) {
say "decint:\n" ~ $parsed.Int if $.debugging;
say "End of Line." if $.debugging;

		$parsed.Int
	}

	class HexInt does Formatter {
		has $.value;
	}

	method hexint( Mu $parsed ) {
say "hexint:\n" ~ $parsed.Int if $.debugging;
say "End of Line." if $.debugging;

		HexInt.new( :value(
			$parsed.Int
		) )
	}

	method args( Mu $parsed ) {
say "args:\n" ~ $parsed.dump if $.debugging;
		die "args is not a hash"
			unless $parsed.hash;
		die "args does not have an arglist"
			unless $parsed.hash.<arglist>;

		self.arglist( $parsed.hash.<arglist> )
	}

	method arglist( Mu $parsed ) {
say "arglist:\n" ~ $parsed.dump if $.debugging;
		die "arglist is not a hash"
			unless $parsed.hash;
		die "arglist does not have an EXPR"
			unless $parsed.hash.<EXPR>;

		self.EXPR( $parsed.hash.<EXPR> )
	}
}
