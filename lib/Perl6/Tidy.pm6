class Perl6::Tidy {
	use nqp;

	has $.debugging = False;

	role Nesting {
		has @.children;
	}

#`(
	method boilerplate( Mu $parsed ) {
		if $parsed.list {
			if $parsed.hash {
				die "list and hash"
			}
			die "list"
		}
		elsif $parsed.hash {
			say "boilerplate:\n" ~ $parsed.hash.dump if $.debugging;
			if $parsed.list {
				die "hash and list"
			}
			if $parsed.hash.<key> {
				die "Too many keys" if $parsed.hash.keys > 1;
				die "key";
			}
			else {
				die "No key found"
			}
			die "hash"
		}
		elsif $parsed.Int {
			die "Int"
		}
		elsif $parsed.Str {
			die "Str"
		}
		elsif $parsed.Bool {
			die " Bool"
		}
		else {
			die "Unknown type"
		}
	}
)

	# convert-hex-integers is just a sample.
	role Formatting {
	}

	method tidy( Str $text ) {
		my $compiler := nqp::getcomp('perl6');
		my $g := nqp::findmethod($compiler,'parsegrammar')($compiler);
		#$g.HOW.trace-on($g);
		my $a := nqp::findmethod($compiler,'parseactions')($compiler);

		my $parsed = $g.parse( $text, :p( 0 ), :actions( $a ) );

		say "tidy:\n" ~ $parsed.dump if $.debugging;
		if $parsed.list {
			die "list"
		}
		elsif $parsed.hash {
			if $parsed.hash.<statementlist> {
				die "Too many keys" if $parsed.hash.keys > 1;
				self.statementlist(
					$parsed.hash.<statementlist>
				);
			}
			else {
				die "hash"
			}
		}
		elsif $parsed.Int {
			die "Int"
		}
		elsif $parsed.Str {
			die "Str"
		}
		elsif $parsed.Bool {
			die "Bool"
		}
		else {
			die "Unknown type"
		}
	}

	class statementlist does Nesting does Formatting {
	}

	method statementlist( Mu $parsed ) {
		if $parsed.list {
			die "list"
		}
		elsif $parsed.hash {
			say "statementlist:\n" ~ $parsed.dump if $.debugging;
			if $parsed.hash.<statement> {
				die "Too many keys" if $parsed.hash.keys > 1;
				my @children;
				for $parsed.hash.<statement> {
					say "statementlist[]:\n" ~ $_.dump if $.debugging;
					@children.push(
						self.statement( $_ )
					)
				}
				statementlist.new(
					:children(
						@children
					)
				)
			}
			else {
				statementlist.new
			}
		}
		elsif $parsed.Int {
			die "Int"
		}
		elsif $parsed.Str {
			die "Str"
		}
		elsif $parsed.Bool {
			statementlist.new
		}
		else {
			die "Unknown type"
		}
	}

	class statement does Nesting does Formatting {
	}

	method statement( Mu $parsed ) {
		if $parsed.list {
			my @children;
			for $parsed.list {
				say "statement[]:\n" ~ $_.dump if $.debugging;
				@children.push(
					self.EXPR( $_.hash.<EXPR> )
				)
			}
			statement.new(
				:children(
					@children
				)
			)
		}
		elsif $parsed.hash {
			say "statement:\n" ~ $parsed.dump if $.debugging;
			if $parsed.hash.<EXPR> {
				die "Too many keys" if $parsed.hash.keys > 1;
				self.EXPR( $parsed.hash.<EXPR> )
			}
			else {
				die "hash"
			}
		}
		elsif $parsed.Int {
			die "Int"
		}
		elsif $parsed.Str {
			die "Str"
		}
		elsif $parsed.Bool {
			die "Bool"
		}
		else {
			die "Unknown type"
		}
	}

	class EXPR does Nesting does Formatting {
		has $.postfix;
		has $.OPER;
	}

	method sym( Mu $parsed ) {
		if $parsed.list {
			die "list"
		}
		elsif $parsed.hash {
			die "hash"
		}
		elsif $parsed.Int {
			die "Int"
		}
		elsif $parsed.Str {
			$parsed.Str
		}
		elsif $parsed.Bool {
			die "Bool"
		}
		else {
			die "Unknown type"
		}
	}

	method postfix( Mu $parsed ) {
		if $parsed.list {
			die "list"
		}
		elsif $parsed.hash {
			say "statement:\n" ~ $parsed.dump if $.debugging;
			if $parsed.hash.<sym> and
			   $parsed.hash.<O> {
				die "Too many keys" if $parsed.hash.keys > 2;
				self.sym( $parsed.hash.<sym> )
			}
			else {
				die "hash"
			}
		}
		elsif $parsed.Int {
			die "Int"
		}
		elsif $parsed.Str {
			die "Str"
		}
		elsif $parsed.Bool {
			die "Bool"
		}
		else {
			die "Unknown type"
		}
	}

	method OPER( Mu $parsed ) {
		if $parsed.list {
			die "list"
		}
		elsif $parsed.hash {
			say "statement:\n" ~ $parsed.dump if $.debugging;
			if $parsed.hash.<sym> and
			   $parsed.hash.<O> {
				die "Too many keys" if $parsed.hash.keys > 2;
				self.sym( $parsed.hash.<sym> )
			}
			else {
				die "hash"
			}
		}
		elsif $parsed.Int {
			die "Int"
		}
		elsif $parsed.Str {
			die "Str"
		}
		elsif $parsed.Bool {
			die "Bool"
		}
		else {
			die "Unknown type"
		}
	}

	method EXPR( Mu $parsed ) {
		if $parsed.list {
			my @children;
			for $parsed.list {
				say "EXPR[]:\n" ~ $_.dump if $.debugging;
				if $_.hash.<value> {
					@children.push(
						self.value( $_.hash.<value> )
					)
				}
				else {
					die "Unknown key"
				}
			}
			if $parsed.hash {
				if $parsed.hash.<postfix> and
				   $parsed.hash.<OPER> {
					EXPR.new(
						:children(
							@children
						),
						:postfix(
							self.postfix(
								$parsed.hash.<postfix>
							)
						),
						:OPER(
							self.OPER(
								$parsed.hash.<OPER>
							)
						),
					)
				}
			}
			else {
				EXPR.new(
					:children(
						@children
					)
				)
			}
		}
		elsif $parsed.hash {
			say "EXPR:\n" ~ $parsed.dump if $.debugging;
			if $parsed.hash.<value> {
				die "Too many keys" if $parsed.hash.keys > 1;
				self.value( $parsed.hash.<value> )
			}
			else {
				die "Unknown key"
			}
		}
		elsif $parsed.Int {
			die "Int"
		}
		elsif $parsed.Str {
			die "Str"
		}
		elsif $parsed.Bool {
			die "Bool"
		}
		else {
			die "Unknown type"
		}
	}

	method value( Mu $parsed ) {
		if $parsed.list {
			die "list"
		}
		elsif $parsed.hash {
			say "value:\n" ~ $parsed.dump if $.debugging;
			if $parsed.hash.<number> {
				die "Too many keys" if $parsed.hash.keys > 1;
				self.number( $parsed.hash.<number> )
			}
			elsif $parsed.hash.<quote> {
				die "Too many keys" if $parsed.hash.keys > 1;
				self.quote( $parsed.hash.<quote> )
			}
			else {
				die "Unknown key"
			}
		}
		elsif $parsed.Int {
			die "Int"
		}
		elsif $parsed.Str {
			die "Str"
		}
		elsif $parsed.Bool {
			die "Bool"
		}
		else {
			die "Unknown type"
		}
	}

	method number( Mu $parsed ) {
		if $parsed.list {
			die "list"
		}
		elsif $parsed.hash {
			say "number:\n" ~ $parsed.dump if $.debugging;
			if $parsed.hash.<numish> {
				die "Too many keys" if $parsed.hash.keys > 1;
				self.numish( $parsed.hash.<numish> )
			}
			else {
				die "Unknown key"
			}
		}
		elsif $parsed.Int {
			die "Int"
		}
		elsif $parsed.Str {
			die "Str"
		}
		elsif $parsed.Bool {
			die "Bool"
		}
		else {
			die "Unknown type"
		}
	}

	method quote( Mu $parsed ) {
		if $parsed.list {
			die "list"
		}
		elsif $parsed.hash {
			say "quote:\n" ~ $parsed.dump if $.debugging;
			if $parsed.hash.<nibble> {
				die "Too many keys" if $parsed.hash.keys > 1;
				self.nibble( $parsed.hash.<nibble> )
			}
			else {
				die "Unknown key"
			}
		}
		elsif $parsed.Int {
			die "Int"
		}
		elsif $parsed.Str {
			die "Str"
		}
		elsif $parsed.Bool {
			die "Bool"
		}
		else {
			die "Unknown type"
		}
	}

	method nibble( Mu $parsed ) {
		if $parsed.list {
			die "list"
		}
		elsif $parsed.hash {
			die " Unknown key"
		}
		elsif $parsed.Int {
			die "Int"
		}
		elsif $parsed.Str {
			say "nibble:\n" ~ $parsed.Str if $.debugging;
			$parsed.Str
		}
		elsif $parsed.Bool {
			die "Bool"
		}
		else {
			die "Unknown type"
		}
	}

	method numish( Mu $parsed ) {
		if $parsed.list {
			die "list"
		}
		elsif $parsed.hash {
			say "numish:\n" ~ $parsed.dump if $.debugging;
			if $parsed.hash.<integer> {
				die "Too many keys" if $parsed.hash.keys > 1;
				self.integer( $parsed.hash.<integer> )
			}
			elsif $parsed.hash.<rad_number> {
				die "Too many keys" if $parsed.hash.keys > 1;
				self.rad_number( $parsed.hash.<rad_number> )
			}
			else {
				die "Unknown key"
			}
		}
		elsif $parsed.Int {
			die "Int"
		}
		elsif $parsed.Str {
			die "Str"
		}
		elsif $parsed.Bool {
			die "Bool"
		}
		else {
			die "Unknown type"
		}
	}

	method integer( Mu $parsed ) {
		if $parsed.list {
			die "list"
		}
		elsif $parsed.hash {
			say "integer:\n" ~ $parsed.dump if $.debugging;
			if $parsed.hash.<decint> and
			   $parsed.hash.<VALUE> {
				die "Too many keys" if $parsed.hash.keys > 2;
				self.decint( $parsed.hash.<decint> )
			}
			elsif $parsed.hash.<binint> and
			      $parsed.hash.<VALUE> {
				die "Too many keys" if $parsed.hash.keys > 2;
				self.binint( $parsed.hash.<binint> )
			}
			elsif $parsed.hash.<octint> and
			      $parsed.hash.<VALUE> {
				die "Too many keys" if $parsed.hash.keys > 2;
				self.octint( $parsed.hash.<octint> )
			}
			elsif $parsed.hash.<hexint> and
			      $parsed.hash.<VALUE> {
				die "Too many keys" if $parsed.hash.keys > 2;
				self.hexint( $parsed.hash.<hexint> )
			}
			else {
				die "Unknown key"
			}
		}
		elsif $parsed.Int {
			die "Int"
		}
		elsif $parsed.Str {
			die "Str"
		}
		elsif $parsed.Bool {
			die "Bool"
		}
		else {
			die "Unknown type"
		}
	}

	method circumfix_radix( Mu $circumfix, Mu $radix ) {
		if $circumfix.list {
			die "list"
		}
		elsif $circumfix.hash {
			say "circumfix:\n" ~ $circumfix.dump if $.debugging;
			if $circumfix.hash.<semilist> {
				die "Too many keys" if $circumfix.hash.keys > 1;
				self.semilist( $circumfix.hash.<semilist> )
			}
			else {
				die "Unknown key"
			}
		}
		elsif $circumfix.Int {
			die "Int"
		}
		elsif $circumfix.Str {
			die "Str"
		}
		elsif $circumfix.Bool {
			die "Bool"
		}
		else {
			die "Unknown type"
		}
	}

	method semilist( Mu $parsed ) {
		if $parsed.list {
			die "list"
		}
		elsif $parsed.hash {
			say "semilist:\n" ~ $parsed.dump if $.debugging;
			if $parsed.hash.<statement> {
				die "Too many keys" if $parsed.hash.keys > 1;
				self.statement( $parsed.hash.<statement> )
			}
			else {
				die "Unknown key"
			}
		}
		elsif $parsed.Int {
			die "Int"
		}
		elsif $parsed.Str {
			die "Str"
		}
		elsif $parsed.Bool {
			die "Bool"
		}
		else {
			die "Unknown type"
		}
	}

	method rad_number( Mu $parsed ) {
		if $parsed.list {
			die "list"
		}
		elsif $parsed.hash {
			say "rad_number:\n" ~ $parsed.dump if $.debugging;
			if $parsed.hash.<circumfix> and
			   $parsed.hash.<radix> {
				die "Too many keys" if $parsed.hash.keys > 4;
				self.circumfix_radix(
					$parsed.hash.<circumfix>,
					$parsed.hash.<radix>
				)
			}
			else {
				die "Unknown key"
			}
		}
		elsif $parsed.Int {
			die "Int"
		}
		elsif $parsed.Str {
			die "Str"
		}
		elsif $parsed.Bool {
			die "Bool"
		}
		else {
			die "Unknown type"
		}
	}

	method binint( Mu $parsed ) {
		if $parsed.list {
			die "list"
		}
		elsif $parsed.hash {
			die "hash"
		}
		elsif $parsed.Int {
			say "binint:\n" ~ $parsed.Int if $.debugging;
			$parsed.Int
		}
		elsif $parsed.Str {
			die "Str"
		}
		elsif $parsed.Bool {
			die "Bool"
		}
		else {
			die "Unknown type"
		}
	}

	method octint( Mu $parsed ) {
		if $parsed.list {
			die "list"
		}
		elsif $parsed.hash {
			die "hash"
		}
		elsif $parsed.Int {
			say "octint:\n" ~ $parsed.Int if $.debugging;
			$parsed.Int
		}
		elsif $parsed.Str {
			die "Str"
		}
		elsif $parsed.Bool {
			die "Bool"
		}
		else {
			die "Unknown type"
		}
	}

	method decint( Mu $parsed ) {
		if $parsed.list {
			die "list"
		}
		elsif $parsed.hash {
			die "hash"
		}
		elsif $parsed.Int {
			say "decint:\n" ~ $parsed.Int if $.debugging;
			$parsed.Int
		}
		elsif $parsed.Str {
			die "Str"
		}
		elsif $parsed.Bool {
			die "Bool"
		}
		else {
			die "Unknown type"
		}
	}

	method hexint( Mu $parsed ) {
		if $parsed.list {
			die "list"
		}
		elsif $parsed.hash {
			die "hash"
		}
		elsif $parsed.Int {
			say "hexint:\n" ~ $parsed.Int if $.debugging;
			$parsed.Int
		}
		elsif $parsed.Str {
			die "Str"
		}
		elsif $parsed.Bool {
			die "Bool"
		}
		else {
			die "Unknown type"
		}
	}
}
