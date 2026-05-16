use strict;
use warnings;

use Test::More;

use Octra;

ok(1, "Loaded Octra module");

Octra::hello();

my $dp = Octra::DPair->new(1.0, 2.0);
is($dp->swig_first_get(), 1.0, "DPair first");
is($dp->swig_second_get(), 2.0, "DPair second");

done_testing();
