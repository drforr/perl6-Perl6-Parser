use v6;

use Test;
use Perl6::Parser;

use lib 't/lib/';
use Utils;

plan 23;

my $pp                 = Perl6::Parser.new;
my $*CONSISTENCY-CHECK = True;
my $*FALL-THROUGH      = True;

# number
#
subtest {
  subtest {
    subtest {
      my $source = Q{0};
      my $tree = $pp.to-tree( $source );
      ok has-a( $tree, Perl6::Number ), Q{found token};
      is $pp.to-string( $tree ), $source, Q{formatted};

      done-testing;
    }, Q{no ws};

    subtest {
      my $source = Q{ 0  };
      my $tree = $pp.to-tree( $source );
      ok has-a( $tree, Perl6::Number ), Q{found token};
      is $pp.to-string( $tree ), $source, Q{formatted};

      done-testing;
    }, Q{ws};

    done-testing;
  }, Q{Zero};

  subtest {
    subtest {
      my $source = Q{1};
      my $tree = $pp.to-tree( $source );
      ok has-a( $tree, Perl6::Number ), Q{found token};
      is $pp.to-string( $tree ), $source, Q{formatted};

      done-testing;
    }, Q{no ws};

    subtest {
      my $source = Q{ 1  };
      my $tree = $pp.to-tree( $source );
      ok has-a( $tree, Perl6::Number ), Q{found token};
      is $pp.to-string( $tree ), $source, Q{formatted};

      done-testing;
    }, Q{ws};

    done-testing;
  }, Q{1};

  subtest {
    subtest {
      my $source = Q{-1};
      my $tree = $pp.to-tree( $source );
      ok has-a( $tree, Perl6::Number ), Q{found token};
      is $pp.to-string( $tree ), $source, Q{formatted};

      done-testing;
    }, Q{no ws};

    subtest {
      my $source = Q{ -1  };
      my $tree = $pp.to-tree( $source );
      ok has-a( $tree, Perl6::Number ), Q{found token};
      is $pp.to-string( $tree ), $source, Q{formatted};

      done-testing;
    }, Q{ws};

    done-testing;
  }, Q{-1};

  subtest {
    subtest {
      my $source = Q{1_1};
      my $tree = $pp.to-tree( $source );
      ok has-a( $tree, Perl6::Number ), Q{found token};
      is $pp.to-string( $tree ), $source, Q{formatted};

      done-testing;
    }, Q{no ws};

    subtest {
      my $source = Q{ 1_1  };
      my $tree = $pp.to-tree( $source );
      ok has-a( $tree, Perl6::Number ), Q{found token};
      is $pp.to-string( $tree ), $source, Q{formatted};

      done-testing;
    }, Q{ws};

    done-testing;
  }, Q{1_1};

  subtest {
    subtest {
      my $source = Q{Inf};
      my $tree = $pp.to-tree( $source );
      ok has-a( $tree, Perl6::Infinity ), Q{found token};
      is $pp.to-string( $tree ), $source, Q{formatted};

      done-testing;
    }, Q{no ws};

    subtest {
      my $source = Q{ Inf  };
      my $tree = $pp.to-tree( $source );
      ok has-a( $tree, Perl6::Infinity ), Q{found token};
      is $pp.to-string( $tree ), $source, Q{formatted};

      done-testing;
    }, Q{ws};

    done-testing;
  }, Q{Inf};

  subtest {
    subtest {
      my $source = Q{NaN};
      my $tree = $pp.to-tree( $source );
      ok has-a( $tree, Perl6::NotANumber ), Q{found token};
      is $pp.to-string( $tree ), $source, Q{formatted};

      done-testing;
    }, Q{no ws};

    subtest {
      my $source = Q{ NaN  };
      my $tree = $pp.to-tree( $source );
      ok has-a( $tree, Perl6::NotANumber ), Q{found token};
      is $pp.to-string( $tree ), $source, Q{formatted};

      done-testing;
    }, Q{ws};

    done-testing;
  }, Q{Inf};

  done-testing;
}, Q{decimal};

subtest {
  subtest {
    subtest {
      my $source = Q{0b0};
      my $tree = $pp.to-tree( $source );
      ok has-a( $tree, Perl6::Number ), Q{found token};
      is $pp.to-string( $tree ), $source, Q{formatted};

      done-testing;
    }, Q{no ws};

    subtest {
      my $source = Q{ 0b0  };
      my $tree = $pp.to-tree( $source );
      ok has-a( $tree, Perl6::Number ), Q{found token};
      is $pp.to-string( $tree ), $source, Q{formatted};

      done-testing;
    }, Q{ws};
  }, Q{0b0};

  subtest {
    subtest {
      my $source = Q{0b1};
      my $tree = $pp.to-tree( $source );
      ok has-a( $tree, Perl6::Number ), Q{found token};
      is $pp.to-string( $tree ), $source, Q{formatted};

      done-testing;
    }, Q{no ws};

    subtest {
      my $source = Q{ 0b1  };
      my $tree = $pp.to-tree( $source );
      ok has-a( $tree, Perl6::Number ), Q{found token};
      is $pp.to-string( $tree ), $source, Q{formatted};

      done-testing;
    }, Q{ws};
  }, Q{0b1};

  subtest {
    subtest {
      my $source = Q{-0b1};
      my $tree = $pp.to-tree( $source );
      ok has-a( $tree, Perl6::Number ), Q{found token};
      is $pp.to-string( $tree ), $source, Q{formatted};

      done-testing;
    }, Q{no ws};

    subtest {
      my $source = Q{ -0b1  };
      my $tree = $pp.to-tree( $source );
      ok has-a( $tree, Perl6::Number ), Q{found token};
      is $pp.to-string( $tree ), $source, Q{formatted};

      done-testing;
    }, Q{ws};

    done-testing;
  }, Q{-0b1};

  done-testing;
}, Q{binary};

subtest {
  subtest {
    subtest {
      my $source = Q{0o0};
      my $tree = $pp.to-tree( $source );
      ok has-a( $tree, Perl6::Number ), Q{found token};
      is $pp.to-string( $tree ), $source, Q{formatted};

      done-testing;
    }, Q{no ws};

    subtest {
      my $source = Q{ 0o0  };
      my $tree = $pp.to-tree( $source );
      ok has-a( $tree, Perl6::Number ), Q{found token};
      is $pp.to-string( $tree ), $source, Q{formatted};

      done-testing;
    }, Q{ws};

    done-testing;
  }, Q{0o0};

  subtest {
    subtest {
      my $source = Q{0o1};
      my $tree = $pp.to-tree( $source );
      ok has-a( $tree, Perl6::Number ), Q{found token};
      is $pp.to-string( $tree ), $source, Q{formatted};

      done-testing;
    }, Q{no ws};

    subtest {
      my $source = Q{ 0o1  };
      my $tree = $pp.to-tree( $source );
      ok has-a( $tree, Perl6::Number ), Q{found token};
      is $pp.to-string( $tree ), $source, Q{formatted};

      done-testing;
    }, Q{ws};

    done-testing;
  }, Q{0o1};

  subtest {
    subtest {
      my $source = Q{-0o1};
      my $tree = $pp.to-tree( $source );
      ok has-a( $tree, Perl6::Number ), Q{found token};
      is $pp.to-string( $tree ), $source, Q{formatted};

      done-testing;
    }, Q{no ws};

    subtest {
      my $source = Q{ -0o1  };
      my $tree = $pp.to-tree( $source );
      ok has-a( $tree, Perl6::Number ), Q{found token};
      is $pp.to-string( $tree ), $source, Q{formatted};

      done-testing;
    }, Q{ws};

    done-testing;
  }, Q{-0o1};

  done-testing;
}, Q{octal};

subtest {
  subtest {
    subtest {
      my $source = Q{0d0};
      my $tree = $pp.to-tree( $source );
      ok has-a( $tree, Perl6::Number ), Q{found token};
      is $pp.to-string( $tree ), $source, Q{formatted};

      done-testing;
    }, Q{no ws};

    subtest {
      my $source = Q{ 0d0  };
      my $tree = $pp.to-tree( $source );
      ok has-a( $tree, Perl6::Number ), Q{found token};
      is $pp.to-string( $tree ), $source, Q{formatted};

      done-testing;
    }, Q{ws};

    done-testing;
  }, Q{0d0};

  subtest {
    subtest {
      my $source = Q{0d1};
      my $tree = $pp.to-tree( $source );
      ok has-a( $tree, Perl6::Number ), Q{found token};
      is $pp.to-string( $tree ), $source, Q{formatted};

      done-testing;
    }, Q{no ws};

    subtest {
      my $source = Q{ 0d1  };
      my $tree = $pp.to-tree( $source );
      ok has-a( $tree, Perl6::Number ), Q{found token};
      is $pp.to-string( $tree ), $source, Q{formatted};

      done-testing;
    }, Q{ws};

    done-testing;
  }, Q{0d1};

  subtest {
    subtest {
      my $source = Q{-0d1};
      my $tree = $pp.to-tree( $source );
      ok has-a( $tree, Perl6::Number ), Q{found token};
      is $pp.to-string( $tree ), $source, Q{formatted};

      done-testing;
    }, Q{no ws};

    subtest {
      my $source = Q{ -0d1  };
      my $tree = $pp.to-tree( $source );
      ok has-a( $tree, Perl6::Number ), Q{found token};
      is $pp.to-string( $tree ), $source, Q{formatted};

      done-testing;
    }, Q{ws};

    done-testing;
  }, Q{-0d1};

  done-testing;
}, Q{explicit decimal};

subtest {
  subtest {
    subtest {
      my $source = Q{0};
      my $tree = $pp.to-tree( $source );
      ok has-a( $tree, Perl6::Number ), Q{found token};
      is $pp.to-string( $tree ), $source, Q{formatted};

      done-testing;
    }, Q{no ws};

    subtest {
      my $source = Q{ 0  };
      my $tree = $pp.to-tree( $source );
      ok has-a( $tree, Perl6::Number ), Q{found token};
      is $pp.to-string( $tree ), $source, Q{formatted};

      done-testing;
    }, Q{ws};

    done-testing;
  }, Q{0};

  subtest {
    subtest {
      my $source = Q{1};
      my $tree = $pp.to-tree( $source );
      ok has-a( $tree, Perl6::Number ), Q{found token};
      is $pp.to-string( $tree ), $source, Q{formatted};

      done-testing;
    }, Q{no ws};

    subtest {
      my $source = Q{ 1  };
      my $tree = $pp.to-tree( $source );
      ok has-a( $tree, Perl6::Number ), Q{found token};
      is $pp.to-string( $tree ), $source, Q{formatted};

      done-testing;
    }, Q{ws};

    done-testing;
  }, Q{1};

  subtest {
    subtest {
      my $source = Q{-1};
      my $tree = $pp.to-tree( $source );
      ok has-a( $tree, Perl6::Number ), Q{found token};
      is $pp.to-string( $tree ), $source, Q{formatted};

      done-testing;
    }, Q{no ws};

    subtest {
      my $source = Q{ -1  };
      my $tree = $pp.to-tree( $source );
      ok has-a( $tree, Perl6::Number ), Q{found token};
      is $pp.to-string( $tree ), $source, Q{formatted};

      done-testing;
    }, Q{ws};

    done-testing;
  }, Q{-1};

  done-testing;
}, Q{implicit decimal};

subtest {
  subtest {
    subtest {
      my $source = Q{0x0};
      my $tree = $pp.to-tree( $source );
      ok has-a( $tree, Perl6::Number ), Q{found token};
      is $pp.to-string( $tree ), $source, Q{formatted};

      done-testing;
    }, Q{no ws};

    subtest {
      my $source = Q{ 0x0  };
      my $tree = $pp.to-tree( $source );
      ok has-a( $tree, Perl6::Number ), Q{found token};
      is $pp.to-string( $tree ), $source, Q{formatted};

      done-testing;
    }, Q{ws};

    done-testing;
  }, Q{0x0};

  subtest {
    subtest {
      my $source = Q{0x1};
      my $tree = $pp.to-tree( $source );
      ok has-a( $tree, Perl6::Number ), Q{found token};
      is $pp.to-string( $tree ), $source, Q{formatted};

      done-testing;
    }, Q{no ws};

    subtest {
      my $source = Q{ 0x1  };
      my $tree = $pp.to-tree( $source );
      ok has-a( $tree, Perl6::Number ), Q{found token};
      is $pp.to-string( $tree ), $source, Q{formatted};

      done-testing;
    }, Q{ws};

    done-testing;
  }, Q{0x1};

  subtest {
    subtest {
      my $source = Q{-0x1};
      my $tree = $pp.to-tree( $source );
      ok has-a( $tree, Perl6::Number ), Q{found token};
      is $pp.to-string( $tree ), $source, Q{formatted};

      done-testing;
    }, Q{no ws};

    subtest {
      my $source = Q{ -0x1  };
      my $tree = $pp.to-tree( $source );
      ok has-a( $tree, Perl6::Number ), Q{found token};
      is $pp.to-string( $tree ), $source, Q{formatted};

      done-testing;
    }, Q{ws};

    done-testing;
  }, Q{-0x1};

  done-testing;
}, Q{hexadecimal};

subtest {
  subtest {
    subtest {
      my $source = Q{:13(0)};
      my $tree = $pp.to-tree( $source );
      ok has-a( $tree, Perl6::Number ), Q{found token};
      is $pp.to-string( $tree ), $source, Q{formatted};

      done-testing;
    }, Q{no ws};

    subtest {
      my $source = Q{ :13(0)  };
      my $tree = $pp.to-tree( $source );
      ok has-a( $tree, Perl6::Number ), Q{found token};
      is $pp.to-string( $tree ), $source, Q{formatted};

      done-testing;
    }, Q{ws};

    done-testing;
  }, Q{:13(0)};

  subtest {
    subtest {
      my $source = Q{:13(1)};
      my $tree = $pp.to-tree( $source );
      ok has-a( $tree, Perl6::Number ), Q{found token};
      is $pp.to-string( $tree ), $source, Q{formatted};

      done-testing;
    }, Q{no ws};

    subtest {
      my $source = Q{ :13(1)  };
      my $tree = $pp.to-tree( $source );
      ok has-a( $tree, Perl6::Number ), Q{found token};
      is $pp.to-string( $tree ), $source, Q{formatted};

      done-testing;
    }, Q{ws};

    done-testing;
  }, Q{:13(1)};

  subtest {
    subtest {
      my $source = Q{:13(-1)};
      my $tree = $pp.to-tree( $source );
      ok has-a( $tree, Perl6::Number ), Q{found token};
      is $pp.to-string( $tree ), $source, Q{formatted};

      done-testing;
    }, Q{no ws};

    subtest {
      my $source = Q{ :13(-1)  };
      my $tree = $pp.to-tree( $source );
      ok has-a( $tree, Perl6::Number ), Q{found token};
      is $pp.to-string( $tree ), $source, Q{formatted};

      done-testing;
    }, Q{ws};

    done-testing;
  }, Q{:13(-1)};

  done-testing;
}, Q{radix};

subtest {
  subtest {
    subtest {
      my $source = Q{0e0};
      my $tree = $pp.to-tree( $source );
      ok has-a( $tree, Perl6::Number ), Q{found token};
      is $pp.to-string( $tree ), $source, Q{formatted};

      done-testing;
    }, Q{no ws};

    subtest {
      my $source = Q{ 0e0  };
      my $tree = $pp.to-tree( $source );
      ok has-a( $tree, Perl6::Number ), Q{found token};
      is $pp.to-string( $tree ), $source, Q{formatted};

      done-testing;
    }, Q{ws};

    done-testing;
  }, Q{0e0};

  subtest {
    subtest {
      my $source = Q{0e1};
      my $tree = $pp.to-tree( $source );
      ok has-a( $tree, Perl6::Number ), Q{found token};
      is $pp.to-string( $tree ), $source, Q{formatted};

      done-testing;
    }, Q{no ws};

    subtest {
      my $source = Q{ 0e1  };
      my $tree = $pp.to-tree( $source );
      ok has-a( $tree, Perl6::Number ), Q{found token};
      is $pp.to-string( $tree ), $source, Q{formatted};

      done-testing;
    }, Q{ws};

    done-testing;
  }, Q{0e1};

  subtest {
    subtest {
      my $source = Q{-0e1};
      my $tree = $pp.to-tree( $source );
      ok has-a( $tree, Perl6::Number ), Q{found token};
      is $pp.to-string( $tree ), $source, Q{formatted};

      done-testing;
    }, Q{no ws};

    subtest {
      my $source = Q{ -0e1  };
      my $tree = $pp.to-tree( $source );
      ok has-a( $tree, Perl6::Number ), Q{found token};
      is $pp.to-string( $tree ), $source, Q{formatted};

      done-testing;
    }, Q{ws};

    done-testing;
  }, Q{-0e1};

  subtest {
    subtest {
      my $source = Q{0e-1};
      my $tree = $pp.to-tree( $source );
      ok has-a( $tree, Perl6::Number ), Q{found token};
      is $pp.to-string( $tree ), $source, Q{formatted};

      done-testing;
    }, Q{no ws};

    subtest {
      my $source = Q{ 0e-1  };
      my $tree = $pp.to-tree( $source );
      ok has-a( $tree, Perl6::Number ), Q{found token};
      is $pp.to-string( $tree ), $source, Q{formatted};

      done-testing;
    }, Q{ws};

    done-testing;
  }, Q{-0e1};

  done-testing;
}, Q{scientific};

subtest {
  subtest {
    subtest {
      my $source = Q{0i};
      my $tree = $pp.to-tree( $source );
      ok has-a( $tree, Perl6::Number ), Q{found token};
      is $pp.to-string( $tree ), $source, Q{formatted};

      done-testing;
    }, Q{no ws};

    subtest {
      my $source = Q{ 0i  };
      my $tree = $pp.to-tree( $source );
      ok has-a( $tree, Perl6::Number ), Q{found token};
      is $pp.to-string( $tree ), $source, Q{formatted};

      done-testing;
    }, Q{ws};

    done-testing;
  }, Q{0i};

  subtest {
    subtest {
      my $source = Q{1i};
      my $tree = $pp.to-tree( $source );
      ok has-a( $tree, Perl6::Number ), Q{found token};
      is $pp.to-string( $tree ), $source, Q{formatted};

      done-testing;
    }, Q{no ws};

    subtest {
      my $source = Q{ 1i  };
      my $tree = $pp.to-tree( $source );
      ok has-a( $tree, Perl6::Number ), Q{found token};
      is $pp.to-string( $tree ), $source, Q{formatted};

      done-testing;
    }, Q{ws};

    done-testing;
  }, Q{1i};

  subtest {
    subtest {
      my $source = Q{-1i};
      my $tree = $pp.to-tree( $source );
      ok has-a( $tree, Perl6::Number ), Q{found token};
      is $pp.to-string( $tree ), $source, Q{formatted};

      done-testing;
    }, Q{no ws};

    subtest {
      my $source = Q{ -1i  };
      my $tree = $pp.to-tree( $source );
      ok has-a( $tree, Perl6::Number ), Q{found token};
      is $pp.to-string( $tree ), $source, Q{formatted};

      done-testing;
    }, Q{ws};

    done-testing;
  }, Q{-1i};

  done-testing;
}, Q{imaginary};

# variable
#
subtest {
  subtest {
    my $source = Q{@*ARGS};
    my $tree = $pp.to-tree( $source );
    ok has-a( $tree, Perl6::Variable ), Q{found token};
    is $pp.to-string( $tree ), $source, Q{formatted}; 

    done-testing;
  }, Q{no ws};

  subtest {
    my $source = Q{ @*ARGS  };
    my $tree = $pp.to-tree( $source );
    ok has-a( $tree, Perl6::Variable ), Q{found token};
    is $pp.to-string( $tree ), $source, Q{formatted};

    done-testing;
  }, Q{ws};

  done-testing;
}, Q{@*ARGS (is a global, so available everywhere)};

subtest {
  subtest {
    my $source = Q{$};
    my $tree = $pp.to-tree( $source );
    ok has-a( $tree, Perl6::Variable ), Q{found token};
    is $pp.to-string( $tree ), $source, Q{formatted};

    done-testing;
  }, Q{no ws};

  subtest {
    my $source = Q{ $  };
    my $tree = $pp.to-tree( $source );
    ok has-a( $tree, Perl6::Variable ), Q{found token};
    is $pp.to-string( $tree ), $source, Q{formatted};

    done-testing;
  }, Q{ws};

  done-testing;
}, Q{$};

subtest {
  subtest {
    my $source = Q{$_};
    my $tree = $pp.to-tree( $source );
    ok has-a( $tree, Perl6::Variable ), Q{found token};
    is $pp.to-string( $tree ), $source, Q{formatted};

    done-testing;
  }, Q{no ws};

  subtest {
    my $source = Q{ $_  };
    my $tree = $pp.to-tree( $source );
    ok has-a( $tree, Perl6::Variable ), Q{found token};
    is $pp.to-string( $tree ), $source, Q{formatted};

    done-testing;
  }, Q{ws};

  done-testing;
}, Q{$_};

subtest {
  subtest {
    my $source = Q{$/};
    my $tree = $pp.to-tree( $source );
    ok has-a( $tree, Perl6::Variable ), Q{found token};
    is $pp.to-string( $tree ), $source, Q{formatted};

    done-testing;
  }, Q{no ws};

  subtest {
    my $source = Q{ $/  };
    my $tree = $pp.to-tree( $source );
    ok has-a( $tree, Perl6::Variable ), Q{found token};
    is $pp.to-string( $tree ), $source, Q{formatted};

    done-testing;
  }, Q{ws};

  done-testing;
}, Q{$/};

subtest {
  subtest {
    my $source = Q{$!};
    my $tree = $pp.to-tree( $source );
    ok has-a( $tree, Perl6::Variable ), Q{found token};
    is $pp.to-string( $tree ), $source, Q{formatted};

    done-testing;
  }, Q{no ws};

  subtest {
    my $source = Q{ $!  };
    my $tree = $pp.to-tree( $source );
    ok has-a( $tree, Perl6::Variable ), Q{found token};
    is $pp.to-string( $tree ), $source, Q{formatted};

    done-testing;
  }, Q{ws};

  done-testing;
}, Q{$!};

subtest {
  subtest {
    my $source = Q{$Foo::Bar};
    my $tree = $pp.to-tree( $source );
    ok has-a( $tree, Perl6::Variable ), Q{found token};
    is $pp.to-string( $tree ), $source, Q{formatted};

    done-testing;
  }, Q{no ws};

  subtest {
    my $source = Q{ $Foo::Bar  };
    my $tree = $pp.to-tree( $source );
    ok has-a( $tree, Perl6::Variable ), Q{found token};
    is $pp.to-string( $tree ), $source, Q{formatted};

    done-testing;
  }, Q{ws};


  done-testing;
}, Q{$Foo::Bar};

subtest {
  subtest {
    my $source = Q{&sum};
    my $tree = $pp.to-tree( $source );
    is $pp.to-string( $tree ), $source, Q{formatted};

    done-testing;
  }, Q{no ws};

  subtest {
    my $source = Q{ &sum  };
    my $tree = $pp.to-tree( $source );
    is $pp.to-string( $tree ), $source, Q{formatted};

    done-testing;
  }, Q{ws};

  done-testing;
}, Q{&sum};

subtest {
  subtest {
    my $source = Q{$Foo::($*GLOBAL)::Bar};
    my $tree = $pp.to-tree( $source );
    ok has-a( $tree, Perl6::Variable ), Q{found token};
    is $pp.to-string( $tree ), $source, Q{formatted};

    done-testing;
  }, Q{no ws};

  subtest {
    my $source = Q{ $Foo::($*GLOBAL)::Bar  };
    my $tree = $pp.to-tree( $source );
    ok has-a( $tree, Perl6::Variable ), Q{found token};
    is $pp.to-string( $tree ), $source, Q{formatted};

    done-testing;
  }, Q{ws};

  done-testing;
}, Q[$Foo::($*GLOBAL)::Bar];

# type
#
subtest {
  subtest {
    my $source = Q{Int};
    my $tree = $pp.to-tree( $source );
# XXX Probably shouldn't be a bareword...
#    ok (grep { $_ ~~ Perl6::Number },
#       $tree.child.[0].child),
#       Q{found number};
    is $pp.to-string( $tree ), $source, Q{formatted};

    done-testing;
  }, Q{no ws};

  subtest {
    my $source = Q{ Int  };
    my $tree = $pp.to-tree( $source );
# XXX Probably shouldn't be a bareword...
#    ok (grep { $_ ~~ Perl6::Number },
#       $tree.child.[0].child),
#       Q{found number};
    is $pp.to-string( $tree ), $source, Q{formatted};

    done-testing;
  }, Q{ws};

  done-testing;
}, Q{Int};

subtest {
  subtest {
    my $source = Q{IO::Handle};
    my $tree = $pp.to-tree( $source );
# XXX Probably shouldn't be a bareword...
#    ok (grep { $_ ~~ Perl6::Number },
#       $tree.child.[0].child),
#       Q{found number};
    is $pp.to-string( $tree ), $source, Q{formatted};

    done-testing;
  }, Q{no ws};

  subtest {
    my $source = Q{ IO::Handle  };
    my $tree = $pp.to-tree( $source );
# XXX Probably shouldn't be a bareword...
#    ok (grep { $_ ~~ Perl6::Number },
#       $tree.child.[0].child),
#       Q{found number};
    is $pp.to-string( $tree ), $source, Q{formatted};

    done-testing;
  }, Q{ws};

  done-testing;
}, Q{IO::Handle (Two package names)};

# constant
#
subtest {
  subtest {
    my $source = Q{pi};
    my $tree = $pp.to-tree( $source );
# XXX Probably shouldn't be a bareword...
#    ok (grep { $_ ~~ Perl6::Number },
#       $tree.child.[0].child),
#       Q{found number};
    is $pp.to-string( $tree ), $source, Q{formatted};

    done-testing;
  }, Q{no ws};

  subtest {
    my $source = Q{ pi  };
    my $tree = $pp.to-tree( $source );
# XXX Probably shouldn't be a bareword...
#    ok (grep { $_ ~~ Perl6::Number },
#       $tree.child.[0].child),
#       Q{found number};
    is $pp.to-string( $tree ), $source, Q{formatted};

    done-testing;
  }, Q{ws};

  done-testing;
}, Q{pi};

# function call
#
subtest {
  subtest {
    my $source = Q{sum};
    my $tree = $pp.to-tree( $source );
#    ok (grep { $_ ~~ Perl6::Number },
#       $tree.child.[0].child),
#       Q{found number};
    is $pp.to-string( $tree ), $source, Q{formatted};

    done-testing;
  }, Q{no ws};

  subtest {
    my $source = Q{ sum  };
    my $tree = $pp.to-tree( $source );
#    ok (grep { $_ ~~ Perl6::Number },
#       $tree.child.[0].child),
#       Q{found number};
    is $pp.to-string( $tree ), $source, Q{formatted};

    done-testing;
  }, Q{ws};

  done-testing;
}, Q{sum};

# operators
#
subtest {
  subtest {
    my $source = Q{()};
    my $tree = $pp.to-tree( $source );
#    ok (grep { $_ ~~ Perl6::Number },
#       $tree.child.[0].child),
#       Q{found number};
    is $pp.to-string( $tree ), $source, Q{formatted};

    done-testing;
  }, Q{no ws};

  subtest {
    my $source = Q{ ()  };
    my $tree = $pp.to-tree( $source );
#    ok (grep { $_ ~~ Perl6::Number },
#       $tree.child.[0].child),
#       Q{found number};
    is $pp.to-string( $tree ), $source, Q{formatted};

    done-testing;
  }, Q{ws};

  done-testing;
}, Q{circumfix};

# :foo (adverbial-pair) is already tested in t/pair.t

# signature
#
subtest {
  subtest {
    my $source = Q{:()};
    my $tree = $pp.to-tree( $source );
#    ok (grep { $_ ~~ Perl6::Number },
#       $tree.child.[0].child),
#       Q{found number};
    is $pp.to-string( $tree ), $source, Q{formatted};

    done-testing;
  }, Q{no ws};

  subtest {
    my $source = Q{ :()  };
    my $tree = $pp.to-tree( $source );
#    ok (grep { $_ ~~ Perl6::Number },
#       $tree.child.[0].child),
#       Q{found number};
    is $pp.to-string( $tree ), $source, Q{formatted};

    done-testing;
  }, Q{ws};

  done-testing;
}, Q{:()};

done-testing;

# vim: ft=perl6
