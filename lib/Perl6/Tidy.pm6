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

class _BinInt {...}
class _OctInt {...}
class _DecInt {...}
class _HexInt {...}
class _Coeff {...}
class _Frac {...}
class _Radix {...}
class _Int {...}
class _Key {...}
class _NormSpace {...}
class _Sigil {...}
class _VALUE {...}
class _Sym {...}
class _Sign {...}
class _EScale {...}
class _Integer {...}
class _BackSlash {...}
class _VStr {...}
class _VNum {...}
class _Version {...}
class _Doc {...}
class _Identifier {...}
class _Name {...}
class _LongName {...}
class _ModuleName {...}
class _ModifierExpr {...}
class _Block {...}
class _Blorst {...}
class _StatementPrefix {...}
class _StatementControl {...}
class _O {...}
class _Postfix {...}
class _Prefix {...}
class _Args {...}
class _MethodOp {...}
class _ArgList {...}
class _PostCircumfix {...}
class _PostOp {...}
class _Circumfix {...}
class _FakeSignature {...}
class _Var {...}
class _PBlock {...}
class _ColonCircumfix {...}
class _ColonPair {...}
class _DottyOp {...}
class _Dotty {...}
class _IdentifierArgs {...}
class _LongNameArgs {...}
class _OPER {...}
class _Val {...}
class _DefTerm {...}
class _TypeDeclarator {...}
class _FatArrow {...}
class _EXPR {...}
class _Infix {...}
class _InfixIsh {...}
class _Signature {...}
class _Twigil {...}
class _DeSigilName {...}
class _DefLongName {...}
class _CharSpec {...}
class _CClassElem_INTERMEDIARY {...}
class _CClassElem {...}
class _Variable {...}
class _Assertion {...}
class _MetaChar {...}
class _Atom {...}
class _Noun {...}
class _TermIsh {...}
class _TermConj {...}
class _TermAlt {...}
class _TermConjSeq {...}
class _TermAltSeq {...}
class _TermSeq {...}
class _Nibble {...}
class _MethodDef {...}
class _Specials {...}
class _RegexDef {...}
class _RegexDeclarator {...}
class _SemiList {...}
class _B {...}
class _Babble {...}
class _Quibble {...}
class _Quote {...}
class _RadNumber {...}
class _DecNumber {...}
class _Numish {...}
class _Number {...}
class _Value {...}
class _VariableDeclarator {...}
class _TypeName_INTERMEDIARY {...}
class _TypeName {...}
class _Blockoid {...}
class _Initializer {...}
class _Declarator {...}
class _PackageDef {...}
class _InfixOPER {...}
class _DottyOPER {...}
class _PostfixOPER {...}
class _PrefixOPER {...}
class _PostConstraint {...}
class _MultiDeclarator {...}
class _MultiSig {...}
class _RoutineDef {...}
class _DECL {...}
class _Scoped {...}
class _ScopeDeclarator {...}
class _RoutineDeclarator {...}
class Perl6::Tidy::Root {...}
class _StatementList {...}
class _SMExpr {...}
class _StatementModLoop {...}
class _StatementModLoopEXPR {...}
class _StatementModCond {...}
class _StatementModCondEXPR {...}
class _Statement {...}
class _Op {...}
class _MoreName {...}
class _PackageDeclarator {...}
class _PackageDeclarator {...}

sub trace( Str $name ) {
	say $name if $*TRACE
}

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

role Node {
	has $.name;
	has @.child;
	has %.content;
}

# $parsed can only be Int, by extension Str, by extension Bool.
#
sub assert-Int( Mu $parsed ) {
	return False if $parsed.hash;
	return False if $parsed.list;

	if $parsed.Int {
		return True
	}
	die "Uncaught type"
}

# $parsed can only be Str, by extension Bool
#
sub assert-Str( Mu $parsed ) {
	return False if $parsed.hash;
	return False if $parsed.list;
	return False if $parsed.Int;

	if $parsed.Str {
		return True
	}
	die "Uncaught type"
}

# $parsed can only be Bool
#
sub assert-Bool( Mu $parsed ) {
	return False if $parsed.hash;
	return False if $parsed.list;
	return False if $parsed.Int;
	return False if $parsed.Str;

	if $parsed.Bool {
		return True
	}
	die "Uncaught type"
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
		trace "BinInt";
		if assert-Int( $parsed ) {
			return self.bless( :name( $parsed.Int ) )
		}
		die debug( 'binint', $parsed );
	}
}

class _OctInt does Node {
	method new( Mu $parsed ) {
		trace "OctInt";
		if assert-Int( $parsed ) {
			return self.bless( :name( $parsed.Int ) )
		}
		die debug( 'octint', $parsed );
	}
}

class _DecInt does Node {
	method new( Mu $parsed ) {
		trace "DecInt";
		if $parsed.Str and
		   $parsed.Str eq '0' {
			return self.bless( :name( $parsed.Str ) )
		}
		if assert-Int( $parsed ) {
			return self.bless( :name( $parsed.Int ) )
		}
		die debug( 'decint', $parsed );
	}
}

class _HexInt does Node {
	method new( Mu $parsed ) {
		trace "HexInt";
		if assert-Int( $parsed ) {
			return self.bless( :name( $parsed.Int ) )
		}
		die debug( 'hexint', $parsed );
	}
}

class _Coeff does Node {
	method new( Mu $parsed ) {
		trace "Coeff";
		if assert-Int( $parsed ) {
			return self.bless( :name( $parsed.Int ) )
		}
		die debug( 'coeff', $parsed );
	}
}

class _Frac does Node {
	method new( Mu $parsed ) {
		trace "Frac";
		if assert-Int( $parsed ) {
			return self.bless( :name( $parsed.Int ) )
		}
		die debug( 'frac', $parsed );
	}
}

class _Radix does Node {
	method new( Mu $parsed ) {
		trace "Radix";
		if assert-Int( $parsed ) {
			return self.bless( :name( $parsed.Int ) )
		}
		die debug( 'radix', $parsed );
	}
}

class _Int does Node {
	method new( Mu $parsed ) {
		trace "_Int";
		if assert-Int( $parsed ) {
			return self.bless( :name( $parsed.Int ) )
		}
		die debug( 'int', $parsed );
	}
}

class _Key does Node {
	method new( Mu $parsed ) {
		trace "Key";
		if assert-Str( $parsed ) {
			return self.bless( :name( $parsed.Str ) )
		}
		die debug( 'key', $parsed );
	}
}

class _NormSpace does Node {
	method new( Mu $parsed ) {
		trace "NormSpace";
		if assert-Str( $parsed ) {
			return self.bless( :name( $parsed.Str ) )
		}
		die debug( 'normspace', $parsed );
	}
}

class _Sigil does Node {
	method new( Mu $parsed ) {
		trace "Sigil";
		if assert-Str( $parsed ) {
			return self.bless( :name( $parsed.Str ) )
		}
		die debug( 'sigil', $parsed );
	}
}

class _VALUE does Node {
	method new( Mu $parsed ) {
		trace "VALUE";
		if $parsed.Str and
		   $parsed.Str eq '0' {
			return self.bless( :name( $parsed.Str ) )
		}
		if assert-Int( $parsed ) {
			return self.bless( :name( $parsed.Int ) )
		}
		die debug( 'VALUE', $parsed );
	}
}

class _Sym does Node {
	method new( Mu $parsed ) {
		trace "Sym";
		if $parsed.Bool and		# XXX Huh?
		   $parsed.Str eq '+' {
			return self.bless( :name( $parsed.Str ) )
		}
		if $parsed.Bool and		# XXX Huh?
		   $parsed.Str eq '' {
			return self.bless( :name( $parsed.Str ) )
		}
		if assert-Str( $parsed ) {
			return self.bless( :name( $parsed.Str ) )
		}
		die debug( 'sym', $parsed );
	}
}

class _Sign does Node {
	method new( Mu $parsed ) {
		trace "Sign";
		if assert-Bool( $parsed ) {
			return self.bless( :name( $parsed.Bool ) )
		}
		die debug( 'sign', $parsed );
	}
}

class _EScale does Node {
	method new( Mu $parsed ) {
		trace "EScale";
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
		die debug( 'escale', $parsed );
	}
}

class _Integer does Node {
	method new( Mu $parsed ) {
		trace "Integer";
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
		die debug( 'integer', $parsed );
	}
}

class _BackSlash does Node {
	method new( Mu $parsed ) {
		trace "BackSlash";
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
		die debug( 'backslash', $parsed );
	}
}

class _VStr does Node {
	method new( Mu $parsed ) {
		trace "VStr";
		if $parsed.Int {
			return self.bless( :name( $parsed.Int ) )
		}
		die debug( 'vstr', $parsed );
	}
}

class _VNum does Node {
	method new( Mu $parsed ) {
		trace "VNum";
		if $parsed.list {
			return self.bless( :child() )
		}
		die debug( 'vnum', $parsed );
	}
}

class _Version does Node {
	method new( Mu $parsed ) {
		trace "Version";
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
		die debug( 'version', $parsed );
	}
}

class _Doc does Node {
	method new( Mu $parsed ) {
		trace "Doc";
		if assert-Bool( $parsed ) {
			return self.bless( :name( $parsed.Bool ) )
		}
		die debug( 'doc', $parsed );
	}
}

class _Identifier does Node {
	method new( Mu $parsed ) {
		trace "Identifier";
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

class _Name does Node {
	method new( Mu $parsed ) {
		trace "Name";
		if assert-hash-keys( $parsed, [< identifier >],
					      [< morename >] ) {
			return self.bless(
				:content(
					:identifier(
						_Identifier.new(
							$parsed.hash.<identifier>
						)
					),
				),
				:child()
			)
		}
		die debug( 'name', $parsed );
	}
}

class _LongName does Node {
	method new( Mu $parsed ) {
		trace "LongName";
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
		die debug( 'longname', $parsed );
	}
}

class _ModuleName does Node {
	method new( Mu $parsed ) {
		trace "ModuleName";
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
		die debug( 'module_name', $parsed );
	}
}

class _Block does Node {
	method new( Mu $parsed ) {
		trace "Block";
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
		die debug( 'block', $parsed );
	}
}

class _Blorst does Node {
	method new( Mu $parsed ) {
		trace "Blorst";
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
		die debug( 'blorst', $parsed );
	}
}

class _StatementPrefix does Node {
	method new( Mu $parsed ) {
		trace "StatementPrefix";
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
		die debug( 'statement_prefix', $parsed );
	}
}

class _StatementControl does Node {
	method new( Mu $parsed ) {
		trace "StatementControl";
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
		die debug( 'statement_control', $parsed );
	}
}

class _O does Node {
	method new( Mu $parsed ) {
		trace "O";
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
		die $parsed.perl;
		#die dump-parsed( $parsed );
	}
}

class _Postfix does Node {
	method new( Mu $parsed ) {
		trace "Postfix";
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
		die debug( 'postfix', $parsed );
	}
}

class _Prefix does Node {
	method new( Mu $parsed ) {
		trace "Prefix";
		if $parsed {
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
		}
		else {
			return self.bless
		}
		die debug( 'prefix', $parsed );
	}
}

class _Args does Node {
	method new( Mu $parsed ) {
		trace "Args";
		if $parsed.Bool {
			return self.bless( :name( $parsed.Bool ) )
		}
		die debug( 'args', $parsed );
	}
}

class _MethodOp does Node {
	method new( Mu $parsed ) {
		trace "MethodOp";
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
		trace "ArgList";
		if assert-Bool( $parsed ) {
			return self.bless(
				:name( $parsed.Bool )
			)
		}
		die debug( 'arglist', $parsed );
	}
}

class _PostCircumfix does Node {
	method new( Mu $parsed ) {
		trace "PostCircumfix";
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
		die debug( 'postcircumfix', $parsed );
	}
}

class _PostOp does Node {
	method new( Mu $parsed ) {
		trace "PostOp";
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
		die debug( 'postop', $parsed );
	}
}

class _Circumfix does Node {
	method new( Mu $parsed ) {
		trace "Circumfix";
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
		die debug( 'circumfix', $parsed );
	}
}

class _FakeSignature does Node {
	method new( Mu $parsed ) {
		trace "FakeSignature";
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
		die debug( 'fakesignature', $parsed );
	}
}

class _Var does Node {
	method new( Mu $parsed ) {
		trace "Var";
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
		die debug( 'var', $parsed );
	}
}

class _PBlock does Node {
	method new( Mu $parsed ) {
		trace "PBlock";
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
		die debug( 'circumfix', $parsed );
	}
}

class _ColonCircumfix does Node {
	method new( Mu $parsed ) {
		trace "ColonCircumfix";
		if assert-hash-keys( $parsed,
				     [< circumfix >] ) {
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
		die debug( 'coloncicumfix', $parsed );
	}
}

class _ColonPair does Node {
	method new( Mu $parsed ) {
		trace "ColonPair";
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
		die debug( 'colonpair', $parsed );
	}
}

class _DottyOp does Node {
	method new( Mu $parsed ) {
		trace "DottyOp";
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
		die debug( 'dottyop', $parsed );
	}
}

class _Dotty does Node {
	method new( Mu $parsed ) {
		trace "Dotty";
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
		die debug( 'dotty', $parsed );
	}
}

# XXX This is a compound type
class _IdentifierArgs does Node {
	method new( Mu $parsed ) {
		trace "IdentifierArgs";
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
}

# XXX This is a compound type
class _LongNameArgs does Node {
	method new( Mu $parsed ) {
		trace "LongNameArgs";
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
}

class _OPER does Node {
	method new( Mu $parsed ) {
		trace "OPER";
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
		die debug( 'OPER', $parsed );
	}
}

class _Val does Node {
	method new( Mu $parsed ) {
		trace "Val";
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
		die debug( 'val', $parsed );
	}
}

class _DefTerm does Node {
	method new( Mu $parsed ) {
		trace "DefTerm";
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
		die debug( 'defterm', $parsed );
	}
}

class _TypeDeclarator does Node {
	method new( Mu $parsed ) {
		trace "TypeDeclarator";
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
		die debug( 'type_declarator', $parsed );
	}
}

class _FatArrow does Node {
	method new( Mu $parsed ) {
		trace "FatArrow";
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
		die debug( 'fatarrow', $parsed );
	}
}

class _EXPR does Node {
	method new( Mu $parsed ) {
		trace "EXPR";
		if $parsed.list {
			my @child;
			for $parsed.list {
				if assert-hash-keys( $_, [< OPER dotty >],
							 [< postfix_prefix_meta_operator >] ) {
					@child.push(
						_DottyOPER.new( $_ )
					);
					next
				}
				if assert-hash-keys( $_, [< prefix OPER >],
							 [< prefix_postfix_meta_operator >] ) {
					@child.push(
						_PrefixOPER.new( $_ )
					);
					next
				}
				if assert-hash-keys( $_, [< identifier args >] ) {
					@child.push(
						_IdentifierArgs.new( $_ )
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
			die debug( 'EXPR', $parsed )
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
				:child( 
					_LongName.new(
						$parsed.hash.<longname>
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
		die debug( 'EXPR', $parsed );
	}
}

class _Infix does Node {
	method new( Mu $parsed ) {
		trace "Infix";
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
		die debug( 'infix', $parsed );
	}
}

class _InfixIsh does Node {
	method new( Mu $parsed ) {
		trace "InfixIsh";
		if assert-hash-keys(
			$parsed,
			[< infix OPER >] ) {
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
		die debug( 'infixish', $parsed );
	}
}

class _Signature does Node {
	method new( Mu $parsed ) {
		trace "_Signature";
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

class _Twigil does Node {
	method new( Mu $parsed ) {
		trace "Twigil";
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
		die debug( 'twigil', $parsed );
	}
}

class _DeSigilName does Node {
	method new( Mu $parsed ) {
		trace "DeSigilName";
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
		die debug( 'desigilname', $parsed );
	}
}

class _DefLongName does Node {
	method new( Mu $parsed ) {
		trace "DefLongName";
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
		die debug( 'deflongname', $parsed );
	}
}

class _CharSpec does Node {
	method new( Mu $parsed ) {
		trace "CharSpec";
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

class _CClassElem_INTERMEDIARY does Node {
}

class _CClassElem does Node {
	method new( Mu $parsed ) {
		trace "CClassElem";
		if $parsed.list {
			my @child;
			for $parsed.list {
				if assert-hash-keys( $_, [< sign charspec >] ) {
					@child.push(
						_CClassElem_INTERMEDIARY.new(
							:content(
								:sign(
									_Sign.new(
										$_.hash.<sign>
									)
								),
								:charspec(
									_CharSpec.new(
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

class _Variable does Node {
	method new( Mu $parsed ) {
		trace "_Variable";
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
		die debug( 'variable', $parsed );
	}
}

class _Assertion does Node {
	method new( Mu $parsed ) {
		trace "Assertion";
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
		die debug( 'assertion', $parsed );
	}
}

class _MetaChar does Node {
	method new( Mu $parsed ) {
		trace "MetaChar";
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
		die debug( 'metachar', $parsed );
	}
}

class _Atom does Node {
	method new( Mu $parsed ) {
		trace "Atom";
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
		die debug( 'atom', $parsed );
	}
}

class _Noun does Node {
	method new( Mu $parsed ) {
		trace "Noun";
		if $parsed.list {
			my @child;
			for $parsed.list {
				if assert-hash-keys( $_, [< atom >],
							 [< sigfinal >] ) {
					@child.push(
						_Atom.new(
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

class _TermIsh does Node {
	method new( Mu $parsed ) {
		trace "TermIsh";
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
						_Noun.new(
							$parsed.hash.<noun>
						)
					)
				)
			)
		}
		die debug( 'termish', $parsed );
	}
}

class _TermConj does Node {
	method new( Mu $parsed ) {
		trace "TermConj";
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
				die debug( 'termconj', $_ );
			}
			return self.bless(
				:child( @child )
			)
		}
		die debug( 'termconj', $parsed );
	}
}

class _TermAlt does Node {
	method new( Mu $parsed ) {
		trace "TermAlt";
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
				die debug( 'termalt', $_ );
			}
			return self.bless(
				:child( @child )
			)
		}
		die debug( 'termalt', $parsed );
	}
}

class _TermConjSeq does Node {
	method new( Mu $parsed ) {
		trace "TermConjSeq";
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
						_TermAlt.new(
							$parsed.hash.<termalt>
						)
					)
				)
			)
		}
		die debug( 'termconjseq', $parsed );
	}
}

class _TermAltSeq does Node {
	method new( Mu $parsed ) {
		trace "TermAltSeq";
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
		die debug( 'termaltseq', $parsed );
	}
}

class _TermSeq does Node {
	method new( Mu $parsed ) {
		trace "TermSeq";
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
		die debug( 'termseq', $parsed );
	}
}

class _Nibble does Node {
	method new( Mu $parsed ) {
		trace "Nibble";
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
		die debug( 'nibble', $parsed );
	}
}

class _MethodDef does Node {
	method new( Mu $parsed ) {
		trace "MethodDef";
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
					)
				)
			)
		}
		die debug( 'method_def', $parsed );
	}
}

class _Specials does Node {
	method new( Mu $parsed ) {
		trace "Specials";
		CATCH { when X::Multi::NoMatch {  } }
		if assert-Bool( $parsed ) {
			return self.bless( :name( $parsed.Bool ) )
		}
		die debug( 'specials', $parsed );
	}
}

class _RegexDef does Node {
	method new( Mu $parsed ) {
		trace "RegexDef";
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
		die debug( 'regex_def', $parsed );
	}
}

class _RegexDeclarator does Node {
	method new( Mu $parsed ) {
		trace "RegexDeclarator";
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
		die debug( 'regex_declarator', $parsed );
	}
}

class _SemiList does Node {
	method new( Mu $parsed ) {
		trace "SemiList";
		if assert-hash-keys( $parsed, [], [< statement >] ) {
			return self.bless
		}
		# XXX danger, Will Robinson!
		if $parsed ~~ Any {
			return self.bless
		}
		die debug( 'semilist', $parsed );
	}
}

class _B does Node {
	method new( Mu $parsed ) {
		trace "B";
		if assert-Bool( $parsed ) {
			return self.bless( :name( $parsed.Bool ) )
		}
		die debug( 'B', $parsed );
	}
}

class _Babble does Node {
	method new( Mu $parsed ) {
		trace "Babble";
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
		die debug( 'babble', $parsed );
	}
}

class _Quibble does Node {
	method new( Mu $parsed ) {
		trace "Quibble";
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
		die debug( 'quibble', $parsed );
	}
}

class _Quote does Node {
	method new( Mu $parsed ) {
		trace "Quote";
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
		die debug( 'quote', $parsed );
	}
}

class _RadNumber does Node {
	method new( Mu $parsed ) {
		trace "RadNumber";
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
		die debug( 'rad_number', $parsed );
	}
}

class _DecNumber does Node {
	method new( Mu $parsed ) {
		trace "DecNumber";
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
		die debug( 'dec_number', $parsed );
	}
}

class _Numish does Node {
	method new( Mu $parsed ) {
		trace "Numish";
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
		die debug( 'numish', $parsed );
	}
}

class _Number does Node {
	method new( Mu $parsed ) {
		trace "Number";
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
		die debug( 'number', $parsed );
	}
}

class _Value does Node {
	method new( Mu $parsed ) {
		trace "Value";
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
		die debug( 'value', $parsed );
	}
}

class _VariableDeclarator does Node {
	method new( Mu $parsed ) {
		trace "VariableDeclarator";
		if assert-hash-keys(
			$parsed,
			[< variable >],
			[< semilist postcircumfix signature trait post_constraint >] ) {
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
		die debug( 'variable_declarator', $parsed );
	}
} 

class _TypeName_INTERMEDIARY does Node {
}

class _TypeName does Node {
	method new( Mu $parsed ) {
		trace "TypeName";
		if $parsed.list {
			my @child;
			for $parsed.list {
				if assert-hash-keys( $_, [< longname >],
							 [< colonpair >] ) {
					@child.push(
						_TypeName_INTERMEDIARY.new(
							:content(
								:longname(
									_LongName.new(
										$_.hash.<longname>
									)
								),
								:colonpair()
							)
						)
					);
					next
				}
				die debug( 'typename', $_ );
			}
			return self.bless(
				:child( @child )
			)
		}
		die debug( 'typename', $parsed );
	}
}

class _Blockoid does Node {
	method new( Mu $parsed ) {
		trace "Blockoid";
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
		die debug( 'blockoid', $parsed );
	}
}

class _Initializer does Node {
	method new( Mu $parsed ) {
		trace "Initializer";
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
		die debug( 'initializer', $parsed );
	}
}

class _Declarator does Node {
	method new( Mu $parsed ) {
		trace "Declarator";
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
		die debug( 'declarator', $parsed );
	}
}

class _PackageDef does Node {
	method new( Mu $parsed ) {
		trace "PackageDef";
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
		die debug( 'package_def', $parsed );
	}
}

# XXX This is a compound type
class _InfixOPER does Node {
	method new( Mu $parsed ) {
		trace "InfixOPER";
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
}

# XXX This is a compound type
class _DottyOPER does Node {
	method new( Mu $parsed ) {
		trace "DottyOPER";
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
				)
			)
		)
	}
}

# XXX This is a compound type
class _PostfixOPER does Node {
	method new( Mu $parsed ) {
		trace "PostfixOPER";
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
				)
			)
		)
	}
}

# XXX This is a compound type
class _PrefixOPER does Node {
	method new( Mu $parsed ) {
		trace "PrefixOPER";
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
				)
			)
		)
	}
}

class _PostConstraint does Node {
	method new( Mu $parsed ) {
		trace "PostConstraint";
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
				die debug( 'post_constraint', $_ );
			}
			return self.bless(
				:child( @child )
			)
		}
		die debug( 'post_constraint', $parsed );
	}
}

class _MultiSig does Node {
	method new( Mu $parsed ) {
		trace "MultiSig";
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
		die debug( 'multi_sig', $parsed );
	}
}

class _MultiDeclarator does Node {
	method new( Mu $parsed ) {
		trace "MultiDeclarator";
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
		die debug( 'multi_declarator', $parsed );
	}
}

class _RoutineDef does Node {
	method new( Mu $parsed ) {
		trace "RoutineDef";
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
		die debug( 'routine_def', $parsed );
	}
}

class _DECL does Node {
	method new( Mu $parsed ) {
		trace "DECL";
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
		die debug( 'DECL', $parsed );
	}
}

class _Scoped does Node {
	method new( Mu $parsed ) {
		trace "Scoped";
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
		die debug( 'scoped', $parsed );
	}
}

class _ScopeDeclarator does Node {
	method new( Mu $parsed ) {
		trace "ScopeDeclarator";
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
		die debug( 'scope_declarator', $parsed );
	}
}

class _RoutineDeclarator does Node {
	method new( Mu $parsed ) {
		trace "RoutineDeclarator";
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
		die debug( 'routine_declarator', $parsed );
	}
}

class Perl6::Tidy::Root does Node {
	method new( Mu $parsed ) {
		trace "Root";
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
		die debug( 'root', $parsed );
	}
}

class _StatementList does Node {
	method new( Mu $parsed ) {
		trace "StatementList";
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
		die debug( 'statementlist', $parsed );
	}
}

class _SMExpr does Node {
	method new( Mu $parsed ) {
		trace "SMExpr";
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
		die debug( 'smexpr', $parsed );
	}
}

class _ModifierExpr does Node {
	method new( Mu $parsed ) {
		trace "ModifierExpr";
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
		die debug( 'modifier_expr', $parsed );
	}
}

class _StatementModCond does Node {
	method new( Mu $parsed ) {
		trace "StatementModCond";
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
		die debug( 'statement_mod_cond', $parsed );
	}
}

class _StatementModLoop does Node {
	method new( Mu $parsed ) {
		trace "StatementModLoop";
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
		die debug( 'statement_mod_loop', $parsed );
	}
}

# XXX This is a compound type
class _StatementModCondEXPR does Node {
	method new( Mu $parsed ) {
		trace "StatementModCondEXPR";
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
}

# XXX This is a compound type
class _StatementModLoopEXPR does Node {
	method new( Mu $parsed ) {
		trace "StatementModLoopEXPR";
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
}

class _Statement does Node {
	method new( Mu $parsed ) {
		trace "Statement";
		if $parsed.list {
			my @child;
			for $parsed.list {
				if assert-hash-keys( $_, [< statement_mod_loop EXPR >] ) {
					@child.push(
						_StatementModLoopEXPR.new(
							$_
						)
					);
					next
				}
				if assert-hash-keys( $_, [< statement_mod_cond EXPR >] ) {
					@child.push(
						_StatementModCondEXPR.new(
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
				die debug( 'statement', $_ );
			}
			return self.bless(
				:child( @child )
			)
		}
		die debug( 'statement', $parsed );
	}
}

class _Op does Node {
	method new( Mu $parsed ) {
		trace "Op";
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
		die debug( 'op', $parsed );
	}
}

class _MoreName does Node {
	method new( Mu $parsed ) {
		trace "MoreName";
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
				die debug( 'morename', $_ );
			}
			return self.bless(
				:child( @child )
			)
		}
		die debug( 'morename', $parsed );
	}
}

class _PackageDeclarator does Node {
	method new( Mu $parsed ) {
		trace  "PackageDeclarator";
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
		die debug( 'package_declarator', $parsed );
	}
}

class Perl6::Tidy {
	use nqp;

	role Node {
		has $.name;
		has $.child;
		has %.content;
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

			die "Too many keys " ~ @keys.gist ~
					       ", " ~
				               @defined-keys.gist
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
