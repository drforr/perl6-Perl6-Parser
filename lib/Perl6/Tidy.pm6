=begin pod

=begin NAME

Perl6::Tidy - Extract a Perl 6 AST from the NQP Perl 6 Parser

=end NAME

=begin SYNOPSIS

    my $pt = Perl6::Tidy.new;
    my $parsed = $pt.tidy( Q:to[_END_] );
    say $parsed.perl6($format-settings); 
    my $other = $pt.tidy-file( 't/clean-me.t' );

=end SYNOPSIS

=begin DESCRIPTION

Uses the built-in Perl 6 parser exposed by the nqp module in order to parse Perl 6 from within Perl 6. If this scares you, well, it probably should. Once this is finished, you should be able to call C<.perl6> on the tidied output, along with a so-far-unspecified formatting object, and get back nicely-formatted Perl 6 code.

As it stands, the C<.tidy> method returns a deeply-nested object representation of the Perl 6 code it's given. It handles the regex language, but not the other braided languages such as embedded blocks in strings. It will do so eventually, but for the moment I'm busy getting the grammar rules covered.

While classes like L<EClass> won't go away, their parent classes like L<DecInteger> will remove them from the tree once their validation job has been done. For example, while the internals need to know that L<< $/<eclass> >> (the exponent for a scientific-notation number) hasn't been renamed or moved elsewhere in the tree, you as a consumer of the L<DecInteger> class don't need to know that. The C<DecInteger.perl6> method will delete the child classes so that we don't end up with a B<horribly> cluttered tree.

Classes representing Perl 6 object code are currently in the same file as the main L<Perl6::Tidy> class, as moving them to separate files caused a severe performance penalty. When the time is right I'll look at moving these to another location, but as shuffling out 20 classes increased my runtime on my little ol' VM from 6 to 20 seconds, it's not worth my time to break them out. And besides, having them all in one file makes editing en masse easier.

=end DESCRIPTION

=begin METHODS

=item tidy( Str $perl-code ) returns Perl6::Tidy::Root

Given a Perl 6 code string, return the class structure, so you can see the parse tree in action. This is mostly because the internal L<Perl6::Tidy> objects are poorly named.

=item perl6( Hash %format-settings ) returns Str

Given a so-far undefined hash of format settings, return formatted Perl 6 code to meet the user's expectations.

=end METHODS

=end pod

# Bulk forward declarations.

class _ArgList {...}
class _Args {...}
class _Assertion {...}
class _Atom {...}
class _Atom_SigFinal {...}
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
class _InfixIsh {...}
class _InfixPrefixMetaOperator {...}
class _Initializer {...}
class _Int {...}
class _Integer {...}
class _Key {...}
class _Lambda {...}
class _LongName {...}
class _LongName_ColonPair {...}
class _MetaChar {...}
class _MethodDef {...}
class _MethodOp {...}
class _ModifierExpr {...}
class _ModuleName {...}
class _MoreName {...}
class _MultiDeclarator {...}
class _MultiSig {...}
class _Name {...}
class _Nibble {...}
class _NormSpace {...}
class _Noun {...}
class _Number {...}
class _Numish {...}
class _O {...}
class _OctInt {...}
class _Op {...}
class _OPER {...}
class _PackageDeclarator {...}
class _PackageDeclarator {...}
class _PackageDef {...}
class _PBlock {...}
class Perl6::Tidy::Root {...}
class _PostCircumfix {...}
class _PostCircumfix_OPER {...}
class _PostConstraint {...}
class _Postfix {...}
class _PostOp {...}
class _Prefix {...}
class _Prefix_OPER {...}
class _QuantifiedAtom {...}
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
	@types.push( 'Int' )  if $parsed.Int;
	@types.push( 'Num' )  if $parsed.Num;

	@lines.push( Q[ ~:   '] ~
		     ~$parsed.Str ~
		     "' - Types: " ~
		     @types.gist );
	@lines.push( Q[{}:    ] ~ $parsed.hash.keys.gist );
	# XXX
	CATCH {
		default { .resume } # workaround for X::Hash exception
	}
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

sub debug( Mu $parsed ) {
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

	@lines.push( "{@types})" );

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

role Node {
	has $.name;
	has @.child;
	has %.content;

	method trace( Str $name ) {
		say $name if $*TRACE
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

		@lines.push( "{@types})" );

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
}

sub assert-hash-keys( Mu $parsed, $keys, $defined-keys = [] ) {
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

class _BinInt does Node {
	method new( Mu $parsed ) {
		self.trace( "BinInt" );
		if self.assert-Int( $parsed ) {
			return self.bless( :name( $parsed.Int ) )
		}
		die self.debug( $parsed );
	}
}

class _OctInt does Node {
	method new( Mu $parsed ) {
		self.trace( "OctInt" );
		if self.assert-Int( $parsed ) {
			return self.bless( :name( $parsed.Int ) )
		}
		die self.debug( $parsed );
	}
}

class _DecInt does Node {
	method new( Mu $parsed ) {
		self.trace( "DecInt" );
		if $parsed.Str and
		   $parsed.Str eq '0' {
			return self.bless( :name( $parsed.Str ) )
		}
		if self.assert-Int( $parsed ) {
			return self.bless( :name( $parsed.Int ) )
		}
		die self.debug( $parsed );
	}
}

class _HexInt does Node {
	method new( Mu $parsed ) {
		self.trace( "HexInt" );
		if self.assert-Int( $parsed ) {
			return self.bless( :name( $parsed.Int ) )
		}
		die self.debug( $parsed );
	}
}

class _Coeff does Node {
	method new( Mu $parsed ) {
		self.trace( "Coeff" );
		if self.assert-Int( $parsed ) {
			return self.bless( :name( $parsed.Int ) )
		}
		die self.debug( $parsed );
	}
}

class _Frac does Node {
	method new( Mu $parsed ) {
		self.trace( "Frac" );
		if self.assert-Int( $parsed ) {
			return self.bless( :name( $parsed.Int ) )
		}
		die self.debug( $parsed );
	}
}

class _Radix does Node {
	method new( Mu $parsed ) {
		self.trace( "Radix" );
		if self.assert-Int( $parsed ) {
			return self.bless( :name( $parsed.Int ) )
		}
		die self.debug( $parsed );
	}
}

class _Int does Node {
	method new( Mu $parsed ) {
		self.trace( "_Int" );
		if self.assert-Int( $parsed ) {
			return self.bless( :name( $parsed.Int ) )
		}
		die self.debug( $parsed );
	}
}

class _Key does Node {
	method new( Mu $parsed ) {
		self.trace( "Key" );
		if self.assert-Str( $parsed ) {
			return self.bless( :name( $parsed.Str ) )
		}
		die self.debug( $parsed );
	}
}

class _NormSpace does Node {
	method new( Mu $parsed ) {
		self.trace( "NormSpace" );
		if self.assert-Str( $parsed ) {
			return self.bless( :name( $parsed.Str ) )
		}
		die self.debug( $parsed );
	}
}

class _Sigil does Node {
	method new( Mu $parsed ) {
		self.trace( "Sigil" );
		if self.assert-Str( $parsed ) {
			return self.bless( :name( $parsed.Str ) )
		}
		die self.debug( $parsed );
	}
}

class _VALUE does Node {
	method new( Mu $parsed ) {
		self.trace( "VALUE" );
		if $parsed.Str and
		   $parsed.Str eq '0' {
			return self.bless( :name( $parsed.Str ) )
		}
		if self.assert-Int( $parsed ) {
			return self.bless( :name( $parsed.Int ) )
		}
		die self.debug( $parsed );
	}
}

class _Sym does Node {
	method new( Mu $parsed ) {
		self.trace( "Sym" );
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
		die self.debug( $parsed );
	}
}

class _Sign does Node {
	method new( Mu $parsed ) {
		self.trace( "Sign" );
		if self.assert-Bool( $parsed ) {
			return self.bless( :name( $parsed.Bool ) )
		}
		die self.debug( $parsed );
	}
}

class _EScale does Node {
	method new( Mu $parsed ) {
		self.trace( "EScale" );
		if assert-hash-keys( $parsed, [< sign decint >] ) {
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
		die self.debug( $parsed );
	}
}

class _Integer does Node {
	method new( Mu $parsed ) {
		self.trace( "Integer" );
		if assert-hash-keys( $parsed, [< decint VALUE >] ) {
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
		if assert-hash-keys( $parsed, [< binint VALUE >] ) {
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
		if assert-hash-keys( $parsed, [< octint VALUE >] ) {
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
		if assert-hash-keys( $parsed, [< hexint VALUE >] ) {
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
		die self.debug( $parsed );
	}
}

class _BackSlash does Node {
	method new( Mu $parsed ) {
		self.trace( "BackSlash" );
		if assert-hash-keys( $parsed, [< sym >] ) {
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
		die self.debug( $parsed );
	}
}

class _VStr does Node {
	method new( Mu $parsed ) {
		self.trace( "VStr" );
		if $parsed.Int {
			return self.bless( :name( $parsed.Int ) )
		}
		die self.debug( $parsed );
	}
}

class _VNum does Node {
	method new( Mu $parsed ) {
		self.trace( "VNum" );
		if $parsed.list {
			return self.bless( :child() )
		}
		die self.debug( $parsed );
	}
}

class _Version does Node {
	method new( Mu $parsed ) {
		self.trace( "Version" );
		if assert-hash-keys( $parsed, [< vnum vstr >] ) {
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
		die self.debug( $parsed );
	}
}

class _Doc does Node {
	method new( Mu $parsed ) {
		self.trace( "Doc" );
		if self.assert-Bool( $parsed ) {
			return self.bless( :name( $parsed.Bool ) )
		}
		die self.debug( $parsed );
	}
}

class _Identifier does Node {
	method new( Mu $parsed ) {
		self.trace( "Identifier" );
		if $parsed.list {
			my @child;
			for $parsed.list {
				if self.assert-Str( $_ ) {
					@child.push(
						$_.Str
					);
					next
				}
				die self.debug( $_ );
			}
			return self.bless(
				:child( @child )
			)
		}
		elsif $parsed.Str {
			return self.bless( :name( $parsed.Str ) )
		}
		die self.debug( $parsed );
	}
}

class _Name does Node {
	method new( Mu $parsed ) {
		self.trace( "Name" );
		if assert-hash-keys( $parsed, [< identifier >],
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
		die self.debug( $parsed );
	}
}

class _LongName does Node {
	method new( Mu $parsed ) {
		self.trace( "LongName" );
		if $parsed {
			if assert-hash-keys( $parsed, [< name >], [< colonpair >] ) {
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
		die self.debug( $parsed )
	}
}

class _ModuleName does Node {
	method new( Mu $parsed ) {
		self.trace( "ModuleName" );
		if assert-hash-keys( $parsed, [< longname >] ) {
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
		die self.debug( $parsed );
	}
}

class _CodeBlock does Node {
	method new( Mu $parsed ) {
		self.trace( "CodeBlock" );
		if assert-hash-keys( $parsed, [< block >] ) {
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
		die self.debug( $parsed );
	}
}

class _XBlock does Node {
	method new( Mu $parsed ) {
		self.trace( "XBlock" );
		if assert-hash-keys( $parsed, [< pblock EXPR >] ) {
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
		if assert-hash-keys( $parsed, [< blockoid >] ) {
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
		die self.debug( $parsed );
	}
}

class _Block does Node {
	method new( Mu $parsed ) {
		self.trace( "Block" );
		if assert-hash-keys( $parsed, [< blockoid >] ) {
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
		die self.debug( $parsed );
	}
}

class _Blorst does Node {
	method new( Mu $parsed ) {
		self.trace( "Blorst" );
		if assert-hash-keys( $parsed, [< statement >] ) {
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
		if assert-hash-keys( $parsed, [< block >] ) {
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
		die self.debug( $parsed );
	}
}

class _Else does Node {
	method new( Mu $parsed ) {
		self.trace( "Else" );
		if assert-hash-keys( $parsed, [< sym blorst >] ) {
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
		die self.debug( $parsed );
	}
}

class _StatementPrefix does Node {
	method new( Mu $parsed ) {
		self.trace( "StatementPrefix" );
		if assert-hash-keys( $parsed, [< sym blorst >] ) {
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
		die self.debug( $parsed );
	}
}

class _E1 does Node {
	method new( Mu $parsed ) {
		self.trace( "E1" );
		if assert-hash-keys( $parsed, [< sym blorst >] ) {
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
		die self.debug( $parsed );
	}
}

class _E2 does Node {
	method new( Mu $parsed ) {
		self.trace( "E2" );
		die self.debug( $parsed );
	}
}

class _E3 does Node {
	method new( Mu $parsed ) {
		self.trace( "E3" );
		die self.debug( $parsed );
	}
}

class _Wu does Node {
	method new( Mu $parsed ) {
		self.trace( "Wu" );
		if self.assert-Str( $parsed ) {
			return self.bless( :naem( $parsed.Str ) )
		}
		die self.debug( $parsed );
	}
}

class _StatementControl does Node {
	method new( Mu $parsed ) {
		self.trace( "StatementControl" );
		if assert-hash-keys( $parsed, [< block sym e1 e2 e3 >] ) {
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
					:e2(
						_E2.new(
							$parsed.hash.<e2>
						)
					),
					:e3(
						_E3.new(
							$parsed.hash.<e3>
						)
					)
				)
			)
		}
		if assert-hash-keys( $parsed, [< doc sym module_name >] ) {
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
		if assert-hash-keys( $parsed, [< doc sym version >] ) {
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
		if assert-hash-keys( $parsed, [< xblock else sym >] ) {
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
		if assert-hash-keys( $parsed, [< xblock sym wu >] ) {
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
		if assert-hash-keys( $parsed, [< xblock sym >] ) {
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
		if assert-hash-keys( $parsed, [< block sym >] ) {
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
		die self.debug( $parsed );
	}
}

class _O does Node {
	method new( Mu $parsed ) {
		self.trace( "O" );
		# XXX There has to be a better way to handle this NoMatch case
		CATCH { when X::Multi::NoMatch {  } }
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
		die self.debug( $parsed );
	}
}

class _Postfix does Node {
	method new( Mu $parsed ) {
		self.trace( "Postfix" );
		if assert-hash-keys( $parsed, [< sym O >] ) {
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
		die self.debug( $parsed );
	}
}

class _Prefix does Node {
	method new( Mu $parsed ) {
		self.trace( "Prefix" );
		if assert-hash-keys( $parsed, [< sym O >] ) {
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
		die self.debug( $parsed );
	}
}

class _Args does Node {
	method new( Mu $parsed ) {
		self.trace( "Args" );
		if $parsed.Bool {
			return self.bless( :name( $parsed.Bool ) )
		}
		die self.debug( $parsed );
	}
}

class _MethodOp does Node {
	method new( Mu $parsed ) {
		self.trace( "MethodOp" );
		if assert-hash-keys( $parsed, [< longname args >] ) {
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
		if assert-hash-keys( $parsed, [< variable >] ) {
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
		if assert-hash-keys( $parsed, [< longname >] ) {
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
}

class _ArgList does Node {
	method new( Mu $parsed ) {
		self.trace( "ArgList" );
		if assert-hash-keys( $parsed, [< EXPR >] ) {
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
		die self.debug( $parsed );
	}
}

class _PostCircumfix_OPER does Node {
	method new( Mu $parsed ) {
		self.trace( "PostCircumfix_OPER" );
		if assert-hash-keys( $parsed,
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
		die self.debug( $parsed );
	}
}

class _PostCircumfix does Node {
	method new( Mu $parsed ) {
		self.trace( "PostCircumfix" );
		if assert-hash-keys( $parsed, [< nibble O >] ) {
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
		if assert-hash-keys( $parsed, [< semilist O >] ) {
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
		if assert-hash-keys( $parsed, [< arglist O >] ) {
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
		die self.debug( $parsed );
	}
}

class _PostOp does Node {
	method new( Mu $parsed ) {
		self.trace( "PostOp" );
		if assert-hash-keys( $parsed, [< sym postcircumfix O >] ) {
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
		die self.debug( $parsed );
	}
}

class _Circumfix does Node {
	method new( Mu $parsed ) {
		self.trace( "Circumfix" );
		if assert-hash-keys( $parsed, [< nibble >] ) {
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
		if assert-hash-keys( $parsed, [< pblock >] ) {
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
		if assert-hash-keys( $parsed, [< semilist >] ) {
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
		if assert-hash-keys( $parsed, [< binint VALUE >] ) {
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
		if assert-hash-keys( $parsed, [< octint VALUE >] ) {
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
		if assert-hash-keys( $parsed, [< hexint VALUE >] ) {
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
		die self.debug( $parsed );
	}
}

class _FakeSignature does Node {
	method new( Mu $parsed ) {
		self.trace( "FakeSignature" );
		if assert-hash-keys( $parsed, [< signature >] ) {
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
		die self.debug( $parsed );
	}
}

class _Var does Node {
	method new( Mu $parsed ) {
		self.trace( "Var" );
		if assert-hash-keys( $parsed, [< sigil desigilname >] ) {
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
		if assert-hash-keys( $parsed, [< variable >] ) {
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
		die self.debug( $parsed );
	}
}

class _Lambda does Node {
	method new( Mu $parsed ) {
		self.trace( "Lambda" );
		if self.assert-Str( $parsed ) {
			return self.bless( :name( $parsed.Str ) )
		}
		die self.debug( $parsed );
	}
}

class _PBlock does Node {
	method new( Mu $parsed ) {
		self.trace( "PBlock" );
		if assert-hash-keys( $parsed,
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
		if assert-hash-keys( $parsed, [< blockoid >] ) {
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
		die self.debug( $parsed );
	}
}

class _ColonCircumfix does Node {
	method new( Mu $parsed ) {
		self.trace( "ColonCircumfix" );
		if assert-hash-keys( $parsed, [< circumfix >] ) {
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
		die self.debug( $parsed );
	}
}

class _ColonPair does Node {
	method new( Mu $parsed ) {
		self.trace( "ColonPair" );
		if assert-hash-keys( $parsed,
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
		if assert-hash-keys( $parsed, [< identifier >] ) {
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
		if assert-hash-keys( $parsed, [< fakesignature >] ) {
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
		if assert-hash-keys( $parsed, [< var >] ) {
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
		die self.debug( $parsed );
	}
}

class _DottyOp does Node {
	method new( Mu $parsed ) {
		self.trace( "DottyOp" );
		if assert-hash-keys( $parsed, [< sym postop O >] ) {
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
		if assert-hash-keys( $parsed, [< methodop >] ) {
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
		if assert-hash-keys( $parsed, [< colonpair >] ) {
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
		die self.debug( $parsed );
	}
}

class _Dotty does Node {
	method new( Mu $parsed ) {
		self.trace( "Dotty" );
		if assert-hash-keys( $parsed, [< sym dottyop O >] ) {
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
		die self.debug( $parsed );
	}
}

# XXX This is a compound type
class _Identifier_Args does Node {
	method new( Mu $parsed ) {
		self.trace( "Identifier_Args" );
		if assert-hash-keys( $parsed, [< identifier args >] ) {
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
		die self.debug( $parsed );
	}
}

class _OPER does Node {
	method new( Mu $parsed ) {
		self.trace( "OPER" );
		if assert-hash-keys( $parsed, [< sym dottyop O >] ) {
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
		if assert-hash-keys(
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
		if assert-hash-keys( $parsed, [< sym O >] ) {
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
		if assert-hash-keys( $parsed, [< EXPR O >] ) {
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
		if assert-hash-keys( $parsed, [< semilist O >] ) {
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
		if assert-hash-keys( $parsed, [< nibble O >] ) {
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
		if assert-hash-keys( $parsed, [< arglist O >] ) {
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
		if assert-hash-keys( $parsed, [< O >] ) {
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
		die self.debug( $parsed );
	}
}

class _Val does Node {
	method new( Mu $parsed ) {
		self.trace( "Val" );
		if assert-hash-keys( $parsed, [< value >] ) {
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
		die self.debug( $parsed );
	}
}

class _DefTerm does Node {
	method new( Mu $parsed ) {
		self.trace( "DefTerm" );
		if assert-hash-keys( $parsed, [< identifier colonpair >] ) {
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
		if assert-hash-keys( $parsed, [< identifier >], [< colonpair >] ) {
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
		die self.debug( $parsed );
	}
}

class _TypeDeclarator does Node {
	method new( Mu $parsed ) {
		self.trace( "TypeDeclarator" );
		CATCH { when X::Multi::NoMatch {  } }
		if assert-hash-keys( $parsed, [< sym initializer variable >],
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
		if assert-hash-keys( $parsed, [< sym initializer defterm >],
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
		if assert-hash-keys( $parsed, [< sym initializer >] ) {
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
		die self.debug( $parsed );
	}
}

class _FatArrow does Node {
	method new( Mu $parsed ) {
		self.trace( "FatArrow" );
		if assert-hash-keys( $parsed, [< val key >] ) {
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
		die self.debug( $parsed );
	}
}

class _EXPR does Node {
	method new( Mu $parsed ) {
		self.trace( "EXPR" );
		if $parsed.list {
			my @child;
			for $parsed.list {
				if assert-hash-keys( $_, [< OPER dotty >],
							 [< postfix_prefix_meta_operator >] ) {
					@child.push(
						_Dotty_OPER.new( $_ )
					);
					next
				}
				if assert-hash-keys( $_,
					[< postcircumfix OPER >],
					[< postfix_prefix_meta_operator >] ) {
					@child.push(
						_PostCircumfix_OPER.new( $_ )
					);
					next
				}
				if assert-hash-keys( $_, [< prefix OPER >],
							 [< prefix_postfix_meta_operator >] ) {
					@child.push(
						_Prefix_OPER.new( $_ )
					);
					next
				}
				if assert-hash-keys( $_, [< identifier args >] ) {
					@child.push(
						_Identifier_Args.new( $_ )
					);
					next
				}
			}
			if assert-hash-keys(
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
			if assert-hash-keys(
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
			if assert-hash-keys(
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
			if assert-hash-keys(
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
			if assert-hash-keys(
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
			if assert-hash-keys(
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
			die self.debug( $parsed )
		}
		if assert-hash-keys( $parsed, [< longname args >] ) {
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
		if assert-hash-keys( $parsed, [< identifier args >] ) {
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
		if assert-hash-keys( $parsed, [< args op >] ) {
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
		if assert-hash-keys( $parsed, [< sym args >] ) {
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
		if assert-hash-keys( $parsed, [< statement_prefix >] ) {
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
		if assert-hash-keys( $parsed, [< type_declarator >] ) {
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
		if assert-hash-keys( $parsed, [< longname >] ) {
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
		if assert-hash-keys( $parsed, [< value >] ) {
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
		if assert-hash-keys( $parsed, [< variable >] ) {
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
		if assert-hash-keys( $parsed, [< circumfix >] ) {
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
		if assert-hash-keys( $parsed, [< colonpair >] ) {
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
		if assert-hash-keys( $parsed, [< scope_declarator >] ) {
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
		if assert-hash-keys( $parsed, [< routine_declarator >] ) {
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
		if assert-hash-keys( $parsed, [< package_declarator >] ) {
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
		if assert-hash-keys( $parsed, [< fatarrow >] ) {
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
		if assert-hash-keys( $parsed, [< multi_declarator >] ) {
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
		if assert-hash-keys( $parsed, [< regex_declarator >] ) {
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
		if assert-hash-keys( $parsed, [< dotty >] ) {
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
		die self.debug( $parsed );
	}
}

class _Infix does Node {
	method new( Mu $parsed ) {
		self.trace( "Infix" );
		if assert-hash-keys( $parsed, [< EXPR O >] ) {
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
		if assert-hash-keys( $parsed, [< infix OPER >] ) {
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
		if assert-hash-keys( $parsed, [< sym O >] ) {
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
		die self.debug( $parsed );
	}
}

class _InfixIsh does Node {
	method new( Mu $parsed ) {
		self.trace( "InfixIsh" );
		if assert-hash-keys( $parsed, [< infix OPER >] ) {
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
		die self.debug( $parsed );
	}
}

class _Signature does Node {
	method new( Mu $parsed ) {
		self.trace( "Signature" );
		if assert-hash-keys( $parsed, [], [< param_sep parameter >] ) {
			return self.bless(
				:name( $parsed.Bool ),
				:content(
					:param_sep(),
					:parameter()
				)
			)
		}
		die self.debug( $parsed );
	}
}

class _Twigil does Node {
	method new( Mu $parsed ) {
		self.trace( "Twigil" );
		if assert-hash-keys( $parsed, [< sym >] ) {
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
		die self.debug( $parsed );
	}
}

class _DeSigilName does Node {
	method new( Mu $parsed ) {
		self.trace( "DeSigilName" );
		if assert-hash-keys( $parsed, [< longname >] ) {
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
		die self.debug( $parsed );
	}
}

class _DefLongName does Node {
	method new( Mu $parsed ) {
		self.trace( "DefLongName" );
		if assert-hash-keys( $parsed, [< name >], [< colonpair >] ) {
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
		die self.debug( $parsed );
	}
}

class _CharSpec does Node {
	method new( Mu $parsed ) {
		self.trace( "CharSpec" );
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
						die self.debug( $_ );
					}
#					die self.debug( $_list );
				}
#				die self.debug( $list );
			}
			return self.bless(
				:child( @child )
			)
		}
		die self.debug( $parsed );
	}
}

class _Sign_CharSpec does Node {
	method new( Mu $parsed ) {
		if assert-hash-keys( $parsed, [< sign charspec >] ) {
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
		die self.debug( $parsed );
	}
}

class _CClassElem does Node {
	method new( Mu $parsed ) {
		self.trace( "CClassElem" );
		if $parsed.list {
			my @child;
			for $parsed.list {
				if assert-hash-keys( $_, [< sign charspec >] ) {
					@child.push(
						_Sign_CharSpec.new(
							$_
						)
					);
					next
				}
				die self.debug( $_ );
			}
			return self.bless(
				:child( @child )
			)
		}
		die self.debug( $parsed );
	}
}

class _Coercee does Node {
	method new( Mu $parsed ) {
		self.trace( "_Coercee" );
		if assert-hash-keys( $parsed, [< semilist >] ) {
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
		die self.debug( $parsed );
	}
}

class _Contextualizer does Node {
	method new( Mu $parsed ) {
		self.trace( "_Contextualizer" );
		if assert-hash-keys( $parsed, [< coercee circumfix sigil >] ) {
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
		die self.debug( $parsed );
	}
}

class _Variable does Node {
	method new( Mu $parsed ) {
		self.trace( "_Variable" );
		if assert-hash-keys( $parsed, [< twigil sigil desigilname >] ) {
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
		if assert-hash-keys( $parsed, [< sigil desigilname >] ) {
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
		if assert-hash-keys( $parsed, [< sigil >] ) {
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
		if assert-hash-keys( $parsed, [< contextualizer >] ) {
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
		die self.debug( $parsed );
	}
}

class _Assertion does Node {
	method new( Mu $parsed ) {
		self.trace( "Assertion" );
		if assert-hash-keys( $parsed, [< var >] ) {
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
		if assert-hash-keys( $parsed, [< longname >] ) {
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
		if assert-hash-keys( $parsed, [< cclass_elem >] ) {
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
		die self.debug( $parsed );
	}
}

class _MetaChar does Node {
	method new( Mu $parsed ) {
		self.trace( "MetaChar" );
		if assert-hash-keys( $parsed, [< sym >] ) {
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
		if assert-hash-keys( $parsed, [< codeblock >] ) {
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
		if assert-hash-keys( $parsed, [< backslash >] ) {
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
		if assert-hash-keys( $parsed, [< assertion >] ) {
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
		if assert-hash-keys( $parsed, [< nibble >] ) {
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
		if assert-hash-keys( $parsed, [< quote >] ) {
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
		die self.debug( $parsed );
	}
}

class _Atom_SigFinal does Node {
	method new( Mu $parsed ) {
		self.trace( "Atom_SigFinal" );
		if assert-hash-keys( $parsed, [< atom sigfinal >] ) {
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
		if assert-hash-keys( $parsed, [< atom >] ) {
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
		die self.debug( $parsed );
	}
}

class _Atom does Node {
	method new( Mu $parsed ) {
		self.trace( "Atom" );
		if assert-hash-keys( $parsed, [< metachar >] ) {
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
		die self.debug( $parsed );
	}
}

class _Quantifier does Node {
	method new( Mu $parsed ) {
		self.trace( "Quantifier" );
		if assert-hash-keys( $parsed, [< sym backmod >] ) {
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
		die self.debug( $parsed );
	}
}

class _BackMod does Node {
	method new( Mu $parsed ) {
		self.trace( "BackMod" );
		if self.assert-Bool( $parsed ) {
			return self.bless( :name( $parsed.Bool ) )
		}
		die self.debug( $parsed );
	}
}

class _SigFinal does Node {
	method new( Mu $parsed ) {
		self.trace( "SigFinal" );
		if assert-hash-keys( $parsed, [< normspace >] ) {
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
		die self.debug( $parsed );
	}
}

class _QuantifiedAtom does Node {
	method new( Mu $parsed ) {
		self.trace( "QuantifiedAtom" );
		if assert-hash-keys( $parsed, [< sigfinal atom >] ) {
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
		die self.debug( $parsed );
	}
}

class _SepType does Node {
	method new( Mu $parsed ) {
		self.trace( "SepType" );
		if self.assert-Str( $parsed ) {
			return self.bless( :name( $parsed.Str ) )
		}
		die self.debug( $parsed );
	}
}

class _Separator does Node {
	method new( Mu $parsed ) {
		self.trace( "Separator" );
		if assert-hash-keys( $parsed, [< septype quantified_atom >] ) {
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
		die self.debug( $parsed );
	}
}

class _SigFinal_Quantifier_Separator_Atom does Node {
	method new( Mu $parsed ) {
		self.trace( "SigFinal_Quantifier_Separator_Atom" );
		if assert-hash-keys( $parsed,
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
		die self.debug( $parsed );
	}
}

class _Noun does Node {
	method new( Mu $parsed ) {
		self.trace( "Noun" );
		if $parsed.list {
			my @child;
			for $parsed.list {
				if assert-hash-keys( $_,
						     [< sigfinal quantifier
							separator atom >] ) {
					@child.push(
						_SigFinal_Quantifier_Separator_Atom.new(
							$_
						)
					);
					next
				}
				if assert-hash-keys( $_, [< atom >],
							 [< sigfinal >] ) {
					@child.push(
						_Atom_SigFinal.new(
							$_
						)
					);
					next
				}
				die self.debug( $_ );
			}
			return self.bless(
				:child( @child )
			)
		}
		die self.debug( $parsed );
	}
}

class _TermIsh does Node {
	method new( Mu $parsed ) {
		self.trace( "TermIsh" );
		if $parsed.list {
			my @child;
			for $parsed.list {
				if assert-hash-keys( $_, [< noun >] ) {
					@child.push(
						_Noun.new(
							$_.hash.<noun>
						)
					);
					next
				}
				die self.debug( $_ );
			}
			return self.bless(
				:child( @child )
			)
		}
		if assert-hash-keys( $parsed, [< noun >] ) {
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
		die self.debug( $parsed );
	}
}

class _TermConj does Node {
	method new( Mu $parsed ) {
		self.trace( "TermConj" );
		if $parsed.list {
			my @child;
			for $parsed.list {
				if assert-hash-keys( $_, [< termish >] ) {
					@child.push(
						_TermIsh.new(
							$_.hash.<termish>
						)
					);
					next
				}
				die self.debug( $_ );
			}
			return self.bless(
				:child( @child )
			)
		}
		die self.debug( $parsed );
	}
}

class _TermAlt does Node {
	method new( Mu $parsed ) {
		self.trace( "TermAlt" );
		if $parsed.list {
			my @child;
			for $parsed.list {
				if assert-hash-keys( $_, [< termconj >] ) {
					@child.push(
						_TermConj.new(
							$_.hash.<termconj>
						)
					);
					next
				}
				die self.debug( $_ );
			}
			return self.bless(
				:child( @child )
			)
		}
		die self.debug( $parsed );
	}
}

class _TermConjSeq does Node {
	method new( Mu $parsed ) {
		self.trace( "TermConjSeq" );
		if $parsed.list {
			my @child;
			for $parsed.list {
				if assert-hash-keys( $_, [< termalt >] ) {
					@child.push(
						_TermAlt.new(
							$_.hash.<termalt>
						)
					);
					next
				}
				die self.debug( $_ );
			}
			return self.bless(
				:child( @child )
			)
		}
		if assert-hash-keys( $parsed, [< termalt >] ) {
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
		die self.debug( $parsed );
	}
}

class _TermAltSeq does Node {
	method new( Mu $parsed ) {
		self.trace( "TermAltSeq" );
		if assert-hash-keys( $parsed, [< termconjseq >] ) {
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
		die self.debug( $parsed );
	}
}

class _TermSeq does Node {
	method new( Mu $parsed ) {
		self.trace( "TermSeq" );
		if assert-hash-keys( $parsed, [< termaltseq >] ) {
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
		die self.debug( $parsed );
	}
}

class _Nibble does Node {
	method new( Mu $parsed ) {
		self.trace( "Nibble" );
		if assert-hash-keys( $parsed, [< termseq >] ) {
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
		die self.debug( $parsed );
	}
}

class _MethodDef does Node {
	method new( Mu $parsed ) {
		self.trace( "MethodDef" );
		if assert-hash-keys( $parsed,
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
		if assert-hash-keys( $parsed,
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
		die self.debug( $parsed );
	}
}

class _Specials does Node {
	method new( Mu $parsed ) {
		self.trace( "Specials" );
		CATCH { when X::Multi::NoMatch {  } }
		if self.assert-Bool( $parsed ) {
			return self.bless( :name( $parsed.Bool ) )
		}
		die self.debug( $parsed );
	}
}

class _RegexDef does Node {
	method new( Mu $parsed ) {
		self.trace( "RegexDef" );
		if assert-hash-keys( $parsed, [< deflongname nibble >],
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
		die self.debug( $parsed );
	}
}

class _RegexDeclarator does Node {
	method new( Mu $parsed ) {
		self.trace( "RegexDeclarator" );
		if assert-hash-keys( $parsed, [< sym regex_def >] ) {
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
		die self.debug( $parsed );
	}
}

class _SemiList does Node {
	method new( Mu $parsed ) {
		self.trace( "SemiList" );
		if assert-hash-keys( $parsed, [], [< statement >] ) {
			return self.bless(
				:content(
					:statement()
				)
			)
		}
		die self.debug( $parsed );
	}
}

class _B does Node {
	method new( Mu $parsed ) {
		self.trace( "B" );
		if self.assert-Bool( $parsed ) {
			return self.bless( :name( $parsed.Bool ) )
		}
		die self.debug( $parsed );
	}
}

class _Babble does Node {
	method new( Mu $parsed ) {
		self.trace( "Babble" );
		if assert-hash-keys( $parsed, [< B >], [< quotepair >] ) {
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
		die self.debug( $parsed );
	}
}

class _Quibble does Node {
	method new( Mu $parsed ) {
		self.trace( "Quibble" );
		if assert-hash-keys( $parsed, [< babble nibble >] ) {
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
		die self.debug( $parsed );
	}
}

class _Quote does Node {
	method new( Mu $parsed ) {
		self.trace( "Quote" );
		if assert-hash-keys( $parsed, [< nibble >] ) {
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
		if assert-hash-keys( $parsed, [< quibble >] ) {
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
		die self.debug( $parsed );
	}
}

class _RadNumber does Node {
	method new( Mu $parsed ) {
		self.trace( "RadNumber" );
		if assert-hash-keys( $parsed, [< circumfix radix >],
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
		die self.debug( $parsed );
	}
}

class _DecNumber does Node {
	method new( Mu $parsed ) {
		self.trace( "DecNumber" );
		if assert-hash-keys( $parsed, [< int coeff frac >] ) {
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
		if assert-hash-keys( $parsed, [< int coeff escale >] ) {
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
		die self.debug( $parsed );
	}
}

class _Numish does Node {
	method new( Mu $parsed ) {
		self.trace( "Numish" );
		if assert-hash-keys( $parsed, [< integer >] ) {
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
		if assert-hash-keys( $parsed, [< rad_number >] ) {
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
		if assert-hash-keys( $parsed, [< dec_number >] ) {
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
		die self.debug( $parsed );
	}
}

class _Number does Node {
	method new( Mu $parsed ) {
		self.trace( "Number" );
		if assert-hash-keys( $parsed, [< numish >] ) {
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
		die self.debug( $parsed );
	}
}

class _Value does Node {
	method new( Mu $parsed ) {
		self.trace( "Value" );
		if assert-hash-keys( $parsed, [< number >] ) {
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
		if assert-hash-keys( $parsed, [< quote >] ) {
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
		die self.debug( $parsed );
	}
}

class _VariableDeclarator does Node {
	method new( Mu $parsed ) {
		self.trace( "VariableDeclarator" );
		if assert-hash-keys(
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
		die self.debug( $parsed );
	}
} 

class _LongName_ColonPair does Node {
	method new( Mu $parsed ) {
		if assert-hash-keys( $parsed, [< longname >],
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
		die self.debug( $parsed );
	}
}

class _TypeName does Node {
	method new( Mu $parsed ) {
		self.trace( "TypeName" );
		if $parsed.list {
			my @child;
			for $parsed.list {
				if assert-hash-keys( $_, [< longname >],
							 [< colonpair >] ) {
					@child.push(
						_LongName_ColonPair.new(
							$_
						)
					);
					next
				}
				die self.debug( $_ );
			}
			return self.bless(
				:child( @child )
			)
		}
		die self.debug( $parsed );
	}
}

class _Blockoid does Node {
	method new( Mu $parsed ) {
		self.trace( "Blockoid" );
		if assert-hash-keys( $parsed, [< statementlist >] ) {
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
		die self.debug( $parsed );
	}
}

class _Initializer does Node {
	method new( Mu $parsed ) {
		self.trace( "Initializer" );
		if assert-hash-keys( $parsed, [< sym EXPR >] ) {
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
		die self.debug( $parsed );
	}
}

class _Declarator does Node {
	method new( Mu $parsed ) {
		self.trace( "Declarator" );
		if assert-hash-keys( $parsed, [< initializer
						 signature >],
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
		if assert-hash-keys( $parsed, [< initializer
						 variable_declarator >],
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
		if assert-hash-keys( $parsed, [< variable_declarator >],
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
		if assert-hash-keys( $parsed, [< regex_declarator >],
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
		if assert-hash-keys( $parsed, [< routine_declarator >],
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
		die self.debug( $parsed );
	}
}

class _PackageDef does Node {
	method new( Mu $parsed ) {
		self.trace( "PackageDef" );
		if assert-hash-keys( $parsed, [< blockoid longname >],
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
		if assert-hash-keys( $parsed, [< longname statementlist >],
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
		die self.debug( $parsed );
	}
}

# XXX This is a compound type
class _Dotty_OPER does Node {
	method new( Mu $parsed ) {
		self.trace( "Dotty_OPER" );
		if assert-hash-keys( $parsed,
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
		die self.debug( $parsed );
	}
}

# XXX This is a compound type
class _Prefix_OPER does Node {
	method new( Mu $parsed ) {
		self.trace( "Prefix_OPER" );
		if assert-hash-keys( $parsed,
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
		die self.debug( $parsed );
	}
}

class _PostConstraint does Node {
	method new( Mu $parsed ) {
		self.trace( "PostConstraint" );
		if $parsed.list {
			my @child;
			for $parsed.list {
				if assert-hash-keys( $_, [< EXPR >] ) {
					@child.push(
						_EXPR.new(
							$_.hash.<EXPR>
						)
					);
					next
				}
				die self.debug( $_ );
			}
			return self.bless(
				:child( @child )
			)
		}
		die self.debug( $parsed );
	}
}

class _MultiSig does Node {
	method new( Mu $parsed ) {
		self.trace( "MultiSig" );
		if assert-hash-keys( $parsed, [< signature >] ) {
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
		die self.debug( $parsed );
	}
}

class _MultiDeclarator does Node {
	method new( Mu $parsed ) {
		self.trace( "MultiDeclarator" );
		if assert-hash-keys( $parsed, [< sym routine_def >] ) {
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
		if assert-hash-keys( $parsed, [< sym declarator >] ) {
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
		if assert-hash-keys( $parsed, [< declarator >] ) {
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
		die self.debug( $parsed );
	}
}

class _RoutineDef does Node {
	method new( Mu $parsed ) {
		self.trace( "RoutineDef" );
		if assert-hash-keys( $parsed,
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
		if assert-hash-keys( $parsed, [< blockoid deflongname >],
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
		if assert-hash-keys( $parsed, [< blockoid >],
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
		die self.debug( $parsed );
	}
}

class _DECL does Node {
	method new( Mu $parsed ) {
		self.trace( "DECL" );
		if assert-hash-keys( $parsed, [< initializer
						 signature >],
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
		if assert-hash-keys( $parsed, [< initializer
						 variable_declarator >],
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
		if assert-hash-keys( $parsed, [< variable_declarator >],
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
		if assert-hash-keys( $parsed, [< regex_declarator >],
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
		if assert-hash-keys( $parsed, [< package_def sym >] ) {
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
		if assert-hash-keys( $parsed, [< declarator >] ) {
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
		die self.debug( $parsed );
	}
}

class _Scoped does Node {
	method new( Mu $parsed ) {
		self.trace( "Scoped" );
		if assert-hash-keys( $parsed, [< declarator DECL >],
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
		if assert-hash-keys( $parsed,
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
		if assert-hash-keys( $parsed, [< package_declarator DECL >],
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
		die self.debug( $parsed );
	}
}

class _ScopeDeclarator does Node {
	method new( Mu $parsed ) {
		self.trace( "ScopeDeclarator" );
		if assert-hash-keys( $parsed, [< sym scoped >] ) {
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
		die self.debug( $parsed );
	}
}

class _RoutineDeclarator does Node {
	method new( Mu $parsed ) {
		self.trace( "RoutineDeclarator" );
		if assert-hash-keys( $parsed, [< sym method_def >] ) {
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
		if assert-hash-keys( $parsed, [< sym routine_def >] ) {
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
		die self.debug( $parsed );
	}
}

class Perl6::Tidy::Root does Node {
	method new( Mu $parsed ) {
		self.trace( "Root" );
		if assert-hash-keys( $parsed, [< statementlist >] ) {
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
		die self.debug( $parsed );
	}
}

class _StatementList does Node {
	method new( Mu $parsed ) {
		self.trace( "StatementList" );
		if assert-hash-keys( $parsed, [< statement >] ) {
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
		if assert-hash-keys( $parsed, [], [< statement >] ) {
			return self.bless
		}
		die self.debug( $parsed );
	}
}

class _SMExpr does Node {
	method new( Mu $parsed ) {
		self.trace( "SMExpr" );
		if assert-hash-keys( $parsed, [< EXPR >] ) {
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
		die self.debug( $parsed );
	}
}

class _ModifierExpr does Node {
	method new( Mu $parsed ) {
		self.trace( "ModifierExpr" );
		if assert-hash-keys( $parsed, [< EXPR >] ) {
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
		die self.debug( $parsed );
	}
}

class _StatementModCond does Node {
	method new( Mu $parsed ) {
		self.trace( "StatementModCond" );
		if assert-hash-keys( $parsed, [< sym modifier_expr >] ) {
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
		die self.debug( $parsed );
	}
}

class _StatementModLoop does Node {
	method new( Mu $parsed ) {
		self.trace( "StatementModLoop" );
		if assert-hash-keys( $parsed, [< sym smexpr >] ) {
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
		die self.debug( $parsed );
	}
}

# XXX This is a compound type
class _StatementModCond_EXPR does Node {
	method new( Mu $parsed ) {
		self.trace( "StatementModCond_EXPR" );
		if assert-hash-keys( $parsed, [< statement_mod_cond EXPR >] ) {
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
		die self.debug( $parsed );
	}
}

# XXX This is a compound type
class _StatementModLoop_EXPR does Node {
	method new( Mu $parsed ) {
		self.trace( "StatementModLoop_EXPR" );
		if assert-hash-keys( $parsed, [< statement_mod_loop EXPR >] ) {
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
		die self.debug( $parsed );
	}
}

class _Statement does Node {
	method new( Mu $parsed ) {
		self.trace( "Statement" );
		if $parsed.list {
			my @child;
			for $parsed.list {
				if assert-hash-keys( $_, [< statement_mod_loop EXPR >] ) {
					@child.push(
						_StatementModLoop_EXPR.new(
							$_
						)
					);
					next
				}
				if assert-hash-keys( $_, [< statement_mod_cond EXPR >] ) {
					@child.push(
						_StatementModCond_EXPR.new(
							$_
						)
					);
					next
				}
				if assert-hash-keys( $_, [< EXPR >] ) {
					@child.push(
						_EXPR.new(
							$_.hash.<EXPR>
						)
					);
					next
				}
				if assert-hash-keys( $_, [< statement_control >] ) {
					@child.push(
						_StatementControl.new(
							$_.hash.<statement_control>
						)
					);
					next
				}
				die self.debug( $_ );
			}
			return self.bless(
				:child( @child )
			)
		}
		if assert-hash-keys( $parsed, [< statement_control >] ) {
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
		if assert-hash-keys( $parsed, [< EXPR >] ) {
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
		die self.debug( $parsed );
	}
}

class _InfixPrefixMetaOperator does Node {
	method new( Mu $parsed ) {
		self.trace( "InfixPrefixMetaOperator" );
		if assert-hash-keys( $parsed,
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
		die self.debug( $parsed );
	}
}

class _Op does Node {
	method new( Mu $parsed ) {
		self.trace( "Op" );
		if assert-hash-keys( $parsed,
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
		if assert-hash-keys( $parsed, [< infix OPER >] ) {
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
		die self.debug( $parsed );
	}
}

class _MoreName does Node {
	method new( Mu $parsed ) {
		self.trace( "MoreName" );
		if $parsed.list {
			my @child;
			for $parsed.list {
				if assert-hash-keys( $_, [< identifier >] ) {
					@child.push(
						_Identifier.new(
							$_.hash.<identifier>
						)
					);
					next
				}
				if assert-hash-keys( $_, [< EXPR >] ) {
					@child.push(
						_EXPR.new(
							$_.hash.<EXPR>
						)
					);
					next
				}
				die self.debug( $_ );
			}
			return self.bless(
				:child( @child )
			)
		}
		die self.debug( $parsed );
	}
}

class _PackageDeclarator does Node {
	method new( Mu $parsed ) {
		self.trace( "PackageDeclarator" );
		if assert-hash-keys( $parsed, [< sym package_def >] ) {
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
		die self.debug( $parsed );
	}
}

class Perl6::Tidy {
	use nqp;

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

		Perl6::Tidy::Root.new( $parsed )
	}

	method dump( Str $text ) {
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

		dump-parsed( $parsed ).join( "\n" )
	}
}
