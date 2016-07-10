class Perl6::Tidy {
	use nqp;

	role Node {
		has $.name;
		has $.child;
		has %.content;
	}

	class BinInt does Node {
		method perl6() {
"### BinInt"
		}
		method new( Mu $parsed ) {
			if assert-Int( $parsed ) {
				return self.bless( :name( $parsed.Int ) )
			}
			die debug( 'binint', $parsed );
		}
	}

	class OctInt does Node {
		method perl6() {
"### OctInt"
		}
		method new( Mu $parsed ) {
			if assert-Int( $parsed ) {
				return self.bless( :name( $parsed.Int ) )
			}
			die debug( 'octint', $parsed );
		}
	}

	class DecInt does Node {
		method perl6() {
"### DecInt"
		}
		method new( Mu $parsed ) {
			if assert-Int( $parsed ) {
				return self.bless( :name( $parsed.Int ) )
			}
			die debug( 'decint', $parsed );
		}
	}

	class HexInt does Node {
		method perl6() {
"### DecInt"
		}
		method new( Mu $parsed ) {
			if assert-Int( $parsed ) {
				return self.bless( :name( $parsed.Int ) )
			}
			die debug( 'hexint', $parsed );
		}
	}

	class Coeff does Node {
		method perl6() {
"### Coeff"
		}
		method new( Mu $parsed ) {
			if assert-Int( $parsed ) {
				return self.bless( :name( $parsed.Int ) )
			}
			die debug( 'coeff', $parsed );
		}
	}

	class Frac does Node {
		method perl6() {
"### Frac"
		}
		method new( Mu $parsed ) {
			if assert-Int( $parsed ) {
				return self.bless( :name( $parsed.Int ) )
			}
			die debug( 'frac', $parsed );
		}
	}

	class NormSpace does Node {
		method perl6() {
"### NormSpace"
		}
		method new( Mu $parsed ) {
			if assert-Str( $parsed ) {
				return self.bless( :name( $parsed.Str ) )
			}
			die debug( 'normspace', $parsed );
		}
	}

	class Radix does Node {
		method perl6() {
"### Radix"
		}
		method new( Mu $parsed ) {
			if assert-Int( $parsed ) {
				return self.bless( :name( $parsed.Int ) )
			}
			die debug( 'radix', $parsed );
		}
	}

	class _Int does Node {
		method perl6() {
"### _Int"
		}
		method new( Mu $parsed ) {
			if assert-Int( $parsed ) {
				return self.bless( :name( $parsed.Int ) )
			}
			die debug( 'int', $parsed );
		}
	}

	class VALUE does Node {
		method perl6() {
"### VALUE"
		}
		method new( Mu $parsed ) {
			if assert-Int( $parsed ) {
				return self.bless( :name( $parsed.Int ) )
			}
			die debug( 'VALUE', $parsed );
		}
	}

	class Sym does Node {
		method perl6() {
"### sym"
		}
		method new( Mu $parsed ) {
			if assert-Str( $parsed ) {
				return self.bless( :name( $parsed.Str ) )
			}
			die debug( 'sym', $parsed );
		}
	}

	class Sigil does Node {
		method perl6() {
"### sigil"
		}
		method new( Mu $parsed ) {
			if assert-Str( $parsed ) {
				return self.bless( :name( $parsed.Str ) )
			}
			die debug( 'sigil', $parsed );
		}
	}

	class Sign does Node {
		method perl6() {
"### sigil"
		}
		method new( Mu $parsed ) {
			if assert-Bool( $parsed ) {
				return self.bless( :name( $parsed.Bool ) )
			}
			die debug( 'sign', $parsed );
		}
	}

	class EScale does Node {
		method perl6() {
"### EScale"
		}
		method new( Mu $parsed ) {
			if assert-hash-keys( $parsed, [< sign decint >] ) {
				return self.bless(
					:content(
						:sign(
							Sign.new(
								$parsed.hash.<sign>
							)
						),
						:decint(
							DecInt.new(
								$parsed.hash.<decint>
							)
						)
					)
				)
			}
			die debug( 'escale', $parsed );
		}
	}

	class Integer does Node {
		method perl6() {
"### Integer"
		}
		method new( Mu $parsed ) {
			if assert-hash-keys( $parsed, [< decint VALUE >] ) {
				return self.bless(
					:content(
						:decint(
							DecInt.new(
								$parsed.hash.<decint>
							)
						),
						:VALUE(
							VALUE.new(
								$parsed.hash.<VALUE>
							)
						)
					)
				)
			}
			if assert-hash-keys( $parsed, [< binint VALUE >] ) {
				return self.bless(
					:content(
						:binint(
							BinInt.new(
								$parsed.hash.<binint>
							)
						),
						:VALUE(
							VALUE.new(
								$parsed.hash.<VALUE>
							)
						)
					)
				)
			}
			if assert-hash-keys( $parsed, [< octint VALUE >] ) {
				return self.bless(
					:content(
						:octint(
							OctInt.new(
								$parsed.hash.<octint>
							)
						),
						:VALUE(
							VALUE.new(
								$parsed.hash.<VALUE>
							)
						)
					)
				)
			}
			if assert-hash-keys( $parsed, [< hexint VALUE >] ) {
				return self.bless(
					:content(
						:hexint(
							HexInt.new(
								$parsed.hash.<hexint>
							)
						),
						:VALUE(
							VALUE.new(
								$parsed.hash.<VALUE>
							)
						)
					)
				)
			}
			die debug( 'integer', $parsed );
		}
	}

	class BackSlash does Node {
		method perl6() {
"### BackSlash"
		}
		method new( Mu $parsed ) {
			if assert-hash-keys( $parsed, [< sym >] ) {
				return self.bless(
					:content(
						:sym(
							Sym.new(
								$parsed.hash.<sym>
							)
						)
					)
				)
			}
			die debug( 'backslash', $parsed );
		}
	}

	class Identifier does Node {
		method perl6() {
"### Identifier"
		}
		method new( Mu $parsed ) {
			if $parsed.list {
				my @child;
				for $parsed.list {
					if assert-Str( $_ ) {
						@child.push(
							$_.Str
						);
						next
					}
					die debug( 'identifier', $_ );
				}
				return self.bless(
					:child( @child )
				)
			}
			elsif $parsed.Str {
				return self.bless( :name( $parsed.Str ) )
			}
			die debug( 'identifier', $parsed );
		}
	}

	sub debug( Str $name, Mu $parsed ) {
		my @lines;
		my @types;

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

		@lines.push( "$name ({@types})" );

		@lines.push( "\+$name: "    ~   $parsed.Int       ) if $parsed.Int;
		@lines.push( "\~$name: '"   ~   $parsed.Str ~ "'" ) if $parsed.Str;
		@lines.push( "\?$name: "    ~ ~?$parsed.Bool      ) if $parsed.Bool;
		if $parsed.list {
			for $parsed.list {
				@lines.push( "$name\[\]:\n" ~ $_.dump )
			}
			return;
		}
		elsif $parsed.hash() {
			@lines.push( "$name\{\} keys: " ~ $parsed.hash.keys );
			@lines.push( "$name\{\}:\n" ~   $parsed.dump );
		}

		@lines.push( "" );
		return @lines.join("\n");
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

	class Root does Node {
		method perl6() {
"### Root"
		}
	}

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
		die debug( 'root', $parsed );
	}

	class StatementList does Node {
		method perl6() {
"### StatementList"
		}
	}

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
		die debug( 'statementlist', $parsed );
	}

	class Statement does Node {
		method perl6() {
"### Statement"
		}
	}

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
					@child.push(
						self.statement_control(
							$_.hash.<statement_control>
						)
					);
					next
				}
				die debug( 'statement', $_ );
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
						Sigil.new(
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
		die debug( 'statement', $parsed );
	}

	class O does Node {
		method perl6() {
"### O"
		}
		method new( Hash $hash ) {
			if $hash.<prec> and
			   $hash.<fiddly> and
			   $hash.<dba> and
			   $hash.<assoc> {
				return self.bless(
					:content(
					)
				)
			}
			die debug( 'O', $hash );
		}
	}

	class Postfix does Node {
		method perl6() {
"### Postfix"
		}
		method new( Mu $parsed ) {
			if assert-hash-keys( $parsed, [< sym O >] ) {
				return self.bless(
					:content(
						:sym(
							Sym.new(
								$parsed.hash.<sym>
							)
						),
						:O(
							O.new(
								$parsed.hash.<O>
							)
						)
					)
				)
			}
			die debug( 'postfix', $parsed );
		}
	}

	class Args does Node {
		method perl6() {
"### Args"
		}
		method new( Mu $parsed ) {
			if $parsed.Bool {
				return self.bless( :name( $parsed.Bool ) )
			}
			die debug( 'args', $parsed );
		}
	}

	class MethodOp does Node {
		method perl6() {
"### MethodOp"
		}
	}

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
						Args.new(
							$parsed.hash.<args>
						)
					)
				)
			)
		}
		die debug( 'methodop', $parsed );
	}

	class DottyOp does Node {
		method perl6() {
"### DottyOp"
		}
	}

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
		die debug( 'dottyop', $parsed );
	}

	class OPER does Node {
		method perl6() {
"### OPER"
		}
	}

	method OPER( Mu $parsed ) {
		if assert-hash-keys( $parsed, [< sym dottyop O >] ) {
			return OPER.new(
				:content(
					:sym(
						Sym.new(
							$parsed.hash.<sym>
						)
					),
					:dottyop(
						self.dottyop(
							$parsed.hash.<dottyop>
						)
					),
					:O(
						O.new(
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
						Sym.new(
							$parsed.hash.<sym>
						)
					),
					:O(
						O.new(
							$parsed.hash.<O>
						)
					)
				)
			)
		}
		die debug( 'OPER', $parsed );
	}

	class MoreName does Node {
		method perl6() {
"### MoreName"
		}
	}

	method morename( Mu $parsed ) {
		if $parsed.list {
			my @child;
			for $parsed.list {
				if assert-hash-keys( $_, [< identifier >] ) {
					@child.push(
						Identifier.new(
							$_.hash.<identifier>
						)
					);
					next
				}
				if assert-hash-keys( $_, [< EXPR >] ) {
					@child.push(
						self.EXPR(
							$_.hash.<EXPR>
						)
					);
					next
				}
				die debug( 'morename', $_ );
			}
			return MoreName.new(
				:child( @child )
			)
		}
		die debug( 'morename', $parsed );
	}

	class Name does Node {
		method perl6() {
"### Name"
		}
	}

	method name( Mu $parsed ) {
		if assert-hash-keys( $parsed, [< identifier morename >] ) {
			return Name.new(
				:content(
					:identifier(
						Identifier.new(
							$parsed.hash.<identifier>
						)
					),
					:morename(
						self.morename(
							$parsed.hash.<morename>
						)
					),
				)
			)
		}
		if assert-hash-keys( $parsed, [< identifier >],
					      [< morename >] ) {
			return Name.new(
				:content(
					:identifier(
						Identifier.new(
							$parsed.hash.<identifier>
						)
					),
				),
				:child()
			)
		}
		die debug( 'name', $parsed );
	}

	class Signature does Node {
		method perl6() {
"### Signature"
		}
		method new( Mu $parsed ) {
			if assert-hash-keys( $parsed, [], [< param_sep parameter >] ) {
				return self.bless(
					:name( $parsed.Bool ),
					:content(
						:param_sep(),
						:parameter()
					)
				)
			}
			die debug( 'signature', $parsed );
		}
	}

	class FakeSignature does Node {
		method perl6() {
"### FakeSignature"
		}
		method new( Mu $parsed ) {
			if assert-hash-keys( $parsed, [< signature >] ) {
				return self.bless(
					:content(
						:signature(
							Signature.new(
								$parsed.hash.<signature>
							)
						)
					)
				)
			}
			die debug( 'fakesignature', $parsed );
		}
	}

	class ColonPair does Node {
		method perl6() {
"### ColonPair"
		}
		method new( Mu $parsed ) {
			if assert-hash-keys( $parsed, [< identifier >] ) {
				return self.bless(
					:content(
						:identifier(
							Identifier.new(
								$parsed.hash.<identifier>
							)
						)
					)
				)
			}
			if assert-hash-keys( $parsed, [< fakesignature >] ) {
				return self.bless(
					:content(
						:fakesignature(
							FakeSignature.new(
								$parsed.hash.<fakesignature>
							)
						)
					)
				)
			}
			die debug( 'colonpair', $parsed );
		}
	}

	class LongName does Node {
		method perl6() {
"### LongName"
		}
	}

	method longname( Mu $parsed ) {
		if assert-hash-keys( $parsed, [< name >], [< colonpair >] ) {
			return LongName.new(
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
		die debug( 'longname', $parsed );
	}

	class Twigil does Node {
		method perl6() {
"### Twigil"
		}
		method new( Mu $parsed ) {
			if assert-hash-keys( $parsed, [< sym >] ) {
				return self.bless(
					:content(
						:sym(
							Sym.new(
								$parsed.hash.<sym>
							)
						)
					)
				)
			}
			die debug( 'twigil', $parsed );
		}
	}

	class DeSigilName does Node {
		method perl6() {
"### DeSigilName"
		}
	}

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
		die debug( 'desigilname', $parsed );
	}

	class Variable does Node {
		method perl6() {
"### Variable"
		}
	}

	method variable( Mu $parsed ) {
		if assert-hash-keys( $parsed, [< twigil sigil desigilname >] ) {
			return Variable.new(
				:content(
					:twigil(
						Twigil.new(
							$parsed.hash.<twigil>
						)
					),
					:sigil(
						Sigil.new(
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
						Sigil.new(
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
						Sigil.new(
							$parsed.hash.<sigil>
						)
					)
				)
			)
		}
		die debug( 'variable', $parsed );
	}

	class RoutineDeclarator does Node {
		method perl6() {
"### RoutineDeclarator"
		}
	}

	method routine_declarator( Mu $parsed ) {
		if assert-hash-keys( $parsed, [< sym routine_def >] ) {
			return RoutineDeclarator.new(
				:content(
					:sym(
						Sym.new(
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
		die debug( 'routine_declarator', $parsed );
	}

	class PackageDeclarator does Node {
		method perl6() {
"### PackageDeclator"
		}
	}

	method package_declarator( Mu $parsed ) {
		if assert-hash-keys( $parsed, [< sym package_def >] ) {
			return PackageDeclarator.new(
				:content(
					:sym(
						Sym.new(
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
		die debug( 'package_declarator', $parsed );
	}

	class RegexDeclarator does Node {
		method perl6() {
"### RegexDeclarator"
		}
	}

	method regex_declarator( Mu $parsed ) {
		if assert-hash-keys( $parsed, [< sym regex_def >] ) {
			return RegexDeclarator.new(
				:content(
					:sym(
						Sym.new(
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
		die debug( 'regex_declarator', $parsed );
	}

	class RoutineDef does Node {
		method perl6() {
"### RoutineDef"
		}
	}

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
		die debug( 'routine_def', $parsed );
	}

	class PackageDef does Node {
		method perl6() {
"### PackageDef"
		}
	}

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
		die debug( 'package_def', $parsed );
	}

	class CharSpec does Node {
		method perl6() {
"### CharSpec"
		}
		method new( Mu $parsed ) {
			if $parsed.list {
				my @child;
				for $parsed.list -> $list {
					my @_child;
					for $list.list -> $_list {
						my @__child;
						for $_list.list {
							if assert-Str( $_ ) {
								@__child.push( $_ );
								next
							}
							die debug( 'charspec', $_ );
						}
	#					die debug( 'charspec', $_list );
					}
	#				die debug( 'charspec', $list );
				}
				return self.bless(
					:child( @child )
				)
			}
			die debug( 'charspec', $parsed );
		}
	}

	class CClassElem_INTERMEDIARY does Node {
		method perl6() {
"### CClassElem_INT"
		}
	}

	class CClassElem does Node {
		method perl6() {
"### CClassElem"
		}
		method new( Mu $parsed ) {
			if $parsed.list {
				my @child;
				for $parsed.list {
					if assert-hash-keys( $_, [< sign charspec >] ) {
						@child.push(
							CClassElem_INTERMEDIARY.new(
								:content(
									:sign(
										Sign.new(
											$_.hash.<sign>
										)
									),
									:charspec(
										CharSpec.new(
											$_.hash.<charspec>
										)
									)
								)
							)
						);
						next
					}
					die debug( 'cclass_elem', $_ );
				}
				return self.bless(
					:child( @child )
				)
			}
			die debug( 'cclass_elem', $parsed );
		}
	}

	class Assertion does Node {
		method perl6() {
"### Assertion"
		}
		method new( Mu $parsed ) {
			if assert-hash-keys( $parsed, [< cclass_elem >] ) {
				return self.bless(
					:content(
						:cclass_elem(
							CClassElem.new(
								$parsed.hash.<cclass_elem>
							)
						)
					)
				)
			}
			die debug( 'assertion', $parsed );
		}
	}

	class MetaChar does Node {
		method perl6() {
"### MetaChar"
		}
		method new( Mu $parsed ) {
			if assert-hash-keys( $parsed, [< sym >] ) {
				return self.bless(
					:content(
						:sym(
							Sym.new(
								$parsed.hash.<sym>
							)
						)
					)
				)
			}
			if assert-hash-keys( $parsed, [< backslash >] ) {
				return self.bless(
					:content(
						:backslash(
							BackSlash.new(
								$parsed.hash.<backslash>
							)
						)
					)
				)
			}
			if assert-hash-keys( $parsed, [< assertion >] ) {
				return self.bless(
					:content(
						:metachar(
							Assertion.new(
								$parsed.hash.<assertion>
							)
						)
					)
				)
			}
			die debug( 'metachar', $parsed );
		}
	}

	class Atom does Node {
		method perl6() {
"### Atom"
		}
		method new( Mu $parsed ) {
			if assert-hash-keys( $parsed, [< metachar >] ) {
				return self.bless(
					:content(
						:metachar(
							MetaChar.new(
								$parsed.hash.<metachar>
							)
						)
					)
				)
			}
			if $parsed.Str {
				return self.bless( :name( $parsed.Str ) )
			}
			die debug( 'atom', $parsed );
		}
	}

	class Noun does Node {
		method perl6() {
"### Node"
		}
		method new( Mu $parsed ) {
			if $parsed.list {
				my @child;
				for $parsed.list {
					if assert-hash-keys( $_, [< atom >],
								 [< sigfinal >] ) {
						@child.push(
							Atom.new(
								$_.hash.<atom>
							)
						);
						next
					}
					die debug( 'noun', $_ );
				}
				return self.bless(
					:child( @child )
				)
			}
			die debug( 'noun', $parsed );
		}
	}

	class TermIsh is Node {
		method perl6() {
"### TermIsh"
		}
		method new( Mu $parsed ) {
			if $parsed.list {
				my @child;
				for $parsed.list {
					if assert-hash-keys( $_, [< noun >] ) {
						@child.push(
							Noun.new(
								$_.hash.<noun>
							)
						);
						next
					}
					die debug( 'termish', $_ );
				}
				return self.bless(
					:child( @child )
				)
			}
			if assert-hash-keys( $parsed, [< noun >] ) {
				return self.bless(
					:content(
						:noun(
							Noun.new(
								$parsed.hash.<noun>
							)
						)
					)
				)
			}
			die debug( 'termish', $parsed );
		}
	}

	class TermConj does Node {
		method perl6() {
"### TermConj"
		}
		method new( Mu $parsed ) {
			if $parsed.list {
				my @child;
				for $parsed.list {
					if assert-hash-keys( $_, [< termish >] ) {
						@child.push(
							TermIsh.new(
								$_.hash.<termish>
							)
						);
						next
					}
					die debug( 'termconj', $_ );
				}
				return self.bless(
					:child( @child )
				)
			}
			die debug( 'termconj', $parsed );
		}
	}

	class TermAlt does Node {
		method perl6() {
"### TermAlt"
		}
		method new( Mu $parsed ) {
			if $parsed.list {
				my @child;
				for $parsed.list {
					if assert-hash-keys( $_, [< termconj >] ) {
						@child.push(
							TermConj.new(
								$_.hash.<termconj>
							)
						);
						next
					}
					die debug( 'termalt', $_ );
				}
				return self.bless(
					:child( @child )
				)
			}
			die debug( 'termalt', $parsed );
		}
	}

	class TermConjSeq does Node {
		method perl6() {
"### TermConjSeq"
		}
		method new( Mu $parsed ) {
			if $parsed.list {
				my @child;
				for $parsed.list {
					if assert-hash-keys( $_, [< termalt >] ) {
						@child.push(
							TermAlt.new(
								$_.hash.<termalt>
							)
						);
						next
					}
					die debug( 'termconjseq', $_ );
				}
				return self.bless(
					:child( @child )
				)
			}
			if assert-hash-keys( $parsed, [< termalt >] ) {
				return self.bless(
					:content(
						:termalt(
							TermAlt.new(
								$parsed.hash.<termalt>
							)
						)
					)
				)
			}
			die debug( 'termconjseq', $parsed );
		}
	}

	class TermAltSeq does Node {
		method perl6() {
"### termAltSeq"
		}
		method new( Mu $parsed ) {
			if assert-hash-keys( $parsed, [< termconjseq >] ) {
				return self.bless(
					:content(
						:termconjseq(
							TermConjSeq.new(
								$parsed.hash.<termconjseq>
							)
						)
					)
				)
			}
			die debug( 'termaltseq', $parsed );
		}
	}

	class TermSeq does Node {
		method perl6() {
"### TermSeq"
		}
		method new( Mu $parsed ) {
			if assert-hash-keys( $parsed, [< termaltseq >] ) {
				return self.bless(
					:content(
						:termaltseq(
							TermAltSeq.new(
								$parsed.hash.<termaltseq>
							)
						)
					)
				)
			}
			die debug( 'termseq', $parsed );
		}
	}

	class Nibble does Node {
		method perl6() {
"### Nibble"
		}
		method new( Mu $parsed ) {
			if assert-hash-keys( $parsed, [< termseq >] ) {
				return self.bless(
					:content(
						:termseq(
							TermSeq.new(
								$parsed.hash.<termseq>
							)
						)
					)
				)
			}
			if $parsed.Str {
				return self.bless( :name( $parsed.Str ) )
			}
			die debug( 'nibble', $parsed );
		}
	}

	class RegexDef does Node {
		method perl6() {
"### RegexDef"
		}
	}

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
						Nibble.new(
							$parsed.hash.<nibble>
						)
					),
					:signature(),
					:trait()
				)
			)
		}
		die debug( 'regex_def', $parsed );
	}

	class Blockoid does Node {
		method perl6() {
"### Blockoid"
		}
	}

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
		die debug( 'blockoid', $parsed );
	}

	class DefLongName does Node {
		method perl6() {
"### DefLongName"
		}
	}

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
		die debug( 'deflongname', $parsed );
	}

	class Dotty does Node {
		method perl6() {
"### Dotty"
		}
	}

	method dotty( Mu $parsed ) {
		if assert-hash-keys( $parsed, [< sym dottyop O >] ) {
			return Dotty.new(
				:content(
					:sym(
						Sym.new(
							$parsed.hash.<sym>
						)
					),
					:dottyop(
						self.dottyop(
							$parsed.hash.<dottyop>
						)
					),
					:O(
						O.new(
							$parsed.hash.<O>
						)
					)
				)
			)
		}
		die debug( 'dotty', $parsed );
	}

	class SemiList does Node {
		method perl6() {
"### SemiList"
		}
		method new( Mu $parsed ) {
			if assert-hash-keys( $parsed, [], [< statement >] ) {
				return self.bless
			}
			die debug( 'semilist', $parsed );
		}
	}

	class Circumfix does Node {
		method perl6() {
"### Circumfix"
		}
		method new( Mu $parsed ) {
			if assert-hash-keys( $parsed, [< semilist >] ) {
				return self.bless(
					:content(
						:semilist(
							SemiList.new(
								$parsed.hash.<semilist>
							)
						)
					)
				)
			}
			if assert-hash-keys( $parsed, [< binint VALUE >] ) {
				return self.bless(
					:content(
						:binint(
							BinInt.new(
								$parsed.hash.<binint>
							)
						),
						:VALUE(
							VALUE.new(
								$parsed.hash.<VALUE>
							)
						)
					)
				)
			}
			if assert-hash-keys( $parsed, [< octint VALUE >] ) {
				return self.bless(
					:content(
						:octint(
							OctInt.new(
								$parsed.hash.<octint>
							)
						),
						:VALUE(
							VALUE.new(
								$parsed.hash.<VALUE>
							)
						)
					)
				)
			}
			if assert-hash-keys( $parsed, [< hexint VALUE >] ) {
				return self.bless(
					:content(
						:hexint(
							HexInt.new(
								$parsed.hash.<hexint>
							)
						),
						:VALUE(
							VALUE.new(
								$parsed.hash.<VALUE>
							)
						)
					)
				)
			}
			die debug( 'circumfix', $parsed );
		}
	}

	class B does Node {
		method perl6() {
"### B"
		}
		method new( Mu $parsed ) {
			if assert-Bool( $parsed ) {
				return self.bless( :name( $parsed.Bool ) )
			}
			die debug( 'B', $parsed );
		}
	}

	class Babble does Node {
		method perl6() {
"### Babble"
		}
		method new( Mu $parsed ) {
			if assert-hash-keys( $parsed, [< B >], [< quotepair >] ) {
				return self.bless(
					:content(
						:B(
							B.new(
								$parsed.hash.<B>
							)
						),
						:quotepair()
					)
				)
			}
			die debug( 'babble', $parsed );
		}
	}

	class Quibble does Node {
		method perl6() {
"### Quibble"
		}
		method new( Mu $parsed ) {
			if assert-hash-keys( $parsed, [< babble nibble >] ) {
				return self.bless(
					:content(
						:babble(
							Babble.new(
								$parsed.hash.<babble>
							)
						),
						:nibble(
							Nibble.new(
								$parsed.hash.<nibble>
							)
						)
					)
				)
			}
			die debug( 'quibble', $parsed );
		}
	}

	class Quote does Node {
		method perl6() {
"### Quote"
		}
		method new( Mu $parsed ) {
			if assert-hash-keys( $parsed, [< nibble >] ) {
				return self.bless(
					:content(
						:nibble(
							Nibble.new(
								$parsed.hash.<nibble>
							)
						)
					)
				)
			}
			if assert-hash-keys( $parsed, [< quibble >] ) {
				return self.bless(
					:content(
						:quibble(
							Quibble.new(
								$parsed.hash.<quibble>
							)
						)
					)
				)
			}
			die debug( 'quote', $parsed );
		}
	}

	class RadNumber does Node {
		method perl6() {
"### RadNumber"
		}
		method new( Mu $parsed ) {
			if assert-hash-keys( $parsed, [< circumfix radix >],
						      [< exp base >] ) {
				return self.bless(
					:content(
						:circumfix(
							Circumfix.new(
								$parsed.hash.<circumfix>,
							)
						),
						:radix(
							Radix.new(
								$parsed.hash.<radix>,
							)
						),
						:exp(),
						:base()
					)
				)
			}
			die debug( 'rad_number', $parsed );
		}
	}

	class DecNumber does Node {
		method perl6() {
"### DecNumber"
		}
		method new( Mu $parsed ) {
			if assert-hash-keys( $parsed, [< int coeff frac >] ) {
				return self.bless(
					:content(
						:int(
							_Int.new(
								$parsed.hash.<int>
							)
						),
						:coeff(
							Coeff.new(
								$parsed.hash.<coeff>
							)
						),
						:frac(
							Frac.new(
								$parsed.hash.<frac>
							)
						)
					)
				)
			}
			if assert-hash-keys( $parsed, [< int coeff escale >] ) {
				return self.bless(
					:content(
						:int(
							_Int.new(
								$parsed.hash.<int>
							)
						),
						:coeff(
							Coeff.new(
								$parsed.hash.<coeff>
							)
						),
						:escale(
							EScale.new(
								$parsed.hash.<escale>
							)
						)
					)
				)
			}
			die debug( 'dec_number', $parsed );
		}
	}

	class Numish does Node {
		method perl6() {
"### Numish"
		}
		method new( Mu $parsed ) {
			if assert-hash-keys( $parsed, [< integer >] ) {
				return self.bless(
					:content(
						:integer(
							Integer.new(
								$parsed.hash.<integer>
							)
						)
					)
				)
			}
			if assert-hash-keys( $parsed, [< rad_number >] ) {
				return self.bless(
					:content(
						:rad_number(
							RadNumber.new(
								$parsed.hash.<rad_number>
							)
						)
					)
				)
			}
			if assert-hash-keys( $parsed, [< dec_number >] ) {
				return self.bless(
					:content(
						:dec_number(
							DecNumber.new(
								$parsed.hash.<dec_number>
							)
						)
					)
				)
			}
			die debug( 'numish', $parsed );
		}
	}

	class Number does Node {
		method perl6() {
"### Number"
		}
		method new( Mu $parsed ) {
			if assert-hash-keys( $parsed, [< numish >] ) {
				return self.bless(
					:content(
						:numish(
							Numish.new(
								$parsed.hash.<numish>
							)
						)
					)
				)
			}
			die debug( 'number', $parsed );
		}
	}

	class Value does Node {
		method perl6() {
"### Value"
		}
		method new( Mu $parsed ) {
			if assert-hash-keys( $parsed, [< number >] ) {
				return self.bless(
					:content(
						:number(
							Number.new(
								$parsed.hash.<number>
							)
						)
					)
				)
			}
			if assert-hash-keys( $parsed, [< quote >] ) {
				return self.bless(
					:content(
						:quote(
							Quote.new(
								$parsed.hash.<quote>
							)
						)
					)
				)
			}
			die debug( 'value', $parsed );
		}
	}

	class EXPR does Node {
		method perl6() {
"### EXPR"
		}
	}

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
						Value.new(
							$_.hash.<value>
						)
					);
					next;
				}
				die debug( 'EXPR', $_ );
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
								Postfix.new(
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
				die debug( 'EXPR', $parsed );
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
						Args.new(
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
						Value.new(
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
						Circumfix.new(
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
						ColonPair.new(
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
		die debug( 'EXPR', $parsed );
	}

	class PostConstraint does Node {
		method perl6() {
"### PostConstraint"
		}
	}

	method post_constraint( Mu $parsed ) {
		if $parsed.list {
			my @child;
			for $parsed.list {
				if assert-hash-keys( $_, [< EXPR >] ) {
					@child.push(
						self.EXPR(
							$_.hash.<EXPR>
						)
					);
					next;
				}
				die debug( 'variable_declarator', $_ );
			}
			return PostConstraint.new(
				:child( @child )
			)
		}
		die debug( 'post_constraint', $parsed );
	}

	class VariableDeclarator does Node {
		method perl6() {
"### VariableDelarator"
		}
	}

	method variable_declarator( Mu $parsed ) {
		if assert-hash-keys(
			$parsed,
			[< variable post_constraint >],
			[< semilist postcircumfix signature trait >] ) {
			return VariableDeclarator.new(
				:content(
					:variable(
						self.variable(
							$parsed.hash.<variable>
						)
					),
					:post_constraint(
						self.post_constraint(
							$parsed.hash.<post_constraint>
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
				:content(
					:variable(
						self.variable(
							$parsed.hash.<variable>
						)
					),
					:semilist(),
					:postcircumfix(),
					:signature(),
					:trait(),
					:post_constraint()
				)
			)
		}
		die debug( 'variable_declarator', $parsed );
	}

	class Doc does Node {
		method perl6() {
"### Doc"
		}
		method new( Mu $parsed ) {
			if assert-Bool( $parsed ) {
				return self.bless( :name( $parsed.Bool ) )
			}
			die debug( 'doc', $parsed );
		}
	}

	class ModuleName does Node {
		method perl6() {
"### ModuleName"
		}
	}

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
		die debug( 'module_name', $parsed );
	}

	class VStr does Node {
		method perl6() {
"### VStr"
		}
		method new( Mu $parsed ) {
			if $parsed.Int {
				return self.bless( :name( $parsed.Int ) )
			}
			die debug( 'vstr', $parsed );
		}
	}

	class VNum does Node {
		method perl6() {
"### VNum"
		}
		method new( Mu $parsed ) {
			if $parsed.list {
				return self.bless( :child() )
			}
			die debug( 'vnum', $parsed );
		}
	}

	class Version does Node {
		method perl6() {
"### Version"
		}
		method new( Mu $parsed ) {
			if assert-hash-keys( $parsed, [< vnum vstr >] ) {
				return self.bless(
					:content(
						:vnum(
							VNum.new(
								$parsed.hash.<vnum>
							)
						),
						:vstr(
							VStr.new(
								$parsed.hash.<vstr>
							)
						)
					)
				)
			}
			die debug( 'version', $parsed );
		}
	}

	class StatementControl does Node {
		method perl6() {
"### StatementControl"
		}
	}

	method statement_control( Mu $parsed ) {
		if assert-hash-keys( $parsed, [< doc sym module_name >] ) {
			return StatementControl.new(
				:content(
					:doc(
						Doc.new(
							$parsed.hash.<doc>
						)
					),
					:sym(
						Sym.new(
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
						Doc.new(
							$parsed.hash.<doc>
						)
					),
					:sym(
						Sym.new(
							$parsed.hash.<sym>
						)
					),
					:version(
						Version.new(
							$parsed.hash.<version>
						)
					)
				)
			)
		}
		die debug( 'statement_control', $parsed );
	}

	class MultiDeclarator does Node {
		method perl6() {
"### MultiDeclarator"
		}
	}

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
		die debug( 'multi_declarator', $parsed );
	}

	class Initializer does Node {
		method perl6() {
"### Initializer"
		}
	}

	method initializer( Mu $parsed ) {
		if assert-hash-keys( $parsed, [< sym EXPR >] ) {
			return Initializer.new(
				:content(
					:sym(
						Sym.new(
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
		die debug( 'initializer', $parsed );
	}

	class Declarator does Node {
		method perl6() {
"### Declarator"
		}
	}

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
		die debug( 'declarator', $parsed );
	}

	class DECL does Node {
		method perl6() {
"### DECL"
		}
	}

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
						Sym.new(
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
		die debug( 'DECL', $parsed );
	}

	class TypeName does Node {
		method perl6() {
"### TypeName"
		}
	}

	class TypeName_INTERMEDIARY does Node {
		method perl6() {
"### TypeName_INTERMEDIARY"
		}
	}

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
				die debug( 'typename', $_ );
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
		die debug( 'typename', $parsed );
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
		die debug( 'scoped', $parsed );
	}

	class ScopeDeclarator does Node {
		method perl6() {
"### ScopeDeclarator"
		}
	}

	method scope_declarator( Mu $parsed ) {
		if assert-hash-keys( $parsed, [< sym scoped >] ) {
			return ScopeDeclarator.new(
				:content(
					:sym(
						Sym.new(
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
		die debug( 'scope_declarator', $parsed );
	}
}
