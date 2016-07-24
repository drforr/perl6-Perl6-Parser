class Perl6::Tidy::Validator {

	method assert-Bool( Mu $parsed ) {
		return False if $parsed.hash;
		return False if $parsed.list;
		return False if $parsed.Int;
		return False if $parsed.Str;

		return True if $parsed.Bool;
		die "Uncaught type"
	}

	# $parsed can only be Int, by extension Str, by extension Bool.
	#
	method assert-Int( Mu $parsed ) {
		return False if $parsed.hash;
		return False if $parsed.list;

		return True if $parsed.Int;
		die "Uncaught type"
	}

	# $parsed can only be Num, by extension Int, by extension Str, by extension Bool.
	#
	method assert-Num( Mu $parsed ) {
		return False if $parsed.hash;
		return False if $parsed.list;

		return True if $parsed.Num;
		die "Uncaught type"
	}

	# $parsed can only be Str, by extension Bool
	#
	method assert-Str( Mu $parsed ) {
		return False if $parsed.hash;
		return False if $parsed.list;
		return False if $parsed.Int;

		return True if $parsed.Str;
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

	method root( Mu $parsed ) returns Bool {
		return True if $parsed.hash.<statementlist>
			and self.statementlist( $parsed.hash.<statementlist> );
		return False
	}

	method arglist( Mu $parsed ) returns Bool {
		return True if self.assert-hash-keys( $parsed,
				[< deftermnow initializer term_init >],
				[< trait >] )
			and _DefTermNow.is-valid( $parsed.hash.<deftermnow> )
			and _Initializer.is-valid( $parsed.hash.<initializer> )
			and _TermInit.is-valid( $parsed.hash.<term_init> );
		return True if self.assert-hash-keys( $parsed, [< EXPR >] )
			and _EXPR.is-valid( $parsed.hash.<EXPR> );
		return True if self.assert-Bool( $parsed );
		return False
	}

	method args( Mu $parsed ) returns Bool {
		return True if self.assert-Bool( $parsed );
		return False
	}

	method assertion( Mu $parsed ) returns Bool {
		return True if self.assert-hash-keys( $parsed, [< var >] )
			and _Var.is-valid( $parsed.hash.<var> );
		return True if self.assert-hash-keys( $parsed, [< longname >] )
			and _LongName.is-valid( $parsed.hash.<longname> );
		return True if self.assert-hash-keys( $parsed, [< cclass_elem >] )
			and _CClassElem.is-valid( $parsed.hash.<cclass_elem> );
		return True if self.assert-hash-keys( $parsed, [< codeblock >] )
			and _CodeBlock.is-valid( $parsed.hash.<codeblock> );
		return True if $parsed.Str;
		return False
	}

	method atom( Mu $parsed ) returns Bool {
		return True if self.assert-hash-keys( $parsed, [< metachar >] )
			and _MetaChar.is-valid( $parsed.hash.<metachar> );
		return True if self.assert-Str( $parsed );
		return False
	}

	method B( Mu $parsed ) returns Bool {
		return True if self.assert-Bool( $parsed );
		return False
	}

	method babble( Mu $parsed ) returns Bool {
		return True if self.assert-hash-keys( $parsed,
				[< B >], [< quotepair >] )
			and _B.is-valid( $parsed.hash.<B> );
		return False
	}

	method backmod( Mu $parsed ) returns Bool {
		return True if self.assert-Bool( $parsed );
		return False
	}

	method backslash( Mu $parsed ) returns Bool {
		return True if self.assert-hash-keys( $parsed, [< sym >] )
			and _Sym.is-valid( $parsed.hash.<sym> );
		return True if self.assert-Str( $parsed );
		return False
	}

	method binint( Mu $parsed ) returns Bool {
		return True if $parsed.Str and $parsed.Str eq '0';
		return True if self.assert-Int( $parsed );
		return False
	}

	method block( Mu $parsed ) returns Bool {
		return True if self.assert-hash-keys( $parsed, [< blockoid >] )
			and _Blockoid.is-valid( $parsed.hash.<blockoid> );
		return False
	}

	method blockoid( Mu $parsed ) returns Bool {
		return True if self.assert-hash-keys( $parsed, [< statementlist >] )
			and _StatementList.is-valid( $parsed.hash.<statementlist> );
		return False
	}

	method blorst( Mu $parsed ) returns Bool {
		return True if self.assert-hash-keys( $parsed, [< statement >] )
			and _Statement.is-valid( $parsed.hash.<statement> );
		return True if self.assert-hash-keys( $parsed, [< block >] )
			and _Block.is-valid( $parsed.hash.<block> );
		return False
	}

	method bracket( Mu $parsed ) returns Bool {
		return True if self.assert-hash-keys( $parsed, [< semilist >] )
			and _SemiList.is-valid( $parsed.hash.<semilist> );
		return False
	}

	method cclass_elem( Mu $parsed ) returns Bool {
		if $parsed.list {
			for $parsed.list {
				next if self.assert-hash-keys( $_,
						[< identifier name sign >],
						[< charspec >] )
					and _Identifier_Name_Sign.is-valid( $_ );
				next if self.assert-hash-keys( $_,
						[< sign charspec >] )
					and _Sign_CharSpec.is-valid( $_ );
				die self.new-term
			}
			return True
		}
		return False
	}

	method charspec( Mu $parsed ) returns Bool {
# XXX work on this, of course.
		return True if $parsed.list;
		return False
	}

	method circumfix( Mu $parsed ) returns Bool {
		return True if self.assert-hash-keys( $parsed, [< nibble >] )
			and _Nibble.is-valid( $parsed.hash.<nibble> );
		return True if self.assert-hash-keys( $parsed, [< pblock >] )
			and _PBlock.is-valid( $parsed.hash.<pblock> );
		return True if self.assert-hash-keys( $parsed, [< semilist >] )
			and _SemiList.is-valid( $parsed.hash.<semilist> );
		return True if self.assert-hash-keys( $parsed, [< binint VALUE >] )
			and _BinInt.is-valid( $parsed.hash.<binint> )
			and _VALUE.is-valid( $parsed.hash.<VALUE> );
		return True if self.assert-hash-keys( $parsed, [< octint VALUE >] )
			and _OctInt.is-valid( $parsed.hash.<octint> )
			and _VALUE.is-valid( $parsed.hash.<VALUE> );
		return True if self.assert-hash-keys( $parsed, [< hexint VALUE >] )
			and _HexInt.is-valid( $parsed.hash.<hexint> )
			and _VALUE.is-valid( $parsed.hash.<VALUE> );
		return False
	}

	method codeblock( Mu $parsed ) returns Bool {
		return True if self.assert-hash-keys( $parsed, [< block >] )
			and _Block.is-valid( $parsed.hash.<block> );
		return False
	}

	method coeff( Mu $parsed ) returns Bool {
		return True if self.assert-Str( $parsed ) and
		   ( $parsed.Str eq '0.0' or
		     $parsed.Str eq '0' );
		return True if self.assert-Int( $parsed );
		return False
	}

	method coercee( Mu $parsed ) returns Bool {
		return True if self.assert-hash-keys( $parsed, [< semilist >] )
			and _SemiList.is-valid( $parsed.hash.<semilist> );
		return False
	}

	method coloncircumfix( Mu $parsed ) returns Bool {
		return True if self.assert-hash-keys( $parsed, [< circumfix >] )
			and _Circumfix.is-valid( $parsed.hash.<circumfix> );
		return False
	}

	method colonpair( Mu $parsed ) returns Bool {
		return True if self.assert-hash-keys( $parsed,
				     [< identifier coloncircumfix >] )
			and _Identifier.is-valid( $parsed.hash.<identifier> )
			and _ColonCircumfix.is-valid( $parsed.hash.<coloncircumfix> );
		return True if self.assert-hash-keys( $parsed, [< identifier >] )
			and _Identifier.is-valid( $parsed.hash.<identifier> );
		return True if self.assert-hash-keys( $parsed, [< fakesignature >] )
			and _FakeSignature.is-valid( $parsed.hash.<fakesignature> );
		return True if self.assert-hash-keys( $parsed, [< var >] )
			and _Var.is-valid( $parsed.hash.<var> );
		return False
	}

	method colonpairs( Mu $parsed ) returns Bool {
		if $parsed ~~ Hash {
			return True if $parsed.<D>;
			return True if $parsed.<U>;
		}
		return False
	}

	method contextualizer( Mu $parsed ) returns Bool {
		return True if self.assert-hash-keys( $parsed,
				[< coercee circumfix sigil >] )
			and _Coercee.is-valid( $parsed.hash.<coercee> )
			and _Circumfix.is-valid( $parsed.hash.<circumfix> )
			and _Sigil.is-valid( $parsed.hash.<sigil> );
		return False
	}

	method decint( Mu $parsed ) returns Bool {
		return True if $parsed.Str and $parsed.Str eq '0';
		return True if self.assert-Int( $parsed );
		return False
	}

	method DECL( Mu $parsed ) returns Bool {
		return True if self.assert-hash-keys( $parsed,
				[< deftermnow initializer term_init >],
				[< trait >] )
			and _DefTermNow.is-valid( $parsed.hash.<deftermnow> )
			and _Initializer.is-valid( $parsed.hash.<initializer> )
			and _TermInit.is-valid( $parsed.hash.<term_init> );
		return True if self.assert-hash-keys( $parsed,
				[< initializer signature >], [< trait >] )
			and _Initializer.is-valid( $parsed.hash.<initializer> )
			and _Signature.is-valid( $parsed.hash.<signature> );
		return True if self.assert-hash-keys( $parsed,
				  [< initializer variable_declarator >],
				  [< trait >] )
			and _Initializer.is-valid( $parsed.hash.<initializer> )
			and _VariableDeclarator.is-valid( $parsed.hash.<variable_declarator> );
		return True if self.assert-hash-keys( $parsed,
				[< variable_declarator >], [< trait >] )
			and _VariableDeclarator.is-valid( $parsed.hash.<variable_declarator> );
		return True if self.assert-hash-keys( $parsed,
				[< regex_declarator >], [< trait >] )
			and _RegexDeclarator.is-valid( $parsed.hash.<regex_declarator> );
		return True if self.assert-hash-keys( $parsed,
				[< routine_declarator >], [< trait >] )
			and _RoutineDeclarator.is-valid( $parsed.hash.<routine_declarator> );
		return True if self.assert-hash-keys( $parsed,
				[< signature >], [< trait >] )
			and _Signature.is-valid( $parsed.hash.<signature> );
		return False
	}

	method declarator( Mu $parsed ) returns Bool {
		return True if self.assert-hash-keys( $parsed,
				[< deftermnow initializer term_init >], [< trait >] )
			and _DefTermNow.is-valid( $parsed.hash.<deftermnow> )
			and _Initializer.is-valid( $parsed.hash.<initializer> )
			and _TermInit.is-valid( $parsed.hash.<term_init> );
		return True if self.assert-hash-keys( $parsed,
				[< deftermnow initializer signature >], [< trait >] )
			and _DefTermNow.is-valid( $parsed.hash.<deftermnow> )
			and _Initializer.is-valid( $parsed.hash.<initializer> )
			and _Signature.is-valid( $parsed.hash.<signature> );
		return True if self.assert-hash-keys( $parsed,
				[< initializer signature >], [< trait >] )
			and _Initializer.is-valid( $parsed.hash.<initializer> )
			and _Signature.is-valid( $parsed.hash.<signature> );
		return True if self.assert-hash-keys( $parsed,
					  [< initializer variable_declarator >],
					  [< trait >] )
			and _Initializer.is-valid( $parsed.hash.<initializer> )
			and _VariableDeclarator.is-valid( $parsed.hash.<variable_declarator> );
		return True if self.assert-hash-keys( $parsed,
				[< signature >], [< trait >] )
			and _Signature.is-valid( $parsed.hash.<signature> );
		return True if self.assert-hash-keys( $parsed,
					  [< variable_declarator >],
					  [< trait >] )
			and _VariableDeclarator.is-valid( $parsed.hash.<variable_declarator> );
		return True if self.assert-hash-keys( $parsed,
					  [< regex_declarator >],
					  [< trait >] )
			and _RegexDeclarator.is-valid( $parsed.hash.<regex_declarator> );
		return True if self.assert-hash-keys( $parsed,
					  [< routine_declarator >],
					  [< trait >] )
			and _RoutineDeclarator.is-valid( $parsed.hash.<routine_declarator> );
		return True if self.assert-hash-keys( $parsed,
					  [< package_def sym >] )
			and _PackageDef.is-valid( $parsed.hash.<package_def> )
			and _Sym.is-valid( $parsed.hash.<sym> );
		return True if self.assert-hash-keys( $parsed,
					  [< declarator >] )
			and _Declarator.is-valid( $parsed.hash.<declarator> );
		return False
	}

	method dec_number( Mu $parsed ) returns Bool {
		return True if self.assert-hash-keys( $parsed,
				  [< int coeff frac escale >] )
			and _Int.is-valid( $parsed.hash.<int> )
			and _Coeff.is-valid( $parsed.hash.<coeff> )
			and _Frac.is-valid( $parsed.hash.<frac> )
			and _EScale.is-valid( $parsed.hash.<escale> );
		return True if self.assert-hash-keys( $parsed,
				  [< coeff frac escale >] )
			and _Coeff.is-valid( $parsed.hash.<coeff> )
			and _Frac.is-valid( $parsed.hash.<frac> )
			and _EScale.is-valid( $parsed.hash.<escale> );
		return True if self.assert-hash-keys( $parsed,
				  [< int coeff frac >] )
			and _Int.is-valid( $parsed.hash.<int> )
			and _Coeff.is-valid( $parsed.hash.<coeff> )
			and _Frac.is-valid( $parsed.hash.<frac> );
		return True if self.assert-hash-keys( $parsed,
				  [< int coeff escale >] )
			and _Int.is-valid( $parsed.hash.<int> )
			and _Coeff.is-valid( $parsed.hash.<coeff> )
			and _EScale.is-valid( $parsed.hash.<escale> );
		return True if self.assert-hash-keys( $parsed,
				  [< coeff frac >] )
			and _Coeff.is-valid( $parsed.hash.<coeff> )
			and _Frac.is-valid( $parsed.hash.<frac> );
		return False
	}

	method deflongname( Mu $parsed ) returns Bool {
		return True if self.assert-hash-keys( $parsed,
				[< name >], [< colonpair >] )
			and _Name.is-valid( $parsed.hash.<name> );
		return False
	}

	method defterm( Mu $parsed ) returns Bool {
		return True if self.assert-hash-keys( $parsed,
				[< identifier colonpair >] )
			and _Identifier.is-valid( $parsed.hash.<identifier> )
			and _ColonPair.is-valid( $parsed.hash.<colonpair> );
		return True if self.assert-hash-keys( $parsed,
				[< identifier >], [< colonpair >] )
			and _Identifier.is-valid( $parsed.hash.<identifier> );
		return False
	}

	method deftermnow( Mu $parsed ) returns Bool {
		return True if self.assert-hash-keys( $parsed, [< defterm >] )
			and _DefTerm.is-valid( $parsed.hash.<defterm> );
		return False
	}

	method desigilname( Mu $parsed ) returns Bool {
		return True if self.assert-hash-keys( $parsed, [< longname >] )
			and _LongName.is-valid( $parsed.hash.<longname> );
		return True if $parsed.Str;
		return False
	}

	method dig( Mu $parsed ) returns Bool {
		if $parsed.list {
			for $parsed.list {
				# UTF-8....
				if $_ {
					# XXX
					next
				}
				else {
					next
				}
				die self.new-term
			}
			return True
		}
		return False
	}

	method doc( Mu $parsed ) returns Bool {
		return True if self.assert-Bool( $parsed );
		return False
	}

	method dotty( Mu $parsed ) returns Bool {
		return True if self.assert-hash-keys( $parsed, [< sym dottyop O >] )
			and _Sym.is-valid( $parsed.hash.<sym> )
			and _DottyOp.is-valid( $parsed.hash.<dottyop> )
			and _O.is-valid( $parsed.hash.<O> );
		return False
	}

	method dottyop( Mu $parsed ) returns Bool {
		return True if self.assert-hash-keys( $parsed,
				[< sym postop >], [< O >] )
			and _Sym.is-valid( $parsed.hash.<sym> )
			and _PostOp.is-valid( $parsed.hash.<postop> );
		return True if self.assert-hash-keys( $parsed, [< methodop >] )
			and _MethodOp.is-valid( $parsed.hash.<methodop> );
		return True if self.assert-hash-keys( $parsed, [< colonpair >] )
			and _ColonPair.is-valid( $parsed.hash.<colonpair> );
		return False
	}

	method dottyopish( Mu $parsed ) returns Bool {
		return True if self.assert-hash-keys( $parsed, [< term >] )
			and _Term.is-valid( $parsed.hash.<term> );
		return False
	}

	method e1( Mu $parsed ) returns Bool {
		return True if self.assert-hash-keys( $parsed,
				[< scope_declarator >] )
			and _ScopeDeclarator.is-valid( $parsed.hash.<scope_declarator> );
		return False
	}

	method e2( Mu $parsed ) returns Bool {
		return True if self.assert-hash-keys( $parsed,
				[< infix OPER >] )
			and _Infix.is-valid( $parsed.hash.<infix> )
			and _OPER.is-valid( $parsed.hash.<OPER> );
		return False
	}

	method e3( Mu $parsed ) returns Bool {
		return True if self.assert-hash-keys( $parsed,
				[< postfix OPER >],
				[< postfix_prefix_meta_operator >] )
			and _Postfix.is-valid( $parsed.hash.<postfix> )
			and _OPER.is-valid( $parsed.hash.<OPER> );
		return False
	}

	method else( Mu $parsed ) returns Bool {
		return True if self.assert-hash-keys( $parsed, [< sym blorst >] )
			and _Sym.is-valid( $parsed.hash.<sym> )
			and _Blorst.is-valid( $parsed.hash.<blorst> );
		return True if self.assert-hash-keys( $parsed, [< blockoid >] )
			and _Blockoid.is-valid( $parsed.hash.<blockoid> );
		return False
	}

	method escale( Mu $parsed ) returns Bool {
		return True if self.assert-hash-keys( $parsed, [< sign decint >] )
			and _Sign.is-valid( $parsed.hash.<sign> )
			and _DecInt.is-valid( $parsed.hash.<decint> );
		return False
	}

	method EXPR( Mu $parsed ) returns Bool {
		if $parsed.list {
			for $parsed.list {
				next if self.assert-hash-keys( $_,
						[< dotty OPER >],
						[< postfix_prefix_meta_operator >] )
					and _Dotty_OPER.is-valid( $_ );
				next if self.assert-hash-keys( $_,
					[< postcircumfix OPER >],
					[< postfix_prefix_meta_operator >] )
					and _PostCircumfix_OPER.is-valid( $_ );
				next if self.assert-hash-keys( $_,
						[< infix OPER >],
						[< infix_postfix_meta_operator >] )
					and _Infix_OPER.is-valid( $_ );
				next if self.assert-hash-keys( $_,
						[< prefix OPER >],
						[< prefix_postfix_meta_operator >] )
					and _Prefix_OPER.is-valid( $_ );
				next if self.assert-hash-keys( $_,
						[< postfix OPER >],
						[< postfix_prefix_meta_operator >] )
					and _Postfix_OPER.is-valid( $_ );
				next if self.assert-hash-keys( $_,
						[< identifier args >] )
					and _Identifier_Args.is-valid( $_ );
				next if self.assert-hash-keys( $_,
					[< infix_prefix_meta_operator OPER >] )
					and _InfixPrefixMetaOperator_OPER.is-valid( $_ );
				next if self.assert-hash-keys( $_,
						[< longname args >] )
					and _LongName_Args.is-valid( $_ );
				next if self.assert-hash-keys( $_,
						[< args op >] )
					and _Args_Op.is-valid( $_ );
				# XXX The *hell*?...
				# Actually it's just a consequence of how the
				# compound terms are structured.
				#
				# They really need to be singularized, but
				# until that happens, what's happening here
				# really is a hash access.
				#
				# But I'm wondering why it took breaking out
				# the validation into a separate method
				# in order to find the bug.
				next if self.assert-hash-keys( $_, [< value >] )
					and _Value.is-valid( $_.hash.<value> );
				next if self.assert-hash-keys( $_, [< longname >] )
					and _LongName.is-valid( $_.hash.<longname> );
				next if self.assert-hash-keys( $_, [< variable >] )
					and _Variable.is-valid( $_.hash.<variable> );
				next if self.assert-hash-keys( $_, [< methodop >] )
					and _MethodOp.is-valid( $_.hash.<methodop> );
				next if self.assert-hash-keys( $_, [< package_declarator >] )
					and _PackageDeclarator.is-valid( $_.hash.<package_declarator> );
				next if self.assert-hash-keys( $_, [< sym >] )
					and _Sym.is-valid( $_.hash.<sym> );
				next if self.assert-hash-keys( $_, [< scope_declarator >] )
					and _ScopeDeclarator.is-valid( $_.hash.<scope_declarator> );
				next if self.assert-hash-keys( $_, [< dotty >] )
					and _Dotty.is-valid( $_.hash.<dotty> );
				next if self.assert-hash-keys( $_, [< circumfix >] )
					and _Circumfix.is-valid( $_.hash.<circumfix> );
				next if self.assert-hash-keys( $_, [< fatarrow >] )
					and _FatArrow.is-valid( $_.hash.<fatarrow> );
				next if self.assert-hash-keys( $_, [< statement_prefix >] )
					and _StatementPrefix.is-valid( $_.hash.<statement_prefix> );
				next if self.assert-Str( $_ );
				die self.new-term
			}
			return True if self.assert-hash-keys(
					$parsed,
					[< fake_infix OPER colonpair >] )
				and _FakeInfix.is-valid( $parsed.hash.<fake_infix> )
				and _OPER.is-valid( $parsed.hash.<OPER> )
				and _ColonPair.is-valid( $parsed.hash.<colonpair> );
			return True if self.assert-hash-keys(
					$parsed,
					[< OPER dotty >],
					[< postfix_prefix_meta_operator >] )
				and _OPER.is-valid( $parsed.hash.<OPER> )
				and _Dotty.is-valid( $parsed.hash.<dotty> );
			return True if self.assert-hash-keys(
					$parsed,
					[< postfix OPER >],
					[< postfix_prefix_meta_operator >] )
				and _Postfix.is-valid( $parsed.hash.<postfix> )
				and _OPER.is-valid( $parsed.hash.<OPER> );
			return True if self.assert-hash-keys(
					$parsed,
					[< infix OPER >],
					[< prefix_postfix_meta_operator >] )
				and _Infix.is-valid( $parsed.hash.<infix> )
				and _OPER.is-valid( $parsed.hash.<OPER> );
			return True if self.assert-hash-keys(
					$parsed,
					[< prefix OPER >],
					[< prefix_postfix_meta_operator >] )
				and _Prefix.is-valid( $parsed.hash.<prefix> )
				and _OPER.is-valid( $parsed.hash.<OPER> );
			return True if self.assert-hash-keys(
					$parsed,
					[< postcircumfix OPER >],
					[< postfix_prefix_meta_operator >] )
				and _PostCircumfix.is-valid( $parsed.hash.<postcircumfix> )
				and _OPER.is-valid( $parsed.hash.<OPER> );
			return True if self.assert-hash-keys( $parsed,
					[< OPER >],
					[< infix_prefix_meta_operator >] )
				and _OPER.is-valid( $parsed.hash.<OPER> );
			die self.new-term
		}
		return True if self.assert-hash-keys( $parsed,
				[< args op triangle >] )
			and _Args.is-valid( $parsed.hash.<args> )
			and _Op.is-valid( $parsed.hash.<op> )
			and _Triangle.is-valid( $parsed.hash.<triangle> );
		return True if self.assert-hash-keys( $parsed, [< longname args >] )
			and _LongName.is-valid( $parsed.hash.<longname> )
			and _Args.is-valid( $parsed.hash.<args> );
		return True if self.assert-hash-keys( $parsed, [< identifier args >] )
			and _Identifier.is-valid( $parsed.hash.<identifier> )
			and _Args.is-valid( $parsed.hash.<args> );
		return True if self.assert-hash-keys( $parsed, [< args op >] )
			and _Args.is-valid( $parsed.hash.<args> )
			and _Op.is-valid( $parsed.hash.<op> );
		return True if self.assert-hash-keys( $parsed, [< sym args >] )
			and _Sym.is-valid( $parsed.hash.<sym> )
			and _Args.is-valid( $parsed.hash.<args> );
		return True if self.assert-hash-keys( $parsed, [< statement_prefix >] )
			and _StatementPrefix.is-valid( $parsed.hash.<statement_prefix> );
		return True if self.assert-hash-keys( $parsed, [< type_declarator >] )
			and _TypeDeclarator.is-valid( $parsed.hash.<type_declarator> );
		return True if self.assert-hash-keys( $parsed, [< longname >] )
			and _LongName.is-valid( $parsed.hash.<longname> );
		return True if self.assert-hash-keys( $parsed, [< value >] )
			and _Value.is-valid( $parsed.hash.<value> );
		return True if self.assert-hash-keys( $parsed, [< variable >] )
			and _Variable.is-valid( $parsed.hash.<variable> );
		return True if self.assert-hash-keys( $parsed, [< circumfix >] )
			and _Circumfix.is-valid( $parsed.hash.<circumfix> );
		return True if self.assert-hash-keys( $parsed, [< colonpair >] )
			and _ColonPair.is-valid( $parsed.hash.<colonpair> );
		return True if self.assert-hash-keys( $parsed, [< scope_declarator >] )
			and _ScopeDeclarator.is-valid( $parsed.hash.<scope_declarator> );
		return True if self.assert-hash-keys( $parsed, [< routine_declarator >] )
			and _RoutineDeclarator.is-valid( $parsed.hash.<routine_declarator> );
		return True if self.assert-hash-keys( $parsed, [< package_declarator >] )
			and _PackageDeclarator.is-valid( $parsed.hash.<package_declarator> );
		return True if self.assert-hash-keys( $parsed, [< fatarrow >] )
			and _FatArrow.is-valid( $parsed.hash.<fatarrow> );
		return True if self.assert-hash-keys( $parsed, [< multi_declarator >] )
			and _MultiDeclarator.is-valid( $parsed.hash.<multi_declarator> );
		return True if self.assert-hash-keys( $parsed, [< regex_declarator >] )
			and _RegexDeclarator.is-valid( $parsed.hash.<regex_declarator> );
		return True if self.assert-hash-keys( $parsed, [< dotty >] )
			and _Dotty.is-valid( $parsed.hash.<dotty> );
		return False
	}

	method fake_infix( Mu $parsed ) returns Bool {
		return True if self.assert-hash-keys( $parsed, [< O >] )
			and _O.is-valid( $parsed.hash.<O> );
		return False
	}

	method fakesignature( Mu $parsed ) returns Bool {
		return True if self.assert-hash-keys( $parsed, [< signature >] )
			and _Signature.is-valid( $parsed.hash.<signature> );
		return False
	}

	method fatarrow( Mu $parsed ) returns Bool {
		return True if self.assert-hash-keys( $parsed, [< val key >] )
			and _Val.is-valid( $parsed.hash.<val> )
			and _Key.is-valid( $parsed.hash.<key> );
		return False
	}

	method frac( Mu $parsed ) returns Bool {
		return True if $parsed.Str and $parsed.Str eq '0';
		return True if self.assert-Int( $parsed );
		return False
	}

	method hexint( Mu $parsed ) returns Bool {
		return True if $parsed.Str and $parsed.Str eq '0';
		return True if self.assert-Int( $parsed );
		return False
	}

	method identifier( Mu $parsed ) returns Bool {
		if $parsed.list {
			for $parsed.list {
				next if self.assert-Str( $_ );
				die self.new-term
			}
			return True
		}
		return True if $parsed.Str;
		return False
	}

	method infix( Mu $parsed ) returns Bool {
		return True if self.assert-hash-keys( $parsed, [< EXPR O >] )
			and _EXPR.is-valid( $parsed.hash.<EXPR> )
			and _O.is-valid( $parsed.hash.<O> );
		return True if self.assert-hash-keys( $parsed, [< infix OPER >] )
			and _Infix.is-valid( $parsed.hash.<infix> )
			and _OPER.is-valid( $parsed.hash.<OPER> );
		return True if self.assert-hash-keys( $parsed, [< sym O >] )
			and _Sym.is-valid( $parsed.hash.<sym> )
			and _O.is-valid( $parsed.hash.<O> );
		return False
	}

	method infixish( Mu $parsed ) returns Bool {
		return True if self.assert-hash-keys( $parsed, [< infix OPER >] )
			and _Infix.is-valid( $parsed.hash.<infix> )
			and _OPER.is-valid( $parsed.hash.<OPER> );
		return False
	}

	method infix_prefix_meta_operator( Mu $parsed ) returns Bool {
		return True if self.assert-hash-keys( $parsed, [< sym infixish O >] )
			and _Sym.is-valid( $parsed.hash.<sym> )
			and _Infixish.is-valid( $parsed.hash.<infixish> )
			and _O.is-valid( $parsed.hash.<O> );
		return False
	}

	method initializer( Mu $parsed ) returns Bool {
		return True if self.assert-hash-keys( $parsed, [< sym EXPR >] )
			and _Sym.is-valid( $parsed.hash.<sym> )
			and _EXPR.is-valid( $parsed.hash.<EXPR> );
		return True if self.assert-hash-keys( $parsed, [< dottyopish sym >] )
			and _DottyOpish.is-valid( $parsed.hash.<dottyopish> )
			and _Sym.is-valid( $parsed.hash.<sym> );
		return False
	}

	method int( Mu $parsed ) returns Bool {
		return True if $parsed.Str and $parsed.Str eq '0';
		return True if self.assert-Int( $parsed );
		return False
	}

	method integer( Mu $parsed ) returns Bool {
		return True if self.assert-hash-keys( $parsed,
				[< decint VALUE >] )
			and _DecInt.is-valid( $parsed.hash.<decint> )
			and _VALUE.is-valid( $parsed.hash.<VALUE> );
		return True if self.assert-hash-keys( $parsed,
				[< binint VALUE >] )
			and _BinInt.is-valid( $parsed.hash.<binint> )
			and _VALUE.is-valid( $parsed.hash.<VALUE> );
		return True if self.assert-hash-keys( $parsed,
				[< octint VALUE >] )
			and _OctInt.is-valid( $parsed.hash.<octint> )
			and _VALUE.is-valid( $parsed.hash.<VALUE> );
		return True if self.assert-hash-keys( $parsed,
				[< hexint VALUE >] )
			and _HexInt.is-valid( $parsed.hash.<hexint> )
			and _VALUE.is-valid( $parsed.hash.<VALUE> );
		return False
	}

	method key( Mu $parsed ) returns Bool {
		return True if self.assert-Str( $parsed );
		return False
	}

	method lambda( Mu $parsed ) returns Bool {
		return True if self.assert-Str( $parsed );
		return False
	}

	method left( Mu $parsed ) returns Bool {
		return True if self.assert-hash-keys( $parsed, [< termseq >] )
			and _TermSeq.is-valid( $parsed.hash.<termseq> );
		return False
	}

	method longname( Mu $parsed ) returns Bool {
		return True if self.assert-hash-keys( $parsed,
				[< name >],
				[< colonpair >] )
			and _Name.is-valid( $parsed.hash.<name> );
		return False
	}

	method max( Mu $parsed ) returns Bool {
		return True if self.assert-Str( $parsed );
		return False
	}

	method metachar( Mu $parsed ) returns Bool {
		return True if self.assert-hash-keys( $parsed, [< sym >] )
			and _Sym.is-valid( $parsed.hash.<sym> );
		return True if self.assert-hash-keys( $parsed, [< codeblock >] )
			and _CodeBlock.is-valid( $parsed.hash.<codeblock> );
		return True if self.assert-hash-keys( $parsed, [< backslash >] )
			and _BackSlash.is-valid( $parsed.hash.<backslash> );
		return True if self.assert-hash-keys( $parsed, [< assertion >] )
			and _Assertion.is-valid( $parsed.hash.<assertion> );
		return True if self.assert-hash-keys( $parsed, [< nibble >] )
			and _Nibble.is-valid( $parsed.hash.<nibble> );
		return True if self.assert-hash-keys( $parsed, [< quote >] )
			and _Quote.is-valid( $parsed.hash.<quote> );
		return True if self.assert-hash-keys( $parsed, [< nibbler >] )
			and _Nibbler.is-valid( $parsed.hash.<nibbler> );
		return True if self.assert-hash-keys( $parsed, [< statement >] )
			and _Statement.is-valid( $parsed.hash.<statement> );
		return False
	}

	method method_def( Mu $parsed ) returns Bool {
		return True if self.assert-hash-keys( $parsed,
			     [< specials longname blockoid multisig >],
			     [< trait >] )
			and _Specials.is-valid( $parsed.hash.<specials> )
			and _LongName.is-valid( $parsed.hash.<longname> )
			and _Blockoid.is-valid( $parsed.hash.<blockoid> )
			and _MultiSig.is-valid( $parsed.hash.<multisig> );
		return True if self.assert-hash-keys( $parsed,
			     [< specials longname blockoid >],
			     [< trait >] )
			and _Specials.is-valid( $parsed.hash.<specials> )
			and _LongName.is-valid( $parsed.hash.<longname> )
			and _Blockoid.is-valid( $parsed.hash.<blockoid> );
		return False
	}

	method methodop( Mu $parsed ) returns Bool {
		return True if self.assert-hash-keys( $parsed, [< longname args >] )
			and _LongName.is-valid( $parsed.hash.<longname> )
			and _Args.is-valid( $parsed.hash.<args> );
		return True if self.assert-hash-keys( $parsed, [< variable >] )
			and _Variable.is-valid( $parsed.hash.<variable> );
		return True if self.assert-hash-keys( $parsed, [< longname >] )
			and _LongName.is-valid( $parsed.hash.<longname> );
		return False
	}

	method min( Mu $parsed ) returns Bool {
		return True if self.assert-hash-keys( $parsed,
				[< decint VALUE >] )
			and _DecInt.is-valid( $parsed.hash.<decint> )
			and _VALUE.is-valid( $parsed.hash.<VALUE> );
		return False
	}

	method modifier_expr( Mu $parsed ) returns Bool {
		return True if self.assert-hash-keys( $parsed, [< EXPR >] )
			and _EXPR.is-valid( $parsed.hash.<EXPR> );
		return False
	}

	method module_name( Mu $parsed ) returns Bool {
		return True if self.assert-hash-keys( $parsed, [< longname >] )
			and _LongName.is-valid( $parsed.hash.<longname> );
		return False
	}

	method morename( Mu $parsed ) returns Bool {
		if $parsed.list {
			for $parsed.list {
				next if self.assert-hash-keys( $_,
						[< identifier >] )
					and _Identifier.is-valid( $_.hash.<identifier> );
				die self.new-term
			}
			return True
		}
		return False
	}

	method multi_declarator( Mu $parsed ) returns Bool {
		return True if self.assert-hash-keys( $parsed,
				[< sym routine_def >] )
			and _Sym.is-valid( $parsed.hash.<sym> )
			and _RoutineDef.is-valid( $parsed.hash.<routine_def> );
		return True if self.assert-hash-keys( $parsed,
				[< sym declarator >] )
			and _Sym.is-valid( $parsed.hash.<sym> )
			and _Declarator.is-valid( $parsed.hash.<declarator> );
		return True if self.assert-hash-keys( $parsed,
				[< declarator >] )
			and _Declarator.is-valid( $parsed.hash.<declarator> );
		return False
	}

	method multisig( Mu $parsed ) returns Bool {
		return True if self.assert-hash-keys( $parsed, [< signature >] )
			and _Signature.is-valid( $parsed.hash.<signature> );
		return False
	}

	method name( Mu $parsed ) returns Bool {
		return True if self.assert-hash-keys( $parsed,
			[< param_var type_constraint quant >],
			[< default_value modifier trait post_constraint >] )
			and _ParamVar.is-valid( $parsed.hash.<param_var> )
			and _TypeConstraint.is-valid( $parsed.hash.<type_constraint> )
			and _Quant.is-valid( $parsed.hash.<quant> );
		return True if self.assert-hash-keys( $parsed,
				[< identifier >], [< morename >] )
			and _Identifier.is-valid( $parsed.hash.<identifier> );
		return True if self.assert-hash-keys( $parsed,
				[< subshortname >] )
			and _SubShortName.is-valid( $parsed.hash.<subshortname> );
		return True if self.assert-hash-keys( $parsed, [< morename >] )
			and _MoreName.is-valid( $parsed.hash.<morename> );
		return True if self.assert-Str( $parsed );
		return False
	}

	method named_param( Mu $parsed ) returns Bool {
		return True if self.assert-hash-keys( $parsed,
				[< param_var >] )
			and _ParamVar.is-valid( $parsed.hash.<param_var> );
		return False
	}

	method nibble( Mu $parsed ) returns Bool {
		return True if self.assert-hash-keys( $parsed, [< termseq >] )
			and _TermSeq.is-valid( $parsed.hash.<termseq> );
		return True if $parsed.Str;
		return True if $parsed.Bool;
		return False
	}

	method nibbler( Mu $parsed ) returns Bool {
		return True if self.assert-hash-keys( $parsed, [< termseq >] )
			and _TermSeq.is-valid( $parsed.hash.<termseq> );
		return False
	}

	method normspace( Mu $parsed ) returns Bool {
		return True if self.assert-Str( $parsed );
		return False
	}

	method noun( Mu $parsed ) returns Bool {
		if $parsed.list {
			for $parsed.list {
				next if self.assert-hash-keys( $_,
					[< sigmaybe sigfinal
					   quantifier atom >] )
					and _SigMaybe_SigFinal_Quantifier_Atom.is-valid( $_ );
				next if self.assert-hash-keys( $_,
					[< sigfinal quantifier
					   separator atom >] )
					and _SigFinal_Quantifier_Separator_Atom.is-valid( $_ );
				next if self.assert-hash-keys( $_,
					[< sigmaybe sigfinal
					   separator atom >] )
					and _SigMaybe_SigFinal_Quantifier_Atom.is-valid( $_ );
				next if self.assert-hash-keys( $_,
					[< atom sigfinal quantifier >] )
					and _Atom_SigFinal_Quantifier.is-valid( $_ );
				next if self.assert-hash-keys( $_,
						[< atom >], [< sigfinal >] )
					and _Atom_SigFinal.is-valid( $_ );
				die self.new-term
			}
			return True
		}
		return False
	}

	method number( Mu $parsed ) returns Bool {
		return True if self.assert-hash-keys( $parsed, [< numish >] )
			and _Numish.is-valid( $parsed.hash.<numish> );
		return False
	}

	method numish( Mu $parsed ) returns Bool {
		return True if self.assert-hash-keys( $parsed, [< integer >] )
			and _Integer.is-valid( $parsed.hash.<integer> );
		return True if self.assert-hash-keys( $parsed, [< rad_number >] )
			and _RadNumber.is-valid( $parsed.hash.<rad_number> );
		return True if self.assert-hash-keys( $parsed, [< dec_number >] )
			and _DecNumber.is-valid( $parsed.hash.<dec_number> );
		return True if self.assert-Num( $parsed );
		return False
	}

	method O( Mu $parsed ) returns Bool {
		CATCH { when X::Multi::NoMatch { } }
		if $parsed ~~ Hash {
			return True if $parsed.<prec>
				and $parsed.<fiddly>
				and $parsed.<dba>
				and $parsed.<assoc>;
			return True if $parsed.<prec>
				and $parsed.<dba>
				and $parsed.<assoc>;
		}
		return False
	}

	method octint( Mu $parsed ) returns Bool {
		return True if $parsed.Str and $parsed.Str eq '0';
		return True if self.assert-Int( $parsed );
		return False
	}

	method op( Mu $parsed ) returns Bool {
		return True if self.assert-hash-keys( $parsed,
			     [< infix_prefix_meta_operator OPER >] )
			and _InfixPrefixMetaOperator.is-valid( $parsed.hash.<infix_prefix_meta_operator> )
			and _OPER.is-valid( $parsed.hash.<OPER> );
		return True if self.assert-hash-keys( $parsed, [< infix OPER >] )
			and _Infix.is-valid( $parsed.hash.<infix> )
			and _OPER.is-valid( $parsed.hash.<OPER> );
		return False
	}

	method OPER( Mu $parsed ) returns Bool {
		return True if self.assert-hash-keys( $parsed, [< sym dottyop O >] )
			and _Sym.is-valid( $parsed.hash.<sym> )
			and _DottyOp.is-valid( $parsed.hash.<dottyop> )
			and _O.is-valid( $parsed.hash.<O> );
		return True if self.assert-hash-keys( $parsed, [< sym infixish O >] )
			and _Sym.is-valid( $parsed.hash.<sym> )
			and _Infixish.is-valid( $parsed.hash.<infixish> )
			and _O.is-valid( $parsed.hash.<O> );
		return True if self.assert-hash-keys( $parsed, [< sym O >] )
			and _Sym.is-valid( $parsed.hash.<sym> )
			and _O.is-valid( $parsed.hash.<O> );
		return True if self.assert-hash-keys( $parsed, [< EXPR O >] )
			and _EXPR.is-valid( $parsed.hash.<EXPR> )
			and _O.is-valid( $parsed.hash.<O> );
		return True if self.assert-hash-keys( $parsed,
				[< semilist O >] )
			and _SemiList.is-valid( $parsed.hash.<semilist> )
			and _O.is-valid( $parsed.hash.<O> );
		return True if self.assert-hash-keys( $parsed, [< nibble O >] )
			and _Nibble.is-valid( $parsed.hash.<nibble> )
			and _O.is-valid( $parsed.hash.<O> );
		return True if self.assert-hash-keys( $parsed, [< arglist O >] )
			and _ArgList.is-valid( $parsed.hash.<arglist> )
			and _O.is-valid( $parsed.hash.<O> );
		return True if self.assert-hash-keys( $parsed, [< dig O >] )
			and _Dig.is-valid( $parsed.hash.<dig> )
			and _O.is-valid( $parsed.hash.<O> );
		return True if self.assert-hash-keys( $parsed, [< O >] )
			and _O.is-valid( $parsed.hash.<O> );
		return False
	}

	method package_declarator( Mu $parsed ) returns Bool {
		return True if self.assert-hash-keys( $parsed,
				[< sym package_def >] )
			and _Sym.is-valid( $parsed.hash.<sym> )
			and _PackageDef.is-valid( $parsed.hash.<package_def> );
		return False
	}

	method package_def( Mu $parsed ) returns Bool {
		return True if self.assert-hash-keys( $parsed,
				[< blockoid longname >], [< trait >] )
			and _Blockoid.is-valid( $parsed.hash.<blockoid> )
			and _LongName.is-valid( $parsed.hash.<longname> );
		return True if self.assert-hash-keys( $parsed,
				[< longname statementlist >], [< trait >] )
			and _LongName.is-valid( $parsed.hash.<longname> )
			and _StatementList.is-valid( $parsed.hash.<statementlist> );
		return True if self.assert-hash-keys( $parsed,
				[< blockoid >], [< trait >] )
			and _Blockoid.is-valid( $parsed.hash.<blockoid> );
		return False
	}

	method parameter( Mu $parsed ) returns Bool {
		if $parsed.list {
			my @child;
			for $parsed.list {
				next if self.assert-hash-keys( $_,
					[< param_var type_constraint quant >],
					[< default_value modifier trait
					   post_constraint >] )
					and _ParamVar_TypeConstraint_Quant.is-valid( $_ );
				next if self.assert-hash-keys( $_,
					[< param_var quant >],
					[< default_value modifier trait
					   type_constraint
					   post_constraint >] )
					and _ParamVar_Quant.is-valid( $_ );
				next if self.assert-hash-keys( $_,
					[< named_param quant >],
					[< default_value modifier
					   post_constraint trait
					   type_constraint >] )
					and _NamedParam_Quant.is-valid( $_ );
				next if self.assert-hash-keys( $_,
					[< defterm quant >],
					[< default_value modifier
					   post_constraint trait
					   type_constraint >] )
					and _DefTerm_Quant.is-valid( $_ );
				next if self.assert-hash-keys( $_,
					[< type_constraint >],
					[< param_var quant default_value						   modifier post_constraint trait
					   type_constraint >] )
					and _TypeConstraint.is-valid( $_.hash.<type_constraint> );
				die self.new-term
			}
			return True
		}
		return False
	}

	method param_var( Mu $parsed ) returns Bool {
		return True if self.assert-hash-keys( $parsed,
				[< name twigil sigil >] )
			and _Name.is-valid( $parsed.hash.<name> )
			and _Twigil.is-valid( $parsed.hash.<twigil> )
			and _Sigil.is-valid( $parsed.hash.<sigil> );
		return True if self.assert-hash-keys( $parsed, [< name sigil >] )
			and _Name.is-valid( $parsed.hash.<name> )
			and _Sigil.is-valid( $parsed.hash.<sigil> );
		return True if self.assert-hash-keys( $parsed, [< signature >] )
			and _Signature.is-valid( $parsed.hash.<signature> );
		return True if self.assert-hash-keys( $parsed, [< sigil >] )
			and _Sigil.is-valid( $parsed.hash.<sigil> );
		return False
	}

	method pblock( Mu $parsed ) returns Bool {
		return True if self.assert-hash-keys( $parsed,
				     [< lambda blockoid signature >] )
			and _Lambda.is-valid( $parsed.hash.<lambda> )
			and _Blockoid.is-valid( $parsed.hash.<blockoid> )
			and _Signature.is-valid( $parsed.hash.<signature> );
		return True if self.assert-hash-keys( $parsed, [< blockoid >] )
			and _Blockoid.is-valid( $parsed.hash.<blockoid> );
		return False
	}

	method postcircumfix( Mu $parsed ) returns Bool {
		return True if self.assert-hash-keys( $parsed, [< nibble O >] )
			and _Nibble.is-valid( $parsed.hash.<nibble> )
			and _O.is-valid( $parsed.hash.<O> );
		return True if self.assert-hash-keys( $parsed, [< semilist O >] )
			and _SemiList.is-valid( $parsed.hash.<semilist> )
			and _O.is-valid( $parsed.hash.<O> );
		return True if self.assert-hash-keys( $parsed, [< arglist O >] )
			and _ArgList.is-valid( $parsed.hash.<arglist> )
			and _O.is-valid( $parsed.hash.<O> );
		return False
	}

	method postfix( Mu $parsed ) returns Bool {
		return True if self.assert-hash-keys( $parsed, [< dig O >] )
			and _Dig.is-valid( $parsed.hash.<dig> )
			and _O.is-valid( $parsed.hash.<O> );
		return True if self.assert-hash-keys( $parsed, [< sym O >] )
			and _Sym.is-valid( $parsed.hash.<sym> )
			and _O.is-valid( $parsed.hash.<O> );
		return False
	}

	method postop( Mu $parsed ) returns Bool {
		return True if self.assert-hash-keys( $parsed,
				[< sym postcircumfix O >] )
			and _Sym.is-valid( $parsed.hash.<sym> )
			and _PostCircumfix.is-valid( $parsed.hash.<postcircumfix> )
			and _O.is-valid( $parsed.hash.<O> );
		return True if self.assert-hash-keys( $parsed,
				[< sym postcircumfix >], [< O >] )
			and _Sym.is-valid( $parsed.hash.<sym> )
			and _PostCircumfix.is-valid( $parsed.hash.<postcircumfix> );
		return False
	}

	method prefix( Mu $parsed ) returns Bool {
		return True if self.assert-hash-keys( $parsed, [< sym O >] )
			and _Sym.is-valid( $parsed.hash.<sym> )
			and _O.is-valid( $parsed.hash.<O> );
		return False
	}

	method quant( Mu $parsed ) returns Bool {
		return True if self.assert-Bool( $parsed );
		return False
	}

	method quantified_atom( Mu $parsed ) returns Bool {
		return True if self.assert-hash-keys( $parsed, [< sigfinal atom >] )
			and _SigFinal.is-valid( $parsed.hash.<sigfinal> )
			and _Atom.is-valid( $parsed.hash.<atom> );
		return False
	}

	method quantifier( Mu $parsed ) returns Bool {
		return True if self.assert-hash-keys( $parsed, [< sym min max backmod >] )
			and _Sym.is-valid( $parsed.hash.<sym> )
			and _Min.is-valid( $parsed.hash.<min> )
			and _Max.is-valid( $parsed.hash.<max> )
			and _BackMod.is-valid( $parsed.hash.<backmod> );
		return True if self.assert-hash-keys( $parsed, [< sym backmod >] )
			and _Sym.is-valid( $parsed.hash.<sym> )
			and _BackMod.is-valid( $parsed.hash.<backmod> );
		return False
	}

	method quibble( Mu $parsed ) returns Bool {
		return True if self.assert-hash-keys( $parsed, [< babble nibble >] )
			and _Babble.is-valid( $parsed.hash.<babble> )
			and _Nibble.is-valid( $parsed.hash.<nibble> );
		return False
	}

	method quote( Mu $parsed ) returns Bool {
		return True if self.assert-hash-keys( $parsed,
				[< sym quibble rx_adverbs >] )
			and _Sym.is-valid( $parsed.hash.<sym> )
			and _Quibble.is-valid( $parsed.hash.<quibble> )
			and _RxAdverbs.is-valid( $parsed.hash.<rx_adverbs> );
		return True if self.assert-hash-keys( $parsed,
				[< sym rx_adverbs sibble >] )
			and _Sym.is-valid( $parsed.hash.<sym> )
			and _RxAdverbs.is-valid( $parsed.hash.<rx_adverbs> )
			and _Sibble.is-valid( $parsed.hash.<sibble> );
		return True if self.assert-hash-keys( $parsed, [< nibble >] )
			and _Nibble.is-valid( $parsed.hash.<nibble> );
		return True if self.assert-hash-keys( $parsed, [< quibble >] )
			and _Quibble.is-valid( $parsed.hash.<quibble> );
		return False
	}

	method quotepair( Mu $parsed ) returns Bool {
		if $parsed.list {
			for $parsed.list {
				next if self.assert-hash-keys( $_,
					[< identifier >] )
					and _Identifier.is-valid( $_.hash.<identifier> );
				die self.new-term
			}
			return True
		}
		return True if self.assert-hash-keys( $parsed,
				[< circumfix bracket radix >], [< exp base >] )
			and _Circumfix.is-valid( $parsed.hash.<circumfix> )
			and _Bracket.is-valid( $parsed.hash.<bracket> )
			and _Radix.is-valid( $parsed.hash.<radix> );
		return True if self.assert-hash-keys( $parsed,
				[< identifier >] )
			and _Identifier.is-valid( $parsed.hash.<identifier> );
		return False
	}

	method radix( Mu $parsed ) returns Bool {
		return True if self.assert-Int( $parsed );
		return False
	}

	method rad_number( Mu $parsed ) returns Bool {
		return True if self.assert-hash-keys( $parsed,
				[< circumfix bracket radix >], [< exp base >] )
			and _Circumfix.is-valid( $parsed.hash.<circumfix> )
			and _Bracket.is-valid( $parsed.hash.<bracket> )
			and _Radix.is-valid( $parsed.hash.<radix> );
		return True if self.assert-hash-keys( $parsed,
				[< circumfix radix >], [< exp base >] )
			and _Circumfix.is-valid( $parsed.hash.<circumfix> )
			and _Radix.is-valid( $parsed.hash.<radix> );
		return False
	}

	method regex_declarator( Mu $parsed ) returns Bool {
		return True if self.assert-hash-keys( $parsed, [< sym regex_def >] )
			and _Sym.is-valid( $parsed.hash.<sym> )
			and _RegexDef.is-valid( $parsed.hash.<regex_def> );
		return False
	}

	method regex_def( Mu $parsed ) returns Bool {
		return True if self.assert-hash-keys( $parsed,
				[< deflongname nibble >],
				[< signature trait >] )
			and _DefLongName.is-valid( $parsed.hash.<deflongname> )
			and _Nibble.is-valid( $parsed.hash.<nibble> );
		return False
	}

	method right( Mu $parsed ) returns Bool {
		return True if self.assert-Bool( $parsed );
		return False
	}

	method routine_declarator( Mu $parsed ) returns Bool {
		return True if self.assert-hash-keys( $parsed, [< sym method_def >] )
			and _Sym.is-valid( $parsed.hash.<sym> )
			and _MethodDef.is-valid( $parsed.hash.<method_def> );
		return True if self.assert-hash-keys( $parsed,
				[< sym routine_def >] )
			and _Sym.is-valid( $parsed.hash.<sym> )
			and _RoutineDef.is-valid( $parsed.hash.<routine_def> );
		return False
	}

	method routine_def( Mu $parsed ) returns Bool {
		return True if self.assert-hash-keys( $parsed,
				[< blockoid deflongname multisig >],
				[< trait >] )
			and _Blockoid.is-valid( $parsed.hash.<blockoid> )
			and _DefLongName.is-valid( $parsed.hash.<deflongname> )
			and _MultiSig.is-valid( $parsed.hash.<multisig> );
		return True if self.assert-hash-keys( $parsed,
				[< blockoid deflongname >],
				[< trait >] )
			and _Blockoid.is-valid( $parsed.hash.<blockoid> )
			and _DefLongName.is-valid( $parsed.hash.<deflongname> );
		return True if self.assert-hash-keys( $parsed,
				[< blockoid multisig >],
				[< trait >] )
			and _Blockoid.is-valid( $parsed.hash.<blockoid> )
			and _MultiSig.is-valid( $parsed.hash.<multisig> );
		return True if self.assert-hash-keys( $parsed,
				[< blockoid >], [< trait >] )
			and _Blockoid.is-valid( $parsed.hash.<blockoid> );
		return False
	}

	method rx_adverbs( Mu $parsed ) returns Bool {
		return True if self.assert-hash-keys( $parsed, [< quotepair >] )
			and _QuotePair.is-valid( $parsed.hash.<quotepair> );
		return True if self.assert-hash-keys( $parsed,
				[], [< quotepair >] );
		return False
	}

	method scoped( Mu $parsed ) returns Bool {
		return True if self.assert-hash-keys( $parsed,
				[< declarator DECL >], [< typename >] )
			and _Declarator.is-valid( $parsed.hash.<declarator> )
			and _DECL.is-valid( $parsed.hash.<DECL> );
		return True if self.assert-hash-keys( $parsed,
					[< multi_declarator DECL typename >] )
			and _MultiDeclarator.is-valid( $parsed.hash.<multi_declarator> )
			and _DECL.is-valid( $parsed.hash.<DECL> )
			and _TypeName.is-valid( $parsed.hash.<typename> );
		return True if self.assert-hash-keys( $parsed,
				[< package_declarator DECL >],
				[< typename >] )
			and _PackageDeclarator.is-valid( $parsed.hash.<package_declarator> )
			and _DECL.is-valid( $parsed.hash.<DECL> );
		return False
	}

	method scope_declarator( Mu $parsed ) returns Bool {
		return True if self.assert-hash-keys( $parsed, [< sym scoped >] )
			and _Sym.is-valid( $parsed.hash.<sym> )
			and _Scoped.is-valid( $parsed.hash.<scoped> );
		return False
	}

	method semilist( Mu $parsed ) returns Bool {
		if $parsed.list {
			for $parsed.list {
				next if self.assert-hash-keys( $_,
						[< statement >] )
					and _Statement.is-valid( $_.hash.<statement> );
				die self.new-term
			}
			return True
		}
		return True if self.assert-hash-keys( $parsed, [ ], [< statement >] );
		return False
	}

	method separator( Mu $parsed ) returns Bool {
		return True if self.assert-hash-keys( $parsed,
				[< septype quantified_atom >] )
			and _SepType.is-valid( $parsed.hash.<septype> )
			and _QuantifiedAtom.is-valid( $parsed.hash.<quantified_atom> );
		return False
	}

	method septype( Mu $parsed ) returns Bool {
		return True if self.assert-Str( $parsed );
		return False
	}

	method shape( Mu $parsed ) returns Bool {
		return True if self.assert-Str( $parsed );
		return False
	}

	method sibble( Mu $parsed ) returns Bool {
		return True if self.assert-hash-keys( $parsed,
				[< right babble left >] )
			and _Right.is-valid( $parsed.hash.<right> )
			and _Babble.is-valid( $parsed.hash.<babble> )
			and _Left.is-valid( $parsed.hash.<left> );
		return False
	}

	method sigfinal( Mu $parsed ) returns Bool {
		return True if self.assert-hash-keys( $parsed, [< normspace >] )
			and _NormSpace.is-valid( $parsed.hash.<normspace> );
		return False
	}

	method sigil( Mu $parsed ) returns Bool {
		return True if self.assert-Str( $parsed );
		return False
	}

	method sigmaybe( Mu $parsed ) returns Bool {
		return True if self.assert-hash-keys( $parsed,
				[< parameter typename >],
				[< param_sep >] )
			and _Parameter.is-valid( $parsed.hash.<parameter> )
			and _TypeName.is-valid( $parsed.hash.<typename> );
		return True if self.assert-hash-keys( $parsed, [],
				[< param_sep parameter >] );
		return False
	}

	method sign( Mu $parsed ) returns Bool {
		return True if $parsed.Str
			and ( $parsed.Str eq '-' or $parsed.Str eq '+' );
		return True if self.assert-Bool( $parsed );
		return False
	}

	method signature( Mu $parsed ) returns Bool {
		return True if self.assert-hash-keys( $parsed,
				[< parameter typename >],
				[< param_sep >] )
			and _Parameter.is-valid( $parsed.hash.<parameter> )
			and _TypeName.is-valid( $parsed.hash.<typename> );
		return True if self.assert-hash-keys( $parsed,
				[< parameter >],
				[< param_sep >] )
			and _Parameter.is-valid( $parsed.hash.<parameter> );
		return True if self.assert-hash-keys( $parsed, [],
				[< param_sep parameter >] );
		return False
	}

	method smexpr( Mu $parsed ) returns Bool {
		return True if self.assert-hash-keys( $parsed, [< EXPR >] )
			and _EXPR.is-valid( $parsed.hash.<EXPR> );
		return False
	}

	method specials( Mu $parsed ) returns Bool {
		return True if self.assert-Bool( $parsed );
		return False
	}

	method statement( Mu $parsed ) returns Bool {
		if $parsed.list {
			for $parsed.list {
				next if self.assert-hash-keys( $_,
						[< statement_mod_loop EXPR >] )
					and _StatementModLoop_EXPR.is-valid( $_ );
				next if self.assert-hash-keys( $_,
						[< statement_mod_cond EXPR >] )
					and _StatementModCond_EXPR.is-valid( $_ );
				next if self.assert-hash-keys( $_, [< EXPR >] )
					and _EXPR.is-valid( $_.hash.<EXPR> );
				next if self.assert-hash-keys( $_,
						[< statement_control >] )
					and _StatementControl.is-valid( $_.hash.<statement_control> );
				next if self.assert-hash-keys( $_, [],
						[< statement_control >] );
				die self.new-term
			}
			return True
		}
		return True if self.assert-hash-keys( $parsed,
				[< statement_control >] )
			and _StatementControl.is-valid( $parsed.hash.<statement_control> );
		return True if self.assert-hash-keys( $parsed, [< EXPR >] )
			and _EXPR.is-valid( $parsed.hash.<EXPR> );
		return False
	}

	method statement_control( Mu $parsed ) returns Bool {
		return True if self.assert-hash-keys( $parsed,
				[< block sym e1 e2 e3 >] )
			and _Block.is-valid( $parsed.hash.<block> )
			and _Sym.is-valid( $parsed.hash.<sym> )
			and _E1.is-valid( $parsed.hash.<e1> )
			and _E2.is-valid( $parsed.hash.<e2> )
			and _E3.is-valid( $parsed.hash.<e3> );
		return if self.assert-hash-keys( $parsed, [< pblock sym EXPR wu >] )
			and _PBlock.is-valid( $parsed.hash.<pblock> )
			and _Sym.is-valid( $parsed.hash.<sym> )
			and _EXPR.is-valid( $parsed.hash.<EXPR> )
			and _Wu.is-valid( $parsed.hash.<wu> );
		return True if self.assert-hash-keys( $parsed, [< doc sym module_name >] )
			and _Doc.is-valid( $parsed.hash.<doc> )
			and _Sym.is-valid( $parsed.hash.<sym> )
			and _ModuleName.is-valid( $parsed.hash.<module_name> );
		return True if self.assert-hash-keys( $parsed,
				[< doc sym version >] )
			and _Doc.is-valid( $parsed.hash.<doc> )
			and _Sym.is-valid( $parsed.hash.<sym> )
			and _Version.is-valid( $parsed.hash.<version> );
		return True if self.assert-hash-keys( $parsed,
				[< sym else xblock >] )
			and _Sym.is-valid( $parsed.hash.<sym> )
			and _Else.is-valid( $parsed.hash.<else> )
			and _XBlock.is-valid( $parsed.hash.<xblock> );
		return True if self.assert-hash-keys( $parsed,
				[< xblock sym wu >] )
			and _XBlock.is-valid( $parsed.hash.<xblock> )
			and _Sym.is-valid( $parsed.hash.<sym> )
			and _Wu.is-valid( $parsed.hash.<wu> );
		return True if self.assert-hash-keys( $parsed,
				[< sym xblock >] )
			and _Sym.is-valid( $parsed.hash.<sym> )
			and _XBlock.is-valid( $parsed.hash.<xblock> );
		return True if self.assert-hash-keys( $parsed,
				[< block sym >] )
			and _Block.is-valid( $parsed.hash.<block> )
			and _Sym.is-valid( $parsed.hash.<sym> );
		return False
	}

	method statementlist( Mu $parsed ) returns Bool {
		return True if self.assert-hash-keys( $parsed, [< statement >] )
			and _Statement.is-valid( $parsed.hash.<statement> );
		return True if self.assert-hash-keys( $parsed, [], [< statement >] );
		return False
	}

	method statement_mod_cond( Mu $parsed ) returns Bool {
		return True if self.assert-hash-keys( $parsed,
				[< sym modifier_expr >] )
			and _Sym.is-valid( $parsed.hash.<sym> )
			and _ModifierExpr.is-valid( $parsed.hash.<modifier_expr> );
		return False
	}

	method statement_mod_loop( Mu $parsed ) returns Bool {
		return True if self.assert-hash-keys( $parsed, [< sym smexpr >] )
			and _Sym.is-valid( $parsed.hash.<sym> )
			and _SMExpr.is-valid( $parsed.hash.<smexpr> );
		return False
	}

	method statement_prefix( Mu $parsed ) returns Bool {
		return True if self.assert-hash-keys( $parsed, [< sym blorst >] )
			and _Sym.is-valid( $parsed.hash.<sym> )
			and _Blorst.is-valid( $parsed.hash.<blorst> );
		return False
	}

	method subshortname( Mu $parsed ) returns Bool {
		return True if self.assert-hash-keys( $parsed,
				[< desigilname >] )
			and _DeSigilName.is-valid( $parsed.hash.<desigilname> );
		return False
	}

	method sym( Mu $parsed ) returns Bool {
		if $parsed.list {
			my @child;
			for $parsed.list {
				next if $_.Str;
				die self.new-term
			}
			return True
		}
		return True if $parsed.Bool and $parsed.Str eq '+';
		return True if $parsed.Bool and $parsed.Str eq '';
		return True if self.assert-Str( $parsed );
		return False
	}

	method term( Mu $parsed ) returns Bool {
		return True if self.assert-hash-keys( $parsed, [< methodop >] )
			and _MethodOp.is-valid( $parsed.hash.<methodop> );
		return False
	}

	method termalt( Mu $parsed ) returns Bool {
		if $parsed.list {
			for $parsed.list {
				next if self.assert-hash-keys( $_, [< termconj >] )
					and _TermConj.is-valid( $_.hash.<termconj> );
				die self.new-term
			}
			return True
		}
		return False
	}

	method termaltseq( Mu $parsed ) returns Bool {
		return True if self.assert-hash-keys( $parsed, [< termconjseq >] )
			and _TermConjSeq.is-valid( $parsed.hash.<termconjseq> );
		return False
	}

	method termconj( Mu $parsed ) returns Bool {
		if $parsed.list {
			for $parsed.list {
				next if self.assert-hash-keys( $_, [< termish >] )
					and _Termish.is-valid( $_.hash.<termish> );
				die self.new-term
			}
			return True
		}
		return False
	}

	method termconjseq( Mu $parsed ) returns Bool {
		if $parsed.list {
			for $parsed.list {
				next if self.assert-hash-keys( $_, [< termalt >] )
					and _TermAlt.is-valid( $_.hash.<termalt> );
				die self.new-term
			}
			return True
		}
		return True if self.assert-hash-keys( $parsed, [< termalt >] )
			and _TermAlt.is-valid( $parsed.hash.<termalt> );
		return False
	}

	method termish( Mu $parsed ) {
		if $parsed.list {
			for $parsed.list {
				next if self.assert-hash-keys( $_, [< noun >] )
					and _Noun.is-valid( $_.hash.<noun> );
				die self.new-term
			}
			return True
		}
		return True if self.assert-hash-keys( $parsed, [< noun >] )
			and _Noun.is-valid( $parsed.hash.<noun> );
		return False
	}

	method term_init( Mu $parsed ) returns Bool {
		return True if self.assert-hash-keys( $parsed, [< sym EXPR >] )
			and _Sym.is-valid( $parsed.hash.<sym> )
			and _EXPR.is-valid( $parsed.hash.<EXPR> );
		return False
	}

	method termseq( Mu $parsed ) returns Bool {
		return True if self.assert-hash-keys( $parsed, [< termaltseq >] )
			and _TermAltSeq.is-valid( $parsed.hash.<termaltseq> );
		return False
	}

	method triangle( Mu $parsed ) returns Bool {
		return True if self.assert-Str( $parsed );
		return False
	}

	method twigil( Mu $parsed ) returns Bool {
		return True if self.assert-hash-keys( $parsed, [< sym >] )
			and _Sym.is-valid( $parsed.hash.<sym> );
		return False
	}

	method type_constraint( Mu $parsed ) returns Bool {
		if $parsed.list {
			for $parsed.list {
				next if self.assert-hash-keys( $_,
						[< typename >] )
					and _TypeName.is-valid( $_.hash.<typename> );
				next if self.assert-hash-keys( $_, [< value >] )
					and _Value.is-valid( $_.hash.<value> );
				die self.new-term
			}
			return True
		}
		return True if self.assert-hash-keys( $parsed, [< value >] )
			and _Value.is-valid( $parsed.hash.<value> );
		return True if self.assert-hash-keys( $parsed, [< typename >] )
			and _TypeName.is-valid( $parsed.hash.<typename> );
		return False
	}

	method type_declarator( Mu $parsed ) returns Bool {
		return True if self.assert-hash-keys( $parsed,
				[< sym initializer variable >], [< trait >] )
			and _Sym.is-valid( $parsed.hash.<sym> )
			and _Initializer.is-valid( $parsed.hash.<initializer> )
			and _Variable.is-valid( $parsed.hash.<variable> );
		return True if self.assert-hash-keys( $parsed,
				[< sym initializer defterm >], [< trait >] )
			and _Sym.is-valid( $parsed.hash.<sym> )
			and _Initializer.is-valid( $parsed.hash.<initializer> )
			and _DefTerm.is-valid( $parsed.hash.<defterm> );
		return True if self.assert-hash-keys( $parsed,
				[< sym initializer >] )
			and _Sym.is-valid( $parsed.hash.<sym> )
			and _Initializer.is-valid( $parsed.hash.<initializer> );
		return False
	}

	method typename( Mu $parsed ) returns Bool {
		if $parsed.list {
			for $parsed.list {
				next if self.assert-hash-keys( $_,
						[< longname colonpairs >],
						[< colonpair >] )
					and _LongName_ColonPairs.is-valid( $_ );
				next if self.assert-hash-keys( $_,
						[< longname >],
						[< colonpair >] )
					and _LongName_ColonPair.is-valid( $_ );
				die self.new-term
			}
			return True
		}
		return True if self.assert-hash-keys( $parsed,
				[< longname >], [< colonpair >] )
			and _LongName.is-valid( $parsed.hash.<longname> );
		return False
	}

	method val( Mu $parsed ) returns Bool {
		return True if self.assert-hash-keys( $parsed,
				[< prefix OPER >],
				[< prefix_postfix_meta_operator >] )
			and _Prefix.is-valid( $parsed.hash.<prefix> )
			and _OPER.is-valid( $parsed.hash.<OPER> );
		return True if self.assert-hash-keys( $parsed, [< value >] )
			and _Value.is-valid( $parsed.hash.<value> );
		return False
	}

	method value( Mu $parsed ) returns Bool {
		return True if self.assert-hash-keys( $parsed, [< number >] )
			and _Number.is-valid( $parsed.hash.<number> );
		return True if self.assert-hash-keys( $parsed, [< quote >] )
			and _Quote.is-valid( $parsed.hash.<quote> );
		return False
	}

	method VALUE( Mu $parsed ) returns Bool {
		return True if $parsed.Str and $parsed.Str eq '0';
		return True if self.assert-Int( $parsed );
		return False
	}

	method var( Mu $parsed ) returns Bool {
		return True if self.assert-hash-keys( $parsed, [< sigil desigilname >] )
			and _Sigil.is-valid( $parsed.hash.<sigil> )
			and _DeSigilName.is-valid( $parsed.hash.<desigilname> );
		return True if self.assert-hash-keys( $parsed, [< variable >] )
			and _Variable.is-valid( $parsed.hash.<variable> );
		return False
	}

	method variable( Mu $parsed ) returns Bool {
		return True if self.assert-hash-keys( $parsed,
				[< twigil sigil desigilname >] )
			and _Twigil.is-valid( $parsed.hash.<twigil> )
			and _Sigil.is-valid( $parsed.hash.<sigil> )
			and _DeSigilName.is-valid( $parsed.hash.<desigilname> );
		return True if self.assert-hash-keys( $parsed,
				[< sigil desigilname >] )
			and _Sigil.is-valid( $parsed.hash.<sigil> )
			and _DeSigilName.is-valid( $parsed.hash.<desigilname> );
		return True if self.assert-hash-keys( $parsed, [< sigil >] )
			and _Sigil.is-valid( $parsed.hash.<sigil> );
		return True if self.assert-hash-keys( $parsed, [< contextualizer >] )
			and _Contextualizer.is-valid( $parsed.hash.<contextualizer> );
		return False
	}

	method variable_declarator( Mu $parsed ) returns Bool {
		return True if self.assert-hash-keys( $parsed,
			[< semilist variable shape >],
			[< postcircumfix signature trait post_constraint >] )
			and _SemiList.is-valid( $parsed.hash.<semilist> )
			and _Variable.is-valid( $parsed.hash.<variable> )
			and _Shape.is-valid( $parsed.hash.<shape> );
		return True if self.assert-hash-keys( $parsed,
			[< variable >],
			[< semilist postcircumfix signature trait post_constraint >] )
			and _Variable.is-valid( $parsed.hash.<variable> );
		return False
	}

	method version( Mu $parsed ) returns Bool {
		return True if self.assert-hash-keys( $parsed, [< vnum vstr >] )
			and _VNum.is-valid( $parsed.hash.<vnum> )
			and _VStr.is-valid( $parsed.hash.<vstr> );
		return False
	}

	method vnum( Mu $parsed ) returns Bool {
		if $parsed.list {
			for $parsed.list {
				next if self.assert-Int( $_ );
				die self.new-term
			}
			return True
		}
		return False
	}

	method vstr( Mu $parsed ) returns Bool {
		return True if self.assert-Int( $parsed );
		return False
	}

	method wu( Mu $parsed ) returns Bool {
		return True if self.assert-Str( $parsed );
		return False
	}

	method xblock( Mu $parsed ) returns Bool {
		if $parsed.list {
			for $parsed.list {
				next if self.assert-hash-keys( $_,
						[< pblock EXPR >] )
					and _PBlock.is-valid( $_.hash.<pblock> )
					and _EXPR.is-valid( $_.hash.<EXPR> );
				die self.new-term
			}
			return True
		}
		return True if self.assert-hash-keys( $parsed,
				[< pblock EXPR >] )
			and _PBlock.is-valid( $parsed.hash.<pblock> )
			and _EXPR.is-valid( $parsed.hash.<EXPR> );
		return True if self.assert-hash-keys( $parsed, [< blockoid >] )
			and _Blockoid.is-valid( $parsed.hash.<blockoid> );
		return False
	}

}
