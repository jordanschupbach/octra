module app;

import octra;

unittest {
  hello();

  auto vec = make_dvector(1.0, 2.0, 3.0);
  assert(sum_dvector(vec) == 6.0);

  auto pair = make_dpair(1.0, 2.0);
  assert(sum_dpair(pair) == 3.0);
}

void main() {}

