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

	# $parsed can only be Int, by extension Str, by extension Bool.
	#
	method assert-Int( Str $name, Mu $parsed ) {
		self.debug( $name, $parsed );

		die "hash" if $parsed.hash;
		die "list" if $parsed.list;

		return Node.new(
			:type( $name ),
			:name( $parsed.Int )
		) if $parsed.Int;
		die "Uncaught type"
	}

	# $parsed can only be Str, by extension Bool
	#
	method assert-Str( Str $name, Mu $parsed ) {
		self.debug( $name, $parsed );

		die "hash" if $parsed.hash;
		die "list" if $parsed.list;
		die "Int"  if $parsed.Int;

		return Node.new(
			:type( $name ),
			:name( $parsed.Str )
		) if $parsed.Str;
		die "Uncaught type"
	}

	# $parsed can only be Bool
	#
	method assert-Bool( Str $name, Mu $parsed ) {
		self.debug( $name, $parsed );

		die "hash" if $parsed.hash;
		die "list" if $parsed.list;
		die "Int"  if $parsed.Int;
		die "Str"  if $parsed.Str;

		return Node.new(
			:type( $name ),
			:name( $parsed.Bool )
		) if $parsed.Bool;
		die "Uncaught type"
	}

	sub assert-keys( Mu $parsed, $keys, $defined-keys = [] ) {
		die "Too many keys " ~ $parsed.hash.keys.gist
			if $parsed.hash.keys.elems >
				$keys.elems + $defined-keys.elems;
		for @( $keys ) -> $key {
			return False unless $parsed.hash.{$key}
		}
		for @( $defined-keys ) -> $key {
			return False unless $parsed.hash:defined{$key}
		}
		return True
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
			if assert-keys( $parsed, [< statementlist >] ) {
				return Node.new(
					:type( 'tidy' ),
					:content(
						:statementlist(
							self.statementlist(
								$parsed.hash.<statementlist>
							)
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
			if assert-keys( $parsed, [< statement >] ) {
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
			if assert-keys( $parsed, [], [< statement >] ) {
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
			if assert-keys( $parsed, [< EXPR >] ) {
				return Node.new(
					:type( 'statement' ),
					:content(
						:EXPR(
							self.EXPR(
								$parsed.hash.<EXPR>
							)
						)
					)
				)
			}
			if assert-keys( $parsed, [< sigil desigilname >] ) {
				return Node.new(
					:type( 'statement' ),
					:content(
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
				)
			}
			die "Uncaught key"
		}
		die "Uncaught type"
	}

	method sym( Mu $parsed ) {
		self.assert-Str( 'sym', $parsed )
	}

	method sign( Mu $parsed ) {
		self.assert-Bool( 'sign', $parsed )
	}

	method postfix( Mu $parsed ) {
		self.debug( 'postfix', $parsed );

		if $parsed.hash {
			if assert-keys( $parsed, [< sym O >] ) {
				return Node.new(
					:type( 'postfix' ),
					:content(
						:sym(
							self.sym(
								$parsed.hash.<sym>
							)
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
			if assert-keys( $parsed, [< sym O >] ) {
				return Node.new(
					:type( 'OPER' ),
					:content(
						:sym(
							self.sym(
								$parsed.hash.<sym>
							)
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
			if assert-keys( $parsed, [< identifier morename >] ) {
				my @child;
				for $parsed.hash.<morename> {
					@child.push(
						$_
					)
				}
				return Node.new(
					:type( 'name' ),
					:content(
						:identifier(
							self.identifier(
								$parsed.hash.<identifier>
							)
						),
					),
					:child( @child )
				)
			}
			if assert-keys( $parsed, [< identifier >],
						 [< morename >] ) {
				return Node.new(
					:type( 'name' ),
					:content(
						:identifier(
							self.identifier(
								$parsed.hash.<identifier>
							)
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
			if assert-keys( $parsed, [< name >], [< colonpair >] ) {
				return Node.new(
					:type( 'longname' ),
					:content(
						:name(
							self.name(
								$parsed.hash.<name>
							)
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
			if assert-keys( $parsed, [< sym >] ) {
				return Node.new(
					:type( 'twigil' ),
					:content(
						:sym(
							self.sym(
								$parsed.hash.<sym>
							)
						)
					)
				)
			}
			die "Uncaught key"
		}
		die "Uncaught type"
	}

	method sigil( Mu $parsed ) {
		self.assert-Str( 'sigil', $parsed )
	}

	method desigilname( Mu $parsed ) {
		self.debug( 'desigilname', $parsed );

		if $parsed.hash {
			if assert-keys( $parsed, [< longname >] ) {
				return Node.new(
					:type( 'desigilname' ),
					:content(
						:longname(
							self.longname(
								$parsed.hash.<longname>
							)
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
			if assert-keys( $parsed,
					[< twigil sigil desigilname >] ) {
				return Node.new(
					:type( 'variable' ),
					:content(
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
						)
					)
				)
			}
			elsif assert-keys( $parsed, [< sigil desigilname >] ) {
				return Node.new(
					:type( 'variable' ),
					:content(
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
				)
			}
			elsif assert-keys( $parsed, [< sigil >] ) {
				return Node.new(
					:type( 'variable' ),
					:content(
						:sigil(
							self.sigil(
								$parsed.hash.<sigil>
							)
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
			if assert-keys( $parsed, [< sym routine_def >] ) {
				return Node.new(
					:type( 'routine_declarator' ),
					:content(
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
				)
			}
			die "Uncaught key"
		}
		die "Uncaught type"
	}

	method package_declarator( Mu $parsed ) {
		self.debug( 'package_declarator', $parsed );

		if $parsed.hash {
			if assert-keys( $parsed, [< sym package_def >] ) {
				return Node.new(
					:type( 'package_declarator' ),
					:content(
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
				)
			}
			die "Uncaught key"
		}
		die "Uncaught type"
	}

	method regex_declarator( Mu $parsed ) {
		self.debug( 'regex_declarator', $parsed );

		if $parsed.hash {
			if assert-keys( $parsed, [< sym regex_def >] ) {
				return Node.new(
					:type( 'regex_declarator' ),
					:content(
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
				)
			}
			die "Uncaught key"
		}
		die "Uncaught type"
	}

	method routine_def( Mu $parsed ) {
		self.debug( 'routine_def', $parsed );

		if $parsed.hash {
			if assert-keys( $parsed,
					[< blockoid deflongname >],
					[< trait >] ) {
				return Node.new(
					:type( 'routine_def' ),
					:cotent(
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
				)
			}
			die "Uncaught key"
		}
		die "Uncaught type"
	}

	method package_def( Mu $parsed ) {
		self.debug( 'package_def', $parsed );

		if $parsed.hash {
			if assert-keys( $parsed,
					[< blockoid longname >], [< trait >] ) {
				return Node.new(
					:type( 'package_def' ),
					:content(
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
				)
			}
			if assert-keys( $parsed,
					[< longname statementlist >],
					[< trait >] ) {
				return Node.new(
					:type( 'package_def' ),
					:content(
						:longname(
							self.longname(
								$parsed.hash.<longname>
							)
						),
						:statementlist(
							self.statementlist(
								$parsed.hash.<statementlist>
							)
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
			if assert-keys( $parsed,
					[< deflongname nibble >],
					[< signature trait >] ) {
				return Node.new(
					:type( 'regex_def' ),
					:content(
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
				)
			}
			die "Uncaught key"
		}
		die "Uncaught type"
	}

	method blockoid( Mu $parsed ) {
		self.debug( 'blockoid', $parsed );

		if $parsed.hash {
			if assert-keys( $parsed, [< statementlist >] ) {
				return Node.new(
					:type( 'blockoid' ),
					:content(
						:statementlist(
							self.statementlist(
								$parsed.hash.<statementlist>
							)
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
			if assert-keys( $parsed,
					[< name >],
					[< colonpair >] ) {
				return Node.new(
					:type( 'deflongname' ),
					:content(
						:name(
							self.name(
								$parsed.hash.<name>
							)
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
				if assert-keys( $parsed,
						[< postfix OPER >],
						[< postfix_prefix_meta_operator >] ) {
					return Node.new(
						:type( 'EXPR' ),
						:content(
							:postfix(
								self.postfix(
									$parsed.hash.<postfix>
								)
							),
							:OPER(
								self.OPER(
									$parsed.hash.<OPER>
								)
							)
						),
						:child( @child )
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
			if assert-keys( $parsed, [< longname args >] ) {
				return Node.new(
					:type( 'EXPR' ),
					:content(
						:longname(
							self.longname(
								$parsed.hash.<longname>
							)
						)
					)
				)
			}
			if assert-keys( $parsed, [< value >] ) {
				return Node.new(
					:type( 'EXPR' ),
					:content(
						:value(
							self.value(
								$parsed.hash.<value>
							)
						)
					)
				)
			}
			if assert-keys( $parsed, [< variable >] ) {
				return Node.new(
					:type( 'EXPR' ),
					:content(
						:variable(
							self.variable(
								$parsed.hash.<variable>
							)
						)
					)
				)
			}
			if assert-keys( $parsed, [< longname >] ) {
				return Node.new(
					:type( 'EXPR' ),
					:content(
						:longname(
							self.longname(
								$parsed.hash.<longname>
							)
						)
					)
				)
			}
			if assert-keys( $parsed, [< circumfix >] ) {
				return Node.new(
					:type( 'EXPR' ),
					:content(
						:circumfix(
							self.circumfix(
								$parsed.hash.<circumfix>
							)
						)
					)
				)
			}
			if assert-keys( $parsed, [< colonpair >] ) {
				return Node.new(
					:type( 'EXPR' ),
					:content(
						:colonpair(
							self.colonpair(
								$parsed.hash.<colonpair>
							)
						)
					)
				)
			}
			if assert-keys( $parsed, [< scope_declarator >] ) {
				return Node.new(
					:type( 'EXPR' ),
					:content(
						:scope_declarator(
							self.scope_declarator(
								$parsed.hash.<scope_declarator>
							)
						)
					)
				)
			}
			if assert-keys( $parsed, [< routine_declarator >] ) {
				return Node.new(
					:type( 'EXPR' ),
					:content(
						:routine_declarator(
							self.routine_declarator(
								$parsed.hash.<routine_declarator>
							)
						)
					)
				)
			}
			if assert-keys( $parsed, [< package_declarator >] ) {
				return Node.new(
					:type( 'EXPR' ),
					:content(
						:package_declarator(
							self.package_declarator(
								$parsed.hash.<package_declarator>
							)
						)
					)
				)
			}
			if assert-keys( $parsed, [< regex_declarator >] ) {
				return Node.new(
					:type( 'EXPR' ),
					:content(
						:regex_declarator(
							self.regex_declarator(
								$parsed.hash.<regex_declarator>
							)
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
			if assert-keys( $parsed,
					[< variable post_constraint >],
					[< semilist postcircumfix signature trait >] ) {
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
					:content(
						:variable(
							self.variable(
								$parsed.hash.<variable>
							)
						)
					)
				)
			}
			if assert-keys( $parsed,
					[< variable >],
					[< semilist postcircumfix signature trait post_constraint >] ) {
				return Node.new(
					:type( 'variable_declarator' ),
					:content(
						:variable(
							self.variable(
								$parsed.hash.<variable>
							)
						)
					)
				)
			}
			die "Uncaught key"
		}
		die "Uncaught type"
	}

	method multi_declarator( Mu $parsed ) {
		self.debug( 'multi_declarator', $parsed );

		if $parsed.hash {
			if assert-keys( $parsed, [< declarator >] ) {
				return Node.new(
					:type( 'multi_declarator' ),
					:content(
						:declarator(
							self.declarator(
								$parsed.hash.<declarator>
							)
						)
					)
				)
			}
			die "Uncaught key"
		}
		die "Uncaught type"
	}

	method declarator( Mu $parsed ) {
		self.debug( 'declarator', $parsed );

		if $parsed.hash {
			if assert-keys( $parsed,
					[< variable_declarator >],
					[< trait >] ) {
				return Node.new(
					:type( 'declarator' ),
					:content(
						:variable_declarator(
							self.variable_declarator(
								$parsed.hash.<variable_declarator>
							)
						)
					)
				)
			}
			if assert-keys( $parsed,
					[< regex_declarator >],
					[< trait >] ) {
				return Node.new(
					:type( 'declarator' ),
					:content(
						:regex_declarator(
							self.regex_declarator(
								$parsed.hash.<regex_declarator>
							)
						)
					)
				)
			}
			die "Uncaught key"
		}
		die "Uncaught type"
	}

	method DECL( Mu $parsed ) {
		self.debug( 'DECL', $parsed );

		if $parsed.hash {
			if assert-keys( $parsed,
					[< variable_declarator >],
					[< trait >] ) {
				return Node.new(
					:type( 'DECL' ),
					:content(
						:variable_declarator(
							self.variable_declarator(
								$parsed.hash.<variable_declarator>
							)
						)
					)
				)
			}
			if assert-keys( $parsed,
					[< regex_declarator >],
					[< trait >] ) {
				return Node.new(
					:type( 'DECL' ),
					:content(
						:regex_declarator(
							self.regex_declarator(
								$parsed.hash.<regex_declarator>
							)
						)
					)
				)
			}
			elsif assert-keys( $parsed, [< package_def sym >] ) {
				return Node.new(
					:type( 'DECL' ),
					:content(
						:package_def(
							self.package_def(
								$parsed.hash.<package_def>
							)
						),
						:sym(
							self.sym(
								$parsed.hash.<sym>
							)
						)
					)
				)
			}
			elsif assert-keys( $parsed, [< declarator >] ) {
				return Node.new(
					:type( 'DECL' ),
					:content(
						:declarator(
							self.declarator(
								$parsed.hash.<declarator>
							)
						)
					)
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
			if assert-keys( $parsed, [< longname >] ) {
				return Node.new(
					:type( 'typename' ),
					:content(
						:longname(
							self.longname(
								$parsed.hash.<longname>
							)
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
			if assert-keys( $parsed,
					[< declarator DECL >],
					[< typename >] ) {
				return Node.new(
					:type( 'scoped' ),
					:content(
						:declarator(
							self.declarator(
								$parsed.hash.<declarator>
							)
						),
						:DECL(
							self.DECL(
								$parsed.hash.<DECL>
							)
						)
					)
				)
			}
			if assert-keys( $parsed, [< multi_declarator
						    DECL
						    typename >] ) {
				return Node.new(
					:type( 'scoped' ),
					:content(
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
						)
					)
				)
			}
			if assert-keys( $parsed, [< package_declarator DECL >],
						 [< typename >] ) {
				return Node.new(
					:type( 'scoped' ),
					:content(
						:package_declarator(
							self.package_declarator(
								$parsed.hash.<package_declarator>
							)
						),
						:DECL(
							self.DECL(
								$parsed.hash.<DECL>
							)
						)
					)
				)
			}
			die "Uncaught key"
		}
		die "Uncaught type"
	}

	method scope_declarator( Mu $parsed ) {
		self.debug( 'scope_declarator', $parsed );

		if $parsed.hash {
			if assert-keys( $parsed, [< sym scoped >] ) {
				return Node.new(
					:type( 'scope_declarator' ),
					:content(
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
				)
			}
			die "Uncaught key"
		}
		die "Uncaught type"
	}

	method value( Mu $parsed ) {
		self.debug( 'value', $parsed );

		if $parsed.hash {
			if assert-keys( $parsed, [< number >] ) {
				return Node.new(
					:type( 'value' ),
					:content(
						:number(
							self.number(
								$parsed.hash.<number>
							)
						)
					)
				)
			}
			if assert-keys( $parsed, [< quote >] ) {
				return Node.new(
					:type( 'value' ),
					:content(
						:quote(
							self.quote(
								$parsed.hash.<quote>
							)
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
			if assert-keys( $parsed, [< numish >] ) {
				return Node.new(
					:type( 'number' ),
					:content(
						:numish(
							self.numish(
								$parsed.hash.<numish>
							)
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
			if assert-keys( $parsed, [< nibble >] ) {
				return Node.new(
					:type( 'quote' ),
					:content(
						:nibble(
							self.nibble(
								$parsed.hash.<nibble>
							)
						)
					)
				)
			}
			if assert-keys( $parsed, [< quibble >] ) {
				return Node.new(
					:type( 'quote' ),
					:content(
						:quibble(
							self.quibble(
								$parsed.hash.<quibble>
							)
						)
					)
				)
			}
			die "Uncaught key"
		}
		die "Uncaught type"
	}

	method B( Mu $parsed ) {
		self.assert-Bool( 'B', $parsed )
	}

	method babble( Mu $parsed ) {
		self.debug( 'babble', $parsed );

		if $parsed.hash {
			if assert-keys( $parsed,
					[< B >],
					[< quotepair >] ) {
				return Node.new(
					:type( 'babble' ),
					:content(
						:B(
							self.B(
								$parsed.hash.<B>
							)
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

		if $parsed.hash {
			if assert-keys( $parsed,
					[],
					[< param_sep parameter >] ) {
				return Node.new(
					:type( 'signature' ),
					:name( $parsed.Bool )
				)
			}
			die "Uncaught key"
		}
		die "Uncaught type"
	}

	method fakesignature( Mu $parsed ) {
		self.debug( 'fakesignature', $parsed );

		if $parsed.hash {
			if assert-keys( $parsed, [< signature >] ) {
				return Node.new(
					:type( 'fakesignature' ),
					:content(
						:signature(
							self.signature(
								$parsed.hash.<signature>
							)
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
			if assert-keys( $parsed, [< identifier >] ) {
				return Node.new(
					:type( 'colonpair' ),
					:content(
						:identifier(
							self.identifier(
								$parsed.hash.<identifier>
							)
						)
					)
				)
			}
			if assert-keys( $parsed, [< fakesignature >] ) {
				return Node.new(
					:type( 'colonpair' ),
					:content(
						:fakesignature(
							self.fakesignature(
								$parsed.hash.<fakesignature>
							)
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
			if assert-keys( $parsed, [< identifier >] ) {
				return Node.new(
					:type( 'quotepair' ),
					:content(
						:identifier(
							self.identifier(
								$parsed.hash.<identifier>
							)
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
			if assert-keys( $parsed, [< babble nibble >] ) {
				return Node.new(
					:type( 'quibble' ),
					:content(
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
				)
			}
			die "Uncaught key"
		}
		die "Uncaught type"
	}

	method _0( Mu $parsed ) {
		self.debug( '0', $parsed );

		if $parsed.hash {
			if assert-keys( $parsed, [< 0 >] ) {
				return Node.new(
					:type( 'quibble' ),
					:content(
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
				)
			}
			die "Uncaught key"
		}
		die "Uncaught type"
	}

	method charspec( Mu $parsed ) {
		self.debug( 'charspec', $parsed );

		if $parsed.list {
			my @child;
			for $parsed.list {
				@child.push(
					$_.hash.<0>
				)
			}
			return Node.new(
				:type( 'cclass_elem' ),
				:child( @child )
			)
		}
		die "Uncaught type"
	}

	method cclass_elem( Mu $parsed ) {
		self.debug( 'cclass_elem', $parsed );

		if $parsed.list {
			my @child;
			for $parsed.list {
				@child.push(
					Node.new(
						:type( 'INTERMEDIARY' ),
						:content(
							:sign(
								self.sign(
									$_.hash.<sign>
								)
							),
							:charspec(
								self.charspec(
									$_.hash.<charspec>
								)
							)
						)
					)
				)
			}
			return Node.new(
				:type( 'cclass_elem' ),
				:child( @child )
			)
		}
		die "Uncaught type"
	}

	method assertion( Mu $parsed ) {
		self.debug( 'metachar', $parsed );

		if $parsed.hash {
			if assert-keys( $parsed, [< cclass_elem >] ) {
				return Node.new(
					:type( 'assertion' ),
					:content(
						:cclass_elem(
							self.cclass_elem(
								$parsed.hash.<cclass_elem>
							)
						)
					)
				)
			}
			die "Uncaught key"
		}
		die "Uncaught type"
	}

	method metachar( Mu $parsed ) {
		self.debug( 'metachar', $parsed );

		if $parsed.hash {
			if assert-keys( $parsed, [< assertion >] ) {
				return Node.new(
					:type( 'metachar' ),
					:content(
						:metachar(
							self.assertion(
								$parsed.hash.<assertion>
							)
						)
					)
				)
			}
			die "Uncaught key"
		}
		die "Uncaught type"
	}

	method atom( Mu $parsed ) {
		self.debug( 'noun', $parsed );

		if $parsed.hash {
			if assert-keys( $parsed, [< metachar >] ) {
				return Node.new(
					:type( 'atom' ),
					:content(
						:atom(
							self.metachar(
								$parsed.hash.<metachar>
							)
						)
					)
				)
			}
			die "Uncaught key"
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
			if assert-keys( $parsed, [< atom >] ) {
				return Node.new(
					:type( 'noun' ),
					:content(
						:atom(
							self.atom(
								$parsed.hash.<atom>
							)
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
			if assert-keys( $parsed, [< noun >] ) {
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
			if assert-keys( $parsed, [< termish >] ) {
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
			if assert-keys( $parsed, [< termconj >] ) {
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
			if assert-keys( $parsed, [< termalt >] ) {
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
			if assert-keys( $parsed, [< termconjseq >] ) {
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
			if assert-keys( $parsed, [< termaltseq >] ) {
				return Node.new(
					:type( 'termseq' ),
					:content(
						:termaltseq(
							self.termaltseq(
								$parsed.hash.<termaltseq>
							)
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
			if assert-keys( $parsed, [< termseq >] ) {
				return Node.new(
					:type( 'nibble' ),
					:content(
						:termseq(
							self.termseq(
								$parsed.hash.<termseq>
							)
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
			if assert-keys( $parsed, [< int coeff frac >] ) {
				return Node.new(
					:type( 'dec_number' ),
					:content(
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
						)
					)
				)
			}
			if assert-keys( $parsed, [< int coeff escale >] ) {
				return Node.new(
					:type( 'dec_number' ),
					:content(
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
						)
					)
				)
			}
			die "Uncaught key"
		}
		die "Uncaught type"
	}

	method numish( Mu $parsed ) {
		self.debug( 'numish', $parsed );

		if $parsed.hash {
			if assert-keys( $parsed, [< integer >] ) {
				return Node.new(
					:type( 'numish' ),
					:content(
						:integer(
							self.integer(
								$parsed.hash.<integer>
							)
						)
					)
				)
			}
			if assert-keys( $parsed, [< rad_number >] ) {
				return Node.new(
					:type( 'numish' ),
					:content(
						:rad_number(
							self.rad_number(
								$parsed.hash.<rad_number>
							)
						)
					)
				)
			}
			if assert-keys( $parsed, [< dec_number >] ) {
				return Node.new(
					:type( 'numish' ),
					:content(
						:dec_number(
							self.dec_number(
								$parsed.hash.<dec_number>
							)
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
			if assert-keys( $parsed, [< decint VALUE >] ) {
				return Node.new(
					:type( 'integer' ),
					:content(
						:decint(
							self.decint(
								$parsed.hash.<decint>
							)
						)
					)
				)
			}
			if assert-keys( $parsed, [< binint VALUE >] ) {
				return Node.new(
					:type( 'integer' ),
					:content(
						:binint(
							self.binint(
								$parsed.hash.<binint>
							)
						)
					)
				)
			}
			if assert-keys( $parsed, [< octint VALUE >] ) {
				return Node.new(
					:type( 'integer' ),
					:content(
						:octint(
							self.octint(
								$parsed.hash.<octint>
							)
						)
					)
				)
			}
			if assert-keys( $parsed, [< hexint VALUE >] ) {
				return Node.new(
					:type( 'integer' ),
					:content(
						:hexint(
							self.hexint(
								$parsed.hash.<hexint>
							)
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
			if assert-keys( $parsed, [< semilist >] ) {
				return Node.new(
					:type( 'circumfix' ),
					:content(
						:semilist(
							self.semilist(
								$parsed.hash.<semilist>
							)
						)
					)
				)
			}
			if assert-keys( $parsed, [< binint VALUE >] ) {
				return Node.new(
					:type( 'circumfix' ),
					:content(
						:binint(
							self.binint(
								$parsed.hash.<binint>
							)
						)
					)
				)
			}
			if assert-keys( $parsed, [< octint VALUE >] ) {
				return Node.new(
					:type( 'circumfix' ),
					:content(
						:octint(
							self.octint(
								$parsed.hash.<octint>
							)
						)
					)
				)
			}
			if assert-keys( $parsed, [< hexint VALUE >] ) {
				return Node.new(
					:type( 'circumfix' ),
					:content(
						:hexint(
							self.hexint(
								$parsed.hash.<hexint>
							)
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
			if assert-keys( $parsed, [< statement >] ) {
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
			if assert-keys( $parsed,
					[< circumfix radix >],
					[< exp base >] ) {
				return Node.new(
					:type( 'rad_number' ),
					:content(
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
				)
			}
			die "Uncaught key"
		}
		die "Uncaught type"
	}

	method int( Mu $parsed ) {
		self.assert-Int( 'int', $parsed )
	}

	method radix( Mu $parsed ) {
		self.assert-Int( 'radix', $parsed )
	}

	method frac( Mu $parsed ) {
		self.assert-Int( 'frac', $parsed )
	}

	method coeff( Mu $parsed ) {
		self.assert-Int( 'coeff', $parsed )
	}

	method escale( Mu $parsed ) {
		self.debug( 'escale', $parsed );

		if $parsed.hash {
			if assert-keys( $parsed, [< sign decint >] ) {
				return Node.new(
					:type( 'escale' ),
					:content(
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
				)
			}
			die "Uncaught key"
		}
		die "Uncaught type"
	}

	method binint( Mu $parsed ) {
		self.assert-Int( 'binint', $parsed )
	}

	method octint( Mu $parsed ) {
		self.assert-Int( 'octint', $parsed )
	}

	method decint( Mu $parsed ) {
		self.assert-Int( 'decint', $parsed )
	}

	method hexint( Mu $parsed ) {
		self.assert-Int( 'hexint', $parsed )
	}
}
