class Perl6::Tidy {
	use nqp;

	has $.debugging = False;

	# When a class needs an arbitrary list of items,
	# give it this role. That way we *always* have a consistent
	# naming scheme for child elements.
	#
	role Nesting {
		has @.child;
	}

	# When a class needs to be given a name, or even just a value,
	# give it this role. That way we *always* have a consistent
	# naming scheme for values or whatnot.
	#
	role Naming {
		has $.name;
	}

	sub _debug( Str $key, Mu $value ) {
		my @types;

		@types.push( 'list' ) if $value.list;
		@types.push( 'hash' ) if $value.hash;
		@types.push( 'Int'  ) if $value.Int;
		@types.push( 'Str'  ) if $value.Str;
		@types.push( 'Bool' ) if $value.Bool;

		die "$key: Unknown type" unless @types;

		say "$key ({@types})";

		if $value.list {
			for $value.list {
				say "$key\[\]:\n" ~ $_.dump
			}
		}
		say "$key\{\}:\n" ~ $value.dump      if $value.hash;
		say "\+$key: "    ~ $value.Int       if $value.Int;
		say "\~$key: '"   ~ $value.Str ~ "'" if $value.Str;
		say "\?$key: "    ~ ~?$value.Bool    if $value.Bool;
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
			die "Uncaught type"
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

		my $parsed = $g.parse(
			$text,
			:p( 0 ),
			:actions( $a )
		);

		debug( 'tidy', 'tidy', $parsed ) if $.debugging;

		if $parsed.hash {
			if $parsed.hash.<statementlist> {
				die "Too many keys"
					if $parsed.hash.keys > 1;
				return self.statementlist(
					$parsed.hash.<statementlist>
				);
			}

			die "Uncaught key"
		}

		die "Uncaught type"
	}

	class statementlist does Nesting does Formatting {
	}

	method statementlist( Mu $parsed ) {
		debug(	'statementlist',
			'statementlist', $parsed ) if $.debugging;

		if $parsed.hash {
			if $parsed.hash.<statement> {
				die "Too many keys"
					if $parsed.hash.keys > 1;
				my @child;
				for $parsed.hash.<statement> {
					@child.push(
						self.statement( $_ )
					)
				}
				return statementlist.new(
					:child(
						@child
					)
				)
			}
			return statementlist.new
		}
		elsif $parsed.Bool {
			return statementlist.new
		}
		die "Uncaught type"
	}

	class statement does Nesting does Formatting {
	}

	method sigil_desigilname( Mu $sigil, Mu $desigilname ) {
		debug(	'sigil_desigilname',
			'sigil', $sigil,
			'desigilname', $desigilname ) if $.debugging;

		if $desigilname.hash {
			if $desigilname.hash.<longname> {
				die "Too many keys"
					if $desigilname.hash.keys > 1;
				return self.longname(
					$desigilname.hash.<longname>
				)
			}
			die "Uncaught key"
		}
		die "Uncaught type"
	}

	method statement( Mu $parsed ) {
		debug(	'statement',
			'statement', $parsed ) if $.debugging;

		if $parsed.list {
			my @child;
			for $parsed.list {
				@child.push(
					self.EXPR( $_.hash.<EXPR> )
				)
			}
			return statement.new(
				:child(
					@child
				)
			)
		}
		elsif $parsed.hash {
			if $parsed.hash.<EXPR> {
				die "Too many keys"
					if $parsed.hash.keys > 1;
				return self.EXPR( $parsed.hash.<EXPR> )
			}
			elsif $parsed.hash.<sigil> and
			      $parsed.hash.<desigilname> {
				die "Too many keys"
					if $parsed.hash.keys > 2;
				return self.sigil_desigilname(
					$parsed.hash.<sigil>,
					$parsed.hash.<desigilname>,
				)
			}
			die "Uncaught key"
		}
		die "Uncaught type"
	}

	method sym( Mu $parsed ) {
		debug(	'sym',
			'sym', $parsed ) if $.debugging;

		if $parsed.hash {
			die "hash"
		}
		if $parsed.Str {
			return $parsed.Str
		}
		die "Uncaught type"
	}

	method postfix( Mu $parsed ) {
		debug(	'postfix',
			'postfix', $parsed ) if $.debugging;

		if $parsed.hash {
			if $parsed.hash.<sym> and
			   $parsed.hash.<O> {
				die "Too many keys"
					if $parsed.hash.keys > 2;
				return self.sym(
					$parsed.hash.<sym>
				)
			}
			die "Uncaught key"
		}
		die "Uncaught type"
	}

	method OPER( Mu $parsed ) {
		debug(	'OPER',
			'OPER', $parsed ) if $.debugging;

		if $parsed.hash {
			if $parsed.hash.<sym> and
			   $parsed.hash.<O> {
				die "Too many keys"
					if $parsed.hash.keys > 2;
				return self.sym(
					$parsed.hash.<sym>
				)
			}
			die "Uncaught key"
		}
		die "Uncaught type"
	}

	class name does Naming does Nesting does Formatting {
	}

	method name( Mu $parsed ) {
		debug(	'name',
			'name', $parsed ) if $.debugging;

		if $parsed.hash {
			# XXX fix this branch
			if $parsed.hash.<identifier> and
			   $parsed.hash.<morename> {
				die "Too many keys"
					if $parsed.hash.keys > 2;
				my @child;
				for $parsed.hash.<morename> {
					@child.push( $_ )
				}
				return name.new(
					:name(
						$parsed.hash.<identifier>
					),
					:child(
						@child
					)
				)
			}
			# XXX fix this branch
			elsif $parsed.hash.<identifier> {
				die "Too many keys"
					if $parsed.hash.keys > 2;
				return self.identifier(
					$parsed.hash.<identifier>
				)
			}
			die "Uncaught key"
		}
		die "Uncaught type"
	}

	method longname( Mu $parsed ) {
		debug(	'longname',
			'longname', $parsed ) if $.debugging;

		if $parsed.hash {
			# XXX fix this branch...
			if $parsed.hash.<name> {
				die "Too many keys"
					if $parsed.hash.keys > 2;
				return self.name(
					$parsed.hash.<name>
				)
			}
			die "Uncaught key"
		}
		die "Uncaught type"
	}

	method twigil_sigil_desigilname( Mu $twigil,
					 Mu $sigil,
					 Mu $desigilname ) {
		debug(	'twigil_sigil_desigilname',
			'twigil', $twigil,
			'sigil', $sigil,
			'desigilname', $desigilname ) if $.debugging;

		if $twigil.hash {
			return $desigilname.Str
		}
		die "Uncaught type"
	}

	method variable( Mu $parsed ) {
		debug(	'variable',
			'variable', $parsed ) if $.debugging;

		if $parsed.hash {
			if $parsed.hash.<twigil> and
			   $parsed.hash.<sigil> and
                           $parsed.hash.<desigilname> {
				die "Too many keys"
					if $parsed.hash.keys > 3;
				return self.twigil_sigil_desigilname(
					$parsed.hash.<twigil>,
					$parsed.hash.<sigil>,
					$parsed.hash.<desigilname>
				)
			}
			elsif $parsed.hash.<sigil> and
                              $parsed.hash.<desigilname> {
				die "Too many keys"
					if $parsed.hash.keys > 2;
				return self.sigil_desigilname(
					$parsed.hash.<sigil>,
					$parsed.hash.<desigilname>
				)
			}
			die "Uncaught key"
		}
		die "Uncaught type"
	}

	class EXPR does Nesting does Formatting {
		has $.postfix;
		has $.OPER;
	}

	method EXPR( Mu $parsed ) {
		debug(	'EXPR',
			'EXPR', $parsed ) if $.debugging;

		if $parsed.list {
			my @child;
			for $parsed.list {
				if $_.hash.<value> {
					@child.push(
						self.value(
							$_.hash.<value>
						)
					)
				}
				else {
					die "Uncaught key"
				}
			}
			if $parsed.hash {
				if $parsed.hash.<postfix> and
				   $parsed.hash.<OPER> {
					return EXPR.new(
						:child(
							@child
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
				die "Uncaught key"
			}
			else {
				return EXPR.new(
					:child(
						@child
					)
				)
			}
		}
		elsif $parsed.hash {
			if $parsed.hash.<value> {
				die "Too many keys"
					if $parsed.hash.keys > 1;
				return self.value(
					$parsed.hash.<value>
				)
			}
			elsif $parsed.hash.<variable> {
				die "Too many keys"
					if $parsed.hash.keys > 1;
				return self.variable(
					$parsed.hash.<variable>
				)
			}
			elsif $parsed.hash.<longname> {
				die "Too many keys"
					if $parsed.hash.keys > 1;
				return self.longname(
					$parsed.hash.<longname>
				)
			}
			die "Uncaught key"
		}
		die "Uncaught type"
	}

	method value( Mu $parsed ) {
		debug(	'value',
			'value', $parsed ) if $.debugging;

		if $parsed.hash {
			if $parsed.hash.<number> {
				die "Too many keys"
					if $parsed.hash.keys > 1;
				return self.number(
					$parsed.hash.<number>
				)
			}
			elsif $parsed.hash.<quote> {
				die "Too many keys"
					if $parsed.hash.keys > 1;
				return self.quote(
					$parsed.hash.<quote>
				)
			}
			die "Uncaught key"
		}
		die "Uncaught type"
	}

	method number( Mu $parsed ) {
		debug(	'number',
			'number', $parsed ) if $.debugging;

		if $parsed.hash {
			if $parsed.hash.<numish> {
				die "Too many keys"
					if $parsed.hash.keys > 1;
				return self.numish(
					$parsed.hash.<numish>
				)
			}
			die "Uncaught key"
		}
		die "Uncaught type"
	}

	method quote( Mu $parsed ) {
		debug(	'quote',
			'quote', $parsed ) if $.debugging;

		if $parsed.hash {
			if $parsed.hash.<nibble> {
				die "Too many keys"
					if $parsed.hash.keys > 1;
				return self.nibble(
					$parsed.hash.<nibble>
				)
			}
			elsif $parsed.hash.<quibble> {
				die "Too many keys"
					if $parsed.hash.keys > 1;
				return self.quibble(
					$parsed.hash.<quibble>
				)
			}
			die "Uncaught key"
		}
		die "Uncaught type"
	}

	method B( Mu $parsed ) {
		debug(	'B',
			'B', $parsed ) if $.debugging;

		if $parsed.hash {
			die "hash"
		}
		if $parsed.Bool {
			return $parsed.Bool
		}
		die "Uncaught type"
	}

	method babble( Mu $parsed ) {
		debug(	'babble',
			'babble', $parsed ) if $.debugging;

		if $parsed.hash {
			if $parsed.hash.<B> {
				return self.B(
					$parsed.hash.<B>
				)
			}
			die "Uncaught type"
		}
		die "Uncaught type"
	}

	class identifier does Nesting does Formatting {
	}

	method identifier( Mu $parsed ) {
		debug(	'identifier',
			'identifier', $parsed ) if $.debugging;

		if $parsed.hash {
			die "hash"
		}
		if $parsed.list {
			my @child;
			for $parsed.list {
				@child.push(
					$_.Str
				)
			}
			return identifier.new(
				:child(
					@child
				)
			)
		}
		elsif $parsed.Str {
			return $parsed.Str
		}
		die "Uncaught type"
	}

	class quotepair does Nesting does Formatting {
	}

	method quotepair( Mu $parsed ) {
		debug(	'quotepair',
			'quotepair', $parsed ) if $.debugging;

		if $parsed.hash {
			if $parsed.hash.<identifier> {
				return self.identifier(
					$parsed.hash.<identifier>
				)
			}
			die "Uncaught key"
		}
		die "Uncaught type"
	}

	class babble_nibble does Nesting does Formatting {
	}

	method babble_nibble( Mu $babble, Mu $nibble ) {
		debug(	'babble_nibble',
			'babble', $babble,
			'nibble', $nibble ) if $.debugging;

		if $babble.hash {
			if $babble.hash.<quotepair> {
				my @child;
				for $babble.hash.<quotepair> {
					@child.push(
						self.quotepair( $_ )
					)
				}
				return babble_nibble.new(
					:child(
						@child
					)
				)
			}
			elsif $babble.hash.<B> {
				return self.B(
					$babble.hash.<B>
				)
			}
			die "Uncaught key"
		}
		die "Uncaught type"
	}

	method quibble( Mu $parsed ) {
		debug(	'quibble',
			'quibble', $parsed ) if $.debugging;

		if $parsed.hash {
			if $parsed.hash.<babble> and
			   $parsed.hash.<nibble> {
				return self.babble_nibble(
					$parsed.hash.<babble>,
					$parsed.hash.<nibble>
				)
			}
			die "Uncaught key"
		}
		die "Uncaught type"
	}

	method atom( Mu $parsed ) {
		debug(	'atom',
			'atom', $parsed ) if $.debugging;

		if $parsed.hash {
			die "hash"
		}
		if $parsed.Str {
			return $parsed.Str
		}
		die "Uncaught type"
	}

	method noun( Mu $parsed ) {
		debug(	'noun',
			'noun', $parsed ) if $.debugging;

		if $parsed.hash {
			if $parsed.hash.<atom> {
				return self.atom(
					$parsed.hash.<atom>
				)
			}
			die "Uncaught key"
		}
		if $parsed.Str {
			die "str"
		}
		die "Uncaught type"
	}

	class termish does Nesting does Formatting {
	}

	method termish( Mu $parsed ) {
		debug(	'termish',
			'termish', $parsed ) if $.debugging;

		if $parsed.hash {
			if $parsed.hash.<noun> {
				my @child;
				for $parsed.hash.<noun> {
					@child.push(
						self.noun( $_ )
					)
				}
				return termish.new(
					:child( @child )
				)
			}
			die "Uncaught key"
		}
		if $parsed.Str {
			die "Str"
		}
		die "Uncaught type"
	}

	class termconj does Nesting does Formatting {
	}

	method termconj( Mu $parsed ) {
		debug(	'termconj',
			'termconj', $parsed ) if $.debugging;

		if $parsed.hash {
			if $parsed.hash.<termish> {
				my @child;
				for $parsed.hash.<termish> {
					@child.push(
						self.termish( $_ )
					)
				}
				return termconj.new(
					:child( @child )
				)
			}
			die "Uncaught key"
		}
		if $parsed.Str {
			die "Str"
		}
		die "Uncaught type"
	}

	class termalt does Nesting does Formatting {
	}

	method termalt( Mu $parsed ) {
		debug(	'termalt',
			'termalt', $parsed ) if $.debugging;

		if $parsed.hash {
			if $parsed.hash.<termconj> {
				my @child;
				for $parsed.hash.<termconj> {
					@child.push(
						self.termconj( $_ )
					)
				}
				return termalt.new(
					:child( @child )
				)
			}
			die "Uncaught key"
		}
		if $parsed.Str {
			die "Str"
		}
		die "Uncaught type"
	}

	class termconjseq does Nesting does Formatting {
	}

	method termconjseq( Mu $parsed ) {
		debug(	'termconjseq',
			'termconjseq', $parsed ) if $.debugging;

		if $parsed.hash {
			if $parsed.hash.<termalt> {
				my @child;
				for $parsed.hash.<termalt> {
					@child.push(
						self.termalt( $_ )
					)
				}
				return termconjseq.new(
					:child( @child )
				)
			}
			die "Uncaught key"
		}
		if $parsed.Str {
			die "Str"
		}
		die "Uncaught type"
	}

	class termaltseq does Nesting does Formatting {
	}

	method termaltseq( Mu $parsed ) {
		debug(	'termaltseq',
			'termaltseq', $parsed ) if $.debugging;

		if $parsed.hash {
			if $parsed.hash.<termconjseq> {
				my @child;
				for $parsed.hash.<termconjseq> {
					@child.push(
						self.termconjseq( $_ )
					)
				}
				return termaltseq.new(
					:child( @child )
				)
			}
			die "Uncaught key"
		}
		if $parsed.Str {
			die "Str"
		}
		die "Uncaught type"
	}

	method termseq( Mu $parsed ) {
		debug(	'termseq',
			'termseq', $parsed ) if $.debugging;

		if $parsed.hash {
			if $parsed.hash.<termaltseq> {
				return self.termaltseq(
					$parsed.hash.<termaltseq>
				)
			}
			die "Uncaught key"
		}
		if $parsed.Str {
			die "Str"
		}
		die "Uncaught type"
	}

	method nibble( Mu $parsed ) {
		debug(	'nibble',
			'nibble', $parsed ) if $.debugging;

		if $parsed.hash {
			if $parsed.hash.<termseq> {
				return self.termseq(
					$parsed.hash.<termseq>
				)
			}
			die "Uncaught key"
		}
		if $parsed.Str {
			return $parsed.Str
		}
		die "Uncaught type"
	}

	method int_coeff_frac( Mu $int, Mu $coeff, Mu $frac ) {
		debug(	'int_coeff_escale',
			'int', $int,
			'coeff', $coeff,
			'frac', $frac ) if $.debugging;

		if $int.hash {
			die "hash"
		}
		if $int.Int {
			return $int.Int
		}
		die "Uncaught type"
	}

	method int_coeff_escale( Mu $int, Mu $coeff, Mu $escale ) {
		debug(	'int_coeff_escale',
			'int', $int,
			'coeff', $coeff,
			'escale', $escale ) if $.debugging;

		if $int.hash {
			die "hash"
		}
		if $int.Int {
			return $int.Int
		}
		die "Uncaught type"
	}

	method dec_number( Mu $parsed ) {
		debug(	'dec_number',
			'dec_number', $parsed ) if $.debugging;

		if $parsed.hash {
			if $parsed.hash.<int> and
			   $parsed.hash.<coeff> and
			   $parsed.hash.<frac> {
				return self.int_coeff_frac(
					$parsed.hash.<int>,
					$parsed.hash.<coeff>,
					$parsed.hash.<frac>
				)
			}
			elsif $parsed.hash.<int> and
			      $parsed.hash.<coeff> and
			      $parsed.hash.<escale> {
				return self.int_coeff_escale(
					$parsed.hash.<int>,
					$parsed.hash.<coeff>,
					$parsed.hash.<escale>
				)
			}
			die "Uncaught key"
		}
		die "Uncaught type"
	}

	method numish( Mu $parsed ) {
		debug(	'numish',
			'numish', $parsed ) if $.debugging;

		if $parsed.hash {
			if $parsed.hash.<integer> {
				die "Too many keys"
					if $parsed.hash.keys > 1;
				return self.integer(
					$parsed.hash.<integer>
				)
			}
			elsif $parsed.hash.<rad_number> {
				die "Too many keys"
					if $parsed.hash.keys > 1;
				return self.rad_number(
					$parsed.hash.<rad_number>
				)
			}
			elsif $parsed.hash.<dec_number> {
				die "Too many keys"
					if $parsed.hash.keys > 1;
				return self.dec_number(
					$parsed.hash.<dec_number>
				)
			}
			die "Uncaught key"
		}
		die "Uncaught type"
	}

	method integer( Mu $parsed ) {
		debug(	'integer',
			'integer', $parsed ) if $.debugging;

		if $parsed.hash {
			if $parsed.hash.<decint> and
			   $parsed.hash.<VALUE> {
				die "Too many keys"
					if $parsed.hash.keys > 2;
				return self.decint(
					$parsed.hash.<decint>
				)
			}
			elsif $parsed.hash.<binint> and
			      $parsed.hash.<VALUE> {
				die "Too many keys"
					if $parsed.hash.keys > 2;
				return self.binint(
					$parsed.hash.<binint>
				)
			}
			elsif $parsed.hash.<octint> and
			      $parsed.hash.<VALUE> {
				die "Too many keys"
					if $parsed.hash.keys > 2;
				return self.octint(
					$parsed.hash.<octint>
				)
			}
			elsif $parsed.hash.<hexint> and
			      $parsed.hash.<VALUE> {
				die "Too many keys"
					if $parsed.hash.keys > 2;
				return self.hexint(
					$parsed.hash.<hexint>
				)
			}
			die "Uncaught key"
		}
		die "Uncaught type"
	}

	method circumfix_radix( Mu $circumfix, Mu $radix ) {
		debug(	'circumfix',
			'circumfix', $circumfix,
			'radix', $radix ) if $.debugging;

		if $circumfix.hash {
			if $circumfix.hash.<semilist> {
				die "Too many keys"
					if $circumfix.hash.keys > 1;
				return self.semilist(
					$circumfix.hash.<semilist>
				)
			}
			die "Uncaught key"
		}
		die "Uncaught type"
	}

	class semilist does Nesting does Formatting {
	}

	method semilist( Mu $parsed ) {
		debug(	'semilist',
			'semilist', $parsed ) if $.debugging;

		if $parsed.hash {
			if $parsed.hash.<statement> {
				die "Too many keys"
					if $parsed.hash.keys > 1;
				my @child;
				for $parsed.hash.<statement> {
					@child.push(
						self.statement( $_ )
					)
				}
				return semilist.new(
					:child( @child )
				)
			}
			die "Uncaught key"
		}
		die "Uncaught type"
	}

	method rad_number( Mu $parsed ) {
		debug(	'rad_number',
			'rad_number', $parsed ) if $.debugging;

		if $parsed.hash {
			# XXX fix this branch...
			if $parsed.hash.<circumfix> and
			   $parsed.hash.<radix> {
				die "Too many keys"
					if $parsed.hash.keys > 4;
				return self.circumfix_radix(
					$parsed.hash.<circumfix>,
					$parsed.hash.<radix>
				)
			}
			die "Uncaught key"
		}
		die "Uncaught type"
	}

	method binint( Mu $parsed ) {
		debug(	'binint',
			'binint', $parsed ) if $.debugging;

		if $parsed.hash {
			die "hash"
		}
		if $parsed.Int {
			return $parsed.Int
		}
		die "Uncaught type"
	}

	method octint( Mu $parsed ) {
		debug(	'octint',
			'octint', $parsed ) if $.debugging;

		if $parsed.hash {
			die "hash"
		}
		if $parsed.Int {
			return $parsed.Int
		}
		die "Uncaught type"
	}

	method decint( Mu $parsed ) {
		debug(	'decint',
			'decint', $parsed ) if $.debugging;

		if $parsed.hash {
			die "hash"
		}
		if $parsed.Int {
			return $parsed.Int
		}
		die "Uncaught type"
	}

	method hexint( Mu $parsed ) {
		debug(	'hexint',
			'hexint', $parsed ) if $.debugging;

		if $parsed.hash {
			die "hash"
		}
		if $parsed.Int {
			return $parsed.Int
		}
		die "Uncaught type"
	}
}
