use strict;
use warnings;

use ExtUtils::MakeMaker;
use Config;

my $octra_root = "$ENV{PWD}/../..";
my $include_dir = "$octra_root/include";
my $lib_dir = "$octra_root/build";

WriteMakefile(
  NAME         => 'Octra',
  VERSION      => '0.0.1',
  PM           => { 'lib/Octra.pm' => '$(INST_LIBDIR)/Octra.pm' },
  OBJECT       => 'Octra_wrap$(OBJ_EXT)',
  INC          => "-I$include_dir",
  LIBS         => [ "-L$lib_dir -loctra" ],
  dynamic_lib  => { OTHERLDFLAGS => $Config{lddlflags} },
  clean        => { FILES => 'Octra_wrap.* Octra.pm lib/Octra.pm' },
);

