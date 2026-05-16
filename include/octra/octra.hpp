#include <utility>
#include <vector>

namespace octra {

void hello();

// Small STL-shaped API surface so SWIG bindings can exercise std::vector/std::pair.
std::vector<double> make_dvector(double a, double b, double c);
double sum_dvector(const std::vector<double>& values);

std::pair<double, double> make_dpair(double a, double b);
double sum_dpair(const std::pair<double, double>& values);

} // namespace octra
