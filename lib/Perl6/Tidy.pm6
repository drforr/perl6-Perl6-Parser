class Perl6::Tidy {
	use nqp;

	method tidy( Str $text ) {
		my $compiler := nqp::getcomp('perl6');
		my $g := nqp::findmethod($compiler,'parsegrammar')($compiler);
		#$g.HOW.trace-on($g);
		my $a := nqp::findmethod($compiler,'parseactions')($compiler);

		my $parsed = $g.parse( $text, :p( 0 ), :actions( $a ) );
say "Root: \n" ~ $parsed.dump;

		g-root( $parsed );
	}

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
}
