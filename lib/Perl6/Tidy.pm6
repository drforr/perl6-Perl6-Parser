class Perl6::Tidy {
	use nqp;

	has $.debugging = False;

#`(
	method boilerplate( Mu $parsed ) {
		if $parsed.list {
			die "statementlist: list"
		}
		elsif $parsed.hash {
			say "boilerplate:\n" ~ $parsed.dump if $.debugging;
			die "statementlist: hash"
		}
		elsif $parsed.Int {
			die "statementlist: Int"
		}
		elsif $parsed.Str {
			die "statementlist: Str"
		}
		elsif $parsed.Bool {
			die "statementlist: Bool"
		}
		else {
			die "statementlist: Unknown type"
		}
	}
)

	# convert-hex-integers is just a sample.
	role Formatter {
	}

	method tidy( Str $text ) {
		my $compiler := nqp::getcomp('perl6');
		my $g := nqp::findmethod($compiler,'parsegrammar')($compiler);
		#$g.HOW.trace-on($g);
		my $a := nqp::findmethod($compiler,'parseactions')($compiler);

		my $parsed = $g.parse( $text, :p( 0 ), :actions( $a ) );

		say "boilerplate:\n" ~ $parsed.dump if $.debugging;
		if $parsed.list {
			die "tidy: list"
		}
		elsif $parsed.hash {
			if $parsed.hash.<statementlist> {
				self.statementlist(
					$parsed.hash.<statementlist>
				);
			}
			else {
				die "tidy: hash"
			}
		}
		elsif $parsed.Int {
			die "tidy: Int"
		}
		elsif $parsed.Str {
			die "tidy: Str"
		}
		elsif $parsed.Bool {
			die "tidy: Bool"
		}
		else {
			die "tidy: Unknown type"
		}
	}

	role Formatted { }

	class StatementList is Formatted {
		has @.statement;
	}

	method statementlist( Mu $parsed ) {
		if $parsed.list {
			die "statementlist: list"
		}
		elsif $parsed.hash {
			say "statementlist:\n" ~ $parsed.dump if $.debugging;
			if $parsed.hash.<statement> {
				my @statement;
				for $parsed.hash.<statement> {
					@statement.push(
						self.statement( $_ )
					)
				}
				StatementList.new(
					:statement(
						@statement
					)
				)
			}
			else {
				StatementList.new
			}
		}
		elsif $parsed.Int {
			die "statementlist: Int"
		}
		elsif $parsed.Str {
			die "statementlist: Str"
		}
		elsif $parsed.Bool {
			StatementList.new
		}
		else {
			die "statementlist: Unknown type"
		}
	}

	method statement( Mu $parsed ) {
		if $parsed.list {
			die "statementlist: list"
		}
		elsif $parsed.hash {
			say "statement:\n" ~ $parsed.dump if $.debugging;
			if $parsed.hash.<EXPR> {
				self.EXPR( $parsed.hash.<EXPR> )
			}
			else {
				die "statementlist: hash"
			}
		}
		elsif $parsed.Int {
			die "statementlist: Int"
		}
		elsif $parsed.Str {
			die "statementlist: Str"
		}
		elsif $parsed.Bool {
			die "statementlist: Bool"
		}
		else {
			die "statementlist: Unknown type"
		}
	}

	method EXPR( Mu $parsed ) {
		if $parsed.list {
			die "EXPR: list"
		}
		elsif $parsed.hash {
			say "EXPR:\n" ~ $parsed.dump if $.debugging;
			if $parsed.hash.<value> {
				self.value( $parsed.hash.<value> )
			}
			else {
				die "EXPR: Unknown key"
			}
		}
		elsif $parsed.Int {
			die "EXPR: Int"
		}
		elsif $parsed.Str {
			die "EXPR: Str"
		}
		elsif $parsed.Bool {
			die "EXPR: Bool"
		}
		else {
			die "EXPR: Unknown type"
		}
	}

	method value( Mu $parsed ) {
		if $parsed.list {
			die "value: list"
		}
		elsif $parsed.hash {
			say "value:\n" ~ $parsed.dump if $.debugging;
			if $parsed.hash.<number> {
				self.number( $parsed.hash.<number> )
			}
			elsif $parsed.hash.<quote> {
				self.quote( $parsed.hash.<quote> )
			}
			else {
				die "value: Unknown key"
			}
		}
		elsif $parsed.Int {
			die "value: Int"
		}
		elsif $parsed.Str {
			die "value: Str"
		}
		elsif $parsed.Bool {
			die "value: Bool"
		}
		else {
			die "value: Unknown type"
		}
	}

	method number( Mu $parsed ) {
		if $parsed.list {
			die "number: list"
		}
		elsif $parsed.hash {
			say "number:\n" ~ $parsed.dump if $.debugging;
			if $parsed.hash.<numish> {
				self.numish( $parsed.hash.<numish> )
			}
			else {
				die "number: Unknown key"
			}
		}
		elsif $parsed.Int {
			die "number: Int"
		}
		elsif $parsed.Str {
			die "number: Str"
		}
		elsif $parsed.Bool {
			die "number: Bool"
		}
		else {
			die "number: Unknown type"
		}
	}

	method quote( Mu $parsed ) {
		if $parsed.list {
			die "quote: list"
		}
		elsif $parsed.hash {
			say "quote:\n" ~ $parsed.dump if $.debugging;
			if $parsed.hash.<nibble> {
				self.nibble( $parsed.hash.<nibble> )
			}
			else {
				die "quote: Unknown key"
			}
		}
		elsif $parsed.Int {
			die "quote: Int"
		}
		elsif $parsed.Str {
			die "quote: Str"
		}
		elsif $parsed.Bool {
			die "quote: Bool"
		}
		else {
			die "quote: Unknown type"
		}
	}

	method nibble( Mu $parsed ) {
		if $parsed.list {
			die "nibble: list"
		}
		elsif $parsed.hash {
			say "nibble:\n" ~ $parsed.dump if $.debugging;
			die "nibble: Unknown key"
		}
		elsif $parsed.Int {
			die "nibble: Int"
		}
		elsif $parsed.Str {
			$parsed.Str
		}
		elsif $parsed.Bool {
			die "nibble: Bool"
		}
		else {
			die "nibble: Unknown type"
		}
	}

	method numish( Mu $parsed ) {
		if $parsed.list {
			die "numish: list"
		}
		elsif $parsed.hash {
			say "numish:\n" ~ $parsed.dump if $.debugging;
			if $parsed.hash.<integer> {
				self.integer( $parsed.hash.<integer> )
			}
			elsif $parsed.hash.<rad_number> {
				self.rad_number( $parsed.hash.<rad_number> )
			}
			else {
				die "numish: Unknown key"
			}
		}
		elsif $parsed.Int {
			die "numish: Int"
		}
		elsif $parsed.Str {
			die "number: Str"
		}
		elsif $parsed.Bool {
			die "numish: Bool"
		}
		else {
			die "numish: Unknown type"
		}
	}

	method integer( Mu $parsed ) {
		if $parsed.list {
			die "integer: list"
		}
		elsif $parsed.hash {
			say "integer:\n" ~ $parsed.dump if $.debugging;
			if $parsed.hash.<decint> {
				self.decint( $parsed.hash.<decint> )
			}
			elsif $parsed.hash.<binint> {
				self.binint( $parsed.hash.<binint> )
			}
			elsif $parsed.hash.<octint> {
				self.octint( $parsed.hash.<octint> )
			}
			elsif $parsed.hash.<hexint> {
				self.hexint( $parsed.hash.<hexint> )
			}
			else {
				die "integer: Unknown key"
			}
		}
		elsif $parsed.Int {
			die "integer: Int"
		}
		elsif $parsed.Str {
			die "integer: Str"
		}
		elsif $parsed.Bool {
			die "integer: Bool"
		}
		else {
			die "integer: Unknown type"
		}
	}

	method circumfix( Mu $parsed ) {
		if $parsed.list {
			die "circumfix: list"
		}
		elsif $parsed.hash {
			say "circumfix:\n" ~ $parsed.dump if $.debugging;
			if $parsed.hash.<semilist> {
				self.semilist( $parsed.hash.<semilist> )
			}
			else {
				die "circumfix: Unknown key"
			}
		}
		elsif $parsed.Int {
			die "circumfix: Int"
		}
		elsif $parsed.Str {
			die "circumfix: Str"
		}
		elsif $parsed.Bool {
			die "circumfix: Bool"
		}
		else {
			die "circumfix: Unknown type"
		}
	}

	method semilist( Mu $parsed ) {
		if $parsed.list {
			die "semilist: list"
		}
		elsif $parsed.hash {
			say "semilist:\n" ~ $parsed.dump if $.debugging;
			if $parsed.hash.<statement> {
				self.statement( $parsed.hash.<statement> )
			}
			else {
				die "semilist: Unknown key"
			}
		}
		elsif $parsed.Int {
			die "semilist: Int"
		}
		elsif $parsed.Str {
			die "semilist: Str"
		}
		elsif $parsed.Bool {
			die "semilist: Bool"
		}
		else {
			die "semilist: Unknown type"
		}
	}

	method rad_number( Mu $parsed ) {
		if $parsed.list {
			die "rad_number: list"
		}
		elsif $parsed.hash {
			say "rad_number:\n" ~ $parsed.dump if $.debugging;
			if $parsed.hash.<circumfix> {
				self.circumfix( $parsed.hash.<circumfix> )
			}
			else {
				die "rad_number: Unknown key"
			}
		}
		elsif $parsed.Int {
			die "rad_number: Int"
		}
		elsif $parsed.Str {
			die "rad_number: Str"
		}
		elsif $parsed.Bool {
			die "rad_number: Bool"
		}
		else {
			die "rad_number: Unknown type"
		}
	}

	method binint( Mu $parsed ) {
		if $parsed.list {
			die "binint: list"
		}
		elsif $parsed.hash {
			say "binint:\n" ~ $parsed.dump if $.debugging;
			die "binint: hash"
		}
		elsif $parsed.Int {
			$parsed.Int
		}
		elsif $parsed.Str {
			die "binint: Str"
		}
		elsif $parsed.Bool {
			die "binint: Bool"
		}
		else {
			die "binint: Unknown type"
		}
	}

	method octint( Mu $parsed ) {
		if $parsed.list {
			die "octint: list"
		}
		elsif $parsed.hash {
			say "octint:\n" ~ $parsed.dump if $.debugging;
			die "octint: hash"
		}
		elsif $parsed.Int {
			$parsed.Int
		}
		elsif $parsed.Str {
			die "octint: Str"
		}
		elsif $parsed.Bool {
			die "octint: Bool"
		}
		else {
			die "octint: Unknown type"
		}
	}

	method decint( Mu $parsed ) {
		if $parsed.list {
			die "decint: list"
		}
		elsif $parsed.hash {
			say "decint:\n" ~ $parsed.dump if $.debugging;
			die "decint: hash"
		}
		elsif $parsed.Int {
			$parsed.Int
		}
		elsif $parsed.Str {
			die "decint: Str"
		}
		elsif $parsed.Bool {
			die "decint: Bool"
		}
		else {
			die "decint: Unknown type"
		}
	}

	method hexint( Mu $parsed ) {
		if $parsed.list {
			die "hexint: list"
		}
		elsif $parsed.hash {
			say "hexint:\n" ~ $parsed.dump if $.debugging;
			die "hexint: hash"
		}
		elsif $parsed.Int {
			$parsed.Int
		}
		elsif $parsed.Str {
			die "hexint: Str"
		}
		elsif $parsed.Bool {
			die "hexint: Bool"
		}
		else {
			die "hexint: Unknown type"
		}
	}

#`(
	method EXPR( Mu $parsed ) {
		self.assert-hash( 'EXPR', $parsed, {
			if $parsed.hash.<longname> and
			   $parsed.hash.<args> {
				self.longname-args(
					$parsed.hash.<longname>,
					$parsed.hash.<args>
				)
			}
			elsif $parsed.hash.<identifier> and
			      $parsed.hash.<args> {
				self.identifier-args(
					$parsed.hash.<identifier>,
					$parsed.hash.<args>
				)
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
				EXPR.new(
					:items(
						@items
					)
				)
			}
			else {
die "EXPR: Unknown type"
			}
		} )
	}


	class LongnameArgs does Formatter {
		has $.longname;
		has @.args;
	}

	method longname-args( Mu $longname, Mu $args ) {
		self.assert-Str( 'longname', $longname );
		self.assert-hash-key( 'args', 'arglist', $args, {
			LongnameArgs.new(
				:longname(
					$longname.Str
				),
				:args(
					self.args( $args )
				)
			)
		} )
	}

	class IdentifierArgs does Formatter {
		has $.identifier;
		has @.semiarglist;
	}

	method identifier-args( Mu $identifier, Mu $semiarglist ) {
		self.assert-Str( 'identifier', $identifier );
		self.assert-hash-key( 'identifier-args', 'semiarglist', $semiarglist, {
			IdentifierArgs.new(
				:identifier(
					$identifier.Str
				),
				:semiarglist(
					self.semiarglist( $semiarglist.hash.<semiarglist> )
				)
			)
		} )
	}

	method arglist( Mu $parsed ) {
		if $parsed.list {
			self.assert-list( 'arglist', $parsed, {
				my @items;
				for $parsed.list {
					self.assert-hash-with-key( 'arglist','EXPR', $_, {
							my $expr = self.EXPR( $_.hash.<EXPR> );
							@items.push( $expr )
					} );
				}
				EXPR.new(
					:items(
						@items
					)
				)
			} )
		}
		elsif $parsed.hash {
			if $parsed.hash.<EXPR> {
				self.assert-hash-key( 'arglist', 'EXPR', $parsed, {
					self.EXPR( $parsed.hash.<EXPR> )
				} )
			}
			else {
die "aglist: Unknown key"
			}
		}
		else {
die "arglist: Unknown type"
		}
	}
)
}
