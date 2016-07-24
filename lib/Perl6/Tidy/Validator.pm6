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
			and self.deftermnow( $parsed.hash.<deftermnow> )
			and self.initializer( $parsed.hash.<initializer> )
			and self.terminit( $parsed.hash.<term_init> );
		return True if self.assert-hash-keys( $parsed, [< EXPR >] )
			and self.EXPR( $parsed.hash.<EXPR> );
		return True if self.assert-Bool( $parsed );
		return False
	}

	method args( Mu $parsed ) returns Bool {
		return True if self.assert-Bool( $parsed );
		return False
	}

	method assertion( Mu $parsed ) returns Bool {
		return True if self.assert-hash-keys( $parsed, [< var >] )
			and self.var( $parsed.hash.<var> );
		return True if self.assert-hash-keys( $parsed, [< longname >] )
			and self.longname( $parsed.hash.<longname> );
		return True if self.assert-hash-keys( $parsed, [< cclass_elem >] )
			and self.cclass_elem( $parsed.hash.<cclass_elem> );
		return True if self.assert-hash-keys( $parsed, [< codeblock >] )
			and self.codeblock( $parsed.hash.<codeblock> );
		return True if $parsed.Str;
		return False
	}

	method atom( Mu $parsed ) returns Bool {
		return True if self.assert-hash-keys( $parsed, [< metachar >] )
			and self.metachar( $parsed.hash.<metachar> );
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
			and self.B( $parsed.hash.<B> );
		return False
	}

	method backmod( Mu $parsed ) returns Bool {
		return True if self.assert-Bool( $parsed );
		return False
	}

	method backslash( Mu $parsed ) returns Bool {
		return True if self.assert-hash-keys( $parsed, [< sym >] )
			and self.sym( $parsed.hash.<sym> );
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
			and self.blockoid( $parsed.hash.<blockoid> );
		return False
	}

	method blockoid( Mu $parsed ) returns Bool {
		return True if self.assert-hash-keys( $parsed, [< statementlist >] )
			and self.statementlist( $parsed.hash.<statementlist> );
		return False
	}

	method blorst( Mu $parsed ) returns Bool {
		return True if self.assert-hash-keys( $parsed, [< statement >] )
			and self.statement( $parsed.hash.<statement> );
		return True if self.assert-hash-keys( $parsed, [< block >] )
			and self.block( $parsed.hash.<block> );
		return False
	}

	method bracket( Mu $parsed ) returns Bool {
		return True if self.assert-hash-keys( $parsed, [< semilist >] )
			and self.semilist( $parsed.hash.<semilist> );
		return False
	}

	method cclass_elem( Mu $parsed ) returns Bool {
		if $parsed.list {
			for $parsed.list {
				next if self.assert-hash-keys( $_,
						[< identifier name sign >],
						[< charspec >] )
					and self.identifier( $_.hash.<identifier> )
					and self.name( $_.hash.<name> )
					and self.charspec( $_.hash.<charspec> );
				next if self.assert-hash-keys( $_,
						[< sign charspec >] )
					and self.sign( $_.hash.<sign> )
					and self.charspec( $_.hash.<charspec> );
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
			and self.nibble( $parsed.hash.<nibble> );
		return True if self.assert-hash-keys( $parsed, [< pblock >] )
			and self.pblock( $parsed.hash.<pblock> );
		return True if self.assert-hash-keys( $parsed, [< semilist >] )
			and self.semilist( $parsed.hash.<semilist> );
		return True if self.assert-hash-keys( $parsed, [< binint VALUE >] )
			and self.binint( $parsed.hash.<binint> )
			and self.VALUE( $parsed.hash.<VALUE> );
		return True if self.assert-hash-keys( $parsed, [< octint VALUE >] )
			and self.octint( $parsed.hash.<octint> )
			and self.VALUE( $parsed.hash.<VALUE> );
		return True if self.assert-hash-keys( $parsed, [< hexint VALUE >] )
			and self.hexint( $parsed.hash.<hexint> )
			and self.VALUE( $parsed.hash.<VALUE> );
		return False
	}

	method codeblock( Mu $parsed ) returns Bool {
		return True if self.assert-hash-keys( $parsed, [< block >] )
			and self.block( $parsed.hash.<block> );
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
			and self.semilist( $parsed.hash.<semilist> );
		return False
	}

	method coloncircumfix( Mu $parsed ) returns Bool {
		return True if self.assert-hash-keys( $parsed, [< circumfix >] )
			and self.circumfix( $parsed.hash.<circumfix> );
		return False
	}

	method colonpair( Mu $parsed ) returns Bool {
		return True if self.assert-hash-keys( $parsed,
				     [< identifier coloncircumfix >] )
			and self.identifier( $parsed.hash.<identifier> )
			and self.coloncircumfix( $parsed.hash.<coloncircumfix> );
		return True if self.assert-hash-keys( $parsed, [< identifier >] )
			and self.identifier( $parsed.hash.<identifier> );
		return True if self.assert-hash-keys( $parsed, [< fakesignature >] )
			and self.fakesignature( $parsed.hash.<fakesignature> );
		return True if self.assert-hash-keys( $parsed, [< var >] )
			and self.var( $parsed.hash.<var> );
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
			and self.coercee( $parsed.hash.<coercee> )
			and self.circumfix( $parsed.hash.<circumfix> )
			and self.sigil( $parsed.hash.<sigil> );
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
			and self.deftermnow( $parsed.hash.<deftermnow> )
			and self.initializer( $parsed.hash.<initializer> )
			and self.terminit( $parsed.hash.<term_init> );
		return True if self.assert-hash-keys( $parsed,
				[< initializer signature >], [< trait >] )
			and self.initializer( $parsed.hash.<initializer> )
			and self.signature( $parsed.hash.<signature> );
		return True if self.assert-hash-keys( $parsed,
				  [< initializer variable_declarator >],
				  [< trait >] )
			and self.initializer( $parsed.hash.<initializer> )
			and self.variable_declarator( $parsed.hash.<variable_declarator> );
		return True if self.assert-hash-keys( $parsed,
				[< variable_declarator >], [< trait >] )
			and self.variable_declarator( $parsed.hash.<variable_declarator> );
		return True if self.assert-hash-keys( $parsed,
				[< regex_declarator >], [< trait >] )
			and self.regex_declarator( $parsed.hash.<regex_declarator> );
		return True if self.assert-hash-keys( $parsed,
				[< routine_declarator >], [< trait >] )
			and self.routine_declarator( $parsed.hash.<routine_declarator> );
		return True if self.assert-hash-keys( $parsed,
				[< signature >], [< trait >] )
			and self.signature( $parsed.hash.<signature> );
		return False
	}

	method declarator( Mu $parsed ) returns Bool {
		return True if self.assert-hash-keys( $parsed,
				[< deftermnow initializer term_init >], [< trait >] )
			and self.deftermnow( $parsed.hash.<deftermnow> )
			and self.initializer( $parsed.hash.<initializer> )
			and self.terminit( $parsed.hash.<term_init> );
		return True if self.assert-hash-keys( $parsed,
				[< deftermnow initializer signature >], [< trait >] )
			and self.deftermnow( $parsed.hash.<deftermnow> )
			and self.initializer( $parsed.hash.<initializer> )
			and self.signature( $parsed.hash.<signature> );
		return True if self.assert-hash-keys( $parsed,
				[< initializer signature >], [< trait >] )
			and self.initializer( $parsed.hash.<initializer> )
			and self.signature( $parsed.hash.<signature> );
		return True if self.assert-hash-keys( $parsed,
					  [< initializer variable_declarator >],
					  [< trait >] )
			and self.initializer( $parsed.hash.<initializer> )
			and self.variable_declarator( $parsed.hash.<variable_declarator> );
		return True if self.assert-hash-keys( $parsed,
				[< signature >], [< trait >] )
			and self.signature( $parsed.hash.<signature> );
		return True if self.assert-hash-keys( $parsed,
					  [< variable_declarator >],
					  [< trait >] )
			and self.variable_declarator( $parsed.hash.<variable_declarator> );
		return True if self.assert-hash-keys( $parsed,
					  [< regex_declarator >],
					  [< trait >] )
			and self.regex_declarator( $parsed.hash.<regex_declarator> );
		return True if self.assert-hash-keys( $parsed,
					  [< routine_declarator >],
					  [< trait >] )
			and self.routine_declarator( $parsed.hash.<routine_declarator> );
		return True if self.assert-hash-keys( $parsed,
					  [< package_def sym >] )
			and self.package_def( $parsed.hash.<package_def> )
			and self.sym( $parsed.hash.<sym> );
		return True if self.assert-hash-keys( $parsed,
					  [< declarator >] )
			and self.declarator( $parsed.hash.<declarator> );
		return False
	}

	method dec_number( Mu $parsed ) returns Bool {
		return True if self.assert-hash-keys( $parsed,
				  [< int coeff frac escale >] )
			and self.int( $parsed.hash.<int> )
			and self.coeff( $parsed.hash.<coeff> )
			and self.frac( $parsed.hash.<frac> )
			and self.escale( $parsed.hash.<escale> );
		return True if self.assert-hash-keys( $parsed,
				  [< coeff frac escale >] )
			and self.coeff( $parsed.hash.<coeff> )
			and self.frac( $parsed.hash.<frac> )
			and self.escale( $parsed.hash.<escale> );
		return True if self.assert-hash-keys( $parsed,
				  [< int coeff frac >] )
			and self.int( $parsed.hash.<int> )
			and self.coeff( $parsed.hash.<coeff> )
			and self.frac( $parsed.hash.<frac> );
		return True if self.assert-hash-keys( $parsed,
				  [< int coeff escale >] )
			and self.int( $parsed.hash.<int> )
			and self.coeff( $parsed.hash.<coeff> )
			and self.escale( $parsed.hash.<escale> );
		return True if self.assert-hash-keys( $parsed,
				  [< coeff frac >] )
			and self.coeff( $parsed.hash.<coeff> )
			and self.frac( $parsed.hash.<frac> );
		return False
	}

	method deflongname( Mu $parsed ) returns Bool {
		return True if self.assert-hash-keys( $parsed,
				[< name >], [< colonpair >] )
			and self.name( $parsed.hash.<name> );
		return False
	}

	method defterm( Mu $parsed ) returns Bool {
		return True if self.assert-hash-keys( $parsed,
				[< identifier colonpair >] )
			and self.identifier( $parsed.hash.<identifier> )
			and self.colonpair( $parsed.hash.<colonpair> );
		return True if self.assert-hash-keys( $parsed,
				[< identifier >], [< colonpair >] )
			and self.identifier( $parsed.hash.<identifier> );
		return False
	}

	method deftermnow( Mu $parsed ) returns Bool {
		return True if self.assert-hash-keys( $parsed, [< defterm >] )
			and self.defterm( $parsed.hash.<defterm> );
		return False
	}

	method desigilname( Mu $parsed ) returns Bool {
		return True if self.assert-hash-keys( $parsed, [< longname >] )
			and self.longname( $parsed.hash.<longname> );
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
			and self.sym( $parsed.hash.<sym> )
			and self.dottyop( $parsed.hash.<dottyop> )
			and self.O( $parsed.hash.<O> );
		return False
	}

	method dottyop( Mu $parsed ) returns Bool {
		return True if self.assert-hash-keys( $parsed,
				[< sym postop >], [< O >] )
			and self.sym( $parsed.hash.<sym> )
			and self.postop( $parsed.hash.<postop> );
		return True if self.assert-hash-keys( $parsed, [< methodop >] )
			and self.methodop( $parsed.hash.<methodop> );
		return True if self.assert-hash-keys( $parsed, [< colonpair >] )
			and self.colonpair( $parsed.hash.<colonpair> );
		return False
	}

	method dottyopish( Mu $parsed ) returns Bool {
		return True if self.assert-hash-keys( $parsed, [< term >] )
			and self.term( $parsed.hash.<term> );
		return False
	}

	method e1( Mu $parsed ) returns Bool {
		return True if self.assert-hash-keys( $parsed,
				[< scope_declarator >] )
			and self.scope_declarator( $parsed.hash.<scope_declarator> );
		return False
	}

	method e2( Mu $parsed ) returns Bool {
		return True if self.assert-hash-keys( $parsed,
				[< infix OPER >] )
			and self.infix( $parsed.hash.<infix> )
			and self.OPER( $parsed.hash.<OPER> );
		return False
	}

	method e3( Mu $parsed ) returns Bool {
		return True if self.assert-hash-keys( $parsed,
				[< postfix OPER >],
				[< postfix_prefix_meta_operator >] )
			and self.postfix( $parsed.hash.<postfix> )
			and self.OPER( $parsed.hash.<OPER> );
		return False
	}

	method else( Mu $parsed ) returns Bool {
		return True if self.assert-hash-keys( $parsed, [< sym blorst >] )
			and self.sym( $parsed.hash.<sym> )
			and self.blorst( $parsed.hash.<blorst> );
		return True if self.assert-hash-keys( $parsed, [< blockoid >] )
			and self.blockoid( $parsed.hash.<blockoid> );
		return False
	}

	method escale( Mu $parsed ) returns Bool {
		return True if self.assert-hash-keys( $parsed, [< sign decint >] )
			and self.sign( $parsed.hash.<sign> )
			and self.decint( $parsed.hash.<decint> );
		return False
	}

	method EXPR( Mu $parsed ) returns Bool {
		if $parsed.list {
			for $parsed.list {
				next if self.assert-hash-keys( $_,
						[< dotty OPER >],
						[< postfix_prefix_meta_operator >] )
					and self.dotty( $_.hash.<dotty> )
					and self.OPER( $_.hash.<OPER> );
				next if self.assert-hash-keys( $_,
					[< postcircumfix OPER >],
					[< postfix_prefix_meta_operator >] )
					and self.postcircumfix( $_.hash.<postcircumfix> )
					and self.OPER( $_.hash.<OPER> );
				next if self.assert-hash-keys( $_,
						[< infix OPER >],
						[< infix_postfix_meta_operator >] )
					and self.infix( $_.hash.<infix> )
					and self.OPER( $_.hash.<OPER> );
				next if self.assert-hash-keys( $_,
						[< prefix OPER >],
						[< prefix_postfix_meta_operator >] )
					and self.prefix( $_.hash.<prefix> )
					and self.OPER( $_.hash.<OPER> );
				next if self.assert-hash-keys( $_,
						[< postfix OPER >],
						[< postfix_prefix_meta_operator >] )
					and self.postfix( $_.hash.<postfix> )
					and self.OPER( $_.hash.<OPER> );
				next if self.assert-hash-keys( $_,
						[< identifier args >] )
					and self.identifier( $_.hash.<identifier> )
					and self.args( $_.hash.<args> );
				next if self.assert-hash-keys( $_,
					[< infix_prefix_meta_operator OPER >] )
					and self.infixprefixmetaoperator( $_ )
					and self.OPER( $_.hash.<OPER> );
				next if self.assert-hash-keys( $_,
						[< longname args >] )
					and self.longname( $_.hash.<longname> )
					and self.args( $_.hash.<args> );
				next if self.assert-hash-keys( $_,
						[< args op >] )
					and self.args( $_.hash.<args> )
					and self.op( $_.hash.<op> );
				next if self.assert-hash-keys( $_, [< value >] )
					and self.value( $_.hash.<value> );
				next if self.assert-hash-keys( $_, [< longname >] )
					and self.longname( $_.hash.<longname> );
				next if self.assert-hash-keys( $_, [< variable >] )
					and self.variable( $_.hash.<variable> );
				next if self.assert-hash-keys( $_, [< methodop >] )
					and self.methodop( $_.hash.<methodop> );
				next if self.assert-hash-keys( $_, [< package_declarator >] )
					and self.package_declarator( $_.hash.<package_declarator> );
				next if self.assert-hash-keys( $_, [< sym >] )
					and self.sym( $_.hash.<sym> );
				next if self.assert-hash-keys( $_, [< scope_declarator >] )
					and self.scope_declarator( $_.hash.<scope_declarator> );
				next if self.assert-hash-keys( $_, [< dotty >] )
					and self.dotty( $_.hash.<dotty> );
				next if self.assert-hash-keys( $_, [< circumfix >] )
					and self.circumfix( $_.hash.<circumfix> );
				next if self.assert-hash-keys( $_, [< fatarrow >] )
					and self.fatarrow( $_.hash.<fatarrow> );
				next if self.assert-hash-keys( $_, [< statement_prefix >] )
					and self.statementprefix( $_.hash.<statement_prefix> );
				next if self.assert-Str( $_ );
				die self.new-term
			}
			return True if self.assert-hash-keys(
					$parsed,
					[< fake_infix OPER colonpair >] )
				and self.fakeinfix( $parsed.hash.<fake_infix> )
				and self.OPER( $parsed.hash.<OPER> )
				and self.colonpair( $parsed.hash.<colonpair> );
			return True if self.assert-hash-keys(
					$parsed,
					[< OPER dotty >],
					[< postfix_prefix_meta_operator >] )
				and self.OPER( $parsed.hash.<OPER> )
				and self.dotty( $parsed.hash.<dotty> );
			return True if self.assert-hash-keys(
					$parsed,
					[< postfix OPER >],
					[< postfix_prefix_meta_operator >] )
				and self.postfix( $parsed.hash.<postfix> )
				and self.OPER( $parsed.hash.<OPER> );
			return True if self.assert-hash-keys(
					$parsed,
					[< infix OPER >],
					[< prefix_postfix_meta_operator >] )
				and self.infix( $parsed.hash.<infix> )
				and self.OPER( $parsed.hash.<OPER> );
			return True if self.assert-hash-keys(
					$parsed,
					[< prefix OPER >],
					[< prefix_postfix_meta_operator >] )
				and self.prefix( $parsed.hash.<prefix> )
				and self.OPER( $parsed.hash.<OPER> );
			return True if self.assert-hash-keys(
					$parsed,
					[< postcircumfix OPER >],
					[< postfix_prefix_meta_operator >] )
				and self.postcircumfix( $parsed.hash.<postcircumfix> )
				and self.OPER( $parsed.hash.<OPER> );
			return True if self.assert-hash-keys( $parsed,
					[< OPER >],
					[< infix_prefix_meta_operator >] )
				and self.OPER( $parsed.hash.<OPER> );
			die self.new-term
		}
		return True if self.assert-hash-keys( $parsed,
				[< args op triangle >] )
			and self.args( $parsed.hash.<args> )
			and self.op( $parsed.hash.<op> )
			and self.triangle( $parsed.hash.<triangle> );
		return True if self.assert-hash-keys( $parsed, [< longname args >] )
			and self.longname( $parsed.hash.<longname> )
			and self.args( $parsed.hash.<args> );
		return True if self.assert-hash-keys( $parsed, [< identifier args >] )
			and self.identifier( $parsed.hash.<identifier> )
			and self.args( $parsed.hash.<args> );
		return True if self.assert-hash-keys( $parsed, [< args op >] )
			and self.args( $parsed.hash.<args> )
			and self.op( $parsed.hash.<op> );
		return True if self.assert-hash-keys( $parsed, [< sym args >] )
			and self.sym( $parsed.hash.<sym> )
			and self.args( $parsed.hash.<args> );
		return True if self.assert-hash-keys( $parsed, [< statement_prefix >] )
			and self.statementprefix( $parsed.hash.<statement_prefix> );
		return True if self.assert-hash-keys( $parsed, [< type_declarator >] )
			and self.type_declarator( $parsed.hash.<type_declarator> );
		return True if self.assert-hash-keys( $parsed, [< longname >] )
			and self.longname( $parsed.hash.<longname> );
		return True if self.assert-hash-keys( $parsed, [< value >] )
			and self.value( $parsed.hash.<value> );
		return True if self.assert-hash-keys( $parsed, [< variable >] )
			and self.variable( $parsed.hash.<variable> );
		return True if self.assert-hash-keys( $parsed, [< circumfix >] )
			and self.circumfix( $parsed.hash.<circumfix> );
		return True if self.assert-hash-keys( $parsed, [< colonpair >] )
			and self.colonpair( $parsed.hash.<colonpair> );
		return True if self.assert-hash-keys( $parsed, [< scope_declarator >] )
			and self.scope_declarator( $parsed.hash.<scope_declarator> );
		return True if self.assert-hash-keys( $parsed, [< routine_declarator >] )
			and self.routine_declarator( $parsed.hash.<routine_declarator> );
		return True if self.assert-hash-keys( $parsed, [< package_declarator >] )
			and self.package_declarator( $parsed.hash.<package_declarator> );
		return True if self.assert-hash-keys( $parsed, [< fatarrow >] )
			and self.fatarrow( $parsed.hash.<fatarrow> );
		return True if self.assert-hash-keys( $parsed, [< multi_declarator >] )
			and self.multi_declarator( $parsed.hash.<multi_declarator> );
		return True if self.assert-hash-keys( $parsed, [< regex_declarator >] )
			and self.regex_declarator( $parsed.hash.<regex_declarator> );
		return True if self.assert-hash-keys( $parsed, [< dotty >] )
			and self.dotty( $parsed.hash.<dotty> );
		return False
	}

	method fake_infix( Mu $parsed ) returns Bool {
		return True if self.assert-hash-keys( $parsed, [< O >] )
			and self.O( $parsed.hash.<O> );
		return False
	}

	method fakesignature( Mu $parsed ) returns Bool {
		return True if self.assert-hash-keys( $parsed, [< signature >] )
			and self.signature( $parsed.hash.<signature> );
		return False
	}

	method fatarrow( Mu $parsed ) returns Bool {
		return True if self.assert-hash-keys( $parsed, [< val key >] )
			and self.val( $parsed.hash.<val> )
			and self.key( $parsed.hash.<key> );
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
			and self.EXPR( $parsed.hash.<EXPR> )
			and self.O( $parsed.hash.<O> );
		return True if self.assert-hash-keys( $parsed, [< infix OPER >] )
			and self.infix( $parsed.hash.<infix> )
			and self.OPER( $parsed.hash.<OPER> );
		return True if self.assert-hash-keys( $parsed, [< sym O >] )
			and self.sym( $parsed.hash.<sym> )
			and self.O( $parsed.hash.<O> );
		return False
	}

	method infixish( Mu $parsed ) returns Bool {
		return True if self.assert-hash-keys( $parsed, [< infix OPER >] )
			and self.infix( $parsed.hash.<infix> )
			and self.OPER( $parsed.hash.<OPER> );
		return False
	}

	method infix_prefix_meta_operator( Mu $parsed ) returns Bool {
		return True if self.assert-hash-keys( $parsed, [< sym infixish O >] )
			and self.sym( $parsed.hash.<sym> )
			and self.infixish( $parsed.hash.<infixish> )
			and self.O( $parsed.hash.<O> );
		return False
	}

	method initializer( Mu $parsed ) returns Bool {
		return True if self.assert-hash-keys( $parsed, [< sym EXPR >] )
			and self.sym( $parsed.hash.<sym> )
			and self.EXPR( $parsed.hash.<EXPR> );
		return True if self.assert-hash-keys( $parsed, [< dottyopish sym >] )
			and self.dottyopish( $parsed.hash.<dottyopish> )
			and self.sym( $parsed.hash.<sym> );
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
			and self.decint( $parsed.hash.<decint> )
			and self.VALUE( $parsed.hash.<VALUE> );
		return True if self.assert-hash-keys( $parsed,
				[< binint VALUE >] )
			and self.binint( $parsed.hash.<binint> )
			and self.VALUE( $parsed.hash.<VALUE> );
		return True if self.assert-hash-keys( $parsed,
				[< octint VALUE >] )
			and self.octint( $parsed.hash.<octint> )
			and self.VALUE( $parsed.hash.<VALUE> );
		return True if self.assert-hash-keys( $parsed,
				[< hexint VALUE >] )
			and self.hexint( $parsed.hash.<hexint> )
			and self.VALUE( $parsed.hash.<VALUE> );
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
			and self.termseq( $parsed.hash.<termseq> );
		return False
	}

	method longname( Mu $parsed ) returns Bool {
		return True if self.assert-hash-keys( $parsed,
				[< name >],
				[< colonpair >] )
			and self.name( $parsed.hash.<name> );
		return False
	}

	method max( Mu $parsed ) returns Bool {
		return True if self.assert-Str( $parsed );
		return False
	}

	method metachar( Mu $parsed ) returns Bool {
		return True if self.assert-hash-keys( $parsed, [< sym >] )
			and self.sym( $parsed.hash.<sym> );
		return True if self.assert-hash-keys( $parsed, [< codeblock >] )
			and self.codeblock( $parsed.hash.<codeblock> );
		return True if self.assert-hash-keys( $parsed, [< backslash >] )
			and self.backslash( $parsed.hash.<backslash> );
		return True if self.assert-hash-keys( $parsed, [< assertion >] )
			and self.assertion( $parsed.hash.<assertion> );
		return True if self.assert-hash-keys( $parsed, [< nibble >] )
			and self.nibble( $parsed.hash.<nibble> );
		return True if self.assert-hash-keys( $parsed, [< quote >] )
			and self.quote( $parsed.hash.<quote> );
		return True if self.assert-hash-keys( $parsed, [< nibbler >] )
			and self.nibbler( $parsed.hash.<nibbler> );
		return True if self.assert-hash-keys( $parsed, [< statement >] )
			and self.statement( $parsed.hash.<statement> );
		return False
	}

	method method_def( Mu $parsed ) returns Bool {
		return True if self.assert-hash-keys( $parsed,
			     [< specials longname blockoid multisig >],
			     [< trait >] )
			and self.specials( $parsed.hash.<specials> )
			and self.longname( $parsed.hash.<longname> )
			and self.blockoid( $parsed.hash.<blockoid> )
			and self.multisig( $parsed.hash.<multisig> );
		return True if self.assert-hash-keys( $parsed,
			     [< specials longname blockoid >],
			     [< trait >] )
			and self.specials( $parsed.hash.<specials> )
			and self.longname( $parsed.hash.<longname> )
			and self.blockoid( $parsed.hash.<blockoid> );
		return False
	}

	method methodop( Mu $parsed ) returns Bool {
		return True if self.assert-hash-keys( $parsed, [< longname args >] )
			and self.longname( $parsed.hash.<longname> )
			and self.args( $parsed.hash.<args> );
		return True if self.assert-hash-keys( $parsed, [< variable >] )
			and self.variable( $parsed.hash.<variable> );
		return True if self.assert-hash-keys( $parsed, [< longname >] )
			and self.longname( $parsed.hash.<longname> );
		return False
	}

	method min( Mu $parsed ) returns Bool {
		return True if self.assert-hash-keys( $parsed,
				[< decint VALUE >] )
			and self.decint( $parsed.hash.<decint> )
			and self.VALUE( $parsed.hash.<VALUE> );
		return False
	}

	method modifier_expr( Mu $parsed ) returns Bool {
		return True if self.assert-hash-keys( $parsed, [< EXPR >] )
			and self.EXPR( $parsed.hash.<EXPR> );
		return False
	}

	method module_name( Mu $parsed ) returns Bool {
		return True if self.assert-hash-keys( $parsed, [< longname >] )
			and self.longname( $parsed.hash.<longname> );
		return False
	}

	method morename( Mu $parsed ) returns Bool {
		if $parsed.list {
			for $parsed.list {
				next if self.assert-hash-keys( $_,
						[< identifier >] )
					and self.identifier( $_.hash.<identifier> );
				die self.new-term
			}
			return True
		}
		return False
	}

	method multi_declarator( Mu $parsed ) returns Bool {
		return True if self.assert-hash-keys( $parsed,
				[< sym routine_def >] )
			and self.sym( $parsed.hash.<sym> )
			and self.routine_def( $parsed.hash.<routine_def> );
		return True if self.assert-hash-keys( $parsed,
				[< sym declarator >] )
			and self.sym( $parsed.hash.<sym> )
			and self.declarator( $parsed.hash.<declarator> );
		return True if self.assert-hash-keys( $parsed,
				[< declarator >] )
			and self.declarator( $parsed.hash.<declarator> );
		return False
	}

	method multisig( Mu $parsed ) returns Bool {
		return True if self.assert-hash-keys( $parsed, [< signature >] )
			and self.signature( $parsed.hash.<signature> );
		return False
	}

	method name( Mu $parsed ) returns Bool {
		return True if self.assert-hash-keys( $parsed,
			[< param_var type_constraint quant >],
			[< default_value modifier trait post_constraint >] )
			and self.paramvar( $parsed.hash.<param_var> )
			and self.type_constraint( $parsed.hash.<type_constraint> )
			and self.quant( $parsed.hash.<quant> );
		return True if self.assert-hash-keys( $parsed,
				[< identifier >], [< morename >] )
			and self.identifier( $parsed.hash.<identifier> );
		return True if self.assert-hash-keys( $parsed,
				[< subshortname >] )
			and self.subshortname( $parsed.hash.<subshortname> );
		return True if self.assert-hash-keys( $parsed, [< morename >] )
			and self.morename( $parsed.hash.<morename> );
		return True if self.assert-Str( $parsed );
		return False
	}

	method named_param( Mu $parsed ) returns Bool {
		return True if self.assert-hash-keys( $parsed,
				[< param_var >] )
			and self.paramvar( $parsed.hash.<param_var> );
		return False
	}

	method nibble( Mu $parsed ) returns Bool {
		return True if self.assert-hash-keys( $parsed, [< termseq >] )
			and self.termseq( $parsed.hash.<termseq> );
		return True if $parsed.Str;
		return True if $parsed.Bool;
		return False
	}

	method nibbler( Mu $parsed ) returns Bool {
		return True if self.assert-hash-keys( $parsed, [< termseq >] )
			and self.termseq( $parsed.hash.<termseq> );
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
					and self.signaybe( $_.hash.<signaybe> )
					and self.sigfinal( $_.hash.<sigfinal> )
					and self.quantifier( $_.hash.<quantifier> )
					and self.atom( $_.hash.<atom> );
				next if self.assert-hash-keys( $_,
					[< sigfinal quantifier
					   separator atom >] )
					and self.sigfinal( $_.hash.<sigfinal> )
					and self.quantifier( $_.hash.<quantifier> )
					and self.separator( $_.hash.<separator> )
					and self.atom( $_.hash.<atom> );
				next if self.assert-hash-keys( $_,
					[< sigmaybe sigfinal
					   separator atom >] )
					and self.signaybe( $_.hash.<signaybe> )
					and self.sigfinal( $_.hash.<sigfinal> )
					and self.separator( $_.hash.<separator> )
					and self.atom( $_.hash.<atom> );
				next if self.assert-hash-keys( $_,
					[< atom sigfinal quantifier >] )
					and self.sigfinal( $_.hash.<sigfinal> )
					and self.quantifier( $_.hash.<quantifier> )
					and self.atom( $_.hash.<atom> );
				next if self.assert-hash-keys( $_,
						[< atom >], [< sigfinal >] )
					and self.sigfinal( $_.hash.<sigfinal> )
					and self.atom( $_.hash.<atom> );
				die self.new-term
			}
			return True
		}
		return False
	}

	method number( Mu $parsed ) returns Bool {
		return True if self.assert-hash-keys( $parsed, [< numish >] )
			and self.numish( $parsed.hash.<numish> );
		return False
	}

	method numish( Mu $parsed ) returns Bool {
		return True if self.assert-hash-keys( $parsed, [< integer >] )
			and self.integer( $parsed.hash.<integer> );
		return True if self.assert-hash-keys( $parsed, [< rad_number >] )
			and self.rad_number( $parsed.hash.<rad_number> );
		return True if self.assert-hash-keys( $parsed, [< dec_number >] )
			and self.decnumber( $parsed.hash.<dec_number> );
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
			and self.infixprefixmetaoperator( $parsed.hash.<infix_prefix_meta_operator> )
			and self.OPER( $parsed.hash.<OPER> );
		return True if self.assert-hash-keys( $parsed, [< infix OPER >] )
			and self.infix( $parsed.hash.<infix> )
			and self.OPER( $parsed.hash.<OPER> );
		return False
	}

	method OPER( Mu $parsed ) returns Bool {
		return True if self.assert-hash-keys( $parsed, [< sym dottyop O >] )
			and self.sym( $parsed.hash.<sym> )
			and self.dottyop( $parsed.hash.<dottyop> )
			and self.O( $parsed.hash.<O> );
		return True if self.assert-hash-keys( $parsed, [< sym infixish O >] )
			and self.sym( $parsed.hash.<sym> )
			and self.infixish( $parsed.hash.<infixish> )
			and self.O( $parsed.hash.<O> );
		return True if self.assert-hash-keys( $parsed, [< sym O >] )
			and self.sym( $parsed.hash.<sym> )
			and self.O( $parsed.hash.<O> );
		return True if self.assert-hash-keys( $parsed, [< EXPR O >] )
			and self.EXPR( $parsed.hash.<EXPR> )
			and self.O( $parsed.hash.<O> );
		return True if self.assert-hash-keys( $parsed,
				[< semilist O >] )
			and self.semilist( $parsed.hash.<semilist> )
			and self.O( $parsed.hash.<O> );
		return True if self.assert-hash-keys( $parsed, [< nibble O >] )
			and self.nibble( $parsed.hash.<nibble> )
			and self.O( $parsed.hash.<O> );
		return True if self.assert-hash-keys( $parsed, [< arglist O >] )
			and self.arglist( $parsed.hash.<arglist> )
			and self.O( $parsed.hash.<O> );
		return True if self.assert-hash-keys( $parsed, [< dig O >] )
			and self.dig( $parsed.hash.<dig> )
			and self.O( $parsed.hash.<O> );
		return True if self.assert-hash-keys( $parsed, [< O >] )
			and self.O( $parsed.hash.<O> );
		return False
	}

	method package_declarator( Mu $parsed ) returns Bool {
		return True if self.assert-hash-keys( $parsed,
				[< sym package_def >] )
			and self.sym( $parsed.hash.<sym> )
			and self.package_def( $parsed.hash.<package_def> );
		return False
	}

	method package_def( Mu $parsed ) returns Bool {
		return True if self.assert-hash-keys( $parsed,
				[< blockoid longname >], [< trait >] )
			and self.blockoid( $parsed.hash.<blockoid> )
			and self.longname( $parsed.hash.<longname> );
		return True if self.assert-hash-keys( $parsed,
				[< longname statementlist >], [< trait >] )
			and self.longname( $parsed.hash.<longname> )
			and self.statementlist( $parsed.hash.<statementlist> );
		return True if self.assert-hash-keys( $parsed,
				[< blockoid >], [< trait >] )
			and self.blockoid( $parsed.hash.<blockoid> );
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
					and self.param_var( $_.hash.<param_var> )
					and self.type_constraint( $_.hash.<type_constraint> )
					and self.quant( $_.hash.<quant> );
				next if self.assert-hash-keys( $_,
					[< param_var quant >],
					[< default_value modifier trait
					   type_constraint
					   post_constraint >] )
					and self.param_var( $_.hash.<param_var> )
					and self.quant( $_.hash.<quant> );
				next if self.assert-hash-keys( $_,
					[< named_param quant >],
					[< default_value modifier
					   post_constraint trait
					   type_constraint >] )
					and self.namedparam( $_.hash.<namedparam> )
					and self.quant( $_.hash.<quant> );
				next if self.assert-hash-keys( $_,
					[< defterm quant >],
					[< default_value modifier
					   post_constraint trait
					   type_constraint >] )
					and self.defterm( $_.hash.<defterm> )
					and self.quant( $_.hash.<quant> );
				next if self.assert-hash-keys( $_,
					[< type_constraint >],
					[< param_var quant default_value						   modifier post_constraint trait
					   type_constraint >] )
					and self.type_constraint( $_.hash.<type_constraint> );
				die self.new-term
			}
			return True
		}
		return False
	}

	method param_var( Mu $parsed ) returns Bool {
		return True if self.assert-hash-keys( $parsed,
				[< name twigil sigil >] )
			and self.name( $parsed.hash.<name> )
			and self.twigil( $parsed.hash.<twigil> )
			and self.sigil( $parsed.hash.<sigil> );
		return True if self.assert-hash-keys( $parsed, [< name sigil >] )
			and self.name( $parsed.hash.<name> )
			and self.sigil( $parsed.hash.<sigil> );
		return True if self.assert-hash-keys( $parsed, [< signature >] )
			and self.signature( $parsed.hash.<signature> );
		return True if self.assert-hash-keys( $parsed, [< sigil >] )
			and self.sigil( $parsed.hash.<sigil> );
		return False
	}

	method pblock( Mu $parsed ) returns Bool {
		return True if self.assert-hash-keys( $parsed,
				     [< lambda blockoid signature >] )
			and self.lambda( $parsed.hash.<lambda> )
			and self.blockoid( $parsed.hash.<blockoid> )
			and self.signature( $parsed.hash.<signature> );
		return True if self.assert-hash-keys( $parsed, [< blockoid >] )
			and self.blockoid( $parsed.hash.<blockoid> );
		return False
	}

	method postcircumfix( Mu $parsed ) returns Bool {
		return True if self.assert-hash-keys( $parsed, [< nibble O >] )
			and self.nibble( $parsed.hash.<nibble> )
			and self.O( $parsed.hash.<O> );
		return True if self.assert-hash-keys( $parsed, [< semilist O >] )
			and self.semilist( $parsed.hash.<semilist> )
			and self.O( $parsed.hash.<O> );
		return True if self.assert-hash-keys( $parsed, [< arglist O >] )
			and self.arglist( $parsed.hash.<arglist> )
			and self.O( $parsed.hash.<O> );
		return False
	}

	method postfix( Mu $parsed ) returns Bool {
		return True if self.assert-hash-keys( $parsed, [< dig O >] )
			and self.dig( $parsed.hash.<dig> )
			and self.O( $parsed.hash.<O> );
		return True if self.assert-hash-keys( $parsed, [< sym O >] )
			and self.sym( $parsed.hash.<sym> )
			and self.O( $parsed.hash.<O> );
		return False
	}

	method postop( Mu $parsed ) returns Bool {
		return True if self.assert-hash-keys( $parsed,
				[< sym postcircumfix O >] )
			and self.sym( $parsed.hash.<sym> )
			and self.postcircumfix( $parsed.hash.<postcircumfix> )
			and self.O( $parsed.hash.<O> );
		return True if self.assert-hash-keys( $parsed,
				[< sym postcircumfix >], [< O >] )
			and self.sym( $parsed.hash.<sym> )
			and self.postcircumfix( $parsed.hash.<postcircumfix> );
		return False
	}

	method prefix( Mu $parsed ) returns Bool {
		return True if self.assert-hash-keys( $parsed, [< sym O >] )
			and self.sym( $parsed.hash.<sym> )
			and self.O( $parsed.hash.<O> );
		return False
	}

	method quant( Mu $parsed ) returns Bool {
		return True if self.assert-Bool( $parsed );
		return False
	}

	method quantified_atom( Mu $parsed ) returns Bool {
		return True if self.assert-hash-keys( $parsed, [< sigfinal atom >] )
			and self.sigfinal( $parsed.hash.<sigfinal> )
			and self.atom( $parsed.hash.<atom> );
		return False
	}

	method quantifier( Mu $parsed ) returns Bool {
		return True if self.assert-hash-keys( $parsed, [< sym min max backmod >] )
			and self.sym( $parsed.hash.<sym> )
			and self.min( $parsed.hash.<min> )
			and self.max( $parsed.hash.<max> )
			and self.backmod( $parsed.hash.<backmod> );
		return True if self.assert-hash-keys( $parsed, [< sym backmod >] )
			and self.sym( $parsed.hash.<sym> )
			and self.backmod( $parsed.hash.<backmod> );
		return False
	}

	method quibble( Mu $parsed ) returns Bool {
		return True if self.assert-hash-keys( $parsed, [< babble nibble >] )
			and self.babble( $parsed.hash.<babble> )
			and self.nibble( $parsed.hash.<nibble> );
		return False
	}

	method quote( Mu $parsed ) returns Bool {
		return True if self.assert-hash-keys( $parsed,
				[< sym quibble rx_adverbs >] )
			and self.sym( $parsed.hash.<sym> )
			and self.quibble( $parsed.hash.<quibble> )
			and self.rxadverbs( $parsed.hash.<rx_adverbs> );
		return True if self.assert-hash-keys( $parsed,
				[< sym rx_adverbs sibble >] )
			and self.sym( $parsed.hash.<sym> )
			and self.rxadverbs( $parsed.hash.<rx_adverbs> )
			and self.sibble( $parsed.hash.<sibble> );
		return True if self.assert-hash-keys( $parsed, [< nibble >] )
			and self.nibble( $parsed.hash.<nibble> );
		return True if self.assert-hash-keys( $parsed, [< quibble >] )
			and self.quibble( $parsed.hash.<quibble> );
		return False
	}

	method quotepair( Mu $parsed ) returns Bool {
		if $parsed.list {
			for $parsed.list {
				next if self.assert-hash-keys( $_,
					[< identifier >] )
					and self.identifier( $_.hash.<identifier> );
				die self.new-term
			}
			return True
		}
		return True if self.assert-hash-keys( $parsed,
				[< circumfix bracket radix >], [< exp base >] )
			and self.circumfix( $parsed.hash.<circumfix> )
			and self.bracket( $parsed.hash.<bracket> )
			and self.radix( $parsed.hash.<radix> );
		return True if self.assert-hash-keys( $parsed,
				[< identifier >] )
			and self.identifier( $parsed.hash.<identifier> );
		return False
	}

	method radix( Mu $parsed ) returns Bool {
		return True if self.assert-Int( $parsed );
		return False
	}

	method rad_number( Mu $parsed ) returns Bool {
		return True if self.assert-hash-keys( $parsed,
				[< circumfix bracket radix >], [< exp base >] )
			and self.circumfix( $parsed.hash.<circumfix> )
			and self.bracket( $parsed.hash.<bracket> )
			and self.radix( $parsed.hash.<radix> );
		return True if self.assert-hash-keys( $parsed,
				[< circumfix radix >], [< exp base >] )
			and self.circumfix( $parsed.hash.<circumfix> )
			and self.radix( $parsed.hash.<radix> );
		return False
	}

	method regex_declarator( Mu $parsed ) returns Bool {
		return True if self.assert-hash-keys( $parsed, [< sym regex_def >] )
			and self.sym( $parsed.hash.<sym> )
			and self.regexdef( $parsed.hash.<regex_def> );
		return False
	}

	method regex_def( Mu $parsed ) returns Bool {
		return True if self.assert-hash-keys( $parsed,
				[< deflongname nibble >],
				[< signature trait >] )
			and self.deflongname( $parsed.hash.<deflongname> )
			and self.nibble( $parsed.hash.<nibble> );
		return False
	}

	method right( Mu $parsed ) returns Bool {
		return True if self.assert-Bool( $parsed );
		return False
	}

	method routine_declarator( Mu $parsed ) returns Bool {
		return True if self.assert-hash-keys( $parsed, [< sym method_def >] )
			and self.sym( $parsed.hash.<sym> )
			and self.method_def( $parsed.hash.<method_def> );
		return True if self.assert-hash-keys( $parsed,
				[< sym routine_def >] )
			and self.sym( $parsed.hash.<sym> )
			and self.routine_def( $parsed.hash.<routine_def> );
		return False
	}

	method routine_def( Mu $parsed ) returns Bool {
		return True if self.assert-hash-keys( $parsed,
				[< blockoid deflongname multisig >],
				[< trait >] )
			and self.blockoid( $parsed.hash.<blockoid> )
			and self.deflongname( $parsed.hash.<deflongname> )
			and self.multisig( $parsed.hash.<multisig> );
		return True if self.assert-hash-keys( $parsed,
				[< blockoid deflongname >],
				[< trait >] )
			and self.blockoid( $parsed.hash.<blockoid> )
			and self.deflongname( $parsed.hash.<deflongname> );
		return True if self.assert-hash-keys( $parsed,
				[< blockoid multisig >],
				[< trait >] )
			and self.blockoid( $parsed.hash.<blockoid> )
			and self.multisig( $parsed.hash.<multisig> );
		return True if self.assert-hash-keys( $parsed,
				[< blockoid >], [< trait >] )
			and self.blockoid( $parsed.hash.<blockoid> );
		return False
	}

	method rx_adverbs( Mu $parsed ) returns Bool {
		return True if self.assert-hash-keys( $parsed, [< quotepair >] )
			and self.quotepair( $parsed.hash.<quotepair> );
		return True if self.assert-hash-keys( $parsed,
				[], [< quotepair >] );
		return False
	}

	method scoped( Mu $parsed ) returns Bool {
		return True if self.assert-hash-keys( $parsed,
				[< declarator DECL >], [< typename >] )
			and self.declarator( $parsed.hash.<declarator> )
			and self.DECL( $parsed.hash.<DECL> );
		return True if self.assert-hash-keys( $parsed,
					[< multi_declarator DECL typename >] )
			and self.multi_declarator( $parsed.hash.<multi_declarator> )
			and self.DECL( $parsed.hash.<DECL> )
			and self.typename( $parsed.hash.<typename> );
		return True if self.assert-hash-keys( $parsed,
				[< package_declarator DECL >],
				[< typename >] )
			and self.package_declarator( $parsed.hash.<package_declarator> )
			and self.DECL( $parsed.hash.<DECL> );
		return False
	}

	method scope_declarator( Mu $parsed ) returns Bool {
		return True if self.assert-hash-keys( $parsed, [< sym scoped >] )
			and self.sym( $parsed.hash.<sym> )
			and self.scoped( $parsed.hash.<scoped> );
		return False
	}

	method semilist( Mu $parsed ) returns Bool {
		if $parsed.list {
			for $parsed.list {
				next if self.assert-hash-keys( $_,
						[< statement >] )
					and self.statement( $_.hash.<statement> );
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
			and self.septype( $parsed.hash.<septype> )
			and self.quantified_atom( $parsed.hash.<quantified_atom> );
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
			and self.right( $parsed.hash.<right> )
			and self.babble( $parsed.hash.<babble> )
			and self.left( $parsed.hash.<left> );
		return False
	}

	method sigfinal( Mu $parsed ) returns Bool {
		return True if self.assert-hash-keys( $parsed, [< normspace >] )
			and self.normspace( $parsed.hash.<normspace> );
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
			and self.parameter( $parsed.hash.<parameter> )
			and self.typename( $parsed.hash.<typename> );
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
			and self.parameter( $parsed.hash.<parameter> )
			and self.typename( $parsed.hash.<typename> );
		return True if self.assert-hash-keys( $parsed,
				[< parameter >],
				[< param_sep >] )
			and self.parameter( $parsed.hash.<parameter> );
		return True if self.assert-hash-keys( $parsed, [],
				[< param_sep parameter >] );
		return False
	}

	method smexpr( Mu $parsed ) returns Bool {
		return True if self.assert-hash-keys( $parsed, [< EXPR >] )
			and self.EXPR( $parsed.hash.<EXPR> );
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
					and self.statement_mod_loop( $_.hash.<statement_mod_loop> )
					and self.EXPR( $_.hash.<EXPR> );
				next if self.assert-hash-keys( $_,
						[< statement_mod_cond EXPR >] )
					and self.statement_mod_cond( $_.hash.<statement_mod_cond> )
					and self.EXPR( $_.hash.<EXPR> );
				next if self.assert-hash-keys( $_, [< EXPR >] )
					and self.EXPR( $_.hash.<EXPR> );
				next if self.assert-hash-keys( $_,
						[< statement_control >] )
					and self.statementcontrol( $_.hash.<statement_control> );
				next if self.assert-hash-keys( $_, [],
						[< statement_control >] );
				die self.new-term
			}
			return True
		}
		return True if self.assert-hash-keys( $parsed,
				[< statement_control >] )
			and self.statementcontrol( $parsed.hash.<statement_control> );
		return True if self.assert-hash-keys( $parsed, [< EXPR >] )
			and self.EXPR( $parsed.hash.<EXPR> );
		return False
	}

	method statement_control( Mu $parsed ) returns Bool {
		return True if self.assert-hash-keys( $parsed,
				[< block sym e1 e2 e3 >] )
			and self.block( $parsed.hash.<block> )
			and self.sym( $parsed.hash.<sym> )
			and self.e1( $parsed.hash.<e1> )
			and self.e2( $parsed.hash.<e2> )
			and self.e3( $parsed.hash.<e3> );
		return if self.assert-hash-keys( $parsed, [< pblock sym EXPR wu >] )
			and self.pblock( $parsed.hash.<pblock> )
			and self.sym( $parsed.hash.<sym> )
			and self.EXPR( $parsed.hash.<EXPR> )
			and self.wu( $parsed.hash.<wu> );
		return True if self.assert-hash-keys( $parsed, [< doc sym module_name >] )
			and self.doc( $parsed.hash.<doc> )
			and self.sym( $parsed.hash.<sym> )
			and self.modulename( $parsed.hash.<module_name> );
		return True if self.assert-hash-keys( $parsed,
				[< doc sym version >] )
			and self.doc( $parsed.hash.<doc> )
			and self.sym( $parsed.hash.<sym> )
			and self.version( $parsed.hash.<version> );
		return True if self.assert-hash-keys( $parsed,
				[< sym else xblock >] )
			and self.sym( $parsed.hash.<sym> )
			and self.else( $parsed.hash.<else> )
			and self.xblock( $parsed.hash.<xblock> );
		return True if self.assert-hash-keys( $parsed,
				[< xblock sym wu >] )
			and self.xblock( $parsed.hash.<xblock> )
			and self.sym( $parsed.hash.<sym> )
			and self.wu( $parsed.hash.<wu> );
		return True if self.assert-hash-keys( $parsed,
				[< sym xblock >] )
			and self.sym( $parsed.hash.<sym> )
			and self.xblock( $parsed.hash.<xblock> );
		return True if self.assert-hash-keys( $parsed,
				[< block sym >] )
			and self.block( $parsed.hash.<block> )
			and self.sym( $parsed.hash.<sym> );
		return False
	}

	method statementlist( Mu $parsed ) returns Bool {
		return True if self.assert-hash-keys( $parsed, [< statement >] )
			and self.statement( $parsed.hash.<statement> );
		return True if self.assert-hash-keys( $parsed, [], [< statement >] );
		return False
	}

	method statement_mod_cond( Mu $parsed ) returns Bool {
		return True if self.assert-hash-keys( $parsed,
				[< sym modifier_expr >] )
			and self.sym( $parsed.hash.<sym> )
			and self.modifierexpr( $parsed.hash.<modifier_expr> );
		return False
	}

	method statement_mod_loop( Mu $parsed ) returns Bool {
		return True if self.assert-hash-keys( $parsed, [< sym smexpr >] )
			and self.sym( $parsed.hash.<sym> )
			and self.smexpr( $parsed.hash.<smexpr> );
		return False
	}

	method statement_prefix( Mu $parsed ) returns Bool {
		return True if self.assert-hash-keys( $parsed, [< sym blorst >] )
			and self.sym( $parsed.hash.<sym> )
			and self.blorst( $parsed.hash.<blorst> );
		return False
	}

	method subshortname( Mu $parsed ) returns Bool {
		return True if self.assert-hash-keys( $parsed,
				[< desigilname >] )
			and self.desigilname( $parsed.hash.<desigilname> );
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
			and self.methodop( $parsed.hash.<methodop> );
		return False
	}

	method termalt( Mu $parsed ) returns Bool {
		if $parsed.list {
			for $parsed.list {
				next if self.assert-hash-keys( $_, [< termconj >] )
					and self.termconj( $_.hash.<termconj> );
				die self.new-term
			}
			return True
		}
		return False
	}

	method termaltseq( Mu $parsed ) returns Bool {
		return True if self.assert-hash-keys( $parsed, [< termconjseq >] )
			and self.termconjseq( $parsed.hash.<termconjseq> );
		return False
	}

	method termconj( Mu $parsed ) returns Bool {
		if $parsed.list {
			for $parsed.list {
				next if self.assert-hash-keys( $_, [< termish >] )
					and self.termish( $_.hash.<termish> );
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
					and self.termalt( $_.hash.<termalt> );
				die self.new-term
			}
			return True
		}
		return True if self.assert-hash-keys( $parsed, [< termalt >] )
			and self.termalt( $parsed.hash.<termalt> );
		return False
	}

	method termish( Mu $parsed ) {
		if $parsed.list {
			for $parsed.list {
				next if self.assert-hash-keys( $_, [< noun >] )
					and self.noun( $_.hash.<noun> );
				die self.new-term
			}
			return True
		}
		return True if self.assert-hash-keys( $parsed, [< noun >] )
			and self.noun( $parsed.hash.<noun> );
		return False
	}

	method term_init( Mu $parsed ) returns Bool {
		return True if self.assert-hash-keys( $parsed, [< sym EXPR >] )
			and self.sym( $parsed.hash.<sym> )
			and self.EXPR( $parsed.hash.<EXPR> );
		return False
	}

	method termseq( Mu $parsed ) returns Bool {
		return True if self.assert-hash-keys( $parsed, [< termaltseq >] )
			and self.termaltseq( $parsed.hash.<termaltseq> );
		return False
	}

	method triangle( Mu $parsed ) returns Bool {
		return True if self.assert-Str( $parsed );
		return False
	}

	method twigil( Mu $parsed ) returns Bool {
		return True if self.assert-hash-keys( $parsed, [< sym >] )
			and self.sym( $parsed.hash.<sym> );
		return False
	}

	method type_constraint( Mu $parsed ) returns Bool {
		if $parsed.list {
			for $parsed.list {
				next if self.assert-hash-keys( $_,
						[< typename >] )
					and self.typename( $_.hash.<typename> );
				next if self.assert-hash-keys( $_, [< value >] )
					and self.value( $_.hash.<value> );
				die self.new-term
			}
			return True
		}
		return True if self.assert-hash-keys( $parsed, [< value >] )
			and self.value( $parsed.hash.<value> );
		return True if self.assert-hash-keys( $parsed, [< typename >] )
			and self.typename( $parsed.hash.<typename> );
		return False
	}

	method type_declarator( Mu $parsed ) returns Bool {
		return True if self.assert-hash-keys( $parsed,
				[< sym initializer variable >], [< trait >] )
			and self.sym( $parsed.hash.<sym> )
			and self.initializer( $parsed.hash.<initializer> )
			and self.variable( $parsed.hash.<variable> );
		return True if self.assert-hash-keys( $parsed,
				[< sym initializer defterm >], [< trait >] )
			and self.sym( $parsed.hash.<sym> )
			and self.initializer( $parsed.hash.<initializer> )
			and self.defterm( $parsed.hash.<defterm> );
		return True if self.assert-hash-keys( $parsed,
				[< sym initializer >] )
			and self.sym( $parsed.hash.<sym> )
			and self.initializer( $parsed.hash.<initializer> );
		return False
	}

	method typename( Mu $parsed ) returns Bool {
		if $parsed.list {
			for $parsed.list {
				next if self.assert-hash-keys( $_,
						[< longname colonpairs >],
						[< colonpair >] )
					and self.longname( $_.hash.<longname> )
					and self.colonpairs( $_.hash.<colonpairs> );
				next if self.assert-hash-keys( $_,
						[< longname >],
						[< colonpair >] )
					and self.longname( $_ );
				die self.new-term
			}
			return True
		}
		return True if self.assert-hash-keys( $parsed,
				[< longname >], [< colonpair >] )
			and self.longname( $parsed.hash.<longname> );
		return False
	}

	method val( Mu $parsed ) returns Bool {
		return True if self.assert-hash-keys( $parsed,
				[< prefix OPER >],
				[< prefix_postfix_meta_operator >] )
			and self.prefix( $parsed.hash.<prefix> )
			and self.OPER( $parsed.hash.<OPER> );
		return True if self.assert-hash-keys( $parsed, [< value >] )
			and self.value( $parsed.hash.<value> );
		return False
	}

	method value( Mu $parsed ) returns Bool {
		return True if self.assert-hash-keys( $parsed, [< number >] )
			and self.number( $parsed.hash.<number> );
		return True if self.assert-hash-keys( $parsed, [< quote >] )
			and self.quote( $parsed.hash.<quote> );
		return False
	}

	method VALUE( Mu $parsed ) returns Bool {
		return True if $parsed.Str and $parsed.Str eq '0';
		return True if self.assert-Int( $parsed );
		return False
	}

	method var( Mu $parsed ) returns Bool {
		return True if self.assert-hash-keys( $parsed, [< sigil desigilname >] )
			and self.sigil( $parsed.hash.<sigil> )
			and self.desigilname( $parsed.hash.<desigilname> );
		return True if self.assert-hash-keys( $parsed, [< variable >] )
			and self.variable( $parsed.hash.<variable> );
		return False
	}

	method variable( Mu $parsed ) returns Bool {
		return True if self.assert-hash-keys( $parsed,
				[< twigil sigil desigilname >] )
			and self.twigil( $parsed.hash.<twigil> )
			and self.sigil( $parsed.hash.<sigil> )
			and self.desigilname( $parsed.hash.<desigilname> );
		return True if self.assert-hash-keys( $parsed,
				[< sigil desigilname >] )
			and self.sigil( $parsed.hash.<sigil> )
			and self.desigilname( $parsed.hash.<desigilname> );
		return True if self.assert-hash-keys( $parsed, [< sigil >] )
			and self.sigil( $parsed.hash.<sigil> );
		return True if self.assert-hash-keys( $parsed, [< contextualizer >] )
			and self.contextualizer( $parsed.hash.<contextualizer> );
		return False
	}

	method variable_declarator( Mu $parsed ) returns Bool {
		return True if self.assert-hash-keys( $parsed,
			[< semilist variable shape >],
			[< postcircumfix signature trait post_constraint >] )
			and self.semilist( $parsed.hash.<semilist> )
			and self.variable( $parsed.hash.<variable> )
			and self.shape( $parsed.hash.<shape> );
		return True if self.assert-hash-keys( $parsed,
			[< variable >],
			[< semilist postcircumfix signature trait post_constraint >] )
			and self.variable( $parsed.hash.<variable> );
		return False
	}

	method version( Mu $parsed ) returns Bool {
		return True if self.assert-hash-keys( $parsed, [< vnum vstr >] )
			and self.vnum( $parsed.hash.<vnum> )
			and self.vstr( $parsed.hash.<vstr> );
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
					and self.pblock( $_.hash.<pblock> )
					and self.EXPR( $_.hash.<EXPR> );
				die self.new-term
			}
			return True
		}
		return True if self.assert-hash-keys( $parsed,
				[< pblock EXPR >] )
			and self.pblock( $parsed.hash.<pblock> )
			and self.EXPR( $parsed.hash.<EXPR> );
		return True if self.assert-hash-keys( $parsed, [< blockoid >] )
			and self.blockoid( $parsed.hash.<blockoid> );
		return False
	}

}
