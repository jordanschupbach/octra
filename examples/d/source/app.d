module app;

import std.stdio : writeln;
import octra;

void main() {
  hello();

  auto vec = make_dvector(1.0, 2.0, 3.0);
  writeln("sum_dvector(1,2,3) = ", sum_dvector(vec));

  auto pair = make_dpair(4.0, 5.0);
  writeln("sum_dpair(4,5) = ", sum_dpair(pair));
}

