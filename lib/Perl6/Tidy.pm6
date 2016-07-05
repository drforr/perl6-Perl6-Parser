class Perl6::Tidy {
	use nqp;

	has $.debugging = False;

	class Node {
		has Str $.type is required;
		has $.name;
		has $.child;
	}

	method debug( Str $name, Mu $parsed ) {
		my @types;

		return unless $.debugging;

		if $parsed.list {
			@types.push( 'list' )
		}
		elsif $parsed.hash {
			@types.push( 'hash' )
		}
		@types.push( 'Int'  ) if $parsed.Int;
		@types.push( 'Str'  ) if $parsed.Str;
		@types.push( 'Bool' ) if $parsed.Bool;

		die "$name: Unknown type" unless @types;

		say "$name ({@types})";

		if $parsed.list {
			for $parsed.list {
				say "$name\[\]:\n" ~ $_.dump
			}
			return;
		}
		elsif $parsed.hash() {
			say "$name\{\} keys: " ~ $parsed.hash.keys;
			say "$name\{\}:\n" ~   $parsed.dump;
		}
		say "\+$name: "    ~   $parsed.Int       if $parsed.Int;
		say "\~$name: '"   ~   $parsed.Str ~ "'" if $parsed.Str;
		say "\?$name: "    ~ ~?$parsed.Bool      if $parsed.Bool;

		say "";
	}

	method tidy( Str $text ) {
		my $*LINEPOSCACHE;
		my $compiler := nqp::getcomp('perl6');
		my $g := nqp::findmethod($compiler,'parsegrammar')($compiler);
		#$g.HOW.trace-on($g);
		my $a := nqp::findmethod($compiler,'parseactions')($compiler);

		my $parsed = $g.parse(
			$text,
			:p( 0 ),
			:actions( $a )
		);

		self.debug( 'tidy', $parsed );

		if $parsed.hash {
			if $parsed.hash.<statementlist> {
				die "Too many keys"
					if $parsed.hash.keys > 1;
				return Node.new(
					:type( 'tidy' ),
					:statementlist(
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
		self.debug( 'statementlist', $parsed );

		if $parsed.hash {
			if $parsed.hash.<statement> {
				die "Too many keys"
					if $parsed.hash.keys > 1;
				my @child;
				for $parsed.hash.<statement> {
					@child.push(
						self.statement(
							$_
						)
					)
				}
				return Node.new(
					:type( 'statementlist' ),
					:child( @child )
				)
			}
			elsif $parsed.hash:defined<statement> {
				die "Too many keys"
					if $parsed.hash.keys > 1;
				return Node.new(
					:type( 'statementlist' ),
				)
			}
			die "Uncaught key"
		}
		die "Uncaught type"
	}

	method statement( Mu $parsed ) {
		self.debug( 'statement', $parsed );

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
					:EXPR(
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
					:sigil(
						self.sigil(
							$parsed.hash.<sigil>
						)
					),
					:desigilname(
						self.desigilname(
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
		self.debug( 'sym', $parsed );

		if $parsed.hash {
			die "hash"
		}
		if $parsed.Str {
			return Node.new(
				:type( 'sym' ),
				:name( $parsed.Str )
			)
		}
		die "Uncaught type"
	}

	method sign( Mu $parsed ) {
		self.debug( 'sign', $parsed );

		if $parsed.Bool {
			return Node.new(
				:type( 'sign' ),
				:name( $parsed.Bool )
			)
		}
		die "Uncaught type"
	}

	method postfix( Mu $parsed ) {
		self.debug( 'postfix', $parsed );

		if $parsed.hash {
			if $parsed.hash.<sym> and
			   $parsed.hash.<O> {
				die "Too many keys"
					if $parsed.hash.keys > 2;
				return Node.new(
					:type( 'postfix' ),
					:sym(
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
		self.debug( 'OPER', $parsed );

		if $parsed.hash {
			if $parsed.hash.<sym> and
			   $parsed.hash.<O> {
				die "Too many keys"
					if $parsed.hash.keys > 2;
				return Node.new(
					:type( 'OPER' ),
					:sym(
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
		self.debug( 'name', $parsed );

		if $parsed.hash {
			if $parsed.hash.<identifier> and
			   $parsed.hash.<morename> {
				die "Too many keys"
					if $parsed.hash.keys > 2;
				my @child;
				for $parsed.hash.<morename> {
					@child.push(
						$_
					)
				}
				return Node.new(
					:type( 'name' ),
					:identifier(
						self.identifier(
							$parsed.hash.<identifier>
						)
					),
					:child( @child )
				)
			}
			elsif $parsed.hash.<identifier> and
			      $parsed.hash:defined<morename> {
				die "Too many keys"
					if $parsed.hash.keys > 2;
				return Node.new(
					:type( 'name' ),
					:identifier(
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
		self.debug( 'longname', $parsed );

		if $parsed.hash {
			if $parsed.hash.<name> and
			   $parsed.hash:defined<colonpair> {
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

	method twigil( Mu $parsed ) {
		self.debug( 'twigil', $parsed );

		if $parsed.hash {
			if $parsed.hash.<sym> {
				die "Too many keys"
					if $parsed.hash.keys > 1;
				return Node.new(
					:type( 'twigil' ),
					:sym(
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

	method sigil( Mu $parsed ) {
		self.debug( 'sigil', $parsed );

		if $parsed.Str {
			return Node.new(
				:type( 'sigil' ),
				:name( $parsed.Str )
			)
		}
		die "Uncaught type"
	}

	method desigilname( Mu $parsed ) {
		self.debug( 'desigilname', $parsed );

		if $parsed.hash {
			if $parsed.hash.<longname> {
				die "Too many keys"
					if $parsed.hash.keys > 1;
				return Node.new(
					:type( 'desigilname' ),
					:longname(
						self.longname(
							$parsed.hash.<longname>
						)
					)
				)
			}
			die "Unknown key"
		}
		if $parsed.Str {
			return Node.new(
				:type( 'desigilname' ),
				:name( $parsed.Str )
			)
		}
		die "Uncaught type"
	}

	method variable( Mu $parsed ) {
		self.debug( 'variable', $parsed );

		if $parsed.hash {
			if $parsed.hash.<twigil> and
			   $parsed.hash.<sigil> and
                           $parsed.hash.<desigilname> {
				die "Too many keys"
					if $parsed.hash.keys > 3;
				return Node.new(
					:type( 'variable' ),
					:twigil(
						self.twigil(
							$parsed.hash.<twigil>
						)
					),
					:sigil(
						self.sigil(
							$parsed.hash.<sigil>
						)
					),
					:desigilname(
						self.desigilname(
							$parsed.hash.<desigilname>
						)
					),
				)
			}
			elsif $parsed.hash.<sigil> and
                              $parsed.hash.<desigilname> {
				die "Too many keys"
					if $parsed.hash.keys > 2;
				return Node.new(
					:type( 'variable' ),
					:sigil(
						self.sigil(
							$parsed.hash.<sigil>
						)
					),
					:desigilname(
						self.desigilname(
							$parsed.hash.<desigilname>
						)
					)
				)
			}
			elsif $parsed.hash.<sigil> {
				die "Too many keys"
					if $parsed.hash.keys > 1;
				return Node.new(
					:type( 'variable' ),
					:sigil(
						self.sigil(
							$parsed.hash.<sigil>
						)
					)
				)
			}
			die "Uncaught key"
		}
		die "Uncaught type"
	}

	method routine_declarator( Mu $parsed ) {
		self.debug( 'routine_declarator', $parsed );

		if $parsed.hash {
			if $parsed.hash.<sym> and
			   $parsed.hash.<routine_def> {
				die "Too many keys"
					if $parsed.hash.keys > 2;
				return Node.new(
					:type( 'routine_declarator' ),
					:sym(
						self.sym(
							$parsed.hash.<sym>
						)
					),
					:routine_def(
						self.routine_def(
							$parsed.hash.<routine_def>
						)
					)
				)
			}
			die "Uncaught key"
		}
		die "Uncaught type"
	}

	method package_declarator( Mu $parsed ) {
		self.debug( 'package_declarator', $parsed );

		if $parsed.hash {
			if $parsed.hash.<sym> and
			   $parsed.hash.<package_def> {
				die "Too many keys"
					if $parsed.hash.keys > 2;
				return Node.new(
					:type( 'package_declarator' ),
					:sym(
						self.sym(
							$parsed.hash.<sym>
						)
					),
					:package_def(
						self.package_def(
							$parsed.hash.<package_def>
						)
					)
				)
			}
			die "Uncaught key"
		}
		die "Uncaught type"
	}

	method regex_declarator( Mu $parsed ) {
		self.debug( 'regex_declarator', $parsed );

		if $parsed.hash {
			if $parsed.hash.<sym> and
			   $parsed.hash.<regex_def> {
				die "Too many keys"
					if $parsed.hash.keys > 2;
				return Node.new(
					:type( 'regex_declarator' ),
					:sym(
						self.sym(
							$parsed.hash.<sym>
						)
					),
					:regex_def(
						self.regex_def(
							$parsed.hash.<regex_def>
						)
					)
				)
			}
			die "Uncaught key"
		}
		die "Uncaught type"
	}

	method routine_def( Mu $parsed ) {
		self.debug( 'routine_def', $parsed );

		if $parsed.hash {
			if $parsed.hash.<blockoid> and
			   $parsed.hash.<deflongname> {
				die "Too many keys"
					if $parsed.hash.keys > 3;
				return Node.new(
					:type( 'routine_def' ),
					:blockoid(
						self.blockoid(
							$parsed.hash.<blockoid>
						)
					),
					:deflongname(
						self.deflongname(
							$parsed.hash.<deflongname>
						)
					)
				)
			}
			die "Uncaught key"
		}
		die "Uncaught type"
	}

	method package_def( Mu $parsed ) {
		self.debug( 'package_def', $parsed );

		if $parsed.hash {
			if $parsed.hash.<blockoid> {
				die "Too many keys"
					if $parsed.hash.keys > 3;
				return Node.new(
					:type( 'package_def' ),
					:blockoid(
						self.blockoid(
							$parsed.hash.<blockoid>
						)
					),
					:longname(
						self.longname(
							$parsed.hash.<longname>
						)
					)
				)
			}
			die "Uncaught key"
		}
		die "Uncaught type"
	}

	method regex_def( Mu $parsed ) {
		self.debug( 'regex_def', $parsed );

		if $parsed.hash {
			if $parsed.hash.<deflongname> and
			   $parsed.hash:defined<signature> and
			   $parsed.hash:defined<trait> and
			   $parsed.hash.<nibble> {
				die "Too many keys"
					if $parsed.hash.keys > 4;
				return Node.new(
					:type( 'regex_def' ),
					:nibble(
						self.nibble(
							$parsed.hash.<nibble>
						)
					),
					:deflongname(
						self.deflongname(
							$parsed.hash.<deflongname>
						)
					)
				)
			}
			die "Uncaught key"
		}
		die "Uncaught type"
	}

	method blockoid( Mu $parsed ) {
		self.debug( 'blockoid', $parsed );

		if $parsed.hash {
			if $parsed.hash.<statementlist> {
				die "Too many keys"
					if $parsed.hash.keys > 1;
				return Node.new(
					:type( 'blockoid' ),
					:statementlist(
						self.statementlist(
							$parsed.hash.<statementlist>
						)
					)
				)
			}
			die "Uncaught key"
		}
		die "Uncaught type"
	}

	method deflongname( Mu $parsed ) {
		self.debug( 'deflongname', $parsed );

		if $parsed.hash {
			if $parsed.hash.<name> {
				die "Too many keys"
					if $parsed.hash.keys > 2;
				return Node.new(
					:type( 'deflongname' ),
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

	method EXPR( Mu $parsed ) {
		self.debug( 'EXPR', $parsed );

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
					:value(
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
					:variable(
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
					:longname(
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
					:longname(
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
					:circumfix(
						self.circumfix(
							$parsed.hash.<circumfix>
						)
					)
				)
			}
			elsif $parsed.hash.<colonpair> {
				die "Too many keys"
					if $parsed.hash.keys > 1;
				return Node.new(
					:type( 'EXPR' ),
					:colonpair(
						self.colonpair(
							$parsed.hash.<colonpair>
						)
					)
				)
			}
			elsif $parsed.hash.<scope_declarator> {
				die "Too many keys"
					if $parsed.hash.keys > 1;
				return Node.new(
					:type( 'EXPR' ),
					:scope_declarator(
						self.scope_declarator(
							$parsed.hash.<scope_declarator>
						)
					)
				)
			}
			elsif $parsed.hash.<routine_declarator> {
				die "Too many keys"
					if $parsed.hash.keys > 1;
				return Node.new(
					:type( 'EXPR' ),
					:routine_declarator(
						self.routine_declarator(
							$parsed.hash.<routine_declarator>
						)
					)
				)
			}
			elsif $parsed.hash.<package_declarator> {
				die "Too many keys"
					if $parsed.hash.keys > 1;
				return Node.new(
					:type( 'EXPR' ),
					:package_declarator(
						self.package_declarator(
							$parsed.hash.<package_declarator>
						)
					)
				)
			}
			elsif $parsed.hash.<regex_declarator> {
				die "Too many keys"
					if $parsed.hash.keys > 1;
				return Node.new(
					:type( 'EXPR' ),
					:regex_declarator(
						self.regex_declarator(
							$parsed.hash.<regex_declarator>
						)
					)
				)
			}
			die "Uncaught key"
		}
		die "Uncaught type"
	}

	method variable_declarator( Mu $parsed ) {
		self.debug( 'variable_declarator', $parsed );

		if $parsed.hash {
			if $parsed.hash.<variable> and
			   $parsed.hash:defined<semilist> and
			   $parsed.hash:defined<postcircumfix> and
			   $parsed.hash:defined<signature> and
			   $parsed.hash:defined<trait> and
			   $parsed.hash.<post_constraint> {
				die "Too many keys"
					if $parsed.hash.keys > 6;
				my @child;
				for $parsed.hash.<post_constraint> {
					@child.push(
						self.EXPR(
							$_.hash.<EXPR>
						)
					)
				}
				return Node.new(
					:type( 'variable_declarator' ),
					:child( @child )
					:variable(
						self.variable(
							$parsed.hash.<variable>
						)
					)
				)
			}
			elsif $parsed.hash.<variable> and
			      $parsed.hash:defined<semilist> and
			      $parsed.hash:defined<postcircumfix> and
			      $parsed.hash:defined<signature> and
			      $parsed.hash:defined<trait> and
			      $parsed.hash:defined<post_constraint> {
				die "Too many keys"
					if $parsed.hash.keys > 6;
				return Node.new(
					:type( 'variable_declarator' ),
					:variable(
						self.variable(
							$parsed.hash.<variable>
						)
					),
				)
			}
			die "Uncaught key"
		}
		die "Uncaught type"
	}

	method multi_declarator( Mu $parsed ) {
		self.debug( 'multi_declarator', $parsed );

		if $parsed.hash {
			if $parsed.hash.<declarator> {
				die "Too many keys"
					if $parsed.hash.keys > 1;
				return Node.new(
					:type( 'multi_declarator' ),
					:declarator(
						self.declarator(
							$parsed.hash.<declarator>
						)
					),
				)
			}
			die "Uncaught key"
		}
		die "Uncaught type"
	}

	method declarator( Mu $parsed ) {
		self.debug( 'declarator', $parsed );

		if $parsed.hash {
			if $parsed.hash.<variable_declarator> and
			   $parsed.hash:defined<trait> {
				die "Too many keys"
					if $parsed.hash.keys > 2;
				return Node.new(
					:type( 'declarator' ),
					:variable_declarator(
						self.variable_declarator(
							$parsed.hash.<variable_declarator>
						)
					),
				)
			}
			elsif $parsed.hash.<regex_declarator> and
			      $parsed.hash:defined<trait> {
				die "Too many keys"
					if $parsed.hash.keys > 2;
				return Node.new(
					:type( 'declarator' ),
					:regex_declarator(
						self.regex_declarator(
							$parsed.hash.<regex_declarator>
						)
					),
				)
			}
			die "Uncaught key"
		}
		die "Uncaught type"
	}

	method DECL( Mu $parsed ) {
		self.debug( 'DECL', $parsed );

		if $parsed.hash {
			if $parsed.hash.<variable_declarator> and
			   $parsed.hash:defined<trait> {
				die "Too many keys"
					if $parsed.hash.keys > 2;
				return Node.new(
					:type( 'DECL' ),
					:variable_declarator(
						self.variable_declarator(
							$parsed.hash.<variable_declarator>
						)
					),
				)
			}
			elsif $parsed.hash.<regex_declarator> and
			      $parsed.hash:defined<trait> {
				die "Too many keys"
					if $parsed.hash.keys > 2;
				return Node.new(
					:type( 'DECL' ),
					:regex_declarator(
						self.regex_declarator(
							$parsed.hash.<regex_declarator>
						)
					),
				)
			}
			elsif $parsed.hash.<declarator> {
				die "Too many keys"
					if $parsed.hash.keys > 2;
				return Node.new(
					:type( 'DECL' ),
					:declarator(
						self.declarator(
							$parsed.hash.<declarator>
						)
					),
				)
			}
			die "Uncaught key"
		}
		die "Uncaught type"
	}

	method typename( Mu $parsed ) {
		self.debug( 'typename', $parsed );

		if $parsed.list {
			my @child;
			for $parsed.list {
				@child.push(
					self.longname(
						$_.hash.<longname>
					)
				)
			}
			return Node.new(
				:type( 'typename' ),
				:child( @child )
			)
		}
		elsif $parsed.hash {
			if $parsed.hash.<longname> {
				die "Too many keys"
					if $parsed.hash.keys > 3;
				return Node.new(
					:type( 'typename' ),
					:longname(
						self.longname(
							$parsed.hash.<longname>
						)
					)
				)
			}
			die "Uncaught key"
		}
		die "Uncaught type"
	}

	method scoped( Mu $parsed ) {
		self.debug( 'scoped', $parsed );

		if $parsed.hash {
			if $parsed.hash.<declarator> and
			   $parsed.hash.<DECL> and
			   $parsed.hash:defined<typename> {
				die "Too many keys"
					if $parsed.hash.keys > 3;
				return Node.new(
					:type( 'scoped' ),
					:declarator(
						self.declarator(
							$parsed.hash.<declarator>
						)
					),
					:DECL(
						self.DECL(
							$parsed.hash.<DECL>
						)
					),
				)
			}
			elsif $parsed.hash.<multi_declarator> and
			      $parsed.hash.<DECL> and
			      $parsed.hash.<typename> {
				die "Too many keys"
					if $parsed.hash.keys > 3;
				return Node.new(
					:type( 'scoped' ),
					:multi_declarator(
						self.multi_declarator(
							$parsed.hash.<multi_declarator>
						)
					),
					:DECL(
						self.DECL(
							$parsed.hash.<DECL>
						)
					),
					:typename(
						self.typename(
							$parsed.hash.<typename>
						)
					),
				)
			}
			die "Uncaught key"
		}
		die "Uncaught type"
	}

	method scope_declarator( Mu $parsed ) {
		self.debug( 'scope_declarator', $parsed );

		if $parsed.hash {
			if $parsed.hash.<sym> and
			   $parsed.hash.<scoped> {
				die "Too many keys"
					if $parsed.hash.keys > 2;
				return Node.new(
					:type( 'scope_declarator' ),
					:sym(
						self.sym(
							$parsed.hash.<sym>
						)
					),
					:scoped(
						self.scoped(
							$parsed.hash.<scoped>
						)
					)
				)
			}
			die "Uncaught key"
		}
		die "Uncaught type"
	}

	method value( Mu $parsed ) {
		self.debug( 'value', $parsed );

		if $parsed.hash {
			if $parsed.hash.<number> {
				die "Too many keys"
					if $parsed.hash.keys > 1;
				return Node.new(
					:type( 'value' ),
					:number(
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
					:quote(
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
		self.debug( 'number', $parsed );

		if $parsed.hash {
			if $parsed.hash.<numish> {
				die "Too many keys"
					if $parsed.hash.keys > 1;
				return Node.new(
					:type( 'number' ),
					:numish(
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
		self.debug( 'quote', $parsed );

		if $parsed.hash {
			if $parsed.hash.<nibble> {
				die "Too many keys"
					if $parsed.hash.keys > 1;
				return Node.new(
					:type( 'quote' ),
					:nibble(
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
					:quibble(
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
		self.debug( 'B', $parsed );

		if $parsed.hash {
			die "hash"
		}
		if $parsed.Bool {
			return Node.new(
				:type( 'B' ),
				:name( $parsed.Bool )
			)
		}
		die "Uncaught type"
	}

	method babble( Mu $parsed ) {
		self.debug( 'babble', $parsed );

		if $parsed.hash {
			if $parsed.hash.<B> {
				return Node.new(
					:type( 'babble' ),
					:B(
						self.B(
							$parsed.hash.<B>
						)
					)
				)
			}
			die "Uncaught key"
		}
		die "Uncaught type"
	}

	method signature( Mu $parsed ) {
		self.debug( 'signature', $parsed );

		if $parsed.Bool {
			return Node.new(
				:type( 'signature' ),
				:name( $parsed.Bool )
			)
		}
		die "Uncaught type"
	}

	method fakesignature( Mu $parsed ) {
		self.debug( 'fakesignature', $parsed );

		if $parsed.hash {
			if $parsed.hash.<signature> {
				die "Too many keys"
					if $parsed.hash.keys > 1;
				return Node.new(
					:type( 'fakesignature' ),
					:signature(
						self.signature(
							$parsed.hash.<signature>
						)
					)
				)
			}
			die "Uncaught key"
		}
		die "Uncaught type"
	}

	method colonpair( Mu $parsed ) {
		self.debug( 'colonpair', $parsed );

		if $parsed.hash {
			if $parsed.hash.<identifier> {
				die "Too many keys"
					if $parsed.hash.keys > 1;
				return Node.new(
					:type( 'colonpair' ),
					:identifier(
						self.identifier(
							$parsed.hash.<identifier>
						)
					)
				)
			}
			elsif $parsed.hash.<fakesignature> {
				die "Too many keys"
					if $parsed.hash.keys > 1;
				return Node.new(
					:type( 'colonpair' ),
					:fakesignature(
						self.fakesignature(
							$parsed.hash.<fakesignature>
						)
					)
				)
			}
			die "Uncaught key"
		}
		die "Uncaught type"
	}

	method identifier( Mu $parsed ) {
		self.debug( 'identifier', $parsed );

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
				:name( $parsed.Str )
			)
		}
		die "Uncaught type"
	}

	method quotepair( Mu $parsed ) {
		self.debug( 'quotepair', $parsed );

		if $parsed.hash {
			if $parsed.hash.<identifier> {
				die "Too many keys"
					if $parsed.hash.keys > 1;
				return Node.new(
					:type( 'quotepair' ),
					:identifier(
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

	method quibble( Mu $parsed ) {
		self.debug( 'quibble', $parsed );

		if $parsed.hash {
			if $parsed.hash.<babble> and
			   $parsed.hash.<nibble> {
				return Node.new(
					:type( 'quibble' ),
					:babble(
						self.babble(
							$parsed.hash.<babble>
						)
					),
					:nibble(
						self.nibble(
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
		self.debug( 'atom', $parsed );

		if $parsed.hash {
			die "hash"
		}
		if $parsed.Str {
			return Node.new(
				:type( 'atom' ),
				:name( $parsed.Str )
			)
		}
		die "Uncaught type"
	}

	method noun( Mu $parsed ) {
		self.debug( 'noun', $parsed );

		if $parsed.hash {
			if $parsed.hash.<atom> {
				return Node.new(
					:type( 'noun' ),
					:atom(
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
		self.debug( 'termish', $parsed );

		if $parsed.hash {
			if $parsed.hash.<noun> {
				my @child;
				for $parsed.hash.<noun> {
					@child.push(
						self.noun(
							$_
						)
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
		self.debug( 'termconj', $parsed );

		if $parsed.hash {
			if $parsed.hash.<termish> {
				my @child;
				for $parsed.hash.<termish> {
					@child.push(
						self.termish(
							$_
						)
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
		self.debug( 'termalt', $parsed );

		if $parsed.hash {
			if $parsed.hash.<termconj> {
				my @child;
				for $parsed.hash.<termconj> {
					@child.push(
						self.termconj(
							$_
						)
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
		self.debug( 'termconjseq', $parsed );

		if $parsed.hash {
			if $parsed.hash.<termalt> {
				my @child;
				for $parsed.hash.<termalt> {
					@child.push(
						self.termalt(
							$_
						)
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
		self.debug( 'termaltseq', $parsed );

		if $parsed.hash {
			if $parsed.hash.<termconjseq> {
				my @child;
				for $parsed.hash.<termconjseq> {
					@child.push(
						self.termconjseq(
							$_
						)
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
		self.debug( 'termseq', $parsed );

		if $parsed.hash {
			if $parsed.hash.<termaltseq> {
				return Node.new(
					:type( 'termseq' ),
					:termaltseq(
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
		self.debug( 'nibble', $parsed );

		if $parsed.hash {
			if $parsed.hash.<termseq> {
				return Node.new(
					:type( 'nibble' ),
					:termseq(
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
				:name( $parsed.Str )
			)
		}
		die "Uncaught type"
	}

	method dec_number( Mu $parsed ) {
		self.debug( 'dec_number', $parsed );

		if $parsed.hash {
			if $parsed.hash.<int> and
			   $parsed.hash.<coeff> and
			   $parsed.hash.<frac> {
				return Node.new(
					:type( 'dec_number' ),
					:int(
						self.int(
							$parsed.hash.<int>
						)
					),
					:coeff(
						self.coeff(
							$parsed.hash.<coeff>
						)
					),
					:frac(
						self.frac(
							$parsed.hash.<frac>
						)
					),
				)
			}
			elsif $parsed.hash.<int> and
			      $parsed.hash.<coeff> and
			      $parsed.hash.<escale> {
				return Node.new(
					:type( 'dec_number' ),
					:int(
						self.int(
							$parsed.hash.<int>
						)
					),
					:coeff(
						self.coeff(
							$parsed.hash.<coeff>
						)
					),
					:escale(
						self.escale(
							$parsed.hash.<escale>
						)
					),
				)
			}
			die "Uncaught key"
		}
		die "Uncaught type"
	}

	method numish( Mu $parsed ) {
		self.debug( 'numish', $parsed );

		if $parsed.hash {
			if $parsed.hash.<integer> {
				die "Too many keys"
					if $parsed.hash.keys > 1;
				return Node.new(
					:type( 'numish' ),
					:integer(
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
					:rad_number(
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
					:dec_number(
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
		self.debug( 'integer', $parsed );

		if $parsed.hash {
			if $parsed.hash.<decint> and
			   $parsed.hash.<VALUE> {
				die "Too many keys"
					if $parsed.hash.keys > 2;
				return Node.new(
					:type( 'integer' ),
					:decint(
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
					:binint(
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
					:octint(
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
					:hexint(
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
		self.debug( 'circumfix', $parsed );

		if $parsed.hash {
			if $parsed.hash.<semilist> {
				die "Too many keys"
					if $parsed.hash.keys > 2;
				return Node.new(
					:type( 'circumfix' ),
					:semilist(
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
					:type( 'circumfix' ),
					:binint(
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
					:type( 'circumfix' ),
					:octint(
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
					:type( 'circumfix' ),
					:hexint(
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

	method semilist( Mu $parsed ) {
		self.debug( 'semilist', $parsed );

		if $parsed.hash {
			if $parsed.hash.<statement> {
				die "Too many keys"
					if $parsed.hash.keys > 1;
				my @child;
				for $parsed.hash.<statement> {
					@child.push(
						self.statement(
							$_
						)
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
		self.debug( 'rad_number', $parsed );

		if $parsed.hash {
			if $parsed.hash.<circumfix> and
			   $parsed.hash.<radix> and
			   $parsed.hash:defined<exp> and
			   $parsed.hash:defined<base> {
				die "Too many keys"
					if $parsed.hash.keys > 4;
				return Node.new(
					:type( 'rad_number' ),
					:circumfix(
						self.circumfix(
							$parsed.hash.<circumfix>,
						)
					),
					:radix(
						self.radix(
							$parsed.hash.<radix>,
						)
					)
				)
			}
			die "Uncaught key"
		}
		die "Uncaught type"
	}

	method int( Mu $parsed ) {
		self.debug( 'int', $parsed );

		if $parsed.hash {
			die "hash"
		}
		if $parsed.Int {
			return Node.new(
				:type( 'int' ),
				:name( $parsed.Int )
			)
		}
		die "Uncaught type"
	}

	method radix( Mu $parsed ) {
		self.debug( 'radix', $parsed );

		if $parsed.hash {
			die "hash"
		}
		if $parsed.Int {
			return Node.new(
				:type( 'radix' ),
				:name( $parsed.Int )
			)
		}
		die "Uncaught type"
	}

	method frac( Mu $parsed ) {
		self.debug( 'frac', $parsed );

		if $parsed.hash {
			die "hash"
		}
		if $parsed.Int {
			return Node.new(
				:type( 'frac' ),
				:name( $parsed.Int )
			)
		}
		die "Uncaught type"
	}

	method coeff( Mu $parsed ) {
		self.debug( 'coeff', $parsed );

		if $parsed.hash {
			die "hash"
		}
		if $parsed.Int {
			return Node.new(
				:type( 'coeff' ),
				:name( $parsed.Int )
			)
		}
		die "Uncaught type"
	}

	method escale( Mu $parsed ) {
		self.debug( 'escale', $parsed );

		if $parsed.hash {
			if $parsed.hash.<sign> and
			   $parsed.hash.<decint> {
				die "Too many keys"
					if $parsed.hash.keys > 2;
				return Node.new(
					:type( 'escale' ),
					:sign(
						self.sign(
							$parsed.hash.<sign>
						)
					),
					:decint(
						self.decint(
							$parsed.hash.<decint>
						)
					)
				)
			}
			die "Uncaught key"
		}
		die "Uncaught type"
	}

	method binint( Mu $parsed ) {
		self.debug( 'binint', $parsed );

		if $parsed.hash {
			die "hash"
		}
		if $parsed.Int {
			return Node.new(
				:type( 'binint' ),
				:name( $parsed.Int )
			)
		}
		die "Uncaught type"
	}

	method octint( Mu $parsed ) {
		self.debug( 'octint', $parsed );

		if $parsed.hash {
			die "hash"
		}
		if $parsed.Int {
			return Node.new(
				:type( 'octint' ),
				:name( $parsed.Int )
			)
		}
		die "Uncaught type"
	}

	method decint( Mu $parsed ) {
		self.debug( 'decint', $parsed );

		if $parsed.hash {
			die "hash"
		}
		if $parsed.Int {
			return Node.new(
				:type( 'decint' ),
				:name( $parsed.Int )
			)
		}
		die "Uncaught type"
	}

	method hexint( Mu $parsed ) {
		self.debug( 'hexint', $parsed );

		if $parsed.hash {
			die "hash"
		}
		if $parsed.Int {
			return Node.new(
				:type( 'hexint' ),
				:name( $parsed.Int )
			)
		}
		die "Uncaught type"
	}
}
