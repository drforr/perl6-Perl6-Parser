class Perl6::Tidy {
	use nqp;

	has $.debugging = False;

#`(
	method boilerplate( Mu $parsed ) {
		say "boilerplate:\n" ~ $parsed.dump if $.debugging;
		if $parsed.list {
			die "statementlist: list"
		}
		elsif $parsed.hash {
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

#`(
	method assert-Int( $name, Mu $parsed ) {
		say "$name:\n" ~ $parsed.Int if $.debugging;
		die "$name is not a Int" unless $parsed.Int;
	}

	method assert-Str( $name, Mu $parsed ) {
		say "$name:\n" ~ $parsed.Str if $.debugging;
		die "$name is not a Str" unless $parsed.Str;
	}

	method assert-hash( $name, Mu $parsed, &sub ) {
		say "$name:\n" ~ $parsed.dump if $.debugging;
		die "$name is not a hash" unless $parsed.hash;

		&sub($parsed)
	}

	method assert-hash-key( $name, $key, Mu $parsed, &sub ) {
		die "$name does not have key '$key'" unless $parsed.hash.{$key};

		&sub($parsed)
	}

	method assert-hash-with-key( $name, $key, Mu $parsed, &sub ) {
		die "$name is not a hash" unless $parsed.hash;

                self.assert-hash-key( $name, $key, $parsed, &sub );
	}

	method assert-list( $name, Mu $parsed, &sub ) {
		die "$name is not a list" unless $parsed.list;

		if $.debugging {
			for $parsed.list {
				say $name ~ "[]:\n" ~ $_.dump;
			}
		}

		&sub($parsed)
	}
)

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
		say "statementlist:\n" ~ $parsed.dump if $.debugging;
		if $parsed.list {
			die "statementlist: list"
		}
		elsif $parsed.hash {
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
		say "statement:\n" ~ $parsed.dump if $.debugging;
		if $parsed.list {
			die "statementlist: list"
		}
		elsif $parsed.hash {
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
		say "EXPR:\n" ~ $parsed.dump if $.debugging;
		if $parsed.list {
			die "EXPR: list"
		}
		elsif $parsed.hash {
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
		say "value:\n" ~ $parsed.dump if $.debugging;
		if $parsed.list {
			if $parsed.hash.<number> {
				self.number( $parsed.hash.<number> )
			}
			else {
				die "value: list"
			}
		}
		elsif $parsed.hash {
			if $parsed.hash.<number> {
				self.number( $parsed.hash.<number> )
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
		say "number:\n" ~ $parsed.dump if $.debugging;
		if $parsed.list {
			die "number: list"
		}
		elsif $parsed.hash {
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

	method numish( Mu $parsed ) {
		say "numish:\n" ~ $parsed.dump if $.debugging;
		if $parsed.list {
			die "numish: list"
		}
		elsif $parsed.hash {
			if $parsed.hash.<integer> {
				self.integer( $parsed.hash.<integer> )
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
		say "integer:\n" ~ $parsed.dump if $.debugging;
		if $parsed.list {
			die "integer: list"
		}
		elsif $parsed.hash {
			if $parsed.hash.<decint> {
				self.decint( $parsed.hash.<decint> )
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

	method decint( Mu $parsed ) {
		say "decint:\n" ~ $parsed.dump if $.debugging;
		if $parsed.list {
			die "decint: list"
		}
		elsif $parsed.hash {
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

	method EXPR-item( Mu $parsed ) {
		self.assert-hash-with-key( 'EXPR-item', 'value', $parsed, {
			self.value( $parsed.hash.<value> )
		} )
	}

	method value( Mu $parsed ) {
		self.assert-hash( 'value', $parsed, {
			if $parsed.hash.<quote> {
				self.quote( $parsed.hash.<quote> )
			}
			elsif $parsed.hash.<number> {
				self.number( $parsed.hash.<number> )
			}
			else {
die "value: Unknown key"
			}
		} )
	}

	class Quote does Formatter {
		has $.value;
	}

	method quote( Mu $parsed ) {
		self.assert-hash-with-key( 'quote', 'nibble', $parsed, {
			self.nibble( $parsed.hash.<nibble> )
		} )
	}

	class Nibble does Formatter {
		has $.value;
	}

	method nibble( Mu $parsed ) {
		self.assert-Str( 'nibble', $parsed );
		Nibble.new(
			:value(
				$parsed.Str
			)
		)
	}

	method number( Mu $parsed ) {
		self.assert-hash-with-key( 'number', 'numish', $parsed, {
			self.numish( $parsed.hash.<numish> )
		} )
	}

	method numish( Mu $parsed ) {
		self.assert-hash-with-key( 'numish', 'integer', $parsed, {
			self.integer( $parsed.hash.<integer> )
		} )
	}

	method integer( Mu $parsed ) {
		self.assert-hash( 'integer', $parsed, {
			if $parsed.hash.<decint> {
				self.decint( $parsed.hash.<decint> )
			}
			elsif $parsed.hash.<hexint> {
				self.hexint( $parsed.hash.<hexint> )
			}
			else {
die "integer: Unknown key"
			}
		} )
	}

	class DecInt does Formatter {
		has $.value;
	}

	method decint( Mu $parsed ) {
		self.assert-Int( 'decint', $parsed );

		$parsed.Int
	}

	class HexInt does Formatter {
		has $.value;
	}

	method hexint( Mu $parsed ) {
		self.assert-Int( 'hexint', $parsed );

		HexInt.new(
			:value(
				$parsed.Int
			)
		)
	}

	method args( Mu $parsed ) {
		self.assert-hash-key( 'args', 'arglist', $parsed, {
			self.arglist( $parsed.hash.<arglist> )
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

	method semiarglist( Mu $parsed ) {
		self.assert-hash-key( 'semiarglist', 'arglist', $parsed, {
			self.arglist( $parsed.hash.<arglist> )
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
