class Perl6::Tidy {
	use nqp;

	has $.debugging = False;

	role Nesting {
		has @.children;
	}

	role Naming {
		has $.name;
	}

	sub _debug( Str $key, Mu $value ) {
		my @types;

		@types.push( 'list' ) if $value.list();
		@types.push( 'hash' ) if $value.hash();
		@types.push( 'Int' )  if $value.Int();
		@types.push( 'Str' )  if $value.Str();
		@types.push( 'Bool' ) if $value.Bool();

		die "$key: Unknown type" unless @types;

		say "$key ({@types})";

		if $value.list {
			for $value.list {
				say "$key\[\]:\n" ~ $_.dump
			}
		}
		say "$key\{\}:\n" ~ $value.dump if $value.hash;
		say "\+$key: " ~ $value.Int if $value.Int;
		say "\~$key: '" ~ $value.Str ~ "'" if $value.Str;
		say "\?$key: " ~ ~?$value.Bool if $value.Bool;
	}

	sub debug( Str $name, *@inputs ) {
		for @inputs -> $k, $v {
			_debug( $k, $v )
		}
		say "";
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
			say "boilerplate:\n" ~ $parsed.dump if $.debugging;
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

		debug( 'tidy', 'tidy', $parsed ) if $.debugging;

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
		debug(	'statementlist',
			'statementlist', $parsed ) if $.debugging;

		if $parsed.list {
			die "list"
		}
		elsif $parsed.hash {
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

	method sigil_desigilname( Mu $sigil, Mu $desigilname ) {
		debug(	'sigil_desigilname',
			'sigil', $sigil,
			'desigilname', $desigilname ) if $.debugging;

		if $desigilname.list {
			die "list"
		}
		elsif $desigilname.hash {
			if $desigilname.hash.<longname> {
				die "Too many keys" if $desigilname.hash.keys > 1;
				self.longname( $desigilname.hash.<longname> )
			}
			else {
				die "Unknown type"
			}
		}
		elsif $desigilname.Int {
			die "Int"
		}
		elsif $desigilname.Str {
			die "Str"
		}
		elsif $desigilname.Bool {
			die "Bool"
		}
		else {
			die "Unknown type"
		}
	}

	method statement( Mu $parsed ) {
		debug(	'statement',
			'statement', $parsed ) if $.debugging;

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
			elsif $parsed.hash.<sigil> and
			      $parsed.hash.<desigilname> {
				die "Too many keys" if $parsed.hash.keys > 2;
				self.sigil_desigilname(
					$parsed.hash.<sigil>,
					$parsed.hash.<desigilname>,
				)
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
		debug(	'sym',
			'sym', $parsed ) if $.debugging;

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
		debug(	'postfix',
			'postfix', $parsed ) if $.debugging;

		if $parsed.list {
			die "list"
		}
		elsif $parsed.hash {
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
		debug(	'OPER',
			'OPER', $parsed ) if $.debugging;

		if $parsed.list {
			die "list"
		}
		elsif $parsed.hash {
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

	class name does Naming does Nesting does Formatting {
	}

	method name( Mu $parsed ) {
		debug(	'name',
			'name', $parsed ) if $.debugging;

		if $parsed.list {
			die "list"
		}
		elsif $parsed.hash {
			# XXX fix this branch
			if $parsed.hash.<identifier> and
			   $parsed.hash.<morename> {
				die "Too many keys" if $parsed.hash.keys > 2;
				my @children;
				for $parsed.hash.<morename> {
					@children.push( $_ )
				}
				name.new(
					:name(
						$parsed.hash.<identifier>
					),
					:children(
						@children
					)
				)
			}
			# XXX fix this branch
			elsif $parsed.hash.<identifier> {
				die "Too many keys" if $parsed.hash.keys > 2;
				self.identifier( $parsed.hash.<identifier> )
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

	method longname( Mu $parsed ) {
		debug(	'longname',
			'longname', $parsed ) if $.debugging;

		if $parsed.list {
			die "list"
		}
		elsif $parsed.hash {
			# XXX fix this branch...
			if $parsed.hash.<name> {
				die "Too many keys" if $parsed.hash.keys > 2;
				self.name( $parsed.hash.<name> )
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

	method twigil_sigil_desigilname( Mu $twigil, Mu $sigil, Mu $desigilname ) {
		debug(	'twigil_sigil_desigilname',
			'twigil', $twigil,
			'sigil', $sigil,
			'desigilname', $desigilname ) if $.debugging;

		if $twigil.list {
			die "list"
		}
		elsif $twigil.hash {
			$desigilname.Str
		}
		elsif $twigil.Int {
			die "Int"
		}
		elsif $twigil.Str {
			die "Str"
		}
		elsif $twigil.Bool {
			die "Bool"
		}
		else {
			die "Unknown type"
		}
	}

	method variable( Mu $parsed ) {
		debug(	'variable',
			'variable', $parsed ) if $.debugging;

		if $parsed.list {
			die "list"
		}
		elsif $parsed.hash {
			if $parsed.hash.<twigil> and
			   $parsed.hash.<sigil> and
                           $parsed.hash.<desigilname> {
				die "Too many keys" if $parsed.hash.keys > 3;
				self.twigil_sigil_desigilname(
					$parsed.hash.<twigil>,
					$parsed.hash.<sigil>,
					$parsed.hash.<desigilname>
				)
			}
			elsif $parsed.hash.<sigil> and
                              $parsed.hash.<desigilname> {
				die "Too many keys" if $parsed.hash.keys > 2;
				self.sigil_desigilname(
					$parsed.hash.<sigil>,
					$parsed.hash.<desigilname>
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

	method EXPR( Mu $parsed ) {
		debug(	'EXPR',
			'EXPR', $parsed ) if $.debugging;

		if $parsed.list {
			my @children;
			for $parsed.list {
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
				else {
					die "Unknown key"
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
			if $parsed.hash.<value> {
				die "Too many keys" if $parsed.hash.keys > 1;
				self.value( $parsed.hash.<value> )
			}
			elsif $parsed.hash.<variable> {
				die "Too many keys" if $parsed.hash.keys > 1;
				self.variable( $parsed.hash.<variable> )
			}
			elsif $parsed.hash.<longname> {
				die "Too many keys" if $parsed.hash.keys > 1;
				self.longname( $parsed.hash.<longname> )
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
		debug(	'value',
			'value', $parsed ) if $.debugging;

		if $parsed.list {
			die "list"
		}
		elsif $parsed.hash {
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
		debug(	'number',
			'number', $parsed ) if $.debugging;

		if $parsed.list {
			die "list"
		}
		elsif $parsed.hash {
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
		debug(	'quote',
			'quote', $parsed ) if $.debugging;

		if $parsed.list {
			die "list"
		}
		elsif $parsed.hash {
			if $parsed.hash.<nibble> {
				die "Too many keys" if $parsed.hash.keys > 1;
				self.nibble( $parsed.hash.<nibble> )
			}
			elsif $parsed.hash.<quibble> {
				die "Too many keys" if $parsed.hash.keys > 1;
				self.quibble( $parsed.hash.<quibble> )
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

	method B( Mu $parsed ) {
		debug(	'B',
			'B', $parsed ) if $.debugging;

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
			die "Str"
		}
		elsif $parsed.Bool {
			$parsed.Bool
		}
		else {
			die "Unknown type"
		}
	}

	method babble( Mu $parsed ) {
		debug(	'babble',
			'babble', $parsed ) if $.debugging;

		if $parsed.list {
			die "list"
		}
		elsif $parsed.hash {
			if $parsed.hash.<B> {
				self.B(
					$parsed.hash.<B>
				)
			}
			else {
				die "Unknown type"
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

	class identifier does Nesting does Formatting {
	}

	method identifier( Mu $parsed ) {
		debug(	'identifier',
			'identifier', $parsed ) if $.debugging;

		if $parsed.list {
			my @children;
			for $parsed.list {
				say "identifier[]:\n" ~ $_.Str if $.debugging;
				@children.push(
					$_.Str
				)
			}
			identifier.new(
				:children(
					@children
				)
			)
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

	class quotepair does Nesting does Formatting {
	}

	method quotepair( Mu $parsed ) {
		if $parsed.list {
			my @children;
			for $parsed.list {
				say "quotepair[]:\n" ~ $_.dump if $.debugging;
				@children.push(
					self.identifier(
						$_.hash.<identifier>
					)
				)
			}
			quotepair.new(
				:children(
					@children
				)
			)
		}
		elsif $parsed.hash {
			die "hash"
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

	method babble_nibble( Mu $babble, Mu $nibble ) {
		debug(	'babble_nibble',
			'babble', $babble,
			'nibble', $nibble ) if $.debugging;

		if $babble.list {
			die "list"
		}
		elsif $babble.hash {
			if $babble.hash.<quotepair> {
				self.quotepair(
					$babble.hash.<quotepair>
				)
			}
			elsif $babble.hash.<B> {
				self.B(
					$babble.hash.<B>
				)
			}
			else {
				die "Unknown key"
			}
		}
		elsif $babble.Int {
			die "Int"
		}
		elsif $babble.Str {
			die "Str"
		}
		elsif $babble.Bool {
			die "Bool"
		}
		else {
			die "Unknown type"
		}
	}

	method quibble( Mu $parsed ) {
		debug(	'quibble',
			'quibble', $parsed ) if $.debugging;

		if $parsed.list {
			die "list"
		}
		elsif $parsed.hash {
			if $parsed.hash.<babble> and
			   $parsed.hash.<nibble> {
				self.babble_nibble(
					$parsed.hash.<babble>,
					$parsed.hash.<nibble>
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

	method nibble( Mu $parsed ) {
		debug(	'nibble',
			'nibble', $parsed ) if $.debugging;

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

	method int_coeff_frac( Mu $int, Mu $coeff, Mu $frac ) {
		debug(	'int_coeff_escale',
			'int', $int,
			'coeff', $coeff,
			'frac', $frac ) if $.debugging;

		if $int.list {
			die "list"
		}
		elsif $int.hash {
			die "hash"
		}
		elsif $int.Int {
			$int.Int
		}
		elsif $int.Str {
			die "Str"
		}
		elsif $int.Bool {
			die "Bool"
		}
		else {
			die "Unknown type"
		}
	}

	method int_coeff_escale( Mu $int, Mu $coeff, Mu $escale ) {
		debug(	'int_coeff_escale',
			'int', $int,
			'coeff', $coeff,
			'escale', $escale ) if $.debugging;

		if $int.list {
			die "list"
		}
		elsif $int.hash {
			die "hash"
		}
		elsif $int.Int {
			$int.Int
		}
		elsif $int.Str {
			die "Str"
		}
		elsif $int.Bool {
			die "Bool"
		}
		else {
			die "Unknown type"
		}
	}

	method dec_number( Mu $parsed ) {
		debug(	'dec_number',
			'dec_number', $parsed ) if $.debugging;

		if $parsed.list {
			die "list"
		}
		elsif $parsed.hash {
			if $parsed.hash.<int> and
			   $parsed.hash.<coeff> and
			   $parsed.hash.<frac> {
				self.int_coeff_frac(
					$parsed.hash.<int>,
					$parsed.hash.<coeff>,
					$parsed.hash.<frac>
				)
			}
			elsif $parsed.hash.<int> and
			      $parsed.hash.<coeff> and
			      $parsed.hash.<escale> {
				self.int_coeff_escale(
					$parsed.hash.<int>,
					$parsed.hash.<coeff>,
					$parsed.hash.<escale>
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

	method numish( Mu $parsed ) {
		debug(	'numish',
			'numish', $parsed ) if $.debugging;

		if $parsed.list {
			die "list"
		}
		elsif $parsed.hash {
			if $parsed.hash.<integer> {
				die "Too many keys" if $parsed.hash.keys > 1;
				self.integer( $parsed.hash.<integer> )
			}
			elsif $parsed.hash.<rad_number> {
				die "Too many keys" if $parsed.hash.keys > 1;
				self.rad_number( $parsed.hash.<rad_number> )
			}
			elsif $parsed.hash.<dec_number> {
				die "Too many keys" if $parsed.hash.keys > 1;
				self.dec_number( $parsed.hash.<dec_number> )
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
		debug(	'integer',
			'integer', $parsed ) if $.debugging;

		if $parsed.list {
			die "list"
		}
		elsif $parsed.hash {
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
		debug(	'circumfix',
			'circumfix', $circumfix,
			'radix', $radix ) if $.debugging;

		if $circumfix.list {
			die "list"
		}
		elsif $circumfix.hash {
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

	class semilist does Nesting does Formatting {
	}

	method semilist( Mu $parsed ) {
		debug(	'semilist',
			'semilist', $parsed ) if $.debugging;

		if $parsed.list {
			die "list"
		}
		elsif $parsed.hash {
			if $parsed.hash.<statement> {
				die "Too many keys" if $parsed.hash.keys > 1;
				my @children;
				for $parsed.hash.<statement> {
					@children.push(
						self.statement( $_ )
					)
				}
				semilist.new(
					:children( @children )
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

	method rad_number( Mu $parsed ) {
		debug(	'rad_number',
			'rad_number', $parsed ) if $.debugging;

		if $parsed.list {
			die "list"
		}
		elsif $parsed.hash {
			# XXX fix this branch...
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
		debug(	'binint',
			'binint', $parsed ) if $.debugging;

		if $parsed.list {
			die "list"
		}
		elsif $parsed.hash {
			die "hash"
		}
		elsif $parsed.Int {
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
		debug(	'octint',
			'octint', $parsed ) if $.debugging;

		if $parsed.list {
			die "list"
		}
		elsif $parsed.hash {
			die "hash"
		}
		elsif $parsed.Int {
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
		debug(	'decint',
			'decint', $parsed ) if $.debugging;

		if $parsed.list {
			die "list"
		}
		elsif $parsed.hash {
			die "hash"
		}
		elsif $parsed.Int {
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
		debug(	'hexint',
			'hexint', $parsed ) if $.debugging;

		if $parsed.list {
			die "list"
		}
		elsif $parsed.hash {
			die "hash"
		}
		elsif $parsed.Int {
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
