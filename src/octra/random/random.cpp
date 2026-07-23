#include <octra/random/random.hpp>

namespace octra::random {

std::uint64_t splitmix64_next(std::uint64_t& state) noexcept {
  state += 0x9e3779b97f4a7c15ULL;
  std::uint64_t z = state;
  z               = (z ^ (z >> 30U)) * 0xbf58476d1ce4e5b9ULL;
  z               = (z ^ (z >> 27U)) * 0x94d049bb133111ebULL;
  return z ^ (z >> 31U);
}

double splitmix64_runif(std::uint64_t& state) noexcept {
  constexpr double kInvPow2_53 = 0x1.0p-53;
  return static_cast<double>(splitmix64_next(state) >> 11U) * kInvPow2_53;
}

void fill_runif(double* data, std::size_t size, std::uint64_t seed) noexcept {
  if (!data || size == 0) {
    return;
  }

  std::uint64_t state = seed;
  for (std::size_t i = 0; i < size; ++i) {
    data[i] = splitmix64_runif(state);
  }
}

double splitmix64_runif_seeded(std::uint64_t seed) noexcept {
  return splitmix64_runif(seed);
}

} // namespace octra::random
