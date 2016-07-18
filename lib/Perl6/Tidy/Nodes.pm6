# Bulk forward declarations.

class _ArgList {...}
class _Args {...}
class _Assertion {...}
class _Atom {...}
class _Atom_SigFinal {...}
class _Atom_SigFinal_Quantifier {...}
class _B {...}
class _Babble {...}
class _BackSlash {...}
class _BackMod {...}
class _BinInt {...}
class _Block {...}
class _Blockoid {...}
class _Blorst {...}
class _CClassElem {...}
class _CharSpec {...}
class _Circumfix {...}
class _CodeBlock {...}
class _Coeff {...}
class _Coercee {...}
class _ColonCircumfix {...}
class _ColonPair {...}
class _ColonPairs {...}
class _Contextualizer {...}
class _DecInt {...}
class _DECL {...}
class _Declarator {...}
class _DecNumber {...}
class _DefLongName {...}
class _DefTerm {...}
class _DeSigilName {...}
class _Doc {...}
class _Dotty {...}
class _DottyOp {...}
class _Dotty_OPER {...}
class _E1 {...}
class _E2 {...}
class _E3 {...}
class _EScale {...}
class _EXPR {...}
class _FakeSignature {...}
class _FatArrow {...}
class _Frac {...}
class _HexInt {...}
class _Identifier {...}
class _Identifier_Args {...}
class _Infix {...}
class _Infix_OPER {...}
class _InfixIsh {...}
class _InfixPrefixMetaOperator {...}
class _Initializer {...}
class _Int {...}
class _Integer {...}
class _Key {...}
class _Lambda {...}
class _LongName {...}
class _LongName_ColonPair {...}
class _LongName_ColonPairs {...}
class _MetaChar {...}
class _MethodDef {...}
class _MethodOp {...}
class _ModifierExpr {...}
class _ModuleName {...}
class _MultiDeclarator {...}
class _MultiSig {...}
class _Name {...}
class _Nibble {...}
class _Nibbler {...}
class _NormSpace {...}
class _Noun {...}
class _Number {...}
class _Numish {...}
class _O {...}
class _OctInt {...}
class _Op {...}
class _OPER {...}
class _PackageDeclarator {...}
class _PackageDef {...}
class _ParamVar {...}
class _ParamVar_TypeConstraint_Quant {...}
class _PBlock {...}
class Root {...}
class _PostCircumfix {...}
class _PostCircumfix_OPER {...}
class _Postfix {...}
class _Postfix_OPER {...}
class _PostOp {...}
class _Prefix {...}
class _Prefix_OPER {...}
class _QuantifiedAtom {...}
class _Quant {...}
class _Quantifier {...}
class _Quibble {...}
class _Quote {...}
class _Radix {...}
class _RadNumber {...}
class _RegexDeclarator {...}
class _RegexDef {...}
class _RoutineDeclarator {...}
class _RoutineDef {...}
class _Scoped {...}
class _ScopeDeclarator {...}
class _SemiList {...}
class _Separator {...}
class _SepType {...}
class _Shape {...}
class _SigFinal {...}
class _Sigil {...}
class _Sign {...}
class _Sign_CharSpec {...}
class _Signature {...}
class _SMExpr {...}
class _Specials {...}
class _Statement {...}
class _StatementControl {...}
class _StatementList {...}
class _StatementModCond {...}
class _StatementModCond_EXPR {...}
class _StatementModLoop {...}
class _StatementModLoop_EXPR {...}
class _StatementPrefix {...}
class _Sym {...}
class _TermAlt {...}
class _TermAltSeq {...}
class _TermConj {...}
class _TermConjSeq {...}
class _TermIsh {...}
class _TermSeq {...}
class _Twigil {...}
class _TypeConstraint {...}
class _TypeDeclarator {...}
class _TypeName {...}
class _Val {...}
class _Value {...}
class _VALUE {...}
class _Var {...}
class _Variable {...}
class _VariableDeclarator {...}
class _Version {...}
class _VNum {...}
class _VStr {...}
class _Wu {...}
class _XBlock {...}

sub dump-parsed( Mu $parsed ) {
	my @lines;
	my @types;
	@types.push( 'Bool' ) if $parsed.Bool;
	@types.push( 'Int'  ) if $parsed.Int;
	@types.push( 'Num'  ) if $parsed.Num;

	@lines.push( Q[ ~:   '] ~ ~$parsed.Str ~ "' - Types: " ~ @types.gist );
	@lines.push( Q[{}:    ] ~ $parsed.hash.keys.gist );
	# XXX
	CATCH { default { .resume } } # workaround for X::Hash exception
	@lines.push( Q{[]:    } ~ $parsed.list.elems );

	if $parsed.hash {
		my @keys;
		for $parsed.hash.keys {
			@keys.push( $_ ) if
				$parsed.hash:defined{$_} and not
				$parsed.hash.{$_}
		}
		@lines.push( Q[{}:U: ] ~ @keys.gist );

		for $parsed.hash.keys {
			next unless $parsed.hash.{$_};
			@lines.push( qq{  {$_}:  } );
			@lines.append( dump-parsed( $parsed.hash.{$_} ) )
		}
	}
	if $parsed.list {
		my $i = 0;
		for $parsed.list {
			@lines.push( qq{  [$i]:  } );
			@lines.append( dump-parsed( $_ ) )
		}
	}

	my $indent-str = '  ';
	map { $indent-str ~ $_ }, @lines
}

sub dump( Mu $parsed ) {
	dump-parsed( $parsed ).join( "\n" )
}

role Node {
	has $.name;
	has @.child;
	has %.content;

#	method validate( Mu $parsed ) {...}

	method trace {
		say self.^name if $*TRACE
	}

	method new-term {
		self.^name ~ " has new (unknown) term!"
	}

	method debug( Mu $parsed ) {
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

		die "Unknown type" unless @types;

		@lines.push( @types.gist );

		@lines.push( "\+: "    ~   $parsed.Int       ) if $parsed.Int;
		@lines.push( "\~: '"   ~   $parsed.Str ~ "'" ) if $parsed.Str;
		@lines.push( "\?: "    ~ ~?$parsed.Bool      ) if $parsed.Bool;
		if $parsed.list {
			for $parsed.list {
				@lines.push( "\[\]:\n" ~ $_.dump )
			}
			return;
		}
		elsif $parsed.hash() {
			@lines.push( "\{\} keys: " ~ $parsed.hash.keys );
			@lines.push( "\{\}:\n" ~   $parsed.dump );
		}

		@lines.push( "" );
		return @lines.join("\n");
	}

	method assert-Bool( Mu $parsed ) {
		return False if $parsed.hash;
		return False if $parsed.list;
		return False if $parsed.Int;
		return False if $parsed.Str;

		if $parsed.Bool {
			return True
		}
		die "Uncaught type"
	}

	# $parsed can only be Int, by extension Str, by extension Bool.
	#
	method assert-Int( Mu $parsed ) {
		return False if $parsed.hash;
		return False if $parsed.list;

		if $parsed.Int {
			return True
		}
		die "Uncaught type"
	}

	# $parsed can only be Str, by extension Bool
	#
	method assert-Str( Mu $parsed ) {
		return False if $parsed.hash;
		return False if $parsed.list;
		return False if $parsed.Int;

		if $parsed.Str {
			return True
		}
		die "Uncaught type"
	}

	method assert-hash-keys( Mu $parsed, $keys, $defined-keys = [] ) {
		if $parsed.hash {
			my @keys;
			my @defined-keys;
			for $parsed.hash.keys {
				if $parsed.hash.{$_} {
					@keys.push( $_ );
				}
				elsif $parsed.hash:defined{$_} {
					@defined-keys.push( $_ );
				}
			}

			if $parsed.hash.keys.elems >
				$keys.elems + $defined-keys.elems {
				warn "Too many keys " ~ @keys.gist ~
						       ", " ~
						       @defined-keys.gist;
				CONTROL { when CX::Warn { warn .message ~ "\n" ~ .backtrace.Str } }
				return False
			}
			
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
}

class _BinInt does Node {
	method new( Mu $parsed ) {
		self.trace;
		if $parsed.Str and
		   $parsed.Str eq '0' {
			return self.bless( :name( $parsed.Str ) )
		}
		if self.assert-Int( $parsed ) {
			return self.bless( :name( $parsed.Int ) )
		}
		die self.new-term
	}
	method validate( Mu $parsed ) {
		self.trace;
		return if $parsed.Str and $parsed.Str eq '0';
		return if self.assert-Int( $parsed );
		die self.new-term
	}
}

class _OctInt does Node {
	method new( Mu $parsed ) {
		self.trace;
		if $parsed.Str and
		   $parsed.Str eq '0' {
			return self.bless( :name( $parsed.Str ) )
		}
		if self.assert-Int( $parsed ) {
			return self.bless( :name( $parsed.Int ) )
		}
		die self.new-term
	}
	method validate( Mu $parsed ) {
		self.trace;
		return if $parsed.Str and $parsed.Str eq '0';
		return if self.assert-Int( $parsed );
		die self.new-term
	}
}

class _DecInt does Node {
	method new( Mu $parsed ) {
		self.trace;
		if $parsed.Str and
		   $parsed.Str eq '0' {
			return self.bless( :name( $parsed.Str ) )
		}
		if self.assert-Int( $parsed ) {
			return self.bless( :name( $parsed.Int ) )
		}
		die self.new-term
	}
	method validate( Mu $parsed ) {
		self.trace;
		return if $parsed.Str and $parsed.Str eq '0';
		return if self.assert-Int( $parsed );
		die self.new-term
	}
}

class _HexInt does Node {
	method new( Mu $parsed ) {
		self.trace;
		if $parsed.Str and
		   $parsed.Str eq '0' {
			return self.bless( :name( $parsed.Str ) )
		}
		if self.assert-Int( $parsed ) {
			return self.bless( :name( $parsed.Int ) )
		}
		die self.new-term
	}
	method validate( Mu $parsed ) {
		self.trace;
		return if $parsed.Str and $parsed.Str eq '0';
		return if self.assert-Int( $parsed );
		die self.new-term
	}
}

class _Coeff does Node {
	method new( Mu $parsed ) {
		self.trace;
		if $parsed.Str and
		   ( $parsed.Str eq '0.0' or
		     $parsed.Str eq '0' ) {
			return self.bless( :name( $parsed.Str ) )
		}
		if self.assert-Int( $parsed ) {
			return self.bless( :name( $parsed.Int ) )
		}
		die self.new-term
	}
	method validate( Mu $parsed ) {
		self.trace;
		return if $parsed.Str and
		   ( $parsed.Str eq '0.0' or
		     $parsed.Str eq '0' );
		return if self.assert-Int( $parsed );
		die self.new-term
	}
}

class _Frac does Node {
	method new( Mu $parsed ) {
		self.trace;
		if $parsed.Str and
		   $parsed.Str eq '0' {
			return self.bless( :name( $parsed.Str ) )
		}
		if self.assert-Int( $parsed ) {
			return self.bless( :name( $parsed.Int ) )
		}
		die self.new-term
	}
	method validate( Mu $parsed ) {
		self.trace;
		return if $parsed.Str and $parsed.Str eq '0';
		return if self.assert-Int( $parsed );
		die self.new-term
	}
}

class _Radix does Node {
	method new( Mu $parsed ) {
		self.trace;
		if self.assert-Int( $parsed ) {
			return self.bless( :name( $parsed.Int ) )
		}
		die self.new-term
	}
	method validate( Mu $parsed ) {
		self.trace;
		return if self.assert-Int( $parsed );
		die self.new-term
	}
}

class _Int does Node {
	method new( Mu $parsed ) {
		self.trace;
		if $parsed.Str and
		   $parsed.Str eq '0' {
			return self.bless( :name( $parsed.Str ) )
		}
		if self.assert-Int( $parsed ) {
			return self.bless( :name( $parsed.Int ) )
		}
		die self.new-term
	}
	method validate( Mu $parsed ) {
		self.trace;
		return if $parsed.Str and $parsed.Str eq '0';
		return if self.assert-Int( $parsed );
		die self.new-term
	}
}

class _Key does Node {
	method new( Mu $parsed ) {
		self.trace;
		if self.assert-Str( $parsed ) {
			return self.bless( :name( $parsed.Str ) )
		}
		die self.new-term
	}
	method validate( Mu $parsed ) {
		self.trace;
		return if self.assert-Str( $parsed );
		die self.new-term
	}
}

class _NormSpace does Node {
	method new( Mu $parsed ) {
		self.trace;
		if self.assert-Str( $parsed ) {
			return self.bless( :name( $parsed.Str ) )
		}
		die self.new-term
	}
	method validate( Mu $parsed ) {
		self.trace;
		return if self.assert-Str( $parsed );
		die self.new-term
	}
}

class _Sigil does Node {
	method new( Mu $parsed ) {
		self.trace;
		if self.assert-Str( $parsed ) {
			return self.bless( :name( $parsed.Str ) )
		}
		die self.new-term
	}
	method validate( Mu $parsed ) {
		self.trace;
		return if self.assert-Str( $parsed );
		die self.new-term
	}
}

class _VALUE does Node {
	method new( Mu $parsed ) {
		self.trace;
		if $parsed.Str and
		   $parsed.Str eq '0' {
			return self.bless( :name( $parsed.Str ) )
		}
		if self.assert-Int( $parsed ) {
			return self.bless( :name( $parsed.Int ) )
		}
		die self.new-term
	}
	method validate( Mu $parsed ) {
		self.trace;
		return if $parsed.Str and $parsed.Str eq '0';
		return if self.assert-Int( $parsed );
		die self.new-term
	}
}

class _Sym does Node {
	method new( Mu $parsed ) {
		self.trace;
		CATCH {
			when X::Hash::Store::OddNumber { }
			when X::Multi::NoMatch { }
		}
		if $parsed.Bool and		# XXX Huh?
		   $parsed.Str eq '+' {
			return self.bless( :name( $parsed.Str ) )
		}
		if $parsed.Bool and		# XXX Huh?
		   $parsed.Str eq '' {
			return self.bless( :name( $parsed.Str ) )
		}
		if self.assert-Str( $parsed ) {
			return self.bless( :name( $parsed.Str ) )
		}
		die self.new-term
	}
	method validate( Mu $parsed ) {
		self.trace;
		CATCH {
			when X::Hash::Store::OddNumber { }
			when X::Multi::NoMatch { }
		}
		return if $parsed.Bool and $parsed.Str eq '+';
		return if $parsed.Bool and $parsed.Str eq '';
		return if self.assert-Str( $parsed );
		die self.new-term
	}
}

class _Sign does Node {
	method new( Mu $parsed ) {
		self.trace;
		if self.assert-Bool( $parsed ) {
			return self.bless( :name( $parsed.Bool ) )
		}
		die self.new-term
	}
	method validate( Mu $parsed ) {
		self.trace;
		return if self.assert-Bool( $parsed );
		die self.new-term
	}
}

class _EScale does Node {
	method new( Mu $parsed ) {
		self.trace;
		if self.assert-hash-keys( $parsed, [< sign decint >] ) {
			return self.bless(
				:content(
					:sign(
						_Sign.new(
							$parsed.hash.<sign>
						)
					),
					:decint(
						_DecInt.new(
							$parsed.hash.<decint>
						)
					)
				)
			)
		}
		die self.new-term
	}
	method validate( Mu $parsed ) {
		self.trace;
		return if self.assert-hash-keys( $parsed, [< sign decint >] )
			and _Sign.new.validate( $parsed.hash.<sign> )
			and _DecInt.new.validate( $parsed.hash.<decint> );
		die self.new-term
	}
}

class _Integer does Node {
	method new( Mu $parsed ) {
		self.trace;
		if self.assert-hash-keys( $parsed, [< decint VALUE >] ) {
			return self.bless(
				:content(
					:decint(
						_DecInt.new(
							$parsed.hash.<decint>
						)
					),
					:VALUE(
						_VALUE.new(
							$parsed.hash.<VALUE>
						)
					)
				)
			)
		}
		if self.assert-hash-keys( $parsed, [< binint VALUE >] ) {
			return self.bless(
				:content(
					:binint(
						_BinInt.new(
							$parsed.hash.<binint>
						)
					),
					:VALUE(
						_VALUE.new(
							$parsed.hash.<VALUE>
						)
					)
				)
			)
		}
		if self.assert-hash-keys( $parsed, [< octint VALUE >] ) {
			return self.bless(
				:content(
					:octint(
						_OctInt.new(
							$parsed.hash.<octint>
						)
					),
					:VALUE(
						_VALUE.new(
							$parsed.hash.<VALUE>
						)
					)
				)
			)
		}
		if self.assert-hash-keys( $parsed, [< hexint VALUE >] ) {
			return self.bless(
				:content(
					:hexint(
						_HexInt.new(
							$parsed.hash.<hexint>
						)
					),
					:VALUE(
						_VALUE.new(
							$parsed.hash.<VALUE>
						)
					)
				)
			)
		}
		die self.new-term
	}
	method validate( Mu $parsed ) {
		self.trace;
		return if self.assert-hash-keys( $parsed, [< decint VALUE >] )
			and _DecInt.new.validate( $parsed.hash.<decint> )
			and _VALUE.new( $parsed.hash.<VALUE> );
		return if self.assert-hash-keys( $parsed, [< binint VALUE >] )
			and _BinInt.new.validate( $parsed.hash.<binint> )
			and _VALUE.new( $parsed.hash.<VALUE> );
		return if self.assert-hash-keys( $parsed, [< octint VALUE >] )
			and _OctInt.new.validate( $parsed.hash.<octint> )
			and _VALUE.new( $parsed.hash.<VALUE> );
		return if self.assert-hash-keys( $parsed, [< hexint VALUE >] )
			and _HexInt.new.validate( $parsed.hash.<hexint> )
			and _VALUE.new( $parsed.hash.<VALUE> );
		die self.new-term
	}
}

class _BackSlash does Node {
	method new( Mu $parsed ) {
		self.trace;
		if self.assert-hash-keys( $parsed, [< sym >] ) {
			return self.bless(
				:content(
					:sym(
						_Sym.new(
							$parsed.hash.<sym>
						)
					)
				)
			)
		}
		die self.new-term
	}
	method validate( Mu $parsed ) {
		self.trace;
		return if self.assert-hash-keys( $parsed, [< sym >] )
			and _Sym.new( $parsed.hash.<sym> );
		die self.new-term
	}
}

class _VStr does Node {
	method new( Mu $parsed ) {
		self.trace;
		if $parsed.Int {
			return self.bless( :name( $parsed.Int ) )
		}
		die self.new-term
	}
	method validate( Mu $parsed ) {
		self.trace;
		return if $parsed.Int;
		die self.new-term
	}
}

class _VNum does Node {
	method new( Mu $parsed ) {
		self.trace;
		if $parsed.list {
			return self.bless( :child() )
		}
		die self.new-term
	}
	method validate( Mu $parsed ) {
		self.trace;
		return if $parsed.list;
		die self.new-term
	}
}

class _Version does Node {
	method new( Mu $parsed ) {
		self.trace;
		if self.assert-hash-keys( $parsed, [< vnum vstr >] ) {
			return self.bless(
				:content(
					:vnum(
						_VNum.new(
							$parsed.hash.<vnum>
						)
					),
					:vstr(
						_VStr.new(
							$parsed.hash.<vstr>
						)
					)
				)
			)
		}
		die self.new-term
	}
	method validate( Mu $parsed ) {
		self.trace;
		return if self.assert-hash-keys( $parsed, [< vnum vstr >] )
			and _VNum.new.validate( $parsed.hash.<vnum> )
			and _VStr.new.validate( $parsed.hash.<vstr> );
		die self.new-term
	}
}

class _Doc does Node {
	method new( Mu $parsed ) {
		self.trace;
		if self.assert-Bool( $parsed ) {
			return self.bless( :name( $parsed.Bool ) )
		}
		die self.new-term
	}
	method validate( Mu $parsed ) {
		self.trace;
		return if self.assert-Bool( $parsed );
		die self.new-term
	}
}

class _Identifier does Node {
	method new( Mu $parsed ) {
		self.trace;
		if $parsed.list {
			my @child;
			for $parsed.list {
				if self.assert-Str( $_ ) {
					@child.push(
						$_.Str
					);
					next
				}
				die self.new-term
			}
			return self.bless(
				:child( @child )
			)
		}
		elsif $parsed.Str {
			return self.bless( :name( $parsed.Str ) )
		}
		die self.new-term
	}
	method validate( Mu $parsed ) {
		self.trace;
		if $parsed.list {
			for $parsed.list {
				next if self.assert-Str( $_ );
				die self.new-term
			}
			return 
		}
		elsif $parsed.Str {
			return
		}
		die self.new-term
	}
}

class _Name does Node {
	method new( Mu $parsed ) {
		self.trace;
		if self.assert-hash-keys( $parsed,
			[< param_var type_constraint quant >],
			[< default_value modifier trait post_constraint >] ) {
			return self.bless(
				:content(
					:param_var(
						_ParamVar.new(
							$parsed.hash.<param_var>
						)
					),
					:type_constraint(
						_TypeConstraint.new(
							$parsed.hash.<type_constraint>
						)
					),
					:quant(
						_Quant.new(
							$parsed.hash.<quant>
						)
					),
					:default_value(),
					:modifier(),
					:trait(),
					:post_constraint()
				)
			)
		}
		if self.assert-hash-keys( $parsed, [< identifier >],
						   [< morename >] ) {
			return self.bless(
				:content(
					:identifier(
						_Identifier.new(
							$parsed.hash.<identifier>
						)
					),
					:morename()
				),
				:child()
			)
		}
		if self.assert-Str( $parsed ) {
			return self.bless( :name( $parsed.Str ) )
		}
		die self.new-term
	}
	method validate( Mu $parsed ) {
		self.trace;
		return if self.assert-hash-keys( $parsed,
			[< param_var type_constraint quant >],
			[< default_value modifier trait post_constraint >] )
			and _ParamVar.new.validate( $parsed.hash.<param_var> )
			and _TypeConstraint.new.validate( $parsed.hash.<type_constraint> )
			and _Quant.new( $parsed.hash.<quant> );
		return if self.assert-hash-keys( $parsed, [< identifier >],
						   [< morename >] )
			and _Identifier.new.validate( $parsed.hash.<identifier> );
		return if self.assert-Str( $parsed );
		die self.new-term
	}
}

class _LongName does Node {
	method new( Mu $parsed ) {
		self.trace;
		if $parsed {
			if self.assert-hash-keys( $parsed,
						  [< name >],
						  [< colonpair >] ) {
				return self.bless(
					:content(
						:name(
							_Name.new(
								$parsed.hash.<name>
							)
						),
						:colonpair()
					)
				)
			}
		}
		else {
			return self.bless
		}
		die self.new-term
	}
	method validate( Mu $parsed ) {
		self.trace;
		if $parsed {
			return if self.assert-hash-keys( $parsed,
						  [< name >],
						  [< colonpair >] )
				and _Name.new.validate( $parsed.hash.<name> );
		}
		else {
			# XXX Hardly seems fair this way, doesn't it?
			return
		}
		die self.new-term
	}
}

class _ModuleName does Node {
	method new( Mu $parsed ) {
		self.trace;
		if self.assert-hash-keys( $parsed, [< longname >] ) {
			return self.bless(
				:content(
					:longname(
						_LongName.new(
							$parsed.hash.<longname>
						)
					)
				)
			)
		}
		die self.new-term
	}
	method validate( Mu $parsed ) {
		self.trace;
		return if self.assert-hash-keys( $parsed, [< longname >] )
			and _LongName.new.validate( $parsed.hash.<longname> );
		die self.new-term
	}
}

class _CodeBlock does Node {
	method new( Mu $parsed ) {
		self.trace;
		if self.assert-hash-keys( $parsed, [< block >] ) {
			return self.bless(
				:content(
					:block(
						_Block.new(
							$parsed.hash.<block>
						)
					)
				)
			)
		}
		die self.new-term
	}
	method validate( Mu $parsed ) {
		self.trace;
		return if self.assert-hash-keys( $parsed, [< block >] )
			and _Block.new.validate( $parsed.hash.<block> );
		die self.new-term
	}
}

class _XBlock does Node {
	method new( Mu $parsed ) {
		self.trace;
		CATCH {
			when X::Hash::Store::OddNumber { }
			when X::Multi::NoMatch { }
		}
		if self.assert-hash-keys( $parsed, [< pblock EXPR >] ) {
			return self.bless(
				:content(
					:pblock(
						_PBlock.new(
							$parsed.hash.<pblock>
						)
					),
					:EXPR(
						_EXPR.new(
							$parsed.hash.<EXPR>
						)
					)
				)
			)
		}
		if self.assert-hash-keys( $parsed, [< blockoid >] ) {
			return self.bless(
				:content(
					:blockoid(
						_Blockoid.new(
							$parsed.hash.<blockoid>
						)
					)
				)
			)
		}
		die self.new-term
	}
	method validate( Mu $parsed ) {
		self.trace;
		CATCH {
			when X::Hash::Store::OddNumber { }
			when X::Multi::NoMatch { }
		}
		return if self.assert-hash-keys( $parsed, [< pblock EXPR >] )
			and _PBlock.new.validate( $parsed.hash.<pblock> )
			and _EXPR.new.validate( $parsed.hash.<EXPR> );
		return if self.assert-hash-keys( $parsed, [< blockoid >] )
			and _Blockoid.new.validate( $parsed.hash.<blockoid> );
		die self.new-term
	}
}

class _Block does Node {
	method new( Mu $parsed ) {
		self.trace;
		if self.assert-hash-keys( $parsed, [< blockoid >] ) {
			return self.bless(
				:content(
					:blockoid(
						_Blockoid.new(
							$parsed.hash.<blockoid>
						)
					)
				)
			)
		}
		die self.new-term
	}
	method validate( Mu $parsed ) {
		self.trace;
		return if self.assert-hash-keys( $parsed, [< blockoid >] )
			and _Blockoid.new.validate( $parsed.hash.<blockoid> );
		die self.new-term
	}
}

class _Blorst does Node {
	method new( Mu $parsed ) {
		self.trace;
		if self.assert-hash-keys( $parsed, [< statement >] ) {
			return self.bless(
				:content(
					:statement(
						_Statement.new(
							$parsed.hash.<statement>
						)
					)
				)
			)
		}
		if self.assert-hash-keys( $parsed, [< block >] ) {
			return self.bless(
				:content(
					:block(
						_Block.new(
							$parsed.hash.<block>
						)
					)
				)
			)
		}
		die self.new-term
	}
	method validate( Mu $parsed ) {
		self.trace;
		return if self.assert-hash-keys( $parsed, [< statement >] )
			and _Statement.new.validate( $parsed.hash.<statement> );
		return if self.assert-hash-keys( $parsed, [< block >] )
			and _Block.new( $parsed.hash.<block> );
		die self.new-term
	}
}

class _Else does Node {
	method new( Mu $parsed ) {
		self.trace;
		if self.assert-hash-keys( $parsed, [< sym blorst >] ) {
			return self.bless(
				:content(
					:sym(
						_Sym.new(
							$parsed.hash.<sym>
						)
					),
					:blorst(
						_Blorst.new(
							$parsed.hash.<blorst>
						)
					)
				)
			)
		}
		if self.assert-hash-keys( $parsed, [< blockoid >] ) {
			return self.bless(
				:content(
					:blockoid(
						_Blockoid.new(
							$parsed.hash.<blockoid>
						)
					)
				)
			)
		}
		die self.new-term
	}
	method validate( Mu $parsed ) {
		self.trace;
		return if self.assert-hash-keys( $parsed, [< sym blorst >] )
			and _Sym.new.validate( $parsed.hash.<sym> )
			and _Blorst.new.validate( $parsed.hash.<blorst> );
		return if self.assert-hash-keys( $parsed, [< blockoid >] )
			and _Blockoid.new( $parsed.hash.<blockoid> );
		die self.new-term
	}
}

class _StatementPrefix does Node {
	method new( Mu $parsed ) {
		self.trace;
		if self.assert-hash-keys( $parsed, [< sym blorst >] ) {
			return self.bless(
				:content(
					:sym(
						_Sym.new(
							$parsed.hash.<sym>
						)
					),
					:blorst(
						_Blorst.new(
							$parsed.hash.<blorst>
						)
					)
				)
			)
		}
		die self.new-term
	}
	method validate( Mu $parsed ) {
		self.trace;
		return if self.assert-hash-keys( $parsed, [< sym blorst >] )
			and _Sym.new.validate( $parsed.hash.<sym> )
			and _Blorst.new.validate( $parsed.hash.<blorst> );
		die self.new-term
	}
}

class _E1 does Node {
	method new( Mu $parsed ) {
		self.trace;
		if self.assert-hash-keys( $parsed, [< scope_declarator >] ) {
			return self.bless(
				:content(
					:scope_declarator(
						_ScopeDeclarator.new(
							$parsed.hash.<scope_declarator>
						)
					)
				)
			)
		}
		die self.new-term
	}
	method validate( Mu $parsed ) {
		self.trace;
		return if self.assert-hash-keys( $parsed, [< scope_declarator >] )
			and _ScopeDeclarator.new.validate( $parsed.hash.<scope_declarator> );
		die self.new-term
	}
}

class _E2 does Node {
	method new( Mu $parsed ) {
		self.trace;
		die self.new-term
	}
	method validate( Mu $parsed ) {
		self.trace;
		die self.new-term
	}
}

class _E3 does Node {
	method new( Mu $parsed ) {
		self.trace;
		die self.new-term
	}
	method validate( Mu $parsed ) {
		self.trace;
		die self.new-term
	}
}

class _Wu does Node {
	method new( Mu $parsed ) {
		self.trace;
		if self.assert-Str( $parsed ) {
			return self.bless( :naem( $parsed.Str ) )
		}
		die self.new-term
	}
	method validate( Mu $parsed ) {
		self.trace;
		return if self.assert-Str( $parsed );
		die self.new-term
	}
}

class _StatementControl does Node {
	method new( Mu $parsed ) {
		self.trace;
		if self.assert-hash-keys( $parsed, [< block sym e1 e2 e3 >] ) {
			return self.bless(
				:content(
					:block(
						_Block.new(
							$parsed.hash.<block>
						)
					),
					:sym(
						_Sym.new(
							$parsed.hash.<sym>
						)
					),
					:e1(
						_E1.new(
							$parsed.hash.<e1>
						)
					),
#					:e2(
#						_E2.new(
#							$parsed.hash.<e2>
#						)
#					),
#					:e3(
#						_E3.new(
#							$parsed.hash.<e3>
#						)
#					)
				)
			)
		}
		if self.assert-hash-keys( $parsed, [< doc sym module_name >] ) {
			return self.bless(
				:content(
					:doc(
						_Doc.new(
							$parsed.hash.<doc>
						)
					),
					:sym(
						_Sym.new(
							$parsed.hash.<sym>
						)
					),
					:module_name(
						_ModuleName.new(
							$parsed.hash.<module_name>
						)
					)
				)
			)
		}
		if self.assert-hash-keys( $parsed, [< doc sym version >] ) {
			return self.bless(
				:content(
					:doc(
						_Doc.new(
							$parsed.hash.<doc>
						)
					),
					:sym(
						_Sym.new(
							$parsed.hash.<sym>
						)
					),
					:version(
						_Version.new(
							$parsed.hash.<version>
						)
					)
				)
			)
		}
		if self.assert-hash-keys( $parsed, [< xblock else sym >] ) {
			return self.bless(
				:content(
					:xblock(
						_XBlock.new(
							$parsed.hash.<xblock>
						)
					),
					:else(
						_Else.new(
							$parsed.hash.<else>
						)
					),
					:sym(
						_Sym.new(
							$parsed.hash.<sym>
						)
					)
				)
			)
		}
		if self.assert-hash-keys( $parsed, [< xblock sym wu >] ) {
			return self.bless(
				:content(
					:xblock(
						_XBlock.new(
							$parsed.hash.<xblock>
						)
					),
					:sym(
						_Sym.new(
							$parsed.hash.<sym>
						)
					),
					:wu(
						_Wu.new(
							$parsed.hash.<wu>
						)
					)
				)
			)
		}
		if self.assert-hash-keys( $parsed, [< xblock sym >] ) {
			return self.bless(
				:content(
					:xblock(
						_XBlock.new(
							$parsed.hash.<xblock>
						)
					),
					:sym(
						_Sym.new(
							$parsed.hash.<sym>
						)
					)
				)
			)
		}
		if self.assert-hash-keys( $parsed, [< block sym >] ) {
			return self.bless(
				:content(
					:block(
						_Block.new(
							$parsed.hash.<block>
						)
					),
					:sym(
						_Sym.new(
							$parsed.hash.<sym>
						)
					)
				)
			)
		}
		die self.new-term
	}
	method validate( Mu $parsed ) {
		self.trace;
		return if self.assert-hash-keys( $parsed, [< block sym e1 e2 e3 >] )
			and _Block.new.validate( $parsed.hash.<block> )
			and _Sym.new.validate( $parsed.hash.<sym> )
			and _E1.new.validate( $parsed.hash.<e1> )
			and _E2.new.validate( $parsed.hash.<e2> )
			and _E3.new.validate( $parsed.hash.<e3> );
		return if self.assert-hash-keys( $parsed, [< doc sym module_name >] )
			and _Doc.new.validate( $parsed.hash.<doc> )
			and _Sym.new.validate( $parsed.hash.<sym> )
			and _ModuleName.new.validate( $parsed.hash.<modulename> );
		return if self.assert-hash-keys( $parsed, [< doc sym version >] )
			and _Doc.new.validate( $parsed.hash.<doc> )
			and _Sym.new.validate( $parsed.hash.<sym> )
			and _Version.new.validate( $parsed.hash.<version> );
		return if self.assert-hash-keys( $parsed, [< xblock else sym >] )
			and _XBlock.new.validate( $parsed.hash.<xblock> )
			and _Else.new.validate( $parsed.hash.<else> )
			and _Sym.new.validate( $parsed.hash.<sym> );
		return if self.assert-hash-keys( $parsed, [< xblock sym wu >] )
			and _XBlock.new.validate( $parsed.hash.<xblock> )
			and _Sym.new.validate( $parsed.hash.<sym> )
			and _Wu.new.validate( $parsed.hash.<wu> );
		return if self.assert-hash-keys( $parsed, [< xblock sym >] )
			and _XBlock.new.validate( $parsed.hash.<xblock> )
			and _Sym.new.validate( $parsed.hash.<sym> );
		return if self.assert-hash-keys( $parsed, [< block sym >] )
			and _Block.new.validate( $parsed.hash.<block> )
			and _Sym.new.validate( $parsed.hash.<sym> );
		die self.new-term
	}
}

class _O does Node {
	method new( Mu $parsed ) {
		self.trace;
		# XXX There has to be a better way to handle this NoMatch case
		CATCH { when X::Multi::NoMatch { } }
		if $parsed ~~ Hash {
			if $parsed.<prec> and
			   $parsed.<fiddly> and
			   $parsed.<dba> and
			   $parsed.<assoc> {
				return self.bless(
					:content(
						:prec( $parsed.<prec> ),
						:fiddly( $parsed.<fiddly> ),
						:dba( $parsed.<dba> ),
						:assoc( $parsed.<assoc> )
					)
				)
			}
			if $parsed.<prec> and
			   $parsed.<dba> and
			   $parsed.<assoc> {
				return self.bless(
					:content(
						:prec( $parsed.<prec> ),
						:dba( $parsed.<dba> ),
						:assoc( $parsed.<assoc> )
					)
				)
			}
		}
		die self.new-term
	}
	method validate( Mu $parsed ) {
		self.trace;
		# XXX There has to be a better way to handle this NoMatch case
		CATCH { when X::Multi::NoMatch { } }
		if $parsed ~~ Hash {
			return if $parsed.<prec>
				and $parsed.<fiddly>
				and $parsed.<dba>
				and $parsed.<assoc>;
			return if $parsed.<prec>
				and $parsed.<dba>
				and $parsed.<assoc>;
		}
		die self.new-term
	}
}

class _Postfix does Node {
	method new( Mu $parsed ) {
		self.trace;
		if self.assert-hash-keys( $parsed, [< sym O >] ) {
			return self.bless(
				:content(
					:sym(
						_Sym.new(
							$parsed.hash.<sym>
						)
					),
					:O(
						_O.new(
							$parsed.hash.<O>
						)
					)
				)
			)
		}
		die self.new-term
	}
	method validate( Mu $parsed ) {
		self.trace;
		return if self.assert-hash-keys( $parsed, [< sym O >] )
			and _Sym.new.validate( $parsed.hash.<sym> )
			and _O.new.validate( $parsed.hash.<O> );
		die self.new-term
	}
}

class _Prefix does Node {
	method new( Mu $parsed ) {
		self.trace;
		if self.assert-hash-keys( $parsed, [< sym O >] ) {
			return self.bless(
				:content(
					:sym(
						_Sym.new(
							$parsed.hash.<sym>
						)
					),
					:O(
						_O.new(
							$parsed.hash.<O>
						)
					)
				)
			)
		}
		die self.new-term
	}
	method validate( Mu $parsed ) {
		self.trace;
		return if self.assert-hash-keys( $parsed, [< sym O >] )
			and _Sym.new.validate( $parsed.hash.<sym> )
			and _O.new.validate( $parsed.hash.<O> );
		die self.new-term
	}
}

class _Args does Node {
	method new( Mu $parsed ) {
		self.trace;
		if $parsed.Bool {
			return self.bless( :name( $parsed.Bool ) )
		}
		die self.new-term
	}
	method validate( Mu $parsed ) {
		self.trace;
		return if $parsed.Bool;
		die self.new-term
	}
}

class _MethodOp does Node {
	method new( Mu $parsed ) {
		self.trace;
		if self.assert-hash-keys( $parsed, [< longname args >] ) {
			return self.bless(
				:content(
					:longname(
						_LongName.new(
							$parsed.hash.<longname>
						)
					),
					:args(
						_Args.new(
							$parsed.hash.<args>
						)
					)
				)
			)
		}
		if self.assert-hash-keys( $parsed, [< variable >] ) {
			return self.bless(
				:content(
					:variable(
						_Variable.new(
							$parsed.hash.<variable>
						)
					)
				)
			)
		}
		if self.assert-hash-keys( $parsed, [< longname >] ) {
			return self.bless(
				:content(
					:longname(
						_LongName.new(
							$parsed.hash.<longname>
						)
					)
				)
			)
		}
		die dump( $parsed );
	}
	method validate( Mu $parsed ) {
		self.trace;
		return if self.assert-hash-keys( $parsed, [< longname args >] )
			and _LongName.new.validate( $parsed.hash.<longname> )
			and _Args.new.validate( $parsed.hash.<args> );
		return if self.assert-hash-keys( $parsed, [< variable >] )
			and _Variable.new.validate( $parsed.hash.<variable> );
		return if self.assert-hash-keys( $parsed, [< longname >] )
			and _LongName.new.validate( $parsed.hash.<longname> );
		die dump( $parsed );
	}
}

class _ArgList does Node {
	method new( Mu $parsed ) {
		self.trace;
		if self.assert-hash-keys( $parsed, [< EXPR >] ) {
			return self.bless(
				:content(
					:EXPR(
						_EXPR.new(
							$parsed.hash.<EXPR>
						)
					)
				)
			)
		}
		if self.assert-Bool( $parsed ) {
			return self.bless( :name( $parsed.Bool ) )
		}
		die self.new-term
	}
	method validate( Mu $parsed ) {
		self.trace;
		return if self.assert-hash-keys( $parsed, [< EXPR >] )
			and _EXPR.new.validate( $parsed.hash.<EXPR> );
		return if self.assert-Bool( $parsed );
		die self.new-term
	}
}

class _PostCircumfix_OPER does Node {
	method new( Mu $parsed ) {
		self.trace;
		if self.assert-hash-keys( $parsed,
				     [< postcircumfix OPER >],
				     [< postfix_prefix_meta_operator >] ) {
			return self.bless(
				:content(
					:postcircumfix(
						_PostCircumfix.new(
							$parsed.hash.<postcircumfix>
						)
					),
					:OPER(
						_OPER.new(
							$parsed.hash.<OPER>
						)
					),
					:postfix_prefix_meta_operator()
				)
			)
		}
		die self.new-term
	}
	method validate( Mu $parsed ) {
		self.trace;
		return if self.assert-hash-keys( $parsed,
				     [< postcircumfix OPER >],
				     [< postfix_prefix_meta_operator >] )
			and _PostCircumfix.new.validate( $parsed.hash.<postcircumfix> )
			and _OPER.new( $parsed.hash.<OPER> );
		die self.new-term
	}
}

class _PostCircumfix does Node {
	method new( Mu $parsed ) {
		self.trace;
		if self.assert-hash-keys( $parsed, [< nibble O >] ) {
			return self.bless(
				:content(
					:nibble(
						_Nibble.new(
							$parsed.hash.<nibble>
						)
					),
					:O(
						_O.new(
							$parsed.hash.<O>
						)
					)
				)
			)
		}
		if self.assert-hash-keys( $parsed, [< semilist O >] ) {
			return self.bless(
				:content(
					:semilist(
						_SemiList.new(
							$parsed.hash.<semilist>
						)
					),
					:O(
						_O.new(
							$parsed.hash.<O>
						)
					)
				)
			)
		}
		if self.assert-hash-keys( $parsed, [< arglist O >] ) {
			return self.bless(
				:content(
					:arglist(
						_ArgList.new(
							$parsed.hash.<arglist>
						)
					),
					:O(
						_O.new(
							$parsed.hash.<O>
						)
					)
				)
			)
		}
		die self.new-term
	}
	method validate( Mu $parsed ) {
		self.trace;
		return if self.assert-hash-keys( $parsed, [< nibble O >] )
			and _Nibble.new.validate( $parsed.hash.<nibble> )
			and _O.new.validate( $parsed.hash.<O> );
		return if self.assert-hash-keys( $parsed, [< semilist O >] )
			and _SemiList.new.validate( $parsed.hash.<semilist> )
			and _O.new.validate( $parsed.hash.<O> );
		return if self.assert-hash-keys( $parsed, [< arglist O >] )
			and _ArgList.new.validate( $parsed.hash.<arglist> )
			and _O.new.validate( $parsed.hash.<O> );
		die self.new-term
	}
}

class _PostOp does Node {
	method new( Mu $parsed ) {
		self.trace;
		if self.assert-hash-keys( $parsed, [< sym postcircumfix O >] ) {
			return self.bless(
				:content(
					:sym(
						_Sym.new(
							$parsed.hash.<sym>
						)
					),
					:postcircumfix(
						_PostCircumfix.new(
							$parsed.hash.<postcircumfix>
						)
					),
					:O(
						_O.new(
							$parsed.hash.<O>
						)
					)
				)
			)
		}
		die self.new-term
	}
	method validate( Mu $parsed ) {
		self.trace;
		return if self.assert-hash-keys( $parsed, [< sym postcircumfix O >] )
			and _Sym.new.validate( $parsed.hash.<sym> )
			and _PostCircumfix.new.validate( $parsed.hash.<postcircumfix> )
			and _O.new.validate( $parsed.hash.<O> );
			
		die self.new-term
	}
}

class _Circumfix does Node {
	method new( Mu $parsed ) {
		self.trace;
		if self.assert-hash-keys( $parsed, [< nibble >] ) {
			return self.bless(
				:content(
					:nibble(
						_Nibble.new(
							$parsed.hash.<nibble>
						)
					)
				)
			)
		}
		if self.assert-hash-keys( $parsed, [< pblock >] ) {
			return self.bless(
				:content(
					:pblock(
						_PBlock.new(
							$parsed.hash.<pblock>
						)
					)
				)
			)
		}
		if self.assert-hash-keys( $parsed, [< semilist >] ) {
			return self.bless(
				:content(
					:semilist(
						_SemiList.new(
							$parsed.hash.<semilist>
						)
					)
				)
			)
		}
		if self.assert-hash-keys( $parsed, [< binint VALUE >] ) {
			return self.bless(
				:content(
					:binint(
						_BinInt.new(
							$parsed.hash.<binint>
						)
					),
					:VALUE(
						_VALUE.new(
							$parsed.hash.<VALUE>
						)
					)
				)
			)
		}
		if self.assert-hash-keys( $parsed, [< octint VALUE >] ) {
			return self.bless(
				:content(
					:octint(
						_OctInt.new(
							$parsed.hash.<octint>
						)
					),
					:VALUE(
						_VALUE.new(
							$parsed.hash.<VALUE>
						)
					)
				)
			)
		}
		if self.assert-hash-keys( $parsed, [< hexint VALUE >] ) {
			return self.bless(
				:content(
					:hexint(
						_HexInt.new(
							$parsed.hash.<hexint>
						)
					),
					:VALUE(
						_VALUE.new(
							$parsed.hash.<VALUE>
						)
					)
				)
			)
		}
		die self.new-term
	}
}

class _FakeSignature does Node {
	method new( Mu $parsed ) {
		self.trace;
		if self.assert-hash-keys( $parsed, [< signature >] ) {
			return self.bless(
				:content(
					:signature(
						_Signature.new(
							$parsed.hash.<signature>
						)
					)
				)
			)
		}
		die self.new-term
	}
}

class _Var does Node {
	method new( Mu $parsed ) {
		self.trace;
		if self.assert-hash-keys( $parsed, [< sigil desigilname >] ) {
			return self.bless(
				:content(
					:sigil(
						_Sigil.new(
							$parsed.hash.<sigil>
						)
					),
					:desigilname(
						_DeSigilName.new(
							$parsed.hash.<desigilname>
						)
					)
				)
			)
		}
		if self.assert-hash-keys( $parsed, [< variable >] ) {
			return self.bless(
				:content(
					:variable(
						_Variable.new(
							$parsed.hash.<variable>
						)
					)
				)
			)
		}
		die self.new-term
	}
}

class _Lambda does Node {
	method new( Mu $parsed ) {
		self.trace;
		if self.assert-Str( $parsed ) {
			return self.bless( :name( $parsed.Str ) )
		}
		die self.new-term
	}
}

class _PBlock does Node {
	method new( Mu $parsed ) {
		self.trace;
		if self.assert-hash-keys( $parsed,
				     [< lambda blockoid signature >] ) {
			return self.bless(
				:content(
					:lambda(
						_Lambda.new(
							$parsed.hash.<lambda>
						)
					),
					:blockoid(
						_Blockoid.new(
							$parsed.hash.<blockoid>
						)
					),
					:signature(
						_Signature.new(
							$parsed.hash.<signature>
						)
					),
				)
			)
		}
		if self.assert-hash-keys( $parsed, [< blockoid >] ) {
			return self.bless(
				:content(
					:blockoid(
						_Blockoid.new(
							$parsed.hash.<blockoid>
						)
					)
				)
			)
		}
		die self.new-term
	}
}

class _ColonCircumfix does Node {
	method new( Mu $parsed ) {
		self.trace;
		if self.assert-hash-keys( $parsed, [< circumfix >] ) {
			return self.bless(
				:content(
					:circumfix(
						_Circumfix.new(
							$parsed.hash.<circumfix>
						)
					)
				)
			)
		}
		die self.new-term
	}
}

class _ColonPair does Node {
	method new( Mu $parsed ) {
		self.trace;
		if self.assert-hash-keys( $parsed,
				     [< identifier coloncircumfix >] ) {
			return self.bless(
				:content(
					:identifier(
						_Identifier.new(
							$parsed.hash.<identifier>
						)
					),
					:coloncircumfix(
						_ColonCircumfix.new(
							$parsed.hash.<coloncircumfix>
						)
					)
				)
			)
		}
		if self.assert-hash-keys( $parsed, [< identifier >] ) {
			return self.bless(
				:content(
					:identifier(
						_Identifier.new(
							$parsed.hash.<identifier>
						)
					)
				)
			)
		}
		if self.assert-hash-keys( $parsed, [< fakesignature >] ) {
			return self.bless(
				:content(
					:fakesignature(
						_FakeSignature.new(
							$parsed.hash.<fakesignature>
						)
					)
				)
			)
		}
		if self.assert-hash-keys( $parsed, [< var >] ) {
			return self.bless(
				:content(
					:var(
						_Var.new(
							$parsed.hash.<var>
						)
					)
				)
			)
		}
		die self.new-term
	}
}

class _ColonPairs does Node {
	method new( Mu $parsed ) {
		self.trace;
		if $parsed {
		}
		else {
			return self.bless
		}
		die self.new-term
	}
}

class _DottyOp does Node {
	method new( Mu $parsed ) {
		self.trace;
		if self.assert-hash-keys( $parsed, [< sym postop O >] ) {
			return self.bless(
				:content(
					:sym(
						_Sym.new(
							$parsed.hash.<sym>
						)
					),
					:postop(
						_PostOp.new(
							$parsed.hash.<postop>
						)
					),
					:O(
						_O.new(
							$parsed.hash.<O>
						)
					)
				)
			)
		}
		if self.assert-hash-keys( $parsed, [< methodop >] ) {
			return self.bless(
				:content(
					:methodop(
						_MethodOp.new(
							$parsed.hash.<methodop>
						)
					)
				)
			)
		}
		if self.assert-hash-keys( $parsed, [< colonpair >] ) {
			return self.bless(
				:content(
					:colonpair(
						_ColonPair.new(
							$parsed.hash.<colonpair>
						)
					)
				)
			)
		}
		die self.new-term
	}
}

class _Dotty does Node {
	method new( Mu $parsed ) {
		self.trace;
		if self.assert-hash-keys( $parsed, [< sym dottyop O >] ) {
			return self.bless(
				:content(
					:sym(
						_Sym.new(
							$parsed.hash.<sym>
						)
					),
					:dottyop(
						_DottyOp.new(
							$parsed.hash.<dottyop>
						)
					),
					:O(
						_O.new(
							$parsed.hash.<O>
						)
					)
				)
			)
		}
		die self.new-term
	}
}

# XXX This is a compound type
class _Identifier_Args does Node {
	method new( Mu $parsed ) {
		self.trace;
		if self.assert-hash-keys( $parsed, [< identifier args >] ) {
			return self.bless(
				:content(
					:identifier(
						_Identifier.new(
							$parsed.hash.<identifier>
						)
					),
					:args(
						_Args.new(
							$parsed.hash.<args>
						)
					)
				)
			)
		}
		die self.new-term
	}
}

class _OPER does Node {
	method new( Mu $parsed ) {
		self.trace;
		if self.assert-hash-keys( $parsed, [< sym dottyop O >] ) {
			return self.bless(
				:content(
					:sym(
						_Sym.new(
							$parsed.hash.<sym>
						)
					),
					:dottyop(
						_DottyOp.new(
							$parsed.hash.<dottyop>
						)
					),
					:O(
						_O.new(
							$parsed.hash.<O>
						)
					)
				)
			)
		}
		if self.assert-hash-keys(
			$parsed,
			[< sym infixish O >] ) {
			return self.bless(
				:content(
					:sym(
						_Sym.new(
							$parsed.hash.<sym>
						)
					),
					:infixish(
						_InfixIsh.new(
							$parsed.hash.<infixish>
						)
					),
					:O(
						_O.new(
							$parsed.hash.<O>
						)
					)
				)
			)
		}
		if self.assert-hash-keys( $parsed, [< sym O >] ) {
			return self.bless(
				:content(
					:sym(
						_Sym.new(
							$parsed.hash.<sym>
						)
					),
					:O(
						_O.new(
							$parsed.hash.<O>
						)
					)
				)
			)
		}
		if self.assert-hash-keys( $parsed, [< EXPR O >] ) {
			return self.bless(
				:content(
					:EXPR(
						_EXPR.new(
							$parsed.hash.<EXPR>
						)
					),
					:O(
						_O.new(
							$parsed.hash.<O>
						)
					)
				)
			)
		}
		if self.assert-hash-keys( $parsed, [< semilist O >] ) {
			return self.bless(
				:content(
					:semilist(
						_SemiList.new(
							$parsed.hash.<semilist>)
					),
					:O(
						_O.new(
							$parsed.hash.<O>
						)
					)
				)
			)
		}
		if self.assert-hash-keys( $parsed, [< nibble O >] ) {
			return self.bless(
				:content(
					:nibble(
						_Nibble.new(
							$parsed.hash.<nibble>)
					),
					:O(
						_O.new(
							$parsed.hash.<O>
						)
					)
				)
			)
		}
		if self.assert-hash-keys( $parsed, [< arglist O >] ) {
			return self.bless(
				:content(
					:arglist(
						_ArgList.new(
							$parsed.hash.<arglist>
						)
					),
					:O(
						_O.new(
							$parsed.hash.<O>
						)
					)
				)
			)
		}
		if self.assert-hash-keys( $parsed, [< O >] ) {
			return self.bless(
				:content(
					:O(
						_O.new(
							$parsed.hash.<O>
						)
					)
				)
			)
		}
		die self.new-term
	}
}

class _Val does Node {
	method new( Mu $parsed ) {
		self.trace;
		if self.assert-hash-keys( $parsed, [< value >] ) {
			return self.bless(
				:content(
					:value(
						_Value.new(
							$parsed.hash.<value>
						)
					)
				)
			)
		}
		die self.new-term
	}
}

class _DefTerm does Node {
	method new( Mu $parsed ) {
		self.trace;
		if self.assert-hash-keys( $parsed, [< identifier colonpair >] ) {
			return self.bless(
				:content(
					:identifier(
						_Identifier.new(
							$parsed.hash.<identifier>
						)
					),
					:colonpair(
						_ColonPair.new(
							$parsed.hash.<colonpair>
						)
					)
				)
			)
		}
		if self.assert-hash-keys( $parsed, [< identifier >], [< colonpair >] ) {
			return self.bless(
				:content(
					:identifier(
						_Identifier.new(
							$parsed.hash.<identifier>
						)
					),
					:colonpair()
				)
			)
		}
		die self.new-term
	}
}

class _TypeDeclarator does Node {
	method new( Mu $parsed ) {
		self.trace;
		CATCH { when X::Multi::NoMatch { } }
		if self.assert-hash-keys( $parsed, [< sym initializer variable >],
					      [< trait >] ) {
			return self.bless(
				:content(
					:sym(
						_Sym.new(
							$parsed.hash.<sym>
						)
					),
					:initializer(
						_Initializer.new(
							$parsed.hash.<initializer>
						)
					),
					:variable(
						_Variable.new(
							$parsed.hash.<variable>
						)
					),
					:trait()
				)
			)
		}
		if self.assert-hash-keys( $parsed, [< sym initializer defterm >],
					      [< trait >] ) {
			return self.bless(
				:content(
					:sym(
						_Sym.new(
							$parsed.hash.<sym>
						)
					),
					:initializer(
						_Initializer.new(
							$parsed.hash.<initializer>
						)
					),
					:defterm(
						_DefTerm.new(
							$parsed.hash.<defterm>
						)
					),
					:trait()
				)
			)
		}
		if self.assert-hash-keys( $parsed, [< sym initializer >] ) {
			return self.bless(
				:content(
					:sym(
						_Sym.new(
							$parsed.hash.<sym>
						)
					),
					:initializer(
						_Initializer.new(
							$parsed.hash.<initializer>
						)
					)
				)
			)
		}
		die self.new-term
	}
}

class _FatArrow does Node {
	method new( Mu $parsed ) {
		self.trace;
		if self.assert-hash-keys( $parsed, [< val key >] ) {
			return self.bless(
				:content(
					:val(
						_Val.new(
							$parsed.hash.<val>
						)
					),
					:key(
						_Key.new(
							$parsed.hash.<key>
						)
					)
				)
			)
		}
		die self.new-term
	}
}

class _EXPR does Node {
	method new( Mu $parsed ) {
		self.trace;
		if $parsed.list {
			my @child;
			for $parsed.list {
				if self.assert-hash-keys( $_, [< OPER dotty >],
							 [< postfix_prefix_meta_operator >] ) {
					@child.push(
						_Dotty_OPER.new( $_ )
					);
					next
				}
				if self.assert-hash-keys( $_,
					[< postcircumfix OPER >],
					[< postfix_prefix_meta_operator >] ) {
					@child.push(
						_PostCircumfix_OPER.new( $_ )
					);
					next
				}
				if self.assert-hash-keys( $_, [< infix OPER >],
							 [< infix_postfix_meta_operator >] ) {
					@child.push(
						_Infix_OPER.new( $_ )
					);
					next
				}
				if self.assert-hash-keys( $_, [< prefix OPER >],
							 [< prefix_postfix_meta_operator >] ) {
					@child.push(
						_Prefix_OPER.new( $_ )
					);
					next
				}
				if self.assert-hash-keys( $_, [< postfix OPER >],
							 [< postfix_prefix_meta_operator >] ) {
					@child.push(
						_Postfix_OPER.new( $_ )
					);
					next
				}
				if self.assert-hash-keys( $_, [< identifier args >] ) {
					@child.push(
						_Identifier_Args.new( $_ )
					);
					next
				}
			}
			if self.assert-hash-keys(
				$parsed,
				[< OPER dotty >],
				[< postfix_prefix_meta_operator >] ) {
				return self.bless(
					:content(
						:OPER(
							_OPER.new(
								$parsed.hash.<OPER>
							)
						),
						:dotty(
							_Dotty.new(
								$parsed.hash.<dotty>
							)
						)
					),
					:postfix_prefix_meta_operator(),
					:child( @child )
				)
			}
			if self.assert-hash-keys(
				$parsed,
				[< postfix OPER >],
				[< postfix_prefix_meta_operator >] ) {
				return self.bless(
					:content(
						:postfix(
							_Postfix.new(
								$parsed.hash.<postfix>
							)
						),
						:OPER(
							_OPER.new(
								$parsed.hash.<OPER>
							)
						),
						:postfix_prefix_meta_operator()
					),
					:child( @child )
				)
			}
			if self.assert-hash-keys(
				$parsed,
				[< infix OPER >],
				[< prefix_postfix_meta_operator >] ) {
				return self.bless(
					:content(
						:infix(
							_Infix.new(
								$parsed.hash.<infix>
							)
						),
						:OPER(
							_OPER.new(
								$parsed.hash.<OPER>
							)
						),
						:infix_postfix_meta_operator()
					),
					:child( @child )
				)
			}
			if self.assert-hash-keys(
				$parsed,
				[< prefix OPER >],
				[< prefix_postfix_meta_operator >] ) {
				return self.bless(
					:content(
						:prefix(
							_Prefix.new(
								$parsed.hash.<prefix>
							)
						),
						:OPER(
							_OPER.new(
								$parsed.hash.<OPER>
							)
						),
						:prefix_postfix_meta_operator()
					),
					:child( @child )
				)
			}
			if self.assert-hash-keys(
				$parsed,
				[< postcircumfix OPER >],
				[< postfix_prefix_meta_operator >] ) {
				return self.bless(
					:content(
						:postcircumfix(
							_PostCircumfix.new(
								$parsed.hash.<postcircumfix>
							)
						),
						:OPER(
							_OPER.new(
								$parsed.hash.<OPER>
							)
						),
						:postfix_prefix_meta_operator()
					),
					:child( @child )
				)
			}
			if self.assert-hash-keys(
				$parsed,
				[< OPER >],
				[< infix_prefix_meta_operator >] ) {
				return self.bless(
					:content(
						:OPER(
							_OPER.new(
								$parsed.hash.<OPER>
							)
						),
						:infix_prefix_meta_operator()
					),
					:child( @child )
				)
			}
			die self.new-term
		}
		if self.assert-hash-keys( $parsed, [< longname args >] ) {
			return self.bless(
				:content(
					:longname(
						_LongName.new(
							$parsed.hash.<longname>
						)
					),
					:args(
						_Args.new(
							$parsed.hash.<args>
						)
					)
				)
			)
		}
		if self.assert-hash-keys( $parsed, [< identifier args >] ) {
			return self.bless(
				:content(
					:identifier(
						_Identifier.new(
							$parsed.hash.<identifier>
						)
					),
					:args(
						_Args.new(
							$parsed.hash.<args>
						)
					)
				)
			)
		}
		if self.assert-hash-keys( $parsed, [< args op >] ) {
			return self.bless(
				:content(
					:args(
						_Args.new(
							$parsed.hash.<args>
						)
					),
					:op(
						_Op.new(
							$parsed.hash.<op>
						)
					)
				)
			)
		}
		if self.assert-hash-keys( $parsed, [< sym args >] ) {
			return self.bless(
				:content(
					:sym( 
						_Sym.new(
							$parsed.hash.<sym>
						)
					),
					:args(
						_Args.new(
							$parsed.hash.<args>
						)
					)
				)
			)
		}
		if self.assert-hash-keys( $parsed, [< statement_prefix >] ) {
			return self.bless(
				:content(
					:statement_prefix(
						_StatementPrefix.new(
							$parsed.hash.<statement_prefix>
						)
					)
				)
			)
		}
		if self.assert-hash-keys( $parsed, [< type_declarator >] ) {
			return self.bless(
				:content(
					:type_declarator(
						_TypeDeclarator.new(
							$parsed.hash.<type_declarator>
						)
					)
				)
			)
		}
		if self.assert-hash-keys( $parsed, [< longname >] ) {
			return self.bless(
				:content( 
					:longname(
						_LongName.new(
							$parsed.hash.<longname>
						)
					)
				)
			)
		}
		if self.assert-hash-keys( $parsed, [< value >] ) {
			return self.bless(
				:content(
					:value(
						_Value.new(
							$parsed.hash.<value>
						)
					)
				)
			)
		}
		if self.assert-hash-keys( $parsed, [< variable >] ) {
			return self.bless(
				:content(
					:variable(
						_Variable.new(
							$parsed.hash.<variable>
						)
					)
				)
			)
		}
		if self.assert-hash-keys( $parsed, [< circumfix >] ) {
			return self.bless(
				:content(
					:circumfix(
						_Circumfix.new(
							$parsed.hash.<circumfix>
						)
					)
				)
			)
		}
		if self.assert-hash-keys( $parsed, [< colonpair >] ) {
			return self.bless(
				:content(
					:colonpair(
						_ColonPair.new(
							$parsed.hash.<colonpair>
						)
					)
				)
			)
		}
		if self.assert-hash-keys( $parsed, [< scope_declarator >] ) {
			return self.bless(
				:content(
					:scope_declarator(
						_ScopeDeclarator.new(
							$parsed.hash.<scope_declarator>
						)
					)
				)
			)
		}
		if self.assert-hash-keys( $parsed, [< routine_declarator >] ) {
			return self.bless(
				:content(
					:routine_declarator(
						_RoutineDeclarator.new(
							$parsed.hash.<routine_declarator>
						)
					)
				)
			)
		}
		if self.assert-hash-keys( $parsed, [< package_declarator >] ) {
			return self.bless(
				:content(
					:package_declarator(
						_PackageDeclarator.new(
							$parsed.hash.<package_declarator>
						)
					)
				)
			)
		}
		if self.assert-hash-keys( $parsed, [< fatarrow >] ) {
			return self.bless(
				:content(
					:fatarrow(
						_FatArrow.new(
							$parsed.hash.<fatarrow>
						)
					)
				)
			)
		}
		if self.assert-hash-keys( $parsed, [< multi_declarator >] ) {
			return self.bless(
				:content(
					:multi_declarator(
						_MultiDeclarator.new(
							$parsed.hash.<multi_declarator>
						)
					)
				)
			)
		}
		if self.assert-hash-keys( $parsed, [< regex_declarator >] ) {
			return self.bless(
				:content(
					:regex_declarator(
						_RegexDeclarator.new(
							$parsed.hash.<regex_declarator>
						)
					)
				)
			)
		}
		if self.assert-hash-keys( $parsed, [< dotty >] ) {
			return self.bless(
				:content(
					:dotty(
						_Dotty.new(
							$parsed.hash.<dotty>
						)
					)
				)
			)
		}
		die self.new-term
	}
}

class _Infix does Node {
	method new( Mu $parsed ) {
		self.trace;
		if self.assert-hash-keys( $parsed, [< EXPR O >] ) {
			return self.bless(
				:content(
					:EXPR(
						_EXPR.new(
							$parsed.hash.<EXPR>
						)
					),
					:O(
						_O.new(
							$parsed.hash.<O>
						)
					)
				)
			)
		}
		if self.assert-hash-keys( $parsed, [< infix OPER >] ) {
			return self.bless(
				:content(
					:infix(
						_Infix.new(
							$parsed.hash.<infix>
						)
					),
					:OPER(
						_OPER.new(
							$parsed.hash.<OPER>
						)
					)
				)
			)
		}
		if self.assert-hash-keys( $parsed, [< sym O >] ) {
			return self.bless(
				:content(
					:sym(
						_Sym.new(
							$parsed.hash.<sym>
						)
					),
					:O(
						_O.new(
							$parsed.hash.<O>
						)
					)
				)
			)
		}
		die self.new-term
	}
}

class _InfixIsh does Node {
	method new( Mu $parsed ) {
		self.trace;
		if self.assert-hash-keys( $parsed, [< infix OPER >] ) {
			return self.bless(
				:content(
					:infix(
						_Infix.new(
							$parsed.hash.<infix>
						)
					),
					:OPER(
						_OPER.new(
							$parsed.hash.<OPER>
						)
					)
				)
			)
		}
		die self.new-term
	}
}

class _TypeConstraint does Node {
	method new( Mu $parsed ) {
		self.trace;
		CATCH {
			when X::Hash::Store::OddNumber { }
		}
		if self.assert-hash-keys( $parsed, [< typename >] ) {
			return self.bless(
				:content(
					:typename(
						_TypeName.new(
							$parsed.hash.<typename>
						)
					)
				)
			)
		}
		die self.new-term
	}
}

class _ParamVar does Node {
	method new( Mu $parsed ) {
		self.trace;
		if self.assert-hash-keys( $parsed, [< name sigil >] ) {
			return self.bless(
				:content(
					:name(
						_Name.new(
							$parsed.hash.<name>
						)
					)
					:sigil(
						_Sigil.new(
							$parsed.hash.<sigil>
						)
					)
				)
			)
		}
		die self.new-term
	}
}

class _ParamVar_TypeConstraint_Quant does Node {
	method new( Mu $parsed ) {
		self.trace;
		if self.assert-hash-keys(
				$parsed,
				[< param_var type_constraint quant >],
				[< default_value modifier trait post_constraint >] ) {
			return self.bless(
				:content(
					:param_var(
						_ParamVar.new(
							$parsed.hash.<param_var>
						)
					)
					:type_constraint(
						_TypeConstraint.new(
							$parsed.hash.<type_constraint>
						)
					),
					:quant(
						_Quant.new(
							$parsed.hash.<quant>
						)
					)
				)
			)
		}
		die self.new-term
	}
}

class _Parameter does Node {
	method new( Mu $parsed ) {
		self.trace;
		if $parsed.list {
			my @child;
			for $parsed.list {
				if self.assert-hash-keys( $_,
					[< param_var type_constraint quant >],
					[< default_value modifier trait post_constraint >] ) {
					@child.push(
						_ParamVar_TypeConstraint_Quant.new(
							$_
						)
					);
					next
				}
				die self.new-term
			}
			return self.bless(
				:child( @child )
			)
		}
		die self.new-term
	}
}

class _Signature does Node {
	method new( Mu $parsed ) {
		self.trace;
		if self.assert-hash-keys( $parsed,
				[< parameter typename >],
				[< param_sep >] ) {
			return self.bless(
				:content(
					:parameter(
						_Parameter.new(
							$parsed.hash.<parameter>
						)
					),
					:typename(
						_TypeName.new(
							$parsed.hash.<typename>
						)
					),
					:param_sep()
				)
			)
		}
		if self.assert-hash-keys( $parsed, [], [< param_sep parameter >] ) {
			return self.bless(
				:name( $parsed.Bool ),
				:content(
					:param_sep(),
					:parameter()
				)
			)
		}
		die self.new-term
	}
}

class _Twigil does Node {
	method new( Mu $parsed ) {
		self.trace;
		if self.assert-hash-keys( $parsed, [< sym >] ) {
			return self.bless(
				:content(
					:sym(
						_Sym.new(
							$parsed.hash.<sym>
						)
					)
				)
			)
		}
		die self.new-term
	}
}

class _DeSigilName does Node {
	method new( Mu $parsed ) {
		self.trace;
		if self.assert-hash-keys( $parsed, [< longname >] ) {
			return self.bless(
				:content(
					:longname(
						_LongName.new(
							$parsed.hash.<longname>
						)
					)
				)
			)
		}
		if $parsed.Str {
			return self.bless( :name( $parsed.Str ) )
		}
		die self.new-term
	}
}

class _DefLongName does Node {
	method new( Mu $parsed ) {
		self.trace;
		if self.assert-hash-keys( $parsed, [< name >], [< colonpair >] ) {
			return self.bless(
				:content(
					:name(
						_Name.new(
							$parsed.hash.<name>
						)
					),
					:colonpair()
				)
			)
		}
		die self.new-term
	}
}

class _CharSpec does Node {
	method new( Mu $parsed ) {
		self.trace;
		if $parsed.list {
			my @child;
			for $parsed.list -> $list {
				my @_child;
				for $list.list -> $_list {
					my @__child;
					for $_list.list {
						if $_ {
							if self.assert-Str( $_ ) {
								@__child.push( $_.Str );
								next
							}
						}
						else {
							next
						}
						die self.new-term
					}
#					die self.new-term
				}
#				die self.new-term
			}
			return self.bless(
				:child( @child )
			)
		}
		die self.new-term
	}
}

class _Sign_CharSpec does Node {
	method new( Mu $parsed ) {
		if self.assert-hash-keys( $parsed, [< sign charspec >] ) {
			return self.bless(
				:content(
					:sign(
						_Sign.new(
							$parsed.hash.<sign>
						)
					),
					:charspec(
						_CharSpec.new(
							$parsed.hash.<charspec>
						)
					)
				)
			)
		}
		die self.new-term
	}
}

class _CClassElem does Node {
	method new( Mu $parsed ) {
		self.trace;
		if $parsed.list {
			my @child;
			for $parsed.list {
				if self.assert-hash-keys( $_, [< sign charspec >] ) {
					@child.push(
						_Sign_CharSpec.new(
							$_
						)
					);
					next
				}
				die self.new-term
			}
			return self.bless(
				:child( @child )
			)
		}
		die self.new-term
	}
}

class _Coercee does Node {
	method new( Mu $parsed ) {
		self.trace;
		if self.assert-hash-keys( $parsed, [< semilist >] ) {
			return self.bless(
				:content(
					:semilist(
						_SemiList.new(
							$parsed.hash.<semilist>
						)
					)
				)
			)
		}
		die self.new-term
	}
}

class _Contextualizer does Node {
	method new( Mu $parsed ) {
		self.trace;
		if self.assert-hash-keys( $parsed, [< coercee circumfix sigil >] ) {
			return self.bless(
				:content(
					:coercee(
						_Coercee.new(
							$parsed.hash.<coercee>
						)
					),
					:circumfix(
						_Circumfix.new(
							$parsed.hash.<circumfix>
						)
					),
					:sigil(
						_Sigil.new(
							$parsed.hash.<sigil>
						)
					)
				)
			)
		}
		die self.new-term
	}
}

class _Variable does Node {
	method new( Mu $parsed ) {
		self.trace;
		if self.assert-hash-keys( $parsed, [< twigil sigil desigilname >] ) {
			return self.bless(
				:content(
					:twigil(
						_Twigil.new(
							$parsed.hash.<twigil>
						)
					),
					:sigil(
						_Sigil.new(
							$parsed.hash.<sigil>
						)
					),
					:desigilname(
						_DeSigilName.new(
							$parsed.hash.<desigilname>
						)
					)
				)
			)
		}
		if self.assert-hash-keys( $parsed, [< sigil desigilname >] ) {
			return self.bless(
				:content(
					:sigil(
						_Sigil.new(
							$parsed.hash.<sigil>
						)
					),
					:desigilname(
						_DeSigilName.new(
							$parsed.hash.<desigilname>
						)
					)
				)
			)
		}
		if self.assert-hash-keys( $parsed, [< sigil >] ) {
			return self.bless(
				:content(
					:sigil(
						_Sigil.new(
							$parsed.hash.<sigil>
						)
					)
				)
			)
		}
		if self.assert-hash-keys( $parsed, [< contextualizer >] ) {
			return self.bless(
				:content(
					:contextualizer(
						_Contextualizer.new(
							$parsed.hash.<contextualizer>
						)
					)
				)
			)
		}
		die self.new-term
	}
}

class _Assertion does Node {
	method new( Mu $parsed ) {
		self.trace;
		if self.assert-hash-keys( $parsed, [< var >] ) {
			return self.bless(
				:content(
					:var(
						_Var.new(
							$parsed.hash.<var>
						)
					)
				)
			)
		}
		if self.assert-hash-keys( $parsed, [< longname >] ) {
			return self.bless(
				:content(
					:longname(
						_LongName.new(
							$parsed.hash.<longname>
						)
					)
				)
			)
		}
		if self.assert-hash-keys( $parsed, [< cclass_elem >] ) {
			return self.bless(
				:content(
					:cclass_elem(
						_CClassElem.new(
							$parsed.hash.<cclass_elem>
						)
					)
				)
			)
		}
		die self.new-term
	}
}

class _MetaChar does Node {
	method new( Mu $parsed ) {
		self.trace;
		if self.assert-hash-keys( $parsed, [< sym >] ) {
			return self.bless(
				:content(
					:sym(
						_Sym.new(
							$parsed.hash.<sym>
						)
					)
				)
			)
		}
		if self.assert-hash-keys( $parsed, [< codeblock >] ) {
			return self.bless(
				:content(
					:codeblock(
						_CodeBlock.new(
							$parsed.hash.<codeblock>
						)
					)
				)
			)
		}
		if self.assert-hash-keys( $parsed, [< backslash >] ) {
			return self.bless(
				:content(
					:backslash(
						_BackSlash.new(
							$parsed.hash.<backslash>
						)
					)
				)
			)
		}
		if self.assert-hash-keys( $parsed, [< assertion >] ) {
			return self.bless(
				:content(
					:assertion(
						_Assertion.new(
							$parsed.hash.<assertion>
						)
					)
				)
			)
		}
		if self.assert-hash-keys( $parsed, [< nibble >] ) {
			return self.bless(
				:content(
					:nibble(
						_Nibble.new(
							$parsed.hash.<nibble>
						)
					)
				)
			)
		}
		if self.assert-hash-keys( $parsed, [< quote >] ) {
			return self.bless(
				:content(
					:quote(
						_Quote.new(
							$parsed.hash.<quote>
						)
					)
				)
			)
		}
		if self.assert-hash-keys( $parsed, [< nibbler >] ) {
			return self.bless(
				:content(
					:nibbler(
						_Nibbler.new(
							$parsed.hash.<nibbler>
						)
					)
				)
			)
		}
		die self.new-term
	}
}

class _Atom_SigFinal does Node {
	method new( Mu $parsed ) {
		self.trace;
		if self.assert-hash-keys( $parsed, [< atom sigfinal >] ) {
			return self.bless(
				:content(
					:atom(
						_Atom.new(
							$parsed.hash.<atom>
						)
					),
					:sigfinal(
						_SigFinal.new(
							$parsed.hash.<sigfinal>
						)
					)
				)
			)
		}
		if self.assert-hash-keys( $parsed, [< atom quantifier >] ) {
			return self.bless(
				:content(
					:atom(
						_Atom.new(
							$parsed.hash.<atom>
						)
					),
					:quantifier(
						_Quantifier.new(
							$parsed.hash.<quantifier>
						)
					)
				)
			)
		}
		if self.assert-hash-keys( $parsed, [< atom >] ) {
			return self.bless(
				:content(
					:atom(
						_Atom.new(
							$parsed.hash.<atom>
						)
					)
				)
			)
		}
		die self.new-term
	}
}

class _Atom_SigFinal_Quantifier does Node {
	method new( Mu $parsed ) {
		self.trace;
		if self.assert-hash-keys( $parsed,
			[< atom sigfinal quantifier >] ) {
			return self.bless(
				:content(
					:atom(
						_Atom.new(
							$parsed.hash.<atom>
						)
					),
					:sigfinal(
						_SigFinal.new(
							$parsed.hash.<sigfinal>
						)
					),
					:quantifier(
						_Quantifier.new(
							$parsed.hash.<quantifier>
						)
					)
				)
			)
		}
		die self.new-term
	}
}

class _Atom does Node {
	method new( Mu $parsed ) {
		self.trace;
		if self.assert-hash-keys( $parsed, [< metachar >] ) {
			return self.bless(
				:content(
					:metachar(
						_MetaChar.new(
							$parsed.hash.<metachar>
						)
					)
				)
			)
		}
		if $parsed.Str {
			return self.bless( :name( $parsed.Str ) )
		}
		die self.new-term
	}
}

class _Quant does Node {
	method new( Mu $parsed ) {
		self.trace;
		if self.assert-Bool( $parsed ) {
			return self.bless( :name( $parsed.Bool ) )
		}
		die self.new-term
	}
}

class _Quantifier does Node {
	method new( Mu $parsed ) {
		self.trace;
		if self.assert-hash-keys( $parsed, [< sym backmod >] ) {
			return self.bless(
				:content(
					:sym(
						_Sym.new(
							$parsed.hash.<sym>
						)
					),
					:backmod(
						_BackMod.new(
							$parsed.hash.<backmod>
						)
					)
				)
			)
		}
		die self.new-term
	}
}

class _BackMod does Node {
	method new( Mu $parsed ) {
		self.trace;
		if self.assert-Bool( $parsed ) {
			return self.bless( :name( $parsed.Bool ) )
		}
		die self.new-term
	}
}

class _SigFinal does Node {
	method new( Mu $parsed ) {
		self.trace;
		if self.assert-hash-keys( $parsed, [< normspace >] ) {
			return self.bless(
				:content(
					:normspace(
						_NormSpace.new(
							$parsed.hash.<normspace>
						)
					)
				)
			)
		}
		die self.new-term
	}
}

class _QuantifiedAtom does Node {
	method new( Mu $parsed ) {
		self.trace;
		if self.assert-hash-keys( $parsed, [< sigfinal atom >] ) {
			return self.bless(
				:content(
					:sigfinal(
						_SigFinal.new(
							$parsed.hash.<sigfinal>
						)
					),
					:atom(
						_Atom.new(
							$parsed.hash.<atom>
						)
					)
				)
			)
		}
		die self.new-term
	}
}

class _Shape does Node {
	method new( Mu $parsed ) {
		self.trace;
		if self.assert-Str( $parsed ) {
			return self.bless( :name( $parsed.Str ) )
		}
		die self.new-term
	}
}

class _SepType does Node {
	method new( Mu $parsed ) {
		self.trace;
		if self.assert-Str( $parsed ) {
			return self.bless( :name( $parsed.Str ) )
		}
		die self.new-term
	}
}

class _Separator does Node {
	method new( Mu $parsed ) {
		self.trace;
		if self.assert-hash-keys( $parsed, [< septype quantified_atom >] ) {
			return self.bless(
				:content(
					:septype(
						_SepType.new(
							$parsed.hash.<septype>
						)
					),
					:quantified_atom(
						_QuantifiedAtom.new(
							$parsed.hash.<quantified_atom>
						)
					)
				)
			)
		}
		die self.new-term
	}
}

class _SigFinal_Quantifier_Separator_Atom does Node {
	method new( Mu $parsed ) {
		self.trace;
		if self.assert-hash-keys( $parsed,
				     [< sigfinal quantifier
				        separator atom >] ) {
			return self.bless(
				:content(
					:sigfinal(
						_SigFinal.new(
							$parsed.hash.<sigfinal>
						)
					),
					:quantifier(
						_Quantifier.new(
							$parsed.hash.<quantifier>
						)
					),
					:separator(
						_Separator.new(
							$parsed.hash.<separator>
						)
					),
					:atom(
						_Atom.new(
							$parsed.hash.<atom>
						)
					)
				)
			)
		}
		die self.new-term
	}
}

class _Noun does Node {
	method new( Mu $parsed ) {
		self.trace;
		if $parsed.list {
			my @child;
			for $parsed.list {
				if self.assert-hash-keys( $_,
					[< sigfinal quantifier
					   separator atom >] ) {
					@child.push(
						_SigFinal_Quantifier_Separator_Atom.new(
							$_
						)
					);
					next
				}
				if self.assert-hash-keys( $_,
					[< atom sigfinal quantifier >] ) {
					@child.push(
						_Atom_SigFinal_Quantifier.new(
							$_
						)
					);
					next
				}
				if self.assert-hash-keys( $_, [< atom >],
							      [< sigfinal >] ) {
					@child.push(
						_Atom_SigFinal.new(
							$_
						)
					);
					next
				}
				die self.new-term
			}
			return self.bless(
				:child( @child )
			)
		}
		die self.new-term
	}
}

class _TermIsh does Node {
	method new( Mu $parsed ) {
		self.trace;
		if $parsed.list {
			my @child;
			for $parsed.list {
				if self.assert-hash-keys( $_, [< noun >] ) {
					@child.push(
						_Noun.new(
							$_.hash.<noun>
						)
					);
					next
				}
				die self.new-term
			}
			return self.bless(
				:child( @child )
			)
		}
		if self.assert-hash-keys( $parsed, [< noun >] ) {
			return self.bless(
				:content(
					:noun(
						_Noun.new(
							$parsed.hash.<noun>
						)
					)
				)
			)
		}
		die self.new-term
	}
}

class _TermConj does Node {
	method new( Mu $parsed ) {
		self.trace;
		if $parsed.list {
			my @child;
			for $parsed.list {
				if self.assert-hash-keys( $_, [< termish >] ) {
					@child.push(
						_TermIsh.new(
							$_.hash.<termish>
						)
					);
					next
				}
				die self.new-term
			}
			return self.bless(
				:child( @child )
			)
		}
		die self.new-term
	}
}

class _TermAlt does Node {
	method new( Mu $parsed ) {
		self.trace;
		if $parsed.list {
			my @child;
			for $parsed.list {
				if self.assert-hash-keys( $_, [< termconj >] ) {
					@child.push(
						_TermConj.new(
							$_.hash.<termconj>
						)
					);
					next
				}
				die self.new-term
			}
			return self.bless(
				:child( @child )
			)
		}
		die self.new-term
	}
}

class _TermConjSeq does Node {
	method new( Mu $parsed ) {
		self.trace;
		if $parsed.list {
			my @child;
			for $parsed.list {
				if self.assert-hash-keys( $_, [< termalt >] ) {
					@child.push(
						_TermAlt.new(
							$_.hash.<termalt>
						)
					);
					next
				}
				die self.new-term
			}
			return self.bless(
				:child( @child )
			)
		}
		if self.assert-hash-keys( $parsed, [< termalt >] ) {
			return self.bless(
				:content(
					:termalt(
						_TermAlt.new(
							$parsed.hash.<termalt>
						)
					)
				)
			)
		}
		die self.new-term
	}
}

class _TermAltSeq does Node {
	method new( Mu $parsed ) {
		self.trace;
		if self.assert-hash-keys( $parsed, [< termconjseq >] ) {
			return self.bless(
				:content(
					:termconjseq(
						_TermConjSeq.new(
							$parsed.hash.<termconjseq>
						)
					)
				)
			)
		}
		die self.new-term
	}
}

class _TermSeq does Node {
	method new( Mu $parsed ) {
		self.trace;
		if self.assert-hash-keys( $parsed, [< termaltseq >] ) {
			return self.bless(
				:content(
					:termaltseq(
						_TermAltSeq.new(
							$parsed.hash.<termaltseq>
						)
					)
				)
			)
		}
		die self.new-term
	}
}

class _Nibbler does Node {
	method new( Mu $parsed ) {
		self.trace;
		if self.assert-hash-keys( $parsed, [< termseq >] ) {
			return self.bless(
				:content(
					:termseq(
						_TermSeq.new(
							$parsed.hash.<termseq>
						)
					)
				)
			)
		}
		die self.new-term
	}
}

class _Nibble does Node {
	method new( Mu $parsed ) {
		self.trace;
		if self.assert-hash-keys( $parsed, [< termseq >] ) {
			return self.bless(
				:content(
					:termseq(
						_TermSeq.new(
							$parsed.hash.<termseq>
						)
					)
				)
			)
		}
		if $parsed.Str {
			return self.bless( :name( $parsed.Str ) )
		}
		if $parsed.Bool {
			return self.bless( :name( $parsed.Bool ) )
		}
		die self.new-term
	}
}

class _MethodDef does Node {
	method new( Mu $parsed ) {
		self.trace;
		if self.assert-hash-keys( $parsed,
				     [< specials longname blockoid multisig >],
				     [< trait >] ) {
			return self.bless(
				:content(
					:specials(
						_Specials.new(
							$parsed.hash.<specials>
						)
					),
					:longname(
						_LongName.new(
							$parsed.hash.<longname>
						)
					),
					:blockoid(
						_Blockoid.new(
							$parsed.hash.<blockoid>
						)
					),
					:multisig(
						_MultiSig.new(
							$parsed.hash.<multisig>
						)
					),
					:trait()
				)
			)
		}
		if self.assert-hash-keys( $parsed,
				     [< specials longname blockoid >],
				     [< trait >] ) {
			return self.bless(
				:content(
					:specials(
						_Specials.new(
							$parsed.hash.<specials>
						)
					),
					:longname(
						_LongName.new(
							$parsed.hash.<longname>
						)
					),
					:blockoid(
						_Blockoid.new(
							$parsed.hash.<blockoid>
						)
					),
					:trait()
				)
			)
		}
		die self.new-term
	}
}

class _Specials does Node {
	method new( Mu $parsed ) {
		self.trace;
		CATCH { when X::Multi::NoMatch { } }
		if self.assert-Bool( $parsed ) {
			return self.bless( :name( $parsed.Bool ) )
		}
		die self.new-term
	}
}

class _RegexDef does Node {
	method new( Mu $parsed ) {
		self.trace;
		if self.assert-hash-keys( $parsed, [< deflongname nibble >],
					      [< signature trait >] ) {
			return self.bless(
				:content(
					:deflongname(
						_DefLongName.new(
							$parsed.hash.<deflongname>
						)
					),
					:nibble(
						_Nibble.new(
							$parsed.hash.<nibble>
						)
					),
					:signature(),
					:trait()
				)
			)
		}
		die self.new-term
	}
}

class _RegexDeclarator does Node {
	method new( Mu $parsed ) {
		self.trace;
		if self.assert-hash-keys( $parsed, [< sym regex_def >] ) {
			return self.bless(
				:content(
					:sym(
						_Sym.new(
							$parsed.hash.<sym>
						)
					),
					:regex_def(
						_RegexDef.new(
							$parsed.hash.<regex_def>
						)
					)
				)
			)
		}
		die self.new-term
	}
}

class _SemiList does Node {
	method new( Mu $parsed ) {
		self.trace;
		CATCH { when X::Hash::Store::OddNumber { } }
		if self.assert-hash-keys( $parsed, [], [< statement >] ) {
			return self.bless(
				:content(
					:statement()
				)
			)
		}
		die self.new-term
	}
}

class _B does Node {
	method new( Mu $parsed ) {
		self.trace;
		if self.assert-Bool( $parsed ) {
			return self.bless( :name( $parsed.Bool ) )
		}
		die self.new-term
	}
}

class _Babble does Node {
	method new( Mu $parsed ) {
		self.trace;
		if self.assert-hash-keys( $parsed, [< B >], [< quotepair >] ) {
			return self.bless(
				:content(
					:B(
						_B.new(
							$parsed.hash.<B>
						)
					),
					:quotepair()
				)
			)
		}
		die self.new-term
	}
}

class _Quibble does Node {
	method new( Mu $parsed ) {
		self.trace;
		if self.assert-hash-keys( $parsed, [< babble nibble >] ) {
			return self.bless(
				:content(
					:babble(
						_Babble.new(
							$parsed.hash.<babble>
						)
					),
					:nibble(
						_Nibble.new(
							$parsed.hash.<nibble>
						)
					)
				)
			)
		}
		die self.new-term
	}
}

class _Quote does Node {
	method new( Mu $parsed ) {
		self.trace;
		if self.assert-hash-keys( $parsed, [< nibble >] ) {
			return self.bless(
				:content(
					:nibble(
						_Nibble.new(
							$parsed.hash.<nibble>
						)
					)
				)
			)
		}
		if self.assert-hash-keys( $parsed, [< quibble >] ) {
			return self.bless(
				:content(
					:quibble(
						_Quibble.new(
							$parsed.hash.<quibble>
						)
					)
				)
			)
		}
		die self.new-term
	}
}

class _RadNumber does Node {
	method new( Mu $parsed ) {
		self.trace;
		if self.assert-hash-keys( $parsed, [< circumfix radix >],
					      [< exp base >] ) {
			return self.bless(
				:content(
					:circumfix(
						_Circumfix.new(
							$parsed.hash.<circumfix>
						)
					),
					:radix(
						_Radix.new(
							$parsed.hash.<radix>
						)
					),
					:exp(),
					:base()
				)
			)
		}
		die self.new-term
	}
}

class _DecNumber does Node {
	method new( Mu $parsed ) {
		self.trace;
		if self.assert-hash-keys( $parsed,
					  [< int coeff frac escale >] ) {
			return self.bless(
				:content(
					:int(
						_Int.new(
							$parsed.hash.<int>
						)
					),
					:coeff(
						_Coeff.new(
							$parsed.hash.<coeff>
						)
					),
					:frac(
						_Frac.new(
							$parsed.hash.<frac>
						)
					),
					:escale(
						_EScale.new(
							$parsed.hash.<escale>
						)
					)
				)
			)
		}
		if self.assert-hash-keys( $parsed, [< coeff frac escale >] ) {
			return self.bless(
				:content(
					:coeff(
						_Coeff.new(
							$parsed.hash.<coeff>
						)
					),
					:frac(
						_Frac.new(
							$parsed.hash.<frac>
						)
					),
					:escale(
						_EScale.new(
							$parsed.hash.<escale>
						)
					)
				)
			)
		}
		if self.assert-hash-keys( $parsed, [< int coeff frac >] ) {
			return self.bless(
				:content(
					:int(
						_Int.new(
							$parsed.hash.<int>
						)
					),
					:coeff(
						_Coeff.new(
							$parsed.hash.<coeff>
						)
					),
					:frac(
						_Frac.new(
							$parsed.hash.<frac>
						)
					)
				)
			)
		}
		if self.assert-hash-keys( $parsed, [< int coeff escale >] ) {
			return self.bless(
				:content(
					:int(
						_Int.new(
							$parsed.hash.<int>
						)
					),
					:coeff(
						_Coeff.new(
							$parsed.hash.<coeff>
						)
					),
					:escale(
						_EScale.new(
							$parsed.hash.<escale>
						)
					)
				)
			)
		}
		if self.assert-hash-keys( $parsed, [< coeff frac >] ) {
			return self.bless(
				:content(
					:coeff(
						_Coeff.new(
							$parsed.hash.<coeff>
						)
					),
					:frac(
						_Frac.new(
							$parsed.hash.<frac>
						)
					)
				)
			)
		}
		die self.new-term
	}
}

class _Numish does Node {
	method new( Mu $parsed ) {
		self.trace;
		if self.assert-hash-keys( $parsed, [< integer >] ) {
			return self.bless(
				:content(
					:integer(
						_Integer.new(
							$parsed.hash.<integer>
						)
					)
				)
			)
		}
		if self.assert-hash-keys( $parsed, [< rad_number >] ) {
			return self.bless(
				:content(
					:rad_number(
						_RadNumber.new(
							$parsed.hash.<rad_number>
						)
					)
				)
			)
		}
		if self.assert-hash-keys( $parsed, [< dec_number >] ) {
			return self.bless(
				:content(
					:dec_number(
						_DecNumber.new(
							$parsed.hash.<dec_number>
						)
					)
				)
			)
		}
		die self.new-term
	}
}

class _Number does Node {
	method new( Mu $parsed ) {
		self.trace;
		if self.assert-hash-keys( $parsed, [< numish >] ) {
			return self.bless(
				:content(
					:numish(
						_Numish.new(
							$parsed.hash.<numish>
						)
					)
				)
			)
		}
		die self.new-term
	}
}

class _Value does Node {
	method new( Mu $parsed ) {
		self.trace;
		if self.assert-hash-keys( $parsed, [< number >] ) {
			return self.bless(
				:content(
					:number(
						_Number.new(
							$parsed.hash.<number>
						)
					)
				)
			)
		}
		if self.assert-hash-keys( $parsed, [< quote >] ) {
			return self.bless(
				:content(
					:quote(
						_Quote.new(
							$parsed.hash.<quote>
						)
					)
				)
			)
		}
		die self.new-term
	}
}

class _VariableDeclarator does Node {
	method new( Mu $parsed ) {
		self.trace;
		if self.assert-hash-keys(
			$parsed,
			[< semilist variable shape >],
			[< postcircumfix signature trait post_constraint >] ) {
			return self.bless(
				:content(
					:semilist(
						_SemiList.new(
							$parsed.hash.<semilist>
						)
					),
					:variable(
						_Variable.new(
							$parsed.hash.<variable>
						)
					),
					:shape(
						_Shape.new(
							$parsed.hash.<shape>
						)
					),
					:postcircumfix(),
					:signature(),
					:trait(),
					:post_constraint()
				)
			)
		}
		if self.assert-hash-keys(
			$parsed,
			[< variable >],
			[< semilist postcircumfix signature
			   trait post_constraint >] ) {
			return self.bless(
				:content(
					:variable(
						_Variable.new(
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
		die self.new-term
	}
} 

class _LongName_ColonPair does Node {
	method new( Mu $parsed ) {
		if self.assert-hash-keys( $parsed, [< longname colonpairs >],
						   [< colonpair >] ) {
			return self.bless(
				:content(
					:longname(
						_LongName.new(
							$_.hash.<longname>
						)
					),
					:colonpairs(
						_ColonPairs.new(
							$_.hash.<colonpairs>
						)
					),
					:colonpair()
				)
			)
		}
		if self.assert-hash-keys( $parsed, [< longname >],
						   [< colonpair >] ) {
			return self.bless(
				:content(
					:longname(
						_LongName.new(
							$_.hash.<longname>
						)
					),
					:colonpair()
				)
			)
		}
		die self.new-term
	}
}

class _LongName_ColonPairs does Node {
	method new( Mu $parsed ) {
		if self.assert-hash-keys( $parsed, [< longname colonpairs >],
						   [< colonpair >] ) {
			return self.bless(
				:content(
					:longname(
						_LongName.new(
							$_.hash.<longname>
						)
					),
					:colonpairs(
						_ColonPairs.new(
							$_.hash.<colonpairs>
						)
					),
					:colonpair()
				)
			)
		}
		die self.new-term
	}
}

class _TypeName does Node {
	method new( Mu $parsed ) {
		self.trace;
		if $parsed.list {
			my @child;
			for $parsed.list {
				if self.assert-hash-keys( $_,
					[< longname colonpairs >],
					[< colonpair >] ) {
					@child.push(
						_LongName_ColonPairs.new(
							$_
						)
					);
					next
				}
				if self.assert-hash-keys( $_,
					[< longname >],
					[< colonpair >] ) {
					@child.push(
						_LongName_ColonPair.new(
							$_
						)
					);
					next
				}
				die self.new-term
			}
			return self.bless(
				:child( @child )
			)
		}
		if self.assert-hash-keys( $parsed, [< longname >],
						   [< colonpair >] ) {
			return self.bless(
				:content(
					:longname(
						_LongName.new(
							$parsed.hash.<longname>
						)
					)
				)
			)
		}
		die self.new-term
	}
}

class _Blockoid does Node {
	method new( Mu $parsed ) {
		self.trace;
		if self.assert-hash-keys( $parsed, [< statementlist >] ) {
			return self.bless(
				:content(
					:statementlist(
						_StatementList.new(
							$parsed.hash.<statementlist>
						)
					)
				)
			)
		}
		die self.new-term
	}
}

class _Initializer does Node {
	method new( Mu $parsed ) {
		self.trace;
		if $parsed {
			if self.assert-hash-keys( $parsed, [< sym EXPR >] ) {
				return self.bless(
					:content(
						:sym(
							_Sym.new(
								$parsed.hash.<sym>
							)
						),
						:EXPR(
							_EXPR.new(
								$parsed.hash.<EXPR>
							)
						)
					)
				)
			}
		}
		else {
			return self.bless
		}
		die self.new-term
	}
}

class _Declarator does Node {
	method new( Mu $parsed ) {
		self.trace;
		if self.assert-hash-keys( $parsed, [< initializer signature >],
						   [< trait >] ) {
			return self.bless(
				:content(
					:initializer(
						_Initializer.new(
							$parsed.hash.<initializer>
						)
					),
					:signature(
						_Signature.new(
							$parsed.hash.<signature>
						)
					),
					:trait()
				)
			)
		}
		if self.assert-hash-keys( $parsed,
					  [< initializer variable_declarator >],
					  [< trait >] ) {
			return self.bless(
				:content(
					:initializer(
						_Initializer.new(
							$parsed.hash.<initializer>
						)
					),
					:variable_declarator(
						_VariableDeclarator.new(
							$parsed.hash.<variable_declarator>
						)
					),
					:trait()
				)
			)
		}
		if self.assert-hash-keys( $parsed, [< variable_declarator >],
						   [< trait >] ) {
			return self.bless(
				:content(
					:variable_declarator(
						_VariableDeclarator.new(
							$parsed.hash.<variable_declarator>
						)
					),
					:trait()
				)
			)
		}
		if self.assert-hash-keys( $parsed, [< regex_declarator >],
					      [< trait >] ) {
			return self.bless(
				:content(
					:regex_declarator(
						_RegexDeclarator.new(
							$parsed.hash.<regex_declarator>
						)
					),
					:trait()
				)
			)
		}
		if self.assert-hash-keys( $parsed, [< routine_declarator >],
					      [< trait >] ) {
			return self.bless(
				:content(
					:routine_declarator(
						_RoutineDeclarator.new(
							$parsed.hash.<routine_declarator>
						)
					),
					:trait()
				)
			)
		}
		if self.assert-hash-keys( $parsed, [< signature >],
					      [< trait >] ) {
			return self.bless(
				:content(
					:routine_declarator(
						_Signature.new(
							$parsed.hash.<signature>
						)
					),
					:trait()
				)
			)
		}
		die self.new-term
	}
}

class _PackageDef does Node {
	method new( Mu $parsed ) {
		self.trace;
		if self.assert-hash-keys( $parsed, [< blockoid longname >],
					      [< trait >] ) {
			return self.bless(
				:content(
					:blockoid(
						_Blockoid.new(
							$parsed.hash.<blockoid>
						)
					),
					:longname(
						_LongName.new(
							$parsed.hash.<longname>
						)
					),
					:trait()
				)
			)
		}
		if self.assert-hash-keys( $parsed, [< longname statementlist >],
					      [< trait >] ) {
			return self.bless(
				:content(
					:longname(
						_LongName.new(
							$parsed.hash.<longname>
						)
					),
					:statementlist(
						_StatementList.new(
							$parsed.hash.<statementlist>
						)
					),
					:trait()
				)
			)
		}
		die self.new-term
	}
}

# XXX This is a compound type
class _Dotty_OPER does Node {
	method new( Mu $parsed ) {
		self.trace;
		if self.assert-hash-keys( $parsed,
				     [< dotty OPER >],
				     [< postfix_prefix_meta_operator >] ) {
			return self.bless(
				:content(
					:dotty(
						_Dotty.new(
							$parsed.hash.<dotty>
						)
					),
					:OPER(
						_OPER.new(
							$parsed.hash.<OPER>
						)
					),
					:postfix_prefix_meta_operator()
				)
			)
		}
		die self.new-term
	}
}

# XXX This is a compound type
class _Prefix_OPER does Node {
	method new( Mu $parsed ) {
		self.trace;
		if self.assert-hash-keys( $parsed,
				     [< prefix OPER >],
				     [< prefix_postfix_meta_operator >] ) {
			return self.bless(
				:content(
					:prefix(
						_Prefix.new(
							$parsed.hash.<prefix>
						)
					),
					:OPER(
						_OPER.new(
							$parsed.hash.<OPER>
						)
					),
					:prefix_postfix_meta_operator()
				)
			)
		}
		die self.new-term
	}
}

# XXX This is a compound type
class _Postfix_OPER does Node {
	method new( Mu $parsed ) {
		self.trace;
		if self.assert-hash-keys( $parsed,
				     [< postfix OPER >],
				     [< postfix_prefix_meta_operator >] ) {
			return self.bless(
				:content(
					:postfix(
						_Postfix.new(
							$parsed.hash.<postfix>
						)
					),
					:OPER(
						_OPER.new(
							$parsed.hash.<OPER>
						)
					),
					:postfix_prefix_meta_operator()
				)
			)
		}
		die self.new-term
	}
}

# XXX This is a compound type
class _Infix_OPER does Node {
	method new( Mu $parsed ) {
		self.trace;
		if self.assert-hash-keys( $parsed,
				     [< infix OPER >],
				     [< infix_postfix_meta_operator >] ) {
			return self.bless(
				:content(
					:infix(
						_Infix.new(
							$parsed.hash.<infix>
						)
					),
					:OPER(
						_OPER.new(
							$parsed.hash.<OPER>
						)
					),
					:infix_postfix_meta_operator()
				)
			)
		}
		die self.new-term
	}
}

class _MultiSig does Node {
	method new( Mu $parsed ) {
		self.trace;
		if self.assert-hash-keys( $parsed, [< signature >] ) {
			return self.bless(
				:content(
					:signature(
						_Signature.new(
							$parsed.hash.<signature>
						)
					)
				)
			)
		}
		die self.new-term
	}
}

class _MultiDeclarator does Node {
	method new( Mu $parsed ) {
		self.trace;
		if self.assert-hash-keys( $parsed, [< sym routine_def >] ) {
			return self.bless(
				:content(
					:sym(
						_Sym.new(
							$parsed.hash.<sym>
						)
					),
					:routine_def(
						_RoutineDef.new(
							$parsed.hash.<routine_def>
						)
					)
				)
			)
		}
		if self.assert-hash-keys( $parsed, [< sym declarator >] ) {
			return self.bless(
				:content(
					:sym(
						_Sym.new(
							$parsed.hash.<sym>
						)
					),
					:declarator(
						_Declarator.new(
							$parsed.hash.<declarator>
						)
					)
				)
			)
		}
		if self.assert-hash-keys( $parsed, [< declarator >] ) {
			return self.bless(
				:content(
					:declarator(
						_Declarator.new(
							$parsed.hash.<declarator>
						)
					)
				)
			)
		}
		die self.new-term
	}
}

class _RoutineDef does Node {
	method new( Mu $parsed ) {
		self.trace;
		if self.assert-hash-keys( $parsed,
				     [< blockoid deflongname multisig >],
				     [< trait >] ) {
			return self.bless(
				:content(
					:blockoid(
						_Blockoid.new(
							$parsed.hash.<blockoid>
						)
					),
					:deflongname(
						_DefLongName.new(
							$parsed.hash.<deflongname>
						)
					),
					:multisig(
						_MultiSig.new(
							$parsed.hash.<multisig>
						)
					),
					:trait()
				)
			)
		}
		if self.assert-hash-keys( $parsed, [< blockoid deflongname >],
					      [< trait >] ) {
			return self.bless(
				:content(
					:blockoid(
						_Blockoid.new(
							$parsed.hash.<blockoid>
						)
					),
					:deflongname(
						_DefLongName.new(
							$parsed.hash.<deflongname>
						)
					),
					:trait()
				)
			)
		}
		if self.assert-hash-keys( $parsed, [< blockoid multisig >],
						   [< trait >] ) {
			return self.bless(
				:content(
					:blockoid(
						_Blockoid.new(
							$parsed.hash.<blockoid>
						)
					),
					:multisig(
						_MultiSig.new(
							$parsed.hash.<multisig>
						)
					),
					:trait()
				)
			)
		}
		if self.assert-hash-keys( $parsed, [< blockoid >],
					      [< trait >] ) {
			return self.bless(
				:content(
					:blockoid(
						_Blockoid.new(
							$parsed.hash.<blockoid>
						)
					),
					:trait()
				)
			)
		}
		die self.new-term
	}
}

class _DECL does Node {
	method new( Mu $parsed ) {
		self.trace;
		if self.assert-hash-keys( $parsed, [< initializer signature >],
						   [< trait >] ) {
			return self.bless(
				:content(
					:initializer(
						_Initializer.new(
							$parsed.hash.<initializer>
						)
					),
					:signature(
						_Signature.new(
							$parsed.hash.<signature>
						)
					),
					:trait()
				)
			)
		}
		if self.assert-hash-keys( $parsed,
					  [< initializer variable_declarator >],
					  [< trait >] ) {
			return self.bless(
				:content(
					:initializer(
						_Initializer.new(
							$parsed.hash.<initializer>
						)
					),
					:variable_declarator(
						_VariableDeclarator.new(
							$parsed.hash.<variable_declarator>
						)
					),
					:trait()
				)
			)
		}
		if self.assert-hash-keys( $parsed, [< signature >],
						   [< trait >] ) {
			return self.bless(
				:content(
					:initializer(
						_Initializer.new(
							$parsed.hash.<initializer>
						)
					),
					:signature(
						_Signature.new(
							$parsed.hash.<signature>
						)
					),
					:trait()
				)
			)
		}
		if self.assert-hash-keys( $parsed, [< variable_declarator >],
						   [< trait >] ) {
			return self.bless(
				:content(
					:variable_declarator(
						_VariableDeclarator.new(
							$parsed.hash.<variable_declarator>
						)
					),
					:trait()
				)
			)
		}
		if self.assert-hash-keys( $parsed, [< regex_declarator >],
						   [< trait >] ) {
			return self.bless(
				:content(
					:regex_declarator(
						_RegexDeclarator.new(
							$parsed.hash.<regex_declarator>
						)
					),
					:trait()
				)
			)
		}
		if self.assert-hash-keys( $parsed, [< routine_declarator >],
						   [< trait >] ) {
			return self.bless(
				:content(
					:routine_declarator(
						_RoutineDeclarator.new(
							$parsed.hash.<routine_declarator>
						)
					),
					:trait()
				)
			)
		}
		if self.assert-hash-keys( $parsed, [< package_def sym >] ) {
			return self.bless(
				:content(
					:package_def(
						_PackageDef.new(
							$parsed.hash.<package_def>
						)
					),
					:sym(
						_Sym.new(
							$parsed.hash.<sym>
						)
					)
				)
			)
		}
		if self.assert-hash-keys( $parsed, [< declarator >] ) {
			return self.bless(
				:content(
					:declarator(
						_Declarator.new(
							$parsed.hash.<declarator>
						)
					)
				)
			)
		}
		die self.new-term
	}
}

class _Scoped does Node {
	method new( Mu $parsed ) {
		self.trace;
		if self.assert-hash-keys( $parsed, [< declarator DECL >],
						   [< typename >] ) {
			return self.bless(
				:content(
					:declarator(
						_Declarator.new(
							$parsed.hash.<declarator>
						)
					),
					:DECL(
						_DECL.new(
							$parsed.hash.<DECL>
						)
					),
					:typename()
				)
			)
		}
		if self.assert-hash-keys( $parsed,
					[< multi_declarator DECL typename >] ) {
			return self.bless(
				:content(
					:multi_declarator(
						_MultiDeclarator.new(
							$parsed.hash.<multi_declarator>
						)
					),
					:DECL(
						_DECL.new(
							$parsed.hash.<DECL>
						)
					),
					:typename(
						_TypeName.new(
							$parsed.hash.<typename>
						)
					)
				)
			)
		}
		if self.assert-hash-keys( $parsed,
					  [< package_declarator DECL >],
					  [< typename >] ) {
			return self.bless(
				:content(
					:package_declarator(
						_PackageDeclarator.new(
							$parsed.hash.<package_declarator>
						)
					),
					:DECL(
						_DECL.new(
							$parsed.hash.<DECL>
						)
					),
					:typename()
				)
			)
		}
		die self.new-term
	}
}

class _ScopeDeclarator does Node {
	method new( Mu $parsed ) {
		self.trace;
		if self.assert-hash-keys( $parsed, [< sym scoped >] ) {
			return self.bless(
				:content(
					:sym(
						_Sym.new(
							$parsed.hash.<sym>
						)
					),
					:scoped(
						_Scoped.new(
							$parsed.hash.<scoped>
						)
					)
				)
			)
		}
		die self.new-term
	}
}

class _RoutineDeclarator does Node {
	method new( Mu $parsed ) {
		self.trace;
		if self.assert-hash-keys( $parsed, [< sym method_def >] ) {
			return self.bless(
				:content(
					:sym(
						_Sym.new(
							$parsed.hash.<sym>
						)
					),
					:method_def(
						_MethodDef.new(
							$parsed.hash.<method_def>
						)
					)
				)
			)
		}
		if self.assert-hash-keys( $parsed, [< sym routine_def >] ) {
			return self.bless(
				:content(
					:sym(
						_Sym.new(
							$parsed.hash.<sym>
						)
					),
					:routine_def(
						_RoutineDef.new(
							$parsed.hash.<routine_def>
						)
					)
				)
			)
		}
		die self.new-term
	}
}

class Root does Node {
	method new( Mu $parsed ) {
		self.trace;
		if self.assert-hash-keys( $parsed, [< statementlist >] ) {
			return self.bless(
				:content(
					:statementlist(
						_StatementList.new(
							$parsed.hash.<statementlist>
						)
					)
				)
			);
		}
		die self.new-term
	}
}

class _StatementList does Node {
	method new( Mu $parsed ) {
		self.trace;
		if self.assert-hash-keys( $parsed, [< statement >] ) {
			return self.bless(
				:content(
					:statement(
						_Statement.new(
							$parsed.hash.<statement>
						)
					)
				)
			)
		}
		if self.assert-hash-keys( $parsed, [], [< statement >] ) {
			return self.bless
		}
		die self.new-term
	}
}

class _SMExpr does Node {
	method new( Mu $parsed ) {
		self.trace;
		if self.assert-hash-keys( $parsed, [< EXPR >] ) {
			return self.bless(
				:content(
					:EXPR(
						_EXPR.new(
							$parsed.hash.<EXPR>
						)
					)
				)
			)
		}
		die self.new-term
	}
}

class _ModifierExpr does Node {
	method new( Mu $parsed ) {
		self.trace;
		if self.assert-hash-keys( $parsed, [< EXPR >] ) {
			return self.bless(
				:content(
					:EXPR(
						_EXPR.new(
							$parsed.hash.<EXPR>
						)
					)
				)
			)
		}
		die self.new-term
	}
}

class _StatementModCond does Node {
	method new( Mu $parsed ) {
		self.trace;
		if self.assert-hash-keys( $parsed, [< sym modifier_expr >] ) {
			return self.bless(
				:content(
					:sym(
						_Sym.new(
							$parsed.hash.<sym>
						)
					),
					:modifier_expr(
						_ModifierExpr.new(
							$parsed.hash.<modifier_expr>
						)
					)
				)
			)
		}
		die self.new-term
	}
}

class _StatementModLoop does Node {
	method new( Mu $parsed ) {
		self.trace;
		if self.assert-hash-keys( $parsed, [< sym smexpr >] ) {
			return self.bless(
				:content(
					:sym(
						_Sym.new(
							$parsed.hash.<sym>
						)
					),
					:smexpr(
						_SMExpr.new(
							$parsed.hash.<smexpr>
						)
					)
				)
			)
		}
		die self.new-term
	}
}

# XXX This is a compound type
class _StatementModCond_EXPR does Node {
	method new( Mu $parsed ) {
		self.trace;
		if self.assert-hash-keys( $parsed, [< statement_mod_cond EXPR >] ) {
			return self.bless(
				:content(
					:statement_mod_cond(
						_StatementModCond.new(
							$parsed.hash.<statement_mod_cond>
						)
					),
					:EXPR(
						_EXPR.new(
							$parsed.hash.<EXPR>
						)
					)
				)
			)
		}
		die self.new-term
	}
}

# XXX This is a compound type
class _StatementModLoop_EXPR does Node {
	method new( Mu $parsed ) {
		self.trace;
		if self.assert-hash-keys( $parsed, [< statement_mod_loop EXPR >] ) {
			return self.bless(
				:content(
					:statement_mod_loop(
						_StatementModLoop.new(
							$parsed.hash.<statement_mod_loop>
						)
					),
					:EXPR(
						_EXPR.new(
							$parsed.hash.<EXPR>
						)
					)
				)
			)
		}
		die self.new-term
	}
}

class _Statement does Node {
	method new( Mu $parsed ) {
		self.trace;
		if $parsed.list {
			my @child;
			for $parsed.list {
				if self.assert-hash-keys( $_, [< statement_mod_loop EXPR >] ) {
					@child.push(
						_StatementModLoop_EXPR.new( $_ )
					);
					next
				}
				if self.assert-hash-keys( $_, [< statement_mod_cond EXPR >] ) {
					@child.push(
						_StatementModCond_EXPR.new(
							$_
						)
					);
					next
				}
				if self.assert-hash-keys( $_, [< EXPR >] ) {
					@child.push(
						_EXPR.new(
							$_.hash.<EXPR>
						)
					);
					next
				}
				if self.assert-hash-keys( $_, [< statement_control >] ) {
					@child.push(
						_StatementControl.new(
							$_.hash.<statement_control>
						)
					);
					next
				}
				die self.new-term
			}
			return self.bless(
				:child( @child )
			)
		}
		if self.assert-hash-keys( $parsed, [< statement_control >] ) {
			return self.bless(
				:content(
					:statement_control(
						_StatementControl.new(
							$parsed.hash.<statement_control>
						)
					)
				)
			)
		}
		if self.assert-hash-keys( $parsed, [< EXPR >] ) {
			return self.bless(
				:content(
					:EXPR(
						_EXPR.new(
							$parsed.hash.<EXPR>
						)
					)
				)
			)
		}
		die self.new-term
	}
}

class _InfixPrefixMetaOperator does Node {
	method new( Mu $parsed ) {
		self.trace;
		if self.assert-hash-keys( $parsed,
				     [< sym infixish O >] ) {
			return self.bless(
				:content(
					:sym(
						_Sym.new(
							$parsed.hash.<sym>
						)
					),
					:infixish(
						_InfixIsh.new(
							$parsed.hash.<infixish>
						)
					),
					:O(
						_O.new(
							$parsed.hash.<O>
						)
					)
				)
			)
		}
		die self.new-term
	}
}

class _Op does Node {
	method new( Mu $parsed ) {
		self.trace;
		if self.assert-hash-keys( $parsed,
				     [< infix_prefix_meta_operator OPER >] ) {
			return self.bless(
				:content(
					:infix_prefix_meta_operator(
						_InfixPrefixMetaOperator.new(
							$parsed.hash.<infix_prefix_meta_operator>
						)
					),
					:OPER(
						_OPER.new(
							$parsed.hash.<OPER>
						)
					)
				)
			)
		}
		if self.assert-hash-keys( $parsed, [< infix OPER >] ) {
			return self.bless(
				:content(
					:infix(
						_Infix.new(
							$parsed.hash.<infix>
						)
					),
					:OPER(
						_OPER.new(
							$parsed.hash.<OPER>
						)
					)
				)
			)
		}
		die self.new-term
	}
}

class _PackageDeclarator does Node {
	method new( Mu $parsed ) {
		self.trace;
		if self.assert-hash-keys( $parsed, [< sym package_def >] ) {
			return self.bless(
				:content(
					:sym(
						_Sym.new(
							$parsed.hash.<sym>
						)
					),
					:package_def(
						_PackageDef.new(
							$parsed.hash.<package_def>
						)
					)
				)
			)
		}
		die self.new-term
	}
}
