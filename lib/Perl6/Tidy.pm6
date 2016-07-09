class Perl6::Tidy {
	use nqp;

	has $.debugging = False;

	role Node {
		has $.name;
		has $.child;
	}

	method debug( Str $name, Mu $parsed ) {
		my @types;

		return unless $.debugging;

		if $parsed.list {
			@types.push( 'list' )
		}
		if $parsed.hash {
			@types.push( 'hash' )
		}
		@types.push( 'Int'  ) if $parsed.Int;
		@types.push( 'Str'  ) if $parsed.Str;
		@types.push( 'Bool' ) if $parsed.Bool;

		die "$name: Unknown type" unless @types;

		say "$name ({@types})";

		say "\+$name: "    ~   $parsed.Int       if $parsed.Int;
		say "\~$name: '"   ~   $parsed.Str ~ "'" if $parsed.Str;
		say "\?$name: "    ~ ~?$parsed.Bool      if $parsed.Bool;
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

		say "";
	}

	# $parsed can only be Int, by extension Str, by extension Bool.
	#
	sub assert-Int( Mu $parsed ) {
		die "hash" if $parsed.hash;
		die "list" if $parsed.list;

		if $parsed.Int {
			return True
		}
		die "Uncaught type"
	}

	# $parsed can only be Str, by extension Bool
	#
	sub assert-Str( Mu $parsed ) {
		die "hash" if $parsed.hash;
		die "list" if $parsed.list;
		die "Int"  if $parsed.Int;

		if $parsed.Str {
			return True
		}
		die "Uncaught type"
	}

	# $parsed can only be Bool
	#
	sub assert-Bool( Mu $parsed ) {
		die "hash" if $parsed.hash;
		die "list" if $parsed.list;
		die "Int"  if $parsed.Int;
		die "Str"  if $parsed.Str;

		if $parsed.Bool {
			return True
		}
		die "Uncaught type"
	}

	sub assert-hash-keys( Mu $parsed, $keys, $defined-keys = [] ) {
		if $parsed.hash {
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
		return False
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

		self.root( $parsed )
	}

	class Root does Node { }

	method root( Mu $parsed ) {
		if assert-hash-keys( $parsed, [< statementlist >] ) {
			return Root.new(
				:content(
					:statementlist(
						self.statementlist(
							$parsed.hash.<statementlist>
						)
					)
				)
			);
		}
		self.debug( 'root', $parsed );
		die "Uncaught type"
	}

	class StatementList does Node { }

	method statementlist( Mu $parsed ) {
		if assert-hash-keys( $parsed, [< statement >] ) {
			return StatementList.new(
				:content(
					:statement(
						self.statement(
							$parsed.hash.<statement>
						)
					)
				)
			);
		}
		if assert-hash-keys( $parsed, [], [< statement >] ) {
			return StatementList.new
		}
		self.debug( 'statementlist', $parsed );
		die "Uncaught type"
	}

	class Statement does Node { }

	method statement( Mu $parsed ) {
		if $parsed.list {
			my @child;
			for $parsed.list {
				if assert-hash-keys( $_, 'EXPR' ) {
					@child.push(
						self.EXPR(
							$_.hash.<EXPR>
						)
					);
					next
				}
				if assert-hash-keys( $_, [< statement_control >] ) {
					return Statement.new(
						:content(
							:statement_control(
								self.statement_control(
									$_.hash.<statement_control>
								)
							)
						)
					)
				}
				self.debug( 'statement', $_ );
				die "Uncaught key"
			}
			return Statement.new(
				:child( @child )
			)
		}
		if assert-hash-keys( $parsed, [< EXPR >] ) {
			return Statement.new(
				:content(
					:EXPR(
						self.EXPR(
							$parsed.hash.<EXPR>
						)
					)
				)
			)
		}
		if assert-hash-keys( $parsed, [< sigil desigilname >] ) {
			return Statement.new(
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
		self.debug( 'statement', $parsed );
		die "Uncaught type"
	}

	class Sym does Node { }

	method sym( Mu $parsed ) {
		if assert-Str( $parsed ) {
			return Sym.new( :name( $parsed.Str ) )
		}
		self.debug( 'sym', $parsed );
		die "Uncaught type"
	}

	class Sign does Node { }

	method sign( Mu $parsed ) {
		if assert-Bool( $parsed ) {
			return Sign.new( :name( $parsed.Bool ) )
		}
		self.debug( 'sign', $parsed );
		die "Uncaught type"
	}

	class O does Node { }

	method O( Hash $hash ) {
		if $hash.<prec> and
		   $hash.<fiddly> and
		   $hash.<dba> and
		   $hash.<assoc> {
			return O.new(
				:content(
				)
			)
		}
say $hash.perl;
		die "Uncaught type"
	}

	class Postfix does Node { }

	method postfix( Mu $parsed ) {
		if assert-hash-keys( $parsed, [< sym O >] ) {
			return Postfix.new(
				:content(
					:sym(
						self.sym(
							$parsed.hash.<sym>
						)
					),
					:O(
						self.O(
							$parsed.hash.<O>
						)
					)
				)
			)
		}
		self.debug( 'postfix', $parsed );
		die "Uncaught type"
	}

	class MethodOp does Node { }

	method methodop( Mu $parsed ) {
		if assert-hash-keys( $parsed, [< longname args >] ) {
			return MethodOp.new(
				:content(
					:longname(
						self.longname(
							$parsed.hash.<longname>
						)
					),
					:args(
						self.args(
							$parsed.hash.<args>
						)
					)
				)
			)
		}
		self.debug( 'methodop', $parsed );
		die "Uncaught type"
	}

	class DottyOp does Node { }

	method dottyop( Mu $parsed ) {
		if assert-hash-keys( $parsed, [< methodop >] ) {
			return DottyOp.new(
				:content(
					:methodop(
						self.methodop(
							$parsed.hash.<methodop>
						)
					)
				)
			)
		}
		self.debug( 'dottyop', $parsed );
		die "Uncaught type"
	}

	class OPER does Node { }

	method OPER( Mu $parsed ) {
		if assert-hash-keys( $parsed, [< sym dottyop O >] ) {
			return OPER.new(
				:content(
					:sym(
						self.sym(
							$parsed.hash.<sym>
						)
					),
					:dottyop(
						self.dottyop(
							$parsed.hash.<dottyop>
						)
					),
					:O(
						self.O(
							$parsed.hash.<O>
						)
					)
				)
			)
		}
		if assert-hash-keys( $parsed, [< sym O >] ) {
			return OPER.new(
				:content(
					:sym(
						self.sym(
							$parsed.hash.<sym>
						)
					),
					:O(
						self.O(
							$parsed.hash.<O>
						)
					)
				)
			)
		}
		self.debug( 'OPER', $parsed );
		die "Uncaught type"
	}

	class MoreName does Node { }

	method morename( Mu $parsed ) {
		if assert-hash-keys( $parsed, [< identifier >] ) {
			return MoreName.new(
				:content(
					:identifier(
						self.identifier(
							$parsed.hash.<identifier>
						)
					),
				),
			)
		}
		if assert-hash-keys( $parsed, [< EXPR >] ) {
			return MoreName.new(
				:content(
					:EXPR(
						self.EXPR(
							$parsed.hash.<EXPR>
						)
					),
				),
			)
		}
		self.debug( 'morename', $parsed );
		die "Uncaught type"
	}

	class Name does Node { }

	method name( Mu $parsed ) {
		if assert-hash-keys( $parsed, [< identifier morename >] ) {
			my @child;
			for $parsed.hash.<morename> {
				@child.push(
					self.morename(
						$_
					)
				)
			}
			return Name.new(
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
		if assert-hash-keys( $parsed, [< identifier >],
					      [< morename >] ) {
			return Name.new(
				:content(
					:identifier(
						self.identifier(
							$parsed.hash.<identifier>
						)
					),
				),
				:child()
			)
		}
		self.debug( 'name', $parsed );
		die "Uncaught type"
	}

	class Longname does Node { }

	method longname( Mu $parsed ) {
		if assert-hash-keys( $parsed, [< name >], [< colonpair >] ) {
			return Longname.new(
				:content(
					:name(
						self.name(
							$parsed.hash.<name>
						)
					),
					:colonpair()
				)
			)
		}
		self.debug( 'longname', $parsed );
		die "Uncaught type"
	}

	class Twigil does Node { }

	method twigil( Mu $parsed ) {
		if assert-hash-keys( $parsed, [< sym >] ) {
			return Twigil.new(
				:content(
					:sym(
						self.sym(
							$parsed.hash.<sym>
						)
					)
				)
			)
		}
		self.debug( 'twigil', $parsed );
		die "Uncaught type"
	}

	class Sigil does Node { }

	method sigil( Mu $parsed ) {
		if assert-Str( $parsed ) {
			return Sigil.new( :name( $parsed.Str ) )
		}
		self.debug( 'sigil', $parsed );
		die "Uncaught type"
	}

	class DeSigilName does Node { }

	method desigilname( Mu $parsed ) {
		if assert-hash-keys( $parsed, [< longname >] ) {
			return DeSigilName.new(
				:content(
					:longname(
						self.longname(
							$parsed.hash.<longname>
						)
					)
				)
			)
		}
		if $parsed.Str {
			return DeSigilName.new( :name( $parsed.Str ) )
		}
		self.debug( 'desigilname', $parsed );
		die "Uncaught type"
	}

	class Variable does Node { }

	method variable( Mu $parsed ) {
		if assert-hash-keys( $parsed, [< twigil sigil desigilname >] ) {
			return Variable.new(
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
		elsif assert-hash-keys( $parsed, [< sigil desigilname >] ) {
			return Variable.new(
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
		elsif assert-hash-keys( $parsed, [< sigil >] ) {
			return Variable.new(
				:content(
					:sigil(
						self.sigil(
							$parsed.hash.<sigil>
						)
					)
				)
			)
		}
		self.debug( 'variable', $parsed );
		die "Uncaught type"
	}

	class RoutineDeclarator does Node { }

	method routine_declarator( Mu $parsed ) {
		if assert-hash-keys( $parsed, [< sym routine_def >] ) {
			return RoutineDeclarator.new(
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
		self.debug( 'routine_declarator', $parsed );
		die "Uncaught type"
	}

	class PackageDeclarator does Node { }

	method package_declarator( Mu $parsed ) {
		if assert-hash-keys( $parsed, [< sym package_def >] ) {
			return PackageDeclarator.new(
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
		self.debug( 'package_declarator', $parsed );
		die "Uncaught type"
	}

	class RegexDeclarator does Node { }

	method regex_declarator( Mu $parsed ) {
		if assert-hash-keys( $parsed, [< sym regex_def >] ) {
			return RegexDeclarator.new(
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
		self.debug( 'regex_declarator', $parsed );
		die "Uncaught type"
	}

	class RoutineDef does Node { }

	method routine_def( Mu $parsed ) {
		if assert-hash-keys( $parsed, [< blockoid deflongname >],
					      [< trait >] ) {
			return RoutineDef.new(
				:content(
					:blockoid(
						self.blockoid(
							$parsed.hash.<blockoid>
						)
					),
					:deflongname(
						self.deflongname(
							$parsed.hash.<deflongname>
						)
					),
					:trait()
				)
			)
		}
		self.debug( 'routine_def', $parsed );
		die "Uncaught type"
	}

	class PackageDef does Node { }

	method package_def( Mu $parsed ) {
		if assert-hash-keys( $parsed, [< blockoid longname >],
					      [< trait >] ) {
			return PackageDef.new(
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
					),
					:trait()
				)
			)
		}
		if assert-hash-keys( $parsed, [< longname statementlist >],
					      [< trait >] ) {
			return PackageDef.new(
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
					),
					:trait()
				)
			)
		}
		self.debug( 'package_def', $parsed );
		die "Uncaught type"
	}

	class RegexDef does Node { }

	method regex_def( Mu $parsed ) {
		if assert-hash-keys( $parsed, [< deflongname nibble >],
					      [< signature trait >] ) {
			return RegexDef.new(
				:content(
					:deflongname(
						self.deflongname(
							$parsed.hash.<deflongname>
						)
					),
					:nibble(
						self.nibble(
							$parsed.hash.<nibble>
						)
					),
					:signature(),
					:trait()
				)
			)
		}
		self.debug( 'regex_def', $parsed );
		die "Uncaught type"
	}

	class Blockoid does Node { }

	method blockoid( Mu $parsed ) {
		if assert-hash-keys( $parsed, [< statementlist >] ) {
			return Blockoid.new(
				:content(
					:statementlist(
						self.statementlist(
							$parsed.hash.<statementlist>
						)
					)
				)
			)
		}
		self.debug( 'blockoid', $parsed );
		die "Uncaught type"
	}

	class DefLongName does Node { }

	method deflongname( Mu $parsed ) {
		if assert-hash-keys( $parsed, [< name >], [< colonpair >] ) {
			return DefLongName.new(
				:content(
					:name(
						self.name(
							$parsed.hash.<name>
						)
					),
					:colonpair()
				)
			)
		}
		self.debug( 'deflongname', $parsed );
		die "Uncaught type"
	}

	class Args does Node { }

	method args( Mu $parsed ) {
		if $parsed.Bool {
			return Args.new( :name( $parsed.Bool ) )
		}
		self.debug( 'args', $parsed );
		die "Uncaught type"
	}

	class Dotty does Node { }

	method dotty( Mu $parsed ) {
		if assert-hash-keys( $parsed, [< sym dottyop O >] ) {
			return Dotty.new(
				:content(
					:sym(
						self.sym(
							$parsed.hash.<sym>
						)
					),
					:dottyop(
						self.dottyop(
							$parsed.hash.<dottyop>
						)
					),
					:O(
						self.O(
							$parsed.hash.<O>
						)
					)
				)
			)
		}
		self.debug( 'dotty', $parsed );
		die "Uncaught type"
	}

	class EXPR does Node { }

	method EXPR( Mu $parsed ) {
		if $parsed.list {
			my @child;
			for $parsed.list {
				if assert-hash-keys( $_, [< longname >] ) {
					@child.push(
						self.longname(
							$_.hash.<longname>
						)
					);
					next;
				}
				if assert-hash-keys( $_, [< value >] ) {
					@child.push(
						self.value(
							$_.hash.<value>
						)
					);
					next;
				}
				self.debug( 'EXPR', $_ );
				die "Uncaught key"
			}
			if $parsed.hash {
				if assert-hash-keys(
					$parsed,
					[< OPER dotty >],
					[< postfix_prefix_meta_operator >] ) {
					return EXPR.new(
						:content(
							:OPER(
								self.OPER(
									$parsed.hash.<OPER>
								)
							),
							:dotty(
								self.dotty(
									$parsed.hash.<dotty>
								)
							)
						),
						:postfix_prefix_meta_operator(),
						:child( @child )
					)
				}
				if assert-hash-keys(
					$parsed,
					[< postfix OPER >],
					[< postfix_prefix_meta_operator >] ) {
					return EXPR.new(
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
							),
							:postfix_prefix_meta_operator()
						),
						:child( @child )
					)
				}
				if assert-hash-keys( $parsed, [< longname >] ) {
					return EXPR.new(
						:content(
							:longname(
								self.longname(
									$parsed.hash.<longname>
								)
							),
						),
						:child( @child )
					)
				}
				self.debug( 'EXPR', $parsed );
				die "Uncaught key"
			}
			else {
				return EXPR.new(
					:child( @child )
				)
			}
		}
		if assert-hash-keys( $parsed, [< longname args >] ) {
			return EXPR.new(
				:child( 
					self.longname(
						$parsed.hash.<longname>
					)
				),
				:content(
					:args(
						self.args(
							$parsed.hash.<args>
						)
					)
				)
			)
		}
		if assert-hash-keys( $parsed, [< longname >] ) {
			return EXPR.new(
				:child( 
					self.longname(
						$parsed.hash.<longname>
					)
				)
			)
		}
		if assert-hash-keys( $parsed, [< value >] ) {
			return EXPR.new(
				:content(
					:value(
						self.value(
							$parsed.hash.<value>
						)
					)
				)
			)
		}
		if assert-hash-keys( $parsed, [< variable >] ) {
			return EXPR.new(
				:content(
					:variable(
						self.variable(
							$parsed.hash.<variable>
						)
					)
				)
			)
		}
		if assert-hash-keys( $parsed, [< circumfix >] ) {
			return EXPR.new(
				:content(
					:circumfix(
						self.circumfix(
							$parsed.hash.<circumfix>
						)
					)
				)
			)
		}
		if assert-hash-keys( $parsed, [< colonpair >] ) {
			return EXPR.new(
				:content(
					:colonpair(
						self.colonpair(
							$parsed.hash.<colonpair>
						)
					)
				)
			)
		}
		if assert-hash-keys( $parsed, [< scope_declarator >] ) {
			return EXPR.new(
				:content(
					:scope_declarator(
						self.scope_declarator(
							$parsed.hash.<scope_declarator>
						)
					)
				)
			)
		}
		if assert-hash-keys( $parsed, [< routine_declarator >] ) {
			return EXPR.new(
				:content(
					:routine_declarator(
						self.routine_declarator(
							$parsed.hash.<routine_declarator>
						)
					)
				)
			)
		}
		if assert-hash-keys( $parsed, [< package_declarator >] ) {
			return EXPR.new(
				:content(
					:package_declarator(
						self.package_declarator(
							$parsed.hash.<package_declarator>
						)
					)
				)
			)
		}
		if assert-hash-keys( $parsed, [< regex_declarator >] ) {
			return EXPR.new(
				:content(
					:regex_declarator(
						self.regex_declarator(
							$parsed.hash.<regex_declarator>
						)
					)
				)
			)
		}
		self.debug( 'EXPR', $parsed );
		die "Uncaught type"
	}

	class VariableDeclarator does Node { }

	method variable_declarator( Mu $parsed ) {
		if assert-hash-keys(
			$parsed,
			[< variable post_constraint >],
			[< semilist postcircumfix signature trait >] ) {
			my @child;
			for $parsed.hash.<post_constraint> {
				if assert-hash-keys( $_, [< EXPR >] ) {
					@child.push(
						self.EXPR(
							$_.hash.<EXPR>
						)
					);
					next;
				}
				self.debug( 'variable_declarator', $_ );
				die "Unknown key"
			}
			return VariableDeclarator.new(
				:child( @child )
				:content(
					:variable(
						self.variable(
							$parsed.hash.<variable>
						)
					),
					:semilist(),
					:postcircumfix(),
					:signature(),
					:trait()
				)
			)
		}
		if assert-hash-keys(
			$parsed,
			[< variable >],
			[< semilist postcircumfix signature trait post_constraint >] ) {
			return VariableDeclarator.new(
				:child(), # post_constraint
				:content(
					:variable(
						self.variable(
							$parsed.hash.<variable>
						)
					),
					:semilist(),
					:postcircumfix(),
					:signature(),
					:trait()
				)
			)
		}
		self.debug( 'variable_declarator', $parsed );
		die "Uncaught type"
	}

	class Doc does Node { }

	method doc( Mu $parsed ) {
		if assert-Bool( $parsed ) {
			return Doc.new( :name( $parsed.Bool ) )
		}
		self.debug( 'doc', $parsed );
		die "Uncaught type"
	}

	class ModuleName does Node { }

	method module_name( Mu $parsed ) {
		if assert-hash-keys( $parsed, [< longname >] ) {
			return ModuleName.new(
				:content(
					:longname(
						self.longname(
							$parsed.hash.<longname>
						)
					)
				)
			)
		}
		self.debug( 'module_name', $parsed );
		die "Uncaught type"
	}

	class Version does Node { }

	method version( Mu $parsed ) {
		if assert-hash-keys( $parsed, [< vnum vstr >] ) {
			return Version.new(
				:content(
					:vnum(
						self.vnum(
							$parsed.hash.<vnum>
						)
					),
					:vstr(
						self.vstr(
							$parsed.hash.<vstr>
						)
					)
				)
			)
		}
		self.debug( 'version', $parsed );
		die "Uncaught type"
	}

	class VNum does Node { }

	method vnum( Mu $parsed ) {
		if $parsed.list {
			return VNum.new( :child() )
		}
		self.debug( 'vnum', $parsed );
		die "Uncaught type"
	}

	class VStr does Node { }

	method vstr( Mu $parsed ) {
		if $parsed.Int {
			return VStr.new( :name( $parsed.Int ) )
		}
		self.debug( 'vstr', $parsed );
		die "Uncaught type"
	}

	class StatementControl does Node { }

	method statement_control( Mu $parsed ) {
		if assert-hash-keys( $parsed, [< doc sym module_name >] ) {
			return StatementControl.new(
				:content(
					:doc(
						self.doc(
							$parsed.hash.<doc>
						)
					),
					:sym(
						self.sym(
							$parsed.hash.<sym>
						)
					),
					:module_name(
						self.module_name(
							$parsed.hash.<module_name>
						)
					)
				)
			)
		}
		if assert-hash-keys( $parsed, [< doc sym version >] ) {
			return StatementControl.new(
				:content(
					:doc(
						self.doc(
							$parsed.hash.<doc>
						)
					),
					:sym(
						self.sym(
							$parsed.hash.<sym>
						)
					),
					:version(
						self.version(
							$parsed.hash.<version>
						)
					)
				)
			)
		}
		self.debug( 'statement_control', $parsed );
		die "Uncaught type"
	}

	class MultiDeclarator does Node { }

	method multi_declarator( Mu $parsed ) {
		if assert-hash-keys( $parsed, [< declarator >] ) {
			return MultiDeclarator.new(
				:content(
					:declarator(
						self.declarator(
							$parsed.hash.<declarator>
						)
					)
				)
			)
		}
		self.debug( 'multi_declarator', $parsed );
		die "Uncaught type"
	}

	class Initializer does Node { }

	method initializer( Mu $parsed ) {
		if assert-hash-keys( $parsed, [< sym EXPR >] ) {
			return Initializer.new(
				:content(
					:sym(
						self.sym(
							$parsed.hash.<sym>
						)
					),
					:EXPR(
						self.EXPR(
							$parsed.hash.<EXPR>
						)
					)
				)
			)
		}
		self.debug( 'initializer', $parsed );
		die "Uncaught type"
	}

	class Declarator does Node { }

	method declarator( Mu $parsed ) {
		if assert-hash-keys( $parsed, [< initializer
						 variable_declarator >],
					      [< trait >] ) {
			return Declarator.new(
				:content(
					:initializer(
						self.initializer(
							$parsed.hash.<initializer>
						)
					),
					:variable_declarator(
						self.variable_declarator(
							$parsed.hash.<variable_declarator>
						)
					),
					:trait()
				)
			)
		}
		if assert-hash-keys( $parsed, [< variable_declarator >],
					      [< trait >] ) {
			return Declarator.new(
				:content(
					:variable_declarator(
						self.variable_declarator(
							$parsed.hash.<variable_declarator>
						)
					),
					:trait()
				)
			)
		}
		if assert-hash-keys( $parsed, [< regex_declarator >],
					      [< trait >] ) {
			return Declarator.new(
				:content(
					:regex_declarator(
						self.regex_declarator(
							$parsed.hash.<regex_declarator>
						)
					),
					:trait()
				)
			)
		}
		self.debug( 'declarator', $parsed );
		die "Uncaught type"
	}

	class DECL does Node { }

	method DECL( Mu $parsed ) {
		if assert-hash-keys( $parsed, [< initializer
						 variable_declarator >],
					      [< trait >] ) {
			return Declarator.new(
				:content(
					:initializer(
						self.initializer(
							$parsed.hash.<initializer>
						)
					),
					:variable_declarator(
						self.variable_declarator(
							$parsed.hash.<variable_declarator>
						)
					),
					:trait()
				)
			)
		}
		if assert-hash-keys( $parsed, [< variable_declarator >],
					      [< trait >] ) {
			return DECL.new(
				:content(
					:variable_declarator(
						self.variable_declarator(
							$parsed.hash.<variable_declarator>
						)
					),
					:trait()
				)
			)
		}
		if assert-hash-keys( $parsed, [< regex_declarator >],
					      [< trait >] ) {
			return DECL.new(
				:content(
					:regex_declarator(
						self.regex_declarator(
							$parsed.hash.<regex_declarator>
						)
					),
					:trait()
				)
			)
		}
		elsif assert-hash-keys( $parsed, [< package_def sym >] ) {
			return DECL.new(
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
		elsif assert-hash-keys( $parsed, [< declarator >] ) {
			return DECL.new(
				:content(
					:declarator(
						self.declarator(
							$parsed.hash.<declarator>
						)
					)
				)
			)
		}
		self.debug( 'DECL', $parsed );
		die "Uncaught type"
	}

	class TypeName does Node { }

	class TypeName_INTERMEDIARY does Node { }

	method typename( Mu $parsed ) {
		if $parsed.list {
			my @child;
			for $parsed.list {
				if assert-hash-keys( $_, [< longname >],
							 [< colonpair >] ) {
					@child.push(
						TypeName_INTERMEDIARY.new(
							:content(
								:longname(
									self.longname(
										$_.hash.<longname>
									)
								),
								:colonpair()
							)
						)
					);
					next;
				}
				self.debug( 'typename', $_ );
				die "Uncaught type"
			}
			return TypeName.new(
				:child( @child )
			)
		}
		if assert-hash-keys( $parsed, [< longname >] ) {
			return TypeName.new(
				:content(
					:longname(
						self.longname(
							$parsed.hash.<longname>
						)
					)
				)
			)
		}
		self.debug( 'typename', $parsed );
		die "Uncaught type"
	}

	class Scoped is Node { }

	method scoped( Mu $parsed ) {
		if assert-hash-keys( $parsed, [< declarator DECL >],
					      [< typename >] ) {
			return Scoped.new(
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
					),
					:typename()
				)
			)
		}
		if assert-hash-keys( $parsed,
					[< multi_declarator DECL typename >] ) {
			return Scoped.new(
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
		if assert-hash-keys( $parsed, [< package_declarator DECL >],
 					      [< typename >] ) {
			return Scoped.new(
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
					),
					:typename()
				)
			)
		}
		self.debug( 'scoped', $parsed );
		die "Uncaught type"
	}

	class ScopeDeclarator does Node { }

	method scope_declarator( Mu $parsed ) {
		if assert-hash-keys( $parsed, [< sym scoped >] ) {
			return ScopeDeclarator.new(
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
		self.debug( 'scope_declarator', $parsed );
		die "Uncaught type"
	}

	class Value does Node { }

	method value( Mu $parsed ) {
		if assert-hash-keys( $parsed, [< number >] ) {
			return Value.new(
				:content(
					:number(
						self.number(
							$parsed.hash.<number>
						)
					)
				)
			)
		}
		if assert-hash-keys( $parsed, [< quote >] ) {
			return Value.new(
				:content(
					:quote(
						self.quote(
							$parsed.hash.<quote>
						)
					)
				)
			)
		}
		self.debug( 'value', $parsed );
		die "Uncaught type"
	}

	class Number does Node { }

	method number( Mu $parsed ) {
		if assert-hash-keys( $parsed, [< numish >] ) {
			return Number.new(
				:content(
					:numish(
						self.numish(
							$parsed.hash.<numish>
						)
					)
				)
			)
		}
		self.debug( 'number', $parsed );
		die "Uncaught type"
	}

	class Quote does Node { }

	method quote( Mu $parsed ) {
		if assert-hash-keys( $parsed, [< nibble >] ) {
			return Quote.new(
				:content(
					:nibble(
						self.nibble(
							$parsed.hash.<nibble>
						)
					)
				)
			)
		}
		if assert-hash-keys( $parsed, [< quibble >] ) {
			return Quote.new(
				:content(
					:quibble(
						self.quibble(
							$parsed.hash.<quibble>
						)
					)
				)
			)
		}
		self.debug( 'quote', $parsed );
		die "Uncaught type"
	}

	class B does Node { }

	method B( Mu $parsed ) {
		if assert-Bool( $parsed ) {
			return B.new( :name( $parsed.Bool ) )
		}
		self.debug( 'B', $parsed );
		die "Uncaught type"
	}

	class Babble does Node { }

	method babble( Mu $parsed ) {
		if assert-hash-keys( $parsed, [< B >], [< quotepair >] ) {
			return Babble.new(
				:content(
					:B(
						self.B(
							$parsed.hash.<B>
						)
					),
					:quotepair()
				)
			)
		}
		self.debug( 'babble', $parsed );
		die "Uncaught type"
	}

	class Signature does Node { }

	method signature( Mu $parsed ) {
		if assert-hash-keys( $parsed, [], [< param_sep parameter >] ) {
			return Signature.new(
				:name(
					$parsed.Bool
				),
				:param_sep(),
				:parameter()
			)
		}
		self.debug( 'signature', $parsed );
		die "Uncaught type"
	}

	class FakeSignature does Node { }

	method fakesignature( Mu $parsed ) {
		if assert-hash-keys( $parsed, [< signature >] ) {
			return FakeSignature.new(
				:content(
					:signature(
						self.signature(
							$parsed.hash.<signature>
						)
					)
				)
			)
		}
		self.debug( 'fakesignature', $parsed );
		die "Uncaught type"
	}

	class ColonPair does Node { }

	method colonpair( Mu $parsed ) {
		if assert-hash-keys( $parsed, [< identifier >] ) {
			return ColonPair.new(
				:content(
					:identifier(
						self.identifier(
							$parsed.hash.<identifier>
						)
					)
				)
			)
		}
		if assert-hash-keys( $parsed, [< fakesignature >] ) {
			return ColonPair.new(
				:content(
					:fakesignature(
						self.fakesignature(
							$parsed.hash.<fakesignature>
						)
					)
				)
			)
		}
		self.debug( 'colonpair', $parsed );
		die "Uncaught type"
	}

	class Identifier does Node { }

	method identifier( Mu $parsed ) {
		if $parsed.list {
			my @child;
			for $parsed.list {
				if assert-Str( $_ ) {
					@child.push(
						$_.Str
					);
					next
				}
				self.debug( 'identifier', $_ );
				die "Uncaught type"
			}
			return Identifier.new(
				:child( @child )
			)
		}
		elsif $parsed.Str {
			return Identifier.new( :name( $parsed.Str ) )
		}
		self.debug( 'identifier', $parsed );
		die "Uncaught type"
	}

	class QuotePair does Node { }

	method quotepair( Mu $parsed ) {
		if assert-hash-keys( $parsed, [< identifier >] ) {
			return QuotePair.new(
				:content(
					:identifier(
						self.identifier(
							$parsed.hash.<identifier>
						)
					)
				)
			)
		}
		self.debug( 'quotepair', $parsed );
		die "Uncaught type"
	}

	class Quibble does Node { }

	method quibble( Mu $parsed ) {
		if assert-hash-keys( $parsed, [< babble nibble >] ) {
			return Quibble.new(
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
		self.debug( 'quibble', $parsed );
		die "Uncaught type"
	}

	class _0 does Node { }

	method _0( Mu $parsed ) {
		if assert-hash-keys( $parsed, [< 0 >] ) {
			return _0.new(
				:content(
					:_0(
						self._0(
							$parsed.hash.<0>
						)
					)
				)
			)
		}
		self.debug( '_0', $parsed );
		die "Uncaught type"
	}

	class CharSpec does Node { }

	method charspec( Mu $parsed ) {
		if $parsed.list {
			my @child;
			for $parsed.list {
#				self.debug( 'charspec', $_ );
#				die "Uncaught type"
			}
			return CharSpec.new(
				:child( @child )
			)
		}
		self.debug( 'charspec', $parsed );
		die "Uncaught type"
	}

	class CClassElem_INTERMEDIARY does Node { }

	class CClassElem does Node { }

	method cclass_elem( Mu $parsed ) {
		if $parsed.list {
			my @child;
			for $parsed.list {
				if assert-hash-keys( $_, [< sign charspec >] ) {
					@child.push(
						CClassElem_INTERMEDIARY.new(
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
					);
					next
				}
				self.debug( 'cclass_elem', $_ );
				die "Uncaught type"
			}
			return CClassElem.new(
				:child( @child )
			)
		}
		self.debug( 'cclass_elem', $parsed );
		die "Uncaught type"
	}

	class Assertion does Node { }

	method assertion( Mu $parsed ) {
		if assert-hash-keys( $parsed, [< cclass_elem >] ) {
			return Assertion.new(
				:content(
					:cclass_elem(
						self.cclass_elem(
							$parsed.hash.<cclass_elem>
						)
					)
				)
			)
		}
		self.debug( 'assertion', $parsed );
		die "Uncaught type"
	}

	class BackSlash does Node { }

	method backslash( Mu $parsed ) {
		if assert-hash-keys( $parsed, [< sym >] ) {
			return BackSlash.new(
				:content(
					:sym(
						self.sym(
							$parsed.hash.<sym>
						)
					)
				)
			)
		}
		self.debug( 'backslash', $parsed );
		die "Uncaught type"
	}

	class MetaChar does Node { }

	method metachar( Mu $parsed ) {
		if assert-hash-keys( $parsed, [< sym >] ) {
			return MetaChar.new(
				:content(
					:sym(
						self.sym(
							$parsed.hash.<sym>
						)
					)
				)
			)
		}
		if assert-hash-keys( $parsed, [< backslash >] ) {
			return MetaChar.new(
				:content(
					:backslash(
						self.backslash(
							$parsed.hash.<backslash>
						)
					)
				)
			)
		}
		if assert-hash-keys( $parsed, [< assertion >] ) {
			return MetaChar.new(
				:content(
					:metachar(
						self.assertion(
							$parsed.hash.<assertion>
						)
					)
				)
			)
		}
		self.debug( 'metachar', $parsed );
		die "Uncaught type"
	}

	class Atom does Node { }

	method atom( Mu $parsed ) {
		if assert-hash-keys( $parsed, [< metachar >] ) {
			return Atom.new(
				:content(
					:metachar(
						self.metachar(
							$parsed.hash.<metachar>
						)
					)
				)
			)
		}
		if $parsed.Str {
			return Atom.new( :name( $parsed.Str ) )
		}
		self.debug( 'atom', $parsed );
		die "Uncaught type"
	}

	class NormSpace does Node { }

	method normspace( Mu $parsed ) {
		if $parsed.Str {
			return NormSpace.new( :name( $parsed.Str ) )
		}
		self.debug( 'normspace', $parsed );
		die "Uncaught type"
	}
	class SigFinal does Node { }

	method sigfinal( Mu $parsed ) {
		if assert-hash-keys( $parsed, [< normspace >] ) {
			return SigFinal.new(
				:content(
					:normspace(
						self.normspace(
							$parsed.hash.<normspace>
						)
					)
				)
			)
		}
		self.debug( 'sigfinal', $parsed );
		die "Uncaught type"
	}

	class Noun does Node { }

	method noun( Mu $parsed ) {
		if assert-hash-keys( $parsed, [< atom sigfinal >] ) {
			return Noun.new(
				:content(
					:atom(
						self.atom(
							$parsed.hash.<atom>
						)
					),
					:sigfinal(
						self.sigfinal(
							$parsed.hash.<sigfinal>
						)
					)
				)
			)
		}
		if assert-hash-keys( $parsed, [< atom >] ) {
			return Noun.new(
				:content(
					:atom(
						self.atom(
							$parsed.hash.<atom>
						)
					)
				)
			)
		}
		self.debug( 'noun', $parsed );
		die "Uncaught type"
	}

	class Termish is Node { }

	method termish( Mu $parsed ) {
		if assert-hash-keys( $parsed, [< noun >] ) {
			my @child;
			for $parsed.hash.<noun> {
				@child.push(
					self.noun(
						$_
					)
				)
			}
			return Termish.new(
				:child( @child )
			)
		}
		self.debug( 'termish', $parsed );
		die "Uncaught type"
	}

	class TermConj does Node { }

	method termconj( Mu $parsed ) {
		if assert-hash-keys( $parsed, [< termish >] ) {
			my @child;
			for $parsed.hash.<termish> {
				@child.push(
					self.termish(
						$_
					)
				)
			}
			return TermConj.new(
				:type( 'termconj' ),
				:child( @child )
			)
		}
		self.debug( 'termconj', $parsed );
		die "Uncaught type"
	}

	class TermAlt does Node { }

	method termalt( Mu $parsed ) {
		if assert-hash-keys( $parsed, [< termconj >] ) {
			my @child;
			for $parsed.hash.<termconj> {
				@child.push(
					self.termconj(
						$_
					)
				)
			}
			return TermAlt.new(
				:child( @child )
			)
		}
		self.debug( 'termalt', $parsed );
		die "Uncaught type"
	}

	class TermConjSeq does Node { }

	method termconjseq( Mu $parsed ) {
		if assert-hash-keys( $parsed, [< termalt >] ) {
			my @child;
			for $parsed.hash.<termalt> {
				@child.push(
					self.termalt(
						$_
					)
				)
			}
			return TermConjSeq.new(
				:child( @child )
			)
		}
		self.debug( 'termconjseq', $parsed );
		die "Uncaught type"
	}

	class TermAltSeq does Node { }

	method termaltseq( Mu $parsed ) {
		if assert-hash-keys( $parsed, [< termconjseq >] ) {
			my @child;
			for $parsed.hash.<termconjseq> {
				@child.push(
					self.termconjseq(
						$_
					)
				)
			}
			return TermAltSeq.new(
				:child( @child )
			)
		}
		self.debug( 'termaltseq', $parsed );
		die "Uncaught type"
	}

	class TermSeq does Node { }

	method termseq( Mu $parsed ) {
		if assert-hash-keys( $parsed, [< termaltseq >] ) {
			return TermSeq.new(
				:content(
					:termaltseq(
						self.termaltseq(
							$parsed.hash.<termaltseq>
						)
					)
				)
			)
		}
		self.debug( 'termseq', $parsed );
		die "Uncaught type"
	}

	class Nibble does Node { }

	method nibble( Mu $parsed ) {
		if assert-hash-keys( $parsed, [< termseq >] ) {
			return Nibble.new(
				:content(
					:termseq(
						self.termseq(
							$parsed.hash.<termseq>
						)
					)
				)
			)
		}
		if $parsed.Str {
			return Nibble.new( :name( $parsed.Str ) )
		}
		self.debug( 'nibble', $parsed );
		die "Uncaught type"
	}

	class DecNumber does Node { }

	method dec_number( Mu $parsed ) {
		if assert-hash-keys( $parsed, [< int coeff frac >] ) {
			return DecNumber.new(
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
		if assert-hash-keys( $parsed, [< int coeff escale >] ) {
			return DecNumber.new(
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
		self.debug( 'dec_number', $parsed );
		die "Uncaught type"
	}

	class VALUE does Node { }

	method VALUE( Mu $parsed ) {
		if assert-Int( $parsed ) {
			return VALUE.new( :name( $parsed.Int ) )
		}
		self.debug( 'VALUE', $parsed );
		die "Uncaught type"
	}

	class Numish does Node { }

	method numish( Mu $parsed ) {
		if assert-hash-keys( $parsed, [< integer >] ) {
			return Numish.new(
				:content(
					:integer(
						self.integer(
							$parsed.hash.<integer>
						)
					)
				)
			)
		}
		if assert-hash-keys( $parsed, [< rad_number >] ) {
			return Numish.new(
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
		if assert-hash-keys( $parsed, [< dec_number >] ) {
			return Numish.new(
				:content(
					:dec_number(
						self.dec_number(
							$parsed.hash.<dec_number>
						)
					)
				)
			)
		}
		self.debug( 'numish', $parsed );
		die "Uncaught type"
	}

	class Integer does Node { }

	method integer( Mu $parsed ) {
		if assert-hash-keys( $parsed, [< decint VALUE >] ) {
			return Integer.new(
				:content(
					:decint(
						self.decint(
							$parsed.hash.<decint>
						)
					),
					:VALUE(
						self.VALUE(
							$parsed.hash.<VALUE>
						)
					)
				)
			)
		}
		if assert-hash-keys( $parsed, [< binint VALUE >] ) {
			return Integer.new(
				:content(
					:binint(
						self.binint(
							$parsed.hash.<binint>
						)
					),
					:VALUE(
						self.VALUE(
							$parsed.hash.<VALUE>
						)
					)
				)
			)
		}
		if assert-hash-keys( $parsed, [< octint VALUE >] ) {
			return Integer.new(
				:content(
					:octint(
						self.octint(
							$parsed.hash.<octint>
						)
					),
					:VALUE(
						self.VALUE(
							$parsed.hash.<VALUE>
						)
					)
				)
			)
		}
		if assert-hash-keys( $parsed, [< hexint VALUE >] ) {
			return Integer.new(
				:content(
					:hexint(
						self.hexint(
							$parsed.hash.<hexint>
						)
					),
					:VALUE(
						self.VALUE(
							$parsed.hash.<VALUE>
						)
					)
				)
			)
		}
		self.debug( 'integer', $parsed );
		die "Uncaught type"
	}

	class Circumfix does Node { }

	method circumfix( Mu $parsed ) {
		if assert-hash-keys( $parsed, [< semilist >] ) {
			return Circumfix.new(
				:content(
					:semilist(
						self.semilist(
							$parsed.hash.<semilist>
						)
					)
				)
			)
		}
		if assert-hash-keys( $parsed, [< binint VALUE >] ) {
			return Circumfix.new(
				:content(
					:binint(
						self.binint(
							$parsed.hash.<binint>
						)
					),
					:VALUE(
						self.VALUE(
							$parsed.hash.<VALUE>
						)
					)
				)
			)
		}
		if assert-hash-keys( $parsed, [< octint VALUE >] ) {
			return Circumfix.new(
				:content(
					:octint(
						self.octint(
							$parsed.hash.<octint>
						)
					),
					:VALUE(
						self.VALUE(
							$parsed.hash.<VALUE>
						)
					)
				)
			)
		}
		if assert-hash-keys( $parsed, [< hexint VALUE >] ) {
			return Circumfix.new(
				:content(
					:hexint(
						self.hexint(
							$parsed.hash.<hexint>
						)
					),
					:VALUE(
						self.VALUE(
							$parsed.hash.<VALUE>
						)
					)
				)
			)
		}
		self.debug( 'circumfix', $parsed );
		die "Uncaught type"
	}

	class SemiList does Node { }

	method semilist( Mu $parsed ) {
		if assert-hash-keys( $parsed, [< statement >] ) {
			my @child;
			for $parsed.hash.<statement> {
				@child.push(
					self.statement(
						$_
					)
				)
			}
			return SemiList.new(
				:type( 'semilist' ),
				:child( @child )
			)
		}
		if assert-hash-keys( $parsed, [], [< statement >] ) {
			return SemiList.new(
				:child() # statement is the child.
			)
		}
		self.debug( 'semilist', $parsed );
		die "Uncaught type"
	}

	class RadNumber does Node { }

	method rad_number( Mu $parsed ) {
		if assert-hash-keys( $parsed, [< circumfix radix >],
					      [< exp base >] ) {
			return RadNumber.new(
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
					),
					:exp(),
					:base()
				)
			)
		}
		self.debug( 'rad_number', $parsed );
		die "Uncaught type"
	}

	class _Int does Node { }

	method int( Mu $parsed ) {
		if assert-Int( $parsed ) {
			return _Int.new( :name( $parsed.Int ) )
		}
		self.debug( 'int', $parsed );
		die "Uncaught type"
	}

	class Radix does Node { }

	method radix( Mu $parsed ) {
		if assert-Int( $parsed ) {
			return Radix.new( :name( $parsed.Int ) )
		}
		self.debug( 'radix', $parsed );
		die "Uncaught type"
	}

	class Frac does Node { }

	method frac( Mu $parsed ) {
		if assert-Int( $parsed ) {
			return Frac.new( :name( $parsed.Int ) )
		}
		self.debug( 'frac', $parsed );
		die "Uncaught type"
	}

	class Coeff does Node { }

	method coeff( Mu $parsed ) {
		if assert-Int( $parsed ) {
			return Coeff.new( :name( $parsed.Int ) )
		}
		self.debug( 'coeff', $parsed );
		die "Uncaught type"
	}

	class EScale does Node { }

	method escale( Mu $parsed ) {
		if assert-hash-keys( $parsed, [< sign decint >] ) {
			return EScale.new(
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
		self.debug( 'escale', $parsed );
		die "Uncaught type"
	}

	class BinInt does Node { }

	method binint( Mu $parsed ) {
		if assert-Int( $parsed ) {
			return BinInt.new( :name( $parsed.Int ) )
		}
		self.debug( 'binint', $parsed );
		die "Uncaught type"
	}

	class OctInt does Node { }

	method octint( Mu $parsed ) {
		if assert-Int( $parsed ) {
			return OctInt.new( :name( $parsed.Int ) )
		}
		self.debug( 'octint', $parsed );
		die "Uncaught type"
	}

	class DecInt does Node { }

	method decint( Mu $parsed ) {
		if assert-Int( $parsed ) {
			return DecInt.new( :name( $parsed.Int ) )
		}
		self.debug( 'decint', $parsed );
		die "Uncaught type"
	}

	class HexInt does Node { }

	method hexint( Mu $parsed ) {
		if assert-Int( $parsed ) {
			return HexInt.new( :name( $parsed.Int ) )
		}
		self.debug( 'hexint', $parsed );
		die "Uncaught type"
	}
}
