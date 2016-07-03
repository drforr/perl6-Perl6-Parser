class Perl6::Tidy {
	use nqp;

	has $.debugging = False;

	class Node {
		has Str $.type is required;
		has $.name;
		has $.child;
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
		say "$key\{\}:\n" ~   $value.dump      if $value.hash;
		say "\+$key: "    ~   $value.Int       if $value.Int;
		say "\~$key: '"   ~   $value.Str ~ "'" if $value.Str;
		say "\?$key: "    ~ ~?$value.Bool      if $value.Bool;
	}

	method debug( Str $name, *@inputs ) {
		return unless $.debugging;
		for @inputs -> $k, $v {
			_debug( $k, $v )
		}
		say "";
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

		self.debug( 'tidy', 'tidy', $parsed );

		if $parsed.hash {
			if $parsed.hash.<statementlist> {
				die "Too many keys"
					if $parsed.hash.keys > 1;
				return Node.new(
					:type( 'tidy' ),
					:name(
						self.statementlist(
							$parsed.hash.<statementlist>
						)
					)
				);
			}

			die "Uncaught key"
		}

		die "Uncaught type"
	}

	method statementlist( Mu $parsed ) {
		self.debug(
			'statementlist',
			'statementlist', $parsed
		);

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
				return Node.new(
					:type( 'statementlist' ),
					:child( @child )
				)
			}
			die "Uncaught key"
		}
		elsif $parsed.Bool {
			return Node.new(
				:type( 'statementlist' )
			)
		}
		die "Uncaught type"
	}

	method sigil_desigilname( Mu $sigil, Mu $desigilname ) {
		self.debug(
			'sigil_desigilname',
			'sigil',       $sigil,
			'desigilname', $desigilname
		);

		if $desigilname.hash {
			if $desigilname.hash.<longname> {
				die "Too many keys"
					if $desigilname.hash.keys > 1;
				return Node.new(
					:type( 'sigil_desigilname' ),
					:name(
						 self.longname(
							$desigilname.hash.<longname>
						)
					)
				)
			}
			die "Uncaught key"
		}
		die "Uncaught type"
	}

	method statement( Mu $parsed ) {
		self.debug(
			'statement',
			'statement', $parsed
		);

		if $parsed.list {
			my @child;
			for $parsed.list {
				@child.push(
					self.EXPR(
						$_.hash.<EXPR>
					)
				)
			}
			return Node.new(
				:type( 'statement' ),
				:child( @child )
			)
		}
		elsif $parsed.hash {
			if $parsed.hash.<EXPR> {
				die "Too many keys"
					if $parsed.hash.keys > 1;
				return Node.new(
					:type( 'statement' ),
					:name(
						self.EXPR(
							$parsed.hash.<EXPR>
						)
					)
				)
			}
			elsif $parsed.hash.<sigil> and
			      $parsed.hash.<desigilname> {
				die "Too many keys"
					if $parsed.hash.keys > 2;
				return Node.new(
					:type( 'statement' ),
					:name(
						self.sigil_desigilname(
							$parsed.hash.<sigil>,
							$parsed.hash.<desigilname>
						)
					)
				)
			}
			die "Uncaught key"
		}
		die "Uncaught type"
	}

	method sym( Mu $parsed ) {
		self.debug(
			'sym',
			'sym', $parsed
		);

		if $parsed.hash {
			die "hash"
		}
		if $parsed.Str {
			return Node.new(
				:type( 'sym' ),
				:name(
					$parsed.Str
				)
			)
		}
		die "Uncaught type"
	}

	method postfix( Mu $parsed ) {
		self.debug(
			'postfix',
			'postfix', $parsed
		);

		if $parsed.hash {
			if $parsed.hash.<sym> and
			   $parsed.hash.<O> {
				die "Too many keys"
					if $parsed.hash.keys > 2;
				return Node.new(
					:type( 'postfix' ),
					:name(
						self.sym(
							$parsed.hash.<sym>
						)
					)
				)
			}
			die "Uncaught key"
		}
		die "Uncaught type"
	}

	method OPER( Mu $parsed ) {
		self.debug(
			'OPER',
			'OPER', $parsed
		);

		if $parsed.hash {
			if $parsed.hash.<sym> and
			   $parsed.hash.<O> {
				die "Too many keys"
					if $parsed.hash.keys > 2;
				return Node.new(
					:type( 'OPER' ),
					:name(
						self.sym(
							$parsed.hash.<sym>
						)
					)
				)
			}
			die "Uncaught key"
		}
		die "Uncaught type"
	}

	method name( Mu $parsed ) {
		self.debug(
			'name',
			'name', $parsed
		);

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
				return Node.new(
					:type( 'name' ),
					:name(
						self.identifier(
							$parsed.hash.<identifier>
						)
					),
					:child( @child )
				)
			}
			# XXX fix this branch
			elsif $parsed.hash.<identifier> {
				die "Too many keys"
					if $parsed.hash.keys > 2;
				return Node.new(
					:type( 'name' ),
					:name(
						self.identifier(
							$parsed.hash.<identifier>
						)
					)
				)
			}
			die "Uncaught key"
		}
		die "Uncaught type"
	}

	method longname( Mu $parsed ) {
		self.debug(
			'longname',
			'longname', $parsed
		);

		if $parsed.hash {
			# XXX fix this branch...
			if $parsed.hash.<name> {
				die "Too many keys"
					if $parsed.hash.keys > 2;
				return Node.new(
					:type( 'longname' ),
					:name(
						self.name(
							$parsed.hash.<name>
						)
					)
				)
			}
			die "Uncaught key"
		}
		die "Uncaught type"
	}

	method twigil_sigil_desigilname( Mu $twigil,
					 Mu $sigil,
					 Mu $desigilname ) {
		self.debug(
			'twigil_sigil_desigilname',
			'twigil',      $twigil,
			'sigil',       $sigil,
			'desigilname', $desigilname
		);

		if $twigil.hash {
			return Node.new(
				:type( 'twigil_sigil_desigilname' ),
				:name(
					self.longname(
						$desigilname.hash.<longname>
					)
				),
				:twigil(
					self.sym(
						$twigil.hash.<sym>
					)
				),
				:sigil(
					$sigil.Str
				),
				:desigilname(
					self.longname(
						$desigilname.hash.<longname>
					)
				)
			)
		}
		die "Uncaught type"
	}

	method variable( Mu $parsed ) {
		self.debug(
			'variable',
			'variable', $parsed
		);

		if $parsed.hash {
			if $parsed.hash.<twigil> and
			   $parsed.hash.<sigil> and
                           $parsed.hash.<desigilname> {
				die "Too many keys"
					if $parsed.hash.keys > 3;
				return Node.new(
					:type( 'variable' ),
					:name(
						self.twigil_sigil_desigilname(
							$parsed.hash.<twigil>,
							$parsed.hash.<sigil>,
							$parsed.hash.<desigilname>
						)
					)
				)
			}
			elsif $parsed.hash.<sigil> and
                              $parsed.hash.<desigilname> {
				die "Too many keys"
					if $parsed.hash.keys > 2;
				return Node.new(
					:type( 'variable' ),
					:name(
						self.sigil_desigilname(
							$parsed.hash.<sigil>,
							$parsed.hash.<desigilname>
						)
					)
				)
			}
			die "Uncaught key"
		}
		die "Uncaught type"
	}

	method EXPR( Mu $parsed ) {
		self.debug(
			'EXPR',
			'EXPR', $parsed
		);

		if $parsed.list {
			my @child;
			for $parsed.list {
				if $_.hash.<value> {
					@child.push(
						self.value(
							$_.hash.<value>
						)
					);
					next;
				}
				die "Uncaught key"
			}
			if $parsed.hash {
				if $parsed.hash.<postfix> and
				   $parsed.hash.<OPER> {
					return Node.new(
						:type( 'EXPR' ),
						:child( @child ),

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
				return Node.new(
					:type( 'EXPR' ),
					:child( @child )
				)
			}
		}
		if $parsed.hash {
			if $parsed.hash.<value> {
				die "Too many keys"
					if $parsed.hash.keys > 1;
				return Node.new(
					:type( 'EXPR' ),
					:name(
						self.value(
							$parsed.hash.<value>
						)
					)
				)
			}
			elsif $parsed.hash.<variable> {
				die "Too many keys"
					if $parsed.hash.keys > 1;
				return Node.new(
					:type( 'EXPR' ),
					:name(
						self.variable(
							$parsed.hash.<variable>
						)
					)
				)
			}
			elsif $parsed.hash.<longname> and
			      $parsed.hash.<args> {
				die "Too many keys"
					if $parsed.hash.keys > 2;
				return Node.new(
					:type( 'EXPR' ),
					:name(
						self.longname(
							$parsed.hash.<longname>
						)
					)
				)
			}
			elsif $parsed.hash.<longname> {
				die "Too many keys"
					if $parsed.hash.keys > 1;
				return Node.new(
					:type( 'EXPR' ),
					:name(
						self.longname(
							$parsed.hash.<longname>
						)
					)
				)
			}
			elsif $parsed.hash.<circumfix> {
				die "Too many keys"
					if $parsed.hash.keys > 1;
				return Node.new(
					:type( 'EXPR' ),
					:name(
						self.circumfix(
							$parsed.hash.<circumfix>
						)
					)
				)
			}
			die "Uncaught key"
		}
		die "Uncaught type"
	}

	method value( Mu $parsed ) {
		self.debug(
			'value',
			'value', $parsed
		);

		if $parsed.hash {
			if $parsed.hash.<number> {
				die "Too many keys"
					if $parsed.hash.keys > 1;
				return Node.new(
					:type( 'value' ),
					:name(
						self.number(
							$parsed.hash.<number>
						)
					)
				)
			}
			elsif $parsed.hash.<quote> {
				die "Too many keys"
					if $parsed.hash.keys > 1;
				return Node.new(
					:type( 'value' ),
					:name(
						self.quote(
							$parsed.hash.<quote>
						)
					)
				)
			}
			die "Uncaught key"
		}
		die "Uncaught type"
	}

	method number( Mu $parsed ) {
		self.debug(
			'number',
			'number', $parsed
		);

		if $parsed.hash {
			if $parsed.hash.<numish> {
				die "Too many keys"
					if $parsed.hash.keys > 1;
				return Node.new(
					:type( 'number' ),
					:name(
						self.numish(
							$parsed.hash.<numish>
						)
					)
				)
			}
			die "Uncaught key"
		}
		die "Uncaught type"
	}

	method quote( Mu $parsed ) {
		self.debug(
			'quote',
			'quote', $parsed
		);

		if $parsed.hash {
			if $parsed.hash.<nibble> {
				die "Too many keys"
					if $parsed.hash.keys > 1;
				return Node.new(
					:type( 'quote' ),
					:name(
						self.nibble(
							$parsed.hash.<nibble>
						)
					)
				)
			}
			elsif $parsed.hash.<quibble> {
				die "Too many keys"
					if $parsed.hash.keys > 1;
				return Node.new(
					:type( 'quote' ),
					:name(
						self.quibble(
							$parsed.hash.<quibble>
						)
					)
				)
			}
			die "Uncaught key"
		}
		die "Uncaught type"
	}

	method B( Mu $parsed ) {
		self.debug(
			'B',
			'B', $parsed
		);

		if $parsed.hash {
			die "hash"
		}
		if $parsed.Bool {
			return Node.new(
				:type( 'B' ),
				:name(
					 $parsed.Bool
				)
			)
		}
		die "Uncaught type"
	}

	method babble( Mu $parsed ) {
		self.debug(	
			'babble',
			'babble', $parsed
		);

		if $parsed.hash {
			if $parsed.hash.<B> {
				return Node.new(
					:type( 'babble' ),
					:name(
						self.B(
							$parsed.hash.<B>
						)
					)
				)
			}
			die "Uncaught type"
		}
		die "Uncaught type"
	}

	method identifier( Mu $parsed ) {
		self.debug(
			'identifier',
			'identifier', $parsed
		);

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
			return Node.new(
				:type( 'identifier' ),
				:child( @child )
			)
		}
		elsif $parsed.Str {
			return Node.new(
				:type( 'identifier' ),
				:name(
					$parsed.Str
				)
			)
		}
		die "Uncaught type"
	}

	method quotepair( Mu $parsed ) {
		self.debug(
			'quotepair',
			'quotepair', $parsed
		);

		if $parsed.hash {
			if $parsed.hash.<identifier> {
				die "Too many keys"
					if $parsed.hash.keys > 1;
				return Node.new(
					:type( 'quotepair' ),
					:node(
						self.identifier(
							$parsed.hash.<identifier>
						)
					)
				)
			}
			die "Uncaught key"
		}
		die "Uncaught type"
	}

	method babble_nibble( Mu $babble, Mu $nibble ) {
		self.debug(
			'babble_nibble',
			'babble', $babble,
			'nibble', $nibble
		);

		if $babble.hash {
			if $babble.hash.<quotepair> {
				my @child;
				for $babble.hash.<quotepair> {
					@child.push(
						self.quotepair( $_ )
					)
				}
				return Node.new(
					:type( 'babble_nibble' ),
					:child( @child )
				)
			}
			elsif $babble.hash.<B> {
				return Node.new(
					:type( 'babble_nibble' ),
					:name(
						self.B(
							$babble.hash.<B>
						)
					)
				)
			}
			die "Uncaught key"
		}
		die "Uncaught type"
	}

	method quibble( Mu $parsed ) {
		self.debug(
			'quibble',
			'quibble', $parsed
		);

		if $parsed.hash {
			if $parsed.hash.<babble> and
			   $parsed.hash.<nibble> {
				return Node.new(
					:type( 'quibble' ),
					:name(
						self.babble_nibble(
							$parsed.hash.<babble>,
							$parsed.hash.<nibble>
						)
					)
				)
			}
			die "Uncaught key"
		}
		die "Uncaught type"
	}

	method atom( Mu $parsed ) {
		self.debug(
			'atom',
			'atom', $parsed
		);

		if $parsed.hash {
			die "hash"
		}
		if $parsed.Str {
			return Node.new(
				:type( 'atom' ),
				:name(
					$parsed.Str
				)
			)
		}
		die "Uncaught type"
	}

	method noun( Mu $parsed ) {
		self.debug(
			'noun',
			'noun', $parsed
		);

		if $parsed.hash {
			if $parsed.hash.<atom> {
				return Node.new(
					:type( 'noun' ),
					:name(
						self.atom(
							$parsed.hash.<atom>
						)
					)
				)
			}
			die "Uncaught key"
		}
		if $parsed.Str {
			die "str"
		}
		die "Uncaught type"
	}

	method termish( Mu $parsed ) {
		self.debug(
			'termish',
			'termish', $parsed
		);

		if $parsed.hash {
			if $parsed.hash.<noun> {
				my @child;
				for $parsed.hash.<noun> {
					@child.push(
						self.noun( $_ )
					)
				}
				return Node.new(
					:type( 'termish' ),
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

	method termconj( Mu $parsed ) {
		self.debug(
			'termconj',
			'termconj', $parsed
		);

		if $parsed.hash {
			if $parsed.hash.<termish> {
				my @child;
				for $parsed.hash.<termish> {
					@child.push(
						self.termish( $_ )
					)
				}
				return Node.new(
					:type( 'termconj' ),
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

	method termalt( Mu $parsed ) {
		self.debug(
			'termalt',
			'termalt', $parsed
		);

		if $parsed.hash {
			if $parsed.hash.<termconj> {
				my @child;
				for $parsed.hash.<termconj> {
					@child.push(
						self.termconj( $_ )
					)
				}
				return Node.new(
					:type( 'termalt' )
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

	method termconjseq( Mu $parsed ) {
		self.debug(
			'termconjseq',
			'termconjseq', $parsed
		);

		if $parsed.hash {
			if $parsed.hash.<termalt> {
				my @child;
				for $parsed.hash.<termalt> {
					@child.push(
						self.termalt( $_ )
					)
				}
				return Node.new(
					:type( 'termconjseq' ),
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

	method termaltseq( Mu $parsed ) {
		self.debug(
			'termaltseq',
			'termaltseq', $parsed
		);

		if $parsed.hash {
			if $parsed.hash.<termconjseq> {
				my @child;
				for $parsed.hash.<termconjseq> {
					@child.push(
						self.termconjseq( $_ )
					)
				}
				return Node.new(
					:type( 'termaltseq' ),
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
		self.debug(
			'termseq',
			'termseq', $parsed
		);

		if $parsed.hash {
			if $parsed.hash.<termaltseq> {
				return Node.new(
					:type( 'termseq' ),
					:name(
						self.termaltseq(
							$parsed.hash.<termaltseq>
						)
					)
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
		self.debug(
			'nibble',
			'nibble', $parsed
		);

		if $parsed.hash {
			if $parsed.hash.<termseq> {
				return Node.new(
					:type( 'nibble' ),
					:name(
						self.termseq(
							$parsed.hash.<termseq>
						)
					)
				)
			}
			die "Uncaught key"
		}
		if $parsed.Str {
			return Node.new(
				:type( 'nibble' ),
				:name(
					$parsed.Str
				)
			)
		}
		die "Uncaught type"
	}

	method int_coeff_frac( Mu $int, Mu $coeff, Mu $frac ) {
		self.debug(
			'int_coeff_frac',
			'int',   $int,
			'coeff', $coeff,
			'frac',  $frac
		);

		if $int.hash {
			die "hash"
		}
		if $int.Int {
			return Node.new(
				:type( 'int_coeff_frac' ),
				:name(
					$int.Int
				)
			)
		}
		die "Uncaught type"
	}

	method int_coeff_escale( Mu $int, Mu $coeff, Mu $escale ) {
		self.debug(
			'int_coeff_escale',
			'int',    $int,
			'coeff',  $coeff,
			'escale', $escale
		);

		if $int.hash {
			die "hash"
		}
		if $int.Int {
			return Node.new(
				:type( 'int_coeff_escale' ),
				:name(
					$int.Int
				)
			)
		}
		die "Uncaught type"
	}

	method dec_number( Mu $parsed ) {
		self.debug(
			'dec_number',
			'dec_number', $parsed
		);

		if $parsed.hash {
			if $parsed.hash.<int> and
			   $parsed.hash.<coeff> and
			   $parsed.hash.<frac> {
				return Node.new(
					:type( 'dec_number' ),
					:name(
						self.int_coeff_frac(
							$parsed.hash.<int>,
							$parsed.hash.<coeff>,
							$parsed.hash.<frac>
						)
					)
				)
			}
			elsif $parsed.hash.<int> and
			      $parsed.hash.<coeff> and
			      $parsed.hash.<escale> {
				return Node.new(
					:type( 'dec_number' ),
					:name(
						self.int_coeff_escale(
							$parsed.hash.<int>,
							$parsed.hash.<coeff>,
							$parsed.hash.<escale>
						)
					)
				)
			}
			die "Uncaught key"
		}
		die "Uncaught type"
	}

	method numish( Mu $parsed ) {
		self.debug(
			'numish',
			'numish', $parsed
		);

		if $parsed.hash {
			if $parsed.hash.<integer> {
				die "Too many keys"
					if $parsed.hash.keys > 1;
				return Node.new(
					:type( 'numish' ),
					:name(
						self.integer(
							$parsed.hash.<integer>
						)
					)
				)
			}
			elsif $parsed.hash.<rad_number> {
				die "Too many keys"
					if $parsed.hash.keys > 1;
				return Node.new(
					:type( 'numish' ),
					:name(
						self.rad_number(
							$parsed.hash.<rad_number>
						)
					)
				)
			}
			elsif $parsed.hash.<dec_number> {
				die "Too many keys"
					if $parsed.hash.keys > 1;
				return Node.new(
					:type( 'numish' ),
					:name(
						self.dec_number(
							$parsed.hash.<dec_number>
						)
					)
				)
			}
			die "Uncaught key"
		}
		die "Uncaught type"
	}

	method integer( Mu $parsed ) {
		self.debug(
			'integer',
			'integer', $parsed
		);

		if $parsed.hash {
			if $parsed.hash.<decint> and
			   $parsed.hash.<VALUE> {
				die "Too many keys"
					if $parsed.hash.keys > 2;
				return Node.new(
					:type( 'integer' ),
					:name(
						self.decint(
							$parsed.hash.<decint>
						)
					)
				)
			}
			elsif $parsed.hash.<binint> and
			      $parsed.hash.<VALUE> {
				die "Too many keys"
					if $parsed.hash.keys > 2;
				return Node.new(
					:type( 'integer' ),
					:name(
						self.binint(
							$parsed.hash.<binint>
						)
					)
				)
			}
			elsif $parsed.hash.<octint> and
			      $parsed.hash.<VALUE> {
				die "Too many keys"
					if $parsed.hash.keys > 2;
				return Node.new(
					:type( 'integer' ),
					:name(
						self.octint(
							$parsed.hash.<octint>
						)
					)
				)
			}
			elsif $parsed.hash.<hexint> and
			      $parsed.hash.<VALUE> {
				die "Too many keys"
					if $parsed.hash.keys > 2;
				return Node.new(
					:type( 'integer' ),
					:name(
						self.hexint(
							$parsed.hash.<hexint>
						)
					)
				)
			}
			die "Uncaught key"
		}
		die "Uncaught type"
	}

	method circumfix( Mu $parsed ) {
		self.debug(
			'circumfix',
			'circumfix', $parsed
		);

		if $parsed.hash {
			if $parsed.hash.<semilist> {
				die "Too many keys"
					if $parsed.hash.keys > 2;
				return Node.new(
					:type( 'circumfix' ),
					:name(
						self.semilist(
							$parsed.hash.<semilist>
						)
					)
				)
			}
			elsif $parsed.hash.<binint> and
			      $parsed.hash.<VALUE> {
				die "Too many keys"
					if $parsed.hash.keys > 2;
				return Node.new(
					:type( 'integer' ),
					:name(
						self.binint(
							$parsed.hash.<binint>
						)
					)
				)
			}
			elsif $parsed.hash.<octint> and
			      $parsed.hash.<VALUE> {
				die "Too many keys"
					if $parsed.hash.keys > 2;
				return Node.new(
					:type( 'integer' ),
					:name(
						self.octint(
							$parsed.hash.<octint>
						)
					)
				)
			}
			elsif $parsed.hash.<hexint> and
			      $parsed.hash.<VALUE> {
				die "Too many keys"
					if $parsed.hash.keys > 2;
				return Node.new(
					:type( 'integer' ),
					:name(
						self.hexint(
							$parsed.hash.<hexint>
						)
					)
				)
			}
			die "Uncaught key"
		}
		die "Uncaught type"
	}

	method circumfix_radix( Mu $circumfix, Mu $radix ) {
		self.debug(
			'circumfix',
			'circumfix', $circumfix,
			'radix',     $radix
		);

		if $circumfix.hash {
			if $circumfix.hash.<semilist> {
				die "Too many keys"
					if $circumfix.hash.keys > 1;
				return Node.new(
					:type( 'circumfix_radix' ),
					:name(
						self.semilist(
							$circumfix.hash.<semilist>
						)
					)
				)
			}
			die "Uncaught key"
		}
		die "Uncaught type"
	}

	method semilist( Mu $parsed ) {
		self.debug(
			'semilist',
			'semilist', $parsed
		);

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
				return Node.new(
					:type( 'semilist' ),
					:child( @child )
				)
			}
			elsif $parsed.hash:defined<statement> {
				return Node.new(
					:type( 'semilist' )
				)
			}
			die "Uncaught key"
		}
		die "Uncaught type"
	}

	method rad_number( Mu $parsed ) {
		self.debug(
			'rad_number',
			'rad_number', $parsed
		);

		if $parsed.hash {
			# XXX fix this branch...
			if $parsed.hash.<circumfix> and
			   $parsed.hash.<radix> {
				die "Too many keys"
					if $parsed.hash.keys > 4;
				return Node.new(
					:type( 'rad_number' ),
					:name(
						self.circumfix_radix(
							$parsed.hash.<circumfix>,
							$parsed.hash.<radix>
						)
					)
				)
			}
			die "Uncaught key"
		}
		die "Uncaught type"
	}

	method binint( Mu $parsed ) {
		self.debug(
			'binint',
			'binint', $parsed
		);

		if $parsed.hash {
			die "hash"
		}
		if $parsed.Int {
			return Node.new(
				:type( 'binint' ),
				:name(
					$parsed.Int
				)
			)
		}
		die "Uncaught type"
	}

	method octint( Mu $parsed ) {
		self.debug(
			'octint',
			'octint', $parsed
		);

		if $parsed.hash {
			die "hash"
		}
		if $parsed.Int {
			return Node.new(
				:type( 'octint' ),
				:name(
					$parsed.Int
				)
			)
		}
		die "Uncaught type"
	}

	method decint( Mu $parsed ) {
		self.debug(
			'decint',
			'decint', $parsed
		);

		if $parsed.hash {
			die "hash"
		}
		if $parsed.Int {
			return Node.new(
				:type( 'decint' ),
				:name(
					$parsed.Int
				)
			)
		}
		die "Uncaught type"
	}

	method hexint( Mu $parsed ) {
		self.debug(
			'hexint',
			'hexint', $parsed
		);

		if $parsed.hash {
			die "hash"
		}
		if $parsed.Int {
			return Node.new(
				:type( 'hexint' ),
				:name(
					$parsed.Int
				)
			)
		}
		die "Uncaught type"
	}
}
