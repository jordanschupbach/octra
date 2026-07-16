#include <algorithm>
#include <chrono>
#include <cstddef>
#include <cstdint>
#include <cstdlib>
#include <iomanip>
#include <iostream>
#include <numeric>
#include <octra/random/random.hpp>
#include <string_view>
#include <vector>

namespace {

struct BenchmarkCase {
  std::size_t      size;
  std::string_view label;
};

void run_case(const BenchmarkCase& bench_case, int iterations) {
  std::vector<double> buffer(bench_case.size);
  std::vector<double> samples;
  samples.reserve(static_cast<std::size_t>(iterations));

  std::uint64_t seed = 0x123456789abcdef0ULL;
  for (int i = 0; i < iterations; ++i) {
    const auto start = std::chrono::steady_clock::now();
    octra::random::fill_runif(buffer.data(), buffer.size(), seed + static_cast<std::uint64_t>(i));
    const auto stop    = std::chrono::steady_clock::now();
    const auto elapsed = std::chrono::duration<double, std::nano>(stop - start).count();
    samples.push_back(elapsed / static_cast<double>(bench_case.size));
  }

  std::sort(samples.begin(), samples.end());
  const double median_ns_per_value = samples[samples.size() / 2];
  const double values_per_second   = 1e9 / median_ns_per_value;
  const double checksum = std::accumulate(buffer.begin(), buffer.end(), 0.0);

  std::cout << bench_case.label << '\t' << bench_case.size << '\t' << std::fixed
            << std::setprecision(3) << median_ns_per_value << '\t' << std::setprecision(0)
            << values_per_second << '\t' << std::setprecision(6) << checksum << '\n';
}

} // namespace

int main(int argc, char** argv) {
  int iterations = 25;
  if (argc > 1) {
    iterations = std::max(1, std::atoi(argv[1]));
  }

  const std::vector<BenchmarkCase> cases{
      {1 << 10, "splitmix64_fill_runif"},
      {1 << 16, "splitmix64_fill_runif"},
      {1 << 20, "splitmix64_fill_runif"},
  };

  std::cout << "name\tsize\tmedian_ns_per_value\tvalues_per_second\tchecksum\n";
  for (const auto& bench_case : cases) {
    run_case(bench_case, iterations);
  }

  return 0;
}
