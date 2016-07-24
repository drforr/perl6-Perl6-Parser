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

	method _ArgList( Mu $parsed ) returns Bool {
		CATCH { when X::Hash::Store::OddNumber { } }
		return True if self.assert-hash-keys( $parsed,
				[< deftermnow initializer term_init >],
				[< trait >] )
			and self._DefTermNow( $parsed.hash.<deftermnow> )
			and self._Initializer( $parsed.hash.<initializer> )
			and self._TermInit( $parsed.hash.<term_init> );
		return True if self.assert-hash-keys( $parsed, [< EXPR >] )
			and self._EXPR( $parsed.hash.<EXPR> );
		return True if self.assert-Bool( $parsed );
		return False
	}

	method _Args( Mu $parsed ) returns Bool {
		return True if self.assert-hash-keys( $parsed,
				[< invocant semiarglist >] )
			and self._Invocant( $parsed.hash.<invocant> )
			and self._SemiArgList( $parsed.hash.<semiarglist> );
		return True if self.assert-hash-keys( $parsed,
				[< semiarglist >] )
			and self._SemiArgList( $parsed.hash.<semiarglist> );
		return True if self.assert-Bool( $parsed );
		return False
	}

	method _Assertion( Mu $parsed ) returns Bool {
		return True if self.assert-hash-keys( $parsed, [< var >] )
			and self._Var( $parsed.hash.<var> );
		return True if self.assert-hash-keys( $parsed, [< longname >] )
			and self._LongName( $parsed.hash.<longname> );
		return True if self.assert-hash-keys( $parsed,
				[< cclass_elem >] )
			and self._CClassElem( $parsed.hash.<cclass_elem> );
		return True if self.assert-hash-keys( $parsed, [< codeblock >] )
			and self._CodeBlock( $parsed.hash.<codeblock> );
		return True if $parsed.Str;
		return False
	}

	method _Atom( Mu $parsed ) returns Bool {
		return True if self.assert-hash-keys( $parsed, [< metachar >] )
			and self._MetaChar( $parsed.hash.<metachar> );
		return True if self.assert-Str( $parsed );
		return False
	}

	method _Babble( Mu $parsed ) returns Bool {
		return True if self.assert-hash-keys( $parsed,
				[< B >], [< quotepair >] )
			and self._B( $parsed.hash.<B> );
		return False
	}

	method _BackMod( Mu $parsed ) returns Bool {
		return True if self.assert-Bool( $parsed );
		return False
	}

	method _BackSlash( Mu $parsed ) returns Bool {
		return True if self.assert-hash-keys( $parsed, [< sym >] )
			and self._Sym( $parsed.hash.<sym> );
		return True if self.assert-Str( $parsed );
		return False
	}

	method _B( Mu $parsed ) returns Bool {
		return True if self.assert-Bool( $parsed );
		return False
	}

	method _BinInt( Mu $parsed ) returns Bool {
		return True if $parsed.Str and $parsed.Str eq '0';
		return True if self.assert-Int( $parsed );
		return False
	}

	method _Block( Mu $parsed ) returns Bool {
		return True if self.assert-hash-keys( $parsed, [< blockoid >] )
			and self._Blockoid( $parsed.hash.<blockoid> );
		return False
	}

	method _Blockoid( Mu $parsed ) returns Bool {
		return True if self.assert-hash-keys( $parsed,
				[< statementlist >] )
			and self._StatementList( $parsed.hash.<statementlist> );
		return False
	}

	method _Blorst( Mu $parsed ) returns Bool {
		return True if self.assert-hash-keys( $parsed, [< statement >] )
			and self._Statement( $parsed.hash.<statement> );
		return True if self.assert-hash-keys( $parsed, [< block >] )
			and self._Block( $parsed.hash.<block> );
		return False
	}

	method _Bracket( Mu $parsed ) returns Bool {
		return True if self.assert-hash-keys( $parsed, [< semilist >] )
			and self._SemiList( $parsed.hash.<semilist> );
		return False
	}

	method _CClassElem( Mu $parsed ) returns Bool {
		if $parsed.list {
			for $parsed.list {
				next if self.assert-hash-keys( $_,
						[< identifier name sign >],
						[< charspec >] )
					and self._Identifier( $_.hash.<identifier> )
					and self._Name( $_.hash.<name> )
					and self._Sign( $_.hash.<sign> );
				next if self.assert-hash-keys( $_,
						[< sign charspec >] )
					and self._Sign( $_.hash.<sign> )
					and self._CharSpec( $_.hash.<charspec> );
				return False
			}
			return True
		}
		return False
	}

	method _CharSpec( Mu $parsed ) returns Bool {
# XXX work on this, of course.
		return True if $parsed.list;
		return False
	}

	method _Circumfix( Mu $parsed ) returns Bool {
		return True if self.assert-hash-keys( $parsed, [< nibble >] )
			and self._Nibble( $parsed.hash.<nibble> );
		return True if self.assert-hash-keys( $parsed, [< pblock >] )
			and self._PBlock( $parsed.hash.<pblock> );
		return True if self.assert-hash-keys( $parsed, [< semilist >] )
			and self._SemiList( $parsed.hash.<semilist> );
		return True if self.assert-hash-keys( $parsed,
				[< binint VALUE >] )
			and self._BinInt( $parsed.hash.<binint> )
			and self._VALUE( $parsed.hash.<VALUE> );
		return True if self.assert-hash-keys( $parsed,
				[< octint VALUE >] )
			and self._OctInt( $parsed.hash.<octint> )
			and self._VALUE( $parsed.hash.<VALUE> );
		return True if self.assert-hash-keys( $parsed,
				[< hexint VALUE >] )
			and self._HexInt( $parsed.hash.<hexint> )
			and self._VALUE( $parsed.hash.<VALUE> );
		return False
	}

	method _CodeBlock( Mu $parsed ) returns Bool {
		return True if self.assert-hash-keys( $parsed, [< block >] )
			and self._Block( $parsed.hash.<block> );
		return False
	}

	method _Coeff( Mu $parsed ) returns Bool {
		return True if self.assert-Str( $parsed ) and
		   ( $parsed.Str eq '0.0' or
		     $parsed.Str eq '0' );
		return True if self.assert-Int( $parsed );
		return False
	}

	method _Coercee( Mu $parsed ) returns Bool {
		return True if self.assert-hash-keys( $parsed, [< semilist >] )
			and self._SemiList( $parsed.hash.<semilist> );
		return False
	}

	method _ColonCircumfix( Mu $parsed ) returns Bool {
		return True if self.assert-hash-keys( $parsed, [< circumfix >] )
			and self._Circumfix( $parsed.hash.<circumfix> );
		return False
	}

	method _ColonPair( Mu $parsed ) returns Bool {
		return True if self.assert-hash-keys( $parsed,
				     [< identifier coloncircumfix >] )
			and self._Identifier( $parsed.hash.<identifier> )
			and self._ColonCircumfix( $parsed.hash.<coloncircumfix> );
		return True if self.assert-hash-keys( $parsed,
				[< identifier >] )
			and self._Identifier( $parsed.hash.<identifier> );
		return True if self.assert-hash-keys( $parsed,
				[< fakesignature >] )
			and self._FakeSignature( $parsed.hash.<fakesignature> );
		return True if self.assert-hash-keys( $parsed, [< var >] )
			and self._Var( $parsed.hash.<var> );
		return False
	}

	method _ColonPairs( Mu $parsed ) {
		if $parsed ~~ Hash {
			return True if $parsed.<D>;
			return True if $parsed.<U>;
		}
		return False
	}

	method _Contextualizer( Mu $parsed ) {
		return True if self.assert-hash-keys( $parsed,
				[< coercee circumfix sigil >] )
			and self._Coercee( $parsed.hash.<coercee> )
			and self._Circumfix( $parsed.hash.<circumfix> )
			and self._Sigil( $parsed.hash.<sigil> );
		return False
	}

	method _DecInt( Mu $parsed ) {
		return True if $parsed.Str and $parsed.Str eq '0';
		return True if self.assert-Int( $parsed );
		return False
	}

	method _Declarator( Mu $parsed ) {
		return True if self.assert-hash-keys( $parsed,
				[< deftermnow initializer term_init >],
				[< trait >] )
			and self._DefTermNow( $parsed.hash.<deftermnow> )
			and self._Initializer( $parsed.hash.<initializer> )
			and self._TermInit( $parsed.hash.<term_init> );
		return True if self.assert-hash-keys( $parsed,
				[< initializer signature >], [< trait >] )
			and self._Initializer( $parsed.hash.<initializer> )
			and self._Signature( $parsed.hash.<signature> );
		return True if self.assert-hash-keys( $parsed,
				  [< initializer variable_declarator >],
				  [< trait >] )
			and self._Initializer( $parsed.hash.<initializer> )
			and self._VariableDeclarator( $parsed.hash.<variable_declarator> );
		return True if self.assert-hash-keys( $parsed,
				[< variable_declarator >], [< trait >] )
			and self._VariableDeclarator( $parsed.hash.<variable_declarator> );
		return True if self.assert-hash-keys( $parsed,
				[< regex_declarator >], [< trait >] )
			and self._RegexDeclarator( $parsed.hash.<regex_declarator> );
		return True if self.assert-hash-keys( $parsed,
				[< routine_declarator >], [< trait >] )
			and self._RoutineDeclarator( $parsed.hash.<routine_declarator> );
		return True if self.assert-hash-keys( $parsed,
				[< signature >], [< trait >] )
			and self._Signature( $parsed.hash.<signature> );
		return False
	}

	method _DECL( Mu $parsed ) {
		return True if self.assert-hash-keys( $parsed,
				[< deftermnow initializer term_init >],
				[< trait >] )
			and self._DefTermNow( $parsed.hash.<deftermnow> )
			and self._Initializer( $parsed.hash.<initializer> )
			and self._TermInit( $parsed.hash.<term_init> );
		return True if self.assert-hash-keys( $parsed,
				[< deftermnow initializer signature >],
				[< trait >] )
			and self._DefTermNow( $parsed.hash.<deftermnow> )
			and self._Initializer( $parsed.hash.<initializer> )
			and self._Signature( $parsed.hash.<signature> );
		return True if self.assert-hash-keys( $parsed,
				[< initializer signature >], [< trait >] )
			and self._Initializer( $parsed.hash.<initializer> )
			and self._Signature( $parsed.hash.<signature> );
		return True if self.assert-hash-keys( $parsed,
					  [< initializer variable_declarator >],
					  [< trait >] )
			and self._Initializer( $parsed.hash.<initializer> )
			and self._VariableDeclarator( $parsed.hash.<variable_declarator> );
		return True if self.assert-hash-keys( $parsed,
				[< signature >], [< trait >] )
			and self._Signature( $parsed.hash.<signature> );
		return True if self.assert-hash-keys( $parsed,
					  [< variable_declarator >],
					  [< trait >] )
			and self._VariableDeclarator( $parsed.hash.<variable_declarator> );
		return True if self.assert-hash-keys( $parsed,
					  [< regex_declarator >],
					  [< trait >] )
			and self._RegexDeclarator( $parsed.hash.<regex_declarator> );
		return True if self.assert-hash-keys( $parsed,
					  [< routine_declarator >],
					  [< trait >] )
			and self._RoutineDeclarator( $parsed.hash.<routine_declarator> );
		return True if self.assert-hash-keys( $parsed,
					  [< package_def sym >] )
			and self._PackageDef( $parsed.hash.<package_def> )
			and self._Sym( $parsed.hash.<sym> );
		return True if self.assert-hash-keys( $parsed,
					  [< declarator >] )
			and self._Declarator( $parsed.hash.<declarator> );
		return False
	}

	method _DecNumber( Mu $parsed ) {
		return True if self.assert-hash-keys( $parsed,
				  [< int coeff frac escale >] )
			and self._Int( $parsed.hash.<int> )
			and self._Coeff( $parsed.hash.<coeff> )
			and self._Frac( $parsed.hash.<frac> )
			and self._EScale( $parsed.hash.<escale> );
		return True if self.assert-hash-keys( $parsed,
				  [< coeff frac escale >] )
			and self._Coeff( $parsed.hash.<coeff> )
			and self._Frac( $parsed.hash.<frac> )
			and self._EScale( $parsed.hash.<escale> );
		return True if self.assert-hash-keys( $parsed,
				  [< int coeff frac >] )
			and self._Int( $parsed.hash.<int> )
			and self._Coeff( $parsed.hash.<coeff> )
			and self._Frac( $parsed.hash.<frac> );
		return True if self.assert-hash-keys( $parsed,
				  [< int coeff escale >] )
			and self._Int( $parsed.hash.<int> )
			and self._Coeff( $parsed.hash.<coeff> )
			and self._EScale( $parsed.hash.<escale> );
		return True if self.assert-hash-keys( $parsed,
				  [< coeff frac >] )
			and self._Coeff( $parsed.hash.<coeff> )
			and self._Frac( $parsed.hash.<frac> );
		return False
	}

	method _DefLongName( Mu $parsed ) {
		return True if self.assert-hash-keys( $parsed,
				[< name >], [< colonpair >] )
			and self._Name( $parsed.hash.<name> );
		return False
	}

	method _DefTerm( Mu $parsed ) {
		return True if self.assert-hash-keys( $parsed,
				[< identifier colonpair >] )
			and self._Identifier( $parsed.hash.<identifier> )
			and self._ColonPair( $parsed.hash.<colonpair> );
		return True if self.assert-hash-keys( $parsed,
				[< identifier >], [< colonpair >] )
			and self._Identifier( $parsed.hash.<identifier> );
		return False
	}

	method _DefTermNow( Mu $parsed ) {
		return True if self.assert-hash-keys( $parsed, [< defterm >] )
			and self._DefTerm( $parsed.hash.<defterm> );
		return False
	}

	method _DeSigilName( Mu $parsed ) {
		return True if self.assert-hash-keys( $parsed, [< longname >] )
			and self._LongName( $parsed.hash.<longname> );
		return True if $parsed.Str;
		return False
	}

	method _Dig( Mu $parsed ) {
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
				return False
			}
			return True
		}
		return False
	}

	method _Doc( Mu $parsed ) returns Bool {
		return True if self.assert-Bool( $parsed );
		return False
	}

	method _Dotty( Mu $parsed ) {
		return True if self.assert-hash-keys( $parsed,
				[< sym dottyop O >] )
			and self._Sym( $parsed.hash.<sym> )
			and self._DottyOp( $parsed.hash.<dottyop> )
			and self._O( $parsed.hash.<O> );
		return False
	}

	method _DottyOp( Mu $parsed ) {
		return True if self.assert-hash-keys( $parsed,
				[< sym postop >], [< O >] )
			and self._Sym( $parsed.hash.<sym> )
			and self._PostOp( $parsed.hash.<postop> );
		return True if self.assert-hash-keys( $parsed, [< methodop >] )
			and self._MethodOp( $parsed.hash.<methodop> );
		return True if self.assert-hash-keys( $parsed, [< colonpair >] )
			and self._ColonPair( $parsed.hash.<colonpair> );
		return False
	}

	method _DottyOpish( Mu $parsed ) {
		return True if self.assert-hash-keys( $parsed, [< term >] )
			and self._Term( $parsed.hash.<term> );
		return False
	}

	method _E1( Mu $parsed ) {
		return True if self.assert-hash-keys( $parsed,
				[< scope_declarator >] )
			and self._ScopeDeclarator( $parsed.hash.<scope_declarator> );
		return False
	}

	method _E2( Mu $parsed ) {
		return True if self.assert-hash-keys( $parsed,
				[< infix OPER >] )
			and self._Infix( $parsed.hash.<infix> )
			and self._OPER( $parsed.hash.<OPER> );
		return False
	}

	method _E3( Mu $parsed ) {
		return True if self.assert-hash-keys( $parsed,
				[< postfix OPER >],
				[< postfix_prefix_meta_operator >] )
			and self._Postfix( $parsed.hash.<postfix> )
			and self._OPER( $parsed.hash.<OPER> );
		return False
	}

	method _Else( Mu $parsed ) {
		return True if self.assert-hash-keys( $parsed, [< sym blorst >] )
			and self._Sym( $parsed.hash.<sym> )
			and self._Blorst( $parsed.hash.<blorst> );
		return True if self.assert-hash-keys( $parsed, [< blockoid >] )
			and self._Blockoid( $parsed.hash.<blockoid> );
		return False
	}

	method _EScale( Mu $parsed ) {
		return True if self.assert-hash-keys( $parsed,
				[< sign decint >] )
			and self._Sign( $parsed.hash.<sign> )
			and self._DecInt( $parsed.hash.<decint> );
		return False
	}

	method _EXPR( Mu $parsed ) {
		if $parsed.list {
			for $parsed.list {
				next if self.assert-hash-keys( $_,
						[< dotty OPER >],
						[< postfix_prefix_meta_operator >] )
					and self._Dotty( $_.hash.<dotty> )
					and self._OPER( $_.hash.<OPER> );
				next if self.assert-hash-keys( $_,
					[< postcircumfix OPER >],
					[< postfix_prefix_meta_operator >] )
					and self._PostCircumfix( $_.hash.<postcircumfix> )
					and self._OPER( $_.hash.<OPER> );
				next if self.assert-hash-keys( $_,
						[< infix OPER >],
						[< infix_postfix_meta_operator >] )
					and self._Infix( $_.hash.<infix> )
					and self._OPER( $_.hash.<OPER> );
				next if self.assert-hash-keys( $_,
						[< prefix OPER >],
						[< prefix_postfix_meta_operator >] )
					and self._Prefix( $_.hash.<prefix> )
					and self._OPER( $_.hash.<OPER> );
				next if self.assert-hash-keys( $_,
						[< postfix OPER >],
						[< postfix_prefix_meta_operator >] )
					and self._Postfix( $_.hash.<postfix> )
					and self._OPER( $_.hash.<OPER> );
				next if self.assert-hash-keys( $_,
						[< identifier args >] )
					and self._Identifier( $_.hash.<identifier> )
					and self._Args( $_.hash.<args> );
				next if self.assert-hash-keys( $_,
					[< infix_prefix_meta_operator OPER >] )
					and self._InfixPrefixMetaOperator( $_.hash.<infix_prefix_meta_operator> )
					and self._OPER( $_.hash.<OPER> );
				next if self.assert-hash-keys( $_,
						[< longname args >] )
					and self._LongName( $_.hash.<longname> )
					and self._Args( $_.hash.<args> );
				next if self.assert-hash-keys( $_,
						[< args op >] )
					and self._Args( $_.hash.<args> )
					and self._Op( $_.hash.<op> );
				next if self.assert-hash-keys( $_, [< value >] )
					and self._Value( $_.hash.<value> );
				next if self.assert-hash-keys( $_,
						[< longname >] )
					and self._LongName( $_.hash.<longname> );
				next if self.assert-hash-keys( $_,
						[< variable >] )
					and self._Variable( $_.hash.<variable> );
				next if self.assert-hash-keys( $_,
						[< methodop >] )
					and self._MethodOp( $_.hash.<methodop> );
				next if self.assert-hash-keys( $_,
						[< package_declarator >] )
					and self._PackageDeclarator( $_.hash.<package_declarator> );
				next if self.assert-hash-keys( $_, [< sym >] )
					and self._Sym( $_.hash.<sym> );
				next if self.assert-hash-keys( $_,
						[< scope_declarator >] )
					and self._ScopeDeclarator( $_.hash.<scope_declarator> );
				next if self.assert-hash-keys( $_, [< dotty >] )
					and self._Dotty( $_.hash.<dotty> );
				next if self.assert-hash-keys( $_,
						[< circumfix >] )
					and self._Circumfix( $_.hash.<circumfix> );
				next if self.assert-hash-keys( $_,
						[< fatarrow >] )
					and self._FatArrow( $_.hash.<fatarrow> );
				next if self.assert-hash-keys( $_,
						[< statement_prefix >] )
					and self._StatementPrefix( $_.hash.<statement_prefix> );
				next if self.assert-Str( $_ );
				return False
			}
			return True if self.assert-hash-keys(
					$parsed,
					[< fake_infix OPER colonpair >] )
				and self._FakeInfix( $parsed.hash.<fake_infix> )
				and self._OPER( $parsed.hash.<OPER> )
				and self._ColonPair( $parsed.hash.<colonpair> );
			return True if self.assert-hash-keys(
					$parsed,
					[< OPER dotty >],
					[< postfix_prefix_meta_operator >] )
				and self._OPER( $parsed.hash.<OPER> )
				and self._Dotty( $parsed.hash.<dotty> );
			return True if self.assert-hash-keys(
					$parsed,
					[< postfix OPER >],
					[< postfix_prefix_meta_operator >] )
				and self._Postfix( $parsed.hash.<postfix> )
				and self._OPER( $parsed.hash.<OPER> );
			return True if self.assert-hash-keys(
					$parsed,
					[< infix OPER >],
					[< prefix_postfix_meta_operator >] )
				and self._Infix( $parsed.hash.<infix> )
				and self._OPER( $parsed.hash.<OPER> );
			return True if self.assert-hash-keys(
					$parsed,
					[< prefix OPER >],
					[< prefix_postfix_meta_operator >] )
				and self._Prefix( $parsed.hash.<prefix> )
				and self._OPER( $parsed.hash.<OPER> );
			return True if self.assert-hash-keys(
					$parsed,
					[< postcircumfix OPER >],
					[< postfix_prefix_meta_operator >] )
				and self._PostCircumfix( $parsed.hash.<postcircumfix> )
				and self._OPER( $parsed.hash.<OPER> );
			return True if self.assert-hash-keys( $parsed,
					[< OPER >],
					[< infix_prefix_meta_operator >] )
				and self._OPER( $parsed.hash.<OPER> );
			return False
		}
		return True if self.assert-hash-keys( $parsed,
				[< args op triangle >] )
			and self._Args( $parsed.hash.<args> )
			and self._Op( $parsed.hash.<op> )
			and self._Triangle( $parsed.hash.<triangle> );
		return True if self.assert-hash-keys( $parsed,
				[< longname args >] )
			and self._LongName( $parsed.hash.<longname> )
			and self._Args( $parsed.hash.<args> );
		return True if self.assert-hash-keys( $parsed,
				[< identifier args >] )
			and self._Identifier( $parsed.hash.<identifier> )
			and self._Args( $parsed.hash.<args> );
		return True if self.assert-hash-keys( $parsed, [< args op >] )
			and self._Args( $parsed.hash.<args> )
			and self._Op( $parsed.hash.<op> );
		return True if self.assert-hash-keys( $parsed, [< sym args >] )
			and self._Sym( $parsed.hash.<sym> )
			and self._Args( $parsed.hash.<args> );
		return True if self.assert-hash-keys( $parsed,
				[< statement_prefix >] )
			and self._StatementPrefix( $parsed.hash.<statement_prefix> );
		return True if self.assert-hash-keys( $parsed,
				[< type_declarator >] )
			and self._TypeDeclarator( $parsed.hash.<type_declarator> );
		return True if self.assert-hash-keys( $parsed, [< longname >] )
			and self._LongName( $parsed.hash.<longname> );
		return True if self.assert-hash-keys( $parsed, [< value >] )
			and self._Value( $parsed.hash.<value> );
		return True if self.assert-hash-keys( $parsed, [< variable >] )
			and self._Variable( $parsed.hash.<variable> );
		return True if self.assert-hash-keys( $parsed, [< circumfix >] )
			and self._Circumfix( $parsed.hash.<circumfix> );
		return True if self.assert-hash-keys( $parsed, [< colonpair >] )
			and self._ColonPair( $parsed.hash.<colonpair> );
		return True if self.assert-hash-keys( $parsed,
				[< scope_declarator >] )
			and self._ScopeDeclarator( $parsed.hash.<scope_declarator> );
		return True if self.assert-hash-keys( $parsed,
				[< routine_declarator >] )
			and self._RoutineDeclarator( $parsed.hash.<routine_declarator> );
		return True if self.assert-hash-keys( $parsed,
				[< package_declarator >] )
			and self._PackageDeclarator( $parsed.hash.<package_declarator> );
		return True if self.assert-hash-keys( $parsed, [< fatarrow >] )
			and self._FatArrow( $parsed.hash.<fatarrow> );
		return True if self.assert-hash-keys( $parsed,
				[< multi_declarator >] )
			and self._MultiDeclarator( $parsed.hash.<multi_declarator> );
		return True if self.assert-hash-keys( $parsed,
				[< regex_declarator >] )
			and self._RegexDeclarator( $parsed.hash.<regex_declarator> );
		return True if self.assert-hash-keys( $parsed, [< dotty >] )
			and self._Dotty( $parsed.hash.<dotty> );
		return False
	}

	method _FakeInfix( Mu $parsed ) {
		return True if self.assert-hash-keys( $parsed, [< O >] )
			and self._O( $parsed.hash.<O> );
		return False
	}

	method _FakeSignature( Mu $parsed ) {
		return True if self.assert-hash-keys( $parsed, [< signature >] )
			and self._Signature( $parsed.hash.<signature> );
		return False
	}

	method _FatArrow( Mu $parsed ) {
		return True if self.assert-hash-keys( $parsed, [< val key >] )
			and self._Val( $parsed.hash.<val> )
			and self._Key( $parsed.hash.<key> );
		return False
	}

	method _Frac( Mu $parsed ) {
		return True if $parsed.Str and $parsed.Str eq '0';
		return True if self.assert-Int( $parsed );
		return False
	}

	method _HexInt( Mu $parsed ) {
		return True if $parsed.Str and $parsed.Str eq '0';
		return True if self.assert-Int( $parsed );
		return False
	}

	method _Identifier( Mu $parsed ) {
		if $parsed.list {
			for $parsed.list {
				next if self.assert-Str( $_ );
				return False
			}
			return True
		}
		return True if $parsed.Str;
		return False
	}

	method _Infix( Mu $parsed ) {
		return True if self.assert-hash-keys( $parsed, [< EXPR O >] )
			and self._EXPR( $parsed.hash.<EXPR> )
			and self._O( $parsed.hash.<O> );
		return True if self.assert-hash-keys( $parsed,
				[< infix OPER >] )
			and self._Infix( $parsed.hash.<infix> )
			and self._OPER( $parsed.hash.<OPER> );
		return True if self.assert-hash-keys( $parsed, [< sym O >] )
			and self._Sym( $parsed.hash.<sym> )
			and self._O( $parsed.hash.<O> );
		return False
	}

	method _Infixish( Mu $parsed ) {
		return True if self.assert-hash-keys( $parsed,
				[< infix OPER >] )
			and self._Infix( $parsed.hash.<infix> )
			and self._OPER( $parsed.hash.<OPER> );
		return False
	}

	method _InfixPrefixMetaOperator( Mu $parsed ) {
		return True if self.assert-hash-keys( $parsed,
				[< sym infixish O >] )
			and self._Sym( $parsed.hash.<sym> )
			and self._Infixish( $parsed.hash.<infixish> )
			and self._O( $parsed.hash.<O> );
		return False
	}

	method _Initializer( Mu $parsed ) {
		return True if self.assert-hash-keys( $parsed, [< sym EXPR >] )
			and self._Sym( $parsed.hash.<sym> )
			and self._EXPR( $parsed.hash.<EXPR> );
		return True if self.assert-hash-keys( $parsed,
				[< dottyopish sym >] )
			and self._DottyOpish( $parsed.hash.<dottyopish> )
			and self._Sym( $parsed.hash.<sym> );
		return False
	}

	method _Int( Mu $parsed ) {
		return True if $parsed.Str and $parsed.Str eq '0';
		return True if self.assert-Int( $parsed );
		return False
	}

	method _Integer( Mu $parsed ) {
		return True if self.assert-hash-keys( $parsed,
				[< decint VALUE >] )
			and self._DecInt( $parsed.hash.<decint> )
			and self._VALUE( $parsed.hash.<VALUE> );
		return True if self.assert-hash-keys( $parsed,
				[< binint VALUE >] )
			and self._BinInt( $parsed.hash.<binint> )
			and self._VALUE( $parsed.hash.<VALUE> );
		return True if self.assert-hash-keys( $parsed,
				[< octint VALUE >] )
			and self._OctInt( $parsed.hash.<octint> )
			and self._VALUE( $parsed.hash.<VALUE> );
		return True if self.assert-hash-keys( $parsed,
				[< hexint VALUE >] )
			and self._HexInt( $parsed.hash.<hexint> )
			and self._VALUE( $parsed.hash.<VALUE> );
		return False
	}

	method _Invocant( Mu $parsed ) {
		#return True if $parsed ~~ QAST::Want;
		#return True if self.assert-hash-keys( $parsed, [< XXX >] )
		#	and self._VALUE( $parsed.hash.<XXX> );
		#return False
# XXX Fixme
		return True
	}

	method _Key( Mu $parsed ) returns Bool {
		return True if self.assert-Str( $parsed );
		return False
	}

	method _Lambda( Mu $parsed ) returns Bool {
		return True if self.assert-Str( $parsed );
		return False
	}

	method _Left( Mu $parsed ) {
		return True if self.assert-hash-keys( $parsed, [< termseq >] )
			and self._TermSeq( $parsed.hash.<termseq> );
		return False
	}

	method _LongName( Mu $parsed ) {
		return True if self.assert-hash-keys( $parsed,
				[< name >],
				[< colonpair >] )
			and self._Name( $parsed.hash.<name> );
		return False
	}

	method _Max( Mu $parsed ) returns Bool {
		return True if self.assert-Str( $parsed );
		return False
	}

	method _MetaChar( Mu $parsed ) {
		return True if self.assert-hash-keys( $parsed, [< sym >] )
			and self._Sym( $parsed.hash.<sym> );
		return True if self.assert-hash-keys( $parsed, [< codeblock >] )
			and self._CodeBlock( $parsed.hash.<codeblock> );
		return True if self.assert-hash-keys( $parsed, [< backslash >] )
			and self._BackSlash( $parsed.hash.<backslash> );
		return True if self.assert-hash-keys( $parsed, [< assertion >] )
			and self._Assertion( $parsed.hash.<assertion> );
		return True if self.assert-hash-keys( $parsed, [< nibble >] )
			and self._Nibble( $parsed.hash.<nibble> );
		return True if self.assert-hash-keys( $parsed, [< quote >] )
			and self._Quote( $parsed.hash.<quote> );
		return True if self.assert-hash-keys( $parsed, [< nibbler >] )
			and self._Nibbler( $parsed.hash.<nibbler> );
		return True if self.assert-hash-keys( $parsed, [< statement >] )
			and self._Statement( $parsed.hash.<statement> );
		return False
	}

	method _MethodDef( Mu $parsed ) {
		return True if self.assert-hash-keys( $parsed,
			     [< specials longname blockoid multisig >],
			     [< trait >] )
			and self._Specials( $parsed.hash.<specials> )
			and self._LongName( $parsed.hash.<longname> )
			and self._Blockoid( $parsed.hash.<blockoid> )
			and self._MultiSig( $parsed.hash.<multisig> );
		return True if self.assert-hash-keys( $parsed,
			     [< specials longname blockoid >],
			     [< trait >] )
			and self._Specials( $parsed.hash.<specials> )
			and self._LongName( $parsed.hash.<longname> )
			and self._Blockoid( $parsed.hash.<blockoid> );
		return False
	}

	method _MethodOp( Mu $parsed ) {
		return True if self.assert-hash-keys( $parsed,
				[< longname args >] )
			and self._LongName( $parsed.hash.<longname> )
			and self._Args( $parsed.hash.<args> );
		return True if self.assert-hash-keys( $parsed, [< variable >] )
			and self._Variable( $parsed.hash.<variable> );
		return True if self.assert-hash-keys( $parsed, [< longname >] )
			and self._LongName( $parsed.hash.<longname> );
		return False
	}

	method _Min( Mu $parsed ) {
		return True if self.assert-hash-keys( $parsed,
				[< decint VALUE >] )
			and self._DecInt( $parsed.hash.<decint> )
			and self._VALUE( $parsed.hash.<VALUE> );
		return False
	}

	method _ModifierExpr( Mu $parsed ) {
		return True if self.assert-hash-keys( $parsed, [< EXPR >] )
			and self._EXPR( $parsed.hash.<EXPR> );
		return False
	}

	method _ModuleName( Mu $parsed ) {
		return True if self.assert-hash-keys( $parsed, [< longname >] )
			and self._LongName( $parsed.hash.<longname> );
		return False
	}

	method _MoreName( Mu $parsed ) {
		if $parsed.list {
			for $parsed.list {
				next if self.assert-hash-keys( $_,
						[< identifier >] )
					and self._Identifier( $_.hash.<identifier> );
				return False
			}
			return True
		}
		return False
	}

	method _MultiDeclarator( Mu $parsed ) {
		return True if self.assert-hash-keys( $parsed,
				[< sym routine_def >] )
			and self._Sym( $parsed.hash.<sym> )
			and self._RoutineDef( $parsed.hash.<routine_def> );
		return True if self.assert-hash-keys( $parsed,
				[< sym declarator >] )
			and self._Sym( $parsed.hash.<sym> )
			and self._Declarator( $parsed.hash.<declarator> );
		return True if self.assert-hash-keys( $parsed,
				[< declarator >] )
			and self._Declarator( $parsed.hash.<declarator> );
		return False
	}

	method _MultiSig( Mu $parsed ) {
		return True if self.assert-hash-keys( $parsed, [< signature >] )
			and self._Signature( $parsed.hash.<signature> );
		return False
	}

	method _NamedParam( Mu $parsed ) {
		return True if self.assert-hash-keys( $parsed,
				[< param_var >] )
			and self._ParamVar( $parsed.hash.<param_var> );
		return False
	}

	method _Name( Mu $parsed ) {
		return True if self.assert-hash-keys( $parsed,
			[< param_var type_constraint quant >],
			[< default_value modifier trait post_constraint >] )
			and self._ParamVar( $parsed.hash.<param_var> )
			and self._TypeConstraint( $parsed.hash.<type_constraint> )
			and self._Quant( $parsed.hash.<quant> );
		return True if self.assert-hash-keys( $parsed,
				[< identifier >], [< morename >] )
			and self._Identifier( $parsed.hash.<identifier> );
		return True if self.assert-hash-keys( $parsed,
				[< subshortname >] )
			and self._SubShortName( $parsed.hash.<subshortname> );
		return True if self.assert-hash-keys( $parsed, [< morename >] )
			and self._MoreName( $parsed.hash.<morename> );
		return True if self.assert-Str( $parsed );
		return False
	}

	method _Nibble( Mu $parsed ) {
		return True if self.assert-hash-keys( $parsed, [< termseq >] )
			and self._TermSeq( $parsed.hash.<termseq> );
		return True if $parsed.Str;
		return True if $parsed.Bool;
		return False
	}

	method _Nibbler( Mu $parsed ) {
		return True if self.assert-hash-keys( $parsed, [< termseq >] )
			and self._TermSeq( $parsed.hash.<termseq> );
		return False
	}

	method _NormSpace( Mu $parsed ) returns Bool {
		return True if self.assert-Str( $parsed );
		return False
	}

	method _Noun( Mu $parsed ) {
		if $parsed.list {
			for $parsed.list {
				next if self.assert-hash-keys( $_,
					[< sigmaybe sigfinal
					   quantifier atom >] )
					and self._SigMaybe( $_.hash.<sigmaybe> )
					and self._SigFinal( $_.hash.<sigfinal> )
					and self._Quantifier( $_.hash.<quantifier> )
					and self._Atom( $_.hash.<atom> );
				next if self.assert-hash-keys( $_,
					[< sigfinal quantifier
					   separator atom >] )
					and self._SigFinal( $_.hash.<sigfinal> )
					and self._Quantifier( $_.hash.<quantifier> )
					and self._Separator( $_.hash.<separator> )
					and self._Atom( $_.hash.<atom> );
				next if self.assert-hash-keys( $_,
					[< sigmaybe sigfinal
					   separator atom >] )
					and self._SigMaybe( $_.hash.<sigmaybe> )
					and self._SigFinal( $_.hash.<sigfinal> )
					and self._Separator( $_.hash.<separator> )
					and self._Atom( $_.hash.<atom> );
				next if self.assert-hash-keys( $_,
					[< atom sigfinal quantifier >] )
					and self._Atom( $_.hash.<atom> )
					and self._SigFinal( $_.hash.<sigfinal> )
					and self._Quantifier( $_.hash.<quantifier> );
				next if self.assert-hash-keys( $_,
						[< atom >], [< sigfinal >] )
					and self._Atom( $_.hash.<atom> );
				return False
			}
			return True
		}
		return False
	}

	method _Number( Mu $parsed ) {
		return True if self.assert-hash-keys( $parsed, [< numish >] )
			and self._Numish( $parsed.hash.<numish> );
		return False
	}

	method _Numish( Mu $parsed ) {
		return True if self.assert-hash-keys( $parsed, [< integer >] )
			and self._Integer( $parsed.hash.<integer> );
		return True if self.assert-hash-keys( $parsed,
				[< rad_number >] )
			and self._RadNumber( $parsed.hash.<rad_number> );
		return True if self.assert-hash-keys( $parsed,
				[< dec_number >] )
			and self._DecNumber( $parsed.hash.<dec_number> );
		return True if self.assert-Num( $parsed );
		return False
	}

	method _OctInt( Mu $parsed ) {
		return True if $parsed.Str and $parsed.Str eq '0';
		return True if self.assert-Int( $parsed );
		return False
	}

	method _O( Mu $parsed ) {
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

	method _Op( Mu $parsed ) {
		return True if self.assert-hash-keys( $parsed,
			     [< infix_prefix_meta_operator OPER >] )
			and self._InfixPrefixMetaOperator( $parsed.hash.<infix_prefix_meta_operator> )
			and self._OPER( $parsed.hash.<OPER> );
		return True if self.assert-hash-keys( $parsed, [< infix OPER >] )
			and self._Infix( $parsed.hash.<infix> )
			and self._OPER( $parsed.hash.<OPER> );
		return False
	}

	method _OPER( Mu $parsed ) {
		return True if self.assert-hash-keys( $parsed,
				[< sym dottyop O >] )
			and self._Sym( $parsed.hash.<sym> )
			and self._DottyOp( $parsed.hash.<dottyop> )
			and self._O( $parsed.hash.<O> );
		return True if self.assert-hash-keys( $parsed,
				[< sym infixish O >] )
			and self._Sym( $parsed.hash.<sym> )
			and self._Infixish( $parsed.hash.<infixish> )
			and self._O( $parsed.hash.<O> );
		return True if self.assert-hash-keys( $parsed, [< sym O >] )
			and self._Sym( $parsed.hash.<sym> )
			and self._O( $parsed.hash.<O> );
		return True if self.assert-hash-keys( $parsed, [< EXPR O >] )
			and self._EXPR( $parsed.hash.<EXPR> )
			and self._O( $parsed.hash.<O> );
		return True if self.assert-hash-keys( $parsed,
				[< semilist O >] )
			and self._SemiList( $parsed.hash.<semilist> )
			and self._O( $parsed.hash.<O> );
		return True if self.assert-hash-keys( $parsed, [< nibble O >] )
			and self._Nibble( $parsed.hash.<nibble> )
			and self._O( $parsed.hash.<O> );
		return True if self.assert-hash-keys( $parsed, [< arglist O >] )
			and self._ArgList( $parsed.hash.<arglist> )
			and self._O( $parsed.hash.<O> );
		return True if self.assert-hash-keys( $parsed, [< dig O >] )
			and self._Dig( $parsed.hash.<dig> )
			and self._O( $parsed.hash.<O> );
		return True if self.assert-hash-keys( $parsed, [< O >] )
			and self._O( $parsed.hash.<O> );
		return False
	}

	method _PackageDeclarator( Mu $parsed ) {
		return True if self.assert-hash-keys( $parsed,
				[< sym package_def >] )
			and self._Sym( $parsed.hash.<sym> )
			and self._PackageDef( $parsed.hash.<package_def> );
		return False
	}

	method _PackageDef( Mu $parsed ) {
		return True if self.assert-hash-keys( $parsed,
				[< blockoid longname >], [< trait >] )
			and self._Blockoid( $parsed.hash.<blockoid> )
			and self._LongName( $parsed.hash.<longname> );
		return True if self.assert-hash-keys( $parsed,
				[< longname statementlist >], [< trait >] )
			and self._LongName( $parsed.hash.<longname> )
			and self._StatementList( $parsed.hash.<statementlist> );
		return True if self.assert-hash-keys( $parsed,
				[< blockoid >], [< trait >] )
			and self._Blockoid( $parsed.hash.<blockoid> );
		return False
	}

	method _Parameter( Mu $parsed ) {
		if $parsed.list {
			my @child;
			for $parsed.list {
				next if self.assert-hash-keys( $_,
					[< param_var type_constraint quant >],
					[< default_value modifier trait
					   post_constraint >] )
					and self._ParamVar( $_.hash.<param_var> )
					and self._TypeConstraint( $_.hash.<type_constraint> )
					and self._Quant( $_.hash.<quant> );
				next if self.assert-hash-keys( $_,
					[< param_var quant >],
					[< default_value modifier trait
					   type_constraint
					   post_constraint >] )
					and self._ParamVar( $_.hash.<param_var> )
					and self._Quant( $_.hash.<quant> );
	
				next if self.assert-hash-keys( $_,
					[< named_param quant >],
					[< default_value modifier
					   post_constraint trait
					   type_constraint >] )
					and self._NamedParam( $_.hash.<named_param> )
					and self._Quant( $_.hash.<quant> );
				next if self.assert-hash-keys( $_,
					[< defterm quant >],
					[< default_value modifier
					   post_constraint trait
					   type_constraint >] )
					and self._DefTerm( $_.hash.<defterm> )
					and self._Quant( $_.hash.<quant> );
				next if self.assert-hash-keys( $_,
					[< type_constraint >],
					[< param_var quant default_value						   modifier post_constraint trait
					   type_constraint >] )
					and self._TypeConstraint( $_.hash.<type_constraint> );
				return False
			}
			return True
		}
		return False
	}

	method _ParamVar( Mu $parsed ) {
		return True if self.assert-hash-keys( $parsed,
				[< name twigil sigil >] )
			and self._Name( $parsed.hash.<name> )
			and self._Twigil( $parsed.hash.<twigil> )
			and self._Sigil( $parsed.hash.<sigil> );
		return True if self.assert-hash-keys( $parsed, [< name sigil >] )
			and self._Name( $parsed.hash.<name> )
			and self._Sigil( $parsed.hash.<sigil> );
		return True if self.assert-hash-keys( $parsed, [< signature >] )
			and self._Signature( $parsed.hash.<signature> );
		return True if self.assert-hash-keys( $parsed, [< sigil >] )
			and self._Sigil( $parsed.hash.<sigil> );
		return False
	}

	method _PBlock( Mu $parsed ) {
		return True if self.assert-hash-keys( $parsed,
				     [< lambda blockoid signature >] )
			and self._Lambda( $parsed.hash.<lambda> )
			and self._Blockoid( $parsed.hash.<blockoid> )
			and self._Signature( $parsed.hash.<signature> );
		return True if self.assert-hash-keys( $parsed, [< blockoid >] )
			and self._Blockoid( $parsed.hash.<blockoid> );
		return False
	}

	method _PostCircumfix( Mu $parsed ) {
		return True if self.assert-hash-keys( $parsed, [< nibble O >] )
			and self._Nibble( $parsed.hash.<nibble> )
			and self._O( $parsed.hash.<O> );
		return True if self.assert-hash-keys( $parsed, [< semilist O >] )
			and self._SemiList( $parsed.hash.<semilist> )
			and self._O( $parsed.hash.<O> );
		return True if self.assert-hash-keys( $parsed, [< arglist O >] )
			and self._ArgList( $parsed.hash.<arglist> )
			and self._O( $parsed.hash.<O> );
		return False
	}

	method _Postfix( Mu $parsed ) {
		return True if self.assert-hash-keys( $parsed, [< dig O >] )
			and self._Dig( $parsed.hash.<dig> )
			and self._O( $parsed.hash.<O> );
		return True if self.assert-hash-keys( $parsed, [< sym O >] )
			and self._Sym( $parsed.hash.<sym> )
			and self._O( $parsed.hash.<O> );
		return False
	}

	method _PostOp( Mu $parsed ) {
		return True if self.assert-hash-keys( $parsed,
				[< sym postcircumfix O >] )
			and self._Sym( $parsed.hash.<sym> )
			and self._PostCircumfix( $parsed.hash.<postcircumfix> )
			and self._O( $parsed.hash.<O> );
		return True if self.assert-hash-keys( $parsed,
				[< sym postcircumfix >], [< O >] )
			and self._Sym( $parsed.hash.<sym> )
			and self._PostCircumfix( $parsed.hash.<postcircumfix> );
		return False
	}

	method _Prefix( Mu $parsed ) {
		return True if self.assert-hash-keys( $parsed, [< sym O >] )
			and self._Sym( $parsed.hash.<sym> )
			and self._O( $parsed.hash.<O> );
		return False
	}

	method _Quant( Mu $parsed ) returns Bool {
		return True if self.assert-Bool( $parsed );
		return False
	}


	method _QuantifiedAtom( Mu $parsed ) {
		return True if self.assert-hash-keys( $parsed,
				[< sigfinal atom >] )
			and self._SigFinal( $parsed.hash.<sigfinal> )
			and self._Atom( $parsed.hash.<atom> );
		return False
	}

	method _Quantifier( Mu $parsed ) {
		return True if self.assert-hash-keys( $parsed,
				[< sym min max backmod >] )
			and self._Sym( $parsed.hash.<sym> )
			and self._Min( $parsed.hash.<min> )
			and self._Max( $parsed.hash.<max> )
			and self._BackMod( $parsed.hash.<backmod> );
		return True if self.assert-hash-keys( $parsed,
				[< sym backmod >] )
			and self._Sym( $parsed.hash.<sym> )
			and self._BackMod( $parsed.hash.<backmod> );
		return False
	}

	method _Quibble( Mu $parsed ) {
		return True if self.assert-hash-keys( $parsed,
				[< babble nibble >] )
			and self._Babble( $parsed.hash.<babble> )
			and self._Nibble( $parsed.hash.<nibble> );
		return False
	}

	method _Quote( Mu $parsed ) {
		return True if self.assert-hash-keys( $parsed,
				[< sym quibble rx_adverbs >] )
			and self._Sym( $parsed.hash.<sym> )
			and self._Quibble( $parsed.hash.<quibble> )
			and self._RxAdverbs( $parsed.hash.<rx_adverbs> );
		return True if self.assert-hash-keys( $parsed,
				[< sym rx_adverbs sibble >] )
			and self._Sym( $parsed.hash.<sym> )
			and self._RxAdverbs( $parsed.hash.<rx_adverbs> )
			and self._Sibble( $parsed.hash.<sibble> );
		return True if self.assert-hash-keys( $parsed, [< nibble >] )
			and self._Nibble( $parsed.hash.<nibble> );
		return True if self.assert-hash-keys( $parsed, [< quibble >] )
			and self._Quibble( $parsed.hash.<quibble> );
		return False
	}

	method _QuotePair( Mu $parsed ) {
		if $parsed.list {
			for $parsed.list {
				next if self.assert-hash-keys( $_,
					[< identifier >] )
					and self._Identifier( $_.hash.<identifier> );
				return False
			}
			return True
		}
		return True if self.assert-hash-keys( $parsed,
				[< circumfix bracket radix >], [< exp base >] )
			and self._Circumfix( $parsed.hash.<circumfix> )
			and self._Bracket( $parsed.hash.<bracket> )
			and self._Radix( $parsed.hash.<radix> );
		return True if self.assert-hash-keys( $parsed,
				[< identifier >] )
			and self._Identifier( $parsed.hash.<identifier> );
		return False
	}

	method _Radix( Mu $parsed ) returns Bool {
		return True if self.assert-Int( $parsed );
		return False
	}

	method _RadNumber( Mu $parsed ) {
		return True if self.assert-hash-keys( $parsed,
				[< circumfix bracket radix >], [< exp base >] )
			and self._Circumfix( $parsed.hash.<circumfix> )
			and self._Bracket( $parsed.hash.<bracket> )
			and self._Radix( $parsed.hash.<radix> );
		return True if self.assert-hash-keys( $parsed,
				[< circumfix radix >], [< exp base >] )
			and self._Circumfix( $parsed.hash.<circumfix> )
			and self._Radix( $parsed.hash.<radix> );
		return False
	}

	method _RegexDeclarator( Mu $parsed ) {
		return True if self.assert-hash-keys( $parsed,
				[< sym regex_def >] )
			and self._Sym( $parsed.hash.<sym> )
			and self._RegexDef( $parsed.hash.<regex_def> );
		return False
	}

	method _RegexDef( Mu $parsed ) {
		return True if self.assert-hash-keys( $parsed,
				[< deflongname nibble >],
				[< signature trait >] )
			and self._DefLongName( $parsed.hash.<deflongname> )
			and self._Nibble( $parsed.hash.<nibble> );
		return False
	}

	method _Right( Mu $parsed ) {
		return True if self.assert-Bool( $parsed );
		return False
	}

	method Root( Mu $parsed ) {
		return True if self.assert-hash-keys( $parsed,
				[< statementlist >] )
			and self._StatementList( $parsed.hash.<statementlist> );
		return False
	}

	method _RoutineDeclarator( Mu $parsed ) {
		return True if self.assert-hash-keys( $parsed,
				[< sym method_def >] )
			and self._Sym( $parsed.hash.<sym> )
			and self._MethodDef( $parsed.hash.<method_def> );
		return True if self.assert-hash-keys( $parsed,
				[< sym routine_def >] )
			and self._Sym( $parsed.hash.<sym> )
			and self._RoutineDef( $parsed.hash.<routine_def> );
		return False
	}

	method _RoutineDef( Mu $parsed ) {
		return True if self.assert-hash-keys( $parsed,
				[< blockoid deflongname multisig >],
				[< trait >] )
			and self._Blockoid( $parsed.hash.<blockoid> )
			and self._DefLongName( $parsed.hash.<deflongname> )
			and self._MultiSig( $parsed.hash.<multisig> );
		return True if self.assert-hash-keys( $parsed,
				[< blockoid deflongname >],
				[< trait >] )
			and self._Blockoid( $parsed.hash.<blockoid> )
			and self._DefLongName( $parsed.hash.<deflongname> );
		return True if self.assert-hash-keys( $parsed,
				[< blockoid multisig >],
				[< trait >] )
			and self._Blockoid( $parsed.hash.<blockoid> )
			and self._MultiSig( $parsed.hash.<multisig> );
		return True if self.assert-hash-keys( $parsed,
				[< blockoid >], [< trait >] )
			and self._Blockoid( $parsed.hash.<blockoid> );
		return False
	}

	method _RxAdverbs( Mu $parsed ) {
		return True if self.assert-hash-keys( $parsed, [< quotepair >] )
			and self._QuotePair( $parsed.hash.<quotepair> );
		return True if self.assert-hash-keys( $parsed,
				[], [< quotepair >] );
		return False
	}

	method _Scoped( Mu $parsed ) {
		return True if self.assert-hash-keys( $parsed,
				[< declarator DECL >], [< typename >] )
			and self._Declarator( $parsed.hash.<declarator> )
			and self._DECL( $parsed.hash.<DECL> );
		return True if self.assert-hash-keys( $parsed,
					[< multi_declarator DECL typename >] )
			and self._MultiDeclarator( $parsed.hash.<multi_declarator> )
			and self._DECL( $parsed.hash.<DECL> )
			and self._TypeName( $parsed.hash.<typename> );
		return True if self.assert-hash-keys( $parsed,
				[< package_declarator DECL >],
				[< typename >] )
			and self._PackageDeclarator( $parsed.hash.<package_declarator> )
			and self._DECL( $parsed.hash.<DECL> );
		return False
	}

	method _ScopeDeclarator( Mu $parsed ) {
		return True if self.assert-hash-keys( $parsed,
				[< sym scoped >] )
			and self._Sym( $parsed.hash.<sym> )
			and self._Scoped( $parsed.hash.<scoped> );
		return False
	}

	method _SemiArgList( Mu $parsed ) {
		next if self.assert-hash-keys( $parsed, [< arglist >] )
			and self._ArgList( $parsed.hash.<arglist> );
		return False
	}

	method _SemiList( Mu $parsed ) {
		if $parsed.list {
			for $parsed.list {
				next if self.assert-hash-keys( $_,
						[< statement >] )
					and self._Statement( $_.hash.<statement> );
				return False
			}
			return True
		}
		return True if self.assert-hash-keys( $parsed, [ ],
			[< statement >] );
		return False
	}

	method _Separator( Mu $parsed ) {
		return True if self.assert-hash-keys( $parsed,
				[< septype quantified_atom >] )
			and self._SepType( $parsed.hash.<septype> )
			and self._QuantifiedAtom( $parsed.hash.<quantified_atom> );
		return False
	}

	method _SepType( Mu $parsed ) returns Bool {
		return True if self.assert-Str( $parsed );
		return False
	}

	method _Shape( Mu $parsed ) returns Bool {
		return True if self.assert-Str( $parsed );
		return False
	}

	method _Sibble( Mu $parsed ) {
		return True if self.assert-hash-keys( $parsed,
				[< right babble left >] )
			and self._Right( $parsed.hash.<right> )
			and self._Babble( $parsed.hash.<babble> )
			and self._Left( $parsed.hash.<left> );
		return False
	}

	method _SigFinal( Mu $parsed ) {
		return True if self.assert-hash-keys( $parsed, [< normspace >] )
			and self._NormSpace( $parsed.hash.<normspace> );
		return False
	}

	method _Sigil( Mu $parsed ) returns Bool {
		return True if self.assert-Str( $parsed );
		return False
	}

	method _SigMaybe( Mu $parsed ) {
		return True if self.assert-hash-keys( $parsed,
				[< parameter typename >],
				[< param_sep >] )
			and self._Parameter( $parsed.hash.<parameter> )
			and self._TypeName( $parsed.hash.<typename> );
		return True if self.assert-hash-keys( $parsed, [],
				[< param_sep parameter >] );
		return False
	}

	method _Signature( Mu $parsed ) {
		return True if self.assert-hash-keys( $parsed,
				[< parameter typename >],
				[< param_sep >] )
			and self._Parameter( $parsed.hash.<parameter> )
			and self._TypeName( $parsed.hash.<typename> );
		return True if self.assert-hash-keys( $parsed,
				[< parameter >],
				[< param_sep >] )
			and self._Parameter( $parsed.hash.<parameter> );
		return True if self.assert-hash-keys( $parsed, [],
				[< param_sep parameter >] );
		return False
	}

	method _Sign( Mu $parsed ) {
		return True if $parsed.Str
			and ( $parsed.Str eq '-' or $parsed.Str eq '+' );
		return True if self.assert-Bool( $parsed );
		return False
	}

	method _SMExpr( Mu $parsed ) {
		return True if self.assert-hash-keys( $parsed, [< EXPR >] )
			and self._EXPR( $parsed.hash.<EXPR> );
		return False
	}

	method _Specials( Mu $parsed ) returns Bool {
		return True if self.assert-Bool( $parsed );
		return False
	}

	method _StatementControl( Mu $parsed ) {
		return True if self.assert-hash-keys( $parsed,
				[< block sym e1 e2 e3 >] )
			and self._Block( $parsed.hash.<block> )
			and self._Sym( $parsed.hash.<sym> )
			and self._E1( $parsed.hash.<e1> )
			and self._E2( $parsed.hash.<e2> )
			and self._E3( $parsed.hash.<e3> );
		return if self.assert-hash-keys( $parsed,
				[< pblock sym EXPR wu >] )
			and self._PBlock( $parsed.hash.<pblock> )
			and self._Sym( $parsed.hash.<sym> )
			and self._EXPR( $parsed.hash.<EXPR> )
			and self._Wu( $parsed.hash.<wu> );
		return True if self.assert-hash-keys( $parsed,
				[< doc sym module_name >] )
			and self._Doc( $parsed.hash.<doc> )
			and self._Sym( $parsed.hash.<sym> )
			and self._ModuleName( $parsed.hash.<module_name> );
		return True if self.assert-hash-keys( $parsed,
				[< doc sym version >] )
			and self._Doc( $parsed.hash.<doc> )
			and self._Sym( $parsed.hash.<sym> )
			and self._Version( $parsed.hash.<version> );
		return True if self.assert-hash-keys( $parsed,
				[< sym else xblock >] )
			and self._Sym( $parsed.hash.<sym> )
			and self._Else( $parsed.hash.<else> )
			and self._XBlock( $parsed.hash.<xblock> );
		return True if self.assert-hash-keys( $parsed,
				[< xblock sym wu >] )
			and self._XBlock( $parsed.hash.<xblock> )
			and self._Sym( $parsed.hash.<sym> )
			and self._Wu( $parsed.hash.<wu> );
		return True if self.assert-hash-keys( $parsed,
				[< sym xblock >] )
			and self._Sym( $parsed.hash.<sym> )
			and self._XBlock( $parsed.hash.<xblock> );
		return True if self.assert-hash-keys( $parsed,
				[< block sym >] )
			and self._Block( $parsed.hash.<block> )
			and self._Sym( $parsed.hash.<sym> );
		return False
	}

	method _Statement( Mu $parsed ) {
		if $parsed.list {
			for $parsed.list {
				next if self.assert-hash-keys( $_,
						[< statement_mod_loop EXPR >] )
					and self._StatementModLoop( $_.hash.<statement_mod_loop> )
					and self._EXPR( $_.hash.<EXPR> );
				next if self.assert-hash-keys( $_,
						[< statement_mod_cond EXPR >] )
					and self._StatementModCond( $_.hash.<statemet_mod_cond> )
					and self._EXPR( $_.hash.<EXPR> );
				next if self.assert-hash-keys( $_, [< EXPR >] )
					and self._EXPR( $_.hash.<EXPR> );
				next if self.assert-hash-keys( $_,
						[< statement_control >] )
					and self._StatementControl( $_.hash.<statement_control> );
				next if self.assert-hash-keys( $_, [],
						[< statement_control >] );
				return False
			}
			return True
		}
		return True if self.assert-hash-keys( $parsed,
				[< statement_control >] )
			and self._StatementControl( $parsed.hash.<statement_control> );
		return True if self.assert-hash-keys( $parsed, [< EXPR >] )
			and self._EXPR( $parsed.hash.<EXPR> );
		return False
	}

	method _StatementList( Mu $parsed ) {
return True;
		return True if self.assert-hash-keys( $parsed, [< statement >] )
			and self._Statement( $parsed.hash.<statement> );
		return True if self.assert-hash-keys( $parsed, [], [< statement >] );
		return False
	}

	method _StatementModCond( Mu $parsed ) {
		return True if self.assert-hash-keys( $parsed,
				[< sym modifier_expr >] )
			and self._Sym( $parsed.hash.<sym> )
			and self._ModifierExpr( $parsed.hash.<modifier_expr> );
		return False
	}

	method _StatementModLoop( Mu $parsed ) {
		return True if self.assert-hash-keys( $parsed,
				[< sym smexpr >] )
			and self._Sym( $parsed.hash.<sym> )
			and self._SMExpr( $parsed.hash.<smexpr> );
		return False
	}

	method _StatementPrefix( Mu $parsed ) {
		return True if self.assert-hash-keys( $parsed,
				[< sym blorst >] )
			and self._Sym( $parsed.hash.<sym> )
			and self._Blorst( $parsed.hash.<blorst> );
		return False
	}

	method _SubShortName( Mu $parsed ) {
		return True if self.assert-hash-keys( $parsed,
				[< desigilname >] )
			and self._DeSigilName( $parsed.hash.<desigilname> );
		return False
	}

	method _Sym( Mu $parsed ) {
		if $parsed.list {
			my @child;
			for $parsed.list {
				next if $_.Str;
				return False
			}
			return True
		}
		return True if $parsed.Bool and $parsed.Str eq '+';
		return True if $parsed.Bool and $parsed.Str eq '';
		return True if self.assert-Str( $parsed );
		return False
	}

	method _Term( Mu $parsed ) {
		return True if self.assert-hash-keys( $parsed, [< methodop >] )
			and self._MethodOp( $parsed.hash.<methodop> );
		return False
	}

	method _TermAlt( Mu $parsed ) {
		if $parsed.list {
			for $parsed.list {
				next if self.assert-hash-keys( $_,
						[< termconj >] )
					and self._TermConj( $_.hash.<termconj> );
				return False
			}
			return True
		}
		return False
	}

	method _TermAltSeq( Mu $parsed ) {
		return True if self.assert-hash-keys( $parsed,
				[< termconjseq >] )
			and self._TermConjSeq( $parsed.hash.<termconjseq> );
		return False
	}

	method _TermConj( Mu $parsed ) {
		if $parsed.list {
			for $parsed.list {
				next if self.assert-hash-keys( $_,
						[< termish >] )
					and self._Termish( $_.hash.<termish> );
				return False
			}
			return True
		}
		return False
	}

	method _TermConjSeq( Mu $parsed ) {
		if $parsed.list {
			for $parsed.list {
				next if self.assert-hash-keys( $_,
						[< termalt >] )
					and self._TermAlt( $_.hash.<termalt> );
				return False
			}
			return True
		}
		return True if self.assert-hash-keys( $parsed, [< termalt >] )
			and self._TermAlt( $parsed.hash.<termalt> );
		return False
	}

	method _TermInit( Mu $parsed ) {
		return True if self.assert-hash-keys( $parsed, [< sym EXPR >] )
			and self._Sym( $parsed.hash.<sym> )
			and self._EXPR( $parsed.hash.<EXPR> );
		return False
	}

	method _Termish( Mu $parsed ) {
		if $parsed.list {
			for $parsed.list {
				next if self.assert-hash-keys( $_, [< noun >] )
					and self._Noun( $_.hash.<noun> );
				return False
			}
			return True
		}
		return True if self.assert-hash-keys( $parsed, [< noun >] )
			and self._Noun( $parsed.hash.<noun> );
		return False
	}

	method _Triangle( Mu $parsed ) {
		return True if self.assert-Str( $parsed );
		return False
	}

	method _TermSeq( Mu $parsed ) {
		return True if self.assert-hash-keys( $parsed,
				[< termaltseq >] )
			and self._TermAltSeq( $parsed.hash.<termaltseq> );
		return False
	}

	method _Twigil( Mu $parsed ) {
		return True if self.assert-hash-keys( $parsed, [< sym >] )
			and self._Sym( $parsed.hash.<sym> );
		return False
	}

	method _TypeConstraint( Mu $parsed ) {
		if $parsed.list {
			for $parsed.list {
				next if self.assert-hash-keys( $_,
						[< typename >] )
					and self._TypeName( $_.hash.<typename> );
				next if self.assert-hash-keys( $_, [< value >] )
					and self._Value( $_.hash.<value> );
				return False
			}
			return True
		}
		return True if self.assert-hash-keys( $parsed, [< value >] )
			and self._Value( $parsed.hash.<value> );
		return True if self.assert-hash-keys( $parsed, [< typename >] )
			and self._TypeName( $parsed.hash.<typename> );
		return False
	}

	method _TypeDeclarator( Mu $parsed ) {
		return True if self.assert-hash-keys( $parsed,
				[< sym initializer variable >], [< trait >] )
			and self._Sym( $parsed.hash.<sym> )
			and self._Initializer( $parsed.hash.<initializer> )
			and self._Variable( $parsed.hash.<variable> );
		return True if self.assert-hash-keys( $parsed,
				[< sym initializer defterm >], [< trait >] )
			and self._Sym( $parsed.hash.<sym> )
			and self._Initializer( $parsed.hash.<initializer> )
			and self._DefTerm( $parsed.hash.<defterm> );
		return True if self.assert-hash-keys( $parsed,
				[< sym initializer >] )
			and self._Sym( $parsed.hash.<sym> )
			and self._Initializer( $parsed.hash.<initializer> );
		return False
	}

	method _TypeName( Mu $parsed ) {
		if $parsed.list {
			for $parsed.list {
				next if self.assert-hash-keys( $_,
						[< longname colonpairs >],
						[< colonpair >] )
					and self._LongName( $_.hash.<longname> )
					and self._ColonPairs( $_.hash.<colonpairs> );
				next if self.assert-hash-keys( $_,
						[< longname >],
						[< colonpair >] )
					and self._LongName( $_.hash.<longname> )
					and self._ColonPair( $_.hash.<colonpair> );
				return False
			}
			return True
		}
		return True if self.assert-hash-keys( $parsed,
				[< longname >], [< colonpair >] )
			and self._LongName( $parsed.hash.<longname> );
		return False
	}

	method _Val( Mu $parsed ) {
		return True if self.assert-hash-keys( $parsed,
				[< prefix OPER >],
				[< prefix_postfix_meta_operator >] )
			and self._Prefix( $parsed.hash.<prefix> )
			and self._OPER( $parsed.hash.<OPER> );
		return True if self.assert-hash-keys( $parsed, [< value >] )
			and self._Value( $parsed.hash.<value> );
		return False
	}

	method _Value( Mu $parsed ) {
		return True if self.assert-hash-keys( $parsed, [< number >] )
			and self._Number( $parsed.hash.<number> );
		return True if self.assert-hash-keys( $parsed, [< quote >] )
			and self._Quote( $parsed.hash.<quote> );
		return False
	}

	method _VALUE( Mu $parsed ) {
		return True if $parsed.Str and $parsed.Str eq '0';
		return True if self.assert-Int( $parsed );
		return False
	}

	method _Var( Mu $parsed ) {
		return True if self.assert-hash-keys( $parsed,
				[< sigil desigilname >] )
			and self._Sigil( $parsed.hash.<sigil> )
			and self._DeSigilName( $parsed.hash.<desigilname> );
		return True if self.assert-hash-keys( $parsed, [< variable >] )
			and self._Variable( $parsed.hash.<variable> );
		return False
	}

	method _VariableDeclarator( Mu $parsed ) {
		return True if self.assert-hash-keys( $parsed,
			[< semilist variable shape >],
			[< postcircumfix signature trait post_constraint >] )
			and self._SemiList( $parsed.hash.<semilist> )
			and self._Variable( $parsed.hash.<variable> )
			and self._Shape( $parsed.hash.<shape> );
		return True if self.assert-hash-keys( $parsed,
			[< variable >],
			[< semilist postcircumfix signature
			   trait post_constraint >] )
			and self._Variable( $parsed.hash.<variable> );
		return False
	}

	method _Variable( Mu $parsed ) {
		return True if self.assert-hash-keys( $parsed,
				[< twigil sigil desigilname >] )
			and self._Twigil( $parsed.hash.<twigil> )
			and self._Sigil( $parsed.hash.<sigil> )
			and self._DeSigilName( $parsed.hash.<desigilname> );
		return True if self.assert-hash-keys( $parsed,
				[< sigil desigilname >] )
			and self._Sigil( $parsed.hash.<sigil> )
			and self._DeSigilName( $parsed.hash.<desigilname> );
		return True if self.assert-hash-keys( $parsed, [< sigil >] )
			and self._Sigil( $parsed.hash.<sigil> );
		return True if self.assert-hash-keys( $parsed,
				[< contextualizer >] )
			and self._Contextualizer( $parsed.hash.<contextualizer> );
		return False
	}

	method _Version( Mu $parsed ) {
		return True if self.assert-hash-keys( $parsed, [< vnum vstr >] )
			and self._VNum( $parsed.hash.<vnum> )
			and self._VStr( $parsed.hash.<vstr> );
		return False
	}

	method _VNum( Mu $parsed ) {
		if $parsed.list {
			for $parsed.list {
				next if self.assert-Int( $_ );
				return False
			}
			return True
		}
		return False
	}

	method _VStr( Mu $parsed ) returns Bool {
		return True if self.assert-Int( $parsed );
		return False
	}

	method _Wu( Mu $parsed ) returns Bool {
		return True if self.assert-Str( $parsed );
		return False
	}

	method _XBlock( Mu $parsed ) returns Bool {
		if $parsed.list {
			for $parsed.list {
				next if self.assert-hash-keys( $_,
						[< pblock EXPR >] )
					and self._PBlock( $_.hash.<pblock> )
					and self._EXPR( $_.hash.<EXPR> );
				return False
			}
			return True
		}
		return True if self.assert-hash-keys( $parsed,
				[< pblock EXPR >] )
			and self._PBlock( $parsed.hash.<pblock> )
			and self._EXPR( $parsed.hash.<EXPR> );
		return True if self.assert-hash-keys( $parsed, [< blockoid >] )
			and self._Blockoid( $parsed.hash.<blockoid> );
		return False
	}

}
