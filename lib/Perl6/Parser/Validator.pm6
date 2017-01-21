my role Assertion {

	method assert-Bool( Mu $parsed ) {
		return False if $parsed.hash;
		return False if $parsed.list;
		return False if $parsed.Int;
		return False if $parsed.Str;

		return True if $parsed.Bool;

		die "Uncaught Bool" if $*VALIDATION-FAILURE-FATAL;
		warn "Uncaught type";
		return False
	}

	# $parsed can only be Int, by extension Str, by extension Bool.
	#
	method assert-Int( Mu $parsed ) {
		return False if $parsed.hash;
		return False if $parsed.list;

		return True if $parsed.Int;
		return True if $parsed.Bool;

		die "Uncaught Int" if $*VALIDATION-FAILURE-FATAL;
		warn "Uncaught type";
		return False
	}

	# $parsed can only be Num, by extension Int, by extension Str, by extension Bool.
	#
	method assert-Num( Mu $parsed ) {
		return False if $parsed.hash;
		return False if $parsed.list;

		return True if $parsed.Num;

		die "Uncaught Num" if $*VALIDATION-FAILURE-FATAL;
		warn "Uncaught type";
		return False
	}

	# $parsed can only be Str, by extension Bool
	#
	method assert-Str( Mu $parsed ) {
		return False if $parsed.hash;
		return False if $parsed.list;
		return False if $parsed.Num;
		return False if $parsed.Int;

		return True if $parsed.Str;

		die "Uncaught Str" if $*VALIDATION-FAILURE-FATAL;
		warn "Uncaught type";
		return False
	}

	method assert-hash-keys( Mu $parsed, $keys, $defined-keys = [] ) {
		return False unless $parsed and $parsed.hash;

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

		if $parsed.hash.keys.elems !=
			$keys.elems + $defined-keys.elems {
#				warn "Test " ~
#					$keys.gist ~
#					", " ~
#					$defined-keys.gist ~
#					" against parser " ~
#					$parsed.hash.keys.gist;
#				CONTROL { when CX::Warn { warn .message ~ "\n" ~ .backtrace.Str } }

			return False
		}
		
		for @( $keys ) -> $key {
			next if $parsed.hash.{$key};
			return False
		}
		for @( $defined-keys ) -> $key {
			next if $parsed.hash:defined{$key};
			return False
		}
		return True
	}
}

class Perl6::Parser::Validator {
	also does Assertion;

	method trace( Str $term ) {
		note $term if $*TRACE;
	}

	method record-failure( Str $term ) returns Bool {
		note "Validation failed for term '$term'" if $*DEBUG;
		die "Validation failed for term '$term'" if
			$*VALIDATION-FAILURE-FATAL;
		return False
	}

	sub debug-match( Mu $p ) {
		my %classified = classify {
			$p.hash.{$_}.Str ?? 'with' !! 'without'
		}, $p.hash.keys;
		my @keys-with-content = @( %classified<with> );
		my @keys-without-content = @( %classified<without> );

		say "With content: {@keys-with-content.gist}";
		say "Without content: {@keys-without-content.gist}";
	}

	method validate( Mu $parsed ) {
		self.trace( 'validate' );
		return True if self.assert-hash-keys( $parsed,
				[< statementlist >] )
			and self._StatementList( $parsed.hash.<statementlist> );
		debug-match( $parsed );
		return self.record-failure( 'Root' );
	}


	method _ArgList( Mu $parsed ) returns Bool {
		self.trace( '_ArgList' );
		CATCH {
			when X::Hash::Store::OddNumber { .resume }
		}
#return True;
		if $parsed.list {
			for $parsed.list {
				next if self.assert-hash-keys( $_, [< EXPR >] )
					and self._EXPR( $_.hash.<EXPR> );
				next if self.assert-Bool( $_ );
				next if $_.Str;
				debug-match( $_ );
				return self.record-failure( '_ArgList list' );
			}
			return True;
		}
		return True if self.assert-hash-keys( $parsed,
				[< deftermnow initializer term_init >],
				[< trait >] )
			and self._DefTermNow( $parsed.hash.<deftermnow> )
			and self._Initializer( $parsed.hash.<initializer> )
			and self._TermInit( $parsed.hash.<term_init> );
		return True if self.assert-hash-keys( $parsed,
				[< arglist >], [< O >] )
			and self._ArgList( $parsed.hash.<arglist> );
		return True if self.assert-hash-keys( $parsed, [< EXPR >] )
			and self._EXPR( $parsed.hash.<EXPR> );
		return True if self.assert-Int( $parsed );
		return True if self.assert-Bool( $parsed );
		debug-match( $parsed );
		return self.record-failure( '_ArgList' );
	}

	method _Args( Mu $parsed ) returns Bool {
		self.trace( '_Args' );
#return True;
		return True if self.assert-hash-keys( $parsed,
				[< invocant semiarglist >] )
			and self._Invocant( $parsed.hash.<invocant> )
			and self._SemiArgList( $parsed.hash.<semiarglist> );
		return True if self.assert-hash-keys( $parsed,
				[< semiarglist >] )
			and self._SemiArgList( $parsed.hash.<semiarglist> );
		return True if self.assert-hash-keys( $parsed, [ ],
				[< semiarglist >] );
		return True if self.assert-hash-keys( $parsed, [< arglist >] )
			and self._ArgList( $parsed.hash.<arglist> );
		return True if self.assert-hash-keys( $parsed, [< EXPR >] )
			and self._EXPR( $parsed.hash.<EXPR> );
		return True if self.assert-Bool( $parsed );
		return True if self.assert-Str( $parsed );
		debug-match( $parsed );
		return self.record-failure( '_Args' );
	}

	method _Assertion( Mu $parsed ) returns Bool {
		self.trace( '_Assertion' );
#return True;
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
		debug-match( $parsed );
		return self.record-failure( '_Assertion' );
	}

	method _Atom( Mu $parsed ) returns Bool {
		self.trace( '_Atom' );
#return True;
		return True if self.assert-hash-keys( $parsed, [< metachar >] )
			and self._MetaChar( $parsed.hash.<metachar> );
		return True if self.assert-Str( $parsed );
		debug-match( $parsed );
		return self.record-failure( '_Atom' );
	}

	method _Babble( Mu $parsed ) returns Bool {
		self.trace( '_Bubble' );
#return True;
		return True if self.assert-hash-keys( $parsed,
				[< B >], [< quotepair >] )
			and self._B( $parsed.hash.<B> );
		debug-match( $parsed );
		return self.record-failure( '_Babble' );
	}

	method _BackMod( Mu $parsed ) returns Bool {
		self.trace( '_BackMod' );
#return True;
		return True if self.assert-Bool( $parsed );
		debug-match( $parsed );
		return self.record-failure( '_BackMod' );
	}

	method _BackSlash( Mu $parsed ) returns Bool {
		self.trace( '_BackSlash' );
#return True;
		return True if self.assert-hash-keys( $parsed, [< sym >] )
			and self._Sym( $parsed.hash.<sym> );
		return True if self.assert-Str( $parsed );
		debug-match( $parsed );
		return self.record-failure( '_BackSlash' );
	}

	method _B( Mu $parsed ) returns Bool {
		self.trace( '_B' );
#return True;
		return True if self.assert-Bool( $parsed );
		debug-match( $parsed );
		return self.record-failure( '_B' );
	}

	method _BinInt( Mu $parsed ) returns Bool {
		self.trace( '_BinInt' );
#return True;
		return True if $parsed.Str and $parsed.Str eq '0';
		return True if self.assert-Int( $parsed );
		debug-match( $parsed );
		return self.record-failure( '_BinInt' );
	}

	method _Block( Mu $parsed ) returns Bool {
		self.trace( '_Block' );
#return True;
		return True if self.assert-hash-keys( $parsed, [< blockoid >] )
			and self._Blockoid( $parsed.hash.<blockoid> );
		debug-match( $parsed );
		return self.record-failure( '_Block' );
	}

	method _Blockoid( Mu $parsed ) returns Bool {
		self.trace( '_Blockoid' );
#return True;
		return True if self.assert-hash-keys( $parsed,
				[< statementlist >] )
			and self._StatementList( $parsed.hash.<statementlist> );
		debug-match( $parsed );
		return self.record-failure( '_Blockoid' );
	}

	method _Blorst( Mu $parsed ) returns Bool {
		self.trace( '_Blorst' );
#return True;
		return True if self.assert-hash-keys( $parsed, [< statement >] )
			and self._Statement( $parsed.hash.<statement> );
		return True if self.assert-hash-keys( $parsed, [< block >] )
			and self._Block( $parsed.hash.<block> );
		debug-match( $parsed );
		return self.record-failure( '_Blorst' );
	}

	method _Bracket( Mu $parsed ) returns Bool {
		self.trace( '_Bracket' );
#return True;
		return True if self.assert-hash-keys( $parsed, [< semilist >] )
			and self._SemiList( $parsed.hash.<semilist> );
		debug-match( $parsed );
		return self.record-failure( '_Bracket' );
	}

	method _CClassElem( Mu $parsed ) returns Bool {
		self.trace( '_CClassElem' );
#return True;
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
				debug-match( $_ );
				return self.record-failure( '_CClassElem list' );
			}
			return True
		}
		debug-match( $parsed );
		return self.record-failure( '_CClassElem' );
	}

	method _CharSpec( Mu $parsed ) returns Bool {
		self.trace( '_CharSpec' );
#return True;
# XXX work on this, of course.
		return True if $parsed.list;
		debug-match( $parsed );
		return self.record-failure( '_CharSpec' );
	}

	method _Circumfix( Mu $parsed ) returns Bool {
		self.trace( '_Circumfix' );
#return True;
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
		debug-match( $parsed );
		return self.record-failure( '_Circumfix' );
	}

	method _CodeBlock( Mu $parsed ) returns Bool {
		self.trace( '_CodeBlock' );
#return True;
		return True if self.assert-hash-keys( $parsed, [< block >] )
			and self._Block( $parsed.hash.<block> );
		debug-match( $parsed );
		return self.record-failure( '_CodeBlock' );
	}

	method _Coeff( Mu $parsed ) returns Bool {
		self.trace( '_Coeff' );
#return True;
		return True if self.assert-Str( $parsed ) and
		   ( $parsed.Str eq '0.0' or
		     $parsed.Str eq '0' );
		return True if self.assert-Int( $parsed );
		debug-match( $parsed );
		return self.record-failure( '_Coeff' );
	}

	method _Coercee( Mu $parsed ) returns Bool {
		self.trace( '_Coercee' );
#return True;
		return True if self.assert-hash-keys( $parsed, [< semilist >] )
			and self._SemiList( $parsed.hash.<semilist> );
		return True if self.assert-hash-keys( $parsed, [< statement >] )
			and self._Statement( $parsed.hash.<statement> );
		debug-match( $parsed );
		return self.record-failure( '_Coercee' );
	}

	method _ColonCircumfix( Mu $parsed ) returns Bool {
		self.trace( '_ColonCircumfix' );
#return True;
		return True if self.assert-hash-keys( $parsed, [< circumfix >] )
			and self._Circumfix( $parsed.hash.<circumfix> );
		debug-match( $parsed );
		return self.record-failure( '_ColonCircumfix' );
	}

	method _ColonPair( Mu $parsed ) returns Bool {
		self.trace( '_ColonPair' );
#return True;
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
		return True if self.assert-hash-keys( $parsed,
				[< coloncircumfix >] )
			and self._ColonCircumfix( $parsed.hash.<coloncircumfix> );
		debug-match( $parsed );
		return self.record-failure( '_ColonPair' );
	}

	method _ColonPairs( Mu $parsed ) {
#say $parsed.orig.Str;#.dump; # 'my Int:U $a'
#say $parsed.from;
#say $parsed.to;
#say $parsed.made; # '{U => 1}'
#say $parsed.dump_str; # '{U => 1}'
#say $parsed.keys;
#return;
		CATCH {
			when X::Multi::NoMatch { }
		}
		self.trace( '_ColonPairs' );
#return True;
		if $parsed ~~ Hash {
			return True if $parsed.<D>;
			return True if $parsed.<U>;
		}
		debug-match( $parsed );
		return self.record-failure( '_ColonPairs' );
	}

	method _Contextualizer( Mu $parsed ) {
		self.trace( '_Contextualizer' );
#return True;
		return True if self.assert-hash-keys( $parsed,
				[< coercee circumfix sigil >] )
			and self._Coercee( $parsed.hash.<coercee> )
			and self._Circumfix( $parsed.hash.<circumfix> )
			and self._Sigil( $parsed.hash.<sigil> );
		return True if self.assert-hash-keys( $parsed,
				[< coercee sequence sigil >] )
			and self._Coercee( $parsed.hash.<coercee> )
			and self._Sequence( $parsed.hash.<sequence> )
			and self._Sigil( $parsed.hash.<sigil> );
		debug-match( $parsed );
		return self.record-failure( '_Contextualizer' );
	}

	method _DecInt( Mu $parsed ) {
		self.trace( '_DecInt' );
#return True;
		return True if $parsed.Str and $parsed.Str eq '0';
		return True if self.assert-Int( $parsed );
		debug-match( $parsed );
		return self.record-failure( '_DecInt' );
	}

	method _Declarator( Mu $parsed ) {
		self.trace( '_Declarator' );
#return True;
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
				[< type_declarator >], [< trait >] )
			and self._TypeDeclarator( $parsed.hash.<type_declarator> );
		return True if self.assert-hash-keys( $parsed,
				[< regex_declarator >], [< trait >] )
			and self._RegexDeclarator( $parsed.hash.<regex_declarator> );
		return True if self.assert-hash-keys( $parsed,
				[< routine_declarator >], [< trait >] )
			and self._RoutineDeclarator( $parsed.hash.<routine_declarator> );
		return True if self.assert-hash-keys( $parsed,
				[< signature >], [< trait >] )
			and self._Signature( $parsed.hash.<signature> );
		debug-match( $parsed );
		return self.record-failure( '_Declarator' );
	}

	method _DECL( Mu $parsed ) {
		self.trace( '_DECL' );
#return True;
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
			and self._RoutineDeclarator(
				$parsed.hash.<routine_declarator>
			);
		return True if self.assert-hash-keys( $parsed,
					  [< package_def sym >] )
			and self._PackageDef( $parsed.hash.<package_def> )
			and self._Sym( $parsed.hash.<sym> );
		return True if self.assert-hash-keys( $parsed,
				[< type_declarator >], [< trait >] )
			and self._TypeDeclarator(
				$parsed.hash.<type_declarator>
			);
		return True if self.assert-hash-keys( $parsed,
					  [< declarator >] )
			and self._Declarator( $parsed.hash.<declarator> );
		debug-match( $parsed );
		return self.record-failure( '_DECL' );
	}

	method _DecNumber( Mu $parsed ) {
		self.trace( '_DecNumber' );
#return True;
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
		debug-match( $parsed );
		return self.record-failure( '_DecNumber' );
	}

	method _DefLongName( Mu $parsed ) {
		self.trace( '_DefLongName' );
#return True;
		return True if self.assert-hash-keys( $parsed,
				[< name >], [< colonpair >] )
			and self._Name( $parsed.hash.<name> );
		debug-match( $parsed );
		return self.record-failure( '_DefLongName' );
	}

	method _DefTerm( Mu $parsed ) {
		self.trace( '_DefTerm' );
#return True;
		return True if self.assert-hash-keys( $parsed,
				[< identifier colonpair >] )
			and self._Identifier( $parsed.hash.<identifier> )
			and self._ColonPair( $parsed.hash.<colonpair> );
		return True if self.assert-hash-keys( $parsed,
				[< identifier >], [< colonpair >] )
			and self._Identifier( $parsed.hash.<identifier> );
		debug-match( $parsed );
		return self.record-failure( '_DefTerm' );
	}

	method _DefTermNow( Mu $parsed ) {
		self.trace( '_DefTermNow' );
#return True;
		return True if self.assert-hash-keys( $parsed, [< defterm >] )
			and self._DefTerm( $parsed.hash.<defterm> );
		debug-match( $parsed );
		return self.record-failure( '_DefTermNow' );
	}

	method _DeSigilName( Mu $parsed ) {
		self.trace( '_DeSigilName' );
#return True;
		return True if self.assert-hash-keys( $parsed, [< longname >] )
			and self._LongName( $parsed.hash.<longname> );
		return True if $parsed.Str;
		debug-match( $parsed );
		return self.record-failure( '_DeSigilName' );
	}

	method _Dig( Mu $parsed ) {
		self.trace( '_Dig' );
#return True;
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
				debug-match( $parsed );
				return self.record-failure( '_Dig list' );
			}
			return True
		}
		debug-match( $parsed );
		return self.record-failure( '_Dig' );
	}

	method _Doc( Mu $parsed ) returns Bool {
		self.trace( '_Doc' );
#return True;
		return True if self.assert-Bool( $parsed );
		debug-match( $parsed );
		return self.record-failure( '_Doc' );
	}

	method _Dotty( Mu $parsed ) {
		self.trace( '_Dotty' );
#return True;
		return True if self.assert-hash-keys( $parsed,
				[< sym dottyop O >] )
			and self._Sym( $parsed.hash.<sym> )
			and self._DottyOp( $parsed.hash.<dottyop> )
			and self._O( $parsed.hash.<O> );
		return True if self.assert-hash-keys( $parsed,
				[< sym dottyop >], [< O >] )
			and self._Sym( $parsed.hash.<sym> )
			and self._DottyOp( $parsed.hash.<dottyop> );
		debug-match( $parsed );
		return self.record-failure( '_Dotty' );
	}

	method _DottyOp( Mu $parsed ) {
		self.trace( '_DottyOp' );
#return True;
		return True if self.assert-hash-keys( $parsed,
				[< sym postop >], [< O >] )
			and self._Sym( $parsed.hash.<sym> )
			and self._PostOp( $parsed.hash.<postop> );
		return True if self.assert-hash-keys( $parsed, [< methodop >] )
			and self._MethodOp( $parsed.hash.<methodop> );
		return True if self.assert-hash-keys( $parsed, [< colonpair >] )
			and self._ColonPair( $parsed.hash.<colonpair> );
		debug-match( $parsed );
		return self.record-failure( '_DottyOp' );
	}

	method _DottyOpish( Mu $parsed ) {
		self.trace( '_DottyOpish' );
#return True;
		return True if self.assert-hash-keys( $parsed, [< term >] )
			and self._Term( $parsed.hash.<term> );
		debug-match( $parsed );
		return self.record-failure( '_DottyOpish' );
	}

	method _E1( Mu $parsed ) {
		self.trace( '_E1' );
#return True;
		return True if self.assert-hash-keys( $parsed,
				[< scope_declarator >] )
			and self._ScopeDeclarator( $parsed.hash.<scope_declarator> );
		debug-match( $parsed );
		return self.record-failure( '_E1' );
	}

	method _E2( Mu $parsed ) {
		self.trace( '_E2' );
#return True;
		return True if self.assert-hash-keys( $parsed,
				[< infix OPER >] )
			and self._Infix( $parsed.hash.<infix> )
			and self._OPER( $parsed.hash.<OPER> );
		debug-match( $parsed );
		return self.record-failure( '_E2' );
	}

	method _E3( Mu $parsed ) {
		self.trace( '_E3' );
#return True;
		return True if self.assert-hash-keys( $parsed,
				[< postfix OPER >],
				[< postfix_prefix_meta_operator >] )
			and self._Postfix( $parsed.hash.<postfix> )
			and self._OPER( $parsed.hash.<OPER> );
		debug-match( $parsed );
		return self.record-failure( '_E3' );
	}

	method _Else( Mu $parsed ) {
		self.trace( '_Else' );
#return True;
		return True if self.assert-hash-keys( $parsed, [< sym blorst >] )
			and self._Sym( $parsed.hash.<sym> )
			and self._Blorst( $parsed.hash.<blorst> );
		return True if self.assert-hash-keys( $parsed, [< blockoid >] )
			and self._Blockoid( $parsed.hash.<blockoid> );
		debug-match( $parsed );
		return self.record-failure( '_Else' );
	}

	method _EScale( Mu $parsed ) {
		self.trace( '_EScale' );
#return True;
		return True if self.assert-hash-keys( $parsed,
				[< sign decint >] )
			and self._Sign( $parsed.hash.<sign> )
			and self._DecInt( $parsed.hash.<decint> );
		debug-match( $parsed );
		return self.record-failure( '_EScale' );
	}

	method _EXPR( Mu $parsed ) {
		self.trace( '_EXPR' );
#return True;
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
				next if self.assert-hash-keys( $_,
						[< infix OPER >] )
					and self._Infix( $_.hash.<infix> )
					and self._OPER( $_.hash.<OPER> );
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
				next if self.assert-hash-keys( $_,
						[< colonpair >] )
					and self._ColonPair( $_.hash.<colonpair> );
				next if self.assert-hash-keys( $_,
						[< pblock >] )
					and self._PBlock( $_.hash.<pblock> );
				next if self.assert-Str( $_ );
				debug-match( $_ );
				return self.record-failure( '_EXPR list' );
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
			debug-match( $parsed );
			return self.record-failure( '_EXPR hash' );
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
			and self._StatementPrefix(
				$parsed.hash.<statement_prefix>
			);
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
		return True if self.assert-hash-keys( $parsed, [< sym >] )
			and self._Sym( $parsed.hash.<sym> );
		return True if self.assert-hash-keys( $parsed, [< pblock >] )
			and self._PBlock( $parsed.hash.<pblock> );
		debug-match( $parsed );
		return self.record-failure( '_EXPR' ):
	}

	method _FakeInfix( Mu $parsed ) {
		self.trace( '_FakeInfix' );
#return True;
		return True if self.assert-hash-keys( $parsed, [< O >] )
			and self._O( $parsed.hash.<O> );
		return True if self.assert-hash-keys( $parsed, [< >], [< O >] );
		debug-match( $parsed );
		return self.record-failure( '_FakeInfix' );
	}

	method _FakeSignature( Mu $parsed ) {
		self.trace( '_FakeSignature' );
#return True;
		return True if self.assert-hash-keys( $parsed, [< signature >] )
			and self._Signature( $parsed.hash.<signature> );
		debug-match( $parsed );
		return self.record-failure( '_FakeSignature' );
	}

	method _FatArrow( Mu $parsed ) {
		self.trace( '_FatArrow' );
#return True;
		return True if self.assert-hash-keys( $parsed, [< val key >] )
			and self._Val( $parsed.hash.<val> )
			and self._Key( $parsed.hash.<key> );
		debug-match( $parsed );
		return self.record-failure( '_FatArrow' );
	}

	method _Frac( Mu $parsed ) {
		self.trace( '_Frac' );
#return True;
		return True if $parsed.Str and $parsed.Str eq '0';
		return True if self.assert-Int( $parsed );
		debug-match( $parsed );
		return self.record-failure( '_Frac' );
	}

	method _HexInt( Mu $parsed ) {
		self.trace( '_HexInt' );
#return True;
		return True if $parsed.Str and $parsed.Str eq '0';
		return True if self.assert-Int( $parsed );
		debug-match( $parsed );
		return self.record-failure( '_HexInt' );
	}

	method _Identifier( Mu $parsed ) {
		self.trace( '_Identifier' );
#return True;
		if $parsed.list {
			for $parsed.list {
				next if self.assert-Str( $_ );
				debug-match( $parsed );
				return self.record-failure( '_Identifier list' );
			}
			return True
		}
		return True if $parsed.Str;
		debug-match( $parsed );
		return self.record-failure( '_Identifier' );
	}

	method _Infix( Mu $parsed ) {
		self.trace( '_Infix' );
#return True;
		return True if self.assert-hash-keys( $parsed,
				[< sym EXPR >], [< O >] )
			and self._Sym( $parsed.hash.<sym> )
			and self._EXPR( $parsed.hash.<EXPR> );
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
		return True if self.assert-hash-keys( $parsed,
				[< sym >], [< O >] )
			and self._Sym( $parsed.hash.<sym> );
		debug-match( $parsed );
		return self.record-failure( '_Infix' );
	}

	method _Infixish( Mu $parsed ) {
		self.trace( '_Infixish' );
#return True;
		return True if self.assert-hash-keys( $parsed,
				[< infix OPER >] )
			and self._Infix( $parsed.hash.<infix> )
			and self._OPER( $parsed.hash.<OPER> );
		debug-match( $parsed );
		return self.record-failure( '_Infixish' );
	}

	method _InfixPrefixMetaOperator( Mu $parsed ) {
		self.trace( '_InfixPrefixMetaOperator' );
#return True;
		return True if self.assert-hash-keys( $parsed,
				[< sym infixish O >] )
			and self._Sym( $parsed.hash.<sym> )
			and self._Infixish( $parsed.hash.<infixish> )
			and self._O( $parsed.hash.<O> );
		return True if self.assert-hash-keys( $parsed,
				[< sym infixish >], [< O >] )
			and self._Sym( $parsed.hash.<sym> )
			and self._Infixish( $parsed.hash.<infixish> );
		debug-match( $parsed );
		return self.record-failure( '_InfixPrefixMetaOperator' );
	}

	method _Initializer( Mu $parsed ) {
		self.trace( '_Initializer' );
#return True;
		return True if self.assert-hash-keys( $parsed, [< sym EXPR >] )
			and self._Sym( $parsed.hash.<sym> )
			and self._EXPR( $parsed.hash.<EXPR> );
		return True if self.assert-hash-keys( $parsed,
				[< dottyopish sym >] )
			and self._DottyOpish( $parsed.hash.<dottyopish> )
			and self._Sym( $parsed.hash.<sym> );
		debug-match( $parsed );
		return self.record-failure( '_Initializer' );
	}

	method _Int( Mu $parsed ) {
		self.trace( '_Int' );
#return True;
		return True if $parsed.Str and $parsed.Str eq '0';
		return True if self.assert-Int( $parsed );
		debug-match( $parsed );
		return self.record-failure( '_Int' );
	}

	method _Integer( Mu $parsed ) {
		self.trace( '_Integer' );
#return True;
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
		debug-match( $parsed );
		return self.record-failure( '_Integer' );
	}

	method _Invocant( Mu $parsed ) {
		self.trace( '_Invocant' );
		CATCH {
			when X::Multi::NoMatch { }
		}
#return True;
		#return True if $parsed ~~ QAST::Want;
		#return True if self.assert-hash-keys( $parsed, [< XXX >] )
		#	and self._VALUE( $parsed.hash.<XXX> );
# XXX Fixme
#say $parsed.dump;
#say $parsed.dump_annotations;
#say "############## " ~$parsed.<annotations>.gist;#<BY>;
return True;
		debug-match( $parsed );
		return self.record-failure( '_Invocant' );
	}

	method _Key( Mu $parsed ) returns Bool {
		self.trace( '_Key' );
#return True;
		return True if self.assert-Str( $parsed );
		debug-match( $parsed );
		return self.record-failure( '_Key' );
	}

	method _Lambda( Mu $parsed ) returns Bool {
		self.trace( '_Lambda' );
#return True;
		return True if self.assert-Str( $parsed );
		debug-match( $parsed );
		return self.record-failure( '_Labmda' );
	}

	method _Left( Mu $parsed ) {
		self.trace( '_Left' );
#return True;
		return True if self.assert-hash-keys( $parsed, [< termseq >] )
			and self._TermSeq( $parsed.hash.<termseq> );
		debug-match( $parsed );
		return self.record-failure( '_Left' );
	}

	method _LongName( Mu $parsed ) {
		self.trace( '_LongName' );
#return True;
		return True if self.assert-hash-keys( $parsed,
				[< name >],
				[< colonpair >] )
			and self._Name( $parsed.hash.<name> );
		debug-match( $parsed );
		return self.record-failure( '_LongName' );
	}

	method _Max( Mu $parsed ) returns Bool {
		self.trace( '_Max' );
#return True;
		return True if self.assert-Str( $parsed );
		debug-match( $parsed );
		return self.record-failure( '_Max' );
	}

	method _MetaChar( Mu $parsed ) {
		self.trace( '_MetaChar' );
#return True;
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
		return True if self.assert-Str( $parsed ); # XXX not sure this should be needed.
		debug-match( $parsed );
		return self.record-failure( '_MetaChar' );
	}

	method _MethodDef( Mu $parsed ) {
		self.trace( '_MethodDef' );
#return True;
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
		debug-match( $parsed );
		return self.record-failure( '_MethodDef' );
	}

	method _MethodOp( Mu $parsed ) {
		self.trace( '_MethodOp' );
#return True;
		return True if self.assert-hash-keys( $parsed,
				[< longname args >] )
			and self._LongName( $parsed.hash.<longname> )
			and self._Args( $parsed.hash.<args> );
		return True if self.assert-hash-keys( $parsed, [< longname >] )
			and self._LongName( $parsed.hash.<longname> );
		return True if self.assert-hash-keys( $parsed, [< variable >] )
			and self._Variable( $parsed.hash.<variable> );
		debug-match( $parsed );
		return self.record-failure( '_MethodOp' );
	}

	method _Min( Mu $parsed ) {
		self.trace( '_Min' );
#return True;
		return True if self.assert-hash-keys( $parsed,
				[< decint VALUE >] )
			and self._DecInt( $parsed.hash.<decint> )
			and self._VALUE( $parsed.hash.<VALUE> );
		debug-match( $parsed );
		return self.record-failure( '_Min' );
	}

	method _ModifierExpr( Mu $parsed ) {
		self.trace( '_ModifierExpr' );
#return True;
		return True if self.assert-hash-keys( $parsed, [< EXPR >] )
			and self._EXPR( $parsed.hash.<EXPR> );
		debug-match( $parsed );
		return self.record-failure( '_ModifierExpr' );
	}

	method _ModuleName( Mu $parsed ) {
		self.trace( '_ModuleName' );
#return True;
		return True if self.assert-hash-keys( $parsed, [< longname >] )
			and self._LongName( $parsed.hash.<longname> );
		debug-match( $parsed );
		return self.record-failure( '_ModuleName' );
	}

	method _MoreName( Mu $parsed ) {
		self.trace( '_MoreName' );
#return True;
		if $parsed.list {
			for $parsed.list {
				next if self.assert-hash-keys( $_,
						[< identifier >] )
					and self._Identifier( $_.hash.<identifier> );
				debug-match( $_ );
				return self.record-failure( '_MoreName list' );
			}
			return True
		}
		debug-match( $parsed );
		return self.record-failure( '_MoreName' );
	}

	method _MultiDeclarator( Mu $parsed ) {
		self.trace( '_MultiDeclarator' );
#return True;
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
		debug-match( $parsed );
		return self.record-failure( '_MultiDeclarator' );
	}

	method _MultiSig( Mu $parsed ) {
		self.trace( '_MultiSig' );
#return True;
		return True if self.assert-hash-keys( $parsed, [< signature >] )
			and self._Signature( $parsed.hash.<signature> );
		debug-match( $parsed );
		return self.record-failure( '_MultiSig' );
	}

	method _NamedParam( Mu $parsed ) {
		self.trace( '_NamedParam' );
#return True;
		return True if self.assert-hash-keys( $parsed,
				[< name param_var >] )
			and self._Name( $parsed.hash.<name> )
			and self._ParamVar( $parsed.hash.<param_var> );
		return True if self.assert-hash-keys( $parsed,
				[< param_var >] )
			and self._ParamVar( $parsed.hash.<param_var> );
		debug-match( $parsed );
		return self.record-failure( '_NamedParam' );
	}

	method _Name( Mu $parsed ) {
		self.trace( '_Name' );
#return True;
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
		debug-match( $parsed );
		return self.record-failure( '_Name' );
	}

	method _Nibble( Mu $parsed ) {
		self.trace( '_Nibble' );
#return True;
		return True if self.assert-hash-keys( $parsed, [< termseq >] )
			and self._TermSeq( $parsed.hash.<termseq> );
		return True if $parsed.Str;
		return True if $parsed.Bool;
		debug-match( $parsed );
		return self.record-failure( '_Nibble' );
	}

	method _Nibbler( Mu $parsed ) {
		self.trace( '_Nibbler' );
#return True;
		return True if self.assert-hash-keys( $parsed, [< termseq >] )
			and self._TermSeq( $parsed.hash.<termseq> );
		debug-match( $parsed );
		return self.record-failure( '_Nibbler' );
	}

	method _NormSpace( Mu $parsed ) returns Bool {
		self.trace( '_NormSpace' );
#return True;
		return True if self.assert-Str( $parsed );
		debug-match( $parsed );
		return self.record-failure( '_NormSpace' );
	}

	method _Noun( Mu $parsed ) {
		self.trace( '_Noun' );
#return True;
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
				next if self.assert-hash-keys( $_,
						[< atom >], [ ] )
					and self._Atom( $_.hash.<atom> );
				debug-match( $_ );
				return self.record-failure( 'Noun list' );
			}
			return True
		}
		debug-match( $parsed );
		return self.record-failure( '_Noun' );
	}

	method _Number( Mu $parsed ) {
		self.trace( '_Number' );
#return True;
		return True if self.assert-hash-keys( $parsed, [< numish >] )
			and self._Numish( $parsed.hash.<numish> );
		debug-match( $parsed );
		return self.record-failure( '_Number' );
	}

	method _Numish( Mu $parsed ) {
		self.trace( '_Numish' );
#return True;
		return True if self.assert-hash-keys( $parsed, [< integer >] )
			and self._Integer( $parsed.hash.<integer> );
		return True if self.assert-hash-keys( $parsed,
				[< rad_number >] )
			and self._RadNumber( $parsed.hash.<rad_number> );
		return True if self.assert-hash-keys( $parsed,
				[< dec_number >] )
			and self._DecNumber( $parsed.hash.<dec_number> );
		return True if self.assert-Num( $parsed );
		debug-match( $parsed );
		return self.record-failure( '_Numish' );
	}

	method _OctInt( Mu $parsed ) {
		self.trace( '_OctInt' );
#return True;
		return True if $parsed.Str and $parsed.Str eq '0';
		return True if self.assert-Int( $parsed );
		debug-match( $parsed );
		return self.record-failure( '_OctInt' );
	}

	method _O( Mu $parsed ) {
		self.trace( '_O' );
		CATCH {
			when X::Multi::NoMatch { .resume }
			#default { .resume }
			default { }
		}
#return True;
		return True if $parsed.<thunky>
			and $parsed.<prec>
			and $parsed.<fiddly>
			and $parsed.<reducecheck>
			and $parsed.<pasttype>
			and $parsed.<dba>
			and $parsed.<assoc>;
		return True if $parsed.<thunky>
			and $parsed.<prec>
			and $parsed.<pasttype>
			and $parsed.<dba>
			and $parsed.<iffy>
			and $parsed.<assoc>;
		return True if $parsed.<prec>
			and $parsed.<pasttype>
			and $parsed.<dba>
			and $parsed.<diffy>
			and $parsed.<iffy>
			and $parsed.<assoc>;
		return True if $parsed.<prec>
			and $parsed.<fiddly>
			and $parsed.<sub>
			and $parsed.<dba>
			and $parsed.<assoc>;
		return True if $parsed.<prec>
			and $parsed.<nextterm>
			and $parsed.<fiddly>
			and $parsed.<dba>
			and $parsed.<assoc>;
		return True if $parsed.<thunky>
			and $parsed.<prec>
			and $parsed.<dba>
			and $parsed.<assoc>;
		return True if $parsed.<prec>
			and $parsed.<diffy>
			and $parsed.<dba>
			and $parsed.<assoc>;
		return True if $parsed.<prec>
			and $parsed.<iffy>
			and $parsed.<dba>
			and $parsed.<assoc>;
		return True if $parsed.<prec>
			and $parsed.<fiddly>
			and $parsed.<dba>
			and $parsed.<assoc>;
		return True if $parsed.<prec>
			and $parsed.<dba>
			and $parsed.<assoc>;
		debug-match( $parsed );
		return self.record-failure( '_O' );
	}

	method _Op( Mu $parsed ) {
		self.trace( '_Op' );
#return True;
		return True if self.assert-hash-keys( $parsed,
			     [< infix_prefix_meta_operator OPER >] )
			and self._InfixPrefixMetaOperator( $parsed.hash.<infix_prefix_meta_operator> )
			and self._OPER( $parsed.hash.<OPER> );
		return True if self.assert-hash-keys( $parsed, [< infix OPER >] )
			and self._Infix( $parsed.hash.<infix> )
			and self._OPER( $parsed.hash.<OPER> );
		debug-match( $parsed );
		return self.record-failure( '_Op' );
	}

	method _OPER( Mu $parsed ) {
		self.trace( '_OPER' );
#return True;
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
		return True if self.assert-hash-keys( $parsed,
				[< sym EXPR >], [< O >] )
			and self._Sym( $parsed.hash.<sym> )
			and self._EXPR( $parsed.hash.<EXPR> );
		return True if self.assert-hash-keys( $parsed,
				[< sym infixish >], [< O >] )
			and self._Sym( $parsed.hash.<sym> )
			and self._Infixish( $parsed.hash.<infixish> );
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
		return True if self.assert-hash-keys( $parsed,
				[< arglist >], [< O >] )
			and self._ArgList( $parsed.hash.<arglist> );
		return True if self.assert-hash-keys( $parsed,
				[< sym dottyop >], [< O >] )
			and self._Sym( $parsed.hash.<sym> )
			and self._DottyOp( $parsed.hash.<dottyop> );
		return True if self.assert-hash-keys( $parsed, [< dig O >] )
			and self._Dig( $parsed.hash.<dig> )
			and self._O( $parsed.hash.<O> );
		return True if self.assert-hash-keys( $parsed,
				[< dig >], [< O >] )
			and self._Dig( $parsed.hash.<dig> );
		return True if self.assert-hash-keys( $parsed,
				[< sym >], [< O >] )
			and self._Sym( $parsed.hash.<sym> );
		return True if self.assert-hash-keys( $parsed,
				[< semilist >], [< O >] )
			and self._SemiList( $parsed.hash.<semilist> );
		return True if self.assert-hash-keys( $parsed,
				[< nibble >], [< O >] )
			and self._Nibble( $parsed.hash.<nibble> );
		return True if self.assert-hash-keys( $parsed, [< O >] )
			and self._O( $parsed.hash.<O> );
		return True if self.assert-hash-keys( $parsed, [], [< O >] );
		debug-match( $parsed );
		return self.record-failure( '_OPER' );
	}

	method _PackageDeclarator( Mu $parsed ) {
		self.trace( '_PackageDeclarator' );
#return True;
		return True if self.assert-hash-keys( $parsed,
				[< sym package_def >] )
			and self._Sym( $parsed.hash.<sym> )
			and self._PackageDef( $parsed.hash.<package_def> );
		return True if self.assert-hash-keys( $parsed,
				[< sym trait >] )
			and self._Sym( $parsed.hash.<sym> )
			and self._Trait( $parsed.hash.<trait> );
		return True if self.assert-hash-keys( $parsed,
				[< sym typename >] )
			and self._Sym( $parsed.hash.<sym> )
			and self._TypeName( $parsed.hash.<typename> );
		debug-match( $parsed );
		return self.record-failure( '_PackageDeclarator' );
	}

	method _PackageDef( Mu $parsed ) {
		self.trace( '_PackageDef' );
#return True;
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
		debug-match( $parsed );
		return self.record-failure( '_PackageDef' );
	}

	method _Parameter( Mu $parsed ) {
		self.trace( '_Parameter' );
#return True;
		if $parsed.list {
			for $parsed.list {
				next if self.assert-hash-keys( $_,
					[< param_var type_constraint quant >],
					[< default_value modifier trait
					   post_constraint >] )
					and self._ParamVar( $_.hash.<param_var> )
					and self._TypeConstraint( $_.hash.<type_constraint> )
					and self._Quant( $_.hash.<quant> );
				next if self.assert-hash-keys( $_,
					[< param_term quant >],
					[< default_value type_constraint modifier trait post_constraint >] )
					and self._ParamTerm( $_.hash.<param_term> )
					and self._Quant( $_.hash.<quant> );
				next if self.assert-hash-keys( $_,
					[< param_var quant >],
					[< default_value type_constraint modifier trait post_constraint >] )
					and self._ParamVar( $_.hash.<param_var> )
					and self._Quant( $_.hash.<quant> );
				next if self.assert-hash-keys( $_,
					[< param_var quant >],
					[< default_value modifier trait
					   type_constraint
					   post_constraint >] )
					and self._ParamVar(
						$_.hash.<param_var>
					)
					and self._Quant( $_.hash.<quant> );
	
				next if self.assert-hash-keys( $_,
					[< named_param quant >],
					[< default_value modifier
					   post_constraint trait
					   type_constraint >] )
					and self._NamedParam(
						$_.hash.<named_param>
					)
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
					and self._TypeConstraint(
						$_.hash.<type_constraint>
					);
				next if self.assert-hash-keys( $_,
					[< type_constraint >],
					[< default_value modifier trait
					   post_constraint >] )
					and self._TypeConstraint(
						$_.hash.<type_constraint>
					);
				debug-match( $_ );
				return self.record-failure( '_Parameter list' );
			}
			return True
		}
		debug-match( $parsed );
		return self.record-failure( '_Parameter' );
	}

	method _ParamTerm( Mu $parsed ) {
		self.trace( '_ParamTerm' );
#return True;
		return True if self.assert-hash-keys( $parsed,
				[< defterm >] )
			and self._DefTerm( $parsed.hash.<defterm> );
		debug-match( $parsed );
		return self.record-failure( '_ParamTerm' );
	}

	method _ParamVar( Mu $parsed ) {
		self.trace( '_ParamVar' );
#return True;
		return True if self.assert-hash-keys( $parsed,
				[< name twigil sigil >] )
			and self._Name( $parsed.hash.<name> )
			and self._Twigil( $parsed.hash.<twigil> )
			and self._Sigil( $parsed.hash.<sigil> );
		return True if self.assert-hash-keys( $parsed,
				[< name sigil >] )
			and self._Name( $parsed.hash.<name> )
			and self._Sigil( $parsed.hash.<sigil> );
		return True if self.assert-hash-keys( $parsed, [< signature >] )
			and self._Signature( $parsed.hash.<signature> );
		return True if self.assert-hash-keys( $parsed, [< sigil >] )
			and self._Sigil( $parsed.hash.<sigil> );
		debug-match( $parsed );
		return self.record-failure( '_ParamVar' );
	}

	method _PBlock( Mu $parsed ) {
		self.trace( '_PBlock' );
#return True;
		return True if self.assert-hash-keys( $parsed,
				     [< lambda blockoid signature >] )
			and self._Lambda( $parsed.hash.<lambda> )
			and self._Blockoid( $parsed.hash.<blockoid> )
			and self._Signature( $parsed.hash.<signature> );
		return True if self.assert-hash-keys( $parsed, [< blockoid >] )
			and self._Blockoid( $parsed.hash.<blockoid> );
		debug-match( $parsed );
		return self.record-failure( '_PBlock' );
	}

	method _PostCircumfix( Mu $parsed ) {
		self.trace( '_PostCircumfix' );
#return True;
		return True if self.assert-hash-keys( $parsed, [< nibble O >] )
			and self._Nibble( $parsed.hash.<nibble> )
			and self._O( $parsed.hash.<O> );
		return True if self.assert-hash-keys( $parsed, [< semilist O >] )
			and self._SemiList( $parsed.hash.<semilist> )
			and self._O( $parsed.hash.<O> );
		return True if self.assert-hash-keys( $parsed, [< arglist O >] )
			and self._ArgList( $parsed.hash.<arglist> )
			and self._O( $parsed.hash.<O> );
		return True if self.assert-hash-keys( $parsed,
				[< arglist >], [< O >] )
			and self._ArgList( $parsed.hash.<arglist> );
		return True if self.assert-hash-keys( $parsed,
				[< semilist >], [< O >] )
			and self._SemiList( $parsed.hash.<semilist> );
		return True if self.assert-hash-keys( $parsed,
				[< nibble >], [< O >] )
			and self._Nibble( $parsed.hash.<nibble> );
		debug-match( $parsed );
		return self.record-failure( '_PostCircumfix' );
	}

	method _Postfix( Mu $parsed ) {
		self.trace( '_Postfix' );
#return True;
		return True if self.assert-hash-keys( $parsed, [< dig O >] )
			and self._Dig( $parsed.hash.<dig> )
			and self._O( $parsed.hash.<O> );
		return True if self.assert-hash-keys( $parsed, [< sym O >] )
			and self._Sym( $parsed.hash.<sym> )
			and self._O( $parsed.hash.<O> );
		return True if self.assert-hash-keys( $parsed,
				[< dig>], [< O >] )
			and self._Dig( $parsed.hash.<dig> );
		return True if self.assert-hash-keys( $parsed,
				[< sym >], [< O >] )
			and self._Sym( $parsed.hash.<sym> );
		debug-match( $parsed );
		return self.record-failure( '_Postfix' );
	}

	method _PostOp( Mu $parsed ) {
		self.trace( '_PostOp' );
#return True;
		return True if self.assert-hash-keys( $parsed,
				[< sym postcircumfix O >] )
			and self._Sym( $parsed.hash.<sym> )
			and self._PostCircumfix( $parsed.hash.<postcircumfix> )
			and self._O( $parsed.hash.<O> );
		return True if self.assert-hash-keys( $parsed,
				[< sym postcircumfix >], [< O >] )
			and self._Sym( $parsed.hash.<sym> )
			and self._PostCircumfix( $parsed.hash.<postcircumfix> );
		debug-match( $parsed );
		return self.record-failure( '_PostOp' );
	}

	method _Prefix( Mu $parsed ) {
		self.trace( '_Prefix' );
#return True;
		return True if self.assert-hash-keys( $parsed, [< sym O >] )
			and self._Sym( $parsed.hash.<sym> )
			and self._O( $parsed.hash.<O> );
		return True if self.assert-hash-keys( $parsed,
				[< sym >], [< O >] )
			and self._Sym( $parsed.hash.<sym> );
		debug-match( $parsed );
		return self.record-failure( '_Prefix' );
	}

	method _Quant( Mu $parsed ) returns Bool {
		self.trace( '_Quant' );
#return True;
		return True if $parsed.Str;
		return True if self.assert-Bool( $parsed );
		debug-match( $parsed );
		return self.record-failure( '_Quant' );
	}


	method _QuantifiedAtom( Mu $parsed ) {
		self.trace( '_QuantifiedAtom' );
#return True;
		return True if self.assert-hash-keys( $parsed,
				[< sigfinal atom >] )
			and self._SigFinal( $parsed.hash.<sigfinal> )
			and self._Atom( $parsed.hash.<atom> );
		debug-match( $parsed );
		return self.record-failure( '_QuantifiedAtom' );
	}

	method _Quantifier( Mu $parsed ) {
		self.trace( '_Quantifier' );
#return True;
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
		debug-match( $parsed );
		return self.record-failure( '_Quantifier' );
	}

	method _Quibble( Mu $parsed ) {
		self.trace( '_Quibble' );
#return True;
		return True if self.assert-hash-keys( $parsed,
				[< babble nibble >] )
			and self._Babble( $parsed.hash.<babble> )
			and self._Nibble( $parsed.hash.<nibble> );
		debug-match( $parsed );
		return self.record-failure( '_Quibble' );
	}

	method _Quote( Mu $parsed ) {
		self.trace( '_Quote' );
#return True;
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
		return True if self.assert-hash-keys( $parsed,
				[< quibble quote_mod >] )
			and self._Quibble( $parsed.hash.<quibble> )
			and self._QuoteMod( $parsed.hash.<quote_mod> );
		return True if self.assert-hash-keys( $parsed, [< nibble >] )
			and self._Nibble( $parsed.hash.<nibble> );
		return True if self.assert-hash-keys( $parsed, [< quibble >] )
			and self._Quibble( $parsed.hash.<quibble> );
		debug-match( $parsed );
		return self.record-failure( '_Quote' );
	}

	method _QuoteMod( Mu $parsed ) {
		self.trace( '_QuoteMod' );
#return True;
		return True if self.assert-hash-keys( $parsed, [< sym >] )
			and self._Sym( $parsed.hash.<sym> );
		debug-match( $parsed );
		return self.record-failure( '_QuoteMod' );
	}

	method _QuotePair( Mu $parsed ) {
		self.trace( '_QuotePair' );
#return True;
		if $parsed.list {
			for $parsed.list {
				next if self.assert-hash-keys( $_,
					[< identifier >] )
					and self._Identifier(
						$_.hash.<identifier>
					);
				debug-match( $_ );
				return self.record-failure( '_QuotePair list' );
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
		debug-match( $parsed );
		return self.record-failure( '_QuotePair' );
	}

	method _Radix( Mu $parsed ) returns Bool {
		self.trace( '_Radix' );
#return True;
		return True if self.assert-Int( $parsed );
		debug-match( $parsed );
		return self.record-failure( '_Radix' );
	}

	method _RadNumber( Mu $parsed ) {
		self.trace( '_RadNumber' );
#return True;
		return True if self.assert-hash-keys( $parsed,
				[< circumfix bracket radix >],
				[< exp rad_digits base >] )
			and self._Circumfix( $parsed.hash.<circumfix> )
			and self._Bracket( $parsed.hash.<bracket> )
			and self._Radix( $parsed.hash.<radix> );
		return True if self.assert-hash-keys( $parsed,
				[< circumfix bracket radix >], [< exp base >] )
			and self._Circumfix( $parsed.hash.<circumfix> )
			and self._Bracket( $parsed.hash.<bracket> )
			and self._Radix( $parsed.hash.<radix> );
		return True if self.assert-hash-keys( $parsed,
				[< circumfix radix >],
				[< exp rad_digits base >] )
			and self._Circumfix( $parsed.hash.<circumfix> )
			and self._Radix( $parsed.hash.<radix> );
		return True if self.assert-hash-keys( $parsed,
				[< circumfix radix >], [< exp base >] )
			and self._Circumfix( $parsed.hash.<circumfix> )
			and self._Radix( $parsed.hash.<radix> );
		debug-match( $parsed );
		return self.record-failure( '_RadNumber' );
	}

	method _RegexDeclarator( Mu $parsed ) {
		self.trace( '_RegexDeclarator' );
#return True;
		return True if self.assert-hash-keys( $parsed,
				[< sym regex_def >] )
			and self._Sym( $parsed.hash.<sym> )
			and self._RegexDef( $parsed.hash.<regex_def> );
		debug-match( $parsed );
		return self.record-failure( '_RegexDeclarator' );
	}

	method _RegexDef( Mu $parsed ) {
		self.trace( '_RegexDef' );
#return True;
		return True if self.assert-hash-keys( $parsed,
				[< deflongname nibble >],
				[< signature trait >] )
			and self._DefLongName( $parsed.hash.<deflongname> )
			and self._Nibble( $parsed.hash.<nibble> );
		debug-match( $parsed );
		return self.record-failure( '_RegexDef' );
	}

	method _Right( Mu $parsed ) {
		self.trace( '_Right' );
#return True;
		return True if self.assert-Bool( $parsed );
		debug-match( $parsed );
		return self.record-failure( '_Right' );
	}

	method _RoutineDeclarator( Mu $parsed ) {
		self.trace( '_RoutineDeclarator' );
#return True;
		return True if self.assert-hash-keys( $parsed,
				[< sym method_def >] )
			and self._Sym( $parsed.hash.<sym> )
			and self._MethodDef( $parsed.hash.<method_def> );
		return True if self.assert-hash-keys( $parsed,
				[< sym routine_def >] )
			and self._Sym( $parsed.hash.<sym> )
			and self._RoutineDef( $parsed.hash.<routine_def> );
		debug-match( $parsed );
		return self.record-failure( '_RoutineDeclarator' );
	}

	# DING
	method _RoutineDef( Mu $parsed ) {
		self.trace( '_RoutineDef' );
#return True;
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
				[< deflongname >],
				[< statementlist trait >] )
			and self._DefLongName( $parsed.hash.<deflongname> );
		return True if self.assert-hash-keys( $parsed,
				[< blockoid >], [< trait >] )
			and self._Blockoid( $parsed.hash.<blockoid> );
		debug-match( $parsed );
		return self.record-failure( '_RoutineDef' );
	}

	method _RxAdverbs( Mu $parsed ) {
		self.trace( '_RxAdverbs' );
#return True;
		return True if self.assert-hash-keys( $parsed, [< quotepair >] )
			and self._QuotePair( $parsed.hash.<quotepair> );
		return True if self.assert-hash-keys( $parsed,
				[], [< quotepair >] );
		debug-match( $parsed );
		return self.record-failure( '_RxAdverbs' );
	}

	method _Scoped( Mu $parsed ) {
		self.trace( '_Scoped' );
#return True;
		return True if self.assert-hash-keys( $parsed,
				[< declarator DECL >], [< typename >] )
			and self._Declarator( $parsed.hash.<declarator> )
			and self._DECL( $parsed.hash.<DECL> );
		return True if self.assert-hash-keys( $parsed,
					[< multi_declarator DECL typename >] )
			and self._MultiDeclarator(
				$parsed.hash.<multi_declarator>
			)
			and self._DECL( $parsed.hash.<DECL> )
			and self._TypeName( $parsed.hash.<typename> );
		return True if self.assert-hash-keys( $parsed,
				[< package_declarator DECL >],
				[< typename >] )
			and self._PackageDeclarator(
				$parsed.hash.<package_declarator>
			)
			and self._DECL( $parsed.hash.<DECL> );
		debug-match( $parsed );
		return self.record-failure( '_Scoped' );
	}

	method _ScopeDeclarator( Mu $parsed ) {
		self.trace( '_ScopeDeclarator' );
#return True;
		return True if self.assert-hash-keys( $parsed,
				[< sym scoped >] )
			and self._Sym( $parsed.hash.<sym> )
			and self._Scoped( $parsed.hash.<scoped> );
		debug-match( $parsed );
		return self.record-failure( '_ScopeDeclarator' );
	}

	method _SemiArgList( Mu $parsed ) {
		self.trace( '_SemiArgList' );
#return True;
		return True if self.assert-hash-keys( $parsed, [< arglist >] )
			and self._ArgList( $parsed.hash.<arglist> );
		debug-match( $parsed );
		return self.record-failure( '_SemiArgList' );
	}

	method _SemiList( Mu $parsed ) {
		self.trace( '_SemiList' );
#return True;
		if $parsed.list {
			for $parsed.list {
				next if self.assert-hash-keys( $_,
						[< statement >] )
					and self._Statement(
						$_.hash.<statement>
					);
				debug-match( $_ );
				return self.record-failure( '_SemiList list' );
			}
			return True
		}
		return True if self.assert-hash-keys( $parsed, [ ],
			[< statement >] );
		debug-match( $parsed );
		return self.record-failure( '_SemiList' );
	}

	method _Separator( Mu $parsed ) {
		self.trace( '_Separator' );
#return True;
		return True if self.assert-hash-keys( $parsed,
				[< septype quantified_atom >] )
			and self._SepType( $parsed.hash.<septype> )
			and self._QuantifiedAtom(
				$parsed.hash.<quantified_atom>
			);
		debug-match( $parsed );
		return self.record-failure( '_Separator' );
	}

	method _SepType( Mu $parsed ) returns Bool {
		self.trace( '_SepType' );
#return True;
		return True if self.assert-Str( $parsed );
		debug-match( $parsed );
		return self.record-failure( '_SepType' );
	}

	method _Sequence( Mu $parsed ) returns Bool {
		self.trace( '_Sequence' );
#return True;
		return True if self.assert-hash-keys( $parsed,
				[< statement >] )
			and self._Statement( $parsed.hash.<statement> );
		debug-match( $parsed );
		return self.record-failure( '_Sequence' );
	}

	method _Shape( Mu $parsed ) returns Bool {
		self.trace( '_Shape' );
#return True;
		return True if self.assert-Str( $parsed );
		debug-match( $parsed );
		return self.record-failure( '_Shape' );
	}

	method _Sibble( Mu $parsed ) {
		self.trace( '_Sibble' );
#return True;
		return True if self.assert-hash-keys( $parsed,
				[< right babble left >] )
			and self._Right( $parsed.hash.<right> )
			and self._Babble( $parsed.hash.<babble> )
			and self._Left( $parsed.hash.<left> );
		debug-match( $parsed );
		return self.record-failure( '_Sibble' );
	}

	method _SigFinal( Mu $parsed ) {
		self.trace( '_SigFinal' );
#return True;
		return True if self.assert-hash-keys( $parsed, [< normspace >] )
			and self._NormSpace( $parsed.hash.<normspace> );
		debug-match( $parsed );
		return self.record-failure( '_SigFinal' );
	}

	method _Sigil( Mu $parsed ) returns Bool {
		self.trace( '_Sigil' );
#return True;
		return True if self.assert-Str( $parsed );
		debug-match( $parsed );
		return self.record-failure( '_Sigil' );
	}

	method _SigMaybe( Mu $parsed ) {
		self.trace( '_SigMaybe' );
#return True;
		return True if self.assert-hash-keys( $parsed,
				[< parameter typename >],
				[< param_sep >] )
			and self._Parameter( $parsed.hash.<parameter> )
			and self._TypeName( $parsed.hash.<typename> );
		return True if self.assert-hash-keys( $parsed,
				[< normspace >] )
			and self._NormSpace( $parsed.hash.<normspace> );
		return True if self.assert-hash-keys( $parsed, [],
				[< param_sep parameter >] );
		debug-match( $parsed );
		return self.record-failure( '_SigMaybe' );
	}

	method _Signature( Mu $parsed ) {
		self.trace( '_Signature' );
#return True;
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
		debug-match( $parsed );
		return self.record-failure( '_Signature' );
	}

	method _Sign( Mu $parsed ) {
		self.trace( '_Sign' );
#return True;
		return True if $parsed.Str
			and ( $parsed.Str eq '-' or $parsed.Str eq '+' );
		return True if self.assert-Bool( $parsed );
		debug-match( $parsed );
		return self.record-failure( '_Sign' );
	}

	method _SMExpr( Mu $parsed ) {
		self.trace( '_SMExpr' );
#return True;
		return True if self.assert-hash-keys( $parsed, [< EXPR >] )
			and self._EXPR( $parsed.hash.<EXPR> );
		debug-match( $parsed );
		return self.record-failure( '_SMExpr' );
	}

	method _Specials( Mu $parsed ) returns Bool {
		self.trace( '_Specials' );
#return True;
		return True if self.assert-Bool( $parsed );
		debug-match( $parsed );
		return self.record-failure( '_Specials' );
	}

	method _StatementControl( Mu $parsed ) {
		self.trace( '_StatementControl' );
#return True;
		return True if self.assert-hash-keys( $parsed,
				[< block sym e1 e2 e3 >] )
			and self._Block( $parsed.hash.<block> )
			and self._Sym( $parsed.hash.<sym> )
			and self._E1( $parsed.hash.<e1> )
			and self._E2( $parsed.hash.<e2> )
			and self._E3( $parsed.hash.<e3> );
		return True if self.assert-hash-keys( $parsed,
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
		debug-match( $parsed );
		return self.record-failure( '_StatementControl' );
	}

	method _Statement( Mu $parsed ) {
		self.trace( '_Statement' );
#return True;
		if $parsed.list {
			for $parsed.list {
				next if self.assert-hash-keys( $_,
						[< statement_mod_loop EXPR >] )
					and self._StatementModLoop(
						$_.hash.<statement_mod_loop>
					)
					and self._EXPR( $_.hash.<EXPR> );
				next if self.assert-hash-keys( $_,
						[< statement_mod_cond EXPR >] )
					and self._StatementModCond(
						$_.hash.<statement_mod_cond>
					)
					and self._EXPR( $_.hash.<EXPR> );
				next if self.assert-hash-keys( $_, [< EXPR >] )
					and self._EXPR( $_.hash.<EXPR> );
				next if self.assert-hash-keys( $_,
						[< statement_control >] )
					and self._StatementControl(
						$_.hash.<statement_control>
					);
				next if self.assert-hash-keys( $_, [],
						[< statement_control >] );
				debug-match( $_ );
				return self.record-failure( '_Statement list' );
			}
			return True
		}
		return True if self.assert-hash-keys( $parsed,
				[< statement_control >] )
			and self._StatementControl(
				$parsed.hash.<statement_control>
			);
		return True if self.assert-hash-keys( $parsed, [< EXPR >] )
			and self._EXPR( $parsed.hash.<EXPR> );
		debug-match( $parsed );
		return self.record-failure( '_Statement' );
	}

	method _StatementList( Mu $parsed ) {
		self.trace( '_StatementList' );
#return True;
		return True if self.assert-hash-keys( $parsed, [< statement >] )
			and self._Statement( $parsed.hash.<statement> );
		return True if self.assert-hash-keys( $parsed, [],
			[< statement >]
		);
		# This line is caught above, but is where comments and POD are
		# stored.
		return True if self.assert-Str( $parsed );
		debug-match( $parsed );
		return self.record-failure( '_StatementList' );
	}

	method _StatementModCond( Mu $parsed ) {
		self.trace( '_StatementModCond' );
#return True;
		return True if self.assert-hash-keys( $parsed,
				[< sym modifier_expr >] )
			and self._Sym( $parsed.hash.<sym> )
			and self._ModifierExpr( $parsed.hash.<modifier_expr> );
		debug-match( $parsed );
		return self.record-failure( '_StatementModCond' );
	}

	method _StatementModLoop( Mu $parsed ) {
		self.trace( '_StatementModLoop' );
#return True;
		return True if self.assert-hash-keys( $parsed,
				[< sym smexpr >] )
			and self._Sym( $parsed.hash.<sym> )
			and self._SMExpr( $parsed.hash.<smexpr> );
		debug-match( $parsed );
		return self.record-failure( '_StatementModLoop' );
	}

	method _StatementPrefix( Mu $parsed ) {
		self.trace( '_StatementPrefix' );
#return True;
		return True if self.assert-hash-keys( $parsed,
				[< sym blorst >] )
			and self._Sym( $parsed.hash.<sym> )
			and self._Blorst( $parsed.hash.<blorst> );
		debug-match( $parsed );
		return self.record-failure( '_StatementPrefix' );
		return False
	}

	method _SubShortName( Mu $parsed ) {
		self.trace( '_SubShortName' );
#return True;
		return True if self.assert-hash-keys( $parsed,
				[< desigilname >] )
			and self._DeSigilName( $parsed.hash.<desigilname> );
		debug-match( $parsed );
		return self.record-failure( '_SubShortName' );
	}

	method _Sym( Mu $parsed ) {
		self.trace( '_Sym' );
#return True;
		if $parsed.list {
			for $parsed.list {
				next if $_.Str;
				debug-match( $_ );
				return self.record-failure( '_Sym list' );
			}
			return True
		}
		return True if $parsed.Bool and $parsed.Str eq '+';
		return True if $parsed.Bool and $parsed.Str eq '';
		return True if self.assert-Str( $parsed );
		debug-match( $parsed );
		return self.record-failure( '_Sym' );
	}

	method _Term( Mu $parsed ) {
		self.trace( '_Term' );
#return True;
		return True if self.assert-hash-keys( $parsed, [< methodop >] )
			and self._MethodOp( $parsed.hash.<methodop> );
		return True if self.assert-hash-keys( $parsed, [< circumfix >] )
			and self._Circumfix( $parsed.hash.<circumfix> );
		debug-match( $parsed );
		return self.record-failure( '_Term' );
	}

	method _TermAlt( Mu $parsed ) {
		self.trace( '_TermAlt' );
#return True;
		if $parsed.list {
			for $parsed.list {
				next if self.assert-hash-keys( $_,
						[< termconj >] )
					and self._TermConj( $_.hash.<termconj> );
				debug-match( $_ );
				return self.record-failure( '_TermAlt list' );
			}
			return True
		}
		debug-match( $parsed );
		return self.record-failure( '_TermAlt' );
	}

	method _TermAltSeq( Mu $parsed ) {
		self.trace( '_TermAltSeq' );
#return True;
		return True if self.assert-hash-keys( $parsed,
				[< termconjseq >] )
			and self._TermConjSeq( $parsed.hash.<termconjseq> );
		debug-match( $parsed );
		return self.record-failure( '_TermAltSeq' );
	}

	method _TermConj( Mu $parsed ) {
		self.trace( '_TermConj' );
#return True;
		if $parsed.list {
			for $parsed.list {
				next if self.assert-hash-keys( $_,
						[< termish >] )
					and self._Termish( $_.hash.<termish> );
				debug-match( $_ );
				return self.record-failure( '_TermConj list' );
			}
			return True
		}
		debug-match( $parsed );
		return self.record-failure( '_TermConj' );
	}

	method _TermConjSeq( Mu $parsed ) {
		self.trace( '_TermConjSeq' );
#return True;
		if $parsed.list {
			for $parsed.list {
				next if self.assert-hash-keys( $_,
						[< termalt >] )
					and self._TermAlt( $_.hash.<termalt> );
				debug-match( $_ );
				return self.record-failure( '_TermConjSeq list' );
			}
			return True
		}
		return True if self.assert-hash-keys( $parsed, [< termalt >] )
			and self._TermAlt( $parsed.hash.<termalt> );
		debug-match( $parsed );
		return self.record-failure( '_TermConjSeq' );
	}

	method _TermInit( Mu $parsed ) {
		self.trace( '_TermInit' );
#return True;
		return True if self.assert-hash-keys( $parsed, [< sym EXPR >] )
			and self._Sym( $parsed.hash.<sym> )
			and self._EXPR( $parsed.hash.<EXPR> );
		debug-match( $parsed );
		return self.record-failure( '_TermInit' );
	}

	method _Termish( Mu $parsed ) {
		self.trace( '_Termish' );
#return True;
		if $parsed.list {
			for $parsed.list {
				next if self.assert-hash-keys( $_, [< noun >] )
					and self._Noun( $_.hash.<noun> );
				debug-match( $_ );
				return self.record-failure( '_Termish list' );
			}
			return True
		}
		return True if self.assert-hash-keys( $parsed, [< noun >] )
			and self._Noun( $parsed.hash.<noun> );
		debug-match( $parsed );
		return self.record-failure( '_Termish' );
	}

	method _TermSeq( Mu $parsed ) {
		self.trace( '_TermSeq' );
#return True;
		return True if self.assert-hash-keys( $parsed,
				[< termaltseq >] )
			and self._TermAltSeq( $parsed.hash.<termaltseq> );
		debug-match( $parsed );
		return self.record-failure( '_TermSeq' );
	}

	method _TraitMod( Mu $parsed ) {
		self.trace( '_Trait' );
#return True;
		return True if self.assert-hash-keys( $parsed,
				[< sym longname >], [< circumfix >] )
			and self._Sym( $parsed.hash.<sym> )
			and self._LongName( $parsed.hash.<longname> );
		return True if self.assert-hash-keys( $parsed,
				[< sym typename >] )
			and self._Sym( $parsed.hash.<sym> )
			and self._TypeName( $parsed.hash.<typename> );
		debug-match( $parsed );
		return self.record-failure( '_TraitMod' );
	}

	method _Trait( Mu $parsed ) {
		self.trace( '_Trait' );
#return True;
		if $parsed.list {
			for $parsed.list {
				return True if self.assert-hash-keys( $_,
						[< trait_mod >] )
					and self._TraitMod(
						$_.hash.<trait_mod>
					);
				debug-match( $_ );
				return self.record-failure( '_XBlock list' );
			}
			return True
		}
		debug-match( $parsed );
		return self.record-failure( '_Trait' );
	}

	method _Triangle( Mu $parsed ) {
		self.trace( '_Triangle' );
#return True;
		return True if self.assert-hash-keys( $parsed,
				[< sym typename >] )
			and self._Sym( $parsed.hash.<sym> )
			and self._TypeName( $parsed.hash.<typename> );
		return True if self.assert-Str( $parsed );
		debug-match( $parsed );
		return self.record-failure( '_Triangle' );
	}

	method _Twigil( Mu $parsed ) {
		self.trace( '_Twigil' );
#return True;
		return True if self.assert-hash-keys( $parsed, [< sym >] )
			and self._Sym( $parsed.hash.<sym> );
		debug-match( $parsed );
		return self.record-failure( '_Twigil' );
	}

	method _TypeConstraint( Mu $parsed ) {
		self.trace( '_TypeConstraint' );
#return True;
		if $parsed.list {
			for $parsed.list {
				next if self.assert-hash-keys( $_,
						[< typename >] )
					and self._TypeName( $_.hash.<typename> );
				next if self.assert-hash-keys( $_, [< value >] )
					and self._Value( $_.hash.<value> );
				debug-match( $_ );
				return self.record-failure( '_TypeConstraint list' );
			}
			return True
		}
		return True if self.assert-hash-keys( $parsed, [< value >] )
			and self._Value( $parsed.hash.<value> );
		return True if self.assert-hash-keys( $parsed, [< typename >] )
			and self._TypeName( $parsed.hash.<typename> );
		debug-match( $parsed );
		return self.record-failure( '_TypeConstraint' );
	}

	method _TypeDeclarator( Mu $parsed ) {
		self.trace( '_TypeDeclarator' );
#return True;
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
				[< sym longname term >], [< trait >] )
			and self._Sym( $parsed.hash.<sym> )
			and self._LongName( $parsed.hash.<longname> )
			and self._Term( $parsed.hash.<term> );
		return True if self.assert-hash-keys( $parsed,
				[< sym longname trait >] )
			and self._Sym( $parsed.hash.<sym> )
			and self._LongName( $parsed.hash.<longname> )
			and self._Trait( $parsed.hash.<trait> );
		return True if self.assert-hash-keys( $parsed,
				[< sym longname >], [< trait >] )
			and self._Sym( $parsed.hash.<sym> )
			and self._LongName( $parsed.hash.<longname> );
		return True if self.assert-hash-keys( $parsed,
				[< sym initializer >] )
			and self._Sym( $parsed.hash.<sym> )
			and self._Initializer( $parsed.hash.<initializer> );
		debug-match( $parsed );
		return self.record-failure( '_TypeDeclarator' );
	}

	method _TypeName( Mu $parsed ) {
		self.trace( '_TypeName' );
#return True;
		if $parsed.list {
			for $parsed.list {
				next if self.assert-hash-keys( $_,
						[< longname colonpairs >],
						[< colonpair >] )
					and self._LongName( $_.hash.<longname> )
					and self._ColonPairs(
						$_.hash.<colonpairs>
					);
				next if self.assert-hash-keys( $_,
						[< longname >],
						[< colonpair colonpair >] )
					and self._LongName( $_.hash.<longname> );
				next if self.assert-hash-keys( $_,
						[< longname >],
						[< colonpair >] )
					and self._LongName(
						$_.hash.<longname>
					);
				debug-match( $_ );
				return self.record-failure( '_TypeName list' );
			}
			return True
		}
		return True if self.assert-hash-keys( $parsed,
				[< longname >], [< colonpair >] )
			and self._LongName( $parsed.hash.<longname> );
		debug-match( $parsed );
		return self.record-failure( '_TypeName' );
	}

	method _Val( Mu $parsed ) {
		self.trace( '_Val' );
#return True;
		return True if self.assert-hash-keys( $parsed,
				[< postcircumfix OPER >],
				[< postfix_prefix_meta_operator >] )
			and self._PostCircumfix( $parsed.hash.<postcircumfix> )
			and self._OPER( $parsed.hash.<OPER> );
		return True if self.assert-hash-keys( $parsed,
				[< longname args >] )
			and self._LongName( $parsed.hash.<longname> )
			and self._Args( $parsed.hash.<args> );
		return True if self.assert-hash-keys( $parsed,
				[< prefix OPER >],
				[< prefix_postfix_meta_operator >] )
			and self._Prefix( $parsed.hash.<prefix> )
			and self._OPER( $parsed.hash.<OPER> );
		return True if self.assert-hash-keys( $parsed, [< value >] )
			and self._Value( $parsed.hash.<value> );
		debug-match( $parsed );
		return self.record-failure( '_Val' );
	}

	method _Value( Mu $parsed ) {
		self.trace( '_Value' );
#return True;
		return True if self.assert-hash-keys( $parsed, [< number >] )
			and self._Number( $parsed.hash.<number> );
		return True if self.assert-hash-keys( $parsed, [< quote >] )
			and self._Quote( $parsed.hash.<quote> );
		debug-match( $parsed );
		return self.record-failure( '_Value' );
	}

	method _VALUE( Mu $parsed ) {
		self.trace( '_VALUE' );
#return True;
		return True if $parsed.Str and $parsed.Str eq '0';
		return True if self.assert-Int( $parsed );
		debug-match( $parsed );
		return self.record-failure( '_VALUE' );
	}

	method _Var( Mu $parsed ) {
		self.trace( '_Var' );
#return True;
		return True if self.assert-hash-keys( $parsed,
				[< sigil twigil desigilname >] )
			and self._Sigil( $parsed.hash.<sigil> )
			and self._Twigil( $parsed.hash.<twigil> )
			and self._DeSigilName( $parsed.hash.<desigilname> );
		return True if self.assert-hash-keys( $parsed,
				[< sigil desigilname >] )
			and self._Sigil( $parsed.hash.<sigil> )
			and self._DeSigilName( $parsed.hash.<desigilname> );
		return True if self.assert-hash-keys( $parsed, [< variable >] )
			and self._Variable( $parsed.hash.<variable> );
		debug-match( $parsed );
		return self.record-failure( '_Var' );
	}

	method _VariableDeclarator( Mu $parsed ) {
		self.trace( '_VariableDeclarator' );
#return True;
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
		debug-match( $parsed );
		return self.record-failure( '_VariableDeclarator' );
	}

	method _Variable( Mu $parsed ) {
		self.trace( '_Variable' );
#return True;
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
		debug-match( $parsed );
		return self.record-failure( '_Variable' );
	}

	method _Version( Mu $parsed ) {
		self.trace( '_Version' );
#return True;
		return True if self.assert-hash-keys( $parsed, [< vnum vstr >] )
			and self._VNum( $parsed.hash.<vnum> )
			and self._VStr( $parsed.hash.<vstr> );
		debug-match( $parsed );
		return self.record-failure( '_Version' );
	}

	method _VNum( Mu $parsed ) {
		self.trace( '_VNum' );
#return True;
		if $parsed.list {
			for $parsed.list {
				next if self.assert-Int( $_ );
				debug-match( $parsed );
				return self.record-failure( '_VNum list' );
			}
			return True
		}
		debug-match( $parsed );
		return self.record-failure( '_VNum' );
	}

	method _VStr( Mu $parsed ) returns Bool {
		self.trace( '_VStr' );
#return True;
		return True if self.assert-Int( $parsed );
		debug-match( $parsed );
		return self.record-failure( '_VStr' );
	}

	method _Wu( Mu $parsed ) returns Bool {
		self.trace( '_Wu' );
#return True;
		return True if self.assert-Str( $parsed );
		debug-match( $parsed );
		return self.record-failure( '_Wu' );
	}

	method _XBlock( Mu $parsed ) returns Bool {
		self.trace( '_XBlock' );
#return True;
		if $parsed.list {
			for $parsed.list {
				next if self.assert-hash-keys( $_,
						[< pblock EXPR >] )
					and self._PBlock( $_.hash.<pblock> )
					and self._EXPR( $_.hash.<EXPR> );
				debug-match( $_ );
				return self.record-failure( '_XBlock list' );
			}
			return True
		}
		return True if self.assert-hash-keys( $parsed,
				[< pblock EXPR >] )
			and self._PBlock( $parsed.hash.<pblock> )
			and self._EXPR( $parsed.hash.<EXPR> );
		return True if self.assert-hash-keys( $parsed, [< blockoid >] )
			and self._Blockoid( $parsed.hash.<blockoid> );
		debug-match( $parsed );
		return self.record-failure( '_XBlock' );
	}
}
