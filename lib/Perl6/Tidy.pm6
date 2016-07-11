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

class Perl6::Tidy {
	use nqp;

	role Node {
		has $.name;
		has $.child;
		has %.content;
	}

	class BinInt does Node {
		method new( Mu $parsed ) {
			if assert-Int( $parsed ) {
				return self.bless( :name( $parsed.Int ) )
			}
			die debug( 'binint', $parsed );
		}
	}

	class OctInt does Node {
		method new( Mu $parsed ) {
			if assert-Int( $parsed ) {
				return self.bless( :name( $parsed.Int ) )
			}
			die debug( 'octint', $parsed );
		}
	}

	class DecInt does Node {
		method new( Mu $parsed ) {
#die dump-parsed($parsed);
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
			if assert-Int( $parsed ) {
				return self.bless( :name( $parsed.Int ) )
			}
			die debug( 'hexint', $parsed );
		}
	}

	class Coeff does Node {
		method new( Mu $parsed ) {
			if assert-Int( $parsed ) {
				return self.bless( :name( $parsed.Int ) )
			}
			die debug( 'coeff', $parsed );
		}
	}

	class Frac does Node {
		method new( Mu $parsed ) {
			if assert-Int( $parsed ) {
				return self.bless( :name( $parsed.Int ) )
			}
			die debug( 'frac', $parsed );
		}
	}

	class NormSpace does Node {
		method new( Mu $parsed ) {
			if assert-Str( $parsed ) {
				return self.bless( :name( $parsed.Str ) )
			}
			die debug( 'normspace', $parsed );
		}
	}

	class Radix does Node {
		method new( Mu $parsed ) {
			if assert-Int( $parsed ) {
				return self.bless( :name( $parsed.Int ) )
			}
			die debug( 'radix', $parsed );
		}
	}

	class _Int does Node {
		method new( Mu $parsed ) {
			if assert-Int( $parsed ) {
				return self.bless( :name( $parsed.Int ) )
			}
			die debug( 'int', $parsed );
		}
	}

	class VALUE does Node {
		method new( Mu $parsed ) {
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

	class Sigil does Node {
		method new( Mu $parsed ) {
			if assert-Str( $parsed ) {
				return self.bless( :name( $parsed.Str ) )
			}
			die debug( 'sigil', $parsed );
		}
	}

	class Sign does Node {
		method new( Mu $parsed ) {
			if assert-Bool( $parsed ) {
				return self.bless( :name( $parsed.Bool ) )
			}
			die debug( 'sign', $parsed );
		}
	}

	class EScale does Node {
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

		self.root( $parsed )
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

	class Root does Node {
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

	class VStr does Node {
		method new( Mu $parsed ) {
			if $parsed.Int {
				return self.bless( :name( $parsed.Int ) )
			}
			die debug( 'vstr', $parsed );
		}
	}

	class VNum does Node {
		method new( Mu $parsed ) {
			if $parsed.list {
				return self.bless( :child() )
			}
			die debug( 'vnum', $parsed );
		}
	}

	class Version does Node {
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

	class Doc does Node {
		method new( Mu $parsed ) {
			if assert-Bool( $parsed ) {
				return self.bless( :name( $parsed.Bool ) )
			}
			die debug( 'doc', $parsed );
		}
	}

	class Identifier does Node {
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

	class Name does Node {
		method new( Mu $parsed ) {
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

	class StatementControl does Node {
		method new( Mu $parsed ) {
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

	class Statement does Node {
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
						StatementControl.new(
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
		die debug( 'statement', $parsed );
	}

	class O does Node {
		method new( Mu $parsed ) {
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
			die debug( 'prefix', $parsed );
		}
	}

	class Infix does Node {
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
			die debug( 'infix', $parsed );
		}
	}

	class Args does Node {
		method new( Mu $parsed ) {
			if $parsed.Bool {
				return self.bless( :name( $parsed.Bool ) )
			}
			die debug( 'args', $parsed );
		}
	}

	class MethodOp does Node {
		method new( Mu $parsed ) {
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

	class DottyOp does Node {
		method new( Mu $parsed ) {
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
			die debug( 'dottyop', $parsed );
		}
	}

	# "forward" declaration, sigh.
	class InfixIsh {...}

	class OPER does Node {
		method new( Mu $parsed ) {
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
			die debug( 'OPER', $parsed );
		}
	}

	class Op does Node {
		method new( Mu $parsed ) {
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

	class InfixIsh does Node {
		method new( Mu $parsed ) {
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

	class MoreName does Node {
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

	class Signature does Node {
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

	class Twigil does Node {
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
		method new( Mu $parsed ) {
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

	class Variable does Node {
		method new( Mu $parsed ) {
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
			elsif assert-hash-keys( $parsed, [< sigil desigilname >] ) {
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
			elsif assert-hash-keys( $parsed, [< sigil >] ) {
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

	class RoutineDeclarator does Node {
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

	class DefLongName does Node {
		method new( Mu $parsed ) {
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
		method new( Mu $parsed ) {
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

	class RoutineDef does Node {
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

	class PackageDef does Node {
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
			return PackageDef.new(
				:content(
					:longname(
						LongName.new(
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

	class Blockoid does Node {
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

	class Dotty does Node {
		method new( Mu $parsed ) {
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

	class SemiList does Node {
		method new( Mu $parsed ) {
			if assert-hash-keys( $parsed, [], [< statement >] ) {
				return self.bless
			}
			die debug( 'semilist', $parsed );
		}
	}

	class Circumfix does Node {
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
		method new( Mu $parsed ) {
			if assert-Bool( $parsed ) {
				return self.bless( :name( $parsed.Bool ) )
			}
			die debug( 'B', $parsed );
		}
	}

	class Babble does Node {
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

	# XXX This is a compound type
	class IdentifierArgs does Node {
		method new( Mu $parsed ) {
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

	class EXPR does Node {
	}

	method EXPR( Mu $parsed ) {
		if $parsed.list {
			my @child;
			for $parsed.list {
				if assert-hash-keys( $_, [< identifier args >] ) {
					@child.push(
						IdentifierArgs.new( $_ )
					);
					next;
				}
				if assert-hash-keys( $_, [< longname args >] ) {
					@child.push(
						LongNameArgs.new( $_ )
					);
					next;
				}
				if assert-hash-keys( $_, [< longname >] ) {
					@child.push(
						LongName.new(
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
				if assert-hash-keys( $_, [< variable >] ) {
					@child.push(
						Variable.new(
							$_.hash.<variable>
						)
					);
					next;
				}
				die dump( $_ );
			}
			if $parsed.hash {
				if assert-hash-keys(
					$parsed,
					[< OPER dotty >],
					[< postfix_prefix_meta_operator >] ) {
					return EXPR.new(
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
					return EXPR.new(
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
					return EXPR.new(
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
					return EXPR.new(
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
					[< OPER >],
					[< infix_prefix_meta_operator >] ) {
					return EXPR.new(
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
				if assert-hash-keys( $parsed, [< longname >] ) {
					return EXPR.new(
						:content(
							:longname(
								LongName.new(
									$parsed.hash.<longname>
								)
							),
						),
						:child( @child )
					)
				}
				die debug( 'EXPR', $parsed )
			}
			else {
				return EXPR.new(
					:child( @child )
				)
			}
		}
		if assert-hash-keys( $parsed, [< args op >] ) {
			return EXPR.new(
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
			return EXPR.new(
				:child( 
					Sym.new(
						$parsed.hash.<sym>
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
		if assert-hash-keys( $parsed, [< longname args >] ) {
			return EXPR.new(
				:child( 
					LongName.new(
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
					LongName.new(
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
						Variable.new(
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
						RegexDeclarator.new(
							$parsed.hash.<regex_declarator>
						)
					)
				)
			)
		}
		die debug( 'EXPR', $parsed );
	}

	class PostConstraint does Node {
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
				die debug( 'post_constraint', $_ );
			}
			return PostConstraint.new(
				:child( @child )
			)
		}
		die debug( 'post_constraint', $parsed );
	}

	class VariableDeclarator does Node {
		method new( Mu $parsed ) {
			if assert-hash-keys(
				$parsed,
				[< variable >],
				[< semilist postcircumfix signature trait post_constraint >] ) {
				return self.bless(
					:content(
						:variable(
							Variable.new(
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

	class MultiDeclarator does Node {
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
			return Declarator.new(
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
			return Declarator.new(
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

	class DECL does Node {
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
			return DECL.new(
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
			return DECL.new(
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
		if assert-hash-keys( $parsed, [< declarator >] ) {
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

	class TypeName_INTERMEDIARY does Node {
	}

	class TypeName does Node {
		method new( Mu $parsed ) {
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
						next;
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

	class Scoped is Node {
	}

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
						TypeName.new(
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
