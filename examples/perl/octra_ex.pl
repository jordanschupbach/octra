use strict;
use warnings;

use Octra;

Octra::hello();

my $dp = Octra::DPair->new(1.0, 2.0);
print "DPair: First=" . $dp->swig_first_get() . ", Second=" . $dp->swig_second_get() . "\n";
