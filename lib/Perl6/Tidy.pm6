class Perl6::Tidy {
	use nqp;

	method tidy( Str $text ) {
		my $compiler := nqp::getcomp('perl6');
		my $g := nqp::findmethod($compiler,'parsegrammar')($compiler);
		#$g.HOW.trace-on($g);
		my $a := nqp::findmethod($compiler,'parseactions')($compiler);

		my $root = $g.parse( $text, :p( 0 ), :actions( $a ) );
		self.root( $root )
	}

	method root( Mu $parsed ) {
say "Root:\n" ~ $parsed.dump;
		die "root is not a hash"
			unless $parsed.hash;
		die "root does not have a statementlist"
			unless $parsed.hash.<statementlist>;

		self.statementlist( $parsed.hash.<statementlist> )
	}

	method statementlist( Mu $parsed ) {
say "statementlist:\n" ~ $parsed.dump;
		die "statementlist is not a hash"
			unless $parsed.hash;
		die "statementlist does not have a statement"
			unless $parsed.hash.<statement>;

		self.statement( $parsed.hash.<statement> )
	}

	method statement( Mu $parsed ) {
		die "statement is not a list"
			unless $parsed.list;

		for $parsed.list -> $statement {
say "statement[]:\n" ~ $statement.dump;
			die "statement is not a hash"
				unless $statement.hash;
			die "statement has no EXPR"
				unless $statement.hash.<EXPR>;

			self.EXPR( $statement.hash.<EXPR> )
		}
	}

	method EXPR( Mu $parsed ) {
say "EXPR:\n" ~ $parsed.dump;
		die "EXPR is not a hash"
			unless $parsed.hash;

		if $parsed.hash.<longname> and
		   $parsed.hash.<args> {
			self.args( $parsed.hash.<args> )
		}
elsif $parsed.list {
	for $parsed.list -> $arg {
		self.EXPR-item( $arg )
	}
}
	}

	method EXPR-item( Mu $parsed ) {
say "EXPR-item:\n" ~ $parsed.dump;
		die "EXPR-item is not a hash"
			unless $parsed.hash;
		die "EXPR-item does not have a value"
			unless $parsed.hash.<value>;
			
		self.value( $parsed.hash.<value> )
	}

	method value( Mu $parsed ) {
say "value:\n" ~ $parsed.dump;
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

	method quote( Mu $parsed ) {
say "quote:\n" ~ $parsed.dump;
		die "quote is not a hash"
			unless $parsed.hash;
		die "quote does not have a nibble"
			unless $parsed.hash.<nibble>;

		self.nibble( $parsed.hash.<nibble> )
	}

	method nibble( Mu $parsed ) {
say "nibble:\n" ~ $parsed.Str;
say "End of Line.";
	}

	method number( Mu $parsed ) {
say "number:\n" ~ $parsed.dump;
		die "number is not a hash"
			unless $parsed.hash;
		die "number does not have a numish"
			unless $parsed.hash.<numish>;

		self.numish( $parsed.hash.<numish> )
	}

	method numish( Mu $parsed ) {
say "numish:\n" ~ $parsed.dump;
		die "numish is not a hash"
			unless $parsed.hash;
		die "numish does not have an integer"
			unless $parsed.hash.<integer>;

		self.integer( $parsed.hash.<integer> )
	}

	method integer( Mu $parsed ) {
say "integer:\n" ~ $parsed.dump;
		die "integer is not a hash"
			unless $parsed.hash;

		if $parsed.hash.<decint> {
			self.decint( $parsed.hash.<decint> )
		}
		else {
die "uncaught type";
		}
	}

	method decint( Mu $parsed ) {
say "decint:\n" ~ $parsed.Int;
say "End of Line.";
	}

	method args( Mu $parsed ) {
say "args:\n" ~ $parsed.dump;
		die "args is not a hash"
			unless $parsed.hash;
		die "args does not have an arglist"
			unless $parsed.hash.<arglist>;

		self.arglist( $parsed.hash.<arglist> )
	}

	method arglist( Mu $parsed ) {
say "arglist:\n" ~ $parsed.dump;
		die "arglist is not a hash"
			unless $parsed.hash;
		die "arglist does not have an EXPR"
			unless $parsed.hash.<EXPR>;

		self.EXPR( $parsed.hash.<EXPR> )
	}







	my class StatementList {
	}
























#`(

	sub g-root( Mu $parsed ) {

		# Test structure at each point, that way we raise failures as
		# early as possible.
		#
		die "document root is not a hash"
			unless $parsed.hash;
		die "document root has no statementlist"
			unless $parsed.hash.<statementlist>;

		g-statementlist( $parsed.hash.<statementlist> );
	}

# Just keep on breaking it down.
# Keep in mind that for:
#
# class, token, rule, regex, module
#
# you can create a mixin Role NamedBlock {} that has a perl6() method
# that generically requires a $.name and a $.type, and spits back
# "$.type $.name { @content }" or the like.
#
# For the unions like below...
#
# Drop the generic EXPR, and have it return the typed value for now.
#
# Yes, may have to rejigger things into a DOM-ish layer for easier use for
# later, but for now just give this a try.

	class EXPR {
		has $.longname;
		has $.args;
		has $.value;
	}

	sub g-EXPR( Mu $parsed ) {

		die "EXPR is not a hash"
			unless $parsed.hash;
		if $parsed.hash.<longname> {
			die "EXPR's longname is not a Str"
				unless $parsed.hash.<longname>.Str;
		}
		if $parsed.hash.<args> {
			die "EXPR's args is not a hash"
				unless $parsed.hash.<args>.hash;
		}

# Not looking further into hash.<longname>
return EXPR.new(
#	:longname( $parsed.hash.<longname>.Str ),
);
	}

	class Statement {
		has $.EXPR;
	}

	# 0-19, and 21-43, so 
	sub g-statement( Mu $parsed ) {

		die "statement is not a hash"
			unless $parsed.hash;
		die "statement has no EXPR"
			unless $parsed.hash.<EXPR>;
say "from [{$parsed.from}] to [{$parsed.to}], orig [{$parsed.orig.chars}]";
say $parsed.dump;

		my $EXPR = g-EXPR( $parsed.hash.<EXPR> );
return Statement.new( :EXPR( $EXPR ) );
	}

	class StatementList {
		has @.statement;
	}

	# statementlist matches the entire text block, apparently.
	#
	sub g-statementlist( Mu $parsed ) {

		die "statementlist is not a hash"
			unless $parsed.hash;
		die "statementlist has no statement"
			unless $parsed.hash.<statement>;

		my @statement = map { g-statement( $_ ) }, 
			$parsed.hash.<statement>.list;

say "from [{$parsed.from}] to [{$parsed.to}], orig [{$parsed.orig.chars}]";
return StatementList.new( :statement( @statement ) );
	}
)
}
