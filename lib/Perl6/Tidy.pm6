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

class BinInt {...}
class OctInt {...}
class DecInt {...}
class HexInt {...}
class Coeff {...}
class Frac {...}
class Radix {...}
class _Int {...}
class Key {...}
class NormSpace {...}
class Sigil {...}
class VALUE {...}
class Sym {...}
class Sign {...}
class EScale {...}
class Integer {...}
class BackSlash {...}
class VStr {...}
class VNum {...}
class Version {...}
class Doc {...}
class Identifier {...}
class Name {...}
class LongName {...}
class ModuleName {...}
class Block {...}
class Blorst {...}
class StatementPrefix {...}
class StatementControl {...}
class O {...}
class Postfix {...}
class Prefix {...}
class Args {...}
class MethodOp {...}
class ArgList {...}
class PostCircumfix {...}
class PostOp {...}
class Circumfix {...}
class FakeSignature {...}
class Var {...}
class PBlock {...}
class ColonCircumfix {...}
class ColonPair {...}
class DottyOp {...}
class Dotty {...}
class IdentifierArgs {...}
class LongNameArgs {...}
class OPER {...}
class Val {...}
class DefTerm {...}
class TypeDeclarator {...}
class FatArrow {...}
class EXPR {...}
class Infix {...}
class InfixIsh {...}
class _Signature {...}
class Twigil {...}
class DeSigilName {...}
class DefLongName {...}
class CharSpec {...}
class CClassElem_INTERMEDIARY {...}
class CClassElem {...}
class _Variable {...}
class Assertion {...}
class MetaChar {...}
class Atom {...}
class Noun {...}
class TermIsh {...}
class TermConj {...}
class TermAlt {...}
class TermConjSeq {...}
class TermAltSeq {...}
class TermSeq {...}
class Nibble {...}
class MethodDef {...}
class Specials {...}
class RegexDef {...}
class RegexDeclarator {...}
class SemiList {...}
class B {...}
class Babble {...}
class Quibble {...}
class Quote {...}
class RadNumber {...}
class DecNumber {...}
class Numish {...}
class Number {...}
class Value {...}
class VariableDeclarator {...}
class TypeName_INTERMEDIARY {...}
class TypeName {...}
class Blockoid {...}
class Initializer {...}
class Declarator {...}
class PackageDef {...}
class InfixOPER {...}
class DottyOPER {...}
class PostfixOPER {...}
class PrefixOPER {...}
class PostConstraint {...}
class MultiDeclarator {...}
class RoutineDef {...}
class DECL {...}
class Scoped {...}
class ScopeDeclarator {...}
class RoutineDeclarator {...}
class Perl6::Tidy::Root {...}
class StatementList {...}
class SMExpr {...}
class StatementModLoop {...}
class StatementModLoopEXPR {...}
class Statement {...}
class Op {...}
class MoreName {...}
class PackageDeclarator {...}
class PackageDeclarator {...}

sub trace( Str $name ) {
	say $name if $*TRACE
}

sub dump-parsed( Mu $parsed ) {
	my @lines;
	my @types;
	@types.push( 'Bool' ) if $parsed.Bool;
	@types.push( 'Int' ) if $parsed.Int;
	@types.push( 'Num' ) if $parsed.Num;

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

class BinInt does Node {
	method new( Mu $parsed ) {
		trace "BinInt";
		if assert-Int( $parsed ) {
			return self.bless( :name( $parsed.Int ) )
		}
		die debug( 'binint', $parsed );
	}
}

class OctInt does Node {
	method new( Mu $parsed ) {
		trace "OctInt";
		if assert-Int( $parsed ) {
			return self.bless( :name( $parsed.Int ) )
		}
		die debug( 'octint', $parsed );
	}
}

class DecInt does Node {
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

class HexInt does Node {
	method new( Mu $parsed ) {
		trace "HexInt";
		if assert-Int( $parsed ) {
			return self.bless( :name( $parsed.Int ) )
		}
		die debug( 'hexint', $parsed );
	}
}

class Coeff does Node {
	method new( Mu $parsed ) {
		trace "Coeff";
		if assert-Int( $parsed ) {
			return self.bless( :name( $parsed.Int ) )
		}
		die debug( 'coeff', $parsed );
	}
}

class Frac does Node {
	method new( Mu $parsed ) {
		trace "Frac";
		if assert-Int( $parsed ) {
			return self.bless( :name( $parsed.Int ) )
		}
		die debug( 'frac', $parsed );
	}
}

class Radix does Node {
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

class Key does Node {
	method new( Mu $parsed ) {
		trace "Key";
		if assert-Str( $parsed ) {
			return self.bless( :name( $parsed.Str ) )
		}
		die debug( 'key', $parsed );
	}
}

class NormSpace does Node {
	method new( Mu $parsed ) {
		trace "NormSpace";
		if assert-Str( $parsed ) {
			return self.bless( :name( $parsed.Str ) )
		}
		die debug( 'normspace', $parsed );
	}
}

class Sigil does Node {
	method new( Mu $parsed ) {
		trace "Sigil";
		if assert-Str( $parsed ) {
			return self.bless( :name( $parsed.Str ) )
		}
		die debug( 'sigil', $parsed );
	}
}

class VALUE does Node {
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

class Sym does Node {
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

class Sign does Node {
	method new( Mu $parsed ) {
		trace "Sign";
		if assert-Bool( $parsed ) {
			return self.bless( :name( $parsed.Bool ) )
		}
		die debug( 'sign', $parsed );
	}
}

class EScale does Node {
	method new( Mu $parsed ) {
		trace "EScale";
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
	method new( Mu $parsed ) {
		trace "Integer";
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
	method new( Mu $parsed ) {
		trace "BackSlash";
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

class VStr does Node {
	method new( Mu $parsed ) {
		trace "VStr";
		if $parsed.Int {
			return self.bless( :name( $parsed.Int ) )
		}
		die debug( 'vstr', $parsed );
	}
}

class VNum does Node {
	method new( Mu $parsed ) {
		trace "VNum";
		if $parsed.list {
			return self.bless( :child() )
		}
		die debug( 'vnum', $parsed );
	}
}

class Version does Node {
	method new( Mu $parsed ) {
		trace "Version";
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

class Doc does Node {
	method new( Mu $parsed ) {
		trace "Doc";
		if assert-Bool( $parsed ) {
			return self.bless( :name( $parsed.Bool ) )
		}
		die debug( 'doc', $parsed );
	}
}

class Identifier does Node {
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

class Name does Node {
	method new( Mu $parsed ) {
		trace "Name";
		if assert-hash-keys( $parsed, [< identifier >],
					      [< morename >] ) {
			return self.bless(
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
}

class LongName does Node {
	method new( Mu $parsed ) {
		trace "LongName";
		if assert-hash-keys( $parsed, [< name >], [< colonpair >] ) {
			return self.bless(
				:content(
					:name(
						Name.new(
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

class ModuleName does Node {
	method new( Mu $parsed ) {
		trace "ModuleName";
		if assert-hash-keys( $parsed, [< longname >] ) {
			return self.bless(
				:content(
					:longname(
						LongName.new(
							$parsed.hash.<longname>
						)
					)
				)
			)
		}
		die debug( 'module_name', $parsed );
	}
}

class Block does Node {
	method new( Mu $parsed ) {
		trace "Block";
		if assert-hash-keys( $parsed, [< blockoid >] ) {
			return self.bless(
				:content(
					:blockoid(
						Blockoid.new(
							$parsed.hash.<blockoid>
						)
					)
				)
			)
		}
		die debug( 'block', $parsed );
	}
}

class Blorst does Node {
	method new( Mu $parsed ) {
		trace "Blorst";
		if assert-hash-keys( $parsed, [< block >] ) {
			return self.bless(
				:content(
					:block(
						Block.new(
							$parsed.hash.<block>
						)
					)
				)
			)
		}
		die debug( 'blorst', $parsed );
	}
}

class StatementPrefix does Node {
	method new( Mu $parsed ) {
		trace "StatementPrefix";
		if assert-hash-keys( $parsed, [< sym blorst >] ) {
			return self.bless(
				:content(
					:sym(
						Sym.new(
							$parsed.hash.<sym>
						)
					),
					:blorst(
						Blorst.new(
							$parsed.hash.<blorst>
						)
					)
				)
			)
		}
		die debug( 'statement_prefix', $parsed );
	}
}

class StatementControl does Node {
	method new( Mu $parsed ) {
		trace "StatementControl";
		if assert-hash-keys( $parsed, [< doc sym module_name >] ) {
			return self.bless(
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
						ModuleName.new(
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
}

class O does Node {
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

class Postfix does Node {
	method new( Mu $parsed ) {
		trace "Postfix";
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

class Prefix does Node {
	method new( Mu $parsed ) {
		trace "Prefix";
		if $parsed {
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
		}
		else {
			return self.bless
		}
		die debug( 'prefix', $parsed );
	}
}

class Args does Node {
	method new( Mu $parsed ) {
		trace "Args";
		if $parsed.Bool {
			return self.bless( :name( $parsed.Bool ) )
		}
		die debug( 'args', $parsed );
	}
}

class MethodOp does Node {
	method new( Mu $parsed ) {
		trace "MethodOp";
		if assert-hash-keys( $parsed, [< longname args >] ) {
			return self.bless(
				:content(
					:longname(
						LongName.new(
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
		if assert-hash-keys( $parsed, [< longname >] ) {
			return self.bless(
				:content(
					:longname(
						LongName.new(
							$parsed.hash.<longname>
						)
					)
				)
			)
		}
		die dump( $parsed );
	}
}

class ArgList does Node {
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

class PostCircumfix does Node {
	method new( Mu $parsed ) {
		trace "PostCircumfix";
		if assert-hash-keys( $parsed, [< nibble O >] ) {
			return self.bless(
				:content(
					:nibble(
						Nibble.new(
							$parsed.hash.<nibble>
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
		if assert-hash-keys( $parsed, [< semilist O >] ) {
			return self.bless(
				:content(
					:semilist(
						SemiList.new(
							$parsed.hash.<semilist>
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
		if assert-hash-keys( $parsed, [< arglist O >] ) {
			return self.bless(
				:content(
					:arglist(
						ArgList.new(
							$parsed.hash.<arglist>
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
		die debug( 'postcircumfix', $parsed );
	}
}

class PostOp does Node {
	method new( Mu $parsed ) {
		trace "PostOp";
		if assert-hash-keys( $parsed, [< sym postcircumfix O >] ) {
			return self.bless(
				:content(
					:sym(
						Sym.new(
							$parsed.hash.<sym>
						)
					),
					:postcircumfix(
						PostCircumfix.new(
							$parsed.hash.<postcircumfix>
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
		die debug( 'postop', $parsed );
	}
}

class Circumfix does Node {
	method new( Mu $parsed ) {
		trace "Circumfix";
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
		if assert-hash-keys( $parsed, [< pblock >] ) {
			return self.bless(
				:content(
					:pblock(
						PBlock.new(
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

class FakeSignature does Node {
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

class Var does Node {
	method new( Mu $parsed ) {
		trace "Var";
		if assert-hash-keys( $parsed, [< sigil desigilname >] ) {
			return self.bless(
				:content(
					:sigil(
						Sigil.new(
							$parsed.hash.<sigil>
						)
					),
					:desigilname(
						DeSigilName.new(
							$parsed.hash.<desigilname>
						)
					)
				)
			)
		}
		die debug( 'var', $parsed );
	}
}

class PBlock does Node {
	method new( Mu $parsed ) {
		trace "PBlock";
		if assert-hash-keys( $parsed, [< blockoid >] ) {
			return self.bless(
				:content(
					:blockoid(
						Blockoid.new(
							$parsed.hash.<blockoid>
						)
					)
				)
			)
		}
		die debug( 'circumfix', $parsed );
	}
}

class ColonCircumfix does Node {
	method new( Mu $parsed ) {
		trace "ColonCircumfix";
		if assert-hash-keys( $parsed,
				     [< circumfix >] ) {
			return self.bless(
				:content(
					:circumfix(
						Circumfix.new(
							$parsed.hash.<circumfix>
						)
					)
				)
			)
		}
		die debug( 'coloncicumfix', $parsed );
	}
}

class ColonPair does Node {
	method new( Mu $parsed ) {
		trace "ColonPair";
		if assert-hash-keys( $parsed,
				     [< identifier coloncircumfix >] ) {
			return self.bless(
				:content(
					:identifier(
						Identifier.new(
							$parsed.hash.<identifier>
						)
					),
					:coloncircumfix(
						ColonCircumfix.new(
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
		if assert-hash-keys( $parsed, [< var >] ) {
			return self.bless(
				:content(
					:var(
						Var.new(
							$parsed.hash.<var>
						)
					)
				)
			)
		}
		die debug( 'colonpair', $parsed );
	}
}

class DottyOp does Node {
	method new( Mu $parsed ) {
		trace "DottyOp";
		if assert-hash-keys( $parsed, [< sym postop O >] ) {
			return self.bless(
				:content(
					:sym(
						Sym.new(
							$parsed.hash.<sym>
						)
					),
					:postop(
						PostOp.new(
							$parsed.hash.<postop>
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
		if assert-hash-keys( $parsed, [< methodop >] ) {
			return self.bless(
				:content(
					:methodop(
						MethodOp.new(
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
						ColonPair.new(
							$parsed.hash.<colonpair>
						)
					)
				)
			)
		}
		die debug( 'dottyop', $parsed );
	}
}

class Dotty does Node {
	method new( Mu $parsed ) {
		trace "Dotty";
		if assert-hash-keys( $parsed, [< sym dottyop O >] ) {
			return self.bless(
				:content(
					:sym(
						Sym.new(
							$parsed.hash.<sym>
						)
					),
					:dottyop(
						DottyOp.new(
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
}

# XXX This is a compound type
class IdentifierArgs does Node {
	method new( Mu $parsed ) {
		trace "IdentifierArgs";
		return self.bless(
			:content(
				:identifier(
					Identifier.new(
						$parsed.hash.<identifier>
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
}

# XXX This is a compound type
class LongNameArgs does Node {
	method new( Mu $parsed ) {
		trace "LongNameArgs";
		return self.bless(
			:content(
				:longname(
					LongName.new(
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
}

class OPER does Node {
	method new( Mu $parsed ) {
		trace "OPER";
		if assert-hash-keys( $parsed, [< sym dottyop O >] ) {
			return self.bless(
				:content(
					:sym(
						Sym.new(
							$parsed.hash.<sym>
						)
					),
					:dottyop(
						DottyOp.new(
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
		if assert-hash-keys(
			$parsed,
			[< sym infixish O >] ) {
			return self.bless(
				:content(
					:sym(
						Sym.new(
							$parsed.hash.<sym>
						)
					),
					:infixish(
						InfixIsh.new(
							$parsed.hash.<infixish>
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
		if assert-hash-keys( $parsed, [< EXPR O >] ) {
			return self.bless(
				:content(
					:EXPR(
						EXPR.new(
							$parsed.hash.<EXPR>
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
		if assert-hash-keys( $parsed, [< semilist O >] ) {
			return self.bless(
				:content(
					:semilist(
						SemiList.new(
							$parsed.hash.<semilist>)
					),
					:O(
						O.new(
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
						Nibble.new(
							$parsed.hash.<nibble>)
					),
					:O(
						O.new(
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
						O.new(
							$parsed.hash.<O>
						)
					)
				)
			)
		}
		die debug( 'OPER', $parsed );
	}
}

class Infix {...} # Forward

class Val does Node {
	method new( Mu $parsed ) {
		trace "Val";
		if assert-hash-keys( $parsed, [< value >] ) {
			return self.bless(
				:content(
					:value(
						Value.new(
							$parsed.hash.<value>
						)
					)
				)
			)
		}
		die debug( 'val', $parsed );
	}
}

class DefTerm does Node {
	method new( Mu $parsed ) {
		trace "DefTerm";
		if assert-hash-keys( $parsed, [< identifier colonpair >] ) {
			return self.bless(
				:content(
					:identifier(
						Identifier.new(
							$parsed.hash.<identifier>
						)
					),
					:colonpair(
						ColonPair.new(
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
						Identifier.new(
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

class TypeDeclarator does Node {
	method new( Mu $parsed ) {
		trace "TypeDeclarator";
		CATCH { when X::Multi::NoMatch {  } }
		if assert-hash-keys( $parsed, [< sym initializer variable >],
					      [< trait >] ) {
			return self.bless(
				:content(
					:sym(
						Sym.new(
							$parsed.hash.<sym>
						)
					),
					:initializer(
						Initializer.new(
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
						Sym.new(
							$parsed.hash.<sym>
						)
					),
					:initializer(
						Initializer.new(
							$parsed.hash.<initializer>
						)
					),
					:defterm(
						DefTerm.new(
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
						Sym.new(
							$parsed.hash.<sym>
						)
					),
					:initializer(
						Initializer.new(
							$parsed.hash.<initializer>
						)
					)
				)
			)
		}
		die debug( 'type_declarator', $parsed );
	}
}

class FatArrow does Node {
	method new( Mu $parsed ) {
		trace "FatArrow";
		if assert-hash-keys( $parsed, [< val key >] ) {
			return self.bless(
				:content(
					:val(
						Val.new(
							$parsed.hash.<val>
						)
					),
					:key(
						Key.new(
							$parsed.hash.<key>
						)
					)
				)
			)
		}
		die debug( 'fatarrow', $parsed );
	}
}

class EXPR does Node {
	method new( Mu $parsed ) {
		trace "EXPR";
		if $parsed.list {
			my @child;
			for $parsed.list {
				if assert-hash-keys( $_, [< OPER dotty >],
							 [< postfix_prefix_meta_operator >] ) {
					@child.push(
						DottyOPER.new( $_ )
					);
					next
				}
				if assert-hash-keys( $_, [< prefix OPER >],
							 [< prefix_postfix_meta_operator >] ) {
					@child.push(
						PrefixOPER.new( $_ )
					);
					next
				}
				if assert-hash-keys( $_, [< identifier args >] ) {
					@child.push(
						IdentifierArgs.new( $_ )
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
							OPER.new(
								$parsed.hash.<OPER>
							)
						),
						:dotty(
							Dotty.new(
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
							Postfix.new(
								$parsed.hash.<postfix>
							)
						),
						:OPER(
							OPER.new(
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
							Infix.new(
								$parsed.hash.<infix>
							)
						),
						:OPER(
							OPER.new(
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
							Prefix.new(
								$parsed.hash.<prefix>
							)
						),
						:OPER(
							OPER.new(
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
							PostCircumfix.new(
								$parsed.hash.<postcircumfix>
							)
						),
						:OPER(
							OPER.new(
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
							OPER.new(
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
						LongName.new(
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
		if assert-hash-keys( $parsed, [< identifier args >] ) {
			return self.bless(
				:content(
					:identifier(
						Identifier.new(
							$parsed.hash.<identifier>
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
		if assert-hash-keys( $parsed, [< args op >] ) {
			return self.bless(
				:content(
					:args(
						Args.new(
							$parsed.hash.<args>
						)
					),
					:op(
						Op.new(
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
						Sym.new(
							$parsed.hash.<sym>
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
		if assert-hash-keys( $parsed, [< statement_prefix >] ) {
			return self.bless(
				:content(
					:statement_prefix(
						StatementPrefix.new(
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
						TypeDeclarator.new(
							$parsed.hash.<type_declarator>
						)
					)
				)
			)
		}
		if assert-hash-keys( $parsed, [< longname >] ) {
			return self.bless(
				:child( 
					LongName.new(
						$parsed.hash.<longname>
					)
				)
			)
		}
		if assert-hash-keys( $parsed, [< value >] ) {
			return self.bless(
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
						Circumfix.new(
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
						ColonPair.new(
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
						ScopeDeclarator.new(
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
						RoutineDeclarator.new(
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
						PackageDeclarator.new(
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
						FatArrow.new(
							$parsed.hash.<fatarrow>
						)
					)
				)
			)
		}
		die debug( 'EXPR', $parsed );
	}
}

class Infix does Node {
	method new( Mu $parsed ) {
		trace "Infix";
		if assert-hash-keys( $parsed, [< EXPR O >] ) {
			return self.bless(
				:content(
					:EXPR(
						EXPR.new(
							$parsed.hash.<EXPR>
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
		if assert-hash-keys( $parsed, [< infix OPER >] ) {
			return self.bless(
				:content(
					:infix(
						Infix.new(
							$parsed.hash.<infix>
						)
					),
					:OPER(
						OPER.new(
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
		die debug( 'infix', $parsed );
	}
}

class InfixIsh does Node {
	method new( Mu $parsed ) {
		trace "InfixIsh";
		if assert-hash-keys(
			$parsed,
			[< infix OPER >] ) {
			return self.bless(
				:content(
					:infix(
						Infix.new(
							$parsed.hash.<infix>
						)
					),
					:OPER(
						OPER.new(
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

class Twigil does Node {
	method new( Mu $parsed ) {
		trace "Twigil";
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
	method new( Mu $parsed ) {
		trace "DeSigilName";
		if assert-hash-keys( $parsed, [< longname >] ) {
			return self.bless(
				:content(
					:longname(
						LongName.new(
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

class DefLongName does Node {
	method new( Mu $parsed ) {
		trace "DefLongName";
		if assert-hash-keys( $parsed, [< name >], [< colonpair >] ) {
			return self.bless(
				:content(
					:name(
						Name.new(
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

class CharSpec does Node {
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

class CClassElem_INTERMEDIARY does Node {
}

class CClassElem does Node {
	method new( Mu $parsed ) {
		trace "CClassElem";
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

class _Variable does Node {
	method new( Mu $parsed ) {
		trace "_Variable";
		if assert-hash-keys( $parsed, [< twigil sigil desigilname >] ) {
			return self.bless(
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
						DeSigilName.new(
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
						Sigil.new(
							$parsed.hash.<sigil>
						)
					),
					:desigilname(
						DeSigilName.new(
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
						Sigil.new(
							$parsed.hash.<sigil>
						)
					)
				)
			)
		}
		die debug( 'variable', $parsed );
	}
}

class Assertion does Node {
	method new( Mu $parsed ) {
		trace "Assertion";
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
	method new( Mu $parsed ) {
		trace "MetaChar";
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
					:assertion(
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
	method new( Mu $parsed ) {
		trace "Atom";
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
	method new( Mu $parsed ) {
		trace "Noun";
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

class TermIsh does Node {
	method new( Mu $parsed ) {
		trace "TermIsh";
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
	method new( Mu $parsed ) {
		trace "TermConj";
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
	method new( Mu $parsed ) {
		trace "TermAlt";
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
	method new( Mu $parsed ) {
		trace "TermConjSeq";
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
	method new( Mu $parsed ) {
		trace "TermAltSeq";
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
	method new( Mu $parsed ) {
		trace "TermSeq";
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
	method new( Mu $parsed ) {
		trace "Nibble";
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
		if $parsed.Bool {
			return self.bless( :name( $parsed.Bool ) )
		}
		die debug( 'nibble', $parsed );
	}
}

class MethodDef does Node {
	method new( Mu $parsed ) {
		trace "MethodDef";
		if assert-hash-keys( $parsed,
				     [< specials longname blockoid >],
				     [< trait >] ) {
			return self.bless(
				:content(
					:specials(
						Specials.new(
							$parsed.hash.<specials>
						)
					),
					:longname(
						LongName.new(
							$parsed.hash.<longname>
						)
					),
					:blockoid(
						Blockoid.new(
							$parsed.hash.<blockoid>
						)
					)
				)
			)
		}
		die debug( 'method_def', $parsed );
	}
}

class Specials does Node {
	method new( Mu $parsed ) {
		trace "Specials";
		CATCH { when X::Multi::NoMatch {  } }
		if assert-Bool( $parsed ) {
			return self.bless( :name( $parsed.Bool ) )
		}
		die debug( 'specials', $parsed );
	}
}

class RegexDef does Node {
	method new( Mu $parsed ) {
		trace "RegexDef";
		if assert-hash-keys( $parsed, [< deflongname nibble >],
					      [< signature trait >] ) {
			return self.bless(
				:content(
					:deflongname(
						DefLongName.new(
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
}

class RegexDeclarator does Node {
	method new( Mu $parsed ) {
		trace "RegexDeclarator";
		if assert-hash-keys( $parsed, [< sym regex_def >] ) {
			return self.bless(
				:content(
					:sym(
						Sym.new(
							$parsed.hash.<sym>
						)
					),
					:regex_def(
						RegexDef.new(
							$parsed.hash.<regex_def>
						)
					)
				)
			)
		}
		die debug( 'regex_declarator', $parsed );
	}
}

class SemiList does Node {
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

class B does Node {
	method new( Mu $parsed ) {
		trace "B";
		if assert-Bool( $parsed ) {
			return self.bless( :name( $parsed.Bool ) )
		}
		die debug( 'B', $parsed );
	}
}

class Babble does Node {
	method new( Mu $parsed ) {
		trace "Babble";
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
	method new( Mu $parsed ) {
		trace "Quibble";
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
	method new( Mu $parsed ) {
		trace "Quote";
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
	method new( Mu $parsed ) {
		trace "RadNumber";
		if assert-hash-keys( $parsed, [< circumfix radix >],
					      [< exp base >] ) {
			return self.bless(
				:content(
					:circumfix(
						Circumfix.new(
							$parsed.hash.<circumfix>
						)
					),
					:radix(
						Radix.new(
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

class DecNumber does Node {
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
	method new( Mu $parsed ) {
		trace "Numish";
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
	method new( Mu $parsed ) {
		trace "Number";
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
	method new( Mu $parsed ) {
		trace "Value";
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

class VariableDeclarator does Node {
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

class TypeName_INTERMEDIARY does Node {
}

class TypeName does Node {
	method new( Mu $parsed ) {
		trace "TypeName";
		if $parsed.list {
			my @child;
			for $parsed.list {
				if assert-hash-keys( $_, [< longname >],
							 [< colonpair >] ) {
					@child.push(
						TypeName_INTERMEDIARY.new(
							:content(
								:longname(
									LongName.new(
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

class Blockoid does Node {
	method new( Mu $parsed ) {
		trace "Blockoid";
		if assert-hash-keys( $parsed, [< statementlist >] ) {
			return self.bless(
				:content(
					:statementlist(
						StatementList.new(
							$parsed.hash.<statementlist>
						)
					)
				)
			)
		}
		die debug( 'blockoid', $parsed );
	}
}

class Initializer does Node {
	method new( Mu $parsed ) {
		trace "Initializer";
		if assert-hash-keys( $parsed, [< sym EXPR >] ) {
			return self.bless(
				:content(
					:sym(
						Sym.new(
							$parsed.hash.<sym>
						)
					),
					:EXPR(
						EXPR.new(
							$parsed.hash.<EXPR>
						)
					)
				)
			)
		}
		die debug( 'initializer', $parsed );
	}
}

class Declarator does Node {
	method new( Mu $parsed ) {
		trace "Declarator";
		if assert-hash-keys( $parsed, [< initializer
						 variable_declarator >],
					      [< trait >] ) {
			return self.bless(
				:content(
					:initializer(
						Initializer.new(
							$parsed.hash.<initializer>
						)
					),
					:variable_declarator(
						VariableDeclarator.new(
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
						VariableDeclarator.new(
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
						RegexDeclarator.new(
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

class PackageDef does Node {
	method new( Mu $parsed ) {
		trace "PackageDef";
		if assert-hash-keys( $parsed, [< blockoid longname >],
					      [< trait >] ) {
			return self.bless(
				:content(
					:blockoid(
						Blockoid.new(
							$parsed.hash.<blockoid>
						)
					),
					:longname(
						LongName.new(
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
						LongName.new(
							$parsed.hash.<longname>
						)
					),
					:statementlist(
						StatementList.new(
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
class InfixOPER does Node {
	method new( Mu $parsed ) {
		trace "InfixOPER";
		return self.bless(
			:content(
				:infix(
					Infix.new(
						$parsed.hash.<infix>
					)
				),
				:OPER(
					OPER.new(
						$parsed.hash.<OPER>
					)
				)
			)
		)
	}
}

# XXX This is a compound type
class DottyOPER does Node {
	method new( Mu $parsed ) {
		trace "DottyOPER";
		return self.bless(
			:content(
				:dotty(
					Dotty.new(
						$parsed.hash.<dotty>
					)
				),
				:OPER(
					OPER.new(
						$parsed.hash.<OPER>
					)
				)
			)
		)
	}
}

# XXX This is a compound type
class PostfixOPER does Node {
	method new( Mu $parsed ) {
		trace "PostfixOPER";
		return self.bless(
			:content(
				:postfix(
					Postfix.new(
						$parsed.hash.<postfix>
					)
				),
				:OPER(
					OPER.new(
						$parsed.hash.<OPER>
					)
				)
			)
		)
	}
}

# XXX This is a compound type
class PrefixOPER does Node {
	method new( Mu $parsed ) {
		trace "PrefixOPER";
		return self.bless(
			:content(
				:prefix(
					Prefix.new(
						$parsed.hash.<prefix>
					)
				),
				:OPER(
					OPER.new(
						$parsed.hash.<OPER>
					)
				)
			)
		)
	}
}

class PostConstraint does Node {
	method new( Mu $parsed ) {
		trace "PostConstraint";
		if $parsed.list {
			my @child;
			for $parsed.list {
				if assert-hash-keys( $_, [< EXPR >] ) {
					@child.push(
						EXPR.new(
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

class MultiDeclarator does Node {
	method new( Mu $parsed ) {
		trace "MultiDeclarator";
		if assert-hash-keys( $parsed, [< declarator >] ) {
			return self.bless(
				:content(
					:declarator(
						Declarator.new(
							$parsed.hash.<declarator>
						)
					)
				)
			)
		}
		die debug( 'multi_declarator', $parsed );
	}
}

class RoutineDef does Node {
	method new( Mu $parsed ) {
		trace "RoutineDef";
		if assert-hash-keys( $parsed, [< blockoid deflongname >],
					      [< trait >] ) {
			return self.bless(
				:content(
					:blockoid(
						Blockoid.new(
							$parsed.hash.<blockoid>
						)
					),
					:deflongname(
						DefLongName.new(
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

class DECL does Node {
	method new( Mu $parsed ) {
		trace "DECL";
		if assert-hash-keys( $parsed, [< initializer
						 variable_declarator >],
					      [< trait >] ) {
			return self.bless(
				:content(
					:initializer(
						Initializer.new(
							$parsed.hash.<initializer>
						)
					),
					:variable_declarator(
						VariableDeclarator.new(
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
						VariableDeclarator.new(
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
						RegexDeclarator.new(
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
						PackageDef.new(
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
		if assert-hash-keys( $parsed, [< declarator >] ) {
			return self.bless(
				:content(
					:declarator(
						Declarator.new(
							$parsed.hash.<declarator>
						)
					)
				)
			)
		}
		die debug( 'DECL', $parsed );
	}
}

class Scoped does Node {
	method new( Mu $parsed ) {
		trace "Scoped";
		if assert-hash-keys( $parsed, [< declarator DECL >],
					      [< typename >] ) {
			return self.bless(
				:content(
					:declarator(
						Declarator.new(
							$parsed.hash.<declarator>
						)
					),
					:DECL(
						DECL.new(
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
						MultiDeclarator.new(
							$parsed.hash.<multi_declarator>
						)
					),
					:DECL(
						DECL.new(
							$parsed.hash.<DECL>
						)
					),
					:typename(
						TypeName.new(
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
						PackageDeclarator.new(
							$parsed.hash.<package_declarator>
						)
					),
					:DECL(
						DECL.new(
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

class ScopeDeclarator does Node {
	method new( Mu $parsed ) {
		trace "ScopeDeclarator";
		if assert-hash-keys( $parsed, [< sym scoped >] ) {
			return self.bless(
				:content(
					:sym(
						Sym.new(
							$parsed.hash.<sym>
						)
					),
					:scoped(
						Scoped.new(
							$parsed.hash.<scoped>
						)
					)
				)
			)
		}
		die debug( 'scope_declarator', $parsed );
	}
}

class RoutineDeclarator does Node {
	method new( Mu $parsed ) {
		trace "RoutineDeclarator";
		if assert-hash-keys( $parsed, [< sym method_def >] ) {
			return self.bless(
				:content(
					:sym(
						Sym.new(
							$parsed.hash.<sym>
						)
					),
					:method_def(
						MethodDef.new(
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
						Sym.new(
							$parsed.hash.<sym>
						)
					),
					:routine_def(
						RoutineDef.new(
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
						StatementList.new(
							$parsed.hash.<statementlist>
						)
					)
				)
			);
		}
		die debug( 'root', $parsed );
	}
}

class StatementList does Node {
	method new( Mu $parsed ) {
		trace "StatementList";
		if assert-hash-keys( $parsed, [< statement >] ) {
			return self.bless(
				:content(
					:statement(
						Statement.new(
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

class SMExpr does Node {
	method new( Mu $parsed ) {
		trace "SMExpr";
		if assert-hash-keys( $parsed, [< EXPR >] ) {
			return self.bless(
				:content(
					:EXPR(
						EXPR.new(
							$parsed.hash.<EXPR>
						)
					)
				)
			)
		}
		die debug( 'smexpr', $parsed );
	}
}

class StatementModLoop does Node {
	method new( Mu $parsed ) {
		trace "StatementModLoop";
		if assert-hash-keys( $parsed, [< sym smexpr >] ) {
			return self.bless(
				:content(
					:sym(
						Sym.new(
							$parsed.hash.<sym>
						)
					),
					:smexpr(
						SMExpr.new(
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
class StatementModLoopEXPR does Node {
	method new( Mu $parsed ) {
		trace "StatementModLoopEXPR";
		return self.bless(
			:content(
				:statement_mod_loop(
					StatementModLoop.new(
						$parsed.hash.<statement_mod_loop>
					)
				),
				:EXPR(
					EXPR.new(
						$parsed.hash.<EXPR>
					)
				)
			)
		)
	}
}

class Statement does Node {
	method new( Mu $parsed ) {
		trace "Statement";
		if $parsed.list {
			my @child;
			for $parsed.list {
				if assert-hash-keys( $_, [< statement_mod_loop EXPR >] ) {
					@child.push(
						StatementModLoopEXPR.new(
							$_
						)
					);
					next
				}
				if assert-hash-keys( $_, [< EXPR >] ) {
					@child.push(
						EXPR.new(
							$_.hash.<EXPR>
						)
					);
					next
				}
				if assert-hash-keys( $_, [< statement_control >] ) {
					@child.push(
						StatementControl.new(
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

class Op does Node {
	method new( Mu $parsed ) {
		trace "Op";
		if assert-hash-keys( $parsed, [< infix OPER >] ) {
			return self.bless(
				:content(
					:infix(
						Infix.new(
							$parsed.hash.<infix>
						)
					),
					:OPER(
						OPER.new(
							$parsed.hash.<OPER>
						)
					)
				)
			)
		}
		die debug( 'op', $parsed );
	}
}

class MoreName does Node {
	method new( Mu $parsed ) {
		trace "MoreName";
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
						EXPR.new(
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

class PackageDeclarator does Node {
	method new( Mu $parsed ) {
		trace  "PackageDeclarator";
		if assert-hash-keys( $parsed, [< sym package_def >] ) {
			return self.bless(
				:content(
					:sym(
						Sym.new(
							$parsed.hash.<sym>
						)
					),
					:package_def(
						PackageDef.new(
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
